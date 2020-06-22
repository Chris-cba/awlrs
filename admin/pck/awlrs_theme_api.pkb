CREATE OR REPLACE PACKAGE BODY awlrs_theme_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_theme_api.pkb-arc   1.5   Jun 22 2020 16:35:02   Barbara.Odriscoll  $
  --       Date into PVCS   : $Date:   Jun 22 2020 16:35:02  $
  --       Module Name      : $Workfile:   awlrs_theme_api.pkb  $
  --       Date fetched Out : $Modtime:   Jun 22 2020 16:30:30  $
  --       Version          : $Revision:   1.5  $
  --
  -----------------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated.  All rights reserved.
  -----------------------------------------------------------------------------------
  --
  g_body_sccsid     CONSTANT  VARCHAR2(2000) := '"$Revision:   1.5  $"';
  --
  g_package_name    CONSTANT VARCHAR2 (30) := 'awlrs_theme_api';
  --
  --roles constants
  cv_hig_admin      CONSTANT VARCHAR2(9) := 'HIG_ADMIN';
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
  FUNCTION get_last_analysed_date(pi_table_name IN user_tables.table_name%TYPE) 
    RETURN DATE
  IS
  --
  lv_last_analysed   date;
  --
  BEGIN
    --
    IF pi_table_name IS NOT NULL
      THEN
        SELECT last_analyzed
          INTO lv_last_analysed 
          FROM user_tables
         WHERE table_name = pi_table_name;
         --
         RETURN lv_last_analysed;
    ELSE
        --
        RETURN NULL;
        --     
    END IF;  
    --
  END get_last_analysed_date;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_types_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hco_code
          ,hco_meaning
      FROM hig_codes
     WHERE hco_domain = 'THEME_TYPE'
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
  END get_theme_types_lov; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_products_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor      OUT  sys_refcursor
                            ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hpr_product
          ,hpr_product_name
      FROM hig_products
     WHERE hpr_key IS NOT NULL
    ORDER BY hpr_sequence;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_products_lov; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_storage_types_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT  sys_refcursor
                                 ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 'S'       storage_code 
          ,'Stored'  storage_desc 
      FROM dual
    UNION
    SELECT 'D'
          ,'Derived'  
      FROM dual
    ORDER BY storage_code desc;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_storage_types_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_dependency_types_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor
                                    ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 'I'            dependency_code 
          ,'Independant'  dependency_desc 
      FROM dual
    UNION
    SELECT 'D'
          ,'Dependant'  
      FROM dual
    ORDER BY dependency_code desc;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_dependency_types_lov;                                    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_update_on_edit_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor
                                    ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 'I'          update_on_edit_code 
          ,'Immediate'  update_on_edit_desc 
      FROM dual
    UNION
    SELECT 'D'
          ,'Deffered'  
      FROM dual
    UNION
    SELECT 'N'
          ,'No'  
      FROM dual;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_update_on_edit_lov;                                    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_snap_to_theme_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT  sys_refcursor
                                    ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 'N'       snap_to_theme_code 
          ,'No'      snap_to_theme_desc 
      FROM dual
    UNION
    SELECT 'S'
          ,'Snap'  
      FROM dual;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_snap_to_theme_lov;                                    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_tab_cols_lov(pi_theme_table_name  IN     nm_themes_all.nth_table_name%TYPE
                                  ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT  sys_refcursor
                                  ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT column_name
          ,(data_type ||(to_char(nvl(data_precision, data_length)) || decode(data_scale, '0' , null, null, null, '','' || to_char(data_scale)) || '')) data_type
      FROM all_tab_columns
     WHERE OWNER = UPPER(SYS_CONTEXT('NM3CORE','APPLICATION_OWNER'))
       AND table_name = pi_theme_table_name
    ORDER BY column_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_tab_cols_lov;                                
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_theme_ft_cols_lov(pi_theme_ft_table_name  IN     nm_themes_all.nth_feature_table%TYPE
                                 ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor         OUT  sys_refcursor
                                 ,po_cursor                 OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT column_name
          ,(data_type ||(to_char(nvl(data_precision, data_length)) || decode(data_scale, '0' , null, null, null, '','' || to_char(data_scale)) || '')) data_type
      FROM all_tab_columns
     WHERE OWNER = UPPER(SYS_CONTEXT('NM3CORE','APPLICATION_OWNER'))
       AND table_name = pi_theme_ft_table_name
    ORDER BY column_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_ft_cols_lov;                                
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_themes(po_message_severity    OUT  hig_codes.hco_code%TYPE
                      ,po_message_cursor      OUT  sys_refcursor
                      ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nta1.nth_theme_id                 theme_id
          ,nta1.nth_theme_name               theme_name
          ,nta1.nth_table_name               table_name
          ,nta1.nth_where                    where_clause
          ,nta1.nth_sequence_name            seq_name
          ,nta1.nth_pk_column                pk_col
          ,nta1.nth_label_column             pk_label
          ,nta1.nth_x_column                 easting
          ,nta1.nth_y_column                 northing
          ,nta1.nth_theme_type               theme_type
          ,nta1.nth_hpr_product              product
          ,CASE 
             WHEN nta1.nth_storage = 'S' THEN 'Stored'
             WHEN nta1.nth_storage = 'D' THEN 'Derived'
           END                               storage_type
          ,nta1.nth_base_table_theme         base_table_theme
          ,nta2.nth_theme_name               base_table_theme_name
          ,nta1.nth_feature_table            feature_table
          ,nta1.nth_feature_pk_column        feature_pk
          ,nta1.nth_feature_fk_column        feature_fk
          ,nta1.nth_feature_shape_column     feature_shape
          ,nta1.nth_rse_table_name           rse_table
          ,nta1.nth_rse_fk_column            rse_fk_col
          ,nta1.nth_st_chain_column          start_chainage
          ,nta1.nth_end_chain_column         end_chainage  
          ,nta1.nth_use_history              use_history 
          ,nta1.nth_start_date_column        start_date
          ,nta1.nth_end_date_column          end_date
          ,nta1.nth_tolerance                tolerance
          ,un.un_unit_name                   tol_unit_descr
          ,nta1.nth_dependency               dependency
          ,nta1.nth_update_on_edit           update_on_edit
          ,nta1.nth_snap_to_theme            snap_to_theme
          ,nta1.nth_location_updatable       is_updatable
          ,CASE 
             WHEN nta1.nth_where IS NOT NULL THEN 'Y'
             WHEN nta1.nth_where IS NULL THEN 'N'
           END                               is_custom
      FROM nm_themes_all  nta1
          ,nm_themes_all  nta2
          ,nm_units un  
     WHERE un.un_unit_id             = nta1.nth_tol_units
       AND nta1.nth_base_table_theme = nta2.nth_theme_id(+)  
    ORDER BY nta1.nth_theme_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_themes;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme(pi_theme_id              IN    nm_themes_all.nth_theme_id%TYPE
                     ,po_message_severity        OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor          OUT sys_refcursor
                     ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
  --
    OPEN po_cursor FOR
    SELECT nta1.nth_theme_id                 theme_id
          ,nta1.nth_theme_name               theme_name
          ,nta1.nth_table_name               table_name
          ,nta1.nth_where                    where_clause
          ,nta1.nth_sequence_name            seq_name
          ,nta1.nth_pk_column                pk_col
          ,nta1.nth_label_column             pk_label
          ,nta1.nth_x_column                 easting
          ,nta1.nth_y_column                 northing
          ,nta1.nth_theme_type               theme_type
          ,nta1.nth_hpr_product              product
          ,CASE 
             WHEN nta1.nth_storage = 'S' THEN 'Stored'
             WHEN nta1.nth_storage = 'D' THEN 'Derived'
           END                               storage_type
          ,nta1.nth_base_table_theme         base_table_theme
          ,nta2.nth_theme_name               base_table_theme_name
          ,nta1.nth_feature_table            feature_table
          ,nta1.nth_feature_pk_column        feature_pk
          ,nta1.nth_feature_fk_column        feature_fk
          ,nta1.nth_feature_shape_column     feature_shape
          ,nta1.nth_rse_table_name           rse_table
          ,nta1.nth_rse_fk_column            rse_fk_col
          ,nta1.nth_st_chain_column          start_chainage
          ,nta1.nth_end_chain_column         end_chainage  
          ,nta1.nth_use_history              use_history 
          ,nta1.nth_start_date_column        start_date
          ,nta1.nth_end_date_column          end_date
          ,nta1.nth_tolerance                tolerance
          ,un.un_unit_name                   tol_unit_descr
          ,nta1.nth_dependency               dependency
          ,nta1.nth_update_on_edit           update_on_edit
          ,nta1.nth_snap_to_theme            snap_to_theme
          ,nta1.nth_location_updatable       is_updatable
          ,CASE 
             WHEN nta1.nth_where IS NOT NULL THEN 'Y'
             WHEN nta1.nth_where IS NULL THEN 'N'
           END                               is_custom
      FROM nm_themes_all  nta1
          ,nm_themes_all  nta2
          ,nm_units un 
     WHERE un.un_unit_id             = nta1.nth_tol_units
       AND nta1.nth_base_table_theme = nta2.nth_theme_id(+)
       AND nta1.nth_theme_id         = pi_theme_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_themes(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 := 'SELECT  nta1.nth_theme_id                 theme_id
                                                      ,nta1.nth_theme_name               theme_name
                                                      ,nta1.nth_table_name               table_name
                                                      ,nta1.nth_where                    where_clause
                                                      ,nta1.nth_sequence_name            seq_name
                                                      ,nta1.nth_pk_column                pk_col
                                                      ,nta1.nth_label_column             pk_label
                                                      ,nta1.nth_x_column                 easting
                                                      ,nta1.nth_y_column                 northing
                                                      ,nta1.nth_theme_type               theme_type
                                                      ,nta1.nth_hpr_product              product
                                                      ,CASE 
                                                         WHEN nta1.nth_storage = ''S'' THEN ''Stored''
                                                         WHEN nta1.nth_storage = ''D'' THEN ''Derived''
                                                       END                               storage_type
                                                      ,nta1.nth_base_table_theme         base_table_theme
                                                      ,nta2.nth_theme_name               base_table_theme_name
                                                      ,nta1.nth_feature_table            feature_table
                                                      ,nta1.nth_feature_pk_column        feature_pk
                                                      ,nta1.nth_feature_fk_column        feature_fk
                                                      ,nta1.nth_feature_shape_column     feature_shape
                                                      ,nta1.nth_rse_table_name           rse_table
                                                      ,nta1.nth_rse_fk_column            rse_fk_col
                                                      ,nta1.nth_st_chain_column          start_chainage
                                                      ,nta1.nth_end_chain_column         end_chainage  
                                                      ,nta1.nth_use_history              use_history 
                                                      ,nta1.nth_start_date_column        start_date
                                                      ,nta1.nth_end_date_column          end_date
                                                      ,nta1.nth_tolerance                tolerance
                                                      ,un.un_unit_name                   tol_unit_descr
                                                      ,nta1.nth_dependency               dependency
                                                      ,nta1.nth_update_on_edit           update_on_edit
                                                      ,nta1.nth_snap_to_theme            snap_to_theme
                                                      ,nta1.nth_location_updatable       is_updatable
                                                      ,CASE 
                                                         WHEN nta1.nth_where IS NOT NULL THEN ''Y''
                                                         WHEN nta1.nth_where IS NULL THEN ''N''
                                                       END                               is_custom
                                                  FROM nm_themes_all  nta1
                                                      ,nm_themes_all  nta2
                                                      ,nm_units un 
                                                 WHERE un.un_unit_id             = nta1.nth_tol_units 
                                                   AND nta1.nth_base_table_theme = nta2.nth_theme_id(+) ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT   theme_id'
                                                   ||',theme_name'
                                                   ||',table_name' 
                                                   ||',where_clause'
                                                   ||',seq_name' 
                                                   ||',pk_col'
                                                   ||',pk_label'
                                                   ||',easting'
                                                   ||',northing'
                                                   ||',theme_type'
                                                   ||',product'
                                                   ||',storage_type'       
                                                   ||',base_table_theme'
                                                   ||',base_table_theme_name'
                                                   ||',feature_table'  
                                                   ||',feature_pk'
                                                   ||',feature_fk'
                                                   ||',feature_shape' 
                                                   ||',rse_table'
                                                   ||',rse_fk_col' 
                                                   ||',start_chainage'
                                                   ||',end_chainage'  
                                                   ||',use_history'
                                                   ||',start_date' 
                                                   ||',end_date'
                                                   ||',tolerance'
                                                   ||',tol_unit_descr'
                                                   ||',dependency' 
                                                   ||',update_on_edit'
                                                   ||',snap_to_theme'
                                                   ||',is_updatable'
                                                   ||',is_custom'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'theme_name'
                                ,pi_query_col    => 'nta1.nth_theme_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'table_name'
                                ,pi_query_col    => 'nta1.nth_table_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'pk_col'
                                ,pi_query_col    => 'nta1.nth_pk_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'pk_label'
                                ,pi_query_col    => 'nta1.nth_label_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'easting'
                                ,pi_query_col    => 'nta1.nth_x_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'northing'
                                ,pi_query_col    => 'nta1.nth_y_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'theme_type'
                                ,pi_query_col    => 'nta1.nth_theme_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'product'
                                ,pi_query_col    => 'nta1.nth_hpr_product'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'storage_type'
                                ,pi_query_col    => 'CASE 
                                                           WHEN nta1.nth_storage = ''S'' THEN ''Stored''
                                                           WHEN nta1.nth_storage = ''D'' THEN ''Derived''
                                                     END'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'base_table_theme'
                                ,pi_query_col    => 'nta2.nth_theme_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);                       
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'feature_table'
                                ,pi_query_col    => 'nta1.nth_feature_table'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'feature_pk'
                                ,pi_query_col    => 'nta1.nth_feature_pk_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'feature_fk'
                                ,pi_query_col    => 'nta1.nth_feature_fk_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'feature_shape'
                                ,pi_query_col    => 'nta1.nth_feature_shape_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'rse_table'
                                ,pi_query_col    => 'nta1.nth_rse_table_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'rse_fk_col'
                                ,pi_query_col    => 'nta1.nth_rse_fk_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_chainage'
                                ,pi_query_col    => 'nta1.nth_st_chain_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_chainage'
                                ,pi_query_col    => 'nta1.nth_end_chain_column'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'use_history'
                                ,pi_query_col    => 'nta1.nth_use_history'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'nta1.nth_start_date_column'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_date'
                                ,pi_query_col    => 'nta1.nth_end_date_column'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'tolerence'
                                ,pi_query_col    => 'nta1.nth_tolerance'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'dependency'
                                ,pi_query_col    => 'nta1.nth_dependency'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'update_on_edit'
                                ,pi_query_col    => 'nta1.nth_update_on_edit'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'snap_to_theme'
                                ,pi_query_col    => 'nta1.nth_snap_to_theme'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'is_updatable'
                                ,pi_query_col    => 'nta1.nth_location_updatable'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
                                --
      awlrs_util.add_column_data(pi_cursor_col   => 'is_custom'
                                ,pi_query_col    => 'CASE 
                                                         WHEN nta1.nth_where IS NOT NULL THEN ''Y''
                                                         WHEN nta1.nth_where IS NULL THEN ''N''
                                                     END'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nta1.nth_theme_name')||') a)'
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
  END get_paged_themes;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_a_view(pi_object_name IN VARCHAR2)
    RETURN BOOLEAN
  IS
    lv_dummy user_views.view_name%TYPE;
  BEGIN
  	SELECT view_name 
  	  INTO lv_dummy
  	  FROM user_views
  	 WHERE view_name = pi_object_name;
  	RETURN TRUE;
  EXCEPTION
  	WHEN NO_DATA_FOUND
  	  THEN RETURN FALSE;
  	WHEN OTHERS
  	  THEN RAISE;
  END is_a_view;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION can_actions_occur(pi_base_feature_table  IN  nm_themes_all.nth_feature_table%TYPE) 
    RETURN varchar2
  -- 
  IS
  --
  lv_results  varchar2(1) := 'N';
  --
  BEGIN
    --
    IF pi_base_feature_table IS NOT NULL
      THEN
        IF nm3ddl.does_object_exist(pi_base_feature_table)
          THEN
            IF is_a_view(pi_object_name => pi_base_feature_table)
              THEN
                lv_results := 'N';
            ELSE     
                lv_results := 'Y';
            END IF;
        END IF;                   
    END IF;   
    --
    RETURN lv_results;
    -- 
  END can_actions_occur;
  
  --
  -----------------------------------------------------------------------------
  --                            
  PROCEDURE get_spatial_details(pi_theme_id             IN     nm_themes_all.nth_theme_id%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
  IS
  --
  lv_results    nm3layer_tool.tab_sdo_results;
  lv_actions    varchar2(1);
  --
  BEGIN
  --
    BEGIN
      nm3layer_tool.get_sdo_details(pi_nth_theme_id => pi_theme_id
                                   ,po_results      => lv_results);
      -- 
      --this Y/N attribute is required to tell the UI when the Refresh metadata and Rebuild Spatial Index can be called  
      lv_actions := can_actions_occur(pi_base_feature_table => lv_results(1).c_sdo_index_table);                            
                                    
    END;   
    --
    OPEN po_cursor FOR
    SELECT nta1.nth_theme_id                 theme_id
          ,nta1.nth_feature_table            feature_table
          ,nta1.nth_feature_pk_column        feature_pk
          ,nta1.nth_feature_fk_column        feature_fk
          ,nta1.nth_feature_shape_column     feature_shape
          ,nta1.nth_rse_table_name           rse_table
          ,nta1.nth_rse_fk_column            rse_fk_col
          ,nta1.nth_st_chain_column          start_chainage
          ,nta1.nth_end_chain_column         end_chainage  
          ,ntg.ntg_gtype                     geometry_type
          ,hco.hco_meaning                   geometry_type_descr
          ,lv_results(1).c_sdo_index_table   base_feature_table
          ,lv_results(1).c_sdo_index_name    spatial_index_name
          ,lv_results(1).c_sdo_column_name   column_name         -- required for rebuild_index api--
          ,lv_results(1).c_sdo_index_type    index_type          -- required for rebuild_index api-- 
          ,awlrs_theme_api.get_last_analysed_date(pi_table_name => nta1.nth_feature_table)  last_analysed_date
          ,lv_results(1).c_usgm_srid         srid
          ,lv_results(1).c_usgm_srid_meaning srid_meaning
          ,lv_actions                        actions_yn
      FROM nm_themes_all  nta1
          ,nm_theme_gtypes ntg
          ,hig_codes hco
     WHERE nta1.nth_theme_id = pi_theme_id
       AND ntg.ntg_theme_id  = nta1.nth_theme_id
       AND hco.hco_code      = ntg.ntg_gtype
       AND hco.hco_domain    = 'GEOMETRY_TYPE';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_spatial_details;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_exists(pi_theme_id  IN  nm_themes_all.nth_theme_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_themes_all
     WHERE nth_theme_id = pi_theme_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_exists(pi_theme_name  IN  nm_themes_all.nth_theme_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_themes_all
     WHERE nth_theme_name = pi_theme_name;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION view_exists(pi_view_name  IN  user_views.view_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM user_views
     WHERE UPPER(view_name) = UPPER(pi_view_name);
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END view_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_gtypes_exist(pi_theme_id  IN  nm_theme_gtypes.ntg_theme_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_theme_gtypes
     WHERE ntg_theme_id = pi_theme_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_gtypes_exist;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_snappings_exist(pi_theme_id  IN  nm_theme_snaps.nts_theme_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_theme_snaps
     WHERE nts_theme_id = pi_theme_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_snappings_exist;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION base_themes_exist(pi_theme_id  IN  nm_base_themes.nbth_theme_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_base_themes
     WHERE nbth_theme_id = pi_theme_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END base_themes_exist;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION inv_themes_exist(pi_theme_id  IN  nm_inv_themes.nith_nth_theme_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_themes
     WHERE nith_nth_theme_id = pi_theme_id;
    --   
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END inv_themes_exist;
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE datum_nw_type_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor      OUT  sys_refcursor
                             ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type
          ,nt_unique
          ,nt_descr 
      FROM nm_types
     WHERE nt_datum = 'Y'
     ORDER BY nt_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END datum_nw_type_lov;                            
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE group_type_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT  sys_refcursor
                          ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type
          ,ngt_descr
          ,ngt_nt_type
          ,ngt_linear_flag
      FROM nm_group_types
     WHERE ngt_nt_type not in ('NSGN')
     ORDER BY ngt_group_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END group_type_lov;                                     
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE asset_type_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT  sys_refcursor
                          ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nit_inv_type
           ,nit_descr
           ,nit_category 
       FROM nm_inv_types
      WHERE nit_category != 'G'
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
  END asset_type_lov;
       
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_base_themes_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nth_theme_name
           ,nth_feature_table
           ,nth_theme_id 
       FROM nm_themes_all
      WHERE nth_theme_type = 'SDO'
      ORDER BY nth_theme_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_base_themes_lov;                                                                                      
  
  --
  -----------------------------------------------------------------------------
  --
  
  PROCEDURE create_group_theme(pi_nt_type           IN      nm_group_types.ngt_nt_type%TYPE
                              ,pi_group_type        IN      nm_group_types.ngt_group_type%TYPE
                              ,pi_linear_flag       IN      nm_group_types.ngt_linear_flag%TYPE
                              ,pi_theme_name        IN      nm_themes_all.nth_theme_name%TYPE
                              ,pi_log_errors        IN      varchar2
                              ,po_log_errors_id        OUT  nm3sdm_dyn_seg_ex.ndse_job_id%TYPE
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
  IS                              
  --
  lv_job_id   nm3sdm_dyn_seg_ex.ndse_job_id%TYPE;
  --
  BEGIN
    --
    SAVEPOINT create_group_theme_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value =>  pi_nt_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value =>  pi_group_type);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Linear'
                           ,pi_parameter_value => pi_linear_flag);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Name'
                               ,pi_parameter_value =>  pi_theme_name);
    
    IF theme_exists(pi_theme_name  =>  pi_theme_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme with this name already exists, theme name: '||pi_theme_name);
    END IF;
    --
    IF pi_log_errors = 'Y'
      THEN
       lv_job_id        := nm3job.get_next_njc_job_id;
       po_log_errors_id := lv_job_id;
    END IF;
    --
    IF pi_linear_flag = 'Y'
      THEN
        -- Create linear layer
	    nm3sdm.make_group_layer(p_nt_type            => pi_nt_type
	                           ,p_gty_type           => pi_group_type
	                           ,linear_flag_override => 'N'
	                           ,p_Job_Id             => lv_job_id);                    
	ELSE 
	    -- Create non linear layer
	    nm3sdm.make_group_layer(p_nt_type            => pi_nt_type
	                           ,p_gty_type           => pi_group_type
	                           ,linear_flag_override => 'Y'
	                           ,p_Job_Id             => lv_job_id); 
	END IF;                                                    
    --
    /*
    ||Check to see if the core API created a theme with
    ||the name to be used for the DT theme, if so update it.
    */
    UPDATE nm_themes_all
       SET nth_theme_name = SUBSTR(nth_theme_name,1,28)||'_V'
     WHERE nth_theme_id  IN(SELECT nth_theme_id
                              FROM nm_themes_all
                             WHERE EXISTS (
                                      SELECT 1
                                        FROM nm_nw_themes
                                       WHERE nnth_nth_theme_id = nth_theme_id
                                         AND EXISTS (
                                                SELECT 1
                                                  FROM nm_linear_types
                                                 WHERE nlt_id = nnth_nlt_id
                                                   AND nlt_gty_type = pi_group_type
                                                   AND nlt_g_i_d = 'G'))
                               OR EXISTS (
                                      SELECT 1
                                        FROM nm_area_themes
                                       WHERE nath_nth_theme_id = nth_theme_id
                                         AND EXISTS (
                                                SELECT 1
                                                  FROM nm_area_types
                                                 WHERE nat_id = nath_nat_id
                                                   AND nat_gty_group_type = pi_group_type))                    
                               AND nth_theme_name = pi_theme_name);  
    --
    /*
    || Update the date tracked theme name.
    */
    UPDATE nm_themes_all
       SET nth_theme_name = pi_theme_name
     WHERE nth_theme_id  IN(SELECT nth_theme_id
                              FROM nm_themes_all
                             WHERE EXISTS (
                                      SELECT 1
                                        FROM nm_nw_themes
                                       WHERE nnth_nth_theme_id = nth_theme_id
                                         AND EXISTS (
                                                SELECT 1
                                                  FROM nm_linear_types
                                                 WHERE nlt_id = nnth_nlt_id
                                                   AND nlt_gty_type = pi_group_type
                                                   AND nlt_g_i_d = 'G'))
                               OR EXISTS (
                                      SELECT 1
                                        FROM nm_area_themes
                                       WHERE nath_nth_theme_id = nth_theme_id
                                         AND EXISTS (
                                                SELECT 1
                                                  FROM nm_area_types
                                                 WHERE nat_id = nath_nat_id
                                                   AND nat_gty_group_type = pi_group_type))                    
                               AND nth_feature_table LIKE '%_DT');  
    --                               
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --   
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_group_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_theme;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_types_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT  sys_refcursor
                              ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    awlrs_metanet_api.get_node_types_lov(po_message_severity  =>  po_message_severity
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
  END get_node_types_lov;                             
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_node_theme(pi_node_type         IN      nm_node_types.nnt_type%TYPE
                             ,pi_theme_name        IN      nm_themes_all.nth_theme_name%TYPE
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
  IS                              
  --
  BEGIN
    --
    SAVEPOINT create_node_theme_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node'
                               ,pi_parameter_value =>  pi_node_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Name'
                               ,pi_parameter_value =>  pi_theme_name);
    
    IF theme_exists(pi_theme_name  =>  pi_theme_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme with this name already exists, theme name: '||pi_theme_name);
    END IF;
    --
    nm3layer_tool.create_node_layer(pi_node_type);
    --
    /*
    || Update the node theme name.
    */
    UPDATE nm_themes_all
       SET nth_theme_name = pi_theme_name
     WHERE nth_table_name LIKE 'V_NM_NO_'||UPPER(pi_node_type)||'_SDO';
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --   
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_node_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_node_theme;        
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_doc_gateway(pi_table_name  IN user_tables.table_name%TYPE
                              ,pi_descr       IN doc_gateways.dgt_table_descr%TYPE
                              ,pi_pk_col_name IN doc_gateways.dgt_pk_col_name%TYPE)
  IS
  BEGIN
    --
  	INSERT INTO doc_gateways
      (dgt_table_name,dgt_table_descr,dgt_pk_col_name,dgt_lov_descr_list)
    VALUES
      (pi_table_name, pi_descr, pi_pk_col_name, pi_pk_col_name);
    --  
  EXCEPTION
  	WHEN OTHERS THEN NULL;
  --	
  END create_doc_gateway;
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_asset_theme(pi_asset_type        IN      nm_inv_types.nit_inv_type%TYPE
                              --,pi_geom_type         IN      hig_codes.hco_code%TYPE
                              --,pi_xsp_offset        IN      varchar2
                              ,pi_dynseg            IN      varchar2
                              ,pi_theme_name        IN      nm_themes_all.nth_theme_name%TYPE
                              ,pi_use_history       IN      varchar2
                              ,pi_start_date_col    IN      nm_themes_all.nth_start_date_column%TYPE 
                              ,pi_end_date_col      IN      nm_themes_all.nth_end_date_column%TYPE
                              ,pi_log_errors        IN      varchar2
                              ,po_log_errors_id        OUT  nm3sdm_dyn_seg_ex.ndse_job_id%TYPE         
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
  IS                              
  --
  lv_rec_nit  nm_inv_types%ROWTYPE;
  lv_job_id   nm3sdm_dyn_seg_ex.ndse_job_id%TYPE;       
  --
  BEGIN
    --
    SAVEPOINT create_asset_theme_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value =>  pi_asset_type);
    --
    --awlrs_util.validate_yn(pi_parameter_desc  => 'XSP Offset'
    --                       ,pi_parameter_value => pi_xsp_offset);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Dynseg'
                           ,pi_parameter_value => pi_dynseg);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Log Errors'
                          ,pi_parameter_value => pi_log_errors);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Use History'
                          ,pi_parameter_value => pi_use_history);
    --
    IF pi_use_history = 'Y'
      THEN
        awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date Column'
                                   ,pi_parameter_value =>  pi_start_date_col);
      --
        awlrs_util.validate_notnull(pi_parameter_desc  => 'End Date Column'
                                   ,pi_parameter_value =>  pi_end_date_col);
    END IF;                               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Name'
                               ,pi_parameter_value =>  pi_theme_name);
    --
    IF theme_exists(pi_theme_name  =>  pi_theme_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme with this name already exists, theme name: '||pi_theme_name);
    END IF;
    --
    /*
    || Create the spatial views.
    */
    nm3inv_view.create_view(pi_asset_type,FALSE);
    nm3inv_view.create_view(pi_asset_type,TRUE);
    --
    IF pi_log_errors = 'Y'
      THEN
       lv_job_id        := nm3job.get_next_njc_job_id;
       po_log_errors_id := lv_job_id;
    END IF;
    --
    nm3sdm.make_inv_spatial_layer(pi_nit_inv_type => pi_asset_type
        	                     ,p_job_id        => CASE WHEN pi_log_errors = 'Y'
        	                                                THEN lv_job_id
        	                                              ELSE NULL
        	                                         END);
    --
    /*
    IF pi_xsp_offset = 'Y'
      THEN
        nm3sdo_dynseg.set_offset_flag_on;
        --
        nm3sdm.make_inv_spatial_layer(pi_nit_inv_type => pi_asset_type
        	                         ,p_job_id        => CASE WHEN pi_log_errors = 'Y'
        	                                                THEN Nm3job.get_next_njc_job_id
        	                                                ELSE NULL
        	                                             END);   
    ELSE  
        nm3sdo_dynseg.set_offset_flag_off;
        --
        nm3sdm.make_ona_inv_spatial_layer(pi_nit_inv_type => pi_asset_type
                                         ,pi_nth_gtype    => pi_geom_type
                                         ,pi_s_date_col   => pi_start_date_col
                                         ,pi_e_date_col   => pi_end_date_col);
    END IF;
    */
    --
    --check to see if this is needed--
    lv_rec_nit := nm3get.get_nit(pi_asset_type);
	--
	IF lv_rec_nit.nit_table_name IS NOT NULL
	  THEN
		 create_doc_gateway(lv_rec_nit.nit_table_name
		  	               ,lv_rec_nit.nit_descr
		  	               ,lv_rec_nit.nit_foreign_pk_column);

	END IF;
	--
	/*
    ||Check to see if the core API created a theme with
    ||the name to be used for the DT theme, if so update it.
    */
    UPDATE nm_themes_all
       SET nth_theme_name = SUBSTR(nth_theme_name,1,28)||'_V'
     WHERE nth_theme_id = (SELECT nth_theme_id
                             FROM nm_themes_all
                                 ,nm_inv_themes
                            WHERE nith_nit_id       = pi_asset_type
                              AND nith_nth_theme_id = nth_theme_id
                              AND nth_theme_name    = pi_theme_name);

	/*
    || Update the date tracked theme name.
    */
    UPDATE nm_themes_all
       SET nth_theme_name = pi_theme_name
     WHERE nth_theme_id   IN(SELECT nith_nth_theme_id
                               FROM nm_themes_all
                                   ,nm_inv_themes
                              WHERE nith_nit_id       = pi_asset_type
                                AND nith_nth_theme_id = nth_theme_id
                                AND nth_feature_table LIKE '%_DT');
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --   
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_asset_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_asset_theme;
                                                   
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_custom_col_names_lov(pi_base_table_name   IN      nm_themes_all.nth_feature_table%TYPE
                                    ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor       OUT  sys_refcursor
                                    ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT column_name
           ,data_type
       FROM all_tab_columns
      WHERE table_name = pi_base_table_name
        AND owner      = sys_context('NM3CORE','APPLICATION_OWNER')
        AND data_type  NOT IN ('SDO_GEOMETRY', 'BLOB');
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_custom_col_names_lov;                              
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE valid_custom_where_clause(pi_operator          IN      nm_themes_all.nth_theme_id%TYPE
                                     ,pi_column_name       IN      nm_themes_all.nth_theme_name%TYPE
                                     ,pi_condition         IN      nm_themes_all.nth_where%TYPE 
                                     ,pi_value             IN      nm_themes_all.nth_where%TYPE
                                     ,pi_value_datatype    IN      varchar2
                                     ,pi_base_table_name   IN      nm_themes_all.nth_feature_table%TYPE
                                     ,po_valid_yn             OUT  varchar2
                                     ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                     ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  CURSOR check_value_func(p_value VARCHAR2) IS
  SELECT DISTINCT 'Y' 
    FROM all_objects 
   WHERE p_value LIKE OBJECT_NAME || '(%' --functions with parameters
      OR p_value = OBJECT_NAME -- functions without paras
      OR p_value LIKE '%.' ||OBJECT_NAME -- functions with user
      OR p_value LIKE '%.' ||OBJECT_NAME || '(%' -- functions with user and paras
      OR p_value LIKE OBJECT_NAME || '.%'; -- packages with function in it.
  -- 
  lv_val_func     varchar2(100);
  lv_temp_date    varchar2(60);
  lv_dummy_date   date;
  lv_dummy_number number;
  lv_selectable   boolean;
  --   
  BEGIN
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Operator'
                               ,pi_parameter_value =>  pi_operator);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Column Name'
                               ,pi_parameter_value =>  pi_column_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Condition'
                               ,pi_parameter_value =>  pi_condition);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Value'
                               ,pi_parameter_value =>  pi_value);
    --
    BEGIN
      OPEN check_value_func(pi_value);
        FETCH check_value_func 
         INTO lv_val_func;
      CLOSE check_value_func;
      IF nvl(lv_val_func, 'N') <> 'Y' 
        THEN  
         IF pi_value_datatype = 'DATE' 
          THEN
            --	
            IF pi_value = 'SYSDATE' 
              THEN
                NULL;
            ELSIF pi_value LIKE '''%''' 
              THEN
                SELECT trim(rtrim(ltrim(pi_value, chr(39)), chr(39)))  
                  INTO lv_temp_date
                  FROM dual;
            --        
			    SELECT TO_DATE(lv_temp_date, NVL(hig.get_useopt('GRIDATE', USER), hig.get_sysopt('GRIDATE'))) 
				  INTO lv_dummy_date
				  FROM dual;
			ELSE
			    IF NOT nm3flx.can_string_be_select_from_tab(pi_string => pi_value
                                                           ,pi_table  => pi_base_table_name
                                                            )
			     THEN
                    hig.raise_ner(pi_appl               => 'NET'
                                 ,pi_id                 => 121
                                 ,pi_supplementary_info => pi_value);
			    END IF;
			END IF;
			--
	     ELSIF	pi_value_datatype = 'NUMBER' THEN
			--	
				SELECT pi_value
		       	 INTO lv_dummy_number
				 FROM dual;
			--
		 END IF;
		--
      END IF;
	EXCEPTION
	WHEN OTHERS THEN
		hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 121
	                 ,pi_supplementary_info => nm3flx.parse_error_message(SQLERRM));
	END;	
    --
    IF nvl(lv_val_func, 'N') = 'Y' 
      THEN
	    lv_selectable := nm3flx.can_string_be_select_from_dual (p_string => pi_value);
	  -- 
	    IF NOT lv_selectable 
	      THEN
	        hig.raise_ner(pi_appl               => 'NET'
		                 ,pi_id                 => 121
		                 ,pi_supplementary_info => 'Object can not be used in this way.');
		END IF;             	
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
  END valid_custom_where_clause;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE valid_custom_where_clause(pi_where_clause      IN      nm_themes_all.nth_where%TYPE
                                     ,pi_base_theme_id     IN      nm_base_themes.nbth_theme_id%TYPE
                                     ,po_valid_yn             OUT  varchar2
                                     ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                     ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Where Clause'
                               ,pi_parameter_value =>  pi_where_clause);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Base Theme Id'
                               ,pi_parameter_value =>  pi_base_theme_id);                               
    --
    IF NOT nm3layer_tool.parse_where_clause(pi_base_theme   => pi_base_theme_id 
                                           ,pi_where_clause => pi_where_clause)
      THEN
        po_valid_yn := 'N';
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 121);
    ELSE
        po_valid_yn := 'Y';                  
    END IF;                                             
  	--
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        po_valid_yn := 'N';
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);                                   
  END valid_custom_where_clause;                                   
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_custom_theme(pi_base_theme_id        IN      nm_themes_all.nth_theme_id%TYPE
                               ,pi_custom_theme_name    IN      nm_themes_all.nth_theme_name%TYPE
                               ,pi_where_clause         IN      nm_themes_all.nth_where%TYPE 
                               ,po_message_severity        OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT  sys_refcursor)
  IS                              
  --
  lv_rec_nth   nm_themes_all%ROWTYPE;
  --
  BEGIN
    --
    SAVEPOINT create_custom_theme_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Base Theme Id'
                               ,pi_parameter_value =>  pi_base_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Custom Theme Name'
                               ,pi_parameter_value =>  pi_custom_theme_name);
    --
    IF NOT nm3flx.is_string_valid_for_object(p_string  =>  pi_custom_theme_name)
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme Name: '||pi_custom_theme_name); 
    END IF;
    --   
    --Check whether custom theme name exists already as a view or a theme--
    IF view_exists(pi_view_name  =>  pi_custom_theme_name) = 'Y'
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'View with this name already exists, view name: '||pi_custom_theme_name);
    END IF;
    --
    IF theme_exists(pi_theme_name  =>  pi_custom_theme_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme with this name already exists, theme name: '||pi_custom_theme_name);
    END IF;
    --
    IF pi_where_clause IS NOT NULL 
      AND NOT nm3layer_tool.parse_where_clause(pi_base_theme   => pi_base_theme_id
                                              ,pi_where_clause => pi_where_clause)
  	     THEN
 	       hig.raise_ner(pi_appl => 'HIG'
                        ,pi_id   => 83
                        ,pi_supplementary_info => 'SQL is invalid');       
  	END IF;  
    --                               
    nm3layer_tool.make_layer_where(pi_base_theme    => pi_base_theme_id
	                              ,pi_where_clause  => pi_where_clause
	                              ,pi_view_name     => pi_custom_theme_name);                               
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_custom_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_custom_theme;   
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_reg_base_table_lov(po_message_severity     OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT  sys_refcursor
                                  ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT DISTINCT(table_name)
       FROM user_tab_cols 
      WHERE data_type  = 'SDO_GEOMETRY'
        AND table_name NOT LIKE 'BIN$%'
     ORDER BY 1;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_reg_base_table_lov;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_reg_pk_col_lov(pi_table_name        IN      user_tab_cols.table_name%TYPE
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor
                              ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT column_name 
       FROM user_tab_cols 
      WHERE data_type IN ('NUMBER','CHAR','VARCHAR2')
        AND table_name = pi_table_name
        AND column_name NOT LIKE 'SYS_N%'
        AND data_length = 22 
        AND data_precision = 38 
        AND data_scale = 0;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_reg_pk_col_lov;                                
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_reg_fk_col_lov(pi_table_name        IN      user_tab_cols.table_name%TYPE
                              ,pi_pk_column         IN      user_tab_cols.column_name%TYPE 
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor
                              ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT column_name 
       FROM user_tab_cols 
      WHERE data_type   IN ('NUMBER','CHAR','VARCHAR2')
        AND table_name  = pi_table_name
        AND column_name NOT LIKE 'SYS_N%'
        AND column_name <> pi_pk_column;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_reg_fk_col_lov;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_reg_geom_col_lov(pi_table_name        IN      user_tab_cols.table_name%TYPE
                                ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor       OUT  sys_refcursor
                                ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT column_name
       FROM user_tab_cols
      WHERE data_type in ('SDO_GEOMETRY')
        AND table_name = pi_table_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_reg_geom_col_lov;                                 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_reg_geom_type_lov(pi_table_name        IN      user_tab_cols.table_name%TYPE
                                 ,pi_geom_col_name     IN      user_tab_cols.column_name%TYPE 
                                 ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT  sys_refcursor
                                 ,po_cursor               OUT  sys_refcursor)
  IS
  --
  lv_sql           varchar2(100);
  lv_retval        varchar2(100);
  lv_table_name    user_tab_cols.table_name%TYPE;
  lv_geom_col_name user_tab_cols.column_name%TYPE;
  --
  lt_messages awlrs_message_tab := awlrs_message_tab();
  --
  CURSOR chk_params(cp_table_name    IN user_tab_cols.table_name%TYPE
                   ,cp_geom_col_name IN user_tab_cols.column_name%TYPE)
      IS                
  SELECT table_name
        ,column_name
    FROM user_tab_cols 
   WHERE table_name = cp_table_name
     AND column_name = cp_geom_col_name
     AND table_name NOT LIKE 'BIN$%';
  --   
  BEGIN
   --
    BEGIN
    --
      OPEN  chk_params(pi_table_name, pi_geom_col_name);
      FETCH chk_params
      INTO  lv_table_name
           ,lv_geom_col_name;
      CLOSE chk_params;
      --   
      IF   lv_table_name IS NOT NULL
       AND lv_geom_col_name IS NOT NULL
       THEN
         BEGIN
            lv_sql := 'select DISTINCT(t.'||lv_geom_col_name ||'.sdo_gtype) from '|| lv_table_name ||' t';
            lv_retval := hig.execute_autonomous_sql(lv_sql);
         EXCEPTION
           WHEN others THEN
               lv_retval:= NULL;
         END;
      ELSE   
         hig.raise_ner(pi_appl               => 'HIG'
                      ,pi_id                 =>  110
                      ,pi_supplementary_info => 'pi_table_name: '||pi_table_name||', pi_geom_col_name: '||pi_geom_col_name);
      END IF;
                
    END;
    --
    IF lv_retval IS NOT NULL
      THEN
        OPEN po_cursor FOR
         SELECT lv_retval
           FROM dual;
    ELSE
        OPEN po_cursor FOR
         SELECT hco_code
               ,hco_meaning
           FROM   hig_codes
          WHERE hco_domain = 'GEOMETRY_TYPE'
         ORDER BY hco_code;
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
  END get_reg_geom_type_lov;                                                                                          
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE register_spatial_table(pi_table_name        IN      user_tab_cols.table_name%TYPE
                                  ,pi_theme_name        IN      nm_themes_all.nth_theme_name%TYPE
                                  ,pi_pk_column         IN      user_tab_cols.column_name%TYPE
                                  ,pi_fk_column         IN      user_tab_cols.column_name%TYPE   
                                  ,pi_geom_col_name     IN      user_tab_cols.column_name%TYPE
                                  ,pi_geom_type         IN      hig_codes.hco_code%TYPE
                                  ,pi_tolerance         IN      nm_themes_all.nth_tolerance%TYPE
                                  ,pi_override_metadata IN      varchar2
                                  ,pi_create_spidx      IN      varchar2                               
                                  ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT  sys_refcursor)
  IS                              
  --
  lv_success boolean := TRUE;
  lv_error   varchar2(2000);
  --
  e_failed_reg exception;
  --
  BEGIN
    --
    SAVEPOINT reg_spatial_table_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Table Name'
                               ,pi_parameter_value =>  pi_table_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Name'
                               ,pi_parameter_value =>  pi_theme_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Primary Key Column'
                               ,pi_parameter_value =>  pi_pk_column);
    --
    IF theme_exists(pi_theme_name  =>  pi_theme_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme with this name already exists, theme name: '||pi_theme_name);
    END IF;
    --
    lv_success:= nm3layer_tool.register_table(p_table             => pi_table_name
						                     ,p_theme_name        => pi_theme_name
						                     ,p_pk_col            => pi_pk_column
						                     ,p_fk_col            => pi_fk_column
						                     ,p_shape_col         => pi_geom_col_name					                             						     
						                     ,p_tol               => pi_tolerance
						                     ,p_cre_idx           => pi_create_spidx
						                     ,p_estimate_new_tol  => CASE WHEN pi_tolerance IS NULL THEN 'Y' ELSE 'N' END  -- Check this out with Pano --
						                     ,p_override_sdo_meta => pi_override_metadata				                             
						                     ,p_asset_type        => NULL
						                     ,p_asset_descr       => NULL
						                     ,p_gtype             => pi_geom_type
						                     ,p_error             => lv_error);
    IF NOT lv_success
      THEN
        RAISE e_failed_reg;
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN e_failed_reg
      THEN
        hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 288
                     ,pi_supplementary_info => 'Error Message: '||lv_error);
    WHEN OTHERS
     THEN
        ROLLBACK TO reg_spatial_table_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END register_spatial_table; 

  --
  -----------------------------------------------------------------------------
  --       
--need to check p_where_clause may now be read only--
  PROCEDURE update_theme(pi_old_theme_id           IN      nm_themes_all.nth_theme_id%TYPE
                        ,pi_old_theme_name         IN      nm_themes_all.nth_theme_name%TYPE
                        ,pi_old_pk_col             IN      nm_themes_all.nth_pk_column%TYPE
                        ,pi_old_pk_label           IN      nm_themes_all.nth_label_column%TYPE
                        ,pi_old_is_updatable       IN      nm_themes_all.nth_location_updatable%TYPE
                        ,pi_old_base_theme         IN      nm_themes_all.nth_base_table_theme%TYPE
                        ,pi_old_where_clause       IN      nm_themes_all.nth_where%TYPE
                        ,pi_old_start_chainage     IN      nm_themes_all.nth_st_chain_column%TYPE
                        ,pi_old_end_chainage       IN      nm_themes_all.nth_end_chain_column%TYPE
                        ,pi_new_theme_id           IN      nm_themes_all.nth_theme_id%TYPE
                        ,pi_new_theme_name         IN      nm_themes_all.nth_theme_name%TYPE
                        ,pi_new_pk_col             IN      nm_themes_all.nth_pk_column%TYPE
                        ,pi_new_pk_label           IN      nm_themes_all.nth_label_column%TYPE
                        ,pi_new_is_updatable       IN      nm_themes_all.nth_location_updatable%TYPE
                        ,pi_new_base_theme         IN      nm_themes_all.nth_base_table_theme%TYPE
                        ,pi_new_where_clause       IN      nm_themes_all.nth_where%TYPE
                        ,pi_new_start_chainage     IN      nm_themes_all.nth_st_chain_column%TYPE
                        ,pi_new_end_chainage       IN      nm_themes_all.nth_end_chain_column%TYPE
                        ,po_message_severity          OUT  hig_codes.hco_code%TYPE
                        ,po_message_cursor            OUT  sys_refcursor)
  IS
    --
    lr_db_rec        nm_themes_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_themes_all
       WHERE nth_theme_id = pi_old_theme_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Theme does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_theme_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_new_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Name'
                               ,pi_parameter_value =>  pi_new_theme_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'PK Column'
                               ,pi_parameter_value =>  pi_new_pk_col);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'PK Label'
                               ,pi_parameter_value =>  pi_new_pk_label);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Location Updatable'
                               ,pi_parameter_value =>  pi_new_is_updatable);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nth_theme_id != pi_old_theme_id
     OR (lr_db_rec.nth_theme_id IS NULL AND pi_old_theme_id IS NOT NULL)
     OR (lr_db_rec.nth_theme_id IS NOT NULL AND pi_old_theme_id IS NULL)
     --
     OR (lr_db_rec.nth_theme_name != pi_old_theme_name)
     OR (lr_db_rec.nth_theme_name IS NULL AND pi_old_theme_name IS NOT NULL)
     OR (lr_db_rec.nth_theme_name IS NOT NULL AND pi_old_theme_name IS NULL)
     --
     OR (lr_db_rec.nth_pk_column != pi_old_pk_col)
     OR (lr_db_rec.nth_pk_column IS NULL AND pi_old_pk_col IS NOT NULL)
     OR (lr_db_rec.nth_pk_column IS NOT NULL AND pi_old_pk_col IS NULL)
     --
     OR (lr_db_rec.nth_label_column != pi_old_pk_label)
     OR (lr_db_rec.nth_label_column IS NULL AND pi_old_pk_label IS NOT NULL)
     OR (lr_db_rec.nth_label_column IS NOT NULL AND pi_old_pk_label IS NULL)
     --
     OR (lr_db_rec.nth_location_updatable != pi_old_is_updatable)
     OR (lr_db_rec.nth_location_updatable IS NULL AND pi_old_is_updatable IS NOT NULL)
     OR (lr_db_rec.nth_location_updatable IS NOT NULL AND pi_old_is_updatable IS NULL)
     --
     --OR (lr_db_rec.nth_base_table_theme != pi_old_base_theme)
     --OR (lr_db_rec.nth_base_table_theme IS NULL AND pi_old_base_theme IS NOT NULL)
     --OR (lr_db_rec.nth_base_table_theme IS NOT NULL AND pi_old_base_theme IS NULL)
     --
     OR (lr_db_rec.nth_where != pi_old_where_clause)
     OR (lr_db_rec.nth_where IS NULL AND pi_old_where_clause IS NOT NULL)
     OR (lr_db_rec.nth_where IS NOT NULL AND pi_old_where_clause IS NULL)
     --
     OR (lr_db_rec.nth_st_chain_column != pi_old_start_chainage)
     OR (lr_db_rec.nth_st_chain_column IS NULL AND pi_old_start_chainage IS NOT NULL)
     OR (lr_db_rec.nth_st_chain_column IS NOT NULL AND pi_old_start_chainage IS NULL)
     --
     OR (lr_db_rec.nth_end_chain_column != pi_old_end_chainage)
     OR (lr_db_rec.nth_end_chain_column IS NULL AND pi_old_end_chainage IS NOT NULL)
     OR (lr_db_rec.nth_end_chain_column IS NOT NULL AND pi_old_end_chainage IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_theme_id != pi_new_theme_id
       OR (pi_old_theme_id IS NULL AND pi_new_theme_id IS NOT NULL)
       OR (pi_old_theme_id IS NOT NULL AND pi_new_theme_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_theme_name != pi_new_theme_name
       OR (pi_old_theme_name IS NULL AND pi_new_theme_name IS NOT NULL)
       OR (pi_old_theme_name IS NOT NULL AND pi_new_theme_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_pk_col != pi_new_pk_col
       OR (pi_old_pk_col IS NULL AND pi_new_pk_col IS NOT NULL)
       OR (pi_old_pk_col IS NOT NULL AND pi_new_pk_col IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_pk_label != pi_new_pk_label
       OR (pi_old_pk_label IS NULL AND pi_new_pk_label IS NOT NULL)
       OR (pi_old_pk_label IS NOT NULL AND pi_new_pk_label IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_is_updatable != pi_new_is_updatable
       OR (pi_old_is_updatable IS NULL AND pi_new_is_updatable IS NOT NULL)
       OR (pi_old_is_updatable IS NOT NULL AND pi_new_is_updatable IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_where_clause != pi_new_where_clause
       OR (pi_old_where_clause IS NULL AND pi_new_where_clause IS NOT NULL)
       OR (pi_old_where_clause IS NOT NULL AND pi_new_where_clause IS NULL)
       THEN
         --validate where clause--
         IF nm3layer_tool.parse_where_clause(pi_base_theme     => pi_new_base_theme
                                            ,pi_where_clause   => pi_new_where_clause)
          THEN                          
            lv_upd := 'Y';
         ELSE
            hig.raise_ner(pi_appl               => 'NET'
                         ,pi_id                 => 121
                         ,pi_supplementary_info => 'Please review the Where Clause');    
         END IF;
      END IF;
      --
      IF pi_old_start_chainage != pi_new_start_chainage
       OR (pi_old_start_chainage IS NULL AND pi_new_start_chainage IS NOT NULL)
       OR (pi_old_start_chainage IS NOT NULL AND pi_new_start_chainage IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_end_chainage != pi_new_end_chainage
       OR (pi_old_end_chainage IS NULL AND pi_new_end_chainage IS NOT NULL)
       OR (pi_old_end_chainage IS NOT NULL AND pi_new_end_chainage IS NULL)
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
        UPDATE nm_themes_all
           SET nth_theme_id           =  pi_new_theme_id
              ,nth_theme_name         =  pi_new_theme_name
              ,nth_pk_column          =  pi_new_pk_col
              ,nth_label_column       =  pi_new_pk_label
              ,nth_location_updatable =  pi_new_is_updatable
              ,nth_where              =  pi_new_where_clause 
              ,nth_st_chain_column    =  pi_new_start_chainage
              ,nth_end_chain_column   =  pi_new_end_chainage
         WHERE nth_theme_id =  pi_old_theme_id;
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
        ROLLBACK TO update_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_theme;                      
                                                
  --
  -----------------------------------------------------------------------------
  --                                   
  PROCEDURE delete_theme(pi_theme_id          IN      nm_themes_all.nth_theme_id%TYPE
                        ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                        ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_theme_sp;
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
    IF theme_exists(pi_theme_id  =>  pi_theme_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme does not exist, theme id: '||pi_theme_id);
    END IF;
    --
    -- now check for any child records --    
    IF theme_gtypes_exist(pi_theme_id => pi_theme_id) = 'Y'
     THEN
        DELETE FROM nm_theme_gtypes
         WHERE ntg_theme_id = pi_theme_id;        
--        hig.raise_ner(pi_appl => 'NET'
--                     ,pi_id   => 2
--                     ,pi_supplementary_info => 'Geometry Types');
    END IF;
    --
    IF theme_snappings_exist(pi_theme_id => pi_theme_id) = 'Y'
     THEN
        DELETE FROM nm_theme_snaps 
         WHERE nts_theme_id = pi_theme_id;
--        hig.raise_ner(pi_appl => 'NET'
--                     ,pi_id   => 2
--                     ,pi_supplementary_info => 'Snappings');
    END IF;
    --
    IF base_themes_exist(pi_theme_id => pi_theme_id) = 'Y'
     THEN
        DELETE FROM nm_base_themes
         WHERE nbth_theme_id = pi_theme_id;
--        hig.raise_ner(pi_appl => 'NET'
--                     ,pi_id   => 2
--                     ,pi_supplementary_info => 'Base Themes');
    END IF;
    --
    IF inv_themes_exist(pi_theme_id => pi_theme_id) = 'Y'
     THEN
        DELETE FROM nm_inv_themes
         WHERE nith_nth_theme_id = pi_theme_id;
--        hig.raise_ner(pi_appl => 'NET'
--                     ,pi_id   => 2
--                     ,pi_supplementary_info => 'Inventory Themes');
    END IF;
    --
    DELETE FROM nm_theme_roles
     WHERE nthr_theme_id = pi_theme_id;
    --
    DELETE FROM nm_theme_functions_all
     WHERE ntf_nth_theme_id = pi_theme_id;
    --
    DELETE FROM nm_themes_all
     WHERE nth_theme_id = pi_theme_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_theme;                         
                                                              
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_functions(pi_theme_id          IN      nm_theme_functions_all.ntf_nth_theme_id%TYPE
                               ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT  sys_refcursor
                               ,po_cursor               OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ntf_nth_theme_id       theme_id
          ,ntf_hmo_module         module_
          ,ntf_parameter          parameter
          ,ntf_menu_option        screen_text
          ,ntf_seen_in_gis        seen_in_gis 
      FROM nm_theme_functions_all 
     WHERE ntf_nth_theme_id  =  pi_theme_id
    ORDER BY ntf_hmo_module;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_functions;                             

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_function(pi_theme_id           IN     nm_theme_functions_all.ntf_nth_theme_id%TYPE
                              ,pi_module             IN     nm_theme_functions_all.ntf_hmo_module%TYPE
                              ,pi_parameter          IN     nm_theme_functions_all.ntf_parameter%TYPE
                              ,po_message_severity      OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor        OUT sys_refcursor
                              ,po_cursor                OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ntf_nth_theme_id       theme_id
          ,ntf_hmo_module         module_
          ,ntf_parameter          parameter
          ,ntf_menu_option        screen_text
          ,ntf_seen_in_gis        seen_in_gis 
      FROM nm_theme_functions_all 
     WHERE ntf_nth_theme_id  =  pi_theme_id
       AND ntf_hmo_module    =  pi_module
       AND ntf_parameter     =  pi_parameter;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_function;                                

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_theme_functions(pi_theme_id             IN     nm_theme_functions_all.ntf_nth_theme_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT ntf_nth_theme_id       theme_id
                                                    ,ntf_hmo_module         module_
                                                    ,ntf_parameter          parameter
                                                    ,ntf_menu_option        screen_text
                                                    ,ntf_seen_in_gis        seen_in_gis 
                                                FROM nm_theme_functions_all 
                                               WHERE ntf_nth_theme_id  =  :pi_theme_id ';               
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  theme_id'
                                                  ||',module_'
                                                  ||',parameter'
                                                  ||',screen_text'
                                                  ||',seen_in_gis'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'module_'
                                ,pi_query_col    => 'ntf_hmo_module'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'parameter'
                                ,pi_query_col    => 'ntf_parameter'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'screen_text'
                                ,pi_query_col    => 'ntf_menu_option'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'seen_in_gis'
                                ,pi_query_col    => 'ntf_seen_in_gis'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ntf_hmo_module')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
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
  END get_paged_theme_functions;  
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_theme_modules_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT  sys_refcursor
                                 ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hmo_module
          ,hmo_title
          --,hmo_application   -- removed initially, but is included in forms equivalent --
      FROM hig_modules
    ORDER BY hmo_module;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_modules_lov; 
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_function_exists(pi_theme_id          IN      nm_theme_functions_all.ntf_nth_theme_id%TYPE
                                ,pi_module            IN      nm_theme_functions_all.ntf_hmo_module%TYPE
                                ,pi_parameter         IN      nm_theme_functions_all.ntf_parameter%TYPE )
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_theme_functions_all
     WHERE ntf_nth_theme_id = pi_theme_id
       AND ntf_hmo_module   = pi_module
       AND ntf_parameter    = pi_parameter;      
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_function_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_role_exists(pi_theme_id   IN      nm_theme_roles.nthr_theme_id%TYPE
                            ,pi_role       IN      nm_theme_roles.nthr_role%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_theme_roles
     WHERE nthr_theme_id = pi_theme_id
       AND nthr_role     = pi_role;
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_role_exists;
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_theme_function(pi_theme_id          IN      nm_theme_functions_all.ntf_nth_theme_id%TYPE
                                  ,pi_module            IN      nm_theme_functions_all.ntf_hmo_module%TYPE
                                  ,pi_parameter         IN      nm_theme_functions_all.ntf_parameter%TYPE 
                                  ,pi_screen_text       IN      nm_theme_functions_all.ntf_menu_option%TYPE
                                  ,pi_seen_in_gis       IN      nm_theme_functions_all.ntf_seen_in_gis%TYPE
                                  ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_theme_function_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module'
                               ,pi_parameter_value =>  pi_module);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parameter'
                               ,pi_parameter_value =>  pi_parameter);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Screen Text'
                               ,pi_parameter_value =>  pi_screen_text);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Seen in GIS'
                               ,pi_parameter_value =>  pi_seen_in_gis);
    --
    IF theme_function_exists(pi_theme_id  =>  pi_theme_id 
                            ,pi_module    =>  pi_module
                            ,pi_parameter =>  pi_parameter) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Theme Id '||pi_theme_id||', Module '||pi_module||', Parameter '||pi_parameter);
    END IF;
    --
    /*
    ||insert into nm_theme_functions_all.
    */
    INSERT
      INTO nm_theme_functions_all
          (ntf_nth_theme_id
          ,ntf_hmo_module
          ,ntf_parameter
          ,ntf_menu_option
          ,ntf_seen_in_gis
          )
    VALUES (pi_theme_id
           ,pi_module
           ,pi_parameter 
           ,pi_screen_text
           ,pi_seen_in_gis
           );
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_theme_function_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_theme_function;                            
  
  --
  -----------------------------------------------------------------------------
  --       
  PROCEDURE update_theme_function(pi_old_theme_id          IN      nm_theme_functions_all.ntf_nth_theme_id%TYPE
                                 ,pi_old_module            IN      nm_theme_functions_all.ntf_hmo_module%TYPE
                                 ,pi_old_parameter         IN      nm_theme_functions_all.ntf_parameter%TYPE 
                                 ,pi_old_screen_text       IN      nm_theme_functions_all.ntf_menu_option%TYPE
                                 ,pi_old_seen_in_gis       IN      nm_theme_functions_all.ntf_seen_in_gis%TYPE
                                 ,pi_new_theme_id          IN      nm_theme_functions_all.ntf_nth_theme_id%TYPE
                                 ,pi_new_module            IN      nm_theme_functions_all.ntf_hmo_module%TYPE
                                 ,pi_new_parameter         IN      nm_theme_functions_all.ntf_parameter%TYPE 
                                 ,pi_new_screen_text       IN      nm_theme_functions_all.ntf_menu_option%TYPE
                                 ,pi_new_seen_in_gis       IN      nm_theme_functions_all.ntf_seen_in_gis%TYPE
                                 ,po_message_severity         OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor           OUT  sys_refcursor)
  IS
    --
    lr_db_rec        nm_theme_functions_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_theme_functions_all
       WHERE ntf_nth_theme_id = pi_old_theme_id
         AND ntf_hmo_module   = pi_old_module
         AND ntf_parameter    = pi_old_parameter
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Theme Function does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_theme_function_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_new_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Module'
                               ,pi_parameter_value =>  pi_new_module);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parameter'
                               ,pi_parameter_value =>  pi_new_parameter);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Screen Text'
                               ,pi_parameter_value =>  pi_new_screen_text);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Seen in GIS'
                               ,pi_parameter_value =>  pi_new_seen_in_gis);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.ntf_nth_theme_id != pi_old_theme_id
     OR (lr_db_rec.ntf_nth_theme_id IS NULL AND pi_old_theme_id IS NOT NULL)
     OR (lr_db_rec.ntf_nth_theme_id IS NOT NULL AND pi_old_theme_id IS NULL)
     --
     OR (lr_db_rec.ntf_hmo_module != pi_old_module)
     OR (lr_db_rec.ntf_hmo_module IS NULL AND pi_old_module IS NOT NULL)
     OR (lr_db_rec.ntf_hmo_module IS NOT NULL AND pi_old_module IS NULL)
     --
     OR (lr_db_rec.ntf_parameter != pi_old_parameter)
     OR (lr_db_rec.ntf_parameter IS NULL AND pi_old_parameter IS NOT NULL)
     OR (lr_db_rec.ntf_parameter IS NOT NULL AND pi_old_parameter IS NULL)
     --
     OR (lr_db_rec.ntf_menu_option != pi_old_screen_text)
     OR (lr_db_rec.ntf_menu_option IS NULL AND pi_old_screen_text IS NOT NULL)
     OR (lr_db_rec.ntf_menu_option IS NOT NULL AND pi_old_screen_text IS NULL)
     --
     OR (lr_db_rec.ntf_seen_in_gis != pi_old_seen_in_gis)
     OR (lr_db_rec.ntf_seen_in_gis IS NULL AND pi_old_seen_in_gis IS NOT NULL)
     OR (lr_db_rec.ntf_seen_in_gis IS NOT NULL AND pi_old_seen_in_gis IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_theme_id != pi_new_theme_id
       OR (pi_old_theme_id IS NULL AND pi_new_theme_id IS NOT NULL)
       OR (pi_old_theme_id IS NOT NULL AND pi_new_theme_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_module != pi_new_module
       OR (pi_old_module IS NULL AND pi_new_module IS NOT NULL)
       OR (pi_old_module IS NOT NULL AND pi_new_module IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_parameter != pi_new_parameter
       OR (pi_old_parameter IS NULL AND pi_new_parameter IS NOT NULL)
       OR (pi_old_parameter IS NOT NULL AND pi_new_parameter IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_screen_text != pi_new_screen_text
       OR (pi_old_screen_text IS NULL AND pi_new_screen_text IS NOT NULL)
       OR (pi_old_screen_text IS NOT NULL AND pi_new_screen_text IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_seen_in_gis != pi_new_seen_in_gis
       OR (pi_old_seen_in_gis IS NULL AND pi_new_seen_in_gis IS NOT NULL)
       OR (pi_old_seen_in_gis IS NOT NULL AND pi_new_seen_in_gis IS NULL)
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
        UPDATE nm_theme_functions_all
           SET ntf_nth_theme_id =  pi_new_theme_id
              ,ntf_hmo_module   =  pi_new_module
              ,ntf_parameter    =  pi_new_parameter
              ,ntf_menu_option  =  pi_new_screen_text
              ,ntf_seen_in_gis  =  pi_new_seen_in_gis
         WHERE ntf_nth_theme_id =  pi_old_theme_id
           AND ntf_hmo_module   =  pi_old_module
           AND ntf_parameter    =  pi_old_parameter;
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
        ROLLBACK TO update_theme_function_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_theme_function;
                                                               
  --
  -----------------------------------------------------------------------------
  --                           
  PROCEDURE delete_theme_function(pi_theme_id          IN      nm_theme_functions_all.ntf_nth_theme_id%TYPE
                                 ,pi_module            IN      nm_theme_functions_all.ntf_hmo_module%TYPE
                                 ,pi_parameter         IN      nm_theme_functions_all.ntf_parameter%TYPE 
                                 ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_theme_function_sp;
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
    IF theme_function_exists(pi_theme_id  =>  pi_theme_id 
                            ,pi_module    =>  pi_module
                            ,pi_parameter =>  pi_parameter) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Function does not exist for this Theme');
    END IF;
    --    
    DELETE FROM nm_theme_functions_all
     WHERE ntf_nth_theme_id = pi_theme_id
       AND ntf_hmo_module   = pi_module
       AND ntf_parameter    = pi_parameter;      
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_theme_function_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_theme_function;                                                                   
  --
  -----------------------------------------------------------------------------
  --  
  PROCEDURE get_theme_roles(pi_theme_id          IN      nm_theme_roles.nthr_theme_id%TYPE
                           ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor       OUT  sys_refcursor
                           ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nthr_theme_id     theme_id
          ,nthr_role         role_
          ,nthr_mode         mode_
      FROM nm_theme_roles 
     WHERE nthr_theme_id  =  pi_theme_id
    ORDER BY nthr_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_roles;                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_role(pi_theme_id           IN     nm_theme_roles.nthr_theme_id%TYPE
                          ,pi_role               IN     nm_theme_roles.nthr_role%TYPE
                          ,po_message_severity      OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor        OUT sys_refcursor
                          ,po_cursor                OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nthr_theme_id     theme_id
          ,nthr_role         role_
          ,nthr_mode         mode_
      FROM nm_theme_roles 
     WHERE nthr_theme_id  =  pi_theme_id
       AND nthr_role      =  pi_role
    ORDER BY nthr_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_role;                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_theme_roles(pi_theme_id             IN     nm_theme_roles.nthr_theme_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nthr_theme_id     theme_id
                                                    ,nthr_role         role_
                                                    ,nthr_mode         mode_
                                                FROM nm_theme_roles 
                                               WHERE nthr_theme_id  =  :pi_theme_id ';                                                              
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  theme_id'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'role_'
                                ,pi_query_col    => 'nthr_role'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'mode_'
                                ,pi_query_col    => 'nthr_mode'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nthr_role')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
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
  END get_paged_theme_roles;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_roles_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hro_role
          ,hro_descr
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
  END get_theme_roles_lov; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_roles_mode_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 'NORMAL' 
          ,'NORMAL'   
      FROM dual
    UNION
    SELECT 'READONLY' 
          ,'READONLY'  
      FROM dual;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_roles_mode_lov; 
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_theme_role(pi_theme_id          IN      nm_theme_roles.nthr_theme_id%TYPE
                             ,pi_role              IN      nm_theme_roles.nthr_role%TYPE
                             ,pi_mode              IN      nm_theme_roles.nthr_mode%TYPE 
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_theme_roles_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value =>  pi_role);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value =>  pi_mode);
    --
    IF theme_role_exists(pi_theme_id  =>  pi_theme_id 
                        ,pi_role      =>  pi_role) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Theme Id '||pi_theme_id||', Role '||pi_role);
    END IF;
    --
    /*
    ||insert into nm_theme_roles.
    */
    INSERT
      INTO nm_theme_roles
          (nthr_theme_id
          ,nthr_role
          ,nthr_mode
          )
    VALUES (pi_theme_id
           ,pi_role
           ,pi_mode
           );
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_theme_roles_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_theme_role;                              
  
  --
  -----------------------------------------------------------------------------
  --       
  PROCEDURE update_theme_role(pi_old_theme_id          IN      nm_theme_roles.nthr_theme_id%TYPE
                             ,pi_old_role              IN      nm_theme_roles.nthr_role%TYPE
                             ,pi_old_mode              IN      nm_theme_roles.nthr_mode%TYPE
                             ,pi_new_theme_id          IN      nm_theme_roles.nthr_theme_id%TYPE
                             ,pi_new_role              IN      nm_theme_roles.nthr_role%TYPE
                             ,pi_new_mode              IN      nm_theme_roles.nthr_mode%TYPE 
                             ,po_message_severity         OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor           OUT  sys_refcursor)
  IS
    --
    lr_db_rec        nm_theme_roles%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_theme_roles
       WHERE nthr_theme_id = pi_old_theme_id
         AND nthr_role     = pi_old_role
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Theme Role does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_theme_role_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_new_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value =>  pi_new_role);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value =>  pi_new_mode);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nthr_theme_id != pi_old_theme_id
     OR (lr_db_rec.nthr_theme_id IS NULL AND pi_old_theme_id IS NOT NULL)
     OR (lr_db_rec.nthr_theme_id IS NOT NULL AND pi_old_theme_id IS NULL)
     --
     OR (lr_db_rec.nthr_role != pi_old_role)
     OR (lr_db_rec.nthr_role IS NULL AND pi_old_role IS NOT NULL)
     OR (lr_db_rec.nthr_role IS NOT NULL AND pi_old_role IS NULL)
     --
     OR (lr_db_rec.nthr_mode != pi_old_mode)
     OR (lr_db_rec.nthr_mode IS NULL AND pi_old_mode IS NOT NULL)
     OR (lr_db_rec.nthr_mode IS NOT NULL AND pi_old_mode IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_theme_id != pi_new_theme_id
       OR (pi_old_theme_id IS NULL AND pi_new_theme_id IS NOT NULL)
       OR (pi_old_theme_id IS NOT NULL AND pi_new_theme_id IS NULL)
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
        UPDATE nm_theme_roles
           SET nthr_theme_id =  pi_new_theme_id
              ,nthr_role     =  pi_new_role
              ,nthr_mode     =  pi_new_mode
         WHERE nthr_theme_id =  pi_old_theme_id
           AND nthr_role     =  pi_old_role;
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
        ROLLBACK TO update_theme_role_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_theme_role;                                                           
  --
  -----------------------------------------------------------------------------
  --                           
  PROCEDURE delete_theme_role(pi_theme_id          IN      nm_theme_roles.nthr_theme_id%TYPE
                             ,pi_role              IN      nm_theme_roles.nthr_role%TYPE 
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_theme_roles_sp;
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
    IF theme_role_exists(pi_theme_id  =>  pi_theme_id 
                        ,pi_role      =>  pi_role) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Role does not exist for this Theme');
    END IF;
    --    
    DELETE FROM nm_theme_roles
     WHERE nthr_theme_id = pi_theme_id
       AND nthr_role     = pi_role;      
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_theme_roles_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_theme_role;
                              
  --
  -----------------------------------------------------------------------------
  --                             
  PROCEDURE get_theme_gtypes(pi_theme_id          IN      nm_theme_gtypes.ntg_theme_id%TYPE
                            ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor       OUT  sys_refcursor
                            ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ntg_theme_id      theme_id
          ,ntg_gtype         gtype
          ,hco_meaning       gtype_descr
          ,ntg_seq_no        seq_no
      FROM nm_theme_gtypes
          ,hig_codes 
     WHERE ntg_theme_id  =   pi_theme_id
       AND ntg_gtype     =   hco_code
       AND hco_domain    =  'GEOMETRY_TYPE'
    ORDER BY ntg_seq_no;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_gtypes;      
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_theme_gtypes_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor      OUT  sys_refcursor
                                ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hco_code
          ,hco_meaning
      FROM hig_codes
     WHERE hco_domain = 'GEOMETRY_TYPE'
    ORDER BY hco_code;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_gtypes_lov; 
  
  --
  -----------------------------------------------------------------------------
  --                           
  PROCEDURE get_base_themes(pi_theme_id          IN      nm_base_themes.nbth_theme_id%TYPE
                           ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor       OUT  sys_refcursor
                           ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nbt.nbth_theme_id     theme_id
          ,nbt.nbth_base_theme   base_theme
          ,nta.nth_theme_name    base_theme_name
      FROM nm_base_themes nbt
          ,nm_themes_all nta
     WHERE nbt.nbth_theme_id   = pi_theme_id
       AND nbt.nbth_base_theme = nta.nth_theme_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_base_themes;                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_base_theme(pi_theme_id           IN     nm_base_themes.nbth_theme_id%TYPE
                          ,pi_base_theme         IN     nm_base_themes.nbth_base_theme%TYPE
                          ,po_message_severity      OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor        OUT sys_refcursor
                          ,po_cursor                OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nbt.nbth_theme_id     theme_id
          ,nbt.nbth_base_theme   base_theme
          ,nta.nth_theme_name    base_theme_name
      FROM nm_base_themes nbt
          ,nm_themes_all nta
     WHERE nbt.nbth_theme_id   = pi_theme_id
       AND nbt.nbth_base_theme = pi_base_theme
       AND nbt.nbth_base_theme = nta.nth_theme_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_base_theme;                                              
                          
  --
  -----------------------------------------------------------------------------
  --                            
  PROCEDURE get_theme_snappings(pi_theme_id          IN      nm_theme_snaps.nts_theme_id%TYPE
                               ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT  sys_refcursor
                               ,po_cursor               OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nts.nts_theme_id     theme_id
          ,nts.nts_snap_to      snap_to
          ,nta.nth_theme_name   snap_to_name
          ,nts.nts_priority     priority_
      FROM nm_theme_snaps nts
          ,nm_themes_all nta
     WHERE nts.nts_theme_id = pi_theme_id
       AND nts.nts_snap_to  = nta.nth_theme_id
    ORDER BY nts.nts_priority;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_snappings;                             

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_snapping(pi_theme_id           IN     nm_theme_snaps.nts_theme_id%TYPE
                              ,pi_snap_to            IN     nm_theme_snaps.nts_snap_to%TYPE
                              ,po_message_severity      OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor        OUT sys_refcursor
                              ,po_cursor                OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nts.nts_theme_id     theme_id
          ,nts.nts_snap_to      snap_to
          ,nta.nth_theme_name   snap_to_name
          ,nts.nts_priority     priority_
      FROM nm_theme_snaps nts
          ,nm_themes_all nta
     WHERE nts.nts_theme_id = pi_theme_id
       AND nts.nts_snap_to  = pi_snap_to
       AND nts.nts_snap_to  = nta.nth_theme_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_snapping;                         

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_theme_snappings(pi_theme_id             IN     nm_theme_snaps.nts_theme_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nts.nts_theme_id     theme_id
                                                    ,nts.nts_snap_to      snap_to
                                                    ,nta.nth_theme_name   snap_to_name
                                                    ,nts.nts_priority     priority_
                                                FROM nm_theme_snaps nts
                                                    ,nm_themes_all nta
                                               WHERE nts.nts_theme_id = :pi_theme_id
                                                 AND nts.nts_snap_to  = nta.nth_theme_id'; 
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  theme_id'
                                                  ||',snap_to'
                                                  ||',snap_to_name'
                                                  ||',priority_'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'theme_id'
                                ,pi_query_col    => 'nts_theme_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'snap_to'
                                ,pi_query_col    => 'nts_snap_to'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'snap_to_name'
                                ,pi_query_col    => 'nth_theme_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'priority_'
                                ,pi_query_col    => 'nts_priority'
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
                                   ,pi_where_or_and => 'AND' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                   ,po_where_clause => lv_filter);
          
      END IF;
      --  
      lv_cursor_sql := lv_cursor_sql
                       ||CHR(10)||lv_filter
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nts_priority')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
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
  END get_paged_theme_snappings;  
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION theme_snapping_exists(pi_theme_id   IN   nm_theme_snaps.nts_theme_id%TYPE
                                ,pi_snap_to    IN   nm_theme_snaps.nts_snap_to%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_theme_snaps
     WHERE nts_theme_id = pi_theme_id
       AND nts_snap_to  = pi_snap_to;
    --
    RETURN lv_exists;
    -- 
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END theme_snapping_exists;
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE create_theme_snapping(pi_theme_id          IN      nm_theme_snaps.nts_theme_id%TYPE
                                 ,pi_snap_to           IN      nm_theme_snaps.nts_snap_to%TYPE
                                 ,pi_priority          IN      nm_theme_snaps.nts_priority%TYPE
                                 ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    SAVEPOINT create_theme_snapping_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Snap To'
                               ,pi_parameter_value =>  pi_snap_to);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Priority'
                               ,pi_parameter_value =>  pi_priority);
    --
    IF theme_snapping_exists(pi_theme_id  =>  pi_theme_id 
                            ,pi_snap_to   =>  pi_snap_to) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Theme Id '||pi_theme_id||', Snap To '||pi_snap_to);
    END IF;
    --
    /*
    ||insert into nm_theme_snaps.
    */
    INSERT
      INTO nm_theme_snaps
          (nts_theme_id
          ,nts_snap_to
          ,nts_priority
          )
    VALUES (pi_theme_id
           ,pi_snap_to
           ,pi_priority
           );
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_theme_snapping_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_theme_snapping;                                 
  
  --
  -----------------------------------------------------------------------------
  --       
  PROCEDURE update_theme_snapping(pi_old_theme_id          IN      nm_theme_snaps.nts_theme_id%TYPE
                                 ,pi_old_snap_to           IN      nm_theme_snaps.nts_snap_to%TYPE
                                 ,pi_old_priority          IN      nm_theme_snaps.nts_priority%TYPE
                                 ,pi_new_theme_id          IN      nm_theme_snaps.nts_theme_id%TYPE
                                 ,pi_new_snap_to           IN      nm_theme_snaps.nts_snap_to%TYPE
                                 ,pi_new_priority          IN      nm_theme_snaps.nts_priority%TYPE
                                 ,po_message_severity         OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor           OUT  sys_refcursor)
  IS
    --
    lr_db_rec        nm_theme_snaps%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_theme_snaps
       WHERE nts_theme_id = pi_old_theme_id
         AND nts_snap_to  = pi_old_snap_to
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Theme Snapping does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_theme_snapping_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Id'
                               ,pi_parameter_value =>  pi_new_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Snap To'
                               ,pi_parameter_value =>  pi_new_snap_to);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Priority'
                               ,pi_parameter_value =>  pi_new_priority);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nts_theme_id != pi_old_theme_id
     OR (lr_db_rec.nts_theme_id IS NULL AND pi_old_theme_id IS NOT NULL)
     OR (lr_db_rec.nts_theme_id IS NOT NULL AND pi_old_theme_id IS NULL)
     --
     OR (lr_db_rec.nts_snap_to != pi_old_snap_to)
     OR (lr_db_rec.nts_snap_to IS NULL AND pi_old_snap_to IS NOT NULL)
     OR (lr_db_rec.nts_snap_to IS NOT NULL AND pi_old_snap_to IS NULL)
     --
     OR (lr_db_rec.nts_priority != pi_old_priority)
     OR (lr_db_rec.nts_priority IS NULL AND pi_old_priority IS NOT NULL)
     OR (lr_db_rec.nts_priority IS NOT NULL AND pi_old_priority IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_theme_id != pi_new_theme_id
       OR (pi_old_theme_id IS NULL AND pi_new_theme_id IS NOT NULL)
       OR (pi_old_theme_id IS NOT NULL AND pi_new_theme_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_snap_to != pi_new_snap_to
       OR (pi_old_snap_to IS NULL AND pi_new_snap_to IS NOT NULL)
       OR (pi_old_snap_to IS NOT NULL AND pi_new_snap_to IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_priority != pi_new_priority
       OR (pi_old_priority IS NULL AND pi_new_priority IS NOT NULL)
       OR (pi_old_priority IS NOT NULL AND pi_new_priority IS NULL)
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
        UPDATE nm_theme_snaps
           SET nts_theme_id =  pi_new_theme_id
              ,nts_snap_to  =  pi_new_snap_to
              ,nts_priority =  pi_new_priority
         WHERE nts_theme_id =  pi_old_theme_id
           AND nts_snap_to  =  pi_old_snap_to;
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
        ROLLBACK TO update_theme_snapping_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_theme_snapping;                                  
                                                          
  --
  -----------------------------------------------------------------------------
  --                             
  PROCEDURE delete_theme_snapping(pi_theme_id          IN      nm_theme_snaps.nts_theme_id%TYPE
                                 ,pi_snap_to           IN      nm_theme_snaps.nts_snap_to%TYPE
                                 ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_theme_snapping_sp;
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
    IF theme_snapping_exists(pi_theme_id  =>  pi_theme_id 
                            ,pi_snap_to   =>  pi_snap_to) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Snapping does not exist for this Theme');
    END IF;
    --    
    DELETE FROM nm_theme_snaps
     WHERE nts_theme_id = pi_theme_id
       AND nts_snap_to  = pi_snap_to;      
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_theme_snapping_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_theme_snapping;                                  
                                 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_snappings_lov(po_message_severity    OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT  sys_refcursor
                                   ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nth_theme_id
          ,nth_theme_name
      FROM nm_themes_all
          ,nm_nw_themes
     WHERE nth_theme_id = nnth_nth_theme_id
     AND EXISTS
        (SELECT 1 
           FROM nm_linear_types
          WHERE nlt_id = nnth_nlt_id
        )
    ORDER BY nth_theme_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_snappings_lov; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_lref_details(pi_theme_id             IN     nm_nw_themes.nnth_nth_theme_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nnt.nnth_nth_theme_id      theme_id
                                                    ,nlt.nlt_id                 nlt_id
                                                    ,nlt.nlt_seq_no             seq_no
                                                    ,nlt.nlt_descr              nlt_descr
                                                    ,nlt.nlt_nt_type            nw_type
                                                    ,nt.nt_descr                nw_type_descr
                                                    ,nlt.nlt_gty_type           group_type   
                                                    ,ngt.ngt_descr              group_type_descr
                                                    ,nlt.nlt_units              units 
                                                    ,un.un_unit_name            units_descr
                                                    ,nlt.nlt_admin_type         admin_type
                                                    ,nat.nat_descr              admin_type_descr
                                                    ,nlt.nlt_start_date         start_date
                                                    ,nlt.nlt_end_date           end_date
                                                FROM nm_linear_types nlt
                                                    ,nm_nw_themes nnt
                                                    ,nm_types nt
                                                    ,nm_group_types_all ngt
                                                    ,nm_units un 
                                                    ,nm_au_types_full nat
                                               WHERE nlt.nlt_id            = nnt.nnth_nlt_id
                                                 AND nnt.nnth_nth_theme_id = :pi_theme_id
                                                 AND nlt.nlt_nt_type       = nt.nt_type
                                                 AND nlt.nlt_gty_type      = ngt.ngt_group_type(+)
                                                 AND nlt.nlt_units         = un.un_unit_id
                                                 AND nlt.nlt_admin_type    = nat.nat_admin_type'; 
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  theme_id'
                                                  ||',nlt_id'
                                                  ||',seq_no'
                                                  ||',nlt_descr'
                                                  ||',nw_type'
                                                  ||',nw_type_descr'
                                                  ||',group_type'
                                                  ||',group_type_descr'
                                                  ||',units'
                                                  ||',units_descr'
                                                  ||',admin_type'
                                                  ||',admin_type_descr'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'seq_no'
                                ,pi_query_col    => 'nlt_seq_no'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nlt_descr'
                                ,pi_query_col    => 'nlt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nw_type_descr'
                                ,pi_query_col    => 'nt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'group_type_descr'
                                ,pi_query_col    => 'ngt.ngt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'units_descr'
                                ,pi_query_col    => 'un_unit_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'admin_type_descr'
                                ,pi_query_col    => 'nat_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'nlt_start_date'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nlt_seq_no')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
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
  END get_paged_lref_details;                                                               
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_area_details(pi_theme_id             IN     nm_area_themes.nath_nth_theme_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nat.nath_nth_theme_id      theme_id
                                                    ,naty.nat_id                nat_id
                                                    ,naty.nat_seq_no            seq_no
                                                    ,naty.nat_descr             nat_descr
                                                    ,naty.nat_nt_type           nw_type
                                                    ,nt.nt_descr                nw_type_descr
                                                    ,naty.nat_gty_group_type    group_type   
                                                    ,ngt.ngt_descr              group_type_descr
                                                    ,naty.nat_shape_type        shape_type 
                                                    ,naty.nat_start_date        start_date
                                                    ,naty.nat_end_date          end_date
                                                FROM nm_area_types naty
                                                    ,nm_area_themes nat
                                                    ,nm_types nt
                                                    ,nm_group_types_all ngt
                                               WHERE naty.nat_id             = nat.nath_nat_id
                                                 AND nat.nath_nth_theme_id   = :pi_theme_id
                                                 AND naty.nat_nt_type        = nt.nt_type
                                                 AND naty.nat_gty_group_type = ngt.ngt_group_type'; 
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  theme_id'
                                                  ||',nat_id'
                                                  ||',seq_no'
                                                  ||',nat_descr'
                                                  ||',nw_type'
                                                  ||',nw_type_descr'
                                                  ||',group_type'
                                                  ||',group_type_descr'
                                                  ||',shape_type'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'seq_no'
                                ,pi_query_col    => 'nat_seq_no'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nat_descr'
                                ,pi_query_col    => 'nat_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'nw_type_descr'
                                ,pi_query_col    => 'nt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'group_type_descr'
                                ,pi_query_col    => 'ngt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'shape_type'
                                ,pi_query_col    => 'nat_shape_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_date'
                                ,pi_query_col    => 'nat_start_date'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nat_seq_no')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
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
  END get_paged_area_details;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_details(pi_theme_id             IN     nm_inv_themes.nith_nth_theme_id%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nith.nith_nth_theme_id     theme_id
                                                    ,nith.nith_nit_id           asset_type         
                                                    ,nita.nit_descr             asset_type_descr
                                                    ,nita.nit_notes             notes
                                                    ,nita.nit_table_name        table_name
                                                    ,nita.nit_view_name         view_name  
                                                    ,CASE WHEN nita.nit_pnt_or_cont = ''P'' THEN ''POINT''
                                                          WHEN nita.nit_pnt_or_cont = ''C'' THEN ''LINE''
                                                     END                        point_or_line   
                                                    ,nita.nit_use_xy            use_xy
                                                    ,nita.nit_linear            is_linear 
                                                    ,nita.nit_lr_st_chain       start_chainage
                                                    ,nita.nit_lr_end_chain      end_chainage  
                                                    ,nita.nit_lr_ne_column_name column_name
                                                FROM nm_inv_themes nith
                                                    ,nm_inv_types_all nita 
                                               WHERE nith.nith_nth_theme_id = :pi_theme_id
                                                 AND nita.nit_inv_type = nith.nith_nit_id'; 
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  theme_id'
                                                  ||',asset_type'
                                                  ||',asset_type_descr'
                                                  ||',notes'
                                                  ||',table_name'
                                                  ||',view_name'
                                                  ||',point_or_line'
                                                  ||',use_xy'
                                                  ||',is_linear'
                                                  ||',start_chainage'
                                                  ||',end_chainage'
                                                  ||',column_name'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'asset_type'
                                ,pi_query_col    => 'nith_nit_id'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'asset_type_descr'
                                ,pi_query_col    => 'nit_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'notes'
                                ,pi_query_col    => 'nit_notes'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'table_name'
                                ,pi_query_col    => 'nit_table_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'view_name'
                                ,pi_query_col    => 'nit_view_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'point_or_line'
                                ,pi_query_col    => 'CASE WHEN nita.nit_pnt_or_cont = ''P'' THEN ''POINT''
                                                          WHEN nita.nit_pnt_or_cont = ''C'' THEN ''LINE''
                                                     END'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --                          
      awlrs_util.add_column_data(pi_cursor_col   => 'use_xy'
                                ,pi_query_col    => 'nit_use_xy'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'is_linear'
                                ,pi_query_col    => 'nit_linear'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --       
      awlrs_util.add_column_data(pi_cursor_col   => 'start_chainage'
                                ,pi_query_col    => 'nit_lr_st_chain'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_chainage'
                                ,pi_query_col    => 'nit_lr_end_chain'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'column_name'
                                ,pi_query_col    => 'nit_lr_ne_column_name'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nith_nit_id')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_theme_id
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
  END get_paged_asset_details;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE analyse_table(pi_ft_table_name        IN     nm_themes_all.nth_feature_table%TYPE
                         ,po_last_analysed_date      OUT DATE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor)
  IS                       
  --
  BEGIN
    --
    IF pi_ft_table_name IS NOT NULL
	 THEN
	   nm3ddl.analyse_table(pi_table_name => pi_ft_table_name);
       po_last_analysed_date := get_last_analysed_date(pi_table_name => pi_ft_table_name);    
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
  END analyse_table;                                                                                           
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE rebuild_index(pi_index_name       IN    user_indexes.index_name%TYPE
                         ,pi_table_name       IN    user_tables.table_name%TYPE
                         ,pi_column_name      IN    user_tab_columns.column_name%TYPE
                         ,pi_index_type       IN    VARCHAR2 DEFAULT 'RTREE'
                         ,po_message_severity    OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor      OUT sys_refcursor)
  IS                       
  --
  BEGIN
    --
    IF (   pi_index_name IS NOT NULL
	    OR pi_table_name  IS NOT NULL
	    OR pi_column_name IS NOT NULL
	    OR pi_index_type  IS NOT NULL
	   )
		THEN 
    	   nm3layer_tool.rebuild_spatial_index(pi_index_name  => pi_index_name
                                              ,pi_table_name  => pi_table_name
                                              ,pi_column_name => pi_column_name   
                                              ,pi_index_type  => NVL(pi_index_type,'RTREE'));
                                     
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
  END rebuild_index;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_refresh_themes(pi_theme_id           IN     nm_themes_all.nth_theme_id%TYPE
                              ,pi_dependency_option  IN     VARCHAR2
                              ,po_message_severity      OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor        OUT sys_refcursor
                              ,po_cursor                OUT sys_refcursor)    
  IS
  --
  --lv_results           nm3layer_tool.tab_refresh_themes;
  --
  cv_dep_tab           CONSTANT VARCHAR2(10) := 'TAB';
  cv_dep_all_data      CONSTANT VARCHAR2(10) := 'ALL_DATA';
  --
  BEGIN
  --
--    BEGIN
--      nm3layer_tool.get_refresh_themes(pi_nth_theme_id      => pi_theme_id
--                                      ,pi_metadata_option   => pi_metadata_option
--                                      ,pi_dependency_option => pi_dependency_option
--                                      ,po_results           => lv_results);
--    END;   
    --
    OPEN po_cursor FOR
    SELECT 1 seq
          ,nth_theme_id
          ,'Selected Theme - '||nth_theme_name 
      FROM nm_themes_all
     WHERE nth_theme_id = pi_theme_id
    UNION ALL
    -- Get any view based themes 
    SELECT 2 seq
          ,nth_theme_id
          ,'Child Theme - '||nth_theme_name
      FROM nm_themes_all
     WHERE nth_base_table_theme = pi_theme_id
       AND 1 = CASE WHEN pi_dependency_option != cv_dep_tab
                 THEN 1 
                 ELSE 2 
               END
    UNION ALL
    -- Get dependent Asset Themes
    SELECT 3 seq
          ,nth_theme_id
          ,'Dependent Asset Theme - '||nth_theme_name 
      FROM nm_themes_all
     WHERE nth_theme_id IN (SELECT nbth_theme_id
                              FROM nm_base_themes 
                             WHERE nbth_base_theme = pi_theme_id)
       AND EXISTS
               (SELECT 1 FROM nm_inv_themes
                WHERE nith_nth_theme_id = nth_theme_id)
       AND 1 = CASE WHEN pi_dependency_option = cv_dep_all_data
                 THEN 1 
                 ELSE 2
               END
    UNION ALL
    -- Get dependent Network Themes
    SELECT 4 seq
          ,nth_theme_id
          ,'Dependent Network Theme - '||nth_theme_name 
      FROM nm_themes_all
     WHERE nth_theme_id IN(SELECT nbth_theme_id
                             FROM nm_base_themes 
                            WHERE nbth_base_theme = pi_theme_id )
       AND EXISTS
               (SELECT 1 FROM v_nm_net_themes_all
                 WHERE vnnt_nth_theme_id = nth_theme_id)
                   AND 1 = CASE WHEN pi_dependency_option = cv_dep_all_data
                             THEN 1 
                             ELSE 2
                           END
    UNION ALL
    -- Get any other dependent Themes
    SELECT 5 seq
          ,nth_theme_id
          ,'Dependent - '||nth_theme_name 
      FROM nm_themes_all
     WHERE nth_theme_id IN (SELECT nbth_theme_id
                              FROM nm_base_themes 
                             WHERE nbth_base_theme = pi_theme_id)
       AND NOT EXISTS
          (SELECT 1 FROM v_nm_net_themes_all
            WHERE vnnt_nth_theme_id = nth_theme_id)
       AND NOT EXISTS
          (SELECT 1 FROM nm_inv_themes
            WHERE nith_nth_theme_id = nth_theme_id)
       AND 1 = CASE WHEN pi_dependency_option = cv_dep_all_data
                 THEN 1 
                 ELSE 2
               END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_refresh_themes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE refresh_metadata(pi_theme_id            IN     nm_themes_all.nth_theme_id%TYPE
                            ,pi_sdo_metadata_option IN     VARCHAR2  DEFAULT 'Y'
                            ,pi_sde_metadata_option IN     VARCHAR2  DEFAULT 'Y'
                            ,pi_dependency_option   IN     VARCHAR2  DEFAULT 'ALL_DATA'
                            ,po_message_severity       OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor         OUT sys_refcursor)
  IS
  --
    lv_job_type  VARCHAR2(12);
    lv_dummy1    VARCHAR2(20);
    lv_dummy2    VARCHAR2(20);
  --
  BEGIN
  --
    IF (    pi_sdo_metadata_option = 'Y' 
    	AND pi_sde_metadata_option = 'N')
        THEN
    	    lv_job_type := 'REFRESH_SDO';
    ELSIF 
       (    pi_sdo_metadata_option = 'N' 
    	AND pi_sde_metadata_option = 'Y')
    	THEN
    	    lv_job_type := 'REFRESH_SDE';
    ELSIF 
       (    pi_sdo_metadata_option = 'Y'  
    	AND pi_sde_metadata_option = 'Y')
    	THEN
    	    lv_job_type := 'REFRESH_BOTH';
    ELSE
    	lv_job_type := 'REFRESH_BOTH';
    END IF;
    --
    IF lv_job_type IS NOT NULL
      THEN
        nm3layer_tool.submit_job(pi_job_type => lv_job_type
                                ,pi_arg_1    => pi_theme_id
                                ,pi_arg_2    => NVL(pi_dependency_option,'ALL_DATA')
                                ,pi_arg_3    => 'CLONE'
                                ,po_out_1    => lv_dummy1
                                ,po_out_2    => lv_dummy2
                                );
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
  END refresh_metadata;     
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_theme_log_errors(pi_job_id               IN     nm3sdm_dyn_seg_ex.ndse_job_id%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor 
                                ,po_cursor                  OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT ndse_id
           ,ndse_ner_id
           ,ndse_ne_id_in
           ,ndse_ne_id_of
           ,ndse_shape_length
           ,ndse_ne_length
           ,ndse_start
           ,ndse_end
           ,ndse_sqlerrm 
       FROM nm3sdm_dyn_seg_ex
      WHERE ndse_job_id = pi_job_id
      ORDER BY ndse_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_theme_log_errors;       
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_view_text(pi_view_name            IN     user_views.view_name%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor 
                         ,po_cursor                  OUT sys_refcursor)
  IS
  --
  lv_view_name    user_views.view_name%TYPE;
  lv_text_length  number;
  lv_text         long;
  lv_vc2          varchar2(32767);
  --
  BEGIN
    --
    IF is_a_view(pi_object_name => pi_view_name)
      THEN
       --
       SELECT view_name
             ,text_length
             ,text 
         INTO lv_view_name
             ,lv_text_length
             ,lv_text    
         FROM user_views
        WHERE view_name = pi_view_name;
        --
        lv_vc2 := substr(lv_text, 1, 32767);
       --  
       OPEN po_cursor FOR
       SELECT lv_view_name
             ,lv_text_length
             ,lv_vc2 
         FROM dual;
    ELSE
       hig.raise_ner(pi_appl => 'NET'
                    ,pi_id   => 265);  
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
  END get_view_text;         
  
  --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE copy_theme(pi_copy_from_theme_id   IN     nm_themes_all.nth_theme_id%TYPE
                      ,pi_new_theme_name       IN     nm_themes_all.nth_theme_name%TYPE  
                      ,po_message_severity        OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor          OUT sys_refcursor)                      
  IS
  --
  lv_new_theme_id    nm_themes_all.nth_theme_id%TYPE;
  --
  BEGIN
    --                    
  SAVEPOINT copy_theme_sp;
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
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Copy Theme Id'
                               ,pi_parameter_value =>  pi_copy_from_theme_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Theme Name'
                               ,pi_parameter_value =>  pi_new_theme_name);    
    --
    IF theme_exists(pi_theme_name  =>  pi_new_theme_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Theme with this name already exists, theme name: '||pi_new_theme_name);
    END IF;
    --
    -- get new theme id --
    lv_new_theme_id := higgis.next_theme_id;
    /*
    ||insert into nm_themes_all.
    */
    BEGIN
        INSERT 
          INTO nm_themes_all
              (nth_theme_id
              ,nth_theme_name  
              ,nth_table_name
              ,nth_where
              ,nth_pk_column
              ,nth_label_column
              ,nth_rse_table_name
              ,nth_rse_fk_column
              ,nth_st_chain_column
              ,nth_end_chain_column
              ,nth_x_column
              ,nth_y_column
              ,nth_offset_field
              ,nth_feature_table
              ,nth_feature_pk_column
              ,nth_feature_fk_column
              ,nth_xsp_column
              ,nth_feature_shape_column
              ,nth_hpr_product
              ,nth_location_updatable
              ,nth_theme_type
              ,nth_dependency
              ,nth_storage
              ,nth_update_on_edit
              ,nth_use_history
              ,nth_start_date_column
              ,nth_end_date_column
              ,nth_base_table_theme
              ,nth_sequence_name
              ,nth_snap_to_theme
              ,nth_lref_mandatory
              ,nth_tolerance
              ,nth_tol_units
              ,nth_dynamic_theme
              )
        SELECT lv_new_theme_id
              ,pi_new_theme_name
              ,nth_table_name
              ,nth_where
              ,nth_pk_column
              ,nth_label_column
              ,nth_rse_table_name
              ,nth_rse_fk_column
              ,nth_st_chain_column
              ,nth_end_chain_column
              ,nth_x_column
              ,nth_y_column
              ,nth_offset_field
              ,nth_feature_table
              ,nth_feature_pk_column
              ,nth_feature_fk_column
              ,nth_xsp_column
              ,nth_feature_shape_column
              ,nth_hpr_product
              ,nth_location_updatable
              ,nth_theme_type
              ,nth_dependency
              ,nth_storage
              ,nth_update_on_edit
              ,nth_use_history
              ,nth_start_date_column
              ,nth_end_date_column
              ,nth_base_table_theme
              ,nth_sequence_name
              ,nth_snap_to_theme
              ,nth_lref_mandatory
              ,nth_tolerance
              ,nth_tol_units
              ,nth_dynamic_theme          
          FROM nm_themes_all
         WHERE nth_theme_id = pi_copy_from_theme_id;
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           hig.raise_ner(pi_appl => 'HIG'
                        ,pi_id   => 67
                        ,pi_supplementary_info  => 'Copy Theme Id: '||pi_copy_from_theme_id);
      WHEN OTHERS
       THEN
         ROLLBACK TO copy_theme_sp;
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;         
    --
    /*
    ||insert into nm_theme_functions_all.
    */
    BEGIN
        INSERT
          INTO nm_theme_functions_all
              (ntf_nth_theme_id
              ,ntf_hmo_module
              ,ntf_parameter
              ,ntf_menu_option 
              ,ntf_seen_in_gis
              )
        SELECT lv_new_theme_id
              ,ntf_hmo_module
              ,ntf_parameter
              ,ntf_menu_option 
              ,ntf_seen_in_gis
          FROM nm_theme_functions_all
         WHERE ntf_nth_theme_id = pi_copy_from_theme_id;  
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;      
    --
    /*
    ||insert into nm_theme_roles.
    */
    BEGIN
        INSERT
          INTO nm_theme_roles
              (nthr_theme_id
              ,nthr_role
              ,nthr_mode
              )
        SELECT lv_new_theme_id
               ,nthr_role
               ,nthr_mode
          FROM nm_theme_roles
         WHERE nthr_theme_id = pi_copy_from_theme_id;  
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;      
    --
    /*
    ||insert into nm_theme_gtypes.
    */
    BEGIN
        INSERT
          INTO nm_theme_gtypes
              (ntg_theme_id
              ,ntg_gtype
              ,ntg_seq_no
              ,ntg_xml_url
              )
        SELECT lv_new_theme_id
              ,ntg_gtype
              ,ntg_seq_no
              ,ntg_xml_url
          FROM nm_theme_gtypes
         WHERE ntg_theme_id = pi_copy_from_theme_id;  
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END; 
    --
    /*
    ||insert into nm_theme_snaps.
    */
    BEGIN
        INSERT
          INTO nm_theme_snaps
              (nts_theme_id
              ,nts_snap_to
              ,nts_priority
              )
        SELECT lv_new_theme_id
              ,nts_snap_to
              ,nts_priority
          FROM nm_theme_snaps
         WHERE nts_theme_id = pi_copy_from_theme_id; 
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;  
    --
    /*
    ||insert into nm_base_themes.
    */
    BEGIN
        INSERT
          INTO nm_base_themes
              (nbth_theme_id
              ,nbth_base_theme
              )
        SELECT lv_new_theme_id
              ,nbth_base_theme
          FROM nm_base_themes
         WHERE nbth_theme_id = pi_copy_from_theme_id;
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;   
    --
    /*
    ||insert into nm_inv_themes.
    */
    BEGIN
        INSERT
          INTO nm_inv_themes
              (nith_nit_id
              ,nith_nth_theme_id
              )
        SELECT nith_nit_id
              ,lv_new_theme_id
          FROM nm_inv_themes
         WHERE nith_nth_theme_id = pi_copy_from_theme_id;
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;   
     --
    /*
    ||insert into nm_nw_themes.
    */
    BEGIN
        INSERT
          INTO nm_nw_themes
              (nnth_nlt_id
              ,nnth_nth_theme_id
              )
        SELECT nnth_nlt_id
              ,lv_new_theme_id
          FROM nm_nw_themes
         WHERE nnth_nth_theme_id = pi_copy_from_theme_id;
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;   
    --
    /*
    ||insert into nm_area_themes.
    */
    BEGIN
        INSERT
          INTO nm_area_themes
              (nath_nat_id
              ,nath_nth_theme_id
              )
        SELECT nath_nat_id
              ,lv_new_theme_id
          FROM nm_area_themes
         WHERE nath_nth_theme_id = pi_copy_from_theme_id;
    EXCEPTION
      WHEN NO_DATA_FOUND 
       THEN
           null;
      WHEN OTHERS
       THEN
         awlrs_util.handle_exception(po_message_severity => po_message_severity
                                    ,po_cursor           => po_message_cursor); 
    END;   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO copy_theme_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END copy_theme;                                                                                                                                                        
  --
  -----------------------------------------------------------------------------
  --
                                
  --                                  

END awlrs_theme_api;
/
