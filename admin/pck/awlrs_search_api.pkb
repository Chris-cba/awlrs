CREATE OR REPLACE PACKAGE BODY awlrs_search_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_search_api.pkb-arc   1.44   Jul 21 2020 12:31:30   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_search_api.pkb  $
  --       Date into PVCS   : $Date:   Jul 21 2020 12:31:30  $
  --       Date fetched Out : $Modtime:   Jul 21 2020 12:07:12  $
  --       Version          : $Revision:   1.44  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.44  $';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_search_api';
  --
  g_default_date_format      VARCHAR2(100);
  g_default_datetime_format  VARCHAR2(100);
  --
  TYPE domain_meaning_store_tab IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(32767);
  g_domain_meaning_store  domain_meaning_store_tab;
  --
  TYPE col_rec IS RECORD(data_type    VARCHAR2(106)
                        ,data_length  NUMBER
                        ,data_scale   NUMBER);
  TYPE col_tab IS TABLE OF col_rec INDEX BY VARCHAR2(30);
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
  ------------------------------------------------------------------------------
  --
  FUNCTION prompt_to_column_name(pi_prompt   IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
  BEGIN
    --
    RETURN LOWER(TRANSLATE(pi_prompt,' ."','_'));
    --
  END prompt_to_column_name;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION prompt_to_title(pi_prompt   IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
  BEGIN
    --
    RETURN INITCAP(TRANSLATE(pi_prompt,'_."',' '));
    --
  END prompt_to_title;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION is_node_layer(pi_feature_table IN nm_themes_all.nth_feature_table%TYPE)
    RETURN BOOLEAN IS
  BEGIN
    --
    RETURN (pi_feature_table LIKE 'V_NM_NO_%_SDO');
    --
  END is_node_layer;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_date_formats
    IS
    --
    CURSOR get_format
        IS
    SELECT REPLACE(value,'R','Y')
      FROM v$nls_parameters
     WHERE parameter ='NLS_DATE_FORMAT'
         ;
    --
  BEGIN
    --
    g_default_date_format := REPLACE(hig.get_sysopt('GRIDATE'),'R','Y');
    --
    IF g_default_date_format IS NULL
     THEN
        OPEN  get_format;
        FETCH get_format
         INTO g_default_date_format;
        CLOSE get_format;
    END IF;
    --
    g_default_datetime_format := g_default_date_format||' HH24:MI';
    --
  END set_date_formats;

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
       ||CHR(10)||'              ,CASE ita_format WHEN ''DATE'' THEN REPLACE(NVL(ita_format_mask,:default_date_format),''R'',''Y'') ELSE ita_format_mask END format_mask'
       ||CHR(10)||'              ,CASE ita_format WHEN ''DATE'' THEN LENGTH(REPLACE(NVL(ita_format_mask,:default_date_format),''24'','''')) ELSE ita_fld_length END field_length'
       ||CHR(10)||'              ,ita_dec_places decimal_places'
       ||CHR(10)||'              ,ita_min min_value'
       ||CHR(10)||'              ,ita_max max_value'
       ||CHR(10)||'              ,ita_case'
       ||CHR(10)||'              ,ita_id_domain'
       ||CHR(10)||'              ,''N''         sql_based_domain'
       ||CHR(10)||'              ,ita_disp_seq_no+1 display_sequence'
       ||CHR(10)||'          FROM nm_inv_type_attribs, nit'
       ||CHR(10)||'         WHERE ita_inv_type = nit.nit_inv_type)'
        ;
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
       ||CHR(10)||'              ,CASE column_name'
       ||CHR(10)||'                 WHEN ''IIT_PRIMARY_KEY''   THEN ''Primary Key'''
       ||CHR(10)||'                 WHEN ''IIT_DESCR''         THEN ''Description'''
       ||CHR(10)||'                 WHEN ''IIT_X_SECT''        THEN ''XSP'''
       ||CHR(10)||'                 WHEN ''IIT_ADMIN_UNIT''    THEN ''Admin Unit'''
       ||CHR(10)||'                 WHEN ''IIT_NOTE''          THEN ''Notes'''
       ||CHR(10)||'                 WHEN ''IIT_START_DATE''    THEN ''Start Date'''
       ||CHR(10)||'                 WHEN ''IIT_END_DATE''      THEN ''End Date'''
       ||CHR(10)||'                 WHEN ''IIT_DATE_CREATED''  THEN ''Date Created'''
       ||CHR(10)||'                 WHEN ''IIT_CREATED_BY''    THEN ''Created By'''
       ||CHR(10)||'                 WHEN ''IIT_DATE_MODIFIED'' THEN ''Date Last Modified'''
       ||CHR(10)||'                 WHEN ''IIT_MODIFIED_BY''   THEN ''Last Modified By'''
       ||CHR(10)||'               END prompt'
       ||CHR(10)||'              ,CASE column_name'
       ||CHR(10)||'                 WHEN ''IIT_ADMIN_UNIT'' THEN ''VARCHAR2'''
       ||CHR(10)||'                 ELSE data_type'
       ||CHR(10)||'               END datatype'
       ||CHR(10)||'              ,CASE'
       ||CHR(10)||'                 WHEN column_name IN(''IIT_START_DATE'',''IIT_END_DATE'')'
       ||CHR(10)||'                  THEN'
       ||CHR(10)||'                     :default_date_format'
       ||CHR(10)||'                 WHEN column_name IN(''IIT_DATE_CREATED'',''IIT_DATE_MODIFIED'')'
       ||CHR(10)||'                  THEN'
       ||CHR(10)||'                     :default_datetime_format'
       ||CHR(10)||'                 ELSE'
       ||CHR(10)||'                     NULL '
       ||CHR(10)||'               END format_mask'
       ||CHR(10)||'              ,CASE'
       ||CHR(10)||'                 WHEN column_name IN(''IIT_START_DATE'',''IIT_END_DATE'')'
       ||CHR(10)||'                  THEN'
       ||CHR(10)||'                     LENGTH(:default_date_format)'
       ||CHR(10)||'                 WHEN column_name IN(''IIT_DATE_CREATED'',''IIT_DATE_MODIFIED'')'
       ||CHR(10)||'                  THEN'
       ||CHR(10)||'                     LENGTH(REPLACE(:default_datetime_format,''24'',''''))'
       ||CHR(10)||'                 ELSE'
       ||CHR(10)||'                     NVL(data_precision, data_length)'
       ||CHR(10)||'               END field_length'
       ||CHR(10)||'              ,data_scale decimal_places'
       ||CHR(10)||'              ,NULL min_value'
       ||CHR(10)||'              ,NULL max_value'
       ||CHR(10)||'              ,CASE data_type'
       ||CHR(10)||'                 WHEN ''VARCHAR2'' THEN CASE column_name'
       ||CHR(10)||'                                          WHEN ''IIT_PRIMARY_KEY'' THEN ''UPPER'''
       ||CHR(10)||'                                          ELSE ''MIXED'''
       ||CHR(10)||'                                        END'
       ||CHR(10)||'                 ELSE ''UPPER'''
       ||CHR(10)||'               END field_case'
       ||CHR(10)||'              ,CASE column_name WHEN ''IIT_ADMIN_UNIT'' THEN ''IIT_ADMIN_UNIT'' ELSE NULL END domain_id'
       ||CHR(10)||'              ,''N'' sql_based_domain'
       ||CHR(10)||'              ,CASE column_name'
       ||CHR(10)||'                 WHEN ''IIT_PRIMARY_KEY''   THEN 1'
       ||CHR(10)||'                 WHEN ''IIT_DESCR''         THEN 2'
       ||CHR(10)||'                 WHEN ''IIT_X_SECT''        THEN 3'
       ||CHR(10)||'                 WHEN ''IIT_ADMIN_UNIT''    THEN 4'
       ||CHR(10)||'                 WHEN ''IIT_NOTE''          THEN 5'
       ||CHR(10)||'                 WHEN ''IIT_START_DATE''    THEN 6'
       ||CHR(10)||'                 WHEN ''IIT_END_DATE''      THEN 7'
       ||CHR(10)||'                 WHEN ''IIT_DATE_CREATED''  THEN 8'
       ||CHR(10)||'                 WHEN ''IIT_CREATED_BY''    THEN 9'
       ||CHR(10)||'                 WHEN ''IIT_DATE_MODIFIED'' THEN 10'
       ||CHR(10)||'                 WHEN ''IIT_MODIFIED_BY''   THEN 11'
       ||CHR(10)||'               END display_sequence'
       ||CHR(10)||'          FROM all_tab_columns'
       ||CHR(10)||'         WHERE owner = SYS_CONTEXT (''NM3CORE'',''APPLICATION_OWNER'')'
       ||CHR(10)||'           AND table_name = ''NM_INV_ITEMS_ALL'''
       ||CHR(10)||'           AND column_name IN(''IIT_PRIMARY_KEY'',''IIT_DESCR'',''IIT_X_SECT'',''IIT_ADMIN_UNIT'',''IIT_NOTE'',''IIT_START_DATE'''
       ||CHR(10)||'                             ,''IIT_END_DATE'',''IIT_CREATED_BY'',''IIT_DATE_CREATED'',''IIT_MODIFIED_BY'',''IIT_DATE_MODIFIED'')'
       ||CHR(10)||'        UNION ALL'
       ||CHR(10)||'        SELECT ita_attrib_name column_name'
       ||CHR(10)||'              ,CASE'
       ||CHR(10)||'                 WHEN ita_scrn_text IN(''Primary Key'',''Description'',''XSP'',''Admin Unit'',''Notes'',''Start Date'''
       ||CHR(10)||'                                      ,''End Date'',''Date Created'',''Created By'',''Date Last Modified'',''Last Modified By'')'
       ||CHR(10)||'                  THEN'
       ||CHR(10)||'                     ita_scrn_text||'' (attribute)'''
       ||CHR(10)||'                 ELSE'
       ||CHR(10)||'                     ita_scrn_text'
       ||CHR(10)||'               END prompt'
       ||CHR(10)||'              ,ita_format datatype'
       ||CHR(10)||'              ,CASE ita_format WHEN ''DATE'' THEN REPLACE(NVL(ita_format_mask,:default_date_format),''R'',''Y'') ELSE ita_format_mask END format_mask'
       ||CHR(10)||'              ,CASE ita_format WHEN ''DATE'' THEN LENGTH(REPLACE(NVL(ita_format_mask,:default_date_format),''24'','''')) ELSE ita_fld_length END field_length'
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
  PROCEDURE get_asset_type_attributes(pi_inv_type      IN  nm_inv_types_all.nit_inv_type%TYPE
                                     ,pi_ft_asset_type IN  VARCHAR2
                                     ,po_cursor        OUT sys_refcursor)
    IS
  BEGIN
    --
    IF pi_ft_asset_type = 'Y'
     THEN
        OPEN po_cursor FOR gen_asset_type_attributes_sql(pi_inv_type => pi_inv_type)
                           ||' ORDER BY display_sequence'
          USING pi_inv_type
               ,g_default_date_format
               ,g_default_date_format;
    ELSE
        OPEN po_cursor FOR gen_asset_type_attributes_sql(pi_inv_type => pi_inv_type)
                           ||' ORDER BY display_sequence'
          USING g_default_date_format
               ,g_default_datetime_format
               ,g_default_date_format
               ,g_default_datetime_format
               ,g_default_date_format
               ,g_default_date_format
               ,pi_inv_type;
    END IF;
    --
  END get_asset_type_attributes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_type_attributes(pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    --
    lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_inv_type);
    --
    get_asset_type_attributes(pi_inv_type      => lr_nit.nit_inv_type
                             ,pi_ft_asset_type => CASE WHEN lr_nit.nit_table_name IS NOT NULL THEN 'Y' ELSE 'N' END
                             ,po_cursor        => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
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
  ||CHR(10)||'  FROM (SELECT CASE column_name WHEN ''NE_NAME_1'' THEN ''NE_UNIQUE'' ELSE column_name END column_name'
  ||CHR(10)||'              ,CASE column_name'
  ||CHR(10)||'                 WHEN ''NE_ID''             THEN ''Element Id'''
  ||CHR(10)||'                 WHEN ''NE_NAME_1''         THEN ''Unique'''
  ||CHR(10)||'                 WHEN ''NE_ADMIN_UNIT''     THEN ''Admin Unit'''
  ||CHR(10)||'                 WHEN ''NE_NT_TYPE''        THEN ''Network Type'''
  ||CHR(10)||'                 WHEN ''NE_DESCR''          THEN ''Description'''
  ||CHR(10)||'                 WHEN ''NE_GTY_GROUP_TYPE'' THEN ''Group Type'''
  ||CHR(10)||'                 WHEN ''NE_START_DATE''     THEN ''Start Date'''
  ||CHR(10)||'                 WHEN ''NE_END_DATE''       THEN ''End Date'''
  ||CHR(10)||'                 WHEN ''NE_NO_START''       THEN ''Start Node'''
  ||CHR(10)||'                 WHEN ''NE_NO_END''         THEN ''End Node'''
  ||CHR(10)||'                 WHEN ''NE_LENGTH''         THEN ''Length'''
  ||CHR(10)||'                 WHEN ''NE_DATE_CREATED''   THEN ''Date Created'''
  ||CHR(10)||'                 WHEN ''NE_CREATED_BY''     THEN ''Created By'''
  ||CHR(10)||'                 WHEN ''NE_DATE_MODIFIED''  THEN ''Date Last Modified'''
  ||CHR(10)||'                 WHEN ''NE_MODIFIED_BY''    THEN ''Last Modified By'''
  ||CHR(10)||'               END prompt'
  ||CHR(10)||'              ,CASE  WHEN column_name IN(''NE_ADMIN_UNIT'',''NE_NO_START'',''NE_NO_END'') THEN ''VARCHAR2'' ELSE data_type END datatype'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name IN(''NE_START_DATE'',''NE_END_DATE'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     :default_date_format'
  ||CHR(10)||'                 WHEN column_name IN(''NE_DATE_CREATED'',''NE_DATE_MODIFIED'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     :default_datetime_format'
  ||CHR(10)||'                 WHEN column_name = ''NE_LENGTH'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     nm3unit.get_unit_mask(:unit_id)'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     NULL'
  ||CHR(10)||'               END format_mask'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name IN(''NE_START_DATE'',''NE_END_DATE'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     LENGTH(:default_date_format)'
  ||CHR(10)||'                 WHEN column_name IN(''NE_DATE_CREATED'',''NE_DATE_MODIFIED'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     LENGTH(REPLACE(:default_datetime_format,''24'',''''))'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     NVL(data_precision, data_length)'
  ||CHR(10)||'               END field_length'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name = ''NE_LENGTH'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     (SELECT CASE'
  ||CHR(10)||'                               WHEN INSTR(mask,(SELECT SUBSTR(value,1,1) FROM nls_database_parameters WHERE parameter = ''NLS_NUMERIC_CHARACTERS''),1) = 0'
  ||CHR(10)||'                                THEN'
  ||CHR(10)||'                                   0'
  ||CHR(10)||'                               ELSE'
  ||CHR(10)||'                                   LENGTH(SUBSTR(mask,INSTR(mask,(SELECT SUBSTR(value,1,1) FROM nls_database_parameters WHERE parameter = ''NLS_NUMERIC_CHARACTERS''),1)+ 1))'
  ||CHR(10)||'                             END'
  ||CHR(10)||'                        FROM (SELECT nm3unit.get_unit_mask(:unit_id) mask FROM DUAL))'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     data_scale'
  ||CHR(10)||'               END decimal_places'
  ||CHR(10)||'              ,NULL min_value'
  ||CHR(10)||'              ,NULL max_value'
  ||CHR(10)||'              ,CASE data_type'
  ||CHR(10)||'                 WHEN ''VARCHAR2'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     CASE WHEN column_name = ''NE_DESCR'' THEN ''MIXED'' ELSE ''UPPER'' END'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     ''UPPER'''
  ||CHR(10)||'               END field_case'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name = ''NE_ADMIN_UNIT'' THEN ''NE_ADMIN_UNIT'''
  ||CHR(10)||'                 WHEN column_name IN(''NE_NO_START'',''NE_NO_END'') THEN ''NE_NODE'''
  ||CHR(10)||'                 ELSE NULL'
  ||CHR(10)||'               END domain_id'
  ||CHR(10)||'              ,CASE WHEN column_name IN(''NE_NO_START'',''NE_NO_END'') THEN ''Y'' ELSE ''N'' END sql_based_domain'
  ||CHR(10)||'              ,CASE column_name'
  ||CHR(10)||'                 WHEN ''NE_NAME_1''         THEN 1'
  ||CHR(10)||'                 WHEN ''NE_DESCR''          THEN 2'
  ||CHR(10)||'                 WHEN ''NE_NT_TYPE''        THEN 3'
  ||CHR(10)||'                 WHEN ''NE_GTY_GROUP_TYPE'' THEN 4'
  ||CHR(10)||'                 WHEN ''NE_ADMIN_UNIT''     THEN 5'
  ||CHR(10)||'                 WHEN ''NE_START_DATE''     THEN 6'
  ||CHR(10)||'                 WHEN ''NE_END_DATE''       THEN 7'
  ||CHR(10)||'                 WHEN ''NE_NO_START''       THEN 8'
  ||CHR(10)||'                 WHEN ''NE_NO_END''         THEN 9'
  ||CHR(10)||'                 WHEN ''NE_LENGTH''         THEN 10'
  ||CHR(10)||'                 WHEN ''NE_DATE_CREATED''   THEN 11'
  ||CHR(10)||'                 WHEN ''NE_CREATED_BY''     THEN 12'
  ||CHR(10)||'                 WHEN ''NE_DATE_MODIFIED''  THEN 13'
  ||CHR(10)||'                 WHEN ''NE_MODIFIED_BY''    THEN 14'
  ||CHR(10)||'                 WHEN ''NE_ID''             THEN 10000'
  ||CHR(10)||'               END display_sequence'
  ||CHR(10)||'          FROM all_tab_columns'
  ||CHR(10)||'         WHERE owner = SYS_CONTEXT(''NM3CORE'',''APPLICATION_OWNER'')'
  ||CHR(10)||'           AND table_name = ''NM_ELEMENTS_ALL'''
  ||CHR(10)||'           AND (column_name IN (''NE_ID'',''NE_NAME_1'',''NE_ADMIN_UNIT'',''NE_NT_TYPE'',''NE_DESCR'''
  ||CHR(10)||'                              ,''NE_START_DATE'',''NE_END_DATE'',''NE_DATE_CREATED'''
  ||CHR(10)||'                              ,''NE_CREATED_BY'',''NE_DATE_MODIFIED'',''NE_MODIFIED_BY'')'
  ||CHR(10)||'                OR (nm3net.is_nt_datum(:pi_nt_type) = ''Y'' AND column_name IN(''NE_NO_START'',''NE_NO_END''))'
  ||CHR(10)||'                OR (nm3net.is_nt_datum(:pi_nt_type) = ''N'' AND column_name = ''NE_GTY_GROUP_TYPE'')'
  ||CHR(10)||'                OR (nm3net.is_nt_linear(:pi_nt_type) = ''Y'' AND column_name = ''NE_LENGTH''))'
  ||CHR(10)||'        UNION ALL'
  ||CHR(10)||'        SELECT ntc_column_name    column_name'
  ||CHR(10)||'              ,ntc_prompt         prompt'
  ||CHR(10)||'              ,ntc_column_type    datatype'
  ||CHR(10)||'              ,CASE ntc_column_type WHEN ''DATE'' THEN REPLACE(NVL(ntc_format,:default_date_format),''R'',''Y'') ELSE ntc_format END format_mask'
  ||CHR(10)||'              ,CASE ntc_column_type WHEN ''DATE'' THEN LENGTH(REPLACE(NVL(ntc_format,:default_date_format),''24'','''')) ELSE ntc_str_length END field_length'
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
  ||CHR(10)||'                   AND ntc_displayed = ''Y'')'
  ||CHR(10)||'        UNION ALL'
  ||CHR(10)||'        SELECT ita_attrib_name   column_name'
  ||CHR(10)||'              ,ita_scrn_text     prompt'
  ||CHR(10)||'              ,ita_format        datatype'
  ||CHR(10)||'              ,CASE ita_format WHEN ''DATE'' THEN REPLACE(NVL(ita_format_mask,:default_date_format),''R'',''Y'') ELSE ita_format_mask END format_mask'
  ||CHR(10)||'              ,CASE ita_format WHEN ''DATE'' THEN LENGTH(REPLACE(NVL(ita_format_mask,:default_date_format),''24'','''')) ELSE ita_fld_length END field_length'
  ||CHR(10)||'              ,ita_dec_places    decimal_places'
  ||CHR(10)||'              ,ita_min           min_value'
  ||CHR(10)||'              ,ita_max           max_value'
  ||CHR(10)||'              ,ita_case          field_case'
  ||CHR(10)||'              ,ita_id_domain     domain_id'
  ||CHR(10)||'              ,''N''             sql_based_domain'
  ||CHR(10)||'              ,ita_disp_seq_no+1000 seq_no'
  ||CHR(10)||'          FROM nm_inv_type_attribs'
  ||CHR(10)||'              ,nm_nw_ad_types adt'
  ||CHR(10)||'         WHERE adt.nad_nt_type = :pi_nt_type'
  ||CHR(10)||'           AND NVL(adt.nad_gty_type,''~~~~~'') = NVL(:pi_group_type,''~~~~~'')'
  ||CHR(10)||'           AND adt.nad_primary_ad = ''Y'''
  ||CHR(10)||'           AND adt.nad_inv_type = ita_inv_type)'
    ;
    --
  END gen_network_attributes_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_attributes(pi_nt_type    IN  nm_types.nt_type%TYPE
                                  ,pi_group_type IN  nm_group_types_all.ngt_group_type%TYPE
                                  ,pi_unit_id    IN  nm_units.un_unit_id%TYPE
                                  ,po_cursor     OUT sys_refcursor)
    IS
  BEGIN
    OPEN po_cursor FOR gen_network_attributes_sql||' ORDER BY display_sequence'
    USING g_default_date_format
         ,g_default_datetime_format
         ,pi_unit_id
         ,g_default_date_format
         ,g_default_datetime_format
         ,pi_unit_id
         ,pi_nt_type
         ,pi_nt_type
         ,pi_nt_type
         ,g_default_date_format
         ,g_default_date_format
         ,pi_nt_type
         ,g_default_date_format
         ,g_default_date_format
         ,pi_nt_type
         ,pi_group_type;
  END get_network_attributes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gen_node_attributes_sql
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
  ||CHR(10)||'  FROM (SELECT column_name'
  ||CHR(10)||'              ,CASE column_name'
  ||CHR(10)||'                 WHEN ''NO_NODE_NAME''      THEN ''Name'''
  ||CHR(10)||'                 WHEN ''NO_DESCR''          THEN ''Description'''
  ||CHR(10)||'                 WHEN ''NO_PURPOSE''        THEN ''Purpose'''
  ||CHR(10)||'                 WHEN ''NO_START_DATE''     THEN ''Start Date'''
  ||CHR(10)||'                 WHEN ''NO_END_DATE''       THEN ''End Date'''
  ||CHR(10)||'                 WHEN ''NO_NODE_TYPE''      THEN ''Type'''
  ||CHR(10)||'                 WHEN ''NO_DATE_CREATED''   THEN ''Date Created'''
  ||CHR(10)||'                 WHEN ''NO_CREATED_BY''     THEN ''Created By'''
  ||CHR(10)||'                 WHEN ''NO_DATE_MODIFIED''  THEN ''Date Modified'''
  ||CHR(10)||'                 WHEN ''NO_MODIFIED_BY''    THEN ''Modified By'''
  ||CHR(10)||'                 WHEN ''NO_NODE_ID''        THEN ''Node Id'''
  ||CHR(10)||'                 WHEN ''NO_NP_ID''          THEN ''Point Id'''
  ||CHR(10)||'                 WHEN ''NPL_ID''            THEN ''Point Location Id'''
  ||CHR(10)||'               END prompt'
  ||CHR(10)||'              ,data_type datatype'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name IN(''NO_START_DATE'',''NO_END_DATE'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     :default_date_format'
  ||CHR(10)||'                 WHEN column_name IN(''NO_DATE_CREATED'',''NO_DATE_MODIFIED'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     :default_datetime_format'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     NULL'
  ||CHR(10)||'               END format_mask'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name IN(''NO_START_DATE'',''NO_END_DATE'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     LENGTH(:default_date_format)'
  ||CHR(10)||'                 WHEN column_name IN(''NO_DATE_CREATED'',''NO_DATE_MODIFIED'')'
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     LENGTH(REPLACE(:default_datetime_format,''24'',''''))'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     NVL(data_precision, data_length)'
  ||CHR(10)||'               END field_length'
  ||CHR(10)||'              ,data_scale decimal_places'
  ||CHR(10)||'              ,NULL min_value'
  ||CHR(10)||'              ,NULL max_value'
  ||CHR(10)||'              ,''UPPER'' field_case'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN column_name = ''NO_NODE_TYPE'' THEN ''NO_NODE_TYPE'''
  ||CHR(10)||'                 ELSE NULL'
  ||CHR(10)||'               END domain_id'
  ||CHR(10)||'              ,''N'' sql_based_domain'
  ||CHR(10)||'              ,CASE column_name'
  ||CHR(10)||'                 WHEN ''NO_NODE_NAME''      THEN 1'
  ||CHR(10)||'                 WHEN ''NO_DESCR''          THEN 2'
  ||CHR(10)||'                 WHEN ''NO_PURPOSE''        THEN 3'
  ||CHR(10)||'                 WHEN ''NO_START_DATE''     THEN 4'
  ||CHR(10)||'                 WHEN ''NO_END_DATE''       THEN 5'
  ||CHR(10)||'                 WHEN ''NO_NODE_TYPE''      THEN 6'
  ||CHR(10)||'                 WHEN ''NO_DATE_CREATED''   THEN 7'
  ||CHR(10)||'                 WHEN ''NO_CREATED_BY''     THEN 8'
  ||CHR(10)||'                 WHEN ''NO_DATE_MODIFIED''  THEN 9'
  ||CHR(10)||'                 WHEN ''NO_MODIFIED_BY''    THEN 10'
  ||CHR(10)||'                 WHEN ''NO_NODE_ID''        THEN 11'
  ||CHR(10)||'                 WHEN ''NO_NP_ID''          THEN 12'
  ||CHR(10)||'                 WHEN ''NPL_ID''            THEN 14'
  ||CHR(10)||'               END display_sequence'
  ||CHR(10)||'          FROM all_tab_columns'
  ||CHR(10)||'         WHERE owner = SYS_CONTEXT(''NM3CORE'',''APPLICATION_OWNER'')'
  ||CHR(10)||'           AND table_name = :feature_table'
  ||CHR(10)||'           AND column_name IN(''NO_NODE_NAME'',''NO_DESCR'',''NO_PURPOSE'',''NO_START_DATE'''
  ||CHR(10)||'                             ,''NO_END_DATE'',''NO_NODE_TYPE'',''NO_DATE_CREATED'',''NO_CREATED_BY'''
  ||CHR(10)||'                             ,''NO_DATE_MODIFIED'',''NO_MODIFIED_BY'',''NO_NODE_ID'',''NPL_ID'',''NO_NP_ID''))'
    ;
    --
  END gen_node_attributes_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_attributes(pi_feature_table IN  nm_themes_all.nth_feature_table%TYPE
                               ,po_cursor        OUT sys_refcursor)
    IS
  BEGIN
    OPEN po_cursor FOR gen_node_attributes_sql||' ORDER BY display_sequence'
    USING g_default_date_format
         ,g_default_datetime_format
         ,g_default_date_format
         ,g_default_datetime_format
         ,pi_feature_table
    ;
  END get_node_attributes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gen_table_attributes_sql
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
  ||CHR(10)||'  FROM (SELECT column_name'
  ||CHR(10)||'              ,column_name prompt'
  ||CHR(10)||'              ,data_type datatype'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN data_type = ''DATE'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     :default_datetime_format'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     NULL'
  ||CHR(10)||'               END format_mask'
  ||CHR(10)||'              ,CASE'
  ||CHR(10)||'                 WHEN data_type = ''DATE'''
  ||CHR(10)||'                  THEN'
  ||CHR(10)||'                     LENGTH(REPLACE(:default_datetime_format,''24'',''''))'
  ||CHR(10)||'                 ELSE'
  ||CHR(10)||'                     NVL(data_precision, data_length)'
  ||CHR(10)||'               END field_length'
  ||CHR(10)||'              ,data_scale decimal_places'
  ||CHR(10)||'              ,NULL min_value'
  ||CHR(10)||'              ,NULL max_value'
  ||CHR(10)||'              ,''MIXED'' field_case'
  ||CHR(10)||'              ,NULL domain_id'
  ||CHR(10)||'              ,''N'' sql_based_domain'
  ||CHR(10)||'              ,column_id display_sequence'
  ||CHR(10)||'          FROM all_tab_columns'
  ||CHR(10)||'         WHERE owner = SYS_CONTEXT(''NM3CORE'',''APPLICATION_OWNER'')'
  ||CHR(10)||'           AND table_name = :feature_table'
  ||CHR(10)||'           AND data_type IN(''VARCHAR2'',''NUMBER'',''DATE''))'
    ;
    --
  END gen_table_attributes_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_attributes(pi_feature_table IN  nm_themes_all.nth_feature_table%TYPE
                                ,po_cursor        OUT sys_refcursor)
    IS
  BEGIN
    OPEN po_cursor FOR gen_table_attributes_sql||' ORDER BY display_sequence'
    USING g_default_datetime_format
         ,g_default_datetime_format
         ,pi_feature_table
    ;
  END get_table_attributes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_attributes(pi_feature_table    IN  nm_themes_all.nth_feature_table%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    get_table_attributes(pi_feature_table => pi_feature_table
                        ,po_cursor        => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_table_attributes;

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
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_network_attributes(pi_nt_type    => lt_theme_types(1).network_type
                                    ,pi_group_type => lt_theme_types(1).network_group_type
                                    ,pi_unit_id    => lt_theme_types(1).unit_id
                                    ,po_cursor     => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_asset_type_attributes(pi_inv_type      => lt_theme_types(1).asset_type
                                       ,pi_ft_asset_type => lt_theme_types(1).ft_asset_type
                                       ,po_cursor        => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  get_node_attributes(pi_feature_table => lt_theme_types(1).feature_table
                                     ,po_cursor        => po_cursor);
              ELSE
                  get_table_attributes(pi_feature_table => lt_theme_types(1).feature_table
                                      ,po_cursor        => po_cursor);
              END IF;
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
    RETURN   'SELECT distinct TO_CHAR(nag.nag_child_admin_unit) code'
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
  FUNCTION get_nodes_sql
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN   'SELECT TO_CHAR(no_node_id) code'
  ||CHR(10)||'      ,no_node_name meaning'
  ||CHR(10)||'  FROM nm_nodes'
  ||CHR(10)||' WHERE no_node_type = :node_type'
    ;
    --
  END get_nodes_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nodes(pi_node_type IN  nm_nodes.no_node_type%TYPE
                     ,po_cursor    OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR get_nodes_sql||' ORDER BY meaning' USING pi_node_type;
    --
  END get_nodes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nodes(pi_node_type   IN  nm_nodes.no_node_type%TYPE
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
        lv_filter := ' AND UPPER(no_node_name) LIKE UPPER(''%''||:filter||''%'')';
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
                     ||get_nodes_sql
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
                 ,pi_node_type
                 ,pi_filter
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_node_type
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
                 ,pi_node_type
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,pi_node_type
                 ,lv_lower_index
            ;
        END IF;
    END IF;
    --
  END get_paged_nodes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_node_types_sql
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN   'SELECT nnt_type code'
  ||CHR(10)||'      ,nnt_descr meaning'
  ||CHR(10)||'  FROM nm_node_types'
    ;
    --
  END get_node_types_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_types(po_cursor OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR get_node_types_sql||' ORDER BY meaning';
    --
  END get_node_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_node_types(pi_filter      IN  VARCHAR2
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
        lv_filter := ' WHERE UPPER(nnt_type) LIKE UPPER(''%''||:filter||''%'')';
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
                     ||get_node_types_sql
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
                 ,pi_filter
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
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
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_filter
                 ,lv_lower_index
            ;
        END IF;
    END IF;
    --
  END get_paged_node_types;

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
  PROCEDURE get_asset_domain_values(pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                   ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    --
    IF pi_column_name = 'IIT_ADMIN_UNIT'
     THEN
        --
        lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_inv_type);
        --
        get_admin_units(pi_admin_type  => lr_nit.nit_admin_type
                       ,po_cursor      => po_cursor);
        --
    ELSE
        --
        get_asset_domain(pi_asset_type  => pi_inv_type
                        ,pi_column_name => pi_column_name
                        ,po_cursor      => po_cursor);
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
  END get_asset_domain_values;

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
              CASE
                WHEN pi_column_name = 'NE_ADMIN_UNIT'
                 THEN
                    --
                    get_admin_units(pi_admin_type  => lt_theme_types(1).admin_type
                                   ,po_cursor      => po_cursor);
                    --
                    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                         ,po_cursor           => po_message_cursor);
                    --
                WHEN pi_column_name IN('NE_NO_START','NE_NO_END')
                 THEN
                    --
                    get_nodes(pi_node_type => lt_theme_types(1).node_type
                             ,po_cursor    => po_cursor);
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
                    po_message_severity := lv_message_severity;
                    po_message_cursor := lv_message_cursor;
                    --
              END CASE;
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              IF pi_column_name = 'IIT_ADMIN_UNIT'
               THEN
                  --
                  get_admin_units(pi_admin_type  => lt_theme_types(1).admin_type
                                 ,po_cursor      => po_cursor);
                  --
              ELSE
                  --
                  get_asset_domain(pi_asset_type  => lt_theme_types(1).asset_type
                                  ,pi_column_name => pi_column_name
                                  ,po_cursor      => po_cursor);
                  --
              END IF;
              --
              awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                   ,po_cursor           => po_message_cursor);
              --
          ELSE
              --
              IF pi_column_name = 'NO_NODE_TYPE'
               THEN
                  --
                  get_node_types(po_cursor => po_cursor);
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
              END IF;
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
  END get_domain_values;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_domain_values(pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                         ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                                         ,pi_filter           IN  VARCHAR2
                                         ,pi_skip_n_rows      IN  PLS_INTEGER
                                         ,pi_pagesize         IN  PLS_INTEGER
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    --
    IF pi_column_name = 'IIT_ADMIN_UNIT'
     THEN
        --
        lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_inv_type);
        --
        get_paged_admin_units(pi_admin_type  => lr_nit.nit_admin_type
                             ,pi_filter      => pi_filter
                             ,pi_skip_n_rows => pi_skip_n_rows
                             ,pi_pagesize    => pi_pagesize
                             ,po_cursor      => po_cursor);
    ELSE
        --
        get_paged_asset_domain(pi_asset_type  => pi_inv_type
                              ,pi_column_name => pi_column_name
                              ,pi_filter      => pi_filter
                              ,pi_skip_n_rows => pi_skip_n_rows
                              ,pi_pagesize    => pi_pagesize
                              ,po_cursor      => po_cursor);
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
  END get_paged_asset_domain_values;

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
              CASE
                WHEN pi_column_name = 'NE_ADMIN_UNIT'
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
                WHEN pi_column_name IN('NE_NO_START','NE_NO_END')
                 THEN
                    --
                    get_paged_nodes(pi_node_type   => lt_theme_types(1).node_type
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
              END CASE;
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
                  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                       ,po_cursor           => po_message_cursor);
                  --
              END IF;
              --
          ELSE
              IF pi_column_name = 'NO_NODE_TYPE'
               THEN
                  get_paged_node_types(pi_filter      => pi_filter
                                      ,pi_skip_n_rows => pi_skip_n_rows
                                      ,pi_pagesize    => pi_pagesize
                                      ,po_cursor      => po_cursor);
                  --
                  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                       ,po_cursor           => po_message_cursor);
                  --
              ELSE
                  hig.raise_ner(pi_appl => 'AWLRS'
                               ,pi_id   => 6
                               ,pi_supplementary_info => pi_theme_name);
              END IF;
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
    SELECT EXTRACTVALUE(VALUE(x),'SingleExpression/Operation') operation
          ,EXTRACTVALUE(VALUE(x),'SingleExpression/FieldName') field_name
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
  FUNCTION execute_gaz_query(pi_ne_id            IN nm_elements_all.ne_id%TYPE
                            ,pi_from_offset      IN nm_gaz_query.ngq_begin_mp%TYPE DEFAULT NULL
                            ,pi_to_offset        IN nm_gaz_query.ngq_end_mp%TYPE DEFAULT NULL
                            ,pi_inv_type         IN nm_inv_types_all.nit_inv_type%TYPE
                            ,pi_include_enddated IN VARCHAR2 DEFAULT 'N')
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
          ,ngq_query_all_items
          ,ngq_begin_mp
          ,ngq_end_mp)
    VALUES(lv_job_id
          ,pi_ne_id
          ,nm3extent.c_route
          ,'C'
          ,'I'
          ,'N'
          ,pi_from_offset
          ,pi_to_offset)
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
    IF pi_include_enddated = 'Y'
     THEN
        nm3gaz_qry.g_use_date_based_views := FALSE;
    ELSE
        nm3gaz_qry.g_use_date_based_views := TRUE;
    END IF;
    --
    lv_query_id := nm3gaz_qry.perform_query (lv_job_id);
    --
    nm3gaz_qry.g_use_date_based_views := TRUE;
    --
    RETURN lv_query_id;
    --
  END execute_gaz_query;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION execute_gaz_query(pi_nse_id           IN nm_saved_extents.nse_id%TYPE
                            ,pi_inv_type         IN nm_inv_types_all.nit_inv_type%TYPE
                            ,pi_include_enddated IN VARCHAR2 DEFAULT 'N')
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
          ,pi_nse_id
          ,nm3extent.c_saved
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
    IF pi_include_enddated = 'Y'
     THEN
        nm3gaz_qry.g_use_date_based_views := FALSE;
    ELSE
        nm3gaz_qry.g_use_date_based_views := TRUE;
    END IF;
    --
    lv_query_id := nm3gaz_qry.perform_query (lv_job_id);
    --
    nm3gaz_qry.g_use_date_based_views := TRUE;
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
  BEGIN
    --
    RETURN awlrs_util.get_assignment(pi_value       => UPPER(pi_value)
                                    ,pi_datatype    => pi_datatype
                                    ,pi_format_mask => pi_format_mask);
    --
  END get_assignment;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_clause(pi_datatype    IN     VARCHAR2
                      ,pi_format_mask IN     VARCHAR2
                      ,pi_operation   IN     VARCHAR2
                      ,pi_expression  IN     single_expression_rec
                      ,po_sql         IN OUT nm3type.max_varchar2)
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
          po_sql := po_sql||' '||pi_operation||' UPPER('||lv_expression.field_name||') LIKE ''%'||UPPER(lv_expression.value1)||'%''';
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
          po_sql := po_sql||' '||pi_operation||' UPPER('||lv_expression.field_name||') NOT LIKE ''%'||UPPER(lv_expression.value1)||'%''';
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
          po_sql := po_sql||' '||pi_operation||' UPPER('||lv_expression.field_name||') LIKE '''||UPPER(lv_expression.value1)||'%''';
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
          po_sql := po_sql||' '||pi_operation||' UPPER('||lv_expression.field_name||') LIKE ''%'||UPPER(lv_expression.value1)||'''';
          --
      WHEN lv_expression.filter_function = 'EqualTo'
       THEN
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' UPPER('||lv_expression.field_name||')';
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
          --
          po_sql := po_sql||' = '||get_assignment(pi_value       => lv_expression.value1
                                                 ,pi_datatype    => pi_datatype
                                                 ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'NotEqualTo'
       THEN
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' UPPER('||lv_expression.field_name||')';
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
          --
          po_sql := po_sql||' != '||get_assignment(pi_value       => lv_expression.value1
                                                  ,pi_datatype    => pi_datatype
                                                  ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'GreaterThan'
       THEN
          --
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
          --
          po_sql := po_sql||' > '||get_assignment(pi_value       => lv_expression.value1
                                                 ,pi_datatype    => pi_datatype
                                                 ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'LessThan'
       THEN
          --
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
          --
          po_sql := po_sql||' < '||get_assignment(pi_value       => lv_expression.value1
                                                 ,pi_datatype    => pi_datatype
                                                 ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'GreaterThanOrEqualTo'
       THEN
          --
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
          --
          po_sql := po_sql||' >= '||get_assignment(pi_value       => lv_expression.value1
                                                  ,pi_datatype    => pi_datatype
                                                  ,pi_format_mask => pi_format_mask);
          --
      WHEN lv_expression.filter_function = 'LessThanOrEqualTo'
       THEN
          --
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
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
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
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
          CASE pi_datatype
            WHEN awlrs_util.c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => lv_expression.filter_function||' Datatype: '||pi_datatype);
                --
            WHEN awlrs_util.c_date_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_DATE(TO_CHAR('||lv_expression.field_name||','''||NVL(pi_format_mask,awlrs_util.c_date_mask)||'''),'''||NVL(pi_format_mask,awlrs_util.c_date_mask)||''')';
                --
            WHEN awlrs_util.c_date_in_varchar2_col
             THEN
                --
                po_sql := po_sql||' '||pi_operation||' TO_CHAR(hig.date_convert('||lv_expression.field_name||'),'''||pi_format_mask||''')';
                --
            ELSE
                --
                po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name;
                --
          END CASE;
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
          po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name||' IS NULL';
          --
      WHEN lv_expression.filter_function = 'NotIsEmpty'
       OR lv_expression.filter_function = 'NotIsNull'
       THEN
          --
          po_sql := po_sql||' '||pi_operation||' '||lv_expression.field_name||' IS NOT NULL';
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
  PROCEDURE process_single_expression(pi_theme_types      IN     awlrs_map_api.theme_types_rec
                                     ,pi_group_operation  IN     VARCHAR2
                                     ,pi_expression       IN     single_expression_rec
                                     ,pi_include_enddated IN     VARCHAR2 DEFAULT 'N'
                                     ,po_sql              IN OUT nm3type.max_varchar2)
    IS
    --
    lv_datatype     VARCHAR2(106);
    lv_format_mask  VARCHAR2(80);
    lv_operation    VARCHAR2(10);
    lv_subquery     nm3type.max_varchar2;
    lv_expression   single_expression_rec;
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
      CASE
        WHEN pi_theme_types.network_type IS NOT NULL
         THEN
            --
            lv_sql := gen_network_attributes_sql;
            --
        WHEN pi_theme_types.asset_type IS NOT NULL
         THEN
            --
            lv_sql := gen_asset_type_attributes_sql(pi_inv_type => pi_theme_types.asset_type);
            --
        WHEN is_node_layer(pi_feature_table => pi_theme_types.feature_table)
         THEN
            --
            lv_sql := gen_node_attributes_sql;
            --
        ELSE
            --
            lv_sql := gen_table_attributes_sql;
            --
      END CASE;
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
      CASE
        WHEN pi_theme_types.network_type IS NOT NULL
         THEN
            --
            EXECUTE IMMEDIATE lv_sql
               INTO po_format
                   ,po_format_mask
              USING g_default_date_format
                   ,g_default_datetime_format
                   ,pi_theme_types.unit_id
                   ,g_default_date_format
                   ,g_default_datetime_format
                   ,pi_theme_types.unit_id
                   ,pi_theme_types.network_type
                   ,pi_theme_types.network_type
                   ,pi_theme_types.network_type
                   ,g_default_date_format
                   ,g_default_date_format
                   ,pi_theme_types.network_type
                   ,g_default_date_format
                   ,g_default_date_format
                   ,pi_theme_types.network_type
                   ,pi_theme_types.network_group_type
                   ,pi_attrib_name;
            --
            IF po_format = awlrs_util.c_date_col
             THEN
                /*
                ||Check whether the date is being stored in a VARCHAR2 column.
                */
                IF awlrs_util.is_date_in_varchar(pi_nt_type     => pi_theme_types.network_type
                                                ,pi_group_type  => pi_theme_types.network_group_type
                                                ,pi_column_name => pi_attrib_name)
                 THEN
                    po_format := awlrs_util.c_date_in_varchar2_col;
                END IF;
                --
            END IF;
            --
        WHEN pi_theme_types.asset_type IS NOT NULL
         THEN
            --
            IF pi_theme_types.ft_asset_type = 'Y'
             THEN
                --
                EXECUTE IMMEDIATE lv_sql
                   INTO po_format
                       ,po_format_mask
                  USING pi_theme_types.asset_type
                       ,g_default_date_format
                       ,g_default_date_format
                       ,pi_attrib_name;
                --
            ELSE
                --
                EXECUTE IMMEDIATE lv_sql
                   INTO po_format
                       ,po_format_mask
                  USING g_default_date_format
                       ,g_default_datetime_format
                       ,g_default_date_format
                       ,g_default_datetime_format
                       ,g_default_date_format
                       ,g_default_date_format
                       ,pi_theme_types.asset_type
                       ,pi_attrib_name;
                --
            END IF;
            --
            IF po_format = awlrs_util.c_date_col
             THEN
                /*
                ||Check whether the date is being stored in a VARCHAR2 column.
                */
                IF awlrs_util.is_date_in_varchar(pi_inv_type    => pi_theme_types.asset_type
                                                ,pi_attrib_name => pi_attrib_name)
                 THEN
                    po_format := awlrs_util.c_date_in_varchar2_col;
                END IF;
                --
            END IF;
            --
        WHEN is_node_layer(pi_feature_table => pi_theme_types.feature_table)
         THEN
            --
            EXECUTE IMMEDIATE lv_sql
               INTO po_format
                   ,po_format_mask
              USING g_default_date_format
                   ,g_default_datetime_format
                   ,g_default_date_format
                   ,g_default_datetime_format
                   ,pi_theme_types.feature_table
                   ,pi_attrib_name;
            --
        ELSE
            --
            EXECUTE IMMEDIATE lv_sql
               INTO po_format
                   ,po_format_mask
              USING g_default_datetime_format
                   ,g_default_datetime_format
                   ,pi_theme_types.feature_table
                   ,pi_attrib_name;
            --
      END CASE;
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
    lv_operation := CASE
                      WHEN pi_group_operation IS NULL
                       THEN
                          NULL
                      ELSE
                          UPPER(NVL(pi_expression.operation,pi_group_operation))
                    END;
    --
    get_format(pi_theme_types => pi_theme_types
              ,pi_attrib_name => pi_expression.field_name
              ,po_format      => lv_datatype
              ,po_format_mask => lv_format_mask);
    --
    lv_expression := pi_expression;
    --
    IF pi_theme_types.network_group_type IS NOT NULL
     AND lv_expression.field_name = 'NE_LENGTH'
     THEN
        lv_expression.field_name := 'nm3net.get_ne_length(ne_id)';
    END IF;
    --
    get_clause(pi_datatype    => lv_datatype
              ,pi_format_mask => lv_format_mask
              ,pi_operation   => lv_operation
              ,pi_expression  => lv_expression
              ,po_sql         => po_sql);
    --
  END process_single_expression;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE process_group_expression(pi_theme_types      IN     awlrs_map_api.theme_types_rec
                                    ,pi_expression       IN     group_expression_rec
                                    ,pi_include_enddated IN     VARCHAR2 DEFAULT 'N'
                                    ,po_sql              IN OUT nm3type.max_varchar2)
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
          process_single_expression(pi_theme_types      => pi_theme_types
                                   ,pi_group_operation  => lv_group_expression
                                   ,pi_expression       => lt_single_expression(j)
                                   ,pi_include_enddated => pi_include_enddated
                                   ,po_sql              => po_sql);
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
               AND po_sql NOT LIKE '%AND ('
               AND po_sql NOT LIKE '%OR ('
               THEN
                  --
                  po_sql := po_sql||' '||UPPER(lt_group_expression(i).group_operation)||' ';
                  lv_open_bracket := '(';
                  lv_close_bracket := ')';
                  --
              ELSE
                  lv_open_bracket := NULL;
                  lv_close_bracket := NULL;
              END IF;
              --
              po_sql := po_sql||lv_open_bracket;
              process_group_expression(pi_theme_types      => pi_theme_types
                                      ,pi_expression       => lt_group_expression(i)
                                      ,pi_include_enddated => pi_include_enddated
                                      ,po_sql              => po_sql);
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
  FUNCTION generate_where_clause(pi_theme_types      IN awlrs_map_api.theme_types_rec
                                ,pi_criteria         IN XMLTYPE
                                ,pi_include_enddated IN VARCHAR2 DEFAULT 'N')
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
      process_group_expression(pi_theme_types      => pi_theme_types
                              ,pi_expression       => lt_expressions(i)
                              ,pi_include_enddated => pi_include_enddated
                              ,po_sql              => lv_sql);
    END LOOP;
    --
    RETURN NVL(LTRIM(lv_sql),'1=1');
    --
  END generate_where_clause;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_theme_quick_search_cols(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN columns_tab IS
    --
    lt_retval columns_tab;
    --
  BEGIN
    --
    SELECT aqsc_column
      BULK COLLECT
      INTO lt_retval
      FROM awlrs_quick_search_columns
     WHERE aqsc_theme_name = pi_theme_name
     ORDER
        BY aqsc_priority
         ;
    --
    RETURN lt_retval;
    --
  END get_theme_quick_search_cols;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_asset_attributes(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN ita_tab IS
    --
    lt_retval  ita_tab;
  BEGIN
    --
    SELECT *
      BULK COLLECT
      INTO lt_retval
      FROM nm_inv_type_attribs
     WHERE ita_inv_type = pi_inv_type
       AND ita_displayed = 'Y'
     ORDER
        BY ita_disp_seq_no
         ;
    --
    RETURN lt_retval;
    --
  END get_asset_attributes;

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
    lt_ita  ita_tab;
    --
  BEGIN
    /*
    ||Add any attributes.
    */
    lt_ita := get_asset_attributes(pi_inv_type => pi_inv_type);
    --
    FOR i IN 1..lt_ita.COUNT LOOP
      --
      IF lt_ita(i).ita_displayed = 'Y'
       THEN
          --
          lv_scrn_text := prompt_to_column_name(pi_prompt => lt_ita(i).ita_scrn_text);
          IF lv_scrn_text IN('result_id','primary_key','description','xsp','admin_unit'
                            ,'start_date','end_date','ind','row_count')
           THEN
              lv_scrn_text := '__'||lv_scrn_text;
          END IF;
          --
          IF lt_ita(i).ita_id_domain IS NOT NULL
           THEN
              --
              po_select_list := po_select_list
                ||CHR(10)||'                     ,(SELECT ial_meaning'
                ||CHR(10)||'                         FROM nm_inv_attri_lookup'
                ||CHR(10)||'                        WHERE ial_domain = '||nm3flx.string(lt_ita(i).ita_id_domain)
                ||CHR(10)||'                          AND ial_value = iit.'||LOWER(lt_ita(i).ita_attrib_name)||') "'||lv_scrn_text||'"'
              ;
              --
          ELSE
              --
              po_select_list := po_select_list||CHR(10)||'                     ,'
                ||CASE
                    WHEN lt_ita(i).ita_format = awlrs_util.c_date_col
                     THEN
                        --
                        CASE
                          WHEN INSTR(lt_ita(i).ita_attrib_name,lt_ita(i).ita_format,1,1) != 0
                           THEN
                              'TO_CHAR(iit.'||LOWER(lt_ita(i).ita_attrib_name)
                                   ||','||nm3flx.string(NVL(lt_ita(i).ita_format_mask,Sys_Context('NM3CORE','USER_DATE_MASK')))
                                   ||')'
                          ELSE
                              'TO_CHAR(hig.date_convert(iit.'||LOWER(lt_ita(i).ita_attrib_name)
                                   ||'),'||nm3flx.string(NVL(lt_ita(i).ita_format_mask,Sys_Context('NM3CORE','USER_DATE_MASK')))
                                   ||')'
                        END
                        --
                    WHEN lt_ita(i).ita_format = awlrs_util.c_number_col
                     AND lt_ita(i).ita_format_mask IS NOT NULL
                     THEN
                        --
                        'LTRIM(TO_CHAR(iit.'||LOWER(lt_ita(i).ita_attrib_name)||','||nm3flx.string(lt_ita(i).ita_format_mask)||'))'
                        --
                    WHEN lt_ita(i).ita_format IN(awlrs_util.c_date_col,awlrs_util.c_number_col)
                     THEN
                        --
                        'TO_CHAR(iit.'||LOWER(lt_ita(i).ita_attrib_name)||')'
                        --
                    ELSE
                        --
                        'iit.'||LOWER(lt_ita(i).ita_attrib_name)
                        --
                  END
                ||' "'||lv_scrn_text||'"'
              ;
          END IF;
          --
          po_alias_list := po_alias_list||CHR(10)||'      ,"'||lv_scrn_text||'"';
          --
      END IF;
      --
    END LOOP;
    --
  END get_asset_attributes_lists;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_network_attributes(pi_nt_type IN nm_types.nt_type%TYPE)
    RETURN ntc_tab IS
    --
    lt_retval  ntc_tab;
  BEGIN
    --
    SELECT *
      BULK COLLECT
      INTO lt_retval
      FROM nm_type_columns ntc
     WHERE ntc_nt_type = pi_nt_type
       AND ntc_displayed = 'Y'
     ORDER
        BY ntc_seq_no
         ;
    --
    RETURN lt_retval;
    --
  END get_network_attributes;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_sql_based_domain_meaning(pi_nt_type     IN nm_type_columns.ntc_nt_type%TYPE
                                       ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE
                                       ,pi_value       IN VARCHAR2
                                       ,pi_bind_value  IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_ne_id   nm_elements_all.ne_id%TYPE;
    lv_key     nm3type.max_varchar2 := 'nt_type:'||pi_nt_type||',column_name:'||pi_column_name||',column_value:'||pi_value||',bind_value:'||pi_bind_value;
    lv_retval  nm3type.max_varchar2 := pi_value;
    --
  BEGIN
    --
    IF lv_retval IS NOT NULL
     THEN
        BEGIN
          --
          lv_retval := g_domain_meaning_store(lv_key);
          --
        EXCEPTION
          WHEN no_data_found
           THEN
              --
              lv_retval := NULL;
              --
        END;
        --
        IF lv_retval IS NULL
         THEN
            --
            lv_retval := pi_value;
            --
            nm3flx.validate_flex_column(pi_nt_type             => pi_nt_type
                                       ,pi_column_name         => pi_column_name
                                       ,pi_bind_variable_value => pi_bind_value
                                       ,po_value               => lv_retval  -- actually goes in as actual value comes back out as meaning
                                       ,po_ne_id               => lv_ne_id);
            --
            g_domain_meaning_store(lv_key) := lv_retval;
            --
        END IF;
    END IF;
    --
    RETURN lv_retval;
    --
  END get_sql_based_domain_meaning;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_attributes_lists(pi_nt_type     IN     nm_types.nt_type%TYPE
                                        ,po_alias_list  IN OUT VARCHAR2
                                        ,po_select_list IN OUT VARCHAR2)
    IS
    --
    lv_prompt    nm_type_columns.ntc_prompt%TYPE;
    lv_sql       nm3type.max_varchar2;
    lv_flx_sql   nm3type.max_varchar2;
    lv_bind_var  VARCHAR2(30);
    --
    lt_ntc            ntc_tab;
    --
  BEGIN
    /*
    ||Add any attributes.
    */
    lt_ntc := get_network_attributes(pi_nt_type => pi_nt_type);
    --
    FOR i IN 1..lt_ntc.COUNT LOOP
      --
      lv_prompt := prompt_to_column_name(pi_prompt => lt_ntc(i).ntc_prompt);
      IF lv_prompt IN('result_id','network_type','group_type','unique_','USRN','ESU ID','Street Name'
                     ,'description','admin_unit','start_date','end_date','length','ind','row_count')
       THEN
          lv_prompt := '__'||lv_prompt;
      END IF;
      --
      lv_flx_sql := awlrs_element_api.get_domain_sql_with_bind(pi_nt_type     => pi_nt_type
                                                              ,pi_column_name => lt_ntc(i).ntc_column_name);
      --
      IF lv_flx_sql IS NOT NULL
       THEN
          --
          lv_bind_var := REPLACE(nm3flx.extract_bind_variable(lv_flx_sql),':',NULL);
          --
          IF lv_bind_var IS NULL
           THEN
              awlrs_element_api.gen_domain_sql(pi_nt_type     => pi_nt_type
                                              ,pi_column_name => lt_ntc(i).ntc_column_name
                                              ,pi_bind_value  => NULL
                                              ,pi_ordered     => FALSE
                                              ,po_sql         => lv_sql);
              lv_sql := '(SELECT meaning FROM ('||lv_sql||') WHERE code = '||lt_ntc(i).ntc_column_name||')';
              --
              po_select_list := po_select_list||CHR(10)||'                       ,'||lv_sql||' "'||lv_prompt||'"';
              --
          ELSE
              --
              po_select_list := po_select_list||CHR(10)||'                       ,awlrs_search_api.get_sql_based_domain_meaning(ne_nt_type,'''||lt_ntc(i).ntc_column_name||''','||lt_ntc(i).ntc_column_name||','||lv_bind_var||') "'||lv_prompt||'"';
              --
          END IF;
      ELSE
          --
          po_select_list := po_select_list||CHR(10)||'                     ,'
            ||CASE
                WHEN lt_ntc(i).ntc_column_type = awlrs_util.c_date_col
                 THEN
                    --
                    CASE
                      WHEN awlrs_util.is_date_in_varchar(pi_nt_type     => lt_ntc(i).ntc_nt_type
                                                        ,pi_group_type  => NULL
                                                        ,pi_column_name => lt_ntc(i).ntc_column_name)
                       THEN
                          'TO_CHAR(hig.date_convert('||LOWER(lt_ntc(i).ntc_column_name)
                               ||'),'||nm3flx.string(NVL(lt_ntc(i).ntc_format,Sys_Context('NM3CORE','USER_DATE_MASK')))
                               ||')'
                      ELSE
                          'TO_CHAR('||LOWER(lt_ntc(i).ntc_column_name)
                               ||','||nm3flx.string(NVL(lt_ntc(i).ntc_format,Sys_Context('NM3CORE','USER_DATE_MASK')))
                               ||')'
                    END
                    --
                WHEN lt_ntc(i).ntc_column_type = awlrs_util.c_number_col
                 AND lt_ntc(i).ntc_format IS NOT NULL
                 THEN
                    --
                    'LTRIM(TO_CHAR('||LOWER(lt_ntc(i).ntc_column_name)||','||nm3flx.string(lt_ntc(i).ntc_format)||'))'
                    --
                WHEN lt_ntc(i).ntc_column_type IN(awlrs_util.c_date_col,awlrs_util.c_number_col)
                 THEN
                    --
                    'TO_CHAR('||LOWER(lt_ntc(i).ntc_column_name)||')'
                    --
                ELSE
                    --
                    LOWER(lt_ntc(i).ntc_column_name)
                    --
              END
            ||' "'||lv_prompt||'"'
          ;
          --
      END IF;
      --
      po_alias_list := po_alias_list||CHR(10)||'      ,"'||lv_prompt||'"';
      --
    END LOOP;
    --
  END get_network_attributes_lists;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_attributes_lists(pi_feature_table IN     nm_themes_all.nth_feature_table%TYPE
                                      ,po_alias_list    IN OUT VARCHAR2
                                      ,po_select_list   IN OUT VARCHAR2)
    IS
    --
    lv_prompt  nm_type_columns.ntc_prompt%TYPE;
    lv_sql     nm3type.max_varchar2;
    --
    TYPE atc_rec IS RECORD(column_name  all_tab_columns.column_name%TYPE
                          ,prompt       all_tab_columns.column_name%TYPE);
    TYPE atc_tab IS TABLE OF atc_rec;
    lt_atc  atc_tab;
    --
  BEGIN
    /*
    ||Add any attributes.
    */
    SELECT column_name
          ,column_name prompt
      BULK COLLECT
      INTO lt_atc
      FROM all_tab_columns
     WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
       AND table_name = pi_feature_table
       AND data_type IN('VARCHAR2','NUMBER','DATE')
     ORDER
        BY column_id
         ;
    --
    FOR i IN 1..lt_atc.COUNT LOOP
      --
      lv_prompt := prompt_to_column_name(pi_prompt => lt_atc(i).prompt);
      --
      po_select_list := po_select_list||CHR(10)||'                       ,'||LOWER(lt_atc(i).column_name)||' "'||lv_prompt||'"';
      --
      po_alias_list := po_alias_list||CHR(10)||'      ,"'||lv_prompt||'"';
      --
    END LOOP;
    --
  END get_table_attributes_lists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_network_quick_search_sql(pi_nt_type          IN nm_types.nt_type%TYPE
                                       ,pi_like_cols        IN columns_tab
                                       ,pi_where_clause     IN VARCHAR2 DEFAULT NULL
                                       ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                       ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                       ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_alias_list   nm3type.max_varchar2;
    lv_select_list  nm3type.max_varchar2;
    lv_pagecols     VARCHAR2(200);
    lv_like_cols    nm3type.max_varchar2;
    lv_match_cases  nm3type.max_varchar2;
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    get_network_attributes_lists(pi_nt_type     => pi_nt_type
                                ,po_alias_list  => lv_alias_list
                                ,po_select_list => lv_select_list);
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_like_cols := lv_like_cols||CASE WHEN i > 1 THEN '||'' ''||' END||pi_like_cols(i);
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') = UPPER(:search_string) THEN '||i;
      --
    END LOOP;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') LIKE UPPER(:search_string||''%'') THEN '||TO_CHAR(pi_like_cols.COUNT + i);
      --
    END LOOP;
    --
    lv_match_cases := lv_match_cases||CHR(10)||'                          ELSE '||TO_CHAR((pi_like_cols.COUNT * 2) + 1);
    --
    lv_retval := 'WITH elements AS(SELECT ne_id "result_id"'
      ||CHR(10)||'                       ,ne_nt_type "network_type"'
      ||CHR(10)||'                       ,ne_gty_group_type "group_type"'
      ||CHR(10)||'                       ,ne_unique "unique_"'
    ;
    --
    IF pi_nt_type = 'NSGN'
     THEN
        lv_retval := lv_retval
          ||CHR(10)||'                       ,ne_number "USRN"';
    END IF;
    --
    CASE pi_nt_type
      WHEN 'ESU'
       THEN
          lv_retval := lv_retval
            ||CHR(10)||'                       ,ne_descr "ESU ID"';
      WHEN 'NSGN'
       THEN
          lv_retval := lv_retval
            ||CHR(10)||'                       ,ne_descr "Street Name"';
      ELSE
          lv_retval := lv_retval
            ||CHR(10)||'                       ,ne_descr "description"';
    END CASE;
    --
    lv_retval := lv_retval
      ||CHR(10)||'                       ,ne_start_date "start_date"'
      ||CHR(10)||'                       ,ne_end_date "end_date"'
      ||CHR(10)||'                       ,nm3net.get_ne_length(ne_id) "length"'
      ||CHR(10)||'                       ,nau_name "admin_unit"'
               ||lv_select_list
      ||CHR(10)||'                       ,CASE'||lv_match_cases
      ||CHR(10)||'                        END "match_quality"'
      ||CHR(10)||'                   FROM nm_admin_units_all'
      ||CHR(10)||'                       ,nm_elements_all'
      ||CHR(10)||'                  WHERE ne_type != ''D'''
      ||CHR(10)||'                    AND ne_nt_type = :nt_type'
      ||CHR(10)||'                    AND NVL(ne_gty_group_type,:nvl) = NVL(:group_type,:nvl)'
      ||CASE
          WHEN pi_include_enddated = 'N'
           THEN CHR(10)||'                    AND NVL(ne_end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
        END
      ||CHR(10)||'                    AND ('||NVL(pi_where_clause,'1=1')||')'
      ||CHR(10)||'                    AND UPPER('||NVL(lv_like_cols,'ne_unique||'' ''||ne_descr')||') LIKE :like_string'
      ||CHR(10)||'                    AND ne_admin_unit = nau_admin_unit'
      ||CHR(10)||'                  ORDER BY '||NVL(LOWER(pi_order_column),'"match_quality" ,"unique_"')||')'
      ||CHR(10)||'SELECT '||lv_pagecols
                      ||'"result_id"'
      ||CHR(10)||'      ,"network_type"'
      ||CHR(10)||'      ,"group_type"'
      ||CHR(10)||'      ,"unique_"'
    ;
    --
    IF pi_nt_type = 'NSGN'
     THEN
        lv_retval := lv_retval
          ||CHR(10)||'      ,"USRN"';
    END IF;
    --
    CASE pi_nt_type
      WHEN 'ESU'
       THEN
          lv_retval := lv_retval
            ||CHR(10)||'      ,"ESU ID"';
      WHEN 'NSGN'
       THEN
          lv_retval := lv_retval
            ||CHR(10)||'      ,"Street Name"';
      ELSE
          lv_retval := lv_retval
            ||CHR(10)||'      ,"description"';
    END CASE;
    --
    lv_retval := lv_retval
      ||CHR(10)||'      ,"start_date"'
      ||CHR(10)||'      ,"end_date"'
      ||CHR(10)||'      ,"length"'
      ||CHR(10)||'      ,"admin_unit"'
               ||lv_alias_list
      ||CHR(10)||'  FROM elements'
    ;
    --
    RETURN lv_retval;
    --
  END get_network_quick_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_network_column_data(pi_nt_type     IN     nm_types.nt_type%TYPE
                                   ,po_column_data IN OUT awlrs_util.column_data_tab)
    IS
    --
    lv_column   nm3type.max_varchar2;
    lv_prompt   nm_type_columns.ntc_prompt%TYPE;
    lv_type     VARCHAR2(10);
    lv_sql      nm3type.max_varchar2;
    lv_flx_sql  nm3type.max_varchar2;
    --
    CURSOR get_fixed_cols(cp_nt_type  nm_types.nt_type%TYPE)
        IS
    SELECT column_name
          ,data_type
          ,NVL(data_precision,data_length) data_length
          ,CASE
             WHEN column_name = 'NE_LENGTH'
              THEN
                 (SELECT CASE
                           WHEN mask IS NULL
                            OR INSTR(mask,awlrs_util.get_decimal_point,1) = 0
                            THEN
                               0
                           ELSE
                               LENGTH(SUBSTR(mask,INSTR(mask,awlrs_util.get_decimal_point,1)+1))
                         END
                    FROM (SELECT nm3unit.get_unit_mask(nt_length_unit) mask FROM nm_types WHERE nt_type = cp_nt_type))
             ELSE
                 CASE WHEN data_scale = 0 THEN NULL ELSE data_scale END
           END data_scale
     FROM user_tab_columns
     WHERE table_name IN('NM_ELEMENTS_ALL'
                        ,'NM_ADMIN_UNITS_ALL')
       AND column_name IN('NE_ID'
                         ,'NE_NT_TYPE'
                         ,'NE_GTY_GROUP_TYPE'
                         ,'NE_UNIQUE'
                         ,'NE_NUMBER'
                         ,'NE_DESCR'
                         ,'NE_START_DATE'
                         ,'NE_END_DATE'
                         ,'NE_LENGTH'
                         ,'NAU_NAME')
         ;
    --
    TYPE fixed_cols_tab IS TABLE OF get_fixed_cols%ROWTYPE;
    lt_fixed_cols  fixed_cols_tab;
    --
    lt_col_data  col_tab;
    --
    lt_attr  ntc_tab;
    --
  BEGIN
    --
    OPEN  get_fixed_cols(pi_nt_type);
    FETCH get_fixed_cols
     BULK COLLECT
     INTO lt_fixed_cols;
    CLOSE get_fixed_cols;
    --
    FOR i IN 1..lt_fixed_cols.COUNT LOOP
      --
      lt_col_data(lt_fixed_cols(i).column_name).data_type := lt_fixed_cols(i).data_type;
      lt_col_data(lt_fixed_cols(i).column_name).data_length := lt_fixed_cols(i).data_length;
      lt_col_data(lt_fixed_cols(i).column_name).data_scale := lt_fixed_cols(i).data_scale;
      --
    END LOOP;
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'result_id'
                              ,pi_query_col      => 'ne_id'
                              ,pi_datatype       => lt_col_data('NE_ID').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NE_ID').data_length
                              ,pi_decimal_places => lt_col_data('NE_ID').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'network_type'
                              ,pi_query_col      => 'ne_nt_type'
                              ,pi_datatype       => lt_col_data('NE_NT_TYPE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NE_NT_TYPE').data_length
                              ,pi_decimal_places => lt_col_data('NE_NT_TYPE').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'group_type'
                              ,pi_query_col      => 'ne_gty_group_type'
                              ,pi_datatype       => lt_col_data('NE_GTY_GROUP_TYPE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NE_GTY_GROUP_TYPE').data_length
                              ,pi_decimal_places => lt_col_data('NE_GTY_GROUP_TYPE').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'unique_'
                              ,pi_query_col      => 'ne_unique'
                              ,pi_datatype       => lt_col_data('NE_UNIQUE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NE_UNIQUE').data_length
                              ,pi_decimal_places => lt_col_data('NE_UNIQUE').data_scale
                              ,pio_column_data   => po_column_data);
    --
    IF pi_nt_type = 'NSGN'
     THEN
        awlrs_util.add_column_data(pi_cursor_col   => 'USRN'
                                  ,pi_query_col    => 'ne_number'
                                  ,pi_datatype     => lt_col_data('NE_NUMBER').data_type
                                  ,pi_mask         => NULL
                                  ,pi_field_length   => lt_col_data('NE_NUMBER').data_length
                                  ,pi_decimal_places => lt_col_data('NE_NUMBER').data_scale
                                  ,pio_column_data => po_column_data);
    END IF;
    --
    CASE pi_nt_type
      WHEN 'ESU'
       THEN
          awlrs_util.add_column_data(pi_cursor_col   => 'ESU ID'
                                    ,pi_query_col    => 'ne_descr'
                                    ,pi_datatype     => lt_col_data('NE_DESCR').data_type
                                    ,pi_mask         => NULL
                                    ,pi_field_length   => lt_col_data('NE_DESCR').data_length
                                    ,pi_decimal_places => lt_col_data('NE_DESCR').data_scale
                                    ,pio_column_data => po_column_data);
      WHEN 'NSGN'
       THEN
          awlrs_util.add_column_data(pi_cursor_col   => 'Street Name'
                                    ,pi_query_col    => 'ne_descr'
                                    ,pi_datatype     => lt_col_data('NE_DESCR').data_type
                                    ,pi_mask         => NULL
                                    ,pi_field_length   => lt_col_data('NE_DESCR').data_length
                                    ,pi_decimal_places => lt_col_data('NE_DESCR').data_scale
                                    ,pio_column_data => po_column_data);
      ELSE
          awlrs_util.add_column_data(pi_cursor_col   => 'description'
                                    ,pi_query_col    => 'ne_descr'
                                    ,pi_datatype     => lt_col_data('NE_DESCR').data_type
                                    ,pi_mask         => NULL
                                    ,pi_field_length   => lt_col_data('NE_DESCR').data_length
                                    ,pi_decimal_places => lt_col_data('NE_DESCR').data_scale
                                    ,pio_column_data => po_column_data);
    END CASE;
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                              ,pi_query_col    => 'ne_start_date'
                              ,pi_datatype     => lt_col_data('NE_START_DATE').data_type
                              ,pi_mask         => NULL
                              ,pi_field_length   => lt_col_data('NE_START_DATE').data_length
                              ,pi_decimal_places => lt_col_data('NE_START_DATE').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                              ,pi_query_col    => 'ne_end_date'
                              ,pi_datatype     => lt_col_data('NE_END_DATE').data_type
                              ,pi_mask         => NULL
                              ,pi_field_length   => lt_col_data('NE_END_DATE').data_length
                              ,pi_decimal_places => lt_col_data('NE_END_DATE').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'length'
                              ,pi_query_col    => 'nm3net.get_ne_length(ne_id)'
                              ,pi_datatype     => lt_col_data('NE_LENGTH').data_type
                              ,pi_mask         => NULL
                              ,pi_field_length   => lt_col_data('NE_LENGTH').data_length
                              ,pi_decimal_places => lt_col_data('NE_LENGTH').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'admin_unit'
                              ,pi_query_col    => 'nau_name'
                              ,pi_datatype     => lt_col_data('NAU_NAME').data_type
                              ,pi_mask         => NULL
                              ,pi_field_length   => lt_col_data('NAU_NAME').data_length
                              ,pi_decimal_places => lt_col_data('NAU_NAME').data_scale
                              ,pio_column_data => po_column_data);
    /*
    ||Flex Attribs.
    */
    lt_attr := get_network_attributes(pi_nt_type => pi_nt_type);
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      --
      lv_prompt := prompt_to_column_name(pi_prompt => lt_attr(i).ntc_prompt);
      IF lv_prompt IN('result_id','network_type','group_type','unique_','USRN','ESU ID','Street Name'
                     ,'description','admin_unit','start_date','end_date','length','ind','row_count')
       THEN
          lv_prompt := '__'||lv_prompt;
      END IF;
      --
      lv_flx_sql := awlrs_element_api.get_domain_sql_with_bind(pi_nt_type     => pi_nt_type
                                                              ,pi_column_name => lt_attr(i).ntc_column_name);
      --
      IF lv_flx_sql IS NOT NULL
       THEN
          --
          awlrs_element_api.gen_domain_sql(pi_nt_type     => pi_nt_type
                                          ,pi_column_name => lt_attr(i).ntc_column_name
                                          ,pi_bind_value  => REPLACE(nm3flx.extract_bind_variable(lv_flx_sql),':',NULL)
                                          ,pi_ordered     => FALSE
                                          ,po_sql         => lv_sql);
          lv_column := '(SELECT meaning FROM ('||lv_sql||') WHERE code = '||lt_attr(i).ntc_column_name||')';
          lv_type := awlrs_util.c_varchar2_col;
          --
      ELSE
          --
          lv_column := lt_attr(i).ntc_column_name;
          --
          CASE
            WHEN awlrs_util.is_date_in_varchar(pi_nt_type     => pi_nt_type
                                              ,pi_group_type  => NULL
                                              ,pi_column_name => lt_attr(i).ntc_column_name)
             THEN
                --
                lv_type := awlrs_util.c_date_in_varchar2_col;
                --
            ELSE
                --
                lv_type := lt_attr(i).ntc_column_type;
                --
          END CASE;
          --
      END IF;
      --
      awlrs_util.add_column_data(pi_cursor_col   => lv_prompt
                                ,pi_query_col    => lv_column
                                ,pi_datatype     => lv_type
                                ,pi_mask         => lt_attr(i).ntc_format
                                ,pio_column_data => po_column_data);
      --
    END LOOP;
    --
  END set_network_column_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_quick_search(pi_search_string    IN  VARCHAR2
                                    ,pi_nt_type          IN  nm_elements_all.ne_nt_type%TYPE
                                    ,pi_group_type       IN  nm_elements_all.ne_gty_group_type%TYPE
                                    ,pi_like_cols        IN  columns_tab
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                    ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                    ,pi_max_rows         IN  NUMBER DEFAULT NULL
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_row_restriction   nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    --
  BEGIN
    --
    g_domain_meaning_store.DELETE;
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_row_restriction := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_query := get_network_quick_search_sql(pi_nt_type          => pi_nt_type
                                            ,pi_like_cols        => pi_like_cols
                                            ,pi_include_enddated => pi_include_enddated
                                            ,pi_order_column     => lv_order_by)
                ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_max_rows       PLS_INTEGER := :max_rows;'
    ||CHR(10)||'  lv_nvl            VARCHAR2(10) := nm3type.get_nvl;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
                     ||':nt_type'
    ||CHR(10)||'       ,lv_nvl'
    ||CHR(10)||'       ,:group_type'
    ||CHR(10)||'       ,lv_nvl'
    ||CHR(10)||'       ,:like_string'
             ||CASE
                 WHEN pi_max_rows IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_max_rows'
                 ELSE
                     NULL
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_search_string
           ,pi_max_rows
           ,IN OUT po_cursor
           ,pi_nt_type
           ,pi_group_type
           ,lv_like_string;
    --
  END get_network_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_quick_search(pi_search_string    IN  VARCHAR2
                                          ,pi_nt_type          IN  nm_elements_all.ne_nt_type%TYPE
                                          ,pi_group_type       IN  nm_elements_all.ne_gty_group_type%TYPE
                                          ,pi_like_cols        IN  columns_tab
                                          ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                          ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                          ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                          ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                          ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                          ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                          ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                          ,pi_skip_n_rows      IN  PLS_INTEGER
                                          ,pi_pagesize         IN  PLS_INTEGER
                                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_cursor            sys_refcursor;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    IF NVL(pi_skip_n_rows,0) = 0
     THEN
        g_domain_meaning_store.DELETE;
    END IF;
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_network_column_data(pi_nt_type     => pi_nt_type
                               ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => ''
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_query := 'SELECT *'
     ||CHR(10)||'  FROM ('||get_network_quick_search_sql(pi_nt_type          => pi_nt_type
                                                        ,pi_like_cols        => pi_like_cols
                                                        ,pi_where_clause     => lv_filter
                                                        ,pi_include_enddated => pi_include_enddated
                                                        ,pi_order_column     => lv_order_by
                                                        ,pi_paged            => TRUE)||')'
              ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_lower_index    PLS_INTEGER := :lower_index;'
    ||CHR(10)||'  lv_upper_index    PLS_INTEGER := :upper_index;'
    ||CHR(10)||'  lv_nvl            VARCHAR2(10) := nm3type.get_nvl;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
                     ||':nt_type'
    ||CHR(10)||'       ,lv_nvl'
    ||CHR(10)||'       ,:group_type'
    ||CHR(10)||'       ,lv_nvl'
    ||CHR(10)||'       ,:like_string'
    ||CHR(10)||'       ,lv_lower_index'
             ||CASE
                 WHEN pi_pagesize IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_upper_index'
                 ELSE
                     NULL
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_search_string
           ,lv_lower_index
           ,lv_upper_index
           ,IN OUT po_cursor
           ,pi_nt_type
           ,pi_group_type
           ,lv_like_string;
    --
  END get_paged_network_quick_search;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_asset_quick_search_sql(pi_nit_rec          IN nm_inv_types_all%ROWTYPE
                                     ,pi_like_cols        IN columns_tab
                                     ,pi_where_clause     IN VARCHAR2 DEFAULT NULL
                                     ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                     ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                     ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_alias_list   nm3type.max_varchar2;
    lv_select_list  nm3type.max_varchar2;
    lv_pagecols     VARCHAR2(200);
    lv_like_cols    nm3type.max_varchar2;
    lv_match_cases  nm3type.max_varchar2;
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    get_asset_attributes_lists(pi_inv_type    => pi_nit_rec.nit_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_like_cols := lv_like_cols||CASE WHEN i > 1 THEN '||'' ''||' END||pi_like_cols(i);
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') = UPPER(:search_string) THEN '||i;
      --
    END LOOP;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') LIKE UPPER(:search_string||''%'') THEN '||TO_CHAR(pi_like_cols.COUNT + i);
      --
    END LOOP;
    --
    lv_match_cases := lv_match_cases||CHR(10)||'                          ELSE '||TO_CHAR((pi_like_cols.COUNT * 2) + 1);
    --
    IF pi_nit_rec.nit_table_name IS NOT NULL
     THEN
        --
        lv_retval :=  'WITH assets AS(SELECT '||pi_nit_rec.nit_foreign_pk_column||' "result_id"'
           ||CHR(10)||'                     ,'||pi_nit_rec.nit_foreign_pk_column||' "primary_key"'
                                              ||lv_select_list
           ||CHR(10)||'                     ,CASE'||lv_match_cases
           ||CHR(10)||'                      END "match_quality"'
           ||CHR(10)||'                 FROM '||pi_nit_rec.nit_table_name||' iit'
           ||CHR(10)||'                WHERE UPPER('||NVL(lv_like_cols,pi_nit_rec.nit_foreign_pk_column)||') LIKE :like_string'
           ||CHR(10)||'                  AND ('||NVL(pi_where_clause,'1=1')||')'
           ||CHR(10)||'                ORDER BY '||NVL(LOWER(pi_order_column),'"match_quality", "primary_key"'||CASE
                                                                                                                 WHEN pi_nit_rec.nit_table_name IS NULL
                                                                                                                  THEN
                                                                                                                      ', "description"'
                                                                                                                END)||')'
           ||CHR(10)||'SELECT '||lv_pagecols
                           ||'"result_id"'
           ||CHR(10)||'      ,"primary_key"'
                            ||lv_alias_list
           ||CHR(10)||'  FROM assets'
        ;
        --
    ELSE
        lv_retval :=  'WITH assets AS(SELECT iit_ne_id "result_id"'
           ||CHR(10)||'                     ,iit_primary_key "primary_key"'
           ||CHR(10)||'                     ,iit_descr "description"'
           ||CHR(10)||'                     ,nau_name "admin_unit"'
                    ||lv_select_list
           ||CHR(10)||'                     ,CASE'||lv_match_cases
           ||CHR(10)||'                      END "match_quality"'
           ||CHR(10)||'                 FROM nm_inv_items_all iit'
           ||CHR(10)||'                     ,nm_admin_units_all nau'
           ||CHR(10)||'                WHERE iit.iit_inv_type = :inv_type'
           ||CASE
               WHEN pi_include_enddated = 'N'
                THEN CHR(10)||'                  AND NVL(iit.iit_end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
             END
           ||CHR(10)||'                  AND ('||NVL(pi_where_clause,'1=1')||')'
           ||CHR(10)||'                  AND UPPER('||NVL(lv_like_cols,'iit.iit_primary_key||'' ''||iit.iit_descr')||') LIKE :like_string'
           ||CHR(10)||'                  AND iit.iit_admin_unit = nau.nau_admin_unit'
           ||CHR(10)||'                ORDER BY '||NVL(LOWER(pi_order_column),'"match_quality", "primary_key"'||CASE
                                                                                                                 WHEN pi_nit_rec.nit_table_name IS NULL
                                                                                                                  THEN
                                                                                                                     ', "description"'
                                                                                                                END)||')'
           ||CHR(10)||'SELECT '||lv_pagecols
                           ||'"result_id"'
           ||CHR(10)||'      ,"primary_key"'
           ||CHR(10)||'      ,"description"'
           ||CHR(10)||'      ,"admin_unit"'
                            ||lv_alias_list
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
  PROCEDURE set_asset_column_data(pi_nit_rec           IN     nm_inv_types_all%ROWTYPE
                                 ,pi_include_enddated  IN     VARCHAR2 DEFAULT 'N'
                                 ,po_column_data       IN OUT awlrs_util.column_data_tab)
    IS
    --
    lv_column   nm3type.max_varchar2;
    lv_prompt   nm_type_columns.ntc_prompt%TYPE;
    lv_type     VARCHAR2(10);
    lv_sql      nm3type.max_varchar2;
    lv_flx_sql  nm3type.max_varchar2;
    --
    CURSOR get_fixed_cols(cp_table_name  VARCHAR2
                         ,cp_pk_col      VARCHAR2)
        IS
    SELECT column_name
          ,data_type
          ,NVL(data_precision,data_length) data_length
          ,CASE WHEN data_scale = 0 THEN NULL ELSE data_scale END data_scale
     FROM user_tab_columns
     WHERE table_name IN(cp_table_name
                        ,'NM_ADMIN_UNITS_ALL')
       AND column_name IN(cp_pk_col
                         ,'IIT_PRIMARY_KEY'
                         ,'IIT_DESCR'
                         ,'IIT_X_SECT'
                         ,'IIT_START_DATE'
                         ,'IIT_END_DATE'
                         ,'NAU_NAME')
         ;
    --
    TYPE fixed_cols_tab IS TABLE OF get_fixed_cols%ROWTYPE;
    lt_fixed_cols  fixed_cols_tab;
    --
    lt_col_data  col_tab;
    --
    lt_attr  ita_tab;
    --
  BEGIN
    --
    OPEN  get_fixed_cols(NVL(pi_nit_rec.nit_table_name,'NM_INV_ITEMS_ALL')
                        ,NVL(pi_nit_rec.nit_foreign_pk_column,'IIT_NE_ID'));
    FETCH get_fixed_cols
     BULK COLLECT
     INTO lt_fixed_cols;
    CLOSE get_fixed_cols;
    --
    FOR i IN 1..lt_fixed_cols.COUNT LOOP
      --
      lt_col_data(lt_fixed_cols(i).column_name).data_type := lt_fixed_cols(i).data_type;
      lt_col_data(lt_fixed_cols(i).column_name).data_length := lt_fixed_cols(i).data_length;
      lt_col_data(lt_fixed_cols(i).column_name).data_scale := lt_fixed_cols(i).data_scale;
      --
    END LOOP;
    --
    IF pi_nit_rec.nit_table_name IS NOT NULL
     THEN
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'result_id'
                                  ,pi_query_col      => pi_nit_rec.nit_foreign_pk_column
                                  ,pi_datatype       => lt_col_data(pi_nit_rec.nit_foreign_pk_column).data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data(pi_nit_rec.nit_foreign_pk_column).data_length
                                  ,pi_decimal_places => lt_col_data(pi_nit_rec.nit_foreign_pk_column).data_scale
                                  ,pio_column_data   => po_column_data);
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'primary_key'
                                  ,pi_query_col      => pi_nit_rec.nit_foreign_pk_column
                                  ,pi_datatype       => lt_col_data(pi_nit_rec.nit_foreign_pk_column).data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data(pi_nit_rec.nit_foreign_pk_column).data_length
                                  ,pi_decimal_places => lt_col_data(pi_nit_rec.nit_foreign_pk_column).data_scale
                                  ,pio_column_data   => po_column_data);
        --
    ELSE
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'result_id'
                                  ,pi_query_col      => 'iit_ne_id'
                                  ,pi_datatype       => lt_col_data('IIT_NE_ID').data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data('IIT_NE_ID').data_length
                                  ,pi_decimal_places => lt_col_data('IIT_NE_ID').data_scale
                                  ,pio_column_data   => po_column_data);
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'primary_key'
                                  ,pi_query_col      => 'iit_primary_key'
                                  ,pi_datatype       => lt_col_data('IIT_PRIMARY_KEY').data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data('IIT_PRIMARY_KEY').data_length
                                  ,pi_decimal_places => lt_col_data('IIT_PRIMARY_KEY').data_scale
                                  ,pio_column_data   => po_column_data);
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'description'
                                  ,pi_query_col      => 'iit_descr'
                                  ,pi_datatype       => lt_col_data('IIT_DESCR').data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data('IIT_DESCR').data_length
                                  ,pi_decimal_places => lt_col_data('IIT_DESCR').data_scale
                                  ,pio_column_data   => po_column_data);
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'admin_unit'
                                  ,pi_query_col      => 'nau_name'
                                  ,pi_datatype       => lt_col_data('NAU_NAME').data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data('NAU_NAME').data_length
                                  ,pi_decimal_places => lt_col_data('NAU_NAME').data_scale
                                  ,pio_column_data   => po_column_data);
        --
        IF pi_nit_rec.nit_x_sect_allow_flag = 'Y'
         THEN
            --
            awlrs_util.add_column_data(pi_cursor_col     => 'xsp'
                                      ,pi_query_col      => 'iit_x_sect'
                                      ,pi_datatype       => lt_col_data('IIT_X_SECT').data_type
                                      ,pi_mask           => NULL
                                      ,pi_field_length   => lt_col_data('IIT_X_SECT').data_length
                                      ,pi_decimal_places => lt_col_data('IIT_X_SECT').data_scale
                                      ,pio_column_data   => po_column_data);
            --
        END IF;
        --
        awlrs_util.add_column_data(pi_cursor_col     => 'start_date'
                                  ,pi_query_col      => 'iit_start_date'
                                  ,pi_datatype       => lt_col_data('IIT_START_DATE').data_type
                                  ,pi_mask           => NULL
                                  ,pi_field_length   => lt_col_data('IIT_START_DATE').data_length
                                  ,pi_decimal_places => lt_col_data('IIT_START_DATE').data_scale
                                  ,pio_column_data   => po_column_data);
        --
        IF pi_include_enddated = 'Y'
         THEN
            --
            awlrs_util.add_column_data(pi_cursor_col     => 'end_date'
                                      ,pi_query_col      => 'iit_end_date'
                                      ,pi_datatype       => lt_col_data('IIT_END_DATE').data_type
                                      ,pi_mask           => NULL
                                      ,pi_field_length   => lt_col_data('IIT_END_DATE').data_length
                                      ,pi_decimal_places => lt_col_data('IIT_END_DATE').data_scale
                                      ,pio_column_data   => po_column_data);
            --
        END IF;
        --
    END IF;
    /*
    ||Flex Attribs.
    */
    lt_attr := get_asset_attributes(pi_inv_type => pi_nit_rec.nit_inv_type);
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      --
      lv_prompt := prompt_to_column_name(pi_prompt => lt_attr(i).ita_scrn_text);
      IF lv_prompt IN('result_id','primary_key','description','xsp','admin_unit'
                     ,'start_date','end_date','ind','row_count')
       THEN
          lv_prompt := '__'||lv_prompt;
      END IF;
      --
      IF lt_attr(i).ita_id_domain IS NOT NULL
       THEN
          --
          lv_column := '(SELECT ial_meaning FROM nm_inv_attri_lookup WHERE ial_domain = '||nm3flx.string(lt_attr(i).ita_id_domain)||' AND ial_value = iit.'||LOWER(lt_attr(i).ita_attrib_name)||')';
          lv_type := awlrs_util.c_varchar2_col;
          --
      ELSE
          --
          lv_column := lt_attr(i).ita_attrib_name;
          lv_type   := lt_attr(i).ita_format;
          IF lv_type = awlrs_util.c_date_col
           THEN
              /*
              ||Check whether the date is being stored in a VARCHAR2 column.
              */
              IF awlrs_util.is_date_in_varchar(pi_inv_type    => pi_nit_rec.nit_inv_type
                                              ,pi_attrib_name => lv_column)
               THEN
                  lv_type := awlrs_util.c_date_in_varchar2_col;
              END IF;
              --
          END IF;
          --
      END IF;
      --
      awlrs_util.add_column_data(pi_cursor_col     => lv_prompt
                                ,pi_query_col      => lv_column
                                ,pi_datatype       => lv_type
                                ,pi_mask           => lt_attr(i).ita_format_mask
                                ,pi_field_length   => lt_attr(i).ita_fld_length
                                ,pi_decimal_places => lt_attr(i).ita_dec_places
                                ,pio_column_data   => po_column_data);
      --
    END LOOP;
    --
  END set_asset_column_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_assets_quick_search(pi_search_string    IN  VARCHAR2
                                   ,pi_nit_rec          IN  nm_inv_types_all%ROWTYPE
                                   ,pi_like_cols        IN  columns_tab
                                   ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                   ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                   ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                   ,pi_max_rows         IN  NUMBER DEFAULT NULL
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_row_restriction   nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_row_restriction := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_query := get_asset_quick_search_sql(pi_nit_rec          => pi_nit_rec
                                          ,pi_like_cols        => pi_like_cols
                                          ,pi_include_enddated => pi_include_enddated
                                          ,pi_order_column     => lv_order_by)
                ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_inv_type       nm_inv_types_all.nit_inv_type%TYPE := :inv_type;'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_max_rows       PLS_INTEGER := :max_rows;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
             ||CASE
                 WHEN pi_nit_rec.nit_table_name IS NOT NULL
                  THEN
                     ':like_string'
                 ELSE
                     'lv_inv_type'
                     ||CHR(10)||'       ,:like_string'
               END
             ||CASE
                 WHEN pi_max_rows IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_max_rows'
                 ELSE
                     NULL
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING pi_nit_rec.nit_inv_type
           ,lv_query
           ,lv_search_string
           ,pi_max_rows
           ,IN OUT po_cursor
           ,lv_like_string;
    --
  END get_assets_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_assets_quick_search(pi_search_string    IN  VARCHAR2
                                         ,pi_nit_rec          IN  nm_inv_types_all%ROWTYPE
                                         ,pi_like_cols        IN  columns_tab
                                         ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                         ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                         ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                         ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                         ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                         ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                         ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                         ,pi_skip_n_rows      IN  PLS_INTEGER
                                         ,pi_pagesize         IN  PLS_INTEGER
                                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_asset_column_data(pi_nit_rec          => pi_nit_rec
                             ,pi_include_enddated => pi_include_enddated
                             ,po_column_data      => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => ''
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_query := 'SELECT *'
     ||CHR(10)||'  FROM ('||get_asset_quick_search_sql(pi_nit_rec          => pi_nit_rec
                                                      ,pi_like_cols        => pi_like_cols
                                                      ,pi_where_clause     => lv_filter
                                                      ,pi_include_enddated => pi_include_enddated
                                                      ,pi_order_column     => lv_order_by
                                                      ,pi_paged            => TRUE)||')'
              ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_inv_type       nm_inv_types_all.nit_inv_type%TYPE := :inv_type;'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_lower_index    PLS_INTEGER := :lower_index;'
    ||CHR(10)||'  lv_upper_index    PLS_INTEGER := :upper_index;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
             ||CASE
                 WHEN pi_nit_rec.nit_table_name IS NOT NULL
                  THEN
                     ':like_string'
                 ELSE
                     'lv_inv_type'
                     ||CHR(10)||'       ,:like_string'
               END
    ||CHR(10)||'       ,lv_lower_index'
             ||CASE
                 WHEN pi_pagesize IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_upper_index'
                 ELSE
                     NULL
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING pi_nit_rec.nit_inv_type
           ,lv_query
           ,lv_search_string
           ,lv_lower_index
           ,lv_upper_index
           ,IN OUT po_cursor
           ,lv_like_string;
    --
  END get_paged_assets_quick_search;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_node_quick_search_sql(pi_feature_table    IN VARCHAR2
                                    ,pi_like_cols        IN columns_tab
                                    ,pi_where_clause     IN VARCHAR2 DEFAULT NULL
                                    ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                    ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_pagecols     VARCHAR2(200);
    lv_like_cols    nm3type.max_varchar2;
    lv_match_cases  nm3type.max_varchar2;
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_like_cols := lv_like_cols||CASE WHEN i > 1 THEN '||'' ''||' END||pi_like_cols(i);
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') = UPPER(:search_string) THEN '||i;
      --
    END LOOP;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') LIKE UPPER(:search_string||''%'') THEN '||TO_CHAR(pi_like_cols.COUNT + i);
      --
    END LOOP;
    --
    lv_match_cases := lv_match_cases||CHR(10)||'                          ELSE '||TO_CHAR((pi_like_cols.COUNT * 2) + 1);
    --
    lv_retval :=  'SELECT '||lv_pagecols
                           ||'"result_id"'
       ||CHR(10)||'      ,"name"'
       ||CHR(10)||'      ,"description"'
       ||CHR(10)||'      ,"purpose"'
       ||CHR(10)||'      ,"start_date"'
       ||CHR(10)||'      ,"end_date"'
       ||CHR(10)||'      ,"node_type"'
       ||CHR(10)||'      ,"date_created"'
       ||CHR(10)||'      ,"created_by"'
       ||CHR(10)||'      ,"date_modified"'
       ||CHR(10)||'      ,"modified_by"'
       ||CHR(10)||'      ,"node_id"'
       ||CHR(10)||'      ,"point_id"'
       ||CHR(10)||'      ,"point_location_id"'
       ||CHR(10)||'  FROM (SELECT npl_id "result_id"'
       ||CHR(10)||'              ,no_node_name "name"'
       ||CHR(10)||'              ,no_descr "description"'
       ||CHR(10)||'              ,no_purpose "purpose"'
       ||CHR(10)||'              ,no_start_date "start_date"'
       ||CHR(10)||'              ,no_end_date "end_date"'
       ||CHR(10)||'              ,no_node_type "node_type"'
       ||CHR(10)||'              ,no_date_created "date_created"'
       ||CHR(10)||'              ,no_created_by "created_by"'
       ||CHR(10)||'              ,no_date_modified "date_modified"'
       ||CHR(10)||'              ,no_modified_by "modified_by"'
       ||CHR(10)||'              ,no_node_id "node_id"'
       ||CHR(10)||'              ,no_np_id "point_id"'
       ||CHR(10)||'              ,npl_id "point_location_id"'
       ||CHR(10)||'              ,CASE'||lv_match_cases
       ||CHR(10)||'               END "match_quality"'
       ||CHR(10)||'          FROM '||pi_feature_table
       ||CHR(10)||'         WHERE UPPER('||NVL(lv_like_cols,'no_node_name||'' ''||no_descr')||') LIKE :like_string'
       ||CASE
           WHEN pi_include_enddated = 'N'
            THEN CHR(10)||'           AND NVL(no_end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
         END
       ||CHR(10)||'           AND ('||NVL(pi_where_clause,'1=1')||')'
       ||CHR(10)||'         ORDER BY '||NVL(LOWER(pi_order_column),'"match_quality", "name"')||')'
    ;
    --
    RETURN lv_retval;
    --
  END get_node_quick_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_node_column_data(pi_feature_table IN VARCHAR2
                                ,po_column_data   IN OUT awlrs_util.column_data_tab)
    IS
    --
    CURSOR get_fixed_cols(cp_feature_table  VARCHAR2)
        IS
    SELECT column_name
          ,data_type
          ,NVL(data_precision,data_length) data_length
          ,CASE WHEN data_scale = 0 THEN NULL ELSE data_scale END data_scale
     FROM user_tab_columns
     WHERE table_name = cp_feature_table
       AND column_name IN('NPL_ID'
                         ,'NO_NODE_NAME'
                         ,'NO_DESCR'
                         ,'NO_PURPOSE'
                         ,'NO_START_DATE'
                         ,'NO_END_DATE'
                         ,'NO_NODE_TYPE'
                         ,'NO_DATE_CREATED'
                         ,'NO_CREATED_BY'
                         ,'NO_DATE_MODIFIED'
                         ,'NO_MODIFIED_BY'
                         ,'NO_NODE_ID'
                         ,'NO_NP_ID')
         ;
    --
    TYPE fixed_cols_tab IS TABLE OF get_fixed_cols%ROWTYPE;
    lt_fixed_cols  fixed_cols_tab;
    --
    lt_col_data  col_tab;
    --
  BEGIN
    --
    OPEN  get_fixed_cols(pi_feature_table);
    FETCH get_fixed_cols
     BULK COLLECT
     INTO lt_fixed_cols;
    CLOSE get_fixed_cols;
    --
    FOR i IN 1..lt_fixed_cols.COUNT LOOP
      --
      lt_col_data(lt_fixed_cols(i).column_name).data_type := lt_fixed_cols(i).data_type;
      lt_col_data(lt_fixed_cols(i).column_name).data_length := lt_fixed_cols(i).data_length;
      lt_col_data(lt_fixed_cols(i).column_name).data_scale := lt_fixed_cols(i).data_scale;
      --
    END LOOP;
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'result_id'
                              ,pi_query_col      => 'npl_id'
                              ,pi_datatype       => lt_col_data('NPL_ID').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NPL_ID').data_length
                              ,pi_decimal_places => lt_col_data('NPL_ID').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'name'
                              ,pi_query_col      => 'no_node_name'
                              ,pi_datatype       => lt_col_data('NO_NODE_NAME').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_NODE_NAME').data_length
                              ,pi_decimal_places => lt_col_data('NO_NODE_NAME').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'description'
                              ,pi_query_col      => 'no_descr'
                              ,pi_datatype       => lt_col_data('NO_DESCR').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_DESCR').data_length
                              ,pi_decimal_places => lt_col_data('NO_DESCR').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'purpose'
                              ,pi_query_col      => 'no_purpose'
                              ,pi_datatype       => lt_col_data('NO_PURPOSE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_PURPOSE').data_length
                              ,pi_decimal_places => lt_col_data('NO_PURPOSE').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'start_date'
                              ,pi_query_col      => 'no_start_date'
                              ,pi_datatype       => lt_col_data('NO_START_DATE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_START_DATE').data_length
                              ,pi_decimal_places => lt_col_data('NO_START_DATE').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col     => 'end_date'
                              ,pi_query_col      => 'no_end_date'
                              ,pi_datatype       => lt_col_data('NO_END_DATE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_END_DATE').data_length
                              ,pi_decimal_places => lt_col_data('NO_END_DATE').data_scale
                              ,pio_column_data   => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'node_type'
                              ,pi_query_col    => 'no_node_type'
                              ,pi_datatype       => lt_col_data('NO_NODE_TYPE').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_NODE_TYPE').data_length
                              ,pi_decimal_places => lt_col_data('NO_NODE_TYPE').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'date_created'
                              ,pi_query_col    => 'no_date_created'
                              ,pi_datatype       => lt_col_data('NO_DATE_CREATED').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_DATE_CREATED').data_length
                              ,pi_decimal_places => lt_col_data('NO_DATE_CREATED').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'created_by'
                              ,pi_query_col    => 'no_created_by'
                              ,pi_datatype       => lt_col_data('NO_CREATED_BY').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_CREATED_BY').data_length
                              ,pi_decimal_places => lt_col_data('NO_CREATED_BY').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'date_modified'
                              ,pi_query_col    => 'no_date_modified'
                              ,pi_datatype       => lt_col_data('NO_DATE_MODIFIED').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_DATE_MODIFIED').data_length
                              ,pi_decimal_places => lt_col_data('NO_DATE_MODIFIED').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'modified_by'
                              ,pi_query_col    => 'no_modified_by'
                              ,pi_datatype       => lt_col_data('NO_MODIFIED_BY').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_MODIFIED_BY').data_length
                              ,pi_decimal_places => lt_col_data('NO_MODIFIED_BY').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'node_id'
                              ,pi_query_col    => 'no_node_id'
                              ,pi_datatype       => lt_col_data('NO_NODE_ID').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_NODE_ID').data_length
                              ,pi_decimal_places => lt_col_data('NO_NODE_ID').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'point_id'
                              ,pi_query_col    => 'no_np_id'
                              ,pi_datatype       => lt_col_data('NO_NP_ID').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NO_NP_ID').data_length
                              ,pi_decimal_places => lt_col_data('NO_NP_ID').data_scale
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'point_location_id'
                              ,pi_query_col    => 'npl_id'
                              ,pi_datatype       => lt_col_data('NPL_ID').data_type
                              ,pi_mask           => NULL
                              ,pi_field_length   => lt_col_data('NPL_ID').data_length
                              ,pi_decimal_places => lt_col_data('NPL_ID').data_scale
                              ,pio_column_data => po_column_data);
    --
  END set_node_column_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nodes_quick_search(pi_search_string    IN  VARCHAR2
                                  ,pi_feature_table    IN  VARCHAR2
                                  ,pi_like_cols        IN  columns_tab
                                  ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                  ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                                  ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                                  ,pi_max_rows         IN  NUMBER DEFAULT NULL
                                  ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_row_restriction   nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_row_restriction := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_query := get_node_quick_search_sql(pi_feature_table    => pi_feature_table
                                         ,pi_like_cols        => pi_like_cols
                                         ,pi_include_enddated => pi_include_enddated
                                         ,pi_order_column     => lv_order_by)
                ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_max_rows       PLS_INTEGER := :max_rows;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
             ||':like_string'
             ||CASE
                 WHEN pi_max_rows IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_max_rows'
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_search_string
           ,pi_max_rows
           ,IN OUT po_cursor
           ,lv_like_string;
    --
  END get_nodes_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nodes_quick_search(pi_search_string    IN  VARCHAR2
                                        ,pi_feature_table    IN  VARCHAR2
                                        ,pi_like_cols        IN  columns_tab
                                        ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                        ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                        ,pi_skip_n_rows      IN  PLS_INTEGER
                                        ,pi_pagesize         IN  PLS_INTEGER
                                        ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_node_column_data(pi_feature_table => pi_feature_table
                            ,po_column_data   => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => ''
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_query := 'SELECT *'
     ||CHR(10)||'  FROM ('||get_node_quick_search_sql(pi_feature_table    => pi_feature_table
                                                     ,pi_like_cols        => pi_like_cols
                                                     ,pi_where_clause     => lv_filter
                                                     ,pi_include_enddated => pi_include_enddated
                                                     ,pi_order_column     => lv_order_by
                                                     ,pi_paged            => TRUE)||')'
              ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_lower_index    PLS_INTEGER := :lower_index;'
    ||CHR(10)||'  lv_upper_index    PLS_INTEGER := :upper_index;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
             ||':like_string'
    ||CHR(10)||'       ,lv_lower_index'
             ||CASE
                 WHEN pi_pagesize IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_upper_index'
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_search_string
           ,lv_lower_index
           ,lv_upper_index
           ,IN OUT po_cursor
           ,lv_like_string;
    --
  END get_paged_nodes_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_table_quick_search_sql(pi_feature_table     IN VARCHAR2
                                     ,pi_feature_pk_column IN VARCHAR2
                                     ,pi_like_cols         IN columns_tab
                                     ,pi_where_clause      IN VARCHAR2 DEFAULT NULL
                                     ,pi_order_column      IN VARCHAR2 DEFAULT NULL
                                     ,pi_paged             IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_alias_list   nm3type.max_varchar2;
    lv_select_list  nm3type.max_varchar2;
    lv_pagecols     VARCHAR2(200);
    lv_like_cols    nm3type.max_varchar2;
    lv_match_cases  nm3type.max_varchar2;
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    get_table_attributes_lists(pi_feature_table => pi_feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_like_cols := lv_like_cols||CASE WHEN i > 1 THEN '||'' ''||' END||pi_like_cols(i);
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') = UPPER(:search_string) THEN '||i;
      --
    END LOOP;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_match_cases := lv_match_cases||CHR(10)||'                          WHEN UPPER('||pi_like_cols(i)||') LIKE UPPER(:search_string||''%'') THEN '||TO_CHAR(pi_like_cols.COUNT + i);
      --
    END LOOP;
    --
    lv_match_cases := lv_match_cases||CHR(10)||'                          ELSE '||TO_CHAR((pi_like_cols.COUNT * 2) + 1);
    --
    lv_retval := 'WITH records AS(SELECT '||pi_feature_pk_column||' "result_id"'
               ||lv_select_list
      ||CHR(10)||'                       ,CASE'||lv_match_cases
      ||CHR(10)||'                        END "match_quality"'
      ||CHR(10)||'                   FROM '||pi_feature_table
      ||CHR(10)||'                  WHERE UPPER('||NVL(lv_like_cols,pi_feature_pk_column)||') LIKE :like_string'
      ||CHR(10)||'                    AND ('||NVL(pi_where_clause,'1=1')||')'
      ||CHR(10)||'                  ORDER BY '||NVL(LOWER(pi_order_column),'"match_quality", "'||pi_feature_pk_column||'"')||')'
      ||CHR(10)||'SELECT '||lv_pagecols
               ||'"result_id"'
               ||lv_alias_list
      ||CHR(10)||'  FROM records'
    ;
    --
    RETURN lv_retval;
    --
  END get_table_quick_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_table_column_data(pi_table_name  IN     VARCHAR2
                                 ,pi_pk_column   IN     VARCHAR2
                                 ,po_column_data IN OUT awlrs_util.column_data_tab)
    IS
    --
    CURSOR get_attr(cp_table_name IN all_tab_columns.table_name%TYPE
                   ,cp_pk_col     IN all_tab_columns.column_name%TYPE)
        IS
    SELECT LOWER(column_name) column_name
          ,data_type
          ,NVL(data_precision,data_length) data_length
          ,CASE WHEN data_scale = 0 THEN NULL ELSE data_scale END data_scale
          ,CASE WHEN column_name = cp_pk_col THEN 1 ELSE 2 END pk_ind
      FROM all_tab_columns
     WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
       AND table_name = cp_table_name
       AND data_type IN('VARCHAR2','NUMBER','DATE')
     ORDER
        BY pk_ind
          ,column_id
         ;
    --
    TYPE attr_rec IS TABLE OF get_attr%ROWTYPE;
    lt_attr  attr_rec;
    --
  BEGIN
    --
    OPEN  get_attr(pi_table_name
                  ,pi_pk_column);
    FETCH get_attr
     BULK COLLECT
     INTO lt_attr;
    CLOSE get_attr;
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      --
      IF lt_attr(i).pk_ind = 1
       THEN
          awlrs_util.add_column_data(pi_cursor_col     => 'result_id'
                                    ,pi_query_col      => lt_attr(i).column_name
                                    ,pi_datatype       => lt_attr(i).data_type
                                    ,pi_mask           => NULL
                                    ,pi_field_length   => lt_attr(i).data_length
                                    ,pi_decimal_places => lt_attr(i).data_scale
                                    ,pio_column_data   => po_column_data);
      END IF;
      --
      awlrs_util.add_column_data(pi_cursor_col     => lt_attr(i).column_name
                                ,pi_query_col      => NULL
                                ,pi_datatype       => lt_attr(i).data_type
                                ,pi_mask           => NULL
                                ,pi_field_length   => lt_attr(i).data_length
                                ,pi_decimal_places => lt_attr(i).data_scale
                                ,pio_column_data   => po_column_data);
      --
    END LOOP;
    --
  END set_table_column_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_quick_search(pi_search_string     IN  VARCHAR2
                                  ,pi_feature_table     IN  VARCHAR2
                                  ,pi_feature_pk_column IN  VARCHAR2
                                  ,pi_like_cols         IN  columns_tab
                                  ,pi_order_column      IN  VARCHAR2 DEFAULT NULL
                                  ,pi_order_asc_desc    IN  VARCHAR2 DEFAULT NULL
                                  ,pi_max_rows          IN  NUMBER DEFAULT NULL
                                  ,po_cursor            OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_row_restriction  nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_row_restriction := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_query := get_table_quick_search_sql(pi_feature_table     => pi_feature_table
                                          ,pi_feature_pk_column => pi_feature_pk_column
                                          ,pi_like_cols         => pi_like_cols
                                          ,pi_order_column      => lv_order_by)
                ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_max_rows       PLS_INTEGER := :max_rows;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
             ||':like_string'
             ||CASE
                 WHEN pi_max_rows IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_max_rows'
                 ELSE
                     NULL
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_search_string
           ,pi_max_rows
           ,IN OUT po_cursor
           ,lv_like_string;
    --
  END get_table_quick_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_table_quick_search(pi_search_string     IN  VARCHAR2
                                        ,pi_feature_table     IN  VARCHAR2
                                        ,pi_feature_pk_column IN  VARCHAR2
                                        ,pi_like_cols         IN  columns_tab
                                        ,pi_filter_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_operators  IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_values_1   IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_filter_values_2   IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_order_columns     IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_order_asc_desc    IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                        ,pi_skip_n_rows       IN  PLS_INTEGER
                                        ,pi_pagesize          IN  PLS_INTEGER
                                        ,po_cursor            OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_using             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    lv_search_string     nm3type.max_varchar2;
    lv_like_string       nm3type.max_varchar2;
    lv_cursor            sys_refcursor;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    lv_search_string := UPPER(pi_search_string);
    lv_like_string := '%'||lv_search_string||'%';
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_table_column_data(pi_table_name  => pi_feature_table
                             ,pi_pk_column   => pi_feature_pk_column
                             ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => ''
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_query := 'SELECT *'
     ||CHR(10)||'  FROM ('||get_table_quick_search_sql(pi_feature_table     => pi_feature_table
                                                      ,pi_feature_pk_column => pi_feature_pk_column
                                                      ,pi_like_cols         => pi_like_cols
                                                      ,pi_where_clause      => lv_filter
                                                      ,pi_order_column      => lv_order_by
                                                      ,pi_paged             => TRUE)||')'
              ||lv_row_restriction
    ;
    --
    FOR i IN 1..pi_like_cols.COUNT LOOP
      --
      lv_using := lv_using||'lv_search_string'
         ||CHR(10)||'       ,lv_search_string'
         ||CHR(10)||'       ,'
      ;
      --
    END LOOP;
    --
    lv_sql :=  'DECLARE'
    ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
    ||CHR(10)||'  lv_search_string  nm3type.max_varchar2 := :search_string;'
    ||CHR(10)||'  lv_lower_index    PLS_INTEGER := :lower_index;'
    ||CHR(10)||'  lv_upper_index    PLS_INTEGER := :upper_index;'
    ||CHR(10)||'BEGIN'
    ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
    ||CHR(10)||'  USING '||lv_using
             ||':like_string'
    ||CHR(10)||'       ,lv_lower_index'
             ||CASE
                 WHEN pi_pagesize IS NOT NULL
                  THEN
                     CHR(10)||'       ,lv_upper_index'
                 ELSE
                     NULL
               END
    ||CHR(10)||'  ;'
    ||CHR(10)||'END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_search_string
           ,lv_lower_index
           ,lv_upper_index
           ,IN OUT lv_cursor
           ,lv_like_string;
    --
    po_cursor := lv_cursor;
    --
  END get_paged_table_quick_search;

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
    lt_like_cols    columns_tab;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
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
        --
        lt_like_cols := get_theme_quick_search_cols(pi_theme_name => pi_theme_name);
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              IF lt_like_cols.COUNT = 0
               THEN
                  lt_like_cols(1) := 'ne_unique';
                  lt_like_cols(2) := 'ne_descr';
              END IF;
              --
              get_network_quick_search(pi_search_string    => pi_search_string
                                      ,pi_nt_type          => lt_theme_types(1).network_type
                                      ,pi_group_type       => lt_theme_types(1).network_group_type
                                      ,pi_like_cols        => lt_like_cols
                                      ,pi_include_enddated => pi_include_enddated
                                      ,pi_order_column     => pi_order_column
                                      ,pi_order_asc_desc   => pi_order_asc_desc
                                      ,pi_max_rows         => pi_max_rows
                                      ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              lr_nit := nm3get.get_nit(lt_theme_types(1).asset_type);
              --
              IF lt_like_cols.COUNT = 0
               THEN
                  IF lr_nit.nit_table_name IS NOT NULL
                   THEN
                      lt_like_cols(1) := lr_nit.nit_foreign_pk_column;
                  ELSE
                      lt_like_cols(1) := 'iit_primary_key';
                      lt_like_cols(2) := 'iit_descr';
                  END IF;
              END IF;
              --
              get_assets_quick_search(pi_search_string    => pi_search_string
                                     ,pi_nit_rec          => lr_nit
                                     ,pi_like_cols        => lt_like_cols
                                     ,pi_include_enddated => pi_include_enddated
                                     ,pi_order_column     => pi_order_column
                                     ,pi_order_asc_desc   => pi_order_asc_desc
                                     ,pi_max_rows         => pi_max_rows
                                     ,po_cursor           => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  IF lt_like_cols.COUNT = 0
                   THEN
                      lt_like_cols(1) := 'no_node_name';
                      lt_like_cols(2) := 'no_descr';
                  END IF;
                  --
                  get_nodes_quick_search(pi_search_string    => pi_search_string
                                        ,pi_feature_table    => lt_theme_types(1).feature_table
                                        ,pi_like_cols        => lt_like_cols
                                        ,pi_include_enddated => pi_include_enddated
                                        ,pi_order_column     => pi_order_column
                                        ,pi_order_asc_desc   => pi_order_asc_desc
                                        ,pi_max_rows         => pi_max_rows
                                        ,po_cursor           => po_cursor);
                  --
              ELSE
                  --
                  IF lt_like_cols.COUNT = 0
                   THEN
                      lt_like_cols(1) := lt_theme_types(1).feature_pk_column;
                  END IF;
                  --
                  get_table_quick_search(pi_search_string     => pi_search_string
                                        ,pi_feature_table     => lt_theme_types(1).feature_table
                                        ,pi_feature_pk_column => lt_theme_types(1).feature_pk_column
                                        ,pi_like_cols         => lt_like_cols
                                        ,pi_order_column      => pi_order_column
                                        ,pi_order_asc_desc    => pi_order_asc_desc
                                        ,pi_max_rows          => pi_max_rows
                                        ,po_cursor            => po_cursor);
                  --
              END IF;
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
                                          ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                          ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                          ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                          ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                          ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                          ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
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
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lt_like_cols    columns_tab;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
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
        --
        lt_like_cols := get_theme_quick_search_cols(pi_theme_name => pi_theme_name);
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              IF lt_like_cols.COUNT = 0
               THEN
                  lt_like_cols(1) := 'ne_unique';
                  lt_like_cols(2) := 'ne_descr';
              END IF;
              --
              get_paged_network_quick_search(pi_search_string    => pi_search_string
                                            ,pi_nt_type          => lt_theme_types(1).network_type
                                            ,pi_group_type       => lt_theme_types(1).network_group_type
                                            ,pi_like_cols        => lt_like_cols
                                            ,pi_include_enddated => pi_include_enddated
                                            ,pi_filter_columns   => pi_filter_columns
                                            ,pi_filter_operators => pi_filter_operators
                                            ,pi_filter_values_1  => pi_filter_values_1
                                            ,pi_filter_values_2  => pi_filter_values_2
                                            ,pi_order_columns    => pi_order_columns
                                            ,pi_order_asc_desc   => pi_order_asc_desc
                                            ,pi_skip_n_rows      => pi_skip_n_rows
                                            ,pi_pagesize         => pi_pagesize
                                            ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              lr_nit := nm3get.get_nit(lt_theme_types(1).asset_type);
              --
              IF lt_like_cols.COUNT = 0
               THEN
                  IF lr_nit.nit_table_name IS NOT NULL
                   THEN
                      lt_like_cols(1) := lr_nit.nit_foreign_pk_column;
                  ELSE
                      lt_like_cols(1) := 'iit_primary_key';
                      lt_like_cols(2) := 'iit_descr';
                  END IF;
              END IF;
              --
              get_paged_assets_quick_search(pi_search_string    => pi_search_string
                                           ,pi_nit_rec          => lr_nit
                                           ,pi_like_cols        => lt_like_cols
                                           ,pi_include_enddated => pi_include_enddated
                                           ,pi_filter_columns   => pi_filter_columns
                                           ,pi_filter_operators => pi_filter_operators
                                           ,pi_filter_values_1  => pi_filter_values_1
                                           ,pi_filter_values_2  => pi_filter_values_2
                                           ,pi_order_columns    => pi_order_columns
                                           ,pi_order_asc_desc   => pi_order_asc_desc
                                           ,pi_skip_n_rows      => pi_skip_n_rows
                                           ,pi_pagesize         => pi_pagesize
                                           ,po_cursor           => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  IF lt_like_cols.COUNT = 0
                   THEN
                      lt_like_cols(1) := 'no_node_name';
                      lt_like_cols(2) := 'no_descr';
                  END IF;
                  --
                  get_paged_nodes_quick_search(pi_search_string    => pi_search_string
                                              ,pi_feature_table    => lt_theme_types(1).feature_table
                                              ,pi_like_cols        => lt_like_cols
                                              ,pi_include_enddated => pi_include_enddated
                                              ,pi_filter_columns   => pi_filter_columns
                                              ,pi_filter_operators => pi_filter_operators
                                              ,pi_filter_values_1  => pi_filter_values_1
                                              ,pi_filter_values_2  => pi_filter_values_2
                                              ,pi_order_columns    => pi_order_columns
                                              ,pi_order_asc_desc   => pi_order_asc_desc
                                              ,pi_skip_n_rows      => pi_skip_n_rows
                                              ,pi_pagesize         => pi_pagesize
                                              ,po_cursor           => po_cursor);
                  --
              ELSE
                  --
                  IF lt_like_cols.COUNT = 0
                   THEN
                      lt_like_cols(1) := lt_theme_types(1).feature_pk_column;
                  END IF;
                  --
                  get_paged_table_quick_search(pi_search_string     => pi_search_string
                                              ,pi_feature_table     => lt_theme_types(1).feature_table
                                              ,pi_feature_pk_column => lt_theme_types(1).feature_pk_column
                                              ,pi_like_cols         => lt_like_cols
                                              ,pi_filter_columns    => pi_filter_columns
                                              ,pi_filter_operators  => pi_filter_operators
                                              ,pi_filter_values_1   => pi_filter_values_1
                                              ,pi_filter_values_2   => pi_filter_values_2
                                              ,pi_order_columns     => pi_order_columns
                                              ,pi_order_asc_desc    => pi_order_asc_desc
                                              ,pi_skip_n_rows       => pi_skip_n_rows
                                              ,pi_pagesize          => pi_pagesize
                                              ,po_cursor            => po_cursor);
                  --
              END IF;
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
  FUNCTION get_network_search_sql(pi_nt_type          IN nm_types.nt_type%TYPE
                                 ,pi_where_clause     IN VARCHAR2
                                 ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                                 ,pi_order_column     IN VARCHAR2 DEFAULT NULL
                                 ,pi_paged            IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_pagecols     VARCHAR2(200);
    lv_retval       nm3type.max_varchar2;
    lv_alias_list   nm3type.max_varchar2;
    lv_select_list  nm3type.max_varchar2;
    --
  BEGIN
    --
    get_network_attributes_lists(pi_nt_type     => pi_nt_type
                                ,po_alias_list  => lv_alias_list
                                ,po_select_list => lv_select_list);
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    lv_retval := 'WITH elements AS(SELECT ne_id "result_id"'
      ||CHR(10)||'                       ,ne_nt_type "network_type"'
      ||CHR(10)||'                       ,ne_gty_group_type "group_type"'
      ||CHR(10)||'                       ,ne_unique "unique_"'
    ;
    --
    IF pi_nt_type = 'NSGN'
     THEN
        lv_retval := lv_retval
          ||CHR(10)||'                       ,ne_number "USRN"';
    END IF;
    --
    CASE pi_nt_type
      WHEN 'ESU'
       THEN
          lv_retval := lv_retval
            ||CHR(10)||'                       ,ne_descr "ESU ID"';
      WHEN 'NSGN'
       THEN
          lv_retval := lv_retval
            ||CHR(10)||'                       ,ne_descr "Street Name"';
      ELSE
          lv_retval := lv_retval
            ||CHR(10)||'                       ,ne_descr "description"';
    END CASE;
    --
    lv_retval := lv_retval
      ||CHR(10)||'                       ,ne_start_date "start_date"'
      ||CHR(10)||'                       ,ne_end_date "end_date"'
      ||CHR(10)||'                       ,nm3net.get_ne_length(ne_id) "length"'
      ||CHR(10)||'                       ,nau_name "admin_unit"'
               ||lv_select_list
      ||CHR(10)||'                   FROM nm_admin_units_all'
      ||CHR(10)||'                       ,nm_elements_all'
      ||CHR(10)||'                       ,nm_nw_ad_link'
      ||CHR(10)||'                       ,nm_inv_items'
      ||CHR(10)||'                  WHERE ne_type != ''D'''
      ||CHR(10)||'                    AND ne_nt_type = :nt_type'
      ||CHR(10)||'                    AND NVL(ne_gty_group_type,:nvl) = NVL(:group_type,:nvl)'
      ||CASE
          WHEN pi_include_enddated = 'N'
            THEN CHR(10)||'                  AND NVL(ne_end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
        END
      ||CHR(10)||'                    AND ('||pi_where_clause||')'
      ||CHR(10)||'                    AND ne_admin_unit = nau_admin_unit'
      ||CHR(10)||'                    AND ne_id = nad_ne_id(+)'
      ||CHR(10)||'                    AND nad_primary_ad(+) = ''Y'''
      ||CHR(10)||'                    AND nad_iit_ne_id = iit_ne_id(+)'
      ||CHR(10)||'         ORDER BY '||NVL(LOWER(pi_order_column),'"unique_" asc ')||')'
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
  PROCEDURE get_network_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                              ,pi_criteria         IN  XMLTYPE
                              ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                              ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                              ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                              ,pi_max_rows         IN  NUMBER DEFAULT NULL
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    --
  BEGIN
    --
    g_domain_meaning_store.DELETE;
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
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_network_search_sql(pi_nt_type          => pi_theme_types.network_type
                                    ,pi_where_clause     => lv_where
                                    ,pi_include_enddated => pi_include_enddated
                                    ,pi_order_column     => lv_order_by)
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
  PROCEDURE get_network_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                               ,pi_ids              IN  nm_ne_id_array
                               ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                               ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                               ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                               ,pi_max_rows         IN  NUMBER DEFAULT NULL
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    --
  BEGIN
    --
    g_domain_meaning_store.DELETE;
    --
    lv_where := 'ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_network_search_sql(pi_nt_type          => pi_theme_types.network_type
                                    ,pi_where_clause     => lv_where
                                    ,pi_include_enddated => pi_include_enddated
                                    ,pi_order_column     => lv_order_by)
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
             ,pi_ids
             ,pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
             ,pi_ids
        ;
    END IF;
    --
  END get_network_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_results_csv(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                   ,pi_ids              IN  nm_ne_id_array
                                   ,pi_include_wkt      IN  VARCHAR2 DEFAULT 'N'
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql       nm3type.max_varchar2 := 'DECLARE lv_tmp CLOB; lv_out CLOB; CURSOR get_results IS SELECT ne_id,ne_nt_type,ne_gty_group_type,ne_unique';
    lv_concat    nm3type.max_varchar2 := 'lt_results(i).ne_id||'',"''||lt_results(i).ne_nt_type||''","''||lt_results(i).ne_gty_group_type||''","''||lt_results(i).ne_unique||''"''';
    lv_flx_sql   nm3type.max_varchar2;
    lv_dom_sql   nm3type.max_varchar2;
    lv_bind_var  VARCHAR2(30);
    lv_field     VARCHAR2(100);
    lv_tmp_clob  CLOB;
    lv_title     CLOB := '"Id","Network Type","Group Type","Unique"';
    lv_retval    CLOB;
    --
    lt_attr  ntc_tab;
    --
  BEGIN
    /*
    ||Build the header row.
    */
    IF pi_theme_types.network_type = 'NSGN'
     THEN
        lv_title := lv_title||',"USRN"';
        lv_sql := lv_sql||',ne_number';
        lv_concat := lv_concat||'||'',"''||lt_results(i).ne_number||''"''';
    END IF;
    --
    CASE pi_theme_types.network_type
      WHEN 'ESU'
       THEN
          lv_title := lv_title||',"ESU ID"';
      WHEN 'NSGN'
       THEN
          lv_title := lv_title||',"Street Name"';
      ELSE
          lv_title := lv_title||',"Description"';
    END CASE;
    --
    lv_title := lv_title||',"Start Date","End Date","Length","Admin Unit"';
    --
    lv_sql := lv_sql||',ne_descr,ne_start_date,ne_end_date,nm3net.get_ne_length(ne_id) length,(SELECT nau_name FROM nm_admin_units_all WHERE nau_admin_unit = ne_admin_unit) nau_name';
    lv_concat := lv_concat||'||'',"''||lt_results(i).ne_descr||''",''||TO_CHAR(lt_results(i).ne_start_date,''DD-MON-YYYY'')||'',''||TO_CHAR(lt_results(i).ne_end_date,''DD-MON-YYYY'')||'',''||lt_results(i).length||'',"''||lt_results(i).nau_name||''"''';
    --
    lt_attr := get_network_attributes(pi_nt_type => pi_theme_types.network_type);
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      /*
      ||Set the Title.
      */
      lv_title := lv_title||',"'||prompt_to_title(pi_prompt => lt_attr(i).ntc_prompt)||'"';
      /*
      ||Select select list.
      */
      lv_flx_sql := awlrs_element_api.get_domain_sql_with_bind(pi_nt_type     => pi_theme_types.network_type
                                                              ,pi_column_name => lt_attr(i).ntc_column_name);
      --
      IF lv_flx_sql IS NOT NULL
       THEN
          --
          lv_bind_var := REPLACE(nm3flx.extract_bind_variable(lv_flx_sql),':',NULL);
          --
          IF lv_bind_var IS NULL
           THEN
              awlrs_element_api.gen_domain_sql(pi_nt_type     => pi_theme_types.network_type
                                              ,pi_column_name => lt_attr(i).ntc_column_name
                                              ,pi_bind_value  => NULL
                                              ,pi_ordered     => FALSE
                                              ,po_sql         => lv_dom_sql);
              lv_dom_sql := '(SELECT meaning FROM ('||REPLACE(lv_dom_sql,CHR(10),' ')||') WHERE code = '||lt_attr(i).ntc_column_name||')';
              --
          ELSE
              --
              lv_dom_sql := 'awlrs_search_api.get_sql_based_domain_meaning(ne_nt_type,'''||lt_attr(i).ntc_column_name||''','||lt_attr(i).ntc_column_name||','||lv_bind_var||')';
              --
          END IF;
          --
          lv_sql := lv_sql||','||lv_dom_sql||' '||lt_attr(i).ntc_column_name;
          --
      ELSE
          --
          lv_sql := lv_sql||','||lt_attr(i).ntc_column_name;
          --
      END IF;
      /*
      ||Set the field for concatenation.
      */
      lv_field := '''"''||lt_results(i).'||lt_attr(i).ntc_column_name||'||''"''';
      --
      lv_concat := lv_concat||'||'',''||'||lv_field;
      --
    END LOOP;
    --
    IF pi_include_wkt = 'Y'
     THEN
        lv_title := lv_title||',"WKT"';
        lv_sql := lv_sql||',awlrs_sdo.get_wkt_by_pk('''||pi_theme_types.feature_table||''','''||pi_theme_types.feature_shape_column||''','''||pi_theme_types.feature_pk_column||''',ne_id) shape_wkt';
        lv_concat := lv_concat||'||'',"''||lt_results(i).shape_wkt||''"''';
    END IF;
    --
    lv_title := lv_title||CHR(10);
    --
    lv_sql := lv_sql
    ||' FROM nm_elements_all'
    ||' ,nm_nw_ad_link'
    ||' ,nm_inv_items'
    ||' WHERE ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))'
    ||' AND ne_id = nad_ne_id(+)'
    ||' AND nad_primary_ad(+) = ''Y'''
    ||' AND nad_iit_ne_id = iit_ne_id(+);'
    ||' TYPE results_tab IS TABLE OF get_results%ROWTYPE; lt_results results_tab;'
    ||' BEGIN'
    ||' OPEN  get_results;'
    ||' FETCH get_results BULK COLLECT INTO lt_results;'
    ||' CLOSE get_results;'
    ||' FOR i IN 1..lt_results.COUNT LOOP'
    ||' lv_tmp := '||lv_concat||'||CHR(10);'
    ||' lv_out := lv_out||lv_tmp;'
    ||' END LOOP;'
    ||' :out := lv_out;'
    ||' END;'
    ;
    --
dbms_output.put_line(lv_sql);
    EXECUTE IMMEDIATE lv_sql USING pi_ids, OUT lv_tmp_clob;
    --
    lv_retval := lv_title||lv_tmp_clob;
    --
    OPEN po_cursor FOR
    SELECT lv_retval
      FROM dual
    ;
    --
  END get_network_results_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
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
    lv_order_by          nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    --
  BEGIN
    --
    IF NVL(pi_skip_n_rows,0) = 0
     THEN
         --
         g_domain_meaning_store.DELETE;
         --
    END IF;
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql :=  'SELECT *'
    ||CHR(10)||'  FROM ('||get_network_search_sql(pi_nt_type          => pi_theme_types.network_type
                                                ,pi_where_clause     => lv_where
                                                ,pi_include_enddated => pi_include_enddated
                                                ,pi_order_column     => lv_order_by
                                                ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
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
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                    ,pi_criteria         IN  XMLTYPE
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                    ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                    ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                    ,pi_skip_n_rows      IN  PLS_INTEGER
                                    ,pi_pagesize         IN  PLS_INTEGER
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_driving_sql       nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    IF NVL(pi_skip_n_rows,0) = 0
     THEN
        g_domain_meaning_store.DELETE;
    END IF;
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_network_column_data(pi_nt_type     => pi_theme_types.network_type
                               ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_where := lv_where||' '||lv_filter;
    --
    lv_driving_sql := get_network_search_sql(pi_nt_type          => pi_theme_types.network_type
                                            ,pi_where_clause     => lv_where
                                            ,pi_include_enddated => pi_include_enddated
                                            ,pi_order_column     => lv_order_by
                                            ,pi_paged            => TRUE);
    --
    lv_sql :=  'SELECT *'
    ||CHR(10)||'  FROM ('||lv_driving_sql||')'
            ||lv_row_restriction
    ;
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
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                     ,pi_ids              IN  nm_ne_id_array
                                     ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                     ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                     ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                     ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                     ,pi_skip_n_rows      IN  PLS_INTEGER
                                     ,pi_pagesize         IN  PLS_INTEGER
                                     ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_driving_sql       nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    IF NVL(pi_skip_n_rows,0) = 0
     THEN
        --
        g_domain_meaning_store.DELETE;
        --
    END IF;
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_network_column_data(pi_nt_type     => pi_theme_types.network_type
                               ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_where := 'ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array))) '||lv_filter;
    --
    lv_driving_sql := get_network_search_sql(pi_nt_type          => pi_theme_types.network_type
                                            ,pi_where_clause     => lv_where
                                            ,pi_include_enddated => pi_include_enddated
                                            ,pi_order_column     => lv_order_by
                                            ,pi_paged            => TRUE);
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||lv_driving_sql||')'
            ||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
             ,pi_ids
             ,lv_lower_index
             ,lv_upper_index
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_theme_types.network_type
             ,lv_nvl
             ,pi_theme_types.network_group_type
             ,lv_nvl
             ,pi_ids
             ,lv_lower_index
        ;
    END IF;
    --
  END get_paged_network_results;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_asset_search_sql(pi_nit_rec          IN nm_inv_types_all%ROWTYPE
                               ,pi_alias_list       IN VARCHAR2
                               ,pi_select_list      IN VARCHAR2
                               ,pi_where_clause     IN VARCHAR2
                               ,pi_net_filter       IN VARCHAR2 DEFAULT NULL
                               ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                               ,pi_order_column     IN VARCHAR2 DEFAULT NULL
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
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    IF pi_nit_rec.nit_table_name IS NOT NULL
     THEN
        --
        lv_retval :=  'WITH assets AS(SELECT '||pi_nit_rec.nit_foreign_pk_column||' "result_id"'
           ||CHR(10)||'                     ,'||pi_nit_rec.nit_foreign_pk_column||' "primary_key"'
                                              ||pi_select_list
           ||CHR(10)||'                 FROM '||pi_nit_rec.nit_table_name||' iit'
           ||CHR(10)||'                WHERE ('||pi_where_clause||')'
           ||CASE
               WHEN pi_net_filter IS NOT NULL
                THEN CHR(10)||'                  AND '||pi_net_filter
             END
           ||CHR(10)||'                ORDER BY '||NVL(LOWER(pi_order_column),'"primary_key" asc')||')'
           ||CHR(10)||'SELECT '||lv_pagecols
                            ||'assets.*'
           ||CHR(10)||'  FROM assets'
        ;
        --
    ELSE
        lv_retval :=  'WITH assets AS(SELECT iit_ne_id "result_id"'
           ||CHR(10)||'                     ,iit_primary_key "primary_key"'
           ||CHR(10)||'                     ,iit_descr "description"'
           ||CHR(10)||'                     ,nau_name "admin_unit"'
           ||CASE
               WHEN pi_nit_rec.nit_x_sect_allow_flag = 'Y'
                THEN CHR(10)||'                     ,iit_x_sect "xsp"'
             END
           ||CHR(10)||'                     ,iit_start_date "start_date"'
           ||CASE
               WHEN pi_include_enddated = 'Y'
                THEN CHR(10)||'                     ,iit_end_date "end_date"'
             END
                    ||pi_select_list
           ||CHR(10)||'                 FROM nm_inv_items_all iit'
           ||CHR(10)||'                     ,nm_admin_units_all nau'
           ||CHR(10)||'                WHERE iit.iit_inv_type = :inv_type'
           ||CASE
               WHEN pi_include_enddated = 'N'
                THEN CHR(10)||'                  AND NVL(iit.iit_end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
             END
           ||CASE
               WHEN pi_net_filter IS NOT NULL
                THEN CHR(10)||'                  AND '||pi_net_filter
             END
           ||CHR(10)||'                  AND ('||pi_where_clause||')'
           ||CHR(10)||'                  AND iit.iit_admin_unit = nau.nau_admin_unit'
           ||CHR(10)||'         ORDER BY '||NVL(LOWER(pi_order_column),'"primary_key" asc ')||')'
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
  PROCEDURE validate_offset(pi_ne_id  IN nm_elements_all.ne_id%TYPE
                           ,pi_offset IN NUMBER)
    IS
    --
    lv_min_offset  NUMBER;
    lv_max_offset  NUMBER;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    lr_ne := nm3get.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.is_nt_datum(p_nt_type => lr_ne.ne_nt_type) = 'Y'
     THEN
        lv_min_offset := 0;
        lv_max_offset := lr_ne.ne_length;
    ELSE
        lv_min_offset := nm3net.get_min_slk(pi_ne_id);
        lv_max_offset := nm3net.get_max_slk(pi_ne_id);
    END IF;
    --
    IF pi_offset NOT BETWEEN lv_min_offset AND lv_max_offset
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 29
                     ,pi_supplementary_info => ' ' || TO_CHAR(lv_min_offset) || ' -> ' || TO_CHAR(lv_max_offset));
    END IF;
    --
  END validate_offset;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_asset_net_filter(pi_nit_rec              IN nm_inv_types_all%ROWTYPE
                                    ,pi_net_filter_ne_id     IN nm_elements_all.ne_id%TYPE DEFAULT NULL
                                    ,pi_net_filter_marker_id IN nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                    ,pi_net_filter_from      IN NUMBER DEFAULT NULL
                                    ,pi_net_filter_to        IN NUMBER DEFAULT NULL
                                    ,pi_net_filter_nse_id    IN nm_saved_extents.nse_id%TYPE DEFAULT NULL
                                    ,pi_include_enddated     IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2 IS
    --
    lv_pk_column    VARCHAR2(30);
    lv_from_offset  NUMBER;
    lv_to_offset    NUMBER;
    lv_sql          nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_nit_rec.nit_table_name IS NULL
     THEN
        lv_pk_column := 'iit_ne_id';
    ELSE
        lv_pk_column := pi_nit_rec.nit_foreign_pk_column;
    END IF;
    --
    IF pi_net_filter_ne_id IS NOT NULL
     THEN
        IF pi_net_filter_marker_id IS NULL
         THEN
            lv_from_offset := pi_net_filter_from;
            lv_to_offset   := pi_net_filter_to;
        ELSE
            --
            nm3mp_ref.validate_element(pi_ne_id => pi_net_filter_ne_id);
            --
            nm3mp_ref.validate_ref_item(pi_iit_ne_id => pi_net_filter_marker_id
                                       ,pi_route_id  => pi_net_filter_ne_id);
            --
            lv_from_offset := nm3mp_ref.get_route_offset_for_ref_item(pi_route_id => pi_net_filter_ne_id
                                                                     ,pi_ref_item => pi_net_filter_marker_id)
                              + pi_net_filter_from;
            lv_to_offset := nm3mp_ref.get_route_offset_for_ref_item(pi_route_id => pi_net_filter_ne_id
                                                                   ,pi_ref_item => pi_net_filter_marker_id)
                            + pi_net_filter_to;
        END IF;
        --
        IF lv_from_offset IS NOT NULL
         THEN
            validate_offset(pi_ne_id  => pi_net_filter_ne_id
                           ,pi_offset => lv_from_offset);
        END IF;
        --
        IF lv_to_offset IS NOT NULL
         THEN
            validate_offset(pi_ne_id  => pi_net_filter_ne_id
                           ,pi_offset => lv_to_offset);
        END IF;
        --
        lv_sql := lv_pk_column||' IN(SELECT ngqi_item_id FROM nm_gaz_query_item_list WHERE ngqi_job_id = '
                    ||execute_gaz_query(pi_ne_id            => pi_net_filter_ne_id
                                       ,pi_from_offset      => lv_from_offset
                                       ,pi_to_offset        => lv_to_offset
                                       ,pi_inv_type         => pi_nit_rec.nit_inv_type
                                       ,pi_include_enddated => pi_include_enddated)
                    ||')';
        --
    END IF;
    --
    IF pi_net_filter_nse_id IS NOT NULL
     THEN
        --
        IF lv_sql IS NOT NULL
         THEN
            lv_sql := lv_sql||' AND';
        END IF;
        --
        lv_sql := lv_pk_column||' IN(SELECT ngqi_item_id FROM nm_gaz_query_item_list WHERE ngqi_job_id = '
                    ||execute_gaz_query(pi_nse_id           => pi_net_filter_nse_id
                                       ,pi_inv_type         => pi_nit_rec.nit_inv_type
                                       ,pi_include_enddated => pi_include_enddated)
                    ||')';
        --
    END IF;
    --
    RETURN lv_sql;
    --
  END generate_asset_net_filter;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_assets_search(pi_theme_types          IN  awlrs_map_api.theme_types_rec
                             ,pi_criteria             IN  XMLTYPE
                             ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                             ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                             ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                             ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                             ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                             ,pi_include_enddated     IN  VARCHAR2 DEFAULT 'N'
                             ,pi_order_column         IN  VARCHAR2 DEFAULT NULL
                             ,pi_order_asc_desc       IN  VARCHAR2 DEFAULT NULL
                             ,pi_max_rows             IN  NUMBER DEFAULT NULL
                             ,po_cursor               OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_net_filter        nm3type.max_varchar2;
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
    lv_where := generate_where_clause(pi_theme_types      => pi_theme_types
                                     ,pi_criteria         => pi_criteria
                                     ,pi_include_enddated => pi_include_enddated);
    --
    lv_net_filter := generate_asset_net_filter(pi_nit_rec              => lr_nit
                                              ,pi_net_filter_ne_id     => pi_net_filter_ne_id
                                              ,pi_net_filter_marker_id => pi_net_filter_marker_id
                                              ,pi_net_filter_from      => pi_net_filter_from
                                              ,pi_net_filter_to        => pi_net_filter_to
                                              ,pi_net_filter_nse_id    => pi_net_filter_nse_id
                                              ,pi_include_enddated     => pi_include_enddated);
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
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_asset_search_sql(pi_nit_rec          => lr_nit
                                  ,pi_alias_list       => lv_alias_list
                                  ,pi_select_list      => lv_select_list
                                  ,pi_where_clause     => lv_where
                                  ,pi_net_filter       => lv_net_filter
                                  ,pi_include_enddated => pi_include_enddated
                                  ,pi_order_column     => lv_order_by)
              ||lv_additional_where
    ;
    --
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
  PROCEDURE get_assets_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                              ,pi_ids              IN  nm_ne_id_array
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
    lv_order_by          nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_theme_types.asset_type);
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
        --
    ELSE
        --
        lv_where := 'iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
        --
    END IF;
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
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_asset_search_sql(pi_nit_rec          => lr_nit
                                 ,pi_alias_list       => lv_alias_list
                                 ,pi_select_list      => lv_select_list
                                 ,pi_where_clause     => lv_where
                                 ,pi_include_enddated => pi_include_enddated
                                 ,pi_order_column     => lv_order_by)
              ||lv_additional_where
    ;
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_max_rows IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING pi_ids
                 ,pi_max_rows;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING pi_ids;
        END IF;
        --
    ELSE
        --
        IF pi_max_rows IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,pi_ids
                 ,pi_max_rows;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,pi_ids;
        END IF;
        --
    END IF;
    --
  END get_assets_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_results_csv(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                 ,pi_ids              IN  nm_ne_id_array
                                 ,pi_include_wkt      IN  VARCHAR2 DEFAULT 'N'
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql        nm3type.max_varchar2 := 'DECLARE lv_tmp CLOB; lv_out CLOB; CURSOR get_results IS SELECT';
    lv_concat     nm3type.max_varchar2;
    lv_scrn_text  nm_inv_type_attribs_all.ita_scrn_text%TYPE;
    lv_where    nm3type.max_varchar2;
    lv_field     VARCHAR2(100);
    lv_tmp_clob  CLOB;
    lv_title     CLOB := '"Id","Primary Key"';
    lv_retval    CLOB;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_attr  ita_tab;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_theme_types.asset_type);
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
        --
        lv_sql := lv_sql||' '||lr_nit.nit_foreign_pk_column||' result_id,'||lr_nit.nit_foreign_pk_column||' primary_key';
        --
        lv_concat:= 'lt_results(i).'||LOWER(lr_nit.nit_foreign_pk_column)||'||'',"''||lt_results(i).'||LOWER(lr_nit.nit_foreign_pk_column)||'||''"''';
        --
    ELSE
        --
        lv_where := 'iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
        --
        lv_title := lv_title||',"Description","Admin Unit"'
          ||CASE
              WHEN lr_nit.nit_x_sect_allow_flag = 'Y'
               THEN ',"XSP"'
            END
          ||',"Start Date","End Date"'
        ;
        --
        lv_sql := lv_sql||' iit_ne_id,iit_primary_key,iit_descr,nau_name'
          ||CASE
              WHEN lr_nit.nit_x_sect_allow_flag = 'Y'
               THEN ',iit_x_sect'
            END
          ||',iit_start_date,iit_end_date'
        ;
        --
        lv_concat := 'lt_results(i).iit_ne_id||'',"''||lt_results(i).iit_primary_key||''","''||lt_results(i).iit_descr||''","''||lt_results(i).nau_name||''"'
          ||CASE
              WHEN lr_nit.nit_x_sect_allow_flag = 'Y'
               THEN ',"''||lt_results(i).iit_x_sect||''"'''
            END
          ||',''||TO_CHAR(lt_results(i).iit_start_date,''DD-MON-YYYY'')||'',''||TO_CHAR(lt_results(i).iit_end_date,''DD-MON-YYYY'')'
        ;
    END IF;
    /*
    ||Process the attributes.
    */
    lt_attr := get_asset_attributes(pi_inv_type => pi_theme_types.asset_type);
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      /*
      ||Set the Title.
      */
      lv_title := lv_title||',"'||prompt_to_title(pi_prompt => lt_attr(i).ita_scrn_text)||'"';
      /*
      ||Add the attributes.
      */
      IF lt_attr(i).ita_id_domain IS NOT NULL
       THEN
          --
          lv_sql := lv_sql||',(SELECT ial_meaning FROM nm_inv_attri_lookup WHERE ial_domain = '
            ||nm3flx.string(lt_attr(i).ita_id_domain)||' AND ial_value = iit.'||LOWER(lt_attr(i).ita_attrib_name)||') '||LOWER(lt_attr(i).ita_attrib_name)
          ;
          --
      ELSE
          --
          lv_sql := lv_sql||',iit.'||LOWER(lt_attr(i).ita_attrib_name);
          --
      END IF;
      /*
      ||Set the field for concatenation.
      */
      lv_field := CASE
                    WHEN lt_attr(i).ita_format = 'VARCHAR2'
                     THEN
                        '''"''||lt_results(i).'||lt_attr(i).ita_attrib_name||'||''"'''
                    WHEN lt_attr(i).ita_format = 'DATE'
                     THEN
                        'TO_CHAR(lt_results(i).'||lt_attr(i).ita_attrib_name||',''DD-MON-YYYY HH24:MI'')'
                    ELSE
                        'lt_results(i).'||lt_attr(i).ita_attrib_name
                  END;
      lv_concat := lv_concat||'||'',''||'||lv_field;
      --
    END LOOP;
    --
    IF pi_include_wkt = 'Y'
     THEN
        lv_title := lv_title||',"WKT"';
        lv_sql := lv_sql||',awlrs_sdo.get_wkt_by_pk('''||pi_theme_types.feature_table||''','''||pi_theme_types.feature_shape_column||''','''||pi_theme_types.feature_pk_column||''',ne_id) shape_wkt';
        lv_concat := lv_concat||'||'',"''||lt_results(i).shape_wkt||''"''';
    END IF;
    --
    lv_title := lv_title||CHR(10);
    --
    lv_sql := lv_sql
    ||CASE
        WHEN lr_nit.nit_table_name IS NOT NULL
         THEN
            ' FROM '||lr_nit.nit_table_name||' iit WHERE '||lv_where
        ELSE
            ' FROM nm_inv_items_all iit'
          ||' ,nm_admin_units_all nau WHERE '||lv_where
          ||' AND iit.iit_admin_unit = nau.nau_admin_unit'
      END
    ||'; TYPE results_tab IS TABLE OF get_results%ROWTYPE; lt_results results_tab;'
    ||' BEGIN'
    ||' OPEN  get_results;'
    ||' FETCH get_results BULK COLLECT INTO lt_results;'
    ||' CLOSE get_results;'
    ||' FOR i IN 1..lt_results.COUNT LOOP'
    ||' lv_tmp := '||lv_concat||'||CHR(10);'
    ||' lv_out := lv_out||lv_tmp;'
    ||' END LOOP;'
    ||' :out := lv_out;'
    ||' END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql USING pi_ids, OUT lv_tmp_clob;
    --
    lv_retval := lv_title||lv_tmp_clob;
    --
    OPEN po_cursor FOR
    SELECT lv_retval
      FROM dual
    ;
    --
  END get_asset_results_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_assets_search(pi_theme_types          IN  awlrs_map_api.theme_types_rec
                                   ,pi_criteria             IN  XMLTYPE
                                   ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                                   ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                   ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                                   ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                                   ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                                   ,pi_include_enddated     IN  VARCHAR2 DEFAULT 'N'
                                   ,pi_order_column         IN  VARCHAR2 DEFAULT NULL
                                   ,pi_order_asc_desc       IN  VARCHAR2 DEFAULT NULL
                                   ,pi_skip_n_rows          IN  PLS_INTEGER
                                   ,pi_pagesize             IN  PLS_INTEGER
                                   ,po_cursor               OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_net_filter        nm3type.max_varchar2;
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
    lv_where := generate_where_clause(pi_theme_types      => pi_theme_types
                                     ,pi_criteria         => pi_criteria
                                     ,pi_include_enddated => pi_include_enddated);
    --
    lv_net_filter := generate_asset_net_filter(pi_nit_rec              => lr_nit
                                              ,pi_net_filter_ne_id     => pi_net_filter_ne_id
                                              ,pi_net_filter_marker_id => pi_net_filter_marker_id
                                              ,pi_net_filter_from      => pi_net_filter_from
                                              ,pi_net_filter_to        => pi_net_filter_to
                                              ,pi_net_filter_nse_id    => pi_net_filter_nse_id
                                              ,pi_include_enddated     => pi_include_enddated);
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
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
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_asset_search_sql(pi_nit_rec          => lr_nit
                                              ,pi_alias_list       => lv_alias_list
                                              ,pi_select_list      => lv_select_list
                                              ,pi_where_clause     => lv_where
                                              ,pi_net_filter       => lv_net_filter
                                              ,pi_include_enddated => pi_include_enddated
                                              ,pi_order_column     => lv_order_by
                                              ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
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
  PROCEDURE get_paged_assets_search(pi_theme_types          IN  awlrs_map_api.theme_types_rec
                                   ,pi_criteria             IN  XMLTYPE
                                   ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                                   ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                   ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                                   ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                                   ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                                   ,pi_include_enddated     IN  VARCHAR2 DEFAULT 'N'
                                   ,pi_filter_columns       IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_filter_operators     IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_filter_values_1      IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                   ,pi_filter_values_2      IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                   ,pi_order_columns        IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_order_asc_desc       IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                   ,pi_skip_n_rows          IN  PLS_INTEGER
                                   ,pi_pagesize             IN  PLS_INTEGER
                                   ,po_cursor               OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    lv_net_filter        nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_theme_types.asset_type);
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types      => pi_theme_types
                                     ,pi_criteria         => pi_criteria
                                     ,pi_include_enddated => pi_include_enddated);
    --
    lv_net_filter := generate_asset_net_filter(pi_nit_rec              => lr_nit
                                              ,pi_net_filter_ne_id     => pi_net_filter_ne_id
                                              ,pi_net_filter_marker_id => pi_net_filter_marker_id
                                              ,pi_net_filter_from      => pi_net_filter_from
                                              ,pi_net_filter_to        => pi_net_filter_to
                                              ,pi_net_filter_nse_id    => pi_net_filter_nse_id
                                              ,pi_include_enddated     => pi_include_enddated);
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_asset_column_data(pi_nit_rec          => lr_nit
                             ,pi_include_enddated => pi_include_enddated
                             ,po_column_data      => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    get_asset_attributes_lists(pi_inv_type    => lr_nit.nit_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    lv_where := lv_where||' '||lv_filter;
    --
    lv_sql :=  'SELECT *'
    ||CHR(10)||'  FROM ('||get_asset_search_sql(pi_nit_rec          => lr_nit
                                               ,pi_alias_list       => lv_alias_list
                                               ,pi_select_list      => lv_select_list
                                               ,pi_where_clause     => lv_where
                                               ,pi_net_filter       => lv_net_filter
                                               ,pi_include_enddated => pi_include_enddated
                                               ,pi_order_column     => lv_order_by
                                               ,pi_paged            => TRUE)||')'
             ||lv_row_restriction
    ;
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
  PROCEDURE get_paged_assets_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                    ,pi_ids              IN  nm_ne_id_array
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
    lv_order_by          nm3type.max_varchar2;
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
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
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
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
        --
    ELSE
        --
        lv_where := 'iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
        --
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_asset_search_sql(pi_nit_rec          => lr_nit
                                              ,pi_alias_list       => lv_alias_list
                                              ,pi_select_list      => lv_select_list
                                              ,pi_where_clause     => lv_where
                                              ,pi_include_enddated => pi_include_enddated
                                              ,pi_order_column     => lv_order_by
                                              ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING pi_ids
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING pi_ids
                 ,lv_lower_index
            ;
        END IF;
        --
    ELSE
       --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,pi_ids
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,pi_ids
                 ,lv_lower_index
            ;
        END IF;
        --
    END IF;
    --
  END get_paged_assets_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_assets_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                    ,pi_ids              IN  nm_ne_id_array
                                    ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                    ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                    ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                    ,pi_skip_n_rows      IN  PLS_INTEGER
                                    ,pi_pagesize         IN  PLS_INTEGER
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_theme_types.asset_type);
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_asset_column_data(pi_nit_rec          => lr_nit
                             ,pi_include_enddated => pi_include_enddated
                             ,po_column_data      => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    get_asset_attributes_lists(pi_inv_type    => lr_nit.nit_inv_type
                              ,po_alias_list  => lv_alias_list
                              ,po_select_list => lv_select_list);
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array))) '||lv_filter;
        --
    ELSE
        --
        lv_where := 'iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array))) '||lv_filter;
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_asset_search_sql(pi_nit_rec          => lr_nit
                                              ,pi_alias_list       => lv_alias_list
                                              ,pi_select_list      => lv_select_list
                                              ,pi_where_clause     => lv_where
                                              ,pi_include_enddated => pi_include_enddated
                                              ,pi_order_column     => lv_order_by
                                              ,pi_paged            => TRUE)||')'
            ||lv_row_restriction
    ;
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING pi_ids
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING pi_ids
                 ,lv_lower_index
            ;
        END IF;
        --
    ELSE
       --
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,pi_ids
                 ,lv_lower_index
                 ,lv_upper_index
            ;
        ELSE
            OPEN po_cursor FOR lv_sql
            USING lr_nit.nit_inv_type
                 ,pi_ids
                 ,lv_lower_index
            ;
        END IF;
        --
    END IF;
    --
  END get_paged_assets_results;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_node_search_sql(pi_feature_table    IN VARCHAR2
                              ,pi_where_clause     IN VARCHAR2
                              ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                              ,pi_order_column     IN VARCHAR2 DEFAULT NULL
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
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    lv_retval :=  'SELECT '||lv_pagecols
                       ||'"result_id"'
       ||CHR(10)||'      ,"name"'
       ||CHR(10)||'      ,"description"'
       ||CHR(10)||'      ,"purpose"'
       ||CHR(10)||'      ,"start_date"'
       ||CHR(10)||'      ,"end_date"'
       ||CHR(10)||'      ,"node_type"'
       ||CHR(10)||'      ,"date_created"'
       ||CHR(10)||'      ,"created_by"'
       ||CHR(10)||'      ,"date_modified"'
       ||CHR(10)||'      ,"modified_by"'
       ||CHR(10)||'      ,"node_id"'
       ||CHR(10)||'      ,"point_id"'
       ||CHR(10)||'      ,"point_location_id"'
       ||CHR(10)||'  FROM (SELECT npl_id "result_id"'
       ||CHR(10)||'              ,no_node_id "node_id"'
       ||CHR(10)||'              ,no_node_name "name"'
       ||CHR(10)||'              ,no_descr "description"'
       ||CHR(10)||'              ,no_purpose "purpose"'
       ||CHR(10)||'              ,no_start_date "start_date"'
       ||CHR(10)||'              ,no_end_date "end_date"'
       ||CHR(10)||'              ,no_node_type "node_type"'
       ||CHR(10)||'              ,no_date_created "date_created"'
       ||CHR(10)||'              ,no_created_by "created_by"'
       ||CHR(10)||'              ,no_date_modified "date_modified"'
       ||CHR(10)||'              ,no_modified_by "modified_by"'
       ||CHR(10)||'              ,no_np_id "point_id"'
       ||CHR(10)||'              ,npl_id "point_location_id"'
       ||CHR(10)||'          FROM '||pi_feature_table
       ||CHR(10)||'         WHERE ('||pi_where_clause||')'
       ||CASE
          WHEN pi_include_enddated = 'N'
           THEN CHR(10)||'         AND NVL(no_end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
         END
       ||CHR(10)||'         ORDER BY '||NVL(LOWER(pi_order_column),'"name" asc ')||')'
    ;
    --
    RETURN lv_retval;
    --
  END get_node_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
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
    lv_order_by          nm3type.max_varchar2;
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
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_node_search_sql(pi_feature_table    => pi_theme_types.feature_table
                                 ,pi_where_clause     => lv_where
                                 ,pi_include_enddated => pi_include_enddated
                                 ,pi_order_column     => lv_order_by)
              ||lv_additional_where
    ;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql;
    END IF;
    --
  END get_node_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                            ,pi_ids              IN  nm_ne_id_array
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
    lv_order_by          nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    --
  BEGIN
    --
    lv_where := 'npl_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_node_search_sql(pi_feature_table    => pi_theme_types.feature_table
                                 ,pi_where_clause     => lv_where
                                 ,pi_include_enddated => pi_include_enddated
                                 ,pi_order_column     => lv_order_by)
              ||lv_additional_where
    ;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_ids;
    END IF;
    --
  END get_node_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_results_csv(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                ,pi_ids              IN  nm_ne_id_array
                                ,pi_include_wkt      IN  VARCHAR2 DEFAULT 'N'
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql  nm3type.max_varchar2 := 'DECLARE lv_tmp CLOB; lv_out CLOB; CURSOR get_results IS'
      ||' SELECT no_node_id,no_node_name,no_descr,no_purpose,no_start_date,no_end_date'
      ||',no_node_type,no_date_created,no_created_by,no_date_modified,no_modified_by'
      ||',no_np_id,npl_id'
    ;
    lv_from  VARCHAR2(500) := ' FROM '||pi_theme_types.feature_table
      ||' WHERE npl_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))'
    ;
    lv_concat  nm3type.max_varchar2 := 'lt_results(i).no_node_id||'',"''||lt_results(i).no_node_name||''","'''
      ||'||lt_results(i).no_descr||''","''||lt_results(i).no_purpose||''",'''
      ||'||TO_CHAR(lt_results(i).no_start_date,''DD-MON-YYYY'')||'',''||TO_CHAR(lt_results(i).no_end_date,''DD-MON-YYYY'')'
      ||'||'',"''||lt_results(i).no_node_type||''",''||TO_CHAR(lt_results(i).no_date_created,''DD-MON-YYYY'')'
      ||'||'',"''||lt_results(i).no_created_by||''",''||TO_CHAR(lt_results(i).no_date_modified,''DD-MON-YYYY'')'
      ||'||'',"''||lt_results(i).no_modified_by||''",''||lt_results(i).no_np_id||'',''||lt_results(i).npl_id'
    ;
    lv_title  CLOB := '"Node Id","Name","Description","Purpose","Start Date","End Date","Node Type","Date Created","Created By","Date Modified","Modified By","Point Id","Point Location Id"'
    ;
    lv_tmp_clob  CLOB;
    lv_retval    CLOB;
    --
  BEGIN
    --
    IF pi_include_wkt = 'Y'
     THEN
        lv_title := lv_title||',"WKT"';
        lv_sql := lv_sql||',awlrs_sdo.get_wkt_by_pk('''||pi_theme_types.feature_table||''','''||pi_theme_types.feature_shape_column||''','''||pi_theme_types.feature_pk_column||''',npl_id) shape_wkt';
        lv_concat := lv_concat||'||'',"''||lt_results(i).shape_wkt||''"''';
    END IF;
    --
    lv_sql := lv_sql
    ||lv_from
    ||'; TYPE results_tab IS TABLE OF get_results%ROWTYPE; lt_results results_tab;'
    ||' BEGIN'
    ||' OPEN  get_results;'
    ||' FETCH get_results BULK COLLECT INTO lt_results;'
    ||' CLOSE get_results;'
    ||' FOR i IN 1..lt_results.COUNT LOOP'
    ||' lv_tmp := '||lv_concat||'||CHR(10);'
    ||' lv_out := lv_out||lv_tmp;'
    ||' END LOOP;'
    ||' :out := lv_out;'
    ||' END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql USING pi_ids, OUT lv_tmp_clob;
    --
    lv_retval := lv_title||lv_tmp_clob;
    --
    OPEN po_cursor FOR
    SELECT lv_retval
      FROM dual
    ;
    --
  END get_node_results_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_node_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
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
    lv_additional_where  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
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
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_node_search_sql(pi_feature_table    => pi_theme_types.feature_table
                                             ,pi_where_clause     => lv_where
                                             ,pi_include_enddated => pi_include_enddated
                                             ,pi_order_column     => lv_order_by
                                             ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
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
  END get_paged_node_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_node_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                 ,pi_criteria         IN  XMLTYPE
                                 ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                 ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                 ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                 ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                 ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                 ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                 ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                 ,pi_skip_n_rows      IN  PLS_INTEGER
                                 ,pi_pagesize         IN  PLS_INTEGER
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_where            nm3type.max_varchar2;
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_sql              nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_node_column_data(pi_feature_table => pi_theme_types.feature_table
                            ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_where := lv_where||' '||lv_filter;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_node_search_sql(pi_feature_table    => pi_theme_types.feature_table
                                             ,pi_where_clause     => lv_where
                                             ,pi_include_enddated => pi_include_enddated
                                             ,pi_order_column     => lv_order_by
                                             ,pi_paged            => TRUE)||')'
            ||lv_row_restriction
    ;
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
  END get_paged_node_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_node_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                  ,pi_ids              IN  nm_ne_id_array
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
    lv_additional_where  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    --
  BEGIN
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    lv_where := 'npl_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_node_search_sql(pi_feature_table    => pi_theme_types.feature_table
                                             ,pi_where_clause     => lv_where
                                             ,pi_include_enddated => pi_include_enddated
                                             ,pi_order_column     => lv_order_by
                                             ,pi_paged            => TRUE)||')'
            ||lv_additional_where
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
             ,lv_upper_index
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
        ;
    END IF;
    --
  END get_paged_node_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_node_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                  ,pi_ids              IN  nm_ne_id_array
                                  ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                  ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                  ,pi_skip_n_rows      IN  PLS_INTEGER
                                  ,pi_pagesize         IN  PLS_INTEGER
                                  ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_where            nm3type.max_varchar2;
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_sql              nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_node_column_data(pi_feature_table => pi_theme_types.feature_table
                            ,po_column_data   => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_where := 'npl_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array))) '||lv_filter;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_node_search_sql(pi_feature_table    => pi_theme_types.feature_table
                                             ,pi_where_clause     => lv_where
                                             ,pi_include_enddated => pi_include_enddated
                                             ,pi_order_column     => lv_order_by
                                             ,pi_paged            => TRUE)||')'
            ||lv_row_restriction
    ;
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index;
    END IF;
    --
  END get_paged_node_results;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_table_search_sql(pi_theme_types      IN awlrs_map_api.theme_types_rec
                               ,pi_select_list      IN VARCHAR2
                               ,pi_where_clause     IN VARCHAR2
                               ,pi_include_enddated IN VARCHAR2 DEFAULT 'N'
                               ,pi_order_column     IN VARCHAR2 DEFAULT NULL
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
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        lv_order_by := pi_order_column;
    ELSE
        lv_order_by := pi_theme_types.feature_pk_column;
    END IF;
    --
    lv_retval := 'WITH records AS(SELECT '||pi_theme_types.feature_pk_column||' "result_id"'
               ||pi_select_list
      ||CHR(10)||'                   FROM '||pi_theme_types.feature_table
      ||CHR(10)||'                  WHERE ('||pi_where_clause||')'
      ||CHR(10)||'                  ORDER BY '||LOWER(lv_order_by)||')'
      ||CHR(10)||'SELECT '||lv_pagecols
                       ||'records.*'
      ||CHR(10)||'  FROM records'
    ;
    --
    RETURN lv_retval;
    --
  END get_table_search_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_search(pi_theme_types    IN  awlrs_map_api.theme_types_rec
                            ,pi_criteria       IN  XMLTYPE
                            ,pi_order_column   IN  VARCHAR2 DEFAULT NULL
                            ,pi_order_asc_desc IN  VARCHAR2 DEFAULT NULL
                            ,pi_max_rows       IN  NUMBER DEFAULT NULL
                            ,po_cursor         OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
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
    get_table_attributes_lists(pi_feature_table => pi_theme_types.feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_table_search_sql(pi_theme_types    => pi_theme_types
                                  ,pi_select_list    => lv_select_list
                                  ,pi_where_clause   => lv_where
                                  ,pi_order_column   => lv_order_by)
              ||lv_additional_where
    ;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql;
    END IF;
    --
  END get_table_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_results(pi_theme_types    IN  awlrs_map_api.theme_types_rec
                             ,pi_ids            IN  nm_ne_id_array
                             ,pi_order_column   IN  VARCHAR2 DEFAULT NULL
                             ,pi_order_asc_desc IN  VARCHAR2 DEFAULT NULL
                             ,pi_max_rows       IN  NUMBER DEFAULT NULL
                             ,po_cursor         OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_nvl               VARCHAR2(10) := nm3type.get_nvl;
    --
  BEGIN
    --
    lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
    --
    IF pi_max_rows IS NOT NULL
     THEN
        lv_additional_where := CHR(10)||' WHERE rownum <= :max_rows';
    END IF;
    --
    get_table_attributes_lists(pi_feature_table => pi_theme_types.feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := get_table_search_sql(pi_theme_types    => pi_theme_types
                                  ,pi_select_list    => lv_select_list
                                  ,pi_where_clause   => lv_where
                                  ,pi_order_column   => lv_order_by)
              ||lv_additional_where
    ;
    --
    IF pi_max_rows IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,pi_max_rows
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_ids;
    END IF;
    --
  END get_table_results;


  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_results_csv_sql(pi_theme_types IN     awlrs_map_api.theme_types_rec
                                     ,pi_use_tab_ids IN     VARCHAR2 DEFAULT 'Y'
                                     ,pi_max_rows    IN     NUMBER DEFAULT NULL
                                     ,pi_include_wkt IN     VARCHAR2 DEFAULT 'N'
                                     ,po_sql         IN OUT VARCHAR2
                                     ,po_title       IN OUT CLOB)
    IS
    --
    lv_sql     nm3type.max_varchar2 := 'DECLARE lv_tmp CLOB; lv_out CLOB; CURSOR get_results IS SELECT ';
    lv_concat  nm3type.max_varchar2;
    lv_field   nm3type.max_varchar2;
    lv_title   CLOB;
    --
    CURSOR get_attr(cp_feature_table IN all_tab_columns.table_name%TYPE)
        IS
    SELECT column_name
          ,data_type
      FROM all_tab_columns
     WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
       AND table_name = cp_feature_table
       AND data_type IN('VARCHAR2','NUMBER','DATE')
     ORDER
        BY column_id
         ;
    --
    TYPE attr_rec IS TABLE OF get_attr%ROWTYPE;
    lt_attr  attr_rec;
    --
  BEGIN
    --
    OPEN  get_attr(pi_theme_types.feature_table);
    FETCH get_attr
     BULK COLLECT
     INTO lt_attr;
    CLOSE get_attr;
    --
    FOR i IN 1..lt_attr.COUNT LOOP
      --
      lv_field := CASE
                    WHEN lt_attr(i).data_type = 'VARCHAR2'
                     THEN
                        '''"''||lt_results(i).'||lt_attr(i).column_name||'||''"'''
                    WHEN lt_attr(i).data_type = 'DATE'
                     THEN
                        'TO_CHAR(lt_results(i).'||lt_attr(i).column_name||',''DD-MON-YYYY HH24:MI'')'
                    ELSE
                        'lt_results(i).'||lt_attr(i).column_name
                  END;
      --
      IF i > 1
       THEN
          lv_title := lv_title||',"'||prompt_to_title(pi_prompt => lt_attr(i).column_name)||'"';
          lv_sql := lv_sql||','||lt_attr(i).column_name;
          lv_concat := lv_concat||'||'',''||'||lv_field;
      ELSE
          lv_title := lv_title||'"'||prompt_to_title(pi_prompt => lt_attr(i).column_name)||'"';
          lv_sql := lv_sql||lt_attr(i).column_name;
          lv_concat := lv_concat||lv_field;
      END IF;
      --
    END LOOP;
    --
    IF pi_include_wkt = 'Y'
     THEN
        lv_title := lv_title||',"WKT"';
        lv_sql := lv_sql||',awlrs_sdo.get_wkt_by_pk('''||pi_theme_types.feature_table||''','''||pi_theme_types.feature_shape_column||''','''||pi_theme_types.feature_pk_column||''','||pi_theme_types.feature_pk_column||') shape_wkt';
        lv_concat := lv_concat||'||'',"''||lt_results(i).shape_wkt||''"''';
    END IF;
    --
    lv_title := lv_title||CHR(10);
    --
    lv_sql := lv_sql
    ||' FROM '||pi_theme_types.feature_table
    ;
    --
    IF pi_use_tab_ids = 'Y'
     THEN
        lv_sql := lv_sql
        ||' WHERE '||pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))'
        ;
        --
        IF pi_max_rows IS NOT NULL
         THEN
            lv_sql := lv_sql||' AND rownum <= :max_rows';
        END IF;
        --
    ELSE
        --
        IF pi_max_rows IS NOT NULL
         THEN
            lv_sql := lv_sql||' WHERE rownum <= :max_rows';
        END IF;
        --
    END IF;
    --
    lv_sql := lv_sql
    ||'; TYPE results_tab IS TABLE OF get_results%ROWTYPE; lt_results results_tab;'
    ||' BEGIN'
    ||' OPEN  get_results;'
    ||' FETCH get_results BULK COLLECT INTO lt_results;'
    ||' CLOSE get_results;'
    ||' FOR i IN 1..lt_results.COUNT LOOP'
    ||' lv_tmp := '||lv_concat||'||CHR(10);'
    ||' lv_out := lv_out||lv_tmp;'
    ||' END LOOP;'
    ||' :out := lv_out;'
    ||' END;'
    ;
    --
    po_sql := lv_sql;
    po_title := lv_title;
    --
  END get_table_results_csv_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_table_results_csv(pi_theme_types IN  awlrs_map_api.theme_types_rec
                                 ,pi_ids         IN  nm_ne_id_array
                                 ,pi_include_wkt IN  VARCHAR2 DEFAULT 'N'
                                 ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_sql       nm3type.max_varchar2;
    lv_tmp_clob  CLOB;
    lv_title     CLOB;
    lv_retval    CLOB;
    --
  BEGIN
    --
    get_table_results_csv_sql(pi_theme_types => pi_theme_types
                             ,pi_use_tab_ids => 'Y'
                             ,pi_include_wkt => pi_include_wkt
                             ,po_sql         => lv_sql
                             ,po_title       => lv_title);
    --
    EXECUTE IMMEDIATE lv_sql USING pi_ids, OUT lv_tmp_clob;
    --
    lv_retval := lv_title||lv_tmp_clob;
    --
    OPEN po_cursor FOR
    SELECT lv_retval
      FROM dual
    ;
    --
  END get_table_results_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_all_table_results_csv(pi_theme_types IN  awlrs_map_api.theme_types_rec
                                     ,pi_max_rows    IN  NUMBER DEFAULT NULL
                                     ,pi_include_wkt IN  VARCHAR2 DEFAULT 'N'
                                     ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_sql       nm3type.max_varchar2;
    lv_tmp_clob  CLOB;
    lv_title     CLOB;
    lv_retval    CLOB;
    --
  BEGIN
    --
    get_table_results_csv_sql(pi_theme_types => pi_theme_types
                             ,pi_use_tab_ids => 'N'
                             ,pi_max_rows    => pi_max_rows
                             ,pi_include_wkt => pi_include_wkt
                             ,po_sql         => lv_sql
                             ,po_title       => lv_title);
    --
    IF pi_max_rows IS NOT NULL
     THEN
        EXECUTE IMMEDIATE lv_sql USING pi_max_rows, OUT lv_tmp_clob;
    ELSE
        EXECUTE IMMEDIATE lv_sql USING OUT lv_tmp_clob;
    END IF;
    --
    lv_retval := lv_title||lv_tmp_clob;
    --
    OPEN po_cursor FOR
    SELECT lv_retval
      FROM dual
    ;
    --
  END get_all_table_results_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_table_search(pi_theme_types    IN awlrs_map_api.theme_types_rec
                                  ,pi_criteria       IN  XMLTYPE
                                  ,pi_order_column   IN  VARCHAR2 DEFAULT NULL
                                  ,pi_order_asc_desc IN  VARCHAR2 DEFAULT NULL
                                  ,pi_skip_n_rows    IN  PLS_INTEGER
                                  ,pi_pagesize       IN  PLS_INTEGER
                                  ,po_cursor         OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
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
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    get_table_attributes_lists(pi_feature_table => pi_theme_types.feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_table_search_sql(pi_theme_types    => pi_theme_types
                                              ,pi_select_list    => lv_select_list
                                              ,pi_where_clause   => lv_where
                                              ,pi_order_column   => lv_order_by
                                              ,pi_paged          => TRUE)||')'
            ||lv_additional_where
    ;
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
  END get_paged_table_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_table_search(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                  ,pi_criteria         IN  XMLTYPE
                                  ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                  ,pi_skip_n_rows      IN  PLS_INTEGER
                                  ,pi_pagesize         IN  PLS_INTEGER
                                  ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql              nm3type.max_varchar2;
    lv_where            nm3type.max_varchar2;
    lv_alias_list       nm3type.max_varchar2;
    lv_select_list      nm3type.max_varchar2;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    /*
    ||Generate the where clause from the given criteria.
    */
    lv_where := generate_where_clause(pi_theme_types => pi_theme_types
                                     ,pi_criteria    => pi_criteria);
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    --
    get_table_attributes_lists(pi_feature_table => pi_theme_types.feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_table_column_data(pi_table_name  => pi_theme_types.feature_table
                             ,pi_pk_column   => pi_theme_types.feature_pk_column
                             ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_where := lv_where||' '||lv_filter;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_table_search_sql(pi_theme_types    => pi_theme_types
                                              ,pi_select_list    => lv_select_list
                                              ,pi_where_clause   => lv_where
                                              ,pi_order_column   => lv_order_by
                                              ,pi_paged          => TRUE)||')'
            ||lv_row_restriction
    ;
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
  END get_paged_table_search;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_table_results(pi_theme_types    IN awlrs_map_api.theme_types_rec
                                   ,pi_ids            IN  nm_ne_id_array
                                   ,pi_order_column   IN  VARCHAR2 DEFAULT NULL
                                   ,pi_order_asc_desc IN  VARCHAR2 DEFAULT NULL
                                   ,pi_skip_n_rows    IN  PLS_INTEGER
                                   ,pi_pagesize       IN  PLS_INTEGER
                                   ,po_cursor         OUT sys_refcursor)
    IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2;
    lv_alias_list        nm3type.max_varchar2;
    lv_select_list       nm3type.max_varchar2;
    lv_additional_where  nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    --
  BEGIN
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_additional_where);
    --
    get_table_attributes_lists(pi_feature_table => pi_theme_types.feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    --
    lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))';
    --
    IF pi_order_column IS NOT NULL
     THEN
        --
        lv_order_by := '"'||pi_order_column||'" '||NVL(pi_order_asc_desc,'ASC');
        --
    END IF;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_table_search_sql(pi_theme_types    => pi_theme_types
                                              ,pi_select_list    => lv_select_list
                                              ,pi_where_clause   => lv_where
                                              ,pi_order_column   => lv_order_by
                                              ,pi_paged          => TRUE)||')'
            ||lv_additional_where
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
             ,lv_upper_index
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
        ;
    END IF;
    --
  END get_paged_table_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_table_results(pi_theme_types      IN  awlrs_map_api.theme_types_rec
                                   ,pi_ids              IN  nm_ne_id_array
                                   ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                   ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                   ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                   ,pi_skip_n_rows      IN  PLS_INTEGER
                                   ,pi_pagesize         IN  PLS_INTEGER
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql              nm3type.max_varchar2;
    lv_where            nm3type.max_varchar2;
    lv_alias_list       nm3type.max_varchar2;
    lv_select_list      nm3type.max_varchar2;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    --
    get_table_attributes_lists(pi_feature_table => pi_theme_types.feature_table
                              ,po_alias_list    => lv_alias_list
                              ,po_select_list   => lv_select_list);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_table_column_data(pi_table_name  => pi_theme_types.feature_table
                             ,pi_pk_column   => pi_theme_types.feature_pk_column
                             ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_where := pi_theme_types.feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array))) '||lv_filter;
    --
    lv_sql := 'SELECT *'
   ||CHR(10)||'  FROM ('||get_table_search_sql(pi_theme_types    => pi_theme_types
                                              ,pi_select_list    => lv_select_list
                                              ,pi_where_clause   => lv_where
                                              ,pi_order_column   => lv_order_by
                                              ,pi_paged          => TRUE)||')'
            ||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
             ,lv_upper_index
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING pi_ids
             ,lv_lower_index
        ;
    END IF;
    --
  END get_paged_table_results;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_search_results(pi_theme_name           IN  nm_themes_all.nth_theme_name%TYPE
                              ,pi_criteria             IN  XMLTYPE
                              ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                              ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                              ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                              ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                              ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                              ,pi_include_enddated     IN  VARCHAR2 DEFAULT 'N'
                              ,pi_order_column         IN  VARCHAR2 DEFAULT NULL
                              ,pi_order_asc_desc       IN  VARCHAR2 DEFAULT NULL
                              ,pi_max_rows             IN  NUMBER DEFAULT NULL
                              ,po_message_severity     OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT sys_refcursor
                              ,po_cursor               OUT sys_refcursor)
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
              get_assets_search(pi_theme_types          => lt_theme_types(1)
                               ,pi_criteria             => pi_criteria
                               ,pi_net_filter_ne_id     => pi_net_filter_ne_id
                               ,pi_net_filter_marker_id => pi_net_filter_marker_id
                               ,pi_net_filter_from      => pi_net_filter_from
                               ,pi_net_filter_to        => pi_net_filter_to
                               ,pi_net_filter_nse_id    => pi_net_filter_nse_id
                               ,pi_include_enddated     => pi_include_enddated
                               ,pi_order_column         => pi_order_column
                               ,pi_order_asc_desc       => pi_order_asc_desc
                               ,pi_max_rows             => pi_max_rows
                               ,po_cursor               => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  get_node_search(pi_theme_types      => lt_theme_types(1)
                                 ,pi_criteria         => pi_criteria
                                 ,pi_include_enddated => pi_include_enddated
                                 ,pi_order_column     => pi_order_column
                                 ,pi_order_asc_desc   => pi_order_asc_desc
                                 ,pi_max_rows         => pi_max_rows
                                 ,po_cursor           => po_cursor);
                  --
              ELSE
                  get_table_search(pi_theme_types    => lt_theme_types(1)
                                  ,pi_criteria       => pi_criteria
                                  ,pi_order_column   => pi_order_column
                                  ,pi_order_asc_desc => pi_order_asc_desc
                                  ,pi_max_rows       => pi_max_rows
                                  ,po_cursor         => po_cursor);
              END IF;
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
  PROCEDURE get_paged_search_results(pi_theme_name           IN  nm_themes_all.nth_theme_name%TYPE
                                    ,pi_criteria             IN  XMLTYPE
                                    ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                                    ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                    ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                                    ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                                    ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                                    ,pi_include_enddated     IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_order_column         IN  VARCHAR2 DEFAULT NULL
                                    ,pi_order_asc_desc       IN  VARCHAR2 DEFAULT NULL
                                    ,pi_skip_n_rows          IN  PLS_INTEGER
                                    ,pi_pagesize             IN  PLS_INTEGER
                                    ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor       OUT sys_refcursor
                                    ,po_cursor               OUT sys_refcursor)
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
              get_paged_assets_search(pi_theme_types          => lt_theme_types(1)
                                     ,pi_criteria             => pi_criteria
                                     ,pi_net_filter_ne_id     => pi_net_filter_ne_id
                                     ,pi_net_filter_marker_id => pi_net_filter_marker_id
                                     ,pi_net_filter_from      => pi_net_filter_from
                                     ,pi_net_filter_to        => pi_net_filter_to
                                     ,pi_net_filter_nse_id    => pi_net_filter_nse_id
                                     ,pi_include_enddated     => pi_include_enddated
                                     ,pi_order_column         => pi_order_column
                                     ,pi_order_asc_desc       => pi_order_asc_desc
                                     ,pi_skip_n_rows          => pi_skip_n_rows
                                     ,pi_pagesize             => pi_pagesize
                                     ,po_cursor               => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  get_paged_node_search(pi_theme_types      => lt_theme_types(1)
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
                  get_paged_table_search(pi_theme_types    => lt_theme_types(1)
                                        ,pi_criteria       => pi_criteria
                                        ,pi_order_column   => pi_order_column
                                        ,pi_order_asc_desc => pi_order_asc_desc
                                        ,pi_skip_n_rows    => pi_skip_n_rows
                                        ,pi_pagesize       => pi_pagesize
                                        ,po_cursor         => po_cursor);
                  --
              END IF;
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

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_search_results(pi_theme_name           IN  nm_themes_all.nth_theme_name%TYPE
                                    ,pi_criteria             IN  XMLTYPE
                                    ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                                    ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                    ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                                    ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                                    ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                                    ,pi_include_enddated     IN  VARCHAR2 DEFAULT 'N'
                                    ,pi_filter_columns       IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_filter_operators     IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_filter_values_1      IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                    ,pi_filter_values_2      IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                    ,pi_order_columns        IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                    ,pi_order_asc_desc       IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                    ,pi_skip_n_rows          IN  PLS_INTEGER
                                    ,pi_pagesize             IN  PLS_INTEGER
                                    ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor       OUT sys_refcursor
                                    ,po_cursor               OUT sys_refcursor)
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
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_paged_network_search(pi_theme_types      => lt_theme_types(1)
                                      ,pi_criteria         => pi_criteria
                                      ,pi_include_enddated => pi_include_enddated
                                      ,pi_filter_columns   => pi_filter_columns
                                      ,pi_filter_operators => pi_filter_operators
                                      ,pi_filter_values_1  => pi_filter_values_1
                                      ,pi_filter_values_2  => pi_filter_values_2
                                      ,pi_order_columns    => pi_order_columns
                                      ,pi_order_asc_desc   => pi_order_asc_desc
                                      ,pi_skip_n_rows      => pi_skip_n_rows
                                      ,pi_pagesize         => pi_pagesize
                                      ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_paged_assets_search(pi_theme_types          => lt_theme_types(1)
                                     ,pi_criteria             => pi_criteria
                                     ,pi_net_filter_ne_id     => pi_net_filter_ne_id
                                     ,pi_net_filter_marker_id => pi_net_filter_marker_id
                                     ,pi_net_filter_from      => pi_net_filter_from
                                     ,pi_net_filter_to        => pi_net_filter_to
                                     ,pi_net_filter_nse_id    => pi_net_filter_nse_id
                                     ,pi_include_enddated     => pi_include_enddated
                                     ,pi_filter_columns       => pi_filter_columns
                                     ,pi_filter_operators     => pi_filter_operators
                                     ,pi_filter_values_1      => pi_filter_values_1
                                     ,pi_filter_values_2      => pi_filter_values_2
                                     ,pi_order_columns        => pi_order_columns
                                     ,pi_order_asc_desc       => pi_order_asc_desc
                                     ,pi_skip_n_rows          => pi_skip_n_rows
                                     ,pi_pagesize             => pi_pagesize
                                     ,po_cursor               => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  get_paged_node_search(pi_theme_types      => lt_theme_types(1)
                                       ,pi_criteria         => pi_criteria
                                       ,pi_include_enddated => pi_include_enddated
                                       ,pi_filter_columns   => pi_filter_columns
                                       ,pi_filter_operators => pi_filter_operators
                                       ,pi_filter_values_1  => pi_filter_values_1
                                       ,pi_filter_values_2  => pi_filter_values_2
                                       ,pi_order_columns    => pi_order_columns
                                       ,pi_order_asc_desc   => pi_order_asc_desc
                                       ,pi_skip_n_rows      => pi_skip_n_rows
                                       ,pi_pagesize         => pi_pagesize
                                       ,po_cursor           => po_cursor);
                  --
              ELSE
                  --
                  get_paged_table_search(pi_theme_types      => lt_theme_types(1)
                                        ,pi_criteria         => pi_criteria
                                        ,pi_filter_columns   => pi_filter_columns
                                        ,pi_filter_operators => pi_filter_operators
                                        ,pi_filter_values_1  => pi_filter_values_1
                                        ,pi_filter_values_2  => pi_filter_values_2
                                        ,pi_order_columns    => pi_order_columns
                                        ,pi_order_asc_desc   => pi_order_asc_desc
                                        ,pi_skip_n_rows      => pi_skip_n_rows
                                        ,pi_pagesize         => pi_pagesize
                                        ,po_cursor           => po_cursor);
                  --
              END IF;
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

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_results_by_id(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                             ,pi_ids              IN  id_tab
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
    lt_ids          nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        --
        FOR i IN 1..pi_ids.COUNT LOOP
          --
          lt_ids.extend;
          lt_ids(i) := nm_ne_id_type(pi_ids(i));
          --
        END LOOP;
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_network_results(pi_theme_types      => lt_theme_types(1)
                                 ,pi_ids              => lt_ids
                                 ,pi_include_enddated => pi_include_enddated
                                 ,pi_order_column     => pi_order_column
                                 ,pi_order_asc_desc   => pi_order_asc_desc
                                 ,pi_max_rows         => pi_max_rows
                                 ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_assets_results(pi_theme_types      => lt_theme_types(1)
                                ,pi_ids              => lt_ids
                                ,pi_include_enddated => pi_include_enddated
                                ,pi_order_column     => pi_order_column
                                ,pi_order_asc_desc   => pi_order_asc_desc
                                ,pi_max_rows         => pi_max_rows
                                ,po_cursor           => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  get_node_results(pi_theme_types      => lt_theme_types(1)
                                  ,pi_ids              => lt_ids
                                  ,pi_include_enddated => pi_include_enddated
                                  ,pi_order_column     => pi_order_column
                                  ,pi_order_asc_desc   => pi_order_asc_desc
                                  ,pi_max_rows         => pi_max_rows
                                  ,po_cursor           => po_cursor);
                  --
              ELSE
                  get_table_results(pi_theme_types    => lt_theme_types(1)
                                   ,pi_ids            => lt_ids
                                   ,pi_order_column   => pi_order_column
                                   ,pi_order_asc_desc => pi_order_asc_desc
                                   ,pi_max_rows       => pi_max_rows
                                   ,po_cursor         => po_cursor);
              END IF;
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
  END get_results_by_id;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_results_by_id_csv(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                 ,pi_ids              IN  id_tab
                                 ,pi_include_wkt      IN  VARCHAR2 DEFAULT 'N'
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lt_ids          nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        --
        FOR i IN 1..pi_ids.COUNT LOOP
          --
          lt_ids.extend;
          lt_ids(i) := nm_ne_id_type(pi_ids(i));
          --
        END LOOP;
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_network_results_csv(pi_theme_types      => lt_theme_types(1)
                                     ,pi_ids              => lt_ids
                                     ,pi_include_wkt      => pi_include_wkt
                                     ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_asset_results_csv(pi_theme_types => lt_theme_types(1)
                                   ,pi_ids         => lt_ids
                                   ,pi_include_wkt => pi_include_wkt
                                   ,po_cursor      => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  get_node_results_csv(pi_theme_types => lt_theme_types(1)
                                      ,pi_ids         => lt_ids
                                      ,pi_include_wkt => pi_include_wkt
                                      ,po_cursor      => po_cursor);
                  --
              ELSE
                  get_table_results_csv(pi_theme_types => lt_theme_types(1)
                                       ,pi_ids         => lt_ids
                                       ,pi_include_wkt => pi_include_wkt
                                       ,po_cursor      => po_cursor);
              END IF;
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
  END get_results_by_id_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_all_results_csv(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                               ,pi_max_rows         IN  NUMBER DEFAULT NULL
                               ,pi_include_wkt      IN  VARCHAR2 DEFAULT 'N'
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lt_ids          nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        --
        get_all_table_results_csv(pi_theme_types => lt_theme_types(1)
                                 ,pi_max_rows    => pi_max_rows
                                 ,pi_include_wkt => pi_include_wkt
                                 ,po_cursor      => po_cursor);
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
  END get_all_results_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_results_by_id(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                   ,pi_ids              IN  id_tab
                                   ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                   ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                   ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                   ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                   ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                   ,pi_skip_n_rows      IN  PLS_INTEGER
                                   ,pi_pagesize         IN  PLS_INTEGER
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lt_ids          nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        --
        FOR i IN 1..pi_ids.COUNT LOOP
          --
          lt_ids.extend;
          lt_ids(i) := nm_ne_id_type(pi_ids(i));
          --
        END LOOP;
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              get_paged_network_results(pi_theme_types      => lt_theme_types(1)
                                       ,pi_ids              => lt_ids
                                       ,pi_include_enddated => pi_include_enddated
                                       ,pi_filter_columns   => pi_filter_columns
                                       ,pi_filter_operators => pi_filter_operators
                                       ,pi_filter_values_1  => pi_filter_values_1
                                       ,pi_filter_values_2  => pi_filter_values_2
                                       ,pi_order_columns    => pi_order_columns
                                       ,pi_order_asc_desc   => pi_order_asc_desc
                                       ,pi_skip_n_rows      => pi_skip_n_rows
                                       ,pi_pagesize         => pi_pagesize
                                       ,po_cursor           => po_cursor);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              get_paged_assets_results(pi_theme_types      => lt_theme_types(1)
                                      ,pi_ids              => lt_ids
                                      ,pi_include_enddated => pi_include_enddated
                                      ,pi_filter_columns   => pi_filter_columns
                                      ,pi_filter_operators => pi_filter_operators
                                      ,pi_filter_values_1  => pi_filter_values_1
                                      ,pi_filter_values_2  => pi_filter_values_2
                                      ,pi_order_columns    => pi_order_columns
                                      ,pi_order_asc_desc   => pi_order_asc_desc
                                      ,pi_skip_n_rows      => pi_skip_n_rows
                                      ,pi_pagesize         => pi_pagesize
                                      ,po_cursor           => po_cursor);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  get_paged_node_results(pi_theme_types      => lt_theme_types(1)
                                        ,pi_ids              => lt_ids
                                        ,pi_include_enddated => pi_include_enddated
                                        ,pi_filter_columns   => pi_filter_columns
                                        ,pi_filter_operators => pi_filter_operators
                                        ,pi_filter_values_1  => pi_filter_values_1
                                        ,pi_filter_values_2  => pi_filter_values_2
                                        ,pi_order_columns    => pi_order_columns
                                        ,pi_order_asc_desc   => pi_order_asc_desc
                                        ,pi_skip_n_rows      => pi_skip_n_rows
                                        ,pi_pagesize         => pi_pagesize
                                        ,po_cursor           => po_cursor);
              ELSE
                  --
                  get_paged_table_results(pi_theme_types      => lt_theme_types(1)
                                         ,pi_ids              => lt_ids
                                         ,pi_filter_columns   => pi_filter_columns
                                         ,pi_filter_operators => pi_filter_operators
                                         ,pi_filter_values_1  => pi_filter_values_1
                                         ,pi_filter_values_2  => pi_filter_values_2
                                         ,pi_order_columns    => pi_order_columns
                                         ,pi_order_asc_desc   => pi_order_asc_desc
                                         ,pi_skip_n_rows      => pi_skip_n_rows
                                         ,pi_pagesize         => pi_pagesize
                                         ,po_cursor           => po_cursor);
                  --
              END IF;
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
  END get_paged_results_by_id;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_results_column_data(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                   ,pi_include_enddated IN  VARCHAR2 DEFAULT 'N'
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lt_column_data  awlrs_util.column_data_tab;
    lt_cursor_data  awlrs_column_data_tab := awlrs_column_data_tab();
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        --
        CASE
          WHEN lt_theme_types(1).network_type IS NOT NULL
           THEN
              --
              set_network_column_data(pi_nt_type     => lt_theme_types(1).network_type
                                     ,po_column_data => lt_column_data);
              --
          WHEN lt_theme_types(1).asset_type IS NOT NULL
           THEN
              --
              lr_nit := nm3get.get_nit(lt_theme_types(1).asset_type);
              --
              set_asset_column_data(pi_nit_rec          => lr_nit
                                   ,pi_include_enddated => pi_include_enddated
                                   ,po_column_data      => lt_column_data);
              --
          ELSE
              --
              IF is_node_layer(pi_feature_table => lt_theme_types(1).feature_table)
               THEN
                  --
                  set_node_column_data(pi_feature_table => lt_theme_types(1).feature_table
                                      ,po_column_data   => lt_column_data);

                  --
              ELSE
                  --
                  set_table_column_data(pi_table_name  => lt_theme_types(1).feature_table
                                       ,pi_pk_column   => lt_theme_types(1).feature_pk_column
                                       ,po_column_data => lt_column_data);
                  --
              END IF;
              --
        END CASE;
        --
        FOR i IN 1..lt_column_data.COUNT LOOP
          --
          lt_cursor_data.extend;
          lt_cursor_data(i) := awlrs_column_data_rec(lt_column_data(i).cursor_col
                                                    ,lt_column_data(i).query_col
                                                    ,lt_column_data(i).datatype
                                                    ,lt_column_data(i).mask
                                                    ,lt_column_data(i).field_length
                                                    ,lt_column_data(i).decimal_places);
          --
        END LOOP;
        --
        OPEN po_cursor FOR
        SELECT cursor_col
              ,datatype
              ,mask
              ,field_length
              ,decimal_places
          FROM TABLE(lt_cursor_data)
             ;
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
  END get_results_column_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_network_types(pi_filter           IN  VARCHAR2
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
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                     ||CHR(10)||'SELECT nt_type'
                                     ||CHR(10)||'      ,name'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,results.*'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (SELECT nt_type nt_type'
                                     ||CHR(10)||'                      ,nt_unique||'' - ''||nt_descr name'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(nt_unique) = f.filter_value THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(nt_descr) = f.filter_value THEN 2'
                                     ||CHR(10)||'                         WHEN UPPER(nt_unique) LIKE f.filter_value||''%'' THEN 3'
                                     ||CHR(10)||'                         WHEN UPPER(nt_descr) LIKE f.filter_value||''%'' THEN 4'
                                     ||CHR(10)||'                         ELSE 5'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_types'
                                     ||CHR(10)||'                      ,filter_tab f'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'                 WHERE UPPER(nt_unique||'' - ''||nt_descr) LIKE ''%''||f.filter_value||''%''';
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
                     ||CHR(10)||'                 ORDER BY match_quality,nt_unique) results)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
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
  END get_list_of_network_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_group_types(pi_nt_type          IN  nm_types.nt_type%TYPE
                                   ,pi_filter           IN  VARCHAR2
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
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                     ||CHR(10)||'SELECT group_type'
                                     ||CHR(10)||'      ,name'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,results.*'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (SELECT ngt_group_type group_type'
                                     ||CHR(10)||'                      ,ngt_descr name'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(ngt_descr) = f.filter_value THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(ngt_descr) LIKE f.filter_value||''%'' THEN 2'
                                     ||CHR(10)||'                         ELSE 3'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_group_types'
                                     ||CHR(10)||'                      ,filter_tab f'
                                     ||CHR(10)||'                 WHERE ngt_nt_type = :nt_type'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'                   AND UPPER(ngt_descr) LIKE ''%''||f.filter_value||''%''';
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
                     ||CHR(10)||'                 ORDER BY match_quality,ngt_search_group_no) results)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_nt_type
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_nt_type
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
  END get_list_of_group_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_marker_types(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                    ,pi_filter           IN  VARCHAR2
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
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH params AS(SELECT hig.get_user_or_sys_opt(pi_option => ''DEFITEMTYP'') def_type'
                                     ||CHR(10)||'                     ,UPPER(:filter) filter_value'
                                     ||CHR(10)||'                 FROM dual)'
                                     ||CHR(10)||'SELECT inv_type'
                                     ||CHR(10)||'      ,inv_type_name'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,types.*'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (SELECT nit.nit_inv_type inv_type'
                                     ||CHR(10)||'                      ,nit.nit_inv_type||'' - ''||nit.nit_descr    inv_type_name'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN nit.nit_inv_type = p.def_type THEN 0'
                                     ||CHR(10)||'                         WHEN p.filter_value IS NULL THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(nit.nit_inv_type) = p.filter_value THEN 2'
                                     ||CHR(10)||'                         WHEN UPPER(nit.nit_descr) = p.filter_value THEN 3'
                                     ||CHR(10)||'                         WHEN UPPER(nit.nit_inv_type) LIKE p.filter_value||''%'' THEN 4'
                                     ||CHR(10)||'                         WHEN UPPER(nit.nit_descr) LIKE p.filter_value||''%'' THEN 5'
                                     ||CHR(10)||'                         ELSE 6'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_inv_types nit'
                                     ||CHR(10)||'                      ,nm_inv_nw nin'
                                     ||CHR(10)||'                      ,nm_nt_groupings nng'
                                     ||CHR(10)||'                      ,nm_elements'
                                     ||CHR(10)||'                      ,params p'
                                     ||CHR(10)||'                 WHERE ne_id = :ne_id'
                                     ||CHR(10)||'                   AND ne_gty_group_type = nng.nng_group_type'
                                     ||CHR(10)||'                   AND nng.nng_nt_type = nin.nin_nw_type'
                                     ||CHR(10)||'                   AND nin.nin_nit_inv_code = nit.nit_inv_type'
                                     ||CHR(10)||'                   AND nit.nit_pnt_or_cont = ''P'''
                                     ||CHR(10)||'                   AND nit.nit_category in (''I'', ''D'')'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'                   AND UPPER(nit.nit_inv_type||'' - ''||nit.nit_descr) LIKE ''%''||p.filter_value||''%''';
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
                     ||CHR(10)||'                 ORDER BY match_quality, nit.nit_descr) types)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_ne_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_ne_id
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
  END get_list_of_marker_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_marker_items(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                    ,pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                    ,pi_filter           IN  VARCHAR2
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
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                     ||CHR(10)||'SELECT id'
                                     ||CHR(10)||'      ,item_name'
                                     ||CHR(10)||'      ,offset'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,id'
                                     ||CHR(10)||'              ,SUBSTR(iit_descr||'' @ ''||offset||'' ''||unit_name,1,2000) item_name'
                                     ||CHR(10)||'              ,offset'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (SELECT iit.iit_ne_id id'
                                     ||CHR(10)||'                      ,iit.iit_descr'
                                     ||CHR(10)||'                      ,un_grp.un_unit_name unit_name'
                                     ||CHR(10)||'                      ,TO_NUMBER(nm3unit.get_formatted_value(CASE'
                                     ||CHR(10)||'                                                               WHEN nm_r.nm_cardinality = 1 THEN nm3unit.convert_unit(nt_dat.nt_length_unit,nt_grp.nt_length_unit,nm_i.nm_begin_mp)'
                                     ||CHR(10)||'                                                               ELSE nm3unit.convert_unit(nt_dat.nt_length_unit,nt_grp.nt_length_unit,ne_dat.ne_length - nm_i.nm_begin_mp)'
                                     ||CHR(10)||'                                                             END + nm_r.nm_slk'
                                     ||CHR(10)||'                                                            ,nt_grp.nt_length_unit)) offset'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(iit.iit_descr) = f.filter_value THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(iit.iit_descr) LIKE f.filter_value||''%'' THEN 2'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_members nm_r'
                                     ||CHR(10)||'                      ,nm_elements ne_grp'
                                     ||CHR(10)||'                      ,nm_types nt_grp'
                                     ||CHR(10)||'                      ,nm_units un_grp'
                                     ||CHR(10)||'                      ,nm_elements ne_dat'
                                     ||CHR(10)||'                      ,nm_types nt_dat'
                                     ||CHR(10)||'                      ,nm_members nm_i'
                                     ||CHR(10)||'                      ,nm_inv_items iit'
                                     ||CHR(10)||'                      ,filter_tab f'
                                     ||CHR(10)||'                 WHERE nm_r.nm_ne_id_in = :pi_ne_id'
                                     ||CHR(10)||'                   AND nm_r.nm_ne_id_in = ne_grp.ne_id'
                                     ||CHR(10)||'                   AND ne_grp.ne_nt_type = nt_grp.nt_type'
                                     ||CHR(10)||'                   AND nt_grp.nt_length_unit = un_grp.un_unit_id'
                                     ||CHR(10)||'                   AND nm_r.nm_ne_id_of = ne_dat.ne_id'
                                     ||CHR(10)||'                   AND ne_dat.ne_nt_type = nt_dat.nt_type'
                                     ||CHR(10)||'                   AND nm_r.nm_ne_id_of = nm_i.nm_ne_id_of'
                                     ||CHR(10)||'                   AND nm_i.nm_obj_type = :pi_inv_type'
                                     ||CHR(10)||'                   AND nm_i.nm_ne_id_in = iit.iit_ne_id'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'           AND UPPER(iit.iit_descr) LIKE ''%''||f.filter_value||''%''';
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
                     ||CHR(10)||'         ORDER BY match_quality, iit.iit_descr))'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_ne_id
             ,pi_inv_type
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_ne_id
             ,pi_inv_type
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
  END get_list_of_marker_items;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_elements(pi_nt_type          IN  nm_types.nt_type%TYPE
                                ,pi_group_type       IN  nm_group_types_all.ngt_group_type%TYPE DEFAULT NULL
                                ,pi_filter           IN  VARCHAR2
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
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
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
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = ''Y'' THEN (SELECT MIN(nm_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)'
                                     ||CHR(10)||'                         ELSE NULL'
                                     ||CHR(10)||'                       END min_offset'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NULL THEN ne_length'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = ''Y'' THEN (SELECT MAX(nm_end_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)'
                                     ||CHR(10)||'                         ELSE NULL'
                                     ||CHR(10)||'                       END max_offset'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(ne_unique) = f.filter_value THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(ne_descr) = f.filter_value THEN 2'
                                     ||CHR(10)||'                         WHEN UPPER(ne_unique) LIKE f.filter_value||''%'' THEN 3'
                                     ||CHR(10)||'                         WHEN UPPER(ne_descr) LIKE f.filter_value||''%'' THEN 4'
                                     ||CHR(10)||'                         ELSE 5'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_group_types'
                                     ||CHR(10)||'                      ,nm_elements'
                                     ||CHR(10)||'                      ,filter_tab f'
                                     ||CHR(10)||'                 WHERE ne_nt_type = :nt_type'
                                     ||CHR(10)||'                   AND ne_gty_group_type = ngt_group_type(+)'
    ;
    --
  BEGIN
    /*
    ||Set the group type.
    */
    IF pi_group_type IS NOT NULL
     THEN
        lv_cursor_sql := lv_cursor_sql||CHR(10)||'                   AND ne_gty_group_type = :grp_type';
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
        IF pi_group_type IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_nt_type
                 ,pi_group_type
                 ,lv_lower_index
                 ,lv_upper_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_nt_type
                 ,lv_lower_index
                 ,lv_upper_index;
        END IF;
    ELSE
        IF pi_group_type IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_nt_type
                 ,pi_group_type
                 ,lv_lower_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_nt_type
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
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_extents(pi_filter           IN  VARCHAR2
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
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                     ||CHR(10)||'SELECT id'
                                     ||CHR(10)||'      ,name'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,results.*'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (SELECT nse_id id'
                                     ||CHR(10)||'                      ,nse_name||'' - ''||nse_descr name'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(nse_name) = f.filter_value THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(nse_descr) = f.filter_value THEN 2'
                                     ||CHR(10)||'                         WHEN UPPER(nse_name) LIKE f.filter_value||''%'' THEN 3'
                                     ||CHR(10)||'                         WHEN UPPER(nse_descr) LIKE f.filter_value||''%'' THEN 4'
                                     ||CHR(10)||'                         ELSE 5'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_saved_extents'
                                     ||CHR(10)||'                      ,filter_tab f'
                                     ||CHR(10)||'                 WHERE (nse_owner = ''PUBLIC'''
                                     ||CHR(10)||'                        OR nse_owner = SYS_CONTEXT(''NM3_SECURITY_CTX'',''USERNAME''))'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'                   AND UPPER(nse_name||'' - ''||nse_descr) LIKE ''%''||f.filter_value||''%''';
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
                     ||CHR(10)||'                 ORDER BY match_quality,nse_name) results)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
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
  END get_list_of_extents;


  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_element_and_extent(pi_filter           IN  VARCHAR2
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
    lv_net_filter       nm3type.max_varchar2;
    lv_ext_filter       nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2;
    lv_net_cursor_sql   nm3type.max_varchar2 := 'SELECT id'
                                     ||CHR(10)||'      ,item_type'
                                     ||CHR(10)||'      ,item_name'
                                     ||CHR(10)||'      ,min_offset'
                                     ||CHR(10)||'      ,max_offset'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,id'
                                     ||CHR(10)||'              ,item_type'
                                     ||CHR(10)||'              ,item_name'
                                     ||CHR(10)||'              ,min_offset'
                                     ||CHR(10)||'              ,max_offset'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (WITH filter_tab AS (SELECT :filter filter_value FROM dual)'
                                     ||CHR(10)||'                SELECT ne_id id'
                                     ||CHR(10)||'                      ,ne_unique order_name'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NULL THEN ''DATUM'''
                                     ||CHR(10)||'                         WHEN ngt_linear_flag = ''Y'' THEN ''ROUTE'''
                                     ||CHR(10)||'                         ELSE ''GROUP'''
                                     ||CHR(10)||'                       END item_type'
                                     ||CHR(10)||'                      ,CASE '
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NULL THEN nt_unique'
                                     ||CHR(10)||'                         ELSE ngt_descr'
                                     ||CHR(10)||'                       END||'' - ''||ne_unique||'' - ''||ne_descr item_name'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = ''Y'' THEN (SELECT MIN(nm_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)'
                                     ||CHR(10)||'                         ELSE NULL'
                                     ||CHR(10)||'                       END min_offset'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NULL THEN ne_length'
                                     ||CHR(10)||'                         WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = ''Y'' THEN (SELECT MAX(nm_end_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)'
                                     ||CHR(10)||'                         ELSE NULL'
                                     ||CHR(10)||'                       END max_offset'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(ne_unique) = UPPER(f.filter_value) THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(ne_descr) = UPPER(f.filter_value) THEN 2'
                                     ||CHR(10)||'                         WHEN UPPER(ne_unique) LIKE UPPER(f.filter_value)||''%'' THEN 3'
                                     ||CHR(10)||'                         WHEN UPPER(ne_descr) LIKE UPPER(f.filter_value)||''%'' THEN 4'
                                     ||CHR(10)||'                         ELSE 5'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_group_types'
                                     ||CHR(10)||'                      ,nm_elements'
                                     ||CHR(10)||'                      ,nm_types'
                                     ||CHR(10)||'                      ,filter_tab f'
                                     ||CHR(10)||'                 WHERE nt_type = ne_nt_type'
                                     ||CHR(10)||'                   AND ne_gty_group_type = ngt_group_type(+)'
    ;
    lv_ext_cursor_sql   nm3type.max_varchar2 := '                UNION ALL'
                                     ||CHR(10)||'                SELECT nse_id id'
                                     ||CHR(10)||'                      ,nse_name order_name'
                                     ||CHR(10)||'                      ,''EXTENT'' item_type'
                                     ||CHR(10)||'                      ,''Saved Extent - ''||nse_name||'' - ''||nse_descr item_name'
                                     ||CHR(10)||'                      ,CAST(NULL AS NUMBER) min_offset'
                                     ||CHR(10)||'                      ,CAST(NULL AS NUMBER) max_offset'
                                     ||CHR(10)||'                      ,CASE'
                                     ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                         WHEN UPPER(nse_name) = UPPER(f.filter_value) THEN 1'
                                     ||CHR(10)||'                         WHEN UPPER(nse_descr) = UPPER(f.filter_value) THEN 2'
                                     ||CHR(10)||'                         WHEN UPPER(nse_name) LIKE UPPER(f.filter_value)||''%'' THEN 3'
                                     ||CHR(10)||'                         WHEN UPPER(nse_descr) LIKE UPPER(f.filter_value)||''%'' THEN 4'
                                     ||CHR(10)||'                         ELSE 5'
                                     ||CHR(10)||'                       END match_quality'
                                     ||CHR(10)||'                  FROM nm_saved_extents'
                                     ||CHR(10)||'                      ,filter_tab f'
                                     ||CHR(10)||'                 WHERE (nse_owner = ''PUBLIC'''
                                     ||CHR(10)||'                        OR nse_owner = SYS_CONTEXT(''NM3_SECURITY_CTX'',''USERNAME''))'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_net_filter := CHR(10)||'                   AND UPPER(ne_unique||'' - ''||ne_descr) LIKE UPPER(''%''||f.filter_value||''%'')';
        lv_ext_filter := CHR(10)||'                   AND UPPER(nse_name||'' - ''||nse_descr) LIKE UPPER(''%''||f.filter_value||''%'')';
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
    lv_cursor_sql := lv_net_cursor_sql
                     ||lv_net_filter
                     ||CHR(10)||lv_ext_cursor_sql
                     ||lv_ext_filter
                     ||CHR(10)||'                 ORDER BY match_quality,order_name))'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
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
  END get_list_of_element_and_extent;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE save_criteria(pi_theme_name           IN  nm_themes_all.nth_theme_name%TYPE
                         ,pi_name                 IN  awlrs_saved_search_criteria.assc_name%TYPE
                         ,pi_description          IN  awlrs_saved_search_criteria.assc_description%TYPE
                         ,pi_criteria             IN  awlrs_saved_search_criteria.assc_criteria%TYPE
                         ,pi_net_filter_ne_id     IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                         ,pi_net_filter_nse_id    IN  nm_saved_extents.nse_id%TYPE DEFAULT NULL
                         ,pi_net_filter_marker_id IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                         ,pi_net_filter_from      IN  NUMBER DEFAULT NULL
                         ,pi_net_filter_to        IN  NUMBER DEFAULT NULL
                         ,pi_overwrite_existing   IN  VARCHAR2 DEFAULT 'N'
                         ,po_message_severity     OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    lv_ass_id  awlrs_saved_search_criteria.assc_id%TYPE;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    lt_messages     awlrs_message_tab := awlrs_message_tab();
    --
    CURSOR search_exists(cp_name IN awlrs_saved_search_criteria.assc_name%TYPE)
        IS
    SELECT assc_id
      FROM awlrs_saved_search_criteria
     WHERE assc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND assc_name = cp_name
         ;
    --
  BEGIN
    --
    lt_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     THEN
        IF pi_overwrite_existing = 'N'
         THEN
            --
            OPEN  search_exists(pi_name);
            FETCH search_exists
             INTO lv_ass_id;
            CLOSE search_exists;
            --
            IF lv_ass_id IS NOT NULL
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
             INTO awlrs_saved_search_criteria
            USING (SELECT sys_context('NM3CORE', 'USER_ID') user_id
                         ,pi_theme_name theme_name
                         ,pi_name name
                         ,pi_description descr
                         ,pi_criteria criteria
                         ,pi_net_filter_ne_id     net_filter_ne_id
                         ,pi_net_filter_nse_id    net_filter_nse_id
                         ,pi_net_filter_marker_id net_filter_marker_id
                         ,pi_net_filter_from      net_filter_from
                         ,pi_net_filter_to        net_filter_to
                     FROM DUAL) param
               ON (assc_name = param.name AND assc_user_id = param.user_id)
             WHEN MATCHED
              THEN
                 UPDATE SET assc_theme_name = param.theme_name
                           ,assc_description = param.descr
                           ,assc_criteria = param.criteria
                           ,assc_net_filter_ne_id = param.net_filter_ne_id
                           ,assc_net_filter_nse_id = param.net_filter_nse_id
                           ,assc_net_filter_marker_id = param.net_filter_marker_id
                           ,assc_net_filter_from = param.net_filter_from
                           ,assc_net_filter_to = param.net_filter_to
             WHEN NOT MATCHED
              THEN
                 INSERT(assc_id
                       ,assc_user_id
                       ,assc_theme_name
                       ,assc_name
                       ,assc_description
                       ,assc_criteria
                       ,assc_net_filter_ne_id
                       ,assc_net_filter_nse_id
                       ,assc_net_filter_marker_id
                       ,assc_net_filter_from
                       ,assc_net_filter_to
                       )
                 VALUES(assc_id_seq.NEXTVAL
                       ,param.user_id
                       ,param.theme_name
                       ,param.name
                       ,param.descr
                       ,param.criteria
                       ,param.net_filter_ne_id
                       ,param.net_filter_nse_id
                       ,param.net_filter_marker_id
                       ,param.net_filter_from
                       ,param.net_filter_to)
            ;
        END IF;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
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
  END save_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_criteria(pi_assc_id          IN  awlrs_saved_search_criteria.assc_id%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    DELETE awlrs_saved_search_criteria
     WHERE assc_id = pi_assc_id
       AND assc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
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
  END delete_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_criteria(pi_assc_id          IN  awlrs_saved_search_criteria.assc_id%TYPE
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor
                        ,po_cursor           OUT sys_refcursor)
    IS
    --
    CURSOR get_assc(cp_assc_id IN awlrs_saved_search_criteria.assc_id%TYPE)
        IS
    SELECT assc_id                   id
          ,assc_theme_name           theme_name
          ,assc_name                 name
          ,assc_description          description
          ,assc_criteria             criteria
          ,assc_net_filter_ne_id     net_filter_ne_id
          ,assc_net_filter_nse_id    net_filter_nse_id
          ,nit_inv_type              net_filter_marker_type
          ,nit_inv_type||' - '||nit_descr  net_filter_marker_type_name
          ,assc_net_filter_marker_id net_filter_marker_id
          ,assc_net_filter_from      net_filter_from
          ,assc_net_filter_to        net_filter_to
      FROM awlrs_saved_search_criteria
          ,nm_inv_items
          ,nm_inv_types
     WHERE assc_id = cp_assc_id
       AND assc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND assc_net_filter_marker_id = iit_ne_id(+)
       AND iit_inv_type = nit_inv_type(+)
         ;
    --
    lr_assc  get_assc%ROWTYPE;
    --
    CURSOR get_ne_nse(cp_ne_id  IN nm_elements_all.ne_id%TYPE
                     ,cp_nse_id IN nm_saved_extents.nse_id%TYPE)
        IS
    SELECT CASE
             WHEN ne_gty_group_type IS NULL THEN 'DATUM'
             WHEN ngt_linear_flag = 'Y' THEN 'ROUTE'
             ELSE 'GROUP'
           END net_filter_item_type
          ,CASE
             WHEN ne_gty_group_type IS NULL THEN nt_unique
             ELSE ngt_descr
           END||' - '||ne_unique||' - '||ne_descr net_filter_item_name
          ,CASE
             WHEN ne_gty_group_type IS NULL THEN 0
             WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = 'Y' THEN (SELECT MIN(nm_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)
             ELSE NULL
           END net_filter_item_min_offset
          ,CASE
             WHEN ne_gty_group_type IS NULL THEN ne_length
             WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = 'Y' THEN (SELECT MAX(nm_end_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)
             ELSE NULL
           END net_filter_item_max_offset
      FROM nm_group_types
          ,nm_elements
          ,nm_types
     WHERE nt_type = ne_nt_type
       AND ne_id = cp_ne_id
       AND ne_gty_group_type = ngt_group_type(+)
    UNION ALL
    SELECT 'EXTENT' net_filter_item_type
          ,'Saved Extent - '||nse_name||' - '||nse_descr net_filter_item_name
          ,CAST(NULL AS NUMBER) net_filter_item_min_offset
          ,CAST(NULL AS NUMBER) net_filter_item_max_offset
      FROM nm_saved_extents
     WHERE nse_id = cp_nse_id
         ;
    --
    lr_ne_nse  get_ne_nse%ROWTYPE;
    --
    CURSOR get_marker(cp_ne_id     IN nm_elements_all.ne_id%TYPE
                     ,cp_iit_ne_id IN nm_inv_items_all.iit_ne_id%TYPE)
        IS
    SELECT SUBSTR(iit_descr||' @ '||offset||' '||unit_name,1,2000) net_filter_marker_name
          ,offset net_filter_marker_offset
      FROM (SELECT iit.iit_ne_id id
                  ,iit.iit_descr
                  ,un_grp.un_unit_name unit_name
                  ,TO_NUMBER(nm3unit.get_formatted_value(CASE
                                                           WHEN nm_r.nm_cardinality = 1 THEN nm3unit.convert_unit(nt_dat.nt_length_unit,nt_grp.nt_length_unit,nm_i.nm_begin_mp)
                                                           ELSE nm3unit.convert_unit(nt_dat.nt_length_unit,nt_grp.nt_length_unit,ne_dat.ne_length - nm_i.nm_begin_mp)
                                                         END + nm_r.nm_slk
                                                        ,nt_grp.nt_length_unit)) offset
              FROM nm_members nm_r
                  ,nm_elements ne_grp
                  ,nm_types nt_grp
                  ,nm_units un_grp
                  ,nm_elements ne_dat
                  ,nm_types nt_dat
                  ,nm_members nm_i
                  ,nm_inv_items iit
             WHERE nm_r.nm_ne_id_in = cp_ne_id
               AND nm_r.nm_ne_id_in = ne_grp.ne_id
               AND ne_grp.ne_nt_type = nt_grp.nt_type
               AND nt_grp.nt_length_unit = un_grp.un_unit_id
               AND nm_r.nm_ne_id_of = ne_dat.ne_id
               AND ne_dat.ne_nt_type = nt_dat.nt_type
               AND nm_r.nm_ne_id_of = nm_i.nm_ne_id_of
               AND nm_i.nm_ne_id_in = iit.iit_ne_id
               AND iit.iit_ne_id = cp_iit_ne_id)
         ;
    --
    lr_marker  get_marker%ROWTYPE;
    --
  BEGIN
    --
    OPEN  get_assc(pi_assc_id);
    FETCH get_assc
     INTO lr_assc;
    CLOSE get_assc;
    --
    OPEN  get_ne_nse(lr_assc.net_filter_ne_id
                    ,lr_assc.net_filter_nse_id);
    FETCH get_ne_nse
     INTO lr_ne_nse;
    CLOSE get_ne_nse;
    --
    OPEN  get_marker(lr_assc.net_filter_ne_id
                    ,lr_assc.net_filter_marker_id);
    FETCH get_marker
     INTO lr_marker;
    CLOSE get_marker;
    --
    OPEN po_cursor FOR
    SELECT lr_assc.id
          ,lr_assc.theme_name
          ,lr_assc.name
          ,lr_assc.description
          ,lr_assc.criteria
          ,lr_assc.net_filter_ne_id
          ,lr_assc.net_filter_nse_id
          ,lr_ne_nse.net_filter_item_type
          ,lr_ne_nse.net_filter_item_name
          ,lr_ne_nse.net_filter_item_min_offset
          ,lr_ne_nse.net_filter_item_max_offset
          ,lr_assc.net_filter_marker_type
          ,lr_assc.net_filter_marker_type_name
          ,lr_assc.net_filter_marker_id
          ,lr_marker.net_filter_marker_name
          ,lr_marker.net_filter_marker_offset
          ,lr_assc.net_filter_from
          ,lr_assc.net_filter_to
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
  END get_criteria;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_criteria_list(po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT assc_id                   id
          ,assc_theme_name           theme_name
          ,assc_name                 name
          ,assc_description          description
      FROM awlrs_saved_search_criteria
     WHERE assc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
     ORDER
        BY assc_theme_name
          ,assc_name
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
  END get_criteria_list;

--
-----------------------------------------------------------------------------
--
BEGIN
  set_date_formats;
END awlrs_search_api;
/
