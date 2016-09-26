CREATE OR REPLACE PACKAGE BODY awlrs_util
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_util.pkb-arc   1.0   26 Sep 2016 18:17:32   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_util.pkb  $
  --       Date into PVCS   : $Date:   26 Sep 2016 18:17:32  $
  --       Date fetched Out : $Modtime:   26 Sep 2016 17:09:26  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.0  $';
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
  FUNCTION user_has_normal_access(pi_admin_unit IN nm_admin_units_all.nau_admin_unit%TYPE)
    RETURN BOOLEAN IS
    --
    lv_retval      BOOLEAN := FALSE;
    --lv_admin_type  nm_au_types.nat_admin_type%TYPE;
    --
    lt_user_normal_nau  admin_unit_tab;
    --
  BEGIN
    /*
    ||TODO - make sure excluding Admin Type is ok.
    */
    --
    --lv_admin_type := ???;
    --
    SELECT DISTINCT nag.nag_child_admin_unit
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
       --AND nau.nau_admin_type = lv_admin_type
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
                     ,c_msg_cat_error)
     THEN
        po_message_tab.extend;
        po_message_tab(po_message_tab.count) := awlrs_message(pi_category,pi_message);
    ELSE
        raise_application_error(-20001,'Invalid Message Category ['||pi_category||'].');
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
                                  ,po_message_severity   IN OUT hig_codes.hco_code%TYPE
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
                   ,pi_message     => SQLERRM
                   ,po_message_tab => po_message_tab);
        --
        IF hig.get_sysopt('AWLUIDBUG') = 'Y'
         THEN
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
-----------------------------------------------------------------------------
--
END awlrs_util;
/