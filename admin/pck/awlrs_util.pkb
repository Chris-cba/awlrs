CREATE OR REPLACE PACKAGE BODY awlrs_util
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_util.pkb-arc   1.34   Nov 21 2019 15:54:24   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_util.pkb  $
  --       Date into PVCS   : $Date:   Nov 21 2019 15:54:24  $
  --       Date fetched Out : $Modtime:   Nov 15 2019 13:32:08  $
  --       Version          : $Revision:   1.34  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.34  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_util';
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
  ------------------------------------------------------------------------------
  --
  FUNCTION set_effective_date(pi_date IN DATE)
    RETURN PLS_INTEGER IS
    --
    lv_retval PLS_INTEGER := 1;
    --
  BEGIN
    --
    nm3user.set_effective_date(p_date => TRUNC(pi_date));
    --
    RETURN lv_retval;
    --
  END set_effective_date;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION historic_mode
    RETURN BOOLEAN IS
    --
  BEGIN
    --
    RETURN NOT(TRUNC(SYSDATE) = TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY'));
    --
  END;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_historic_mode
    IS
  BEGIN
    --
    IF historic_mode
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 6);
    END IF;
    --
  END check_historic_mode;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION escape_single_quotes(pi_string IN VARCHAR2)
    RETURN nm3type.max_varchar2 IS
    --
    lv_single_quote          VARCHAR2(1) := '''';
    lv_escaped_single_quote  VARCHAR2(2) := '''''';
    --
  BEGIN
    --
    RETURN REPLACE(pi_string,lv_single_quote,lv_escaped_single_quote);
    --
  END escape_single_quotes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION tokenise_string(pi_string      IN VARCHAR2
                          ,pi_token       IN VARCHAR2 DEFAULT ','
                          ,pi_trim_values IN BOOLEAN DEFAULT TRUE)
    RETURN nm3type.tab_varchar32767 IS
    --
    lt_retval  nm3type.tab_varchar32767;
    --
    lv_str    nm3type.max_varchar2;
    lv_char   varchar2(1);
    lv_value  nm3type.max_varchar2 := NULL;
    --
  BEGIN
    --
    IF pi_string IS NOT NULL
     THEN
        lv_str := pi_string;
        --
        FOR i IN 1..LENGTH(lv_str) LOOP
          --
          lv_char := SUBSTR(lv_str,i,1);
          --
          IF lv_char != pi_token
           AND i <= LENGTH(lv_str)
           THEN
              lv_value := lv_value||lv_char;
          END IF;
          --
          IF (lv_char = pi_token OR i = LENGTH(lv_str))
           AND lv_value IS NOT NULL
           THEN
              IF pi_trim_values
               THEN
                  lv_value := LTRIM(RTRIM(lv_value));
              END IF;
              lt_retval(lt_retval.COUNT+1) := lv_value;
              lv_value := NULL;
          END IF;
          --
        END LOOP;
    END IF;
    --
    RETURN lt_retval;
    --
  END tokenise_string;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_date_in_varchar(pi_inv_type    IN nm_inv_types_all.nit_inv_type%TYPE
                             ,pi_attrib_name IN nm_inv_type_attribs.ita_attrib_name%TYPE)
    RETURN BOOLEAN IS
    --
    lv_retval BOOLEAN;
    lv_dummy  NUMBER;
    --
    CURSOR chk_col(cp_inv_type     nm_inv_types_all.nit_inv_type%TYPE
                  ,cp_attrib_name  nm_inv_type_attribs.ita_attrib_name%TYPE
                  ,cp_table_name   all_tab_cols.table_name%TYPE)
        IS
    SELECT 1
      FROM all_tab_cols
          ,nm_inv_type_attribs
     WHERE ita_inv_type = cp_inv_type
       AND ita_attrib_name = cp_attrib_name
       AND ita_format = 'DATE'
       AND ita_attrib_name = column_name
       AND table_name = 'NM_INV_ITEMS_ALL'
       AND owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
       AND data_type = 'VARCHAR2'
         ;
    --
  BEGIN
    --
    OPEN  chk_col(pi_inv_type
                 ,pi_attrib_name
                 ,NVL(nm3get.get_nit(pi_nit_inv_type => pi_inv_type).nit_table_name,'NM_INV_ITEMS_ALL'));
    FETCH chk_col
     INTO lv_dummy;
    lv_retval := chk_col%FOUND;
    CLOSE chk_col;
    --
    RETURN lv_retval;
    --
  END is_date_in_varchar;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_format(pi_obj_type    IN  VARCHAR2
                      ,pi_inv_or_ne   IN  VARCHAR2
                      ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                      ,po_datatype    OUT nm_type_columns.ntc_column_type%TYPE
                      ,po_format      OUT nm_type_columns.ntc_format%TYPE)
    IS
    --
  BEGIN
    --
    IF pi_inv_or_ne = 'INV'
     THEN
        --
        SELECT ita_format
              ,ita_format_mask
          INTO po_datatype
              ,po_format
          FROM nm_inv_type_attribs
         WHERE ita_inv_type = pi_obj_type
           AND ita_attrib_name = pi_column_name
             ;
        IF po_datatype = c_date_col
         THEN
            /*
            ||Check whether the date is being stored in a VARCHAR2 column.
            */
            IF is_date_in_varchar(pi_inv_type    => pi_obj_type
                                 ,pi_attrib_name => pi_column_name)
             THEN
                po_datatype := c_date_in_varchar2_col;
            END IF;
            --
        END IF;
        --
    ELSIF pi_inv_or_ne = 'NE'
     THEN
        --
        IF pi_column_name = 'NE_UNIQUE'
         THEN
            po_datatype := 'VARCHAR2';
            po_format := NULL;
        ELSE
            SELECT ntc_column_type
                  ,ntc_format
              INTO po_datatype
                  ,po_format
              FROM nm_type_columns
             WHERE ntc_nt_type = pi_obj_type
               AND ntc_column_name = pi_column_name
                 ;
        END IF;
        --
    ELSE
        RAISE no_data_found;
    END IF;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        --Invalid Attribute Supplied
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 3);
    WHEN others
     THEN
        RAISE;
  END get_format;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_assignment(pi_value       IN VARCHAR2
                         ,pi_datatype    IN VARCHAR2
                         ,pi_format_mask IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_value   nm3type.max_varchar2;
    lv_retval  nm3type.max_varchar2;
    --
    lv_test_number  NUMBER;
    --
  BEGIN
    --
    IF pi_value IS NULL
     THEN
        --
        lv_retval := 'NULL';
        --
    ELSE
        /*
        ||Escape any single in the value quotes.
        */
        lv_value := awlrs_util.escape_single_quotes(pi_string => pi_value);
        --
        CASE pi_datatype
          WHEN c_number_col
           THEN
              /*
              ||Try to convert to number directly.
              */
              BEGIN
                --
                lv_test_number := TO_NUMBER(lv_value);
                --
                lv_retval := 'TO_NUMBER('||nm3flx.string(lv_value)||')';
                --
              EXCEPTION
                WHEN value_error
                 THEN
                    lv_retval := NULL;
              END;
              --
              IF lv_retval IS NULL
               THEN
                  /*
                  ||Try to convert to number with the format mask.
                  */
                  IF pi_format_mask IS NOT NULL
                   THEN
                      BEGIN
                        --
                        lv_test_number := TO_NUMBER(lv_value,pi_format_mask);
                        --
                        lv_retval := 'TO_NUMBER('||nm3flx.string(lv_value)||','||nm3flx.string(pi_format_mask)||')';
                        --
                      EXCEPTION
                       WHEN value_error
                        THEN
                           --Invalid numeric attribute value supplied
                           hig.raise_ner(pi_appl               => 'AWLRS'
                                        ,pi_id                 => 21
                                        ,pi_supplementary_info => 'Value ['||lv_value||'] Format Mask ['||pi_format_mask||']');
                      END;
                  END IF;
              END IF;
              --
              IF lv_retval IS NULL
               THEN
                  --Invalid numeric attribute value supplied
                  hig.raise_ner(pi_appl               => 'AWLRS'
                               ,pi_id                 => 21
                               ,pi_supplementary_info => 'Value ['||lv_value||']');
              END IF;
              --
          WHEN c_date_col
           THEN
              --
              lv_retval := 'TO_DATE('||nm3flx.string(lv_value)||','||nm3flx.string(NVL(pi_format_mask,c_date_mask))||')';
              --
          WHEN c_datetime_col
           THEN
              --
              lv_retval := 'TO_DATE('||nm3flx.string(lv_value)||','||nm3flx.string(NVL(pi_format_mask,c_datetime_mask))||')';
              --
          WHEN c_date_in_varchar2_col
           THEN
              --
              lv_retval := 'TO_CHAR(hig.date_convert('||nm3flx.string(lv_value)||'),'||nm3flx.string(NVL(pi_format_mask,c_date_mask))||')';
              --
          ELSE
              --
              lv_retval := nm3flx.string(lv_value);
              --
        END CASE;
    END IF;
    --
    RETURN lv_retval;
    --
  END get_assignment;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_attr_assignment(pi_obj_type    IN VARCHAR2
                              ,pi_inv_or_ne   IN VARCHAR2
                              ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE
                              ,pi_value       IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_datatype    nm_type_columns.ntc_column_type%TYPE;
    lv_format_mask nm_type_columns.ntc_format%TYPE;
    --
    lv_retval  nm3type.max_varchar2;
    --
  BEGIN
    --
    get_format(pi_obj_type    => pi_obj_type
              ,pi_inv_or_ne   => pi_inv_or_ne
              ,pi_column_name => pi_column_name
              ,po_datatype    => lv_datatype
              ,po_format      => lv_format_mask);
    --
    RETURN get_assignment(pi_value       => pi_value
                         ,pi_datatype    => CASE
                                              WHEN lv_datatype = 'DATE'
                                               AND pi_inv_or_ne = 'NE'
                                               THEN
                                                  'VARCHAR2'
                                              ELSE
                                                  lv_datatype
                                            END
                         ,pi_format_mask => lv_format_mask);
    --
  END get_attr_assignment;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_attribute(pi_obj_type    IN VARCHAR2
                         ,pi_inv_or_ne   IN VARCHAR2
                         ,pi_global      IN VARCHAR2
                         ,pi_column_name IN nm_type_columns.ntc_column_name%TYPE
                         ,pi_prompt      IN nm_type_columns.ntc_prompt%TYPE
                         ,pi_value       IN VARCHAR2)
    IS
    --
    lv_sql  nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||Set The Value.
    */
    lv_sql := 'BEGIN '||pi_global||'.'||pi_column_name||' := '
              ||get_attr_assignment(pi_obj_type    => pi_obj_type
                                   ,pi_inv_or_ne   => pi_inv_or_ne
                                   ,pi_column_name => pi_column_name
                                   ,pi_value       => pi_value)
              ||'; END;'
    ;
    --
    EXECUTE IMMEDIATE lv_sql;
    --
  EXCEPTION
    WHEN others
     THEN
        --Invalid attribute value supplied
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 22
                     ,pi_supplementary_info => '['||pi_prompt||']: '||SQLERRM);
  END set_attribute;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_has_normal_access(pi_admin_unit IN nm_admin_units_all.nau_admin_unit%TYPE)
    RETURN BOOLEAN IS
    --
    lv_retval      BOOLEAN := FALSE;
    --
    lt_user_normal_nau  admin_unit_tab;
    --
  BEGIN
    --
    SELECT DISTINCT nau.nau_admin_unit
          ,nau_unit_code
          ,nau_name
      BULK COLLECT
      INTO lt_user_normal_nau
      FROM nm_admin_units nau
          ,nm_admin_groups nag
          ,nm_user_aus nua
     WHERE nua.nua_user_id = TO_NUMBER(SYS_CONTEXT('NM3CORE','USER_ID'))
       AND nua.nua_mode = 'NORMAL'
       AND nua.nua_admin_unit = nag.nag_parent_admin_unit
       AND nag.nag_child_admin_unit = nau.nau_admin_unit
         ;
    --
    FOR i IN 1..lt_user_normal_nau.COUNT LOOP
      --
      IF lt_user_normal_nau(i).admin_unit = pi_admin_unit
       THEN
          lv_retval := TRUE;
          EXIT;
      END IF;
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END user_has_normal_access;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_normal_admin_units(po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor
                                       ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT distinct nau.nau_admin_type
          ,nau.nau_admin_unit
          ,nau.nau_unit_code
          ,nau.nau_name
      FROM nm_admin_units nau
          ,nm_admin_groups nag
          ,nm_user_aus nua
     WHERE nua.nua_user_id = TO_NUMBER(SYS_CONTEXT('NM3CORE','USER_ID'))
       AND nua.nua_mode = 'NORMAL'
       AND nua.nua_admin_unit = nag.nag_parent_admin_unit
       AND nag.nag_child_admin_unit = nau.nau_admin_unit
     ORDER
        BY nau_admin_type
          ,nau.nau_name
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
  END get_user_normal_admin_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_product_versions(pi_product_codes    IN  product_codes_tab
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_products nm_code_tbl := nm_code_tbl();
    --
  BEGIN
    --
    FOR i IN 1..pi_product_codes.COUNT LOOP
      --
      lt_products.extend;
      lt_products(i) := pi_product_codes(i);
      --
    END LOOP;
    --
    OPEN po_cursor FOR
    SELECT hpr_product      code
          ,hpr_product_name name
          ,hpr_version      version
      FROM hig_products
     WHERE hpr_product IN(SELECT * FROM TABLE(CAST(lt_products AS nm_code_tbl)))
     ORDER
        BY hpr_sequence
         ;
    --
    get_default_success_cursor(po_message_severity => po_message_severity
                              ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        handle_exception(po_message_severity => po_message_severity
                        ,po_cursor           => po_message_cursor);
  END get_product_versions;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_hig_option_values(pi_option_names     IN  option_names_tab
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_names nm_code_tbl := nm_code_tbl();
    --
  BEGIN
    --
    FOR i IN 1..pi_option_names.COUNT LOOP
      --
      lt_names.extend;
      lt_names(i) := pi_option_names(i);
      --
    END LOOP;
    --
    OPEN po_cursor FOR
    SELECT hol_id option_id
          ,hig.get_user_or_sys_opt(hol_id) option_value
          ,hol_user_option can_be_user_option
      FROM hig_option_list
     WHERE hol_id IN(SELECT * FROM TABLE(CAST(lt_names AS nm_code_tbl)))
     ORDER
        BY hol_id
         ;
    --
    get_default_success_cursor(po_message_severity => po_message_severity
                              ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        handle_exception(po_message_severity => po_message_severity
                        ,po_cursor           => po_message_cursor);
  END get_hig_option_values;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_user_option(pi_option_name      IN  hig_user_options.huo_id%TYPE
                           ,pi_value            IN  hig_user_options.huo_value%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_option  hig_user_option_list_all%ROWTYPE;
    --
    CURSOR get_option(cp_option_id IN hig_user_option_list.huol_id%TYPE)
        IS
    SELECT *
      FROM hig_user_option_list_all
     WHERE huol_id = cp_option_id
         ;
    --
  BEGIN
    --
    OPEN  get_option(pi_option_name);
    FETCH get_option
     INTO lr_option;
    IF get_option%NOTFOUND
     THEN
        --
        CLOSE get_option;
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 83
                     ,pi_supplementary_info => pi_option_name);
        --
    END IF;
    CLOSE get_option;
    --
    IF lr_option.huol_domain IS NOT NULL
     THEN
        DECLARE
          l_invalid EXCEPTION;
          PRAGMA EXCEPTION_INIT (l_invalid,-20001);
        BEGIN
          hig.valid_fk_hco(pi_hco_domain => lr_option.huol_domain
                          ,pi_hco_code   => pi_value);
        EXCEPTION
          WHEN l_invalid
           THEN
              hig.raise_ner(pi_appl               => nm3type.c_hig
                           ,pi_id                 => 109
                           ,pi_supplementary_info => '"'||lr_option.huol_domain||'" -> "'||pi_value||'"');
        END;
    END IF;
    --
    IF lr_option.huol_datatype = nm3type.c_varchar
     THEN
        IF lr_option.huol_mixed_case = 'N'
         AND pi_value != UPPER(pi_value)
         THEN
            hig.raise_ner(pi_appl               => nm3type.c_hig
                         ,pi_id                 => 159
                         ,pi_supplementary_info => pi_value);
        END IF;
    ELSIF lr_option.huol_datatype = nm3type.c_number
     THEN
        IF NOT nm3flx.is_numeric (pi_value)
         THEN
            hig.raise_ner(pi_appl               => nm3type.c_hig
                         ,pi_id                 => 111
                         ,pi_supplementary_info => pi_value);
        END IF;
    ELSIF lr_option.huol_datatype = nm3type.c_date
     THEN
        IF hig.date_convert (pi_value) IS NULL
         THEN
            hig.raise_ner(pi_appl               => nm3type.c_hig
                         ,pi_id                 => 148
                         ,pi_supplementary_info => pi_value);
        END IF;
    END IF;
    --
    hig.set_useopt(pi_huo_hus_user_id => sys_context('NM3CORE', 'USER_ID')
                  ,pi_huo_id          => pi_option_name
                  ,pi_huo_value       => pi_value);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_user_option;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gen_row_restriction(pi_index_column   IN VARCHAR2
                              ,pi_where_clause   IN BOOLEAN DEFAULT TRUE
                              ,pi_start_index    IN PLS_INTEGER
                              ,pi_number_of_rows IN PLS_INTEGER)

    RETURN VARCHAR2 IS
    --
    lv_predicate    VARCHAR2(7) := ' WHERE ';
    lv_start_index  PLS_INTEGER;
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    IF NOT pi_where_clause
     THEN
        lv_predicate := ' AND ';
    END IF;
    --
    lv_start_index := pi_start_index;
    --
    IF lv_start_index IS NOT NULL
     THEN
        lv_start_index := GREATEST(lv_start_index,1);
        lv_retval := lv_predicate||pi_index_column||' >= '||lv_start_index;
    END IF;
    --
    IF pi_number_of_rows IS NOT NULL
     THEN
        IF lv_retval IS NOT NULL
         THEN
            lv_retval := lv_retval||' AND '||pi_index_column||' < '||TO_CHAR(NVL(lv_start_index,1) + pi_number_of_rows);
        ELSE
            lv_retval := lv_predicate||pi_index_column||' < '||TO_CHAR(NVL(lv_start_index,1) + pi_number_of_rows);
        END IF;
    END IF;
    --
    RETURN lv_retval;
    --
  END gen_row_restriction;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE gen_row_restriction(pi_index_column IN  VARCHAR2
                               ,pi_where_clause IN  BOOLEAN DEFAULT TRUE
                               ,pi_skip_n_rows  IN  PLS_INTEGER
                               ,pi_pagesize     IN  PLS_INTEGER
                               ,po_lower_index  OUT PLS_INTEGER
                               ,po_upper_index  OUT PLS_INTEGER
                               ,po_statement    OUT VARCHAR2)
    IS
    --
    lv_predicate    VARCHAR2(7) := ' WHERE ';
    lv_lower_index  PLS_INTEGER;
    lv_upper_index  PLS_INTEGER;
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    IF NOT pi_where_clause
     THEN
        lv_predicate := ' AND ';
    END IF;
    --
    lv_lower_index := NVL(pi_skip_n_rows,0) + 1;
    lv_retval := lv_predicate||pi_index_column||' >= :lower_index';
    --
    IF pi_pagesize IS NOT NULL
     THEN
        lv_upper_index := lv_lower_index + pi_pagesize;
        lv_retval := lv_retval||' AND '||pi_index_column||' < :upper_index';
    END IF;
    --
    po_lower_index := lv_lower_index;
    po_upper_index := lv_upper_index;
    po_statement   := lv_retval;
    --
  END gen_row_restriction;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION gen_order_by(pi_order_columns  IN nm3type.tab_varchar30
                       ,pi_order_asc_desc IN nm3type.tab_varchar4
                       ,pi_enclose_cols   IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    --
    lv_retval  nm3type.max_varchar2;
    lv_enc     VARCHAR2(1);
    --
  BEGIN
    --
    IF pi_order_columns.COUNT != pi_order_asc_desc.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_util.gen_order_by');
    END IF;
    --
    IF pi_enclose_cols
     THEN
        lv_enc := '"';
    END IF;
    --
    FOR i IN 1..pi_order_columns.COUNT LOOP
      --
      IF i > 1
       THEN
          lv_retval := lv_retval||',';
      END IF;
      --
      lv_retval := lv_retval||lv_enc||pi_order_columns(i)||lv_enc||' '||pi_order_asc_desc(i);
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END gen_order_by;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE add_column_data(pi_cursor_col   IN     VARCHAR2
                           ,pi_query_col    IN     VARCHAR2
                           ,pi_datatype     IN     VARCHAR2
                           ,pi_mask         IN     VARCHAR2
                           ,pio_column_data IN OUT column_data_tab)
    IS
  BEGIN
    --
    pio_column_data(pio_column_data.COUNT+1).cursor_col := pi_cursor_col;
    pio_column_data(pio_column_data.COUNT).query_col := pi_query_col;
    pio_column_data(pio_column_data.COUNT).datatype := pi_datatype;
    pio_column_data(pio_column_data.COUNT).mask := pi_mask;
    --
  END add_column_data;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_datatype(pi_column_data IN  column_data_tab
                        ,pi_column      IN  VARCHAR2
                        ,po_query_col   OUT VARCHAR2
                        ,po_datatype    OUT VARCHAR2
                        ,po_mask        OUT VARCHAR2)
    IS
    --
    lv_query_col  nm3type.max_varchar2;
    lv_datatype   VARCHAR2(30);
    lv_mask       VARCHAR2(100);
    --
  BEGIN
    --
    FOR i IN 1..pi_column_data.COUNT LOOP
      --
      IF UPPER(pi_column_data(i).cursor_col) = UPPER(pi_column)
       THEN
          po_query_col := UPPER(NVL(pi_column_data(i).query_col,pi_column_data(i).cursor_col));
          po_datatype  := pi_column_data(i).datatype;
          po_mask      := pi_column_data(i).mask;
          EXIT;
      END IF;
      --
    END LOOP;
    --
    IF po_query_col IS NULL
     THEN
        --Unable to derive datatype of column
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 62
                     ,pi_supplementary_info => pi_column);
    END IF;
    --
  END get_datatype;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE process_filter(pi_columns            IN  nm3type.tab_varchar30
                          ,pi_column_data       IN  column_data_tab
                          ,pi_operators          IN  nm3type.tab_varchar30
                          ,pi_values_1           IN  nm3type.tab_varchar32767
                          ,pi_values_2           IN  nm3type.tab_varchar32767
                          ,pi_where_or_and       IN  VARCHAR2 DEFAULT 'WHERE'
                          ,po_where_clause       OUT nm3type.max_varchar2)
    IS
    --
    lv_query_col  nm3type.max_varchar2;
    lv_datatype   VARCHAR2(30);
    lv_mask       VARCHAR2(100);
    lv_operation  VARCHAR2(10) := pi_where_or_and;
    --
  BEGIN
    --
    IF pi_columns.COUNT != pi_operators.COUNT
     OR pi_columns.COUNT != pi_values_1.COUNT
     OR pi_columns.COUNT != pi_values_2.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_api.process_filter');
    END IF;
    --
    FOR i IN 1..pi_columns.COUNT LOOP
      --
      IF i > 1
       THEN
          lv_operation := 'AND';
      END IF;
      --
      get_datatype(pi_column_data => pi_column_data
                  ,pi_column      => pi_columns(i)
                  ,po_query_col   => lv_query_col
                  ,po_datatype    => lv_datatype
                  ,po_mask        => lv_mask);
      --
      CASE
        WHEN pi_operators(i) = c_contains
         THEN
            --
            IF lv_datatype != c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
            END IF;
            --
            po_where_clause := po_where_clause||' '||lv_operation||' UPPER('||lv_query_col||') LIKE ''%'||UPPER(pi_values_1(i))||'%''';
            --
        WHEN pi_operators(i) = c_does_not_contain
         THEN
            --
            IF lv_datatype != c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
            END IF;
            --
            po_where_clause := po_where_clause||' '||lv_operation||' UPPER('||lv_query_col||') NOT LIKE ''%'||UPPER(pi_values_1(i))||'%''';
            --
        WHEN pi_operators(i) = c_starts_with
         THEN
            --
            IF lv_datatype != c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
            END IF;
            --
            po_where_clause := po_where_clause||' '||lv_operation||' UPPER('||lv_query_col||') LIKE '''||UPPER(pi_values_1(i))||'%''';
            --
        WHEN pi_operators(i) = c_ends_with
         THEN
            IF lv_datatype != c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
            END IF;
            --
            po_where_clause := po_where_clause||' '||lv_operation||' UPPER('||lv_query_col||') LIKE ''%'||UPPER(pi_values_1(i))||'''';
            --
        WHEN pi_operators(i) = c_equals
         THEN
            IF lv_datatype = c_varchar2_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' UPPER('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' = '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                     ,pi_datatype    => lv_datatype
                                                                     ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_does_not_equal
         THEN
            IF lv_datatype = c_varchar2_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' UPPER('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' != '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                      ,pi_datatype    => lv_datatype
                                                                      ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_greater_than
         THEN
            --
            IF lv_datatype = c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' > '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                     ,pi_datatype    => lv_datatype
                                                                     ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_less_than
         THEN
            --
            IF lv_datatype = c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' < '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                     ,pi_datatype    => lv_datatype
                                                                     ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_geater_than_or_equal_to
         THEN
            --
            IF lv_datatype = c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' >= '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                      ,pi_datatype    => lv_datatype
                                                                      ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_less_than_or_equal_to
         THEN
            --
            IF lv_datatype = c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' <= '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                      ,pi_datatype    => lv_datatype
                                                                      ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_between
         THEN
            --
            IF (pi_values_1(i) IS NULL OR pi_values_2(i) IS NULL)
             THEN
                --Two values must be supplied for filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 45
                             ,pi_supplementary_info => pi_operators(i));
            END IF;
            --
            IF lv_datatype = c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' BETWEEN '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                           ,pi_datatype    => lv_datatype
                                                                           ,pi_format_mask => lv_mask)
                            ||' AND '||get_assignment(pi_value       => UPPER(pi_values_2(i))
                                                     ,pi_datatype    => lv_datatype
                                                     ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_not_between
         THEN
            --
            IF (pi_values_1(i) IS NULL OR pi_values_2(i) IS NULL)
             THEN
                --Two values must be supplied for filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 45
                             ,pi_supplementary_info => pi_operators(i));
            END IF;
            --
            IF lv_datatype = c_varchar2_col
             THEN
                --Invalid filter function
                hig.raise_ner(pi_appl               => 'AWLRS'
                             ,pi_id                 => 43
                             ,pi_supplementary_info => pi_operators(i)||' Datatype: '||lv_datatype);
                --
            ELSIF lv_datatype = c_date_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TRUNC('||lv_query_col||')';
                --
            ELSIF lv_datatype = c_datetime_col
             THEN
                --
                po_where_clause := po_where_clause||' '||lv_operation||' TO_DATE(TO_CHAR('||lv_query_col||','''||c_datetime_mask||'''),'''||c_datetime_mask||''')';
                --
            ELSE
                --
                po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col;
                --
            END IF;
            --
            po_where_clause := po_where_clause||' NOT BETWEEN '||get_assignment(pi_value       => UPPER(pi_values_1(i))
                                                                               ,pi_datatype    => lv_datatype
                                                                               ,pi_format_mask => lv_mask)
                            ||' AND '||get_assignment(pi_value       => UPPER(pi_values_2(i))
                                                     ,pi_datatype    => lv_datatype
                                                     ,pi_format_mask => lv_mask);
            --
        WHEN pi_operators(i) = c_has_value
         THEN
            --
            po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col||' IS NOT NULL';
            --
        WHEN pi_operators(i) = c_does_not_have_value
         THEN
            --
            po_where_clause := po_where_clause||' '||lv_operation||' '||lv_query_col||' IS NULL';
            --
        ELSE
            --Invalid filter function
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 43);
      END CASE;
          --
    END LOOP;
    --
  END process_filter;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_preferred_lrm
    RETURN VARCHAR2 IS
    --
  BEGIN
    --
    RETURN NVL(SYS_CONTEXT('NM3CORE','PREFERRED_LRM'),c_all_lrms_code);
    --
  END get_preferred_lrm;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_preferred_lrm(po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    WITH plrm AS (SELECT CAST(NVL(SYS_CONTEXT('NM3CORE','PREFERRED_LRM'),c_all_lrms_code) AS VARCHAR2(10)) plrm_code FROM dual)
    SELECT plrm_code
          ,CAST(NVL(ngt_descr,c_all_lrms_descr) AS VARCHAR2(40)) plrm_descr
      FROM plrm
          ,nm_group_types
     WHERE plrm_code = ngt_group_type(+)
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
  END get_preferred_lrm;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_lrms(pi_filter           IN  VARCHAR2
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
                                     ||CHR(10)||'      ,group_type_descr'
                                     ||CHR(10)||'      ,row_count'
                                     ||CHR(10)||'  FROM (SELECT rownum ind'
                                     ||CHR(10)||'              ,group_type'
                                     ||CHR(10)||'              ,group_type_descr'
                                     ||CHR(10)||'              ,CASE'
                                     ||CHR(10)||'                 WHEN f.filter_value IS NULL THEN 0'
                                     ||CHR(10)||'                 WHEN UPPER(group_type_descr) = f.filter_value THEN 1'
                                     ||CHR(10)||'                 WHEN UPPER(group_type_descr) LIKE f.filter_value||''%'' THEN 2'
                                     ||CHR(10)||'                 ELSE 3'
                                     ||CHR(10)||'               END match_quality'
                                     ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                     ||CHR(10)||'          FROM (SELECT ngt.ngt_group_type group_type'
                                     ||CHR(10)||'                      ,ngt.ngt_descr group_type_descr'
                                     ||CHR(10)||'                  FROM nm_group_types ngt'
                                     ||CHR(10)||'                 WHERE ngt.ngt_linear_flag = ''Y'''
                                     ||CHR(10)||'                 UNION ALL'
                                     ||CHR(10)||'                SELECT :all_lrms_code group_type'
                                     ||CHR(10)||'                      ,:all_lrms_descr group_type_descr'
                                     ||CHR(10)||'                  FROM dual'
                                     ||CHR(10)||'                 ORDER BY 2)'
                                     ||CHR(10)||'              ,filter_tab f'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'         WHERE UPPER(group_type_descr) LIKE ''%''||f.filter_value||''%''';
        --
    END IF;
    /*
    ||Get the page parameters.
    */
    gen_row_restriction(pi_index_column => 'ind'
                       ,pi_skip_n_rows  => pi_skip_n_rows
                       ,pi_pagesize     => pi_pagesize
                       ,po_lower_index  => lv_lower_index
                       ,po_upper_index  => lv_upper_index
                       ,po_statement    => lv_row_restriction);
    --
    lv_cursor_sql := lv_cursor_sql
                     ||lv_filter
                     ||CHR(10)||'         ORDER BY match_quality,group_type_descr)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,c_all_lrms_code
             ,c_all_lrms_descr
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,c_all_lrms_code
             ,c_all_lrms_descr
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
  END get_list_of_lrms;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_preferred_lrm(pi_group_type   IN VARCHAR2
                             ,pi_set_user_opt IN BOOLEAN DEFAULT TRUE)
    IS
    --
    lv_group_type  nm_group_types_all.ngt_group_type%TYPE;
    --
  BEGIN
    --
    IF NVL(pi_group_type,c_all_lrms_code) = c_all_lrms_code
     THEN
        lv_group_type := NULL;
    ELSE
        lv_group_type := pi_group_type;
    END IF;
    --
    nm3user.set_preferred_lrm(pi_group_type   => lv_group_type
                             ,pi_set_user_opt => pi_set_user_opt);
    --
  END set_preferred_lrm;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_preferred_lrm(pi_group_type       IN  VARCHAR2
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    set_preferred_lrm(pi_group_type => pi_group_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_preferred_lrm;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_length_units(po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT un_unit_id     unit_id
          ,un_unit_name   unit_name
          ,un_format_mask format_mask
      FROM nm_units
     WHERE un_domain_id = (SELECT ud_domain_id
                             FROM nm_unit_domains
                            WHERE ud_domain_name = 'LENGTH')
         ;
    --
    get_default_success_cursor(po_message_severity => po_message_severity
                              ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        handle_exception(po_message_severity => po_message_severity
                        ,po_cursor           => po_message_cursor);
  END get_length_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_message(pi_category    IN     hig_codes.hco_code%TYPE
                       ,pi_message     IN     VARCHAR2
                       ,po_message_tab IN OUT NOCOPY awlrs_message_tab)
    IS
  BEGIN
    --
    IF pi_category IN(c_msg_cat_success
                     ,c_msg_cat_info
                     ,c_msg_cat_warning
                     ,c_msg_cat_ask_continue
                     ,c_msg_cat_circular_route
                     ,c_msg_cat_error)
     THEN
        po_message_tab.extend;
        po_message_tab(po_message_tab.count) := awlrs_message(pi_category,pi_message);
    ELSE
        --Invalid Message Category
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 20
                     ,pi_supplementary_info => pi_category);
    END IF;
    --
  END add_message;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_message_cursor(pi_message_tab IN  awlrs_message_tab
                              ,po_cursor      OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT category
          ,message
      FROM TABLE(CAST(pi_message_tab AS awlrs_message_tab))
         ;
    --
  END get_message_cursor;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_highest_severity(pi_message_tab      IN  awlrs_message_tab
                                ,po_message_severity OUT hig_codes.hco_code%TYPE)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := c_msg_cat_success;
    --
  BEGIN
    --
    FOR i IN 1..pi_message_tab.COUNT LOOP
      --
      CASE pi_message_tab(i).category
        WHEN c_msg_cat_error
         THEN
            lv_severity := c_msg_cat_error;
            EXIT;
        WHEN c_msg_cat_circular_route
         THEN
            lv_severity := c_msg_cat_circular_route;
        WHEN c_msg_cat_ask_continue
         THEN
            lv_severity := c_msg_cat_ask_continue;
        WHEN c_msg_cat_warning
         THEN
            IF lv_severity NOT IN(c_msg_cat_circular_route,c_msg_cat_ask_continue)
             THEN
                lv_severity := c_msg_cat_warning;
            END IF;
        WHEN c_msg_cat_info
         THEN
            IF lv_severity NOT IN (c_msg_cat_circular_route,c_msg_cat_ask_continue,c_msg_cat_warning)
             THEN
                lv_severity := c_msg_cat_info;
            END IF;
        ELSE
            NULL;
      END CASE;
      --
    END LOOP;
    --
    po_message_severity := lv_severity;
    --
  END get_highest_severity;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_default_success_tab(po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_tab      OUT NOCOPY awlrs_message_tab)
    IS
    --
    --
  BEGIN
    --
    po_message_severity := c_msg_cat_success;
    po_message_tab      := awlrs_message_tab();
    --
  END get_default_success_tab;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_default_success_cursor(po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_messages  awlrs_message_tab;
    --
  BEGIN
    --
    get_default_success_tab(po_message_severity => po_message_severity
                           ,po_message_tab      => lt_messages);
    --
    get_message_cursor(pi_message_tab => lt_messages
                      ,po_cursor      => po_cursor);
    --
  END get_default_success_cursor;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_ner_to_message_tab(pi_ner_appl           IN     nm_errors.ner_appl%TYPE
                                  ,pi_ner_id             IN     nm_errors.ner_id%TYPE
                                  ,pi_supplementary_info IN     VARCHAR2 DEFAULT NULL
                                  ,pi_category           IN     hig_codes.hco_code%TYPE
                                  ,po_message_tab        IN OUT NOCOPY awlrs_message_tab)
    IS
  BEGIN
    --
    add_message(pi_category    => pi_category
               ,pi_message     => hig.raise_and_catch_ner(pi_appl               => pi_ner_appl
                                                         ,pi_id                 => pi_ner_id
                                                         ,pi_supplementary_info => pi_supplementary_info)
               ,po_message_tab => po_message_tab);
    --
  END add_ner_to_message_tab;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE handle_exception(po_message_severity IN OUT hig_codes.hco_code%TYPE
                            ,po_message_tab      IN OUT NOCOPY awlrs_message_tab)
    IS
  BEGIN
    --
    IF SQLCODE != 0
     THEN
        --
        po_message_severity := c_msg_cat_error;
        add_message(pi_category    => c_msg_cat_error
                   ,pi_message     => nm3flx.parse_error_message(SQLERRM)
                   ,po_message_tab => po_message_tab);
        --
        IF hig.get_sysopt('AWLUIDBUG') = 'Y'
         THEN
            --
            add_message(pi_category    => c_msg_cat_error
                       ,pi_message     => 'Unparsed Error:'||CHR(10)||SQLERRM
                       ,po_message_tab => po_message_tab);
            --
            add_message(pi_category    => c_msg_cat_error
                       ,pi_message     => 'Backtrace:'||CHR(10)||dbms_utility.format_error_backtrace
                       ,po_message_tab => po_message_tab);
            --
            add_message(pi_category    => c_msg_cat_error
                       ,pi_message     => 'Call Stack:'||CHR(10)||dbms_utility.format_call_stack
                       ,po_message_tab => po_message_tab);
            --
        END IF;
    END IF;
    --
  END handle_exception;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE handle_exception(po_message_severity IN OUT hig_codes.hco_code%TYPE
                            ,po_cursor              OUT sys_refcursor)
    IS
    --
    lt_message_tab  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    handle_exception(po_message_severity => po_message_severity
                    ,po_message_tab      => lt_message_tab);
    --
    get_message_cursor(pi_message_tab => lt_message_tab
                      ,po_cursor      => po_cursor);
    --
  END handle_exception;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION inv_category_is_updatable(pi_category IN nm_inv_categories.nic_category%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval BOOLEAN;
    --
  BEGIN
    --
    lv_retval := invsec.nic_is_updatable_from_module(pi_category => pi_category
                                                    ,pi_module   => c_awlrs_module);
    --
    RETURN nm3flx.boolean_to_char(p_boolean => lv_retval);
    --
  END inv_category_is_updatable;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION ref_cursor_to_csv(pi_cursor    IN sys_refcursor
                            ,pi_title_row IN BOOLEAN DEFAULT TRUE)
    RETURN CLOB IS
    --
    lv_cursor        sys_refcursor := pi_cursor;
    lv_cursor_id     NUMBER;
    lv_column_count  NUMBER;
    lv_varchar2      nm3type.max_varchar2;
    lv_number        NUMBER;
    lv_date          DATE;
    lv_clob          CLOB;
    lv_title         CLOB;
    lv_tmp           CLOB;
    lv_retval        CLOB;
    --
    lt_desc  dbms_sql.desc_tab;
    --
  BEGIN
    /*
    ||Convert to DBMS_SQL Cursor.
    */
    lv_cursor_id := dbms_sql.to_cursor_number(rc => lv_cursor);
    --
    dbms_sql.describe_columns(c       => lv_cursor_id
                             ,col_cnt => lv_column_count
                             ,desc_t  => lt_desc);
    /*
    ||Define the columns for DBMS_SQL.
    */
    FOR i IN 1 .. lv_column_count LOOP
      --
      IF pi_title_row
       THEN
          --
          IF i > 1
           THEN
              lv_title := lv_title||',"'||INITCAP(REPLACE(lt_desc(i).col_name,'_',' '))||'"';
          ELSE
              lv_title := lv_title||'"'||INITCAP(REPLACE(lt_desc(i).col_name,'_',' '))||'"';
          END IF;
          --
      END IF;
      --
      CASE
        WHEN lt_desc(i).col_type = c_number
          THEN
             dbms_sql.define_column(c        => lv_cursor_id
                                   ,position => i
                                   ,column   => lv_number);
        WHEN lt_desc(i).col_type = c_date
          THEN
             dbms_sql.define_column(c        => lv_cursor_id
                                   ,position => i
                                   ,column   => lv_date);
        WHEN lt_desc(i).col_type IN(c_varchar,c_varchar2)
          THEN
             dbms_sql.define_column(c           => lv_cursor_id
                                   ,position    => i
                                   ,column      => lv_varchar2
                                   ,column_size => nm3type.c_max_varchar2_size);
        WHEN lt_desc(i).col_type = c_clob
          THEN
             dbms_sql.define_column(c        => lv_cursor_id
                                   ,position => i
                                   ,column   => lv_clob);
        ELSE
            /*
            ||Unsupported Column Type.
            */
            NULL;
      END CASE;
      --
    END LOOP;
    --
    IF pi_title_row
     THEN
        lv_title := lv_title||CHR(10);
        lv_retval := lv_title;
    END IF;
    /*
    ||Get the data from the cursor and write it to the output.
    */
    WHILE NVL(dbms_sql.fetch_rows(lv_cursor_id),0) > 0 LOOP
      --
      FOR i IN 1 .. lv_column_count LOOP
        --
        IF i > 1
         THEN
            lv_tmp := lv_tmp||',';
        END IF;
        --
        CASE
          WHEN lt_desc(i).col_type = c_number
            THEN
               dbms_sql.column_value(c        => lv_cursor_id
                                    ,position => i
                                    ,value    => lv_number);
               --
               lv_tmp := lv_tmp||lv_number;
               --
          WHEN lt_desc(i).col_type = c_date
            THEN
               dbms_sql.column_value(c        => lv_cursor_id
                                    ,position => i
                                    ,value    => lv_date);
               --
               lv_tmp := lv_tmp||TO_CHAR(lv_date,'DD-MON-YYYY HH24:MI');
               --
          WHEN lt_desc(i).col_type IN(c_varchar,c_varchar2)
            THEN
               dbms_sql.column_value(c        => lv_cursor_id
                                    ,position => i
                                    ,value    => lv_varchar2);
               --
               lv_tmp := lv_tmp||'"'||lv_varchar2||'"';
               --
          WHEN lt_desc(i).col_type = c_clob
            THEN
               dbms_sql.column_value(c        => lv_cursor_id
                                    ,position => i
                                    ,value    => lv_clob);
               --
               lv_tmp := lv_tmp||'"'||lv_clob||'"';
               --
          ELSE
              /*
              ||Unsupported Column Type.
              */
              NULL;
        END CASE;
        --
      END LOOP;
      --
      lv_tmp := lv_tmp||CHR(10);
      lv_retval := lv_retval||lv_tmp;
      lv_tmp := NULL;
      --
    END LOOP;
    --
    dbms_sql.close_cursor(c => lv_cursor_id);
    --
    RETURN lv_retval;
    --
  EXCEPTION
    WHEN others
     THEN
        IF dbms_sql.is_open(lv_cursor_id)
         THEN
            dbms_sql.close_cursor(lv_cursor_id);
        END IF;
        RAISE;
  END ref_cursor_to_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE ref_cursor_to_csv(pi_cursor           IN  sys_refcursor
                             ,pi_title_row        IN  VARCHAR2 DEFAULT 'Y'
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_retval  CLOB;
    --
  BEGIN
    --
    lv_retval := awlrs_util.ref_cursor_to_csv(pi_cursor    => pi_cursor
                                             ,pi_title_row => (pi_title_row = 'Y'));
    --
    OPEN po_cursor FOR
    SELECT lv_retval csv_output
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
  END ref_cursor_to_csv;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_notnull(pi_parameter_desc  IN hig_options.hop_id%TYPE
                            ,pi_parameter_value IN hig_options.hop_value%TYPE)
    IS
    --
  BEGIN
    --
    IF pi_parameter_value IS NULL THEN
      --
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 22
                   ,pi_supplementary_info => pi_parameter_desc || ' has not been specified');
      --
    END IF;
    --
  END validate_notnull;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_yn(pi_parameter_desc  IN hig_options.hop_id%TYPE
                       ,pi_parameter_value IN hig_options.hop_value%TYPE)
    IS
    --
  BEGIN
    --
    IF pi_parameter_value IS NULL THEN
      --
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 22
                   ,pi_supplementary_info => pi_parameter_desc || ' has not been specified');

    ELSE
      --
      IF pi_parameter_value NOT IN ('Y','N') THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 1
                     ,pi_supplementary_info => pi_parameter_desc);
        --
      END IF;
      --
    END IF;
    --
  END validate_yn;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_enddate_isnull(pi_enddate IN DATE)
    IS
    --
  BEGIN
    --
    IF pi_enddate IS NOT NULL THEN
      --
      hig.raise_ner(pi_appl               => 'AWLRS'
                   ,pi_id                 => 74);
      --
    END IF;
    --
  END validate_enddate_isnull;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE set_decimal_point
    IS
    --
  BEGIN
    --
    SELECT SUBSTR(value,1,1) decimal_point
      INTO g_decimal_point
      FROM v$nls_parameters
     WHERE parameter ='NLS_NUMERIC_CHARACTERS'
         ;
    --
  EXCEPTION
    WHEN others
     THEN
        --
        g_decimal_point := '.';
        --
  END set_decimal_point;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_decimal_point
    RETURN VARCHAR IS
    --
  BEGIN
    --
    RETURN g_decimal_point;
    --
  END get_decimal_point;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION apply_max_digits(pi_value IN NUMBER)
    RETURN NUMBER IS
    --
  BEGIN
    /*
    ||The .Net Decimal Class can only deal with 28 digits so
    ||we need to round the number returned to make sure we
    ||respect that limit.
    */
    RETURN ROUND(pi_value,c_max_digits - INSTR(TO_CHAR(pi_value),g_decimal_point) -1);
    --
  END apply_max_digits;

--
--------------------------------------------------------------------------------
--
BEGIN
  --
  set_decimal_point;
  --
END awlrs_util;
/