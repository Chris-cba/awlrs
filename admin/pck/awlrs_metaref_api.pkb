CREATE OR REPLACE PACKAGE BODY awlrs_metaref_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_metaref_api.pkb-arc   1.4   May 09 2019 14:11:10   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_metaref_api.pkb  $
  --       Date into PVCS   : $Date:   May 09 2019 14:11:10  $
  --       Date fetched Out : $Modtime:   Mar 25 2019 11:16:12  $
  --       Version          : $Revision:   1.4  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.4  $';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_metaref_api';
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
  FUNCTION code_exists(pi_domain IN hig_codes.hco_domain%TYPE
                      ,pi_code   IN hig_codes.hco_code%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists 
      FROM hig_codes 
     WHERE hco_domain = pi_domain
       AND hco_code = pi_code;   
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      RETURN lv_exists;
      --
  END code_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION domain_exists(pi_domain IN hig_codes.hco_domain%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_domains 
     WHERE hdo_domain = pi_domain;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      RETURN lv_exists;
      --
  END domain_exists;
  
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
  FUNCTION unit_domain_exists (pi_unit_domain_id IN nm_unit_domains.ud_domain_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_unit_domains
     WHERE ud_domain_id = pi_unit_domain_id;
    --    
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
       --
       RETURN lv_exists;
       --
  END unit_domain_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION unit_exists (pi_unit_id IN nm_units.un_unit_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_units
     WHERE un_unit_id = pi_unit_id;
    --    
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
       --
       RETURN lv_exists;
       --
  END unit_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_option_exists (pi_user_id          IN       hig_user_options.huo_hus_user_id%TYPE
                              ,pi_option_id        IN       hig_user_options.huo_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_user_options
     WHERE huo_hus_user_id = pi_user_id
       AND huo_id = pi_option_id;
    --    
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
       --
       RETURN lv_exists;
       --
  END user_option_exists; 
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION unit_conversion_exists (pi_unit_conv_id_in  IN nm_unit_conversions.uc_unit_id_in%TYPE
                                  ,pi_unit_conv_id_out IN nm_unit_conversions.uc_unit_id_out%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_unit_conversions
     WHERE uc_unit_id_in  = pi_unit_conv_id_in
       AND uc_unit_id_out = pi_unit_conv_id_out;
    --    
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
       --
       RETURN lv_exists;
       --
  END unit_conversion_exists;  
    
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_code_value_length(pi_domain IN hig_codes.hco_domain%TYPE
                                   ,pi_code   IN hig_codes.hco_code%TYPE) 
  IS
  --
  lv_code_length hig_domains.hdo_code_length%TYPE;
  --
  BEGIN
    --
    SELECT hdo_code_length
      INTO lv_code_length
      FROM hig_domains
     WHERE hdo_domain = pi_domain;
    --
    IF LENGTH(pi_code) > lv_code_length THEN
      --
      hig.raise_ner(pi_appl => 'HIG'
                   ,pi_id   => 69
                   ,pi_supplementary_info => ' You have exceeded the defined limit of ' || lv_code_length || ' characters for this option.');
      --
    END IF;
    --
  END check_code_value_length;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_option_value(pi_option_id IN hig_options.hop_id%TYPE
                                 ,pi_value     IN hig_options.hop_value%TYPE) 
  IS
  --
   lv_format     hig_options.hop_datatype%TYPE;
   lv_domain     hig_options.hop_domain%TYPE;
   lv_case       hig_options.hop_mixed_case%TYPE;
   lv_max_Length hig_options.hop_max_length%TYPE;
  --
  BEGIN
    --
    SELECT datatype
          ,domain
          ,mixed_case
          ,max_length
      INTO lv_format
          ,lv_domain
          ,lv_case
          ,lv_max_Length
      FROM (SELECT hol_id          option_id
                  ,hol_datatype    datatype
                  ,hol_domain      domain
                  ,hol_mixed_case  mixed_case
                  ,hol_max_length  max_length
              FROM hig_option_list
             UNION
            SELECT huol_id         option_id
                  ,huol_datatype   datatype
                  ,huol_domain     domain
                  ,huol_mixed_case mixed_case
                  ,huol_max_length max_length
              FROM hig_user_option_list)
     WHERE option_id = pi_option_id;
    --
	   IF lv_domain IS NULL
	   	THEN
		     IF lv_format = 'VARCHAR2' THEN
		       IF lv_case = 'Y' THEN
		         NULL; -- Mixed case is allowed, so all OK
		       ELSIF UPPER(pi_value) != pi_value THEN
		         --
             hig.raise_ner(pi_appl => 'HIG'
                          ,pi_id   => 159);
             --
		       END IF;
		     ELSIF lv_format = 'NUMBER' THEN
		        IF NOT nm3flx.is_numeric (pi_value) THEN
		           --
               hig.raise_ner(pi_appl => 'HIG'
                            ,pi_id   => 111);
               --
		        END IF;
		     ELSE   -- It's a DATE
		   	    IF hig.date_convert (pi_value) IS NULL THEN
		           --
               hig.raise_ner(pi_appl => 'HIG'
                            ,pi_id   => 148); --pb todo this id looks wrong but came from forms?
               --
		   	    END IF;
		     END IF;
	   ELSE
       /*
       ||check valid code.
       */
       DECLARE
          l_invalid EXCEPTION;
          PRAGMA EXCEPTION_INIT (l_invalid,-20001);
       BEGIN
          hig.valid_fk_hco (pi_hco_domain => lv_domain
                           ,pi_hco_code   => pi_value
                           );
       EXCEPTION
          WHEN l_invalid
           THEN
             hig.raise_ner (pi_appl               => nm3type.c_hig
                           ,pi_id                 => 109
                           ,pi_supplementary_info => '"'||lv_domain||'" -> "'||pi_value||'"'
                           );
       END;
       --
     END IF;
	   --
	   IF LENGTH(pi_value) > lv_max_Length THEN
        hig.raise_ner (pi_appl               => 'HIG'
                      ,pi_id                 => 69
                      ,pi_supplementary_info => ' You have exceeded the defined limit of ' || lv_max_Length || ' characters for this option.'
                      );
     END IF;
    --
  END validate_option_value;

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
  PROCEDURE gen_unit_conversion_fun(pi_unit_conv_function     IN      nm_unit_conversions.uc_function%TYPE
                                   ,pi_unit_conv_conversion   IN      nm_unit_conversions.uc_conversion%TYPE)
    IS
    --
    e_no_object_for_syn EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_object_for_syn, -20301);
    
    e_user_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_user_not_exist, -20302);
    
    e_no_permission EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_permission, -20303);
    
    e_no_create_priv exception;
    PRAGMA EXCEPTION_INIT(e_no_create_priv, -20305);
    
    e_sql_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_sql_error, -20306);
    
    e_no_object_in_string EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_object_in_string, -20307);    
    --
  BEGIN
    --
    BEGIN
      nm3ddl.create_object_and_syns(p_object_name => pi_unit_conv_function
                                   ,p_ddl_text    => pi_unit_conv_conversion);    
       --
    EXCEPTION
      WHEN e_no_object_for_syn
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 79);      
      WHEN e_user_not_exist
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 80);    
      WHEN e_no_permission
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 81);        
      WHEN e_no_create_priv
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 82);        
      WHEN e_sql_error
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 83);        
      WHEN e_no_object_in_string
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 84);
    END;
    --
  END gen_unit_conversion_fun; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_code(pi_domain           IN     hig_codes.hco_domain%TYPE
                    ,pi_code             IN     hig_codes.hco_code%TYPE
                    ,po_message_severity    OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor      OUT sys_refcursor
                    ,po_cursor              OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR    
    SELECT hco_domain
          ,hco_code
          ,hco_meaning
          ,hco_system
          ,hco_seq
          ,hco_start_date
          ,hco_end_date
      FROM hig_codes
     WHERE hco_domain = pi_domain
       AND hco_code = pi_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_code;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_codes(pi_domain           IN     hig_codes.hco_domain%TYPE
                     ,po_message_severity    OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor      OUT sys_refcursor
                     ,po_cursor              OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR    
    SELECT hco_domain
          ,hco_code
          ,hco_meaning
          ,hco_system
          ,hco_seq
          ,hco_start_date
          ,hco_end_date
      FROM hig_codes
     WHERE hco_domain = pi_domain
     ORDER BY hco_domain;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_codes;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_codes(pi_domain           IN  hig_codes.hco_domain%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT hco_domain domain
                                                   ,hco_code code
                                                   ,hco_meaning meaning
                                                   ,hco_system system_data
                                                   ,hco_seq seq
                                                   ,hco_start_date start_date
                                                   ,hco_end_date end_date
                                              FROM hig_codes
                                             WHERE hco_domain = :pi_domain'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT domain'
                                              ||' ,code'
                                              ||' ,meaning'
                                              ||' ,system_data'
                                              ||' ,seq'
                                              ||' ,start_date'
                                              ||' ,end_date'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'domain'
                                ,pi_query_col    => 'hco_domain'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'code'
                                ,pi_query_col    => 'hco_code'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'meaning'
                                ,pi_query_col    => 'hco_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'system_data'
                                ,pi_query_col    => 'hco_system'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'seq'
                                ,pi_query_col    => 'hco_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'hco_start_date'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MM-YYYY' 
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                                ,pi_query_col    => 'hco_end_date'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MM-YYYY' 
                                ,pio_column_data => po_column_data);
      --        
      --
      --<Repeat for each column that should allow filtering>
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
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hco_domain, hco_seq')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_domain
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_domain
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
  END get_paged_codes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_domain(pi_domain           IN     hig_domains.hdo_domain%TYPE
                      ,po_message_severity    OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor      OUT sys_refcursor
                      ,po_cursor              OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR    
    SELECT hdo_domain
          ,hdo_product
          ,hdo_title          
          ,hdo_code_length
      FROM hig_domains
     WHERE hdo_domain = pi_domain;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_domain;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_domains(po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor
                       ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR    
    SELECT hdo_domain
          ,hdo_product
          ,hdo_title          
          ,hdo_code_length
      FROM hig_domains
     ORDER BY hdo_domain;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_domains(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT hdo_domain domain
                                                   ,hdo_title title
                                                   ,hdo_product product
                                                   ,hdo_code_length code_length
                                               FROM hig_domains'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT domain'
                                              ||' ,title'
                                              ||' ,product'
                                              ||' ,code_length'                                              
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
      awlrs_util.add_column_data(pi_cursor_col   => 'domain'
                                ,pi_query_col    => 'hdo_domain'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'title'
                                ,pi_query_col    => 'hdo_title'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product'
                                ,pi_query_col    => 'hdo_product'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'code_length'
                                ,pi_query_col    => 'hdo_code_length'
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
                                 ,pi_where_or_and => 'WHERE'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hdo_domain')||') a)'
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
  END get_paged_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_product_option(pi_option           IN      hig_options.hop_id%TYPE
                              ,po_message_severity     OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT sys_refcursor
                              ,po_cursor               OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR        
    SELECT hop_id           option_id
          ,hop_product      product
          ,hop_name         name
          ,hop_value        option_value
          ,hop_remarks      remark
          ,hop_domain       option_domain
          ,hop_datatype     option_datatype
          ,hop_mixed_case   mixed_case
          ,hop_max_length   max_length
          ,hol_user_option user_option
      FROM hig_options
          ,hig_option_list
     WHERE hop_id = hol_id
       AND hop_id = pi_option;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_product_option;
 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_product_options(po_message_severity     OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT sys_refcursor
                               ,po_cursor               OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR      
    SELECT hop_id          option_id
          ,hop_product     product
          ,hop_name        name
          ,hop_value       option_value
          ,hop_remarks     remark
          ,hop_domain      option_domain
          ,hop_datatype    option_datatype
          ,hop_mixed_case  mixed_case
          ,hop_max_length  max_length
          ,hol_user_option user_option
      FROM hig_options
          ,hig_option_list
     WHERE hop_id = hol_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_product_options;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_product_options(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT hop_id          option_id
                                                   ,hop_product     product
                                                   ,hop_name        name
                                                   ,hop_value       option_value
                                                   ,hop_remarks     remark
                                                   ,hop_domain      option_domain
                                                   ,hop_datatype    option_datatype
                                                   ,hop_mixed_case  mixed_case
                                                   ,hop_max_length  max_length
                                                   ,hol_user_option user_option
                                               FROM hig_options
                                                   ,hig_option_list
                                              WHERE hop_id = hol_id'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT option_id
                                                  ,product
                                                  ,name
                                                  ,option_value
                                                  ,remark
                                                  ,option_domain
                                                  ,option_datatype
                                                  ,mixed_case
                                                  ,max_length
                                                  ,user_option'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'option_id'
                                ,pi_query_col    => 'hop_id' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product'
                                ,pi_query_col    => 'hop_product' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'name'
                                ,pi_query_col    => 'hop_name' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_value'
                                ,pi_query_col    => 'hop_value' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'remark'
                                ,pi_query_col    => 'hop_remarks' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_domain'
                                ,pi_query_col    => 'hop_domain' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_datatype'
                                ,pi_query_col    => 'hop_datatype' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'mixed_case'
                                ,pi_query_col    => 'hop_mixed_case' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'max_length'
                                ,pi_query_col    => 'hop_max_length' 
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'user_option'
                                ,pi_query_col    => 'hol_user_option' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
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
                                 ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hop_product, hop_id')||') a)'
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
  END get_paged_product_options;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_prod_option(pi_option           IN      hig_options.hop_id%TYPE
                                ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor       OUT sys_refcursor
                                ,po_cursor               OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR        
    SELECT huol_id           option_id
          ,huol_product      product
          ,huol_name         name
          ,huol_remarks      remark
          ,huol_domain       option_domain
          ,huol_datatype     option_datatype
          ,huol_mixed_case   mixed_case
          ,huol_max_length   max_length
      FROM hig_user_option_list
     WHERE huol_id = pi_option;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_prod_option;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_prod_options(po_message_severity     OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT sys_refcursor
                                 ,po_cursor               OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR      
    SELECT huol_id           option_id
          ,huol_product      product
          ,huol_name         name
          ,huol_remarks      remark
          ,huol_domain       option_domain
          ,huol_datatype     option_datatype
          ,huol_mixed_case   mixed_case
          ,huol_max_length   max_length
      FROM hig_user_option_list;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_prod_options;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_prod_options(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := '    SELECT huol_id           option_id
                                                       ,huol_product      product
                                                       ,huol_name         name
                                                       ,huol_remarks      remark
                                                       ,huol_domain       option_domain
                                                       ,huol_datatype     option_datatype
                                                       ,huol_mixed_case   mixed_case
                                                       ,huol_max_length   max_length
                                                  FROM hig_user_option_list'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT option_id
                                                  ,product
                                                  ,name
                                                  ,remark
                                                  ,option_domain
                                                  ,option_datatype
                                                  ,mixed_case
                                                  ,max_length'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'option_id'
                                ,pi_query_col    => 'huol_id' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product'
                                ,pi_query_col    => 'huol_product' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'name'
                                ,pi_query_col    => 'huol_name' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'remark'
                                ,pi_query_col    => 'huol_remarks' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_domain'
                                ,pi_query_col    => 'huol_domain' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_datatype'
                                ,pi_query_col    => 'huol_datatype' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'mixed_case'
                                ,pi_query_col    => 'huol_mixed_case' 
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'max_length'
                                ,pi_query_col    => 'huol_max_length' 
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'huol_product, huol_id')||') a)'
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
  END get_paged_user_prod_options;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user(pi_user_id       IN     hig_users.hus_user_id%TYPE
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor
                    ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hus_user_id user_id
            ,hus_initials initials
            ,hus_name name
            ,hus_username username
        FROM hig_users 
       WHERE hus_user_id = pi_user_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_users(po_message_severity OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor   OUT sys_refcursor
                     ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT hus_user_id user_id
            ,hus_initials initials
            ,hus_name name
            ,hus_username username
        FROM hig_users
       ORDER BY DECODE(hus_username,Sys_Context('NM3_SECURITY_CTX','USERNAME'),1,2), upper(hus_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_users;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_users(pi_filter_columns   IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT hus_user_id  user_id
                                                   ,hus_initials initials
                                                   ,hus_name     name
                                                   ,hus_username username
                                               FROM hig_users'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT user_id'
                                              ||' ,initials'
                                              ||' ,name'
                                              ||' ,username'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'user_id'
                                ,pi_query_col    => 'hus_user_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'initials'
                                ,pi_query_col    => 'hus_initials'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'name'
                                ,pi_query_col    => 'hus_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'username'
                                ,pi_query_col    => 'hus_username'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'DECODE(hus_username,Sys_Context(''NM3_SECURITY_CTX'',''USERNAME''),1,2), upper(hus_name)')||') a)'
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
  END get_paged_users;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_option(pi_user_id       IN     hig_user_options.huo_hus_user_id%TYPE
                           ,pi_option_id     IN     hig_user_options.huo_id%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT huo_hus_user_id user_id
            ,huo_id          option_id
            ,huol_product    product
            ,huo_value       option_value
            ,huol_name       option_meaning
            ,huol_domain     option_domain
            ,huol_datatype   option_datatype
            ,huol_mixed_case mixed_case
            ,huol_max_length max_length            
        FROM hig_user_options
            ,hig_user_option_list_all
       WHERE huo_id = huol_id
         AND huo_hus_user_id = pi_user_id
         AND huo_id = pi_option_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_option;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_options(pi_user_id       IN     hig_user_options.huo_hus_user_id%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT huo_hus_user_id user_id
            ,huo_id          option_id
            ,huol_product    product
            ,huo_value       option_value
            ,huol_name       option_meaning
            ,huol_domain     option_domain
            ,huol_datatype   option_datatype
            ,huol_mixed_case mixed_case
            ,huol_max_length max_length     
        FROM hig_user_options
            ,hig_user_option_list_all
       WHERE huo_id = huol_id
         AND huo_hus_user_id = pi_user_id;    
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_options;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_add_user_options(pi_user_id       IN     hig_user_options.huo_hus_user_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT huol_id         option_id
            ,huol_name       option_meaning
            ,huol_domain     option_domain
            ,huol_datatype   option_datatype
            ,huol_mixed_case mixed_case
            ,huol_max_length max_length              
        FROM hig_user_option_list_all
       WHERE NOT EXISTS (SELECT 1
                           FROM hig_user_options
                          WHERE huo_hus_user_id = pi_user_id
                            AND huo_id = huol_id)
       ORDER BY huol_id;    
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_add_user_options;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_options(pi_user_id          IN  hig_user_options.huo_hus_user_id%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT huo_hus_user_id user_id
                                                   ,huo_id          option_id
                                                   ,huol_product    product
                                                   ,huo_value       option_value
                                                   ,huol_name       option_meaning
                                                   ,huol_domain     option_domain
                                                   ,huol_datatype   option_datatype
                                                   ,huol_mixed_case mixed_case
                                                   ,huol_max_length max_length    
                                               FROM hig_user_options
                                                   ,hig_user_option_list_all
                                              WHERE huo_id = huol_id
                                                AND huo_hus_user_id = :pi_user_id'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT user_id'
                                              ||' ,option_id'
                                              ||' ,product'
                                              ||' ,option_value'
                                              ||' ,option_meaning'
                                              ||' ,option_domain'
                                              ||' ,option_datatype'
                                              ||' ,mixed_case'
                                              ||' ,max_length'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'user_id'
                                ,pi_query_col    => 'huo_hus_user_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_id'
                                ,pi_query_col    => 'huo_id'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product'
                                ,pi_query_col    => 'huol_product'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);                                
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_value'
                                ,pi_query_col    => 'huo_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_meaning'
                                ,pi_query_col    => 'huol_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_domain'
                                ,pi_query_col    => 'huol_domain'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_datatype'
                                ,pi_query_col    => 'huol_datatype'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'mixed_case'
                                ,pi_query_col    => 'huol_mixed_case'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);                                    
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'max_length'
                                ,pi_query_col    => 'huol_max_length'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
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
                                 ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'huo_id')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    nm_debug.debug_on;
    nm_debug.debug(lv_filter);
    nm_debug.debug(lv_cursor_sql);    
    nm_debug.debug_off;
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_user_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_user_id
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
  END get_paged_user_options;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_error(pi_product_id    IN     nm_errors.ner_appl%TYPE
                     ,pi_error_id      IN     nm_errors.ner_id%TYPE
                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor   OUT sys_refcursor
                     ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ner_appl
            ,ner_id
            ,ner_her_no
            ,ner_descr
            ,ner_cause
        FROM nm_errors
       WHERE ner_appl = pi_product_id
         AND ner_id = pi_error_id
       ORDER BY ner_appl, ner_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_error;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_errors(po_message_severity OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor   OUT sys_refcursor
                      ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ner_appl
            ,ner_id
            ,ner_her_no
            ,ner_descr
            ,ner_cause
        FROM nm_errors
       ORDER BY ner_appl, ner_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_errors;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_errors(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT ner_appl product
                                                   ,ner_id error_id
                                                   ,ner_her_no hig_error_id
                                                   ,ner_descr description
                                                   ,ner_cause cause
                                               FROM nm_errors'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT product'
                                              ||' ,error_id'
                                              ||' ,hig_error_id'
                                              ||' ,description'
                                              ||' ,cause'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'product'
                                ,pi_query_col    => 'ner_appl'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'error_id'
                                ,pi_query_col    => 'ner_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'hig_error_id'
                                ,pi_query_col    => 'ner_her_no'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'description'
                                ,pi_query_col    => 'ner_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => null
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'cause'
                                ,pi_query_col    => 'ner_cause'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ner_appl, ner_id')||') a)'
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
  END get_paged_errors;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit_domains(po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ud_domain_id unit_domain_id
            ,ud_domain_name unit_domain_name
            ,ud_text unit_domain_desc 
       FROM nm_unit_domains
       ORDER BY ud_domain_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit_domain(pi_unit_domain   IN     nm_unit_domains.ud_domain_id%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ud_domain_id unit_domain_id
            ,ud_domain_name unit_domain_name
            ,ud_text unit_domain_desc 
       FROM nm_unit_domains
      WHERE ud_domain_id = pi_unit_domain
      ORDER BY ud_domain_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit_domain;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_unit_domains(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT ud_domain_id   unit_domain_id
                                                   ,ud_domain_name unit_domain_name
                                                   ,ud_text        unit_domain_desc 
                                              FROM nm_unit_domains'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT unit_domain_id
                                                  ,unit_domain_name
                                                  ,unit_domain_desc'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_domain_id'
                                ,pi_query_col    => 'ud_domain_id' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_domain_name'
                                ,pi_query_col    => 'ud_domain_name' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_domain_desc'
                                ,pi_query_col    => 'ud_text' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);                                
      --
      --<Repeat for each column that should allow filtering>
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ud_domain_id')||') a)'
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
  END get_paged_unit_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_units(pi_unit_domain   IN     nm_units.un_domain_id%TYPE
                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor   OUT sys_refcursor
                     ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT un_domain_id    unit_domain_id
            ,un_unit_id      unit_id
            ,un_unit_name    unit_name 
            ,un_format_mask  unit_format_mask 
       FROM nm_units
      WHERE un_domain_id = pi_unit_domain
      ORDER BY un_domain_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit(pi_unit_domain   IN     nm_units.un_domain_id%TYPE
                    ,pi_unit_id       IN     nm_units.un_unit_id%TYPE
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor
                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT un_domain_id    unit_domain_id
            ,un_unit_id      unit_id
            ,un_unit_name    unit_name 
            ,un_format_mask  unit_format_mask 
       FROM nm_units
      WHERE un_domain_id = pi_unit_domain
        AND un_unit_id   = pi_unit_id
      ORDER BY un_domain_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_units(pi_unit_domain      IN  nm_units.un_domain_id%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT un_domain_id    unit_domain_id
                                                   ,un_unit_id      unit_id
                                                   ,un_unit_name    unit_name 
                                                   ,un_format_mask  unit_format_mask 
                                              FROM nm_units
                                             WHERE un_domain_id = :pi_unit_domain'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT unit_domain_id
                                                  ,unit_id
                                                  ,unit_name
                                                  ,unit_format_mask'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_domain_id'
                                ,pi_query_col    => 'un_domain_id' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_id'
                                ,pi_query_col    => 'un_unit_id' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_name'
                                ,pi_query_col    => 'un_unit_name' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);                                
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'unit_format_mask'
                                ,pi_query_col    => 'un_format_mask' --can be null if the same as pi_cursor_col
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);  
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'un_domain_id')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_unit_domain 
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_unit_domain 
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
  END get_paged_units;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit_conversions(pi_unit_id       IN     nm_units.un_unit_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
        SELECT uc_unit_id_in                         unit_in_id
              ,uc_unit_id_out                        unit_out_id
              ,(SELECT nvl(un_unit_name,' ') FROM nm_units WHERE un_unit_id =uc_unit_id_out) unit_out_name
              ,uc_function                           unit_function
              ,uc_conversion                         unit_conversion
              ,uc_conversion_factor                  unit_conversion_factor
         FROM nm_unit_conversions
        WHERE uc_unit_id_in = pi_unit_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit_conversions;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit_conversion(pi_unit_in       IN     nm_units.un_unit_id%TYPE
                               ,pi_unit_out      IN     nm_units.un_unit_id%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
    --
  BEGIN
    --
    OPEN po_cursor FOR
        SELECT uc_unit_id_in                         unit_in_id
              ,uc_unit_id_out                        unit_out_id
              ,(SELECT nvl(un_unit_name,' ') FROM nm_units WHERE un_unit_id =uc_unit_id_out) unit_out_name
              ,uc_function                           unit_function
              ,uc_conversion                         unit_conversion
              ,uc_conversion_factor                  unit_conversion_factor
         FROM nm_unit_conversions
        WHERE uc_unit_id_in  = pi_unit_in
          AND uc_unit_id_out = pi_unit_out;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit_conversion;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_add_unit_conversions(pi_unit_domain   IN     nm_unit_domains.ud_domain_id%TYPE
                                    ,pi_unit_id       IN     nm_units.un_unit_id%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
        SELECT un_domain_id    unit_domain_id
              ,un_unit_id      unit_id
              ,un_unit_name    unit_name 
              ,un_format_mask  unit_format_mask 
         FROM nm_units
        WHERE un_domain_id = pi_unit_domain
          AND un_unit_id != pi_unit_id
          AND NOT EXISTS (SELECT uc_unit_id_out
                           FROM nm_unit_conversions
                          WHERE uc_unit_id_in = pi_unit_id
                            AND uc_unit_id_out = un_unit_id)
       ORDER BY un_domain_id, un_unit_id ;    
       --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_add_unit_conversions;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_default_unit_conversion(pi_unit_conv_function   IN     nm_unit_conversions.uc_function%TYPE
                                       ,pi_unit_conv_factor     IN     nm_unit_conversions.uc_conversion_factor%TYPE
                                       ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor          OUT sys_refcursor
                                       ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
  	IF pi_unit_conv_factor IS NULL 
     OR pi_unit_conv_function IS NULL THEN
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 26);
      --
  	END IF;  
    --
    OPEN po_cursor FOR
      SELECT nm3unit.get_function_from_factor(p_function_name => pi_unit_conv_function
                                             ,p_factor        => pi_unit_conv_factor)
        FROM dual;  
       --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_default_unit_conversion;
    
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_domain(pi_domain           IN      hig_domains.hdo_domain%TYPE
                         ,pi_title            IN      hig_domains.hdo_title%TYPE
                         ,pi_product          IN      hig_domains.hdo_product%TYPE
                         ,pi_code_length      IN      hig_domains.hdo_code_length%TYPE
                         ,po_message_severity     OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor       OUT sys_refcursor)
    IS
    --
    lv_max_code_length NUMBER := 20;
    --
  BEGIN
    --
    IF pi_product IS NOT NULL THEN
      --
      IF product_exists(pi_product => pi_product) = 'N' THEN   
        --
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);
        --
      END IF;
      --
    END IF;
    --
    IF pi_code_length > lv_max_code_length THEN
      --
      hig.raise_ner(pi_appl => 'HIG'
                   ,pi_id   => 30); 
      --
    END IF;
    --
    IF domain_exists(pi_domain => pi_domain) = 'Y' THEN   
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 3); 
      --
    END IF;
    --
    INSERT 
      INTO hig_domains 
           (hdo_domain
           ,hdo_title
           ,hdo_product
           ,hdo_code_length)
    VALUES (UPPER(pi_domain)
           ,pi_title
           ,pi_product
           ,pi_code_length);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_code(pi_seq              IN     hig_codes.hco_seq%TYPE
                       ,pi_domain           IN     hig_codes.hco_domain%TYPE
                       ,pi_code             IN     hig_codes.hco_code%TYPE
                       ,pi_meaning          IN     hig_codes.hco_meaning%TYPE
                       ,pi_system           IN     hig_codes.hco_system%TYPE
                       ,pi_start_date       IN     hig_codes.hco_start_date%TYPE
                       ,pi_end_date         IN     hig_codes.hco_end_date%TYPE
                       ,po_message_severity    OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor      OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    IF code_exists(pi_domain => pi_domain
                  ,pi_code   => pi_code) = 'Y' THEN      
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 3);
      --
    END IF;
    --
    IF pi_system NOT IN ('Y','N') THEN
      --
      hig.raise_ner(pi_appl => 'HIG'
                   ,pi_id   => 1);
      --
    END IF;
    --
    /*
    ||check value length does not exceed domain value
    */
    check_code_value_length(pi_domain => pi_domain
                           ,pi_code   => pi_code);
    --
    INSERT
      INTO hig_codes
           (hco_seq
           ,hco_domain
           ,hco_code
           ,hco_meaning
           ,hco_system
           ,hco_start_date
           ,hco_end_date)
    VALUES (pi_seq
           ,UPPER(pi_domain)
           ,UPPER(pi_code)
           ,pi_meaning
           ,pi_system
           ,TRUNC(pi_start_date)
           ,TRUNC(pi_end_date));
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_code;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_user_option(pi_user_id          IN     hig_user_options.huo_hus_user_id%TYPE
                              ,pi_option_id        IN     hig_user_options.huo_id%TYPE
                              ,pi_value            IN     hig_user_options.huo_value%TYPE
                              ,po_message_severity    OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor      OUT sys_refcursor)
    IS
    --
    lv_exists hig_user_options.huo_hus_user_id%TYPE;
    --
  BEGIN
    --
    /*
    || Check no user option exists, if it does then error
    */
    BEGIN
      --
      SELECT huo_hus_user_id
        INTO lv_exists
        FROM hig_user_options
       WHERE huo_hus_user_id = pi_user_id
         AND huo_id = pi_option_id;
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 432);
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        null;
        --
    END;
    --
    /*
    ||check value length does not exceed prod option length and meets prod option criteria
    */
    validate_option_value(pi_option_id => pi_option_id
                         ,pi_value     => pi_value); 
    --
    hig.set_useopt (pi_huo_hus_user_id => pi_user_id
                   ,pi_huo_id          => UPPER(pi_option_id)
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
  END create_user_option;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_unit_domain(pi_unit_domain_name   IN      nm_unit_domains.ud_domain_name%TYPE
                              ,pi_unit_domain_text   IN      nm_unit_domains.ud_text%TYPE
                              ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
    lv_unit_domain_id nm_unit_domains.ud_domain_id%TYPE := nm3unit.get_next_ud_domain_id;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Domain name'
                    ,pi_parameter_value => pi_unit_domain_name);
    --
    validate_notnull(pi_parameter_desc  => 'Domain text'
                    ,pi_parameter_value => pi_unit_domain_text);

    --    
    INSERT 
      INTO nm_unit_domains 
           (ud_domain_id
           ,ud_domain_name
           ,ud_text)
    VALUES (lv_unit_domain_id
           ,UPPER(pi_unit_domain_name)
           ,UPPER(pi_unit_domain_text));
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_unit_domain;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_unit(pi_unit_domain_id     IN      nm_units.un_domain_id%TYPE
                       ,pi_unit_name          IN      nm_units.un_unit_name%TYPE
                       ,pi_unit_format_mask   IN      nm_units.un_format_mask%TYPE
                       ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
    lv_unit_id nm_unit_domains.ud_domain_id%TYPE := nm3unit.get_next_unit_id;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Domain'
                    ,pi_parameter_value => pi_unit_domain_id);
    --
    validate_notnull(pi_parameter_desc  => 'Unit name'
                    ,pi_parameter_value => pi_unit_name);
    --
    validate_notnull(pi_parameter_desc  => 'Unit format mask'
                    ,pi_parameter_value => pi_unit_format_mask);
    --
    /*
    ||Check domain exists
    */
    IF unit_domain_exists (pi_unit_domain_id => pi_unit_domain_id) = 'N' THEN
      --
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 16
                   ,pi_supplementary_info => 'Unit Domain does not exist');         
      --
    END IF;
    --
    INSERT 
      INTO nm_units 
           (un_unit_id
           ,un_unit_name
           ,un_format_mask
           ,un_domain_id)
    VALUES (lv_unit_id
           ,pi_unit_name
           ,pi_unit_format_mask
           ,pi_unit_domain_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_unit;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_unit_conversion(pi_unit_conv_id_in         IN      nm_unit_conversions.uc_unit_id_in%TYPE
                                  ,pi_unit_conv_id_out        IN      nm_unit_conversions.uc_unit_id_out%TYPE
                                  ,pi_unit_conv_function      IN      nm_unit_conversions.uc_function%TYPE
                                  ,pi_unit_conv_conversion    IN      nm_unit_conversions.uc_conversion%TYPE
                                  ,pi_unit_conv_factor        IN      nm_unit_conversions.uc_conversion_factor%TYPE
                                  ,po_message_severity           OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor             OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    IF unit_conversion_exists (pi_unit_conv_id_in      => pi_unit_conv_id_in
                              ,pi_unit_conv_id_out => pi_unit_conv_id_out) = 'Y' THEN
      --
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 64);
      --
    END IF;
    --
    validate_notnull(pi_parameter_desc  => 'Unit'
                    ,pi_parameter_value => pi_unit_conv_id_in);
    --
    validate_notnull(pi_parameter_desc  => 'Unit out'
                    ,pi_parameter_value => pi_unit_conv_id_out);
    --
    validate_notnull(pi_parameter_desc  => 'Function'
                    ,pi_parameter_value => pi_unit_conv_function);
    --
    validate_notnull(pi_parameter_desc  => 'Conversion'
                    ,pi_parameter_value => pi_unit_conv_conversion);
    --
    validate_notnull(pi_parameter_desc  => 'Factor'
                    ,pi_parameter_value => pi_unit_conv_factor);
    --
    IF unit_exists(pi_unit_id => pi_unit_conv_id_in) = 'N' THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 22
                     ,pi_supplementary_info => 'Unit does not exist');    
    END IF;
    --
    IF unit_exists(pi_unit_id => pi_unit_conv_id_out) = 'N'  THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 29
                     ,pi_supplementary_info => 'Unit does not exist');   
    END IF;
    --
    gen_unit_conversion_fun(pi_unit_conv_function     => UPPER(pi_unit_conv_function)
                           ,pi_unit_conv_conversion   => pi_unit_conv_conversion);
    --
    INSERT 
      INTO nm_unit_conversions
           (uc_unit_id_in
           ,uc_unit_id_out
           ,uc_function
           ,uc_conversion
           ,uc_conversion_factor)
    VALUES (pi_unit_conv_id_in
           ,pi_unit_conv_id_out
           ,UPPER(pi_unit_conv_function)
           ,pi_unit_conv_conversion
           ,pi_unit_conv_factor);
    --                               
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_unit_conversion;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_code(pi_domain               IN     hig_codes.hco_domain%TYPE
                       ,pi_old_code             IN     hig_codes.hco_code%TYPE
                       ,pi_old_meaning          IN     hig_codes.hco_meaning%TYPE
                       ,pi_old_system           IN     hig_codes.hco_system%TYPE
                       ,pi_old_seq              IN     hig_codes.hco_seq%TYPE
                       ,pi_old_start_date       IN     hig_codes.hco_start_date%TYPE
                       ,pi_old_end_date         IN     hig_codes.hco_end_date%TYPE
                       ,pi_new_code             IN     hig_codes.hco_code%TYPE
                       ,pi_new_meaning          IN     hig_codes.hco_meaning%TYPE
                       ,pi_new_system           IN     hig_codes.hco_system%TYPE
                       ,pi_new_seq              IN     hig_codes.hco_seq%TYPE
                       ,pi_new_start_date       IN     hig_codes.hco_start_date%TYPE
                       ,pi_new_end_date         IN     hig_codes.hco_end_date%TYPE
                       ,po_message_severity        OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lr_db_hco_rec    hig_codes%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_domain IN hig_codes.hco_domain%TYPE
                        ,pi_code   IN hig_codes.hco_code%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_hco_rec
        FROM hig_codes
       WHERE hco_domain = pi_domain
         AND hco_code = pi_code
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Code does not exist');
      --      
    END get_db_rec;
    --
  BEGIN
    --
    IF pi_old_system = 'Y' THEN
      --
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 85
                   ,pi_supplementary_info => 'System values cannot be updated');
      -- 
    END IF;
    --
    IF domain_exists(pi_domain => pi_domain) ='N' THEN
      --
      hig.raise_ner(pi_appl => 'HIG'
                   ,pi_id   => 109);
      -- 
    END IF;
    --
    IF pi_new_system NOT IN ('Y','N') THEN
      --
      hig.raise_ner(pi_appl => 'HIG'
                   ,pi_id   => 1);
      --
    END IF;
    /*
    ||check value length does not exceed domain value
    */
    check_code_value_length(pi_domain => pi_domain
                           ,pi_code   => pi_new_code);    
    --    
    get_db_rec(pi_domain => pi_domain
              ,pi_code   => pi_old_code);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_hco_rec.hco_code != pi_old_code
     OR (lr_db_hco_rec.hco_code IS NULL AND pi_old_code IS NOT NULL)
     OR (lr_db_hco_rec.hco_code IS NOT NULL AND pi_old_code IS NULL)
     --meaning
     OR (lr_db_hco_rec.hco_meaning != pi_old_meaning)
     OR (lr_db_hco_rec.hco_meaning IS NULL AND pi_old_meaning IS NOT NULL)
     OR (lr_db_hco_rec.hco_meaning IS NOT NULL AND pi_old_meaning IS NULL)
     --system
     OR (lr_db_hco_rec.hco_system != pi_old_system)
     OR (lr_db_hco_rec.hco_system IS NULL AND pi_old_system IS NOT NULL)
     OR (lr_db_hco_rec.hco_system IS NOT NULL AND pi_old_system IS NULL)
     --seq
     OR (lr_db_hco_rec.hco_seq != pi_old_seq)
     OR (lr_db_hco_rec.hco_seq IS NULL AND pi_old_seq IS NOT NULL)
     OR (lr_db_hco_rec.hco_seq IS NOT NULL AND pi_old_seq IS NULL)     
     --start date
     OR (lr_db_hco_rec.hco_start_date != pi_old_start_date)
     OR (lr_db_hco_rec.hco_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_hco_rec.hco_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --end date
     OR (lr_db_hco_rec.hco_end_date != pi_old_end_date)
     OR (lr_db_hco_rec.hco_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_hco_rec.hco_end_date IS NOT NULL AND pi_old_end_date IS NULL)     
     --=
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_code != pi_new_code
       OR (pi_old_code IS NULL AND pi_new_code IS NOT NULL)
       OR (pi_old_code IS NOT NULL AND pi_new_code IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_meaning != pi_new_meaning
       OR (pi_old_meaning IS NULL AND pi_new_meaning IS NOT NULL)
       OR (pi_old_meaning IS NOT NULL AND pi_new_meaning IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_system != pi_new_system
       OR (pi_old_system IS NULL AND pi_new_system IS NOT NULL)
       OR (pi_old_system IS NOT NULL AND pi_new_system IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_seq != pi_new_seq
       OR (pi_old_seq IS NULL AND pi_new_seq IS NOT NULL)
       OR (pi_old_seq IS NOT NULL AND pi_new_seq IS NULL)
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
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE hig_codes
           SET hco_code        = UPPER(pi_new_code)
              ,hco_meaning     = pi_new_meaning
              ,hco_system      = pi_new_system
              ,hco_seq         = pi_new_seq
              ,hco_start_date  = TRUNC(pi_new_start_date)
              ,hco_end_date    = TRUNC(pi_new_end_date)
         WHERE hco_domain = pi_domain
           AND hco_code   = pi_old_code;
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
  END update_code;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_product_option(pi_option              IN     hig_option_values.hov_id%TYPE
                                 ,pi_old_value           IN     hig_option_values.hov_value%TYPE
                                 ,pi_new_value           IN     hig_option_values.hov_value%TYPE
                                 ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lr_db_hov_rec    hig_option_values%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_option IN hig_option_values.hov_id%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_hov_rec
        FROM hig_option_values
       WHERE hov_id = pi_option
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Product Option Value does not exist');
      --      
    END get_db_rec;
    --
  BEGIN
    --
    /*
    ||if there is a value then check it has not been updated by another user.
    */
    IF pi_old_value IS NOT NULL THEN
      /*
      ||get db values
      */
      get_db_rec(pi_option => pi_option);
      --
      IF lr_db_hov_rec.hov_value != pi_old_value
        OR (lr_db_hov_rec.hov_value IS NULL AND pi_old_value IS NOT NULL)
        OR (lr_db_hov_rec.hov_value IS NOT NULL AND pi_old_value IS NULL)
        --=
        THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
      END IF;
    END IF;
    /*
    ||Compare old with New
    */
    IF pi_old_value != pi_new_value
     OR (pi_old_value IS NULL AND pi_new_value IS NOT NULL)
     OR (pi_old_value IS NOT NULL AND pi_new_value IS NULL)
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
      IF pi_new_value IS NOT NULL
       THEN
          validate_option_value(pi_option_id => pi_option
                               ,pi_value     => pi_new_value);
      END IF;
      --
      /*
      ||delete and insert as per the instead of clause used in the form as apposed to update.S
      */
      hig.set_opt (pi_hov_id          => pi_option
                  ,pi_hov_value       => pi_new_value);      
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
  END update_product_option;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_user_option(pi_user_id             IN     hig_user_options.huo_hus_user_id%TYPE
                              ,pi_option_id           IN     hig_user_options.huo_id%TYPE
                              ,pi_old_value           IN     hig_user_options.huo_value%TYPE
                              ,pi_new_value           IN     hig_user_options.huo_value%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lr_db_huo_rec    hig_user_options%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_user_id   IN hig_user_options.huo_hus_user_id%TYPE
                        ,pi_option_id IN hig_user_options.huo_id%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_huo_rec
        FROM hig_user_options
       WHERE huo_hus_user_id = pi_user_id
         AND huo_id = pi_option_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'User option does not exist');
      --      
    END get_db_rec;
    --
  BEGIN
    --    
    get_db_rec(pi_user_id   => pi_user_id
              ,pi_option_id => pi_option_id);
    --          
    /*
    ||Compare old with DB
    */
    IF lr_db_huo_rec.huo_value != pi_old_value
     OR (lr_db_huo_rec.huo_value IS NULL AND pi_old_value IS NOT NULL)
     OR (lr_db_huo_rec.huo_value IS NOT NULL AND pi_old_value IS NULL)
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_value != pi_new_value
       OR (pi_old_value IS NULL AND pi_new_value IS NOT NULL)
       OR (pi_old_value IS NOT NULL AND pi_new_value IS NULL)
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
        /*
        ||check value length does not exceed prod option length and meets prod option criteria
        */
        validate_option_value(pi_option_id => pi_option_id
                             ,pi_value     => pi_new_value); 
                             
        /*UPDATE hig_user_options
           SET huo_value  = pi_new_value
         WHERE huo_hus_user_id = pi_user_id
           AND huo_id   = pi_option_id;
        */
        --

        hig.set_useopt (pi_huo_hus_user_id => pi_user_id
                       ,pi_huo_id          => pi_option_id
                       ,pi_huo_value       => pi_new_value);
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
  END update_user_option;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_error(pi_product_id       IN     nm_errors.ner_appl%TYPE
                        ,pi_error_id         IN     nm_errors.ner_id%TYPE
                        ,pi_old_error_text   IN     nm_errors.ner_descr%TYPE
                        ,pi_old_error_cause  IN     nm_errors.ner_cause%TYPE
                        ,pi_new_error_text   IN     nm_errors.ner_descr%TYPE
                        ,pi_new_error_cause  IN     nm_errors.ner_cause%TYPE                         
                        ,po_message_severity    OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor      OUT sys_refcursor)
    IS
    --
    lr_db_ner_rec    nm_errors%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_product_id       IN     nm_errors.ner_appl%TYPE
                        ,pi_error_id         IN     nm_errors.ner_id%TYPE)
      IS
    BEGIN
      --
    SELECT * 
      INTO lr_db_ner_rec
      FROM nm_errors
     WHERE ner_appl = pi_product_id
       AND ner_id = pi_error_id
       FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Error ID does not exist');
      --      
    END get_db_rec;
  BEGIN
    --
    get_db_rec(pi_product_id  => pi_product_id
              ,pi_error_id    => pi_error_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_ner_rec.ner_descr != pi_old_error_text
     OR (lr_db_ner_rec.ner_descr IS NULL AND pi_old_error_text IS NOT NULL)
     OR (lr_db_ner_rec.ner_descr IS NOT NULL AND pi_old_error_text IS NULL)
     --error cause
     OR (lr_db_ner_rec.ner_cause != pi_old_error_cause)
     OR (lr_db_ner_rec.ner_cause IS NULL AND pi_old_error_cause IS NOT NULL)
     OR (lr_db_ner_rec.ner_cause IS NOT NULL AND pi_old_error_cause IS NULL)
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_error_text != pi_new_error_text
       OR (pi_old_error_text IS NULL AND pi_new_error_text IS NOT NULL)
       OR (pi_old_error_text IS NOT NULL AND pi_new_error_text IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_error_cause != pi_new_error_cause
       OR (pi_old_error_cause IS NULL AND pi_new_error_cause IS NOT NULL)
       OR (pi_old_error_cause IS NOT NULL AND pi_new_error_cause IS NULL)
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
        UPDATE nm_errors
           SET ner_descr = pi_new_error_text
              ,ner_cause = pi_new_error_cause
         WHERE ner_appl = pi_product_id
           AND ner_id = pi_error_id;
        --           
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF; 
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_error;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_unit_domain(pi_unit_domain_id        IN     nm_unit_domains.ud_domain_id%TYPE
                              ,pi_old_name              IN     nm_unit_domains.ud_domain_name%TYPE
                              ,pi_new_name              IN     nm_unit_domains.ud_domain_name%TYPE
                              ,pi_old_desc              IN     nm_unit_domains.ud_text%TYPE
                              ,pi_new_desc              IN     nm_unit_domains.ud_text%TYPE                              
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lr_db_ud_rec    nm_unit_domains%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_unit_domain_id   IN nm_unit_domains.ud_domain_id%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_ud_rec
        FROM nm_unit_domains
       WHERE ud_domain_id = pi_unit_domain_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Unit Domain does not exist');
      --      
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Unit Name'
                    ,pi_parameter_value => pi_new_name);
    --
    validate_notnull(pi_parameter_desc  => 'Unit Description'
                    ,pi_parameter_value => pi_new_desc);
    --    
    get_db_rec(pi_unit_domain_id   => pi_unit_domain_id);
    --          
    /*
    ||Compare old with DB
    */
    IF lr_db_ud_rec.ud_domain_name != pi_old_name
     OR (lr_db_ud_rec.ud_domain_name IS NULL AND pi_old_name IS NOT NULL)
     OR (lr_db_ud_rec.ud_domain_name IS NOT NULL AND pi_old_name IS NULL)
     --unit domain desc
     OR (lr_db_ud_rec.ud_text != pi_old_desc)
     OR (lr_db_ud_rec.ud_text IS NULL AND pi_old_desc IS NOT NULL)
     OR (lr_db_ud_rec.ud_text IS NOT NULL AND pi_old_desc IS NULL)
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_name != pi_new_name
       OR (pi_old_name IS NULL AND pi_new_name IS NOT NULL)
       OR (pi_old_name IS NOT NULL AND pi_new_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_desc != pi_new_desc
       OR (pi_old_desc IS NULL AND pi_new_desc IS NOT NULL)
       OR (pi_old_desc IS NOT NULL AND pi_new_desc IS NULL)
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
        UPDATE nm_unit_domains
           SET ud_domain_name  = UPPER(pi_new_name)
              ,ud_text         = UPPER(pi_new_desc)
         WHERE ud_domain_id = pi_unit_domain_id;
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
  END update_unit_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_unit(pi_unit_id               IN     nm_units.un_unit_id%TYPE
                       ,pi_old_name              IN     nm_units.un_unit_name%TYPE
                       ,pi_new_name              IN     nm_units.un_unit_name%TYPE
                       ,pi_old_format_mask       IN     nm_units.un_format_mask%TYPE
                       ,pi_new_format_mask       IN     nm_units.un_format_mask%TYPE                              
                       ,po_message_severity        OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lr_db_un_rec    nm_units%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_unit_id          IN nm_units.un_unit_id%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_un_rec
        FROM nm_units
       WHERE un_unit_id   = pi_unit_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Unit does not exist');
      --      
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Unit Name'
                    ,pi_parameter_value => pi_new_name);
    --
    validate_notnull(pi_parameter_desc  => 'Unit format mask'
                    ,pi_parameter_value => pi_new_format_mask);                
    --    
    get_db_rec(pi_unit_id          => pi_unit_id);
    --          
    /*
    ||Compare old with DB
    */
    IF lr_db_un_rec.un_unit_name != pi_old_name
     OR (lr_db_un_rec.un_unit_name IS NULL AND pi_old_name IS NOT NULL)
     OR (lr_db_un_rec.un_unit_name IS NOT NULL AND pi_old_name IS NULL)
     --format mask
     OR (lr_db_un_rec.un_format_mask != pi_old_format_mask)
     OR (lr_db_un_rec.un_format_mask IS NULL AND pi_old_format_mask IS NOT NULL)
     OR (lr_db_un_rec.un_format_mask IS NOT NULL AND pi_old_format_mask IS NULL)
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_name != pi_new_name
       OR (pi_old_name IS NULL AND pi_new_name IS NOT NULL)
       OR (pi_old_name IS NOT NULL AND pi_new_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_format_mask != pi_new_format_mask
       OR (pi_old_format_mask IS NULL AND pi_new_format_mask IS NOT NULL)
       OR (pi_old_format_mask IS NOT NULL AND pi_new_format_mask IS NULL)
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
        UPDATE nm_units
           SET un_unit_name    = pi_new_name
              ,un_format_mask  = pi_new_format_mask
         WHERE un_unit_id   = pi_unit_id; 
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
  END update_unit;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_unit_conversion(pi_unit_id_in            IN     nm_unit_conversions.uc_unit_id_in%TYPE
                                  ,pi_unit_id_out           IN     nm_unit_conversions.uc_unit_id_out%TYPE
                                  ,pi_old_function          IN     nm_unit_conversions.uc_function%TYPE
                                  ,pi_new_function          IN     nm_unit_conversions.uc_function%TYPE
                                  ,pi_old_conversion        IN     nm_unit_conversions.uc_conversion%TYPE
                                  ,pi_new_conversion        IN     nm_unit_conversions.uc_conversion%TYPE
                                  ,pi_old_conversion_factor IN     nm_unit_conversions.uc_conversion_factor%TYPE
                                  ,pi_new_conversion_factor IN     nm_unit_conversions.uc_conversion_factor%TYPE                                      
                                  ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor           OUT sys_refcursor)
    IS
    --
    lr_db_uc_rec     nm_unit_conversions%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec(pi_unit_id_in   IN nm_unit_conversions.uc_unit_id_in%TYPE
                        ,pi_unit_id_out  IN nm_unit_conversions.uc_unit_id_out%TYPE)
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_uc_rec
        FROM nm_unit_conversions
       WHERE uc_unit_id_in  = pi_unit_id_in
         AND uc_unit_id_out = pi_unit_id_out
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Unit Conversion does not exist');
      --      
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Function'
                    ,pi_parameter_value => pi_new_function);
    --
    validate_notnull(pi_parameter_desc  => 'Conversion'
                    ,pi_parameter_value => pi_new_conversion);                
    --
    validate_notnull(pi_parameter_desc  => 'Conversion factod'
                    ,pi_parameter_value => pi_new_conversion_factor);
    -- 
    get_db_rec(pi_unit_id_in   => pi_unit_id_in
              ,pi_unit_id_out  => pi_unit_id_out);
    --          
    /*
    ||Compare old with DB
    */
    IF lr_db_uc_rec.uc_function != pi_old_function
     OR (lr_db_uc_rec.uc_function IS NULL AND pi_old_function IS NOT NULL)
     OR (lr_db_uc_rec.uc_function IS NOT NULL AND pi_old_function IS NULL)
     --conversion
     OR (lr_db_uc_rec.uc_conversion != pi_old_conversion)
     OR (lr_db_uc_rec.uc_conversion IS NULL AND pi_old_conversion IS NOT NULL)
     OR (lr_db_uc_rec.uc_conversion IS NOT NULL AND pi_old_conversion IS NULL)
     --conversion factor
     OR (lr_db_uc_rec.uc_conversion_factor != pi_old_conversion_factor)
     OR (lr_db_uc_rec.uc_conversion_factor IS NULL AND pi_old_conversion_factor IS NOT NULL)
     OR (lr_db_uc_rec.uc_conversion_factor IS NOT NULL AND pi_old_conversion_factor IS NULL)
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_function != pi_new_function
       OR (pi_old_function IS NULL AND pi_new_function IS NOT NULL)
       OR (pi_old_function IS NOT NULL AND pi_new_function IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_conversion != pi_new_conversion
       OR (pi_old_conversion IS NULL AND pi_new_conversion IS NOT NULL)
       OR (pi_old_conversion IS NOT NULL AND pi_new_conversion IS NULL)
       THEN
         lv_upd := 'Y';
      END IF; 
      --
      IF pi_old_conversion_factor != pi_new_conversion_factor
       OR (pi_old_conversion_factor IS NULL AND pi_new_conversion_factor IS NOT NULL)
       OR (pi_old_conversion_factor IS NOT NULL AND pi_new_conversion_factor IS NULL)
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
        BEGIN
          --
          gen_unit_conversion_fun(pi_unit_conv_function   => UPPER(pi_new_function)
                                 ,pi_unit_conv_conversion => pi_new_conversion);
          --
        EXCEPTION
          WHEN others
           THEN
              /*
              ||if function create fails then reestblish old function but return error to user.
              */
              BEGIN
                gen_unit_conversion_fun(pi_unit_conv_function   => UPPER(pi_old_function)
                                       ,pi_unit_conv_conversion => pi_old_conversion);
              EXCEPTION
                WHEN others
                 THEN
                   null;
                   /*
                   ||attempt to resetablish old function failed but we report new function failure.
                   */
              END;
              --
              RAISE;
              --
        END;      
        --
        UPDATE nm_unit_conversions
           SET uc_function          = UPPER(pi_new_function)
              ,uc_conversion        = pi_new_conversion
              ,uc_conversion_factor = pi_new_conversion_factor
         WHERE uc_unit_id_in  = pi_unit_id_in
           AND uc_unit_id_out = pi_unit_id_out;
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
        --           
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_unit_conversion;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_domain(pi_domain            IN      hig_domains.hdo_domain%TYPE
                         ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
    CURSOR c_domain_codes is
    SELECT COUNT(hco_domain)
      FROM hig_codes
     WHERE hco_domain = pi_domain;
    --
    lv_cnt  NUMBER;
    --
  BEGIN
    --
    IF domain_exists(pi_domain => pi_domain) <> 'Y' THEN 
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 26);
    END IF;
    --
    OPEN  c_domain_codes;
    FETCH c_domain_codes 
     INTO lv_cnt;
    CLOSE c_domain_codes;
    
    IF lv_cnt = 0 THEN
      --
      DELETE 
        FROM hig_domains
       WHERE hdo_domain = pi_domain;
      -- 
    ELSE
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 2);
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
  END delete_domain;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_unit_domain(pi_unit_domain_id    IN      nm_unit_domains.ud_domain_id%TYPE
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
    CURSOR c_units is
    SELECT COUNT(un_unit_id)
      FROM nm_units
     WHERE un_domain_id = pi_unit_domain_id;
    --
    lv_cnt  NUMBER;
    --
  BEGIN
    --
    IF unit_domain_exists (pi_unit_domain_id => pi_unit_domain_id) <> 'Y' THEN 
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 26);
    END IF;
    --
    OPEN  c_units;
    FETCH c_units 
     INTO lv_cnt;
    CLOSE c_units;
    
    IF lv_cnt = 0 THEN
      --
      DELETE 
        FROM nm_unit_domains
       WHERE ud_domain_id = pi_unit_domain_id;
      -- 
    ELSE
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 2);
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
  END delete_unit_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_unit(pi_unit_id           IN      nm_units.un_unit_id%TYPE
                       ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
    CURSOR c_unit_conversions IS 
    SELECT COUNT(uc_unit_id_in)
      FROM nm_unit_conversions
     WHERE uc_unit_id_in = pi_unit_id 
        OR uc_unit_id_out = pi_unit_id;
    --
    lv_cnt  NUMBER;
    --
  BEGIN
    --
    IF unit_exists (pi_unit_id => pi_unit_id) <> 'Y' THEN
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 26);
    END IF;
    --
    OPEN  c_unit_conversions;
    FETCH c_unit_conversions 
     INTO lv_cnt;
    CLOSE c_unit_conversions;
    
    IF lv_cnt = 0 THEN
      --
      DELETE 
        FROM nm_units
       WHERE un_unit_id = pi_unit_id;
      -- 
    ELSE
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 2);
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
  END delete_unit;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_user_option(pi_user_id          IN       hig_user_options.huo_hus_user_id%TYPE
                              ,pi_option_id        IN       hig_user_options.huo_id%TYPE
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    IF user_option_exists (pi_user_id    => pi_user_id      
                          ,pi_option_id  => pi_option_id) <> 'Y' 
     THEN
       hig.raise_ner(pi_appl => 'NET'
                    ,pi_id   => 26);
    END IF;
    --
    DELETE 
      FROM hig_user_options
     WHERE huo_hus_user_id = pi_user_id
       AND huo_id = pi_option_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_user_option;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_unit_conversion(pi_unit_conv_id_in   IN      nm_unit_conversions.uc_unit_id_in%TYPE
                                  ,pi_unit_conv_id_out  IN      nm_unit_conversions.uc_unit_id_out%TYPE
                                  ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    IF unit_conversion_exists (pi_unit_conv_id_in  => pi_unit_conv_id_in
                              ,pi_unit_conv_id_out => pi_unit_conv_id_out) <> 'Y' THEN
      --
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 26);
      --
    END IF;   
    --
    DELETE 
      FROM nm_unit_conversions
     WHERE uc_unit_id_in = pi_unit_conv_id_in 
       AND uc_unit_id_out = pi_unit_conv_id_out;
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_unit_conversion;
  

  --
END awlrs_metaref_api;