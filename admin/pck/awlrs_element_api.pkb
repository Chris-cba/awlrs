CREATE OR REPLACE PACKAGE BODY awlrs_element_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_element_api.pkb-arc   1.20   28 Feb 2017 09:44:26   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_element_api.pkb  $
  --       Date into PVCS   : $Date:   28 Feb 2017 09:44:26  $
  --       Date fetched Out : $Modtime:   28 Feb 2017 09:43:40  $
  --       Version          : $Revision:   1.20  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.20  $';
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
  PROCEDURE init_element_globals
    IS
    --
    lv_empty_rec  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    g_db_element := lv_empty_rec;
    g_old_element := lv_empty_rec;
    g_new_element := lv_empty_rec;
    --
  END init_element_globals;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE init_ad_globals
    IS
    --
    lv_empty_rec  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    --
    g_db_prim_ad_asset := lv_empty_rec;
    g_old_prim_ad_asset := lv_empty_rec;
    g_new_prim_ad_asset := lv_empty_rec;
    --
  END init_ad_globals;

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
  ------------------------------------------------------------------------------
  --
  FUNCTION is_nt_inclusion_parent(pi_nt_type IN nm_types.nt_type%TYPE)
    RETURN BOOLEAN IS
    --
    lv_dummy  PLS_INTEGER;
    lv_retval BOOLEAN;
    --
    CURSOR chk_inclusion(cp_type IN nm_types.nt_type%TYPE)
        IS
    SELECT 1
      FROM nm_type_inclusion
     WHERE nti_nw_parent_type = cp_type
         ;
  BEGIN
    --
    OPEN  chk_inclusion(pi_nt_type);
    FETCH chk_inclusion
     INTO lv_dummy;
    lv_retval := chk_inclusion%FOUND;
    CLOSE chk_inclusion;
    --
    RETURN lv_retval;
    --
  END is_nt_inclusion_parent;
  
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
  PROCEDURE gen_domain_sql(pi_nt_type     IN  nm_types.nt_type%TYPE
                          ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                          ,pi_bind_value  IN  VARCHAR2 DEFAULT NULL
                          ,po_sql         OUT VARCHAR2)
    IS
    --
    lv_retval    nm3type.max_varchar2 := 'SELECT NVL(lov_value,lov_code) code'
                                 ||CHR(10)||'      ,lov_meaning meaning'
                                 ||CHR(10)||'      ,lov_seq seq'
                                 ||CHR(10)||'  FROM (SELECT NULL lov_code, NULL lov_meaning, NULL lov_value, 1 lov_seq FROM DUAL WHERE 1=2';
    lv_lov_sql   nm3type.max_varchar2;
    --
  BEGIN
    --
    IF SUBSTR(pi_column_name,1,3) = 'NE_'
     THEN
        lv_lov_sql := get_domain_sql_with_bind(pi_nt_type     => pi_nt_type
                                              ,pi_column_name => pi_column_name);
        --
        IF nm3flx.extract_bind_variable(lv_lov_sql) IS NOT NULL
         THEN
            lv_lov_sql := nm3flx.build_lov_sql_string(p_nt_type                    => pi_nt_type
                                                     ,p_column_name                => pi_column_name
	 			                                             ,p_include_bind_variable      => FALSE
                                                     ,p_replace_bind_variable_with => pi_bind_value);
        END IF;
        --
        IF lv_lov_sql IS NOT NULL
         THEN
            --
            lv_retval := lv_retval
                  ||CHR(10)||'UNION ALL'
                  ||CHR(10)||'SELECT sql.*,rownum lov_seq FROM('||lv_lov_sql
                           ||CASE
                               WHEN lv_lov_sql LIKE '%ORDER BY%'
                                THEN
                                   ') sql'
                               ELSE
                                   ' ORDER BY 1) sql'
                             END
            ;
        END IF;
        --
        lv_retval := lv_retval||')';
        --
    ELSIF SUBSTR(pi_column_name,1,4) = 'IIT_'
     THEN
        --
        lv_retval := lv_retval
              ||CHR(10)||'UNION ALL'
              ||CHR(10)||'SELECT code lov_code'
              ||CHR(10)||'      ,meaning lov_meaning'
              ||CHR(10)||'      ,code lov_value'
              ||CHR(10)||'      ,seq lov_seq'
              ||CHR(10)||'  FROM(SELECT ial_value  code'
              ||CHR(10)||'             ,ial_meaning meaning'
              ||CHR(10)||'             ,ial_seq seq'
              ||CHR(10)||'         FROM nm_inv_attri_lookup'
              ||CHR(10)||'        WHERE TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'') >= NVL(ial_start_date,TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY''))'
              ||CHR(10)||'          AND TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'') <= NVL(ial_end_date,TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY''))'
              ||CHR(10)||'          AND ial_domain IN(SELECT ita_id_domain'
              ||CHR(10)||'                              FROM nm_inv_type_attribs'
              ||CHR(10)||'                                  ,nm_nw_ad_types'
              ||CHR(10)||'                             WHERE nad_nt_type = :nt_type'
              ||CHR(10)||'                               AND NVL(nad_gty_type,''~~~~~'') = NVL(:pi_gty_type,''~~~~~'')'
              ||CHR(10)||'                               AND nad_primary_ad = ''Y'''
              ||CHR(10)||'                               AND nad_inv_type = ita_inv_type'
              ||CHR(10)||'                               AND ita_attrib_name = :pi_column_name'
              ||CHR(10)||'                               AND ita_id_domain IS NOT NULL)'
              ||CHR(10)||'        ORDER BY ial_seq))'
        ;
        --
    ELSE
        /*
        ||Column name does not belong to the Element Attributes or
        ||the Primary AD Asset Attributes so return an empty cursor.
        */
        --
        lv_retval := lv_retval||')';
        --
    END IF;
    --
    po_sql := lv_retval;
    --
  END gen_domain_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flx_col_data(pi_ne_id                  IN  nm_elements.ne_id%TYPE
                               ,pi_column_name            IN  nm_type_columns.ntc_column_name%TYPE
                               ,pi_prompt_text            IN  nm_type_columns.ntc_prompt%TYPE
                               ,pi_disp_validation_errors IN  BOOLEAN DEFAULT FALSE
                               ,pi_continue_after_val_err IN  BOOLEAN DEFAULT FALSE
                               ,po_value                  OUT VARCHAR2
                               ,po_meaning                OUT VARCHAR2)
    IS
    --
--    lv_value    VARCHAR2(240);
--    lv_meaning  VARCHAR2(240);
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
                           ,po_value       => po_value
                           ,po_meaning     => po_meaning);
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
  END get_nt_flx_col_data;

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
  BEGIN
    --
    get_nt_flx_col_data(pi_ne_id                  => pi_ne_id
                       ,pi_column_name            => pi_column_name
                       ,pi_prompt_text            => pi_prompt_text
                       ,pi_disp_validation_errors => pi_disp_validation_errors
                       ,pi_continue_after_val_err => pi_continue_after_val_err
                       ,po_value                  => lv_value
                       ,po_meaning                => lv_meaning);
    --
    RETURN lv_value;
    --
  END get_nt_flx_col_value;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_flx_col_meaning(pi_ne_id                  IN nm_elements.ne_id%TYPE
                                 ,pi_column_name            IN nm_type_columns.ntc_column_name%TYPE
                                 ,pi_prompt_text            IN nm_type_columns.ntc_prompt%TYPE
                                 ,pi_disp_validation_errors IN BOOLEAN DEFAULT FALSE
                                 ,pi_continue_after_val_err IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_value    VARCHAR2(240);
    lv_meaning  VARCHAR2(240);
    lv_sql      nm3type.max_varchar2;
    --
  BEGIN
    --
    gen_domain_sql(pi_nt_type     => nm3net.get_nt_type(p_ne_id => pi_ne_id)
                  ,pi_column_name => pi_column_name
                  ,pi_bind_value  => NULL
                  ,po_sql         => lv_sql);
    --
    lv_sql :=  'SELECT meaning'
    ||CHR(10)||'  FROM ('||lv_sql||')'
    ||CHR(10)||' WHERE code = (SELECT '||pi_column_name
    ||CHR(10)||'                 FROM nm_elements_all'
    ||CHR(10)||'                WHERE ne_id = :ne_id)'
    ;
    --
    EXECUTE IMMEDIATE lv_sql INTO lv_meaning USING pi_ne_id;
    --
    RETURN lv_meaning;
    --
  END get_nt_flx_col_meaning;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domain(pi_nt_type     IN  nm_types.nt_type%TYPE
                              ,pi_group_type  IN  nm_group_types_all.ngt_group_type%TYPE
                              ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                              ,pi_bind_value  IN  VARCHAR2 DEFAULT NULL
                              ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_cursor_sql  nm3type.max_varchar2;
    --
  BEGIN
    --
    gen_domain_sql(pi_nt_type     => pi_nt_type
                  ,pi_column_name => pi_column_name
                  ,pi_bind_value  => pi_bind_value
                  ,po_sql         => lv_cursor_sql);
    --
    lv_cursor_sql := 'SELECT code'
          ||CHR(10)||'      ,meaning'
          ||CHR(10)||'  FROM ('||lv_cursor_sql||')';
    --
    IF SUBSTR(pi_column_name,1,3) = 'NE_'
     THEN
        --
        OPEN po_cursor FOR lv_cursor_sql;
        --
    ELSIF SUBSTR(pi_column_name,1,4) = 'IIT_'
     THEN
        --
        OPEN po_cursor FOR lv_cursor_sql USING pi_nt_type, pi_group_type, pi_column_name;
        --
    ELSE
        /*
        ||Column name does not belong to the Element Attributes or
        ||the Primary AD Asset Attributes so return an empty cursor.
        */
        --
        OPEN po_cursor FOR lv_cursor_sql;
        --
    END IF;
    --
  END get_nt_flex_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domain(pi_nt_type          IN  nm_types.nt_type%TYPE
                              ,pi_group_type       IN  nm_group_types_all.ngt_group_type%TYPE
                              ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                              ,pi_bind_value       IN  VARCHAR2 DEFAULT NULL
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_nt_flex_domain(pi_nt_type     => pi_nt_type
                      ,pi_group_type  => pi_group_type
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
  FUNCTION get_nt_flex_domain(pi_nt_type     IN nm_types.nt_type%TYPE
                             ,pi_group_type  IN nm_group_types_all.ngt_group_type%TYPE
                             ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE
                             ,pi_bind_value  IN VARCHAR2 DEFAULT NULL)
    RETURN domain_values_tab IS
    --
    lv_cursor         sys_refcursor;
    lt_domain_values  domain_values_tab;
    --
  BEGIN
    --
    get_nt_flex_domain(pi_nt_type     => pi_nt_type
                      ,pi_group_type  => pi_group_type
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
  PROCEDURE get_paged_nt_flex_domain(pi_nt_type     IN  nm_types.nt_type%TYPE
                                    ,pi_group_type  IN  nm_group_types_all.ngt_group_type%TYPE
                                    ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                                    ,pi_bind_value  IN  VARCHAR2 DEFAULT NULL
                                    ,pi_filter      IN  VARCHAR2
                                    ,pi_skip_n_rows IN  PLS_INTEGER
                                    ,pi_pagesize    IN  PLS_INTEGER
                                    ,po_cursor      OUT sys_refcursor)
    IS
    --
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_driving_sql      nm3type.max_varchar2;
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
        lv_filter := ' WHERE UPPER(lov_meaning) LIKE UPPER(''%''||:filter||''%'')';
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
    gen_domain_sql(pi_nt_type     => pi_nt_type
                  ,pi_column_name => pi_column_name
                  ,pi_bind_value  => pi_bind_value
                  ,po_sql         => lv_driving_sql);
    --
    lv_cursor_sql := lv_cursor_sql||lv_driving_sql||lv_filter||') ORDER BY match_quality,seq)'||CHR(10)||lv_row_restriction;
    --
    IF SUBSTR(pi_column_name,1,3) = 'NE_'
     THEN
        --
        IF pi_filter IS NOT NULL
         THEN
             IF pi_pagesize IS NOT NULL
              THEN
                 OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, pi_filter, lv_lower_index, lv_upper_index;
             ELSE
                 OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, pi_filter, lv_lower_index;
             END IF;
        ELSE
             IF pi_pagesize IS NOT NULL
              THEN
                 OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, lv_lower_index, lv_upper_index;
             ELSE
                 OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, lv_lower_index;
             END IF;
        END IF;
        --
    ELSIF SUBSTR(pi_column_name,1,4) = 'IIT_'
     THEN
        --
        IF pi_filter IS NOT NULL
         THEN
            IF pi_pagesize IS NOT NULL
             THEN
                OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, pi_nt_type, pi_group_type, pi_column_name, pi_filter, lv_lower_index, lv_upper_index;
            ELSE
                OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, pi_nt_type, pi_group_type, pi_column_name, pi_filter, lv_lower_index;
            END IF;
        ELSE
            IF pi_pagesize IS NOT NULL
             THEN
                OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, pi_nt_type, pi_group_type, pi_column_name, lv_lower_index, lv_upper_index;
            ELSE
                OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, pi_nt_type, pi_group_type, pi_column_name, lv_lower_index;
            END IF;
        END IF;
        --
    ELSE
        /*
        ||Column name does not belong to the Element Attributes or
        ||the Primary AD Asset Attributes so return an empty cursor.
        */
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, lv_lower_index, lv_upper_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql USING pi_filter, pi_filter, lv_lower_index;
        END IF;
        --
    END IF;
    --
  END get_paged_nt_flex_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nt_flex_domain(pi_nt_type          IN  nm_types.nt_type%TYPE
                                    ,pi_group_type       IN  nm_group_types_all.ngt_group_type%TYPE
                                    ,pi_column_name      IN  nm_type_columns.ntc_column_name%TYPE
                                    ,pi_bind_value       IN  VARCHAR2 DEFAULT NULL
                                    ,pi_filter           IN  VARCHAR2
                                    ,pi_skip_n_rows      IN  PLS_INTEGER
                                    ,pi_pagesize         IN  PLS_INTEGER
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_paged_nt_flex_domain(pi_nt_type     => pi_nt_type
                            ,pi_group_type  => pi_group_type
                            ,pi_column_name => pi_column_name
                            ,pi_bind_value  => pi_bind_value
                            ,pi_filter      => pi_filter
                            ,pi_skip_n_rows => pi_skip_n_rows
                            ,pi_pagesize    => pi_pagesize
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
  END get_paged_nt_flex_domain;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_paged_nt_flex_domain(pi_nt_type     IN nm_types.nt_type%TYPE
                                   ,pi_group_type  IN nm_group_types_all.ngt_group_type%TYPE
                                   ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE
                                   ,pi_bind_value  IN VARCHAR2 DEFAULT NULL
                                   ,pi_filter      IN VARCHAR2
                                   ,pi_skip_n_rows IN PLS_INTEGER
                                   ,pi_pagesize    IN PLS_INTEGER)
    RETURN domain_values_tab IS
    --
    lv_cursor         sys_refcursor;
    lt_domain_values  domain_values_tab;
    --
  BEGIN
    --
    get_paged_nt_flex_domain(pi_nt_type     => pi_nt_type
                            ,pi_group_type  => pi_group_type
                            ,pi_column_name => pi_column_name
                            ,pi_bind_value  => pi_bind_value
                            ,pi_filter      => pi_filter
                            ,pi_skip_n_rows => pi_skip_n_rows
                            ,pi_pagesize    => pi_pagesize
                            ,po_cursor      => lv_cursor);
    --
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_domain_values;
    CLOSE lv_cursor;
    --
    RETURN lt_domain_values;
    --
  END get_paged_nt_flex_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domains(pi_nt_type    IN  nm_types.nt_type%TYPE
                               ,pi_group_type IN  nm_group_types_all.ngt_group_type%TYPE
                               ,po_cursor     OUT sys_refcursor)
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
                         ||CHR(10)||'                               AND NVL(nad_gty_type,''~~~~~'') = NVL(:pi_gty_type,''~~~~~'')'
                         ||CHR(10)||'                               AND nad_primary_ad = ''Y'''
                         ||CHR(10)||'                               AND nad_inv_type = ita_inv_type'
                         ||CHR(10)||'                               AND ita_id_domain IS NOT NULL)'
                         ||CHR(10)||'        ORDER BY ial_domain,ial_seq)'
    ;
    --
    OPEN po_cursor FOR lv_cursor_sql USING pi_nt_type, pi_group_type;
    --
  END get_nt_flex_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_domains(pi_nt_type          IN  nm_types.nt_type%TYPE
                               ,pi_group_type       IN  nm_group_types_all.ngt_group_type%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_nt_flex_domains(pi_nt_type    => pi_nt_type
                       ,pi_group_type => pi_group_type
                       ,po_cursor     => po_cursor);
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
  FUNCTION get_nt_flex_domains(pi_nt_type    IN  nm_types.nt_type%TYPE
                              ,pi_group_type IN  nm_group_types_all.ngt_group_type%TYPE)
    RETURN domain_name_and_values_tab IS
    lv_cursor         sys_refcursor;
    lt_domain_values  domain_name_and_values_tab;
    --
  BEGIN
    --
    get_nt_flex_domains(pi_nt_type    => pi_nt_type
                       ,pi_group_type => pi_group_type
                       ,po_cursor     => lv_cursor);
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
  PROCEDURE get_nt_flex_attribs(pi_ne_id           IN  nm_elements_all.ne_id%TYPE
                               ,pi_nt_type         IN  nm_types.nt_type%TYPE
                               ,pi_group_type      IN  nm_group_types_all.ngt_group_type%TYPE
                               ,pi_disp_derived    IN  BOOLEAN DEFAULT TRUE
                               ,pi_disp_inherited  IN  BOOLEAN DEFAULT TRUE
                               ,pi_disp_primary_ad IN  BOOLEAN DEFAULT TRUE
                               ,po_cursor          OUT sys_refcursor)
    IS
    --
    lv_disp_derived VARCHAR2(1) := CASE WHEN pi_disp_derived THEN 'Y' ELSE 'N' END;
    lv_disp_inherited VARCHAR2(1) := CASE WHEN pi_disp_inherited THEN 'Y' ELSE 'N' END;
    lv_disp_primary_ad VARCHAR2(1) := CASE WHEN pi_disp_primary_ad THEN 'Y' ELSE 'N' END;
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
          ,CAST(sql_based_domain AS VARCHAR2(1)) sql_based_domain
          ,CAST(domain_bind_column AS VARCHAR2(30)) domain_bind_column
          ,CAST(char_value AS VARCHAR2(500)) char_value
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
                  ,'N'         sql_based_domain
                  ,NULL        domain_bind_column
                  ,CASE
                     WHEN pi_ne_id IS NOT NULL
                      THEN
                         (SELECT ne_unique
                            FROM nm_elements_all
                           WHERE ne_id = pi_ne_id)
                     ELSE
                         NULL
                   END char_value
                  ,'Y'         required
                  ,'N'         updateable
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
                  ,CASE
                     WHEN ntc_query IS NOT NULL
                      OR (domain_sql IS NOT NULL AND ntc_domain IS NULL)
                      THEN
                         'Y'
                     ELSE
                         'N'
                   END sql_based_domain
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
                  ,'N'               sql_based_domain
                  ,NULL              domain_bind_column
                  ,nm3inv.get_attrib_value(p_ne_id       => adlink.nad_iit_ne_id
                                          ,p_attrib_name => ita_attrib_name) char_value
                  ,ita_mandatory_yn  required
                  ,'Y'               updateable
                  ,ita_disp_seq_no+100 seq_no
              FROM nm_nw_ad_link adlink
                  ,nm_inv_type_attribs
                  ,nm_nw_ad_types adt
             WHERE lv_disp_primary_ad = 'Y'
               AND adt.nad_nt_type = pi_nt_type
               AND NVL(adt.nad_gty_type,'~~~~~') = NVL(pi_group_type,'~~~~~')
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
                               ,pi_group_type       IN  nm_group_types_all.ngt_group_type%TYPE
                               ,pi_disp_derived     IN  BOOLEAN DEFAULT TRUE
                               ,pi_disp_inherited   IN  BOOLEAN DEFAULT TRUE
                               ,pi_disp_primary_ad  IN  BOOLEAN DEFAULT TRUE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_nt_flex_attribs(pi_ne_id           => pi_ne_id
                       ,pi_nt_type         => pi_nt_type
                       ,pi_group_type      => pi_group_type
                       ,pi_disp_derived    => pi_disp_derived
                       ,pi_disp_inherited  => pi_disp_inherited
                       ,pi_disp_primary_ad => pi_disp_primary_ad
                       ,po_cursor          => po_cursor);
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
  FUNCTION get_nt_flex_attribs(pi_ne_id           IN nm_elements_all.ne_id%TYPE
                              ,pi_nt_type         IN nm_types.nt_type%TYPE
                              ,pi_group_type      IN nm_group_types_all.ngt_group_type%TYPE
                              ,pi_disp_derived    IN BOOLEAN DEFAULT TRUE
                              ,pi_disp_inherited  IN BOOLEAN DEFAULT TRUE
                              ,pi_disp_primary_ad IN BOOLEAN DEFAULT TRUE)
    RETURN flex_attr_tab IS
    --
    lv_cursor         sys_refcursor;
    lt_attrib_values  flex_attr_tab;
    --
  BEGIN
    --
    get_nt_flex_attribs(pi_ne_id           => pi_ne_id
                       ,pi_nt_type         => pi_nt_type
                       ,pi_group_type      => pi_group_type
                       ,pi_disp_derived    => pi_disp_derived
                       ,pi_disp_inherited  => pi_disp_inherited
                       ,pi_disp_primary_ad => pi_disp_primary_ad
                       ,po_cursor          => lv_cursor);
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
    EXECUTE IMMEDIATE 'BEGIN'
           ||CHR(10)||'  nm3nwval.validate_nw_element_cols(p_ne_nt_type        => '||pi_global||'.ne_nt_type'
           ||CHR(10)||'                                   ,p_ne_owner          => '||pi_global||'.ne_owner'
           ||CHR(10)||'                                   ,p_ne_name_1         => '||pi_global||'.ne_name_1'
           ||CHR(10)||'                                   ,p_ne_name_2         => '||pi_global||'.ne_name_2'
           ||CHR(10)||'                                   ,p_ne_prefix         => '||pi_global||'.ne_prefix'
           ||CHR(10)||'                                   ,p_ne_number         => '||pi_global||'.ne_number'
           ||CHR(10)||'                                   ,p_ne_sub_type       => '||pi_global||'.ne_sub_type'
           ||CHR(10)||'                                   ,p_ne_no_start       => '||pi_global||'.ne_no_start'
           ||CHR(10)||'                                   ,p_ne_no_end         => '||pi_global||'.ne_no_end'
           ||CHR(10)||'                                   ,p_ne_sub_class      => '||pi_global||'.ne_sub_class'
           ||CHR(10)||'                                   ,p_ne_nsg_ref        => '||pi_global||'.ne_nsg_ref'
           ||CHR(10)||'                                   ,p_ne_version_no     => '||pi_global||'.ne_version_no'
           ||CHR(10)||'                                   ,p_ne_group          => '||pi_global||'.ne_group'
           ||CHR(10)||'                                   ,p_ne_start_date     => '||pi_global||'.ne_start_date'
           ||CHR(10)||'                                   ,p_ne_gty_group_type => '||pi_global||'.ne_gty_group_type'
           ||CHR(10)||'                                   ,p_ne_admin_unit     => '||pi_global||'.ne_admin_unit);'
           ||CHR(10)||'END;'
    ;
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
          ,ne_type           element_type
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
  PROCEDURE get_element_member_of(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ne_id             element_id
          ,ne_unique         element_unique
          ,ne_descr          element_description
          ,CASE
             WHEN ngt_sub_group_allowed = 'Y'
              THEN
                 'P' --Group Of Groups
             ELSE
                 'G' --Group Of Datums
           END               element_type
          ,ne_gty_group_type element_group_type
          ,ngt_descr         element_group_type_descr
          ,nm_start_date     membership_start_date
          ,nm_begin_mp       membership_from_offset
          ,nm_end_mp         membership_to_offset
          ,nm_slk            membership_slk
          ,nm_cardinality    membership_cardinality
      FROM nm_group_types
          ,nm_elements
          ,nm_members
     WHERE nm_type = 'G'
       AND nm_ne_id_of = pi_ne_id
       AND nm_ne_id_in = ne_id
       AND ne_gty_group_type = ngt_group_type
     ORDER
        BY ne_unique
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
  END get_element_member_of;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_primary_ad_asset(pi_ne_id          IN nm_elements_all.ne_id%TYPE
                                   ,pi_nt_type        IN nm_types.nt_type%TYPE
                                   ,pi_group_type     IN nm_group_types_all.ngt_group_type%TYPE
                                   ,pi_admin_unit     IN nm_admin_units_all.nau_admin_unit%TYPE
                                   ,pi_start_date     IN nm_elements_all.ne_start_date%TYPE
                                   ,pi_primary_ad_rec IN nm_inv_items_all%ROWTYPE)
    IS
    --
    lv_prim_ad_type  nm_inv_types_all.nit_inv_type%TYPE;
    --
    lr_ad  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    --
    lv_prim_ad_type := get_primary_ad_inv_type(pi_nt_type    => pi_nt_type
                                              ,pi_group_type => pi_group_type);
    IF lv_prim_ad_type IS NOT NULL
     THEN
        lr_ad := pi_primary_ad_rec;
        nm3nwad.iit_rec_init(pi_inv_type   => lv_prim_ad_type
                            ,pi_admin_unit => pi_admin_unit);
        --
        lr_ad.iit_inv_type := lv_prim_ad_type;
        lr_ad.iit_admin_unit := pi_admin_unit;
        lr_ad.iit_start_date := pi_start_date;
        --
        nm3nwad.add_inv_ad_to_ne(pi_ne_id   => pi_ne_id
                                ,pi_rec_iit => lr_ad);
        --
    END IF;
    --
  END create_primary_ad_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_check(pi_ne_id             IN     nm_elements.ne_id%TYPE DEFAULT NULL
                       ,pi_new_start_node_id IN     nm_elements.ne_no_start%TYPE
                       ,pi_new_end_node_id   IN     nm_elements.ne_no_end%TYPE
                       ,pi_new_ne_sub_class  IN     nm_elements.ne_sub_class%TYPE
                       ,pi_new_ne_group      IN     nm_elements.ne_group%TYPE
                       ,po_message_severity  IN OUT hig_codes.hco_code%TYPE
                       ,po_message_tab       IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    e0 exception;
    pragma exception_init(e0, -20100);
    e1 exception;
    pragma exception_init(e1, -20101);
    e2 exception;
    pragma exception_init(e2, -20102);
    e3 exception;
    pragma exception_init(e3, -20103);
    e4 exception;
    pragma exception_init(e4, -20104);
    e5 exception;
    pragma exception_init(e5, -20105);
    e6 exception;
    pragma exception_init(e6, -20106);
    e7 exception;
    pragma exception_init(e7, -20107);
    e8 exception;
    pragma exception_init(e8, -20108);
    e9 exception;
    pragma exception_init(e9, -20109);
    e10 exception;
    pragma exception_init(e10, -20110);
    e11 exception;
    pragma exception_init(e11, -20111);
    e12 exception;
    pragma exception_init(e12, -20112);
    e13 exception;
    pragma exception_init(e13, -20113);
    e14 exception;
    pragma exception_init(e14, -20114);
    --
    PROCEDURE add_message(pi_appl IN nm_errors.ner_appl%TYPE
                         ,pi_id   IN nm_errors.ner_id%TYPE)
      IS
    BEGIN
      awlrs_util.add_ner_to_message_tab(pi_ner_appl    => pi_appl
                                       ,pi_ner_id      => pi_id
                                       ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                       ,po_message_tab => po_message_tab);
      po_message_severity := awlrs_util.c_msg_cat_ask_continue;
    END;
    --
  BEGIN
    --
    nm3nwval.route_check(p_ne_no_start_new  => pi_new_start_node_id
                        ,p_ne_no_end_new    => pi_new_end_node_id
                        ,p_ne_sub_class_new => pi_new_ne_sub_class
                        ,p_ne_group_new     => pi_new_ne_group
                        ,p_ne_id            => pi_ne_id);
    --
  EXCEPTION
    WHEN e0
     THEN
        --Adding an element with the same sub class as one that exists at this start node.
        add_message(pi_appl => 'NET'
                   ,pi_id   => 19);
    WHEN e1
     THEN
        --More that one element with this sub-class at this start node.
        add_message(pi_appl => 'NET'
                   ,pi_id   => 20);
    WHEN e2
     THEN
        --Adding an element with the same sub class as one that exists at this end node.
        add_message(pi_appl => 'NET'
                   ,pi_id   => 21);
    WHEN e3
     THEN
        --More that one element with this sub-class at this end node.
        add_message(pi_appl => 'NET'
                   ,pi_id   => 22);
    WHEN e4
     THEN
        --A Single and Left or Right element start at this node
        add_message(pi_appl => 'NET'
                   ,pi_id   => 23);
    WHEN e5
     THEN
        --A Single and a Left element start at this node
        add_message(pi_appl => 'NET'
                   ,pi_id   => 24);
    WHEN e6
     THEN
        --A Single and a Right element start at this node
        add_message(pi_appl => 'NET'
                   ,pi_id   => 25);
    WHEN e7
     THEN
        --Left Starts without a right
        add_message(pi_appl => 'NET'
                   ,pi_id   => 133);
    WHEN e8
     THEN
        --Right Starts without a Left
        add_message(pi_appl => 'NET'
                   ,pi_id   => 134);
    WHEN e9
     THEN
        --Adding a Left without a right
        add_message(pi_appl => 'NET'
                   ,pi_id   => 135);
    WHEN e10
     THEN
        --Adding a Right without a Left
        add_message(pi_appl => 'NET'
                   ,pi_id   => 136);
    WHEN e11
     THEN
        --Left ends without a right
        add_message(pi_appl => 'NET'
                   ,pi_id   => 137);
    WHEN e12
     THEN
        --Adding a Left without a right
        add_message(pi_appl => 'NET'
                   ,pi_id   => 138);
    WHEN e13
     THEN
        --Adding a Right without a Left
        add_message(pi_appl => 'NET'
                   ,pi_id   => 139);
    WHEN e14
     THEN
        --Adding a Right without a Left
        add_message(pi_appl => 'NET'
                   ,pi_id   => 140);
    WHEN others
     THEN
        RAISE;
  END route_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_check(pi_ne_id             IN  nm_elements.ne_id%TYPE
                       ,pi_new_start_node_id IN  nm_elements.ne_no_start%TYPE
                       ,pi_new_end_node_id   IN  nm_elements.ne_no_end%TYPE
                       ,pi_new_ne_sub_class  IN  nm_elements.ne_sub_class%TYPE
                       ,pi_new_ne_group      IN  nm_elements.ne_group%TYPE
                       ,po_message_severity  OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    route_check(pi_ne_id             => pi_ne_id
               ,pi_new_start_node_id => pi_new_start_node_id
               ,pi_new_end_node_id   => pi_new_end_node_id
               ,pi_new_ne_sub_class  => pi_new_ne_sub_class
               ,pi_new_ne_group      => pi_new_ne_group
               ,po_message_severity  => lv_severity
               ,po_message_tab       => lt_messages);
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
  END route_check;

--  FUNCTION check_slk RETURN BOOLEAN IS
--    e_start_slk EXCEPTION;
--    PRAGMA EXCEPTION_INIT(e_start_slk, -20198);
--    e_end_slk EXCEPTION;
--    PRAGMA EXCEPTION_INIT(e_end_slk, -20199);
--    --
--  BEGIN
--  	nm_Debug.debug('check_slk');
--    IF nm3net.is_nt_inclusion_child(pi_nt => :ne.ne_nt_type)
--    THEN
--  
--  	  set_application_property(cursor_style, 'Busy');
--  	  --
--  	  FOR cs_rec IN (SELECT *
--  	                  FROM  nm_type_inclusion
--  	                 WHERE  nti_nw_child_type = :ne.ne_nt_type
--  	                )
--  	   LOOP
--  	    
--        DECLARE
--        	 l_allow_fail_on_ele_lookup BOOLEAN;
--         	 x_parent_element_not_found EXCEPTION;
--      	   PRAGMA EXCEPTION_INIT(x_parent_element_not_found,-20001);
--        BEGIN
--           l_allow_fail_on_ele_lookup := nm3net.column_is_autocreate_child_col (:ne.NE_NT_TYPE,cs_rec.NTI_CHILD_COLUMN);
--           
--        	  nm3nwval.check_slk (p_parent_ne_id => nm3net.get_single_ne_id (cs_rec.nti_nw_parent_type
--        	                                                                ,cs_rec.NTI_PARENT_COLUMN
--        	                                                                ,name_in ('ne.'||cs_rec.NTI_CHILD_COLUMN)
--        	                                                                )
--      	                       ,p_no_start_new => :ne.ne_no_start
--      	                       ,p_no_end_new   => :ne.ne_no_end
--      	                       ,p_length       => :ne.ne_length
--      	                       ,p_sub_class    => :ne.ne_sub_class
--      	                       ,p_datum_ne_id  => NVL(:ne.ne_id,1)
--      	                       );
--        EXCEPTION
--        	 WHEN x_parent_element_not_found
--        	  THEN
--         		  IF NOT l_allow_fail_on_ele_lookup
--      	   	   THEN
--      	   	     hig.raise_ner('HIG',67);
--      	   	  END IF;
--        END;
--  	  END LOOP;
--  	  set_application_property(cursor_style, 'Default');
--    END IF;
--    
--    RETURN TRUE;
--  EXCEPTION
--    WHEN e_start_slk
--     THEN
--        set_application_property(cursor_style, 'Default');
--        RETURN ask(get_error_text('NET', 187));
--    WHEN e_end_slk
--     THEN
--        set_application_property(cursor_style, 'Default');
--        RETURN ask(get_error_text('NET', 188));
--  END check_slk;

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
                          ,pi_element_attribs IN     flex_attr_tab
                          ,pi_shape_wkt       IN     CLOB
                          ,pi_run_checks      IN     VARCHAR2 DEFAULT 'Y'
                          ,po_ne_id           IN OUT nm_elements_all.ne_id%TYPE
                          ,po_message_severity   OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor     OUT sys_refcursor)
    IS
    --
    lv_shape           mdsys.sdo_geometry;
    lv_srid            NUMBER;
    lv_x               NUMBER;
    lv_y               NUMBER;
    lv_prim_ad_type    nm_inv_types_all.nit_inv_type%TYPE;
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    lr_nt  nm_types%ROWTYPE;
    lr_ad  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT cre_element_sp;
    /*
    ||Process the Element details.
    */
    init_element_globals;
    --
    g_new_element.ne_nt_type        := pi_network_type;
    g_new_element.ne_type           := pi_element_type;
    g_new_element.ne_descr          := pi_description;
    g_new_element.ne_length         := pi_length;
    g_new_element.ne_admin_unit     := pi_admin_unit_id;
    g_new_element.ne_start_date     := TRUNC(pi_start_date);
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
    init_ad_globals;
    --
    lv_prim_ad_type := get_primary_ad_inv_type(pi_nt_type    => lr_ne.ne_nt_type
                                              ,pi_group_type => lr_ne.ne_gty_group_type);
    IF lv_prim_ad_type IS NOT NULL
     THEN
        build_ad_rec(pi_inv_type   => lv_prim_ad_type
                    ,pi_global     => 'awlrs_element_api.g_new_prim_ad_asset'
                    ,pi_attributes => pi_element_attribs);
        lr_ad := g_new_prim_ad_asset;
    END IF;
    /*
    ||Make sure that either start\end nodes have been passed in or a shape has been passed in.
    */
    lr_nt := nm3net.get_nt(pi_nt_type => lr_ne.ne_nt_type);
    --
    IF lr_nt.nt_node_type IS NOT NULL
     AND (lr_ne.ne_no_start IS NULL OR lr_ne.ne_no_end IS NULL)
     AND pi_shape_wkt IS NULL
     THEN
        --Please specify both start and end nodes or a shape for the new Element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 4);
    END IF;
    /*
    ||Convert the shape to sdo geom.
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
    ||Run some route based checks.
    */
    IF pi_run_checks = 'Y'
     AND hig.get_sysopt('CHECKROUTE') = 'Y'
     THEN
        route_check(pi_ne_id             => NULL
                   ,pi_new_start_node_id => lr_ne.ne_no_start
                   ,pi_new_end_node_id   => lr_ne.ne_no_end
                   ,pi_new_ne_sub_class  => lr_ne.ne_sub_class
                   ,pi_new_ne_group      => lr_ne.ne_group
                   ,po_message_severity  => lv_severity
                   ,po_message_cursor    => lv_message_cursor);
    END IF;
    --
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN
        /*
        ||TODO - passing in defaults for p_nm_cardinality and p_auto_include need to work out if this is okay.
        */
        nm3net.insert_any_element(p_rec_ne         => lr_ne
                                 ,p_nm_cardinality => NULL
                                 ,p_auto_include   => TRUE);
        /*
        ||Create primary AD asset if required.
        */
        create_primary_ad_asset(pi_ne_id          => lr_ne.ne_id
                               ,pi_nt_type        => lr_ne.ne_nt_type
                               ,pi_group_type     => lr_ne.ne_gty_group_type
                               ,pi_admin_unit     => lr_ne.ne_admin_unit
                               ,pi_start_date     => lr_ne.ne_start_date
                               ,pi_primary_ad_rec => lr_ad);
        --
        IF lv_shape IS NOT NULL
         THEN
            --
            nm3sdo.insert_element_shape(p_layer => nm3get.get_nth(pi_nth_theme_name => pi_theme_name).nth_theme_id
                                       ,p_ne_id => lr_ne.ne_id
                                       ,p_geom  => lv_shape);
            --
        END IF;
        --
        po_ne_id := lr_ne.ne_id;
        --
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
    ELSE
        --
        po_message_severity := lv_severity;
        po_message_cursor := lv_message_cursor;
        --
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO cre_element_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
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
                          ,pi_run_checks          IN     VARCHAR2 DEFAULT 'Y'
                          ,po_ne_id               IN OUT nm_elements_all.ne_id%TYPE
                          ,po_message_severity       OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
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
    create_element(pi_theme_name       => pi_theme_name
                  ,pi_network_type     => pi_network_type
                  ,pi_element_type     => pi_element_type
                  ,pi_description      => pi_description
                  ,pi_length           => pi_length
                  ,pi_admin_unit_id    => pi_admin_unit_id
                  ,pi_start_date       => pi_start_date
                  ,pi_end_date         => pi_end_date
                  ,pi_group_type       => pi_group_type
                  ,pi_start_node_id    => pi_start_node_id
                  ,pi_end_node_id      => pi_end_node_id
                  ,pi_element_attribs  => lt_element_attribs
                  ,pi_shape_wkt        => pi_shape_wkt
                  ,pi_run_checks       => pi_run_checks
                  ,po_ne_id            => po_ne_id
                  ,po_message_severity => lv_message_severity
                  ,po_message_cursor   => lv_message_cursor);
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
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
  PROCEDURE update_element(pi_ne_id           IN nm_elements_all.ne_id%TYPE
                          ,pi_old_description IN nm_elements_all.ne_descr%TYPE
                          ,pi_new_description IN nm_elements_all.ne_descr%TYPE
                          ,pi_old_attributes  IN flex_attr_tab
                          ,pi_new_attributes  IN flex_attr_tab)
    IS
    --
    lv_prim_ad_type  nm_inv_types_all.nit_inv_type%TYPE;
    --
    PROCEDURE get_db_rec(pi_ne_id IN nm_elements_all.ne_id%TYPE)
      IS
    BEGIN
      BEGIN
        --
        SELECT *
          INTO g_db_element
          FROM nm_elements
         WHERE ne_id = pi_ne_id
           FOR UPDATE NOWAIT
             ;
        --
      EXCEPTION
       WHEN no_data_found
        THEN
           --Invalid Element Id supplied
           hig.raise_ner(pi_appl => 'AWLRS'
                        ,pi_id   => 29);
      END;
      --
      BEGIN
        SELECT *
          INTO g_db_prim_ad_asset
          FROM nm_inv_items_all
         WHERE iit_ne_id = (SELECT nad_iit_ne_id
                              FROM nm_nw_ad_link
                             WHERE nad_ne_id = pi_ne_id
                               AND nad_primary_ad = 'Y')
           FOR UPDATE NOWAIT
             ;
      EXCEPTION
       WHEN no_data_found
        THEN
           NULL;
      END;           
    END get_db_rec;
    --
    PROCEDURE compare_old_with_db
      IS
      --
      lv_sql nm3type.max_varchar2;
      --
    BEGIN
      /*
      ||Check the Description (this is the only updatable fixed attribute).
      */
      IF g_db_element.ne_descr != pi_old_description
       OR (g_db_element.ne_descr IS NULL AND pi_old_description IS NOT NULL)
       OR (g_db_element.ne_descr IS NOT NULL AND pi_old_description IS NULL)
       THEN
          --Updated by another user
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 24);
      END IF;
      /*
      ||Check the flexible attributes (Element and AD Asset).
      */
      FOR i IN 1..pi_old_attributes.count LOOP
        /*
        ||Ignore NE_UNIQUE as it is not updatable.
        */
        IF pi_old_attributes(i).column_name != 'NE_UNIQUE'
         THEN
          --
          lv_sql := NULL;
          --
          IF SUBSTR(pi_old_attributes(i).column_name,1,3) = 'NE_'
           THEN
              lv_sql := 'BEGIN'
             ||CHR(10)||'  IF awlrs_element_api.g_db_element.'||pi_old_attributes(i).column_name||' != awlrs_element_api.g_old_element.'||pi_old_attributes(i).column_name
             ||CHR(10)||'   OR (awlrs_element_api.g_db_element.'||pi_old_attributes(i).column_name||' IS NULL AND awlrs_element_api.g_old_element.'||pi_old_attributes(i).column_name||' IS NOT NULL)'
             ||CHR(10)||'   OR (awlrs_element_api.g_db_element.'||pi_old_attributes(i).column_name||' IS NOT NULL AND awlrs_element_api.g_old_element.'||pi_old_attributes(i).column_name||' IS NULL)'
             ||CHR(10)||'   THEN '
             ||CHR(10)||'      hig.raise_ner(pi_appl => ''AWLRS'''
             ||CHR(10)||'                   ,pi_id   => 24);'
             ||CHR(10)||'  END IF;'
             ||CHR(10)||'END;'
              ;
          ELSIF SUBSTR(pi_old_attributes(i).column_name,1,4) = 'IIT_'
           THEN
              lv_sql := 'BEGIN'
             ||CHR(10)||'  IF awlrs_element_api.g_db_prim_ad_asset.'||pi_old_attributes(i).column_name||' != awlrs_element_api.g_old_prim_ad_asset.'||pi_old_attributes(i).column_name
             ||CHR(10)||'   OR (awlrs_element_api.g_db_prim_ad_asset.'||pi_old_attributes(i).column_name||' IS NULL AND awlrs_element_api.g_old_prim_ad_asset.'||pi_old_attributes(i).column_name||' IS NOT NULL)'
             ||CHR(10)||'   OR (awlrs_element_api.g_db_prim_ad_asset.'||pi_old_attributes(i).column_name||' IS NOT NULL AND awlrs_element_api.g_old_prim_ad_asset.'||pi_old_attributes(i).column_name||' IS NULL)'
             ||CHR(10)||'   THEN '
             ||CHR(10)||'      hig.raise_ner(pi_appl => ''AWLRS'''
             ||CHR(10)||'                   ,pi_id   => 24);'
             ||CHR(10)||'  END IF;'
             ||CHR(10)||'END;'
              ;
          END IF;
          --
          IF lv_sql IS NOT NULL
           THEN
              EXECUTE IMMEDIATE lv_sql;
          END IF;
          --
        END IF;
        --
      END LOOP;
      --
    END compare_old_with_db;
    --
    PROCEDURE compare_old_with_new
      IS
      --
      lv_sql              nm3type.max_varchar2;
      lv_upd_element_sql  nm3type.max_varchar2 := 'DECLARE lr_ne nm_elements_all%ROWTYPE := awlrs_element_api.g_new_element; BEGIN UPDATE nm_elements_all SET ';
      lv_upd_element      VARCHAR2(1) := 'N';
      lv_upd_ad_sql       nm3type.max_varchar2 := 'DECLARE lr_iit nm_inv_items_all%ROWTYPE := awlrs_element_api.g_new_prim_ad_asset; BEGIN UPDATE nm_inv_items_all SET ';
      lv_upd_ad           VARCHAR2(1) := 'N';
      --
    BEGIN
      --
      IF g_old_element.ne_descr != g_new_element.ne_descr
       THEN
          lv_upd_element_sql := lv_upd_element_sql||'ne_descr = lr_ne.ne_descr';
          lv_upd_element := 'Y';
      END IF;
      --
      FOR i IN 1..pi_new_attributes.count LOOP
        /*
        ||Ignore NE_UNIQUE as it is not updatable.
        */
        IF pi_old_attributes(i).column_name != 'NE_UNIQUE'
         THEN
            --
            lv_sql := NULL;
            --
            IF SUBSTR(pi_new_attributes(i).column_name,1,3) = 'NE_'
             THEN
                lv_sql := 'BEGIN IF awlrs_element_api.g_old_element.'||pi_new_attributes(i).column_name||' != awlrs_element_api.g_new_element.'||pi_new_attributes(i).column_name
                        ||' OR (awlrs_element_api.g_old_element.'||pi_new_attributes(i).column_name||' IS NULL AND awlrs_element_api.g_new_element.'||pi_new_attributes(i).column_name||' IS NOT NULL)'
                        ||' OR (awlrs_element_api.g_old_element.'||pi_new_attributes(i).column_name||' IS NOT NULL AND awlrs_element_api.g_new_element.'||pi_new_attributes(i).column_name||' IS NULL)'
                        ||' THEN :sql_out := :sql_in||'''||CASE WHEN lv_upd_element = 'Y' THEN ', ' ELSE NULL END||LOWER(pi_new_attributes(i).column_name)||' = lr_ne.'||LOWER(pi_new_attributes(i).column_name)||''';'
                        ||' :do_update := ''Y''; END IF; END;'
                ;
                EXECUTE IMMEDIATE lv_sql USING OUT lv_upd_element_sql, IN lv_upd_element_sql, OUT lv_upd_element;
                --
            ELSIF SUBSTR(pi_new_attributes(i).column_name,1,4) = 'IIT_'
             THEN
                lv_sql := 'BEGIN IF awlrs_element_api.g_old_prim_ad_asset.'||pi_new_attributes(i).column_name||' != awlrs_element_api.g_new_prim_ad_asset.'||pi_new_attributes(i).column_name
                        ||' OR (awlrs_element_api.g_old_prim_ad_asset.'||pi_new_attributes(i).column_name||' IS NULL AND awlrs_element_api.g_new_prim_ad_asset.'||pi_new_attributes(i).column_name||' IS NOT NULL)'
                        ||' OR (awlrs_element_api.g_old_prim_ad_asset.'||pi_new_attributes(i).column_name||' IS NOT NULL AND awlrs_element_api.g_new_prim_ad_asset.'||pi_new_attributes(i).column_name||' IS NULL)'
                        ||' THEN :sql_out := :sql_in||'''||CASE WHEN lv_upd_ad = 'Y' THEN ', ' ELSE NULL END||LOWER(pi_new_attributes(i).column_name)||' = lr_iit.'||LOWER(pi_new_attributes(i).column_name)||''';'
                        ||' :do_update := ''Y''; END IF; END;'
                ;
                EXECUTE IMMEDIATE lv_sql USING OUT lv_upd_ad_sql, IN lv_upd_ad_sql, OUT lv_upd_ad;
                --
            END IF;
            --
        END IF;
        --
      END LOOP;
      --
      IF lv_upd_element = 'N'
       AND lv_upd_ad = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      END IF;
      --
      IF lv_upd_element = 'Y'
       THEN
          /*
          ||Complete and execute the element update statement.
          */
          lv_upd_element_sql := lv_upd_element_sql||' WHERE ne_id = :ne_id; END;';
          EXECUTE IMMEDIATE lv_upd_element_sql USING g_db_element.ne_id;
          --
      END IF;
      --
      IF lv_upd_ad = 'Y'
       THEN
          /*
          ||If the ad asset does not exists create it, otherwise update it.
          */
          IF g_db_prim_ad_asset.iit_ne_id IS NULL
           THEN
              create_primary_ad_asset(pi_ne_id          => g_db_element.ne_id
                                     ,pi_nt_type        => g_db_element.ne_nt_type
                                     ,pi_group_type     => g_db_element.ne_gty_group_type
                                     ,pi_admin_unit     => g_db_element.ne_admin_unit
                                     ,pi_start_date     => g_db_element.ne_start_date
                                     ,pi_primary_ad_rec => g_new_prim_ad_asset);
          ELSE
              /*
              ||Complete and execute the primary ad asset update statement.
              */
              lv_upd_ad_sql := lv_upd_ad_sql||' WHERE iit_ne_id = :iit_ne_id; END;';
              EXECUTE IMMEDIATE lv_upd_ad_sql USING g_db_prim_ad_asset.iit_ne_id;
          END IF;
      END IF;
      --
    END compare_old_with_new;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT upd_element_sp;
    /*
    ||Init globals.
    */
    init_element_globals;
    init_ad_globals;
    /*
    ||Get and Lock the record.
    */
    get_db_rec(pi_ne_id => pi_ne_id);
    g_old_element := g_db_element;
    g_new_element := g_db_element;
    /*
    ||Build and validate the element records
    ||based on the attributes passed in.
    */
    g_old_element.ne_descr := pi_old_description;
    g_new_element.ne_descr := pi_new_description;
    --
    build_element_rec(pi_nt_type    => g_db_element.ne_nt_type
                     ,pi_global     => 'awlrs_element_api.g_old_element'
                     ,pi_attributes => pi_old_attributes);
    --
    build_element_rec(pi_nt_type    => g_db_element.ne_nt_type
                     ,pi_global     => 'awlrs_element_api.g_new_element'
                     ,pi_attributes => pi_new_attributes);
    /*
    ||Process any primary AD asset details.
    */
    lv_prim_ad_type := get_primary_ad_inv_type(pi_nt_type    => g_db_element.ne_nt_type
                                              ,pi_group_type => g_db_element.ne_gty_group_type);
    IF lv_prim_ad_type IS NOT NULL
     THEN
        --
        build_ad_rec(pi_inv_type   => lv_prim_ad_type
                    ,pi_global     => 'awlrs_element_api.g_old_prim_ad_asset'
                    ,pi_attributes => pi_old_attributes);
        --
        build_ad_rec(pi_inv_type   => lv_prim_ad_type
                    ,pi_global     => 'awlrs_element_api.g_new_prim_ad_asset'
                    ,pi_attributes => pi_new_attributes);
        --
    END IF;
    /*
    ||Compare old with DB.
    */
    compare_old_with_db;
    /*
    ||Compare new with old.
    */
    compare_old_with_new;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO upd_element_sp;
        RAISE;
  END update_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_element(pi_ne_id                   IN  nm_elements_all.ne_id%TYPE
                          ,pi_old_description         IN  nm_elements_all.ne_descr%TYPE
                          ,pi_new_description         IN  nm_elements_all.ne_descr%TYPE
                          ,pi_old_attrib_column_names IN  attrib_column_name_tab
                          ,pi_old_attrib_prompts      IN  attrib_prompt_tab
                          ,pi_old_attrib_char_values  IN  attrib_char_value_tab
                          ,pi_new_attrib_column_names IN  attrib_column_name_tab
                          ,pi_new_attrib_prompts      IN  attrib_prompt_tab
                          ,pi_new_attrib_char_values  IN  attrib_char_value_tab
                          ,po_message_severity        OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lt_old_element_attribs  flex_attr_tab;
    lt_new_element_attribs  flex_attr_tab;
    --
  BEGIN
    --
    IF pi_old_attrib_column_names.COUNT != pi_old_attrib_prompts.COUNT
     OR pi_old_attrib_column_names.COUNT != pi_old_attrib_char_values.COUNT
     OR pi_old_attrib_column_names.COUNT != pi_new_attrib_column_names.COUNT
     OR pi_old_attrib_column_names.COUNT != pi_new_attrib_prompts.COUNT
     OR pi_old_attrib_column_names.COUNT != pi_new_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_element_api.create_element');
    END IF;
    --
    FOR i IN 1..pi_old_attrib_column_names.COUNT LOOP
      --
      lt_old_element_attribs(i).column_name := pi_old_attrib_column_names(i);
      lt_old_element_attribs(i).prompt      := pi_old_attrib_prompts(i);
      lt_old_element_attribs(i).char_value  := pi_old_attrib_char_values(i);
      --
      lt_new_element_attribs(i).column_name := pi_new_attrib_column_names(i);
      lt_new_element_attribs(i).prompt      := pi_new_attrib_prompts(i);
      lt_new_element_attribs(i).char_value  := pi_new_attrib_char_values(i);
      --
    END LOOP;
    --
    update_element(pi_ne_id           => pi_ne_id
                  ,pi_old_description => pi_old_description
                  ,pi_new_description => pi_new_description
                  ,pi_old_attributes  => lt_old_element_attribs
                  ,pi_new_attributes  => lt_new_element_attribs);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_element;
  
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
    SAVEPOINT reshape_element_sp;
    /*
    ||Convert the shape to sdo geom.
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
        ROLLBACK TO reshape_element_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reshape_element;

--
-----------------------------------------------------------------------------
--
END awlrs_element_api;
/