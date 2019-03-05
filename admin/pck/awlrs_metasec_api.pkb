CREATE OR REPLACE PACKAGE BODY awlrs_metasec_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_metasec_api.pkb-arc   1.2   Mar 05 2019 08:55:36   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_metasec_api.pkb  $
  --       Date into PVCS   : $Date:   Mar 05 2019 08:55:36  $
  --       Date fetched Out : $Modtime:   Mar 04 2019 14:27:42  $
  --       Version          : $Revision:   1.2  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.2  $';
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
  PROCEDURE add_product_license(pi_product          IN     hig_products.hpr_product%TYPE
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor)
    IS
    --
  BEGIN
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
    --
  BEGIN
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
                                ,pi_mask       => 'DD-MM-YYYY' 
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
    validate_notnull(pi_parameter_desc  => 'Admin Type'
                    ,pi_parameter_value => pi_admin_type);
                    
    --
    validate_notnull(pi_parameter_desc  => 'Description'
                    ,pi_parameter_value => pi_desc);
                    
    --
    validate_notnull(pi_parameter_desc  => 'Exclusive Flag'
                    ,pi_parameter_value => pi_exclusive);                    

    IF admin_type_exists(pi_admin_type => pi_admin_type) = 'Y' 
     THEN   
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64);     
    END IF;
    --
    IF pi_exclusive NOT IN ('Y','N') 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 1);
    END IF;
    --    
    INSERT 
      INTO nm_au_types_full 
           (nat_admin_type
           ,nat_descr
           ,nat_exclusive)
    VALUES (UPPER(pi_admin_type)
           ,UPPER(pi_desc)
           ,UPPER(pi_exclusive));--pb check created by and stuff is being created by triggers.
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
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
    validate_notnull(pi_parameter_desc  => 'Admin unit type'
                    ,pi_parameter_value => pi_new_admin_type);  
    --                    
    validate_notnull(pi_parameter_desc  => 'Description'
                    ,pi_parameter_value => pi_new_description);   
    --                    
    validate_notnull(pi_parameter_desc  => 'Exclusive'
                    ,pi_parameter_value => pi_new_exclusive);                    
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
    
    IF pi_new_exclusive NOT IN ('Y','N') 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 1);
    END IF;
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
                                ,pi_mask       => 'DD-MM-YYYY' 
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'nau_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MM-YYYY' 
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
  PROCEDURE create_admin_unit(pi_admin_type        IN     nm_admin_units_all.nau_admin_type%TYPE
                             ,pi_unit_code         IN     nm_admin_units_all.nau_unit_code%TYPE      
                             ,pi_level             IN     nm_admin_units_all.nau_level%TYPE  
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
    validate_notnull(pi_parameter_desc  => 'Admin Type'
                    ,pi_parameter_value => pi_admin_type);
    --
    validate_notnull(pi_parameter_desc  => 'Name'
                    ,pi_parameter_value => pi_name);
    --
    validate_notnull(pi_parameter_desc  => 'Start Date'
                    ,pi_parameter_value => pi_start_date);   
    --
    validate_notnull(pi_parameter_desc  => 'Level'
                    ,pi_parameter_value => pi_level);
    --
    validate_notnull(pi_parameter_desc  => 'Code'
                    ,pi_parameter_value => pi_authority_code);
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
    IF pi_minor_undertaker NOT IN ('Y','N') 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 1
                     ,pi_supplementary_info => 'Minor undertaker');
    END IF;
    /*
    ||build record for insert.
    */    
    lr_nau_rec.nau_admin_unit       := null; --created by package
    lr_nau_rec.nau_unit_code        := UPPER(pi_unit_code);
    lr_nau_rec.nau_level            := 1;--pb to do?
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
    lr_nau_rec.nau_start_date       := pi_start_date;
    lr_nau_rec.nau_end_date         := pi_end_date;
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
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_admin_unit;

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
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Parent Admin Type'
                    ,pi_parameter_value => pi_parent_admin_type);
    --
    validate_notnull(pi_parameter_desc  => 'Parent Name'
                    ,pi_parameter_value => pi_parent_name);
    --
    validate_notnull(pi_parameter_desc  => 'Parent Start Date'
                    ,pi_parameter_value => pi_parent_start_date);   
    --
    validate_notnull(pi_parameter_desc  => 'Parent Level'
                    ,pi_parameter_value => pi_parent_level);
    --
    validate_notnull(pi_parameter_desc  => 'Parent Code'
                    ,pi_parameter_value => pi_parent_authority_code);
    --
    validate_notnull(pi_parameter_desc  => 'Admin Type'
                    ,pi_parameter_value => pi_admin_type);
    --
    validate_notnull(pi_parameter_desc  => 'Name'
                    ,pi_parameter_value => pi_name);
    --
    validate_notnull(pi_parameter_desc  => 'Start Date'
                    ,pi_parameter_value => pi_start_date);   
    --
    validate_notnull(pi_parameter_desc  => 'Level'
                    ,pi_parameter_value => pi_level);
    --
    validate_notnull(pi_parameter_desc  => 'Code'
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
    lr_nau_rec.nau_start_date := pi_start_date;
    lr_nau_rec.nau_end_date := pi_end_date;
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
    lr_nau_rec_parent.nau_start_date := pi_parent_start_date;
    lr_nau_rec_parent.nau_end_date := pi_parent_end_date;
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
                             ,pi_old_start_date        IN     nm_admin_units_all.nau_start_date%TYPE
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
                             ,pi_new_start_date        IN     nm_admin_units_all.nau_start_date%TYPE
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
    validate_notnull(pi_parameter_desc  => 'Admin Type'
                    ,pi_parameter_value => pi_new_admin_type);
    --
    validate_notnull(pi_parameter_desc  => 'Name'
                    ,pi_parameter_value => pi_new_name);
    --
    validate_notnull(pi_parameter_desc  => 'Start Date'
                    ,pi_parameter_value => pi_new_start_date);   
    --
    validate_notnull(pi_parameter_desc  => 'Level'
                    ,pi_parameter_value => pi_new_level);
    --
    validate_notnull(pi_parameter_desc  => 'Code'
                    ,pi_parameter_value => pi_new_authority_code);                    
    --
    IF pi_new_minor_undertaker IS NOT NULL AND pi_new_minor_undertaker NOT IN ('Y','N') 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 1);
    END IF;
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
     OR (lr_db_nau_rec.nau_address2 != pi_old_address3)
     OR (lr_db_nau_rec.nau_address2 IS NULL AND pi_old_address3 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address2 IS NOT NULL AND pi_old_address3 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address3 != pi_old_address4)
     OR (lr_db_nau_rec.nau_address3 IS NULL AND pi_old_address4 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address3 IS NOT NULL AND pi_old_address4 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address4 != pi_old_address5)
     OR (lr_db_nau_rec.nau_address4 IS NULL AND pi_old_address5 IS NOT NULL)
     OR (lr_db_nau_rec.nau_address4 IS NOT NULL AND pi_old_address5 IS NULL)
     --
     OR (lr_db_nau_rec.nau_address5 != pi_old_phone)
     OR (lr_db_nau_rec.nau_address5 IS NULL AND pi_old_phone IS NOT NULL)
     OR (lr_db_nau_rec.nau_address5 IS NOT NULL AND pi_old_phone IS NULL)
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
     OR (lr_db_nau_rec.nau_start_date != pi_old_start_date)
     OR (lr_db_nau_rec.nau_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_nau_rec.nau_start_date IS NOT NULL AND pi_old_start_date IS NULL)
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
      IF pi_old_start_date != pi_new_start_date
       OR (pi_old_start_date IS NULL AND pi_new_start_date IS NOT NULL)
       OR (pi_old_start_date IS NOT NULL AND pi_new_start_date IS NULL)
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
              ,nau_start_date       = TRUNC(pi_new_start_date)      
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
    UPDATE nm_admin_units_all 
       SET nau_end_date = TRUNC(pi_end_date)
     WHERE nau_admin_unit = pi_admin_unit;
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
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
  PROCEDURE get_admin_subtypes(po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
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
  --
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
  --
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
  --
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
  --
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
  --
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
END awlrs_metasec_api;