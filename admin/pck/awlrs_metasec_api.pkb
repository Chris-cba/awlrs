CREATE OR REPLACE PACKAGE BODY awlrs_metasec_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_metasec_api.pkb-arc   1.0   Jan 24 2019 10:47:06   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_metasec_api.pkb  $
  --       Date into PVCS   : $Date:   Jan 24 2019 10:47:06  $
  --       Date fetched Out : $Modtime:   Dec 20 2018 16:47:20  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';
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
END awlrs_metasec_api;