CREATE OR REPLACE PACKAGE BODY awlrs_asset_maint_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_asset_maint_api.pkb-arc   1.12   Sep 02 2020 14:23:04   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_asset_maint_api.pkb  $
  --       Date into PVCS   : $Date:   Sep 02 2020 14:23:04  $
  --       Date fetched Out : $Modtime:   Sep 01 2020 17:22:12  $
  --       Version          : $Revision:   1.12  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.12  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_asset_maint_api';
  --
  TYPE attr_name_tab IS TABLE OF nm_inv_type_attribs_all.ita_attrib_name%TYPE INDEX BY BINARY_INTEGER;
  gt_attr_names  attr_name_tab;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN g_sccsid;
  END get_version;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nlt(pi_nlt_nt_type  IN nm_linear_types.nlt_nt_type%TYPE
                  ,pi_nlt_gty_type IN nm_linear_types.nlt_gty_type%TYPE)
    RETURN nm_linear_types%ROWTYPE IS
    --
    CURSOR cs_nlt(cp_nlt_nt_type  IN nm_linear_types.nlt_nt_type%TYPE
                 ,cp_nlt_gty_type IN nm_linear_types.nlt_gty_type%TYPE)
        IS
    SELECT /*+ INDEX (nlt NLT_UK) */ *
      FROM nm_linear_types nlt
     WHERE nlt.nlt_nt_type = cp_nlt_nt_type
       AND NVL(nlt.nlt_gty_type,'~~~~~') = NVL(cp_nlt_gty_type,'~~~~~')
         ;
    --
    lr_retval nm_linear_types%ROWTYPE;
    --
  BEGIN
    --
    OPEN  cs_nlt(pi_nlt_nt_type
                ,pi_nlt_gty_type);
    FETCH cs_nlt
     INTO lr_retval;
    CLOSE cs_nlt;
    --
    RETURN lr_retval;
    --
  END get_nlt;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_types(po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asset_type_code
          ,asset_type_description
          ,asset_category
          ,admin_type
          ,ft_asset_type
          ,off_network
          ,loc_types
          ,multiple_locs_allowed
          ,xsp_allowed
          ,top_of_hierarchy
          ,hierarchy_relation
          ,child_inv_types
          ,is_editable
          ,alim_doc_man_url
          ,asset_point_or_continuous
      FROM (SELECT it1.nit_inv_type asset_type_code
                  ,it1.nit_inv_type||' - '||it1.nit_descr asset_type_description
                  ,it1.nit_category asset_category
                  ,it1.nit_admin_type admin_type
                  ,CASE WHEN it1.nit_table_name IS NOT NULL THEN 'Y' ELSE 'N' END ft_asset_type
                  ,it1.nit_use_xy off_network
                  ,awlrs_map_api.get_asset_loc_types(pi_inv_type => it1.nit_inv_type) loc_types
                  ,it1.nit_multiple_allowed multiple_locs_allowed
                  ,it1.nit_x_sect_allow_flag xsp_allowed
                  ,it1.nit_top top_of_hierarchy
                  ,(SELECT itg_relation
                      FROM nm_inv_type_groupings
                     WHERE itg_inv_type = it1.nit_inv_type) hierarchy_relation
                  ,(SELECT LISTAGG(it2.nit_inv_type, ',') WITHIN GROUP (ORDER BY it2.nit_inv_type)
                      FROM nm_inv_types it2
                     WHERE it2.nit_table_name IS NULL
                       AND it2.nit_update_allowed = 'Y'
                       AND EXISTS (SELECT 1
                                     FROM hig_user_roles ur
                                         ,nm_inv_type_roles ir
                                         ,nm_user_aus usr
                                         ,nm_admin_units au
                                         ,nm_admin_groups nag
                                         ,hig_users hus
                                    WHERE hus.hus_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
                                      AND ur.hur_role = ir.itr_hro_role
                                      AND ur.hur_username = hus.hus_username
                                      AND ir.itr_inv_type = nit_inv_type
                                      AND usr.nua_admin_unit = au.nau_admin_unit
                                      AND au.nau_admin_unit = nag_child_admin_unit
                                      AND au.nau_admin_type = nit_admin_type
                                      AND usr.nua_admin_unit = nag_parent_admin_unit
                                      AND usr.nua_user_id = hus.hus_user_id)
                       AND it2.nit_inv_type IN(SELECT itg_inv_type
                                                 FROM nm_inv_type_groupings
                                                WHERE itg_parent_inv_type = it1.nit_inv_type
                                                  AND itg_parent_inv_type != itg_inv_type)) child_inv_types
                  ,(SELECT 'Y' editable
                      FROM dual
                     WHERE it1.nit_update_allowed = 'Y'
                       AND it1.nit_table_name IS NULL
                       AND awlrs_util.inv_category_is_updatable(it1.nit_category) = 'TRUE'
                       AND EXISTS(SELECT 1
                                    FROM hig_user_roles
                                        ,nm_inv_type_roles
                                   WHERE itr_inv_type = it1.nit_inv_type
                                     AND itr_mode = 'NORMAL'
                                     AND itr_hro_role = hur_role
                                     AND hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME'))
                       AND EXISTS(SELECT 1
                                    FROM nm_user_aus
                                        ,nm_admin_units
                                   WHERE nua_user_id = SYS_CONTEXT('NM3CORE','USER_ID')
                                     AND nua_mode = 'NORMAL'
                                     AND nua_admin_unit = nau_admin_unit
                                     AND nau_admin_type = it1.nit_admin_type)) is_editable
                  ,awlrs_alim_doc_man_api.get_url_template(pi_table_name => CASE WHEN nit_table_name IS NOT NULL THEN nit_table_name ELSE 'NM_INV_ITEMS' END) alim_doc_man_url
                  ,it1.nit_pnt_or_cont asset_point_or_continuous
              FROM nm_inv_types it1
             WHERE it1.nit_category IN('I','P') --IN ('I','P','F') will support FT when LB is fixed.
               AND it1.nit_use_xy = 'N'
               AND EXISTS (SELECT 1
                             FROM hig_users hus
                                 ,hig_user_roles ur
                                 ,nm_inv_type_roles ir
                                 ,nm_user_aus usr
                                 ,nm_admin_units au
                                 ,nm_admin_groups nag
                            WHERE hus.hus_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
                              AND hus.hus_username = ur.hur_username
                              AND ur.hur_role = ir.itr_hro_role
                              AND ir.itr_inv_type = it1.nit_inv_type
                              AND usr.nua_admin_unit = au.nau_admin_unit
                              AND au.nau_admin_unit = nag_child_admin_unit
                              AND au.nau_admin_type = nit_admin_type
                              AND usr.nua_admin_unit = nag_parent_admin_unit
                              AND usr.nua_user_id = hus.hus_user_id)
               AND EXISTS(SELECT 'x'
                            FROM nm_inv_nw_all
                           WHERE nin_nit_inv_code = it1.nit_inv_type)
               AND NOT EXISTS(SELECT 'x'
                                FROM nm_inv_type_groupings
                               WHERE itg_inv_type = it1.nit_inv_type)
            UNION ALL
            SELECT NULL asset_type_code
                  ,'All Asset Types' asset_type_description
                  ,NULL asset_category
                  ,NULL admin_type
                  ,NULL ft_asset_type
                  ,NULL off_network
                  ,NULL loc_types
                  ,NULL multiple_locs_allowed
                  ,NULL xsp_allowed
                  ,NULL top_of_hierarchy
                  ,NULL hierarchy_relation
                  ,NULL child_inv_types
                  ,NULL is_editable
                  ,NULL alim_doc_man_url
                  ,NULL asset_point_or_continuous
              FROM dual)
     ORDER
        BY CASE WHEN asset_type_code IS NULL THEN 1 ELSE 2 END
          ,asset_type_description
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  END get_asset_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_elements(pi_filter           IN  VARCHAR2
                                ,pi_skip_n_rows      IN  PLS_INTEGER
                                ,pi_pagesize         IN  PLS_INTEGER
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_plrm        VARCHAR2(10);
    lv_group_type  nm_group_types_all.ngt_group_type%TYPE;
    --
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2;
    lv_alllrms_sql   nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                  ||CHR(10)||'SELECT id'
                                  ||CHR(10)||'      ,name'
                                  ||CHR(10)||'      ,min_offset'
                                  ||CHR(10)||'      ,max_offset'
                                  ||CHR(10)||'      ,row_count'
                                  ||CHR(10)||'  FROM (SELECT rownum ind'
                                  ||CHR(10)||'              ,results.*'
                                  ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                  ||CHR(10)||'          FROM (SELECT ne_id id'
                                  ||CHR(10)||'                      ,ne_unique||'' - ''||ne_descr name'
                                  ||CHR(10)||'                      ,0 min_offset'
                                  ||CHR(10)||'                      ,ne_length max_offset'
                                  ||CHR(10)||'                      ,CASE'
                                  ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                  ||CHR(10)||'                         WHEN UPPER(ne_unique) = f.filter_value THEN 1'
                                  ||CHR(10)||'                         WHEN UPPER(ne_descr) = f.filter_value THEN 2'
                                  ||CHR(10)||'                         WHEN UPPER(ne_unique) LIKE f.filter_value||''%'' THEN 3'
                                  ||CHR(10)||'                         WHEN UPPER(ne_descr) LIKE f.filter_value||''%'' THEN 4'
                                  ||CHR(10)||'                         ELSE 5'
                                  ||CHR(10)||'                       END match_quality'
                                  ||CHR(10)||'                  FROM nm_elements'
                                  ||CHR(10)||'                      ,filter_tab f'
                                  ||CHR(10)||'                 WHERE ne_type = ''S'''
                                  ||CHR(10)||'                    OR ne_gty_group_type IN(SELECT ngt.ngt_group_type'
                                  ||CHR(10)||'                                              FROM nm_group_types ngt'
                                  ||CHR(10)||'                                             WHERE ngt.ngt_linear_flag = ''Y'')'
    ;
    --
    lv_group_sql  nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                               ||CHR(10)||'SELECT id'
                               ||CHR(10)||'      ,name'
                               ||CHR(10)||'      ,min_offset'
                               ||CHR(10)||'      ,max_offset'
                               ||CHR(10)||'      ,row_count'
                               ||CHR(10)||'  FROM (SELECT rownum ind'
                               ||CHR(10)||'              ,results.*'
                               ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                               ||CHR(10)||'          FROM (SELECT ne_id id'
                               ||CHR(10)||'                      ,ne_unique||'' - ''||ne_descr name'
                               ||CHR(10)||'                      ,(SELECT MIN(nm_slk) FROM nm_members WHERE nm_ne_id_in = ne_id) min_offset'
                               ||CHR(10)||'                      ,(SELECT MAX(nm_end_slk) FROM nm_members WHERE nm_ne_id_in = ne_id) max_offset'
                               ||CHR(10)||'                      ,CASE'
                               ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                               ||CHR(10)||'                         WHEN UPPER(ne_unique) = f.filter_value THEN 1'
                               ||CHR(10)||'                         WHEN UPPER(ne_descr) = f.filter_value THEN 2'
                               ||CHR(10)||'                         WHEN UPPER(ne_unique) LIKE f.filter_value||''%'' THEN 3'
                               ||CHR(10)||'                         WHEN UPPER(ne_descr) LIKE f.filter_value||''%'' THEN 4'
                               ||CHR(10)||'                         ELSE 5'
                               ||CHR(10)||'                       END match_quality'
                               ||CHR(10)||'                  FROM nm_elements'
                               ||CHR(10)||'                      ,filter_tab f'
                               ||CHR(10)||'                 WHERE ne_gty_group_type = :grp_type'
    ;
    --
  BEGIN
    /*
    ||Get the preferred LRM.
    */
    lv_plrm := awlrs_util.get_preferred_lrm;
    --
    IF lv_plrm != awlrs_util.c_all_lrms_code
     THEN
        lv_group_type := lv_plrm;
        lv_cursor_sql := lv_group_sql;
    ELSE
        lv_cursor_sql := lv_alllrms_sql;
    END IF;
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'                   AND UPPER(ne_unique||'' - ''||ne_descr) LIKE ''%''||f.filter_value||''%''';
        --
    END IF;
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    --
    lv_cursor_sql := lv_cursor_sql
                     ||lv_filter
                     ||CHR(10)||'                 ORDER BY match_quality,ne_unique) results)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        IF lv_group_type IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,lv_group_type
                 ,lv_lower_index
                 ,lv_upper_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,lv_lower_index
                 ,lv_upper_index;
        END IF;
    ELSE
        IF lv_group_type IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,lv_group_type
                 ,lv_lower_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,lv_lower_index;
        END IF;
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_list_of_elements;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_job_types(pi_job_id     IN awlrs_asset_maint_results.aamr_job_id%TYPE
                        ,pi_result_ids IN nm_ne_id_array)
    RETURN nit_tab IS
    --
    lt_retval nit_tab;
    --
  BEGIN
    --
    IF pi_result_ids.COUNT > 0
     THEN
        SELECT *
          BULK COLLECT
          INTO lt_retval
          FROM nm_inv_types
         WHERE nit_inv_type IN(SELECT DISTINCT aamr_inv_type
                                 FROM awlrs_asset_maint_results
                                WHERE aamr_id IN(SELECT ne_id FROM TABLE(CAST(pi_result_ids AS nm_ne_id_array))))
         ORDER
            BY nit_table_name NULLS FIRST
              ,nit_inv_type
             ;
    ELSE
        IF pi_job_id IS NOT NULL
         THEN
            SELECT *
              BULK COLLECT
              INTO lt_retval
              FROM nm_inv_types
             WHERE nit_inv_type IN(SELECT DISTINCT aamr_inv_type
                                     FROM awlrs_asset_maint_results
                                    WHERE aamr_job_id = pi_job_id)
             ORDER
                BY nit_table_name NULLS FIRST
                  ,nit_inv_type
                 ;
        END IF;
    END IF;
    --
    RETURN lt_retval;
    --
  END get_job_types;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_job_max_attrib_count(pi_job_id IN awlrs_asset_maint_results.aamr_job_id%TYPE)
    RETURN PLS_INTEGER IS
    --
    lv_retval PLS_INTEGER;
    --
  BEGIN
    --
    SELECT NVL(MAX(COUNT(*)),0)
      INTO lv_retval
      FROM nm_inv_type_attribs
     WHERE ita_displayed = 'Y'
       AND ita_inv_type IN(SELECT DISTINCT aamr_inv_type res_type
                             FROM awlrs_asset_maint_results aamr
                            WHERE aamr_job_id = pi_job_id)
     GROUP
        BY ita_inv_type
         ;
    --
    RETURN lv_retval;
    --
  END get_job_max_attrib_count;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE set_job_attributes(pi_nit_tab    IN     nit_tab
                              ,po_attr_tab   IN OUT NOCOPY ita_by_nit_tab)
    IS
    --
    lt_ita    ita_tab;
    lt_types  nm_code_tbl := nm_code_tbl();
    --
    lv_inv_type  nm_inv_types_all.nit_inv_type%TYPE;
    lv_cnt       NUMBER := 1;
    --
  BEGIN
    /*
    ||Init attribute tables to cater for any asset types
    ||that have no attributes defined.
    */
    FOR i IN 1..pi_nit_tab.COUNT LOOP
      --
      po_attr_tab(pi_nit_tab(i).nit_inv_type) := lt_ita;
      lt_types.extend;
      lt_types(i) := pi_nit_tab(i).nit_inv_type;
      --
    END LOOP;
    /*
    ||Get the attributes for all asset types that
    ||exist in the results table for the given job id.
    */
    SELECT *
      BULK COLLECT
      INTO lt_ita
      FROM nm_inv_type_attribs
     WHERE ita_displayed = 'Y'
       AND ita_inv_type IN(SELECT column_value FROM TABLE(CAST(lt_types AS nm_code_tbl)))
     ORDER
        BY ita_inv_type
          ,ita_disp_seq_no
         ;
    /*
    ||Set the attribute tables for those asset types
    ||that have attributes defined.
    */
    FOR i IN 1..lt_ita.COUNT LOOP
      --
      IF NVL(lv_inv_type,'~~~~~') != lt_ita(i).ita_inv_type
       THEN
          lv_inv_type := lt_ita(i).ita_inv_type;
          lv_cnt := 1;
      END IF;
      --
      po_attr_tab(lv_inv_type)(lv_cnt) := lt_ita(i);
      --
      lv_cnt := lv_cnt + 1;
      --
    END LOOP;
    --
  END set_job_attributes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_type_criteria(pi_xml  IN XMLTYPE)
    RETURN type_criteria_tab IS
    --
    lt_retval type_criteria_tab;
    --
  BEGIN
    --
    SELECT EXTRACTVALUE(VALUE(x),'TypeCriteria/EntityType') entity_type
          ,EXTRACTVALUE(VALUE(x),'TypeCriteria/EntityTypeType') entity_type_type
          ,EXTRACT(VALUE(x),'TypeCriteria/SearchCriteria') criteria
      BULK COLLECT
      INTO lt_retval
      FROM TABLE(xmlsequence(EXTRACT(pi_xml,'MultipleTypeSearchCriteria/TypeCriteria'))) x
         ;
    --
    RETURN lt_retval;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        RETURN lt_retval;
    WHEN others
     THEN
        RAISE;
  END get_type_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE generate_where_clause(pi_criteria         IN  XMLTYPE
                                 ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                 ,po_where            OUT VARCHAR2
                                 ,po_asset_types      OUT asset_types_tab)
    IS
    --
    lv_temp_sql  nm3type.max_varchar2;
    lv_ft_sql    nm3type.max_varchar2;
    lv_inv_sql   nm3type.max_varchar2;
    lv_retval    nm3type.max_varchar2;
    --
    lr_theme_types  awlrs_map_api.theme_types_rec;
    lr_nit          nm_inv_types_all%ROWTYPE;
    --
    lt_criteria     type_criteria_tab;
    lt_asset_types  asset_types_tab;
    --
  BEGIN
    --
    lt_criteria := get_type_criteria(pi_xml  => pi_criteria);
    --
    FOR i IN 1..lt_criteria.COUNT LOOP
      --
      IF lt_criteria(i).entity_type = 'ASSET'
       THEN
          --
          lr_nit := nm3get.get_nit(pi_nit_inv_type => lt_criteria(i).entity_type_type);
          --
          lt_asset_types(lt_asset_types.COUNT+1) := lr_nit.nit_inv_type;
          lr_theme_types.asset_type := lr_nit.nit_inv_type;
          lr_theme_types.ft_asset_type := CASE WHEN lr_nit.nit_table_name IS NOT NULL THEN 'Y' ELSE 'N' END;
          --
          lv_temp_sql := awlrs_search_api.generate_where_clause(pi_theme_types      => lr_theme_types
                                                               ,pi_criteria         => lt_criteria(i).criteria
                                                               ,pi_include_enddated => 'N');
          --
          IF lr_nit.nit_table_name IS NOT NULL
           THEN
              IF lv_temp_sql IS NOT NULL
               THEN
                  lv_ft_sql := lv_ft_sql||' UNION ALL SELECT 1 FROM '||lr_nit.nit_table_name||' WHERE '||lr_nit.nit_foreign_pk_column||' = ngqi_item_id
                  AND ngqi_item_type = '''||lr_nit.nit_inv_type||''' AND '||lv_temp_sql;
              ELSE
                  lv_ft_sql := lv_ft_sql||' UNION ALL SELECT 1 FROM '||lr_nit.nit_table_name||' WHERE '||lr_nit.nit_foreign_pk_column||' = ngqi_item_id
                  AND ngqi_item_type = '''||lr_nit.nit_inv_type||'''';
              END IF;
          ELSE
              IF lv_temp_sql IS NOT NULL
               THEN
                  lv_inv_sql := lv_inv_sql||CASE WHEN lv_inv_sql IS NOT NULL THEN ' OR ' END||'(iit_inv_type = '''||lr_nit.nit_inv_type||''' AND '||lv_temp_sql||')';
              ELSE
                  lv_inv_sql := lv_inv_sql||CASE WHEN i > 1 THEN ' OR ' END||'(iit_inv_type = '''||lr_nit.nit_inv_type||''')';
              END IF;
          END IF;
          --
      END IF;
      --
    END LOOP;
    --
    IF lv_ft_sql IS NOT NULL
     OR lv_inv_sql IS NOT NULL
     THEN
        lv_retval := 'EXISTS (SELECT 1'
                            ||' FROM nm_inv_items_all'
                           ||' WHERE iit_ne_id = ngqi_item_id'
                             ||' AND iit_inv_type = ngqi_item_type'
                             ||' AND ('||lv_inv_sql||lv_ft_sql||'))';
    END IF;
    --
    po_asset_types := lt_asset_types;
    po_where := NVL(LTRIM(lv_retval),c_default_where);
    --
  END generate_where_clause;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE generate_where_clause_lb(pi_criteria         IN  XMLTYPE
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,po_where            OUT VARCHAR2
                                    ,po_asset_types      OUT asset_types_tab)
    IS
    --
    lv_temp_sql  nm3type.max_varchar2;
    lv_ft_sql    nm3type.max_varchar2;
    lv_inv_sql   nm3type.max_varchar2;
    lv_retval    nm3type.max_varchar2;
    --
    lr_theme_types  awlrs_map_api.theme_types_rec;
    lr_nit          nm_inv_types_all%ROWTYPE;
    --
    lt_criteria     type_criteria_tab;
    lt_asset_types  asset_types_tab;
    --
  BEGIN
    --
    lt_criteria := get_type_criteria(pi_xml  => pi_criteria);
    --
    FOR i IN 1..lt_criteria.COUNT LOOP
      --
      IF lt_criteria(i).entity_type = 'ASSET'
       THEN
          --
          lr_nit := nm3get.get_nit(pi_nit_inv_type => lt_criteria(i).entity_type_type);
          --
          lt_asset_types(lt_asset_types.COUNT+1) := lr_nit.nit_inv_type;
          lr_theme_types.asset_type := lr_nit.nit_inv_type;
          lr_theme_types.ft_asset_type := CASE WHEN lr_nit.nit_table_name IS NOT NULL THEN 'Y' ELSE 'N' END;
          --
          lv_temp_sql := awlrs_search_api.generate_where_clause(pi_theme_types      => lr_theme_types
                                                               ,pi_criteria         => lt_criteria(i).criteria
                                                               ,pi_include_enddated => 'N');
          --
          IF lr_nit.nit_table_name IS NOT NULL
           THEN
              IF lv_temp_sql IS NOT NULL
               THEN
                  lv_ft_sql := lv_ft_sql||' UNION ALL SELECT 1 FROM '||lr_nit.nit_table_name||' WHERE '||lr_nit.nit_foreign_pk_column||' = t.obj_id
                  AND t.obj_type = '''||lr_nit.nit_inv_type||''' AND '||lv_temp_sql;
              ELSE
                  lv_ft_sql := lv_ft_sql||' UNION ALL SELECT 1 FROM '||lr_nit.nit_table_name||' WHERE '||lr_nit.nit_foreign_pk_column||' = t.obj_id
                  AND t.obj_type = '''||lr_nit.nit_inv_type||'''';
              END IF;
          ELSE
              IF lv_temp_sql IS NOT NULL
               THEN
                  lv_inv_sql := lv_inv_sql||CASE WHEN lv_inv_sql IS NOT NULL THEN ' OR ' END||'(iit_inv_type = '''||lr_nit.nit_inv_type||''' AND '||lv_temp_sql||')';
              ELSE
                  lv_inv_sql := lv_inv_sql||CASE WHEN i > 1 THEN ' OR ' END||'(iit_inv_type = '''||lr_nit.nit_inv_type||''')';
              END IF;
          END IF;
          --
      END IF;
      --
    END LOOP;
    --
    IF lv_inv_sql IS NOT NULL
     THEN
        lv_retval := 'EXISTS (SELECT 1'
                            ||' FROM nm_inv_items_all'
                           ||' WHERE iit_ne_id = t.obj_id
'
                             ||' AND iit_inv_type = t.obj_type'
                             ||' AND ('||lv_inv_sql||')';
        IF lv_ft_sql IS NOT NULL
         THEN
            lv_retval := lv_retval||lv_ft_sql||')';
        ELSE
            lv_retval := lv_retval||')';
        END IF;
    ELSE
        IF lv_ft_sql IS NOT NULL
         THEN
            lv_retval := 'EXISTS ('||SUBSTR(lv_ft_sql,12)||')';
        END IF;
    END IF;
    --
    po_asset_types := lt_asset_types;
    po_where := NVL(LTRIM(lv_retval),c_default_where);
    --
  END generate_where_clause_lb;


  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_locations(pi_iit_ne_id         IN nm_inv_items_all.iit_ne_id%TYPE
                        ,pi_iit_inv_type      IN nm_inv_items_all.iit_inv_type%TYPE
                        ,pi_tablename         IN nm_inv_types_all.nit_table_name%TYPE
                        ,pi_net_filter_ne_id  IN nm_elements_all.ne_id%TYPE
                        ,pi_output_group_type IN nm_elements.ne_gty_group_type%TYPE)
    RETURN nm_placement_array_type IS
    --
    lt_pla  nm_placement_array := nm3pla.initialise_placement_array;
    --
    lt_route_locs  nm3route_ref.tab_rec_route_loc_dets;
    --
  BEGIN
    --
    IF pi_tablename IS NOT NULL
     THEN
        /*
        ||Get connected chunks does not work for FT asset types souse nm3asset.
        */
        nm3asset.get_inv_route_location_details(pi_iit_ne_id          => pi_iit_ne_id
                                               ,pi_nit_inv_type       => pi_iit_inv_type
                                               ,po_tab_route_loc_dets => lt_route_locs);

        FOR i IN 1..lt_route_locs.COUNT LOOP
          --
          nm3pla.add_element_to_pl_arr(pio_pl_arr => lt_pla
                                      ,pi_ne_id   => lt_route_locs(i).route_ne_id
                                      ,pi_start   => lt_route_locs(i).nm_slk
                                      ,pi_end     => lt_route_locs(i).nm_end_slk);
          --
        END LOOP;
        --
    ELSIF pi_net_filter_ne_id IS NOT NULL
     THEN
        --
        lt_pla := nm3pla.get_connected_chunks(pi_ne_id    => pi_iit_ne_id
                                             ,pi_route_id => pi_net_filter_ne_id);
        --
    ELSE
        --
        lt_pla := nm3pla.get_connected_chunks(p_ne_id    => pi_iit_ne_id
                                             ,p_route_id => NULL
                                             ,p_obj_type => pi_output_group_type);
        --
    END IF;
    --
    RETURN lt_pla.npa_placement_array;
    --
  END get_locations;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE execute_query_gaz(pi_asset_type        IN  nm_inv_types_all.nit_inv_type%TYPE DEFAULT NULL
                             ,pi_asset_criteria    IN  XMLTYPE DEFAULT NULL
                             ,pi_net_filter_ne_id  IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                             ,pi_net_filter_from   IN  NUMBER DEFAULT NULL
                             ,pi_net_filter_to     IN  NUMBER DEFAULT NULL
                             ,pi_net_filter_nse_id IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                             ,po_job_id            OUT awlrs_asset_maint_results.aamr_job_id%TYPE
                             ,po_message_severity  OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lv_gaz_results_id     nm_gaz_query_item_list.ngqi_job_id%TYPE;
    lv_job_id             awlrs_asset_maint_results.aamr_job_id%TYPE;
    lv_sql                nm3type.max_varchar2 := 'INSERT'
                                                 ||' INTO awlrs_asset_maint_results'
                                                      ||'(aamr_id'
                                                      ||',aamr_job_id'
                                                      ||',aamr_inv_type'
                                                      ||',aamr_iit_ne_id'
                                                      ||',aamr_ne_id'
                                                      ||',aamr_from_offset'
                                                      ||',aamr_to_offset)'
                                               ||' SELECT aamr_id_seq.NEXTVAL'
                                                      ||',:lv_job_id'
                                                      ||',ngqi_item_type'
                                                      ||',ngqi_item_id'
    ;
    lv_where              nm3type.max_varchar2 := c_default_where;
    lv_location_out_type  VARCHAR2(10) := CASE
                                            WHEN awlrs_util.get_preferred_lrm = awlrs_util.c_all_lrms_code
                                             THEN 'DATUM'
                                            ELSE awlrs_util.get_preferred_lrm
                                          END;
    lv_location_out_nt  nm_types.nt_type%TYPE;
    --
    lr_ngq  nm_gaz_query%ROWTYPE;
    lr_ne   nm_elements_all%ROWTYPE;
    --
    TYPE ngqt_tab IS TABLE OF nm_gaz_query_types%ROWTYPE INDEX BY BINARY_INTEGER;
    lt_ngqt  ngqt_tab;
    --
    lt_asset_types  asset_types_tab;
    --
    CURSOR get_grp_nt
        IS
    SELECT ngt_nt_type
      FROM nm_group_types ngt
     WHERE ngt_group_type = SYS_CONTEXT('NM3CORE','PREFERRED_LRM')
         ;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT execute_query_sp;
    /*
    ||Check the parameters.
    */
    IF pi_net_filter_ne_id IS NOT NULL
     THEN
        --
        lr_ne := nm3net.get_ne(pi_ne_id => pi_net_filter_ne_id);
        --
        IF pi_net_filter_from IS NOT NULL
         THEN
            awlrs_search_api.validate_offset(pi_ne_id  => pi_net_filter_ne_id
                                            ,pi_offset => pi_net_filter_from);
        END IF;
        --
        IF pi_net_filter_to IS NOT NULL
         THEN
            awlrs_search_api.validate_offset(pi_ne_id  => pi_net_filter_ne_id
                                            ,pi_offset => pi_net_filter_to);
        END IF;
        --
        lr_ngq.ngq_source_id := pi_net_filter_ne_id;
        lr_ngq.ngq_source := nm3extent.c_route;
        lr_ngq.ngq_open_or_closed := nm3gaz_qry.c_closed_query;
        lr_ngq.ngq_items_or_area := nm3gaz_qry.c_items_query;
        lr_ngq.ngq_query_all_items := 'N';
        lr_ngq.ngq_begin_mp := pi_net_filter_from;
        lr_ngq.ngq_end_mp := pi_net_filter_to;
        --
    END IF;
    /*
    ||If both an pi_net_filter_ne_id and pi_net_filter_nse_id are passed
    ||in then pi_net_filter_ne_id takes priority.
    */
    IF pi_net_filter_ne_id IS NULL
     AND pi_net_filter_nse_id IS NOT NULL
     THEN
        /*
        ||Using a saved extent.
        */
        lr_ngq.ngq_source_id := pi_net_filter_nse_id;
        lr_ngq.ngq_source := nm3extent.c_saved;
        lr_ngq.ngq_open_or_closed := nm3gaz_qry.c_closed_query;
        lr_ngq.ngq_items_or_area := nm3gaz_qry.c_items_query;
        lr_ngq.ngq_query_all_items := 'N';
        --
    END IF;
    --
    lr_ngq.ngq_id := nm3ddl.sequence_nextval('RTG_JOB_ID_SEQ');
    /*
    ||Insert the Gaz Query Header Record.
    */
    INSERT
      INTO nm_gaz_query
    VALUES lr_ngq
         ;
    --
    IF pi_asset_criteria IS NOT NULL
     THEN
        /*
        ||Process the criteria.
        */
        generate_where_clause(pi_criteria    => pi_asset_criteria
                             ,po_where       => lv_where
                             ,po_asset_types => lt_asset_types);
        --
        FOR i IN 1..lt_asset_types.COUNT LOOP
          --
          lt_ngqt(i).ngqt_ngq_id := lr_ngq.ngq_id;
          lt_ngqt(i).ngqt_seq_no := i;
          lt_ngqt(i).ngqt_item_type_type := 'I';
          lt_ngqt(i).ngqt_item_type := lt_asset_types(i);
          --
        END LOOP;
        --
        FORALL i IN 1..lt_ngqt.COUNT
        INSERT
          INTO nm_gaz_query_types
        VALUES lt_ngqt(i)
             ;
        --
    ELSE
        --
        IF pi_asset_type IS NOT NULL
         THEN
            /*
            ||Add the specified Asset Type to the Gaz Query.
            */
            INSERT
              INTO nm_gaz_query_types
            SELECT lr_ngq.ngq_id
                  ,1
                  ,'I'
                  ,pi_asset_type
              FROM dual
                 ;
        ELSE
            /*
            ||Add all relevant Inventory Asset Types that the user has access to.
            */
            INSERT
              INTO nm_gaz_query_types
            SELECT lr_ngq.ngq_id
                  ,rownum
                  ,'I'
                  ,nit_inv_type
              FROM nm_inv_types
             WHERE nit_category IN('I','P') --IN ('I','P','F') will support FT when LB is fixed.
               AND nit_use_xy = 'N'
               AND EXISTS (SELECT 1
                             FROM hig_users hus
                                 ,hig_user_roles ur
                                 ,nm_inv_type_roles ir
                                 ,nm_user_aus usr
                                 ,nm_admin_units au
                                 ,nm_admin_groups nag
                            WHERE hus.hus_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
                              AND hus.hus_username = ur.hur_username
                              AND ur.hur_role = ir.itr_hro_role
                              AND ir.itr_inv_type = nit_inv_type
                              AND usr.nua_admin_unit = au.nau_admin_unit
                              AND au.nau_admin_unit = nag_child_admin_unit
                              AND au.nau_admin_type = nit_admin_type
                              AND usr.nua_admin_unit = nag_parent_admin_unit
                              AND usr.nua_user_id = hus.hus_user_id)
               AND EXISTS(SELECT 'x'
                            FROM nm_inv_nw_all
                           WHERE nin_nit_inv_code = nit_inv_type)
               AND NOT EXISTS(SELECT 'x'
                                FROM nm_inv_type_groupings
                               WHERE itg_inv_type = nit_inv_type)
                 ;
        END IF;
    END IF;
    /*
    ||Run the Gaz Query.
    */
    nm3gaz_qry.g_use_date_based_views := TRUE;
    lv_gaz_results_id := nm3gaz_qry.perform_query(lr_ngq.ngq_id);
    --
    lv_job_id := nm3ddl.sequence_nextval('AAMR_JOB_ID_SEQ');
    --
    IF lv_location_out_type != 'DATUM'
     THEN
        --
        OPEN  get_grp_nt;
        FETCH get_grp_nt
         INTO lv_location_out_nt;
        CLOSE get_grp_nt;
        --
        lv_sql := lv_sql||',pla.pl_ne_id'
                        ||',pla.pl_start'
                        ||',pla.pl_end'
                   ||' FROM (SELECT ngqi_item_type'
                                ||',ngqi_item_id'
                                ||',nit_table_name'
                           ||' FROM nm_gaz_query_item_list'
                                ||',nm_inv_types_all'
                          ||' WHERE ngqi_job_id = :gaz_results_id'
                            ||' AND ngqi_item_type = nit_inv_type'
                            ||' AND '||lv_where||') items'
                        ||',TABLE(awlrs_asset_maint_api.get_locations(ngqi_item_id,ngqi_item_type,nit_table_name,:net_filter_ne_id,:location_out_type)) pla'
        ;
        --
        EXECUTE IMMEDIATE(lv_sql) USING lv_job_id, lv_gaz_results_id, pi_net_filter_ne_id, lv_location_out_type;
        --
    ELSE
        IF pi_net_filter_ne_id IS NOT NULL
         THEN
            --
            lv_sql := lv_sql||',nm_ne_id_of'
                            ||',nm_begin_mp'
                            ||',nm_end_mp'
                       ||' FROM nm_gaz_query_item_list'
                            ||',nm_members'
                      ||' WHERE ngqi_job_id = :gaz_results_id'
                        ||' AND '||lv_where
                        ||' AND ngqi_item_id = nm_ne_id_in'
            ;
            IF lr_ne.ne_type = 'S'
             THEN
                lv_sql := lv_sql||' AND nm_ne_id_of = :net_filter_ne_id';
            ELSE
                lv_sql := lv_sql||' AND nm_ne_id_of IN(SELECT nm_ne_id_of'
                                                     ||' FROM nm_members'
                                                    ||' WHERE nm_ne_id_in = :net_filter_ne_id)'
                ;
            END IF;
            --
            EXECUTE IMMEDIATE(lv_sql) USING lv_job_id, lv_gaz_results_id, pi_net_filter_ne_id;
            --
        ELSE
            --
            lv_sql := lv_sql||',nm_ne_id_of'
                            ||',nm_begin_mp'
                            ||',nm_end_mp'
                       ||' FROM nm_gaz_query_item_list'
                            ||',nm_members'
                      ||' WHERE ngqi_job_id = :gaz_results_id'
                        ||' AND '||lv_where
                      ||'   AND ngqi_item_id = nm_ne_id_in'
                 ;
            --
            EXECUTE IMMEDIATE(lv_sql) USING lv_job_id, lv_gaz_results_id;
            --
        END IF;
    END IF;
    --
    po_job_id := lv_job_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO execute_query_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END execute_query_gaz;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_rpt_tab_from_nse(pi_nse_id IN nm_saved_extents.nse_id%TYPE)
    RETURN lb_rpt_tab IS
    --
    lt_retval  lb_rpt_tab;
    --
    CURSOR get_nse(cp_nse_id IN nm_saved_extents.nse_id%TYPE)
        IS
    SELECT lb_rpt(nsd_ne_id
                 ,nlt_id
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,nsd_cardinality
                 ,nsd_begin_mp
                 ,nsd_end_mp
                 ,nt_length_unit)
      FROM nm_saved_extent_members
          ,nm_saved_extent_member_datums
          ,nm_elements ne
          ,nm_types
          ,nm_linear_types
     WHERE nsm_nse_id = cp_nse_id
       AND nsm_nse_id = nsd_nse_id
       AND nsm_id = nsd_nsm_id
       AND nsd_ne_id = ne.ne_id
       AND ne.ne_nt_type = nt_type
       AND ne.ne_nt_type = nlt_nt_type
       AND nlt_gty_type IS NULL
     ORDER
        BY nsm_seq_no
          ,nsd_seq_no
         ;
    --
  BEGIN
    --
    OPEN  get_nse(pi_nse_id);
    FETCH get_nse
     BULK COLLECT
     INTO lt_retval;
    CLOSE get_nse;
    --
    RETURN lt_retval;
    --
  END get_rpt_tab_from_nse;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_obj_rpt_tab(pi_refnt_tab  IN lb_rpt_tab
                          ,pi_obj_types IN nm_code_tbl)
    RETURN lb_rpt_tab IS
    --
    lt_retval lb_rpt_tab;
    --
  BEGIN
    --
    IF pi_refnt_tab IS NOT NULL
     AND lb_ops.lb_rpt_tab_has_network(pi_refnt_tab) = 'TRUE'
     THEN
        --
        SELECT lb_rpt(nm_ne_id_of
                     ,nlt_id
                     ,nm_obj_type
                     ,nm_ne_id_in
                     ,nm_seg_no
                     ,nm_seq_no
                     ,nm_cardinality
                     ,nm_begin_mp
                     ,nm_end_mp
                     ,nlt_units) rpt
          BULK COLLECT
          INTO lt_retval
          FROM nm_members m
              ,nm_linear_types
              ,nm_elements
         WHERE nlt_nt_type = ne_nt_type
           AND nm_ne_id_of = ne_id
           AND nlt_g_i_d = 'D'
           AND nm_obj_type IN(SELECT column_value FROM TABLE(CAST(pi_obj_types AS nm_code_tbl)))
           AND nm_ne_id_in IN(SELECT c.nm_ne_id_in
                                FROM nm_members c
                                    ,TABLE(pi_refnt_tab) t
                               WHERE c.nm_ne_id_of = refnt
                                 AND ((c.nm_begin_mp < t.end_m
                                       AND c.nm_end_mp > t.start_m)
                                      OR (c.nm_begin_mp = nm_end_mp
                                          AND c.nm_begin_mp BETWEEN t.start_m AND t.end_m)))
             ;
        --
    ELSE
        --
        SELECT lb_rpt(nm_ne_id_of
                     ,nlt_id
                     ,nm_obj_type
                     ,nm_ne_id_in
                     ,nm_seg_no
                     ,nm_seq_no
                     ,nm_cardinality
                     ,nm_begin_mp
                     ,nm_end_mp
                     ,nlt_units)
          BULK COLLECT
          INTO lt_retval
          FROM nm_members
              ,nm_linear_types
              ,nm_elements
         WHERE nm_obj_type IN(SELECT column_value FROM TABLE(CAST(pi_obj_types AS nm_code_tbl)))
           AND ne_id = nm_ne_id_of
           AND ne_nt_type = nlt_nt_type
           AND NVL (ne_gty_group_type, '~~~~~') = NVL (nlt_gty_type, '~~~~~');
        --
    END IF;
    --
    RETURN lt_retval;
    --
  END get_obj_rpt_tab;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE execute_query_lb(pi_asset_type        IN  nm_inv_types_all.nit_inv_type%TYPE DEFAULT NULL
                            ,pi_asset_criteria    IN  XMLTYPE DEFAULT NULL
                            ,pi_net_filter_ne_id  IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                            ,pi_net_filter_from   IN  NUMBER DEFAULT NULL
                            ,pi_net_filter_to     IN  NUMBER DEFAULT NULL
                            ,pi_net_filter_nse_id IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                            ,po_job_id            OUT awlrs_asset_maint_results.aamr_job_id%TYPE
                            ,po_message_severity  OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lv_job_id             awlrs_asset_maint_results.aamr_job_id%TYPE;
    lv_sql                CLOB := 'INSERT'
                                 ||' INTO awlrs_asset_maint_results'
                                      ||'(aamr_id'
                                      ||',aamr_job_id'
                                      ||',aamr_inv_type'
                                      ||',aamr_iit_ne_id'
                                      ||',aamr_ne_id'
                                      ||',aamr_from_offset'
                                      ||',aamr_to_offset)'
                               ||' SELECT aamr_id_seq.NEXTVAL'
                                      ||',:lv_job_id'
                                      ||',t.obj_type'
                                      ||',t.obj_id'
                                      ||',t.refnt'
                                      ||',t.start_m'
                                      ||',t.end_m'
    ;
    lv_where              CLOB := c_default_where;
    lv_location_out_type  VARCHAR2(10) := CASE
                                            WHEN awlrs_util.get_preferred_lrm = awlrs_util.c_all_lrms_code
                                             THEN 'DATUM'
                                            ELSE awlrs_util.get_preferred_lrm
                                          END;
    --
    lr_ne   nm_elements_all%ROWTYPE;
    lr_nt   nm_types%ROWTYPE;
    lr_nlt  nm_linear_types%ROWTYPE;
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_asset_types       asset_types_tab;
    lt_non_ft_types      nm_code_tbl := nm_code_tbl();
    lt_d_rpt             lb_rpt_tab := lb_rpt_tab();
    lt_ids_and_locs      lb_rpt_tab;
    lt_all_ids_and_locs  lb_rpt_tab := lb_rpt_tab();
    --
    PROCEDURE add_results(pi_new_results IN     lb_rpt_tab
                         ,po_all_results IN OUT NOCOPY lb_rpt_tab)
      IS
    BEGIN
      --
      FOR j IN 1..pi_new_results.COUNT LOOP
        --
        po_all_results.extend;
        po_all_results(po_all_results.COUNT) := pi_new_results(j);
        --
      END LOOP;
      --
    END add_results;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT execute_query_sp;
    /*
    ||Check the parameters.
    */
    IF pi_net_filter_ne_id IS NOT NULL
     THEN
        --
        lr_ne := nm3net.get_ne(pi_ne_id => pi_net_filter_ne_id);
        lr_nt := nm3net.get_nt(pi_nt_type => lr_ne.ne_nt_type);
        lr_nlt := get_nlt(pi_nlt_nt_type  => lr_ne.ne_nt_type
                         ,pi_nlt_gty_type => lr_ne.ne_gty_group_type);
        --
        IF pi_net_filter_from IS NOT NULL
         THEN
            awlrs_search_api.validate_offset(pi_ne_id  => pi_net_filter_ne_id
                                            ,pi_offset => pi_net_filter_from);
        END IF;
        --
        IF pi_net_filter_to IS NOT NULL
         THEN
            awlrs_search_api.validate_offset(pi_ne_id  => pi_net_filter_ne_id
                                            ,pi_offset => pi_net_filter_to);
        END IF;
        --
        IF lr_nt.nt_datum = 'Y'
         THEN
            /*
            ||Override the PLRM
            */
            lv_location_out_type := 'DATUM';
            --
            lt_d_rpt := lb_rpt_tab(lb_rpt(pi_net_filter_ne_id
                                         ,lr_nlt.nlt_id
                                         ,NULL
                                         ,NULL
                                         ,NULL
                                         ,NULL
                                         ,1
                                         ,pi_net_filter_from
                                         ,pi_net_filter_to
                                         ,lr_nt.nt_length_unit));
        ELSE
            /*
            ||Override the PLRM
            */
            lv_location_out_type := lr_ne.ne_gty_group_type;
            --
            lt_d_rpt := lb_get.get_lb_rpt_d_tab(p_lb_RPt_tab => lb_rpt_tab(lb_rpt(pi_net_filter_ne_id
                                                                                 ,lr_nlt.nlt_id
                                                                                 ,NULL
                                                                                 ,NULL
                                                                                 ,NULL
                                                                                 ,NULL
                                                                                 ,1
                                                                                 ,pi_net_filter_from
                                                                                 ,pi_net_filter_to
                                                                                 ,lr_nt.nt_length_unit)));
        END IF;
        --
    END IF;
    /*
    ||If both an pi_net_filter_ne_id and pi_net_filter_nse_id are passed
    ||in then pi_net_filter_ne_id takes priority.
    */
    IF pi_net_filter_ne_id IS NULL
     AND pi_net_filter_nse_id IS NOT NULL
     THEN
        /*
        ||Using a saved extent.
        */
        lt_d_rpt := get_rpt_tab_from_nse(pi_nse_id => pi_net_filter_nse_id);
        --
    END IF;
    --
    IF pi_asset_criteria IS NOT NULL
     THEN
        /*
        ||Process the criteria.
        */
        generate_where_clause_lb(pi_criteria    => pi_asset_criteria
                                ,po_where       => lv_where
                                ,po_asset_types => lt_asset_types);
        --
    ELSE
        --
        IF pi_asset_type IS NOT NULL
         THEN
            /*
            ||Add the specified Asset Type to the Gaz Query.
            */
            lt_asset_types(1) := pi_asset_type;
        ELSE
            /*
            ||Add all relevant Inventory Asset Types that the user has access to.
            */
            SELECT nit_inv_type
              BULK COLLECT
              INTO lt_asset_types
              FROM nm_inv_types
             WHERE nit_category IN('I','P') --IN ('I','P','F') will support FT when LB is fixed.
               AND nit_use_xy = 'N'
               AND EXISTS (SELECT 1
                             FROM hig_users hus
                                 ,hig_user_roles ur
                                 ,nm_inv_type_roles ir
                                 ,nm_user_aus usr
                                 ,nm_admin_units au
                                 ,nm_admin_groups nag
                            WHERE hus.hus_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
                              AND hus.hus_username = ur.hur_username
                              AND ur.hur_role = ir.itr_hro_role
                              AND ir.itr_inv_type = nit_inv_type
                              AND usr.nua_admin_unit = au.nau_admin_unit
                              AND au.nau_admin_unit = nag_child_admin_unit
                              AND au.nau_admin_type = nit_admin_type
                              AND usr.nua_admin_unit = nag_parent_admin_unit
                              AND usr.nua_user_id = hus.hus_user_id)
               AND EXISTS(SELECT 'x'
                            FROM nm_inv_nw_all
                           WHERE nin_nit_inv_code = nit_inv_type)
               AND NOT EXISTS(SELECT 'x'
                                FROM nm_inv_type_groupings
                               WHERE itg_inv_type = nit_inv_type)
                 ;
        END IF;
    END IF;
    /*
    ||Run the LB Query.
    */
    FOR i IN 1..lt_asset_types.COUNT LOOP
      --
      lr_nit :=nm3get.get_nit(pi_nit_inv_type => lt_asset_types(i));
      --
      IF lr_nit.nit_table_name IS NULL
       THEN
          --
          lt_non_ft_types.EXTEND;
          lt_non_ft_types(lt_non_ft_types.COUNT) := lt_asset_types(i);
          --
      ELSE
          /*
          ||TODO - Later version of LB may support FT assets in the above call to get_obj_rpt_tab.
          ||right now however we are not supporting FT Asset Types due to issues in LB and Gaz
          ||query with FT Asset Types located at datum or route level so this code won't get called.
          */
          lt_ids_and_locs := lb_get.get_ft_rpt_tab(p_rpt_tab    => lt_d_rpt
                                                  ,p_table_name => lr_nit.nit_table_name
                                                  ,p_inv_type   => lt_asset_types(i)
                                                  ,p_key        => lr_nit.nit_foreign_pk_column
                                                  ,p_ne_key     => lr_nit.nit_lr_ne_column_name
                                                  ,p_start_col  => lr_nit.nit_lr_st_chain
                                                  ,p_end_col    => CASE WHEN lr_nit.nit_pnt_or_cont = 'P' THEN lr_nit.nit_lr_st_chain ELSE lr_nit.nit_lr_end_chain END);
          --
          add_results(pi_new_results => lt_ids_and_locs
                     ,po_all_results => lt_all_ids_and_locs);
          --
      END IF;
    END LOOP;
    --
    IF lt_non_ft_types.COUNT > 0
     THEN
        /*
        ||TODO - Call below is to a temporary hacked version of LB procedure to allow it to be
        ||called for multiple Asset Types when this is addressed in the LB package then the
        ||official version should be called.
        */
        lt_ids_and_locs := get_obj_rpt_tab(pi_refnt_tab => lt_d_rpt
                                          ,pi_obj_types => lt_non_ft_types);
        --
        add_results(pi_new_results => lt_ids_and_locs
                   ,po_all_results => lt_all_ids_and_locs);
        --
    END IF;
    --
    IF lv_location_out_type != 'DATUM'
     AND lt_all_ids_and_locs.COUNT > 0
     THEN
        lt_all_ids_and_locs := lb_get.get_lb_rpt_r_tab(p_lb_rpt_tab      => lt_all_ids_and_locs
                                                      ,p_linear_obj_type => lv_location_out_type
                                                      ,p_cardinality     => 10);
    END IF;
    --
    lv_job_id := nm3ddl.sequence_nextval('AAMR_JOB_ID_SEQ');
    --
    lv_sql := lv_sql||' FROM TABLE(:rpt_tab) t WHERE '||lv_where
    ;
    IF pi_net_filter_ne_id IS NOT NULL
     THEN
        lv_sql := lv_sql||' AND t.refnt = :net_filter_ne_id';
        EXECUTE IMMEDIATE lv_sql USING lv_job_id,lt_all_ids_and_locs,pi_net_filter_ne_id;
    ELSE
        EXECUTE IMMEDIATE lv_sql USING lv_job_id,lt_all_ids_and_locs;
    END IF;
    --
    po_job_id := lv_job_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO execute_query_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END execute_query_lb;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE execute_query(pi_asset_type        IN  nm_inv_types_all.nit_inv_type%TYPE DEFAULT NULL
                         ,pi_asset_criteria    IN  XMLTYPE DEFAULT NULL
                         ,pi_net_filter_ne_id  IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                         ,pi_net_filter_from   IN  NUMBER DEFAULT NULL
                         ,pi_net_filter_to     IN  NUMBER DEFAULT NULL
                         ,pi_net_filter_nse_id IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                         ,po_job_id            OUT awlrs_asset_maint_results.aamr_job_id%TYPE
                         ,po_message_severity  OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor    OUT sys_refcursor)
    IS
  BEGIN
    --
    execute_query_lb(pi_asset_type        => pi_asset_type
                    ,pi_asset_criteria    => pi_asset_criteria
                    ,pi_net_filter_ne_id  => pi_net_filter_ne_id
                    ,pi_net_filter_from   => pi_net_filter_from
                    ,pi_net_filter_to     => pi_net_filter_to
                    ,pi_net_filter_nse_id => pi_net_filter_nse_id
                    ,po_job_id            => po_job_id
                    ,po_message_severity  => po_message_severity
                    ,po_message_cursor    => po_message_cursor);
    --
  END execute_query;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_query_sql(pi_job_id     IN NUMBER
                        ,pi_result_ids IN nm_ne_id_array DEFAULT nm_ne_id_array())
    RETURN CLOB IS
    --
    lv_retval       CLOB;
    lv_asset_tab    CLOB;
    lv_select_list  CLOB;
    lv_max_attribs  PLS_INTEGER;
    --
    lt_nit         nit_tab;
    lt_ita_by_nit  ita_by_nit_tab;
    --
  BEGIN
    /*
    ||Get the asset types that exist in the results
    ||table for the given job id.
    */
    lt_nit := get_job_types(pi_job_id     => pi_job_id
                           ,pi_result_ids => pi_result_ids);
    IF lt_nit.COUNT > 0
     THEN
        /*
        ||Get the maximum number of attributes defined for
        ||the asset types  that exist in the results table
        ||for the given job id. This determines the number
        ||of attribute columns needed in the cursor.
        */
        lv_max_attribs := get_job_max_attrib_count(pi_job_id => pi_job_id);
        /*
        ||Get the details of the attributes.
        */
        set_job_attributes(pi_nit_tab    => lt_nit
                          ,po_attr_tab   => lt_ita_by_nit);
        /*
        ||Build a table from asset queries.
        */
        FOR i IN 1..lv_max_attribs LOOP
          --
          lv_select_list := lv_select_list||',x_'||LPAD(i,2,0);
          --
        END LOOP;
        --
        lv_asset_tab := '(';
        --
        FOR i IN 1..lt_nit.COUNT LOOP
          --
          lv_asset_tab := lv_asset_tab||CASE
                                          WHEN i > 1
                                           THEN ' UNION ALL '
                                          ELSE
                                                NULL
                                        END
                                      ||'SELECT '||CASE
                                                     WHEN lt_nit(i).nit_table_name IS NULL
                                                      THEN
                                                         '/*+ index(nm_inv_items inv_items_all_pk) */ '
                                                     ELSE
                                                         NULL
                                                   END
                                                 ||NVL(lt_nit(i).nit_foreign_pk_column,'iit_ne_id')||' pk,'
                                                 ||CASE
                                                     WHEN lt_nit(i).nit_table_name IS NULL
                                                      THEN
                                                         'iit_descr descr,'
                                                     ELSE
                                                         'CAST(NULL AS VARCHAR2(40)) descr,'
                                                   END
                                                 ||''''||lt_nit(i).nit_inv_type||''' inv_type,'
                                                 ||CASE
                                                     WHEN lt_nit(i).nit_table_name IS NULL
                                                      THEN
                                                         'iit_primary_key primary_key,'
                                                     ELSE
                                                         'CAST('||lt_nit(i).nit_foreign_pk_column||' AS VARCHAR2(50)) primary_key,'
                                                     END
                                                 ||CASE
                                                     WHEN lt_nit(i).nit_table_name IS NULL
                                                      THEN
                                                         'iit_x_sect xsp '
                                                     ELSE
                                                         'CAST(NULL AS VARCHAR2(4)) xsp '
                                                   END;
          --
          FOR j IN 1..lv_max_attribs LOOP
            lv_asset_tab := lv_asset_tab||','
                                        ||CASE
                                            WHEN j <= NVL(lt_ita_by_nit(lt_nit(i).nit_inv_type).COUNT,0)
                                             THEN
                                                CASE
                                                  WHEN lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format = awlrs_util.c_date_col
                                                   AND INSTR(lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_attrib_name
                                                            ,lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format,1,1) != 0
                                                   THEN
                                                      'TO_CHAR('||lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_attrib_name
                                                           ||','||nm3flx.string(NVL(lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format_mask
                                                                                   ,Sys_Context('NM3CORE','USER_DATE_MASK')))
                                                           ||')'
                                                  WHEN lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format = awlrs_util.c_number_col
                                                   AND lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format_mask IS NOT NULL
                                                   THEN
                                                      'TO_CHAR('||lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_attrib_name
                                                           ||','||nm3flx.string(lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format_mask)
                                                           ||')'
                                                  WHEN lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_format IN(awlrs_util.c_date_col,awlrs_util.c_number_col)
                                                   THEN
                                                      'TO_CHAR('||lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_attrib_name||')'
                                                  ELSE
                                                      lt_ita_by_nit(lt_nit(i).nit_inv_type)(j).ita_attrib_name
                                                END
                                            ELSE
                                                'NULL'
                                          END
                                        ||' x_'||LPAD(j,2,0);
          END LOOP;
          --
          lv_asset_tab := lv_asset_tab||' FROM '||NVL(lt_nit(i).nit_table_name,'nm_inv_items')||CASE
                                                                                               WHEN lt_nit(i).nit_table_name IS NULL
                                                                                                THEN ' WHERE iit_inv_type = '''||lt_nit(i).nit_inv_type||''''
                                                                                               ELSE
                                                                                                     NULL
                                                                                             END;
          --
        END LOOP;
        --
        lv_asset_tab := lv_asset_tab||') assets';
        --
    ELSE
        --
        lv_select_list := NULL;
        lv_asset_tab := '(SELECT iit_ne_id pk, iit_descr descr, iit_inv_type inv_type, iit_primary_key primary_key, iit_x_sect xsp FROM nm_inv_items) assets';
        --
    END IF;
    --
    lv_retval := 'SELECT /*+ index(nm_elements ne_pk) */ aamr_id result_id'
                          ||',aamr_iit_ne_id asset_id'
                          ||',aamr_inv_type asset_type'
                          ||',assets.primary_key'
                          ||',assets.descr description'
                          ||',aamr_ne_id location_id'
                          ||',ne_unique location'
                          ||',TO_NUMBER(nm3unit.get_formatted_value(aamr_from_offset,un_unit_id)) from_offset'
                          ||',TO_NUMBER(nm3unit.get_formatted_value(aamr_to_offset,un_unit_id)) to_offset'
                          /*
                          ||The partial location flag is needed to warn the user when they use the
                          ||delete asset function. Since this will not be available for FT asset
                          ||Types the select below will drop through to the NVL and return 'N'.
                          */
                          ||',NVL((SELECT ''Y'''
                                 ||' FROM nm_elements'
                                ||' WHERE nit_table_name IS NULL'
                                  ||' AND ne_id = aamr_ne_id'
                                  ||' AND ne_gty_group_type IS NOT NULL'
                                  ||' AND EXISTS(SELECT ''X'''
                                               ||' FROM nm_members im'
                                              ||' WHERE im.nm_ne_id_in = aamr_iit_ne_id'
                                                ||' AND NOT EXISTS(SELECT ''X'''
                                                                ||' FROM nm_members rm'
                                                              ||' WHERE rm.nm_ne_id_in = aamr_ne_id'
                                                               ||' AND rm.nm_slk <= aamr_to_offset'
                                                                 ||' AND rm.nm_end_slk >= aamr_from_offset'
                                                                 ||' AND rm.nm_ne_id_of = im.nm_ne_id_of'
                                                                 ||' AND rm.nm_begin_mp <= im.nm_begin_mp'
                                                                 ||' AND rm.nm_end_mp >= im.nm_end_mp))'
                               ||' UNION ALL'
                               ||' SELECT ''Y'''
                                 ||' FROM nm_elements'
                                ||' WHERE nit_table_name IS NULL'
                                  ||' AND ne_id = aamr_ne_id'
                                  ||' AND ne_gty_group_type IS NULL'
                                  ||' AND EXISTS(SELECT ''X'''
                                               ||' FROM nm_members im'
                                              ||' WHERE im.nm_ne_id_in = aamr_iit_ne_id'
                                                ||' AND (im.nm_ne_id_of != aamr_ne_id'
                                                     ||' OR(im.nm_ne_id_of = aamr_ne_id'
                                                        ||' AND im.nm_begin_mp != aamr_from_offset)))'
                                ||'),''N'') partial_location'
                          ||',assets.xsp'
                          ||lv_select_list
                     ||' FROM awlrs_asset_maint_results'
                          ||',nm_inv_types'
                          ||','||lv_asset_tab
                          ||',nm_elements'
                          ||',nm_types'
                          ||',nm_units'
                          ||',nm_unit_domains'
    ;
    --
    IF pi_result_ids.COUNT > 0
     THEN
        lv_retval := lv_retval||' WHERE aamr_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
    ELSE
        lv_retval := lv_retval||' WHERE aamr_job_id = :job_id';
    END IF;
    --
    lv_retval := lv_retval||' AND aamr_inv_type = nit_inv_type'
                          ||' AND aamr_iit_ne_id = assets.pk'
                          ||' AND aamr_inv_type = assets.inv_type'
                          ||' AND aamr_ne_id = ne_id(+)'
                          ||' AND ne_nt_type = nt_type(+)'
                          ||' AND nt_length_unit = un_unit_id(+)'
                          ||' AND un_domain_id = ud_domain_id(+)'
                          ||' AND ud_domain_name(+) = ''LENGTH'''
    ;
    --
    RETURN lv_retval;
    --
  END get_query_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_query_results(pi_job_id           IN  awlrs_asset_maint_results.aamr_job_id%TYPE
                             ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                             ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                             ,pi_skip_n_rows      IN  PLS_INTEGER
                             ,pi_pagesize         IN  PLS_INTEGER
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    lv_offset  PLS_INTEGER := 1;
    --
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    --
    lv_driving_sql  CLOB;
    lv_cursor_sql   CLOB;
    --
  BEGIN
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc);
    /*
    ||Build the driving SQL with derived flexible attribute columns.
    */
    lv_driving_sql := get_query_sql(pi_job_id => pi_job_id);
    /*
    ||Build the overall cursor.
    */
    lv_cursor_sql := 'SELECT b.*'
                    ||' FROM (SELECT rownum ind'
                                ||' ,a.*'
                                ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                            ||' FROM ('||lv_driving_sql
                                  ||' ORDER BY '||NVL(lv_order_by,'ne_unique, aamr_from_offset, aamr_to_offset')||') a) b'
                        ||lv_row_restriction
    ;
    /*
    ||Open the cursor.
    */
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_job_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_job_id
             ,lv_lower_index;
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_query_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_query_results(pi_job_id           IN  awlrs_asset_maint_results.aamr_job_id%TYPE
                             ,pi_result_ids       IN  result_id_tab
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_driving_sql  CLOB;
    --
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    /*
    ||Build the array of ids.
    */
    FOR i IN 1..pi_result_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_result_ids(i));
      --
    END LOOP;
    /*
    ||Build the driving SQL with derived flexible attribute columns.
    */
    lv_driving_sql := get_query_sql(pi_job_id     => pi_job_id
                                   ,pi_result_ids => lt_ids);
    --
    OPEN po_cursor FOR lv_driving_sql
    USING lt_ids;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_query_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_query_results(pi_job_id           IN  awlrs_asset_maint_results.aamr_job_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    DELETE awlrs_asset_maint_results
     WHERE aamr_job_id = pi_job_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_query_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE bulk_update_asset_attributes(pi_assets     IN asset_identifier_tab
                                        ,pi_attributes IN awlrs_asset_api.flex_attr_tab)
    IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_iit                iit_tab;
    lt_old_asset_attribs  awlrs_asset_api.flex_attr_tab;
    --
    PROCEDURE add_asset(pi_iit_ne_id IN     nm_inv_items_all.iit_ne_id%TYPE
                       ,pi_iit_tab   IN OUT NOCOPY iit_tab)
      IS
      --
      lv_exists BOOLEAN := FALSE;
      --
    BEGIN
      --
      FOR i IN 1..pi_iit_tab.COUNT LOOP
        --
        IF pi_iit_tab(i).iit_ne_id = pi_iit_ne_id
         THEN
            lv_exists := TRUE;
            EXIT;
        END IF;
        --
      END LOOP;
      --
      IF NOT lv_exists
       THEN
          --
          pi_iit_tab(pi_iit_tab.COUNT+1) := nm3get.get_iit(pi_iit_ne_id => pi_iit_ne_id);
          --
          IF pi_iit_tab.COUNT > 1
           AND pi_iit_tab(pi_iit_tab.COUNT).iit_inv_type != pi_iit_tab(pi_iit_tab.COUNT-1).iit_inv_type
           THEN
              --All assets must be of the same type
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 67);
          END IF;
          --
      END IF;
      --
    END add_asset;
    --
  BEGIN
    /*
    ||Make sure we are not in historic mode.
    */
    awlrs_util.check_historic_mode;
    /*
    ||Check Assets are the same valid type.
    */
    FOR i IN 1..pi_assets.COUNT LOOP
      --
      lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_assets(i).asset_type);
      --
      IF lr_nit.nit_table_name IS NOT NULL
       THEN
          hig.raise_ner(pi_appl => 'NET'
                       ,pi_id   => 285);
      END IF;
      --
      add_asset(pi_iit_ne_id => pi_assets(i).asset_id
               ,pi_iit_tab   => lt_iit);
      --
    END LOOP;
    --
    FOR i IN 1..lt_iit.COUNT LOOP
      /*
      ||Get the existing attribute values
      */
      FOR j IN 1..pi_attributes.COUNT LOOP
        --
        lt_old_asset_attribs(i).attrib_name := pi_attributes(j).attrib_name;
        lt_old_asset_attribs(i).scrn_text   := pi_attributes(j).scrn_text;
        lt_old_asset_attribs(i).char_value  := awlrs_asset_api.get_attrib_value(pi_inv_type  => lt_iit(i).iit_inv_type
                                                                               ,pi_ne_id => lt_iit(i).iit_ne_id
                                                                               ,pi_attrib_name => pi_attributes(j).attrib_name);
        --
      END LOOP;
      --
      awlrs_asset_api.update_asset(pi_iit_ne_id       => lt_iit(i).iit_ne_id
                                  ,pi_old_primary_key => lt_iit(i).iit_primary_key
                                  ,pi_old_admin_unit  => lt_iit(i).iit_admin_unit
                                  ,pi_old_xsp         => lt_iit(i).iit_x_sect
                                  ,pi_old_description => lt_iit(i).iit_descr
                                  ,pi_old_start_date  => lt_iit(i).iit_start_date
                                  ,pi_old_end_date    => lt_iit(i).iit_end_date
                                  ,pi_old_notes       => lt_iit(i).iit_note
                                  ,pi_new_primary_key => lt_iit(i).iit_primary_key
                                  ,pi_new_admin_unit  => lt_iit(i).iit_admin_unit
                                  ,pi_new_xsp         => lt_iit(i).iit_x_sect
                                  ,pi_new_description => lt_iit(i).iit_descr
                                  ,pi_new_start_date  => lt_iit(i).iit_start_date
                                  ,pi_new_end_date    => lt_iit(i).iit_end_date
                                  ,pi_new_notes       => lt_iit(i).iit_note
                                  ,pi_old_attributes  => lt_old_asset_attribs
                                  ,pi_new_attributes  => pi_attributes);
    END LOOP;
    --
  END bulk_update_asset_attributes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE bulk_update_asset_attributes(pi_asset_ids          IN  awlrs_util.ne_id_tab
                                        ,pi_asset_types        IN  asset_types_tab
                                        ,pi_attrib_names       IN  awlrs_asset_api.attrib_name_tab
                                        ,pi_attrib_scrn_texts  IN  awlrs_asset_api.attrib_scrn_text_tab
                                        ,pi_attrib_char_values IN  awlrs_asset_api.attrib_value_tab
                                        ,po_message_severity   OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor     OUT sys_refcursor)
    IS
    --
    lt_assets         asset_identifier_tab;
    lt_asset_attribs  awlrs_asset_api.flex_attr_tab;
    --
  BEGIN
    /*
    ||Check the parameters
    */
    IF pi_asset_ids.COUNT != pi_asset_types.COUNT
     THEN
        --The tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_maint_api.bulk_update_asset_attributes');
    END IF;
    --
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      IF pi_asset_ids(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_ids('||i||')');
      END IF;
      --
      IF pi_asset_types(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_types('||i||')');
      END IF;
      --
      lt_assets(i).asset_id := pi_asset_ids(i);
      lt_assets(i).asset_type := pi_asset_types(i);
      --
    END LOOP;
    --
    IF pi_attrib_names.COUNT != pi_attrib_scrn_texts.COUNT
     OR pi_attrib_names.COUNT != pi_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_maint_api.bulk_update_asset_attributes');
    END IF;
    --
    FOR i IN 1..pi_attrib_names.COUNT LOOP
      --
      lt_asset_attribs(i).attrib_name := pi_attrib_names(i);
      lt_asset_attribs(i).scrn_text   := pi_attrib_scrn_texts(i);
      lt_asset_attribs(i).char_value  := pi_attrib_char_values(i);
      --
    END LOOP;
    --
    bulk_update_asset_attributes(pi_assets     => lt_assets
                                ,pi_attributes => lt_asset_attribs);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END bulk_update_asset_attributes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE compare_asset_globals
    IS
    --
    lv_sql  nm3type.max_varchar2;
    --
    CURSOR get_attr(cp_inv_type IN nm_inv_types.nit_inv_type%TYPE)
        IS
    SELECT ita_attrib_name
      FROM nm_inv_type_attribs
     WHERE ita_inv_type = cp_inv_type
         ;
    --
  BEGIN
    /*
    ||Check the end dates
    */
    IF g_iit_rec_1.iit_end_date IS NOT NULL
     OR g_iit_rec_2.iit_end_date IS NOT NULL
     THEN
        --End Dated assets cannot be merged
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 82);
    END IF;
    /*
    ||Check the fixed attributes
    */
    IF --Admin Unit
     g_iit_rec_1.iit_admin_unit != g_iit_rec_2.iit_admin_unit
     OR (g_iit_rec_1.iit_admin_unit IS NULL AND g_iit_rec_2.iit_admin_unit IS NOT NULL)
     OR (g_iit_rec_1.iit_admin_unit IS NOT NULL AND g_iit_rec_2.iit_admin_unit IS NULL)
     --XSP
     OR g_iit_rec_1.iit_x_sect != g_iit_rec_2.iit_x_sect
     OR (g_iit_rec_1.iit_x_sect IS NULL AND g_iit_rec_2.iit_x_sect IS NOT NULL)
     OR (g_iit_rec_1.iit_x_sect IS NOT NULL AND g_iit_rec_2.iit_x_sect IS NULL)
     THEN
        --Asset Attribution Does Not Match
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 64);
    END IF;
    /*
    ||Check the flexible attributes
    */
    IF gt_attr_names.COUNT = 0
     THEN
        OPEN  get_attr(g_iit_rec_1.iit_inv_type);
        FETCH get_attr
         BULK COLLECT
         INTO gt_attr_names;
        CLOSE get_attr;
    END IF;
    --
    FOR i IN 1..gt_attr_names.COUNT LOOP
      --
      lv_sql := NULL;
      --
      lv_sql := 'BEGIN'
      ||CHR(10)||'  IF awlrs_asset_maint_api.g_iit_rec_1.'||gt_attr_names(i)||' != awlrs_asset_maint_api.g_iit_rec_2.'||gt_attr_names(i)
      ||CHR(10)||'   OR (awlrs_asset_maint_api.g_iit_rec_1.'||gt_attr_names(i)||' IS NULL AND awlrs_asset_maint_api.g_iit_rec_2.'||gt_attr_names(i)||' IS NOT NULL)'
      ||CHR(10)||'   OR (awlrs_asset_maint_api.g_iit_rec_1.'||gt_attr_names(i)||' IS NOT NULL AND awlrs_asset_maint_api.g_iit_rec_2.'||gt_attr_names(i)||' IS NULL)'
      ||CHR(10)||'   THEN '
      ||CHR(10)||'      hig.raise_ner(pi_appl => ''AWLRS'''
      ||CHR(10)||'                   ,pi_id   => 64);'
      ||CHR(10)||'  END IF;'
      ||CHR(10)||'END;'
      ;
      --
      IF lv_sql IS NOT NULL
       THEN
          EXECUTE IMMEDIATE lv_sql;
      END IF;
      --
    END LOOP;
    --
  END compare_asset_globals;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE contiguity_check(pi_assets         IN     asset_identifier_tab
                            ,pi_ne_id          IN     nm_elements_all.ne_id%TYPE
                            ,po_new_loc_job_id IN OUT NUMBER)
    IS
    --
    lv_element_extent     NUMBER;
    lv_combined_extent    NUMBER;
    lv_asset_extent       NUMBER;
    lv_minus_extent       NUMBER;
    lv_no_overlap_extent  NUMBER;
    lv_remaining_count    NUMBER;
    lv_db_chk             nm_elements_all.ne_id%TYPE;
    lv_is_db              BOOLEAN;
    --
    lv_start timestamp;
    lv_end   timestamp;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lt_pla  nm_placement_array;
    --
    CURSOR chk_db(cp_ne_id   IN nm_elements_all.ne_id%TYPE
                 ,cp_slk     IN nm_members_all.nm_slk%TYPE
                 ,cp_end_slk IN nm_members_all.nm_end_slk%TYPE)
        IS
    SELECT 1
      FROM dual
     WHERE EXISTS(SELECT 'x'
                    FROM nm_members
                        ,nm_elements
                   WHERE nm_ne_id_in = cp_ne_id
                     AND nm_slk = cp_slk
                     AND nm_end_slk = cp_end_slk
                     AND nm_ne_id_of = ne_id
                     AND ne_type = 'D')
         ;
    --
  BEGIN
    /*
    ||Build a temp extent for all the Assets.
    */
    FOR i IN 1..pi_assets.COUNT LOOP
      --
      nm3extent.create_temp_ne(pi_source_id => pi_assets(i).asset_id
                              ,pi_source    => nm3extent.get_route
                              ,pi_begin_mp  => NULL
                              ,pi_end_mp    => NULL
                              ,po_job_id    => lv_asset_extent);
      --
      IF i = 1
       THEN
          --
          lv_combined_extent := lv_asset_extent;
          --
      ELSE
          --
          nm3extent.combine_temp_nes(pi_job_id_1       => lv_combined_extent
                                    ,pi_job_id_2       => lv_asset_extent
                                    ,pi_check_overlaps => FALSE);
          --
      END IF;
      --
    END LOOP;
    /*
    ||Build a temp extent for the Element.
    */
    nm3extent.create_temp_ne(pi_source_id => pi_ne_id
                            ,pi_source    => nm3extent.get_route
                            ,pi_begin_mp  => NULL
                            ,pi_end_mp    => NULL
                            ,po_job_id    => lv_element_extent);
    /*
    ||Check whether assets are located only on the given element.
    */
    nm3extent.nte_minus_nte(pi_nte_1      => lv_combined_extent
                           ,pi_nte_2      => lv_element_extent
                           ,po_nte_result => lv_minus_extent);
    --
    SELECT count(*)
      INTO lv_remaining_count
      FROM nm_nw_temp_extents
     WHERE nte_job_id = lv_minus_extent
         ;
    --
    IF lv_remaining_count > 0
     THEN
        --Assets have locations beyond the specified element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 65);
    END IF;
    --
    lv_no_overlap_extent := nm3extent.remove_overlaps(pi_nte_id => lv_combined_extent);
    --
    lt_pla := nm3pla.get_connected_chunks(p_nte_job_id => lv_no_overlap_extent
                                         ,p_route_id   => pi_ne_id
                                         ,p_obj_type   => nm3net.get_ne(pi_ne_id).ne_gty_group_type);
    --
    IF lt_pla.npa_placement_array.COUNT != 1
     THEN
        /*
        ||If we are working with a group the gap in the
        ||placement array may be due to a distance break
        ||which is ok in this scenario
        */
        lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
        --
        IF lr_ne.ne_gty_group_type IS NOT NULL
         AND nm3net.is_gty_linear(p_gty => lr_ne.ne_gty_group_type) = 'Y'
         THEN
            --
            FOR i IN 2..lt_pla.npa_placement_array.COUNT LOOP
              --
              OPEN  chk_db(pi_ne_id
                          ,lt_pla.npa_placement_array(i-1).pl_end
                          ,lt_pla.npa_placement_array(i).pl_start);
              FETCH chk_db
               INTO lv_db_chk;
              lv_is_db := chk_db%FOUND;
              CLOSE chk_db;
              --
              IF NOT lv_is_db
               THEN
                  --Asset locations are not contiguous
                  hig.raise_ner(pi_appl => 'AWLRS'
                               ,pi_id   => 66);
              END IF;
              --
            END LOOP;
            --
        ELSE
            --
            --Asset locations are not contiguous
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 66);
        END IF;
    END IF;
    --
    po_new_loc_job_id := lv_no_overlap_extent;
    --
  END contiguity_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_assets_can_be_merged(pi_assets         IN     asset_identifier_tab
                                      ,pi_ne_id          IN     nm_elements_all.ne_id%TYPE
                                      ,po_new_loc_job_id IN OUT NUMBER)
    IS
    --
    lt_iit  iit_tab;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Make sure we are not in historic mode.
    */
    awlrs_util.check_historic_mode;
    /*
    ||Check Assets are the same valid type.
    */
    FOR i IN 1..pi_assets.COUNT LOOP
      --
      lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_assets(i).asset_type);
      --
      IF lr_nit.nit_table_name IS NOT NULL
       THEN
          hig.raise_ner(pi_appl => 'NET'
                       ,pi_id   => 285);
      END IF;
      --
      lt_iit(i) := nm3get.get_iit(pi_iit_ne_id => pi_assets(i).asset_id);
      --
      IF i > 1
       AND lt_iit(i).iit_inv_type != lt_iit(i-1).iit_inv_type
       THEN
          --All assets must be of the same type
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 67);
      END IF;
      --
    END LOOP;
    --
    g_iit_rec_1 := lt_iit(1);
    /*
    ||Raise an error if the asset type is hierarchical.
    */
    IF nm3inv.inv_type_is_hierarchical(pi_type => g_iit_rec_1.iit_inv_type)
     THEN
        --Merge of hierarchical assets is not supported.
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 68);
    END IF;
    /*
    ||Check Assets have the same attribution.
    */
    gt_attr_names.DELETE;
    --
    FOR i IN 2..lt_iit.COUNT LOOP
      --
      g_iit_rec_2 := lt_iit(i);
      --
      compare_asset_globals;
      --
    END LOOP;
    /*
    ||Check Assets are contiguous.
    */
    contiguity_check(pi_assets         => pi_assets
                    ,pi_ne_id          => pi_ne_id
                    ,po_new_loc_job_id => po_new_loc_job_id);
    --
  END check_assets_can_be_merged;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_assets_can_be_merged(pi_asset_ids        IN  awlrs_util.ne_id_tab
                                      ,pi_asset_types      IN  asset_types_tab
                                      ,pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_new_loc_job_id  NUMBER;
    --
    lt_assets  asset_identifier_tab;
    --
  BEGIN
    /*
    ||Check the parameters
    */
    IF pi_asset_ids.COUNT != pi_asset_types.COUNT
     THEN
        --The tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_maint_api.delete_assets');
    END IF;
    --
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      IF pi_asset_ids(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_ids('||i||')');
      END IF;
      --
      IF pi_asset_types(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_types('||i||')');
      END IF;
      --
      lt_assets(i).asset_id := pi_asset_ids(i);
      lt_assets(i).asset_type := pi_asset_types(i);
      --
    END LOOP;
    --
    check_assets_can_be_merged(pi_assets         => lt_assets
                              ,pi_ne_id          => pi_ne_id
                              ,po_new_loc_job_id => lv_new_loc_job_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_assets_can_be_merged;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE merge_assets(pi_asset_ids        IN  awlrs_util.ne_id_tab
                        ,pi_asset_types      IN  asset_types_tab
                        ,pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                        ,po_new_asset_id     OUT nm_inv_items_all.iit_ne_id%TYPE
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_new_loc_job_id  NUMBER;
    lv_effective_date  DATE := TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY');
    lv_warning_code    VARCHAR2(1000);
    lv_warning_msg     VARCHAR2(1000);
    --
    lt_assets  asset_identifier_tab;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT merge_assets_sp;
    /*
    ||Check the parameters
    */
    IF pi_asset_ids.COUNT != pi_asset_types.COUNT
     THEN
        --The tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_maint_api.delete_assets');
    END IF;
    --
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      IF pi_asset_ids(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_ids('||i||')');
      END IF;
      --
      IF pi_asset_types(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_types('||i||')');
      END IF;
      --
      lt_assets(i).asset_id := pi_asset_ids(i);
      lt_assets(i).asset_type := pi_asset_types(i);
      --
    END LOOP;
    /*
    ||Validate the assets passed in.
    */
    check_assets_can_be_merged(pi_assets         => lt_assets
                              ,pi_ne_id          => pi_ne_id
                              ,po_new_loc_job_id => lv_new_loc_job_id);
    /*
    ||Lock the assets and their locations.
    */
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      nm3lock.lock_inv_item_and_members(pi_iit_ne_id      => pi_asset_ids(i)
                                       ,p_lock_for_update => TRUE);
      --
    END LOOP;
    /*
    ||Create the new asset with the merged location.
    */
    g_iit_rec_1.iit_ne_id := ne_id_seq.NEXTVAL;
    /*
    ||Set the primary key if it is not in use as an attribute
    */
    IF NOT nm3inv.attrib_in_use(pi_inv_type    => g_iit_rec_1.iit_inv_type
                               ,pi_attrib_name => 'IIT_PRIMARY_KEY')
     THEN
        g_iit_rec_1.iit_primary_key := g_iit_rec_1.iit_ne_id;
    END IF;
    /*
    ||Set the start date
    */
    g_iit_rec_1.iit_start_date := lv_effective_date;
    --
    nm3ins.ins_iit(g_iit_rec_1);
    --
    nm3homo.homo_update(p_temp_ne_id_in  => lv_new_loc_job_id
                       ,p_iit_ne_id      => g_iit_rec_1.iit_ne_id
                       ,p_effective_date => lv_effective_date
                       ,p_warning_code   => lv_warning_code
                       ,p_warning_msg    => lv_warning_msg);
    /*
    ||End date the original assets.
    */
    FORALL i IN 1..pi_asset_ids.COUNT
    UPDATE nm_inv_items_all
       SET iit_end_date = lv_effective_date
     WHERE iit_ne_id = pi_asset_ids(i)
         ;
    /*
    ||Set the new asset id.
    */
    po_new_asset_id := g_iit_rec_1.iit_ne_id;
    /*
    ||Set the message parameters.
    */
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO merge_assets_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END merge_assets;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE remove_spatial_data(pi_asset_ids IN int_array_type)
    IS
  BEGIN
    --
    nm3sdo_ops.remove_spatial_data(p_ids => pi_asset_ids);
    --
  END remove_spatial_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_child_assets(pi_asset_id IN  nm_inv_items_all.iit_ne_id%TYPE
                               ,po_summary  OUT CLOB)
    IS
    --
    lt_ids  int_array_type := int_array_type();
    /*
    ||Since the FK based upon iit_foreign_key does not allow deletion
    ||of a parent asset while a child remains and the trigger
    ||nm_inv_items_all_b_upd prevents update of iit_foreign_key
    ||the code below cannot leave children with a non-mandatory
    ||relationship orphaned so delete all children.
    ||Hence the references to itg_mandatory below are commented out.
    */
    CURSOR get_children(cp_asset_id IN nm_inv_items_all.iit_ne_id%TYPE)
        IS
    SELECT iig_item_id
          ,iit_inv_type
          ,iit_primary_key
          ,iig_top_id
      FROM nm_inv_item_groupings
          ,nm_inv_items_all
          ,nm_inv_type_groupings
     WHERE iig_item_id = iit_ne_id
       AND iit_inv_type = itg_inv_type
   CONNECT BY PRIOR iig_item_id = iig_parent_id
       --AND itg_mandatory = 'Y'
     START WITH iig_parent_id = cp_asset_id
       --AND itg_mandatory = 'Y'
     ORDER
        BY level DESC
         ;
    --
    TYPE iig_tab IS TABLE OF get_children%ROWTYPE;
    lt_children  iig_tab;
    --
  BEGIN
    /*
    ||Get the child assets
    */
    OPEN  get_children(pi_asset_id);
    FETCH get_children
     BULK COLLECT
     INTO lt_children;
    CLOSE get_children;
    --
    IF lt_children.COUNT > 0
     THEN
        /*
        ||Lock the assets and their locations.
        */
        FOR i IN 1..lt_children.COUNT LOOP
          --
          nm3lock.lock_inv_item_and_members(pi_iit_ne_id      => lt_children(i).iig_item_id
                                           ,p_lock_for_update => TRUE);
          --
        END LOOP;
        /*
        ||Delete Groupings
        */
        FORALL i IN 1..lt_children.COUNT
        DELETE
          FROM nm_inv_item_groupings_all
         WHERE iig_item_id = lt_children(i).iig_item_id
           AND iig_top_id = lt_children(i).iig_top_id
             ;
        /*
        ||Delete Locations
        */
        FORALL i IN 1..lt_children.COUNT
        DELETE
          FROM nm_members_all m
         WHERE m.nm_ne_id_in = lt_children(i).iig_item_id
             ;
        /*
        ||Delete Items
        */
        FORALL i IN 1..lt_children.COUNT
        DELETE
          FROM nm_inv_items_all
         WHERE iit_ne_id = lt_children(i).iig_item_id
             ;
        /*
        ||Delete Document Associations
        */
        FORALL i IN 1..lt_children.COUNT
        DELETE
          FROM doc_assocs
         WHERE das_rec_id = TO_CHAR(lt_children(i).iig_item_id)
           AND (das_table_name IN ('NM_INV_ITEMS_ALL','NM_INV_ITEMS','INV_ITEMS_ALL','INV_ITEMS')
                OR das_table_name IN (SELECT dgs_table_syn
                                        FROM doc_gate_syns
                                       WHERE dgs_dgt_table_name IN ('NM_INV_ITEMS_ALL','NM_INV_ITEMS','INV_ITEMS_ALL','INV_ITEMS')))
             ;
        /*
        ||Delete Spatial data
        */
        FOR i IN 1..lt_children.COUNT LOOP
          lt_ids.extend;
          lt_ids(i) := lt_children(i).iig_item_id;
        END LOOP;
        --
        remove_spatial_data(pi_asset_ids => lt_ids);
        /*
        ||Delete Asset Maint results table
        */
        FORALL i IN 1..lt_children.COUNT
        DELETE awlrs_asset_maint_results
         WHERE aamr_iit_ne_id = lt_children(i).iig_item_id
             ;
        /*
        ||Write to the summary
        */
        po_summary := po_summary||CHR(10)||'  '||hig.get_ner(pi_appl => 'AWLRS'
                                                            ,pi_id   => 81).ner_descr;
        --
        FOR i IN 1..lt_children.COUNT LOOP
          --
          po_summary := po_summary||CHR(10)||'    '||lt_children(i).iit_primary_key||' ('||lt_children(i).iit_inv_type||')';
          --
        END LOOP;
        --
    END IF;
    --
  END delete_child_assets;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset(pi_iit_ne_id    IN     nm_inv_items_all.iit_ne_id%TYPE
                        ,pi_nit_inv_type IN     nm_inv_types_all.nit_inv_type%TYPE
                        ,po_summary      IN OUT NOCOPY CLOB)
    IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    lr_iit  nm_inv_items_all%ROWTYPE;
    --
    lv_asset_name     VARCHAR2(100) := pi_iit_ne_id||' ('||pi_nit_inv_type||')';
    lv_child_summary  CLOB;
    --
    CURSOR get_iit(cp_iit_ne_id    IN nm_inv_items_all.iit_ne_id%TYPE
                  ,cp_nit_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
        IS
    SELECT *
      FROM nm_inv_items
     WHERE iit_ne_id = cp_iit_ne_id
       AND iit_inv_type = cp_nit_inv_type
         ;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT delete_asset_sp;
    /*
    ||Check the asset and lock it
    */
    lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_nit_inv_type);
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 285);
    END IF;
    --
    OPEN  get_iit(pi_iit_ne_id
                 ,pi_nit_inv_type);
    FETCH get_iit
     INTO lr_iit;
    CLOSE get_iit;
    --
    IF lr_iit.iit_ne_id IS NULL
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 67);
    END IF;
    --
    lv_asset_name := lr_iit.iit_primary_key||' ('||pi_nit_inv_type||')';
    --
    nm3lock.lock_inv_item_and_members(pi_iit_ne_id      => pi_iit_ne_id
                                     ,p_lock_for_update => TRUE);
    /*
    ||Delete Child Assets.
    */
    delete_child_assets(pi_asset_id => pi_iit_ne_id
                      ,po_summary   => lv_child_summary);
    /*
    ||Delete Groupings
    */
    DELETE
      FROM nm_inv_item_groupings_all
     WHERE iig_item_id  = pi_iit_ne_id
        OR iig_parent_id = pi_iit_ne_id
         ;
    /*
    ||Delete Locations
    */
    DELETE
      FROM nm_members_all m
     WHERE m.nm_ne_id_in = pi_iit_ne_id
         ;
    /*
    ||Delete Items
    */
    DELETE
      FROM nm_inv_items_all
     WHERE iit_ne_id = pi_iit_ne_id
         ;
    /*
    ||Delete Document Associations
    */
    DELETE
      FROM doc_assocs
     WHERE das_rec_id = TO_CHAR(pi_iit_ne_id)
       AND (das_table_name IN ('NM_INV_ITEMS_ALL','NM_INV_ITEMS','INV_ITEMS_ALL','INV_ITEMS')
            OR das_table_name IN (SELECT dgs_table_syn
                                    FROM doc_gate_syns
                                   WHERE dgs_dgt_table_name IN ('NM_INV_ITEMS_ALL','NM_INV_ITEMS','INV_ITEMS_ALL','INV_ITEMS')))
         ;
    /*
    ||Delete Spatial data
    */
    remove_spatial_data(pi_asset_ids => int_array_type(pi_iit_ne_id));
    /*
    ||Delete Asset Maint results table
    */
    DELETE awlrs_asset_maint_results
     WHERE aamr_iit_ne_id = pi_iit_ne_id
         ;
    --
    po_summary := po_summary||CHR(10)||hig.get_ner(pi_appl => 'AWLRS'
                                                  ,pi_id   => 79).ner_descr||' '||lv_asset_name
                            ||lv_child_summary;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_asset_sp;
        po_summary := po_summary||CHR(10)||hig.get_ner(pi_appl => 'AWLRS'
                                                      ,pi_id   => 78).ner_descr||' '||lv_asset_name||': '||nm3flx.parse_error_message(SQLERRM);
  END delete_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_assets(pi_assets  IN  asset_identifier_tab
                         ,po_summary IN OUT NOCOPY CLOB)
    IS
    --
  BEGIN
    --
    po_summary := hig.get_ner(pi_appl => 'AWLRS'
                             ,pi_id   => 77).ner_descr||CHR(10);
    --
    FOR i IN 1..pi_assets.COUNT LOOP
      --
      delete_asset(pi_iit_ne_id    => pi_assets(i).asset_id
                  ,pi_nit_inv_type => pi_assets(i).asset_type
                  ,po_summary      => po_summary);
      --
    END LOOP;
    --
  END delete_assets;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_assets(pi_asset_ids        IN  awlrs_util.ne_id_tab
                         ,pi_asset_types      IN  asset_types_tab
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message  CLOB;
    --
    lt_assets  asset_identifier_tab;
    --
  BEGIN
    /*
    ||Check the parameters
    */
    IF pi_asset_ids.COUNT != pi_asset_types.COUNT
     THEN
        --The tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_maint_api.delete_assets');
    END IF;
    --
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      IF pi_asset_ids(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_ids('||i||')');
      END IF;
      --
      IF pi_asset_types(i) IS NULL
       THEN
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 214
                       ,pi_supplementary_info => 'pi_asset_types('||i||')');
      END IF;
      --
      lt_assets(i).asset_id := pi_asset_ids(i);
      lt_assets(i).asset_type := pi_asset_types(i);
      --
    END LOOP;
    /*
    ||Delete the asset
    */
    delete_assets(pi_assets  => lt_assets
                 ,po_summary => lv_message);
    /*
    ||Return the summary
    */
    OPEN po_cursor FOR
    SELECT lv_message summary
      FROM dual
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_assets;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE save_asset_criteria(pi_name                 IN  awlrs_saved_asset_criteria.asac_name%TYPE
                               ,pi_description          IN  awlrs_saved_asset_criteria.asac_description%TYPE
                               ,pi_criteria             IN  awlrs_saved_asset_criteria.asac_criteria%TYPE
                               ,pi_overwrite_existing   IN  VARCHAR2 DEFAULT 'N'
                               ,po_message_severity     OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    lv_asac_id  awlrs_saved_asset_criteria.asac_id%TYPE;
    --
    lt_messages     awlrs_message_tab := awlrs_message_tab();
    --
    CURSOR search_exists(cp_name IN awlrs_saved_asset_criteria.asac_name%TYPE)
        IS
    SELECT asac_id
      FROM awlrs_saved_asset_criteria
     WHERE asac_name = cp_name
         ;
    --
  BEGIN
    --
    IF pi_overwrite_existing = 'N'
     THEN
        --
        OPEN  search_exists(pi_name);
        FETCH search_exists
         INTO lv_asac_id;
        CLOSE search_exists;
        --
        IF lv_asac_id IS NOT NULL
         THEN
            awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'AWLRS'
                                             ,pi_ner_id      => 46
                                             ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                             ,po_message_tab => lt_messages);
        END IF;
        --
    END IF;
    --
    IF lt_messages.COUNT = 0
     THEN
        MERGE
         INTO awlrs_saved_asset_criteria
        USING (SELECT pi_name name
                     ,pi_description descr
                     ,pi_criteria criteria
                 FROM DUAL) param
           ON (asac_name = param.name)
         WHEN MATCHED
          THEN
             UPDATE SET asac_description = param.descr
                       ,asac_criteria = param.criteria
         WHEN NOT MATCHED
          THEN
             INSERT(asac_id
                   ,asac_name
                   ,asac_description
                   ,asac_criteria)
             VALUES(asac_id_seq.NEXTVAL
                   ,param.name
                   ,param.descr
                   ,param.criteria)
        ;
    END IF;
    --
    IF lt_messages.COUNT > 0
     THEN
        awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                     ,po_cursor      => po_message_cursor);
        awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                       ,po_message_severity => po_message_severity);
    ELSE
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END save_asset_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_criteria(pi_asac_id          IN  awlrs_saved_asset_criteria.asac_id%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    DELETE awlrs_saved_asset_criteria
     WHERE asac_id = pi_asac_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_criteria(pi_asac_id          IN  awlrs_saved_asset_criteria.asac_id%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asac_id           id
          ,asac_name         name
          ,asac_description  description
          ,asac_criteria     criteria
      FROM awlrs_saved_asset_criteria
     WHERE asac_id = pi_asac_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_criteria_list(po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asac_id                   id
          ,asac_name                 name
          ,asac_description          description
      FROM awlrs_saved_asset_criteria
     ORDER
        BY asac_name
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_criteria_list;

END awlrs_asset_maint_api;
/
