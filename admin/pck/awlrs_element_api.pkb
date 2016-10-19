CREATE OR REPLACE PACKAGE BODY awlrs_element_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_element_api.pkb-arc   1.5   19 Oct 2016 15:52:14   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_element_api.pkb  $
  --       Date into PVCS   : $Date:   19 Oct 2016 15:52:14  $
  --       Date fetched Out : $Modtime:   18 Oct 2016 20:44:36  $
  --       Version          : $Revision:   1.5  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.5  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_element_api';
  --
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version
    RETURN VARCHAR2 IS
  BEGIN
    RETURN g_sccsid;
  END get_version;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version
    RETURN VARCHAR2 IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE init_element_global
    IS
    --
    lv_empty_rec  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    g_new_element := lv_empty_rec;
    --
  END init_element_global;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE init_ad_global
    IS
    --
    lv_empty_rec  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    --
    g_prim_ad_asset := lv_empty_rec;
    --
  END init_ad_global;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_primary_ad_inv_type(pi_nt_type    IN nm_types.nt_type%TYPE
                                  ,pi_group_type IN nm_group_types_all.ngt_group_type%TYPE)
    RETURN nm_inv_types_all.nit_inv_type%TYPE IS
    --
    lv_retval nm_inv_types_all.nit_inv_type%TYPE;
    --
  BEGIN
    --
    IF pi_group_type IS NOT NULL
     THEN
        lv_retval := nm3nwad.get_prim_nadt(pi_nt_type  => pi_nt_type
                                          ,pi_gty_type => pi_group_type).nad_inv_type;
    ELSE
        lv_retval := nm3nwad.get_prim_nadt(pi_nt_type => pi_nt_type).nad_inv_type;
    END IF;
    --
    RETURN lv_retval;
    --
  END get_primary_ad_inv_type;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gen_domain_name(pi_nt_type     IN nm_types.nt_type%TYPE
                          ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE)
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN pi_nt_type||'_'||pi_column_name;
    --
  END;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_ne_id(pi_element_name IN VARCHAR2)
    RETURN nm_elements_all.ne_id%TYPE IS
    --
    lv_ne_id  nm_elements_all.ne_id%TYPE;
    --
    CURSOR get_esu(cp_element_name IN VARCHAR2)
        IS
    SELECT ne_id
      FROM nm_elements
     WHERE ne_nt_type = 'ESU'
       AND ne_name_1 = cp_element_name
     ORDER
        BY TO_NUMBER(ne_owner) desc
         ;
    --
    CURSOR get_street(cp_element_name IN VARCHAR2)
        IS
    SELECT ne_id
      FROM nm_elements
     WHERE ne_nt_type = 'NSGN'
       AND ne_number = cp_element_name
     ORDER
        BY TO_NUMBER(ne_prefix) desc
         ;
    --
  BEGIN
    --
    BEGIN
      lv_ne_id := nm3net.get_ne_id(p_ne_unique => pi_element_name);
    EXCEPTION
      WHEN others
       THEN
          NULL;
    END;
    --
    IF lv_ne_id IS NULL
     THEN
        OPEN  get_esu(pi_element_name);
        FETCH get_esu
         INTO lv_ne_id;
        CLOSE get_esu;
    END IF;
    --
    IF lv_ne_id IS NULL
     THEN
        OPEN  get_street(pi_element_name);
        FETCH get_street
         INTO lv_ne_id;
        CLOSE get_street;
    END IF;
    --
    IF lv_ne_id IS NULL
     THEN
        --Unable to derive an Id for given Element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 2
                     ,pi_supplementary_info => pi_element_name);
    END IF;
    --
    RETURN lv_ne_id;
    --
  EXCEPTION
    WHEN others
     THEN
        --Unable to derive an Id for given Element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 2
                     ,pi_supplementary_info => pi_element_name);
  END get_ne_id;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_domain_sql_with_bind(pi_nt_type     IN nm_types.nt_type%TYPE
                                   ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN nm3flx.build_lov_sql_string(p_nt_type                    => pi_nt_type
                                      ,p_column_name                => pi_column_name
                                      ,p_include_bind_variable      => TRUE);
  END get_domain_sql_with_bind;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_flx_col_value(pi_ne_id                  IN nm_elements.ne_id%TYPE
                               ,pi_column_name            IN nm_type_columns.ntc_column_name%TYPE
                               ,pi_prompt_text            IN nm_type_columns.ntc_prompt%TYPE
                               ,pi_disp_validation_errors IN BOOLEAN DEFAULT FALSE
                               ,pi_continue_after_val_err IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_value    VARCHAR2(240);
    lv_meaning  VARCHAR2(240);
    --
    e_col_mandatory EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_col_mandatory, -20602);
    --
    e_val_too_long EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_val_too_long, -20603);
    --
    e_val_invalid_for_domain EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_val_invalid_for_domain, -20604);
    --
    e_too_many_records EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_too_many_records, -20605);
    --
    e_val_invalid_for_format_mask EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_val_invalid_for_format_mask, -20606);
    --
    e_too_many_bind_variables EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_too_many_bind_variables, -20609);
    --
    e_no_bind_variable EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_bind_variable, -20610);
    --
    e_error_in_sql EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_error_in_sql, -20611);
    --
    FUNCTION handle_error(pi_err_app     IN varchar2
                         ,pi_err_no      IN varchar2
                         ,pi_err_type    IN varchar2 DEFAULT 'E'
                         ,pi_prompt_text IN nm_type_columns.ntc_prompt%TYPE)
      RETURN BOOLEAN IS
      --
      lv_retval BOOLEAN := TRUE;
      --
    BEGIN
      --
      IF pi_disp_validation_errors
       THEN
          hig.raise_ner(pi_appl               => pi_err_app
                       ,pi_id                 => pi_err_no
                       ,pi_supplementary_info => CHR(10)||CHR(10)||pi_prompt_text);
      END IF;
      /*
      ||TODO - Forms app can continue after an error is displayed to the user
      ||obviously this API can't raise an exception and continue.
      */
      --IF NOT(pi_continue_after_val_err)
      -- THEN
      --    lv_retval := FALSE;
      --END IF;
      --
      RETURN FALSE; --lv_retval;
      --
    END;
    --
  BEGIN
    --
    nm3flx.get_flx_col_data(pi_ne_id       => pi_ne_id
                           ,pi_column_name => pi_column_name
                           ,po_value       => lv_value
                           ,po_meaning     => lv_meaning);
    --
    RETURN lv_value;
    --
  EXCEPTION
    WHEN e_col_mandatory
     THEN
        IF NOT(handle_error(pi_err_app     => 'HIG'
                           ,pi_err_no      => 107
                           ,pi_err_type    => 'W'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_val_too_long
     THEN
        IF NOT(handle_error(pi_err_app     => 'HIG'
                           ,pi_err_no      => 108
                           ,pi_err_type    => 'W'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_val_invalid_for_domain
     THEN
        IF NOT(handle_error(pi_err_app     => 'HIG'
                           ,pi_err_no      => 109
                           ,pi_err_type    => 'W'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_too_many_records
     THEN
        IF NOT(handle_error(pi_err_app     => 'NET'
                           ,pi_err_no      => 47
                           ,pi_err_type    => 'E'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_val_invalid_for_format_mask
     THEN
        IF NOT(handle_error(pi_err_app     => 'HIG'
                           ,pi_err_no      => 70
                           ,pi_err_type    => 'W'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_too_many_bind_variables
     THEN
        IF NOT(handle_error(pi_err_app     => 'NET'
                           ,pi_err_no      => 48
                           ,pi_err_type    => 'E'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_no_bind_variable
     THEN
        IF NOT(handle_error(pi_err_app     => 'NET'
                           ,pi_err_no      => 48
                           ,pi_err_type    => 'E'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
    WHEN e_error_in_sql
     THEN
        IF NOT(handle_error(pi_err_app     => 'HIG'
                           ,pi_err_no      => 83
                           ,pi_err_type    => 'E'
                           ,pi_prompt_text => pi_prompt_text))
         THEN
            RAISE;
        END IF;
  END get_nt_flx_col_value;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domain(pi_nt_type     IN  nm_types.nt_type%TYPE
                              ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                              ,pi_bind_value  IN  VARCHAR2 DEFAULT NULL
                              ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT NVL(lov_value,lov_code) code'
                                ||CHR(10)||'      ,lov_meaning meaning'
                                ||CHR(10)||'  FROM (SELECT NULL lov_code, NULL lov_meaning, NULL lov_value FROM DUAL WHERE 1=2';
    lv_lov_sql  nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_lov_sql := get_domain_sql_with_bind(pi_nt_type     => pi_nt_type
                                          ,pi_column_name => pi_column_name);
    --
    IF lv_lov_sql IS NOT NULL
     THEN
        --
        lv_cursor_sql := lv_cursor_sql
              ||CHR(10)||'UNION ALL'
              ||CHR(10)||'SELECT sql.* FROM ('||lv_lov_sql||') sql'
        ;
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql||')';
    --
    IF nm3flx.extract_bind_variable(lv_lov_sql) IS NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql USING pi_bind_value;
    END IF;
    --
  END get_nt_flex_domain;


  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domain(pi_nt_type          IN  nm_types.nt_type%TYPE
                              ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                              ,pi_bind_value       IN  VARCHAR2 DEFAULT NULL
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_nt_flex_domain(pi_nt_type     => pi_nt_type
                      ,pi_column_name => pi_column_name
                      ,pi_bind_value  => pi_bind_value
                      ,po_cursor      => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_flex_domain;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_flex_domain(pi_nt_type     IN  nm_types.nt_type%TYPE
                             ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                             ,pi_bind_value  IN  VARCHAR2 DEFAULT NULL)
    RETURN domain_values_tab IS
    lv_cursor         sys_refcursor;
    lt_domain_values  domain_values_tab;
    --
  BEGIN
    --
    get_nt_flex_domain(pi_nt_type     => pi_nt_type
                      ,pi_column_name => pi_column_name
                      ,pi_bind_value  => pi_bind_value
                      ,po_cursor      => lv_cursor);
    --
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_domain_values;
    CLOSE lv_cursor;
    --
    RETURN lt_domain_values;
    --
  END get_nt_flex_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domains(pi_nt_type IN  nm_types.nt_type%TYPE
                               ,po_cursor  OUT sys_refcursor)
    IS
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT domain'
                                ||CHR(10)||'      ,NVL(lov_value,lov_code) code'
                                ||CHR(10)||'      ,lov_meaning meaning'
                                ||CHR(10)||'  FROM (SELECT NULL domain, NULL lov_code, NULL lov_meaning, NULL lov_value FROM DUAL WHERE 1=2';
    lv_lov_sql    nm3type.max_varchar2;
    lv_domain_id  VARCHAR2(40);
    --
    CURSOR get_cols(cp_nt_type IN nm_types.nt_type%TYPE)
        IS
    SELECT ntc_nt_type
          ,ntc_column_name
          ,ntc_domain
      FROM nm_type_columns
     WHERE ntc_nt_type = cp_nt_type
       AND ntc_displayed = 'Y'
         ;
    --
    TYPE cols_tab IS TABLE OF get_cols%ROWTYPE;
    lt_cols  cols_tab;
    --
  BEGIN
    --
    OPEN  get_cols(pi_nt_type);
    FETCH get_cols
     BULK COLLECT
     INTO lt_cols;
    CLOSE get_cols;
    --
    FOR i IN 1..lt_cols.COUNT LOOP
      --
      lv_lov_sql := nm3flx.build_lov_sql_string(p_nt_type     => lt_cols(i).ntc_nt_type
                                               ,p_column_name => lt_cols(i).ntc_column_name);
      --
      IF lv_lov_sql IS NOT NULL
       THEN
          --
          CASE
           WHEN lt_cols(i).ntc_domain IS NOT NULL
            THEN
               lv_domain_id := lt_cols(i).ntc_domain;
           ELSE
               lv_domain_id := gen_domain_name(pi_nt_type     => lt_cols(i).ntc_nt_type
                                              ,pi_column_name => lt_cols(i).ntc_column_name);
          END CASE;
          --
          lv_cursor_sql := lv_cursor_sql
          ||CHR(10)||'UNION ALL'
          ||CHR(10)||'SELECT '||nm3flx.string(lv_domain_id)||' domain, sql'||i||'.* FROM ('||lv_lov_sql||') sql'||i
          ;
      END IF;
      --
    END LOOP;
    --
    lv_cursor_sql := lv_cursor_sql||')';
    /*
    ||Add the primary AD Asset Type Domains
    */
    lv_cursor_sql := lv_cursor_sql||'UNION ALL'
                         ||CHR(10)||'SELECT domain'
                         ||CHR(10)||'      ,code'
                         ||CHR(10)||'      ,meaning'
                         ||CHR(10)||'  FROM(SELECT ial_domain domain'
                         ||CHR(10)||'             ,ial_value  code'
                         ||CHR(10)||'             ,ial_meaning meaning'
                         ||CHR(10)||'         FROM nm_inv_attri_lookup'
                         ||CHR(10)||'        WHERE TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'') >= NVL(ial_start_date,TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY''))'
                         ||CHR(10)||'          AND TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'') <= NVL(ial_end_date,TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY''))'
                         ||CHR(10)||'          AND ial_domain IN(SELECT ita_id_domain'
                         ||CHR(10)||'                              FROM nm_inv_type_attribs'
                         ||CHR(10)||'                                  ,nm_nw_ad_types'
                         ||CHR(10)||'                             WHERE nad_nt_type = :nt_type'
                         ||CHR(10)||'                               AND nad_primary_ad = ''Y'''
                         ||CHR(10)||'                               AND nad_inv_type = ita_inv_type'
                         ||CHR(10)||'                               AND ita_id_domain IS NOT NULL)'
                         ||CHR(10)||'        ORDER BY ial_domain,ial_seq)'
    ;
    --
    OPEN po_cursor FOR lv_cursor_sql USING pi_nt_type;
    --
  END get_nt_flex_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domains(pi_nt_type          IN  nm_types.nt_type%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_nt_flex_domains(pi_nt_type => pi_nt_type
                       ,po_cursor  => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_flex_domains;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_flex_domains(pi_nt_type IN  nm_types.nt_type%TYPE)
    RETURN domain_name_and_values_tab IS
    lv_cursor         sys_refcursor;
    lt_domain_values  domain_name_and_values_tab;
    --
  BEGIN
    --
    get_nt_flex_domains(pi_nt_type => pi_nt_type
                       ,po_cursor  => lv_cursor);
    --
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_domain_values;
    CLOSE lv_cursor;
    --
    RETURN lt_domain_values;
    --
  END get_nt_flex_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_attribs(pi_ne_id          IN  nm_elements_all.ne_id%TYPE
                               ,pi_nt_type        IN  nm_types.nt_type%TYPE
                               ,pi_disp_derived   IN  BOOLEAN DEFAULT TRUE
                               ,pi_disp_inherited IN  BOOLEAN DEFAULT TRUE
                               ,po_cursor         OUT sys_refcursor)
    IS
    --
    lv_disp_derived VARCHAR2(1) := CASE WHEN pi_disp_derived THEN 'Y' ELSE 'N' END;
    lv_disp_inherited VARCHAR2(1) := CASE WHEN pi_disp_inherited THEN 'Y' ELSE 'N' END;
    lt_columns  nm3flx.tab_type_columns;
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT column_name
          ,prompt
          ,view_column_name
          ,datatype
          ,format_mask
          ,CAST(field_length AS NUMBER(4)) field_length
          ,CAST(decimal_places AS NUMBER(1)) decimal_places
          ,CAST(min_value AS NUMBER(11,3)) min_value
          ,CAST(max_value AS NUMBER(11,3)) max_value
          ,field_case
          ,CAST(domain_id AS VARCHAR2(40)) domain_id
          ,CAST(domain_bind_column AS VARCHAR2(30)) domain_bind_column
          ,CAST(char_value AS VARCHAR2(240)) char_value
          ,required
          ,updateable
      FROM (SELECT 'NE_UNIQUE' column_name
                  ,'Unique'    prompt
                  ,'NE_UNIQUE' view_column_name
                  ,'VARCHAR2'  datatype
                  ,NULL        format_mask
                  ,30          field_length
                  ,NULL        decimal_places
                  ,NULL        min_value
                  ,NULL        max_value
                  ,'UPPER'     field_case
                  ,NULL        domain_id
                  ,NULL        domain_bind_column
                  ,NULL        char_value
                  ,'Y'         required
                  ,'Y'         updateable
                  ,0           seq_no
              FROM nm_types
             WHERE nt_type = pi_nt_type
               AND nt_pop_unique = 'N'
            UNION ALL
            SELECT ntc_column_name    column_name
                  ,ntc_prompt         prompt
                  ,ntc_column_name    view_column_name
                  ,ntc_column_type    datatype
                  ,CASE
                     WHEN ntc_column_type = 'DATE'
                      THEN
                         NVL(ntc_format,'DD-MON-YYYY')
                     ELSE
                         ntc_format
                   END format_mask
                  ,CASE
                     WHEN ntc_column_type = 'DATE'
                      THEN
                         LENGTH(REPLACE(ntc_format,'24',''))
                     ELSE
                         ntc_str_length
                   END field_length
                  ,NULL               decimal_places
                  ,NULL               min_value
                  ,NULL               max_value
                  ,'UPPER'            field_case
                  ,CASE
                     WHEN domain_sql IS NOT NULL
                      THEN
                         CASE
                           WHEN ntc_domain IS NOT NULL
                            THEN
                               ntc_domain
                           ELSE
                               awlrs_element_api.gen_domain_name(pi_nt_type     => ntc_nt_type
                                                              ,pi_column_name => ntc_column_name)
                         END
                   END domain_id
                  ,REPLACE(nm3flx.extract_bind_variable(domain_sql),':',NULL) domain_bind_column
                  ,awlrs_element_api.get_nt_flx_col_value(pi_ne_id       => pi_ne_id
                                                       ,pi_column_name => ntc_column_name
                                                       ,pi_prompt_text => ntc_prompt) char_value
                  ,ntc_mandatory      required
                  ,ntc_updatable      updateable
                  ,ntc_seq_no + 1     seq_no
              FROM (SELECT ntc.*
                          ,awlrs_element_api.get_domain_sql_with_bind(pi_nt_type     => ntc_nt_type
                                                                   ,pi_column_name => ntc_column_name) domain_sql
                      FROM nm_type_columns ntc
                     WHERE ntc_nt_type = pi_nt_type
                       AND ntc_displayed = 'Y'
                       AND (lv_disp_inherited = 'Y'
                             OR ntc_inherit = 'N')
                       AND (lv_disp_derived = 'Y'
                            OR NOT EXISTS (SELECT 1
                                             FROM nm_type_inclusion
                                            WHERE nti_nw_child_type = ntc_nt_type
                                              AND ntc_column_name = nti_code_control_column)))
            UNION ALL
            SELECT ita_attrib_name   column_name
                  ,ita_scrn_text     prompt
                  ,ita_view_col_name view_column_name
                  ,ita_format        datatype
                  ,CASE
                     WHEN ita_format = 'DATE'
                      THEN
                         NVL(ita_format_mask,'DD-MON-YYYY')
                     ELSE
                         ita_format_mask
                   END format_mask
                  ,CASE
                     WHEN ita_format = 'DATE'
                      THEN
                         LENGTH(REPLACE(ita_format_mask,'24',''))
                     ELSE
                         ita_fld_length
                   END field_length
                  ,ita_dec_places    decimal_places
                  ,ita_min           min_value
                  ,ita_max           max_value
                  ,ita_case          field_case
                  ,ita_id_domain     domain_id
                  ,NULL              domain_bind_column
                  ,nm3inv.get_attrib_value(p_ne_id       => adlink.nad_iit_ne_id
                                          ,p_attrib_name => ita_attrib_name) char_value
                  ,ita_mandatory_yn  required
                  ,'Y'               updateable
                  ,ita_disp_seq_no+100 seq_no
              FROM nm_nw_ad_link adlink
                  ,nm_inv_type_attribs
                  ,nm_nw_ad_types adt
             WHERE adt.nad_nt_type = pi_nt_type
               AND adt.nad_primary_ad = 'Y'
               AND adt.nad_inv_type = ita_inv_type
               AND adt.nad_id = adlink.nad_id(+)
               AND adlink.nad_ne_id(+) = pi_ne_id)
     ORDER
        BY seq_no
          ,column_name
         ;
    --
  END get_nt_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_attribs(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                               ,pi_nt_type          IN  nm_types.nt_type%TYPE
                               ,pi_disp_derived     IN  BOOLEAN DEFAULT TRUE
                               ,pi_disp_inherited   IN  BOOLEAN DEFAULT TRUE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_nt_flex_attribs(pi_ne_id          => pi_ne_id
                       ,pi_nt_type        => pi_nt_type
                       ,pi_disp_derived   => pi_disp_derived
                       ,pi_disp_inherited => pi_disp_inherited
                       ,po_cursor         => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_flex_attribs(pi_ne_id          IN nm_elements_all.ne_id%TYPE
                              ,pi_disp_derived   IN BOOLEAN DEFAULT TRUE
                              ,pi_disp_inherited IN BOOLEAN DEFAULT TRUE
                              ,pi_nt_type        IN nm_types.nt_type%TYPE)
    RETURN flex_attr_tab IS
    --
    lv_cursor         sys_refcursor;
    lt_attrib_values  flex_attr_tab;
    --
  BEGIN
    --
    get_nt_flex_attribs(pi_ne_id          => pi_ne_id
                       ,pi_nt_type        => pi_nt_type
                       ,pi_disp_derived   => pi_disp_derived
                       ,pi_disp_inherited => pi_disp_inherited
                       ,po_cursor         => lv_cursor);
    --
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_attrib_values;
    CLOSE lv_cursor;
    --
    RETURN lt_attrib_values;
    --
  END get_nt_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE build_element_rec(pi_nt_type    IN nm_types.nt_type%TYPE
                             ,pi_global     IN VARCHAR2
                             ,pi_attributes IN flex_attr_tab)
    IS
    --
  BEGIN
    --
    FOR i IN 1..pi_attributes.count LOOP
      /*
      ||Filter out any primary AD asset attributes.
      */
      IF SUBSTR(pi_attributes(i).column_name,1,3) = 'NE_'
       THEN
          awlrs_util.set_attribute(pi_obj_type    => pi_nt_type
                                  ,pi_inv_or_ne   => 'NE'
                                  ,pi_global      => pi_global
                                  ,pi_column_name => pi_attributes(i).column_name
                                  ,pi_prompt      => pi_attributes(i).prompt
                                  ,pi_value       => pi_attributes(i).char_value);
      END IF;
      --
    END LOOP;
    --
  END build_element_rec;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE build_ad_rec(pi_inv_type   IN nm_inv_types_all.nit_inv_type%TYPE
                        ,pi_global     IN VARCHAR2
                        ,pi_attributes IN flex_attr_tab)
    IS
    --
  BEGIN
    --
    FOR i IN 1..pi_attributes.count LOOP
      /*
      ||Filter out any network element attributes.
      */
      IF SUBSTR(pi_attributes(i).column_name,1,4) = 'IIT_'
       THEN
          awlrs_util.set_attribute(pi_obj_type    => pi_inv_type
                                  ,pi_inv_or_ne   => 'INV'
                                  ,pi_global      => pi_global
                                  ,pi_column_name => pi_attributes(i).column_name
                                  ,pi_prompt      => pi_attributes(i).prompt
                                  ,pi_value       => pi_attributes(i).char_value);
      END IF;
      --
    END LOOP;
    --
  END build_ad_rec;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_elements(pi_ne_ids IN  awlrs_util.ne_id_tab
                        ,po_cursor OUT sys_refcursor)
    IS
    --
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    FOR i IN 1..pi_ne_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_ne_ids(i));
      --
    END LOOP;
    --
    OPEN po_cursor FOR
    SELECT ne_id             element_id
          ,ne_nt_type        element_network_type
          ,nt_unique         element_network_type_unique
          ,nt_descr          element_network_type_descr
          ,ne_unique         element_unique
          ,ne_gty_group_type element_group_type
          ,ngt_descr         element_group_type_descr
          ,ne_admin_unit     element_admin_unit_id
          ,nau_unit_code     element_admin_unit_code
          ,nau_name          element_admin_unit_name
          ,ne_descr          element_dercription
          ,ne_start_date     element_start_date
          ,ne_end_date       element_end_date
          ,CASE
             WHEN nt_length_unit IS NOT NULL
              THEN
                 nm3unit.convert_unit(nt_length_unit,un_unit_id,nm3net.get_ne_length(ne_id))
             ELSE
                 NULL
           END               element_length
          ,un_unit_id        element_length_unit
          ,un_unit_name      element_length_unit_name
          ,ne_no_start       start_node_id
          ,nos.no_node_name  start_node_name
          ,nos.no_descr      start_node_descr
          ,nps.np_grid_east  start_node_x
          ,nps.np_grid_north start_node_y
          ,ne_no_end         end_node_id
          ,noe.no_node_name  end_node_name
          ,noe.no_descr      end_node_descr
          ,npe.np_grid_east  end_node_x
          ,npe.np_grid_north end_node_y
     FROM nm_elements_all
         ,nm_types
         ,nm_admin_units_all
         ,nm_group_types_all
         ,nm_nodes_all nos
         ,nm_points nps
         ,nm_nodes_all noe
         ,nm_points npe
         ,(SELECT * FROM nm_units WHERE un_unit_id = Sys_Context('NM3CORE','USER_LENGTH_UNITS')) user_units
    WHERE ne_nt_type = nt_type
      AND ne_admin_unit = nau_admin_unit
      AND ne_gty_group_type = ngt_group_type(+)
      AND ne_no_start = nos.no_node_id(+)
      AND nos.no_np_id = nps.np_id(+)
      AND ne_no_end = noe.no_node_id(+)
      AND noe.no_np_id = npe.np_id(+)
      AND ne_id IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
        ;
    --
  END get_elements;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_elements(pi_ne_ids           IN  awlrs_util.ne_id_tab
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor
                        ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_elements(pi_ne_ids => pi_ne_ids
                ,po_cursor => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_elements;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_element(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor
                       ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_ids     awlrs_util.ne_id_tab;
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    lt_ids(1) := pi_ne_id;
    --
    get_elements(pi_ne_ids => lt_ids
                ,po_cursor => lv_cursor);
    --
    po_cursor := lv_cursor;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_element(pi_theme_name     IN     nm_themes_all.nth_theme_name%TYPE
                          ,pi_element_rec    IN     nm_elements_all%ROWTYPE
                          ,pi_primary_ad_rec IN     nm_inv_items_all%ROWTYPE
                          ,pi_shape_wkt      IN     CLOB
                          ,po_ne_id          IN OUT nm_elements_all.ne_id%TYPE)
    IS
    --
    lv_shape         mdsys.sdo_geometry;
    lv_srid          NUMBER;
    lv_x             NUMBER;
    lv_y             NUMBER;
    lv_prim_ad_type  nm_inv_types_all.nit_inv_type%TYPE;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    lr_nt  nm_types%ROWTYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT cre_element_sp;
    --
    lr_ne := pi_element_rec;
    lr_nt := nm3net.get_nt(pi_nt_type => lr_ne.ne_nt_type);
    /*
    ||Make sure that either start\end nodes have been passed in or a shape has been passed in.
    */
    IF lr_nt.nt_node_type IS NOT NULL
     AND (lr_ne.ne_no_start IS NULL OR lr_ne.ne_no_end IS NULL)
     AND pi_shape_wkt IS NULL
     THEN
        --Please specify both start and end nodes or a shape for the new Element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 4);
    END IF;
    /*
    ||Convert the shape to geom so we can use it for nodes if needed.
    */
    IF pi_shape_wkt IS NOT NULL
     THEN
        --
        lv_shape := awlrs_sdo.wkt_to_sdo_geom(pi_theme_name => pi_theme_name
                                           ,pi_shape      => pi_shape_wkt);
        --
    END IF;
    /*
    ||Create Nodes if needed.
    */
    IF lr_nt.nt_node_type IS NOT NULL
     AND lr_ne.ne_no_start IS NULL
     THEN
        awlrs_sdo.get_start_x_y(pi_shape => lv_shape
                               ,po_x     => lv_x
                               ,po_y     => lv_y);
        --
        awlrs_node_api.create_node(pi_type       => lr_nt.nt_node_type
                                  ,pi_name       => NULL
                                  ,pi_descr      => 'Entered by exor'
                                  ,pi_purpose    => NULL
                                  ,pi_point_id   => NULL
                                  ,pi_point_x    => lv_x
                                  ,pi_point_y    => lv_y
                                  ,pi_start_date => lr_ne.ne_start_date
                                  ,po_node_id    => lr_ne.ne_no_start);
    END IF;
    --
    IF lr_nt.nt_node_type IS NOT NULL
     AND lr_ne.ne_no_end IS NULL
     THEN
        awlrs_sdo.get_end_x_y(pi_shape => lv_shape
                             ,po_x     => lv_x
                             ,po_y     => lv_y);
        --
        awlrs_node_api.create_node(pi_type       => lr_nt.nt_node_type
                                  ,pi_name       => NULL
                                  ,pi_descr      => 'Entered by exor'
                                  ,pi_purpose    => NULL
                                  ,pi_point_id   => NULL
                                  ,pi_point_x    => lv_x
                                  ,pi_point_y    => lv_y
                                  ,pi_start_date => lr_ne.ne_start_date
                                  ,po_node_id    => lr_ne.ne_no_end);
    END IF;
    /*
    ||TODO - SM uses nm3net.gis_insert_element which calls the code below first, need to work out whether this is needed.
    IF pi_ignore_check = 'N'
     AND hig.get_sysopt('CHECKROUTE') = 'Y'
     THEN
        nm3nwval.route_check(p_ne_no_start_new  => lr_ne.ne_no_start
                            ,p_ne_no_end_new    => lr_ne.ne_no_end
                            ,p_ne_sub_class_new => lr_ne.ne_sub_class
                            ,p_ne_group_new     => lr_ne.ne_group);
    END IF;
    */
    /*
    ||TODO - passing in defaults for p_nm_cardinality and p_auto_include need to work out if this is okay.
    */
    nm3net.insert_any_element(p_rec_ne         => lr_ne
                             ,p_nm_cardinality => NULL
                             ,p_auto_include   => TRUE);
    /*
    ||Create primary AD asset if required.
    */
    lv_prim_ad_type := get_primary_ad_inv_type(pi_nt_type    => lr_ne.ne_nt_type
                                              ,pi_group_type => lr_ne.ne_gty_group_type);
    IF lv_prim_ad_type IS NOT NULL
     THEN
        nm3nwad.iit_rec_init(pi_inv_type   => lv_prim_ad_type
                            ,pi_admin_unit => lr_ne.ne_admin_unit);
        --
        g_prim_ad_asset.iit_inv_type := lv_prim_ad_type;
        g_prim_ad_asset.iit_admin_unit := lr_ne.ne_admin_unit;
        g_prim_ad_asset.iit_start_date := lr_ne.ne_start_date;
        --
        nm3nwad.add_inv_ad_to_ne(pi_ne_id   => lr_ne.ne_id
                                ,pi_rec_iit => g_prim_ad_asset);
        --
    END IF;
    --
    IF lv_shape IS NOT NULL
     THEN
        --
        nm3sdo.insert_element_shape(p_layer => nm3get.get_nth(pi_nth_theme_name => pi_theme_name).nth_theme_id
                                   ,p_ne_id => lr_ne.ne_id
                                   ,p_geom  => lv_shape);
        --
    END IF;
    po_ne_id := lr_ne.ne_id;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO cre_element_sp;
        RAISE;
  END create_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_element(pi_theme_name     IN     nm_themes_all.nth_theme_name%TYPE
                          ,pi_network_type   IN     nm_elements_all.ne_nt_type%TYPE
                          ,pi_element_type   IN     nm_elements_all.ne_type%TYPE
                          ,pi_description    IN     nm_elements_all.ne_descr%TYPE
                          ,pi_length         IN     nm_elements_all.ne_length%TYPE
                          ,pi_admin_unit_id  IN     nm_elements_all.ne_admin_unit%TYPE
                          ,pi_start_date     IN     nm_elements_all.ne_start_date%TYPE     DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                          ,pi_end_date       IN     nm_elements_all.ne_end_date%TYPE       DEFAULT NULL
                          ,pi_group_type     IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                          ,pi_start_node_id  IN     nm_elements_all.ne_no_start%TYPE       DEFAULT NULL
                          ,pi_end_node_id    IN     nm_elements_all.ne_no_end%TYPE         DEFAULT NULL
                          ,pi_unique         IN     nm_elements_all.ne_unique%TYPE         DEFAULT NULL
                          ,pi_owner          IN     nm_elements_all.ne_owner%TYPE          DEFAULT NULL
                          ,pi_name_1         IN     nm_elements_all.ne_name_1%TYPE         DEFAULT NULL
                          ,pi_name_2         IN     nm_elements_all.ne_name_2%TYPE         DEFAULT NULL
                          ,pi_prefix         IN     nm_elements_all.ne_prefix%TYPE         DEFAULT NULL
                          ,pi_number         IN     nm_elements_all.ne_number%TYPE         DEFAULT NULL
                          ,pi_sub_type       IN     nm_elements_all.ne_sub_type%TYPE       DEFAULT NULL
                          ,pi_group          IN     nm_elements_all.ne_group%TYPE          DEFAULT NULL
                          ,pi_sub_class      IN     nm_elements_all.ne_sub_class%TYPE      DEFAULT NULL
                          ,pi_nsg_ref        IN     nm_elements_all.ne_nsg_ref%TYPE        DEFAULT NULL
                          ,pi_version_no     IN     nm_elements_all.ne_version_no%TYPE     DEFAULT NULL
                          ,pi_primary_ad_rec IN     nm_inv_items_all%ROWTYPE
                          ,pi_shape_wkt      IN     CLOB
                          ,po_ne_id          IN OUT nm_elements_all.ne_id%TYPE)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    lr_ne.ne_unique         := pi_unique;
    lr_ne.ne_type           := pi_element_type;
    lr_ne.ne_nt_type        := pi_network_type;
    lr_ne.ne_descr          := pi_description;
    lr_ne.ne_length         := pi_length;
    lr_ne.ne_admin_unit     := pi_admin_unit_id;
    lr_ne.ne_start_date     := pi_start_date;
    lr_ne.ne_end_date       := pi_end_date;
    lr_ne.ne_gty_group_type := pi_group_type;
    lr_ne.ne_owner          := pi_owner;
    lr_ne.ne_name_1         := pi_name_1;
    lr_ne.ne_name_2         := pi_name_2;
    lr_ne.ne_prefix         := pi_prefix;
    lr_ne.ne_number         := pi_number;
    lr_ne.ne_sub_type       := pi_sub_type;
    lr_ne.ne_group          := pi_group;
    lr_ne.ne_no_start       := pi_start_node_id;
    lr_ne.ne_no_end         := pi_end_node_id;
    lr_ne.ne_sub_class      := pi_sub_class;
    lr_ne.ne_nsg_ref        := pi_nsg_ref;
    lr_ne.ne_version_no     := pi_version_no;
    --
    create_element(pi_theme_name     => pi_theme_name
                  ,pi_element_rec    => lr_ne
                  ,pi_primary_ad_rec => pi_primary_ad_rec
                  ,pi_shape_wkt      => pi_shape_wkt
                  ,po_ne_id          => po_ne_id);
    --
  END create_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_element(pi_theme_name      IN     nm_themes_all.nth_theme_name%TYPE
                          ,pi_network_type    IN     nm_elements_all.ne_nt_type%TYPE
                          ,pi_element_type    IN     nm_elements_all.ne_type%TYPE
                          ,pi_description     IN     nm_elements_all.ne_descr%TYPE
                          ,pi_length          IN     nm_elements_all.ne_length%TYPE
                          ,pi_admin_unit_id   IN     nm_elements_all.ne_admin_unit%TYPE
                          ,pi_start_date      IN     nm_elements_all.ne_start_date%TYPE     DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                          ,pi_end_date        IN     nm_elements_all.ne_end_date%TYPE       DEFAULT NULL
                          ,pi_group_type      IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                          ,pi_start_node_id   IN     nm_elements_all.ne_no_start%TYPE       DEFAULT NULL
                          ,pi_end_node_id     IN     nm_elements_all.ne_no_end%TYPE         DEFAULT NULL
                          ,pi_element_attribs IN     awlrs_element_api.flex_attr_tab
                          ,pi_shape_wkt       IN     CLOB
                          ,po_ne_id           IN OUT nm_elements_all.ne_id%TYPE)
    IS
    --
    lv_prim_ad_type  nm_inv_types_all.nit_inv_type%TYPE;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    lr_ad  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Process the Element details.
    */
    init_element_global;
    --
    g_new_element.ne_nt_type        := pi_network_type;
    g_new_element.ne_type           := pi_element_type;
    g_new_element.ne_descr          := pi_description;
    g_new_element.ne_length         := pi_length;
    g_new_element.ne_admin_unit     := pi_admin_unit_id;
    g_new_element.ne_start_date     := pi_start_date;
    g_new_element.ne_end_date       := pi_end_date;
    g_new_element.ne_gty_group_type := pi_group_type;
    g_new_element.ne_no_start       := pi_start_node_id;
    g_new_element.ne_no_end         := pi_end_node_id;
    --
    build_element_rec(pi_nt_type    => g_new_element.ne_nt_type
                     ,pi_global     => 'awlrs_element_api.g_new_element'
                     ,pi_attributes => pi_element_attribs);
    --
    lr_ne := g_new_element;
    /*
    ||Process any primary AD asset details.
    */
    init_ad_global;
    --
    lv_prim_ad_type := get_primary_ad_inv_type(pi_nt_type    => lr_ne.ne_nt_type
                                              ,pi_group_type => lr_ne.ne_gty_group_type);
    IF lv_prim_ad_type IS NOT NULL
     THEN
        build_ad_rec(pi_inv_type   => lv_prim_ad_type
                    ,pi_global     => 'awlrs_element_api.g_prim_ad_asset'
                    ,pi_attributes => pi_element_attribs);
        lr_ad := g_prim_ad_asset;
    END IF;
    --
    create_element(pi_theme_name     => pi_theme_name
                  ,pi_element_rec    => lr_ne
                  ,pi_primary_ad_rec => lr_ad
                  ,pi_shape_wkt      => pi_shape_wkt
                  ,po_ne_id          => po_ne_id);
    --
  END create_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_element(pi_theme_name          IN     nm_themes_all.nth_theme_name%TYPE
                          ,pi_network_type        IN     nm_elements_all.ne_nt_type%TYPE
                          ,pi_element_type        IN     nm_elements_all.ne_type%TYPE
                          ,pi_description         IN     nm_elements_all.ne_descr%TYPE
                          ,pi_length              IN     nm_elements_all.ne_length%TYPE
                          ,pi_admin_unit_id       IN     nm_elements_all.ne_admin_unit%TYPE
                          ,pi_start_date          IN     nm_elements_all.ne_start_date%TYPE     DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                          ,pi_end_date            IN     nm_elements_all.ne_end_date%TYPE       DEFAULT NULL
                          ,pi_group_type          IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                          ,pi_start_node_id       IN     nm_elements_all.ne_no_start%TYPE       DEFAULT NULL
                          ,pi_end_node_id         IN     nm_elements_all.ne_no_end%TYPE         DEFAULT NULL
                          ,pi_attrib_column_names IN     attrib_column_name_tab
                          ,pi_attrib_prompts      IN     attrib_prompt_tab
                          ,pi_attrib_char_values  IN     attrib_char_value_tab
                          ,pi_shape_wkt           IN     CLOB
                          ,po_ne_id               IN OUT nm_elements_all.ne_id%TYPE
                          ,po_message_severity       OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lt_element_attribs  flex_attr_tab;
    --
  BEGIN
    --
    IF pi_attrib_column_names.COUNT != pi_attrib_prompts.COUNT
     OR pi_attrib_column_names.COUNT != pi_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_element_api.create_element');
    END IF;
    --
    FOR i IN 1..pi_attrib_column_names.COUNT LOOP
      --
      lt_element_attribs(i).column_name := pi_attrib_column_names(i);
      lt_element_attribs(i).prompt      := pi_attrib_prompts(i);
      lt_element_attribs(i).char_value  := pi_attrib_char_values(i);
      --
    END LOOP;
    --
    create_element(pi_theme_name      => pi_theme_name
                  ,pi_network_type    => pi_network_type
                  ,pi_element_type    => pi_element_type
                  ,pi_description     => pi_description
                  ,pi_length          => pi_length
                  ,pi_admin_unit_id   => pi_admin_unit_id
                  ,pi_start_date      => pi_start_date
                  ,pi_end_date        => pi_end_date
                  ,pi_group_type      => pi_group_type
                  ,pi_start_node_id   => pi_start_node_id
                  ,pi_end_node_id     => pi_end_node_id
                  ,pi_element_attribs => lt_element_attribs
                  ,pi_shape_wkt       => pi_shape_wkt
                  ,po_ne_id           => po_ne_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reshape_element(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                           ,pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                           ,pi_shape_wkt        IN  CLOB
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_shape  mdsys.sdo_geometry;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reshape_element;
    /*
    ||Convert the shape to geom so we can use it for nodes if needed.
    */
    IF pi_shape_wkt IS NOT NULL
     THEN
        --
        lv_shape := awlrs_sdo.wkt_to_sdo_geom(pi_theme_name => pi_theme_name
                                           ,pi_shape      => pi_shape_wkt);
        --
    END IF;
    --
    nm3sdm.reshape_element(p_ne_id => pi_ne_id
                          ,p_geom  => lv_shape);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
        ROLLBACK TO reshape_element_sp;
  END reshape_element;

--
-----------------------------------------------------------------------------
--
END awlrs_element_api;
/