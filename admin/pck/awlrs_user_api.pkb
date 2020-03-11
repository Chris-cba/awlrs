CREATE OR REPLACE PACKAGE BODY awlrs_user_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_user_api.pkb-arc   1.10   Mar 11 2020 10:18:42   Barbara.Odriscoll  $
  --       Date into PVCS   : $Date:   Mar 11 2020 10:18:42  $
  --       Module Name      : $Workfile:   awlrs_user_api.pkb  $
  --       Date fetched Out : $Modtime:   Mar 11 2020 10:04:30  $
  --       Version          : $Revision:   1.10  $
  --
  -----------------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated.  All rights reserved.
  -----------------------------------------------------------------------------------
  --

  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT  VARCHAR2(2000) := '"$Revision:   1.10  $"';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_user_api';
  --
  --constant variables
  cv_b		      CONSTANT varchar2(1) := 'B';
  cv_kb 		  CONSTANT varchar2(1) := 'K';
  cv_mb           CONSTANT varchar2(1) := 'M';
  cv_gb	  		  CONSTANT varchar2(1) := 'G';
  cv_tb           CONSTANT varchar2(1) := 'T';
  cv_pb      	  CONSTANT varchar2(1) := 'P';
  --roles constants
  cv_hig_user_role  CONSTANT varchar2(8)  := 'HIG_USER';
  cv_hig_admin      CONSTANT varchar2(9)  := 'HIG_ADMIN';
  cv_hig_user_admin CONSTANT varchar2(14) := 'HIG_USER_ADMIN';
  cv_proxy_owner    CONSTANT varchar2(11) := 'PROXY_OWNER';
  --
  --get_user constants
  cv_user_filter  CONSTANT varchar2(1) := 'A';
  --

  cv_Quota_Option_Name	CONSTANT hig_option_list.hol_id%TYPE :='USRQUOTA';
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
  FUNCTION user_privs_check RETURN VARCHAR2  
  IS
     lv_count number(1);
  BEGIN
      --
      SELECT  COUNT(*)
      INTO    lv_count
      FROM    hig_user_roles
      WHERE   hur_role    IN (cv_hig_admin,cv_hig_user_admin)
      AND     hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME');
      --
      IF lv_count = 2  --to create/alter a user, the user needs both roles 
        THEN
          RETURN 'Y';
      ELSE     
          RETURN 'N';
      END IF;    
      -- 
  END user_privs_check;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_exists(pi_user_id   IN  hig_users.hus_user_id%TYPE)                     
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_users
     WHERE hus_user_id   =  pi_user_id;      
    --
    RETURN lv_exists;   
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_exists;  
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_exists(pi_username   IN  hig_users.hus_username%TYPE)                     
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_users
     WHERE hus_username   =  pi_username;      
    --
    RETURN lv_exists;   
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_exists; 
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION active_user_yn(pi_end_date  IN  hig_users.hus_end_date%TYPE) RETURN varchar2
  IS
  --
  l_retval  varchar2(1)  := 'Y'; 
  --
  BEGIN
  --
    IF (    pi_end_date IS NOT NULL
        AND pi_end_date <= TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
       )
      THEN
         l_retval := 'N';
    END IF;
  -- 
    RETURN l_retval;
  --   
  END active_user_yn;  
  
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION sso_user_yn(pi_email  IN  nm_mail_users.nmu_email_address%TYPE)                     
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_relationship
     WHERE hir_attribute1   =  pi_email;      
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
    WHEN OTHERS   -- table may not exist on schema
     THEN
        RETURN lv_exists;    
  END sso_user_yn;
  
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION override_pwd(pi_email  IN  nm_mail_users.nmu_email_address%TYPE)                     
    RETURN varchar2
  IS
    lv_yn VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT hir_attribute3
      INTO lv_yn
      FROM hig_relationship
     WHERE hir_attribute1   =  pi_email;      
    --
    RETURN lv_yn;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_yn;
     
  END override_pwd;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_users(po_message_severity    OUT  hig_codes.hco_code%TYPE
                     ,po_message_cursor      OUT  sys_refcursor
                     ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    /*  Context HIG1832_FILTER value determines the User data retured from view v_nm_hig_users
    --  A = All
    --  L = Active
    --  E = End Dated
    */
    Begin
      Nm3Ctx.Set_Context('HIG1832_FILTER',cv_user_filter);
    End;  
    --
    OPEN po_cursor FOR
    SELECT hus.hus_user_id              user_id
          ,hus.hus_name                 name
          ,hus.hus_initials             initials
          ,hus.hus_job_title            job_title
          ,awlrs_user_api.active_user_yn(pi_end_date => hus.hus_end_date) active
          ,hus.hus_start_date           start_date
          ,hus.hus_end_date             end_date
          ,hus.account_status           status
          ,hus.hus_unrestricted         unrestricted
          ,hus.hus_username             username
          ,hus.password                 password  
          ,hus.default_tablespace       dflt_tablespace         
          ,hus.temporary_tablespace     temp_tablespace
          ,hus.profile                  profile
          ,hus.hus_agent_code           agent_code
          ,hus.hus_admin_unit           admin_unit
          ,hau.hau_unit_code            admin_unit_code
          ,hau.hau_name                 admin_unit_name
          ,huc.huc_address1             address1
          ,huc.huc_address2             address2
          ,huc.huc_address3             address3
          ,huc.huc_address4             address4
          ,huc.huc_address5             address5
          ,huc.huc_postcode             postcode
          ,huc.huc_tel_type_1           tel_type_1
          ,huc.huc_telephone_1          tel_no_1
          ,huc_primary_tel_1            primary_tel_1
          ,huc.huc_tel_type_2           tel_type_2
          ,huc.huc_telephone_2          tel_no_2
          ,huc_primary_tel_2            primary_tel_2
          ,huc.huc_tel_type_3           tel_type_3
          ,huc.huc_telephone_3          tel_no_3
          ,huc_primary_tel_3            primary_tel_3
          ,huc.huc_tel_type_4           tel_type_4
          ,huc.huc_telephone_4          tel_no_4
          ,huc_primary_tel_4            primary_tel_4
          ,nmu.nmu_email_address        email
          ,awlrs_user_api.sso_user_yn(pi_email => nmu.nmu_email_address) sso_user
          ,awlrs_user_api.override_pwd(pi_email => nmu.nmu_email_address) override_pwd
      FROM v_nm_hig_users  hus
          ,hig_admin_units hau               
          ,hig_user_contacts_all huc
          ,nm_mail_users  nmu
     WHERE hus.hus_admin_unit = hau.hau_admin_unit(+)
       AND hus.hus_user_id    = huc.huc_hus_user_id(+)   
       AND hus.hus_user_id    = nmu.nmu_hus_user_id(+)
     ORDER BY hus.hus_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_users;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user(pi_user_id              IN     hig_users.hus_user_id%TYPE
                    ,po_message_severity        OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor          OUT sys_refcursor
                    ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    -- 
    /*  Context HIG1832_FILTER value determines the User data retured from view v_nm_hig_users
    --  A = All
    --  L = Active
    --  E = End Dated
    */
    Begin
      Nm3Ctx.Set_Context('HIG1832_FILTER',cv_user_filter);
    End;  
    --
    OPEN po_cursor FOR
    SELECT hus.hus_user_id              user_id
          ,hus.hus_name                 name
          ,hus.hus_initials             initials
          ,hus.hus_job_title            job_title
          ,awlrs_user_api.active_user_yn(pi_end_date => hus.hus_end_date) active
          ,hus.hus_start_date           start_date
          ,hus.hus_end_date             end_date
          ,hus.account_status           status
          ,hus.hus_unrestricted         unrestricted
          ,hus.hus_username             username
          ,hus.password                 password  
          ,hus.default_tablespace       dflt_tablespace         
          ,hus.temporary_tablespace     temp_tablespace
          ,hus.profile                  profile
          ,hus.hus_agent_code           agent_code
          ,hus.hus_admin_unit           admin_unit
          ,hau.hau_unit_code            admin_unit_code
          ,hau.hau_name                 admin_unit_name
          ,huc.huc_address1             address1
          ,huc.huc_address2             address2
          ,huc.huc_address3             address3
          ,huc.huc_address4             address4
          ,huc.huc_address5             address5
          ,huc.huc_postcode             postcode
          ,huc.huc_tel_type_1           tel_type_1
          ,huc.huc_telephone_1          tel_no_1
          ,huc_primary_tel_1            primary_tel_1
          ,huc.huc_tel_type_2           tel_type_2
          ,huc.huc_telephone_2          tel_no_2
          ,huc_primary_tel_2            primary_tel_2
          ,huc.huc_tel_type_3           tel_type_3
          ,huc.huc_telephone_3          tel_no_3
          ,huc_primary_tel_3            primary_tel_3
          ,huc.huc_tel_type_4           tel_type_4
          ,huc.huc_telephone_4          tel_no_4
          ,huc_primary_tel_4            primary_tel_4  
          ,nmu.nmu_email_address        email
          ,awlrs_user_api.sso_user_yn(pi_email => nmu.nmu_email_address) sso_user
          ,awlrs_user_api.override_pwd(pi_email => nmu.nmu_email_address) override_pwd
      FROM v_nm_hig_users  hus
          ,hig_admin_units hau               
          ,hig_user_contacts_all huc
          ,nm_mail_users  nmu
     WHERE hus.hus_user_id    = pi_user_id
       AND hus.hus_admin_unit = hau.hau_admin_unit(+)
       AND hus.hus_user_id    = huc.huc_hus_user_id(+)   
       AND hus.hus_user_id    = nmu.nmu_hus_user_id(+);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_users(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT hus.hus_user_id              user_id
                                                    ,hus.hus_name                 name
                                                    ,hus.hus_initials             initials
                                                    ,hus.hus_job_title            job_title
                                                    ,awlrs_user_api.active_user_yn(pi_end_date => hus.hus_end_date) active
                                                    ,hus.hus_start_date           start_date
                                                    ,hus.hus_end_date             end_date
                                                    ,hus.account_status           status
                                                    ,hus.hus_unrestricted         unrestricted
                                                    ,hus.hus_username             username
                                                    ,hus.password                 password  
                                                    ,hus.default_tablespace       dflt_tablespace         
                                                    ,hus.temporary_tablespace     temp_tablespace
                                                    ,hus.profile                  profile
                                                    ,hus.hus_agent_code           agent_code
                                                    ,hus.hus_admin_unit           admin_unit
                                                    ,hau.hau_unit_code            admin_unit_code
                                                    ,hau.hau_name                 admin_unit_name
                                                    ,huc.huc_address1             address1
                                                    ,huc.huc_address2             address2
                                                    ,huc.huc_address3             address3
                                                    ,huc.huc_address4             address4
                                                    ,huc.huc_address5             address5
                                                    ,huc.huc_postcode             postcode
                                                    ,huc.huc_tel_type_1           tel_type_1
                                                    ,huc.huc_telephone_1          tel_no_1
                                                    ,huc_primary_tel_1            primary_tel_1
                                                    ,huc.huc_tel_type_2           tel_type_2
                                                    ,huc.huc_telephone_2          tel_no_2
                                                    ,huc_primary_tel_2            primary_tel_2
                                                    ,huc.huc_tel_type_3           tel_type_3
                                                    ,huc.huc_telephone_3          tel_no_3
                                                    ,huc_primary_tel_3            primary_tel_3
                                                    ,huc.huc_tel_type_4           tel_type_4
                                                    ,huc.huc_telephone_4          tel_no_4
                                                    ,huc_primary_tel_4            primary_tel_4  
                                                    ,nmu.nmu_email_address        email
                                                    ,awlrs_user_api.sso_user_yn(pi_email => nmu.nmu_email_address) sso_user
                                                    ,awlrs_user_api.override_pwd(pi_email => nmu.nmu_email_address) override_pwd
                                                FROM v_nm_hig_users  hus     
                                                    ,hig_admin_units hau          
                                                    ,hig_user_contacts_all huc
                                                    ,nm_mail_users  nmu
                                               WHERE hus.hus_admin_unit = hau.hau_admin_unit(+) 
                                                 AND hus.hus_user_id    = huc.huc_hus_user_id(+)   
                                                 AND hus.hus_user_id    = nmu.nmu_hus_user_id(+) ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  user_id'
                                                  ||',name'
                                                  ||',initials'
                                                  ||',job_title'
                                                  ||',active'
                                                  ||',start_date'
                                                  ||',end_date'
                                                  ||',status'
                                                  ||',unrestricted'
                                                  ||',username'
                                                  ||',password'
                                                  ||',dflt_tablespace'
                                                  ||',temp_tablespace'
                                                  ||',profile'
                                                  ||',agent_code'
                                                  ||',admin_unit'
                                                  ||',admin_unit_code'
                                                  ||',admin_unit_name'
                                                  ||',address1'
                                                  ||',address2'
                                                  ||',address3'
                                                  ||',address4'
                                                  ||',address5'
                                                  ||',postcode'
                                                  ||',tel_type_1'
                                                  ||',tel_no_1'
                                                  ||',primary_tel_1'
                                                  ||',tel_type_2'
                                                  ||',tel_no_2'
                                                  ||',primary_tel_2'
                                                  ||',tel_type_3'
                                                  ||',tel_no_3'
                                                  ||',primary_tel_3'
                                                  ||',tel_type_4'
                                                  ||',tel_no_4' 
                                                  ||',primary_tel_4'
                                                  ||',email'
                                                  ||',sso_user'
                                                  ||',override_pwd'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'username'
                                ,pi_query_col    => 'hus_username'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'name'
                                ,pi_query_col    => 'hus_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'initials'
                                ,pi_query_col    => 'hus_initials'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'job_title'
                                ,pi_query_col    => 'hus_job_title'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      
      awlrs_util.add_column_data(pi_cursor_col   => 'active'
                                ,pi_query_col    => 'awlrs_user_api.active_user_yn(pi_end_date => hus.hus_end_date)'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'unrestricted'
                                ,pi_query_col    => 'hus_unrestricted'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'hus_start_date'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                                ,pi_query_col    => 'hus_end_date'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MON-YYYY'
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
      /*  Context HIG1832_FILTER value determines the User data retured from view v_nm_hig_users
      --  A = All
      --  L = Active
      --  E = End Dated
      */
      Begin
         Nm3Ctx.Set_Context('HIG1832_FILTER',cv_user_filter);
      End;  
      --  
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hus_name')||') a)'
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
  END get_paged_users;
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_admin_units_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT  sys_refcursor
                                    ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hau.hau_admin_unit, 
           hau.hau_unit_code, 
           hau.hau_name
      FROM hig_admin_units hau
    ORDER BY hau.hau_unit_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_admin_units_lov;
                          
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_admin_unit_lov(pi_user_admin_unit  IN      hig_admin_units.hau_admin_unit%TYPE
                                   ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT  sys_refcursor
                                   ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hau.hau_admin_unit, 
           hau.hau_unit_code, 
           hau.hau_name
      FROM hig_admin_units hau
     WHERE hau.hau_admin_unit = pi_user_admin_unit
    ORDER BY hau.hau_unit_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_admin_unit_lov;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_temp_tablespaces_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT  sys_refcursor
                                    ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT tablespace_name 
      FROM dba_tablespaces 
     WHERE contents = 'TEMPORARY' 
    ORDER BY tablespace_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_temp_tablespaces_lov;                                  

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_temp_tablespace_lov(pi_tablespace_name  IN      dba_tablespaces.tablespace_name%TYPE
                                   ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT  sys_refcursor
                                   ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT tablespace_name 
      FROM dba_tablespaces 
     WHERE contents = 'TEMPORARY' 
       AND tablespace_name = pi_tablespace_name
    ORDER BY tablespace_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_temp_tablespace_lov;         
                                                                                        
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_dflt_tablespaces_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT  sys_refcursor
                                    ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT tablespace_name 
      FROM user_tablespaces 
     WHERE contents = 'PERMANENT' 
       AND tablespace_name != 'HHINV_LOAD_3_SPACE'
    ORDER BY tablespace_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_dflt_tablespaces_lov;                                  

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_dflt_tablespace_lov(pi_tablespace_name  IN      dba_tablespaces.tablespace_name%TYPE
                                   ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT  sys_refcursor
                                   ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT tablespace_name 
      FROM user_tablespaces 
     WHERE contents = 'PERMANENT' 
       AND tablespace_name = pi_tablespace_name
    ORDER BY tablespace_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_dflt_tablespace_lov;     
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_profiles_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT  sys_refcursor
                                 ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT DISTINCT profile  profile
      FROM dba_profiles 
    ORDER by profile;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_profiles_lov;                               

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_profile_lov(pi_profile          IN      dba_profiles.profile%TYPE
                                ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor      OUT  sys_refcursor
                                ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT DISTINCT profile   profile
      FROM dba_profiles 
     WHERE profile = pi_profile 
    ORDER by profile;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_profile_lov;                                     
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_username(pi_username  IN  hig_users.hus_username%TYPE)
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF INSTR(pi_username,' ',1) = 0 
     THEN
		BEGIN
	  	   SELECT 'Y'
		     INTO lv_exists
		     FROM hig_users	hu
		    WHERE hu.hus_username = pi_username;
							
           IF lv_exists = 'Y' 	   
            THEN
              hig.raise_ner(pi_appl => 'HIG'
                           ,pi_id   =>  64
                           ,pi_supplementary_info  => 'Username: '||pi_username);
           END IF; 
			    
		EXCEPTION
			WHEN NO_DATA_FOUND 
			  THEN
				IF nm3user_admin.user_exists(p_user	=> pi_username) 
				 THEN
				   hig.raise_ner(pi_appl => 'HIG'
                                ,pi_id   =>  445
                                ,pi_supplementary_info  => 'Username: '|| pi_username);
				END IF;
		END;
	ELSE
	    hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  70
                     ,pi_supplementary_info  => 'Usernames can not have spaces in them '|| pi_username);
	END IF;
  END validate_username;
    
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_name(pi_name IN hig_users.hus_name%TYPE)
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_users
     WHERE UPPER(hus_name) = UPPER(pi_name);
     
     IF lv_exists = 'Y' 
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Name: '|| pi_name);
     END IF;                
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        null;
        
  END validate_name;
    	  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_initials(pi_initials IN hig_users.hus_initials%TYPE)
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_users
     WHERE hus_initials	= pi_initials;
     
     IF lv_exists = 'Y' 
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Initials: '|| pi_initials);
     END IF;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        null;
        
  END validate_initials;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_job_title(pi_job_title IN hig_users.hus_job_title%TYPE)
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_job_title IS NOT NULL
     THEN
       SELECT 'Y'
         INTO lv_exists
         FROM hig_codes
        WHERE hco_domain = 'PEO_TITLE_CODE'
          AND hco_code   =  pi_job_title;
          
       IF lv_exists <> 'Y' 
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   =>  29
                       ,pi_supplementary_info  => 'Job Title: '|| pi_job_title);
       END IF;   
    END IF;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        null;
        
  END validate_job_title;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_profile(pi_profile IN dba_profiles.profile%TYPE)
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT DISTINCT('Y')
     INTO lv_exists
     FROM dba_profiles
    WHERE profile = pi_profile;
          
    IF lv_exists <> 'Y' 
     THEN
       hig.raise_ner(pi_appl => 'HIG'
                    ,pi_id   =>  30
                    ,pi_supplementary_info  => 'Profile: '|| pi_profile);
    END IF;   
    --        
  END validate_profile;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_user_contact_details(pi_user_id                IN  hig_user_contacts_all.huc_hus_user_id%TYPE
                                       ,pi_address1               IN  hig_user_contacts_all.huc_address1%TYPE
                                       ,pi_address2               IN  hig_user_contacts_all.huc_address2%TYPE
                                       ,pi_address3               IN  hig_user_contacts_all.huc_address3%TYPE
                                       ,pi_address4               IN  hig_user_contacts_all.huc_address4%TYPE
                                       ,pi_address5               IN  hig_user_contacts_all.huc_address5%TYPE
                                       ,pi_postcode               IN  hig_user_contacts_all.huc_postcode%TYPE
                                       ,pi_tel_type_1             IN  hig_user_contacts_all.huc_tel_type_1%TYPE
                                       ,pi_tel_no_1               IN  hig_user_contacts_all.huc_telephone_1%TYPE
                                       ,pi_primary_tel_1          IN  hig_user_contacts_all.huc_primary_tel_1%TYPE
                                       ,pi_tel_type_2             IN  hig_user_contacts_all.huc_tel_type_2%TYPE
                                       ,pi_tel_no_2               IN  hig_user_contacts_all.huc_telephone_2%TYPE
                                       ,pi_primary_tel_2          IN  hig_user_contacts_all.huc_primary_tel_2%TYPE
                                       ,pi_tel_type_3             IN  hig_user_contacts_all.huc_tel_type_3%TYPE
                                       ,pi_tel_no_3               IN  hig_user_contacts_all.huc_telephone_3%TYPE
                                       ,pi_primary_tel_3          IN  hig_user_contacts_all.huc_primary_tel_3%TYPE
                                       ,pi_tel_type_4             IN  hig_user_contacts_all.huc_tel_type_4%TYPE
                                       ,pi_tel_no_4               IN  hig_user_contacts_all.huc_telephone_4%TYPE
                                       ,pi_primary_tel_4          IN  hig_user_contacts_all.huc_primary_tel_4%TYPE)
  IS
  --
  BEGIN
  --
  IF(   pi_address1 IS NOT NULL
     OR pi_address2 IS NOT NULL
     OR pi_address3 IS NOT NULL
     OR pi_address4 IS NOT NULL
     OR pi_address5 IS NOT NULL
     OR pi_postcode IS NOT NULL
     OR pi_tel_type_1 IS NOT NULL
     OR pi_tel_no_1 IS NOT NULL
     OR pi_primary_tel_1 IS NOT NULL
     OR pi_tel_type_2 IS NOT NULL
     OR pi_tel_no_2 IS NOT NULL
     OR pi_primary_tel_2 IS NOT NULL
     OR pi_tel_type_3 IS NOT NULL
     OR pi_tel_no_3 IS NOT NULL
     OR pi_primary_tel_3 IS NOT NULL
     OR pi_tel_type_4 IS NOT NULL
     OR pi_tel_no_4 IS NOT NULL
     OR pi_primary_tel_4 IS NOT NULL)       
   THEN
      INSERT
          INTO hig_user_contacts_all
              (huc_id
              ,huc_hus_user_id
              ,huc_address1
              ,huc_address2
              ,huc_address3
              ,huc_address4
              ,huc_address5
              ,huc_postcode
              ,huc_tel_type_1
              ,huc_telephone_1
              ,huc_primary_tel_1 
              ,huc_tel_type_2 
              ,huc_telephone_2
              ,huc_primary_tel_2 
              ,huc_tel_type_3
              ,huc_telephone_3
              ,huc_primary_tel_3 
              ,huc_tel_type_4 
              ,huc_telephone_4
              ,huc_primary_tel_4)
      VALUES ( hig_hus_id_seq.NEXTVAL
              ,pi_user_id
              ,pi_address1 
              ,pi_address2 
              ,pi_address3 
              ,pi_address4 
              ,pi_address5 
              ,pi_postcode
              ,pi_tel_type_1
              ,pi_tel_no_1
              ,pi_primary_tel_1
              ,pi_tel_type_2 
              ,pi_tel_no_2
              ,pi_primary_tel_2
              ,pi_tel_type_3
              ,pi_tel_no_3
              ,pi_primary_tel_3  
              ,pi_tel_type_4
              ,pi_tel_no_4
              ,pi_primary_tel_4);
   END IF;           
          
         
  END create_user_contact_details;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_user_email_details(pi_user_id IN  nm_mail_users.nmu_hus_user_id%TYPE
                                     ,pi_name    IN  nm_mail_users.nmu_name%TYPE
                                     ,pi_email   IN  nm_mail_users.nmu_email_address%TYPE)
  IS
  --
  BEGIN
  --
  --no need to check if pi_name is not null as this check will have been in place for creating the hig_user record--
  IF pi_email IS NOT NULL
   THEN
      INSERT
          INTO nm_mail_users
              (nmu_id
              ,nmu_hus_user_id
              ,nmu_name
              ,nmu_email_address)
      VALUES ( Nm3seq.Next_Nmu_Id_Seq
              ,pi_user_id
              ,pi_name 
              ,pi_email); 
  END IF;          
         
  END create_user_email_details; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_default_quota(po_quota	          OUT  dba_ts_quotas.max_bytes%type
							 ,po_quota_size_type  OUT  varchar2)
  IS
  --
  lv_default_quota 	varchar2(38) := upper(trim(hig.get_sysopt(cv_quota_option_name)));
  lv_quota			number;
  lv_quota_type		varchar2(1);
  default_quota_invalid	EXCEPTION;
  --
  BEGIN
  --
    BEGIN
		BEGIN
			lv_quota := to_number(lv_default_quota);
			-- If this doesn't raise a value error then no letter is in the default so assume it's in bytes.
			po_quota :=lv_quota;
			po_quota_size_type :=cv_b;
		EXCEPTION		
			--Must have char(s) in value, so now check to see if it's the last char and one of the valid ones.
			WHEN VALUE_ERROR THEN
				NM_DEBUG.DEBUG('Exception - Value Error, char in system option');
                --get the char at the end of the string
                lv_quota_type := SUBSTR(lv_default_quota,-1,1);
                IF lv_quota_type IN (cv_kb,cv_mb,cv_gb,cv_tb,cv_pb) THEN
                    BEGIN
                        lv_quota :=TO_NUMBER(SUBSTR(lv_default_quota,1,LENGTH(lv_default_quota)-1));
                        po_quota := lv_quota;
                        po_quota_size_type := lv_quota_type;
                    EXCEPTION
                        --Default quota is still invalid.
                        WHEN VALUE_ERROR THEN
                            --nm_debug.debug('Exception - Value Error, char still invalid must have more than one char in field');
                            RAISE default_quota_invalid;
                        END;
                ELSE
                    --nm_debug.debug('product option as an invalid char in it.');
                    RAISE default_quota_invalid;
                END IF;		  
		END;
	EXCEPTION
		WHEN DEFAULT_QUOTA_INVALID THEN
			hig.raise_ner(pi_Appl               => 'HIG'
		                 ,pi_Id                 =>  30
		                 ,pi_Supplementary_Info => 'Can''t determine default Quota from system option:' || cv_quota_option_name);
	END;
          
  END get_default_quota; 
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_proxy_lov(pi_username         IN      hig_users.hus_username%TYPE
                         ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor      OUT  sys_refcursor
                         ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT grantee  proxy_user   
          ,'N'      proxy_user_assigned 
      FROM dba_role_privs
     WHERE granted_role =  cv_proxy_owner
       AND grantee      <> 'SYSTEM'
       AND NOT EXISTS(SELECT 1 FROM PROXY_USERS
                       WHERE PROXY  = grantee
                         AND CLIENT = pi_username)
    UNION ALL
    SELECT grantee  proxy_user
          ,'Y'      proxy_user_assigned 
      FROM dba_role_privs
     WHERE granted_role = cv_proxy_owner
       AND grantee      <> 'SYSTEM'
       AND EXISTS(SELECT 1 FROM PROXY_USERS
                   WHERE PROXY  = grantee
                     AND CLIENT = pi_username)                               
    ORDER BY proxy_user;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_proxy_lov;       
                 
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_proxy_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor      OUT  sys_refcursor
                         ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT grantee proxy_user
      FROM dba_role_privs
     WHERE granted_role = cv_proxy_owner
       AND grantee      <> 'SYSTEM'
     ORDER BY grantee;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_proxy_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION proxy_user_exists(pi_username  IN  hig_users.hus_username%TYPE)                     
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM proxy_users
     WHERE client  =  pi_username;      
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END proxy_user_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION proxy_role_exists(pi_username  IN  hig_users.hus_username%TYPE)                     
    RETURN BOOLEAN
  IS
    lv_exists BOOLEAN := FALSE;
    lv_dummy  varchar2(1) := 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_dummy
      FROM dba_role_privs
     WHERE grantee       =  UPPER(pi_username)
       AND grantee       <> 'SYSTEM'
       AND granted_role  =  cv_proxy_owner;  
    --
    RETURN (lv_dummy = 'Y');
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END proxy_role_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_application_owner                     
    RETURN VARCHAR2
  IS
    lv_app_owner VARCHAR2(30) := Null;
  BEGIN
    --
    SELECT UPPER(SYS_CONTEXT('NM3CORE','APPLICATION_OWNER'))
      INTO lv_app_owner
      FROM dual;      
    --
    RETURN lv_app_owner;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_app_owner;
  END get_application_owner;
   
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_instantiate_user_trg(pi_username IN hig_users.hus_username%Type)
  IS
    --  
	e_trigger_invalid Exception;
	pragma	exception_init(e_trigger_invalid, -24344);
    --
  BEGIN
	--
	BEGIN		
		nm3context.create_instantiate_user_trig(pi_new_trigger_owner => pi_username);   

	EXCEPTION
		WHEN e_trigger_invalid	
		  THEN
			nm3user.lock_account(pi_username => pi_username);
			hig.raise_ner(pi_appl               => 'HIG'
                         ,pi_id                 => 443
                         ,pi_supplementary_info => 'There was a problem with the compilation of the instantiate_user trigger on the new user. The user has been locked. This could be an issue with your synonyms or roles/privileges.');
		
	END;
   END create_instantiate_user_trg;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_sso_user(pi_username           IN  hig_users.hus_username%TYPE
                           ,pi_email              IN  nm_mail_users.nmu_email_address%TYPE
                           ,pi_proxy_users        IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                           ,pi_override_password  IN  varchar2)
  IS
  --
  lr_hig_relationship  hig_relationship%ROWTYPE;
  --
  lv_key   RAW(32);
  --  
  lv_proc_input varchar2(200) := '';
  --
  e_invalid_proxy_user EXCEPTION;
  --
  BEGIN
   -- 
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Email'
                               ,pi_parameter_value => pi_email);
    -- 
    --Firstly assign the proxy users--
    IF  pi_proxy_users.COUNT = 1
        AND pi_proxy_users(1) is not null 
      THEN
        FOR i IN 1..pi_proxy_users.COUNT LOOP
        -- 
           IF (    UPPER(pi_proxy_users(i)) NOT IN ('SYS', 'SYSTEM', get_application_owner)
               AND proxy_role_exists(pi_username => pi_proxy_users(i))) 
            THEN
               lv_proc_input := 'ALTER USER '||pi_username||' GRANT CONNECT THROUGH '||pi_proxy_users(i);
               hig.execute_ddl(lv_proc_input);
           ELSE
               RAISE e_invalid_proxy_user;
           END IF;    
        --
        END LOOP;
       --
    END IF;    
    --
    lv_key := DBMS_CRYPTO.RANDOMBYTES(32);
    lr_hig_relationship.hir_attribute1 := pi_email;
    lr_hig_relationship.hir_attribute2 := hig_relationship_api.encrypt_input(pi_input_string => pi_username
                                                                            ,pi_key          => lv_key);
    lr_hig_relationship.hir_attribute3 := pi_override_password;
    lr_hig_relationship.hir_attribute4 := lv_key;
    -- 
    hig_relationship_api.create_relationship(pi_relationship => lr_hig_relationship);
    --
    EXCEPTION
    WHEN e_invalid_proxy_user
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 560
                     ,pi_Supplementary_Info => 'The Proxy Username specified is incorrect.'); 
  --
  END create_sso_user;                          
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_user(pi_user_id                IN      hig_users.hus_user_id%TYPE
                       ,pi_name                   IN      hig_users.hus_name%TYPE
                       ,pi_initials               IN      hig_users.hus_initials%TYPE
                       ,pi_job_title              IN      hig_users.hus_job_title%TYPE
                       ,pi_start_date             IN      hig_users.hus_start_date%TYPE
                       ,pi_end_date               IN      hig_users.hus_end_date%TYPE
                       ,pi_unrestricted           IN      hig_users.hus_unrestricted%TYPE
                       ,pi_username               IN      hig_users.hus_username%TYPE
                       ,pi_password               IN      varchar2 
                       ,pi_dflt_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                       ,pi_temp_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                       ,pi_profile                IN      dba_profiles.profile%TYPE
                       ,pi_agent_code             IN      hig_users.hus_agent_code%TYPE
                       ,pi_admin_unit             IN      hig_users.hus_admin_unit%TYPE
                       ,pi_address1               IN      hig_user_contacts_all.huc_address1%TYPE
                       ,pi_address2               IN      hig_user_contacts_all.huc_address2%TYPE
                       ,pi_address3               IN      hig_user_contacts_all.huc_address3%TYPE
                       ,pi_address4               IN      hig_user_contacts_all.huc_address4%TYPE
                       ,pi_address5               IN      hig_user_contacts_all.huc_address5%TYPE
                       ,pi_postcode               IN      hig_user_contacts_all.huc_postcode%TYPE
                       ,pi_tel_type_1             IN      hig_user_contacts_all.huc_tel_type_1%TYPE
                       ,pi_tel_no_1               IN      hig_user_contacts_all.huc_telephone_1%TYPE
                       ,pi_primary_tel_1          IN      hig_user_contacts_all.huc_primary_tel_1%TYPE
                       ,pi_tel_type_2             IN      hig_user_contacts_all.huc_tel_type_2%TYPE
                       ,pi_tel_no_2               IN      hig_user_contacts_all.huc_telephone_2%TYPE
                       ,pi_primary_tel_2          IN      hig_user_contacts_all.huc_primary_tel_2%TYPE
                       ,pi_tel_type_3             IN      hig_user_contacts_all.huc_tel_type_3%TYPE
                       ,pi_tel_no_3               IN      hig_user_contacts_all.huc_telephone_3%TYPE
                       ,pi_primary_tel_3          IN      hig_user_contacts_all.huc_primary_tel_3%TYPE
                       ,pi_tel_type_4             IN      hig_user_contacts_all.huc_tel_type_4%TYPE
                       ,pi_tel_no_4               IN      hig_user_contacts_all.huc_telephone_4%TYPE
                       ,pi_primary_tel_4          IN      hig_user_contacts_all.huc_primary_tel_4%TYPE
                       ,pi_email                  IN      nm_mail_users.nmu_email_address%TYPE
                       ,pi_sso_user               IN      varchar2
                       ,pi_override_password      IN      varchar2
                       ,pi_proxy_users            IN      nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                       ,po_message_severity          OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor            OUT  sys_refcursor)
  IS
  --
  lv_password  varchar2(12);
  lv_error_msg varchar2(2000);
  lv_quota     dba_ts_quotas.max_bytes%TYPE;
  lv_quota_size_type  varchar2(1);
  lv_message_severity  hig_codes.hco_code%TYPE;
  lv_message_cursor    sys_refcursor;
  --
  lr_rec_hus    hig_users%ROWTYPE;
  --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    --Firstly we need to check the caller has the correct roles to continue-- 
    IF user_privs_check = 'N'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 146);
    END IF;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Initials'
                               ,pi_parameter_value => pi_initials);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Username'
                               ,pi_parameter_value => pi_username);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Password'
                               ,pi_parameter_value => pi_password);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Unrestricted'
                               ,pi_parameter_value => pi_unrestricted);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Temporary Tablespace'
                               ,pi_parameter_value => pi_temp_tablespace);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Default Tablespace'
                               ,pi_parameter_value => pi_dflt_tablespace);
    --
    --awlrs_util.validate_notnull(pi_parameter_desc  => 'Quota'
    --                           ,pi_parameter_value => pi_quota);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Profile'
                               ,pi_parameter_value => pi_profile);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'SSO User'
                          ,pi_parameter_value => pi_sso_user);
    --                           
    awlrs_util.validate_yn(pi_parameter_desc  => 'SSO User Override Password?'
                          ,pi_parameter_value => pi_override_password);                                                         
    --
    --Data Validation Routines
    --
    validate_name(pi_name => pi_name);
    --
    validate_initials(pi_initials => pi_initials);
    --
    validate_job_title(pi_job_title => pi_job_title);
    --
    validate_username(pi_username => pi_username);
    --
    --validate_quota();
    --
    validate_profile(pi_profile => pi_profile);
    --
    --End Date cannot be earlier than the Start Date--
    IF NVL(pi_end_date, pi_start_date) < pi_start_date
      THEN
         hig.raise_ner(pi_Appl  => 'HIG'
		              ,pi_Id    => 5);
    END IF;
    --
    /*BOD 27/09/19
    Time ran out but would like to streamline this to call create_sso_user or create_user.   
    Note, sso not tested at all so expect some changes --
    */
    -- SSO
    IF (    pi_sso_user = 'Y'
        AND pi_override_password = 'Y')
      THEN
        lv_password := hig_relationship_api.f_generate_password;
    --ELSE
    --    create_user    
    END IF;  
    --
    IF NOT nm3flx.is_string_valid_for_password(pi_Password => NVL(lv_password, pi_password)
                                              ,po_Reason   => lv_error_msg)
      THEN
		hig.raise_ner(pi_Appl               => 'NET'
		             ,pi_Id                 => 555
		             ,pi_Supplementary_Info => lv_Error_Msg);
	End If;
	--
	--Build User Rec 
	lr_rec_hus.Hus_Initials      := pi_initials;
	lr_rec_hus.Hus_Name          := pi_name;
	lr_rec_hus.Hus_Username      := pi_username;
	lr_rec_hus.Hus_Job_Title     := pi_job_title;
	lr_rec_hus.Hus_Agent_Code    := pi_agent_code;
	lr_rec_hus.Hus_Start_Date    := pi_start_date;
	lr_rec_hus.Hus_End_Date      := pi_end_date;           
	lr_rec_hus.Hus_Unrestricted  := pi_unrestricted;       
	lr_rec_hus.Hus_Admin_Unit    := pi_admin_unit;
	--
	--required to call nnm3ddl.create_user--
	get_default_quota(po_quota           => lv_quota
                     ,po_quota_size_type => lv_quota_size_type);
    --                 
	nm3ddl.create_user(p_rec_hus            =>	lr_rec_hus
	                  ,p_password           => 	NVL(lv_password, pi_password)
	                  ,p_default_tablespace => 	pi_dflt_tablespace
	                  ,p_temp_tablespace    => 	pi_temp_tablespace
	                  ,p_default_quota      => 	(lv_quota||lv_quota_size_type)
	                  ,p_profile            => 	pi_profile);
    --	 
    create_user_contact_details(pi_user_id                => lr_rec_hus.hus_user_id
                               ,pi_address1               => pi_address1 
                               ,pi_address2               => pi_address2
                               ,pi_address3               => pi_address3
                               ,pi_address4               => pi_address4
                               ,pi_address5               => pi_address5
                               ,pi_postcode               => pi_postcode
                               ,pi_tel_type_1             => pi_tel_type_1
                               ,pi_tel_no_1               => pi_tel_no_1
                               ,pi_primary_tel_1          => pi_primary_tel_1
                               ,pi_tel_type_2             => pi_tel_type_2
                               ,pi_tel_no_2               => pi_tel_no_2
                               ,pi_primary_tel_2          => pi_primary_tel_2
                               ,pi_tel_type_3             => pi_tel_type_3
                               ,pi_tel_no_3               => pi_tel_no_3
                               ,pi_primary_tel_3          => pi_primary_tel_3
                               ,pi_tel_type_4             => pi_tel_type_4
                               ,pi_tel_no_4               => pi_tel_no_4
                               ,pi_primary_tel_4          => pi_primary_tel_4);
    --
    create_user_email_details(pi_user_id  => lr_rec_hus.hus_user_id 
                             ,pi_name     => pi_name  
                             ,pi_email    => pi_email);                             
    --
    --check sso
    --
    IF pi_sso_user = 'Y'
     THEN
       create_sso_user(pi_username           => pi_username
                      ,pi_email              => pi_email
                      ,pi_proxy_users        => pi_proxy_users
                      ,pi_override_password  => pi_override_password);
    END IF;
    --
    --
    -- All users must have the HIG_USER role assigned. --
    --
    create_user_role(pi_username          =>  pi_username
                    ,pi_role              =>  cv_hig_user_role
                    ,pi_admin_option      =>  Null
                    ,po_message_severity  =>  lv_message_severity
                    ,po_message_cursor    =>  lv_message_cursor
                    ); 
    --
    IF lv_message_severity = awlrs_util.c_msg_cat_success    
      THEN
        --
        create_instantiate_user_trg(pi_username => pi_username);
        --
        nm3ddl.create_sub_sdo_views(pi_username);
        --
        -- run dummy update to action the triggers that copy the user_sdo_geom_metadata
        --
        UPDATE hig_user_roles
        SET    hur_role     = hur_role
        WHERE  hur_username = pi_username;
        -- 
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
  END create_user; 
  
  
  PROCEDURE grant_role_privs (pi_username     IN  hig_users.hus_username%TYPE
    	                     ,pi_role         IN  hig_user_roles.hur_role%TYPE
    	                     ,pi_admin_option IN  dba_role_privs.admin_option%TYPE)
  IS
  --
  lv_proc_input varchar2(200) := '';
  --
  CURSOR c1 IS
    SELECT privilege
      FROM dba_sys_privs
     WHERE grantee = pi_role;
  --
  CURSOR c2 IS
    SELECT d.privilege, d.owner, d.table_name
      FROM dba_tab_privs d
     WHERE d.grantee = pi_role
       AND d.owner   = (SELECT sys_context('NM3_SECURITY_CTX','USERNAME') 
                          FROM user_objects o
                         WHERE o.object_name = 'HIG_OPTIONS'
                           AND o.object_type = 'VIEW'
                        UNION
                        SELECT o.table_owner from user_synonyms o
                         WHERE o.synonym_name = 'HIG_OPTIONS'); 
  --                       
  BEGIN
    --
    IF pi_admin_option = 'YES' THEN
       lv_proc_input := 'GRANT '||pi_role||' TO '||pi_username||' WITH ADMIN OPTION';
    ELSE
       lv_proc_input := 'GRANT '||pi_role||' TO '||pi_username;
    END IF;  
    hig.execute_ddl(lv_proc_input);
    --
    -- Role system privileges                        
    FOR c1_rec in c1
    LOOP
     lv_proc_input := ''; 
          lv_proc_input := ('GRANT '||c1_rec.privilege||' TO '||pi_username);
     hig.execute_ddl(lv_proc_input);
    END LOOP; 
    --  
    -- Role object privileges
    FOR c2_rec IN c2
    LOOP
     lv_proc_input := ''; 
     lv_proc_input := ( 'GRANT ' || c2_rec.privilege
                      ||' ON '   || c2_rec.owner || '.' || c2_rec.table_name
                      ||' TO '   || pi_username);
     hig.execute_ddl(lv_proc_input);
    END LOOP; 
    --

  END grant_role_privs;  	                     
  --
  -----------------------------------------------------------------------------
  --  
  PROCEDURE grant_roles_from_copy(pi_username      varchar2
                                 ,pi_copy_username varchar2 default null)
  IS
  --
   CURSOR cs_hur (c_user varchar2) is
   SELECT hur_role
    FROM  hig_user_roles
   WHERE  hur_username = c_user;
   
   CURSOR cs_drp (c_user varchar2
                 ,c_role varchar2
                 ) is
   SELECT admin_option
    FROM  dba_role_privs
   WHERE  grantee      = c_user
    AND   granted_role = c_role;
   -- 
   lv_admin_option dba_role_privs.admin_option%type;
   --
  BEGIN
   FOR cs_rec IN cs_hur(pi_username)
    LOOP
    	IF pi_copy_username IS NOT NULL
    	 THEN
    	   lv_admin_option := null;
    	   OPEN  cs_drp(pi_copy_username,cs_rec.hur_role);
    	   FETCH cs_drp INTO lv_admin_option;
    	   CLOSE cs_drp;
    	END IF;
    	--
    	grant_role_privs (pi_username     => pi_username
    	                 ,pi_role         => cs_rec.hur_role
    	                 ,pi_admin_option => lv_admin_option);
    	--                 
   END LOOP;
   --
  END grant_roles_from_copy;
  
   --
   -----------------------------------------------------------------------------
   -- 

  PROCEDURE copy_user(pi_copy_user_id      IN      hig_users.hus_user_id%TYPE
                     ,pi_copy_username     IN      hig_users.hus_username%TYPE
                     ,pi_new_name          IN      hig_users.hus_name%TYPE
                     ,pi_new_initials      IN      hig_users.hus_initials%TYPE
                     ,pi_new_username      IN      hig_users.hus_username%TYPE
                     ,pi_new_password      IN      varchar2
                     ,pi_new_start_date    IN      hig_users.hus_start_date%TYPE
                     ,pi_new_unrestricted  IN      hig_users.hus_unrestricted%TYPE
                     ,pi_new_roles         IN      varchar2 
                     ,pi_new_admin_units   IN      varchar2
                     ,pi_new_user_options  IN      varchar2
                     ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                     ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  lv_new_user_id  hig_users.hus_user_id%TYPE;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Copy User Id'
                               ,pi_parameter_value =>  pi_copy_user_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Copy Username'
                               ,pi_parameter_value =>  pi_copy_username);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Initials'
                               ,pi_parameter_value => pi_new_initials);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_new_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Username'
                               ,pi_parameter_value => pi_new_username);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Password'
                               ,pi_parameter_value => pi_new_password);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Unrestricted'
                          ,pi_parameter_value => pi_new_unrestricted);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Copy Roles?'
                          ,pi_parameter_value => pi_new_roles);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Copy Admin Units?'
                          ,pi_parameter_value => pi_new_admin_units);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Copy User Options?'
                          ,pi_parameter_value => pi_new_user_options);                                                                      
    --                 
    nm3user.copy_user (pi_hus_user_id_old   => pi_copy_user_id
                      ,pi_hus_name          => pi_new_name
                      ,pi_hus_initials      => pi_new_initials
                      ,pi_hus_username      => pi_new_username
                      ,pi_password          => pi_new_password
                      ,pi_hus_start_date    => pi_new_start_date
                      ,pi_hus_unrestricted  => pi_new_unrestricted
                      ,pi_copy_roles        => CASE WHEN pi_new_roles = 'Y' THEN TRUE ELSE FALSE END 
                      ,pi_copy_admin_units  => CASE WHEN pi_new_admin_units = 'Y' THEN TRUE ELSE FALSE END
                      ,pi_copy_user_options => CASE WHEN pi_new_user_options = 'Y' THEN TRUE ELSE FALSE END
                      ,po_hus_user_id_new   => lv_new_user_id);
    --
    grant_roles_from_copy(pi_username      => pi_new_username
                         ,pi_copy_username => pi_copy_username);
    --                        
    create_instantiate_user_trg(pi_username => pi_new_username);
    --
    nm3ddl.create_sub_sdo_views(pi_new_username);
    --
    -- run dummy update to action the triggers that copy the user_sdo_geom_metadata??
    --
    UPDATE hig_user_roles
    SET    hur_role     = hur_role
    WHERE  hur_username = pi_new_username;
    --
    IF NVL(hig.get_sysopt('DEFSSO'),'N') = 'Y'
     THEN
       hig.raise_ner(pi_appl               => 'HIG'
                    ,pi_id                 => 2
                    ,pi_supplementary_info => 'Please note: New users created using ''Copy User'' are not registered as SSO users by default');
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
  
  END copy_user;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_contact_dets_exists(pi_user_id   IN  hig_users.hus_user_id%TYPE)                     
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_user_contacts_all
     WHERE huc_hus_user_id   =  pi_user_id;      
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_contact_dets_exists;    
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_email_exists(pi_user_id   IN  hig_users.hus_user_id%TYPE)                     
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_mail_users
     WHERE nmu_hus_user_id   =  pi_user_id;      
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_email_exists;    
  --
  -----------------------------------------------------------------------------
  --                    
  PROCEDURE validate_user_for_update(pi_old_user_id                IN      hig_users.hus_user_id%TYPE
                                    ,pi_old_name                   IN      hig_users.hus_name%TYPE
                                    ,pi_old_initials               IN      hig_users.hus_initials%TYPE
                                    ,pi_old_job_title              IN      hig_users.hus_job_title%TYPE
                                    ,pi_old_start_date             IN      hig_users.hus_start_date%TYPE
                                    ,pi_old_end_date               IN      hig_users.hus_end_date%TYPE
                                    ,pi_old_unrestricted           IN      hig_users.hus_unrestricted%TYPE
                                    ,pi_old_username               IN      hig_users.hus_username%TYPE
                                    ,pi_old_password               IN      varchar2 
                                    ,pi_old_dflt_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                                    ,pi_old_temp_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                                    ,pi_old_profile                IN      dba_profiles.profile%TYPE
                                    ,pi_old_agent_code             IN      hig_users.hus_agent_code%TYPE
                                    ,pi_old_admin_unit             IN      hig_users.hus_admin_unit%TYPE
                                    ,pi_new_user_id                IN      hig_users.hus_user_id%TYPE
                                    ,pi_new_name                   IN      hig_users.hus_name%TYPE
                                    ,pi_new_initials               IN      hig_users.hus_initials%TYPE
                                    ,pi_new_job_title              IN      hig_users.hus_job_title%TYPE
                                    ,pi_new_start_date             IN      hig_users.hus_start_date%TYPE
                                    ,pi_new_end_date               IN      hig_users.hus_end_date%TYPE
                                    ,pi_new_unrestricted           IN      hig_users.hus_unrestricted%TYPE
                                    ,pi_new_username               IN      hig_users.hus_username%TYPE
                                    ,pi_new_password               IN      varchar2 
                                    ,pi_new_dflt_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                                    ,pi_new_temp_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                                    ,pi_new_profile                IN      dba_profiles.profile%TYPE
                                    ,pi_new_agent_code             IN      hig_users.hus_agent_code%TYPE
                                    ,pi_new_admin_unit             IN      hig_users.hus_admin_unit%TYPE
                                    ,pi_new_sso_user               IN      varchar2
                                    ,pi_new_override_password      IN      varchar2
                                    ,po_user_latest_rec_flag       IN OUT  boolean
                                    ,po_user_upd_rec_flag          IN OUT  boolean)
  IS
    --
    lr_db_rec         hig_users%ROWTYPE;
    lv_upd            VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_users
       WHERE hus_user_id = pi_old_user_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'User does not exist');
    --
    END get_db_rec;
    --
  BEGIN
    --   
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Initials'
                               ,pi_parameter_value => pi_new_initials);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_new_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Username'
                               ,pi_parameter_value => pi_new_username);
    --
    --awlrs_util.validate_notnull(pi_parameter_desc  => 'Password'
    --                           ,pi_parameter_value => pi_new_password);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Unrestricted'
                               ,pi_parameter_value => pi_new_unrestricted);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Temporary Tablespace'
                               ,pi_parameter_value => pi_new_temp_tablespace);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Default Tablespace'
                               ,pi_parameter_value => pi_new_dflt_tablespace);
    --
    --awlrs_util.validate_notnull(pi_parameter_desc  => 'Quota'
    --                           ,pi_parameter_value => pi_quota);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Profile'
                               ,pi_parameter_value => pi_new_profile);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'SSO User'
                          ,pi_parameter_value => pi_new_sso_user);
    --                           
    awlrs_util.validate_yn(pi_parameter_desc  => 'SSO User Override Password?'
                          ,pi_parameter_value => pi_new_override_password);                                                         
    --                               
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.hus_user_id != pi_old_user_id
     OR (lr_db_rec.hus_user_id IS NULL AND pi_old_user_id IS NOT NULL)
     OR (lr_db_rec.hus_user_id IS NOT NULL AND pi_old_user_id IS NULL)
     --
     OR (lr_db_rec.hus_initials != pi_old_initials)
     OR (lr_db_rec.hus_initials IS NULL AND pi_old_initials IS NOT NULL)
     OR (lr_db_rec.hus_initials IS NOT NULL AND pi_old_initials IS NULL)
     --
     OR (lr_db_rec.hus_name != pi_old_name)
     OR (lr_db_rec.hus_name IS NULL AND pi_old_name IS NOT NULL)
     OR (lr_db_rec.hus_name IS NOT NULL AND pi_old_name IS NULL)
     --
     OR (lr_db_rec.hus_username != pi_old_username)
     OR (lr_db_rec.hus_username IS NULL AND pi_old_username IS NOT NULL)
     OR (lr_db_rec.hus_username IS NOT NULL AND pi_old_username IS NULL)
     --
     --password??
     --
     OR (lr_db_rec.hus_job_title != pi_old_job_title)
     OR (lr_db_rec.hus_job_title IS NULL AND pi_old_job_title IS NOT NULL)
     OR (lr_db_rec.hus_job_title IS NOT NULL AND pi_old_job_title IS NULL)
     --
     OR (lr_db_rec.hus_agent_code != pi_old_agent_code)
     OR (lr_db_rec.hus_agent_code IS NULL AND pi_old_agent_code IS NOT NULL)
     OR (lr_db_rec.hus_agent_code IS NOT NULL AND pi_old_agent_code IS NULL)
     --
     OR (lr_db_rec.hus_start_date != pi_old_start_date)
     OR (lr_db_rec.hus_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_rec.hus_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --
     OR (lr_db_rec.hus_end_date != pi_old_end_date)
     OR (lr_db_rec.hus_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_rec.hus_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     OR (lr_db_rec.hus_unrestricted != pi_old_unrestricted)
     OR (lr_db_rec.hus_unrestricted IS NULL AND pi_old_unrestricted IS NOT NULL)
     OR (lr_db_rec.hus_unrestricted IS NOT NULL AND pi_old_unrestricted IS NULL)
     --
     OR (lr_db_rec.hus_admin_unit != pi_old_admin_unit)
     OR (lr_db_rec.hus_admin_unit IS NULL AND pi_old_admin_unit IS NOT NULL)
     OR (lr_db_rec.hus_admin_unit IS NOT NULL AND pi_old_admin_unit IS NULL)
     --
     THEN
        --Updated by another user
        po_user_latest_rec_flag := FALSE;
    ELSE
     /*
      ||Compare Old with New
      */
      IF pi_old_user_id != pi_new_user_id
       OR (pi_old_user_id IS NULL AND pi_new_user_id IS NOT NULL)
       OR (pi_old_user_id IS NOT NULL AND pi_new_user_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_initials != pi_new_initials
       OR (pi_old_initials IS NULL AND pi_new_initials IS NOT NULL)
       OR (pi_old_initials IS NOT NULL AND pi_new_initials IS NULL)
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
      IF pi_old_username != pi_new_username
       OR (pi_old_username IS NULL AND pi_new_username IS NOT NULL)
       OR (pi_old_username IS NOT NULL AND pi_new_username IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      --password
      --
      IF pi_old_job_title != pi_new_job_title
       OR (pi_old_job_title IS NULL AND pi_new_job_title IS NOT NULL)
       OR (pi_old_job_title IS NOT NULL AND pi_new_job_title IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_agent_code != pi_new_agent_code
       OR (pi_old_agent_code IS NULL AND pi_new_agent_code IS NOT NULL)
       OR (pi_old_agent_code IS NOT NULL AND pi_new_agent_code IS NULL)
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
      IF pi_old_unrestricted != pi_new_unrestricted
       OR (pi_old_unrestricted IS NULL AND pi_new_unrestricted IS NOT NULL)
       OR (pi_old_unrestricted IS NOT NULL AND pi_new_unrestricted IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_admin_unit != pi_new_admin_unit
       OR (pi_old_admin_unit IS NULL AND pi_new_admin_unit IS NOT NULL)
       OR (pi_old_admin_unit IS NOT NULL AND pi_new_admin_unit IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_dflt_tablespace != pi_new_dflt_tablespace
       OR (pi_old_dflt_tablespace IS NULL AND pi_new_dflt_tablespace IS NOT NULL)
       OR (pi_old_dflt_tablespace IS NOT NULL AND pi_new_dflt_tablespace IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_temp_tablespace != pi_new_temp_tablespace
       OR (pi_old_temp_tablespace IS NULL AND pi_new_temp_tablespace IS NOT NULL)
       OR (pi_old_temp_tablespace IS NOT NULL AND pi_new_temp_tablespace IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_profile != pi_new_profile
       OR (pi_old_profile IS NULL AND pi_new_profile IS NOT NULL)
       OR (pi_old_profile IS NOT NULL AND pi_new_profile IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          po_user_upd_rec_flag := FALSE;
      END IF;     
    END IF;
    --  
  END validate_user_for_update;                              

  --
  -----------------------------------------------------------------------------
  --                    
  PROCEDURE validate_user_contact_dets(pi_old_user_id                IN  hig_user_contacts_all.huc_hus_user_id%TYPE
                                      ,pi_old_address1               IN  hig_user_contacts_all.huc_address1%TYPE
                                      ,pi_old_address2               IN  hig_user_contacts_all.huc_address2%TYPE
                                      ,pi_old_address3               IN  hig_user_contacts_all.huc_address3%TYPE
                                      ,pi_old_address4               IN  hig_user_contacts_all.huc_address4%TYPE
                                      ,pi_old_address5               IN  hig_user_contacts_all.huc_address5%TYPE
                                      ,pi_old_postcode               IN  hig_user_contacts_all.huc_postcode%TYPE
                                      ,pi_old_tel_type_1             IN  hig_user_contacts_all.huc_tel_type_1%TYPE
                                      ,pi_old_tel_no_1               IN  hig_user_contacts_all.huc_telephone_1%TYPE
                                      ,pi_old_primary_tel_1          IN  hig_user_contacts_all.huc_primary_tel_1%TYPE
                                      ,pi_old_tel_type_2             IN  hig_user_contacts_all.huc_tel_type_2%TYPE
                                      ,pi_old_tel_no_2               IN  hig_user_contacts_all.huc_telephone_2%TYPE
                                      ,pi_old_primary_tel_2          IN  hig_user_contacts_all.huc_primary_tel_2%TYPE
                                      ,pi_old_tel_type_3             IN  hig_user_contacts_all.huc_tel_type_3%TYPE
                                      ,pi_old_tel_no_3               IN  hig_user_contacts_all.huc_telephone_3%TYPE
                                      ,pi_old_primary_tel_3          IN  hig_user_contacts_all.huc_primary_tel_3%TYPE
                                      ,pi_old_tel_type_4             IN  hig_user_contacts_all.huc_tel_type_4%TYPE
                                      ,pi_old_tel_no_4               IN  hig_user_contacts_all.huc_telephone_4%TYPE
                                      ,pi_old_primary_tel_4          IN  hig_user_contacts_all.huc_primary_tel_4%TYPE
                                      ,pi_new_user_id                IN  hig_user_contacts_all.huc_hus_user_id%TYPE
                                      ,pi_new_address1               IN  hig_user_contacts_all.huc_address1%TYPE
                                      ,pi_new_address2               IN  hig_user_contacts_all.huc_address2%TYPE
                                      ,pi_new_address3               IN  hig_user_contacts_all.huc_address3%TYPE
                                      ,pi_new_address4               IN  hig_user_contacts_all.huc_address4%TYPE
                                      ,pi_new_address5               IN  hig_user_contacts_all.huc_address5%TYPE
                                      ,pi_new_postcode               IN  hig_user_contacts_all.huc_postcode%TYPE
                                      ,pi_new_tel_type_1             IN  hig_user_contacts_all.huc_tel_type_1%TYPE
                                      ,pi_new_tel_no_1               IN  hig_user_contacts_all.huc_telephone_1%TYPE
                                      ,pi_new_primary_tel_1          IN  hig_user_contacts_all.huc_primary_tel_1%TYPE
                                      ,pi_new_tel_type_2             IN  hig_user_contacts_all.huc_tel_type_2%TYPE
                                      ,pi_new_tel_no_2               IN  hig_user_contacts_all.huc_telephone_2%TYPE
                                      ,pi_new_primary_tel_2          IN  hig_user_contacts_all.huc_primary_tel_2%TYPE
                                      ,pi_new_tel_type_3             IN  hig_user_contacts_all.huc_tel_type_3%TYPE
                                      ,pi_new_tel_no_3               IN  hig_user_contacts_all.huc_telephone_3%TYPE
                                      ,pi_new_primary_tel_3          IN  hig_user_contacts_all.huc_primary_tel_3%TYPE
                                      ,pi_new_tel_type_4             IN  hig_user_contacts_all.huc_tel_type_4%TYPE
                                      ,pi_new_tel_no_4               IN  hig_user_contacts_all.huc_telephone_4%TYPE
                                      ,pi_new_primary_tel_4          IN  hig_user_contacts_all.huc_primary_tel_4%TYPE
                                      ,po_contacts_latest_rec_flag   IN OUT  boolean
                                      ,po_contacts_upd_rec_flag      IN OUT  boolean)
  IS
    --
    lr_db_rec        hig_user_contacts_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_user_contacts_all
       WHERE huc_hus_user_id = pi_old_user_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'User Contact Details do not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --   
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.huc_hus_user_id != pi_old_user_id
     OR (lr_db_rec.huc_hus_user_id IS NULL AND pi_old_user_id IS NOT NULL)
     OR (lr_db_rec.huc_hus_user_id IS NOT NULL AND pi_old_user_id IS NULL)
     --
     OR (lr_db_rec.huc_address1 != pi_old_address1)
     OR (lr_db_rec.huc_address1 IS NULL AND pi_old_address1 IS NOT NULL)
     OR (lr_db_rec.huc_address1 IS NOT NULL AND pi_old_address1 IS NULL)
     --
     OR (lr_db_rec.huc_address2 != pi_old_address2)
     OR (lr_db_rec.huc_address2 IS NULL AND pi_old_address2 IS NOT NULL)
     OR (lr_db_rec.huc_address2 IS NOT NULL AND pi_old_address2 IS NULL)
     --
     OR (lr_db_rec.huc_address3 != pi_old_address3)
     OR (lr_db_rec.huc_address3 IS NULL AND pi_old_address3 IS NOT NULL)
     OR (lr_db_rec.huc_address3 IS NOT NULL AND pi_old_address3 IS NULL)
     --
     OR (lr_db_rec.huc_address4 != pi_old_address4)
     OR (lr_db_rec.huc_address4 IS NULL AND pi_old_address4 IS NOT NULL)
     OR (lr_db_rec.huc_address4 IS NOT NULL AND pi_old_address4 IS NULL)
     --
     OR (lr_db_rec.huc_address5 != pi_old_address5)
     OR (lr_db_rec.huc_address5 IS NULL AND pi_old_address5 IS NOT NULL)
     OR (lr_db_rec.huc_address5 IS NOT NULL AND pi_old_address5 IS NULL)
     --
     OR (lr_db_rec.huc_postcode != pi_old_postcode)
     OR (lr_db_rec.huc_postcode IS NULL AND pi_old_postcode IS NOT NULL)
     OR (lr_db_rec.huc_postcode IS NOT NULL AND pi_old_postcode IS NULL)
     --
     OR (lr_db_rec.huc_tel_type_1 != pi_old_tel_type_1)
     OR (lr_db_rec.huc_tel_type_1 IS NULL AND pi_old_tel_type_1 IS NOT NULL)
     OR (lr_db_rec.huc_tel_type_1 IS NOT NULL AND pi_old_tel_type_1 IS NULL)
     --
     OR (lr_db_rec.huc_telephone_1 != pi_old_tel_no_1)
     OR (lr_db_rec.huc_telephone_1 IS NULL AND pi_old_tel_no_1 IS NOT NULL)
     OR (lr_db_rec.huc_telephone_1 IS NOT NULL AND pi_old_tel_no_1 IS NULL)
     --
     OR (lr_db_rec.huc_primary_tel_1 != pi_old_primary_tel_1)
     OR (lr_db_rec.huc_primary_tel_1 IS NULL AND pi_old_primary_tel_1 IS NOT NULL)
     OR (lr_db_rec.huc_primary_tel_1 IS NOT NULL AND pi_old_primary_tel_1 IS NULL)
     --    
     OR (lr_db_rec.huc_tel_type_2 != pi_old_tel_type_2)
     OR (lr_db_rec.huc_tel_type_2 IS NULL AND pi_old_tel_type_2 IS NOT NULL)
     OR (lr_db_rec.huc_tel_type_2 IS NOT NULL AND pi_old_tel_type_2 IS NULL)
     --
     OR (lr_db_rec.huc_telephone_2 != pi_old_tel_no_2)
     OR (lr_db_rec.huc_telephone_2 IS NULL AND pi_old_tel_no_2 IS NOT NULL)
     OR (lr_db_rec.huc_telephone_2 IS NOT NULL AND pi_old_tel_no_2 IS NULL)
     --
     OR (lr_db_rec.huc_primary_tel_2 != pi_old_primary_tel_2)
     OR (lr_db_rec.huc_primary_tel_2 IS NULL AND pi_old_primary_tel_2 IS NOT NULL)
     OR (lr_db_rec.huc_primary_tel_2 IS NOT NULL AND pi_old_primary_tel_2 IS NULL)
     --
     OR (lr_db_rec.huc_tel_type_3 != pi_old_tel_type_3)
     OR (lr_db_rec.huc_tel_type_3 IS NULL AND pi_old_tel_type_3 IS NOT NULL)
     OR (lr_db_rec.huc_tel_type_3 IS NOT NULL AND pi_old_tel_type_3 IS NULL)
     --
     OR (lr_db_rec.huc_telephone_3 != pi_old_tel_no_3)
     OR (lr_db_rec.huc_telephone_3 IS NULL AND pi_old_tel_no_3 IS NOT NULL)
     OR (lr_db_rec.huc_telephone_3 IS NOT NULL AND pi_old_tel_no_3 IS NULL)
     --
     OR (lr_db_rec.huc_primary_tel_3 != pi_old_primary_tel_3)
     OR (lr_db_rec.huc_primary_tel_3 IS NULL AND pi_old_primary_tel_3 IS NOT NULL)
     OR (lr_db_rec.huc_primary_tel_3 IS NOT NULL AND pi_old_primary_tel_3 IS NULL)
     --     
     OR (lr_db_rec.huc_tel_type_4 != pi_old_tel_type_4)
     OR (lr_db_rec.huc_tel_type_4 IS NULL AND pi_old_tel_type_4 IS NOT NULL)
     OR (lr_db_rec.huc_tel_type_4 IS NOT NULL AND pi_old_tel_type_4 IS NULL)
     --
     OR (lr_db_rec.huc_telephone_4 != pi_old_tel_no_4)
     OR (lr_db_rec.huc_telephone_4 IS NULL AND pi_old_tel_no_4 IS NOT NULL)
     OR (lr_db_rec.huc_telephone_4 IS NOT NULL AND pi_old_tel_no_4 IS NULL)
     --
     OR (lr_db_rec.huc_primary_tel_4 != pi_old_primary_tel_4)
     OR (lr_db_rec.huc_primary_tel_4 IS NULL AND pi_old_primary_tel_4 IS NOT NULL)
     OR (lr_db_rec.huc_primary_tel_4 IS NOT NULL AND pi_old_primary_tel_4 IS NULL)
     --
     THEN
        --Updated by another user
        po_contacts_latest_rec_flag := FALSE;
    ELSE
     /*
      ||Compare Old with New
      */
      IF pi_old_user_id != pi_new_user_id
       OR (pi_old_user_id IS NULL AND pi_new_user_id IS NOT NULL)
       OR (pi_old_user_id IS NOT NULL AND pi_new_user_id IS NULL)
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
      IF pi_old_postcode != pi_new_postcode
       OR (pi_old_postcode IS NULL AND pi_new_postcode IS NOT NULL)
       OR (pi_old_postcode IS NOT NULL AND pi_new_postcode IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_type_1 != pi_new_tel_type_1
       OR (pi_old_tel_type_1 IS NULL AND pi_new_tel_type_1 IS NOT NULL)
       OR (pi_old_tel_type_1 IS NOT NULL AND pi_new_tel_type_1 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_no_1 != pi_new_tel_no_1
       OR (pi_old_tel_no_1 IS NULL AND pi_new_tel_no_1 IS NOT NULL)
       OR (pi_old_tel_no_1 IS NOT NULL AND pi_new_tel_no_1 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_primary_tel_1 != pi_new_primary_tel_1
       OR (pi_old_primary_tel_1 IS NULL AND pi_new_primary_tel_1 IS NOT NULL)
       OR (pi_old_primary_tel_1 IS NOT NULL AND pi_new_primary_tel_1 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_type_2 != pi_new_tel_type_2
       OR (pi_old_tel_type_2 IS NULL AND pi_new_tel_type_2 IS NOT NULL)
       OR (pi_old_tel_type_2 IS NOT NULL AND pi_new_tel_type_2 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_no_2 != pi_new_tel_no_2
       OR (pi_old_tel_no_2 IS NULL AND pi_new_tel_no_2 IS NOT NULL)
       OR (pi_old_tel_no_2 IS NOT NULL AND pi_new_tel_no_2 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_primary_tel_2 != pi_new_primary_tel_2
       OR (pi_old_primary_tel_2 IS NULL AND pi_new_primary_tel_2 IS NOT NULL)
       OR (pi_old_primary_tel_2 IS NOT NULL AND pi_new_primary_tel_2 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_type_3 != pi_new_tel_type_3
       OR (pi_old_tel_type_3 IS NULL AND pi_new_tel_type_3 IS NOT NULL)
       OR (pi_old_tel_type_3 IS NOT NULL AND pi_new_tel_type_3 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_no_3 != pi_new_tel_no_3
       OR (pi_old_tel_no_3 IS NULL AND pi_new_tel_no_3 IS NOT NULL)
       OR (pi_old_tel_no_3 IS NOT NULL AND pi_new_tel_no_3 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_primary_tel_3 != pi_new_primary_tel_3
       OR (pi_old_primary_tel_3 IS NULL AND pi_new_primary_tel_3 IS NOT NULL)
       OR (pi_old_primary_tel_3 IS NOT NULL AND pi_new_primary_tel_3 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_type_4 != pi_new_tel_type_4
       OR (pi_old_tel_type_4 IS NULL AND pi_new_tel_type_4 IS NOT NULL)
       OR (pi_old_tel_type_4 IS NOT NULL AND pi_new_tel_type_4 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tel_no_4 != pi_new_tel_no_4
       OR (pi_old_tel_no_4 IS NULL AND pi_new_tel_no_4 IS NOT NULL)
       OR (pi_old_tel_no_4 IS NOT NULL AND pi_new_tel_no_4 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_primary_tel_4 != pi_new_primary_tel_4
       OR (pi_old_primary_tel_4 IS NULL AND pi_new_primary_tel_4 IS NOT NULL)
       OR (pi_old_primary_tel_4 IS NOT NULL AND pi_new_primary_tel_4 IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          po_contacts_upd_rec_flag := FALSE;
      END IF;     
    END IF;
    --  
  END validate_user_contact_dets;
  
  --
  -----------------------------------------------------------------------------
  --                    
  PROCEDURE validate_user_email_details(pi_old_user_id             IN  nm_mail_users.nmu_hus_user_id%TYPE
                                       ,pi_old_name                IN  nm_mail_users.nmu_name%TYPE
                                       ,pi_old_email               IN  nm_mail_users.nmu_email_address%TYPE
                                       ,pi_new_user_id             IN  nm_mail_users.nmu_hus_user_id%TYPE
                                       ,pi_new_name                IN  nm_mail_users.nmu_name%TYPE
                                       ,pi_new_email               IN  nm_mail_users.nmu_email_address%TYPE
                                       ,po_email_latest_rec_flag   IN OUT  boolean
                                       ,po_email_upd_rec_flag      IN OUT  boolean)
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
       WHERE nmu_hus_user_id = pi_old_user_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'User does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --   
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nmu_hus_user_id != pi_old_user_id
     OR (lr_db_rec.nmu_hus_user_id IS NULL AND pi_old_user_id IS NOT NULL)
     OR (lr_db_rec.nmu_hus_user_id IS NOT NULL AND pi_old_user_id IS NULL)
     --
     OR (lr_db_rec.nmu_name != pi_old_name)
     OR (lr_db_rec.nmu_name IS NULL AND pi_old_name IS NOT NULL)
     OR (lr_db_rec.nmu_name IS NOT NULL AND pi_old_name IS NULL)
     --
     OR (lr_db_rec.nmu_email_address != pi_old_email)
     OR (lr_db_rec.nmu_email_address IS NULL AND pi_old_email IS NOT NULL)
     OR (lr_db_rec.nmu_email_address IS NOT NULL AND pi_old_email IS NULL)
     --
     THEN
        --Updated by another user
        po_email_latest_rec_flag := FALSE;
    ELSE
     /*
      ||Compare Old with New
      */
      IF pi_old_user_id != pi_new_user_id
       OR (pi_old_user_id IS NULL AND pi_new_user_id IS NOT NULL)
       OR (pi_old_user_id IS NOT NULL AND pi_new_user_id IS NULL)
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
      IF pi_old_email != pi_new_email
       OR (pi_old_email IS NULL AND pi_new_email IS NOT NULL)
       OR (pi_old_email IS NOT NULL AND pi_new_email IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          po_email_upd_rec_flag := FALSE;
      END IF;     
    END IF;
    --  
  END validate_user_email_details;
  
  --
  -----------------------------------------------------------------------------
  --                    
  PROCEDURE validate_sso_data(pi_old_email              IN      nm_mail_users.nmu_email_address%TYPE
                             ,pi_old_proxy_users        IN      nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                             ,pi_old_override_password  IN      varchar2
                             ,pi_new_email              IN      nm_mail_users.nmu_email_address%TYPE
                             ,pi_new_proxy_users        IN      nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                             ,pi_new_override_password  IN      varchar2
                             ,po_sso_latest_rec_flag    IN OUT  boolean
                             ,po_sso_upd_rec_flag       IN OUT  boolean)                                     
  IS
    --
    lr_db_rec        hig_relationship%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_relationship
       WHERE hir_attribute1 = pi_old_email
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'SSO Email does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --   
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.hir_attribute1 != pi_old_email
     OR (lr_db_rec.hir_attribute1 IS NULL AND pi_old_email IS NOT NULL)
     OR (lr_db_rec.hir_attribute1 IS NOT NULL AND pi_old_email IS NULL)
     --
     OR (lr_db_rec.hir_attribute3 != pi_old_override_password)
     OR (lr_db_rec.hir_attribute3 IS NULL AND pi_old_override_password IS NOT NULL)
     OR (lr_db_rec.hir_attribute3 IS NOT NULL AND pi_old_override_password IS NULL)
     --
     THEN
        --Updated by another user
        po_sso_latest_rec_flag := FALSE;
    ELSE
     /*
      ||Compare Old with New
      */
      IF pi_old_email != pi_new_email
       OR (pi_old_email IS NULL AND pi_new_email IS NOT NULL)
       OR (pi_old_email IS NOT NULL AND pi_new_email IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_override_password != pi_new_override_password
       OR (pi_old_override_password IS NULL AND pi_new_override_password IS NOT NULL)
       OR (pi_old_override_password IS NOT NULL AND pi_new_override_password IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          po_sso_upd_rec_flag := FALSE;
      END IF;     
    END IF;
    --  
  END validate_sso_data;
  
  --
  -----------------------------------------------------------------------------
  --                    
  PROCEDURE process_account_status(pi_username     IN  hig_users.hus_username%TYPE
                                  ,pi_old_end_date IN  hig_users.hus_end_date%TYPE
                                  ,pi_new_end_date IN  hig_users.hus_end_date%TYPE)
  IS
  --
  BEGIN
    --  
    IF (    pi_new_end_date IS NULL 
            AND pi_old_end_date IS NOT NULL) 
     THEN 
		    nm3user.unlock_account(pi_username => pi_username);	
	ELSIF
	   (    pi_old_end_date IS NULL 
	    AND pi_new_end_date IS NOT NULL) 
	 THEN
	        nm3user.lock_account(pi_username => pi_username);
	END IF;
   --   
  END process_account_status;                              

  --
  -----------------------------------------------------------------------------
  --                    
  PROCEDURE process_tablespace(pi_username            IN  hig_users.hus_username%TYPE
                              ,pi_old_dflt_tablespace IN  dba_tablespaces.tablespace_name%TYPE
                              ,pi_new_dflt_tablespace IN  dba_tablespaces.tablespace_name%TYPE)
  IS
  --
  lv_quota            dba_ts_quotas.max_bytes%TYPE;
  lv_quota_size_type  varchar2(1);
  --
  BEGIN
    --  
    IF (    pi_old_dflt_tablespace <> pi_new_dflt_tablespace
        OR  pi_old_dflt_tablespace IS NULL AND  pi_new_dflt_tablespace IS NOT NULL
        OR  pi_old_dflt_tablespace IS NOT NULL AND  pi_new_dflt_tablespace IS NULL)
     THEN 
        --
        get_default_quota(po_quota           => lv_quota
                         ,po_quota_size_type => lv_quota_size_type);
        -- 
        nm3user_admin.set_default_tablespace(p_User                    => pi_username
											,p_Default_Tablespace_Name => pi_new_dflt_tablespace
											,p_Quota				   => lv_quota
											,p_Quota_Size_Type		   => lv_quota_size_type);                
    --
	END IF;
   --   
  END process_tablespace;

  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE process_password(pi_username     IN  hig_users.hus_username%TYPE
                            ,pi_old_password IN  varchar2
                            ,pi_new_password IN  varchar2)
  IS
  --
  invalid_password EXCEPTION;
  invalid_user	   EXCEPTION;
	
  Pragma Exception_Init(Invalid_User,-20001);
  Pragma Exception_Init(Invalid_Password,-20002);
  --
  BEGIN
    --  
    IF pi_old_password <> pi_new_password
     THEN 
        --
        BEGIN 
        nm3user_admin.set_user_password(p_user      =>	pi_username
								       ,p_Password  =>	pi_new_password);
        EXCEPTION
			WHEN invalid_password	
			 THEN			  
			    hig.raise_ner(pi_appl => 'NET'
                             ,pi_id   => 555);
			WHEN invalid_user 
			 THEN 
			    hig.raise_ner(pi_appl => 'NET'
                             ,pi_id   => 560);			
        END;								        
	    --
	END IF;
   --   
  END process_password;
  
  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE process_profile(pi_username     IN  hig_users.hus_username%TYPE
                           ,pi_old_profile  IN  dba_profiles.profile%TYPE
                           ,pi_new_profile  IN  dba_profiles.profile%TYPE)
  IS
  --
  BEGIN
    -- 
    NM_DEBUG.DEBUG('process_profile STARTING');
    
    IF (    pi_old_profile <> pi_new_profile
        OR  pi_old_profile IS NULL AND pi_new_profile IS NOT NULL
        OR  pi_old_profile IS NOT NULL AND pi_new_profile IS NULL)
     THEN 
        NM_DEBUG.DEBUG('b4 call to set_user_profile'); 
        nm3user_admin.set_user_profile(p_user    =>	pi_username
				                      ,p_profile =>	pi_new_profile);                  
    END IF; 
    
    NM_DEBUG.DEBUG('process_profile ending');
    --  
  END process_profile;
 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_sso_user(pi_username               IN  hig_users.hus_username%TYPE
                           ,pi_old_email              IN  nm_mail_users.nmu_email_address%TYPE
                           ,pi_new_email              IN  nm_mail_users.nmu_email_address%TYPE
                           ,pi_old_proxy_users        IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                           ,pi_new_proxy_users        IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                           ,pi_old_override_password  IN  varchar2
                           ,pi_new_override_password  IN  varchar2)
  IS
  --
  lv_proc_input varchar2(200) := '';
  lv_application_owner varchar2(40);
  --
  e_invalid_proxy_user EXCEPTION;
  --
  BEGIN
   -- 
    IF (  pi_old_email <> pi_new_email
       OR pi_old_override_password <> pi_new_override_password)
      THEN
        hig_relationship_api.update_relationship(pi_key        =>  pi_old_email
                                                ,pi_attribute1 =>  pi_new_email
                                                ,pi_attribute3 =>  pi_new_override_password);
    END IF;
    --
    --Firstly revoke current proxy users
    IF  pi_old_proxy_users.COUNT = 1
        AND pi_old_proxy_users(1) is not null 
      THEN          
        FOR i IN 1..pi_old_proxy_users.COUNT LOOP
		--
		    IF (    UPPER(pi_old_proxy_users(i)) NOT IN ('SYS', 'SYSTEM', get_application_owner)
                AND proxy_role_exists(pi_username => pi_old_proxy_users(i))) 
             THEN
               lv_proc_input :='ALTER USER '||pi_username||' REVOKE CONNECT THROUGH '||pi_old_proxy_users(i);
               hig.execute_ddl(lv_proc_input);
            ELSE
               RAISE e_invalid_proxy_user;
            END IF; 
            --
        END LOOP;
      --        
    END IF;
    --
	--Now assign the new proxy users--
	IF  pi_new_proxy_users.COUNT = 1
        AND pi_new_proxy_users(1) is not null 
      THEN 
        FOR i IN 1..pi_new_proxy_users.COUNT LOOP
           --
           IF (    UPPER(pi_new_proxy_users(i)) NOT IN ('SYS', 'SYSTEM', get_application_owner)
               AND proxy_role_exists(pi_username => pi_new_proxy_users(i))) 
             THEN
               lv_proc_input := 'ALTER USER '||pi_username||' GRANT CONNECT THROUGH '||pi_new_proxy_users(i);
               hig.execute_ddl(lv_proc_input);
           ELSE
               RAISE e_invalid_proxy_user;
           END IF;    
           --
        END LOOP;
        --
    END IF;    
    --
    EXCEPTION
    WHEN e_invalid_proxy_user
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 560
                     ,pi_Supplementary_Info => 'The Proxy Username specified is incorrect.');
  --                       
  END update_sso_user; 
  
  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE update_user(pi_old_user_id                IN      hig_users.hus_user_id%TYPE
                       ,pi_old_name                   IN      hig_users.hus_name%TYPE
                       ,pi_old_initials               IN      hig_users.hus_initials%TYPE
                       ,pi_old_job_title              IN      hig_users.hus_job_title%TYPE
                       ,pi_old_start_date             IN      hig_users.hus_start_date%TYPE
                       ,pi_old_end_date               IN      hig_users.hus_end_date%TYPE
                       ,pi_old_unrestricted           IN      hig_users.hus_unrestricted%TYPE
                       ,pi_old_username               IN      hig_users.hus_username%TYPE
                       ,pi_old_password               IN      varchar2 
                       ,pi_old_dflt_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                       ,pi_old_temp_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                       ,pi_old_profile                IN      dba_profiles.profile%TYPE
                       ,pi_old_agent_code             IN      hig_users.hus_agent_code%TYPE
                       ,pi_old_admin_unit             IN      hig_users.hus_admin_unit%TYPE
                       ,pi_old_address1               IN      hig_user_contacts_all.huc_address1%TYPE
                       ,pi_old_address2               IN      hig_user_contacts_all.huc_address2%TYPE
                       ,pi_old_address3               IN      hig_user_contacts_all.huc_address3%TYPE
                       ,pi_old_address4               IN      hig_user_contacts_all.huc_address4%TYPE
                       ,pi_old_address5               IN      hig_user_contacts_all.huc_address5%TYPE
                       ,pi_old_postcode               IN      hig_user_contacts_all.huc_postcode%TYPE
                       ,pi_old_tel_type_1             IN      hig_user_contacts_all.huc_tel_type_1%TYPE
                       ,pi_old_tel_no_1               IN      hig_user_contacts_all.huc_telephone_1%TYPE
                       ,pi_old_primary_tel_1          IN      hig_user_contacts_all.huc_primary_tel_1%TYPE
                       ,pi_old_tel_type_2             IN      hig_user_contacts_all.huc_tel_type_2%TYPE
                       ,pi_old_tel_no_2               IN      hig_user_contacts_all.huc_telephone_2%TYPE
                       ,pi_old_primary_tel_2          IN      hig_user_contacts_all.huc_primary_tel_2%TYPE
                       ,pi_old_tel_type_3             IN      hig_user_contacts_all.huc_tel_type_3%TYPE
                       ,pi_old_tel_no_3               IN      hig_user_contacts_all.huc_telephone_3%TYPE
                       ,pi_old_primary_tel_3          IN      hig_user_contacts_all.huc_primary_tel_3%TYPE
                       ,pi_old_tel_type_4             IN      hig_user_contacts_all.huc_tel_type_4%TYPE
                       ,pi_old_tel_no_4               IN      hig_user_contacts_all.huc_telephone_4%TYPE
                       ,pi_old_primary_tel_4          IN      hig_user_contacts_all.huc_primary_tel_4%TYPE
                       ,pi_old_email                  IN      nm_mail_users.nmu_email_address%TYPE
                       ,pi_old_sso_user               IN      varchar2
                       ,pi_old_override_password      IN      varchar2
                       ,pi_old_proxy_users            IN      nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                       ,pi_new_user_id                IN      hig_users.hus_user_id%TYPE
                       ,pi_new_name                   IN      hig_users.hus_name%TYPE
                       ,pi_new_initials               IN      hig_users.hus_initials%TYPE
                       ,pi_new_job_title              IN      hig_users.hus_job_title%TYPE
                       ,pi_new_start_date             IN      hig_users.hus_start_date%TYPE
                       ,pi_new_end_date               IN      hig_users.hus_end_date%TYPE
                       ,pi_new_unrestricted           IN      hig_users.hus_unrestricted%TYPE
                       ,pi_new_username               IN      hig_users.hus_username%TYPE
                       ,pi_new_password               IN      varchar2 
                       ,pi_new_dflt_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                       ,pi_new_temp_tablespace        IN      dba_tablespaces.tablespace_name%TYPE
                       ,pi_new_profile                IN      dba_profiles.profile%TYPE
                       ,pi_new_agent_code             IN      hig_users.hus_agent_code%TYPE
                       ,pi_new_admin_unit             IN      hig_users.hus_admin_unit%TYPE
                       ,pi_new_address1               IN      hig_user_contacts_all.huc_address1%TYPE
                       ,pi_new_address2               IN      hig_user_contacts_all.huc_address2%TYPE
                       ,pi_new_address3               IN      hig_user_contacts_all.huc_address3%TYPE
                       ,pi_new_address4               IN      hig_user_contacts_all.huc_address4%TYPE
                       ,pi_new_address5               IN      hig_user_contacts_all.huc_address5%TYPE
                       ,pi_new_postcode               IN      hig_user_contacts_all.huc_postcode%TYPE
                       ,pi_new_tel_type_1             IN      hig_user_contacts_all.huc_tel_type_1%TYPE
                       ,pi_new_tel_no_1               IN      hig_user_contacts_all.huc_telephone_1%TYPE
                       ,pi_new_primary_tel_1          IN      hig_user_contacts_all.huc_primary_tel_1%TYPE
                       ,pi_new_tel_type_2             IN      hig_user_contacts_all.huc_tel_type_2%TYPE
                       ,pi_new_tel_no_2               IN      hig_user_contacts_all.huc_telephone_2%TYPE
                       ,pi_new_primary_tel_2          IN      hig_user_contacts_all.huc_primary_tel_2%TYPE
                       ,pi_new_tel_type_3             IN      hig_user_contacts_all.huc_tel_type_3%TYPE
                       ,pi_new_tel_no_3               IN      hig_user_contacts_all.huc_telephone_3%TYPE
                       ,pi_new_primary_tel_3          IN      hig_user_contacts_all.huc_primary_tel_3%TYPE
                       ,pi_new_tel_type_4             IN      hig_user_contacts_all.huc_tel_type_4%TYPE
                       ,pi_new_tel_no_4               IN      hig_user_contacts_all.huc_telephone_4%TYPE
                       ,pi_new_primary_tel_4          IN      hig_user_contacts_all.huc_primary_tel_4%TYPE
                       ,pi_new_email                  IN      nm_mail_users.nmu_email_address%TYPE
                       ,pi_new_sso_user               IN      varchar2
                       ,pi_new_override_password      IN      varchar2
                       ,pi_new_proxy_users            IN      nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                       ,po_message_severity              OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor                OUT  sys_refcursor)
  IS
  --
  lv_user_latest_rec_flag      boolean := TRUE;
  lv_user_upd_rec_flag         boolean := TRUE;
  lv_contacts_latest_rec_flag  boolean := TRUE;
  lv_contacts_upd_rec_flag     boolean := TRUE;
  lv_email_latest_rec_flag     boolean := TRUE;
  lv_email_upd_rec_flag        boolean := TRUE;
  --
  BEGIN
    --
    SAVEPOINT update_user_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    --Firstly we need to check the caller has the correct roles to continue--
    IF user_privs_check = 'N'
      THEN
         hig.raise_ner(pi_appl => 'NET'
                      ,pi_id   => 236);
    END IF;
    --  
    validate_user_for_update(pi_old_user_id           =>  pi_old_user_id
                            ,pi_old_name              =>  pi_old_name
                            ,pi_old_initials          =>  pi_old_initials
                            ,pi_old_job_title         =>  pi_old_job_title
                            ,pi_old_start_date        =>  pi_old_start_date
                            ,pi_old_end_date          =>  pi_old_end_date
                            ,pi_old_unrestricted      =>  pi_old_unrestricted
                            ,pi_old_username          =>  pi_old_username
                            ,pi_old_password          =>  pi_old_password
                            ,pi_old_dflt_tablespace   =>  pi_old_dflt_tablespace
                            ,pi_old_temp_tablespace   =>  pi_old_temp_tablespace
                            ,pi_old_profile           =>  pi_old_profile
                            ,pi_old_agent_code        =>  pi_old_agent_code
                            ,pi_old_admin_unit        =>  pi_old_admin_unit 
                            ,pi_new_user_id           =>  pi_new_user_id
                            ,pi_new_name              =>  pi_new_name
                            ,pi_new_initials          =>  pi_new_initials
                            ,pi_new_job_title         =>  pi_new_job_title
                            ,pi_new_start_date        =>  pi_new_start_date
                            ,pi_new_end_date          =>  pi_new_end_date
                            ,pi_new_unrestricted      =>  pi_new_unrestricted
                            ,pi_new_username          =>  pi_new_username
                            ,pi_new_password          =>  pi_new_password
                            ,pi_new_dflt_tablespace   =>  pi_new_dflt_tablespace
                            ,pi_new_temp_tablespace   =>  pi_new_temp_tablespace
                            ,pi_new_profile           =>  pi_new_profile
                            ,pi_new_agent_code        =>  pi_new_agent_code
                            ,pi_new_admin_unit        =>  pi_new_admin_unit
                            ,pi_new_sso_user          =>  pi_new_sso_user
                            ,pi_new_override_password =>  pi_new_override_password
                            ,po_user_latest_rec_flag  =>  lv_user_latest_rec_flag
                            ,po_user_upd_rec_flag     =>  lv_user_upd_rec_flag);
    --
    --End Date cannot be earlier than the Start Date--
    IF NVL(pi_new_end_date, pi_new_start_date) < pi_new_start_date
      THEN
         hig.raise_ner(pi_Appl  => 'HIG'
		              ,pi_Id    => 5);
    END IF;
    --
    -- check if contact dets exist as they are not mandatory
    IF user_contact_dets_exists(pi_user_id =>  pi_old_user_id) = 'Y'
     THEN   
        validate_user_contact_dets(pi_old_user_id                =>  pi_old_user_id
                                  ,pi_old_address1               =>  pi_old_address1
                                  ,pi_old_address2               =>  pi_old_address2
                                  ,pi_old_address3               =>  pi_old_address3
                                  ,pi_old_address4               =>  pi_old_address4
                                  ,pi_old_address5               =>  pi_old_address5
                                  ,pi_old_postcode               =>  pi_old_postcode
                                  ,pi_old_tel_type_1             =>  pi_old_tel_type_1
                                  ,pi_old_tel_no_1               =>  pi_old_tel_no_1
                                  ,pi_old_primary_tel_1          =>  pi_old_primary_tel_1
                                  ,pi_old_tel_type_2             =>  pi_old_tel_type_2
                                  ,pi_old_tel_no_2               =>  pi_old_tel_no_2
                                  ,pi_old_primary_tel_2          =>  pi_old_primary_tel_2
                                  ,pi_old_tel_type_3             =>  pi_old_tel_type_3
                                  ,pi_old_tel_no_3               =>  pi_old_tel_no_3
                                  ,pi_old_primary_tel_3          =>  pi_old_primary_tel_3
                                  ,pi_old_tel_type_4             =>  pi_old_tel_type_4
                                  ,pi_old_tel_no_4               =>  pi_old_tel_no_4
                                  ,pi_old_primary_tel_4          =>  pi_old_primary_tel_4
                                  ,pi_new_user_id                =>  pi_new_user_id
                                  ,pi_new_address1               =>  pi_new_address1
                                  ,pi_new_address2               =>  pi_new_address2
                                  ,pi_new_address3               =>  pi_new_address3
                                  ,pi_new_address4               =>  pi_new_address4
                                  ,pi_new_address5               =>  pi_new_address5
                                  ,pi_new_postcode               =>  pi_new_postcode
                                  ,pi_new_tel_type_1             =>  pi_new_tel_type_1
                                  ,pi_new_tel_no_1               =>  pi_new_tel_no_1
                                  ,pi_new_primary_tel_1          =>  pi_new_primary_tel_1
                                  ,pi_new_tel_type_2             =>  pi_new_tel_type_2
                                  ,pi_new_tel_no_2               =>  pi_new_tel_no_2
                                  ,pi_new_primary_tel_2          =>  pi_new_primary_tel_2
                                  ,pi_new_tel_type_3             =>  pi_new_tel_type_3
                                  ,pi_new_tel_no_3               =>  pi_new_tel_no_3
                                  ,pi_new_primary_tel_3          =>  pi_new_primary_tel_3
                                  ,pi_new_tel_type_4             =>  pi_new_tel_type_4
                                  ,pi_new_tel_no_4               =>  pi_new_tel_no_4
                                  ,pi_new_primary_tel_4          =>  pi_new_primary_tel_4
                                  ,po_contacts_latest_rec_flag   =>  lv_contacts_latest_rec_flag
                                  ,po_contacts_upd_rec_flag      =>  lv_contacts_upd_rec_flag);
    END IF;                              
    --
    -- check if email address exists as its not mandatory for non-sso users
    IF user_email_exists(pi_user_id =>  pi_old_user_id) = 'Y'
      THEN
        validate_user_email_details(pi_old_user_id             =>  pi_old_user_id
                                   ,pi_old_name                =>  pi_old_name
                                   ,pi_old_email               =>  pi_old_email
                                   ,pi_new_user_id             =>  pi_new_user_id
                                   ,pi_new_name                =>  pi_new_name
                                   ,pi_new_email               =>  pi_new_email
                                   ,po_email_latest_rec_flag   =>  lv_email_latest_rec_flag
                                   ,po_email_upd_rec_flag      =>  lv_email_upd_rec_flag);
    END IF;                               
    --      
    --if any of the recs old parameters do not match the db record, then need to requery--    
    IF (  NOT lv_user_latest_rec_flag
       OR NOT lv_contacts_latest_rec_flag
       OR NOT lv_email_latest_rec_flag)
     THEN     
        --Updated by another user
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 24);
    END IF;
    --
    IF (    lv_user_latest_rec_flag
        AND lv_user_upd_rec_flag) 
     THEN
        UPDATE hig_users
           SET hus_initials		=	pi_new_initials,
               hus_name			=	pi_new_name,
               hus_username 	=	pi_new_username,
               hus_unrestricted	=	pi_new_unrestricted,
               hus_start_date 	= 	pi_new_start_date,  
               hus_job_title	=	pi_new_job_title,
               hus_agent_code	=	pi_new_agent_code,  
               hus_end_date 	=	pi_new_end_date,  
               hus_admin_unit 	=	pi_new_admin_unit
         WHERE hus_user_id 	    =	pi_old_user_id;
         --
        process_account_status(pi_username     => pi_new_username
                              ,pi_old_end_date => pi_old_end_date
                              ,pi_new_end_date => pi_new_end_date);
        --                              
        process_tablespace(pi_username            => pi_new_username
                          ,pi_old_dflt_tablespace => pi_old_dflt_tablespace
                          ,pi_new_dflt_tablespace => pi_new_dflt_tablespace);
        --
        process_password(pi_username      => pi_new_username
						,pi_old_password  => pi_old_password
						,pi_new_password  => pi_new_password);
        --
        process_profile(pi_username    => pi_new_username
				       ,pi_old_profile => pi_old_profile
					   ,pi_new_profile => pi_new_profile);	   
        --
    END IF;                     
    --
    IF (    lv_contacts_latest_rec_flag
        AND lv_contacts_upd_rec_flag) 
         THEN
         MERGE INTO hig_user_contacts_all
            USING (SELECT 1 FROM dual)
            ON    (huc_hus_user_id 	 =	pi_old_user_id)
            WHEN MATCHED THEN UPDATE 
                 SET huc_address1      =   pi_new_address1
                    ,huc_address2      =   pi_new_address2  
                    ,huc_address3      =   pi_new_address3
                    ,huc_address4      =   pi_new_address4
                    ,huc_address5      =   pi_new_address5
                    ,huc_postcode      =   pi_new_postcode
                    ,huc_tel_type_1    =   pi_new_tel_type_1
                    ,huc_telephone_1   =   pi_new_tel_no_1
                    ,huc_primary_tel_1 =   pi_new_primary_tel_1
                    ,huc_tel_type_2    =   pi_new_tel_type_2
                    ,huc_telephone_2   =   pi_new_tel_no_2
                    ,huc_primary_tel_2 =   pi_new_primary_tel_2
                    ,huc_tel_type_3    =   pi_new_tel_type_3
                    ,huc_telephone_3   =   pi_new_tel_no_3
                    ,huc_primary_tel_3 =   pi_new_primary_tel_3
                    ,huc_tel_type_4    =   pi_new_tel_type_4
                    ,huc_telephone_4   =   pi_new_tel_no_4
                    ,huc_primary_tel_4 =   pi_new_primary_tel_4   
            WHERE    huc_hus_user_id   =   pi_old_user_id             
            WHEN NOT MATCHED THEN INSERT
                    (huc_id
                    ,huc_hus_user_id
                    ,huc_address1
                    ,huc_address2
                    ,huc_address3
                    ,huc_address4
                    ,huc_address5
                    ,huc_postcode
                    ,huc_tel_type_1
                    ,huc_telephone_1
                    ,huc_primary_tel_1 
                    ,huc_tel_type_2 
                    ,huc_telephone_2
                    ,huc_primary_tel_2 
                    ,huc_tel_type_3
                    ,huc_telephone_3
                    ,huc_primary_tel_3 
                    ,huc_tel_type_4 
                    ,huc_telephone_4
                    ,huc_primary_tel_4)
             VALUES (hig_hus_id_seq.NEXTVAL
                    ,pi_new_user_id
                    ,pi_new_address1 
                    ,pi_new_address2 
                    ,pi_new_address3 
                    ,pi_new_address4 
                    ,pi_new_address5 
                    ,pi_new_postcode
                    ,pi_new_tel_type_1
                    ,pi_new_tel_no_1
                    ,pi_new_primary_tel_1
                    ,pi_new_tel_type_2 
                    ,pi_new_tel_no_2
                    ,pi_new_primary_tel_2
                    ,pi_new_tel_type_3
                    ,pi_new_tel_no_3
                    ,pi_new_primary_tel_3  
                    ,pi_new_tel_type_4
                    ,pi_new_tel_no_4
                    ,pi_new_primary_tel_4);
    END IF;
    --    
    IF (    lv_email_latest_rec_flag
        AND lv_email_upd_rec_flag
        AND pi_new_email IS NOT NULL  -- caters for updates where an email didn't previously exist. --
       ) 
     THEN
        MERGE INTO nm_mail_users
            USING (SELECT 1 FROM dual)
            ON    (nmu_hus_user_id   =	 pi_old_user_id)
            WHEN MATCHED THEN UPDATE 
                 SET nmu_name          =  pi_new_name
                    ,nmu_email_address =  pi_new_email
               WHERE nmu_hus_user_id   =  pi_old_user_id
            WHEN NOT MATCHED THEN INSERT
                    (nmu_id
                    ,nmu_hus_user_id
                    ,nmu_name
                    ,nmu_email_address)
             VALUES (Nm3seq.Next_Nmu_Id_Seq
                    ,pi_new_user_id
                    ,pi_new_name 
                    ,pi_new_email);     
    END IF; 
    --
    --sso user 
    IF  (    pi_old_sso_user = 'Y' 
         AND pi_old_sso_user = pi_new_sso_user
        )      
      THEN 
        update_sso_user(pi_username               => pi_old_username
                       ,pi_old_email              => pi_old_email
                       ,pi_new_email              => pi_new_email
                       ,pi_old_proxy_users        => pi_old_proxy_users
                       ,pi_new_proxy_users        => pi_new_proxy_users
                       ,pi_old_override_password  => pi_old_override_password
                       ,pi_new_override_password  => pi_new_override_password);
    ELSIF
           (    pi_old_sso_user = 'N'
           AND  pi_new_sso_user = 'Y')
          THEN -- need to update this non-sso user to be a sso-user
            create_sso_user(pi_username           => pi_new_username
                           ,pi_email              => pi_new_email
                           ,pi_proxy_users        => pi_new_proxy_users
                           ,pi_override_password  => pi_new_override_password);        
    ELSIF  (    pi_old_sso_user = 'Y'
           AND  pi_new_sso_user = 'N')
          THEN -- need to update this sso user to be a non-sso user
            hig_relationship_api.delete_relationship(pi_old_email);                                                                                                   
    END IF;                                             
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO update_user_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);       
  END update_user;
   
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION can_delete_user(pi_username  IN  Hig_users.hus_username%TYPE) RETURN BOOLEAN
  IS
  --
  BEGIN
	--
	RETURN (pi_username <> Sys_Context('NM3CORE','APPLICATION_OWNER'));
	--    
  END can_delete_user;          
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE active_jobs_exist(pi_username          IN      hig_users.hus_username%TYPE
                             ,po_active_jobs_exist    OUT  varchar2
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    IF user_exists(pi_username => pi_username) = 'Y'
      THEN
        IF nm3utils.user_has_active_jobs(p_user  => pi_username) > 0 
          THEN
             po_active_jobs_exist := 'Y';
        ELSE
             po_active_jobs_exist := 'N';
        END IF;
    ELSE
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 30
                   ,pi_supplementary_info => 'Username '||pi_username||' does not exist');
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
  
                                  
  END active_jobs_exist; 
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION users_start_date(pi_user_id IN  Hig_users.hus_user_id%TYPE) RETURN DATE
  IS
  --
  lv_start_date hig_users.hus_start_date%TYPE;
  --
  BEGIN
	--
	SELECT TRUNC(hus_start_date)
	INTO   lv_start_date
	FROM   hig_users
	WHERE  hus_user_id = pi_user_id;
	
	RETURN lv_start_date;
  	--    
  END users_start_date;          
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_user(pi_user_id          IN      hig_users.hus_user_id%TYPE
                       ,pi_username         IN      hig_users.hus_username%TYPE
                       ,pi_email            IN      nm_mail_users.nmu_email_address%TYPE
                       ,pi_disable_jobs     IN      varchar2
                       ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                       ,po_message_cursor      OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_user_sp;
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
    awlrs_util.validate_yn(pi_parameter_desc  => 'Disable User Jobs?'
                          ,pi_parameter_value =>  pi_disable_jobs);
    --
    IF user_exists(pi_user_id  => pi_user_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'User: '||pi_username||' does not exist.');
    END IF;
    --
    IF can_delete_user(pi_username => pi_username)
     THEN
     --
       IF pi_disable_jobs = 'Y'
        THEN      
        --
          nm3utils.disable_all_user_schd_jobs(p_user => pi_username);
        --  
       END IF;
     --
       --Before end dating the user, we need to check that todays date is >= User's start date
       IF users_start_date(pi_user_id => pi_user_id) > TRUNC(SYSDATE)   
         THEN
         --
           hig.raise_ner(pi_appl  => 'HIG'
		                ,pi_id    =>  5);
         --
       END IF;
     --
    --
       UPDATE HIG_USERS
          SET hus_end_date = TRUNC(SYSDATE)
        WHERE hus_user_id  = pi_user_id;
     -- 
    ELSE        
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  49);
    END IF;
    --
    -- 
    IF NVL(hig.get_sysopt('DEFSSO'),'N') = 'Y' 
      THEN 
         awlrs_util.validate_notnull(pi_parameter_desc  => 'Email'
                                    ,pi_parameter_value => pi_email);
         --
         hig_relationship_api.delete_relationship(pi_email);
         --                                                     
    END IF; 
    --   
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_user_sp; 
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_user;                        
  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reactivate_user(pi_user_id          IN      hig_users.hus_user_id%TYPE
                           ,pi_username         IN      hig_users.hus_username%TYPE
                           ,pi_status           IN      dba_users.Account_Status%TYPE
                           ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor      OUT  sys_refcursor)
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value =>  pi_user_id);
    --
    IF user_exists(pi_user_id  => pi_user_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'User: '||pi_username||' does not exist.');
    END IF;
    --
    IF pi_status = 'LOCKED' 
     THEN
	   nm3user.unlock_account(pi_username);
	END IF;   
    --
    UPDATE hig_users
       SET hus_end_date = Null
     WHERE hus_user_id  = pi_user_id;
    -- 
    --TODO update SSO ??
    --no coding in form for this but needs checking out 
    --  
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reactivate_user;                                                                                                                
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_roles(pi_username          IN      hig_users.hus_username%TYPE
                          ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor       OUT  sys_refcursor
                          ,po_cursor               OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT grantee        username                   
          ,granted_role   role_name
          ,admin_option   admin_option
          ,default_role   default_role
      FROM dba_role_privs               
     WHERE grantee = pi_username
       AND granted_role <> cv_proxy_owner
     ORDER BY granted_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_roles;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_role(pi_username             IN     hig_users.hus_username%TYPE
                         ,pi_role                 IN     dba_role_privs.granted_role%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT grantee        username                   
          ,granted_role   role_name
          ,admin_option   admin_option
          ,default_role   default_role
      FROM dba_role_privs               
     WHERE grantee      = pi_username
       AND granted_role = pi_role
       AND granted_role <> cv_proxy_owner;
     --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_role;                       

  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_roles(pi_username             IN     hig_users.hus_username%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT grantee        username                   
                                                    ,granted_role   role_name
                                                    ,admin_option   admin_option
                                                    ,default_role   default_role
                                                FROM dba_role_privs               
                                               WHERE grantee = :pi_username ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  username'
                                                  ||',role_name'
                                                  ||',admin_option'
                                                  ||',default_role'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'role_name'
                                ,pi_query_col    => 'granted_role'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'admin_option'
                                ,pi_query_col    => 'admin_option'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'default_role'
                                ,pi_query_col    => 'default_role'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'granted_role')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_username
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_username
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
  END get_paged_user_roles;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_roles_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT  sys_refcursor
                              ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hro_role   role
          ,SUBSTR(hro_descr,1,30)  role_descr 
      FROM hig_roles 
     WHERE hro_role <> cv_proxy_owner 
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
  END get_user_roles_lov;                               

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_role_lov(pi_role             IN      hig_roles.hro_role%TYPE
                             ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor      OUT  sys_refcursor
                             ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hro_role   role
          ,SUBSTR(hro_descr,1,30)  role_descr 
      FROM hig_roles 
     WHERE hro_role = pi_role
       AND hro_role <> cv_proxy_owner;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_role_lov;     
 
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_role_exists(pi_username          IN     hig_users.hus_username%TYPE
                           ,pi_role              IN     dba_role_privs.granted_role%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_user_roles
     WHERE hur_username = UPPER(pi_username)
       AND hur_role     = UPPER(pi_role);
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_role_exists;
  
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION proxy_owner_role(pi_role  IN  dba_role_privs.granted_role%TYPE)
    RETURN BOOLEAN
  IS
  BEGIN
    --
    RETURN (pi_role = cv_proxy_owner);
    -- 
  END proxy_owner_role;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_user_role(pi_username          IN     hig_users.hus_username%TYPE
                            ,pi_role              IN     dba_role_privs.granted_role%TYPE
                            ,pi_admin_option      IN     dba_role_privs.admin_option%TYPE DEFAULT Null
                            ,po_message_severity     OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor       OUT sys_refcursor)
  IS
  --
  lv_proc_input varchar2(200) := '';
  --
  BEGIN
    --
    SAVEPOINT create_user_role_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Username'
                               ,pi_parameter_value => pi_username);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_role);
    --
    IF pi_admin_option NOT IN ('YES','NO')
     THEN
       hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Admin Option must be set to either YES or NO');
    END IF; 
    --
    IF user_role_exists(pi_username => pi_username
                       ,pi_role     => pi_role) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Role '||pi_role||' already assigned for this User');
    END IF;
    --
    --Proxy Owner role is not to be assigned to any user via these apis??--
    IF proxy_owner_role(pi_role => pi_role) 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Role '||pi_role||' cannot be assigned to this User');
    END IF;
    --
    /*
    ||insert into hig_user_roles.
    */
    INSERT
      INTO hig_user_roles
          (hur_username
          ,hur_role
          ,hur_start_date
           )
    VALUES (pi_username
           ,pi_role
           ,TRUNC(sysdate)
           );
    --  
    grant_role_privs(pi_username     =>  pi_username
    	            ,pi_role         =>  pi_role
    	            ,pi_admin_option =>  pi_admin_option);
    --    
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_user_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_user_role; 
  
  --
  -----------------------------------------------------------------------------
  --       
  PROCEDURE get_user_default_role(pi_username		IN	   dba_role_privs.grantee%TYPE
						         ,pi_role_name	    IN	   dba_role_privs.granted_role%TYPE
								 ,po_default_role	   OUT dba_role_privs.default_role%TYPE
                                 ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor    OUT sys_refcursor)
  IS
    --
  BEGIN
    --
     BEGIN  
	   SELECT default_role
		 INTO po_default_role
	 	 FROM dba_role_privs
		WHERE grantee 	   =  pi_username
	      AND granted_role =  pi_role_name;  
  
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
	    	 po_default_role := null;
	END;
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END Get_User_Default_Role;                                      
  --
  -----------------------------------------------------------------------------
  --                             
  PROCEDURE delete_user_role(pi_username          IN     hig_users.hus_username%TYPE
                            ,pi_role              IN     dba_role_privs.granted_role%TYPE
                            ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  lv_proc_input varchar2(200) := '';
  --
  CURSOR c1 IS
    SELECT d.privilege 
      FROM dba_sys_privs d, dba_sys_privs u
     WHERE d.grantee   = pi_role
       AND u.grantee   = pi_username
       AND d.privilege = u.privilege
       AND d.privilege NOT IN ( 
                               SELECT s.privilege 
                                 FROM dba_sys_privs s, dba_role_privs r
                                WHERE r.granted_role  = s.grantee
                                  AND r.grantee       = pi_username
                                  AND r.granted_role != d.grantee );
  --
  CURSOR c2 IS
    SELECT p.privilege, p.table_name, p.owner  
      FROM dba_tab_privs p, dba_tab_privs u
     WHERE p.grantee    = pi_role 
       AND u.grantee    = pi_username
       AND p.privilege  = u.privilege
       AND p.table_name = u.table_name
       AND p.owner      = u.owner
       AND p.owner      = (SELECT SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME') FROM user_objects o
                            WHERE o.object_name = 'HIG_OPTIONS'
                              AND o.object_type = 'VIEW'
                           UNION
                           SELECT o.table_owner FROM user_synonyms o
                            WHERE o.synonym_name = 'HIG_OPTIONS' )
       AND (p.privilege, p.table_name, p.owner) NOT IN 
                          (SELECT t.privilege, t.table_name, t.owner
                             FROM dba_tab_privs t, dba_role_privs r
                            WHERE r.granted_role = t.grantee
                              AND t.grantee = r.granted_role
                              AND r.granted_role != p.grantee );  
    
  BEGIN
    --
    SAVEPOINT delete_user_role_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Username'
                               ,pi_parameter_value => pi_username);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_role);
    --
    IF user_role_exists(pi_username => pi_username
                       ,pi_role     => pi_role) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Role '||pi_role||' does not exist for this User');
    END IF;
    --
    -- Revoking role system privileges -- 
    FOR c1_rec in c1
    LOOP
     lv_proc_input := ''; 
     lv_proc_input := ('REVOKE '||c1_rec.privilege||' FROM '||pi_username);
     hig.execute_ddl(lv_proc_input);
    END LOOP; 
    --  
    -- Revoking role object privileges -- 
    FOR c2_rec IN c2
    LOOP
     lv_proc_input := ''; 
     lv_proc_input := ( 'REVOKE ' || c2_rec.privilege
                      ||' ON '    || c2_rec.owner || '.' || c2_rec.table_name
                      ||' FROM '  || pi_username);
     hig.execute_ddl(lv_proc_input);
    END LOOP; 
    --
    /*
    ||delete from hig_user_roles.
    */
    DELETE
      FROM hig_user_roles
     WHERE hur_username = pi_username
       AND hur_role     = pi_role;
    --  
    -- Revoking Role from User -- 
    lv_proc_input := 'REVOKE '||pi_role||' FROM '||pi_username;
    hig.execute_ddl(lv_proc_input);
    --                
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_user_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_user_role;                            
                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_admin_units(pi_user_id           IN     hig_users.hus_user_id%TYPE
                                ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor      OUT  sys_refcursor
                                ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nua.nua_user_id     user_id
          ,nua.nua_admin_unit  admin_unit
          ,nau.nau_unit_code   admin_unit_code
          ,nau.nau_name        description
          ,nau.nau_admin_type  admin_type
          ,nua.nua_mode        mode_
          ,nua.nua_start_date  start_date
          ,nua.nua_end_date    end_date
      FROM nm_user_aus_all nua
          ,nm_admin_units nau               
     WHERE nua_user_id        = pi_user_id
       AND nau.nau_admin_unit = nua.nua_admin_unit
     ORDER BY nau.nau_unit_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_admin_units;                                

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_admin_unit(pi_user_id            IN     hig_users.hus_user_id%TYPE
                               ,pi_admin_unit         IN     nm_user_aus.nua_admin_unit%TYPE
                               ,po_message_severity      OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor        OUT sys_refcursor
                               ,po_cursor                OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nua.nua_user_id     user_id
          ,nua.nua_admin_unit  admin_unit
          ,nau.nau_unit_code   admin_unit_code
          ,nau.nau_name        description
          ,nau.nau_admin_type  admin_type
          ,nua.nua_mode        mode_
          ,nua.nua_start_date  start_date
          ,nua.nua_end_date    end_date
      FROM nm_user_aus_all nua
          ,nm_admin_units nau               
     WHERE nua_user_id        = pi_user_id 
       AND nau.nau_admin_unit = nua.nua_admin_unit
       AND nau.nau_admin_unit = pi_admin_unit;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_admin_unit;                             
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_admin_units(pi_user_id              IN     hig_users.hus_user_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nua.nua_user_id     user_id
                                                    ,nua.nua_admin_unit  admin_unit
                                                    ,nau.nau_unit_code   admin_unit_code
                                                    ,nau.nau_name        description
                                                    ,nau.nau_admin_type  admin_type
                                                    ,nua.nua_mode        mode_
                                                    ,nua.nua_start_date  start_date
                                                    ,nua.nua_end_date    end_date
                                                FROM nm_user_aus_all nua
                                                    ,nm_admin_units nau               
                                               WHERE nua_user_id        = :pi_user_id
                                                 AND nau.nau_admin_unit = nua.nua_admin_unit ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  user_id'
                                                  ||',admin_unit'
                                                  ||',admin_unit_code'
                                                  ||',description'
                                                  ||',admin_type'
                                                  ||',mode_'
                                                  ||',start_date'
                                                  ||',end_date'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'admin_unit_code'
                                ,pi_query_col    => 'nau_unit_code'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'description'
                                ,pi_query_col    => 'nau_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'admin_type'
                                ,pi_query_col    => 'nau_admin_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'mode_'
                                ,pi_query_col    => 'nua_mode'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'nua_start_date'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                                ,pi_query_col    => 'nua_end_date'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MON-YYYY'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'admin_unit_code')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_user_admin_units;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_admin_units_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT  sys_refcursor
                               ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nau_admin_unit   admin_unit,
           nau_unit_code    admin_unit_code,
           nau_name         admin_unit_name,
           nau_admin_type   admin_type
      FROM nm_admin_units
    ORDER BY nau_unit_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_units_lov;                               

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_admin_unit_lov(pi_admin_unit       IN      hig_admin_units.hau_admin_unit%TYPE
                              ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor      OUT  sys_refcursor
                              ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nau_admin_unit   admin_unit,
           nau_unit_code    admin_unit_code,
           nau_name         admin_unit_name,
           nau_admin_type   admin_type
      FROM nm_admin_units
     WHERE nau_admin_unit = pi_admin_unit 
    ORDER BY nau_unit_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_unit_lov;                              
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_admin_unit_exists_dt(pi_user_id     IN  nm_user_aus_all.nua_user_id%TYPE
                                    ,pi_admin_unit  IN  nm_user_aus_all.nua_admin_unit%TYPE
                                    ,pi_start_date  IN  nm_user_aus_all.nua_start_date%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_user_aus
     WHERE nua_user_id     =  pi_user_id
       AND nua_admin_unit  =  pi_admin_unit
       AND nua_start_date <=  pi_start_date
       AND nua_end_date   IS NULL;
    --
    RETURN lv_exists;
    --       
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_admin_unit_exists_dt;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_admin_unit_exists(pi_user_id     IN  nm_user_aus_all.nua_user_id%TYPE
                                 ,pi_admin_unit  IN  nm_user_aus_all.nua_admin_unit%TYPE
                                 ,pi_start_date  IN  nm_user_aus_all.nua_start_date%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_user_aus_all
     WHERE nua_user_id     =  pi_user_id
       AND nua_admin_unit  =  pi_admin_unit
       AND nua_start_date  =  pi_start_date;
       --AND nua_end_date   IS NULL;
    --
    RETURN lv_exists;
    --       
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_admin_unit_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION valid_start_date(pi_user_id     IN  nm_user_aus_all.nua_user_id%TYPE
                           ,pi_start_date  IN  nm_user_aus_all.nua_start_date%TYPE)
    RETURN VARCHAR2
  IS
    lv_valid VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_valid
      FROM hig_users
     WHERE hus_user_id     = pi_user_id
       AND hus_start_date <= pi_start_date;
    --   
    RETURN lv_valid;
    --       
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_valid;
  --
  END valid_start_date;
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_user_admin_unit(pi_user_id          IN     nm_user_aus_all.nua_user_id%TYPE
                                  ,pi_admin_unit       IN     nm_user_aus_all.nua_admin_unit%TYPE
                                  ,pi_mode             IN     nm_user_aus_all.nua_mode%TYPE
                                  ,pi_start_date       IN     nm_user_aus_all.nua_start_date%TYPE
                                  ,pi_end_date         IN     nm_user_aus_all.nua_end_date%TYPE
                                  ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_user_admin_unit_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value => pi_user_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Unit'
                               ,pi_parameter_value => pi_admin_unit);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value => pi_mode);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    --check to ensure the start date is not before the user's start date
    IF valid_start_date(pi_user_id    => pi_user_id
                       ,pi_start_date => pi_start_date) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 84);
    END IF;                 
    --
    IF user_admin_unit_exists_dt(pi_user_id    => pi_user_id
                                ,pi_admin_unit => pi_admin_unit
                                ,pi_start_date => pi_start_date) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Admin Unit already assigned to this User');
    END IF;
    --
    /*
    ||insert into nm_user_aus_all.
    */
    INSERT
      INTO nm_user_aus_all
          (nua_user_id
          ,nua_admin_unit
          ,nua_start_date
          ,nua_mode
          ,nua_end_date
          )
    VALUES (pi_user_id
           ,pi_admin_unit
           ,pi_start_date
           ,pi_mode
           ,pi_end_date
           );     
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_user_admin_unit_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_user_admin_unit;                                   

  --
  -----------------------------------------------------------------------------
  --       
  PROCEDURE update_user_admin_unit(pi_old_user_id      IN     nm_user_aus_all.nua_user_id%TYPE
                                  ,pi_old_admin_unit   IN     nm_user_aus_all.nua_admin_unit%TYPE
                                  ,pi_old_mode         IN     nm_user_aus_all.nua_mode%TYPE
                                  ,pi_old_start_date   IN     nm_user_aus_all.nua_start_date%TYPE
                                  ,pi_old_end_date     IN     nm_user_aus_all.nua_end_date%TYPE
                                  ,pi_new_user_id      IN     nm_user_aus_all.nua_user_id%TYPE
                                  ,pi_new_admin_unit   IN     nm_user_aus_all.nua_admin_unit%TYPE
                                  ,pi_new_mode         IN     nm_user_aus_all.nua_mode%TYPE
                                  ,pi_new_start_date   IN     nm_user_aus_all.nua_start_date%TYPE
                                  ,pi_new_end_date     IN     nm_user_aus_all.nua_end_date%TYPE
                                  ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_user_aus_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_user_aus_all
       WHERE nua_user_id    = pi_old_user_id
         AND nua_admin_unit = pi_old_admin_unit
         AND nua_start_date = pi_old_start_date
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'User Admin Unit does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_user_admin_unit_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value =>  pi_new_user_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Unit'
                               ,pi_parameter_value =>  pi_new_admin_unit);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value =>  pi_new_mode);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value =>  pi_new_start_date);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nua_user_id != pi_old_user_id
     OR (lr_db_rec.nua_user_id IS NULL AND pi_old_user_id IS NOT NULL)
     OR (lr_db_rec.nua_user_id IS NOT NULL AND pi_old_user_id IS NULL)
     --
     OR (lr_db_rec.nua_admin_unit != pi_old_admin_unit)
     OR (lr_db_rec.nua_admin_unit IS NULL AND pi_old_admin_unit IS NOT NULL)
     OR (lr_db_rec.nua_admin_unit IS NOT NULL AND pi_old_admin_unit IS NULL)
     --
     OR (lr_db_rec.nua_mode != pi_old_mode)
     OR (lr_db_rec.nua_mode IS NULL AND pi_old_mode IS NOT NULL)
     OR (lr_db_rec.nua_mode IS NOT NULL AND pi_old_mode IS NULL)
     --
     OR (lr_db_rec.nua_start_date != pi_old_start_date)
     OR (lr_db_rec.nua_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_rec.nua_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --
     OR (lr_db_rec.nua_end_date != pi_old_end_date)
     OR (lr_db_rec.nua_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_rec.nua_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_user_id != pi_new_user_id
       OR (pi_old_user_id IS NULL AND pi_new_user_id IS NOT NULL)
       OR (pi_old_user_id IS NOT NULL AND pi_new_user_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_admin_unit != pi_new_admin_unit
       OR (pi_old_admin_unit IS NULL AND pi_new_admin_unit IS NOT NULL)
       OR (pi_old_admin_unit IS NOT NULL AND pi_new_admin_unit IS NULL)
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
        UPDATE nm_user_aus_all
           SET nua_user_id    =  pi_new_user_id
              ,nua_admin_unit =  pi_new_admin_unit
              ,nua_mode       =  pi_new_mode
              ,nua_start_date =  pi_new_start_date
              ,nua_end_date   =  pi_new_end_date
         WHERE nua_user_id    =  pi_old_user_id
           AND nua_admin_unit =  pi_old_admin_unit
           AND nua_start_date =  pi_old_start_date;
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
        ROLLBACK TO update_user_admin_unit_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_user_admin_unit;
                                                                
  --
  -----------------------------------------------------------------------------
  --                             
  PROCEDURE delete_user_admin_unit(pi_user_id          IN     nm_user_aus_all.nua_user_id%TYPE
                                  ,pi_admin_unit       IN     nm_user_aus_all.nua_admin_unit%TYPE
                                  ,pi_start_date       IN     nm_user_aus_all.nua_start_date%TYPE
                                  ,pi_end_date         IN     nm_user_aus_all.nua_end_date%TYPE
                                  ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_user_admin_unit_sp;
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
    IF user_admin_unit_exists(pi_user_id     =>  pi_user_id
                             ,pi_admin_unit  =>  pi_admin_unit
                             ,pi_start_date  =>  pi_start_date ) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Admin Unit does not exist for this User');
    END IF;
    --    
    UPDATE nm_user_aus_all
       SET nua_end_date   =  NVL(pi_end_date, TRUNC(SYSDATE))
     WHERE nua_user_id    =  pi_user_id
       AND nua_admin_unit =  pi_admin_unit
       AND nua_start_date =  pi_start_date;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_user_admin_unit_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_user_admin_unit;                                  
                                  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_options(pi_user_id           IN     hig_users.hus_user_id%TYPE
                            ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor      OUT  sys_refcursor
                            ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT huo_hus_user_id     user_id
          ,huo_id              option_id
          ,huo_value           option_value         
      FROM hig_user_options                        
     WHERE huo_hus_user_id     = pi_user_id
     ORDER BY huo_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_options;                          

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_option(pi_user_id            IN     hig_users.hus_user_id%TYPE
                           ,pi_option_id          IN     hig_user_options.huo_id%TYPE
                           ,po_message_severity      OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor        OUT sys_refcursor
                           ,po_cursor                OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT huo_hus_user_id     user_id
          ,huo_id              option_id
          ,huo_value           option_value         
      FROM hig_user_options                        
     WHERE huo_hus_user_id  =  pi_user_id
       AND huo_id           =  pi_option_id
     ORDER BY huo_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_option;                         
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_options(pi_user_id              IN     hig_users.hus_user_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT huo_hus_user_id     user_id
                                                    ,huo_id              option_id
                                                    ,huo_value           option_value         
                                                FROM hig_user_options                        
                                               WHERE huo_hus_user_id     = :pi_user_id ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  user_id'
                                                  ||',option_id'
                                                  ||',option_value'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'option_id'
                                ,pi_query_col    => 'huo_id'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'option_value'
                                ,pi_query_col    => 'huo_value'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'option_id')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_user_options;  
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_options_lov(pi_user_id          IN      hig_users.hus_user_id%TYPE
                                ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor      OUT  sys_refcursor
                                ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT huol_id      hco_code
          ,huol_name    hco_meaning
      FROM hig_user_option_list_all
     WHERE NOT EXISTS(SELECT 1
                        FROM hig_user_options
                       WHERE huo_hus_user_id = pi_user_id
                         AND huo_id   = huol_id
                     )
    ORDER BY huol_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_options_lov;                               

  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_user_option_lov(pi_user_id          IN      hig_users.hus_user_id%TYPE
                               ,pi_option_id        IN      hig_user_option_list_all.huol_id%TYPE
                               ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT huol_id      hco_code
          ,huol_name    hco_meaning
      FROM hig_user_option_list_all
     WHERE NOT EXISTS(SELECT 1
                        FROM hig_user_options
                       WHERE huo_hus_user_id = pi_user_id
                         AND huo_id   = huol_id
                     )
       AND  huol_id = pi_option_id             
    ORDER BY huol_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_option_lov;      
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_options_lov(pi_user_id              IN     hig_users.hus_user_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT huol_id      hco_code
                                                    ,huol_name    hco_meaning
                                                FROM hig_user_option_list_all
                                               WHERE NOT EXISTS(SELECT 1
                                                                FROM hig_user_options
                                                                WHERE huo_hus_user_id = :pi_user_id
                                                                AND huo_id   = huol_id) ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  hco_code'
                                                  ||',hco_meaning'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'hco_code'
                                ,pi_query_col    => 'huol_id'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'hco_meaning'
                                ,pi_query_col    => 'huol_name'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'hco_code')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_user_options_lov;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION user_option_exists(pi_user_id    IN  hig_user_options.huo_hus_user_id%TYPE
                             ,pi_option_id  IN  hig_user_options.huo_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_user_options
     WHERE huo_hus_user_id  =  pi_user_id
       AND huo_id           =  pi_option_id;      
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END user_option_exists;
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_user_option(pi_user_id          IN      hig_user_options.huo_hus_user_id%TYPE
                              ,pi_option_id        IN      hig_user_options.huo_id%TYPE
                              ,pi_option_value     IN      hig_user_options.huo_value%TYPE
                              ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor      OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_user_option_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value =>  pi_user_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Option Id'
                               ,pi_parameter_value =>  pi_option_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Option Value'
                               ,pi_parameter_value =>  pi_option_value);
    --
    IF user_option_exists(pi_user_id   => pi_user_id
                         ,pi_option_id => pi_option_id) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'User Option '||pi_option_id||' already exists');
    END IF;
    --
    /*
    ||insert into hig_user_options.
    */
    INSERT
      INTO hig_user_options
          (huo_hus_user_id
          ,huo_id
          ,huo_value
          )
    VALUES (pi_user_id
           ,pi_option_id 
           ,pi_option_value
           );
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_user_option_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_user_option;                            

  --
  -----------------------------------------------------------------------------
  --       
  PROCEDURE update_user_option(pi_old_user_id          IN      hig_user_options.huo_hus_user_id%TYPE
                              ,pi_old_option_id        IN      hig_user_options.huo_id%TYPE
                              ,pi_old_option_value     IN      hig_user_options.huo_value%TYPE
                              ,pi_new_user_id          IN      hig_user_options.huo_hus_user_id%TYPE
                              ,pi_new_option_id        IN      hig_user_options.huo_id%TYPE
                              ,pi_new_option_value     IN      hig_user_options.huo_value%TYPE
                              ,po_message_severity        OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT  sys_refcursor)
  IS
    --
    lr_db_rec        hig_user_options%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM hig_user_options
       WHERE huo_hus_user_id = pi_old_user_id
         AND huo_id          = pi_old_option_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'User Option does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_user_option_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Id'
                               ,pi_parameter_value =>  pi_new_user_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'User Option'
                               ,pi_parameter_value =>  pi_new_option_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Option Value'
                               ,pi_parameter_value =>  pi_new_option_value);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.huo_hus_user_id != pi_old_user_id
     OR (lr_db_rec.huo_hus_user_id IS NULL AND pi_old_user_id IS NOT NULL)
     OR (lr_db_rec.huo_hus_user_id IS NOT NULL AND pi_old_user_id IS NULL)
     --
     OR (lr_db_rec.huo_id != pi_old_option_id)
     OR (lr_db_rec.huo_id IS NULL AND pi_old_option_id IS NOT NULL)
     OR (lr_db_rec.huo_id IS NOT NULL AND pi_old_option_id IS NULL)
     --
     OR (lr_db_rec.huo_value != pi_old_option_value)
     OR (lr_db_rec.huo_value IS NULL AND pi_old_option_value IS NOT NULL)
     OR (lr_db_rec.huo_value IS NOT NULL AND pi_old_option_value IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_user_id != pi_new_user_id
       OR (pi_old_user_id IS NULL AND pi_new_user_id IS NOT NULL)
       OR (pi_old_user_id IS NOT NULL AND pi_new_user_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_option_id != pi_new_option_id
       OR (pi_old_option_id IS NULL AND pi_new_option_id IS NOT NULL)
       OR (pi_old_option_id IS NOT NULL AND pi_new_option_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_option_value != pi_new_option_value
       OR (pi_old_option_value IS NULL AND pi_new_option_value IS NOT NULL)
       OR (pi_old_option_value IS NOT NULL AND pi_new_option_value IS NULL)
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
        UPDATE hig_user_options
           SET huo_hus_user_id =  pi_new_user_id
              ,huo_id          =  pi_new_option_id
              ,huo_value       =  pi_new_option_value
         WHERE huo_hus_user_id =  pi_old_user_id
           AND huo_id          =  pi_old_option_id;
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
        ROLLBACK TO update_user_option_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_user_option;                                                          
  --
  -----------------------------------------------------------------------------
  --
                              
  PROCEDURE delete_user_option(pi_user_id          IN      hig_user_options.huo_hus_user_id%TYPE
                              ,pi_option_id        IN      hig_user_options.huo_id%TYPE
                              ,pi_option_value     IN      hig_user_options.huo_value%TYPE
                              ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor      OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_user_option_sp;
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
    IF user_option_exists(pi_user_id   => pi_user_id
                         ,pi_option_id => pi_option_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'User Option does not exist for this User');
    END IF;
    --    
    DELETE FROM hig_user_options
     WHERE huo_hus_user_id  =  pi_user_id
       AND huo_id           =  pi_option_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_user_option_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_user_option;                                                                                                                                                
                                
  --                                  

END awlrs_user_api;
/
