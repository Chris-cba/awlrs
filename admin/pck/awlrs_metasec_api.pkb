CREATE OR REPLACE PACKAGE BODY awlrs_metasec_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_metasec_api.pkb-arc   1.18   May 15 2020 11:54:44   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_metasec_api.pkb  $
  --       Date into PVCS   : $Date:   May 15 2020 11:54:44  $
  --       Date fetched Out : $Modtime:   May 15 2020 11:29:34  $
  --       Version          : $Revision:   1.18  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.18  $';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_metasec_api';
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
  FUNCTION admin_type_exists(pi_admin_type IN nm_au_types_full.nat_admin_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_au_types_full
     WHERE nat_admin_type = pi_admin_type;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END admin_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION admin_unit_exists(pi_admin_unit IN nm_admin_units_all.nau_admin_unit%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_admin_units_all
     WHERE nau_admin_unit = pi_admin_unit;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END admin_unit_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION admin_unit_exists(pi_admin_type IN nm_admin_units_all.nau_admin_type%TYPE
                            ,pi_unit_code  IN nm_admin_units_all.nau_unit_code%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_admin_units_all
     WHERE nau_admin_type = pi_admin_type
       AND nau_unit_code  = pi_unit_code;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END admin_unit_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION admin_unit_exists(pi_admin_type IN nm_admin_units_all.nau_admin_type%TYPE
                            ,pi_name       IN nm_admin_units_all.nau_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_admin_units_all
     WHERE nau_admin_type = pi_admin_type
       AND nau_name = pi_name;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END admin_unit_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION module_exists(pi_module IN hig_modules.hmo_module%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_modules
     WHERE hmo_module = pi_module;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END module_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION module_role_exists(pi_module IN hig_module_roles.hmr_module%TYPE
                             ,pi_role   IN hig_module_roles.hmr_module%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_module_roles
     WHERE hmr_module = pi_module
       AND hmr_role   = pi_role;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END module_role_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION product_exists(pi_product IN hig_products.hpr_product%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_products
     WHERE hpr_product = pi_product;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      RETURN lv_exists;
      --
  END product_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION role_exists(pi_role IN hig_roles.hro_role%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_roles
     WHERE hro_role = pi_role;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END role_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION check_privs(pi_priv IN VARCHAR2) 
    RETURN BOOLEAN 
  IS
  
    CURSOR c1 IS
       SELECT 1 
         FROM user_sys_privs 
        WHERE privilege = pi_priv;
    --
    CURSOR c2 IS
       SELECT 1 
         FROM dba_role_privs r, dba_sys_privs s
        WHERE s.privilege = pi_priv
          AND s.grantee = r.granted_role 
          AND r.grantee = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME');
  
    dummy  NUMBER;
    retval BOOLEAN;
  
  BEGIN
      OPEN c1;
     FETCH c1 
      INTO dummy;
     --
     retval := c1%FOUND;
     IF NOT retval THEN
        OPEN c2;
       FETCH c2 
        INTO dummy;
       retval := c2%FOUND;
       CLOSE c2;
     END IF;
     CLOSE c1;
     RETURN retval;  
  END;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION can_delete_role (pi_role  IN  hig_module_roles.hmr_role%TYPE)
    RETURN BOOLEAN 
  IS
    --
    -- Does the user have the privileges to remove a role
    --
    CURSOR C1 is
      SELECT 'x' 
        FROM dba_sys_privs
       WHERE grantee = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
         AND privilege = 'DROP ANY ROLE';
  --
    CURSOR C2 is 
      SELECT 'x' 
        FROM dba_role_privs r
            ,dba_sys_privs s
       WHERE s.privilege = 'DROP ANY ROLE'
         AND s.grantee = r.granted_role
         AND r.grantee = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME');
  --  
    CURSOR C3 is
      SELECT 'x' 
        FROM dba_role_privs
       WHERE grantee = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
         AND GRanted_role = pi_role
         AND ADmin_option = 'YES';
  --
    dummy varchar2(1);
  --
  BEGIN
    OPEN c1;
    FETCH c1 INTO dummy;
    IF c1%notfound THEN
      OPEN c2;
      FETCH c2 INTO dummy;
      IF c2%notfound THEN
         open c3;
         FETCH c3 INTO dummy;
         IF c3%notfound THEN
           RETURN FALSE;
         END IF;
      END IF;
    END IF;
    --
    RETURN TRUE;
    --
  END;
 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_product_license(pi_product          IN     hig_products.hpr_product%TYPE
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    UPDATE hig_products
       SET hpr_key = ascii(hpr_product)
     WHERE hpr_product = pi_product;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_product_license;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE revoke_product_license(pi_product          IN     hig_products.hpr_product%TYPE
                                  ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    UPDATE hig_products
       SET hpr_key = ''
     WHERE hpr_product = pi_product;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END revoke_product_license;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_products(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := ' SELECT hpr_sequence sequence'
                                           ||'      ,hpr_product product_code'
                                           ||'      ,hpr_product_name product_name'
                                           ||'      ,hpr_version version'
                                           ||'      ,hpr_key license_key'
                                           ||'  FROM hig_products';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT sequence'
                                              ||' ,product_code'
                                              ||' ,product_name'
                                              ||' ,version'
                                              ||' ,license_key'
                                              ||' ,row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'sequence'
                                ,pi_query_col    => 'hpr_sequence'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product_code'
                                ,pi_query_col    => 'hpr_product'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product_name'
                                ,pi_query_col    => 'hpr_product_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'version'
                                ,pi_query_col    => 'hpr_version'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'license_key'
                                ,pi_query_col    => 'hpr_key'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --      
    END set_column_data;
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
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_column_data(po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpr_sequence, hpr_product')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING lv_lower_index;
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
  END get_paged_products;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_products(po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor
                        ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hpr_sequence
            ,hpr_product
            ,hpr_product_name
            ,hpr_version
            ,hpr_key 
        FROM hig_products
       ORDER BY hpr_sequence, hpr_product;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_products;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_upgrades(po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor
                        ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hpr_product_name
            ,hpr_product
            ,hup_product
            ,date_upgraded
            ,from_version
            ,to_version
            ,upgrade_script
            ,executed_by
            ,remarks 
        FROM hig_upgrades_vw
       ORDER BY date_upgraded DESC;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_upgrades;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_upgrades(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT hpr_product_name'
                              ||CHR(10)||'          ,hpr_product'
                              ||CHR(10)||'          ,hup_product'
                              ||CHR(10)||'          ,date_upgraded'
                              ||CHR(10)||'          ,from_version'
                              ||CHR(10)||'          ,to_version'
                              ||CHR(10)||'          ,upgrade_script'
                              ||CHR(10)||'          ,executed_by'
                              ||CHR(10)||'          ,remarks'
                              ||CHR(10)||'     FROM hig_upgrades_vw';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  hpr_product_name'      
                                                  ||',hpr_product'
                                                  ||',hup_product'
                                                  ||',date_upgraded'
                                                  ||',from_version'
                                                  ||',to_version'
                                                  ||',upgrade_script'
                                                  ||',executed_by'
                                                  ||',remarks'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'hpr_product_name'
                                ,pi_query_col  => 'hpr_product_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'hpr_product'
                                ,pi_query_col  => 'hpr_product'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'hup_product'
                                ,pi_query_col  => 'hup_product'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'date_upgraded'
                                ,pi_query_col  => 'date_upgraded'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'from_version'
                                ,pi_query_col  => 'from_version'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'to_version'
                                ,pi_query_col  => 'to_version'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);

      --
      awlrs_util.add_column_data(pi_cursor_col => 'upgrade_script'
                                ,pi_query_col  => 'upgrade_script'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'executed_by'
                                ,pi_query_col  => 'executed_by'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'remarks'
                                ,pi_query_col  => 'remarks'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'date_upgraded desc')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index;
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
  END get_paged_upgrades;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_types(po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nat_admin_type code
           ,nat_descr description
           ,nat_exclusive exclusive_
      FROM nm_au_types_full
     ORDER BY nat_admin_type;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_type(pi_admin_type    IN     nm_au_types_full.nat_admin_type%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nat_admin_type code
           ,nat_descr description
           ,nat_exclusive exclusive_
      FROM nm_au_types_full
     WHERE nat_admin_type = pi_admin_type
     ORDER BY nat_admin_type; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_type;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_admin_types(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nat_admin_type   code
                                                    ,nat_descr        description
                                                    ,nat_exclusive    exclusive_
                                               FROM nm_au_types_full';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  code'      
                                                  ||',description'
                                                  ||',exclusive_'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'code'
                                ,pi_query_col  => 'nat_admin_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nat_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'exclusive_'
                                ,pi_query_col  => 'nat_exclusive'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nat_admin_type desc')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index;
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
  END get_paged_admin_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_admin_type(pi_admin_type       IN      nm_au_types_full.nat_admin_type%TYPE
                             ,pi_desc             IN      nm_au_types_full.nat_descr%TYPE
                             ,pi_exclusive        IN      nm_au_types_full.nat_exclusive%TYPE
                             ,po_message_severity     OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    lv_max_code_length NUMBER := 20;
    --
  BEGIN
    --
    SAVEPOINT create_admin_type_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Type'
                               ,pi_parameter_value => pi_admin_type);
                    
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_desc);
    --
    IF admin_type_exists(pi_admin_type => pi_admin_type) = 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64);     
    END IF;
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Exclusive Flag'
                          ,pi_parameter_value => pi_exclusive);      
    --    
    INSERT 
      INTO nm_au_types_full 
           (nat_admin_type
           ,nat_descr
           ,nat_exclusive)
    VALUES (UPPER(pi_admin_type)
           ,UPPER(pi_desc)
           ,UPPER(pi_exclusive));
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO create_admin_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_admin_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_admin_type(pi_old_admin_type       IN     nm_au_types_full.nat_admin_type%TYPE
                             ,pi_old_description      IN     nm_au_types_full.nat_descr%TYPE
                             ,pi_old_exclusive        IN     nm_au_types_full.nat_exclusive%TYPE
                             ,pi_new_admin_type       IN     nm_au_types_full.nat_admin_type%TYPE
                             ,pi_new_description      IN     nm_au_types_full.nat_descr%TYPE
                             ,pi_new_exclusive        IN     nm_au_types_full.nat_exclusive%TYPE
                             ,po_message_severity        OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    CURSOR c_admin_units is
    SELECT COUNT(nau_admin_type)
      FROM nm_admin_units_all
     WHERE nau_admin_type = pi_old_admin_type;
    --
    lv_cnt  NUMBER;
    --    
    lr_db_nat_rec    nm_au_types_full%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_old_admin_type IN nm_au_types_full.nat_admin_type%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_nat_rec
        FROM nm_au_types_full
       WHERE nat_admin_type = pi_old_admin_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Admin unit type does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_admin_type_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin unit type'
                               ,pi_parameter_value => pi_new_admin_type);  
    --                    
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_new_description);                    
    --
    IF pi_old_admin_type <> pi_new_admin_type 
     THEN
        OPEN  c_admin_units;
        FETCH c_admin_units 
         INTO lv_cnt;
        CLOSE c_admin_units;
        
        IF lv_cnt > 0 
         THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 158);
        END IF;
    END IF;
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Exclusive'
                          ,pi_parameter_value => pi_new_exclusive);   
    --    
    get_db_rec(pi_old_admin_type => pi_old_admin_type);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_nat_rec.nat_admin_type != pi_old_admin_type
     OR (lr_db_nat_rec.nat_admin_type IS NULL AND pi_old_admin_type IS NOT NULL)
     OR (lr_db_nat_rec.nat_admin_type IS NOT NULL AND pi_old_admin_type IS NULL)
     --descr
     OR (lr_db_nat_rec.nat_descr != pi_old_description)
     OR (lr_db_nat_rec.nat_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_nat_rec.nat_descr IS NOT NULL AND pi_old_description IS NULL)
     --exclusive_
     OR (lr_db_nat_rec.nat_exclusive != pi_old_exclusive)
     OR (lr_db_nat_rec.nat_exclusive IS NULL AND pi_old_exclusive IS NOT NULL)
     OR (lr_db_nat_rec.nat_exclusive IS NOT NULL AND pi_old_exclusive IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_admin_type != pi_new_admin_type
       OR (pi_old_admin_type IS NULL AND pi_new_admin_type IS NOT NULL)
       OR (pi_old_admin_type IS NOT NULL AND pi_new_admin_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_description != pi_new_description
       OR (pi_old_description IS NULL AND pi_new_description IS NOT NULL)
       OR (pi_old_description IS NOT NULL AND pi_new_description IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_exclusive != pi_new_exclusive
       OR (pi_old_exclusive IS NULL AND pi_new_exclusive IS NOT NULL)
       OR (pi_old_exclusive IS NOT NULL AND pi_new_exclusive IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE nm_au_types_full
           SET nat_admin_type = UPPER(pi_new_admin_type)
              ,nat_descr      = UPPER(pi_new_description)
              ,nat_exclusive  = UPPER(pi_new_exclusive)
         WHERE nat_admin_type = pi_old_admin_type;
        --           
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF; 
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_admin_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_admin_type;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_admin_type(pi_admin_type        IN      nm_au_types_full.nat_admin_type%TYPE
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
    CURSOR c_admin_units IS
    SELECT COUNT(nau_admin_type)
      FROM nm_admin_units_all
     WHERE nau_admin_type = pi_admin_type;
    --
    lv_cnt  NUMBER;
    --
  BEGIN
    --
    SAVEPOINT del_admin_type_sp;
    --
    awlrs_util.check_historic_mode;
    --
    IF admin_type_exists(pi_admin_type => pi_admin_type) <> 'Y' 
     THEN 
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 26);
    END IF;
    --
    OPEN  c_admin_units;
    FETCH c_admin_units 
     INTO lv_cnt;
    CLOSE c_admin_units;
    
    IF lv_cnt = 0 
     THEN
        DELETE 
          FROM nm_au_types_full
         WHERE nat_admin_type = pi_admin_type;
    ELSE
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 2);
    END IF;                       
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO del_admin_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_admin_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_units(pi_admin_type    IN     nm_admin_units_all.nau_admin_type%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nau_admin_unit       admin_unit
           ,nau_unit_code        code
           ,nau_level            level_
           ,nau_authority_code   agency_code
           ,nau_name             name        
           ,nau_address1         address1
           ,nau_address2         address2
           ,nau_address3         address3
           ,nau_address4         address4
           ,nau_address5         address5
           ,nau_phone            phone
           ,nau_fax              fax
           ,nau_comments         comments
           ,nau_last_wor_no      last_work_no
           ,nau_start_date       start_date
           ,nau_end_date         end_date
           ,nau_admin_type       admin_type
           ,nau_nsty_sub_type    sub_type
           ,nau_prefix           prefix_
           ,nau_postcode         post_code
           ,nau_minor_undertaker minor_undertaker
           ,nau_tcpip            TCP_IP
           ,nau_domain           domain_
           ,nau_directory        directory
           ,nau_external_name    external_name
      FROM nm_admin_units_all
     WHERE nau_admin_type = pi_admin_type
     ORDER BY nau_admin_unit;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_unit(pi_admin_type    IN     nm_au_types_full.nat_admin_type%TYPE
                          ,pi_admin_unit    IN     nm_admin_units.nau_admin_unit%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nau_admin_unit       admin_unit
           ,nau_unit_code        code
           ,nau_level            level_
           ,nau_authority_code   agency_code
           ,nau_name             name        
           ,nau_address1         address1
           ,nau_address2         address2
           ,nau_address3         address3
           ,nau_address4         address4
           ,nau_address5         address5
           ,nau_phone            phone
           ,nau_fax              fax
           ,nau_comments         comments
           ,nau_last_wor_no      last_work_no           
           ,nau_start_date       start_date
           ,nau_end_date         end_date
           ,nau_admin_type       admin_type
           ,nau_nsty_sub_type    sub_type
           ,nau_prefix           prefix_
           ,nau_postcode         post_code
           ,nau_minor_undertaker minor_undertaker
           ,nau_tcpip            TCP_IP
           ,nau_domain           domain_
           ,nau_directory        directory
           ,nau_external_name    external_name
      FROM nm_admin_units_all
     WHERE nau_admin_type = pi_admin_type
       AND nau_admin_unit = pi_admin_unit
     ORDER BY nau_admin_unit;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_unit;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_admin_units(pi_admin_type       IN  nm_au_types_full.nat_admin_type%TYPE
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
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nau_admin_unit       admin_unit
                                                    ,nau_unit_code        code
                                                    ,nau_level            level_
                                                    ,nau_authority_code   agency_code
                                                    ,nau_name             name        
                                                    ,nau_address1         address1
                                                    ,nau_address2         address2
                                                    ,nau_address3         address3
                                                    ,nau_address4         address4
                                                    ,nau_address5         address5
                                                    ,nau_phone            phone
                                                    ,nau_fax              fax
                                                    ,nau_comments         comments
                                                    ,nau_last_wor_no      last_work_no                                                    
                                                    ,nau_start_date       start_date
                                                    ,nau_end_date         end_date
                                                    ,nau_admin_type       admin_type
                                                    ,nau_nsty_sub_type    sub_type
                                                    ,nau_prefix           prefix_
                                                    ,nau_postcode         post_code
                                                    ,nau_minor_undertaker minor_undertaker
                                                    ,nau_tcpip            tcp_ip
                                                    ,nau_domain           domain_
                                                    ,nau_directory        directory
                                                    ,nau_external_name    external_name
                                               FROM nm_admin_units_all
                                              WHERE nau_admin_type = :pi_admin_type';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT admin_unit'  
                                                 ||',code'
                                                 ||',level_'
                                                 ||',agency_code'
                                                 ||',name'
                                                 ||',address1'
                                                 ||',address2'
                                                 ||',address3'
                                                 ||',address4'
                                                 ||',address5'
                                                 ||',phone'
                                                 ||',fax'
                                                 ||',comments'
                                                 ||',last_work_no'                                                  
                                                 ||',start_date'
                                                 ||',end_date'
                                                 ||',admin_type'
                                                 ||',sub_type'
                                                 ||',prefix_'
                                                 ||',post_code'
                                                 ||',minor_undertaker'
                                                 ||',tcp_ip'
                                                 ||',domain_'
                                                 ||',directory'
                                                 ||',external_name'
                                                 ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'admin_unit'
                                ,pi_query_col  => 'nau_admin_unit'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'code'
                                ,pi_query_col  => 'nau_unit_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'level_'
                                ,pi_query_col  => 'nau_level'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'agency_code'
                                ,pi_query_col  => 'nau_authority_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'name'
                                ,pi_query_col  => 'nau_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'address1'
                                ,pi_query_col  => 'nau_address1'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'address2'
                                ,pi_query_col  => 'nau_address2'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'address3'
                                ,pi_query_col  => 'nau_address3'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'address4'
                                ,pi_query_col  => 'nau_address4'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'address5'
                                ,pi_query_col  => 'nau_address5'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'phone'
                                ,pi_query_col  => 'nau_phone'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'fax'
                                ,pi_query_col  => 'nau_fax'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'comments'
                                ,pi_query_col  => 'nau_comments'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'last_work_no'
                                ,pi_query_col  => 'nau_last_wor_no'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);                                
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'nau_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'nau_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL 
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'admin_type'
                                ,pi_query_col  => 'nau_admin_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'sub_type'
                                ,pi_query_col  => 'nau_nsty_sub_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'prefix_'
                                ,pi_query_col  => 'nau_prefix'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'post_code'
                                ,pi_query_col  => 'nau_postcode'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);   
      --
      awlrs_util.add_column_data(pi_cursor_col => 'minor_undertaker'
                                ,pi_query_col  => 'nau_minor_undertaker'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'tcp_ip'
                                ,pi_query_col  => 'nau_tcpip'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'domain_'
                                ,pi_query_col  => 'nau_domain'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'directory'
                                ,pi_query_col  => 'nau_directory'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'external_name'
                                ,pi_query_col  => 'nau_external_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);  
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nau_admin_unit desc')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_admin_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_admin_type
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
  END get_paged_admin_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_parent_admin_unit(pi_admin_type        IN     nm_admin_units_all.nau_admin_type%TYPE
                                    ,pi_unit_code         IN     nm_admin_units_all.nau_unit_code%TYPE      
                                    ,pi_authority_code    IN     nm_admin_units_all.nau_authority_code%TYPE
                                    ,pi_name              IN     nm_admin_units_all.nau_name%TYPE
                                    ,pi_address1          IN     nm_admin_units_all.nau_address1%TYPE
                                    ,pi_address2          IN     nm_admin_units_all.nau_address2%TYPE
                                    ,pi_address3          IN     nm_admin_units_all.nau_address3%TYPE
                                    ,pi_address4          IN     nm_admin_units_all.nau_address4%TYPE
                                    ,pi_address5          IN     nm_admin_units_all.nau_address5%TYPE
                                    ,pi_phone             IN     nm_admin_units_all.nau_phone%TYPE
                                    ,pi_fax               IN     nm_admin_units_all.nau_fax%TYPE
                                    ,pi_comments          IN     nm_admin_units_all.nau_comments%TYPE
                                    ,pi_last_wor_no       IN     nm_admin_units_all.nau_last_wor_no%TYPE
                                    ,pi_start_date        IN     nm_admin_units_all.nau_start_date%TYPE
                                    ,pi_end_date          IN     nm_admin_units_all.nau_end_date%TYPE
                                    ,pi_nsty_sub_type     IN     nm_admin_units_all.nau_nsty_sub_type%TYPE
                                    ,pi_prefix            IN     nm_admin_units_all.nau_prefix%TYPE
                                    ,pi_postcode          IN     nm_admin_units_all.nau_postcode%TYPE
                                    ,pi_minor_undertaker  IN     nm_admin_units_all.nau_minor_undertaker%TYPE
                                    ,pi_tcpip             IN     nm_admin_units_all.nau_tcpip%TYPE
                                    ,pi_domain            IN     nm_admin_units_all.nau_domain%TYPE
                                    ,pi_directory         IN     nm_admin_units_all.nau_directory%TYPE
                                    ,pi_external_name     IN     nm_admin_units_all.nau_external_name%TYPE
                                    ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    lr_nau_rec         nm_admin_units_all%ROWTYPE;
    lr_nau_rec_parent  nm_admin_units_all%ROWTYPE;
    --
  BEGIN
    --
    SAVEPOINT cre_parent_admin_unit_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Type'
                               ,pi_parameter_value => pi_admin_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Code'
                               ,pi_parameter_value => pi_unit_code);
    --
    IF admin_unit_exists (pi_admin_type => pi_admin_type
                         ,pi_unit_code  => pi_unit_code) = 'Y'
     OR admin_unit_exists (pi_admin_type => pi_admin_type
                          ,pi_name       => pi_name) = 'Y' 
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 64); 
    END IF;
    --
    IF admin_type_exists(pi_admin_type => pi_admin_type) = 'N' 
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 26);
    END IF;
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Minor Undertaker'
                          ,pi_parameter_value => pi_minor_undertaker); 
    /*
    ||build record for insert.
    */    
    lr_nau_rec.nau_admin_unit       := null; --created by package
    lr_nau_rec.nau_unit_code        := UPPER(pi_unit_code);
    lr_nau_rec.nau_level            := 1; 
    lr_nau_rec.nau_authority_code   := UPPER(pi_authority_code);
    lr_nau_rec.nau_name             := pi_name;
    lr_nau_rec.nau_address1         := pi_address1;
    lr_nau_rec.nau_address2         := pi_address2;
    lr_nau_rec.nau_address3         := pi_address3;
    lr_nau_rec.nau_address4         := pi_address4;
    lr_nau_rec.nau_address5         := pi_address5;
    lr_nau_rec.nau_postcode         := pi_postcode;
    lr_nau_rec.nau_phone            := pi_phone;
    lr_nau_rec.nau_fax              := pi_fax;
    lr_nau_rec.nau_start_date       := TRUNC(pi_start_date);
    lr_nau_rec.nau_end_date         := TRUNC(pi_end_date);
    lr_nau_rec.nau_admin_type       := pi_admin_type;
    lr_nau_rec.nau_nsty_sub_type    := pi_nsty_sub_type;
    lr_nau_rec.nau_prefix           := pi_prefix;
    lr_nau_rec.nau_minor_undertaker := pi_minor_undertaker;
    lr_nau_rec.nau_tcpip            := pi_tcpip;
    lr_nau_rec.nau_domain           := pi_domain;
    lr_nau_rec.nau_directory        := pi_directory;
    --
    nm3api_admin_unit.insert_admin_unit(pi_nau_rec               => lr_nau_rec
                                       ,pi_nau_rec_parent        => lr_nau_rec_parent);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO cre_parent_admin_unit_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_parent_admin_unit;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_child_admin_unit(pi_parent_admin_type        IN     nm_admin_units_all.nau_admin_type%TYPE
                                   ,pi_parent_admin_unit        IN     nm_admin_units_all.nau_admin_unit%TYPE
                                   ,pi_parent_unit_code         IN     nm_admin_units_all.nau_unit_code%TYPE      
                                   ,pi_parent_level             IN     nm_admin_units_all.nau_level%TYPE  
                                   ,pi_parent_authority_code    IN     nm_admin_units_all.nau_authority_code%TYPE
                                   ,pi_parent_name              IN     nm_admin_units_all.nau_name%TYPE
                                   ,pi_parent_address1          IN     nm_admin_units_all.nau_address1%TYPE
                                   ,pi_parent_address2          IN     nm_admin_units_all.nau_address2%TYPE
                                   ,pi_parent_address3          IN     nm_admin_units_all.nau_address3%TYPE
                                   ,pi_parent_address4          IN     nm_admin_units_all.nau_address4%TYPE
                                   ,pi_parent_address5          IN     nm_admin_units_all.nau_address5%TYPE
                                   ,pi_parent_phone             IN     nm_admin_units_all.nau_phone%TYPE
                                   ,pi_parent_fax               IN     nm_admin_units_all.nau_fax%TYPE
                                   ,pi_parent_comments          IN     nm_admin_units_all.nau_comments%TYPE
                                   ,pi_parent_last_wor_no       IN     nm_admin_units_all.nau_last_wor_no%TYPE
                                   ,pi_parent_start_date        IN     nm_admin_units_all.nau_start_date%TYPE
                                   ,pi_parent_end_date          IN     nm_admin_units_all.nau_end_date%TYPE
                                   ,pi_parent_nsty_sub_type     IN     nm_admin_units_all.nau_nsty_sub_type%TYPE
                                   ,pi_parent_prefix            IN     nm_admin_units_all.nau_prefix%TYPE
                                   ,pi_parent_postcode          IN     nm_admin_units_all.nau_postcode%TYPE
                                   ,pi_parent_minor_undertaker  IN     nm_admin_units_all.nau_minor_undertaker%TYPE
                                   ,pi_parent_tcpip             IN     nm_admin_units_all.nau_tcpip%TYPE
                                   ,pi_parent_domain            IN     nm_admin_units_all.nau_domain%TYPE
                                   ,pi_parent_directory         IN     nm_admin_units_all.nau_directory%TYPE
                                   ,pi_parent_external_name     IN     nm_admin_units_all.nau_external_name%TYPE
                                   ,pi_unit_code                IN     nm_admin_units_all.nau_unit_code%TYPE
                                   ,pi_level                    IN     nm_admin_units_all.nau_level%TYPE
                                   ,pi_name                     IN     nm_admin_units_all.nau_name%TYPE
                                   ,pi_start_date               IN     nm_admin_units_all.nau_start_date%TYPE
                                   ,pi_end_date                 IN     nm_admin_units_all.nau_end_date%TYPE
                                   ,pi_admin_type               IN     nm_admin_units_all.nau_admin_type%TYPE
                                   ,pi_nsty_sub_type            IN     nm_admin_units_all.nau_nsty_sub_type%TYPE  
                                   ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lr_nau_rec         nm_admin_units_all%ROWTYPE;
    lr_nau_rec_parent  nm_admin_units_all%ROWTYPE;
    --
    lr_db_nau_rec      nm_admin_units%ROWTYPE;
    lv_upd             VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_parent_admin_unit IN nm_admin_units.nau_admin_unit%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_nau_rec
        FROM nm_admin_units
       WHERE nau_admin_unit = pi_parent_admin_unit;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Admin unit type does not exist');
          --      
    END get_db_rec;    
  BEGIN
    --
    SAVEPOINT cre_child_admin_unit;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_enddate_isnull(pi_parent_end_date); 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Admin Type'
                               ,pi_parameter_value => pi_parent_admin_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Name'
                               ,pi_parameter_value => pi_parent_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Start Date'
                               ,pi_parameter_value => pi_parent_start_date);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Level'
                               ,pi_parameter_value => pi_parent_level);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Code'
                               ,pi_parameter_value => pi_parent_unit_code);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Type'
                               ,pi_parameter_value => pi_admin_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Level'
                               ,pi_parameter_value => pi_level);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Code'
                               ,pi_parameter_value => pi_unit_code);                    
    --
    /*
    ||check parent exists
    */
    IF admin_unit_exists(pi_admin_unit => pi_parent_admin_unit) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 26);
    END IF;
    /*
    ||Check Parent matches DB record
    */
    get_db_rec(pi_parent_admin_unit => pi_parent_admin_unit);
    --
    /*
    ||Compare parent level against DB level as this is used to generate child level in nm3api
    */
    IF lr_db_nau_rec.nau_level != pi_parent_level
     OR (lr_db_nau_rec.nau_level IS NULL AND pi_parent_level IS NOT NULL)
     OR (lr_db_nau_rec.nau_level IS NOT NULL AND pi_parent_level IS NULL)
     --  
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    END IF;                     
    /*
    ||Check Child values
    */
    IF admin_unit_exists (pi_admin_type => pi_admin_type
                         ,pi_unit_code  => pi_unit_code) = 'Y'
     OR admin_unit_exists (pi_admin_type => pi_admin_type
                          ,pi_name       => pi_name) = 'Y' 
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 64); 
    END IF;
    --
    IF admin_type_exists(pi_admin_type => pi_admin_type) = 'N' 
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 26);
    END IF;
    --
    /*
    ||build record for insert.
    */    
    lr_nau_rec.nau_admin_unit := null; --created by package
    lr_nau_rec.nau_unit_code := UPPER(pi_unit_code);
    lr_nau_rec.nau_level := pi_level;
    lr_nau_rec.nau_name := pi_name;
    lr_nau_rec.nau_start_date := TRUNC(pi_start_date);
    lr_nau_rec.nau_end_date := TRUNC(pi_end_date);
    lr_nau_rec.nau_admin_type := UPPER(pi_admin_type);
    lr_nau_rec.nau_nsty_sub_type := pi_nsty_sub_type;
    --
    lr_nau_rec_parent.nau_admin_unit := pi_parent_admin_unit;
    lr_nau_rec_parent.nau_unit_code := UPPER(pi_parent_unit_code);
    lr_nau_rec_parent.nau_level := pi_parent_level;
    lr_nau_rec_parent.nau_authority_code := UPPER(pi_parent_authority_code);
    lr_nau_rec_parent.nau_name := pi_parent_name;
    lr_nau_rec_parent.nau_address1 := pi_parent_address1;
    lr_nau_rec_parent.nau_address2 := pi_parent_address2;
    lr_nau_rec_parent.nau_address3 := pi_parent_address3;
    lr_nau_rec_parent.nau_address4 := pi_parent_address4;
    lr_nau_rec_parent.nau_address5 := pi_parent_address5;
    lr_nau_rec_parent.nau_postcode := pi_parent_postcode;
    lr_nau_rec_parent.nau_phone := pi_parent_phone;
    lr_nau_rec_parent.nau_fax := pi_parent_fax;
    lr_nau_rec_parent.nau_start_date := TRUNC(pi_parent_start_date);
    lr_nau_rec_parent.nau_end_date := TRUNC(pi_parent_end_date);
    lr_nau_rec_parent.nau_admin_type := UPPER(pi_parent_admin_type);
    lr_nau_rec_parent.nau_nsty_sub_type := pi_parent_nsty_sub_type;
    lr_nau_rec_parent.nau_prefix := pi_parent_prefix;
    lr_nau_rec_parent.nau_minor_undertaker := pi_parent_minor_undertaker;
    lr_nau_rec_parent.nau_tcpip := pi_parent_tcpip;
    lr_nau_rec_parent.nau_domain := pi_parent_domain;
    lr_nau_rec_parent.nau_directory := pi_parent_directory;
    --             
    nm3api_admin_unit.insert_admin_unit(pi_nau_rec               => lr_nau_rec
                                       ,pi_nau_rec_parent        => lr_nau_rec_parent);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO cre_child_admin_unit;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_child_admin_unit;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_admin_unit(pi_admin_unit            IN     nm_admin_units_all.nau_admin_unit%TYPE      
                             ,pi_old_admin_type        IN     nm_admin_units_all.nau_admin_type%TYPE
                             ,pi_old_unit_code         IN     nm_admin_units_all.nau_unit_code%TYPE      
                             ,pi_old_level             IN     nm_admin_units_all.nau_level%TYPE  
                             ,pi_old_authority_code    IN     nm_admin_units_all.nau_authority_code%TYPE
                             ,pi_old_name              IN     nm_admin_units_all.nau_name%TYPE
                             ,pi_old_address1          IN     nm_admin_units_all.nau_address1%TYPE
                             ,pi_old_address2          IN     nm_admin_units_all.nau_address2%TYPE
                             ,pi_old_address3          IN     nm_admin_units_all.nau_address3%TYPE
                             ,pi_old_address4          IN     nm_admin_units_all.nau_address4%TYPE
                             ,pi_old_address5          IN     nm_admin_units_all.nau_address5%TYPE
                             ,pi_old_phone             IN     nm_admin_units_all.nau_phone%TYPE
                             ,pi_old_fax               IN     nm_admin_units_all.nau_fax%TYPE
                             ,pi_old_comments          IN     nm_admin_units_all.nau_comments%TYPE
                             ,pi_old_last_wor_no       IN     nm_admin_units_all.nau_last_wor_no%TYPE
                             ,pi_old_end_date          IN     nm_admin_units_all.nau_end_date%TYPE
                             ,pi_old_nsty_sub_type     IN     nm_admin_units_all.nau_nsty_sub_type%TYPE
                             ,pi_old_prefix            IN     nm_admin_units_all.nau_prefix%TYPE
                             ,pi_old_postcode          IN     nm_admin_units_all.nau_postcode%TYPE
                             ,pi_old_minor_undertaker  IN     nm_admin_units_all.nau_minor_undertaker%TYPE
                             ,pi_old_tcpip             IN     nm_admin_units_all.nau_tcpip%TYPE
                             ,pi_old_domain            IN     nm_admin_units_all.nau_domain%TYPE
                             ,pi_old_directory         IN     nm_admin_units_all.nau_directory%TYPE
                             ,pi_old_external_name     IN     nm_admin_units_all.nau_external_name%TYPE
                             ,pi_new_admin_type        IN     nm_admin_units_all.nau_admin_type%TYPE
                             ,pi_new_unit_code         IN     nm_admin_units_all.nau_unit_code%TYPE      
                             ,pi_new_level             IN     nm_admin_units_all.nau_level%TYPE  
                             ,pi_new_authority_code    IN     nm_admin_units_all.nau_authority_code%TYPE
                             ,pi_new_name              IN     nm_admin_units_all.nau_name%TYPE
                             ,pi_new_address1          IN     nm_admin_units_all.nau_address1%TYPE
                             ,pi_new_address2          IN     nm_admin_units_all.nau_address2%TYPE
                             ,pi_new_address3          IN     nm_admin_units_all.nau_address3%TYPE
                             ,pi_new_address4          IN     nm_admin_units_all.nau_address4%TYPE
                             ,pi_new_address5          IN     nm_admin_units_all.nau_address5%TYPE
                             ,pi_new_phone             IN     nm_admin_units_all.nau_phone%TYPE
                             ,pi_new_fax               IN     nm_admin_units_all.nau_fax%TYPE
                             ,pi_new_comments          IN     nm_admin_units_all.nau_comments%TYPE
                             ,pi_new_last_wor_no       IN     nm_admin_units_all.nau_last_wor_no%TYPE
                             ,pi_new_end_date          IN     nm_admin_units_all.nau_end_date%TYPE
                             ,pi_new_nsty_sub_type     IN     nm_admin_units_all.nau_nsty_sub_type%TYPE
                             ,pi_new_prefix            IN     nm_admin_units_all.nau_prefix%TYPE
                             ,pi_new_postcode          IN     nm_admin_units_all.nau_postcode%TYPE
                             ,pi_new_minor_undertaker  IN     nm_admin_units_all.nau_minor_undertaker%TYPE
                             ,pi_new_tcpip             IN     nm_admin_units_all.nau_tcpip%TYPE
                             ,pi_new_domain            IN     nm_admin_units_all.nau_domain%TYPE
                             ,pi_new_directory         IN     nm_admin_units_all.nau_directory%TYPE
                             ,pi_new_external_name     IN     nm_admin_units_all.nau_external_name%TYPE
                             ,po_message_severity         OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor           OUT sys_refcursor)     
    IS
    --
    CURSOR c_admin_units is
    SELECT COUNT(nau_admin_type)
      FROM nm_admin_units_all
     WHERE nau_admin_unit <> pi_admin_unit
       AND (nau_unit_code = pi_new_unit_code
        OR nau_name = pi_new_name);
    --
    lv_cnt  NUMBER;
    --
    lr_db_nau_rec    nm_admin_units_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_admin_unit IN nm_admin_units_all.nau_admin_unit%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_nau_rec
        FROM nm_admin_units_all
       WHERE nau_admin_unit = pi_admin_unit
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Admin unit does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_admin_unit_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Type'
                               ,pi_parameter_value => pi_new_admin_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_new_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Level'
                               ,pi_parameter_value => pi_new_level);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Code'
                               ,pi_parameter_value => pi_new_unit_code);                    
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Minor Undertaker'
                          ,pi_parameter_value => pi_new_minor_undertaker);                     
    --
    /*
    ||check if the name or code will be unique
    */
    OPEN  c_admin_units;
    FETCH c_admin_units 
     INTO lv_cnt;
    CLOSE c_admin_units;
    
    IF lv_cnt > 0 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 158);
    END IF;
    --
    get_db_rec(pi_admin_unit => pi_admin_unit);
    /*
    ||Compare old with DB
    */
    IF lr_db_nau_rec.nau_admin_type != pi_old_admin_type  
     OR (lr_db_nau_rec.nau_admin_type IS NULL AND pi_old_admin_type IS NOT NULL)
     OR (lr_db_nau_rec.nau_admin_type IS NOT NULL AND pi_old_admin_type IS NULL)
     --
     OR (lr_db_nau_rec.nau_unit_code != pi_old_unit_code)
     OR (lr_db_nau_rec.nau_unit_code IS NULL AND pi_old_unit_code IS NOT NULL)
     OR (lr_db_nau_rec.nau_unit_code IS NOT NULL AND pi_old_unit_code IS NULL)
     --
     OR (lr_db_nau_rec.nau_level != pi_old_level)
     OR (lr_db_nau_rec.nau_level IS NULL AND pi_old_level IS NOT NULL)
     OR (lr_db_nau_rec.nau_level IS NOT NULL AND pi_old_level IS NULL)
     --
     OR (lr_db_nau_rec.nau_authority_code != pi_old_authority_code)
     OR (lr_db_nau_rec.nau_authority_code IS NULL AND pi_old_authority_code IS NOT NULL)
     OR (lr_db_nau_rec.nau_authority_code IS NOT NULL AND pi_old_authority_code IS NULL)
     --
     OR (lr_db_nau_rec.nau_name != pi_old_name)
     OR (lr_db_nau_rec.nau_name IS NULL AND pi_old_name IS NOT NULL)
     OR (lr_db_nau_rec.nau_name IS NOT NULL AND pi_old_name IS NULL)
     --
     OR (lr_db_nau_rec.nau_address1 != pi_old_address1)
     OR (lr_db_nau_rec.nau_address1 IS NULL AND pi_old_address1 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address1 IS NOT NULL AND pi_old_address1 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address2 != pi_old_address2)
     OR (lr_db_nau_rec.nau_address2 IS NULL AND pi_old_address2 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address2 IS NOT NULL AND pi_old_address2 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address3 != pi_old_address3)
     OR (lr_db_nau_rec.nau_address3 IS NULL AND pi_old_address3 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address3 IS NOT NULL AND pi_old_address3 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address4 != pi_old_address4)
     OR (lr_db_nau_rec.nau_address4 IS NULL AND pi_old_address4 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address4 IS NOT NULL AND pi_old_address4 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address5 != pi_old_address5)
     OR (lr_db_nau_rec.nau_address5 IS NULL AND pi_old_address5 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address5 IS NOT NULL AND pi_old_address5 IS NULL)
     --
     OR (lr_db_nau_rec.nau_phone != pi_old_phone)
     OR (lr_db_nau_rec.nau_phone IS NULL AND pi_old_phone IS NOT NULL)
     OR (lr_db_nau_rec.nau_phone IS NOT NULL AND pi_old_phone IS NULL)
     --
     OR (lr_db_nau_rec.nau_fax != pi_old_fax)
     OR (lr_db_nau_rec.nau_fax IS NULL AND pi_old_fax IS NOT NULL)
     OR (lr_db_nau_rec.nau_fax IS NOT NULL AND pi_old_fax IS NULL)
     --
     OR (lr_db_nau_rec.nau_comments != pi_old_comments )
     OR (lr_db_nau_rec.nau_comments IS NULL AND pi_old_comments  IS NOT NULL)
     OR (lr_db_nau_rec.nau_comments IS NOT NULL AND pi_old_comments  IS NULL)
     --descr
     OR (lr_db_nau_rec.nau_last_wor_no != pi_old_last_wor_no)
     OR (lr_db_nau_rec.nau_last_wor_no IS NULL AND pi_old_last_wor_no IS NOT NULL)
     OR (lr_db_nau_rec.nau_last_wor_no IS NOT NULL AND pi_old_last_wor_no IS NULL)
     --
     OR (lr_db_nau_rec.nau_end_date != pi_old_end_date)
     OR (lr_db_nau_rec.nau_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_nau_rec.nau_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     OR (lr_db_nau_rec.nau_nsty_sub_type != pi_old_nsty_sub_type)
     OR (lr_db_nau_rec.nau_nsty_sub_type IS NULL AND pi_old_nsty_sub_type IS NOT NULL)
     OR (lr_db_nau_rec.nau_nsty_sub_type IS NOT NULL AND pi_old_nsty_sub_type IS NULL)
     --
     OR (lr_db_nau_rec.nau_prefix != pi_old_prefix)
     OR (lr_db_nau_rec.nau_prefix IS NULL AND pi_old_prefix IS NOT NULL)
     OR (lr_db_nau_rec.nau_prefix IS NOT NULL AND pi_old_prefix IS NULL)
     --
     OR (lr_db_nau_rec.nau_postcode != pi_old_postcode)
     OR (lr_db_nau_rec.nau_postcode IS NULL AND pi_old_postcode IS NOT NULL)
     OR (lr_db_nau_rec.nau_postcode IS NOT NULL AND pi_old_postcode IS NULL)
     --
     OR (lr_db_nau_rec.nau_minor_undertaker != pi_old_minor_undertaker)
     OR (lr_db_nau_rec.nau_minor_undertaker IS NULL AND pi_old_minor_undertaker IS NOT NULL)
     OR (lr_db_nau_rec.nau_minor_undertaker IS NOT NULL AND pi_old_minor_undertaker IS NULL)
     --
     OR (lr_db_nau_rec.nau_tcpip != pi_old_tcpip)
     OR (lr_db_nau_rec.nau_tcpip IS NULL AND pi_old_tcpip IS NOT NULL)
     OR (lr_db_nau_rec.nau_tcpip IS NOT NULL AND pi_old_tcpip IS NULL)
     --
     OR (lr_db_nau_rec.nau_domain != pi_old_domain)
     OR (lr_db_nau_rec.nau_domain IS NULL AND pi_old_domain IS NOT NULL)
     OR (lr_db_nau_rec.nau_domain IS NOT NULL AND pi_old_domain IS NULL)
     --
     OR (lr_db_nau_rec.nau_directory != pi_old_directory)
     OR (lr_db_nau_rec.nau_directory IS NULL AND pi_old_directory IS NOT NULL)
     OR (lr_db_nau_rec.nau_directory IS NOT NULL AND pi_old_directory IS NULL)
     --
     OR (lr_db_nau_rec.nau_external_name != pi_old_external_name)
     OR (lr_db_nau_rec.nau_external_name IS NULL AND pi_old_external_name IS NOT NULL)
     OR (lr_db_nau_rec.nau_external_name IS NOT NULL AND pi_old_external_name IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_admin_type != pi_new_admin_type
       OR (pi_old_admin_type IS NULL AND pi_new_admin_type IS NOT NULL)
       OR (pi_old_admin_type IS NOT NULL AND pi_new_admin_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_unit_code != pi_new_unit_code
       OR (pi_old_unit_code IS NULL AND pi_new_unit_code IS NOT NULL)
       OR (pi_old_unit_code IS NOT NULL AND pi_new_unit_code IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_level != pi_new_level
       OR (pi_old_level IS NULL AND pi_new_level IS NOT NULL)
       OR (pi_old_level IS NOT NULL AND pi_new_level IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --      
      IF pi_old_authority_code != pi_new_authority_code
       OR (pi_old_authority_code IS NULL AND pi_new_authority_code IS NOT NULL)
       OR (pi_old_authority_code IS NOT NULL AND pi_new_authority_code IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_name != pi_new_name
       OR (pi_old_name IS NULL AND pi_new_name IS NOT NULL)
       OR (pi_old_name IS NOT NULL AND pi_new_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_address1 != pi_new_address1
       OR (pi_old_address1 IS NULL AND pi_new_address1 IS NOT NULL)
       OR (pi_old_address1 IS NOT NULL AND pi_new_address1 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --      
      IF pi_old_address2 != pi_new_address2
       OR (pi_old_address2 IS NULL AND pi_new_address2 IS NOT NULL)
       OR (pi_old_address2 IS NOT NULL AND pi_new_address2 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_address3 != pi_new_address3
       OR (pi_old_address3 IS NULL AND pi_new_address3 IS NOT NULL)
       OR (pi_old_address3 IS NOT NULL AND pi_new_address3 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_address4 != pi_new_address4
       OR (pi_old_address4 IS NULL AND pi_new_address4 IS NOT NULL)
       OR (pi_old_address4 IS NOT NULL AND pi_new_address4 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --      
      IF pi_old_address5 != pi_new_address5
       OR (pi_old_address5 IS NULL AND pi_new_address5 IS NOT NULL)
       OR (pi_old_address5 IS NOT NULL AND pi_new_address5 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_phone != pi_new_phone
       OR (pi_old_phone IS NULL AND pi_new_phone IS NOT NULL)
       OR (pi_old_phone IS NOT NULL AND pi_new_phone IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_fax != pi_new_fax
       OR (pi_old_fax IS NULL AND pi_new_fax IS NOT NULL)
       OR (pi_old_fax IS NOT NULL AND pi_new_fax IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --      
      IF pi_old_comments != pi_new_comments
       OR (pi_old_comments IS NULL AND pi_new_comments IS NOT NULL)
       OR (pi_old_comments IS NOT NULL AND pi_new_comments IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_last_wor_no != pi_new_last_wor_no
       OR (pi_old_last_wor_no IS NULL AND pi_new_last_wor_no IS NOT NULL)
       OR (pi_old_last_wor_no IS NOT NULL AND pi_new_last_wor_no IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;       
      --      
      IF pi_old_end_date != pi_new_end_date
       OR (pi_old_end_date IS NULL AND pi_new_end_date IS NOT NULL)
       OR (pi_old_end_date IS NOT NULL AND pi_new_end_date IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nsty_sub_type != pi_new_nsty_sub_type
       OR (pi_old_nsty_sub_type IS NULL AND pi_new_nsty_sub_type IS NOT NULL)
       OR (pi_old_nsty_sub_type IS NOT NULL AND pi_new_nsty_sub_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_prefix != pi_new_prefix
       OR (pi_old_prefix IS NULL AND pi_new_prefix IS NOT NULL)
       OR (pi_old_prefix IS NOT NULL AND pi_new_prefix IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF pi_old_postcode != pi_new_postcode
       OR (pi_old_postcode IS NULL AND pi_new_postcode IS NOT NULL)
       OR (pi_old_postcode IS NOT NULL AND pi_new_postcode IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_minor_undertaker != pi_new_minor_undertaker
       OR (pi_old_minor_undertaker IS NULL AND pi_new_minor_undertaker IS NOT NULL)
       OR (pi_old_minor_undertaker IS NOT NULL AND pi_new_minor_undertaker IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_tcpip != pi_new_tcpip
       OR (pi_old_tcpip IS NULL AND pi_new_tcpip IS NOT NULL)
       OR (pi_old_tcpip IS NOT NULL AND pi_new_tcpip IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF pi_old_domain != pi_new_domain
       OR (pi_old_domain IS NULL AND pi_new_domain IS NOT NULL)
       OR (pi_old_domain IS NOT NULL AND pi_new_domain IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_directory != pi_new_directory
       OR (pi_old_directory IS NULL AND pi_new_directory IS NOT NULL)
       OR (pi_old_directory IS NOT NULL AND pi_new_directory IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_external_name != pi_new_external_name
       OR (pi_old_external_name IS NULL AND pi_new_external_name IS NOT NULL)
       OR (pi_old_external_name IS NOT NULL AND pi_new_external_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE nm_admin_units_all
           SET nau_admin_type       = UPPER(pi_new_admin_type)
              ,nau_unit_code        = UPPER(pi_new_unit_code)               
              ,nau_level            = pi_new_level    
              ,nau_authority_code   = UPPER(pi_new_authority_code) 
              ,nau_name             = pi_new_name            
              ,nau_address1         = pi_new_address1        
              ,nau_address2         = pi_new_address2        
              ,nau_address3         = pi_new_address3        
              ,nau_address4         = pi_new_address4        
              ,nau_address5         = pi_new_address5        
              ,nau_phone            = pi_new_phone           
              ,nau_fax              = pi_new_fax             
              ,nau_comments         = pi_new_comments        
              ,nau_last_wor_no      = pi_new_last_wor_no      
              ,nau_end_date         = TRUNC(pi_new_end_date)   
              ,nau_nsty_sub_type    = pi_new_nsty_sub_type   
              ,nau_prefix           = pi_new_prefix          
              ,nau_postcode         = pi_new_postcode        
              ,nau_minor_undertaker = pi_new_minor_undertaker
              ,nau_tcpip            = pi_new_tcpip           
              ,nau_domain           = pi_new_domain          
              ,nau_directory        = pi_new_directory       
              ,nau_external_name    = pi_new_external_name   
         WHERE nau_admin_unit = pi_admin_unit;
        --           
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF; 
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_admin_unit_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_admin_unit;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_admin_unit(pi_admin_unit        IN      nm_admin_units_all.nau_admin_unit%TYPE
                             ,pi_end_date          IN      nm_admin_units_all.nau_end_date%TYPE
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
    FUNCTION nag_dependencies_exist(pi_admin_unit IN NUMBER
                                   ,pi_start_date IN DATE := NULL
                                   ,pi_end_date   IN DATE := NULL) RETURN BOOLEAN IS
       CURSOR c1 IS
       SELECT nag_child_admin_unit
         FROM nm_admin_groups, nm_admin_units
        WHERE nag_parent_admin_unit = pi_admin_unit
          AND nag_child_admin_unit = nau_admin_unit
          AND NVL(nau_end_date, SYSDATE) >= NVL(pi_end_date, SYSDATE)
          AND NVL(nau_start_date, nvl(pi_start_date, SYSDATE)) <= nvl(pi_start_date, SYSDATE)
          AND nag_child_admin_unit <> pi_admin_unit;      
    
       CURSOR c2 IS
       SELECT rse_admin_unit
         FROM road_segs
        WHERE rse_admin_unit = pi_admin_unit
          AND NVL( rse_end_date, SYSDATE+1 ) >= NVL(pi_end_date, SYSDATE)
          AND rse_start_date <= NVL( pi_start_date, rse_start_date );
       --
       retval BOOLEAN;
       lv_admin_unit NUMBER;
       --
    BEGIN
       --
       OPEN c1;
       FETCH c1 INTO lv_admin_unit;
       retval := c1%FOUND;
       CLOSE C1;       
       --
       IF NOT retval 
        THEN
          OPEN c2;
          FETCH c2 INTO lv_admin_unit;
          retval := c2%FOUND;
          CLOSE c2;
       END IF;
       --
       RETURN retval;
       --
    END nag_dependencies_exist;
    --
  BEGIN
    --
    SAVEPOINT delete_admin_unit_sp;
    --
    awlrs_util.check_historic_mode;
    --
    IF admin_unit_exists(pi_admin_unit => pi_admin_unit) <> 'Y' 
     THEN 
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 26);
    END IF;
    --    
    IF nag_dependencies_exist (pi_admin_unit) 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 502);
    END IF;
    --    
    /*
    ||
    */
    nm3api_admin_unit.end_date_admin_unit(pi_admin_unit  => pi_admin_unit
                                         ,pi_end_date    => TRUNC(pi_end_date));     
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_admin_unit_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_admin_unit;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_unit_tree(pi_admin_unit    IN     nm_admin_units.nau_admin_unit%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
	  Nm3ctx.Set_Context('HIG1860_ADMIN_UNIT',To_Char(pi_admin_unit));
    --
    OPEN po_cursor FOR
	 	SELECT vnaut.initial_state initial_state
          ,vnaut.depth         treedepth
          ,vnaut.label         label
          ,vnaut.icon          icon
          ,vnaut.data          treedata
     FROM  v_nm_admin_units_tree vnaut;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_unit_tree;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_unit_tree(pi_admin_type    IN     nm_admin_units.nau_admin_type%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    -- 
    lv_top_admin_unit nm_admin_units.nau_admin_unit%TYPE;
    --
  BEGIN
    --
    BEGIN
       SELECT nau_admin_unit
         INTO lv_top_admin_unit
         FROM nm_admin_units_all
        WHERE nau_admin_type = pi_admin_type
          AND nau_level = 1;
    EXCEPTION
      WHEN no_data_found
       THEN
          lv_top_admin_unit := '';
      WHEN too_many_rows
       THEN
          lv_top_admin_unit := '';          
    END;
    --
    OPEN po_cursor FOR
    SELECT 1                                         depth
          ,nau_unit_code || ' - ' || nau_name        label
          ,nau_admin_unit                            admin_unit
          ,null                                      parent_admin_unit
          ,DECODE(nvl(nau_end_date,''),'','N','Y')   end_dated
      FROM nm_admin_units_all nau
     WHERE nau.Nau_Admin_Unit = lv_top_admin_unit
     UNION ALL
    SELECT l_level + 1                              depth
          ,x.nau_unit_code || ' - ' || x.nau_name   label
          ,nau_admin_unit                           admin_unit
          ,nag_parent_admin_unit                    parent_admin_unit
          ,end_dated                                end_dated
      FROM (SELECT tre.Nag_Parent_Admin_Unit,
                   tre.Nag_Child_Admin_Unit,
                   tre.Nau_Name,
                   tre.Nau_Admin_Unit,
                   tre.Nau_Unit_Code,
                   tre.end_dated,
                   LEVEL L_Level
              FROM (SELECT nag.nag_parent_admin_unit,
                           nag.nag_child_admin_unit,
                           nau.nau_name,
                           nau.nau_admin_unit,
                           nau.nau_unit_code,
                           DECODE(nvl(nau_end_date,''),'','N','Y')   end_dated
                      FROM nm_admin_groups nag, nm_admin_units_all nau
                     WHERE nag.nag_direct_link = 'Y'
                       AND nau.nau_admin_unit = nag.nag_child_admin_unit)
                   tre
            CONNECT BY PRIOR tre.Nag_Child_Admin_Unit = tre.Nag_Parent_Admin_Unit
            START WITH tre.Nag_Parent_Admin_Unit = lv_top_admin_unit)
            x;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_unit_tree;
  
  --
  -----------------------------------------------------------------------------
  --No longer used according to RC so do not include. PV decided to exclude
  PROCEDURE get_admin_subtypes(po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nsty_id               sub_type_id
           ,nsty_nat_admin_type   admin_type
           ,nsty_sub_type         sub_type
           ,nsty_descr            description
           ,nsty_parent_sub_type  parent_sub_type
           ,nsty_ngt_group_type   group_type
           ,CASE
            WHEN nsty_parent_sub_type IS NOT NULL 
             THEN 
              (SELECT nsty_descr 
                 FROM nm_au_sub_types 
                WHERE nsty_nat_admin_type = nsty.nsty_nat_admin_type
                  AND nsty_parent_sub_type = nsty.nsty_parent_sub_type)
            ELSE 
              ''
             END  parent_sub_type
           ,CASE 
            WHEN nsty_ngt_group_type IS NOT NULL 
             THEN
                (SELECT ngt_descr FROM nm_group_types WHERE ngt_group_type = nsty.nsty_ngt_group_type)
            ELSE
                ''
           END group_type_meaning
      FROM nm_au_sub_types nsty
     ORDER BY nsty_parent_sub_type, nsty_sub_type;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_subtypes;

  --
  -----------------------------------------------------------------------------
  --No longer used according to RC so do not include. PV to decide
  PROCEDURE get_admin_subtype(pi_nsty_id       IN     nm_au_sub_types.nsty_id%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nsty_id               sub_type_id
           ,nsty_nat_admin_type   admin_type
           ,nsty_sub_type         sub_type
           ,nsty_descr            description
           ,nsty_parent_sub_type  parent_sub_type
           ,nsty_ngt_group_type   group_type
           ,CASE
            WHEN nsty_parent_sub_type IS NOT NULL 
             THEN 
              (SELECT nsty_descr 
                 FROM nm_au_sub_types 
                WHERE nsty_nat_admin_type = nsty.nsty_nat_admin_type
                  AND nsty_parent_sub_type = nsty.nsty_parent_sub_type)
            ELSE 
              ''
             END  parent_sub_type
           ,CASE 
            WHEN nsty_ngt_group_type IS NOT NULL 
             THEN
                (SELECT ngt_descr FROM nm_group_types WHERE ngt_group_type = nsty.nsty_ngt_group_type)
            ELSE
                ''
           END group_type_meaning
      FROM nm_au_sub_types nsty
     WHERE nsty_id = pi_nsty_id
     ORDER BY nsty_parent_sub_type, nsty_sub_type;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_subtype;
  
  --
  -----------------------------------------------------------------------------
  --No longer used according to RC so do not include. PV decided to exclude
  PROCEDURE get_paged_admin_subtypes(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nsty_id               sub_type_id
                                                    ,nsty_nat_admin_type   admin_type
                                                    ,nsty_sub_type         sub_type
                                                    ,nsty_descr            description
                                                    ,nsty_parent_sub_type  parent_sub_type
                                                    ,nsty_ngt_group_type   group_type
                                                    ,CASE
                                                     WHEN nsty_parent_sub_type IS NOT NULL 
                                                      THEN 
                                                       (SELECT nsty_descr 
                                                          FROM nm_au_sub_types 
                                                         WHERE nsty_nat_admin_type = nsty.nsty_nat_admin_type
                                                           AND nsty_parent_sub_type = nsty.nsty_parent_sub_type)
                                                     ELSE 
                                                       ''
                                                      END  parent_sub_type_meaning
                                                    ,CASE 
                                                     WHEN nsty_ngt_group_type IS NOT NULL 
                                                      THEN
                                                         (SELECT ngt_descr FROM nm_group_types WHERE ngt_group_type = nsty.nsty_ngt_group_type)
                                                     ELSE
                                                         ''
                                                    END group_type_meaning
                                               FROM nm_au_sub_types nsty';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  sub_type_id'
                                                  ||',admin_type'
                                                  ||',sub_type'
                                                  ||',description'
                                                  ||',parent_sub_type'
                                                  ||',group_type'
                                                  ||',parent_sub_type_meaning'
                                                  ||',group_type_meaning'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'sub_type_id'
                                ,pi_query_col  => 'nsty_id'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'admin_type'
                                ,pi_query_col  => 'nsty_nat_admin_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'sub_type'
                                ,pi_query_col  => 'nsty_sub_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nsty_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'parent_sub_type'
                                ,pi_query_col  => 'CASE
                                                          WHEN nsty_parent_sub_type IS NOT NULL 
                                                           THEN 
                                                            (SELECT nsty_descr 
                                                               FROM nm_au_sub_types 
                                                              WHERE nsty_nat_admin_type = nsty.nsty_nat_admin_type
                                                                AND nsty_parent_sub_type = nsty.nsty_parent_sub_type)
                                                          ELSE 
                                                            ''
                                                           END'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'group_type'
                                ,pi_query_col  => 'nsty_ngt_group_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'parent_sub_type_meaning'
                                ,pi_query_col  => 'nsty_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'group_type_meaning'
                                ,pi_query_col  => 'CASE 
                                                          WHEN nsty_ngt_group_type IS NOT NULL 
                                                           THEN
                                                              (SELECT ngt_descr FROM nm_group_types WHERE ngt_group_type = nsty.nsty_ngt_group_type)
                                                          ELSE
                                                              ''
                                                         END group_type_meaning'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nsty_parent_sub_type, nsty_sub_type')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index;
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
  END get_paged_admin_subtypes;
  
  --
  -----------------------------------------------------------------------------
  --No longer used according to RC so do not include. PV to decide
  PROCEDURE get_groupings(po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT natg_grouping         grouping_group
           ,natg_nat_admin_type   grouping_admin_type
           ,hco_meaning   group_meaning
      FROM nm_au_types_groupings, hig_codes
     WHERE hco_domain = nm3api_admin_unit.get_natg_domain 
       AND hco_code = natg_grouping
     ORDER BY natg_grouping; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_groupings;

  --
  -----------------------------------------------------------------------------
  --No longer used according to RC so do not include. PV to decide
  PROCEDURE get_grouping(pi_admin_grouping       IN     nm_au_types_groupings.natg_grouping%TYPE
                        ,pi_grouping_admin_type  IN     nm_au_types_groupings.natg_nat_admin_type%TYPE
                        ,po_message_severity        OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor          OUT sys_refcursor
                        ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT natg_grouping         grouping_group
           ,natg_nat_admin_type   grouping_admin_type
           ,hco_meaning   group_meaning
      FROM nm_au_types_groupings, hig_codes
     WHERE hco_domain = nm3api_admin_unit.get_natg_domain 
       AND hco_code = natg_grouping
       AND natg_grouping = pi_admin_grouping
       AND natg_nat_admin_type = pi_grouping_admin_type
     ORDER BY natg_grouping;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_grouping;
  
  --
  -----------------------------------------------------------------------------
  --No longer used according to RC so do not include. PV to decide
  PROCEDURE get_paged_groupings(pi_filter_columns   IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                               ,pi_filter_operators IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                               ,pi_filter_values_1  IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                               ,pi_filter_values_2  IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                               ,pi_order_columns    IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                               ,pi_order_asc_desc   IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                               ,pi_skip_n_rows      IN     PLS_INTEGER
                               ,pi_pagesize         IN     PLS_INTEGER
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor
                               ,po_cursor              OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :=' SELECT natg_grouping         grouping_group
                                                     ,natg_nat_admin_type   grouping_admin_type
                                                     ,hco_meaning           group_meaning
                                                FROM nm_au_types_groupings, hig_codes
                                               WHERE hco_domain = nm3api_admin_unit.get_natg_domain 
                                                 AND hco_code = natg_grouping';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  grouping_group'
                                                  ||',grouping_admin_type'
                                                  ||',group_meaning'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'grouping_group'
                                ,pi_query_col  => 'natg_grouping'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'grouping_admin_type'
                                ,pi_query_col  => 'natg_nat_admin_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'group_meaning'
                                ,pi_query_col  => 'hco_meaning'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'natg_grouping')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index;
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
  END get_paged_groupings;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_modules(po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor
                       ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmo_module            module_
            ,hmo_title             title
            ,hmo_filename          filename
            ,hmo_module_type       module_type
            ,hmo_fastpath_opts     fastpath_opts
            ,hmo_fastpath_invalid  fastpath_invalid
            ,hmo_use_gri           use_gri
            ,hmo_application       product
            ,hmo_menu              menu
       FROM hig_modules
      ORDER BY hmo_module, hmo_module_type; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_modules;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_module(pi_module               IN     hig_modules.hmo_module%TYPE
                      ,po_message_severity        OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor          OUT sys_refcursor
                      ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmo_module            module_
            ,hmo_title             title
            ,hmo_filename          filename
            ,hmo_module_type       module_type
            ,hmo_fastpath_opts     fastpath_opts
            ,hmo_fastpath_invalid  fastpath_invalid
            ,hmo_use_gri           use_gri
            ,hmo_application       product
            ,hmo_menu              menu
        FROM hig_modules
       WHERE hmo_module = pi_module
      ORDER BY hmo_module, hmo_module_type; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_module;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_modules(pi_filter_columns   IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                             ,pi_filter_operators IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                             ,pi_filter_values_1  IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                             ,pi_filter_values_2  IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                             ,pi_order_columns    IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                             ,pi_order_asc_desc   IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                             ,pi_skip_n_rows      IN     PLS_INTEGER
                             ,pi_pagesize         IN     PLS_INTEGER
                             ,po_message_severity    OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor      OUT sys_refcursor
                             ,po_cursor              OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT hmo_module            module_
                                                    ,hmo_title             title
                                                    ,hmo_filename          filename
                                                    ,hmo_module_type       module_type
                                                    ,hmo_fastpath_opts     fastpath_opts
                                                    ,hmo_fastpath_invalid  fastpath_invalid
                                                    ,hmo_use_gri           use_gri
                                                    ,hmo_application       product
                                                    ,hmo_menu              menu
                                               FROM hig_modules';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  module_'
                                                  ||',title'
                                                  ||',filename'
                                                  ||',module_type'
                                                  ||',fastpath_opts'
                                                  ||',fastpath_invalid'
                                                  ||',use_gri'
                                                  ||',product'
                                                  ||',menu'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'module_'
                                ,pi_query_col  => 'hmo_module'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'title'
                                ,pi_query_col  => 'hmo_title'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'filename'
                                ,pi_query_col  => 'hmo_filename'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'module_type'
                                ,pi_query_col  => 'hmo_module_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'fastpath_opts'
                                ,pi_query_col  => 'hmo_fastpath_opts'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'fastpath_invalid'
                                ,pi_query_col  => 'hmo_fastpath_invalid'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'use_gri'
                                ,pi_query_col  => 'hmo_use_gri'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'product'
                                ,pi_query_col  => 'hmo_application'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'menu'
                                ,pi_query_col  => 'hmo_menu'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hmo_module, hmo_module_type')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index;
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
  END get_paged_modules;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_module_roles(pi_module        IN      hig_module_roles.hmr_module%TYPE
                            ,po_message_severity OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT  sys_refcursor
                            ,po_cursor           OUT  sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmr_module   module_
            ,hmr_role     role_
            ,hmr_mode     mode_
        FROM hig_module_roles
       WHERE hmr_module = pi_module
     ORDER BY hmr_role; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_module_roles;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_module_role(pi_module              IN      hig_module_roles.hmr_module%TYPE
                           ,pi_role                IN      hig_module_roles.hmr_role%TYPE
                           ,po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmr_module   module_
            ,hmr_role     role_
            ,hmr_mode     mode_
        FROM hig_module_roles
       WHERE hmr_module = pi_module
         AND hmr_role   = pi_role
    ORDER BY hmr_role; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_module_role;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_role_module(pi_role                IN      hig_module_roles.hmr_role%TYPE
                           ,pi_module              IN      hig_module_roles.hmr_module%TYPE
                           ,po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmr_module module_
            ,hmo_title  title 
            ,hmr_mode   mode_
        FROM hig_module_roles
            ,hig_modules
       WHERE hmr_module = pi_module
         AND hmr_role   = pi_role
         AND hmr_module = hmo_module
    ORDER BY hmr_role; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_role_module;
                           
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_module_roles(pi_module               IN     hig_module_roles.hmr_module%TYPE
                                  ,pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_operators     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_values_1      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_filter_values_2      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_order_columns        IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_order_asc_desc       IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                  ,pi_skip_n_rows          IN     PLS_INTEGER
                                  ,pi_pagesize             IN     PLS_INTEGER
                                  ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor          OUT sys_refcursor
                                  ,po_cursor                  OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT hmr_module   module_
                                                    ,hmr_role     role_
                                                    ,hmr_mode     mode_
                                                FROM hig_module_roles
                                               WHERE hmr_module = :pi_module';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  module_'
                                                  ||',role_'
                                                  ||',mode_'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'module_'
                                ,pi_query_col  => 'hmr_module'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'role_'
                                ,pi_query_col  => 'hmr_role'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'mode_'
                                ,pi_query_col  => 'hmr_mode'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hmr_role')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_module
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_module
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
  END get_paged_module_roles;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_module(pi_module           IN      hig_modules.hmo_module%TYPE
                         ,pi_title            IN      hig_modules.hmo_title%TYPE
                         ,pi_filename         IN      hig_modules.hmo_filename%TYPE
                         ,pi_module_type      IN      hig_modules.hmo_module_type%TYPE
                         ,pi_fastpath_opts    IN      hig_modules.hmo_fastpath_opts%TYPE
                         ,pi_fastpath_invalid IN      hig_modules.hmo_fastpath_invalid%TYPE
                         ,pi_use_gri          IN      hig_modules.hmo_use_gri%TYPE
                         ,pi_application      IN      hig_modules.hmo_application%TYPE
                         ,pi_menu             IN      hig_modules.hmo_menu%TYPE
                         ,po_message_severity     OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    FUNCTION module_type_exists(pi_module_type IN hig_codes.hco_code%TYPE)
      RETURN VARCHAR2
    IS
      lv_exists VARCHAR2(1):= 'N';
    BEGIN
      --
      SELECT 'Y'
        INTO lv_exists
        FROM hig_codes 
       WHERE hco_domain = 'MODULE_TYPE'
         AND hco_code = pi_module_type;
      --
      RETURN lv_exists;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          RETURN lv_exists;
    END module_type_exists;
    --
  BEGIN
    --
    SAVEPOINT create_module_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module'
                               ,pi_parameter_value => pi_module);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Title'
                               ,pi_parameter_value => pi_title);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Filename'
                               ,pi_parameter_value => pi_filename);                    
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module Type'
                               ,pi_parameter_value => pi_module_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Fsatpath Invalid'
                               ,pi_parameter_value => pi_fastpath_invalid);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Product'
                               ,pi_parameter_value => pi_application);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Menu'
                               ,pi_parameter_value => pi_menu);                    
    --
    IF module_exists(pi_module => pi_module) = 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64);     
    END IF;
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Fastpath Invalid'
                          ,pi_parameter_value => pi_fastpath_invalid);  
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Use GRI'
                          ,pi_parameter_value => pi_use_gri);  
    --    
    IF product_exists(pi_product => pi_application) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    IF module_type_exists(pi_module_type => pi_module_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29); 
    END IF;
    --
    INSERT 
      INTO hig_modules 
           (hmo_module
           ,hmo_title
           ,hmo_filename
           ,hmo_module_type
           ,hmo_fastpath_opts
           ,hmo_fastpath_invalid
           ,hmo_use_gri
           ,hmo_application
           ,hmo_menu
           )
    VALUES (UPPER(pi_module)
           ,pi_title
           ,pi_filename
           ,pi_module_type
           ,pi_fastpath_opts
           ,pi_fastpath_invalid
           ,pi_use_gri
           ,pi_application
           ,UPPER(pi_menu));
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO create_module_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_module;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_module(pi_old_module           IN      hig_modules.hmo_module%TYPE 
                         ,pi_old_title            IN      hig_modules.hmo_title%TYPE 
                         ,pi_old_filename         IN      hig_modules.hmo_filename%TYPE 
                         ,pi_old_module_type      IN      hig_modules.hmo_module_type%TYPE 
                         ,pi_old_fastpath_opts    IN      hig_modules.hmo_fastpath_opts%TYPE 
                         ,pi_old_fastpath_invalid IN      hig_modules.hmo_fastpath_invalid%TYPE 
                         ,pi_old_use_gri          IN      hig_modules.hmo_use_gri%TYPE 
                         ,pi_old_application      IN      hig_modules.hmo_application%TYPE 
                         ,pi_old_menu             IN      hig_modules.hmo_menu%TYPE 
                         ,pi_new_module           IN      hig_modules.hmo_module%TYPE
                         ,pi_new_title            IN      hig_modules.hmo_title%TYPE
                         ,pi_new_filename         IN      hig_modules.hmo_filename%TYPE
                         ,pi_new_module_type      IN      hig_modules.hmo_module_type%TYPE
                         ,pi_new_fastpath_opts    IN      hig_modules.hmo_fastpath_opts%TYPE
                         ,pi_new_fastpath_invalid IN      hig_modules.hmo_fastpath_invalid%TYPE
                         ,pi_new_use_gri          IN      hig_modules.hmo_use_gri%TYPE
                         ,pi_new_application      IN      hig_modules.hmo_application%TYPE
                         ,pi_new_menu             IN      hig_modules.hmo_menu%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor)
    IS
    --    
    lr_db_hmo_rec    hig_modules%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_hmo_rec
        FROM hig_modules
       WHERE hmo_module = UPPER(pi_old_module)
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Module does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_module_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module'
                               ,pi_parameter_value => pi_new_module);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Title'
                               ,pi_parameter_value => pi_new_title);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Filename'
                               ,pi_parameter_value => pi_new_filename);                    
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module Type'
                               ,pi_parameter_value => pi_new_module_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Fsatpath Invalid'
                               ,pi_parameter_value => pi_new_fastpath_invalid);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Product'
                               ,pi_parameter_value => pi_new_application);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Menu'
                               ,pi_parameter_value => pi_new_menu);                    
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Fastpath Invalid'
                          ,pi_parameter_value => pi_new_fastpath_invalid); 
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Use GRI'
                          ,pi_parameter_value => pi_new_use_gri); 
    --    
    IF  product_exists(pi_product => pi_new_application) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --    
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_hmo_rec.hmo_module != UPPER(pi_old_module)
     OR (lr_db_hmo_rec.hmo_module IS NULL AND UPPER(pi_old_module) IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_module IS NOT NULL AND UPPER(pi_old_module) IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_title != pi_old_title)
     OR (lr_db_hmo_rec.hmo_title IS NULL AND pi_old_title IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_title IS NOT NULL AND pi_old_title IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_filename != pi_old_filename)
     OR (lr_db_hmo_rec.hmo_filename IS NULL AND pi_old_filename IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_filename IS NOT NULL AND pi_old_filename IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_module_type != pi_old_module_type)
     OR (lr_db_hmo_rec.hmo_module_type IS NULL AND pi_old_module_type IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_module_type IS NOT NULL AND pi_old_module_type IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_fastpath_opts != pi_old_fastpath_opts)
     OR (lr_db_hmo_rec.hmo_fastpath_opts IS NULL AND pi_old_fastpath_opts IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_fastpath_opts IS NOT NULL AND pi_old_fastpath_opts IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_fastpath_invalid != pi_old_fastpath_invalid)
     OR (lr_db_hmo_rec.hmo_fastpath_invalid IS NULL AND pi_old_fastpath_invalid IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_fastpath_invalid IS NOT NULL AND pi_old_fastpath_invalid IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_use_gri != pi_old_use_gri)
     OR (lr_db_hmo_rec.hmo_use_gri IS NULL AND pi_old_use_gri IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_use_gri IS NOT NULL AND pi_old_use_gri IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_application != pi_old_application)
     OR (lr_db_hmo_rec.hmo_application IS NULL AND pi_old_application IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_application IS NOT NULL AND pi_old_application IS NULL)
     --
     OR (lr_db_hmo_rec.hmo_menu != pi_old_menu)
     OR (lr_db_hmo_rec.hmo_menu IS NULL AND pi_old_menu IS NOT NULL)
     OR (lr_db_hmo_rec.hmo_menu IS NOT NULL AND pi_old_menu IS NULL)
     --     
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_module != pi_new_module
       OR (pi_old_module IS NULL AND pi_new_module IS NOT NULL)
       OR (pi_old_module IS NOT NULL AND pi_new_module IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_title != pi_new_title
       OR (pi_old_title IS NULL AND pi_new_title IS NOT NULL)
       OR (pi_old_title IS NOT NULL AND pi_new_title IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_filename != pi_new_filename
       OR (pi_old_filename IS NULL AND pi_new_filename IS NOT NULL)
       OR (pi_old_filename IS NOT NULL AND pi_new_filename IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      IF pi_old_module_type != pi_new_module_type
       OR (pi_old_module_type IS NULL AND pi_new_module_type IS NOT NULL)
       OR (pi_old_module_type IS NOT NULL AND pi_new_module_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_fastpath_opts != pi_new_fastpath_opts
       OR (pi_old_fastpath_opts IS NULL AND pi_new_fastpath_opts IS NOT NULL)
       OR (pi_old_fastpath_opts IS NOT NULL AND pi_new_fastpath_opts IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_fastpath_invalid != pi_new_fastpath_invalid
       OR (pi_old_fastpath_invalid IS NULL AND pi_new_fastpath_invalid IS NOT NULL)
       OR (pi_old_fastpath_invalid IS NOT NULL AND pi_new_fastpath_invalid IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;  
      --
      IF pi_old_use_gri != pi_new_use_gri
       OR (pi_old_use_gri IS NULL AND pi_new_use_gri IS NOT NULL)
       OR (pi_old_use_gri IS NOT NULL AND pi_new_use_gri IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_application != pi_new_application
       OR (pi_old_application IS NULL AND pi_new_application IS NOT NULL)
       OR (pi_old_application IS NOT NULL AND pi_new_application IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_menu != pi_new_menu
       OR (pi_old_menu IS NULL AND pi_new_menu IS NOT NULL)
       OR (pi_old_menu IS NOT NULL AND pi_new_menu IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;        
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE hig_modules
           SET  hmo_module            =  UPPER(pi_new_module)
               ,hmo_title             =  pi_new_title
               ,hmo_filename          =  pi_new_filename
               ,hmo_module_type       =  pi_new_module_type
               ,hmo_fastpath_opts     =  pi_new_fastpath_opts
               ,hmo_fastpath_invalid  =  pi_new_fastpath_invalid
               ,hmo_use_gri           =  pi_new_use_gri
               ,hmo_application       =  pi_new_application
               ,hmo_menu              =  UPPER(pi_new_menu)
         WHERE hmo_module = UPPER(pi_old_module);
        --           
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF; 
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_module_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_module;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_module_role(pi_module           IN      hig_module_roles.hmr_module%TYPE
                              ,pi_role             IN      hig_module_roles.hmr_role%TYPE
                              ,pi_mode             IN      hig_module_roles.hmr_mode%TYPE
                              ,po_message_severity     OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    SAVEPOINT create_module_role_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module'
                               ,pi_parameter_value => pi_module);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_role);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value => pi_mode);                                       
    --
    IF module_role_exists(pi_module => pi_module
                         ,pi_role   => pi_role) = 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64);     
    END IF;    
    --
    IF module_exists(pi_module => pi_module) <> 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);     
    END IF;
    --
    IF role_exists(pi_role => pi_role) <> 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);     
    END IF;  
    -- 
    INSERT 
      INTO hig_module_roles 
           (hmr_module
           ,hmr_role
           ,hmr_mode
           )
    VALUES (UPPER(pi_module)
           ,UPPER(pi_role)
           ,UPPER(pi_mode));
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO create_module_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_module_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_module_role(pi_old_module           IN     hig_module_roles.hmr_module%TYPE 
                              ,pi_old_role             IN     hig_module_roles.hmr_role%TYPE 
                              ,pi_old_mode             IN     hig_module_roles.hmr_mode%TYPE 
                              ,pi_new_module           IN     hig_module_roles.hmr_module%TYPE 
                              ,pi_new_role             IN     hig_module_roles.hmr_role%TYPE 
                              ,pi_new_mode             IN     hig_module_roles.hmr_mode%TYPE 
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor)
    IS
    --    
    lr_db_hmr_rec    hig_module_roles%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_hmr_rec
        FROM hig_module_roles
       WHERE hmr_module = pi_old_module
         AND hmr_role   = pi_old_role
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Module Role does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_module_role_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module'
                               ,pi_parameter_value => pi_new_module);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_new_role);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value => pi_old_mode);                       
    --
    IF module_exists(pi_module => pi_new_module) <> 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);     
    END IF;
    --
    IF role_exists(pi_role => pi_new_role) <> 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);     
    END IF;  
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_hmr_rec.hmr_module != pi_old_module
     OR (lr_db_hmr_rec.hmr_module IS NULL AND pi_old_module IS NOT NULL)
     OR (lr_db_hmr_rec.hmr_module IS NOT NULL AND pi_old_module IS NULL)
     --
     OR (lr_db_hmr_rec.hmr_role != pi_old_role)
     OR (lr_db_hmr_rec.hmr_role IS NULL AND pi_old_role IS NOT NULL)
     OR (lr_db_hmr_rec.hmr_role IS NOT NULL AND pi_old_role IS NULL)
     --
     OR (lr_db_hmr_rec.hmr_mode != pi_old_mode)
     OR (lr_db_hmr_rec.hmr_mode IS NULL AND pi_old_mode IS NOT NULL)
     OR (lr_db_hmr_rec.hmr_mode IS NOT NULL AND pi_old_mode IS NULL)
     --     
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_module != pi_new_module
       OR (pi_old_module IS NULL AND pi_new_module IS NOT NULL)
       OR (pi_old_module IS NOT NULL AND pi_new_module IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_role != pi_new_role
       OR (pi_old_role IS NULL AND pi_new_role IS NOT NULL)
       OR (pi_old_role IS NOT NULL AND pi_new_role IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_mode != pi_new_mode
       OR (pi_old_mode IS NULL AND pi_new_mode IS NOT NULL)
       OR (pi_old_mode IS NOT NULL AND pi_new_mode IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;    
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE hig_module_roles
           SET  hmr_module = UPPER(pi_new_module)
               ,hmr_role   = UPPER(pi_new_role)
               ,hmr_mode   = UPPER(pi_new_mode)
         WHERE hmr_module = lr_db_hmr_rec.hmr_module
           AND hmr_role   = lr_db_hmr_rec.hmr_role;
        --           
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF; 
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_module_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_module_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_module_role(pi_module            IN      hig_module_roles.hmr_module%TYPE
                              ,pi_role              IN      hig_module_roles.hmr_role%TYPE 
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    SAVEPOINT delete_module_role_sp;
    --
    awlrs_util.check_historic_mode;
    --
    IF module_role_exists(pi_module => pi_module
                         ,pi_role   => pi_role) <> 'Y' 
     THEN 
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 26);
    END IF;
    --    
    DELETE 
      FROM hig_module_roles
     WHERE hmr_module = pi_module
       AND hmr_role   = pi_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_module_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_module_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_roles(po_message_severity OUT  hig_codes.hco_code%TYPE
                     ,po_message_cursor   OUT  sys_refcursor
                     ,po_cursor           OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT hro_role
           ,hro_product
           ,hro_descr
       FROM hig_roles
     ORDER BY hro_product, hro_role; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_roles;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_role(pi_role                IN      hig_roles.hro_role%TYPE
                    ,po_message_severity        OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor          OUT sys_refcursor
                    ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT hro_role
           ,hro_product
           ,hro_descr
       FROM hig_roles
      WHERE hro_role = pi_role;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_role;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_roles(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                           ,pi_filter_operators     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                           ,pi_filter_values_1      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                           ,pi_filter_values_2      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                           ,pi_order_columns        IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                           ,pi_order_asc_desc       IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                           ,pi_skip_n_rows          IN     PLS_INTEGER
                           ,pi_pagesize             IN     PLS_INTEGER
                           ,po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT hro_role    role_
                                                    ,hro_product product
                                                    ,hro_descr   description_
                                                FROM hig_roles';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  role_'
                                                  ||',product'
                                                  ||',description_'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'role_'
                                ,pi_query_col  => 'hro_role'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'product'
                                ,pi_query_col  => 'hro_product'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description_'
                                ,pi_query_col  => 'hro_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hro_role, hro_product')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING lv_lower_index;
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
  END get_paged_roles;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_module_roles(pi_role          IN      hig_module_roles.hmr_role%TYPE
                            ,po_message_severity OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT  sys_refcursor
                            ,po_cursor           OUT  sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmr_module module_
            ,hmo_title  title 
            ,hmr_mode   mode_
       FROM hig_module_roles
           ,hig_modules
      WHERE hig_module_roles.hmr_role = pi_role
        AND hmr_module = hmo_module
      ORDER BY hmr_module;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_module_roles;

  --
  -----------------------------------------------------------------------------
  --
  /*PROCEDURE get_module_role(pi_module             IN      hig_module_roles.hmr_module%TYPE
                           ,pi_role               IN      hig_module_roles.hmr_role%TYPE
                           ,po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hmr_module module_
            ,hmr_role   role_
            ,hmr_mode   mode_
       FROM hig_module_roles
      WHERE hmr_role   = pi_role
        AND hmr_module = pi_module
      ORDER BY hmr_module; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_module_role;*/
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_module_roles(pi_role                 IN     hig_module_roles.hmr_role%TYPE
                                  ,pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_operators     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_filter_values_1      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_filter_values_2      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                  ,pi_order_columns        IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                  ,pi_order_asc_desc       IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                  ,pi_skip_n_rows          IN     PLS_INTEGER
                                  ,pi_pagesize             IN     PLS_INTEGER
                                  ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor          OUT sys_refcursor
                                  ,po_cursor                  OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT hmr_module module_
                                                    ,hmo_title  title 
                                                    ,hmr_mode   mode_
                                               FROM hig_module_roles
                                                   ,hig_modules
                                              WHERE hmr_role   = :pi_role
                                                AND hmr_module = hmo_module';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  module_'
                                                  ||',title'
                                                  ||',mode_'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'module_'
                                ,pi_query_col  => 'hmr_module'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'title'
                                ,pi_query_col  => 'hmo_title'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'mode_'
                                ,pi_query_col  => 'hmr_mode'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hmr_module')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_role
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_role
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
  END get_paged_module_roles;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sys_privs_roles(pi_role          IN      hig_module_roles.hmr_role%TYPE
                               ,po_message_severity OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT  sys_refcursor
                               ,po_cursor           OUT  sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT role           role_
           ,privilege      privilege
       FROM role_sys_privs 
      WHERE role = pi_role
      ORDER BY role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_sys_privs_roles;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_add_sys_privs(po_message_severity OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT  sys_refcursor
                             ,po_cursor           OUT  sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT distinct privilege      privilege
       FROM dba_sys_privs
      ORDER BY privilege;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_add_sys_privs;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sys_privs_role(pi_sys_priv           IN      role_sys_privs.role%TYPE
                              ,pi_role               IN      hig_module_roles.hmr_role%TYPE
                              ,po_message_severity       OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor         OUT sys_refcursor
                              ,po_cursor                 OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT role           role_
           ,privilege      privilege
       FROM role_sys_privs 
      WHERE role = pi_role
        AND privilege = pi_sys_priv; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_sys_privs_role;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_sys_privs_roles(pi_role                 IN     hig_module_roles.hmr_role%TYPE
                                     ,pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_filter_operators     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_filter_values_1      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                     ,pi_filter_values_2      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                     ,pi_order_columns        IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_order_asc_desc       IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                     ,pi_skip_n_rows          IN     PLS_INTEGER
                                     ,pi_pagesize             IN     PLS_INTEGER
                                     ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor          OUT sys_refcursor
                                     ,po_cursor                  OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT role       role_
                                                    ,privilege  privilege
                                                FROM role_sys_privs 
                                               WHERE role = :pi_role';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  role_'
                                                  ||',privilege'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'role_'
                                ,pi_query_col  => 'role'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'privilege'
                                ,pi_query_col  => 'privilege'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'role')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_role
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_role
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
  END get_paged_sys_privs_roles;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_obj_privs_roles(pi_role          IN      hig_module_roles.hmr_role%TYPE
                               ,po_message_severity OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT  sys_refcursor
                               ,po_cursor           OUT  sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT grantee     grantee
            ,owner       owner_
            ,table_name  table_name
            ,grantor     grantor
            ,privilege   privilege_
            ,grantable   grantable
            ,hierarchy   hierarchy_
       FROM dba_tab_privs
      WHERE grantee = pi_role
      ORDER BY  table_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_obj_privs_roles;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_obj_privs_role(pi_role                IN      dba_tab_privs.grantee%TYPE
                              ,pi_privilege           IN      dba_tab_privs.privilege%TYPE
                              ,pi_table_name          IN      dba_tab_privs.table_name%TYPE
                              ,pi_owner               IN      dba_tab_privs.owner%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT grantee     grantee
            ,owner       owner_
            ,table_name  table_name
            ,grantor     grantor
            ,privilege   privilege_
            ,grantable   grantable
            ,hierarchy   hierarchy_
       FROM dba_tab_privs
      WHERE grantee = pi_role
        AND privilege = pi_privilege
        AND table_name = pi_table_name
        AND owner = pi_owner
      ORDER BY table_name; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_obj_privs_role;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_obj_privs_roles(pi_role                 IN     hig_module_roles.hmr_role%TYPE
                                     ,pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_filter_operators     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_filter_values_1      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                     ,pi_filter_values_2      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                     ,pi_order_columns        IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                     ,pi_order_asc_desc       IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                     ,pi_skip_n_rows          IN     PLS_INTEGER
                                     ,pi_pagesize             IN     PLS_INTEGER
                                     ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor          OUT sys_refcursor
                                     ,po_cursor                  OUT sys_refcursor)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT grantee     grantee
                                                    ,owner       owner_
                                                    ,table_name  table_name
                                                    ,grantor     grantor
                                                    ,privilege   privilege_
                                                    ,grantable   grantable
                                                    ,hierarchy   hierarchy_
                                              FROM dba_tab_privs
                                             WHERE grantee = :pi_role';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  grantee'
                                                  ||',owner_'
                                                  ||',table_name'
                                                  ||',grantor'
                                                  ||',privilege_'
                                                  ||',grantable'
                                                  ||',hierarchy_'
                                                  ||',row_count'
                                            ||' FROM (SELECT rownum ind'
                                                        ||' ,a.*'
                                                        ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                    ||' FROM ('||lv_driving_sql
      ;
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'grantee'
                                ,pi_query_col  => 'grantee'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'owner'
                                ,pi_query_col  => 'owner_'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'table_name'
                                ,pi_query_col  => 'table_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'grantor'
                                ,pi_query_col  => 'grantor'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'privilege'
                                ,pi_query_col  => 'privilege_'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'grantable'
                                ,pi_query_col  => 'grantable'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'hierarchy'
                                ,pi_query_col  => 'hierarchy_'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
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
      ||Process the filter.
      */
      IF pi_filter_columns.COUNT > 0
       THEN
          --
          set_column_data(po_column_data => lt_column_data);
          --
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          --
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'table_name')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_role
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_role
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
  END get_paged_obj_privs_roles;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE gen_role(pi_role                   IN      hig_roles.hro_role%TYPE)
    IS
    --
    ddl_error  exception;
    PRAGMA     exception_init( ddl_error, -20001 );   
    sql_string nm3type.max_varchar2;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --    
    sql_string := 'CREATE ROLE '||pi_role;
    hig.execute_ddl(sql_string);   
    --
  EXCEPTION    
    WHEN ddl_error
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 83);
  END gen_role; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE drop_role(pi_role  IN   hig_roles.hro_role%TYPE)
    IS
    --
    ddl_error  exception;
    PRAGMA     exception_init( ddl_error, -20001 );   
    sql_string nm3type.max_varchar2;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    sql_string := 'DROP ROLE '||pi_role;
    hig.execute_ddl(sql_string);   
    --
  EXCEPTION    
    WHEN ddl_error
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 83);
  END drop_role; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_role(pi_product         IN      hig_roles.hro_product%TYPE
                       ,pi_role            IN      hig_roles.hro_role%TYPE
                       ,pi_description     IN      hig_roles.hro_descr%TYPE
                       ,pi_run_checks      IN      VARCHAR2 DEFAULT 'Y'
                       ,po_message_severity     OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    lr_hur_rec hig_user_roles%ROWTYPE;
    lt_messages awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    SAVEPOINT create_role_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Product'
                               ,pi_parameter_value => pi_product);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_role);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_description);                                     
    --    
    IF  product_exists(pi_product => pi_product) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    IF role_exists(pi_role => pi_role) = 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info => 'Role');    
    END IF;
    --
    /*
    ||Check the user has priviledges
    */
    --
    IF NOT check_privs(pi_priv => 'CREATE ROLE') 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 86);    
    END IF;
    --
    /*
    ||insert the new role into hig_user_roles, if not highways owner then error. pb this should be warning. not error TO DO.
    */
    IF pi_run_checks = 'Y' 
     THEN
       IF SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME') <> SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
        THEN
           awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'HIG'
                                            ,pi_ner_id      => 116
                                            ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                            ,po_message_tab => lt_messages);
           --
       END IF;
    END IF;
    --
    IF lt_messages.COUNT > 0
     THEN
        --
        awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                     ,po_cursor      => po_message_cursor);
        --
        awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                       ,po_message_severity => po_message_severity);
        --
    ELSE
       /*
       ||create the role object, insert into hig role and hig user roles.
       */
       gen_role(pi_role => pi_role);
       --
       /*
       ||insert into roles.
       */
       INSERT 
         INTO hig_roles
              (hro_product
              ,hro_role
              ,hro_descr
              )
       VALUES (UPPER(pi_product)
              ,UPPER(pi_role)
              ,pi_description);     
       --
	     lr_hur_rec.hur_username   := Sys_Context('NM3CORE','APPLICATION_OWNER');
       lr_hur_rec.hur_role       := pi_role;
       lr_hur_rec.hur_start_date := TRUNC(SYSDATE);
       --
       hig.ins_hur(pi_hur_rec => lr_hur_rec);
       --
       awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                            ,po_cursor           => po_message_cursor);
       --
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO create_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_role(pi_role              IN     hig_roles.hro_role%TYPE 
                       ,pi_old_product       IN     hig_roles.hro_product%TYPE 
                       ,pi_old_descr         IN     hig_roles.hro_descr%TYPE 
                       ,pi_new_product       IN     hig_roles.hro_product%TYPE 
                       ,pi_new_descr         IN     hig_roles.hro_descr%TYPE 
                       ,po_message_severity     OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor       OUT sys_refcursor)
    IS
    --    
    lr_db_hro_rec    hig_roles%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_hro_rec
        FROM hig_roles
       WHERE hro_role = pi_role
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Role does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_role_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Product'
                               ,pi_parameter_value => pi_new_product);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_new_descr);                      
    --
    IF  product_exists(pi_product => pi_new_product) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;    
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_hro_rec.hro_product != pi_old_product
     OR (lr_db_hro_rec.hro_product IS NULL AND pi_old_product IS NOT NULL)
     OR (lr_db_hro_rec.hro_product IS NOT NULL AND pi_old_product IS NULL)
     --
     OR (lr_db_hro_rec.hro_descr != pi_old_descr)
     OR (lr_db_hro_rec.hro_descr IS NULL AND pi_old_descr IS NOT NULL)
     OR (lr_db_hro_rec.hro_descr IS NOT NULL AND pi_old_descr IS NULL)
     --    
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_product != pi_new_product
       OR (pi_old_product IS NULL AND pi_new_product IS NOT NULL)
       OR (pi_old_product IS NOT NULL AND pi_new_product IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_descr != pi_new_descr
       OR (pi_old_descr IS NULL AND pi_new_descr IS NOT NULL)
       OR (pi_old_descr IS NOT NULL AND pi_new_descr IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE hig_roles
           SET  hro_product = UPPER(pi_new_product)
               ,hro_descr   = pi_new_descr
         WHERE hro_role = lr_db_hro_rec.hro_role;
        --           
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF; 
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_role;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_role(pi_role              IN      hig_roles.hro_role%TYPE
                       ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    SAVEPOINT delete_role_sp;
    --
    awlrs_util.check_historic_mode;
    --
    IF role_exists(pi_role => pi_role) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    IF NOT can_delete_role (pi_role => pi_role)
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 86);    
    END IF;
    --
    drop_role(pi_role => pi_role);
    --
    DELETE
      FROM hig_module_roles 
     WHERE hmr_role = pi_role;
    --
    DELETE 
      FROM hig_user_roles
     WHERE hur_role = pi_role;
    --
    DELETE 
      FROM hig_roles
     WHERE hro_role = pi_role;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE grant_sys_privs_to_role (pi_role IN VARCHAR2, 
                                     pi_priv IN VARCHAR2) 
  IS
    --
    ddl_error EXCEPTION;
    PRAGMA    exception_init( ddl_error, -20001 );
    ddl_errm  VARCHAR2(70);
    --
    proc_input VARCHAR2(200) := '';
    return_val INTEGER;
    --
    CURSOR c1 IS
      SELECT grantee 
        FROM dba_role_privs
       WHERE granted_role = pi_role;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    proc_input := 'GRANT '||pi_priv||' TO '||pi_role;
    hig.execute_ddl(proc_input);
    --
    proc_input := '';
    --
    FOR c1_rec in c1 LOOP
       proc_input := 'GRANT '||pi_priv||' TO '||c1_rec.grantee;
       hig.execute_ddl(proc_input);
    END LOOP;
    --
  END grant_sys_privs_to_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE revoke_sys_privs_from_role(pi_role IN VARCHAR2, 
                                       pi_priv IN VARCHAR2 ) IS
  --
    ddl_error EXCEPTION;
    pragma    exception_init( ddl_error, -20001 );
    ddl_errm  VARCHAR2(70);
    --
    proc_input VARCHAR2(200) := '';
    return_val INTEGER;
    /*
    || On revoking the privilege from the role, all grantees of that role
    || who also have this privilege (directly) should have the 
    || privilege revoked , unless that privilege has been granted through
    || another role.
    ||
    || Hence the user must not be assigned privileges directly since these will
    || be revoked if the same privileges are assigned to a role and then revoked.
    ||
    */
    CURSOR c1 IS
      SELECT u.grantee
        FROM dba_role_privs u, dba_sys_privs rp, dba_sys_privs up  -- give all grantees of the privilege
       WHERE u.granted_role = pi_role                              -- who have the privilege directly and
         AND up.grantee = u.grantee                                -- through the role
         AND up.privilege = pi_priv
         AND rp.privilege = pi_priv
         AND rp.grantee   = u.grantee
         AND rp.privilege NOT IN (                                 -- where these privilieges are not in
           SELECT s.privilege                                      -- those privileges assigned to the grantee
             FROM dba_role_privs r, 
                  dba_sys_privs s, 
                  dba_role_privs p  
            WHERE s.privilege = pi_priv
              AND s.grantee = r.granted_role
              AND R.grantee = p.grantee
              AND r.granted_role != pi_role                        -- through a role other than the current
              AND p.granted_role = r.granted_role
              AND p.grantee = u.grantee
           );
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    proc_input := 'REVOKE '||pi_priv||' FROM '||pi_role;
    hig.execute_ddl(proc_input);
    --
    proc_input := '';
    --
    FOR c1_rec IN c1 LOOP
       proc_input := 'REVOKE '||pi_priv||' FROM '||c1_rec.grantee;
       hig.execute_ddl(proc_input);
    END LOOP;
    --
  END;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_sys_priv_role(pi_role              IN      hig_roles.hro_role%TYPE
                                ,pi_priv              IN      dba_sys_privs.privilege%TYPE
                                ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    IF role_exists(pi_role => pi_role) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    grant_sys_privs_to_role (pi_role => pi_role
                            ,pi_priv => pi_priv);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_sys_priv_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_sys_priv_role(pi_role              IN      hig_roles.hro_role%TYPE
                                ,pi_priv              IN      dba_sys_privs.privilege%TYPE
                                ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    IF role_exists(pi_role => pi_role) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    revoke_sys_privs_from_role(pi_role => pi_role 
                              ,pi_priv => pi_priv);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_sys_priv_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_launchpad_detail(pi_parent               IN      hig_standard_favourites.hstf_parent%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hstf_child module_name 
          ,decode(hstf_descr,'v3 Errors','Error Messages',hstf_descr) module_desc
          ,hstf_order module_order
      FROM hig_standard_favourites
     WHERE hstf_parent = pi_parent
       AND hstf_type = 'M'
       AND nm3user.user_can_run_module_vc(hstf_child) = 'Y'
     ORDER BY  hstf_order; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_launchpad_detail;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_launchpad_detail(po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    get_launchpad_detail(pi_top                 => 'AWLRS_LAUNCHPAD'
                        ,po_message_severity    => po_message_severity
                        ,po_message_cursor      => po_message_cursor
                        ,po_cursor              => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_launchpad_detail;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_launchpad_detail(pi_top                 IN      hig_standard_favourites.hstf_parent%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hstf_child  module_name
          ,hstf_parent parent_module
          ,hstf_descr  module_desc
          ,hstf_order  module_order
          ,hstf_type   module_type
          ,level
      FROM hig_standard_favourites
     START WITH hstf_parent = pi_top
     CONNECT BY PRIOR hstf_child = hstf_parent
       AND ((hstf_type = 'M' AND nm3user.user_can_run_module_vc(hstf_child) = 'Y' 
       AND (SELECT 'Y'
               FROM hig_module_roles hmr, hig_user_roles sr, hig_modules hm
              WHERE hur_username = SYS_CONTEXT('nm3_security_ctx','username')
                AND hmr.hmr_role = sr.hur_role 
                AND hm.hmo_module = hmr.hmr_module
                AND hm.hmo_module = hstf_child
                AND hmr.hmr_mode = 'NORMAL' 
                AND rownum = 1) ='Y') OR (hstf_type = 'F'))
     ORDER BY  level,hstf_parent,hstf_order; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_launchpad_detail;  
  --
END awlrs_metasec_api;
/