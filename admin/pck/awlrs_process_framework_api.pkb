CREATE OR REPLACE PACKAGE BODY awlrs_process_framework_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_process_framework_api.pkb-arc   1.6   Aug 10 2020 13:41:52   Barbara.Odriscoll  $
  --       Date into PVCS   : $Date:   Aug 10 2020 13:41:52  $
  --       Module Name      : $Workfile:   awlrs_process_framework_api.pkb  $
  --       Date fetched Out : $Modtime:   Aug 10 2020 13:40:18  $
  --       Version          : $Revision:   1.6  $
  --
  -----------------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated.  All rights reserved.
  -----------------------------------------------------------------------------------
  --
  g_body_sccsid     CONSTANT  VARCHAR2(2000) := '"$Revision:   1.6  $"';
  --
  g_package_name    CONSTANT VARCHAR2 (30) := 'awlrs_theme_api';
  --
  --roles constants
  cv_process_user   CONSTANT VARCHAR2(12) := 'PROCESS_USER';
  cv_process_admin  CONSTANT VARCHAR2(13) := 'PROCESS_ADMIN';
  --
  cv_package        CONSTANT VARCHAR2(7) := 'PACKAGE';
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
  FUNCTION privs_check(pi_role_name  IN  varchar2) RETURN VARCHAR2  
  IS
     lv_exists varchar2(1) := 'N';
  BEGIN
      --
      SELECT  'Y'
      INTO    lv_exists
      FROM    hig_user_roles
      WHERE   hur_role     = pi_role_name
      AND     hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME');
      --
      RETURN lv_exists;     
      -- 
  EXCEPTION
      --
      When No_Data_Found Then
        RETURN lv_exists;
      --    
  END privs_check;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION valid_package_call(pi_code_to_execute   IN   hig_process_types.hpt_what_to_call%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_code_to_execute IS NOT NULL
     THEN 
      SELECT 'Y'
        INTO lv_exists
        FROM dba_procedures
       WHERE (   owner          = UPPER(SYS_CONTEXT('NM3CORE','APPLICATION_OWNER'))
             AND object_type    = cv_package 
             AND object_name    = UPPER(SUBSTR(pi_code_to_execute,1,(INSTR(pi_code_to_execute,'.')) -1))
             AND object_name    NOT IN ('NM3USER','NM3DDL')
             AND procedure_name = UPPER(RTRIM(SUBSTR(pi_code_to_execute,(INSTR(pi_code_to_execute,'.')) +1),';'))
          OR     owner          = 'EXOR_CORE'
             AND object_type    = cv_package 
             AND object_name    = UPPER(SUBSTR(pi_code_to_execute,1,(INSTR(pi_code_to_execute,'.')) -1))
             AND object_name    != 'NM3SECURITY'
             AND procedure_name = UPPER(RTRIM(SUBSTR(pi_code_to_execute,(INSTR(pi_code_to_execute,'.')) +1),';')));
    END IF;     
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END valid_package_call;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION valid_date(pi_date  IN  date) RETURN BOOLEAN  
  IS
     lv_date_ok boolean := FALSE;
  BEGIN
      --
      IF(    pi_date IS NOT NULL
         AND TRUNC(pi_date) >= TRUNC(sysdate)
        )
         THEN 
               lv_date_ok := TRUE;
      END IF; 
      --
      RETURN lv_date_ok;     
      -- 
  EXCEPTION
      --
      When Others Then
        RETURN lv_date_ok;
      --    
  END valid_date;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION frequency_exists(pi_frequency_id  IN  hig_scheduling_frequencies.hsfr_frequency_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_scheduling_frequencies
     WHERE hsfr_frequency_id = pi_frequency_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END frequency_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION frequency_desc_exists(pi_freq_descr   IN   hig_scheduling_frequencies.hsfr_meaning%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_scheduling_frequencies
     WHERE lower(hsfr_meaning) = lower(pi_freq_descr);
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END frequency_desc_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION process_type_exists(pi_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_process_types
     WHERE hpt_process_type_id = pi_process_type_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END process_type_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION process_type_role_exists(pi_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE
                                   ,pi_role             IN      hig_process_type_roles.hptr_role%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_process_type_roles
     WHERE hptr_process_type_id = pi_process_type_id
       AND hptr_role            = pi_role;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END process_type_role_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION process_type_freq_exists(pi_process_type_id IN   hig_process_type_frequencies.hpfr_process_type_id%TYPE
                                   ,pi_frequency_id    IN   hig_process_type_frequencies.hpfr_frequency_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_process_type_frequencies
     WHERE hpfr_process_type_id = pi_process_type_id
       AND hpfr_frequency_id    = pi_frequency_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END process_type_freq_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION process_location_exists(pi_file_type_id     IN      hig_process_type_files.hptf_file_type_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_process_type_files
     WHERE hptf_file_type_id = pi_file_type_id;      
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END process_location_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION file_ext_exists(pi_file_type_id    IN   hig_process_type_file_ext.hpte_file_type_id%TYPE
                          ,pi_file_type_ext   IN   hig_process_type_file_ext.hpte_extension%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_process_type_file_ext
     WHERE hpte_file_type_id = pi_file_type_id
       AND hpte_extension    = pi_file_type_ext;     
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END file_ext_exists;
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_process_types(po_message_severity OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT  sys_refcursor
                             ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpt_process_type_id         process_type_id
          ,hpt_name                    process_name  
          ,hpt_process_limit           limit_
          ,hpt_system                  protected_
          ,hpt_descr                   process_descr 
          ,hpt_what_to_call            code_to_execute
          --,hpt_polling_enabled         polling_enabled 
          --,hpt_polling_ftp_type_id     polling_ftp_id
          --,hpt_polling_ftp_type_descr  polling_ftp_id_descr
          ,hpt_see_in_hig2510          see_in_submission_module
          ,hpt_area_type               area_type  
          ,hpt_area_type_meaning       area_type_descr 
          ,hpt_restartable             restartable  
      FROM hig_process_types_v
    ORDER BY hpt_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_types;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_type(pi_process_type_id  IN      hig_process_types.hpt_process_type_id%TYPE
                            ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor      OUT  sys_refcursor
                            ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpt_process_type_id         process_type_id
          ,hpt_name                    process_name  
          ,hpt_process_limit           limit_
          ,hpt_system                  protected_
          ,hpt_descr                   process_descr 
          ,hpt_what_to_call            code_to_execute
          --,hpt_polling_enabled         polling_enabled 
          --,hpt_polling_ftp_type_id     polling_ftp_id
          --,hpt_polling_ftp_type_descr  polling_ftp_id_descr
          ,hpt_see_in_hig2510          see_in_submission_module
          ,hpt_area_type               area_type  
          ,hpt_area_type_meaning       area_type_descr 
          ,hpt_restartable             restartable
      FROM hig_process_types_v
     WHERE hpt_process_type_id  =  pi_process_type_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_type;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpt_process_type_id         process_type_id
                                                     ,hpt_name                    process_name  
                                                     ,hpt_process_limit           limit_
                                                     ,hpt_system                  protected_
                                                     ,hpt_descr                   process_descr 
                                                     ,hpt_what_to_call            code_to_execute
                                                     --,hpt_polling_enabled         polling_enabled 
                                                     --,hpt_polling_ftp_type_id     polling_ftp_id
                                                     --,hpt_polling_ftp_type_descr  polling_ftp_id_descr
                                                     ,hpt_see_in_hig2510          see_in_submission_module
                                                     ,hpt_area_type               area_type  
                                                     ,hpt_area_type_meaning       area_type_descr 
                                                     ,hpt_restartable             restartable
                                                 FROM hig_process_types_v ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_type_id'
                                                   ||',process_name'
                                                   ||',limit_' 
                                                   ||',protected_'
                                                   ||',process_descr' 
                                                   ||',code_to_execute'
                                                  -- ||',polling_enabled'
                                                  -- ||',polling_ftp_id'
                                                  -- ||',polling_ftp_id_descr'
                                                   ||',see_in_submission_module'
                                                   ||',area_type'
                                                   ||',area_type_descr'
                                                   ||',restartable'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_id'
                                ,pi_query_col    => 'hpt_process_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_name'
                                ,pi_query_col    => 'hpt_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'limit_'
                                ,pi_query_col    => 'hpt_process_limit'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'protected_'
                                ,pi_query_col    => 'hpt_system'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_descr'
                                ,pi_query_col    => 'hpt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'code_to_execute'
                                ,pi_query_col    => 'hpt_what_to_call'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'see_in_submission_module'
                                ,pi_query_col    => 'hpt_see_in_hig2510'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      /*
      awlrs_util.add_column_data(pi_cursor_col   => 'polling_enabled'
                                ,pi_query_col    => 'hpt_polling_enabled'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'polling_ftp_id'
                                ,pi_query_col    => 'hpt_polling_ftp_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'polling_ftp_id_descr'
                                ,pi_query_col    => 'hpt_polling_ftp_type_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      */                          
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'area_type'
                                ,pi_query_col    => 'hpt_area_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'area_type_descr'
                                ,pi_query_col    => 'hpt_area_type_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'restartable'
                                ,pi_query_col    => 'hpt_restartable'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpt_name')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_types;    
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE area_types_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT  sys_refcursor
                         ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpa_area_type     area_type 
          ,hpa_description   area_type_descr
      FROM hig_process_areas
    ORDER BY hpa_description;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END area_types_lov;                          
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_process_type(pi_process_name          IN hig_process_types.hpt_name%TYPE
                               ,pi_limit                 IN hig_process_types.hpt_process_limit%TYPE
                               ,pi_process_descr         IN hig_process_types.hpt_descr%TYPE
                               ,pi_code_to_execute       IN hig_process_types.hpt_what_to_call%TYPE
                               ,pi_see_in_form           IN hig_process_types.hpt_see_in_hig2510%TYPE  
                               ,pi_area_type             IN hig_process_types.hpt_area_type%TYPE
                               ,pi_restartable           IN hig_process_types.hpt_restartable%TYPE
                               --,pi_polling_enabled       IN hig_process_types.hpt_polling_enabled%TYPE
                               --,pi_polling_ftp_type_id   IN hig_process_types.hpt_polling_ftp_type_id%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  lv_rec hig_process_types%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT create_process_type_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Name'
                               ,pi_parameter_value =>  pi_process_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value =>  pi_process_descr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'See In Form'
                               ,pi_parameter_value =>  pi_see_in_form);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Restartable'
                               ,pi_parameter_value =>  pi_restartable);
    --
    IF valid_package_call(pi_code_to_execute  => pi_code_to_execute)  = 'N'
      THEN
         hig.raise_ner(pi_appl               => 'AWLRS'
                      ,pi_id                 => 86
                      ,pi_supplementary_info => pi_code_to_execute);
    END IF;
    --
    /*
    ||insert into hig_process_types.
    */
    lv_rec.hpt_name                  :=  pi_process_name;
    lv_rec.hpt_descr                 :=  pi_process_descr;
    lv_rec.hpt_what_to_call          :=  pi_code_to_execute;
    lv_rec.hpt_process_limit         :=  pi_limit;
    lv_rec.hpt_restartable           :=  pi_restartable;
    lv_rec.hpt_see_in_hig2510        :=  pi_see_in_form;  
    lv_rec.hpt_polling_enabled       :=  'N'; --pi_polling_enabled;
    --lv_rec.hpt_polling_ftp_type_id   := pi_polling_ftp_type_id;
    lv_rec.hpt_area_type             := pi_area_type;
    --
    hig_process_framework.insert_process_type(pi_process_type_rec => lv_rec);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_process_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_process_type;                               
  --
  -----------------------------------------------------------------------------
  --
  
  PROCEDURE update_process_type(pi_old_process_type_id    IN     hig_process_types.hpt_process_type_id%TYPE
                               ,pi_old_process_name       IN     hig_process_types.hpt_name%TYPE
                               ,pi_old_limit              IN     hig_process_types.hpt_process_limit%TYPE
                               ,pi_old_process_descr      IN     hig_process_types.hpt_descr%TYPE
                               ,pi_old_code_to_execute    IN     hig_process_types.hpt_what_to_call%TYPE
                               ,pi_old_see_in_form        IN     hig_process_types.hpt_see_in_hig2510%TYPE  
                               ,pi_old_area_type          IN     hig_process_types.hpt_area_type%TYPE
                               ,pi_old_restartable        IN     hig_process_types.hpt_restartable%TYPE
                               --,pi_old_polling_enabled       IN   hig_process_types.hpt_polling_enabled%TYPE
                               --,pi_old_polling_ftp_type_id   IN   hig_process_types.hpt_polling_ftp_type_id%TYPE
                               ,pi_new_process_type_id    IN     hig_process_types.hpt_process_type_id%TYPE
                               ,pi_new_process_name       IN     hig_process_types.hpt_name%TYPE
                               ,pi_new_limit              IN     hig_process_types.hpt_process_limit%TYPE
                               ,pi_new_process_descr      IN     hig_process_types.hpt_descr%TYPE
                               ,pi_new_code_to_execute    IN     hig_process_types.hpt_what_to_call%TYPE
                               ,pi_new_see_in_form        IN     hig_process_types.hpt_see_in_hig2510%TYPE  
                               ,pi_new_area_type          IN     hig_process_types.hpt_area_type%TYPE
                               ,pi_new_restartable        IN     hig_process_types.hpt_restartable%TYPE
                               --,pi_new_polling_enabled       IN   hig_process_types.hpt_polling_enabled%TYPE
                               --,pi_new_polling_ftp_type_id   IN   hig_process_types.hpt_polling_ftp_type_id%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor)
  IS
    --
    lr_db_rec        hig_process_types%ROWTYPE;
    lv_rec           hig_process_types%ROWTYPE;
  --
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_process_types
       WHERE hpt_process_type_id = pi_old_process_type_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Process Type does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_process_type_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Name'
                               ,pi_parameter_value =>  pi_new_process_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value =>  pi_new_process_descr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'See In Form'
                               ,pi_parameter_value =>  pi_new_see_in_form);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Restartable'
                               ,pi_parameter_value =>  pi_new_restartable);
    --
    /*
    IF valid_package_call(pi_code_to_execute  => pi_new_code_to_execute)  = 'N'
      THEN
         hig.raise_ner(pi_appl               => 'AWLRS'
                      ,pi_id                 => 86);
                      
    END IF;
    */
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF   lr_db_rec.hpt_process_type_id != pi_old_process_type_id
     OR (lr_db_rec.hpt_process_type_id IS NULL AND pi_old_process_type_id IS NOT NULL)
     OR (lr_db_rec.hpt_process_type_id IS NOT NULL AND pi_old_process_type_id IS NULL)
     --
     OR (lr_db_rec.hpt_name != pi_old_process_name)
     OR (lr_db_rec.hpt_name IS NULL AND pi_old_process_name IS NOT NULL)
     OR (lr_db_rec.hpt_name IS NOT NULL AND pi_old_process_name IS NULL)
     --
     OR (lr_db_rec.hpt_process_limit != pi_old_limit)
     OR (lr_db_rec.hpt_process_limit IS NULL AND pi_old_limit IS NOT NULL)
     OR (lr_db_rec.hpt_process_limit IS NOT NULL AND pi_old_limit IS NULL)
     --
     OR (lr_db_rec.hpt_descr != pi_old_process_descr)
     OR (lr_db_rec.hpt_descr IS NULL AND pi_old_process_descr IS NOT NULL)
     OR (lr_db_rec.hpt_descr IS NOT NULL AND pi_old_process_descr IS NULL)
     --
     OR (lr_db_rec.hpt_what_to_call != pi_old_code_to_execute)
     OR (lr_db_rec.hpt_what_to_call IS NULL AND pi_old_code_to_execute IS NOT NULL)
     OR (lr_db_rec.hpt_what_to_call IS NOT NULL AND pi_old_code_to_execute IS NULL)
     --
     OR (lr_db_rec.hpt_see_in_hig2510 != pi_old_see_in_form)
     OR (lr_db_rec.hpt_see_in_hig2510 IS NULL AND pi_old_see_in_form IS NOT NULL)
     OR (lr_db_rec.hpt_see_in_hig2510 IS NOT NULL AND pi_old_see_in_form IS NULL)
     --
     OR (lr_db_rec.hpt_area_type != pi_old_area_type)
     OR (lr_db_rec.hpt_area_type IS NULL AND pi_old_area_type IS NOT NULL)
     OR (lr_db_rec.hpt_area_type IS NOT NULL AND pi_old_area_type IS NULL)
     --
     OR (lr_db_rec.hpt_restartable != pi_old_restartable)
     OR (lr_db_rec.hpt_restartable IS NULL AND pi_old_restartable IS NOT NULL)
     OR (lr_db_rec.hpt_restartable IS NOT NULL AND pi_old_restartable IS NULL)
     --
     /*
     OR (lr_db_rec.hpt_polling_enabled != pi_old_polling_enabled)
     OR (lr_db_rec.hpt_polling_enabled IS NULL AND pi_old_polling_enabled IS NOT NULL)
     OR (lr_db_rec.hpt_polling_enabled IS NOT NULL AND pi_old_polling_enabled IS NULL)
     --
     OR (lr_db_rec.hpt_polling_ftp_type_id != pi_old_polling_ftp_type_id)
     OR (lr_db_rec.hpt_polling_ftp_type_id IS NULL AND pi_old_polling_ftp_type_id IS NOT NULL)
     OR (lr_db_rec.hpt_polling_ftp_type_id IS NOT NULL AND pi_old_polling_ftp_type_id IS NULL)
     */
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_process_type_id != pi_new_process_type_id
       OR (pi_old_process_type_id IS NULL AND pi_new_process_type_id IS NOT NULL)
       OR (pi_old_process_type_id IS NOT NULL AND pi_new_process_type_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_process_name != pi_new_process_name
       OR (pi_old_process_name IS NULL AND pi_new_process_name IS NOT NULL)
       OR (pi_old_process_name IS NOT NULL AND pi_new_process_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_limit != pi_new_limit
       OR (pi_old_limit IS NULL AND pi_new_limit IS NOT NULL)
       OR (pi_old_limit IS NOT NULL AND pi_new_limit IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_process_descr != pi_new_process_descr
       OR (pi_old_process_descr IS NULL AND pi_new_process_descr IS NOT NULL)
       OR (pi_old_process_descr IS NOT NULL AND pi_new_process_descr IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      /*
      IF pi_old_code_to_execute != pi_new_code_to_execute
       OR (pi_old_code_to_execute IS NULL AND pi_new_code_to_execute IS NOT NULL)
       OR (pi_old_code_to_execute IS NOT NULL AND pi_new_code_to_execute IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      */
      --
      IF pi_old_see_in_form != pi_new_see_in_form
       OR (pi_old_see_in_form IS NULL AND pi_new_see_in_form IS NOT NULL)
       OR (pi_old_see_in_form IS NOT NULL AND pi_new_see_in_form IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_area_type != pi_new_area_type
       OR (pi_old_area_type IS NULL AND pi_new_area_type IS NOT NULL)
       OR (pi_old_area_type IS NOT NULL AND pi_new_area_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_restartable != pi_new_restartable
       OR (pi_old_restartable IS NULL AND pi_new_restartable IS NOT NULL)
       OR (pi_old_restartable IS NOT NULL AND pi_new_restartable IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      /*
      IF pi_old_polling_enabled != pi_new_polling_enabled
       OR (pi_old_polling_enabled IS NULL AND pi_new_polling_enabled IS NOT NULL)
       OR (pi_old_polling_enabled IS NOT NULL AND pi_new_polling_enabled IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_polling_ftp_type_id != pi_new_polling_ftp_type_id
       OR (pi_old_polling_ftp_type_id IS NULL AND pi_new_polling_ftp_type_id IS NOT NULL)
       OR (pi_old_polling_ftp_type_id IS NOT NULL AND pi_new_polling_ftp_type_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      */
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        lv_rec.hpt_process_type_id       :=  pi_new_process_type_id;
    	lv_rec.hpt_name                  :=  pi_new_process_name;
        lv_rec.hpt_what_to_call          :=  pi_old_code_to_execute;  -- no update allowed to existing value
        lv_rec.hpt_process_limit         :=  pi_new_limit;
        lv_rec.hpt_descr                 :=  pi_new_process_descr;	
        lv_rec.hpt_restartable           :=  pi_new_restartable;  
        lv_rec.hpt_see_in_hig2510        :=  pi_new_see_in_form;    
        lv_rec.hpt_polling_enabled       :=  'N'; --pi_new_polling_enabled;
        --lv_rec.hpt_polling_ftp_type_id   :=  pi_new_polling_ftp_type_id;
        lv_rec.hpt_area_type             :=  pi_new_area_type;  
	    --
        hig_process_framework.update_process_type(pi_process_type_id  => pi_old_process_type_id
                                                 ,pi_process_type_rec => lv_rec);
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
    WHEN OTHERS
     THEN
        ROLLBACK TO update_process_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_process_type;                               
  --
  -----------------------------------------------------------------------------
  --
  
  PROCEDURE delete_process_type(pi_process_type_id      IN     hig_process_types.hpt_process_type_id%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  lv_rec   hig_process_types%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT delete_process_type_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    IF process_type_exists(pi_process_type_id => pi_process_type_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Process Type: '||pi_process_type_id);
    END IF;
    --
    /*
    ||delete from hig_process_types.
    */
    --
    hig_process_framework.delete_process_type(pi_process_type_id  =>  pi_process_type_id);
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_process_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_process_type;                               
                                                         
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_type_roles(pi_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE
                                  ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT  sys_refcursor
                                  ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hptr_process_type_id    process_type_id
          ,hptr_role               role
      FROM hig_process_type_roles
     WHERE hptr_process_type_id   = pi_process_type_id
    ORDER BY hptr_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_type_roles;                              
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_type_roles(pi_process_type_id      IN     hig_process_type_roles.hptr_process_type_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hptr_process_type_id    process_type_id
                                                     ,hptr_role               role
                                                 FROM hig_process_type_roles
                                                WHERE hptr_process_type_id   = :pi_process_type_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_type_id'
                                                   ||',role'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_id'
                                ,pi_query_col    => 'hptr_process_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'role'
                                ,pi_query_col    => 'hptr_role'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hptr_role')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_type_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_type_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_type_roles;                                   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_process_type_role(pi_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE
                                    ,pi_role             IN      hig_process_type_roles.hptr_role%TYPE
                                    ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  lv_rec hig_scheduling_frequencies%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT create_role_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value =>  pi_role);
    --
    IF process_type_role_exists(pi_process_type_id => pi_process_type_id
                               ,pi_role            => pi_role) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Role '||pi_role);
    END IF;
    --
    /*
    ||insert into hig_process_type_roles.
    */
    INSERT
      INTO hig_process_type_roles
          (hptr_process_type_id
          ,hptr_role
          )
    VALUES (pi_process_type_id
           ,pi_role
           );
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_process_type_role;                                    

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE update_process_type_role(pi_old_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE
                                    ,pi_old_role             IN      hig_process_type_roles.hptr_role%TYPE
                                    ,pi_new_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE
                                    ,pi_new_role             IN      hig_process_type_roles.hptr_role%TYPE
                                    ,po_message_severity        OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor          OUT  sys_refcursor)
  IS
    --
    lr_db_rec        hig_process_type_roles%ROWTYPE;
    --
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_process_type_roles
       WHERE hptr_process_type_id = pi_old_process_type_id
         AND hptr_role            = pi_old_role 
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Role does not exist for this Process Type');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_role_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_new_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value =>  pi_new_role);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF   lr_db_rec.hptr_process_type_id != pi_old_process_type_id
     OR (lr_db_rec.hptr_process_type_id IS NULL AND pi_old_process_type_id IS NOT NULL)
     OR (lr_db_rec.hptr_process_type_id IS NOT NULL AND pi_old_process_type_id IS NULL)
     --
     OR (lr_db_rec.hptr_role != pi_old_role)
     OR (lr_db_rec.hptr_role IS NULL AND pi_old_role IS NOT NULL)
     OR (lr_db_rec.hptr_role IS NOT NULL AND pi_old_role IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_role != pi_new_role
       OR (pi_old_role IS NULL AND pi_new_role IS NOT NULL)
       OR (pi_old_role IS NOT NULL AND pi_new_role IS NULL)
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
        UPDATE hig_process_type_roles
           SET hptr_role            = pi_new_role
         WHERE hptr_process_type_id = pi_old_process_type_id
           AND hptr_role            = pi_old_role; 
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
    WHEN OTHERS
     THEN
        ROLLBACK TO update_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_process_type_role;                                     

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_process_type_role(pi_process_type_id  IN      hig_process_type_roles.hptr_process_type_id%TYPE
                                    ,pi_role             IN      hig_process_type_roles.hptr_role%TYPE
                                    ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_role_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value =>  pi_role);
    --
    IF process_type_role_exists(pi_process_type_id => pi_process_type_id
                               ,pi_role            => pi_role) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Role '||pi_role);
    END IF;
    --
    /*
    ||delete from hig_process_type_roles.
    */
    DELETE FROM hig_process_type_roles
     WHERE hptr_process_type_id = pi_process_type_id
       AND hptr_role            = pi_role;
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_process_type_role;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_type_freqs(pi_process_type_id   IN     hig_process_type_frequencies.hpfr_process_type_id%TYPE
                                  ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT  sys_refcursor
                                  ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpfr_process_type_id  process_type_id
          ,hpfr_frequency_id     frequency_id 
          ,LOWER(hsfr_frequency) frequency  
          ,hpfr_seq              seq 
          ,hsfr_meaning          frequency_descr
      FROM hig_process_type_frequencies
          ,hig_scheduling_frequencies
      WHERE hpfr_process_type_id = pi_process_type_id
        AND hsfr_frequency_id    = hpfr_frequency_id 
    ORDER BY hpfr_seq;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_type_freqs;                                 
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_type_freqs(pi_process_type_id      IN     hig_process_type_frequencies.hpfr_process_type_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpfr_process_type_id  process_type_id
                                                     ,hpfr_frequency_id     frequency_id 
                                                     ,LOWER(hsfr_frequency) frequency  
                                                     ,hpfr_seq              seq 
                                                     ,hsfr_meaning          frequency_descr
                                                 FROM hig_process_type_frequencies
                                                     ,hig_scheduling_frequencies
                                                 WHERE hpfr_process_type_id = :pi_process_type_id
                                                   AND hsfr_frequency_id    = hpfr_frequency_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_type_id'
                                                   ||',frequency_id'
                                                   ||',frequency'
                                                   ||',seq'
                                                   ||',frequency_descr'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_id'
                                ,pi_query_col    => 'hpfr_process_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency_id'
                                ,pi_query_col    => 'hpfr_frequency_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency'
                                ,pi_query_col    => 'hsfr_frequency'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'seq'
                                ,pi_query_col    => 'hpfr_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --  
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency_descr'
                                ,pi_query_col    => 'hsfr_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpfr_seq')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_type_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_type_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_type_freqs;  
                                      
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_process_type_freq(pi_process_type_id  IN      hig_process_type_frequencies.hpfr_process_type_id%TYPE
                                    ,pi_frequency_id     IN      hig_process_type_frequencies.hpfr_frequency_id%TYPE
                                    ,pi_seq              IN      hig_process_type_frequencies.hpfr_seq%TYPE
                                    ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  lv_rec hig_process_type_frequencies%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT create_freq_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_frequency_id);
    --
    IF process_type_freq_exists(pi_process_type_id => pi_process_type_id
                               ,pi_frequency_id    => pi_frequency_id) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Frequency '||pi_frequency_id);
    END IF;
    --
    /*
    ||insert into hig_process_type_frequencies.
    */
    lv_rec.hpfr_process_type_id := pi_process_type_id;
    lv_rec.hpfr_frequency_id    := pi_frequency_id;
    lv_rec.hpfr_seq             := pi_seq;  
    --
    hig_process_framework.insert_process_type_frequency(pi_process_type_frequency_rec => lv_rec);
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_freq_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_process_type_freq;                                       

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE update_process_type_freq(pi_old_process_type_id  IN      hig_process_type_frequencies.hpfr_process_type_id%TYPE
                                    ,pi_old_frequency_id     IN      hig_process_type_frequencies.hpfr_frequency_id%TYPE
                                    ,pi_old_seq              IN      hig_process_type_frequencies.hpfr_seq%TYPE
                                    ,pi_new_process_type_id  IN      hig_process_type_frequencies.hpfr_process_type_id%TYPE
                                    ,pi_new_frequency_id     IN      hig_process_type_frequencies.hpfr_frequency_id%TYPE
                                    ,pi_new_seq              IN      hig_process_type_frequencies.hpfr_seq%TYPE
                                    ,po_message_severity        OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor          OUT  sys_refcursor)
  IS
    --
    lr_db_rec        hig_process_type_frequencies%ROWTYPE;
    --
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_process_type_frequencies
       WHERE hpfr_process_type_id = pi_old_process_type_id
         AND hpfr_frequency_id    = pi_old_frequency_id 
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Frequency does not exist for this Process Type');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_freq_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_new_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_new_frequency_id);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF   lr_db_rec.hpfr_process_type_id != pi_old_process_type_id
     OR (lr_db_rec.hpfr_process_type_id IS NULL AND pi_old_process_type_id IS NOT NULL)
     OR (lr_db_rec.hpfr_process_type_id IS NOT NULL AND pi_old_process_type_id IS NULL)
     --
     OR (lr_db_rec.hpfr_frequency_id != pi_old_frequency_id)
     OR (lr_db_rec.hpfr_frequency_id IS NULL AND pi_old_frequency_id IS NOT NULL)
     OR (lr_db_rec.hpfr_frequency_id IS NOT NULL AND pi_old_frequency_id IS NULL)
     --
     OR (lr_db_rec.hpfr_seq != pi_old_seq)
     OR (lr_db_rec.hpfr_seq IS NULL AND pi_old_seq IS NOT NULL)
     OR (lr_db_rec.hpfr_seq IS NOT NULL AND pi_old_seq IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_frequency_id != pi_new_frequency_id
       OR (pi_old_frequency_id IS NULL AND pi_new_frequency_id IS NOT NULL)
       OR (pi_old_frequency_id IS NOT NULL AND pi_new_frequency_id IS NULL)
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
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE hig_process_type_frequencies
           SET hpfr_frequency_id    = pi_new_frequency_id
              ,hpfr_seq             = pi_new_seq
         WHERE hpfr_process_type_id = pi_old_process_type_id
           AND hpfr_frequency_id    = pi_old_frequency_id; 
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
    WHEN OTHERS
     THEN
        ROLLBACK TO update_freq_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_process_type_freq;                                    

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_process_type_freq(pi_process_type_id  IN      hig_process_type_frequencies.hpfr_process_type_id%TYPE
                                    ,pi_frequency_id     IN      hig_process_type_frequencies.hpfr_frequency_id%TYPE
                                    ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  lv_rec hig_process_type_frequencies%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT delete_freq_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_frequency_id);
    --
    IF process_type_freq_exists(pi_process_type_id => pi_process_type_id
                               ,pi_frequency_id    => pi_frequency_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Frequency '||pi_frequency_id);
    END IF;
    --
    /*
    ||delete from hig_process_type_roles.
    */
    hig_process_framework.delete_process_type_frequency(pi_process_type_id =>  pi_process_type_id
                                                       ,pi_frequency_id    =>  pi_frequency_id);
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_freq_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_process_type_freq;     
  
  --
  -----------------------------------------------------------------------------
  --
  /*
  PROCEDURE get_process_polled_locs(pi_process_type_id   IN     hig_process_conns_by_area.hptc_process_type_id%TYPE
                                   ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT  sys_refcursor
                                   ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpfr_process_type_id  process_type_id
          ,hpfr_frequency_id     frequency_id 
          ,LOWER(hsfr_frequency) frequency  
          ,hpfr_seq              seq 
          ,hsfr_meaning          frequency_descr
      FROM hig_process_type_frequencies
          ,hig_scheduling_frequencies
      WHERE hpfr_process_type_id = pi_process_type_id
        AND hsfr_frequency_id    = hpfr_frequency_id 
    ORDER BY hpfr_seq;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_polled_locs;                                   
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_polled_locs(pi_process_type_id      IN     hig_process_conns_by_area.hptc_process_type_id%TYPE
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
                                         ,po_cursor                  OUT sys_refcursor);       
  */  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_locations(pi_process_type_id   IN     hig_process_type_files.hptf_process_type_id%TYPE
                                 ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT  sys_refcursor
                                 ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hptf_file_type_id              file_type_id  
          ,hptf_name                      file_type_descr       
          ,hptf_process_type_id           process_type_id   
          ,hptf_input                     input_yn  
          ,hptf_input_destination         input_file_location 
          ,hptf_input_destination_type    input_data_store
          ,hptf_min_input_files           min_input_files
          ,hptf_max_input_files           max_input_files 
          ,hptf_output                    output_yn
          ,hptf_output_destination        output_file_location  
          ,hptf_output_destination_type   output_data_store
      FROM hig_process_type_files 
     WHERE hptf_process_type_id = pi_process_type_id
    ORDER BY hptf_file_type_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_locations;                                  
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_locations(pi_process_type_id      IN     hig_process_type_files.hptf_process_type_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hptf_file_type_id              file_type_id  
                                                     ,hptf_name                      file_type_descr       
                                                     ,hptf_process_type_id           process_type_id   
                                                     ,hptf_input                     input_yn  
                                                     ,hptf_input_destination         input_file_location 
                                                     ,hptf_input_destination_type    input_data_store
                                                     ,hptf_min_input_files           min_input_files
                                                     ,hptf_max_input_files           max_input_files 
                                                     ,hptf_output                    output_yn
                                                     ,hptf_output_destination        output_file_location  
                                                     ,hptf_output_destination_type   output_data_store
                                                 FROM hig_process_type_files 
                                                WHERE hptf_process_type_id = :pi_process_type_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   file_type_id'
                                                   ||',file_type_descr'
                                                   ||',process_type_id'
                                                   ||',input_yn'
                                                   ||',input_file_location'
                                                   ||',input_data_store'
                                                   ||',min_input_files'
                                                   ||',max_input_files'
                                                   ||',output_yn'
                                                   ||',output_file_location'
                                                   ||',output_data_store'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'file_type_id'
                                ,pi_query_col    => 'hptf_file_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'file_type_descr'
                                ,pi_query_col    => 'hptf_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_id'
                                ,pi_query_col    => 'hptf_process_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'input_yn'
                                ,pi_query_col    => 'hptf_input'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --  
      awlrs_util.add_column_data(pi_cursor_col   => 'input_file_location'
                                ,pi_query_col    => 'hptf_input_destination'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --  
      awlrs_util.add_column_data(pi_cursor_col   => 'input_data_store'
                                ,pi_query_col    => 'hptf_input_destination_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data); 
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'min_input_files'
                                ,pi_query_col    => 'hptf_min_input_files'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data); 
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'max_input_files'
                                ,pi_query_col    => 'hptf_max_input_files'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data); 
      --                          
      awlrs_util.add_column_data(pi_cursor_col   => 'output_yn'
                                ,pi_query_col    => 'hptf_output'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --  
      awlrs_util.add_column_data(pi_cursor_col   => 'output_file_location'
                                ,pi_query_col    => 'hptf_output_destination'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --  
      awlrs_util.add_column_data(pi_cursor_col   => 'output_data_store'
                                ,pi_query_col    => 'hptf_output_destination_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hptf_file_type_id')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_type_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_type_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_locations;     
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_file_exts(pi_file_type_id      IN     hig_process_type_file_ext.hpte_file_type_id%TYPE
                         ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor      OUT  sys_refcursor
                         ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpte_file_type_id   file_type_id 
          ,hpte_extension      file_ext
      FROM hig_process_type_file_ext 
     WHERE hpte_file_type_id = pi_file_type_id
    ORDER BY hpte_extension;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_file_exts;                            
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_file_exts(pi_file_type_id         IN     hig_process_type_file_ext.hpte_file_type_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpte_file_type_id   file_type_id 
                                                     ,hpte_extension      file_ext
                                                 FROM hig_process_type_file_ext 
                                                WHERE hpte_file_type_id = :pi_file_type_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   file_type_id'
                                                   ||',file_ext'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'file_type_id'
                                ,pi_query_col    => 'hpte_file_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'file_ext'
                                ,pi_query_col    => 'hpte_extension'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpte_extension')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_file_type_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_file_type_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_file_exts;                                  
                                     
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE file_destinations_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT  sys_refcursor
                                 ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hco_code     file_dest_code
          ,hco_meaning  file_desc_descr
      FROM hig_codes
     WHERE hco_domain = 'FILE_DESTINATIONS' 
       AND hco_system = 'Y'
       AND hco_code   IN('DATABASE_SERVER','ORACLE_DIRECTORY')
    ORDER BY hco_seq;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END file_destinations_lov;                                                               
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_process_location(pi_process_type_id      IN     hig_process_type_files.hptf_process_type_id%TYPE
                                   ,pi_file_type_descr      IN     hig_process_type_files.hptf_name%TYPE
                                   ,pi_input_file_location  IN     hig_process_type_files.hptf_input_destination%TYPE
                                   ,pi_input_data_store     IN     hig_process_type_files.hptf_input_destination_type%TYPE 
                                   ,pi_min_input_files      IN     hig_process_type_files.hptf_min_input_files%TYPE
                                   ,pi_max_input_files      IN     hig_process_type_files.hptf_max_input_files%TYPE
                                   ,pi_output_file_location IN     hig_process_type_files.hptf_output_destination%TYPE
                                   ,pi_output_data_store    IN     hig_process_type_files.hptf_output_destination_type%TYPE
                                   ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_location_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Descr'
                               ,pi_parameter_value =>  pi_file_type_descr);
    --
    /*
    ||insert into hig_process_type_files.
    */
    INSERT
      INTO hig_process_type_files
          (hptf_file_type_id
          ,hptf_name
          ,hptf_process_type_id
          ,hptf_input
          ,hptf_output  
          ,hptf_input_destination    
          ,hptf_input_destination_type 
          ,hptf_min_input_files 
          ,hptf_max_input_files
          ,hptf_output_destination
          ,hptf_output_destination_type
  )
    VALUES (nm3ddl.sequence_nextval('hptf_file_type_id_seq')
           ,pi_file_type_descr
           ,pi_process_type_id
           ,CASE WHEN pi_input_file_location IS NOT NULL
                   OR pi_input_data_store IS NOT NULL THEN 'Y'
                 ELSE 'N'
            END       
           ,CASE WHEN pi_output_file_location IS NOT NULL
                   OR pi_output_data_store IS NOT NULL THEN 'Y'
                 ELSE 'N'
            END         
           ,pi_input_file_location
           ,pi_input_data_store
           ,pi_min_input_files
           ,pi_max_input_files
           ,pi_output_file_location
           ,pi_output_data_store
           ); 
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_location_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_process_location;                                      

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE update_process_location(pi_old_process_type_id      IN     hig_process_type_files.hptf_process_type_id%TYPE
                                   ,pi_old_file_type_id         IN     hig_process_type_files.hptf_file_type_id%TYPE 
                                   ,pi_old_file_type_descr      IN     hig_process_type_files.hptf_name%TYPE
                                   ,pi_old_input_yn             IN     hig_process_type_files.hptf_input%TYPE
                                   ,pi_old_input_file_location  IN     hig_process_type_files.hptf_input_destination%TYPE
                                   ,pi_old_input_data_store     IN     hig_process_type_files.hptf_input_destination_type%TYPE 
                                   ,pi_old_min_input_files      IN     hig_process_type_files.hptf_min_input_files%TYPE
                                   ,pi_old_max_input_files      IN     hig_process_type_files.hptf_max_input_files%TYPE
                                   ,pi_old_output_yn            IN     hig_process_type_files.hptf_output%TYPE
                                   ,pi_old_output_file_location IN     hig_process_type_files.hptf_output_destination%TYPE
                                   ,pi_old_output_data_store    IN     hig_process_type_files.hptf_output_destination_type%TYPE
                                   ,pi_new_process_type_id      IN     hig_process_type_files.hptf_process_type_id%TYPE
                                   ,pi_new_file_type_id         IN     hig_process_type_files.hptf_file_type_id%TYPE 
                                   ,pi_new_file_type_descr      IN     hig_process_type_files.hptf_name%TYPE
                                   ,pi_new_input_yn             IN     hig_process_type_files.hptf_input%TYPE
                                   ,pi_new_input_file_location  IN     hig_process_type_files.hptf_input_destination%TYPE
                                   ,pi_new_input_data_store     IN     hig_process_type_files.hptf_input_destination_type%TYPE 
                                   ,pi_new_min_input_files      IN     hig_process_type_files.hptf_min_input_files%TYPE
                                   ,pi_new_max_input_files      IN     hig_process_type_files.hptf_max_input_files%TYPE
                                   ,pi_new_output_yn            IN     hig_process_type_files.hptf_output%TYPE
                                   ,pi_new_output_file_location IN     hig_process_type_files.hptf_output_destination%TYPE
                                   ,pi_new_output_data_store    IN     hig_process_type_files.hptf_output_destination_type%TYPE
                                   ,po_message_severity           OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor             OUT  sys_refcursor)
  IS
    --
    lr_db_rec        hig_process_type_files%ROWTYPE;
    --
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_process_type_files
       WHERE hptf_file_type_id = pi_old_file_type_id
      FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Location does not exist for this File Type');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_location_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_new_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Id'
                               ,pi_parameter_value =>  pi_new_file_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Descr'
                               ,pi_parameter_value =>  pi_new_file_type_descr);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Input'
                          ,pi_parameter_value =>  pi_new_input_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Output'
                          ,pi_parameter_value =>  pi_new_output_yn);
    --
    IF (   pi_new_input_yn = 'Y'
       AND pi_new_input_file_location IS NULL
       AND pi_new_input_data_store IS NULL) 
       THEN
           hig.raise_ner(pi_appl               => 'HIG'
                        ,pi_id                 => 110
                        ,pi_supplementary_info => 'When Input is set to Y, the File Location or the Data Store must also be provided.');
    END IF;
    --
    IF (   pi_new_output_yn = 'Y'
       AND pi_new_output_file_location IS NULL
       AND pi_new_output_data_store IS NULL) 
       THEN
           hig.raise_ner(pi_appl               => 'HIG'
                        ,pi_id                 => 110
                        ,pi_supplementary_info => 'When Output is set to Y, the File Location or the Data Store must also be provided.');
    END IF;
    --  
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF   lr_db_rec.hptf_file_type_id != pi_old_file_type_id
     OR (lr_db_rec.hptf_file_type_id IS NULL AND pi_old_file_type_id IS NOT NULL)
     OR (lr_db_rec.hptf_file_type_id IS NOT NULL AND pi_old_file_type_id IS NULL)
     --
     OR (lr_db_rec.hptf_process_type_id != pi_old_process_type_id)
     OR (lr_db_rec.hptf_process_type_id IS NULL AND pi_old_process_type_id IS NOT NULL)
     OR (lr_db_rec.hptf_process_type_id IS NOT NULL AND pi_old_process_type_id IS NULL)
     --
     OR (lr_db_rec.hptf_name != pi_old_file_type_descr)
     OR (lr_db_rec.hptf_name IS NULL AND pi_old_file_type_descr IS NOT NULL)
     OR (lr_db_rec.hptf_name IS NOT NULL AND pi_old_file_type_descr IS NULL)
     --
     OR (lr_db_rec.hptf_input != pi_old_input_yn)
     OR (lr_db_rec.hptf_input IS NULL AND pi_old_input_yn IS NOT NULL)
     OR (lr_db_rec.hptf_input IS NOT NULL AND pi_old_input_yn IS NULL)
     --
     OR (lr_db_rec.hptf_input_destination != pi_old_input_file_location)
     OR (lr_db_rec.hptf_input_destination IS NULL AND pi_old_input_file_location IS NOT NULL)
     OR (lr_db_rec.hptf_input_destination IS NOT NULL AND pi_old_input_file_location IS NULL)
     --
     OR (lr_db_rec.hptf_input_destination_type != pi_old_input_data_store)
     OR (lr_db_rec.hptf_input_destination_type IS NULL AND pi_old_input_data_store IS NOT NULL)
     OR (lr_db_rec.hptf_input_destination_type IS NOT NULL AND pi_old_input_data_store IS NULL)
     --
     OR (lr_db_rec.hptf_min_input_files != pi_old_min_input_files)
     OR (lr_db_rec.hptf_min_input_files IS NULL AND pi_old_min_input_files IS NOT NULL)
     OR (lr_db_rec.hptf_min_input_files IS NOT NULL AND pi_old_min_input_files IS NULL)
     --
     OR (lr_db_rec.hptf_max_input_files != pi_old_max_input_files)
     OR (lr_db_rec.hptf_max_input_files IS NULL AND pi_old_max_input_files IS NOT NULL)
     OR (lr_db_rec.hptf_max_input_files IS NOT NULL AND pi_old_max_input_files IS NULL)
     --
     OR (lr_db_rec.hptf_output != pi_old_output_yn)
     OR (lr_db_rec.hptf_output IS NULL AND pi_old_output_yn IS NOT NULL)
     OR (lr_db_rec.hptf_output IS NOT NULL AND pi_old_output_yn IS NULL)
     --
     OR (lr_db_rec.hptf_output_destination != pi_old_output_file_location)
     OR (lr_db_rec.hptf_output_destination IS NULL AND pi_old_output_file_location IS NOT NULL)
     OR (lr_db_rec.hptf_output_destination IS NOT NULL AND pi_old_output_file_location IS NULL)
     --
     OR (lr_db_rec.hptf_output_destination_type != pi_old_output_data_store)
     OR (lr_db_rec.hptf_output_destination_type IS NULL AND pi_old_output_data_store IS NOT NULL)
     OR (lr_db_rec.hptf_output_destination_type IS NOT NULL AND pi_old_output_data_store IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_file_type_id != pi_new_file_type_id
       OR (pi_old_file_type_id IS NULL AND pi_new_file_type_id IS NOT NULL)
       OR (pi_old_file_type_id IS NOT NULL AND pi_new_file_type_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_process_type_id != pi_new_process_type_id
       OR (pi_old_process_type_id IS NULL AND pi_new_process_type_id IS NOT NULL)
       OR (pi_old_process_type_id IS NOT NULL AND pi_new_process_type_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_file_type_descr != pi_new_file_type_descr
       OR (pi_old_file_type_descr IS NULL AND pi_new_file_type_descr IS NOT NULL)
       OR (pi_old_file_type_descr IS NOT NULL AND pi_new_file_type_descr IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_input_yn != pi_new_input_yn
       OR (pi_old_input_yn IS NULL AND pi_new_input_yn IS NOT NULL)
       OR (pi_old_input_yn IS NOT NULL AND pi_new_input_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_input_file_location != pi_new_input_file_location
       OR (pi_old_input_file_location IS NULL AND pi_new_input_file_location IS NOT NULL)
       OR (pi_old_input_file_location IS NOT NULL AND pi_new_input_file_location IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_input_data_store != pi_new_input_data_store
       OR (pi_old_input_data_store IS NULL AND pi_new_input_data_store IS NOT NULL)
       OR (pi_old_input_data_store IS NOT NULL AND pi_new_input_data_store IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_min_input_files != pi_new_min_input_files
       OR (pi_old_min_input_files IS NULL AND pi_new_min_input_files IS NOT NULL)
       OR (pi_old_min_input_files IS NOT NULL AND pi_new_min_input_files IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_max_input_files != pi_new_max_input_files
       OR (pi_old_max_input_files IS NULL AND pi_new_max_input_files IS NOT NULL)
       OR (pi_old_max_input_files IS NOT NULL AND pi_new_max_input_files IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_output_yn != pi_new_output_yn
       OR (pi_old_output_yn IS NULL AND pi_new_output_yn IS NOT NULL)
       OR (pi_old_output_yn IS NOT NULL AND pi_new_output_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_output_file_location != pi_new_output_file_location
       OR (pi_old_output_file_location IS NULL AND pi_new_output_file_location IS NOT NULL)
       OR (pi_old_output_file_location IS NOT NULL AND pi_new_output_file_location IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_output_data_store != pi_new_output_data_store
       OR (pi_old_output_data_store IS NULL AND pi_new_output_data_store IS NOT NULL)
       OR (pi_old_output_data_store IS NOT NULL AND pi_new_output_data_store IS NULL)
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
        UPDATE hig_process_type_files
           SET hptf_process_type_id         = pi_new_process_type_id
              ,hptf_name                    = pi_new_file_type_descr
              ,hptf_input                   = pi_new_input_yn
              ,hptf_input_destination       = pi_new_input_file_location
              ,hptf_input_destination_type  = pi_new_input_data_store
              ,hptf_min_input_files         = pi_new_min_input_files
              ,hptf_max_input_files         = pi_new_max_input_files
              ,hptf_output                  = pi_new_output_yn
              ,hptf_output_destination      = pi_new_output_file_location
              ,hptf_output_destination_type = pi_new_output_data_store
         WHERE hptf_file_type_id = pi_old_file_type_id;
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
    WHEN OTHERS
     THEN
        ROLLBACK TO update_location_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_process_location;                                   

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_process_location(pi_file_type_id     IN      hig_process_type_files.hptf_file_type_id%TYPE
                                   ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_location_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Id'
                               ,pi_parameter_value =>  pi_file_type_id);
    --
    IF process_location_exists(pi_file_type_id => pi_file_type_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'File '||pi_file_type_id);
    END IF;
    --
    /*
    ||delete from hig_process_type_files.
    */
    DELETE FROM hig_process_type_files
     WHERE hptf_file_type_id = pi_file_type_id;
        -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_location_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_process_location;                                      
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_file_ext(pi_file_type_id       IN     hig_process_type_file_ext.hpte_file_type_id%TYPE
                           ,pi_file_type_ext      IN     hig_process_type_file_ext.hpte_extension%TYPE
                           ,po_message_severity      OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor        OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_file_ext_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Id'
                               ,pi_parameter_value =>  pi_file_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Extenison'
                               ,pi_parameter_value =>  pi_file_type_ext);
    --
    /*
    ||insert into hig_process_type_file_ext.
    */
    INSERT
      INTO hig_process_type_file_ext
          (hpte_file_type_id
          ,hpte_extension
          )
    VALUES (pi_file_type_id
           ,pi_file_type_ext
           ); 
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_file_ext_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_file_ext;                                

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE update_file_ext(pi_old_file_type_id    IN     hig_process_type_file_ext.hpte_file_type_id%TYPE
                           ,pi_old_file_type_ext   IN     hig_process_type_file_ext.hpte_extension%TYPE
                           ,pi_new_file_type_id    IN     hig_process_type_file_ext.hpte_file_type_id%TYPE
                           ,pi_new_file_type_ext   IN     hig_process_type_file_ext.hpte_extension%TYPE
                           ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor        OUT  sys_refcursor)
  IS
    --
    lr_db_rec        hig_process_type_file_ext%ROWTYPE;
    --
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_process_type_file_ext
       WHERE hpte_file_type_id = pi_old_file_type_id
         AND hpte_extension    = pi_old_file_type_ext
      FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'File Extension does not exist for this File Type');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_file_ext_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Id'
                               ,pi_parameter_value =>  pi_new_file_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Extension'
                               ,pi_parameter_value =>  pi_new_file_type_ext);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF   lr_db_rec.hpte_file_type_id != pi_old_file_type_id
     OR (lr_db_rec.hpte_file_type_id IS NULL AND pi_old_file_type_id IS NOT NULL)
     OR (lr_db_rec.hpte_file_type_id IS NOT NULL AND pi_old_file_type_id IS NULL)
     --
     OR (lr_db_rec.hpte_extension != pi_old_file_type_ext)
     OR (lr_db_rec.hpte_extension IS NULL AND pi_old_file_type_ext IS NOT NULL)
     OR (lr_db_rec.hpte_extension IS NOT NULL AND pi_old_file_type_ext IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_file_type_id != pi_new_file_type_id
       OR (pi_old_file_type_id IS NULL AND pi_new_file_type_id IS NOT NULL)
       OR (pi_old_file_type_id IS NOT NULL AND pi_new_file_type_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_file_type_ext != pi_new_file_type_ext
       OR (pi_old_file_type_ext IS NULL AND pi_new_file_type_ext IS NOT NULL)
       OR (pi_old_file_type_ext IS NOT NULL AND pi_new_file_type_ext IS NULL)
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
        UPDATE hig_process_type_file_ext
           SET hpte_file_type_id  = pi_new_file_type_id
              ,hpte_extension     = pi_new_file_type_ext
         WHERE hpte_file_type_id  = pi_old_file_type_id
           AND hpte_extension     = pi_old_file_type_ext;
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
    WHEN OTHERS
     THEN
        ROLLBACK TO update_file_ext_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_file_ext;                           

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_file_ext(pi_file_type_id      IN     hig_process_type_file_ext.hpte_file_type_id%TYPE
                           ,pi_file_type_ext     IN     hig_process_type_file_ext.hpte_extension%TYPE
                           ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_file_ext_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Type Id'
                               ,pi_parameter_value =>  pi_file_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Extenison'
                               ,pi_parameter_value =>  pi_file_type_ext);
    --
    IF file_ext_exists(pi_file_type_id  => pi_file_type_id
                      ,pi_file_type_ext => pi_file_type_ext) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'File Id/Extension '||pi_file_type_id||'/'||pi_file_type_ext);
    END IF;
    --
    /*
    ||delete from hig_process_type_file_ext.
    */
    DELETE FROM hig_process_type_file_ext
     WHERE hpte_file_type_id = pi_file_type_id
       AND hpte_extension    = pi_file_type_ext; 
        -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_file_ext_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_file_ext;                                                                                                                                                                                       
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_frequencies(po_message_severity OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT  sys_refcursor
                           ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hsfr_frequency_id              frequency_id
          ,hsfr_meaning                   freq_descr  
          ,hsfr_frequency                 frequency 
          ,hsfr_next_schedule_date        next_schedule_date
          ,hsfr_subsequent_schedule_date  subsequent_schedule_date 
          ,hsfr_system                    protected_  
          ,hsfr_interval_in_mins          interval_in_mins
      FROM hig_scheduling_frequencies_v
    ORDER BY hsfr_next_schedule_date;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_frequencies;                          
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_frequency(pi_frequency_id     IN      hig_scheduling_frequencies.hsfr_frequency_id%TYPE
                         ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor      OUT  sys_refcursor
                         ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hsfr_frequency_id              frequency_id
          ,hsfr_meaning                   freq_descr  
          ,hsfr_frequency                 frequency 
          ,hsfr_next_schedule_date        next_schedule_date
          ,hsfr_subsequent_schedule_date  subsequent_schedule_date 
          ,hsfr_system                    protected_  
          ,hsfr_interval_in_mins          interval_in_mins
      FROM hig_scheduling_frequencies_v
     WHERE hsfr_frequency_id = pi_frequency_id; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_frequency;                                                       
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_frequencies(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hsfr_frequency_id              frequency_id
                                                     ,hsfr_meaning                   freq_descr  
                                                     ,hsfr_frequency                 frequency 
                                                     ,hsfr_next_schedule_date        next_schedule_date
                                                     ,hsfr_subsequent_schedule_date  subsequent_schedule_date 
                                                     ,hsfr_system                    protected_  
                                                     ,hsfr_interval_in_mins          interval_in_mins
                                                 FROM hig_scheduling_frequencies_v ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   frequency_id'
                                                   ||',freq_descr'
                                                   ||',frequency' 
                                                   ||',next_schedule_date'
                                                   ||',subsequent_schedule_date' 
                                                   ||',protected_'
                                                   ||',interval_in_mins'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency_id'
                                ,pi_query_col    => 'hsfr_frequency_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'freq_descr'
                                ,pi_query_col    => 'hsfr_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency'
                                ,pi_query_col    => 'hsfr_frequency'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'next_schedule_date'
                                ,pi_query_col    => 'hsfr_next_schedule_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'subsequent_schedule_date'
                                ,pi_query_col    => 'hsfr_subsequent_schedule_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'protected_'
                                ,pi_query_col    => 'hsfr_system'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'interval_in_mins'
                                ,pi_query_col    => 'hsfr_interval_in_mins'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hsfr_next_schedule_date')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_frequencies;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_frequency(pi_frequency          IN      hig_scheduling_frequencies.hsfr_frequency%TYPE
                            ,pi_freq_descr         IN      hig_scheduling_frequencies.hsfr_meaning%TYPE
                            ,po_next_schedule_date    OUT  date
                            ,po_subsqnt_schedule_date OUT  date 
                            ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor        OUT  sys_refcursor)
  IS
  --
  lv_rec hig_scheduling_frequencies%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT create_frequency_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency'
                               ,pi_parameter_value =>  pi_frequency);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value =>  pi_freq_descr);
    --
    IF frequency_desc_exists(pi_freq_descr => pi_freq_descr) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Frequency description '||pi_freq_descr);
    END IF;
    --
    nm3jobs.validate_calendar_string(pi_calendar_string => pi_frequency);
    --
    po_next_schedule_date := hig_process_framework.when_would_job_be_scheduled(pi_frequency => pi_frequency);
    --                                                                        
    po_subsqnt_schedule_date := hig_process_framework.when_would_job_be_scheduled(pi_frequency         => pi_frequency
                                                                                 ,pi_return_date_after => po_next_schedule_date); 
    /*
    ||insert into hig_scheduling_frequencies.
    */
    lv_rec.hsfr_frequency         := pi_frequency;
	lv_rec.hsfr_meaning           := pi_freq_descr;
	lv_rec.hsfr_interval_in_mins  := nm3jobs.calendar_string_in_mins(pi_calendar_string => pi_frequency);
	--
    hig_process_framework.insert_scheduling_frequency(pi_frequency_rec => lv_rec);
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_frequency_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_frequency;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE update_frequency(pi_old_frequency_id       IN      hig_scheduling_frequencies.hsfr_frequency_id%TYPE
                            ,pi_old_frequency          IN      hig_scheduling_frequencies.hsfr_frequency%TYPE
                            ,pi_old_freq_descr         IN      hig_scheduling_frequencies.hsfr_meaning%TYPE
                            ,pi_new_frequency_id       IN      hig_scheduling_frequencies.hsfr_frequency_id%TYPE
                            ,pi_new_frequency          IN      hig_scheduling_frequencies.hsfr_frequency%TYPE
                            ,pi_new_freq_descr         IN      hig_scheduling_frequencies.hsfr_meaning%TYPE
                            ,po_interval_in_mins          OUT  hig_scheduling_frequencies.hsfr_interval_in_mins%TYPE
                            ,po_message_severity          OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor            OUT  sys_refcursor)
  IS
    --
    lr_db_rec        hig_scheduling_frequencies%ROWTYPE;
    lv_rec           hig_scheduling_frequencies%ROWTYPE;
  --
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_scheduling_frequencies
       WHERE hsfr_frequency_id = pi_old_frequency_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Frequency does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_frequency_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_new_frequency_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value =>  pi_new_freq_descr);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF   lr_db_rec.hsfr_frequency_id != pi_old_frequency_id
     OR (lr_db_rec.hsfr_frequency_id IS NULL AND pi_old_frequency_id IS NOT NULL)
     OR (lr_db_rec.hsfr_frequency_id IS NOT NULL AND pi_old_frequency_id IS NULL)
     --
     OR (lr_db_rec.hsfr_frequency != pi_old_frequency)
     OR (lr_db_rec.hsfr_frequency IS NULL AND pi_old_frequency IS NOT NULL)
     OR (lr_db_rec.hsfr_frequency IS NOT NULL AND pi_old_frequency IS NULL)
     --
     OR (lr_db_rec.hsfr_meaning != pi_old_freq_descr)
     OR (lr_db_rec.hsfr_meaning IS NULL AND pi_old_freq_descr IS NOT NULL)
     OR (lr_db_rec.hsfr_meaning IS NOT NULL AND pi_old_freq_descr IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_frequency_id != pi_new_frequency_id
       OR (pi_old_frequency_id IS NULL AND pi_new_frequency_id IS NOT NULL)
       OR (pi_old_frequency_id IS NOT NULL AND pi_new_frequency_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_frequency != pi_new_frequency
       OR (pi_old_frequency IS NULL AND pi_new_frequency IS NOT NULL)
       OR (pi_old_frequency IS NOT NULL AND pi_new_frequency IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_freq_descr != pi_new_freq_descr
       OR (pi_old_freq_descr IS NULL AND pi_new_freq_descr IS NOT NULL)
       OR (pi_old_freq_descr IS NOT NULL AND pi_new_freq_descr IS NULL)
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
        lv_rec.hsfr_frequency_id      := pi_new_frequency_id;
        lv_rec.hsfr_frequency         := pi_new_frequency;
	    lv_rec.hsfr_meaning           := pi_new_freq_descr;
        hig_process_framework.update_scheduling_frequency(pi_frequency_id  => pi_old_frequency_id
                                                         ,pi_frequency_rec => lv_rec);
  
	   
     	po_interval_in_mins := lv_rec.hsfr_interval_in_mins;
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
    WHEN OTHERS
     THEN
        ROLLBACK TO update_frequency_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_frequency;                                     
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_frequency(pi_frequency_id      IN      hig_scheduling_frequencies.hsfr_frequency_id%TYPE
                            ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_frequency_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_frequency_id);
    --
    IF frequency_exists(pi_frequency_id => pi_frequency_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Frequency Id '||pi_frequency_id);
    END IF;
    --
    /*
    ||delete from insert into hig_scheduling_frequencies.
    */
    hig_process_framework.delete_scheduling_frequency(pi_frequency_id  => pi_frequency_id);
	-- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_frequency_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_frequency;                                 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_processes(po_message_severity OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT  sys_refcursor
                         ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hp_process_id                    process_id
          ,hp_process_type_id               process_type_id
          ,hp_process_type_name             process_type_name
          ,hp_process_limit                 process_limit
          ,hp_initiated_by_username         initiated_by_username
          ,hp_initiated_date                initiated_date
          ,hp_initiators_ref                initiators_ref
          ,hp_job_name                      job_name 
          ,hp_job_owner                     job_owner
          ,hp_frequency_id                  frequency_id
          ,hsfr_meaning                     frequency_descr
          ,max_runs                         max_runs
          ,max_failures                     max_failures
          ,hp_success_flag                  success_flag 
          ,hp_success_flag_meaning          success_flag_meaning
          ,hp_what_to_call                  what_to_call  
          ,hp_polling_flag                  polling_flag
          ,hp_area_type                     area_type
          ,hp_area_type_description         area_type_descr
          ,hp_area_meaning                  area_meaning 
          ,hpj_job_action                   job_action  
          ,hpj_schedule_type                schedule_type  
          ,hpj_repeat_interval              repeat_interval
          ,hpj_job_state                    job_state 
          ,hpj_run_count                    run_count 
          ,hpj_run_failure_count            run_failure_count
          ,hpj_last_start_date              last_start_date 
          ,hpj_last_run_date                last_run_date
          ,hpj_next_run_date                next_run_date
          ,hp_requires_attention_flag       requires_attention_flag
      FROM hig_processes_v
          ,hig_scheduling_frequencies 
     WHERE hsfr_frequency_id = hp_frequency_id
    ORDER BY hp_process_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_processes;
                         
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process(pi_process_id       IN      hig_processes.hp_process_id%TYPE
                       ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor      OUT  sys_refcursor
                       ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hp_process_id                    process_id
          ,hp_process_type_id               process_type_id
          ,hp_process_type_name             process_type_name
          ,hp_process_limit                 process_limit
          ,hp_initiated_by_username         initiated_by_username
          ,hp_initiated_date                initiated_date
          ,hp_initiators_ref                initiators_ref
          ,hp_job_name                      job_name 
          ,hp_job_owner                     job_owner
          ,hp_frequency_id                  frequency_id
          ,hsfr_meaning                     frequency_descr
          ,max_runs                         max_runs
          ,max_failures                     max_failures
          ,hp_success_flag                  success_flag 
          ,hp_success_flag_meaning          success_flag_meaning
          ,hp_what_to_call                  what_to_call  
          ,hp_polling_flag                  polling_flag
          ,hp_area_type                     area_type
          ,hp_area_type_description         area_type_descr
          ,hp_area_meaning                  area_meaning 
          ,hpj_job_action                   job_action  
          ,hpj_schedule_type                schedule_type  
          ,hpj_repeat_interval              repeat_interval
          ,hpj_job_state                    job_state 
          ,hpj_run_count                    run_count 
          ,hpj_run_failure_count            run_failure_count
          ,hpj_last_start_date              last_start_date 
          ,hpj_last_run_date                last_run_date
          ,hpj_next_run_date                next_run_date
          ,hp_requires_attention_flag       requires_attention_flag
      FROM hig_processes_v
          ,hig_scheduling_frequencies 
     WHERE hp_process_id     = pi_process_id
       AND hsfr_frequency_id = hp_frequency_id;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  END get_process;                                 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_processes(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hp_process_id                    process_id
                                                     ,hp_process_type_id               process_type_id
                                                     ,hp_process_type_name             process_type_name
                                                     ,hp_process_limit                 process_limit
                                                     ,hp_initiated_by_username         initiated_by_username
                                                     ,hp_initiated_date                initiated_date
                                                     ,hp_initiators_ref                initiators_ref
                                                     ,hp_job_name                      job_name 
                                                     ,hp_job_owner                     job_owner
                                                     ,hp_frequency_id                  frequency_id
                                                     ,hsfr_meaning                     frequency_descr
                                                     ,max_runs                         max_runs
                                                     ,max_failures                     max_failures
                                                     ,hp_success_flag                  success_flag 
                                                     ,hp_success_flag_meaning          success_flag_meaning
                                                     ,hp_what_to_call                  what_to_call  
                                                     ,hp_polling_flag                  polling_flag
                                                     ,hp_area_type                     area_type
                                                     ,hp_area_type_description         area_type_descr
                                                     ,hp_area_meaning                  area_meaning 
                                                     ,hpj_job_action                   job_action  
                                                     ,hpj_schedule_type                schedule_type  
                                                     ,hpj_repeat_interval              repeat_interval
                                                     ,hpj_job_state                    job_state 
                                                     ,hpj_run_count                    run_count 
                                                     ,hpj_run_failure_count            run_failure_count
                                                     ,hpj_last_start_date              last_start_date 
                                                     ,hpj_last_run_date                last_run_date
                                                     ,hpj_next_run_date                next_run_date
                                                     ,hp_requires_attention_flag       requires_attention_flag
                                                 FROM hig_processes_v 
                                                     ,hig_scheduling_frequencies 
                                                WHERE hsfr_frequency_id = hp_frequency_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                   ||',process_type_id'
                                                   ||',process_type_name' 
                                                   ||',process_limit'
                                                   ||',initiated_by_username' 
                                                   ||',initiated_date'
                                                   ||',initiators_ref'
                                                   ||',job_name'
                                                   ||',job_owner'
                                                   ||',frequency_id'
                                                   ||',frequency_descr'
                                                   ||',max_runs'
                                                   ||',max_failures' 
                                                   ||',success_flag'
                                                   ||',success_flag_meaning' 
                                                   ||',what_to_call'
                                                   ||',polling_flag'
                                                   ||',area_type'
                                                   ||',area_type_descr'
                                                   ||',area_meaning'
                                                   ||',job_action'
                                                   ||',schedule_type' 
                                                   ||',repeat_interval'
                                                   ||',job_state' 
                                                   ||',run_count'
                                                   ||',run_failure_count'
                                                   ||',last_start_date'
                                                   ||',last_run_date'
                                                   ||',next_run_date'
                                                   ||',requires_attention_flag'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                                ,pi_query_col    => 'hp_process_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_id'
                                ,pi_query_col    => 'hp_process_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_name'
                                ,pi_query_col    => 'hp_process_type_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_limit'
                                ,pi_query_col    => 'hp_process_limit'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'initiated_by_username'
                                ,pi_query_col    => 'hp_initiated_by_username'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'initiated_date'
                                ,pi_query_col    => 'hp_initiated_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'initiators_ref'
                                ,pi_query_col    => 'hp_initiators_ref'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_name'
                                ,pi_query_col    => 'hp_job_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_owner'
                                ,pi_query_col    => 'hp_job_owner'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency_id'
                                ,pi_query_col    => 'hp_frequency_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency_descr'
                                ,pi_query_col    => 'hsfr_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'max_runs'
                                ,pi_query_col    => 'hp_max_runs'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --     
      awlrs_util.add_column_data(pi_cursor_col   => 'max_failures'
                                ,pi_query_col    => 'hp_max_failures'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'success_flag'
                                ,pi_query_col    => 'hp_success_flag'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'success_flag_meaning'
                                ,pi_query_col    => 'hp_success_flag_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'what_to_call'
                                ,pi_query_col    => 'hp_what_to_call'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'polling_flag'
                                ,pi_query_col    => 'hp_polling_flag'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'area_type'
                                ,pi_query_col    => 'hp_area_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'area_type_descr'
                                ,pi_query_col    => 'hp_area_type_description'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'area_meaning'
                                ,pi_query_col    => 'hp_area_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_action'
                                ,pi_query_col    => 'hpj_job_action'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'schedule_type'
                                ,pi_query_col    => 'hpj_schedule_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'repeat_interval'
                                ,pi_query_col    => 'hpj_repeat_interval'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_state'
                                ,pi_query_col    => 'hpj_job_state'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'run_count'
                                ,pi_query_col    => 'hpj_run_count'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'run_failure_count'
                                ,pi_query_col    => 'hpj_run_failure_count'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'last_start_date'
                                ,pi_query_col    => 'hpj_last_start_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'last_run_date'
                                ,pi_query_col    => 'hpj_last_run_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'next_run_date'
                                ,pi_query_col    => 'hpj_next_run_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hp_process_id')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_processes;                               
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_type_for_sub(po_message_severity OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT  sys_refcursor
                                    ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpt_process_type_id         process_type_id
          ,hpt_name                    process_name
          ,hpt_area_type               area_type
      FROM hig_process_types_v
     WHERE hpt_see_in_hig2510  =  'Y';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_type_for_sub;                                    
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_type_for_sub(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpt_process_type_id         process_type_id
                                                     ,hpt_name                    process_name  
                                                     ,hpt_area_type               area_type          
                                                 FROM hig_process_types_v
                                                WHERE hpt_see_in_hig2510  =  ''Y'' ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_type_id'
                                                   ||',process_name'
                                                   ||',area_type'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_type_id'
                                ,pi_query_col    => 'hpt_process_type_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'process_name'
                                ,pi_query_col    => 'hpt_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'area_type'
                                ,pi_query_col    => 'hpt_area_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpt_name')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_type_for_sub;                                           
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_scheduled_date(pi_start_date        IN      DATE
                              ,pi_frequency_id      IN      hig_scheduling_frequencies.hsfr_frequency_id%TYPE
                              ,po_scheduled_date       OUT  DATE
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
     awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_frequency_id);
    --
    po_scheduled_date := hig_process_framework.when_would_job_be_scheduled(pi_start_date    => pi_start_date
                                                                          ,pi_frequency_id  => pi_frequency_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_scheduled_date;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE process_type_freq_lov(pi_process_type_id  IN     hig_process_types.hpt_process_type_id%TYPE
                                 ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor     OUT  sys_refcursor
                                 ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT frequency_id
          ,freq_descr
      FROM (SELECT hpfr_frequency_id         frequency_id
                  ,hsfr_meaning              freq_descr
              FROM hig_process_type_frequencies
                  ,hig_scheduling_frequencies
             WHERE hpfr_process_type_id = pi_process_type_id
               AND hpfr_frequency_id    = hsfr_frequency_id
            UNION -- always at least return a frequency of ONCE
            SELECT hsfr_frequency_id         frequency_id
                  ,hsfr_meaning              freq_descr
              FROM hig_scheduling_frequencies 
             WHERE hsfr_frequency_id = -1
	  	)	       
    ORDER BY frequency_id;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END process_type_freq_lov;
    
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION get_process_type_area(pi_process_type_id     IN hig_process_types.hpt_process_type_id%TYPE
                                ,pi_restricted_list     IN varchar2 DEFAULT 'N'
                                ,pi_include_dummy       IN varchar2 DEFAULT 'N') RETURN VARCHAR2 IS
 

  CURSOR c1 IS
  SELECT 
               'select id, meaning'||chr(10)
             ||'from'||chr(10)
             ||'('||chr(10)
             || case when pi_include_dummy = 'Y' then
                  'select 1 seq, ''None'' meaning, null id from dual'||chr(10)
                   ||'union all'||chr(10)
                  else
                   null
                  end 
            || case when pi_restricted_list = 'Y' THEN 
                          'select 2 seq, SUBSTR('||hpa_meaning_column||',1,100) meaning, TO_CHAR('||hpa_id_column||') id from '||NVL(hpa_restricted_table,hpa_table)||chr(10)||' where '||NVL(hpa_restricted_where_clause,'1=1')||chr(10)
                     else 
                          'select 2 seq, SUBSTR('||hpa_meaning_column||',1,100) meaning, TO_CHAR('||hpa_id_column||') id from '||hpa_table||chr(10)||' where '||NVL(hpa_where_clause,'1=1')||chr(10)
                     end                                                                         
             ||')'||chr(10)
                 ||' order by seq,meaning' the_sql
     FROM   hig_process_areas
          , hig_process_types
     WHERE  hpt_process_type_id = pi_process_type_id
     AND    hpa_area_type = hpt_area_type;
 
  lv_retval    nm3type.max_varchar2;
  --                                 
  BEGIN

     OPEN c1;
     FETCH c1 INTO lv_retval;
     CLOSE c1;
     
     IF lv_retval IS NULL THEN
     
      IF pi_include_dummy = 'Y' THEN
        RETURN('select ''None'' meaning, null id from dual');
      ELSE
        RETURN('select null meaning, null from dual where 1=2');
      END IF;  
      
     ELSE 
      RETURN(lv_retval);
     END IF; 
     
  EXCEPTION
     WHEN others THEN
         RETURN Null;

  END get_process_type_area;
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE process_area_type_lov(pi_process_type_id  IN     hig_process_types.hpt_process_type_id%TYPE
                                 ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor     OUT  sys_refcursor
                                 ,po_cursor             OUT  sys_refcursor)
  IS
  --
  lv_retval varchar2(4000);
  lv_sql    varchar2(4000);
  --
  BEGIN
    --
    lv_sql := get_process_type_area(pi_process_type_id => pi_process_type_id);
    --
    OPEN po_cursor 
     FOR lv_sql;    
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END process_area_type_lov;                                                                                                                                                 
  --
  -----------------------------------------------------------------------------
  --
  --until its decided what data the UI needs, the api out params are as per the from, this will be updated once the design has been reviewed--
  PROCEDURE create_and_schedule_process(pi_process_type_id          IN     hig_processes.hp_process_type_id%TYPE
                                       ,pi_initiated_by_username    IN     hig_processes.hp_initiated_by_username%TYPE DEFAULT Sys_Context('NM3_SECURITY_CTX','USERNAME')
                                       ,pi_initiators_ref           IN     hig_processes.hp_initiators_ref%TYPE
                                       ,pi_start_date               IN     DATE
                                       ,pi_frequency_id             IN     hig_processes.hp_frequency_id%TYPE
                                       ,pi_area_id                  IN     hig_processes.hp_area_id%TYPE DEFAULT NULL
                                       ,po_process_id                  OUT hig_processes.hp_process_id%TYPE
                                       ,po_scheduled_start_date        OUT date
                                       ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  lv_job_name              hig_processes.hp_job_name%TYPE;
  --
  BEGIN
    --
    SAVEPOINT create_process_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_user) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value =>  pi_start_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value =>  pi_frequency_id);
    --
    --start date >= sysdate
    IF NOT valid_date(pi_date => pi_start_date)
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 110
                     ,pi_supplementary_info  => 'Start Date must be greater or equal to todays''s date: '||pi_start_date);
    END IF;
    -- 
    --valid frequency id
    IF frequency_exists(pi_frequency_id  =>  pi_frequency_id) = 'N'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Frequency Id: '||pi_frequency_id);
    END IF;
    --
    hig_process_api.create_and_schedule_process(pi_process_type_id         => pi_process_type_id
                                               ,pi_initiated_by_username   => pi_initiated_by_username
                                               ,pi_initiators_ref          => pi_initiators_ref
                                               ,pi_start_date              => pi_start_date
                                               ,pi_frequency_id            => pi_frequency_id
                                               ,pi_area_id                 => pi_area_id 
                                               ,po_process_id              => po_process_id 
                                               ,po_job_name                => lv_job_name
                                               ,po_scheduled_start_date    => po_scheduled_start_date); 
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_process_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_and_schedule_process;  
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_process(pi_process_type_id  IN      hig_process_types.hpt_process_type_id%TYPE
                          ,pi_job_owner        IN      hig_processes.hp_job_owner%TYPE
                          ,pi_job_name         IN      hig_processes.hp_job_name%TYPE
                          ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  	lt_Delete_Tab			Hig2520.t_Delete_Tab;
  	lt_Exceptions_Tab 		Hig2520.t_Bulk_Exceptions_Tab;
  --
  BEGIN
    --
    SAVEPOINT delete_process_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_user) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Type Id'
                               ,pi_parameter_value =>  pi_process_type_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Job Owner'
                               ,pi_parameter_value =>  pi_job_owner);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Job Name'
                               ,pi_parameter_value =>  pi_job_name);
    --
    lt_delete_tab(1).process_id := pi_process_type_id;
    lt_delete_tab(1).job_owner  := pi_job_owner;
    lt_delete_tab(1).job_name   := pi_job_name;
    --
    hig2520.delete_processes(p_delete_tab      =>  lt_delete_tab
	      		            ,p_exceptions_tab  =>  lt_exceptions_tab);
    --
    IF lt_exceptions_tab.count > 0 
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 514
                     ,pi_supplementary_info => 'Job Name: '||pi_job_name ||' '||lt_exceptions_tab(1).Error_Code);
    END IF;  
    --  
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_process_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_process;  
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE delete_processes(pi_delete_tab       IN      hig2520.t_delete_tab
                            ,pi_exceptions_tab   IN      hig2520.t_bulk_exceptions_tab
                            ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor      OUT  sys_refcursor)
   IS
   --
   lt_delete_tab			hig2520.t_delete_tab;
   lt_exceptions_tab 		hig2520.t_bulk_exceptions_tab;
   --
   lv_message_severity      hig_codes.hco_code%TYPE;
   lv_message_cursor        sys_refcursor;	
   lv_idx                   pls_integer;
  --
  BEGIN                         
    --  
    lv_idx:= pi_delete_tab.FIRST;
    WHILE lv_idx IS NOT NULL
     --
     LOOP 
        delete_process(pi_process_type_id  =>  pi_delete_tab(lv_idx).process_id
                      ,pi_job_owner        =>  pi_delete_tab(lv_idx).job_owner
                      ,pi_job_name         =>  pi_delete_tab(lv_idx).job_name
                      ,po_message_severity =>  lv_message_severity
                      ,po_message_cursor   =>  lv_message_cursor);
        --              
        lv_Idx:=pi_delete_tab.NEXT(lv_Idx);
        --
     END LOOP;
     --                                                    
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_process_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_processes;                                                                          
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE edit_process(pi_old_process_id           IN     hig_processes.hp_process_id%TYPE
                        ,pi_old_job_name             IN     hig_processes.hp_job_name%TYPE
                        ,pi_old_initiators_ref       IN     hig_processes.hp_initiators_ref%TYPE
                        ,pi_old_frequency_id         IN     hig_processes.hp_frequency_id%TYPE
                        ,pi_old_area_id              IN     hig_processes.hp_area_id%TYPE
                        ,pi_old_scheduled_start_date IN     date
                        ,pi_new_process_id           IN     hig_processes.hp_process_id%TYPE
                        ,pi_new_job_name             IN     hig_processes.hp_job_name%TYPE
                        ,pi_new_initiators_ref       IN     hig_processes.hp_initiators_ref%TYPE
                        ,pi_new_frequency_id         IN     hig_processes.hp_frequency_id%TYPE
                        ,pi_new_area_id              IN     hig_processes.hp_area_id%TYPE
                        ,pi_new_scheduled_start_date IN     date
                        ,po_message_severity            OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor              OUT sys_refcursor)
  IS
    --
    lr_db_rec                  hig_processes%ROWTYPE;
    lv_upd                     VARCHAR2(1) := 'N';
    lv_we_disabled_the_process BOOLEAN := FALSE;
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_processes
       WHERE hp_process_id = pi_old_process_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Process does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT amend_process_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_user) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Id'
                               ,pi_parameter_value =>  pi_new_process_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Job Name'
                               ,pi_parameter_value =>  pi_new_job_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency'
                               ,pi_parameter_value =>  pi_new_frequency_id);
    --
    IF NOT hig_process_framework.process_is_disabled(pi_process_id => pi_old_process_id) 
      THEN
        hig_process_api.disable_process(pi_process_id => pi_old_process_id);
        --disable_process(pi_process_id => pi_old_process_id);
        lv_we_disabled_the_process := TRUE;
    END IF;  
    --
    hig_process_framework.check_process_can_be_amended(pi_process_id => pi_old_process_id);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.hp_process_id != pi_old_process_id
     OR (lr_db_rec.hp_process_id IS NULL AND pi_old_process_id IS NOT NULL)
     OR (lr_db_rec.hp_process_id IS NOT NULL AND pi_old_process_id IS NULL)
     --
     OR (lr_db_rec.hp_job_name != pi_old_job_name)
     OR (lr_db_rec.hp_job_name IS NULL AND pi_old_job_name IS NOT NULL)
     OR (lr_db_rec.hp_job_name IS NOT NULL AND pi_old_job_name IS NULL)
     --
     OR (lr_db_rec.hp_initiators_ref != pi_old_initiators_ref)
     OR (lr_db_rec.hp_initiators_ref IS NULL AND pi_old_initiators_ref IS NOT NULL)
     OR (lr_db_rec.hp_initiators_ref IS NOT NULL AND pi_old_initiators_ref IS NULL)
     --
     OR (lr_db_rec.hp_frequency_id != pi_old_frequency_id)
     OR (lr_db_rec.hp_frequency_id IS NULL AND pi_old_frequency_id IS NOT NULL)
     OR (lr_db_rec.hp_frequency_id IS NOT NULL AND pi_old_frequency_id IS NULL)
     --
     OR (lr_db_rec.hp_area_id != pi_old_area_id)
     OR (lr_db_rec.hp_area_id IS NULL AND pi_old_area_id IS NOT NULL)
     OR (lr_db_rec.hp_area_id IS NOT NULL AND pi_old_area_id IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_process_id != pi_new_process_id
       OR (pi_old_process_id IS NULL AND pi_new_process_id IS NOT NULL)
       OR (pi_old_process_id IS NOT NULL AND pi_new_process_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_job_name != pi_new_job_name
       OR (pi_old_job_name IS NULL AND pi_new_job_name IS NOT NULL)
       OR (pi_old_job_name IS NOT NULL AND pi_new_job_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_initiators_ref != pi_new_initiators_ref
       OR (pi_old_initiators_ref IS NULL AND pi_new_initiators_ref IS NOT NULL)
       OR (pi_old_initiators_ref IS NOT NULL AND pi_new_initiators_ref IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_frequency_id != pi_new_frequency_id
       OR (pi_old_frequency_id IS NULL AND pi_new_frequency_id IS NOT NULL)
       OR (pi_old_frequency_id IS NOT NULL AND pi_new_frequency_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_area_id != pi_new_area_id
       OR (pi_old_area_id IS NULL AND pi_new_area_id IS NOT NULL)
       OR (pi_old_area_id IS NOT NULL AND pi_new_area_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_scheduled_start_date != pi_new_scheduled_start_date
       OR (pi_old_scheduled_start_date IS NULL AND pi_new_scheduled_start_date IS NOT NULL)
       OR (pi_old_scheduled_start_date IS NOT NULL AND pi_new_scheduled_start_date IS NULL)
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
        hig_process_api.amend_process(pi_process_id      =>  pi_old_process_id
                                     ,pi_job_name        =>  pi_old_job_name
                                     ,pi_initiators_ref  =>  pi_new_initiators_ref
                                     ,pi_frequency_id    =>  pi_new_frequency_id
                                     ,pi_area_id         =>  pi_new_area_id
                                     ,pi_scheduled_date  =>  pi_new_scheduled_start_date);
        --
        IF lv_we_disabled_the_process 
         THEN
           --
  	       hig_process_api.enable_process(pi_process_Id => pi_old_process_id);
  	       --
        END IF;
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
    WHEN OTHERS
     THEN
        ROLLBACK TO amend_process_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END edit_process;                         
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_job_state(pi_process_id       IN      hig_processes.hp_process_id%TYPE
                         ,po_job_state           OUT  hig_processes_v.hpj_job_state%TYPE)
  IS 
  --
  BEGIN
    --
    SELECT UPPER(hpj_job_state)
      INTO po_job_state
      FROM hig_processes_v
     WHERE hp_process_id =  pi_process_id;       
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        po_job_state := null;
    --    
  END get_job_state;                                                                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE enable_process(pi_process_id       IN      hig_processes.hp_process_id%TYPE
                          ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  lv_job_state   hig_processes_v.hpj_job_state%TYPE;
  --
  BEGIN
    --
    SAVEPOINT enable_process_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Id'
                               ,pi_parameter_value =>  pi_process_id);
    --
    --will only enable a disabled process --
    get_job_state(pi_process_id  =>  pi_process_id
                 ,po_job_state   =>  lv_job_state);
    --
    IF lv_job_state = 'DISABLED'
      THEN
        hig_process_api.enable_process(pi_process_id => pi_process_id);
    -- 
    ELSE 
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  556
                     ,pi_supplementary_info  => 'Process Id: '||pi_process_id);
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO enable_process_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END enable_process;                        

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE disable_process(pi_process_id       IN      hig_processes.hp_process_id%TYPE
                           ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT disable_process_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Id'
                               ,pi_parameter_value =>  pi_process_id);
    
    -- will only disable a process which is scheduled to run --
    hig_process_api.disable_process(pi_process_id => pi_process_id);
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO disable_process_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END disable_process;    
  
  --                         
  -----------------------------------------------------------------------------
  --
  PROCEDURE stop_execution(pi_process_id       IN      hig_processes.hp_process_id%TYPE
                          ,pi_job_run_seq      IN      hig_process_job_runs.hpjr_job_run_seq%TYPE
                          ,pi_reason_to_stop   IN      varchar2
                          ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT  sys_refcursor)
  
  IS
  --
  BEGIN
    --
    SAVEPOINT stop_execution_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Id'
                               ,pi_parameter_value =>  pi_process_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Job Run Sequence'
                               ,pi_parameter_value =>  pi_job_run_seq);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Reason To Stop'
                               ,pi_parameter_value =>  pi_reason_to_stop);
    -- 
    nm3ctx.set_context('HP_PROCESS_ID',pi_process_id);
    nm3ctx.set_context('HPJR_RUN_SEQ',pi_job_run_seq); 
    --
    hig_process_api.stop_process(pi_process_id => pi_process_id
                                ,pi_reason     => pi_reason_to_stop);
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO stop_execution_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END stop_execution; 
  
  --                         
  -----------------------------------------------------------------------------
  --
  PROCEDURE run_process_now(pi_process_id       IN      hig_processes.hp_process_id%TYPE
                           ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor      OUT  sys_refcursor)
   IS
  --
  BEGIN
    --
    SAVEPOINT run_now_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Process Id'
                               ,pi_parameter_value =>  pi_process_id);
    --
    hig_process_framework.check_process_can_run_now(pi_process_id => pi_process_id);
    --
    hig_process_api.run_process_now(pi_process_id => pi_process_id);
	-- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO run_now_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END run_process_now;                       
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE process_types_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT  sys_refcursor
                             ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpt_process_type_id  process_type_id
          ,hpt_name             process_type_name
      FROM hig_process_types
    ORDER BY hpt_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END process_types_lov;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE process_type_lov(pi_process_type_id  IN     hig_processes.hp_process_type_id%TYPE
                            ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor     OUT  sys_refcursor
                            ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpt_process_type_id  process_type_id
          ,hpt_name             process_type_name
      FROM hig_process_types
     WHERE hpt_process_type_id = pi_process_type_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END process_type_lov;      
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE process_type_roles_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT  sys_refcursor
                                  ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hro_role     role_
          ,hro_descr    role_descr
      FROM hig_roles
    ORDER BY hro_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END process_type_roles_lov;                                  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE frequencies_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT  sys_refcursor
                           ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hsfr_frequency_id   frequency_id
          ,hsfr_meaning        freq_descr
      FROM hig_scheduling_frequencies
    ORDER BY freq_descr;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END frequencies_lov;                          
                                 
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE frequency_lov(pi_frequency_id     IN     hig_scheduling_frequencies.hsfr_frequency_id%TYPE
                         ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor     OUT  sys_refcursor
                         ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hsfr_frequency_id   frequency_id
          ,hsfr_meaning        freq_descr
      FROM hig_scheduling_frequencies
     WHERE hsfr_frequency_id = pi_frequency_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END frequency_lov;        
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_job_runs(pi_process_id       IN     hig_process_job_runs.hpjr_process_id%TYPE
                                ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor     OUT  sys_refcursor
                                ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpjr_process_id               process_id
          ,hpjr_job_run_seq              job_run_seq 
          ,hpjr_start_date               start_date  
          ,hpjr_end_date                 end_date 
          ,hpjr_success_flag             success_flag
          ,hpjr_success_flag_meaning     success_flag_meaning 
          ,hpjr_additional_info          additional_info 
      FROM hig_process_job_runs_v
     WHERE hpjr_process_id = pi_process_id
    ORDER BY hpjr_job_run_seq DESC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_job_runs;                                 
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_job_runs(pi_process_id           IN     hig_process_job_runs.hpjr_process_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpjr_process_id               process_id
                                                     ,hpjr_job_run_seq              job_run_seq 
                                                     ,hpjr_start_date               start_date  
                                                     ,hpjr_end_date                 end_date 
                                                     ,hpjr_success_flag             success_flag
                                                     ,hpjr_success_flag_meaning     success_flag_meaning    
                                                     ,hpjr_additional_info          additional_info    
                                                 FROM hig_process_job_runs_v
                                                WHERE hpjr_process_id = :pi_process_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                   ||',job_run_seq'
                                                   ||',start_date' 
                                                   ||',end_date'
                                                   ||',success_flag' 
                                                   ||',success_flag_meaning'
                                                   ||',additional_info'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                                ,pi_query_col    => 'hpjr_process_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_run_seq'
                                ,pi_query_col    => 'hpjr_job_run_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'hpjr_start_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                                ,pi_query_col    => 'hpjr_end_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'success_flag'
                                ,pi_query_col    => 'hpjr_success_flag'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'success_flag_meaning'
                                ,pi_query_col    => 'hpjr_success_flag_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'additional_info'
                                ,pi_query_col    => 'hpjr_additional_info'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpjr_job_run_seq DESC')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_job_runs;
  
  --
  -----------------------------------------------------------------------------
  --
  /*
  PROCEDURE get_polled_locations(pi_process_id       IN     hig_process_job_runs.hpjr_process_id%TYPE
                                ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor     OUT  sys_refcursor
                                ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hp_process_id    process_id
          ,hfc_id           hfc_id
          ,hfc_hft_id       hfc_hft_id
          ,hfc_name         ftp_name
          ,hfc_ftp_host     ftp_host
          ,hfc_ftp_in_dir   ftp_in_dir
      FROM hig_process_polled_conns_v
      WHERE hp_process_id = pi_process_id
    ORDER BY hfc_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_polled_locations;                                  
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_polled_locations(pi_process_id           IN     hig_process_job_runs.hpjr_process_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hp_process_id    process_id
                                                     ,hfc_id           hfc_id
                                                     ,hfc_hft_id       hfc_hft_id
                                                     ,hfc_name         ftp_name
                                                     ,hfc_ftp_host     ftp_host
                                                     ,hfc_ftp_in_dir   ftp_in_dir
                                                 FROM hig_process_polled_conns_v
                                                 WHERE hp_process_id = :pi_process_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                   ||',hfc_id'
                                                   ||',hfc_hft_id' 
                                                   ||',ftp_name'
                                                   ||',ftp_host' 
                                                   ||',ftp_in_dir'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                                ,pi_query_col    => 'hp_process_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'hfc_id'
                                ,pi_query_col    => 'hfc_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'hfc_hft_id'
                                ,pi_query_col    => 'hfc_hft_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'ftp_name'
                                ,pi_query_col    => 'hfc_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'ftp_host'
                                ,pi_query_col    => 'hfc_ftp_host'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'ftp_in_dir'
                                ,pi_query_col    => 'hfc_ftp_in_dir'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
    
      /*
      ||Get the page parameters.
      */    
      /*
      awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                    ,pi_skip_n_rows  => pi_skip_n_rows
                                    ,pi_pagesize     => pi_pagesize
                                    ,po_lower_index  => lv_lower_index
                                    ,po_upper_index  => lv_upper_index
                                    ,po_statement    => lv_row_restriction);
      /*
      ||Get the Order By clause.
      */
      /*
      lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                            ,pi_order_asc_desc => pi_order_asc_desc);
      /*
      ||Process the filter.
      */
      /*
      IF pi_filter_columns.COUNT > 0
       THEN
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hfc_id')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_polled_locations;
  */
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_files(pi_process_id       IN     hig_process_log.hpl_process_id%TYPE
                             ,pi_job_run_seq      IN     hig_process_log.hpl_job_run_seq%TYPE
                             ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor     OUT  sys_refcursor
                             ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpf_process_id                process_id
          ,hpf_file_id                   file_id
          ,hpf_job_run_seq               job_run_seq  
          ,hpjr_start_date               start_date
          ,hpjr_end_date                 end_date 
          ,hpjr_success_flag_meaning     success_flag 
          ,hpf_input_or_output_meaning   io_meaning
          ,hpf_file_type_name            file_type_meaning
          ,hpf_filename                  filename
          ,hpf_destination               destination   
          ,hpf_destination_type_meaning  dest_type_meaning
      FROM hig_process_files_v
     WHERE hpf_process_id   = pi_process_id
       AND hpf_job_run_seq  = pi_job_run_seq 
     ORDER BY hpf_job_run_seq ASC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_files;                           
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_files(pi_process_id           IN     hig_process_log.hpl_process_id%TYPE
                                   ,pi_job_run_seq          IN     hig_process_log.hpl_job_run_seq%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpf_process_id                process_id
                                                     ,hpf_file_id                   file_id
                                                     ,hpf_job_run_seq               job_run_seq  
                                                     ,hpjr_start_date               start_date
                                                     ,hpjr_end_date                 end_date 
                                                     ,hpjr_success_flag_meaning     success_flag 
                                                     ,hpf_input_or_output_meaning   io_meaning
                                                     ,hpf_file_type_name            file_type_meaning
                                                     ,hpf_filename                  filename
                                                     ,hpf_destination               destination   
                                                     ,hpf_destination_type_meaning  dest_type_meaning
                                                 FROM hig_process_files_v
                                                WHERE hpf_process_id   = :pi_process_id
                                                  AND hpf_job_run_seq  = :pi_job_run_seq ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                   ||',file_id'
                                                   ||',job_run_seq' 
                                                   ||',start_date'
                                                   ||',end_date' 
                                                   ||',success_flag'
                                                   ||',io_meaning'
                                                   ||',file_type_meaning' 
                                                   ||',filename'
                                                   ||',destination' 
                                                   ||',dest_type_meaning'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                                ,pi_query_col    => 'hpf_process_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'file_id'
                                ,pi_query_col    => 'hpf_file_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_run_seq'
                                ,pi_query_col    => 'hpf_job_run_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);                               
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'hpjr_start_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                                ,pi_query_col    => 'hpjr_end_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'success_flag'
                                ,pi_query_col    => 'hpjr_success_flag'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'io_meaning'
                                ,pi_query_col    => 'hpf_input_or_output_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'file_type_meaning'
                                ,pi_query_col    => 'hpf_file_type_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'filename'
                                ,pi_query_col    => 'hpf_filename'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);                          
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'destination'
                                ,pi_query_col    => 'hpf_destination'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'dest_type_meaning'
                                ,pi_query_col    => 'hpf_dest_type_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpf_job_run_seq')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,pi_job_run_seq
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,pi_job_run_seq
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_files;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_params(pi_process_id       IN     hig_process_job_runs.hpjr_process_id%TYPE
                              ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor     OUT  sys_refcursor
                              ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpp_process_id  process_id
          ,hpp_seq         param_seq 
          ,hpp_param_name  param_name
          ,hpp_param_value param_value
      FROM hig_process_params
     WHERE hpp_process_id = pi_process_id
    ORDER by hpp_seq;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_params;                              
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_params(pi_process_id           IN     hig_process_job_runs.hpjr_process_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpp_process_id  process_id
                                                     ,hpp_seq         param_seq 
                                                     ,hpp_param_name  param_name
                                                     ,hpp_param_value param_value
                                                 FROM hig_process_params
                                                WHERE hpp_process_id = :pi_process_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                   ||',param_seq'
                                                   ||',param_name' 
                                                   ||',param_value'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                                ,pi_query_col    => 'hpp_process_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'param_seq'
                                ,pi_query_col    => 'hpp_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'param_name'
                                ,pi_query_col    => 'hpp_param_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'param_value'
                                ,pi_query_col    => 'hpp_param_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpp_seq')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_params;                                                                                                     
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_job_log(pi_process_id       IN     hig_process_log.hpl_process_id%TYPE
                               ,pi_job_run_seq      IN     hig_process_log.hpl_job_run_seq%TYPE
                               ,pi_summary_flag     IN     hig_process_log.hpl_summary_flag%TYPE  DEFAULT 'Y' 
                               ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor     OUT  sys_refcursor
                               ,po_cursor             OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpl_process_id            process_id
          ,hpl_job_run_seq           job_run_seq 
          ,hpl_log_seq               log_seq 
          ,hpl_message               message
          ,hpl_message_type          message_type
          ,hpl_message_type_meaning  message_type_meaning
      FROM hig_process_log_v
     WHERE hpl_process_id   = pi_process_id
       AND hpl_job_run_seq  = pi_job_run_seq 
       AND hpl_summary_flag IN  ('Y', pi_summary_flag)  -- we need to always return data where summary flag = 'Y' regardless of pi_summary_flag value --
    ORDER BY hpl_log_seq ASC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_job_log;                                
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_process_job_log(pi_process_id           IN     hig_process_log.hpl_process_id%TYPE
                                     ,pi_job_run_seq          IN     hig_process_log.hpl_job_run_seq%TYPE
                                     ,pi_summary_flag         IN     hig_process_log.hpl_summary_flag%TYPE  DEFAULT 'Y' 
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT hpl_process_id            process_id
                                                     ,hpl_job_run_seq           job_run_seq 
                                                     ,hpl_log_seq               log_seq 
                                                     ,hpl_message               message
                                                     ,hpl_message_type          message_type
                                                     ,hpl_message_type_meaning  message_type_meaning
                                                 FROM hig_process_log_v
                                                WHERE hpl_process_id   = :pi_process_id
                                                  AND hpl_job_run_seq  = :pi_job_run_seq 
                                                  AND hpl_summary_flag IN  (''Y'', :pi_summary_flag) ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                   ||',job_run_seq'
                                                   ||',log_seq' 
                                                   ||',message'
                                                   ||',message_type' 
                                                   ||',message_type_meaning'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                                ,pi_query_col    => 'hpl_process_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_run_seq'
                                ,pi_query_col    => 'hpl_job_run_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'log_seq'
                                ,pi_query_col    => 'hpl_log_seq'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'message'
                                ,pi_query_col    => 'hpl_message'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'message_type'
                                ,pi_query_col    => 'hpl_message_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'message_type_meaning'
                                ,pi_query_col    => 'hpl_message_type_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
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
          
          set_column_data(po_column_data => lt_column_data);
          
          awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                   ,pi_column_data  => lt_column_data
                                   ,pi_operators    => pi_filter_operators
                                   ,pi_values_1     => pi_filter_values_1
                                   ,pi_values_2     => pi_filter_values_2
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpl_log_seq')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,pi_job_run_seq
               ,pi_summary_flag
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_process_id
               ,pi_job_run_seq
               ,pi_summary_flag
               ,lv_lower_index;
      END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_process_job_log;     
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_scheduler_state(po_scheduler_state  OUT  VARCHAR2
                               ,po_message_severity OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT  sys_refcursor)  
  IS
  --
  BEGIN
    --
     awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    po_scheduler_state := nm3jobs.get_scheduler_state;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_scheduler_state;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_scheduler_state(pi_scheduler_state  IN     VARCHAR2
                               ,po_message_severity   OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor     OUT  sys_refcursor) 
  IS
  --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    IF pi_scheduler_state NOT IN ('UP', 'DOWN')
    THEN
       hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Scheduler State:  '||pi_scheduler_state);
	END IF;
    --
    hig_process_admin.set_scheduler_state(pi_scheduler_state);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_scheduler_state; 
   --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_running_processes(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT  sys_refcursor
                                 ,po_cursor              OUT  sys_refcursor)  IS
  --
  BEGIN
    --
     awlrs_util.check_historic_mode;  
    --
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    OPEN po_cursor FOR
    SELECT hp_process_id
	      ,hp_formatted_process_id
		  ,hp_process_type_name
		  ,hp_polling_flag
		  ,hpj_last_run_date
      FROM hig_processes_all_v
	 WHERE UPPER(hpj_job_state) = 'RUNNING'
    ORDER BY hpj_last_run_date DESC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_running_processes;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_running_processes(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT hp_process_id             process_id
                                                   ,hp_formatted_process_id   formatted_process_id
                                                   ,hp_process_type_name      process_type_name
                                                   ,hp_polling_flag           polling_flag
                                                   ,hpj_last_run_date         last_run_date
                                              FROM hig_processes_all_v
                                             WHERE UPPER(hpj_job_state) = ''RUNNING''';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   process_id'
                                                 ||',formatted_process_id'
                                                 ||',process_type_name' 
                                                 ||',polling_flag'
                                                 ||',last_run_date' 
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
    awlrs_util.add_column_data(pi_cursor_col   => 'process_id'
                              ,pi_query_col    => 'hp_process_id'
                              ,pi_datatype     => awlrs_util.c_number_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'formatted_process_id'
                              ,pi_query_col    => 'hp_formatted_process_id'
                              ,pi_datatype     => awlrs_util.c_varchar2_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'process_type_name'
                              ,pi_query_col    => 'hp_process_type_name'
                              ,pi_datatype     => awlrs_util.c_varchar2_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'polling_flag'
                              ,pi_query_col    => 'hp_polling_flag'
                              ,pi_datatype     => awlrs_util.c_varchar2_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'last_run_date'
                              ,pi_query_col    => 'hpj_last_run_date'
                              ,pi_datatype     => awlrs_util.c_datetime_col
                              ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                              ,pio_column_data => po_column_data);
    --     
  END set_column_data;
  --
BEGIN
    --
     awlrs_util.check_historic_mode;  
    --
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_process_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
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
        
        set_column_data(po_column_data => lt_column_data);
        
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                 ,po_where_clause => lv_filter);
        
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hpj_last_run_date DESC')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_running_processes;
                                                                                                                                                                                                                                                                        
  --
  -----------------------------------------------------------------------------
  --
  
END awlrs_process_framework_api;
/
