CREATE OR REPLACE PACKAGE BODY awlrs_asset_maint_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_asset_maint_api.pkb-arc   1.1   Jun 06 2019 17:20:14   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_asset_maint_api.pkb  $
  --       Date into PVCS   : $Date:   Jun 06 2019 17:20:14  $
  --       Date fetched Out : $Modtime:   Jun 06 2019 17:17:10  $
  --       Version          : $Revision:   1.1  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.1  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_asset_maint_api';
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
  PROCEDURE get_asset_types(po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nit_inv_type asset_type_code
          ,nit_descr asset_type_description
      FROM nm_inv_types
     WHERE nit_category = 'I' /*TODO - Should be able to support FT Asset Types */
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
    UNION ALL
    SELECT NULL asset_type_code
          ,'All Asset Types' asset_type_description
      FROM dual
     ORDER
        BY 1 NULLS FIRST
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
    lv_datum_sql   nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                ||CHR(10)||'SELECT id'
                                ||CHR(10)||'      ,name'
                                ||CHR(10)||'      ,min_offset'
                                ||CHR(10)||'      ,max_offset'
                                ||CHR(10)||'      ,row_count'
                                ||CHR(10)||'  FROM (SELECT rownum ind'
                                ||CHR(10)||'              ,ne_id id'
                                ||CHR(10)||'              ,ne_unique||'' - ''||ne_descr name'
                                ||CHR(10)||'              ,0 min_offset'
                                ||CHR(10)||'              ,ne_length max_offset'
                                ||CHR(10)||'              ,CASE'
                                ||CHR(10)||'                 WHEN f.filter_value IS NULL THEN 0'
                                ||CHR(10)||'                 WHEN UPPER(ne_unique) = f.filter_value THEN 1'
                                ||CHR(10)||'                 WHEN UPPER(ne_descr) = f.filter_value THEN 2'
                                ||CHR(10)||'                 WHEN UPPER(ne_unique) LIKE f.filter_value||''%'' THEN 3'
                                ||CHR(10)||'                 WHEN UPPER(ne_descr) LIKE f.filter_value||''%'' THEN 4'
                                ||CHR(10)||'                 ELSE 5'
                                ||CHR(10)||'               END match_quality'
                                ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                ||CHR(10)||'          FROM nm_elements'
                                ||CHR(10)||'              ,filter_tab f'
                                ||CHR(10)||'         WHERE ne_type = ''S'''
    ;
    --
    lv_group_sql  nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                               ||CHR(10)||'SELECT id'
                               ||CHR(10)||'      ,name'
                               ||CHR(10)||'      ,min_offset'
                               ||CHR(10)||'      ,max_offset'
                               ||CHR(10)||'      ,row_count'
                               ||CHR(10)||'  FROM (SELECT rownum ind'
                               ||CHR(10)||'              ,ne_id id'
                               ||CHR(10)||'              ,ne_unique||'' - ''||ne_descr name'
                               ||CHR(10)||'              ,(SELECT MIN(nm_slk) FROM nm_members WHERE nm_ne_id_in = ne_id) min_offset'
                               ||CHR(10)||'              ,(SELECT MAX(nm_end_slk) FROM nm_members WHERE nm_ne_id_in = ne_id) max_offset'
                               ||CHR(10)||'              ,CASE'
                               ||CHR(10)||'                 WHEN f.filter_value IS NULL THEN 0'
                               ||CHR(10)||'                 WHEN UPPER(ne_unique) = f.filter_value THEN 1'
                               ||CHR(10)||'                 WHEN UPPER(ne_descr) = f.filter_value THEN 2'
                               ||CHR(10)||'                 WHEN UPPER(ne_unique) LIKE f.filter_value||''%'' THEN 3'
                               ||CHR(10)||'                 WHEN UPPER(ne_descr) LIKE f.filter_value||''%'' THEN 4'
                               ||CHR(10)||'                 ELSE 5'
                               ||CHR(10)||'               END match_quality'
                               ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                               ||CHR(10)||'          FROM nm_elements'
                               ||CHR(10)||'              ,filter_tab f'
                               ||CHR(10)||'         WHERE ne_gty_group_type = :grp_type'
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
        lv_cursor_sql := lv_datum_sql;
    END IF;
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'           AND UPPER(ne_unique||'' - ''||ne_descr) LIKE ''%''||f.filter_value||''%''';
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
                     ||CHR(10)||'         ORDER BY match_quality,ne_unique)'
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
  FUNCTION get_job_types(pi_job_id IN awlrs_asset_maint_results.aamr_job_id%TYPE)
    RETURN nit_tab IS
    --
    lt_retval nit_tab;
    --
  BEGIN
    --
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
  PROCEDURE set_job_attributes(pi_job_id   IN     awlrs_asset_maint_results.aamr_job_id%TYPE
                              ,pi_nit_tab  IN     nit_tab
                              ,po_attr_tab IN OUT NOCOPY ita_by_nit_tab)
    IS
    --
    lt_ita  ita_tab;
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
       AND ita_inv_type IN(SELECT DISTINCT aamr_inv_type res_type
                             FROM awlrs_asset_maint_results aamr
                            WHERE aamr_job_id = pi_job_id)
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
  ------------------------------------------------------------------------------
  --
  FUNCTION get_job_attribs_sql(pi_job_id IN awlrs_asset_maint_results.aamr_job_id%TYPE)
    RETURN CLOB IS
    --
    lv_retval       CLOB;
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
    lt_nit := get_job_types(pi_job_id => pi_job_id);
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
    set_job_attributes(pi_job_id   => pi_job_id
                      ,pi_nit_tab  => lt_nit
                      ,po_attr_tab => lt_ita_by_nit);
    /*
    ||Build a CASE statement for each attribute column
    ||to be returned in the cursor.
    */
    FOR i IN 1..lv_max_attribs LOOP
      --
      lv_retval := lv_retval||CHR(10)||',CASE iit_inv_type';
      --
      FOR j IN 1..lt_nit.COUNT LOOP
        --
        lv_retval := lv_retval||' WHEN '''||lt_nit(j).nit_inv_type||''' THEN '
                              ||CASE
                                  WHEN i <= NVL(lt_ita_by_nit(lt_nit(j).nit_inv_type).COUNT,0)
                                   THEN
                                      'awlrs_asset_api.get_attrib_value(iit_inv_type,iit_ne_id,'''||lt_ita_by_nit(lt_nit(j).nit_inv_type)(i).ita_attrib_name||''')'
                                  ELSE
                                      'NULL'
                                END;
        --
      END LOOP;
      --
      lv_retval := lv_retval||' END x_'||LPAD(i,2,0);
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END get_job_attribs_sql;

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
    --
    lr_ngq  nm_gaz_query%ROWTYPE;
    lr_ne   nm_elements_all%ROWTYPE;
    --
    TYPE ngqt_tab IS TABLE OF nm_gaz_query_types%ROWTYPE INDEX BY BINARY_INTEGER;
    lt_ngqt  ngqt_tab;
    --
    lt_asset_types  asset_types_tab;
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
        lr_ngq.ngq_source_id := pi_net_filter_ne_id;
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
             WHERE nit_category = 'I' /*TODO - Should be able to support FT Asset Types */
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
    IF pi_net_filter_ne_id IS NOT NULL
     THEN
        IF lv_location_out_type = NVL(lr_ne.ne_gty_group_type,'~~~~~')
         THEN
            --
            lv_sql := lv_sql||',pla.pl_ne_id'
                            ||',pla.pl_start'
                            ||',pla.pl_end'
                       ||' FROM (SELECT ngqi_item_type'
                                    ||',ngqi_item_id'
                               ||' FROM nm_gaz_query_item_list'
                              ||' WHERE ngqi_job_id = :gaz_results_id'
                                ||' AND '||lv_where||') items'
                            ||',TABLE(nm3pla.get_connected_chunks(pi_ne_id => ngqi_item_id,pi_route_id => :net_filter_ne_id).npa_placement_array) pla'
            ;
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
                      ||'   AND nm_ne_id_of = :net_filter_ne_id'
                 ;
            --
            EXECUTE IMMEDIATE(lv_sql) USING lv_job_id, lv_gaz_results_id, pi_net_filter_ne_id;
            --
        END IF;
    END IF;
    --
    IF pi_net_filter_ne_id IS NULL
     AND pi_net_filter_nse_id IS NOT NULL
     THEN
        IF lv_location_out_type != 'DATUM'
         THEN
            --
            lv_sql := lv_sql||',pla.pl_ne_id'
                            ||',pla.pl_start'
                            ||',pla.pl_end'
                       ||' FROM (SELECT ngqi_item_type'
                                    ||',ngqi_item_id'
                               ||' FROM nm_gaz_query_item_list'
                              ||' WHERE ngqi_job_id = :gaz_results_id'
                                ||' AND '||lv_where||') items'
                            ||',TABLE(nm3pla.get_connected_chunks(p_ne_id => ngqi_item_id,p_route_id => NULL,p_obj_type => :location_out_type).npa_placement_array) pla'
            ;
            --
            EXECUTE IMMEDIATE(lv_sql) USING lv_job_id, lv_gaz_results_id, lv_location_out_type;
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
            EXECUTE IMMEDIATE(lv_sql) USING lv_job_id, lv_gaz_results_id, pi_net_filter_ne_id;
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
  END execute_query;

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
    lv_driving_sql := 'SELECT /*+ index(aamr aamr_ind_1) index(ne ne_pk) */ iit_ne_id result_id'
                          ||',iit_inv_type asset_type'
                          ||',iit_primary_key primary_key'
                          ||',ne_unique location'
                          ||',aamr_from_offset from_offset'
                          ||',aamr_to_offset to_offset'
                          ||',iit_x_sect xsp'
                          ||get_job_attribs_sql(pi_job_id => pi_job_id)
                     ||' FROM awlrs_asset_maint_results'
                          ||',nm_inv_items'
                          ||',nm_elements'
                    ||' WHERE aamr_job_id = :job_id'
                      ||' AND aamr_iit_ne_id = iit_ne_id'
                      ||' AND aamr_ne_id = ne_id'
    ;
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
    --
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
    TYPE attr_tab IS TABLE OF get_attr%ROWTYPE;
    lt_attr  attr_tab;
    --
  BEGIN
    --
    IF --Description
        g_iit_rec_1.iit_descr != g_iit_rec_2.iit_descr
     OR (g_iit_rec_1.iit_descr IS NULL AND g_iit_rec_2.iit_descr IS NOT NULL)
     OR (g_iit_rec_1.iit_descr IS NOT NULL AND g_iit_rec_2.iit_descr IS NULL)
     --Primary Key
     OR g_iit_rec_1.iit_primary_key != g_iit_rec_2.iit_primary_key
     OR (g_iit_rec_1.iit_primary_key IS NULL AND g_iit_rec_2.iit_primary_key IS NOT NULL)
     OR (g_iit_rec_1.iit_primary_key IS NOT NULL AND g_iit_rec_2.iit_primary_key IS NULL)
     --Foreign Key
     OR g_iit_rec_1.iit_foreign_key != g_iit_rec_2.iit_foreign_key
     OR (g_iit_rec_1.iit_foreign_key IS NULL AND g_iit_rec_2.iit_foreign_key IS NOT NULL)
     OR (g_iit_rec_1.iit_foreign_key IS NOT NULL AND g_iit_rec_2.iit_foreign_key IS NULL)
     --Admin Unit
     OR g_iit_rec_1.iit_admin_unit != g_iit_rec_2.iit_admin_unit
     OR (g_iit_rec_1.iit_admin_unit IS NULL AND g_iit_rec_2.iit_admin_unit IS NOT NULL)
     OR (g_iit_rec_1.iit_admin_unit IS NOT NULL AND g_iit_rec_2.iit_admin_unit IS NULL)
     --XSP
     OR g_iit_rec_1.iit_x_sect != g_iit_rec_2.iit_x_sect
     OR (g_iit_rec_1.iit_x_sect IS NULL AND g_iit_rec_2.iit_x_sect IS NOT NULL)
     OR (g_iit_rec_1.iit_x_sect IS NOT NULL AND g_iit_rec_2.iit_x_sect IS NULL)
     --Surveyed By
     OR g_iit_rec_1.iit_peo_invent_by_id != g_iit_rec_2.iit_peo_invent_by_id
     OR (g_iit_rec_1.iit_peo_invent_by_id IS NULL AND g_iit_rec_2.iit_peo_invent_by_id IS NOT NULL)
     OR (g_iit_rec_1.iit_peo_invent_by_id IS NOT NULL AND g_iit_rec_2.iit_peo_invent_by_id IS NULL)
     --Start Date
     OR g_iit_rec_1.iit_start_date != g_iit_rec_2.iit_start_date
     OR (g_iit_rec_1.iit_start_date IS NULL AND g_iit_rec_2.iit_start_date IS NOT NULL)
     OR (g_iit_rec_1.iit_start_date IS NOT NULL AND g_iit_rec_2.iit_start_date IS NULL)
     --End Date
     OR g_iit_rec_1.iit_end_date != g_iit_rec_2.iit_end_date
     OR (g_iit_rec_1.iit_end_date IS NULL AND g_iit_rec_2.iit_end_date IS NOT NULL)
     OR (g_iit_rec_1.iit_end_date IS NOT NULL AND g_iit_rec_2.iit_end_date IS NULL)
     THEN
        --Asset Attribution Does Not Match
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 64);
    END IF;
    /*
    ||Check the flexible attributes
    */
    IF lt_attr.COUNT = 0
     THEN
        OPEN  get_attr(g_iit_rec_1.iit_inv_type);
        FETCH get_attr
         BULK COLLECT
         INTO lt_attr;
        CLOSE get_attr;
    END IF;
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      --
      lv_sql := NULL;
      --
      lv_sql := 'BEGIN'
      ||CHR(10)||'  IF awlrs_asset_api.g_iit_rec_1.'||lt_attr(i).ita_attrib_name||' != awlrs_asset_api.g_iit_rec_2.'||lt_attr(i).ita_attrib_name
      ||CHR(10)||'   OR (awlrs_asset_api.g_iit_rec_1.'||lt_attr(i).ita_attrib_name||' IS NULL AND awlrs_asset_api.g_iit_rec_2.'||lt_attr(i).ita_attrib_name||' IS NOT NULL)'
      ||CHR(10)||'   OR (awlrs_asset_api.g_iit_rec_1.'||lt_attr(i).ita_attrib_name||' IS NOT NULL AND awlrs_asset_api.g_iit_rec_2.'||lt_attr(i).ita_attrib_name||' IS NULL)'
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
  PROCEDURE contiguity_check(pi_asset_ids IN     awlrs_util.ne_id_tab
                            ,pi_ne_id     IN     nm_elements_all.ne_id%TYPE
                            ,po_placement IN OUT nm_placement)
    IS
    --
    lv_element_extent   NUMBER;
    lv_combined_extent  NUMBER;
    lv_asset_extent     NUMBER;
    lv_minus_extent     NUMBER;
    lv_remaining_count  NUMBER;
    --
    lv_start timestamp;
    lv_end   timestamp;
    --
    lt_pla  nm_placement_array;
    --
  BEGIN
    /*
    ||Build a temp extent for all the Assets.
    */
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      nm3extent.create_temp_ne(pi_source_id => 12717902
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
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 65);
    END IF;
    --
    lt_pla := nm3pla.get_connected_chunks(p_nte_job_id => lv_combined_extent
                                         ,p_route_id   => pi_ne_id
                                         ,p_obj_type   => nm3net.get_ne(pi_ne_id).ne_gty_group_type);
    --
    IF lt_pla.npa_placement_array.COUNT = 1
     THEN
        po_placement := lt_pla.npa_placement_array(1);
    ELSE
        --Asset locations are not contiguous
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 66);
    END IF;
    --
  END contiguity_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_assets_can_be_merged(pi_asset_ids    IN     awlrs_util.ne_id_tab
                                      ,pi_ne_id        IN     nm_elements_all.ne_id%TYPE
                                      ,po_new_location IN OUT nm_placement)
    IS
    --
    lt_iit  iit_tab;
    --
  BEGIN
    /*
    ||Check Assets are the same type.
    */
    FOR i IN 1..pi_asset_ids.COUNT LOOP
      --
      lt_iit(i) := nm3get.get_iit(pi_iit_ne_id => pi_asset_ids(i));
      --
      IF i > 1
       AND lt_iit(i).iit_inv_type != lt_iit(i-1).iit_inv_type
       THEN
          --All assets must be of the same type
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 67);
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
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 68);
    END IF;
    /*
    ||Check Assets have the same attribution.
    */
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
    contiguity_check(pi_asset_ids => pi_asset_ids
                    ,pi_ne_id     => pi_ne_id
                    ,po_placement => po_new_location);
    --
  END check_assets_can_be_merged;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_assets_can_be_merged(pi_asset_ids        IN  awlrs_util.ne_id_tab
                                      ,pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_new_location  nm_placement;
    --
  BEGIN
    --
    check_assets_can_be_merged(pi_asset_ids    => pi_asset_ids
                              ,pi_ne_id        => pi_ne_id
                              ,po_new_location => lv_new_location);
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
  --PROCEDURE merge_assets(pi_asset_ids        IN  awlrs_util.ne_id_tab
  --                      ,pi_ne_id            IN  nm_elements_all.ne_id%TYPE
  --                      ,po_new_asset_id     OUT nm_inv_items_all.iit_ne_id%TYPE
  --                      ,po_message_severity OUT hig_codes.hco_code%TYPE
  --                      ,po_message_cursor   OUT sys_refcursor)
  --  IS
  --  --
  --  lv_new_location      nm_placement;
  --  lv_message_severity  hig_codes.hco_code%TYPE;
  --  lv_message_cursor    sys_refcursor;
  --  lv_effective_date    DATE := TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY');
  --  --
  --BEGIN
  --  /*
  --  ||Validate the assets passed in.
  --  */
  --  check_assets_can_be_merged(pi_asset_ids    => pi_asset_ids
  --                            ,pi_ne_id        => pi_ne_id
  --                            ,po_new_location => lv_new_location);
  --  /*
  --  ||Set a save point.
  --  */
  --  SAVEPOINT merge_assets_sp;
  --  /*
  --  ||Create the new asset with the merged location.
  --  */
  --  g_iit_rec_1.iit_ne_id := NULL;
  --  nm3ins.ins_iit(g_iit_rec_1);
  --  --
  --  awlrs_asset_api.add_asset_location(pi_iit_ne_id        => g_iit_rec_1.iit_ne_id
  --                                    ,pi_nit_inv_type     => g_iit_rec_1.iit_inv_type
  --                                    ,pi_ne_id            => lv_new_location.pl_ne_id
  --                                    ,pi_begin_mp         => lv_new_location.pl_start
  --                                    ,pi_end_mp           => lv_new_location.pl_end
  --                                    ,pi_startdate        => TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
  --                                    ,pi_append_replace   => 'R'
  --                                    ,po_message_severity => lv_message_severity
  --                                    ,po_message_cursor   => lv_message_cursor);
  --  /*
  --  ||If the new asset has been successfully create and located
  --  ||end date the original assets, otherwise rollback.
  --  */
  --  IF lv_message_severity = awlrs_util.c_msg_cat_success
  --   THEN
  --      /*
  --      ||End date the original assets.
  --      */
  --      FORALL i IN 1..pi_asset_ids.COUNT
  --      UPDATE nm_inv_items_all
  --         SET iit_end_date = lv_effective_date
  --       WHERE iit_ne_id = pi_asset_ids(i)
  --           ;
  --      /*
  --      ||Set the new asset id.
  --      */
  --      po_new_asset_id := g_iit_rec_1.iit_ne_id;
  --      --
  --  ELSE
  --      --
  --      ROLLBACK TO merge_assets_sp;
  --      --
  --  END IF;
  --  /*
  --  ||Set the message parameters.
  --  */
  --  po_message_severity := lv_message_severity;
  --  po_message_cursor   := lv_message_cursor;
  --  --
  --EXCEPTION
  --  WHEN others
  --   THEN
  --      ROLLBACK TO merge_assets_sp;
  --      awlrs_util.handle_exception(po_message_severity => po_message_severity
  --                                 ,po_cursor           => po_message_cursor);
  --END merge_assets;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_assets(pi_asset_ids        IN  awlrs_util.ne_id_tab
                         ,pi_check_contiguity IN  VARCHAR2
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message_text  nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_check_contiguity = 'Y'
     THEN
        NULL; /*TODO*/
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
  PROCEDURE get_asset_criteria(pi_assc_id          IN  awlrs_saved_asset_criteria.asac_id%TYPE
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
