CREATE OR REPLACE PACKAGE BODY awlrs_search_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_search_api.pkb-arc   1.0   27 Feb 2017 11:12:18   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_search_api.pkb  $
  --       Date into PVCS   : $Date:   27 Feb 2017 11:12:18  $
  --       Date fetched Out : $Modtime:   24 Feb 2017 15:34:58  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_search_api';
  --
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
  FUNCTION gen_asset_type_attributes_sql(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN VARCHAR2 IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    lv_sql  nm3type.max_varchar2;
    --
  BEGIN
    --
    lr_nit := nm3get.get_nit(pi_inv_type);
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        lv_sql := 'SELECT CAST(column_name AS VARCHAR2(30)) column_name'
       ||CHR(10)||'      ,CAST(prompt AS VARCHAR2(30)) prompt'
       ||CHR(10)||'      ,CAST(datatype AS VARCHAR2(10)) datatype'
       ||CHR(10)||'      ,CAST(format_mask AS VARCHAR2(80)) format_mask'
       ||CHR(10)||'      ,CAST(field_length AS NUMBER(4)) field_length'
       ||CHR(10)||'      ,CAST(decimal_places AS NUMBER(1)) decimal_places'
       ||CHR(10)||'      ,CAST(min_value AS NUMBER(11,3)) min_value'
       ||CHR(10)||'      ,CAST(max_value AS NUMBER(11,3)) max_value'
       ||CHR(10)||'      ,field_case'
       ||CHR(10)||'      ,CAST(domain_id AS VARCHAR2(40)) domain_id'
       ||CHR(10)||'      ,CAST(sql_based_domain AS VARCHAR2(1)) sql_based_domain'
       ||CHR(10)||'      ,display_sequence'
       ||CHR(10)||'  FROM (WITH nit AS (SELECT nit_inv_type'
       ||CHR(10)||'                           ,nit_table_name'
       ||CHR(10)||'                           ,nit_foreign_pk_column'
       ||CHR(10)||'                       FROM nm_inv_types'
       ||CHR(10)||'                      WHERE nit_inv_type = :inv_type)'
       ||CHR(10)||'        SELECT column_name column_name'
       ||CHR(10)||'              ,''Primary Key'' prompt'
       ||CHR(10)||'              ,data_type datatype'
       ||CHR(10)||'              ,NULL format_mask'
       ||CHR(10)||'              ,NVL (data_precision, data_length) field_length'
       ||CHR(10)||'              ,data_scale decimal_places'
       ||CHR(10)||'              ,NULL min_value'
       ||CHR(10)||'              ,NULL max_value'
       ||CHR(10)||'              ,''UPPER'' field_case'
       ||CHR(10)||'              ,NULL domain_id'
       ||CHR(10)||'              ,''N''         sql_based_domain'
       ||CHR(10)||'              ,1 display_sequence'
       ||CHR(10)||'          FROM all_tab_columns, nit'
       ||CHR(10)||'         WHERE owner = SYS_CONTEXT (''NM3CORE'',''APPLICATION_OWNER'')'
       ||CHR(10)||'           AND table_name = nit.nit_table_name'
       ||CHR(10)||'           AND column_name = nit.nit_foreign_pk_column'
       ||CHR(10)||'           AND NOT EXISTS(SELECT 1'
       ||CHR(10)||'                            FROM nm_inv_type_attribs'
       ||CHR(10)||'                           WHERE ita_inv_type = nit.nit_inv_type'
       ||CHR(10)||'                             AND ita_attrib_name = nit.nit_foreign_pk_column)'
       ||CHR(10)||'        UNION ALL'
       ||CHR(10)||'        SELECT ita_attrib_name column_name'
       ||CHR(10)||'              ,DECODE(ita_scrn_text, ''Primary Key'', ''Primary Key (attribute)'', ''Network Location'', ''Network Location (attribute)'', ita_scrn_text) prompt'
       ||CHR(10)||'              ,ita_format datatype'
       ||CHR(10)||'              ,ita_format_mask format_mask'
       ||CHR(10)||'              ,DECODE(ita_format,''DATE'',LENGTH(REPLACE(ita_format_mask,''24'',''''))'
       ||CHR(10)||'                                         ,ita_fld_length) field_length'
       ||CHR(10)||'              ,ita_dec_places decimal_places'
       ||CHR(10)||'              ,ita_min min_value'
       ||CHR(10)||'              ,ita_max max_value'
       ||CHR(10)||'              ,ita_case'
       ||CHR(10)||'              ,ita_id_domain'
       ||CHR(10)||'              ,''N''         sql_based_domain'
       ||CHR(10)||'              ,ita_disp_seq_no+1 display_sequence'
       ||CHR(10)||'          FROM nm_inv_type_attribs, nit'
       ||CHR(10)||'         WHERE ita_inv_type = nit.nit_inv_type'
        ;
        --
        IF lr_nit.nit_lr_ne_column_name IS NOT NULL
         THEN
            lv_sql := lv_sql||CHR(10)||'        UNION ALL'
                            ||CHR(10)||'        SELECT ''NetworkLocation'' column_name'
                            ||CHR(10)||'              ,''Network Location'' prompt'
                            ||CHR(10)||'              ,''VARCHAR2'' datatype'
                            ||CHR(10)||'              ,NULL format_mask'
                            ||CHR(10)||'              ,240 field_length'
                            ||CHR(10)||'              ,NULL decimal_places'
                            ||CHR(10)||'              ,NULL min_value'
                            ||CHR(10)||'              ,NULL max_value'
                            ||CHR(10)||'              ,''MIXED'' field_case'
                            ||CHR(10)||'              ,NULL domain_id'
                            ||CHR(10)||'              ,''N'' sql_based_domain'
                            ||CHR(10)||'              ,10000 display_sequence'
                            ||CHR(10)||'          FROM DUAL)'
            ;
        ELSE
            lv_sql := lv_sql||')';
        END IF;
        --
    ELSE
        lv_sql := 'SELECT CAST(column_name AS VARCHAR2(30)) column_name'
       ||CHR(10)||'      ,CAST(prompt AS VARCHAR2(30)) prompt'
       ||CHR(10)||'      ,CAST(datatype AS VARCHAR2(10)) datatype'
       ||CHR(10)||'      ,CAST(format_mask AS VARCHAR2(80)) format_mask'
       ||CHR(10)||'      ,CAST(field_length AS NUMBER(4)) field_length'
       ||CHR(10)||'      ,CAST(decimal_places AS NUMBER(1)) decimal_places'
       ||CHR(10)||'      ,CAST(min_value AS NUMBER(11,3)) min_value'
       ||CHR(10)||'      ,CAST(max_value AS NUMBER(11,3)) max_value'
       ||CHR(10)||'      ,field_case'
       ||CHR(10)||'      ,CAST(domain_id AS VARCHAR2(40)) domain_id'
       ||CHR(10)||'      ,CAST(sql_based_domain AS VARCHAR2(1)) sql_based_domain'
       ||CHR(10)||'      ,display_sequence'
       ||CHR(10)||'  FROM (SELECT column_name column_name'
       ||CHR(10)||'              ,DECODE(column_name,''IIT_PRIMARY_KEY'',''Primary Key'',''IIT_DESCR'',''Description'',''IIT_ADMIN_UNIT'',''Admin Unit'') prompt'
       ||CHR(10)||'              ,DECODE(column_name,''IIT_ADMIN_UNIT'',''VARCHAR2'',data_type) datatype'
       ||CHR(10)||'              ,NULL format_mask'
       ||CHR(10)||'              ,NVL (data_precision, data_length) field_length'
       ||CHR(10)||'              ,data_scale decimal_places'
       ||CHR(10)||'              ,NULL min_value'
       ||CHR(10)||'              ,NULL max_value'
       ||CHR(10)||'              ,DECODE(data_type,''VARCHAR2'',DECODE(column_name,''IIT_PRIMARY_KEY'',''UPPER'',''MIXED''),''UPPER'') field_case'
       ||CHR(10)||'              ,DECODE(column_name,''IIT_ADMIN_UNIT'',''IIT_ADMIN_UNIT'',NULL) domain_id'
       ||CHR(10)||'              ,''N'' sql_based_domain'
       ||CHR(10)||'              ,column_id display_sequence'
       ||CHR(10)||'          FROM all_tab_columns'
       ||CHR(10)||'         WHERE owner = SYS_CONTEXT (''NM3CORE'',''APPLICATION_OWNER'')'
       ||CHR(10)||'           AND table_name = ''NM_INV_ITEMS_ALL'''
       ||CHR(10)||'           AND column_name IN (''IIT_PRIMARY_KEY'',''IIT_DESCR'',''IIT_ADMIN_UNIT'')'
       ||CHR(10)||'        UNION ALL'
       ||CHR(10)||'        SELECT ita_attrib_name column_name'
       ||CHR(10)||'              ,DECODE(ita_scrn_text, ''Primary Key'', ''Primary Key (attribute)'', ''Description'', ''Description (attribute)'', ''Network Location'', ''Network Location (attribute)'', ''Admin Unit'', ''Admin Unit (attribute)'', ita_scrn_text) prompt'
       ||CHR(10)||'              ,ita_format datatype'
       ||CHR(10)||'              ,ita_format_mask format_mask'
       ||CHR(10)||'              ,DECODE(ita_format,''DATE'',LENGTH(REPLACE(ita_format_mask,''24'',''''))'
       ||CHR(10)||'                                         ,ita_fld_length) field_length'
       ||CHR(10)||'              ,ita_dec_places decimal_places'
       ||CHR(10)||'              ,ita_min min_value'
       ||CHR(10)||'              ,ita_max max_value'
       ||CHR(10)||'              ,ita_case field_case'
       ||CHR(10)||'              ,ita_id_domain domain_id'
       ||CHR(10)||'              ,''N'' sql_based_domain'
       ||CHR(10)||'              ,ita_disp_seq_no+200 display_sequence'
       ||CHR(10)||'          FROM nm_inv_type_attribs'
       ||CHR(10)||'         WHERE ita_inv_type = :inv_type'
       ||CHR(10)||'           AND ita_queryable = ''Y'''
       ||CHR(10)||'        UNION ALL'
       ||CHR(10)||'        SELECT ''NetworkLocation'' column_name'
       ||CHR(10)||'              ,''Network Location'' prompt'
       ||CHR(10)||'              ,''VARCHAR2'' datatype'
       ||CHR(10)||'              ,NULL format_mask'
       ||CHR(10)||'              ,240 field_length'
       ||CHR(10)||'              ,NULL decimal_places'
       ||CHR(10)||'              ,NULL min_value'
       ||CHR(10)||'              ,NULL max_value'
       ||CHR(10)||'              ,''MIXED'' field_case'
       ||CHR(10)||'              ,NULL domain_id'
       ||CHR(10)||'              ,''N'' sql_based_domain'
       ||CHR(10)||'              ,10000 display_sequence'
       ||CHR(10)||'          FROM DUAL'
       ||CHR(10)||'        UNION ALL'
       ||CHR(10)||'        SELECT column_name column_name'
       ||CHR(10)||'              ,''iit_ne_id'' prompt'
       ||CHR(10)||'              ,data_type datatype'
       ||CHR(10)||'              ,NULL format_mask'
       ||CHR(10)||'              ,NVL(data_precision,data_length) field_length'
       ||CHR(10)||'              ,data_scale decimal_places'
       ||CHR(10)||'              ,NULL min_value'
       ||CHR(10)||'              ,NULL max_value'
       ||CHR(10)||'              ,''UPPER'' field_case'
       ||CHR(10)||'              ,NULL domain_id'
       ||CHR(10)||'              ,''N'' sql_based_domain'
       ||CHR(10)||'              ,10001 display_sequence'
       ||CHR(10)||'          FROM all_tab_columns'
       ||CHR(10)||'         WHERE owner = SYS_CONTEXT (''NM3CORE'',''APPLICATION_OWNER'')'
       ||CHR(10)||'           AND table_name = ''NM_INV_ITEMS_ALL'''
       ||CHR(10)||'           AND column_name = ''IIT_NE_ID'')'
        ;
    END IF;
    --
    RETURN lv_sql;
    --
  END gen_asset_type_attributes_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_type_attributes(pi_inv_type IN  nm_inv_types_all.nit_inv_type%TYPE
                                   ,po_cursor   OUT sys_refcursor)
    IS
  BEGIN
    OPEN po_cursor FOR gen_asset_type_attributes_sql(pi_inv_type => pi_inv_type)
                       ||' ORDER BY display_sequence'
      USING pi_inv_type;
  END get_asset_type_attributes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gen_network_attributes_sql
    RETURN VARCHAR2 IS
  BEGIN
    /*
    ||The ne_unique column in the query below is based upon ne_name_1
    ||because we have to work with the NGS Network Elements and the
    ||column that stores the user recognisable identifier could therefore
    ||be ne_unique, ne_number or ne_name_1, ne_name_1 being the largest column.
    */
    RETURN   'SELECT CAST(column_name AS VARCHAR2(30)) column_name'
  ||CHR(10)||'      ,CAST(prompt AS VARCHAR2(30)) prompt'
  ||CHR(10)||'      ,CAST(datatype AS VARCHAR2(10)) datatype'
  ||CHR(10)||'      ,CAST(format_mask AS VARCHAR2(80)) format_mask'
  ||CHR(10)||'      ,CAST(field_length AS NUMBER(4)) field_length'
  ||CHR(10)||'      ,CAST(decimal_places AS NUMBER(1)) decimal_places'
  ||CHR(10)||'      ,CAST(min_value AS NUMBER(11,3)) min_value'
  ||CHR(10)||'      ,CAST(max_value AS NUMBER(11,3)) max_value'
  ||CHR(10)||'      ,field_case'
  ||CHR(10)||'      ,CAST(domain_id AS VARCHAR2(40)) domain_id'
  ||CHR(10)||'      ,CAST(sql_based_domain AS VARCHAR2(1)) sql_based_domain'
  ||CHR(10)||'      ,display_sequence'
  ||CHR(10)||'  FROM (SELECT DECODE(column_name, ''NE_NAME_1'', ''NE_UNIQUE'', column_name) column_name'
  ||CHR(10)||'              ,DECODE(column_name'
  ||CHR(10)||'                     ,''NE_ID'', ''Element Id'''
  ||CHR(10)||'                     ,''NE_NAME_1'', ''Unique'''
  ||CHR(10)||'                     ,''NE_ADMIN_UNIT'', ''Admin Unit'''
  ||CHR(10)||'                     ,''NE_NT_TYPE'', ''Network Type'''
  ||CHR(10)||'                     ,''NE_DESCR'', ''Description'''
  ||CHR(10)||'                     ,''NE_GTY_GROUP_TYPE'', ''Group Type'') prompt'
  ||CHR(10)||'              ,DECODE(column_name, ''NE_ADMIN_UNIT'', ''VARCHAR2'', data_type) datatype'
  ||CHR(10)||'              ,NULL format_mask'
  ||CHR(10)||'              ,NVL(data_precision, data_length) field_length'
  ||CHR(10)||'              ,data_scale decimal_places'
  ||CHR(10)||'              ,NULL min_value'
  ||CHR(10)||'              ,NULL max_value'
  ||CHR(10)||'              ,DECODE(data_type, ''VARCHAR2'', DECODE(column_name, ''NE_NAME_1'', ''UPPER'', ''NE_NT_TYPE'', ''UPPER'', ''NE_GTY_GROUP_TYPE'', ''UPPER'', ''MIXED''), ''UPPER'') field_case'
  ||CHR(10)||'              ,DECODE(column_name, ''NE_ADMIN_UNIT'', ''NE_ADMIN_UNIT'', NULL) domain_id'
  ||CHR(10)||'              ,''N'' sql_based_domain'
  ||CHR(10)||'              ,CASE column_name'
  ||CHR(10)||'                 WHEN ''NE_NAME_1'' THEN 1'
  ||CHR(10)||'                 WHEN ''NE_DESCR'' THEN 2'
  ||CHR(10)||'                 WHEN ''NE_NT_TYPE'' THEN 3'
  ||CHR(10)||'                 WHEN ''NE_GTY_GROUP_TYPE'' THEN 4'
  ||CHR(10)||'                 WHEN ''NE_ADMIN_UNIT'' THEN 5'
  ||CHR(10)||'                 WHEN ''NE_ID'' THEN 10000'
  ||CHR(10)||'               END display_sequence'
  ||CHR(10)||'          FROM all_tab_columns'
  ||CHR(10)||'         WHERE owner = SYS_CONTEXT(''NM3CORE'',''APPLICATION_OWNER'')'
  ||CHR(10)||'           AND table_name = ''NM_ELEMENTS_ALL'''
  ||CHR(10)||'           AND column_name IN (''NE_ID'''
  ||CHR(10)||'                              ,''NE_NAME_1'''
  ||CHR(10)||'                              ,''NE_ADMIN_UNIT'''
  ||CHR(10)||'                              ,''NE_NT_TYPE'''
  ||CHR(10)||'                              ,''NE_DESCR'''
  ||CHR(10)||'                              ,''NE_GTY_GROUP_TYPE'')'
  ||CHR(10)||'        UNION ALL'
  ||CHR(10)||'        SELECT ntc_column_name    column_name'
  ||CHR(10)||'              ,ntc_prompt         prompt'
  ||CHR(10)||'              ,ntc_column_type    datatype'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN ntc_column_type = ''DATE'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     NVL(ntc_format,''DD-MON-YYYY'')'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     ntc_format'
  ||CHR(10)||'               END format_mask'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN ntc_column_type = ''DATE'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     LENGTH(REPLACE(ntc_format,''24'',''''))'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     ntc_str_length'
  ||CHR(10)||'               END field_length'
  ||CHR(10)||'              ,NULL               decimal_places'
  ||CHR(10)||'              ,NULL               min_value'
  ||CHR(10)||'              ,NULL               max_value'
  ||CHR(10)||'              ,''UPPER''            field_case'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN domain_sql IS NOT NULL'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     CASE'
  ||CHR(10)||'                       WHEN ntc_domain IS NOT NULL'
  ||CHR(10)||'                        THEN'
  ||CHR(10)||'                           ntc_domain'
  ||CHR(10)||'                       ELSE'
  ||CHR(10)||'                           awlrs_element_api.gen_domain_name(pi_nt_type     => ntc_nt_type'
  ||CHR(10)||'                                                            ,pi_column_name => ntc_column_name)'
  ||CHR(10)||'                     END'
  ||CHR(10)||'               END domain_id'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN ntc_query IS NOT NULL'
  ||CHR(10)||'                  OR (domain_sql IS NOT NULL AND ntc_domain IS NULL)'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     ''Y'''
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     ''N'''
  ||CHR(10)||'               END sql_based_domain'
  ||CHR(10)||'              ,ntc_seq_no + 100     display_sequence'
  ||CHR(10)||'          FROM (SELECT ntc.*'
  ||CHR(10)||'                      ,awlrs_element_api.get_domain_sql_with_bind(pi_nt_type     => ntc_nt_type'
  ||CHR(10)||'                                                                 ,pi_column_name => ntc_column_name) domain_sql'
  ||CHR(10)||'                  FROM nm_type_columns ntc'
  ||CHR(10)||'                 WHERE ntc_nt_type = :pi_nt_type'
  ||CHR(10)||'                   AND ntc_displayed = ''Y''))'
    ;
    --
  END gen_network_attributes_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_attributes(pi_nt_type IN  nm_types.nt_type%TYPE
                                  ,po_cursor  OUT sys_refcursor)
    IS
  BEGIN
    OPEN po_cursor FOR gen_network_attributes_sql||' ORDER BY display_sequence'
    USING pi_nt_type;
  END get_network_attributes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_search_attributes(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_network_attributes(pi_nt_type => lt_theme_types(1).network_type
                                    ,po_cursor  => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_asset_type_attributes(pi_inv_type => lt_theme_types(1).asset_type
                                       ,po_cursor   => po_cursor);
              --
          ELSE
              --
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
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
  END get_search_attributes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_admin_unit_sql
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN   'SELECT distinct nag.nag_child_admin_unit code'
  ||CHR(10)||'      ,nau.nau_name meaning'
  ||CHR(10)||'  FROM nm_admin_units nau'
  ||CHR(10)||'      ,nm_admin_groups nag'
  ||CHR(10)||'      ,nm_user_aus nua'
  ||CHR(10)||' WHERE nau.nau_admin_type = :lv_admin_type'
  ||CHR(10)||'   AND nau.nau_admin_unit = nag.Nag_Child_Admin_Unit'
  ||CHR(10)||'   AND nua.nua_admin_unit = nag.Nag_Parent_Admin_Unit'
  ||CHR(10)||'   AND nua.nua_user_id = TO_NUMBER(SYS_CONTEXT(''NM3CORE'',''USER_ID''))'
    ;
    --
  END get_admin_unit_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_units(pi_admin_type IN  nm_admin_units_all.nau_admin_type%TYPE
                           ,po_cursor     OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR get_admin_unit_sql||' ORDER BY meaning' USING pi_admin_type;
    --
  END get_admin_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_admin_units(pi_admin_type  IN  nm_admin_units_all.nau_admin_type%TYPE
                                 ,pi_filter      IN  VARCHAR2
                                 ,pi_skip_n_rows IN  PLS_INTEGER
                                 ,pi_pagesize    IN  PLS_INTEGER
                                 ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'SELECT code'
                                     ||CHR(10)||'      ,meaning'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,code'
                                     ||CHR(10)||'              ,meaning'
                                     ||CHR(10)||'              ,CASE'
                                     ||CHR(10)||'                 WHEN UPPER(meaning) = UPPER(:filter) THEN 1'
                                     ||CHR(10)||'                 WHEN UPPER(meaning) LIKE UPPER(:filter)||''%'' THEN 2'
                                     ||CHR(10)||'                 ELSE 3'
                                     ||CHR(10)||'               END match_quality'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM ('
    ;
    --
  BEGIN
    --
    IF pi_filter IS NOT NULL
     THEN
        lv_filter := ' AND UPPER(nau.nau_name) LIKE UPPER(''%''||:filter||''%'')';
    END IF;
    --
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    --
    lv_cursor_sql := lv_cursor_sql
                     ||get_admin_unit_sql
                     ||lv_filter
                     ||') ORDER BY match_quality,meaning)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_filter IS NOT NULL
     THEN
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_admin_type
                 ,pi_filter
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_admin_type
                 ,pi_filter
                 ,lv_lower_index
            ;
        END IF;
    ELSE
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_admin_type
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_admin_type
                 ,lv_lower_index
            ;
        END IF;
    END IF;
    --
  END get_paged_admin_units;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_asset_domain_sql
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN   'SELECT ial_value code'
  ||CHR(10)||'      ,ial_meaning meaning'
  ||CHR(10)||'      ,ial_seq seq'
  ||CHR(10)||'  FROM nm_inv_attri_lookup_all'
  ||CHR(10)||' WHERE ial_domain = (SELECT ita_id_domain'
  ||CHR(10)||'                       FROM nm_inv_type_attribs'
  ||CHR(10)||'                      WHERE ita_inv_type = :pi_asset_type'
  ||CHR(10)||'                        AND ita_attrib_name = :pi_column_name)'
    ;
    --
  END get_asset_domain_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domain(pi_asset_type  IN  nm_admin_units_all.nau_admin_type%TYPE
                            ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                            ,po_cursor      OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR 'SELECT code, meaning FROM ('||get_asset_domain_sql||' ORDER BY seq)'
    USING pi_asset_type
         ,pi_column_name;
    --
  END get_asset_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_domain(pi_asset_type  IN  nm_admin_units_all.nau_admin_type%TYPE
                                  ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                                  ,pi_filter      IN  VARCHAR2
                                  ,pi_skip_n_rows IN  PLS_INTEGER
                                  ,pi_pagesize    IN  PLS_INTEGER
                                  ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'SELECT code'
                                     ||CHR(10)||'      ,meaning'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,code'
                                     ||CHR(10)||'              ,meaning'
                                     ||CHR(10)||'              ,CASE'
                                     ||CHR(10)||'                 WHEN UPPER(meaning) = UPPER(:filter) THEN 1'
                                     ||CHR(10)||'                 WHEN UPPER(meaning) LIKE UPPER(:filter)||''%'' THEN 2'
                                     ||CHR(10)||'                 ELSE 3'
                                     ||CHR(10)||'               END match_quality'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM ('
    ;
    --
  BEGIN
    --
    IF pi_filter IS NOT NULL
     THEN
        lv_filter := ' AND UPPER(ial_meaning) LIKE UPPER(''%''||:filter||''%'')';
    END IF;
    --
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    --
    lv_cursor_sql := lv_cursor_sql
                     ||get_asset_domain_sql
                     ||lv_filter
                     ||') ORDER BY match_quality,seq)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_filter IS NOT NULL
     THEN
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_asset_type
                 ,pi_column_name
                 ,pi_filter
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_asset_type
                 ,pi_column_name
                 ,pi_filter
                 ,lv_lower_index
            ;
        END IF;
    ELSE
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_asset_type
                 ,pi_column_name
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_asset_type
                 ,pi_column_name
                 ,lv_lower_index
            ;
        END IF;
    END IF;
    --
  END get_paged_asset_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_domain_values(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                             ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              IF pi_column_name = 'NE_ADMIN_UNIT'
               THEN
                  --
                  get_admin_units(pi_admin_type  => lt_theme_types(1).admin_type
                                 ,po_cursor      => po_cursor);
                  --
                  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                       ,po_cursor           => po_message_cursor);
                  --
              ELSE
                  --
                  awlrs_element_api.get_nt_flex_domain(pi_nt_type          => lt_theme_types(1).network_type
                                                      ,pi_group_type       => lt_theme_types(1).network_group_type
                                                      ,pi_column_name      => pi_column_name
                                                      ,po_message_severity => lv_message_severity
                                                      ,po_message_cursor   => lv_message_cursor
                                                      ,po_cursor           => po_cursor);
                  --
              END IF;
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              IF pi_column_name = 'IIT_ADMIN_UNIT'
               THEN
                  --
                  get_admin_units(pi_admin_type  => lt_theme_types(1).admin_type
                                 ,po_cursor      => po_cursor);
              ELSE
                  --
                  get_asset_domain(pi_asset_type  => lt_theme_types(1).asset_type
                                  ,pi_column_name => pi_column_name
                                  ,po_cursor      => po_cursor);
              END IF;
              --
              awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                   ,po_cursor           => po_message_cursor);
              --
          ELSE
              --
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
    END IF;
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_domain_values;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_domain_values(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                   ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                                   ,pi_filter           IN  VARCHAR2
                                   ,pi_skip_n_rows      IN  PLS_INTEGER
                                   ,pi_pagesize         IN  PLS_INTEGER
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              IF pi_column_name = 'NE_ADMIN_UNIT'
               THEN
                  --
                  get_paged_admin_units(pi_admin_type  => lt_theme_types(1).admin_type
                                       ,pi_filter      => pi_filter
                                       ,pi_skip_n_rows => pi_skip_n_rows
                                       ,pi_pagesize    => pi_pagesize
                                       ,po_cursor      => po_cursor);
                  --
                  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                       ,po_cursor           => po_message_cursor);
                  --
              ELSE
                  --
                  awlrs_element_api.get_paged_nt_flex_domain(pi_nt_type          => lt_theme_types(1).network_type
                                                            ,pi_group_type       => lt_theme_types(1).network_group_type
                                                            ,pi_column_name      => pi_column_name
                                                            ,pi_filter           => pi_filter
                                                            ,pi_skip_n_rows      => pi_skip_n_rows
                                                            ,pi_pagesize         => pi_pagesize
                                                            ,po_message_severity => lv_message_severity
                                                            ,po_message_cursor   => lv_message_cursor
                                                            ,po_cursor           => po_cursor);
                  --
                  po_message_severity := lv_message_severity;
                  po_message_cursor := lv_message_cursor;
                  --
              END IF;
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              IF pi_column_name = 'IIT_ADMIN_UNIT'
               THEN
                  --
                  get_paged_admin_units(pi_admin_type  => lt_theme_types(1).admin_type
                                       ,pi_filter      => pi_filter
                                       ,pi_skip_n_rows => pi_skip_n_rows
                                       ,pi_pagesize    => pi_pagesize
                                       ,po_cursor      => po_cursor);
                  --
                  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                       ,po_cursor           => po_message_cursor);
                  --
              ELSE
                  --
                  get_paged_asset_domain(pi_asset_type  => lt_theme_types(1).asset_type
                                        ,pi_column_name => pi_column_name
                                        ,pi_filter      => pi_filter
                                        ,pi_skip_n_rows => pi_skip_n_rows
                                        ,pi_pagesize    => pi_pagesize
                                        ,po_cursor      => po_cursor);
                  --
                  po_message_severity := lv_message_severity;
                  po_message_cursor := lv_message_cursor;
                  --
              END IF;
              --
          ELSE
              --
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_domain_values;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_group_expressions(pi_xml  IN XMLTYPE
                                ,pi_root IN VARCHAR2)
    RETURN group_expression_tab IS
    --
    lt_retval group_expression_tab;
    --
  BEGIN
    --
    SELECT EXTRACTVALUE(VALUE(x),'GroupExpression/GroupOperation') group_operation
          ,EXTRACT(VALUE(x),'/GroupExpression/GroupExpressions')   group_expressions
          ,EXTRACT(VALUE(x),'/GroupExpression/SingleExpressions')  single_expressions
      BULK COLLECT
      INTO lt_retval
      FROM TABLE(xmlsequence(EXTRACT(pi_xml,pi_root||'GroupExpressions/GroupExpression'))) x
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
  END get_group_expressions;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_single_expressions(pi_xml IN XMLTYPE)
    RETURN single_expression_tab IS
    --
    lt_retval single_expression_tab;
    --
  BEGIN
    --
    SELECT EXTRACTVALUE(VALUE(x),'SingleExpression/FieldName') field_name
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/FilterFunction') filter_function
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/HasValue') has_value
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/IsSingleValue') is_single_value
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/IsDoubleValue') is_double_value
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/Value1') value1
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/Value2') value2
      BULK COLLECT
      INTO lt_retval
      FROM TABLE(xmlsequence(EXTRACT(pi_xml,'SingleExpressions/SingleExpression'))) x
         ;
    --
    FOR i IN 1..lt_retval.COUNT LOOP
      --
      lt_retval(i).value1 := awlrs_util.escape_single_quotes(pi_string => lt_retval(i).value1);
      lt_retval(i).value2 := awlrs_util.escape_single_quotes(pi_string => lt_retval(i).value2);
      --
    END LOOP;
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
  END get_single_expressions;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION has_child_single_expression(pi_expression IN group_expression_rec)
    RETURN BOOLEAN IS
    --
    lt_single_expression  single_expression_tab;
    lt_group_expression   group_expression_tab;
    --
  BEGIN
    --
    lt_single_expression := get_single_expressions(pi_xml => pi_expression.single_expressions_xml);
    IF lt_single_expression.COUNT > 0
     THEN
        RETURN TRUE;
    END IF;
    --
    lt_group_expression := get_group_expressions(pi_xml  => pi_expression.group_expressions_xml
                                                ,pi_root => NULL);
    FOR i IN 1..lt_group_expression.COUNT LOOP
      --
      IF has_child_single_expression(pi_expression => lt_group_expression(i))
       THEN
          RETURN TRUE;
      END IF;
      --
    END LOOP;
    --
    RETURN FALSE;
    --
  END has_child_single_expression;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION execute_gaz_query(pi_ne_id   IN nm_elements_all.ne_id%TYPE
                            ,pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN NUMBER IS
    --
    lv_job_id    NUMBER := nm3ddl.sequence_nextval('RTG_JOB_ID_SEQ');
    lv_query_id  NUMBER;
    --
  BEGIN
    --
    INSERT
      INTO nm_gaz_query
          (ngq_id
          ,ngq_source_id
          ,ngq_source
          ,ngq_open_or_closed
          ,ngq_items_or_area
          ,ngq_query_all_items)
    VALUES(lv_job_id
          ,pi_ne_id
          ,'ROUTE'
          ,'C'
          ,'I'
          ,'N')
         ;
    --
    INSERT
      INTO nm_gaz_query_types
          (ngqt_ngq_id
          ,ngqt_seq_no
          ,ngqt_item_type_type
          ,ngqt_item_type)
    VALUES(lv_job_id
          ,1
          ,'I'
          ,pi_inv_type);
    --
    lv_query_id := nm3gaz_qry.perform_query (lv_job_id);
    --
    RETURN lv_query_id;
    --
  END execute_gaz_query;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_assignment(pi_value       IN VARCHAR2
                         ,pi_datatype    IN VARCHAR2
                         ,pi_format_mask IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_retval  nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_datatype = 'DATE'
     THEN
        lv_retval := ' TRUNC('||awlrs_util.get_assignment(pi_value       => UPPER(pi_value)
                                                         ,pi_datatype    => pi_datatype
                                                         ,pi_format_mask => pi_format_mask)||')';
    ELSE
        lv_retval := awlrs_util.get_assignment(pi_value       => UPPER(pi_value)
                                              ,pi_datatype    => pi_datatype
                                              ,pi_format_mask => pi_format_mask);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_assignment;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_clause(pi_datatype        IN     VARCHAR2
                      ,pi_format_mask     IN     VARCHAR2
                      ,pi_group_operation IN     VARCHAR2
                      ,pi_expression      IN     single_expression_rec
                      ,po_sql             IN OUT nm3type.max_varchar2)
    IS
    --
    lv_expression  single_expression_rec;
    --
  BEGIN
    --
    lv_expression := pi_expression;
    --
    CASE
      WHEN lv_expression.filter_function = 'Contains'
       THEN
          --
          IF pi_datatype != 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
          END IF;
          --
          po_sql := po_sql||' '||pi_group_operation||' UPPER('||lv_expression.field_name||') LIKE ''%'||UPPER(lv_expression.value1)||'%''';
          --
      WHEN lv_expression.filter_function = 'DoesNotContain'
       THEN
          --
          IF pi_datatype != 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
          END IF;
          --
          po_sql := po_sql||' '||pi_group_operation||' UPPER('||lv_expression.field_name||') NOT LIKE ''%'||UPPER(lv_expression.value1)||'%''';
          --
      WHEN lv_expression.filter_function = 'StartsWith'
       THEN
          --
          IF pi_datatype != 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
          END IF;
          --
          po_sql := po_sql||' '||pi_group_operation||' UPPER('||lv_expression.field_name||') LIKE '''||UPPER(lv_expression.value1)||'%''';
          --
      WHEN lv_expression.filter_function = 'EndsWith'
       THEN
          IF pi_datatype != 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
          END IF;
          --
          po_sql := po_sql||' '||pi_group_operation||' UPPER('||lv_expression.field_name||') LIKE ''%'||UPPER(lv_expression.value1)||'''';
          --
      WHEN lv_expression.filter_function = 'EqualTo'
       THEN
          IF pi_datatype = 'VARCHAR2'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' UPPER('||lv_expression.field_name||')';
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' = '||get_assignment(pi_value       => lv_expression.value1
                                                 ,pi_datatype    => pi_datatype
                                                 ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'NotEqualTo'
       THEN
          IF pi_datatype = 'VARCHAR2'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' UPPER('||lv_expression.field_name||')';
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' != '||get_assignment(pi_value       => lv_expression.value1
                                                  ,pi_datatype    => pi_datatype
                                                  ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'GreaterThan'
       THEN
          --
          IF pi_datatype = 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' > '||get_assignment(pi_value       => lv_expression.value1
                                                 ,pi_datatype    => pi_datatype
                                                 ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'LessThan'
       THEN
          --
          IF pi_datatype = 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' < '||get_assignment(pi_value       => lv_expression.value1
                                                 ,pi_datatype    => pi_datatype
                                                 ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'GreaterThanOrEqualTo'
       THEN
          --
          IF pi_datatype = 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' >= '||get_assignment(pi_value       => lv_expression.value1
                                                  ,pi_datatype    => pi_datatype
                                                  ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'LessThanOrEqualTo'
       THEN
          --
          IF pi_datatype = 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' <= '||get_assignment(pi_value       => lv_expression.value1
                                                  ,pi_datatype    => pi_datatype
                                                  ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'Between'
       THEN
          --
          IF (lv_expression.value1 IS NULL OR lv_expression.value2 IS NULL)
           THEN
              --Two values must be supplied for filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 45
                           ,pi_supplementary_info => lv_expression.filter_function);
          END IF;
          --
          IF pi_datatype = 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' BETWEEN '||get_assignment(pi_value       => lv_expression.value1
                                                       ,pi_datatype    => pi_datatype
                                                       ,pi_format_mask => pi_format_mask)
                          ||' AND '||get_assignment(pi_value       => lv_expression.value2
                                                   ,pi_datatype    => pi_datatype
                                                   ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'NotBetween'
       THEN
          --
          IF (lv_expression.value1 IS NULL OR lv_expression.value2 IS NULL)
           THEN
              --Two values must be supplied for filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 45
                           ,pi_supplementary_info => lv_expression.filter_function);
          END IF;
          --
          IF pi_datatype = 'VARCHAR2'
           THEN
              --Invalid filter function
              hig.raise_ner(pi_appl               => 'AWLRS'
                           ,pi_id                 => 43
                           ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
              --
          ELSIF pi_datatype = 'DATE'
           THEN
              --
              po_sql := po_sql||' '||pi_group_operation||' TRUNC('||lv_expression.field_name||')';
              --
          ELSE
              --
              po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name;
              --
          END IF;
          --
          po_sql := po_sql||' NOT BETWEEN '||get_assignment(pi_value       => lv_expression.value1
                                                           ,pi_datatype    => pi_datatype
                                                           ,pi_format_mask => pi_format_mask)
                          ||' AND '||get_assignment(pi_value       => lv_expression.value2
                                                   ,pi_datatype    => pi_datatype
                                                   ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'IsEmpty'
       OR lv_expression.filter_function = 'IsNull'
       THEN
          --
          po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name||' IS NULL';
          --
      WHEN lv_expression.filter_function = 'NotIsEmpty'
       OR lv_expression.filter_function = 'NotIsNull'
       THEN
          --
          po_sql := po_sql||' '||pi_group_operation||' '||lv_expression.field_name||' IS NOT NULL';
          --
      ELSE
          --Invalid filter function
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 43);
    END CASE;
    --
  END get_clause;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE process_single_expression(pi_theme_types     IN     awlrs_map_api.theme_types_rec
                                     ,pi_group_operation IN     VARCHAR2
                                     ,pi_expression      IN     single_expression_rec
                                     ,po_sql             IN OUT nm3type.max_varchar2)
    IS
    --
    lv_datatype     VARCHAR2(106);
    lv_format_mask  VARCHAR2(80);
    lv_expression   single_expression_rec;
    lv_subquery     nm3type.max_varchar2;
    --
    PROCEDURE get_format(pi_theme_types IN  awlrs_map_api.theme_types_rec
                        ,pi_attrib_name IN  nm_inv_type_attribs_all.ita_attrib_name%TYPE
                        ,po_format      OUT nm_inv_type_attribs_all.ita_format%TYPE
                        ,po_format_mask OUT nm_inv_type_attribs_all.ita_format_mask%TYPE)
      IS
      --
      lv_sql       nm3type.max_varchar2;
      --
    BEGIN
      --
      IF pi_theme_types.asset_type IS NOT NULL
       THEN
          --
          lv_sql := gen_asset_type_attributes_sql(pi_inv_type => pi_theme_types.asset_type);
          --
      ELSE
          --
          lv_sql := gen_network_attributes_sql;
          --
      END IF;
      /*
      ||Some FT Asset Types include the identified PK column as
      ||an attribute which leads to two rows in the select below
      ||hence the rownum = 1.
      */
      lv_sql := 'SELECT datatype'
                    ||',format_mask'
               ||' FROM ('||lv_sql||') ita'
              ||' WHERE column_name = :attrib_name'
              ||'   AND rownum = 1'
      ;
      --
      IF pi_theme_types.asset_type IS NOT NULL
       THEN
          --
          EXECUTE IMMEDIATE lv_sql INTO po_format, po_format_mask USING pi_theme_types.asset_type, pi_attrib_name;
          --
      ELSE
          --
          EXECUTE IMMEDIATE lv_sql INTO po_format, po_format_mask USING pi_theme_types.network_type,pi_attrib_name;
          --
      END IF;
      --
    EXCEPTION
      WHEN no_data_found
       THEN
          --Invalid Attribute Supplied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 3
                       ,pi_supplementary_info => pi_attrib_name);
      WHEN others
       THEN
          RAISE;
    END get_format;
    --
  BEGIN
    --
    get_format(pi_theme_types => pi_theme_types
              ,pi_attrib_name => pi_expression.field_name
              ,po_format      => lv_datatype
              ,po_format_mask => lv_format_mask);
    --
    IF pi_theme_types.asset_type IS NOT NULL
     AND pi_expression.field_name = 'NetworkLocation'
     THEN
        --
        BEGIN
          po_sql := po_sql||' '||pi_group_operation||' iit_ne_id IN(SELECT ngqi_item_id FROM nm_gaz_query_item_list WHERE ngqi_job_id = '
                    ||execute_gaz_query(pi_ne_id    => awlrs_element_api.get_ne_id(pi_element_name => pi_expression.value1)
                                       ,pi_inv_type => pi_theme_types.asset_type)
                    ||')';
        END;
        --
    ELSE
        --
        get_clause(pi_datatype        => lv_datatype
                  ,pi_format_mask     => lv_format_mask
                  ,pi_group_operation => pi_group_operation
                  ,pi_expression      => pi_expression
                  ,po_sql             => po_sql);
        --
    END IF;
    --
  END process_single_expression;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE process_group_expression(pi_theme_types IN     awlrs_map_api.theme_types_rec
                                    ,pi_expression  IN     group_expression_rec
                                    ,po_sql         IN OUT nm3type.max_varchar2)
    IS
    --
    lv_open_bracket      VARCHAR2(1);
    lv_close_bracket     VARCHAR2(1);
    lv_group_expression  VARCHAR2(100);
    --
    lt_single_expression        single_expression_tab;
    lt_child_single_expression  single_expression_tab;
    lt_group_expression         group_expression_tab;
    --
  BEGIN
    --
    IF pi_expression.single_expressions_xml IS NOT NULL
     THEN
        --
        lt_single_expression := get_single_expressions(pi_xml => pi_expression.single_expressions_xml);
        --
        FOR j IN 1..lt_single_expression.COUNT LOOP
          --
          IF j > 1
           THEN
              lv_group_expression := UPPER(pi_expression.group_operation);
          ELSE
              lv_group_expression := NULL;
          END IF;
          --
          process_single_expression(pi_theme_types     => pi_theme_types
                                   ,pi_group_operation => lv_group_expression
                                   ,pi_expression      => lt_single_expression(j)
                                   ,po_sql             => po_sql);
          --
        END LOOP;
    END IF;
    --
    IF pi_expression.group_expressions_xml IS NOT NULL
     THEN
        --
        lt_group_expression := get_group_expressions(pi_xml  => pi_expression.group_expressions_xml
                                                    ,pi_root => NULL);
        --
        FOR i IN 1..lt_group_expression.COUNT LOOP
          --
          IF has_child_single_expression(pi_expression => lt_group_expression(i))
           THEN
              --
              lt_child_single_expression := get_single_expressions(pi_xml => lt_group_expression(i).single_expressions_xml);
              --
              IF (lt_child_single_expression.COUNT > 0
                  OR lt_single_expression.COUNT > 0)
               AND po_sql IS NOT NULL
               AND po_sql NOT LIKE '%AND ('
               AND po_sql NOT LIKE '%OR ('
               THEN
                  --
                  po_sql := po_sql||' '||UPPER(pi_expression.group_operation)||' ';
                  lv_open_bracket := '(';
                  lv_close_bracket := ')';
                  --
              ELSE
                  lv_open_bracket := NULL;
                  lv_close_bracket := NULL;
              END IF;
              --
              po_sql := po_sql||lv_open_bracket;
              process_group_expression(pi_theme_types => pi_theme_types
                                      ,pi_expression  => lt_group_expression(i)
                                      ,po_sql         => po_sql);
              po_sql := po_sql||lv_close_bracket;
              --
          END IF;
          --
        END LOOP;
        --
    END IF;
    --
  END process_group_expression;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_where_clause(pi_theme_types IN awlrs_map_api.theme_types_rec
                                ,pi_criteria    IN XMLTYPE)
    RETURN VARCHAR2 IS
    --
    lv_sql nm3type.max_varchar2;
    --
    lt_expressions group_expression_tab;
    --
  BEGIN
    --
    lt_expressions := get_group_expressions(pi_xml  => pi_criteria
                                           ,pi_root => 'SearchCriteria/');
    --
    FOR i IN 1..lt_expressions.COUNT LOOP
      process_group_expression(pi_theme_types => pi_theme_types
                              ,pi_expression  => lt_expressions(i)
                              ,po_sql         => lv_sql);
    END LOOP;
    --
    RETURN LTRIM(lv_sql);
    --
  END generate_where_clause;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_attributes_lists(pi_inv_type    IN     nm_inv_types_all.nit_inv_type%TYPE
                                      ,po_alias_list  IN OUT VARCHAR2
                                      ,po_select_list IN OUT VARCHAR2)
    IS
    --
    lv_scrn_text  nm_inv_type_attribs_all.ita_scrn_text%TYPE;
    --
    TYPE ita_tab IS TABLE OF nm_inv_type_attribs_all%ROWTYPE;
    lt_ita  ita_tab;
    --
  BEGIN
    /*
    ||Add any attributes.
    */
    SELECT *
      BULK COLLECT
      INTO lt_ita
      FROM nm_inv_type_attribs
     WHERE ita_inv_type = pi_inv_type
       AND ita_displayed = 'Y'
     ORDER
        BY ita_disp_seq_no
         ;
    --
    FOR i IN 1..lt_ita.COUNT LOOP
      --
      IF lt_ita(i).ita_displayed = 'Y'
       THEN
          lv_scrn_text := LOWER(REPLACE(REPLACE(REPLACE(lt_ita(i).ita_scrn_text,'.',''),'"',''),' ','_'));
          --
          IF lt_ita(i).ita_id_domain IS NOT NULL
           THEN
              --
              po_select_list := po_select_list
                ||CHR(10)||'                     ,(SELECT ial_meaning'
                ||CHR(10)||'                         FROM nm_inv_attri_lookup'
                ||CHR(10)||'                        WHERE ial_domain = '||nm3flx.string(lt_ita(i).ita_id_domain)
                ||CHR(10)||'                          AND ial_value = iit.'||LOWER(lt_ita(i).ita_attrib_name)||') '||lv_scrn_text
              ;
              --
          ELSE
              po_select_list := po_select_list||CHR(10)||'                     ,iit.'||LOWER(lt_ita(i).ita_attrib_name)||' '||lv_scrn_text;
          END IF;
          --
          po_alias_list := po_alias_list||CHR(10)||'      ,'||lv_scrn_text;
          --
      END IF;
      --
    END LOOP;
    --
  END get_asset_attributes_lists;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_attributes_lists(pi_nt_type     IN     nm_types.nt_type%TYPE
                                        ,po_alias_list  IN OUT VARCHAR2
                                        ,po_select_list IN OUT VARCHAR2)
    IS
    --
    lv_prompt  nm_type_columns.ntc_prompt%TYPE;
    lv_sql     nm3type.max_varchar2;
    --
    TYPE ntc_rec IS RECORD(ntc_column_name  nm_type_columns.ntc_column_name%TYPE
                          ,ntc_prompt       nm_type_columns.ntc_prompt%TYPE);
    TYPE ntc_tab IS TABLE OF ntc_rec;
    lt_ntc  ntc_tab;
    --
  BEGIN
    /*
    ||Add any attributes.
    */
    SELECT ntc_column_name
          ,ntc_prompt
      BULK COLLECT
      INTO lt_ntc
      FROM nm_type_columns ntc
     WHERE ntc_nt_type = pi_nt_type
       AND ntc_displayed = 'Y'
     ORDER
        BY ntc_seq_no
         ;
    --
    FOR i IN 1..lt_ntc.COUNT LOOP
      --
      lv_prompt := LOWER(REPLACE(REPLACE(REPLACE(lt_ntc(i).ntc_prompt,'.',''),'"',''),' ','_'));
      --
      IF awlrs_element_api.get_domain_sql_with_bind(pi_nt_type     => pi_nt_type
                                                   ,pi_column_name => lt_ntc(i).ntc_column_name) IS NOT NULL
       THEN
          --
          awlrs_element_api.gen_domain_sql(pi_nt_type     => pi_nt_type
                                          ,pi_column_name => lt_ntc(i).ntc_column_name
                                          ,pi_bind_value  => NULL
                                          ,po_sql         => lv_sql);
          lv_sql := '(SELECT meaning FROM ('||lv_sql||') WHERE code = '||lt_ntc(i).ntc_column_name||')';
          --
          po_select_list := po_select_list||CHR(10)||'                       ,'||lv_sql||' '||lv_prompt;
          --
      ELSE
          --
          po_select_list := po_select_list||CHR(10)||'                       ,'||LOWER(lt_ntc(i).ntc_column_name)||' '||lv_prompt;
          --
      END IF;
      --
      po_alias_list := po_alias_list||CHR(10)||'      ,'||lv_prompt;
      --
    END LOOP;
    --
  END get_network_attributes_lists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_network_quick_search_sql(pi_alias_list       IN VARCHAR2
                                       ,pi_select_list      IN VARCHAR2
                                       ,pi_like_cols        IN VARCHAR2
                                       ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                       ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                       ,pi_order_asc_desc   IN VARCHAR2 DEFAULT NULL
                                       ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_pagecols  VARCHAR2(200);
    lv_retval    nm3type.max_varchar2;
    lv_order_by  VARCHAR2(200);
    --
  BEGIN
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum ind'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
            ||CHR(10)||'      ,';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        lv_order_by := pi_order_column||' '||NVL(LOWER(pi_order_asc_desc),'asc');
    ELSE
        lv_order_by := 'match_quality ,unique_';
    END IF;
    --
    lv_retval := 'WITH elements AS(SELECT ne_id result_id'
      ||CHR(10)||'                       ,ne_nt_type network_type'
      ||CHR(10)||'                       ,ne_gty_group_type group_type'
      ||CHR(10)||'                       ,CASE ne_nt_type'
      ||CHR(10)||'                          WHEN ''ESU'' THEN ne_name_1'
      ||CHR(10)||'                          WHEN ''NSGN'' THEN ne_number'
      ||CHR(10)||'                          ELSE ne_unique'
      ||CHR(10)||'                        END unique_'
      ||CHR(10)||'                       ,ne_descr description'
      ||CHR(10)||'                       ,ne_start_date start_date'
      ||CHR(10)||'                       ,ne_end_date end_date'
      ||CHR(10)||'                       ,nm3net.get_ne_length(ne_id) length'
      ||CHR(10)||'                       ,nau_name admin_unit'
               ||pi_select_list
      ||CHR(10)||'                       ,CASE'
      ||CHR(10)||'                          WHEN UPPER(ne_unique) = UPPER(:search_string) THEN 1'
      ||CHR(10)||'                          WHEN UPPER(ne_descr) = UPPER(:search_string) THEN 2'
      ||CHR(10)||'                          WHEN UPPER(ne_unique) LIKE UPPER(:search_string||''%'') THEN 3'
      ||CHR(10)||'                          WHEN UPPER(ne_descr) LIKE UPPER(:search_string||''%'') THEN 4'
      ||CHR(10)||'                          ELSE 5'
      ||CHR(10)||'                        END match_quality'
      ||CHR(10)||'                   FROM nm_admin_units_all'
      ||CHR(10)||'                       ,nm_elements_all'
      ||CHR(10)||'                  WHERE ne_nt_type = :nt_type'
      ||CHR(10)||'                    AND NVL(ne_gty_group_type,:nvl) = NVL(:group_type,:nvl)'
      ||CASE
          WHEN pi_include_enddated = 'N'
           THEN CHR(10)||'                    AND ne_end_date IS NULL'
        END
      ||CHR(10)||'                    AND UPPER('||pi_like_cols||') LIKE :like_string'
      ||CHR(10)||'                    AND ne_admin_unit = nau_admin_unit'
      ||CHR(10)||'                  ORDER BY '||lv_order_by||')'
      ||CHR(10)||'SELECT '||lv_pagecols
                      ||'result_id'
      ||CHR(10)||'      ,network_type'
      ||CHR(10)||'      ,group_type'
      ||CHR(10)||'      ,unique_'
      ||CHR(10)||'      ,description'
      ||CHR(10)||'      ,start_date'
      ||CHR(10)||'      ,end_date'
      ||CHR(10)||'      ,length'
      ||CHR(10)||'      ,admin_unit'
               ||pi_alias_list
      ||CHR(10)||'  FROM elements'
    ;
    --
    RETURN lv_retval;
    --
  END get_network_quick_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_quick_search(pi_search_string    IN  VARCHAR2
                                    ,pi_nt_type          IN  nm_elements_all.ne_nt_type%TYPE
                                    ,pi_group_type       IN  nm_elements_all.ne_gty_group_type%TYPE
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                    ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                    ,pi_max_rows         IN  NUMBER DEFAULT NULL
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_like_cols         nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    lv_like_cols := 'ne_unique||'' ''||ne_descr';
    --
--    FOR i IN 1..pi_columns.COUNT LOOP
--      --
--      lv_like_cols := lv_like_cols||'||'' ''||'||pi_columns(i).nqsc_column;
--      --
--    END LOOP;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    get_network_attributes_lists(pi_nt_type     => pi_nt_type
                                ,po_alias_list  => lv_alias_list
                                ,po_select_list => lv_select_list);
    --
    lv_sql := get_network_quick_search_sql(pi_alias_list       => lv_alias_list
                                          ,pi_select_list      => lv_select_list
                                          ,pi_like_cols        => lv_like_cols
                                          ,pi_include_enddated => pi_include_enddated
                                          ,pi_order_column     => pi_order_column
                                          ,pi_order_asc_desc   => pi_order_asc_desc)
              ||lv_additional_where
    ;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,pi_nt_type
             ,lv_nvl
             ,pi_group_type
             ,lv_nvl
             ,lv_like_string
             ,pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,pi_nt_type
             ,lv_nvl
             ,pi_group_type
             ,lv_nvl
             ,lv_like_string
        ;
    END IF;
    --
  END get_network_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_quick_search(pi_search_string    IN  VARCHAR2
                                          ,pi_nt_type          IN  nm_elements_all.ne_nt_type%TYPE
                                          ,pi_group_type       IN  nm_elements_all.ne_gty_group_type%TYPE
                                          ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                          ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                          ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                          ,pi_skip_n_rows      IN  PLS_INTEGER
                                          ,pi_pagesize         IN  PLS_INTEGER
                                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_additional_where  nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_like_cols         nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    lv_like_cols := 'ne_unique||'' ''||ne_descr';
    --
--    FOR i IN 1..pi_columns.COUNT LOOP
--      --
--      lv_like_cols := lv_like_cols||'||'' ''||'||pi_columns(i).nqsc_column;
--      --
--    END LOOP;
    --
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    get_network_attributes_lists(pi_nt_type     => pi_nt_type
                                ,po_alias_list  => lv_alias_list
                                ,po_select_list => lv_select_list);
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_network_quick_search_sql(pi_alias_list       => lv_alias_list
                                                      ,pi_select_list      => lv_select_list
                                                      ,pi_like_cols        => lv_like_cols
                                                      ,pi_include_enddated => pi_include_enddated
                                                      ,pi_order_column     => pi_order_column
                                                      ,pi_order_asc_desc   => pi_order_asc_desc
                                                      ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,pi_nt_type
             ,lv_nvl
             ,pi_group_type
             ,lv_nvl
             ,lv_like_string
             ,lv_lower_index
             ,lv_upper_index
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,lv_search_string
             ,pi_nt_type
             ,lv_nvl
             ,pi_group_type
             ,lv_nvl
             ,lv_like_string
             ,lv_lower_index
        ;
    END IF;
    --
  END get_paged_network_quick_search;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_asset_quick_search_sql(pi_nit_rec          IN nm_inv_types_all%ROWTYPE
                                     ,pi_alias_list       IN VARCHAR2
                                     ,pi_select_list      IN VARCHAR2
                                     ,pi_like_cols        IN VARCHAR2
                                     ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                     ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                     ,pi_order_asc_desc   IN VARCHAR2 DEFAULT NULL
                                     ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_pagecols  VARCHAR2(200);
    lv_retval    nm3type.max_varchar2;
    lv_order_by  VARCHAR2(200);
    --
  BEGIN
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum ind'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
            ||CHR(10)||'      ,';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        lv_order_by := pi_order_column||' '||NVL(LOWER(pi_order_asc_desc),'asc');
    ELSE
        lv_order_by := 'match_quality, primary_key'||CASE
                                                       WHEN pi_nit_rec.nit_table_name IS NULL
                                                        THEN
                                                           ', description'
                                                     END;
    END IF;
    --
    IF pi_nit_rec.nit_table_name IS NOT NULL
     THEN
        --
        lv_retval :=  'WITH assets AS(SELECT '||pi_nit_rec.nit_foreign_pk_column||' result_id'
           ||CHR(10)||'                     ,'||pi_nit_rec.nit_foreign_pk_column||' primary_key'
                                              ||pi_select_list
           ||CHR(10)||'                     ,CASE'
           ||CHR(10)||'                        WHEN UPPER('||pi_nit_rec.nit_foreign_pk_column||') = UPPER(:search_string) THEN 1'
           ||CHR(10)||'                        WHEN UPPER('||pi_nit_rec.nit_foreign_pk_column||') LIKE UPPER(:search_string||''%'') THEN 3'
           ||CHR(10)||'                        ELSE 5'
           ||CHR(10)||'                      END match_quality'
           ||CHR(10)||'                 FROM '||pi_nit_rec.nit_table_name||' iit'
           ||CHR(10)||'                WHERE UPPER('||NVL(pi_like_cols,pi_nit_rec.nit_foreign_pk_column)||') LIKE :like_string'
           ||CHR(10)||'                ORDER BY '||lv_order_by||')'
           ||CHR(10)||'SELECT '||lv_pagecols
                           ||'result_id'
           ||CHR(10)||'      ,primary_key'
                            ||pi_alias_list
           ||CHR(10)||'  FROM assets'
        ;
        --
    ELSE
        lv_retval :=  'WITH assets AS(SELECT iit_ne_id result_id'
           ||CHR(10)||'                     ,iit_primary_key primary_key'
           ||CHR(10)||'                     ,iit_descr description'
           ||CHR(10)||'                     ,nau_name admin_unit'
                    ||pi_select_list
           ||CHR(10)||'                     ,CASE'
           ||CHR(10)||'                        WHEN UPPER(iit_primary_key) = UPPER(:search_string) THEN 1'
           ||CHR(10)||'                        WHEN UPPER(iit_descr) = UPPER(:search_string) THEN 2'
           ||CHR(10)||'                        WHEN UPPER(iit_primary_key) LIKE UPPER(:search_string||''%'') THEN 3'
           ||CHR(10)||'                        WHEN UPPER(iit_descr) LIKE UPPER(:search_string||''%'') THEN 4'
           ||CHR(10)||'                        ELSE 5'
           ||CHR(10)||'                      END match_quality'
           ||CHR(10)||'                 FROM nm_inv_items_all iit'
           ||CHR(10)||'                     ,nm_admin_units_all nau'
           ||CHR(10)||'                WHERE iit.iit_inv_type = :inv_type'
           ||CASE
               WHEN pi_include_enddated = 'N'
                THEN CHR(10)||'                  AND iit.iit_end_date IS NULL'
             END
           ||CHR(10)||'                  AND UPPER('||NVL(pi_like_cols,'iit.iit_primary_key||'' ''||iit.iit_descr')||') LIKE :like_string'
           ||CHR(10)||'                  AND iit.iit_admin_unit = nau.nau_admin_unit'
           ||CHR(10)||'                ORDER BY match_quality,iit_primary_key,iit_descr)'
           ||CHR(10)||'SELECT '||lv_pagecols
                           ||'result_id'
           ||CHR(10)||'      ,primary_key'
           ||CHR(10)||'      ,description'
           ||CHR(10)||'      ,admin_unit'
                            ||pi_alias_list
           ||CHR(10)||'  FROM assets'
        ;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END get_asset_quick_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_assets_quick_search(pi_search_string    IN  VARCHAR2
                                   ,pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                   ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                   ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                   ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                   ,pi_max_rows         IN  NUMBER DEFAULT NULL
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_like_cols         nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_inv_type);
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
--    FOR i IN 1..pi_columns.COUNT LOOP
--      --
--      lv_like_cols := lv_like_cols||'||'' ''||'||pi_columns(i).nqsc_column;
--      --
--    END LOOP;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    get_asset_attributes_lists(pi_inv_type    => pi_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    lv_sql := get_asset_quick_search_sql(pi_nit_rec          => lr_nit
                                        ,pi_alias_list       => lv_alias_list
                                        ,pi_select_list      => lv_select_list
                                        ,pi_like_cols        => lv_like_cols
                                        ,pi_include_enddated => pi_include_enddated
                                        ,pi_order_column     => pi_order_column
                                        ,pi_order_asc_desc   => pi_order_asc_desc)
              ||lv_additional_where
    ;
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_max_rows IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_like_string
                 ,pi_max_rows
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_like_string
            ;
        END IF;
        --
    ELSE
        --
        IF pi_max_rows IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,pi_inv_type
                 ,lv_like_string
                 ,pi_max_rows
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,pi_inv_type
                 ,lv_like_string
            ;
        END IF;
        --
    END IF;
    --
  END get_assets_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_assets_quick_search(pi_search_string    IN  VARCHAR2
                                         ,pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                         ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                         ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                         ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                         ,pi_skip_n_rows      IN  PLS_INTEGER
                                         ,pi_pagesize         IN  PLS_INTEGER
                                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_like_cols         nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_inv_type);
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
--    FOR i IN 1..pi_columns.COUNT LOOP
--      --
--      lv_like_cols := lv_like_cols||'||'' ''||'||pi_columns(i).nqsc_column;
--      --
--    END LOOP;
    --
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    get_asset_attributes_lists(pi_inv_type    => pi_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    lv_sql := get_asset_quick_search_sql(pi_nit_rec          => lr_nit
                                        ,pi_alias_list       => lv_alias_list
                                        ,pi_select_list      => lv_select_list
                                        ,pi_like_cols        => lv_like_cols
                                        ,pi_include_enddated => pi_include_enddated
                                        ,pi_order_column     => pi_order_column
                                        ,pi_order_asc_desc   => pi_order_asc_desc
                                        ,pi_paged            => TRUE);
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||lv_sql||')'
            ||lv_additional_where
    ;
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_like_string
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_like_string
                 ,lv_lower_index
            ;
        END IF;
        --
    ELSE
       --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,pi_inv_type
                 ,lv_like_string
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,lv_search_string
                 ,pi_inv_type
                 ,lv_like_string
                 ,lv_lower_index
            ;
        END IF;
        --
    END IF;
    --
  END get_paged_assets_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_quick_search_results(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                    ,pi_search_string    IN  VARCHAR2
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                    ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                    ,pi_max_rows         IN  NUMBER DEFAULT NULL
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lv_include_enddated  VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    IF pi_search_string IS NULL
     THEN
        --Please specify a search string
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 44);
    END IF;
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_network_quick_search(pi_search_string    => pi_search_string
                                      ,pi_nt_type          => lt_theme_types(1).network_type
                                      ,pi_group_type       => lt_theme_types(1).network_group_type
                                      ,pi_include_enddated => pi_include_enddated
                                      ,pi_order_column     => pi_order_column
                                      ,pi_order_asc_desc   => pi_order_asc_desc
                                      ,pi_max_rows         => pi_max_rows
                                      ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_assets_quick_search(pi_search_string    => pi_search_string
                                     ,pi_inv_type         => lt_theme_types(1).asset_type
                                     ,pi_include_enddated => pi_include_enddated
                                     ,pi_order_column     => pi_order_column
                                     ,pi_order_asc_desc   => pi_order_asc_desc
                                     ,pi_max_rows         => pi_max_rows
                                     ,po_cursor           => po_cursor);
              --
          ELSE
              --Layer does not represent an Asset Type or a Network Type
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --Layer does not represent an Asset Type or a Network Type
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
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
  END get_quick_search_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_quick_search_results(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                          ,pi_search_string    IN  VARCHAR2
                                          ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                          ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                          ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                          ,pi_skip_n_rows      IN  PLS_INTEGER
                                          ,pi_pagesize         IN  PLS_INTEGER
                                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                                          ,po_message_cursor   OUT sys_refcursor
                                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_include_enddated  VARCHAR2(1) := 'N';
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    IF pi_search_string IS NULL
     THEN
        --Please specify a search string
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 44);
    END IF;
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_paged_network_quick_search(pi_search_string    => pi_search_string
                                            ,pi_nt_type          => lt_theme_types(1).network_type
                                            ,pi_group_type       => lt_theme_types(1).network_group_type
                                            ,pi_include_enddated => pi_include_enddated
                                            ,pi_order_column     => pi_order_column
                                            ,pi_order_asc_desc   => pi_order_asc_desc
                                            ,pi_skip_n_rows      => pi_skip_n_rows
                                            ,pi_pagesize         => pi_pagesize
                                            ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_paged_assets_quick_search(pi_search_string    => pi_search_string
                                           ,pi_inv_type         => lt_theme_types(1).asset_type
                                           ,pi_include_enddated => pi_include_enddated
                                           ,pi_order_column     => pi_order_column
                                           ,pi_order_asc_desc   => pi_order_asc_desc
                                           ,pi_skip_n_rows      => pi_skip_n_rows
                                           ,pi_pagesize         => pi_pagesize
                                           ,po_cursor           => po_cursor);
              --
          ELSE
              --
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
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
  END get_paged_quick_search_results;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_network_search_sql(pi_select_list      IN VARCHAR2
                                 ,pi_where_clause     IN VARCHAR2
                                 ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                 ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                 ,pi_order_asc_desc   IN VARCHAR2 DEFAULT NULL
                                 ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_pagecols  VARCHAR2(200);
    lv_retval    nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum ind'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
            ||CHR(10)||'      ,';
    END IF;
    --
    lv_retval := 'WITH elements AS(SELECT ne_id result_id'
      ||CHR(10)||'                       ,ne_nt_type network_type'
      ||CHR(10)||'                       ,ne_gty_group_type group_type'
      ||CHR(10)||'                       ,CASE ne_nt_type'
      ||CHR(10)||'                          WHEN ''ESU'' THEN ne_name_1'
      ||CHR(10)||'                          WHEN ''NSGN'' THEN ne_number'
      ||CHR(10)||'                          ELSE ne_unique'
      ||CHR(10)||'                        END unique_'
      ||CHR(10)||'                       ,ne_descr description'
      ||CHR(10)||'                       ,ne_start_date start_date'
      ||CHR(10)||'                       ,ne_end_date end_date'
      ||CHR(10)||'                       ,nm3net.get_ne_length(ne_id) length'
      ||CHR(10)||'                       ,nau_name admin_unit'
               ||pi_select_list
      ||CHR(10)||'                   FROM nm_admin_units_all'
      ||CHR(10)||'                       ,nm_elements_all'
      ||CHR(10)||'                  WHERE ne_nt_type = :nt_type'
      ||CHR(10)||'                    AND NVL(ne_gty_group_type,:nvl) = NVL(:group_type,:nvl)'
      ||CASE
          WHEN pi_include_enddated = 'N'
           THEN
              CHR(10)||'                    AND ne_end_date IS NULL'
        END
      ||CHR(10)||'                    AND ('||pi_where_clause||')'
      ||CHR(10)||'                    AND ne_admin_unit = nau_admin_unit'
      ||CHR(10)||'         ORDER BY '||NVL(LOWER(pi_order_column),'unique_')||' '
                                     ||NVL(LOWER(pi_order_asc_desc),'asc')||')'
      ||CHR(10)||'SELECT '||lv_pagecols
                       ||'elements.*'
      ||CHR(10)||'  FROM elements'
    ;
    --
    RETURN lv_retval;
    --
  END get_network_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_search(pi_theme_types      IN awlrs_map_api.theme_types_rec
                              ,pi_criteria         IN  XMLTYPE
                              ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                              ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                              ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                              ,pi_max_rows         IN  NUMBER DEFAULT NULL
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    --
  BEGIN
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    get_network_attributes_lists(pi_nt_type     => pi_theme_types.network_type
                                ,po_alias_list  => lv_alias_list
                                ,po_select_list => lv_select_list);
    --
    lv_sql := get_network_search_sql(pi_select_list      => lv_select_list
                                    ,pi_where_clause     => lv_where
                                    ,pi_include_enddated => pi_include_enddated
                                    ,pi_order_column     => pi_order_column
                                    ,pi_order_asc_desc   => pi_order_asc_desc)
              ||lv_additional_where
    ;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
             ,pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
        ;
    END IF;
    --
  END get_network_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_search(pi_theme_types      IN awlrs_map_api.theme_types_rec
                                    ,pi_criteria         IN  XMLTYPE
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                    ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                    ,pi_skip_n_rows      IN  PLS_INTEGER
                                    ,pi_pagesize         IN  PLS_INTEGER
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    --
  BEGIN
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    get_network_attributes_lists(pi_nt_type     => pi_theme_types.network_type
                                ,po_alias_list  => lv_alias_list
                                ,po_select_list => lv_select_list);
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_network_search_sql(pi_select_list      => lv_select_list
                                                ,pi_where_clause     => lv_where
                                                ,pi_include_enddated => pi_include_enddated
                                                ,pi_order_column     => pi_order_column
                                                ,pi_order_asc_desc   => pi_order_asc_desc
                                                ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
dbms_output.put_line(lv_sql);
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
             ,lv_lower_index
             ,lv_upper_index
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
             ,lv_lower_index
        ;
    END IF;
    --
  END get_paged_network_search;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_asset_search_sql(pi_nit_rec          IN nm_inv_types_all%ROWTYPE
                               ,pi_alias_list       IN VARCHAR2
                               ,pi_select_list      IN VARCHAR2
                               ,pi_where_clause     IN VARCHAR2
                               ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                               ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                               ,pi_order_asc_desc   IN VARCHAR2 DEFAULT NULL
                               ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_pagecols  VARCHAR2(200);
    lv_retval    nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum ind'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
            ||CHR(10)||'      ,';
    END IF;
    --
    IF pi_nit_rec.nit_table_name IS NOT NULL
     THEN
        --
        lv_retval :=  'WITH assets AS(SELECT '||pi_nit_rec.nit_foreign_pk_column||' result_id'
           ||CHR(10)||'                     ,'||pi_nit_rec.nit_foreign_pk_column||' primary_key'
                                              ||pi_select_list
           ||CHR(10)||'                 FROM '||pi_nit_rec.nit_table_name||' iit'
           ||CHR(10)||'                WHERE ('||pi_where_clause||')'
           ||CHR(10)||'                ORDER BY '||NVL(LOWER(pi_order_column),'primary_key')||' '
                                                 ||NVL(LOWER(pi_order_asc_desc),'asc')||')'
           ||CHR(10)||'SELECT '||lv_pagecols
                            ||'assets.*'
           ||CHR(10)||'  FROM assets'
        ;
        --
    ELSE
        lv_retval :=  'WITH assets AS(SELECT iit_ne_id result_id'
           ||CHR(10)||'                     ,iit_primary_key primary_key'
           ||CHR(10)||'                     ,iit_descr description'
           ||CHR(10)||'                     ,nau_name admin_unit'
                    ||pi_select_list
           ||CHR(10)||'                 FROM nm_inv_items_all iit'
           ||CHR(10)||'                     ,nm_admin_units_all nau'
           ||CHR(10)||'                WHERE iit.iit_inv_type = :inv_type'
           ||CASE
               WHEN pi_include_enddated = 'N'
                THEN CHR(10)||'                  AND iit.iit_end_date IS NULL'
             END
           ||CHR(10)||'                  AND ('||pi_where_clause||')'
           ||CHR(10)||'                  AND iit.iit_admin_unit = nau.nau_admin_unit'
           ||CHR(10)||'         ORDER BY '||NVL(LOWER(pi_order_column),'primary_key')||' '
                                          ||NVL(LOWER(pi_order_asc_desc),'asc')||')'
           ||CHR(10)||'SELECT '||lv_pagecols
                            ||'assets.*'
           ||CHR(10)||'  FROM assets'
        ;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END get_asset_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_assets_search(pi_theme_types      IN awlrs_map_api.theme_types_rec
                             ,pi_criteria         IN  XMLTYPE
                             ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                             ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                             ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                             ,pi_max_rows         IN  NUMBER DEFAULT NULL
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_theme_types.asset_type);
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    get_asset_attributes_lists(pi_inv_type    => lr_nit.nit_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    lv_sql := get_asset_search_sql(pi_nit_rec          => lr_nit
                                  ,pi_alias_list       => lv_alias_list
                                  ,pi_select_list      => lv_select_list
                                  ,pi_where_clause     => lv_where
                                  ,pi_include_enddated => pi_include_enddated
                                  ,pi_order_column     => pi_order_column
                                  ,pi_order_asc_desc   => pi_order_asc_desc)
              ||lv_additional_where
    ;
    --
dbms_output.put_line(lv_sql);
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_max_rows IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql USING pi_max_rows;
        ELSE
            OPEN po_cursor FOR lv_sql;
        END IF;
        --
    ELSE
        --
        IF pi_max_rows IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql USING lr_nit.nit_inv_type,pi_max_rows;
        ELSE
            OPEN po_cursor FOR lv_sql USING lr_nit.nit_inv_type;
        END IF;
        --
    END IF;
    --
  END get_assets_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_assets_search(pi_theme_types      IN awlrs_map_api.theme_types_rec
                                   ,pi_criteria         IN  XMLTYPE
                                   ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                   ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                   ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                   ,pi_skip_n_rows      IN  PLS_INTEGER
                                   ,pi_pagesize         IN  PLS_INTEGER
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_additional_where  nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_theme_types.asset_type);
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    get_asset_attributes_lists(pi_inv_type    => lr_nit.nit_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    lv_sql := get_asset_search_sql(pi_nit_rec          => lr_nit
                                  ,pi_alias_list       => lv_alias_list
                                  ,pi_select_list      => lv_select_list
                                  ,pi_where_clause     => lv_where
                                  ,pi_include_enddated => pi_include_enddated
                                  ,pi_order_column     => pi_order_column
                                  ,pi_order_asc_desc   => pi_order_asc_desc
                                  ,pi_paged            => TRUE)
    ;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||lv_sql||')'
            ||lv_additional_where
    ;
dbms_output.put_line(lv_sql);
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lv_lower_index
            ;
        END IF;
        --
    ELSE
       --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,lv_lower_index
            ;
        END IF;
        --
    END IF;
    --
  END get_paged_assets_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_search_results(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                              ,pi_criteria         IN  XMLTYPE
                              ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                              ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                              ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                              ,pi_max_rows         IN  NUMBER DEFAULT NULL
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lv_include_enddated  VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_network_search(pi_theme_types      => lt_theme_types(1)
                                ,pi_criteria         => pi_criteria
                                ,pi_include_enddated => pi_include_enddated
                                ,pi_order_column     => pi_order_column
                                ,pi_order_asc_desc   => pi_order_asc_desc
                                ,pi_max_rows         => pi_max_rows
                                ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_assets_search(pi_theme_types      => lt_theme_types(1)
                               ,pi_criteria         => pi_criteria
                               ,pi_include_enddated => pi_include_enddated
                               ,pi_order_column     => pi_order_column
                               ,pi_order_asc_desc   => pi_order_asc_desc
                               ,pi_max_rows         => pi_max_rows
                               ,po_cursor           => po_cursor);
              --
          ELSE
              --
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
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
  END get_search_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_search_results(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                    ,pi_criteria         IN  XMLTYPE
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                    ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                    ,pi_skip_n_rows      IN  PLS_INTEGER
                                    ,pi_pagesize         IN  PLS_INTEGER
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_include_enddated  VARCHAR2(1) := 'N';
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_paged_network_search(pi_theme_types      => lt_theme_types(1)
                                      ,pi_criteria         => pi_criteria
                                      ,pi_include_enddated => pi_include_enddated
                                      ,pi_order_column     => pi_order_column
                                      ,pi_order_asc_desc   => pi_order_asc_desc
                                      ,pi_skip_n_rows      => pi_skip_n_rows
                                      ,pi_pagesize         => pi_pagesize
                                      ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_paged_assets_search(pi_theme_types      => lt_theme_types(1)
                                     ,pi_criteria         => pi_criteria
                                     ,pi_include_enddated => pi_include_enddated
                                     ,pi_order_column     => pi_order_column
                                     ,pi_order_asc_desc   => pi_order_asc_desc
                                     ,pi_skip_n_rows      => pi_skip_n_rows
                                     ,pi_pagesize         => pi_pagesize
                                     ,po_cursor           => po_cursor);
              --
          ELSE
              --
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 6
                           ,pi_supplementary_info => pi_theme_name);
              --
        END CASE;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
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
  END get_paged_search_results;

END awlrs_search_api;
/

show err
