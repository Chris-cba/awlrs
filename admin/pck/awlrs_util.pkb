CREATE OR REPLACE PACKAGE BODY awlrs_util
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_util.pkb-arc   1.6   22 Nov 2016 17:35:24   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_util.pkb  $
  --       Date into PVCS   : $Date:   22 Nov 2016 17:35:24  $
  --       Date fetched Out : $Modtime:   18 Nov 2016 13:54:38  $
  --       Version          : $Revision:   1.6  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.6  $';
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
  PROCEDURE get_format(pi_obj_type    IN  VARCHAR2
                      ,pi_inv_or_ne   IN  VARCHAR2
                      ,pi_column_name IN  nm_type_columns.ntc_column_name%TYPE
                      ,po_datatype    OUT nm_type_columns.ntc_column_type%TYPE
                      ,po_format      OUT nm_type_columns.ntc_format%TYPE)
    IS
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
        --
    ELSIF pi_inv_or_ne = 'NE'
     THEN
        --
        SELECT ntc_column_type
              ,ntc_format
          INTO po_datatype
              ,po_format
          FROM nm_type_columns
         WHERE ntc_nt_type = pi_obj_type
           AND ntc_column_name = pi_column_name
             ;
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
        IF pi_datatype = 'NUMBER'
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
        ELSIF pi_datatype = 'DATE'
         THEN
            --
            lv_retval := 'TO_DATE('||nm3flx.string(lv_value)||','||nm3flx.string(NVL(pi_format_mask,'DD-MON-YYYY'))||')';
            --
        ELSE
            --
            lv_retval := nm3flx.string(lv_value);
            --
        END IF;
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
                         ,pi_datatype    => lv_datatype
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
    SELECT hov_id
          ,hov_value
      FROM hig_option_values
     WHERE hov_id IN(SELECT * FROM TABLE(CAST(lt_names AS nm_code_tbl)))
     ORDER
        BY hov_id
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
    lv_severity  hig_codes.hco_code%TYPE;
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
        WHEN c_msg_cat_ask_continue
         THEN
            lv_severity := c_msg_cat_ask_continue;
        WHEN c_msg_cat_warning
         THEN
            IF lv_severity != c_msg_cat_ask_continue
             THEN
                lv_severity := c_msg_cat_warning;
            END IF;
        WHEN c_msg_cat_info
         THEN
            IF lv_severity NOT IN (c_msg_cat_ask_continue,c_msg_cat_warning)
             THEN
                lv_severity := c_msg_cat_info;
            END IF;
        WHEN c_msg_cat_success
         THEN
            IF lv_severity NOT IN (c_msg_cat_ask_continue,c_msg_cat_warning,c_msg_cat_info)
             THEN
                lv_severity := c_msg_cat_success;
            END IF;
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
                                                    ,pi_module   => 'AWLRS0001');
    --
    RETURN nm3flx.boolean_to_char(p_boolean => lv_retval);
    --
  END inv_category_is_updatable;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gen_row_restriction(pi_index_column IN VARCHAR2
                              ,pi_where_clause IN BOOLEAN DEFAULT TRUE
                              ,pi_skip_n_rows  IN PLS_INTEGER
                              ,pi_pagesize     IN PLS_INTEGER)

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
    lv_start_index := NVL(pi_skip_n_rows,0) + 1;
    --
    IF pi_skip_n_rows IS NOT NULL
     THEN
        lv_retval := lv_predicate||pi_index_column||' >= '||lv_start_index;
    END IF;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        IF lv_retval IS NOT NULL
         THEN
            lv_retval := lv_retval||' AND '||pi_index_column||' < '||TO_CHAR(lv_start_index + pi_pagesize);
        ELSE
            lv_retval := lv_predicate||pi_index_column||' < '||TO_CHAR(lv_start_index + pi_pagesize);
        END IF;
    END IF;
    --
    RETURN lv_retval;
    --
  END gen_row_restriction;

--
-----------------------------------------------------------------------------
--
END awlrs_util;
/