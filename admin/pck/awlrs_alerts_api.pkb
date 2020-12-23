CREATE OR REPLACE PACKAGE BODY awlrs_alerts_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_alerts_api.pkb-arc   1.3   Dec 23 2020 13:17:40   Barbara.Odriscoll  $
  --       Date into PVCS   : $Date:   Dec 23 2020 13:17:40  $
  --       Module Name      : $Workfile:   awlrs_alerts_api.pkb  $
  --       Date fetched Out : $Modtime:   Dec 23 2020 11:31:42  $
  --       Version          : $Revision:   1.3  $
  --
  -----------------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated.  All rights reserved.
  -----------------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT  VARCHAR2(2000) := '"$Revision:   1.3  $"';
  g_package_name  CONSTANT  VARCHAR2 (30)  := 'awlrs_alerts_api';
  --
  --Role constants--
  cv_hig_admin    CONSTANT VARCHAR2(9)     := 'HIG_ADMIN';
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
  FUNCTION privs_check (pi_role_name  IN  varchar2) 
    RETURN VARCHAR2  
  IS
     lv_exists varchar2(1) := 'N';
  BEGIN
      --
      SELECT  'Y'
      INTO    lv_exists
      FROM    dba_role_privs
      WHERE   granted_role = pi_role_name
      AND     grantee      = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME');
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
  FUNCTION get_screen_text(pi_ita_inv_type    IN  nm_inv_type_attribs.ita_inv_type%TYPE
                          ,pi_ita_attrib_name IN  nm_inv_type_attribs.ita_attrib_name%TYPE) RETURN nm_inv_type_attribs.ita_scrn_text%TYPE
  IS
  --
    lr_ita_rec  nm_inv_type_attribs%ROWTYPE;
    lv_retval   nm_inv_type_attribs.ita_scrn_text%TYPE;
  --  
  BEGIN
     --
     lr_ita_rec := nm3get.get_ita(pi_ita_inv_type      => pi_ita_inv_type
	                            ,pi_ita_attrib_name   => pi_ita_attrib_name);
     --
     lv_retval := lr_ita_rec.ita_scrn_text;
     --
     RETURN lv_retval;
     --
END get_screen_text; 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_trg_alert_types(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT halt_alert_type         alert_type
          ,halt_id                 alert_id
          ,halt_nit_inv_type       inv_type
          ,nit_descr               alert_for
          ,halt_description        descr_
          ,halt_operation          operation
          ,halt_table_name         table_name
          ,halt_trigger_name       trigger_name
          ,CASE 
             WHEN halt_trigger_name IS NULL THEN 'Not Created'
             ELSE hig_alert.get_trigger_status(pi_trigger_name => halt_trigger_name)
           END                     trg_status   
          ,halt_immediate          immediate_
          ,halt_trigger_count      batch_email_threshold
          ,halt_frequency_id       batch_email_freq_id
          ,hsfr_meaning            batch_email_freq_descr
      FROM hig_alert_types
          ,nm_inv_types_all
          ,hig_scheduling_frequencies
     WHERE halt_alert_type   = 'T'     
       AND halt_nit_inv_type = nit_inv_type(+)
       AND halt_frequency_id = hsfr_frequency_id(+)
    ORDER BY halt_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_trg_alert_types;                                                          

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_trg_alert_type(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT halt_alert_type         alert_type
          ,halt_id                 alert_id
          ,halt_nit_inv_type       inv_type
          ,nit_descr               alert_for
          ,halt_description        descr_
          ,halt_operation          operation
          ,halt_table_name         table_name
          ,halt_trigger_name       trigger_name
          ,CASE 
             WHEN halt_trigger_name IS NULL THEN 'Not Created'
             ELSE hig_alert.get_trigger_status(pi_trigger_name => halt_trigger_name)
           END                     trg_status   
          ,halt_immediate          immediate_
          ,halt_trigger_count      batch_email_threshold
          ,halt_frequency_id       batch_email_freq_id
          ,hsfr_meaning            batch_email_freq_descr
      FROM hig_alert_types
          ,nm_inv_types_all
          ,hig_scheduling_frequencies
     WHERE halt_alert_type   = 'T'          
       AND halt_id           = pi_alert_id     
       AND halt_nit_inv_type = nit_inv_type(+)
       AND halt_frequency_id = hsfr_frequency_id(+);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_trg_alert_type;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_trg_alert_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_cursor_sql  nm3type.max_varchar2 :='SELECT halt_alert_type    alert_type'
                                                 ||',halt_id            alert_id'
                                                 ||',halt_nit_inv_type  inv_type'
                                                 ||',nit_descr          alert_for'
                                                 ||',halt_description   descr_'
                                                 ||',halt_operation     operation'
                                                 ||',halt_table_name    table_name'
                                                 ||',halt_trigger_name  trigger_name'
                                                 ||',CASE'
                                                   ||' WHEN halt_trigger_name IS NULL THEN ''Not Created'''
                                                   ||' ELSE hig_alert.get_trigger_status(pi_trigger_name => halt_trigger_name)'
                                                 ||' END                trg_status'
                                                 ||',halt_immediate     immediate_'
                                                 ||',halt_trigger_count batch_email_threshold'
                                                 ||',halt_frequency_id  batch_email_freq_id'
                                                 ||',hsfr_meaning       batch_email_freq_descr'
                                                 ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                            ||' FROM hig_alert_types'
                                                 ||',nm_inv_types_all'
                                                 ||',hig_scheduling_frequencies'
                                           ||' WHERE halt_alert_type   = ''T'''
                                             ||' AND halt_nit_inv_type = nit_inv_type(+)'
                                             ||' AND halt_frequency_id = hsfr_frequency_id(+)';
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_type'
                                ,pi_query_col    => 'halt_alert_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_for'
                                ,pi_query_col    => 'nit_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'descr_'
                                ,pi_query_col    => 'halt_description'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'operation'
                                ,pi_query_col    => 'halt_operation'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'trg_status'
                                ,pi_query_col    => 'CASE'
                                                   ||' WHEN halt_trigger_name IS NULL THEN ''Not Created'''
                                                   ||' ELSE hig_alert.get_trigger_status(pi_trigger_name => halt_trigger_name)'
                                                 ||' END'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'immediate_'
                                ,pi_query_col    => 'halt_immediate'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'batch_email_threshold'
                                ,pi_query_col    => 'halt_trigger_count'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'batch_email_freq_descr'
                                ,pi_query_col    => 'hsfr_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'halt_id')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_trg_alert_types;  
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sched_alert_types(po_message_severity        OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor          OUT sys_refcursor
                                 ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT halt_alert_type         alert_type
          ,halt_id                 alert_id
          ,halt_nit_inv_type       inv_type
          ,halt_hqt_id             query_id
          ,hqt_name                query_name   
          ,halt_description        descr_
          ,halt_frequency_id       frequency_id
          ,hsfr_meaning            freq_descr
          ,halt_last_run_date      last_run_date
          ,halt_next_run_date      next_run_date
          ,halt_suspend_query      suspend_query
      FROM hig_alert_types
          ,nm_inv_types_all
          ,hig_query_types
          ,hig_scheduling_frequencies
     WHERE halt_alert_type   = 'Q'
       AND halt_nit_inv_type = nit_inv_type(+)
       AND halt_hqt_id       = hqt_id(+) 
       AND halt_frequency_id = hsfr_frequency_id(+)
    ORDER BY halt_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_sched_alert_types;                                                                                         

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sched_alert_type(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT halt_alert_type         alert_type
          ,halt_id                 alert_id
          ,halt_nit_inv_type       inv_type
          ,halt_hqt_id             query_id
          ,hqt_name                query_name   
          ,halt_description        descr_
          ,halt_frequency_id       frequency_id
          ,hsfr_meaning            freq_descr
          ,halt_last_run_date      last_run_date
          ,halt_next_run_date      next_run_date
          ,halt_suspend_query      suspend_query
      FROM hig_alert_types
          ,nm_inv_types_all
          ,hig_query_types
          ,hig_scheduling_frequencies
     WHERE halt_alert_type   = 'Q'
       AND halt_id           = pi_alert_id
       AND halt_nit_inv_type = nit_inv_type(+)
       AND halt_hqt_id       = hqt_id(+) 
       AND halt_frequency_id = hsfr_frequency_id(+);       
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_sched_alert_type;                                                          

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_sched_alert_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2 :='SELECT halt_alert_type    alert_type'
                                              ||',halt_id            alert_id'
                                              ||',halt_nit_inv_type  inv_type'
                                              ||',halt_hqt_id        query_id'
                                              ||',hqt_name           query_name'
                                              ||',halt_description   descr_'
                                              ||',halt_frequency_id  frequency_id'
                                              ||',hsfr_meaning       freq_descr'
                                              ||',halt_last_run_date last_run_date'
                                              ||',halt_next_run_date next_run_date'
                                              ||',halt_suspend_query suspend_query'
                                              ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                         ||' FROM hig_alert_types'
                                              ||',nm_inv_types_all'
                                              ||',hig_query_types'
                                              ||',hig_scheduling_frequencies'
                                        ||' WHERE halt_alert_type   = ''Q'''
                                          ||' AND halt_nit_inv_type = nit_inv_type(+)'
                                          ||' AND halt_hqt_id       = hqt_id(+)'
                                          ||' AND halt_frequency_id = hsfr_frequency_id(+)';
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_type'
                                ,pi_query_col    => 'halt_alert_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_id'
                                ,pi_query_col    => 'halt_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'inv_type'
                                ,pi_query_col    => 'halt_nit_inv_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'query_id'
                                ,pi_query_col    => 'halt_hqt_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'query_name'
                                ,pi_query_col    => 'hqt_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'descr_'
                                ,pi_query_col    => 'halt_description'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'frequency_id'
                                ,pi_query_col    => 'halt_frequency_id'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'last_run_date'
                                ,pi_query_col    => 'halt_last_run_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'next_run_date'
                                ,pi_query_col    => 'halt_next_run_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'suspend_query'
                                ,pi_query_col    => 'halt_suspend_query'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'halt_id')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_sched_alert_types;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_type_attribs(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                                  ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                                  ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor          OUT sys_refcursor
                                  ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hata_halt_id            alert_id
          ,hata_id                 attrib_id
          ,hata_attribute_name     attrib_name
          ,ita_scrn_text           attrib_name_descr
      FROM hig_alert_type_attributes
          ,nm_inv_type_attribs_all
     WHERE hata_halt_id        = pi_alert_id
       AND hata_attribute_name = ita_attrib_name
       AND ita_inv_type        = pi_inv_type
    ORDER BY ita_scrn_text;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_alert_type_attribs;                                  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_type_attrib(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                                 ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                                 ,pi_attribute_name       IN     hig_alert_type_attributes.hata_attribute_name%TYPE 
                                 ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor          OUT sys_refcursor
                                 ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hata_halt_id            alert_id
          ,hata_id                 attrib_id
          ,hata_attribute_name     attrib_name
          ,ita_scrn_text           attrib_name_descr
      FROM hig_alert_type_attributes
          ,nm_inv_type_attribs_all
     WHERE hata_halt_id        = pi_alert_id
       AND hata_attribute_name = pi_attribute_name
       AND hata_attribute_name = ita_attrib_name
       AND ita_inv_type        = pi_inv_type
    ORDER BY ita_scrn_text;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_alert_type_attrib;                                                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_alert_type_attribs(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                                        ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2 :='SELECT hata_halt_id        alert_id'
                                              ||',hata_id             attrib_id'
                                              ||',hata_attribute_name attrib_name'
                                              ||',ita_scrn_text       attrib_name_descr'
                                              ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                         ||' FROM hig_alert_type_attributes'
                                              ||',nm_inv_type_attribs_all'
                                        ||' WHERE hata_halt_id        = :pi_alert_id'
                                          ||' AND hata_attribute_name = ita_attrib_name'
                                          ||' AND ita_inv_type        = :pi_inv_type'
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_id'
                                ,pi_query_col    => 'hata_halt_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'attrib_id'
                                ,pi_query_col    => 'hata_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'attrib_name'
                                ,pi_query_col    => 'hata_attribute_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'attrib_name_descr'
                                ,pi_query_col    => 'ita_scrn_text'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'ita_scrn_text')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql
    USING pi_alert_id
         ,pi_inv_type
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_alert_type_attribs; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_type_conds(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                                ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hatc_halt_id            alert_id
          ,hatc_id                 cond_id
          ,hatc_pre_bracket        cond_pre_bracket
          ,hatc_operator           cond_operator
          ,hatc_attribute_name     cond_attribute_name
          ,ita_scrn_text           attribute_name_text
          ,hatc_condition          cond_condition
          ,hatc_attribute_value    cond_attribute_value
          ,hatc_post_bracket       cond_post_bracket
          ,hatc_old_new_type       cond_old_new_type
          ,CASE 
             WHEN hatc_old_new_type = 'B' THEN 'Both'
             WHEN hatc_old_new_type = 'O' THEN 'Old Value'
             WHEN hatc_old_new_type = 'N' THEN 'New Value'
           END                     old_new_type_descr      
      FROM hig_alert_type_conditions
          ,nm_inv_type_attribs_all
     WHERE hatc_halt_id        = pi_alert_id
       AND hatc_attribute_name = ita_attrib_name
       AND ita_inv_type        = pi_inv_type
    ORDER BY hatc_halt_id, hatc_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_alert_type_conds;                                

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_type_cond(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                               ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                               ,pi_attribute_name       IN     hig_alert_type_attributes.hata_attribute_name%TYPE 
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hatc_halt_id            alert_id
          ,hatc_id                 cond_id
          ,hatc_pre_bracket        cond_pre_bracket
          ,hatc_operator           cond_operator
          ,hatc_attribute_name     cond_attribute_name
          ,ita_scrn_text           attribute_name_text
          ,hatc_condition          cond_condition
          ,hatc_attribute_value    cond_attribute_value
          ,hatc_post_bracket       cond_post_bracket
          ,hatc_old_new_type       cond_old_new_type
          ,CASE 
             WHEN hatc_old_new_type = 'B' THEN 'Both'
             WHEN hatc_old_new_type = 'O' THEN 'Old Value'
             WHEN hatc_old_new_type = 'N' THEN 'New Value'
           END                     old_new_type_descr
      FROM hig_alert_type_conditions
          ,nm_inv_type_attribs_all
     WHERE hatc_halt_id        = pi_alert_id
       AND hatc_attribute_name = pi_attribute_name
       AND hatc_attribute_name = ita_attrib_name
       AND ita_inv_type        = pi_inv_type
    ORDER BY hatc_halt_id, hatc_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_alert_type_cond;                                                       

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_recipients(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                               ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hatr_halt_id            alert_id
          ,hatr_id                 recip_id
          ,hatr_type               recip_type
          ,hatr_harr_id            recip_rule_id
          ,CASE
              WHEN hatr_harr_id IS NOT NULL AND harr_label IS NOT NULL THEN harr_label
              WHEN hatr_harr_id IS NOT NULL AND harr_label IS NULL
                THEN
                   awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                   ,pi_ita_attrib_name => harr_attribute_name)
           END                     recip_rule_descr 
          ,hatr_nmu_id             recip_user_id
          ,nmu_name                recip_user_name
          ,hatr_nmg_id             recip_group_id
          ,nmg_name                recip_group_name
      FROM hig_alert_type_recipients
          ,hig_alert_recipient_rules
          ,nm_mail_users
          ,nm_mail_groups
     WHERE hatr_halt_id        = pi_alert_id
       AND hatr_harr_id        = harr_id(+)
       AND hatr_nmu_id         = nmu_id(+)
       AND hatr_nmg_id         = nmg_id(+)
    ORDER BY hatr_type desc;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_recipients;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_details(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                            ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                            ,po_message_severity        OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor          OUT sys_refcursor
                            ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR                         
    SELECT hatm_halt_id            alert_id
          ,hatm_id                 mail_id
          ,hatm_mail_from          mail_from
          ,hatm_subject            mail_subject
          ,hatm_mail_text          mail_text
          ,hatm_param_1            param_1_code
          ,CASE WHEN hatm_param_1 IS NOT NULL AND hatm_p1_derived = 'Y' THEN hatm_param_1
                WHEN hatm_param_1 IS NOT NULL AND hatm_p1_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_1)
           END                     param_1_descr
          ,hatm_param_2            param_2
          ,CASE WHEN hatm_param_2 IS NOT NULL AND hatm_p2_derived = 'Y' THEN hatm_param_2
                WHEN hatm_param_2 IS NOT NULL AND hatm_p2_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_2)
           END                     param_2_descr
          ,hatm_param_3            param_3
          ,CASE WHEN hatm_param_3 IS NOT NULL AND hatm_p3_derived = 'Y' THEN hatm_param_3
                WHEN hatm_param_3 IS NOT NULL AND hatm_p3_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_3)
           END                     param_3_descr
          ,hatm_param_4            param_4_code
          ,CASE WHEN hatm_param_4 IS NOT NULL AND hatm_p4_derived = 'Y' THEN hatm_param_4
                WHEN hatm_param_4 IS NOT NULL AND hatm_p4_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_4)
           END                     param_4_descr
          ,hatm_param_5            param_5
          ,CASE WHEN hatm_param_5 IS NOT NULL AND hatm_p5_derived = 'Y' THEN hatm_param_5
                WHEN hatm_param_5 IS NOT NULL AND hatm_p5_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_5)
           END                     param_5_descr
          ,hatm_param_6            param_6
          ,CASE WHEN hatm_param_6 IS NOT NULL AND hatm_p6_derived = 'Y' THEN hatm_param_6
                WHEN hatm_param_6 IS NOT NULL AND hatm_p6_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_6)
           END                     param_6_descr
          ,hatm_param_7            param_7
          ,CASE WHEN hatm_param_7 IS NOT NULL AND hatm_p7_derived = 'Y' THEN hatm_param_7
                WHEN hatm_param_7 IS NOT NULL AND hatm_p7_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_7)
           END                     param_7_descr
          ,hatm_param_8            param_8
          ,CASE WHEN hatm_param_8 IS NOT NULL AND hatm_p8_derived = 'Y' THEN hatm_param_8
                WHEN hatm_param_8 IS NOT NULL AND hatm_p8_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_8)
           END                     param_8_descr
          ,hatm_param_9            param_9
          ,CASE WHEN hatm_param_9 IS NOT NULL AND hatm_p9_derived = 'Y' THEN hatm_param_9
                WHEN hatm_param_9 IS NOT NULL AND hatm_p9_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_9)
           END                     param_9_descr  
          ,hatm_param_10           param_10
          ,CASE WHEN hatm_param_10 IS NOT NULL AND hatm_p10_derived = 'Y' THEN hatm_param_10
                WHEN hatm_param_10 IS NOT NULL AND hatm_p10_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_10)
           END                     param_10_descr
          ,hatm_param_11           param_11
          ,CASE WHEN hatm_param_11 IS NOT NULL AND hatm_p11_derived = 'Y' THEN hatm_param_11
                WHEN hatm_param_11 IS NOT NULL AND hatm_p11_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_11)
           END                     param_11_descr
          ,hatm_param_12           param_12
          ,CASE WHEN hatm_param_12 IS NOT NULL AND hatm_p12_derived = 'Y' THEN hatm_param_12
                WHEN hatm_param_12 IS NOT NULL AND hatm_p12_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_12)
           END                     param_12_descr
          ,hatm_param_13           param_13
          ,CASE WHEN hatm_param_13 IS NOT NULL AND hatm_p13_derived = 'Y' THEN hatm_param_13
                WHEN hatm_param_13 IS NOT NULL AND hatm_p13_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_13)
           END                     param_13_descr
          ,hatm_param_14           param_14
          ,CASE WHEN hatm_param_14 IS NOT NULL AND hatm_p14_derived = 'Y' THEN hatm_param_14
                WHEN hatm_param_14 IS NOT NULL AND hatm_p14_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_14)
           END                     param_14_descr
          ,hatm_param_15           param_15
          ,CASE WHEN hatm_param_15 IS NOT NULL AND hatm_p15_derived = 'Y' THEN hatm_param_15
                WHEN hatm_param_15 IS NOT NULL AND hatm_p15_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_15)
           END                     param_15_descr
          ,hatm_param_16           param_16
          ,CASE WHEN hatm_param_16 IS NOT NULL AND hatm_p16_derived = 'Y' THEN hatm_param_16
                WHEN hatm_param_16 IS NOT NULL AND hatm_p16_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_16)
           END                     param_16_descr
          ,hatm_param_17           param_17
          ,CASE WHEN hatm_param_17 IS NOT NULL AND hatm_p17_derived = 'Y' THEN hatm_param_17
                WHEN hatm_param_17 IS NOT NULL AND hatm_p17_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_17)
           END                     param_17_descr
          ,hatm_param_18           param_18
          ,CASE WHEN hatm_param_18 IS NOT NULL AND hatm_p18_derived = 'Y' THEN hatm_param_18
                WHEN hatm_param_18 IS NOT NULL AND hatm_p18_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_18)
           END                     param_18_descr
          ,hatm_param_19           param_19
          ,CASE WHEN hatm_param_19 IS NOT NULL AND hatm_p19_derived = 'Y' THEN hatm_param_19
                WHEN hatm_param_19 IS NOT NULL AND hatm_p19_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_19)
           END                     param_19_descr
          ,hatm_param_20           param_20   
          ,CASE WHEN hatm_param_20 IS NOT NULL AND hatm_p20_derived = 'Y' THEN hatm_param_20
                WHEN hatm_param_20 IS NOT NULL AND hatm_p20_derived <> 'Y' 
                  THEN awlrs_alerts_api.get_screen_text(pi_ita_inv_type    => pi_inv_type
                                                       ,pi_ita_attrib_name => hatm_param_20)
           END                     param_20_descr
      FROM hig_alert_type_mail     
     WHERE hatm_halt_id        =  pi_alert_id;
  --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_details;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_types_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr 
          ,nit_table_name
      FROM all_tables 
          ,nm_inv_types
     WHERE OWNER = sys_context('NM3CORE','APPLICATION_OWNER')
       AND table_name NOT LIKE 'HIG_AUDIT%'
       AND table_name = nit_table_name  
       AND table_name NOT IN ('NM_ELEMENTS_ALL','NM_INV_ITEMS_ALL','HIG_OPTION_VALUES')
    ORDER BY nit_inv_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_types_lov;                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_ops_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor      OUT  sys_refcursor
                             ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 'Insert' 
          ,'Insert' 
          ,1        ind 
      FROM Dual
    UNION
    SELECT 'Update' 
          ,'Update' 
          ,2        ind 
      FROM Dual
    UNION
    SELECT 'Delete' 
          ,'Delete' 
          ,3        ind 
      FROM Dual
    ORDER BY ind;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_alert_ops_lov;
  
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_type_attribs_lov(pi_inv_type          IN     hig_alert_types.halt_nit_inv_type%TYPE
                                      ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                      ,po_message_cursor      OUT  sys_refcursor
                                      ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ita_attrib_name      attrib_name
          ,ita_scrn_text        attrib_name_descr 
      FROM nm_inv_type_attribs
     WHERE ita_inv_type = pi_inv_type
    ORDER BY ita_disp_seq_no;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_alert_type_attribs_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_attrib_values_lov(pi_inv_type          IN     hig_alert_types.halt_nit_inv_type%TYPE
                                 ,pi_attrib_name       IN     hig_alert_type_conditions.hatc_attribute_value%TYPE
                                 ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT  sys_refcursor
                                 ,po_cursor              OUT  sys_refcursor)   
  IS
  --
  lv_ita_query   nm_inv_type_attribs.ita_query%TYPE;
  --
  BEGIN
    --
    lv_ita_query := nm3get.get_ita(pi_ita_inv_type    =>  pi_inv_type
                                  ,pi_ita_attrib_name =>  pi_attrib_name).ita_query;
    --
    OPEN po_cursor FOR lv_ita_query;                              
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_attrib_values_lov;     
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_attrib_old_new_lov(pi_operation         IN     hig_alert_types.halt_operation%TYPE
                                  ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT  sys_refcursor
                                  ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Operation'
                               ,pi_parameter_value => pi_operation);
    --                           
    IF pi_operation = 'Insert'
       THEN
        OPEN po_cursor FOR
        SELECT 'N'         code
              ,'New Value' code_descr
          FROM dual;
    ELSIF      
       pi_operation = 'Delete'
       THEN
        OPEN po_cursor FOR
        SELECT 'O'         code
              ,'Old Value' code_descr
          FROM dual;
    ELSIF      
       pi_operation = 'Update'
           THEN
        OPEN po_cursor FOR
        SELECT 'B'         code 
              ,'Both'      code_descr 
          FROM dual
        UNION  
        SELECT 'O'
              ,'Old Value' 
          FROM dual
        UNION  
        SELECT 'N'
              ,'New Value' 
          FROM dual;    
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
  END get_attrib_old_new_lov;
                                                                                                      
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_trigger_alert(pi_inv_type              IN     hig_alert_types.halt_nit_inv_type%TYPE
                                ,pi_table_name            IN     hig_alert_types.halt_table_name%TYPE
                                ,pi_descr                 IN     hig_alert_types.halt_description%TYPE 
                                ,pi_operation             IN     hig_alert_types.halt_operation%TYPE
                                ,pi_immediate             IN     hig_alert_types.halt_immediate%TYPE
                                ,pi_batch_email_threshold IN     hig_alert_types.halt_trigger_count%TYPE
                                ,pi_batch_email_freq      IN     hig_alert_types.halt_frequency_id%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_trg_alert_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Inv Type'
                               ,pi_parameter_value => pi_inv_type);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Immediate Email'
                          ,pi_parameter_value => pi_immediate);
    --
    IF INITCAP(pi_operation) NOT IN ('Insert','Update','Delete')
       THEN
         hig.raise_ner(pi_appl               => 'HIG'
                      ,pi_id                 =>  70
                      ,pi_supplementary_info => 'Allowable values are Insert, Update and Delete');      
    END IF;                  
    --
    IF pi_immediate = 'N'
      THEN
        IF  NVL(pi_batch_email_freq,NVL(pi_batch_email_threshold,0)) = 0 
           THEN
              hig.raise_ner(pi_appl               => 'HIG'
                           ,pi_id                 => 22
                           ,pi_supplementary_info => 'Either the batch email frequency or the threshold must be supplied.');
        END IF;
        --   
    END IF;  
    /*
    ||insert into hig_alert_types.
    */
    INSERT
      INTO hig_alert_types
          (halt_id
          ,halt_alert_type
          ,halt_nit_inv_type
          ,halt_description
          ,halt_operation
          ,halt_immediate
          ,halt_trigger_count
          ,halt_frequency_id
          ,halt_suspend_query
          )
    VALUES (halt_id_seq.NEXTVAL
           ,'T'
           ,pi_inv_type 
           ,pi_descr
           ,pi_operation
           ,pi_immediate
           ,pi_batch_email_threshold
           ,pi_batch_email_freq
           ,'N'
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_trg_alert_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END create_trigger_alert;                         
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION attribute_exists(pi_alert_id      IN   hig_alert_type_attributes.hata_halt_id%TYPE
                           ,pi_attrib_name   IN   hig_alert_type_attributes.hata_attribute_name%TYPE)  
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_attrib_name IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM hig_alert_type_attributes
         WHERE hata_halt_id               = pi_alert_id 
           AND UPPER(hata_attribute_name) = UPPER(pi_attrib_name);
    ELSE
      lv_exists := 'N';   
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END attribute_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION attribute_exists(pi_attrib_id    IN   hig_alert_type_attributes.hata_id%TYPE)                             
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_attrib_id IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM hig_alert_type_attributes
         WHERE hata_id = pi_attrib_id;
    ELSE
      lv_exists := 'N';   
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END attribute_exists;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_trigger_attributes(pi_alert_id             IN     hig_alert_type_attributes.hata_halt_id%TYPE
                                     ,pi_operation            IN     hig_alert_types.halt_operation%TYPE
                                     ,pi_attribute_name       IN     hig_alert_type_attributes.hata_attribute_name%TYPE  
                                     ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_trg_attrib_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Id'
                               ,pi_parameter_value => pi_alert_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Attribute'
                               ,pi_parameter_value => pi_attribute_name);
    --
    IF INITCAP(pi_operation) <> 'Update'
       THEN
         hig.raise_ner(pi_appl               => 'HIG'
                      ,pi_id                 =>  110
                      ,pi_supplementary_info => 'pi_operation must equal ''Update'' and not '||pi_operation);      
    END IF;                  
    --
    IF attribute_exists(pi_alert_id    => pi_alert_id
                       ,pi_attrib_name => pi_attribute_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Attribute:'||pi_attribute_name);
    END IF;
    --
    /*
    ||insert into hig_alert_type_attributes.
    */
    INSERT
      INTO hig_alert_type_attributes
          (hata_id
          ,hata_halt_id
          ,hata_attribute_name
          )
    VALUES (hata_id_seq.NEXTVAL
           ,pi_alert_id
           ,pi_attribute_name 
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_trg_attrib_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END create_trigger_attributes;                                                                     

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_trigger_attributes(pi_old_attrib_id        IN     hig_alert_type_attributes.hata_id%TYPE
                                     ,pi_old_alert_id         IN     hig_alert_type_attributes.hata_halt_id%TYPE
                                     ,pi_old_attribute_name   IN     hig_alert_type_attributes.hata_attribute_name%TYPE
                                     ,pi_new_attrib_id        IN     hig_alert_type_attributes.hata_id%TYPE
                                     ,pi_new_alert_id         IN     hig_alert_type_attributes.hata_halt_id%TYPE
                                     ,pi_new_attribute_name   IN     hig_alert_type_attributes.hata_attribute_name%TYPE  
                                     ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor          OUT sys_refcursor)
  IS
    --
    lr_db_rec        hig_alert_type_attributes%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_alert_type_attributes
       WHERE hata_id = pi_old_attrib_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Attrib Id does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_trg_attrib_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Attrib Id'
                               ,pi_parameter_value => pi_new_attrib_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Id'
                               ,pi_parameter_value => pi_new_alert_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Attribute'
                               ,pi_parameter_value => pi_new_attribute_name);
    --
    IF attribute_exists(pi_alert_id    => pi_old_alert_id
                       ,pi_attrib_name => pi_new_attribute_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Attribute:'||pi_new_attribute_name);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.hata_id != pi_old_attrib_id
     OR (lr_db_rec.hata_id IS NULL AND pi_old_attrib_id IS NOT NULL)
     OR (lr_db_rec.hata_id IS NOT NULL AND pi_old_attrib_id IS NULL)
     --
     OR (lr_db_rec.hata_halt_id != pi_old_alert_id)
     OR (lr_db_rec.hata_halt_id IS NULL AND pi_old_alert_id IS NOT NULL)
     OR (lr_db_rec.hata_halt_id IS NOT NULL AND pi_old_alert_id IS NULL)
     --
     OR (UPPER(lr_db_rec.hata_attribute_name) != UPPER(pi_old_attribute_name))
     OR (UPPER(lr_db_rec.hata_attribute_name) IS NULL AND UPPER(pi_old_attribute_name) IS NOT NULL)
     OR (UPPER(lr_db_rec.hata_attribute_name) IS NOT NULL AND UPPER(pi_old_attribute_name) IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_attrib_id != pi_new_attrib_id
       OR (pi_old_attrib_id IS NULL AND pi_new_attrib_id IS NOT NULL)
       OR (pi_old_attrib_id IS NOT NULL AND pi_new_attrib_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_alert_id != pi_new_alert_id
       OR (pi_old_alert_id IS NULL AND pi_new_alert_id IS NOT NULL)
       OR (pi_old_alert_id IS NOT NULL AND pi_new_alert_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF UPPER(pi_old_attribute_name) != UPPER(pi_new_attribute_name)
       OR (UPPER(pi_old_attribute_name) IS NULL AND UPPER(pi_new_attribute_name) IS NOT NULL)
       OR (UPPER(pi_old_attribute_name) IS NOT NULL AND UPPER(pi_new_attribute_name) IS NULL)
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
        UPDATE hig_alert_type_attributes
           SET hata_attribute_name = UPPER(pi_new_attribute_name)
         WHERE hata_id             = pi_old_attrib_id
           AND hata_halt_id        = pi_old_alert_id;
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
        ROLLBACK TO update_trg_attrib_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_trigger_attributes;                                      

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_trigger_attributes(pi_attrib_id            IN     hig_alert_type_attributes.hata_id%TYPE
                                     ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_trg_attrib_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Attrib Id'
                               ,pi_parameter_value => pi_attrib_id);
    --
    IF attribute_exists(pi_attrib_id => pi_attrib_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Attrib Id:  '||pi_attrib_id);
    END IF;
    /*
    ||delete from hig_alert_type_attributes.
    */
    DELETE 
      FROM hig_alert_type_attributes
     WHERE hata_id = pi_attrib_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_trg_attrib_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END delete_trigger_attributes;                                                                     
                                     
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_frequencies_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT  sys_refcursor
                               ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    awlrs_process_framework_api.frequencies_lov(po_message_severity  =>  po_message_severity
                                               ,po_message_cursor    =>  po_message_cursor
                                               ,po_cursor            =>  po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_frequencies_lov;                              
                           
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_scheduled_alert(pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                                  ,pi_query_id             IN     hig_alert_types.halt_hqt_id%TYPE
                                  ,pi_descr                IN     hig_alert_types.halt_description%TYPE 
                                  ,pi_frequency_id         IN     hig_alert_types.halt_frequency_id%TYPE
                                  ,pi_suspend_query        IN     hig_alert_types.halt_suspend_query%TYPE
                                  ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor          OUT sys_refcursor) 
  IS
  --
  BEGIN
    --
    SAVEPOINT create_sched_alert_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Inv Type'
                               ,pi_parameter_value => pi_inv_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value => pi_frequency_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Suspended'
                               ,pi_parameter_value => pi_suspend_query);
    --
    /*
    ||insert into hig_alert_types.
    */
    INSERT
      INTO hig_alert_types
          (halt_id
          ,halt_alert_type
          ,halt_nit_inv_type
          ,halt_hqt_id
          ,halt_description
          ,halt_immediate
          ,halt_frequency_id
          ,halt_suspend_query
          ,halt_next_run_date
          )
    VALUES (halt_id_seq.NEXTVAL
           ,'Q'
           ,pi_inv_type 
           ,pi_query_id
           ,pi_descr
           ,'N'
           ,pi_frequency_id
           ,pi_suspend_query
           ,hig_alert.get_next_run_date(pi_hsfr_id => pi_frequency_id)
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_sched_alert_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END create_scheduled_alert;                                                                 
                                              
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_trigger(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                          ,pi_inv_type             IN     hig_alert_types.halt_nit_inv_type%TYPE
                          ,pi_recip_type           IN     hig_alert_type_recipients.hatr_type%TYPE 
                          ,pi_recip_rule_id        IN     hig_alert_type_recipients.hatr_harr_id%TYPE
                          ,pi_recip_user_id        IN     hig_alert_type_recipients.hatr_nmu_id%TYPE
                          ,pi_recip_group_id       IN     hig_alert_type_recipients.hatr_nmg_id%TYPE
                          ,pi_mail_subject         IN     hig_alert_type_mail.hatm_subject%TYPE
                          ,pi_mail_text            IN     hig_alert_type_mail.hatm_mail_text%TYPE
                          ,po_message_severity        OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor          OUT sys_refcursor)
  IS
  --
  lv_error_text varchar2(32767);
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Id'
                               ,pi_parameter_value => pi_alert_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mail Subject'
                               ,pi_parameter_value => pi_mail_subject);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mail Text'
                               ,pi_parameter_value => pi_mail_text);
    --
    IF   pi_recip_type IS NULL 
     OR   (pi_recip_rule_id IS NULL
     AND   pi_recip_user_id IS NULL
     AND   pi_recip_group_id IS NULL)
      THEN
         hig.raise_ner(pi_appl               => 'HIG'
                      ,pi_id                 => 110
                      ,pi_supplementary_info => 'Trigger could not be created, email is not setup for this alert');
    END IF;  
    --
    IF NOT hig_alert.create_trigger(pi_halt_id    => pi_alert_id
                                   ,po_error_text => lv_error_text)
      THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 523
                     ,pi_supplementary_info => lv_error_text);                                        
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
  --
  END create_trigger;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE drop_trigger(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                        ,pi_trigger_name         IN     hig_alert_types.halt_trigger_name%TYPE
                        ,po_message_severity        OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor          OUT sys_refcursor)
  IS                      
  --
  lv_error_text varchar2(32767);
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Id'
                               ,pi_parameter_value => pi_alert_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Trigger Name'
                               ,pi_parameter_value => pi_trigger_name);
    --
    IF NOT hig_alert.drop_trigger(pi_halt_id       => pi_alert_id
                                 ,pi_trigger_name  => pi_trigger_name
                                 ,po_error_text    => lv_error_text)
      THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 544
                     ,pi_supplementary_info => lv_error_text);                                        
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
  --
  END drop_trigger;             
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE suspend_query(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                         ,po_next_run_date           OUT hig_alert_types.halt_next_run_date%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor)
  IS                      
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Id'
                               ,pi_parameter_value => pi_alert_id);
    --
    UPDATE hig_alert_types
       SET halt_next_run_date = null
     WHERE halt_id            = pi_alert_id; 
    --
    po_next_run_date := null; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END suspend_query;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resume_query(pi_alert_id             IN     hig_alert_types.halt_id%TYPE
                        ,pi_frequency_id         IN     hig_alert_types.halt_frequency_id%TYPE
                        ,po_next_run_date           OUT hig_alert_types.halt_next_run_date%TYPE
                        ,po_message_severity        OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor          OUT sys_refcursor)
  IS                      
  --
  lv_next_run_date hig_alert_types.halt_next_run_date%TYPE;
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Id'
                               ,pi_parameter_value => pi_alert_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Frequency Id'
                               ,pi_parameter_value => pi_frequency_id);
    --
    lv_next_run_date := hig_alert.get_next_run_date(pi_hsfr_id => pi_frequency_id);
    --
    UPDATE hig_alert_types
       SET halt_next_run_date = lv_next_run_date
     WHERE halt_id            = pi_alert_id;
    -- 
    po_next_run_date := lv_next_run_date; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END resume_query;                                                              
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_logs(po_message_severity        OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor          OUT sys_refcursor
                          ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT haml_halt_id           alert_id
          ,haml_hal_id            alert_log_id  
          ,haml_har_id            recip_id
          ,haml_nit_inv_type      inv_type
          ,haml_descr             inv_type_descr
          ,haml_description       alert_descr
          ,haml_pk_column         primary_key
          ,haml_pk_id             pk_id
          ,haml_recipient_email   recip_email
          ,haml_created_date      alert_raised_date
          ,haml_email_date_sent   alert_sent_date
          ,haml_status            status
          ,haml_mail_from         mail_from
          ,haml_subject           mail_subject
          ,haml_email_body        mail_text
          ,haml_comments          failure_comments
      FROM hig_alert_manager_logs_vw;    
    --ORDER BY haml_email_date_sent;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_alert_logs;                          

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_alert_log(pi_alert_log_id         IN     hig_alert_manager_logs_vw.haml_hal_id%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT haml_halt_id           alert_id
          ,haml_hal_id            alert_log_id  
          ,haml_har_id            recip_id
          ,haml_nit_inv_type      inv_type
          ,haml_descr             inv_type_descr
          ,haml_description       alert_descr
          ,haml_pk_column         primary_key
          ,haml_pk_id             pk_id
          ,haml_recipient_email   recip_email
          ,haml_created_date      alert_raised_date
          ,haml_email_date_sent   alert_sent_date
          ,haml_status            status
          ,haml_mail_from         mail_from
          ,haml_subject           mail_subject
          ,haml_email_body        mail_text
          ,haml_comments          failure_comments
      FROM hig_alert_manager_logs_vw
     WHERE haml_halt_id = pi_alert_log_id;    
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_alert_log;                                                     

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_alert_logs(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2 :='SELECT haml_halt_id         alert_id'
                                              ||',haml_hal_id          alert_log_id'
                                              ||',haml_har_id          recip_id'
                                              ||',haml_nit_inv_type    inv_type'
                                              ||',haml_descr           inv_type_descr'
                                              ||',haml_description     alert_descr'
                                              ||',haml_pk_column       primary_key'
                                              ||',haml_pk_id           pk_id'
                                              ||',haml_recipient_email recip_email'
                                              ||',haml_created_date    alert_raised_date'
                                              ||',haml_email_date_sent alert_sent_date'
                                              ||',haml_status          status'
                                              ||',haml_mail_from       mail_from'
                                              ||',haml_subject         mail_subject'
                                              ||',haml_email_body      mail_text'
                                              ||',haml_comments        failure_comments'
                                              ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                         ||' FROM hig_alert_manager_logs_vw'
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'inv_type'
                                ,pi_query_col    => 'haml_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'inv_type_descr'
                                ,pi_query_col    => 'halt_alert_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_descr'
                                ,pi_query_col    => 'haml_description'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'primary_key'
                                ,pi_query_col    => 'haml_pk_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'pk_id'
                                ,pi_query_col    => 'haml_pk_id'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'recip_email'
                                ,pi_query_col    => 'haml_recipient_email'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_raised_date'
                                ,pi_query_col    => 'haml_created_date'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'alert_sent_date'
                                ,pi_query_col    => 'haml_email_date_sent'
                                ,pi_datatype     => awlrs_util.c_datetime_col
                                ,pi_mask         => 'DD-MON-YYYY HH24:MI:SS'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'status'
                                ,pi_query_col    => 'haml_status'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'haml_hal_id')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_alert_logs;
                                                      
  
  --
  -----------------------------------------------------------------------------
  --
  /*
  -- for individual recipients
  PROCEDURE send_email(pi_alert_log_id          IN     hig_alert_manager_logs_vw.haml_hal_id%TYPE  
                      ,pi_recip_id              IN     hig_alert_manager_logs_vw.haml_har_id%TYPE
                      ,po_message_severity         OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor           OUT sys_refcursor)   
  IS
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Log Id'
                               ,pi_parameter_value => pi_alert_log_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Recipient Id'
                               ,pi_parameter_value => pi_recip_id);
    --
    hig_alert.send_mail(pi_har_id      => pi_recip_id
                       ,pi_from_screen => 'Y');    --when set to Y, commits
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END send_email;
  */
  
  --
  -----------------------------------------------------------------------------
  --
  -- for multiple recipients
  PROCEDURE send_email(pi_recip_ids             IN     alert_recip_id_tab
                      ,po_message_severity         OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor           OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    FOR i IN 1..pi_recip_ids.COUNT LOOP
    --
      hig_alert.send_mail(pi_har_id      => pi_recip_ids(i)
                         ,pi_from_screen => 'Y');    --when set to Y, commits
    END LOOP;                     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END send_email;                      
  --
  -----------------------------------------------------------------------------
  --
  /*
  -- for individual recipients
  PROCEDURE send_email(pi_alert_log_id          IN     hig_alert_manager_logs_vw.haml_hal_id%TYPE  
                      ,po_message_severity         OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor           OUT sys_refcursor)   
  IS
  --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    -- 
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    -- 
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Alert Log Id'
                               ,pi_parameter_value => pi_alert_log_id);
    --
    hig_alert.send_mail(pi_hal_id      => pi_alert_log_id
                       ,pi_from_screen => 'Y');    --when set to Y, commits
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END send_email;  */       
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_groups(po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmg_id        nmg_id  
          ,nmg_name      nmg_name  
      FROM nm_mail_groups    
    ORDER BY UPPER(nmg_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_groups;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_group(pi_nmg_id               IN     nm_mail_groups.nmg_id%TYPE
                          ,po_message_severity        OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor          OUT sys_refcursor
                          ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmg_id        nmg_id  
          ,nmg_name      nmg_name  
      FROM nm_mail_groups
     WHERE nmg_id = pi_nmg_id;     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_group;                                                        

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_mail_groups(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2 :='SELECT nmg_id   nmg_id'
                                              ||',nmg_name nmg_name'
                                              ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                         ||' FROM nm_mail_groups'
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmg_id'
                                ,pi_query_col    => 'nmg_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmg_name'
                                ,pi_query_col    => 'nmg_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'UPPER(nmg_name)')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_mail_groups;                                                                                    
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION mail_group_exists(pi_nmg_name                 IN     nm_mail_groups.nmg_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmg_name IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_groups
         WHERE nmg_name = UPPER(pi_nmg_name);
    ELSE
      lv_exists := 'Y';   
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END mail_group_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION mail_group_exists(pi_nmg_id      IN     nm_mail_groups.nmg_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmg_id IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_groups
         WHERE nmg_id = pi_nmg_id;
    ELSE
      lv_exists := 'Y';   
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END mail_group_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION mail_id_exists(pi_nmu_id  IN  nm_mail_users.nmu_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmu_id IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_users
         WHERE nmu_id = pi_nmu_id;
    ELSE
      lv_exists := 'Y';   
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END mail_id_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION name_exists(pi_nmu_name  IN  nm_mail_users.nmu_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmu_name IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_users
         WHERE UPPER(nmu_name) = UPPER(pi_nmu_name);
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END name_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION email_exists(pi_nmu_email  IN  nm_mail_users.nmu_email_address%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmu_email IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_users
         WHERE UPPER(nmu_email_address) = UPPER(pi_nmu_email);
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END email_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_id_exists(pi_nmu_hus_user_id  IN  nm_mail_users.nmu_hus_user_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmu_hus_user_id IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_users
         WHERE nmu_hus_user_id = pi_nmu_hus_user_id;
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_id_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_mail_group(pi_nmg_name                 IN     nm_mail_groups.nmg_name%TYPE
                             ,po_message_severity            OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_mail_grp_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Name'
                               ,pi_parameter_value => pi_nmg_name);
    --
    IF mail_group_exists(pi_nmg_name => pi_nmg_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Group Name:  '||pi_nmg_name);
    END IF;
    --
    /*
    ||insert into nm_mail_groups.
    */
    INSERT
      INTO nm_mail_groups
          (nmg_id
          ,nmg_name
          )
    VALUES (nmg_id_seq.NEXTVAL
           ,pi_nmg_name
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_mail_grp_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END create_mail_group;                             
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_mail_group(pi_old_nmg_id               IN     nm_mail_groups.nmg_id%TYPE
                             ,pi_old_nmg_name             IN     nm_mail_groups.nmg_name%TYPE
                             ,pi_new_nmg_id               IN     nm_mail_groups.nmg_id%TYPE
                             ,pi_new_nmg_name             IN     nm_mail_groups.nmg_name%TYPE
                             ,po_message_severity            OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor              OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_mail_groups%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_mail_groups
       WHERE nmg_id = pi_old_nmg_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Group Id does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_mail_group_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Id'
                               ,pi_parameter_value => pi_new_nmg_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Name'
                               ,pi_parameter_value => pi_new_nmg_name);
    --
    IF mail_group_exists(pi_nmg_name => pi_new_nmg_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Group Name:  '||pi_new_nmg_name);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nmg_id != pi_old_nmg_id
     OR (lr_db_rec.nmg_id IS NULL AND pi_old_nmg_id IS NOT NULL)
     OR (lr_db_rec.nmg_id IS NOT NULL AND pi_old_nmg_id IS NULL)
     --
     OR (UPPER(lr_db_rec.nmg_name) != UPPER(pi_old_nmg_name))
     OR (UPPER(lr_db_rec.nmg_name) IS NULL AND UPPER(pi_old_nmg_name) IS NOT NULL)
     OR (UPPER(lr_db_rec.nmg_name) IS NOT NULL AND UPPER(pi_old_nmg_name) IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nmg_id != pi_new_nmg_id
       OR (pi_old_nmg_id IS NULL AND pi_new_nmg_id IS NOT NULL)
       OR (pi_old_nmg_id IS NOT NULL AND pi_new_nmg_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF UPPER(pi_old_nmg_name) != UPPER(pi_new_nmg_name)
       OR (UPPER(pi_old_nmg_name) IS NULL AND UPPER(pi_new_nmg_name) IS NOT NULL)
       OR (UPPER(pi_old_nmg_name) IS NOT NULL AND UPPER(pi_new_nmg_name) IS NULL)
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
        UPDATE nm_mail_groups
           SET nmg_name        = UPPER(pi_new_nmg_name)
         WHERE nmg_id          = pi_old_nmg_id;
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
        ROLLBACK TO update_mail_group_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_mail_group;                                                     

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_mail_group(pi_nmg_id                   IN     nm_mail_groups.nmg_id%TYPE
                             ,po_message_severity            OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_mail_grp_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Id'
                               ,pi_parameter_value => pi_nmg_id);
    --
    IF mail_group_exists(pi_nmg_id => pi_nmg_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Group Id:  '||pi_nmg_id);
    END IF;
    --
    /*
    ||delete from nm_mail_groups.
    */
    DELETE 
      FROM nm_mail_groups
     WHERE nmg_id = pi_nmg_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_mail_grp_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END delete_mail_group;                             
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_grp_members(pi_nmg_id               IN     nm_mail_groups.nmg_id%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmgm_nmg_id      nmgm_nmg_id  
          ,nmgm_nmu_id      nmgm_nmu_id
          ,nmu_name         nmu_name  
      FROM v_nm_mail_group_membership
     WHERE nmgm_nmg_id = pi_nmg_id   
    ORDER BY UPPER(nmu_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_grp_members;                                 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_grp_member(pi_nmg_id               IN     nm_mail_groups.nmg_id%TYPE
                               ,pi_nmgm_nmu_id          IN     nm_mail_group_membership.nmgm_nmu_id%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmgm_nmg_id      nmgm_nmg_id  
          ,nmgm_nmu_id      nmgm_nmu_id
          ,nmu_name         nmu_name  
      FROM v_nm_mail_group_membership
     WHERE nmgm_nmg_id = pi_nmg_id 
       AND nmgm_nmu_id = pi_nmgm_nmu_id;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_grp_member;                                                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_mail_grp_members(pi_nmg_id               IN     nm_mail_groups.nmg_id%TYPE
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2 :='SELECT nmgm_nmg_id nmgm_nmg_id'
                                              ||',nmgm_nmu_id nmgm_nmu_id'
                                              ||',nmu_name    nmu_name'
                                              ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                         ||' FROM v_nm_mail_group_membership'
                                        ||' WHERE nmgm_nmg_id = :pi_nmg_id'
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmgm_nmg_id'
                                ,pi_query_col    => 'nmgm_nmg_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmgm_nmu_id'
                                ,pi_query_col    => 'nmgm_nmu_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmu_name'
                                ,pi_query_col    => 'nmu_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'UPPER(nmu_name)')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql
    USING pi_nmg_id
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);

  END get_paged_mail_grp_members;                                                                                    
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION group_member_exists(pi_nmgm_nmg_id   IN   nm_mail_group_membership.nmgm_nmg_id%TYPE
                              ,pi_nmgm_nmu_id   IN   nm_mail_group_membership.nmgm_nmu_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_nmgm_nmg_id IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_mail_group_membership
         WHERE nmgm_nmg_id = pi_nmgm_nmg_id
           AND nmgm_nmu_id = pi_nmgm_nmu_id;
    ELSE
      lv_exists := 'Y';   
    END IF;     
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END group_member_exists;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_grp_members_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmu_id
          ,nmu_name 
      FROM nm_mail_users 
    ORDER BY UPPER(nmu_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_grp_members_lov;                                

  --
  -----------------------------------------------------------------------------
  --     
  PROCEDURE create_mail_grp_member(pi_nmgm_nmg_id              IN     nm_mail_group_membership.nmgm_nmg_id%TYPE
                                  ,pi_nmgm_nmu_id              IN     nm_mail_group_membership.nmgm_nmu_id%TYPE
                                  ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_group_member_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Id'
                               ,pi_parameter_value => pi_nmgm_nmg_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value => pi_nmgm_nmu_id);
    --
    IF group_member_exists(pi_nmgm_nmg_id => pi_nmgm_nmg_id
                          ,pi_nmgm_nmu_id => pi_nmgm_nmu_id) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'User Id:  '||pi_nmgm_nmu_id);
    END IF;
    --
    /*
    ||insert into nm_mail_group_membership.
    */
    INSERT
      INTO nm_mail_group_membership
          (nmgm_nmg_id
          ,nmgm_nmu_id
          )
    VALUES (pi_nmgm_nmg_id
           ,pi_nmgm_nmu_id
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_group_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END create_mail_grp_member;                                  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_mail_grp_member(pi_old_nmgm_nmg_id          IN     nm_mail_group_membership.nmgm_nmg_id%TYPE
                                  ,pi_old_nmgm_nmu_id          IN     nm_mail_group_membership.nmgm_nmu_id%TYPE
                                  ,pi_new_nmgm_nmg_id          IN     nm_mail_group_membership.nmgm_nmg_id%TYPE
                                  ,pi_new_nmgm_nmu_id          IN     nm_mail_group_membership.nmgm_nmu_id%TYPE
                                  ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor              OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_mail_group_membership%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_mail_group_membership
       WHERE nmgm_nmg_id = pi_old_nmgm_nmg_id
         AND nmgm_nmu_id = pi_old_nmgm_nmu_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Group User Id does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_grp_member_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Id'
                               ,pi_parameter_value => pi_new_nmgm_nmg_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value => pi_new_nmgm_nmu_id);
    --
    IF group_member_exists(pi_nmgm_nmg_id => pi_new_nmgm_nmg_id
                          ,pi_nmgm_nmu_id => pi_new_nmgm_nmu_id) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Group User Id:  '||pi_new_nmgm_nmu_id);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nmgm_nmg_id != pi_old_nmgm_nmg_id
     OR (lr_db_rec.nmgm_nmg_id IS NULL AND pi_old_nmgm_nmg_id IS NOT NULL)
     OR (lr_db_rec.nmgm_nmg_id IS NOT NULL AND pi_old_nmgm_nmg_id IS NULL)
     --
     OR (UPPER(lr_db_rec.nmgm_nmu_id) != pi_old_nmgm_nmu_id)
     OR (UPPER(lr_db_rec.nmgm_nmu_id) IS NULL AND pi_old_nmgm_nmu_id IS NOT NULL)
     OR (UPPER(lr_db_rec.nmgm_nmu_id) IS NOT NULL AND pi_old_nmgm_nmu_id IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nmgm_nmg_id != pi_new_nmgm_nmg_id
       OR (pi_old_nmgm_nmg_id IS NULL AND pi_new_nmgm_nmg_id IS NOT NULL)
       OR (pi_old_nmgm_nmg_id IS NOT NULL AND pi_new_nmgm_nmg_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF UPPER(pi_old_nmgm_nmu_id) != pi_new_nmgm_nmu_id
       OR (UPPER(pi_old_nmgm_nmu_id) IS NULL AND pi_new_nmgm_nmu_id IS NOT NULL)
       OR (UPPER(pi_old_nmgm_nmu_id) IS NOT NULL AND pi_new_nmgm_nmu_id IS NULL)
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
        UPDATE nm_mail_group_membership
           SET nmgm_nmg_id     = pi_new_nmgm_nmg_id
              ,nmgm_nmu_id     = pi_new_nmgm_nmu_id
         WHERE nmgm_nmg_id     = pi_old_nmgm_nmg_id
           AND nmgm_nmu_id     = pi_old_nmgm_nmu_id;
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
        ROLLBACK TO update_grp_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_mail_grp_member;                                                     

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_mail_grp_member(pi_nmgm_nmg_id              IN     nm_mail_group_membership.nmgm_nmg_id%TYPE
                                  ,pi_nmgm_nmu_id              IN     nm_mail_group_membership.nmgm_nmu_id%TYPE
                                  ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_grp_member_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Id'
                               ,pi_parameter_value => pi_nmgm_nmg_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value => pi_nmgm_nmu_id);
    --
    IF group_member_exists(pi_nmgm_nmg_id => pi_nmgm_nmg_id
                          ,pi_nmgm_nmu_id => pi_nmgm_nmu_id) <>'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'User Id:  '||pi_nmgm_nmu_id);
    END IF;
    --
    /*
    ||delete from nm_mail_group_membership.
    */
    DELETE 
      FROM nm_mail_group_membership
     WHERE nmgm_nmg_id = pi_nmgm_nmg_id
       AND nmgm_nmu_id = pi_nmgm_nmu_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_grp_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END delete_mail_grp_member;                                   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_users(po_message_severity       OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor         OUT sys_refcursor
                          ,po_cursor                 OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmu_id             nmu_id
          ,nmu_name           nmu_name
          ,nmu_email_address  nmu_email_address
          ,nmu_hus_user_id    nmu_hus_user_id
          ,hus_name           hus_name
      FROM nm_mail_users
          ,hig_users
     WHERE nmu_hus_user_id = hus_user_id(+)    
    ORDER BY UPPER(nmu_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_users;                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_mail_user(pi_nmu_id               IN     nm_mail_users.nmu_id%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmu_id             nmu_id
          ,nmu_name           nmu_name
          ,nmu_email_address  nmu_email_address
          ,nmu_hus_user_id    nmu_hus_user_id
          ,hus_name           hus_name
      FROM nm_mail_users
          ,hig_users 
     WHERE nmu_id          = pi_nmu_id
       AND nmu_hus_user_id = hus_user_id(+);     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_mail_user;                                                     

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_mail_users(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_cursor_sql  nm3type.max_varchar2 :='SELECT nmu_id            nmu_id'
                                                ||',nmu_name          nmu_name'
                                                ||',nmu_email_address nmu_email_address'
                                                ||',nmu_hus_user_id   nmu_hus_user_id'
                                                ||',hus_name          hus_name'
                                                ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                           ||' FROM nm_mail_users'
                                                ||',hig_users'
                                          ||' WHERE nmu_hus_user_id = hus_user_id(+)';
      --
      lt_column_data  awlrs_util.column_data_tab;
      --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmu_id'
                                ,pi_query_col    => 'nmu_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmu_name'
                                ,pi_query_col    => 'nmu_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmu_email_address'
                                ,pi_query_col    => 'nmu_email_address'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nmu_hus_user_id'
                                ,pi_query_col    => 'nmu_hus_user_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'hus_name'
                                ,pi_query_col    => 'hus_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
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
                     ||lv_filter
                     ||' ORDER BY '||NVL(lv_order_by,'UPPER(nmu_name)')
                     ||' OFFSET '||pi_skip_n_rows||' ROWS '
    ;
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_mail_users;        
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_mail_grps(pi_nmgm_nmu_id          IN     nm_mail_group_membership.nmgm_nmu_id%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nmgm_nmg_id      nmgm_nmg_id  
          ,nmg_name         nmg_name  
      FROM v_nm_mail_group_membership
     WHERE nmgm_nmu_id = pi_nmgm_nmu_id;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END get_user_mail_grps; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_users_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor      OUT  sys_refcursor
                         ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hus_user_id
          ,hus_name 
      FROM hig_users 
    ORDER BY UPPER(hus_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_users_lov;                                                                                   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_mail_user(pi_nmu_name                 IN     nm_mail_users.nmu_name%TYPE
                            ,pi_nmu_email                IN     nm_mail_users.nmu_email_address%TYPE
                            ,pi_nmu_user_id              IN     nm_mail_users.nmu_hus_user_id%TYPE
                            ,po_message_severity            OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_mail_user_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_nmu_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Email'
                               ,pi_parameter_value => pi_nmu_email);
    --
    IF name_exists(pi_nmu_name => pi_nmu_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Name:  '||pi_nmu_name);
    END IF;
    --
    IF email_exists(pi_nmu_email => pi_nmu_email) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Email:  '||pi_nmu_email);
    END IF;
    --
    IF user_id_exists(pi_nmu_hus_user_id => pi_nmu_user_id) = 'Y'
          THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 64
                         ,pi_supplementary_info  => 'User Id:  '||pi_nmu_user_id);
    END IF;
    --                     
    /*
    ||insert into nm_mail_users.
    */
    INSERT
      INTO nm_mail_users
          (nmu_id
          ,nmu_name
          ,nmu_email_address
          ,nmu_hus_user_id
          )
    VALUES (nmu_id_seq.NEXTVAL
           ,pi_nmu_name
           ,pi_nmu_email
           ,pi_nmu_user_id
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_mail_user_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END create_mail_user;                             
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_mail_user(pi_old_nmu_id               IN     nm_mail_users.nmu_id%TYPE
                            ,pi_old_nmu_name             IN     nm_mail_users.nmu_name%TYPE
                            ,pi_old_nmu_email            IN     nm_mail_users.nmu_email_address%TYPE
                            ,pi_old_nmu_user_id          IN     nm_mail_users.nmu_hus_user_id%TYPE
                            ,pi_new_nmu_id               IN     nm_mail_users.nmu_id%TYPE
                            ,pi_new_nmu_name             IN     nm_mail_users.nmu_name%TYPE
                            ,pi_new_nmu_email            IN     nm_mail_users.nmu_email_address%TYPE
                            ,pi_new_nmu_user_id          IN     nm_mail_users.nmu_hus_user_id%TYPE
                            ,po_message_severity            OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor              OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_mail_users%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_mail_users
       WHERE nmu_id = pi_old_nmu_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Mail User Id does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_mail_user_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mail User Id'
                               ,pi_parameter_value => pi_new_nmu_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_new_nmu_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Email'
                               ,pi_parameter_value => pi_new_nmu_email);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nmu_id != pi_old_nmu_id
     OR (lr_db_rec.nmu_id IS NULL AND pi_old_nmu_id IS NOT NULL)
     OR (lr_db_rec.nmu_id IS NOT NULL AND pi_old_nmu_id IS NULL)
     --
     OR (UPPER(lr_db_rec.nmu_name) != UPPER(pi_old_nmu_name))
     OR (UPPER(lr_db_rec.nmu_name) IS NULL AND UPPER(pi_old_nmu_name) IS NOT NULL)
     OR (UPPER(lr_db_rec.nmu_name) IS NOT NULL AND UPPER(pi_old_nmu_name) IS NULL)
     --
     OR (UPPER(lr_db_rec.nmu_email_address) != UPPER(pi_old_nmu_email))
     OR (UPPER(lr_db_rec.nmu_email_address) IS NULL AND UPPER(pi_old_nmu_email) IS NOT NULL)
     OR (UPPER(lr_db_rec.nmu_email_address) IS NOT NULL AND UPPER(pi_old_nmu_email) IS NULL)
     --
     OR (lr_db_rec.nmu_hus_user_id != pi_old_nmu_user_id)
     OR (lr_db_rec.nmu_hus_user_id IS NULL AND pi_old_nmu_user_id IS NOT NULL)
     OR (lr_db_rec.nmu_hus_user_id IS NOT NULL AND pi_old_nmu_user_id IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nmu_id != pi_new_nmu_id
       OR (pi_old_nmu_id IS NULL AND pi_new_nmu_id IS NOT NULL)
       OR (pi_old_nmu_id IS NOT NULL AND pi_new_nmu_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF UPPER(pi_old_nmu_name) != UPPER(pi_new_nmu_name)
       OR (UPPER(pi_old_nmu_name) IS NULL AND UPPER(pi_new_nmu_name) IS NOT NULL)
       OR (UPPER(pi_old_nmu_name) IS NOT NULL AND UPPER(pi_new_nmu_name) IS NULL)
       THEN
         IF name_exists(pi_nmu_name => pi_new_nmu_name) = 'Y'
          THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 64
                         ,pi_supplementary_info  => 'Name:  '||pi_new_nmu_name);
         ELSE
            lv_upd := 'Y';                  
         END IF; 
      END IF;
      --
      IF UPPER(pi_old_nmu_email) != UPPER(pi_new_nmu_email)
       OR (UPPER(pi_old_nmu_email) IS NULL AND UPPER(pi_new_nmu_email) IS NOT NULL)
       OR (UPPER(pi_old_nmu_email) IS NOT NULL AND UPPER(pi_new_nmu_email) IS NULL)
       THEN
         IF email_exists(pi_nmu_email => pi_new_nmu_email) = 'Y'
          THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 64
                         ,pi_supplementary_info  => 'Email:  '||pi_new_nmu_email);
         ELSE
            lv_upd := 'Y';                
         END IF; 
      END IF;
      --
      IF pi_old_nmu_user_id != pi_new_nmu_user_id
       OR (pi_old_nmu_user_id IS NULL AND pi_new_nmu_user_id IS NOT NULL)
       OR (pi_old_nmu_user_id IS NOT NULL AND pi_new_nmu_user_id IS NULL)
       THEN
         IF user_id_exists(pi_nmu_hus_user_id => pi_new_nmu_user_id) = 'Y'
          THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 64
                         ,pi_supplementary_info  => 'User Id:  '||pi_new_nmu_user_id);
         ELSE
            lv_upd := 'Y';                
         END IF;
      END IF;
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE nm_mail_users
           SET nmu_name          = UPPER(pi_new_nmu_name)
              ,nmu_email_address = UPPER(pi_new_nmu_email)
              ,nmu_hus_user_id   = pi_new_nmu_user_id
         WHERE nmu_id            = pi_new_nmu_id;
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
        ROLLBACK TO update_mail_user_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_mail_user;                                                        

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_mail_user(pi_nmu_id                   IN     nm_mail_users.nmu_id%TYPE
                            ,po_message_severity            OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT delete_mail_user_sp;
    --
    awlrs_util.check_historic_mode; 
    --  
    --Firstly we need to check the caller has the correct roles to continue--
    IF privs_check(pi_role_name  => cv_hig_admin) = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 86);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mail User Id'
                               ,pi_parameter_value => pi_nmu_id);
    --
    IF mail_id_exists(pi_nmu_id => pi_nmu_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Mail User Id:  '||pi_nmu_id);
    END IF;
    --
    /*
    ||delete from nm_mail_users.
    */
    DELETE 
      FROM nm_mail_users
     WHERE nmu_id = pi_nmu_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_mail_user_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor); 
  --
  END delete_mail_user;                                                                                                                                        
  --
 
END awlrs_alerts_api;
/

