CREATE OR REPLACE PACKAGE BODY awlrs_metaast_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_metaast_api.pkb-arc   1.3   Sep 06 2019 13:40:44   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_metaast_api.pkb  $
  --       Date into PVCS   : $Date:   Sep 06 2019 13:40:44  $
  --       Date fetched Out : $Modtime:   Sep 05 2019 11:12:30  $
  --       Version          : $Revision:   1.3  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.3  $';
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
  FUNCTION asset_domain_exists(pi_asset_domain IN nm_inv_domains.id_domain%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_domains
     WHERE id_domain = pi_asset_domain;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_domain_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION nw_xsp_exists(pi_nw_type    IN nm_nw_xsp.nwx_nw_type%TYPE
                        ,pi_xsp        IN nm_nw_xsp.nwx_x_sect%TYPE
                        ,pi_sub_class  IN nm_nw_xsp.nwx_nsc_sub_class%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_nw_xsp
     WHERE nwx_nw_type = pi_nw_type
       AND nwx_x_sect = pi_xsp
       AND nwx_nsc_sub_class = pi_sub_class;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END nw_xsp_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION unit_exists(pi_unit_id    IN nm_units.un_unit_id%TYPE)
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
        RETURN lv_exists;
  END unit_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION xsp_restraint_exists(pi_nw_type    IN nm_xsp_restraints.xsr_nw_type%TYPE
                               ,pi_xsp        IN nm_xsp_restraints.xsr_x_sect_value%TYPE
                               ,pi_sub_class  IN nm_xsp_restraints.xsr_scl_class%TYPE
                               ,pi_inv_code   IN nm_xsp_restraints.xsr_ity_inv_code%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_xsp_restraints
     WHERE xsr_nw_type = pi_nw_type
       AND xsr_x_sect_value = pi_xsp
       AND xsr_scl_class = pi_sub_class
       AND xsr_ity_inv_code = pi_inv_code;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END xsp_restraint_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION xsp_reversal_exists(pi_nw_type             IN      nm_xsp_reversal.xrv_nw_type%TYPE
                              ,pi_xsp                 IN      nm_xsp_reversal.xrv_old_xsp%TYPE
                              ,pi_sub_class           IN      nm_xsp_reversal.xrv_old_sub_class%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_xsp_reversal
     WHERE xrv_nw_type = pi_nw_type
       AND xrv_old_xsp = pi_xsp
       AND xrv_old_sub_class = pi_sub_class;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END xsp_reversal_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION asset_domain_value_exists(pi_asset_domain       IN nm_inv_attri_lookup_all.ial_domain%TYPE
                                    ,pi_asset_domain_value IN nm_inv_attri_lookup_all.ial_value%TYPE
                                    ,pi_start_date         IN nm_inv_attri_lookup_all.ial_start_date%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_attri_lookup
     WHERE ial_domain = pi_asset_domain
       AND ial_value  = pi_asset_domain_value
       AND ial_start_date = pi_start_date;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_domain_value_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION sub_class_exists(pi_sub_class  IN   nm_type_subclass.nsc_sub_class%TYPE
                           ,pi_nw_type    IN   nm_type_subclass.nsc_nw_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_type_subclass
     WHERE nsc_nw_type = pi_nw_type
       AND nsc_sub_class = pi_sub_class;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END sub_class_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION asset_type_exists(pi_asset_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_types
     WHERE nit_inv_type = pi_asset_type;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_type_exists;  

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
  FUNCTION asset_role_exists(pi_asset_type  IN nm_inv_type_roles.itr_inv_type%TYPE
                            ,pi_role        IN nm_inv_type_roles.itr_hro_role%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_type_roles
     WHERE itr_inv_type = pi_asset_type
       AND itr_hro_role = pi_role;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_role_exists;  

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION asset_attribute_exists(pi_asset_type          IN      nm_inv_type_attribs.ita_inv_type%TYPE    
                                 ,pi_attrib_name         IN      nm_inv_type_attribs.ita_attrib_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_type_attribs
     WHERE ita_inv_type = pi_asset_type
       AND ita_attrib_name = pi_attrib_name;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_attribute_exists;  
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION asset_attribute_exists(pi_asset_type          IN      nm_inv_type_attribs.ita_inv_type%TYPE    
                                 ,pi_view_attribute      IN      nm_inv_type_attribs.ita_view_attri%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_type_attribs
     WHERE ita_inv_type = pi_asset_type
       AND ita_view_attri = pi_view_attribute;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_attribute_exists;    
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION asset_category_exists(pi_asset_category IN nm_inv_categories.nic_category%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_categories
     WHERE nic_category = pi_asset_category;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_category_exists;  
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION asset_nw_exists(pi_asset_type IN nm_inv_nw.nin_nit_inv_code%TYPE
                          ,pi_nw_type    IN nm_inv_nw.nin_nw_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_nw
     WHERE nin_nit_inv_code = pi_asset_type
       AND nin_nw_type = pi_nw_type;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_nw_exists;  
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION admin_type_exists(pi_admin_type IN nm_au_types.nat_admin_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_au_types 
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
  FUNCTION asset_grouping_exists(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE    
                                ,pi_parent_asset_type  IN      nm_inv_type_groupings_all.itg_parent_inv_type%TYPE
                                ,pi_start_date         IN      nm_inv_type_groupings_all.itg_start_date%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_type_groupings
     WHERE itg_inv_type = pi_asset_type
       AND itg_parent_inv_type = pi_parent_asset_type
       AND itg_start_date = pi_start_date;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END asset_grouping_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_format(pi_table_name  user_tables.table_name%TYPE
                        ,pi_col_name    VARCHAR2
                        ,pi_length      NUMBER    DEFAULT 0
                        ,pi_dec_places  NUMBER    DEFAULT NULL)
  IS
    --
    CURSOR c_format_check (c_col_name all_TAB_COLUMNS.column_name%TYPE, c_tab_name user_tables.table_name%TYPE) 
    IS
    SELECT data_precision
          ,data_scale
          ,NVL (data_precision-data_scale, data_length) data_length_num
          ,data_type
      FROM all_tab_columns 
     WHERE table_name = c_tab_name
       AND column_name = c_col_name
       AND owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER'); 
    
    lv_data_precision  user_tab_columns.data_precision%TYPE;
    lv_data_scale      user_tab_columns.data_scale%TYPE;
    lv_data_length_num NUMBER;
    lv_data_type       VARCHAR(20);
    lv_table_name      user_tables.table_name%TYPE := NVL(pi_table_name,'NM_INV_ITEMS_ALL');
    --
  BEGIN
    --
     OPEN c_format_check(pi_col_name, lv_table_name);
    FETCH c_format_check 
     INTO lv_data_precision 
         ,lv_data_scale
         ,lv_data_length_num
         ,lv_data_type;
    CLOSE c_format_check;
    --
    IF  lv_data_precision IS NULL
     AND lv_data_scale IS NULL
     AND NVL(pi_dec_places,0) > 0
      THEN
        IF  pi_dec_places >  pi_length
         THEN	
           hig.raise_ner(pi_appl               => 'NET'
                        ,pi_id                 => 29
                        ,pi_supplementary_info => 'Decimal Places ' || pi_dec_places || ' is greater than column decimal places ' || lv_data_scale );
        END IF;                   
    ELSE
      IF lv_data_type = 'DATE' 
       AND pi_length <> lv_data_length_num 
        THEN
          hig.raise_ner(pi_appl               => 'NET'
                       ,pi_id                 => 29
                       ,pi_supplementary_info => 'Date lengths are not editable.');    	
      END IF;
      --
      IF NVL(pi_length,0) > lv_data_length_num
       THEN
         hig.raise_ner(pi_appl               => 'NET'
                      ,pi_id                 => 29
                      ,pi_supplementary_info => 'Length ' || pi_length || ' is greater than column length ' || lv_data_length_num); 
      END IF;
      -- 
      IF (pi_dec_places IS NOT NULL 
       AND (pi_dec_places > 0 
       OR lv_data_type <> 'NUMBER'))
       AND (lv_data_scale IS NULL OR lv_data_scale = 0) 
        THEN 
          hig.raise_ner(pi_appl               => 'NET'
                       ,pi_id                 => 29
                       ,pi_supplementary_info => 'Decimal Places are not supported with this attribute ');   
      END IF;                                
      --
      IF lv_data_scale IS NOT NULL 
       AND NVL(pi_dec_places,0) > lv_data_scale 
        THEN
          hig.raise_ner(pi_appl               => 'NET'
                       ,pi_id                 => 29
                       ,pi_supplementary_info => 'Decimal Places ' || pi_dec_places || ' is greater than column decimal places ' || lv_data_scale);      
      END IF;
    END IF;
    --
  END check_format;    

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION col_name_exists(pi_asset_type           IN     nm_inv_type_groupings_all.itg_inv_type%TYPE
                          ,pi_col_name             IN     all_tab_columns.column_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM all_tab_columns
     WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
       AND table_name = 'NM_INV_ITEMS'
       AND nm3inv.is_column_allowable_for_flex(column_id) = nm3type.get_true
       AND column_name = pi_col_name
       AND column_name NOT IN (SELECT ita_attrib_name
    			                       FROM nm_inv_type_attribs
    			                      WHERE ita_inv_type = pi_asset_type
                                  AND column_name = ita_attrib_name) 
       AND column_name NOT IN ('IIT_ANGLE_TXT', 'IIT_CLASS_TXT', 'IIT_COLOUR_TXT', 'IIT_COORD_FLAG', 
                               'IIT_END_DATE', 'IIT_INV_OWNERSHIP', 'IIT_LCO_LAMP_CONFIG_ID', 'IIT_MATERIAL_TXT', 
                               'IIT_METHOD_TXT', 'IIT_OFFSET', 'IIT_OPTIONS_TXT', 'IIT_OUN_ORG_ID_ELEC_BOARD', 
                               'IIT_OWNER_TXT', 'IIT_PROV_FLAG', 'IIT_REV_BY', 'IIT_REV_DATE', 'IIT_TYPE_TXT', 
                               'IIT_XTRA_DOMAIN_TXT_1');
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END col_name_exists;  

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION tab_name_exists(pi_tab_name IN all_tab_columns.column_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM all_objects
     WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
       AND object_type IN ('TABLE','VIEW')
       AND object_name NOT LIKE 'MDRT%$'
       AND object_name NOT LIKE 'BIN$%'
       AND object_name = pi_tab_name;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
    --
  END tab_name_exists;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domains(po_message_severity OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT  sys_refcursor
                             ,po_cursor           OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT id_domain          asset_domain
          ,id_title           title
          ,id_start_date      start_date
          ,id_end_date        end_date
          ,id_datatype        datatype
          ,id_date_created    created_date
          ,id_date_modified   modified_date
          ,id_modified_by     modified_by
          ,id_created_by      created_by
      FROM nm_inv_domains_all
     ORDER BY id_domain; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domain(pi_asset_domain        IN      nm_inv_domains_all.id_domain%TYPE
                            ,po_message_severity        OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor          OUT sys_refcursor
                            ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT id_domain          asset_domain
          ,id_title           title
          ,id_start_date      start_date
          ,id_end_date        end_date
          ,id_datatype        datatype
          ,id_date_created    created_date
          ,id_date_modified   modified_date
          ,id_modified_by     modified_by
          ,id_created_by      created_by
      FROM nm_inv_domains_all 
      WHERE id_domain = pi_asset_domain;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domain;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_domains(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT id_domain          asset_domain
                                                    ,id_title           title
                                                    ,id_start_date      start_date
                                                    ,id_end_date        end_date
                                                    ,id_datatype        datatype
                                                    ,id_date_created    created_date
                                                    ,id_date_modified   modified_date
                                                    ,id_modified_by     modified_by
                                                    ,id_created_by      created_by
                                              FROM nm_inv_domains_all ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  asset_domain'
                                                  ||',title'
                                                  ||',start_date'
                                                  ||',end_date'
                                                  ||',datatype'
                                                  ||',created_date'
                                                  ||',modified_date'
                                                  ||',modified_by'
                                                  ||',created_by'                                               
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
      awlrs_util.add_column_data(pi_cursor_col => 'asset_domain'
                                ,pi_query_col  => 'id_domain'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'title'
                                ,pi_query_col  => 'id_title'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'id_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'id_end_date'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'datatype'
                                ,pi_query_col  => 'id_datatype'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'created_date'
                                ,pi_query_col  => 'id_date_created'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'modified_date'
                                ,pi_query_col  => 'id_date_modified'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'modified_by'
                                ,pi_query_col  => 'id_modified_by'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'created_by'
                                ,pi_query_col  => 'id_created_by'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'id_domain')||') a)'
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
  END get_paged_asset_domains;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_visual_attributes(po_message_severity       OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor         OUT  sys_refcursor
                                 ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nva_id
            ,nva_descr
        FROM nm_visual_attributes
       ORDER BY nva_descr; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_visual_attributes;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domain_types(pi_asset_domain        IN      nm_inv_type_attribs_all.ita_id_domain%TYPE
                                  ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor         OUT  sys_refcursor
                                  ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ita_inv_type    inv_type
            ,ita_attrib_name attrib_name
        FROM nm_inv_type_attribs_all
       WHERE ita_id_domain = pi_asset_domain
       ORDER BY ita_inv_type; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domain_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domain_type(pi_asset_domain        IN      nm_inv_domains_all.id_domain%TYPE
                                 ,pi_inv_type            IN      nm_inv_type_attribs_all.ita_inv_type%TYPE
                                 ,pi_attrib_name         IN      nm_inv_type_attribs_all.ita_attrib_name%TYPE
                                 ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor          OUT sys_refcursor
                                 ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ita_inv_type    inv_type
            ,ita_attrib_name attrib_name
        FROM nm_inv_type_attribs_all
       WHERE ita_id_domain = pi_asset_domain
         AND ita_inv_type   = pi_inv_type
         AND ita_attrib_name = pi_attrib_name;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domain_type;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_domain_types(pi_asset_domain         IN     nm_inv_type_attribs_all.ita_id_domain%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT ita_inv_type    inv_type
                                                    ,ita_attrib_name attrib_name
                                                FROM nm_inv_type_attribs_all
                                               WHERE ita_id_domain = :pi_asset_domain';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  inv_type'
                                                  ||',attrib_name'                                             
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
      awlrs_util.add_column_data(pi_cursor_col => 'inv_type'
                                ,pi_query_col  => 'ita_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'attrib_name'
                                ,pi_query_col  => 'ita_attrib_name'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ita_inv_type')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_domain
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_domain
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
  END get_paged_asset_domain_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domain_values(pi_asset_domain        IN      nm_inv_attri_lookup_all.ial_domain%TYPE
                                   ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor         OUT  sys_refcursor
                                   ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ial_domain         asset_domain
            ,ial_value          asset_domain_value
            ,ial_dtp_code       dtp_code
            ,ial_meaning        meaning
            ,ial_start_date     start_date
            ,ial_end_date       end_date
            ,ial_seq            seq
            ,ial_nva_id         nva_id
            ,ial_date_created   date_created
            ,ial_date_modified  date_modified
            ,ial_modified_by    modified_by
            ,ial_created_by     created_by
        FROM nm_inv_attri_lookup_all
       WHERE ial_domain = pi_asset_domain
       ORDER BY ial_value; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domain_values;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domain_value(pi_asset_domain        IN      nm_inv_attri_lookup_all.ial_domain%TYPE
                                  ,pi_asset_domain_value  IN      nm_inv_attri_lookup_all.ial_value%TYPE
                                  ,pi_start_date          IN      nm_inv_attri_lookup_all.ial_start_date%TYPE
                                  ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor          OUT sys_refcursor
                                  ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ial_domain         asset_domain
            ,ial_value          asset_domain_value
            ,ial_dtp_code       dtp_code
            ,ial_meaning        meaning
            ,ial_start_date     start_date
            ,ial_end_date       end_date
            ,ial_seq            seq
            ,ial_nva_id         nva_id
            ,ial_date_created   date_created
            ,ial_date_modified  date_modified
            ,ial_modified_by    modified_by
            ,ial_created_by     created_by
        FROM nm_inv_attri_lookup_all
       WHERE ial_domain = pi_asset_domain
         AND ial_value = pi_asset_domain_value
         AND ial_start_date = pi_start_date
       ORDER BY ial_value;   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domain_value;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_domain_values(pi_asset_domain         IN     nm_inv_attri_lookup_all.ial_domain%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT ial_domain         asset_domain
                                                    ,ial_value          asset_domain_value
                                                    ,ial_dtp_code       dtp_code
                                                    ,ial_meaning        meaning
                                                    ,ial_start_date     start_date
                                                    ,ial_end_date       end_date
                                                    ,ial_seq            seq
                                                    ,ial_nva_id         nva_id
                                                    ,ial_date_created   date_created
                                                    ,ial_date_modified  date_modified
                                                    ,ial_modified_by    modified_by
                                                    ,ial_created_by     created_by
                                                FROM nm_inv_attri_lookup_all
                                               WHERE ial_domain = :pi_asset_domain';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  asset_domain'
                                                  ||',asset_domain_value'
                                                  ||',dtp_code'
                                                  ||',meaning'
                                                  ||',start_date'
                                                  ||',end_date'
                                                  ||',seq'
                                                  ||',nva_id'
                                                  ||',date_created'
                                                  ||',date_modified'
                                                  ||',modified_by'
                                                  ||',created_by'
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
      awlrs_util.add_column_data(pi_cursor_col => 'asset_domain'
                                ,pi_query_col  => 'ial_domain'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'asset_domain_value'
                                ,pi_query_col  => 'ial_value'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'dtp_code'
                                ,pi_query_col  => 'ial_dtp_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'meaning'
                                ,pi_query_col  => 'ial_meaning'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'ial_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'ial_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);                                
      --
      awlrs_util.add_column_data(pi_cursor_col => 'seq'
                                ,pi_query_col  => 'ial_seq'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'nva_id'
                                ,pi_query_col  => 'ial_nva_id'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'date_created'
                                ,pi_query_col  => 'ial_date_created'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'date_modified'
                                ,pi_query_col  => 'ial_date_modified'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'modified_by'
                                ,pi_query_col  => 'ial_modified_by'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'created_by'
                                ,pi_query_col  => 'ial_created_by'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ial_value')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_domain
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_domain
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
  END get_paged_asset_domain_values;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_network_types(po_message_severity       OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor         OUT  sys_refcursor
                                 ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nt_type, nt_descr
        FROM nm_types
       WHERE nt_linear = 'Y'
         AND EXISTS (SELECT 1 
                       FROM nm_type_subclass
                      WHERE nsc_nw_type = nt_type)
       ORDER BY nt_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_network_types;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_inv_types(pi_nw_type            IN       nm_xsp_restraints.xsr_nw_type%TYPE
                             ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor         OUT  sys_refcursor
                             ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    nm3ctx.set_context('XSP_NW_TYPE', pi_nw_type);
    --
    OPEN po_cursor FOR
      SELECT nxr_inv_type, 
             nxr_descr 
        FROM nm_xsp_related_inv_types 
       ORDER BY nxr_screen_seq, nxr_inv_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_inv_types;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_inv_types(po_message_severity       OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor         OUT  sys_refcursor
                             ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nit_inv_type
            ,nit_descr
            ,nit_pnt_or_cont
        FROM nm_inv_types
       WHERE nit_x_sect_allow_flag = 'Y';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_inv_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_restraint(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                             ,pi_inv_code            IN      nm_xsp_restraints.xsr_ity_inv_code%TYPE
                             ,pi_sub_class           IN      nm_xsp_restraints.xsr_scl_class%TYPE
                             ,pi_xsp                 IN      nm_xsp_restraints.xsr_x_sect_value%TYPE
                             ,po_message_severity        OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor          OUT sys_refcursor
                             ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT xsr_nw_type       nw_type
            ,xsr_ity_inv_code  inv_code
            ,xsr_scl_class     sub_class
            ,nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class) nsc_descr
            ,xsr_x_sect_value  xsp_value
            ,xsr_descr         description
            ,nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code) inv_p_or_c
        FROM nm_xsp_restraints
       WHERE xsr_nw_type = pi_nw_type
         AND xsr_ity_inv_code = pi_inv_code
         AND xsr_scl_class = pi_sub_class
         AND xsr_x_sect_value = pi_xsp
       ORDER BY xsr_nw_type, xsr_scl_class, xsr_x_sect_value;   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_restraint;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_restraints(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                              ,pi_inv_code            IN      nm_xsp_restraints.xsr_ity_inv_code%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT xsr_nw_type       nw_type
            ,xsr_ity_inv_code  inv_code
            ,xsr_scl_class     sub_class
            ,nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class) nsc_descr
            ,xsr_x_sect_value  xsp_value
            ,xsr_descr         description
            ,nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code) inv_p_or_c
        FROM nm_xsp_restraints
       WHERE xsr_nw_type = pi_nw_type
         AND xsr_ity_inv_code = pi_inv_code
       ORDER BY xsr_nw_type, xsr_scl_class, xsr_x_sect_value;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_restraints;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_xsp_restraints(pi_nw_type              IN     nm_xsp_restraints.xsr_nw_type%TYPE
                                    ,pi_inv_code             IN     nm_xsp_restraints.xsr_ity_inv_code%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT xsr_nw_type      nw_type
                                                    ,xsr_ity_inv_code inv_code
                                                    ,xsr_scl_class    sub_class
                                                    ,nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class) nsc_descr
                                                    ,xsr_x_sect_value xsp_value
                                                    ,xsr_descr        description
                                                    ,nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code) inv_p_or_c
                                                FROM nm_xsp_restraints
                                               WHERE xsr_nw_type = :pi_nw_type
                                                 AND xsr_ity_inv_code = :pi_inv_code';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  nw_type'
                                                  ||',inv_code'
                                                  ||',sub_class'
                                                  ||',nsc_descr'                                                  
                                                  ||',xsp_value'
                                                  ||',description'
                                                  ||',inv_p_or_c'
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
      awlrs_util.add_column_data(pi_cursor_col => 'nw_type'
                                ,pi_query_col  => 'xsr_nw_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'inv_code'
                                ,pi_query_col  => 'xsr_ity_inv_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'sub_class'
                                ,pi_query_col  => 'xsr_scl_class'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nsc_descr'
                                ,pi_query_col  => 'nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'xsp_value'
                                ,pi_query_col  => 'xsr_x_sect_value'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'xsr_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'inv_p_or_c'
                                ,pi_query_col  => 'nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code)'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'xsr_nw_type, xsr_scl_class, xsr_x_sect_value')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_nw_type
             ,pi_inv_code
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_nw_type
             ,pi_inv_code
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
  END get_paged_xsp_restraints;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_restraints(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                              ,pi_sub_class           IN      nm_xsp_restraints.xsr_scl_class%TYPE
                              ,pi_xsp                 IN      nm_xsp_restraints.xsr_x_sect_value%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT xsr_nw_type       nw_type
            ,xsr_ity_inv_code  inv_code
            ,xsr_scl_class     sub_class
            ,nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class) nsc_descr
            ,xsr_x_sect_value  xsp_value
            ,xsr_descr         description
            ,nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code) inv_p_or_c
        FROM nm_xsp_restraints
       WHERE xsr_nw_type = pi_nw_type
         AND xsr_scl_class = pi_sub_class
         AND xsr_x_sect_value = pi_xsp
       ORDER BY xsr_nw_type, xsr_scl_class, xsr_x_sect_value;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_restraints;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_xsp_restraints(pi_nw_type              IN     nm_xsp_restraints.xsr_nw_type%TYPE
                                    ,pi_sub_class            IN     nm_xsp_restraints.xsr_scl_class%TYPE
                                    ,pi_xsp                  IN     nm_xsp_restraints.xsr_x_sect_value%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT xsr_nw_type      nw_type
                                                    ,xsr_ity_inv_code inv_code
                                                    ,xsr_scl_class    sub_class
                                                    ,nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class) nsc_descr
                                                    ,xsr_x_sect_value xsp_value
                                                    ,xsr_descr        description
                                                    ,nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code) inv_p_or_c
                                                FROM nm_xsp_restraints
                                               WHERE xsr_nw_type = :pi_nw_type
                                                 AND xsr_scl_class = :pi_sub_class
                                                 AND xsr_x_sect_value = :pi_xsp';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  nw_type'
                                                  ||',inv_code'
                                                  ||',sub_class'
                                                  ||',nsc_descr'                                                  
                                                  ||',xsp_value'
                                                  ||',description'
                                                  ||',inv_p_or_c'
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
      awlrs_util.add_column_data(pi_cursor_col => 'nw_type'
                                ,pi_query_col  => 'xsr_nw_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'inv_code'
                                ,pi_query_col  => 'xsr_ity_inv_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'sub_class'
                                ,pi_query_col  => 'xsr_scl_class'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'inv_p_or_c'
                                ,pi_query_col  => 'nm3net.get_nsc_descr(xsr_nw_type, xsr_scl_class)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'xsp_value'
                                ,pi_query_col  => 'xsr_x_sect_value'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'xsr_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nm3inv.get_nit_pnt_or_cont(xsr_ity_inv_code)'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'xsr_nw_type, xsr_scl_class, xsr_x_sect_value')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_nw_type
             ,pi_sub_class
             ,pi_xsp
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_nw_type
             ,pi_sub_class
             ,pi_xsp
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
  END get_paged_xsp_restraints;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nw_xsp(pi_nw_type             IN      nm_nw_xsp.nwx_nw_type%TYPE
                      ,pi_xsp                 IN      nm_nw_xsp.nwx_x_sect%TYPE
                      ,pi_sub_class           IN      nm_nw_xsp.nwx_nsc_sub_class%TYPE
                      ,po_message_severity        OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor          OUT sys_refcursor
                      ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nwx_nw_type nw_type
            ,nm3net.get_nt_descr(nwx_nw_type) nw_type_descr
            ,nwx_x_sect xsp
            ,nwx_nsc_sub_class sub_class
            ,nm3net.get_nsc_descr(nwx_nw_type, nwx_nsc_sub_class) nsc_descr
            ,nwx_descr description
            ,nwx_seq seq
            ,nwx_offset offset
        FROM nm_nw_xsp
       WHERE nwx_nw_type = pi_nw_type
         AND nwx_x_sect = pi_xsp
         AND nwx_nsc_sub_class = pi_sub_class
       ORDER BY nwx_nw_type, nwx_nsc_sub_class, nwx_x_sect; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nw_xsp;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nw_xsps(po_message_severity        OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor          OUT sys_refcursor
                       ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nwx_nw_type nw_type
            ,nm3net.get_nt_descr(nwx_nw_type) nw_type_descr
            ,nwx_x_sect xsp
            ,nwx_nsc_sub_class sub_class
            ,nm3net.get_nsc_descr(nwx_nw_type, nwx_nsc_sub_class) nsc_descr
            ,nwx_descr description
            ,nwx_seq seq
            ,nwx_offset offset
        FROM nm_nw_xsp
       ORDER BY nwx_nw_type, nwx_nsc_sub_class, nwx_x_sect; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nw_xsps;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nw_xsps(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nwx_nw_type       nw_type
                                                    ,nm3net.get_nt_descr(nwx_nw_type) nw_type_descr
                                                    ,nwx_x_sect        xsp
                                                    ,nwx_nsc_sub_class sub_class
                                                    ,nm3net.get_nsc_descr(nwx_nw_type, nwx_nsc_sub_class) nsc_descr
                                                    ,nwx_descr         description
                                                    ,nwx_seq           seq
                                                    ,nwx_offset        offset
                                                FROM nm_nw_xsp';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  nw_type'
                                                  ||',nw_type_descr'
                                                  ||',xsp'
                                                  ||',sub_class'
                                                  ||',nsc_descr'
                                                  ||',description'
                                                  ||',seq'
                                                  ||',offset'
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
      awlrs_util.add_column_data(pi_cursor_col => 'nw_type'
                                ,pi_query_col  => 'nwx_nw_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nw_type_descr'
                                ,pi_query_col  => 'nm3net.get_nt_descr(nwx_nw_type)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'xsp'
                                ,pi_query_col  => 'nwx_x_sect'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'sub_class'
                                ,pi_query_col  => 'nwx_nsc_sub_class'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nsc_descr'
                                ,pi_query_col  => 'nm3net.get_nsc_descr(nwx_nw_type, nwx_nsc_sub_class)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nwx_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'seq'
                                ,pi_query_col  => 'nwx_seq'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'offset'
                                ,pi_query_col  => 'nwx_offset'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nwx_nw_type, nwx_nsc_sub_class, nwx_x_sect')||') a)'
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
  END get_paged_nw_xsps;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sub_class(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                         ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor         OUT  sys_refcursor
                         ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nsc_sub_class
            ,nsc_descr
       FROM nm_type_subclass
      WHERE nsc_nw_type = pi_nw_type
      ORDER BY nsc_sub_class;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_sub_class;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsps(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                    ,pi_sub_class           IN      nm_xsp_restraints.xsr_scl_class%TYPE
                    ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                    ,po_message_cursor         OUT  sys_refcursor
                    ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT DISTINCT nwx_x_sect
            ,nwx_descr
            ,nwx_seq
       FROM nm_xsp
      WHERE nwx_nw_type = NVL(pi_nw_type, nwx_nw_type)
        AND nwx_nsc_sub_class = NVL(pi_sub_class, nwx_nsc_sub_class)
      ORDER BY nwx_seq, nwx_x_sect;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsps;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsp_reversal(pi_nw_type             IN      nm_xsp_reversal.xrv_nw_type%TYPE
                            ,pi_xsp                 IN      nm_xsp_reversal.xrv_old_xsp%TYPE
                            ,pi_sub_class           IN      nm_xsp_reversal.xrv_old_sub_class%TYPE
                            ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor         OUT  sys_refcursor
                            ,po_cursor                 OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT xrv_new_sub_class sub_class
           ,xrv_new_xsp       new_xsp
           ,nm3net.get_nsc_descr(xrv_nw_type, xrv_new_sub_class) sub_class_desc
           ,nm3net.get_xsp_descr(xrv_nw_type, xrv_new_sub_class, xrv_new_xsp) xsp_desc
           ,nm3net.get_xsp_descr(xrv_nw_type, xrv_old_sub_class, xrv_default_xsp) default_xsp_desc
       FROM nm_xsp_reversal
      WHERE xrv_nw_type = pi_nw_type
        AND xrv_old_xsp = pi_xsp
        AND xrv_old_sub_class = pi_sub_class;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_xsp_reversal;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_type(pi_asset_type          IN      nm_inv_types_all.nit_inv_type%TYPE
                          ,po_message_severity        OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor          OUT sys_refcursor
                          ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nit_inv_type            asset_type
            ,nit_pnt_or_cont         p_or_c
            ,nit_x_sect_allow_flag   xsp_allowed
            ,nit_elec_drain_carr     elec_drain_carr
            ,nit_contiguous          contiguous
            ,nit_replaceable         replaceable
            ,nit_exclusive           exclusive_
            ,nit_category            category_
            ,nit_descr               description
            ,nit_linear              linear_
            ,nit_use_xy              use_xy
            ,nit_multiple_allowed    multiple_allowed
            ,nit_end_loc_only        end_location_only
            ,nit_screen_seq          screen_seq
            ,nit_view_name           view_name
            ,nit_start_date          start_date
            ,nit_end_date            end_date
            ,nit_short_descr         short_description
            ,nit_flex_item_flag      flex_item_flag 
            ,nit_table_name          table_name
            ,nit_lr_ne_column_name   lr_ne_column_name
            ,nit_lr_st_chain         lr_st_chain
            ,nit_lr_end_chain        lr_end_chain
            ,nit_admin_type          admin_type
            ,nit_icon_name           icon_name
            ,nit_top                 top_in_hierarchy
            ,nit_foreign_pk_column   primary_key_column
            ,nit_update_allowed      update_allowed
            ,nit_notes               notes
        FROM nm_inv_types_all
       WHERE nit_inv_type = pi_asset_type;   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_type;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_types(po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nit_inv_type            asset_type
            ,nit_pnt_or_cont         p_or_c
            ,nit_x_sect_allow_flag   xsp_allowed
            ,nit_elec_drain_carr     elec_drain_carr
            ,nit_contiguous          contiguous
            ,nit_replaceable         replaceable
            ,nit_exclusive           exclusive_
            ,nit_category            category_
            ,nit_descr               description
            ,nit_linear              linear_
            ,nit_use_xy              use_xy
            ,nit_multiple_allowed    multiple_allowed
            ,nit_end_loc_only        end_location_only
            ,nit_screen_seq          screen_seq
            ,nit_view_name           view_name
            ,nit_start_date          start_date
            ,nit_end_date            end_date
            ,nit_short_descr         short_description
            ,nit_flex_item_flag      flex_item_flag 
            ,nit_table_name          table_name
            ,nit_lr_ne_column_name   lr_ne_column_name
            ,nit_lr_st_chain         lr_st_chain
            ,nit_lr_end_chain        lr_end_chain
            ,nit_admin_type          admin_type
            ,nit_icon_name           icon_name
            ,nit_top                 top_in_hierarchy
            ,nit_foreign_pk_column   primary_key_column
            ,nit_update_allowed      update_allowed
            ,nit_notes               notes
        FROM nm_inv_types_all
       ORDER BY nit_inv_type;   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_types;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nit_inv_type            asset_type
                                                    ,nit_pnt_or_cont         p_or_c
                                                    ,nit_x_sect_allow_flag   xsp_allowed
                                                    ,nit_elec_drain_carr     elec_drain_carr
                                                    ,nit_contiguous          contiguous
                                                    ,nit_replaceable         replaceable
                                                    ,nit_exclusive           exclusive_
                                                    ,nit_category            category_
                                                    ,nit_descr               description
                                                    ,nit_linear              linear_
                                                    ,nit_use_xy              use_xy
                                                    ,nit_multiple_allowed    multiple_allowed
                                                    ,nit_end_loc_only        end_location_only
                                                    ,nit_screen_seq          screen_seq
                                                    ,nit_view_name           view_name
                                                    ,nit_start_date          start_date
                                                    ,nit_end_date            end_date
                                                    ,nit_short_descr         short_description
                                                    ,nit_flex_item_flag      flex_item_flag 
                                                    ,nit_table_name          table_name
                                                    ,nit_lr_ne_column_name   lr_ne_column_name
                                                    ,nit_lr_st_chain         lr_st_chain
                                                    ,nit_lr_end_chain        lr_end_chain
                                                    ,nit_admin_type          admin_type
                                                    ,nit_icon_name           icon_name
                                                    ,nit_top                 top_in_hierarchy
                                                    ,nit_foreign_pk_column   primary_key_column
                                                    ,nit_update_allowed      update_allowed
                                                    ,nit_notes               notes
                                                FROM nm_inv_types_all';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  asset_type'
                                                  ||',p_or_c'
                                                  ||',xsp_allowed'
                                                  ||',elec_drain_carr'
                                                  ||',contiguous'
                                                  ||',replaceable'
                                                  ||',exclusive_'
                                                  ||',category_'
                                                  ||',description'
                                                  ||',linear_'
                                                  ||',use_xy'
                                                  ||',multiple_allowed'
                                                  ||',end_location_only'
                                                  ||',screen_seq'
                                                  ||',view_name'
                                                  ||',start_date'
                                                  ||',end_date'
                                                  ||',short_description'
                                                  ||',flex_item_flag'
                                                  ||',table_name'
                                                  ||',lr_ne_column_name'
                                                  ||',lr_st_chain'
                                                  ||',lr_end_chain'
                                                  ||',admin_type'
                                                  ||',icon_name'
                                                  ||',top_in_hierarchy'
                                                  ||',primary_key_column'
                                                  ||',update_allowed'
                                                  ||',notes'                                                                          
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
      awlrs_util.add_column_data(pi_cursor_col => 'asset_type'
                                ,pi_query_col  => 'nit_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'p_or_c'
                                ,pi_query_col  => 'nit_pnt_or_cont'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'xsp_allowed'
                                ,pi_query_col  => 'nit_x_sect_allow_flag'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'elec_drain_carr'
                                ,pi_query_col  => 'nit_elec_drain_carr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'contiguous'
                                ,pi_query_col  => 'nit_contiguous'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'replaceable'
                                ,pi_query_col  => 'nit_replaceable'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'exclusive_'
                                ,pi_query_col  => 'nit_exclusive'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);                                
      --
      awlrs_util.add_column_data(pi_cursor_col => 'category_'
                                ,pi_query_col  => 'nit_category'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nit_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'linear_'
                                ,pi_query_col  => 'nit_linear'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'use_xy'
                                ,pi_query_col  => 'nit_use_xy'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'multiple_allowed'
                                ,pi_query_col  => 'nit_multiple_allowed'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'end_location_only'
                                ,pi_query_col  => 'nit_end_loc_only'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'screen_seq'
                                ,pi_query_col  => 'nit_screen_seq'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'view_name'
                                ,pi_query_col  => 'nit_view_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'nit_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'nit_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'short_description'
                                ,pi_query_col  => 'nit_short_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'flex_item_flag'
                                ,pi_query_col  => 'nit_flex_item_flag'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'table_name'
                                ,pi_query_col  => 'nit_table_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'lr_ne_column_name'
                                ,pi_query_col  => 'nit_lr_ne_column_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'lr_st_chain'
                                ,pi_query_col  => 'nit_lr_st_chain'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'lr_end_chain'
                                ,pi_query_col  => 'nit_lr_end_chain'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'admin_type'
                                ,pi_query_col  => 'nit_admin_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'icon_name'
                                ,pi_query_col  => 'nit_icon_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'top_in_hierarchy'
                                ,pi_query_col  => 'nit_top'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'primary_key_column'
                                ,pi_query_col  => 'nit_foreign_pk_column'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'update_allowed'
                                ,pi_query_col  => 'nit_update_allowed'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'notes'
                                ,pi_query_col  => 'nit_notes'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
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
                                 ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nit_inv_type')||') a)'
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
  END get_paged_asset_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_attribute(pi_asset_type          IN      nm_inv_type_attribs_all.ita_inv_type%TYPE
                               ,pi_asset_attribute     IN      nm_inv_type_attribs_all.ita_attrib_name%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ita_inv_type              asset_type
            ,ita_attrib_name           attribute_name
            ,ita_dynamic_attrib        dynamic_attrib
            ,ita_disp_seq_no           display_sequence
            ,ita_mandatory_yn          mandatory_yn
            ,ita_format                type_format
            ,ita_fld_length            field_length
            ,ita_dec_places            decimal_places
            ,ita_scrn_text             screen_text
            ,ita_id_domain             asset_domain
            ,ita_validate_yn           validate_yn
            ,ita_dtp_code              dtp_code
            ,ita_max                   max_value
            ,ita_min                   min_value
            ,ita_view_attri            view_attribute
            ,ita_view_col_name         column_name
            ,ita_start_date            start_date
            ,ita_end_date              end_date
            ,ita_queryable             queryable_yn
            ,ita_ukpms_param_no        ukpms_param_no
            ,ita_units                 unit_id
            ,nm3inv.get_units(ita_units) units
            ,ita_format_mask           format_mask
            ,ita_exclusive             exclusive_yn
            ,ita_keep_history_yn       keep_history_yn
            ,ita_query                 query_
            ,ita_displayed             displayed_yn
            ,ita_disp_width            display_width
            ,ita_inspectable           inspectable_yn
            ,ita_case                  case_
        FROM nm_inv_type_attribs_all
       WHERE ita_inv_type = pi_asset_type
         AND ita_attrib_name = pi_asset_attribute
       ORDER BY ita_disp_seq_no, ita_attrib_name
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
  END get_asset_attribute;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_attributes(pi_asset_type          IN      nm_inv_type_attribs_all.ita_inv_type%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT ita_inv_type              asset_type
            ,ita_attrib_name           attribute_name
            ,ita_dynamic_attrib        dynamic_attrib
            ,ita_disp_seq_no           display_sequence
            ,ita_mandatory_yn          mandatory_yn
            ,ita_format                type_format
            ,ita_fld_length            field_length
            ,ita_dec_places            decimal_places
            ,ita_scrn_text             screen_text
            ,ita_id_domain             asset_domain
            ,ita_validate_yn           validate_yn
            ,ita_dtp_code              dtp_code
            ,ita_max                   max_value
            ,ita_min                   min_value
            ,ita_view_attri            view_attribute
            ,ita_view_col_name         column_name
            ,ita_start_date            start_date
            ,ita_end_date              end_date
            ,ita_queryable             queryable_yn
            ,ita_ukpms_param_no        ukpms_param_no
            ,ita_units                 unit_id
            ,nm3inv.get_units(ita_units) units
            ,ita_format_mask           format_mask
            ,ita_exclusive             exclusive_yn
            ,ita_keep_history_yn       keep_history_yn
            ,ita_query                 query_
            ,ita_displayed             displayed_yn
            ,ita_disp_width            display_width
            ,ita_inspectable           inspectable_yn
            ,ita_case                  case_
        FROM nm_inv_type_attribs_all
       WHERE ita_inv_type = pi_asset_type
       ORDER BY ita_disp_seq_no, ita_attrib_name; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_attributes;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_attributes(pi_asset_type          IN      nm_inv_type_attribs_all.ita_inv_type%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT ita_inv_type              asset_type
                                                    ,ita_attrib_name           attribute_name
                                                    ,ita_dynamic_attrib        dynamic_attrib
                                                    ,ita_disp_seq_no           display_sequence
                                                    ,ita_mandatory_yn          mandatory_yn
                                                    ,ita_format                type_format
                                                    ,ita_fld_length            field_length
                                                    ,ita_dec_places            decimal_places
                                                    ,ita_scrn_text             screen_text
                                                    ,ita_id_domain             asset_domain
                                                    ,ita_validate_yn           validate_yn
                                                    ,ita_dtp_code              dtp_code
                                                    ,ita_max                   max_value
                                                    ,ita_min                   min_value
                                                    ,ita_view_attri            view_attribute
                                                    ,ita_view_col_name         column_name
                                                    ,ita_start_date            start_date
                                                    ,ita_end_date              end_date
                                                    ,ita_queryable             queryable_yn
                                                    ,ita_ukpms_param_no        ukpms_param_no
                                                    ,ita_units                 unit_id
                                                    ,nm3inv.get_units(ita_units) units
                                                    ,ita_format_mask           format_mask
                                                    ,ita_exclusive             exclusive_yn
                                                    ,ita_keep_history_yn       keep_history_yn
                                                    ,ita_query                 query_
                                                    ,ita_displayed             displayed_yn
                                                    ,ita_disp_width            display_width
                                                    ,ita_inspectable           inspectable_yn
                                                    ,ita_case                  case_
                                                FROM  nm_inv_type_attribs_all
                                               WHERE ita_inv_type = :pi_asset_type';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  asset_type'
                                                  ||',attribute_name'
                                                  ||',dynamic_attrib'
                                                  ||',display_sequence'
                                                  ||',mandatory_yn'
                                                  ||',type_format'
                                                  ||',field_length'
                                                  ||',decimal_places'
                                                  ||',screen_text'
                                                  ||',asset_domain'
                                                  ||',validate_yn'
                                                  ||',dtp_code'
                                                  ||',max_value'
                                                  ||',min_value'
                                                  ||',view_attribute'
                                                  ||',column_name'
                                                  ||',start_date'
                                                  ||',end_date'
                                                  ||',queryable_yn'
                                                  ||',ukpms_param_no'
                                                  ||',unit_id'
                                                  ||',units'
                                                  ||',format_mask'
                                                  ||',exclusive_yn'
                                                  ||',keep_history_yn'
                                                  ||',query_'
                                                  ||',displayed_yn'
                                                  ||',display_width'
                                                  ||',inspectable_yn'     
                                                  ||',case_'                                                   
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
      awlrs_util.add_column_data(pi_cursor_col => 'asset_type'
                                ,pi_query_col  => 'ita_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'attribute_name'
                                ,pi_query_col  => 'ita_attrib_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'dynamic_attrib'
                                ,pi_query_col  => 'ita_dynamic_attrib'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'display_sequence'
                                ,pi_query_col  => 'ita_disp_seq_no'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'mandatory_yn'
                                ,pi_query_col  => 'ita_mandatory_yn'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);                                
      --
      awlrs_util.add_column_data(pi_cursor_col => 'type_format'
                                ,pi_query_col  => 'ita_format'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'field_length'
                                ,pi_query_col  => 'ita_fld_length'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'decimal_places'
                                ,pi_query_col  => 'ita_dec_places'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'screen_text'
                                ,pi_query_col  => 'ita_scrn_text'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'asset_domain'
                                ,pi_query_col  => 'ita_id_domain'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'validate_yn'
                                ,pi_query_col  => 'ita_validate_yn'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'dtp_code'
                                ,pi_query_col  => 'ita_dtp_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'max_value'
                                ,pi_query_col  => 'ita_max'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'min_value'
                                ,pi_query_col  => 'ita_min'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'view_attribute'
                                ,pi_query_col  => 'ita_view_attri'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'column_name'
                                ,pi_query_col  => 'ita_view_col_name'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'ita_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'ita_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'queryable_yn'
                                ,pi_query_col  => 'ita_queryable'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'ukpms_param_no'
                                ,pi_query_col  => 'ita_ukpms_param_no'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'unit_id'
                                ,pi_query_col  => 'ita_units'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'units'
                                ,pi_query_col  => 'nm3inv.get_units(ita_units)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'format_mask'
                                ,pi_query_col  => 'ita_format_mask'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'exclusive_yn'
                                ,pi_query_col  => 'ita_exclusive'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'keep_history_yn'
                                ,pi_query_col  => 'ita_keep_history_yn'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
                                      --      
      awlrs_util.add_column_data(pi_cursor_col => 'query_'
                                ,pi_query_col  => 'ita_query'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data); 
      --
      awlrs_util.add_column_data(pi_cursor_col => 'displayed_yn'
                                ,pi_query_col  => 'ita_displayed'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'display_width'
                                ,pi_query_col  => 'ita_disp_width'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'inspectable_yn'
                                ,pi_query_col  => 'ita_inspectable'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);     
      --      
      awlrs_util.add_column_data(pi_cursor_col => 'case_'
                                ,pi_query_col  => 'ita_case'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ita_disp_seq_no, ita_attrib_name')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_type
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_type
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
  END get_paged_asset_attributes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_nw(pi_asset_type          IN      nm_inv_nw_all.nin_nit_inv_code%TYPE
                        ,pi_nw_type             IN      nm_inv_nw_all.nin_nw_type%TYPE
                        ,po_message_severity        OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor          OUT sys_refcursor
                        ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nin_nw_type       nw_type
            ,nin_nit_inv_code  asset_type
            ,nin_loc_mandatory location_mandatory_yn
            ,nm3inv.get_nt_unique(nin_nw_type)  nw_unique
            ,nm3net.get_nt_descr(nin_nw_type)   nw_descr   
            ,nin_start_date    start_date            
            ,nin_end_date      end_date
        FROM nm_inv_nw_all
       WHERE nin_nit_inv_code = pi_asset_type
         AND nin_nw_type = pi_nw_type
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
  END get_asset_nw;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_nws(pi_asset_type          IN      nm_inv_nw_all.nin_nit_inv_code%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nin_nw_type       nw_type
            ,nin_nit_inv_code  asset_type
            ,nin_loc_mandatory location_mandatory_yn
            ,nm3inv.get_nt_unique(nin_nw_type)  nw_unique
            ,nm3net.get_nt_descr(nin_nw_type)   nw_descr   
            ,nin_start_date    start_date            
            ,nin_end_date      end_date            
        FROM nm_inv_nw_all
       WHERE nin_nit_inv_code = pi_asset_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_nws;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_nws(pi_asset_type           IN     nm_inv_nw_all.nin_nit_inv_code%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nin_nw_type       nw_type
                                                    ,nin_nit_inv_code  asset_type
                                                    ,nin_loc_mandatory location_mandatory_yn
                                                    ,nm3inv.get_nt_unique(nin_nw_type)  nw_unique
                                                    ,nm3net.get_nt_descr(nin_nw_type)   nw_descr   
                                                    ,nin_start_date    start_date            
                                                    ,nin_end_date      end_date                                                    
                                                FROM nm_inv_nw_all
                                               WHERE nin_nit_inv_code = :pi_asset_type';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  nw_type'
                                                  ||',asset_type'
                                                  ||',location_mandatory_yn'    
                                                  ||',nw_unique'  
                                                  ||',nw_descr'         
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
      awlrs_util.add_column_data(pi_cursor_col => 'nw_type'
                                ,pi_query_col  => 'nin_nw_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'asset_type'
                                ,pi_query_col  => 'nin_nit_inv_code'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'location_mandatory_yn'
                                ,pi_query_col  => 'nin_loc_mandatory'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nw_unique'
                                ,pi_query_col  => 'nm3inv.get_nt_unique(nin_nw_type)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nw_descr'
                                ,pi_query_col  => 'nm3net.get_nt_descr(nin_nw_type)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);            
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'nin_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);    
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'nin_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nin_nw_type')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_type
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_type
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
  END get_paged_asset_nws;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_type_role(pi_asset_type          IN      nm_inv_type_roles.itr_inv_type%TYPE
                               ,pi_asset_role          IN      nm_inv_type_roles.itr_hro_role%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT itr_inv_type    asset_type
            ,itr_hro_role    asset_role
            ,itr_mode        asset_role_mode
        FROM nm_inv_type_roles
       WHERE itr_inv_type = pi_asset_type
         AND itr_hro_role = pi_asset_role
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
  END get_asset_type_role;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_type_roles(pi_asset_type          IN      nm_inv_type_roles.itr_inv_type%TYPE
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT itr_inv_type    asset_type
            ,itr_hro_role    asset_role
            ,itr_mode        asset_role_mode
        FROM nm_inv_type_roles
       WHERE itr_inv_type = pi_asset_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_type_roles;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_type_roles(pi_asset_type           IN     nm_inv_type_roles.itr_inv_type%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT itr_inv_type    asset_type
                                                    ,itr_hro_role    asset_role
                                                    ,itr_mode        asset_role_mode
                                                FROM nm_inv_type_roles
                                               WHERE itr_inv_type = :pi_asset_type';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  asset_type'
                                                  ||',asset_role'
                                                  ||',asset_role_mode'                                                 
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
      awlrs_util.add_column_data(pi_cursor_col => 'asset_type'
                                ,pi_query_col  => 'itr_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'asset_role'
                                ,pi_query_col  => 'itr_hro_role'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'asset_role_mode'
                                ,pi_query_col  => 'itr_mode'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'itr_hro_role')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_asset_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_asset_type
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
  END get_paged_asset_type_roles;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_grouping(pi_asset_type          IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                              ,pi_parent_asset_type   IN      nm_inv_type_groupings_all.itg_parent_inv_type%TYPE
                              ,pi_start_date          IN      nm_inv_type_groupings_all.itg_start_date%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT itg_inv_type          asset_type
            ,itg_parent_inv_type   parent_asset_type
            ,nm3inv.get_nit_descr(itg_parent_inv_type) parent_asset_descr
            ,itg_mandatory         mandatory_yn      
            ,itg_relation          relation
            ,itg_start_date        start_date
            ,itg_end_date          end_date
        FROM nm_inv_type_groupings_all
       WHERE itg_inv_type = pi_asset_type
         AND itg_parent_inv_type = pi_parent_asset_type
         AND itg_start_date = pi_start_date
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
  END get_asset_grouping;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_groupings(pi_asset_type          IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT itg_inv_type          asset_type
            ,itg_parent_inv_type   parent_asset_type
            ,nm3inv.get_nit_descr(itg_parent_inv_type) parent_asset_descr
            ,itg_mandatory         mandatory_yn      
            ,itg_relation          relation
            ,itg_start_date        start_date
            ,itg_end_date          end_date
        FROM nm_inv_type_groupings_all
       WHERE itg_inv_type = pi_asset_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_groupings;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_asset_groupings(pi_asset_type           IN     nm_inv_type_groupings_all.itg_inv_type%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT itg_inv_type          asset_type
                                                    ,itg_parent_inv_type   parent_asset_type
                                                    ,nm3inv.get_nit_descr(itg_parent_inv_type) parent_asset_descr
                                                    ,itg_mandatory         mandatory_yn      
                                                    ,itg_relation          relation
                                                    ,itg_start_date        start_date
                                                    ,itg_end_date          end_date
                                                FROM nm_inv_type_groupings_all
                                               WHERE itg_inv_type = :pi_asset_type';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  asset_type'
                                                  ||',parent_asset_type'
                                                  ||',parent_asset_descr'
                                                  ||',mandatory_yn'                                                 
                                                  ||',relation'    
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
      awlrs_util.add_column_data(pi_cursor_col => 'asset_type'
                                ,pi_query_col  => 'itg_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'parent_asset_type'
                                ,pi_query_col  => 'itg_parent_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'parent_asset_descr'
                                ,pi_query_col  => 'nm3inv.get_nit_descr(itg_parent_inv_type)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'mandatory_yn'
                                ,pi_query_col  => 'itg_mandatory'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'relation'
                                ,pi_query_col  => 'itg_relation'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);      
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'itg_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);    
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'itg_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'itg_inv_type')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_type
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_asset_type
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
  END get_paged_asset_groupings;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_categories_lov(po_message_severity        OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor          OUT sys_refcursor
                                    ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nic_category
            ,nic_descr
        FROM nm_inv_categories
       ORDER BY nic_category;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_categories_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_ft_names_lov(po_message_severity        OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor          OUT sys_refcursor
                            ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT object_name, object_type
        FROM all_objects
       WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
         AND object_type IN ('TABLE','VIEW')
         AND object_name NOT LIKE 'MDRT%$'
         AND object_name NOT LIKE 'BIN$%'
       ORDER BY object_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_ft_names_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_ft_names_lov(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT object_name, object_type
                                                FROM all_objects
                                               WHERE owner = SYS_CONTEXT(''NM3CORE'',''APPLICATION_OWNER'')
                                                 AND object_type IN (''TABLE'',''VIEW'')
                                                 AND object_name NOT LIKE ''MDRT%$''
                                                 AND object_name NOT LIKE ''BIN$%''';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  object_name'
                                                  ||',object_type'
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
      awlrs_util.add_column_data(pi_cursor_col => 'object_name'
                                ,pi_query_col  => 'object_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'object_type'
                                ,pi_query_col  => 'object_type'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'object_name')||') a)'
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
  END get_paged_ft_names_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_ft_attribute_lov(pi_asset_type           IN     nm_inv_type_groupings_all.itg_inv_type%TYPE
                                ,pi_ft_table             IN     nm_inv_types.nit_table_name%TYPE 
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT sys_refcursor
                                ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT column_name
            ,data_type || '(' || to_char(nvl(data_precision, data_length)) || decode(data_scale, '0' , null, null, null, ',' || to_char(data_scale)) || ')' data_type
						,data_type datatype2
						,NVL(data_precision-data_scale, data_length) data_length_num 
						,decode(data_scale, 0, null, data_scale) decimal_num  
	     FROM all_tab_columns
	    WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
	      AND table_name = pi_ft_table
	      AND column_name NOT IN (SELECT ita_attrib_name 
 	   	                            FROM nm_inv_type_attribs 
	                               WHERE ita_inv_type = pi_asset_type 
	                                 AND column_name = ita_attrib_name)
     ORDER BY column_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_ft_attribute_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_ft_pk_lov(pi_asset_type           IN     nm_inv_type_groupings_all.itg_inv_type%TYPE
                         ,pi_ft_table             IN     nm_inv_types.nit_table_name%TYPE
                         ,pi_nit_category         IN     nm_inv_types.nit_category%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
		  SELECT column_name
            ,data_type || '(' || to_char(nvl(data_precision, data_length)) || decode(data_scale, '0' , null, null, null, ',' || to_char(data_scale)) || ')' data_type
		    	  ,data_type datatype2
		    	  ,NVL(data_precision-data_scale, data_length) data_length_num 
		    	  ,decode(data_scale, 0, null, data_scale) decimal_num 	 
	      FROM all_tab_columns
	     WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
	       AND table_name = pi_ft_table
	       AND (data_type = 'NUMBER' OR pi_nit_category = 'A') 
	       AND  nullable   = 'N'
	     ORDER BY column_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_ft_pk_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_ft_lr_lov(pi_asset_type           IN     nm_inv_type_groupings_all.itg_inv_type%TYPE
                         ,pi_ft_table             IN     nm_inv_types.nit_table_name%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT column_name
            ,data_type || '(' || to_char(nvl(data_precision, data_length)) || decode(data_scale, '0' , null, null, null, ',' || to_char(data_scale)) || ')' data_type
						,data_type datatype2
						,NVL(data_precision-data_scale, data_length) data_length_num 
						,decode(data_scale, 0, null, data_scale) decimal_num 
	     FROM all_tab_columns
	    WHERE owner = SYS_CONTEXT('NM3CORE','APPLICATION_OWNER')
	      AND table_name = pi_ft_table
	      AND data_type = 'NUMBER'	 
	    ORDER BY column_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_ft_lr_lov;


  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_col_names_lov(pi_asset_type           IN     nm_inv_type_groupings_all.itg_inv_type%TYPE
                             ,po_message_severity        OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor          OUT sys_refcursor
                             ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT column_name
            ,data_type || '(' || TO_CHAR (
                                    NVL (
                                      data_precision
                                     ,data_length
                                    )
                                  )
               || DECODE (
                   data_scale
                  ,'0', NULL
                  ,NULL, NULL
                  ,',' || TO_CHAR (
                           data_scale
                         )
                 )
               || ')' data_type
            ,data_type datatype2
            ,NVL (data_precision-data_scale, data_length) data_length_num
            ,DECODE(data_scale, 0, NULL, data_scale) decimal_num
        FROM all_tab_columns
       WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
         AND table_name = 'NM_INV_ITEMS'
         AND nm3inv.is_column_allowable_for_flex(column_id) = nm3type.get_true
         AND column_name NOT IN (SELECT ita_attrib_name
      			                       FROM nm_inv_type_attribs
      			                      WHERE ita_inv_type = pi_asset_type
                                    AND column_name = ita_attrib_name) 
         AND column_name NOT IN ('IIT_ANGLE_TXT', 'IIT_CLASS_TXT', 'IIT_COLOUR_TXT', 'IIT_COORD_FLAG', 
                                 'IIT_END_DATE', 'IIT_INV_OWNERSHIP', 'IIT_LCO_LAMP_CONFIG_ID', 'IIT_MATERIAL_TXT', 
                                 'IIT_METHOD_TXT', 'IIT_OFFSET', 'IIT_OPTIONS_TXT', 'IIT_OUN_ORG_ID_ELEC_BOARD', 
                                 'IIT_OWNER_TXT', 'IIT_PROV_FLAG', 'IIT_REV_BY', 'IIT_REV_DATE', 'IIT_TYPE_TXT', 
                                 'IIT_XTRA_DOMAIN_TXT_1')
       ORDER BY column_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_col_names_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_domains_lov(pi_asset_format         IN     nm_inv_domains_all.id_datatype%TYPE
                                 ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor          OUT sys_refcursor
                                 ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT id_domain, id_title
        FROM nm_inv_domains
       WHERE id_datatype = DECODE (pi_asset_format,NULL,id_datatype,'VARCHAR2',id_datatype,pi_asset_format)
       ORDER BY id_domain;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_domains_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_units_lov(po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor
                         ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT un_unit_name
            ,ud_domain_name
            ,un_unit_id
        FROM nm_units
            ,nm_unit_domains 
       WHERE ud_domain_id = un_domain_id 
       ORDER BY ud_domain_name, un_unit_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_units_lov;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nw_types_lov(po_message_severity        OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor          OUT sys_refcursor
                            ,po_cursor                  OUT sys_refcursor)
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
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nw_types_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_parent_asset_types_lov(po_message_severity        OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor          OUT sys_refcursor
                                      ,po_cursor                  OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nit_inv_type
            ,nit_descr
        FROM nm_inv_types
       WHERE nit_inv_type IN (SELECT itg_inv_type 
                                FROM nm_inv_type_groupings 
                             CONNECT BY PRIOR  itg_inv_type = itg_parent_inv_type
                               START WITH itg_parent_inv_type IN (SELECT nit_inv_type 
                                                                    FROM nm_inv_types 
                                                                   WHERE nit_top = 'Y')
                               UNION 
                              SELECT nit_inv_type 
                                FROM nm_inv_types 
                               WHERE nit_top = 'Y');
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_parent_asset_types_lov;
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_domain(pi_asset_domain     IN      nm_inv_domains_all.id_domain%TYPE
                               ,pi_title            IN      nm_inv_domains_all.id_title%TYPE
                               ,pi_datatype         IN      nm_inv_domains_all.id_datatype%TYPE
                               ,pi_start_date       IN      nm_inv_domains_all.id_start_date%TYPE
                               ,pi_end_date         IN      nm_inv_domains_all.id_end_date%TYPE
                               ,po_message_severity     OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Domain'
                               ,pi_parameter_value => pi_asset_domain);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Title'
                               ,pi_parameter_value => pi_title);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Datatype'
                               ,pi_parameter_value => pi_datatype);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);                        
    --
    IF asset_domain_exists(pi_asset_domain => pi_asset_domain) = 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info => 'Asset domain exists');    
    END IF;
    --
    /*
    ||insert into asset_domain.
    */
    INSERT 
      INTO nm_inv_domains_all
           (id_domain
           ,id_title
           ,id_datatype
           ,id_start_date
           ,id_end_date
           )
    VALUES (UPPER(pi_asset_domain)
           ,UPPER(pi_title)
           ,UPPER(pi_datatype)
           ,TRUNC(pi_start_date)
           ,TRUNC(pi_end_date)
           );     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_asset_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_domain(pi_old_domain           IN      nm_inv_domains_all.id_domain%TYPE
                               ,pi_old_title            IN      nm_inv_domains_all.id_title%TYPE 
                               ,pi_old_datatype         IN      nm_inv_domains_all.id_datatype%TYPE
                               ,pi_old_end_date         IN      nm_inv_domains_all.id_end_date%TYPE
                               ,pi_new_domain           IN      nm_inv_domains_all.id_domain%TYPE
                               ,pi_new_title            IN      nm_inv_domains_all.id_title%TYPE
                               ,pi_new_datatype         IN      nm_inv_domains_all.id_datatype%TYPE
                               ,pi_new_end_date         IN      nm_inv_domains_all.id_end_date%TYPE
                               ,po_message_severity         OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor           OUT sys_refcursor)
    IS
    --    
    lr_db_id_rec     nm_inv_domains_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_id_rec
        FROM nm_inv_domains_all
       WHERE id_domain = pi_old_domain
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Domain does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Domain'
                               ,pi_parameter_value => pi_new_domain);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Title'
                               ,pi_parameter_value => pi_new_title);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Datatype'
                               ,pi_parameter_value => pi_new_datatype);                    
    --
    IF  asset_domain_exists(pi_asset_domain => pi_old_domain) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     );    
    END IF;    
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_id_rec.id_domain != pi_old_domain
     OR (lr_db_id_rec.id_domain IS NULL AND pi_old_domain IS NOT NULL)
     OR (lr_db_id_rec.id_domain IS NOT NULL AND pi_old_domain IS NULL)
     --
     OR (lr_db_id_rec.id_title != pi_old_title)
     OR (lr_db_id_rec.id_title IS NULL AND pi_old_title IS NOT NULL)
     OR (lr_db_id_rec.id_title IS NOT NULL AND pi_old_title IS NULL)
     --    
     OR (lr_db_id_rec.id_datatype != pi_old_datatype)
     OR (lr_db_id_rec.id_datatype IS NULL AND pi_old_datatype IS NOT NULL)
     OR (lr_db_id_rec.id_datatype IS NOT NULL AND pi_old_datatype IS NULL)
     --     
     OR (lr_db_id_rec.id_end_date != pi_old_end_date)
     OR (lr_db_id_rec.id_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_id_rec.id_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --           
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_domain != pi_new_domain
       OR (pi_old_domain IS NULL AND pi_new_domain IS NOT NULL)
       OR (pi_old_domain IS NOT NULL AND pi_new_domain IS NULL)
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
      IF pi_old_datatype != pi_new_datatype
       OR (pi_old_datatype IS NULL AND pi_new_datatype IS NOT NULL)
       OR (pi_old_datatype IS NOT NULL AND pi_new_datatype IS NULL)
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
        UPDATE nm_inv_domains_all
           SET  id_domain = UPPER(pi_new_domain)
               ,id_title   = UPPER(pi_new_title)
               ,id_datatype = UPPER(pi_new_datatype)
               ,id_end_date  = TRUNC(pi_new_end_date)
         WHERE id_domain = lr_db_id_rec.id_domain;
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
  END update_asset_domain;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_domain(pi_asset_domain      IN      hig_roles.hro_role%TYPE
                               ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    IF asset_domain_exists(pi_asset_domain => pi_asset_domain) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Domain does not exist');    
    END IF;
    --
    UPDATE nm_inv_domains_all
       SET id_end_date = TRUNC(SYSDATE)
     WHERE id_domain = UPPER(pi_asset_domain)
       AND id_end_date IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_domain;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_domain_value(pi_asset_domain         IN      nm_inv_attri_lookup_all.ial_domain%TYPE
                                     ,pi_asset_domain_value   IN      nm_inv_attri_lookup_all.ial_value%TYPE
                                     ,pi_dtp_code             IN      nm_inv_attri_lookup_all.ial_dtp_code%TYPE
                                     ,pi_meaning              IN      nm_inv_attri_lookup_all.ial_meaning%TYPE
                                     ,pi_seq                  IN      nm_inv_attri_lookup_all.ial_seq%TYPE
                                     ,pi_nva_id               IN      nm_inv_attri_lookup_all.ial_nva_id%TYPE
                                     ,pi_start_date           IN      nm_inv_attri_lookup_all.ial_start_date%TYPE
                                     ,pi_end_date             IN      nm_inv_attri_lookup_all.ial_end_date%TYPE
                                     ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Domain'
                               ,pi_parameter_value => pi_asset_domain);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Value'
                               ,pi_parameter_value => pi_asset_domain_value);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sequence'
                               ,pi_parameter_value => pi_seq);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);                        
    --
    IF asset_domain_value_exists(pi_asset_domain => pi_asset_domain
                                ,pi_asset_domain_value => pi_asset_domain_value
                                ,pi_start_date => pi_start_date) = 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info => 'Asset Domain value exists');    
    END IF;
    --
    /*
    ||insert into asset_domain.
    */
    INSERT 
      INTO nm_inv_attri_lookup_all
           (ial_domain
           ,ial_value
           ,ial_dtp_code
           ,ial_meaning
           ,ial_start_date
           ,ial_end_date
           ,ial_seq
           ,ial_nva_id
           )
    VALUES (UPPER(pi_asset_domain)
           ,UPPER(pi_asset_domain_value)
           ,pi_dtp_code
           ,pi_meaning
           ,TRUNC(pi_start_date)
           ,TRUNC(pi_end_date)
           ,pi_seq
           ,pi_nva_id
           );     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_asset_domain_value;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_domain_value(pi_asset_domain             IN      nm_inv_attri_lookup_all.ial_domain%TYPE
                                     ,pi_old_asset_domain_value   IN      nm_inv_attri_lookup_all.ial_value%TYPE
                                     ,pi_old_dtp_code             IN      nm_inv_attri_lookup_all.ial_dtp_code%TYPE
                                     ,pi_old_meaning              IN      nm_inv_attri_lookup_all.ial_meaning%TYPE 
                                     ,pi_old_seq                  IN      nm_inv_attri_lookup_all.ial_seq%TYPE
                                     ,pi_old_nva_id               IN      nm_inv_attri_lookup_all.ial_nva_id%TYPE
                                     ,pi_old_start_date           IN      nm_inv_attri_lookup_all.ial_start_date%TYPE
                                     ,pi_old_end_date             IN      nm_inv_attri_lookup_all.ial_end_date%TYPE
                                     ,pi_new_asset_domain_value   IN      nm_inv_attri_lookup_all.ial_value%TYPE                                     
                                     ,pi_new_dtp_code             IN      nm_inv_attri_lookup_all.ial_dtp_code%TYPE                                     
                                     ,pi_new_meaning              IN      nm_inv_attri_lookup_all.ial_meaning%TYPE                                     
                                     ,pi_new_seq                  IN      nm_inv_attri_lookup_all.ial_seq%TYPE                                     
                                     ,pi_new_nva_id               IN      nm_inv_attri_lookup_all.ial_nva_id%TYPE                                     
                                     ,pi_new_start_date           IN      nm_inv_attri_lookup_all.ial_start_date%TYPE                                     
                                     ,pi_new_end_date             IN      nm_inv_attri_lookup_all.ial_end_date%TYPE                                        
                                     ,po_message_severity             OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor               OUT sys_refcursor)
    IS
    --    
    lr_db_ial_rec    nm_inv_attri_lookup_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_ial_rec
        FROM nm_inv_attri_lookup_all
       WHERE ial_domain = pi_asset_domain
         AND ial_value  = pi_old_asset_domain_value
         AND ial_start_date = pi_old_start_date
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Domain Value does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Value'
                               ,pi_parameter_value => pi_new_asset_domain_value);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sequence'
                               ,pi_parameter_value => pi_new_seq);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);                   
    --
    IF  asset_domain_value_exists(pi_asset_domain => pi_asset_domain
                                 ,pi_asset_domain_value => pi_old_asset_domain_value
                                 ,pi_start_date => pi_old_start_date) <> 'Y'
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
    IF lr_db_ial_rec.ial_domain != pi_asset_domain
     OR (lr_db_ial_rec.ial_domain IS NULL AND pi_asset_domain IS NOT NULL)
     OR (lr_db_ial_rec.ial_domain IS NOT NULL AND pi_asset_domain IS NULL)
     --
     OR (lr_db_ial_rec.ial_value != pi_old_asset_domain_value)
     OR (lr_db_ial_rec.ial_value IS NULL AND pi_old_asset_domain_value IS NOT NULL)
     OR (lr_db_ial_rec.ial_value IS NOT NULL AND pi_old_asset_domain_value IS NULL)
     --    
     OR (lr_db_ial_rec.ial_dtp_code != pi_old_dtp_code)
     OR (lr_db_ial_rec.ial_dtp_code IS NULL AND pi_old_dtp_code IS NOT NULL)
     OR (lr_db_ial_rec.ial_dtp_code IS NOT NULL AND pi_old_dtp_code IS NULL)
     --    
     OR (lr_db_ial_rec.ial_meaning != pi_old_meaning)
     OR (lr_db_ial_rec.ial_meaning IS NULL AND pi_old_meaning IS NOT NULL)
     OR (lr_db_ial_rec.ial_meaning IS NOT NULL AND pi_old_meaning IS NULL)
     --     
     OR (lr_db_ial_rec.ial_seq != pi_old_seq)
     OR (lr_db_ial_rec.ial_seq IS NULL AND pi_old_seq IS NOT NULL)
     OR (lr_db_ial_rec.ial_seq IS NOT NULL AND pi_old_seq IS NULL)
     --     
     OR (lr_db_ial_rec.ial_nva_id != pi_old_nva_id)
     OR (lr_db_ial_rec.ial_nva_id IS NULL AND pi_old_nva_id IS NOT NULL)
     OR (lr_db_ial_rec.ial_nva_id IS NOT NULL AND pi_old_nva_id IS NULL)
     --     
     OR (lr_db_ial_rec.ial_start_date != pi_old_start_date)
     OR (lr_db_ial_rec.ial_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_ial_rec.ial_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --     
     OR (lr_db_ial_rec.ial_end_date != pi_old_end_date)
     OR (lr_db_ial_rec.ial_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_ial_rec.ial_end_date IS NOT NULL AND pi_old_end_date IS NULL)     
     --           
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_asset_domain_value != pi_new_asset_domain_value
       OR (pi_old_asset_domain_value IS NULL AND pi_new_asset_domain_value IS NOT NULL)
       OR (pi_old_asset_domain_value IS NOT NULL AND pi_new_asset_domain_value IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_dtp_code != pi_new_dtp_code
       OR (pi_old_dtp_code IS NULL AND pi_new_dtp_code IS NOT NULL)
       OR (pi_old_dtp_code IS NOT NULL AND pi_new_dtp_code IS NULL)
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
      IF pi_old_seq != pi_new_seq
       OR (pi_old_seq IS NULL AND pi_new_seq IS NOT NULL)
       OR (pi_old_seq IS NOT NULL AND pi_new_seq IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_nva_id != pi_new_nva_id
       OR (pi_old_nva_id IS NULL AND pi_new_nva_id IS NOT NULL)
       OR (pi_old_nva_id IS NOT NULL AND pi_new_nva_id IS NULL)
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
        UPDATE nm_inv_attri_lookup_all
           SET ial_value      = UPPER(pi_new_asset_domain_value)
              ,ial_dtp_code   = UPPER(pi_new_dtp_code)
              ,ial_meaning    = pi_new_meaning
              ,ial_start_date = TRUNC(pi_new_start_date)
              ,ial_end_date   = TRUNC(pi_new_end_date)
              ,ial_seq        = pi_new_seq
              ,ial_nva_id     = pi_new_nva_id
         WHERE ial_domain = pi_asset_domain
           AND ial_value = pi_old_asset_domain_value
           AND ial_start_date = pi_old_start_date;
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
  END update_asset_domain_value;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_domain_value(pi_asset_domain       IN      nm_inv_attri_lookup_all.ial_domain%TYPE
                                     ,pi_asset_domain_value IN      nm_inv_attri_lookup_all.ial_value%TYPE
                                     ,pi_start_date         IN      nm_inv_attri_lookup_all.ial_start_date%TYPE
                                     ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                                     ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;    
    --
    IF asset_domain_value_exists(pi_asset_domain => pi_asset_domain
                                ,pi_asset_domain_value => pi_asset_domain_value
                                ,pi_start_date => pi_start_date) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    UPDATE nm_inv_attri_lookup_all
       SET ial_end_date = TRUNC(SYSDATE)
     WHERE ial_domain = UPPER(pi_asset_domain)
       AND ial_value  = UPPER(pi_asset_domain_value)
       AND ial_start_date = TRUNC(pi_start_date)
       AND ial_end_date IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_domain_value;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_xsp_restraint(pi_nw_type               IN     nm_xsp_restraints.xsr_nw_type%TYPE
                                ,pi_xsp                   IN     nm_xsp_restraints.xsr_x_sect_value%TYPE
                                ,pi_sub_class             IN     nm_xsp_restraints.xsr_scl_class%TYPE
                                ,pi_inv_code              IN     nm_xsp_restraints.xsr_ity_inv_code%TYPE
                                ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'NW Type'
                               ,pi_parameter_value => pi_nw_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'XSP'
                               ,pi_parameter_value => pi_xsp);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sub Class'
                               ,pi_parameter_value => pi_sub_class);     
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Inv Code'
                               ,pi_parameter_value => pi_inv_code);  
    --
    IF xsp_restraint_exists(pi_nw_type    => pi_nw_type
                           ,pi_xsp        => pi_xsp
                           ,pi_sub_class  => pi_sub_class
                           ,pi_inv_code   => pi_inv_code) = 'Y'   
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64);    
    END IF;
    --
    /*
    ||insert
    */
    INSERT 
      INTO nm_xsp_restraints
           (xsr_nw_type
           ,xsr_x_sect_value
           ,xsr_scl_class
           ,xsr_ity_inv_code
           ,xsr_descr
           )
    VALUES (pi_nw_type
           ,pi_xsp
           ,pi_sub_class
           ,pi_inv_code
           ,''
           );     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_xsp_restraint;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_xsp_restraint(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                                ,pi_inv_code            IN      nm_xsp_restraints.xsr_ity_inv_code%TYPE
                                ,pi_sub_class           IN      nm_xsp_restraints.xsr_scl_class%TYPE
                                ,pi_xsp                 IN      nm_xsp_restraints.xsr_x_sect_value%TYPE
                                ,pi_old_description     IN      nm_xsp_restraints.xsr_descr%TYPE
                                ,pi_new_description     IN      nm_xsp_restraints.xsr_descr%TYPE
                                ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor           OUT sys_refcursor)
    IS
    --    
    lr_db_xsr_rec    nm_xsp_restraints%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_xsr_rec
        FROM nm_xsp_restraints
       WHERE xsr_nw_type = pi_nw_type
         AND xsr_ity_inv_code = pi_inv_code
         AND xsr_scl_class = pi_sub_class
         AND xsr_x_sect_value = pi_xsp
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'XSP does not exist');
          --      
    END get_db_rec;
    --
  BEGIN      
    --
    awlrs_util.check_historic_mode;  
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_xsr_rec.xsr_descr != pi_old_description
     OR (lr_db_xsr_rec.xsr_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_xsr_rec.xsr_descr IS NOT NULL AND pi_old_description IS NULL)
     --           
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_description != pi_new_description
       OR (pi_old_description IS NULL AND pi_new_description IS NOT NULL)
       OR (pi_old_description IS NOT NULL AND pi_new_description IS NULL)
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
        UPDATE nm_xsp_restraints
           SET xsr_descr = pi_new_description
         WHERE xsr_nw_type = pi_nw_type
           AND xsr_ity_inv_code = pi_inv_code
           AND xsr_scl_class = pi_sub_class
           AND xsr_x_sect_value = pi_xsp;
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
  END update_xsp_restraint;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_xsp_restraint(pi_nw_type             IN      nm_xsp_restraints.xsr_nw_type%TYPE
                                ,pi_inv_code            IN      nm_xsp_restraints.xsr_ity_inv_code%TYPE
                                ,pi_sub_class           IN      nm_xsp_restraints.xsr_scl_class%TYPE
                                ,pi_xsp                 IN      nm_xsp_restraints.xsr_x_sect_value%TYPE
                                ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    IF xsp_restraint_exists(pi_nw_type    => pi_nw_type
                           ,pi_xsp        => pi_xsp
                           ,pi_sub_class  => pi_sub_class
                           ,pi_inv_code   => pi_inv_code) <> 'Y'      
     THEN
        --
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);
        --
    END IF;
    --
    DELETE
      FROM nm_xsp_restraints
     WHERE xsr_nw_type = pi_nw_type
       AND xsr_ity_inv_code = pi_inv_code
       AND xsr_scl_class = pi_sub_class
       AND xsr_x_sect_value = pi_xsp;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_xsp_restraint;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_nw_xsp(pi_nw_type               IN     nm_nw_xsp.nwx_nw_type%TYPE
                         ,pi_xsp                   IN     nm_nw_xsp.nwx_x_sect%TYPE
                         ,pi_sub_class             IN     nm_nw_xsp.nwx_nsc_sub_class%TYPE
                         ,pi_desc                  IN     nm_nw_xsp.nwx_descr%TYPE
                         ,pi_seq                   IN     nm_nw_xsp.nwx_seq%TYPE
                         ,pi_offset                IN     nm_nw_xsp.nwx_offset%TYPE
                         ,po_message_severity         OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'NW Type'
                               ,pi_parameter_value => pi_nw_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'XSP'
                               ,pi_parameter_value => pi_xsp);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sub Class'
                               ,pi_parameter_value => pi_sub_class);                      
    --
    IF nw_xsp_exists(pi_nw_type   => pi_nw_type
                    ,pi_xsp       => pi_xsp
                    ,pi_sub_class => pi_sub_class) = 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info => 'NW XSP exists');    
    END IF;
    --
    /*
    ||insert
    */
    INSERT 
      INTO nm_nw_xsp
           (nwx_nw_type
           ,nwx_x_sect
           ,nwx_nsc_sub_class
           ,nwx_descr
           ,nwx_seq
           ,nwx_offset
           )
    VALUES (UPPER(pi_nw_type)
           ,UPPER(pi_xsp)
           ,pi_sub_class
           ,pi_desc
           ,pi_seq
           ,pi_offset
           );     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_nw_xsp;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_nw_xsp(pi_old_nw_type        IN      nm_nw_xsp.nwx_nw_type%TYPE
                         ,pi_old_sub_class      IN      nm_nw_xsp.nwx_nsc_sub_class%TYPE
                         ,pi_old_xsp            IN      nm_nw_xsp.nwx_x_sect%TYPE 
                         ,pi_old_desc           IN      nm_nw_xsp.nwx_descr%TYPE
                         ,pi_old_seq            IN      nm_nw_xsp.nwx_seq%TYPE
                         ,pi_old_offset         IN      nm_nw_xsp.nwx_offset%TYPE
                         ,pi_new_nw_type        IN      nm_nw_xsp.nwx_nw_type%TYPE                                     
                         ,pi_new_sub_class      IN      nm_nw_xsp.nwx_nsc_sub_class%TYPE 
                         ,pi_new_xsp            IN      nm_nw_xsp.nwx_x_sect%TYPE                         
                         ,pi_new_desc           IN      nm_nw_xsp.nwx_descr%TYPE                          
                         ,pi_new_seq            IN      nm_nw_xsp.nwx_seq%TYPE                                     
                         ,pi_new_offset         IN      nm_nw_xsp.nwx_offset%TYPE                                                                   
                         ,po_message_severity       OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor         OUT sys_refcursor)
    IS
    --    
    lr_db_nwx_rec    nm_nw_xsp%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_nwx_rec
        FROM nm_nw_xsp
       WHERE nwx_nw_type = pi_old_nw_type
         AND nwx_nsc_sub_class  = pi_old_sub_class
         AND nwx_x_sect = pi_old_xsp
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'NW XSP Value does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'NW Type'
                               ,pi_parameter_value => pi_new_nw_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'XSP'
                               ,pi_parameter_value => pi_new_xsp);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sub Class'
                               ,pi_parameter_value => pi_new_sub_class);                      
    --
    IF  nw_xsp_exists(pi_nw_type   => pi_old_nw_type
                     ,pi_xsp       => pi_old_xsp
                     ,pi_sub_class => pi_old_sub_class)  <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;   
    --
    IF pi_new_nw_type <> pi_old_nw_type 
     OR pi_new_xsp <> pi_old_xsp
     OR pi_new_sub_class <> pi_old_sub_class
      THEN
         IF  nw_xsp_exists(pi_nw_type   => pi_new_nw_type
                          ,pi_xsp       => pi_new_xsp
                          ,pi_sub_class => pi_new_sub_class) = 'Y'
          THEN
             hig.raise_ner(pi_appl => 'HIG'
                          ,pi_id   => 64
                          ,pi_supplementary_info => 'NW XSP exists with same values');    
         END IF;    
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_nwx_rec.nwx_nw_type != pi_old_nw_type
     OR (lr_db_nwx_rec.nwx_nw_type IS NULL AND pi_old_nw_type IS NOT NULL)
     OR (lr_db_nwx_rec.nwx_nw_type IS NOT NULL AND pi_old_nw_type IS NULL)
     --
     OR (lr_db_nwx_rec.nwx_nsc_sub_class != pi_old_sub_class)
     OR (lr_db_nwx_rec.nwx_nsc_sub_class IS NULL AND pi_old_sub_class IS NOT NULL)
     OR (lr_db_nwx_rec.nwx_nsc_sub_class IS NOT NULL AND pi_old_sub_class IS NULL)
     --    
     OR (lr_db_nwx_rec.nwx_x_sect != pi_old_xsp)
     OR (lr_db_nwx_rec.nwx_x_sect IS NULL AND pi_old_xsp IS NOT NULL)
     OR (lr_db_nwx_rec.nwx_x_sect IS NOT NULL AND pi_old_xsp IS NULL)
     --    
     OR (lr_db_nwx_rec.nwx_descr != pi_old_desc)
     OR (lr_db_nwx_rec.nwx_descr IS NULL AND pi_old_desc IS NOT NULL)
     OR (lr_db_nwx_rec.nwx_descr IS NOT NULL AND pi_old_desc IS NULL)
     --     
     OR (lr_db_nwx_rec.nwx_seq != pi_old_seq)
     OR (lr_db_nwx_rec.nwx_seq IS NULL AND pi_old_seq IS NOT NULL)
     OR (lr_db_nwx_rec.nwx_seq IS NOT NULL AND pi_old_seq IS NULL)
     --     
     OR (lr_db_nwx_rec.nwx_offset != pi_old_offset)
     OR (lr_db_nwx_rec.nwx_offset IS NULL AND pi_old_offset IS NOT NULL)
     OR (lr_db_nwx_rec.nwx_offset IS NOT NULL AND pi_old_offset IS NULL)  
     --           
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_nw_type != pi_new_nw_type
       OR (pi_old_nw_type IS NULL AND pi_new_nw_type IS NOT NULL)
       OR (pi_old_nw_type IS NOT NULL AND pi_new_nw_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_sub_class != pi_new_sub_class
       OR (pi_old_sub_class IS NULL AND pi_new_sub_class IS NOT NULL)
       OR (pi_old_sub_class IS NOT NULL AND pi_new_sub_class IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF pi_old_xsp != pi_new_xsp
       OR (pi_old_xsp IS NULL AND pi_new_xsp IS NOT NULL)
       OR (pi_old_xsp IS NOT NULL AND pi_new_xsp IS NULL)
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
      IF pi_old_seq != pi_new_seq
       OR (pi_old_seq IS NULL AND pi_new_seq IS NOT NULL)
       OR (pi_old_seq IS NOT NULL AND pi_new_seq IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;   
      --
      IF pi_old_offset != pi_new_offset
       OR (pi_old_offset IS NULL AND pi_new_offset IS NOT NULL)
       OR (pi_old_offset IS NOT NULL AND pi_new_offset IS NULL)
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
        UPDATE nm_nw_xsp
           SET nwx_nw_type       = pi_new_nw_type
              ,nwx_x_sect        = pi_new_xsp
              ,nwx_nsc_sub_class = pi_new_sub_class
              ,nwx_descr         = pi_new_desc
              ,nwx_seq           = pi_new_seq
              ,nwx_offset        = pi_new_offset
        WHERE nwx_nw_type = pi_old_nw_type
          AND nwx_nsc_sub_class  = pi_old_sub_class
          AND nwx_x_sect = pi_old_xsp;
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
  END update_nw_xsp;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_nw_xsp(pi_nw_type               IN     nm_nw_xsp.nwx_nw_type%TYPE
                         ,pi_xsp                   IN     nm_nw_xsp.nwx_x_sect%TYPE
                         ,pi_sub_class             IN     nm_nw_xsp.nwx_nsc_sub_class%TYPE
                         ,po_message_severity        OUT  hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT  sys_refcursor)
    IS
    --
    FUNCTION xsp_restraint_exists(pi_nw_type    IN nm_xsp_restraints.xsr_nw_type%TYPE
                                 ,pi_xsp        IN nm_xsp_restraints.xsr_x_sect_value%TYPE
                                 ,pi_sub_class  IN nm_xsp_restraints.xsr_scl_class%TYPE)
      RETURN VARCHAR2
    IS
      lv_exists VARCHAR2(1):= 'N';
      lv_cnt    NUMBER;
    BEGIN
      --
      SELECT COUNT(xsr_nw_type)
        INTO lv_cnt
        FROM nm_xsp_restraints
       WHERE xsr_nw_type = pi_nw_type
         AND xsr_x_sect_value = pi_xsp
         AND xsr_scl_class = pi_sub_class;
      --
      IF lv_cnt > 0 
       THEN
         lv_exists :='Y';
      END IF;
      --
      RETURN lv_exists;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          RETURN 'N';
    END xsp_restraint_exists;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    IF  nw_xsp_exists(pi_nw_type   => pi_nw_type
                     ,pi_xsp       => pi_xsp
                     ,pi_sub_class => pi_sub_class)  <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    IF  xsp_restraint_exists(pi_nw_type    => pi_nw_type
                            ,pi_xsp        => pi_xsp
                            ,pi_sub_class  => pi_sub_class)  = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 2
                     ,pi_supplementary_info => 'XSP Restraints');    
    END IF;
    --
    IF  xsp_reversal_exists(pi_nw_type    => pi_nw_type
                           ,pi_xsp        => pi_xsp
                           ,pi_sub_class  => pi_sub_class)  = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 2
                     ,pi_supplementary_info => 'XSP Reversals');    
    END IF;
    --
    DELETE 
      FROM nm_nw_xsp 
     WHERE nwx_nw_type = pi_nw_type
       AND nwx_nsc_sub_class  = pi_sub_class
       AND nwx_x_sect = pi_xsp;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_nw_xsp;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_xsp_reversal(pi_nw_type             IN      nm_xsp_reversal.xrv_nw_type%TYPE
                               ,pi_sub_class           IN      nm_xsp_reversal.xrv_old_sub_class%TYPE
                               ,pi_xsp                 IN      nm_xsp_reversal.xrv_old_xsp%TYPE                               
                               ,pi_new_xsp             IN      nm_xsp_reversal.xrv_new_xsp%TYPE
                               ,pi_new_sub_class       IN      nm_xsp_reversal.xrv_new_sub_class%TYPE
                               ,po_message_severity         OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'NW Type'
                               ,pi_parameter_value => pi_nw_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'XSP'
                               ,pi_parameter_value => pi_xsp);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sub Class'
                               ,pi_parameter_value => pi_sub_class);     
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'New XSP'
                               ,pi_parameter_value => pi_new_xsp);  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'New Sub Class'
                               ,pi_parameter_value => pi_new_sub_class);     
    --
    IF xsp_reversal_exists(pi_nw_type             => pi_nw_type
                          ,pi_xsp                 => pi_xsp
                          ,pi_sub_class           => pi_sub_class) = 'Y'   
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info => 'Reversal already exists');    
    END IF;
    --
    /*
    ||insert
    */
    INSERT 
      INTO nm_xsp_reversal
           (xrv_nw_type
           ,xrv_old_xsp
           ,xrv_old_sub_class
           ,xrv_new_xsp
           ,xrv_new_sub_class
           ,xrv_manual_override
           ,xrv_default_xsp
           )
    VALUES (pi_nw_type
           ,pi_xsp
           ,pi_sub_class
           ,pi_new_xsp
           ,pi_new_sub_class
           ,'N'
           ,''
           );     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_xsp_reversal;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_xsp_reversal(pi_nw_type             IN      nm_xsp_reversal.xrv_nw_type%TYPE
                               ,pi_sub_class           IN      nm_xsp_reversal.xrv_old_sub_class%TYPE
                               ,pi_xsp                 IN      nm_xsp_reversal.xrv_old_xsp%TYPE
                               ,pi_old_new_subclass    IN      nm_xsp_reversal.xrv_new_sub_class%TYPE 
                               ,pi_new_new_subclass    IN      nm_xsp_reversal.xrv_new_sub_class%TYPE 
                               ,pi_old_new_xsp         IN      nm_xsp_reversal.xrv_new_xsp%TYPE 
                               ,pi_new_new_xsp         IN      nm_xsp_reversal.xrv_new_xsp%TYPE                           
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor)
    IS
    --    
    lr_db_xrv_rec    nm_xsp_reversal%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_xrv_rec
        FROM nm_xsp_reversal
       WHERE xrv_nw_type = pi_nw_type
         AND xrv_old_xsp = pi_xsp
         AND xrv_old_sub_class = pi_sub_class
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'XSP Reversal does not exist');
          --      
    END get_db_rec;
    --
  BEGIN    
    --
    awlrs_util.check_historic_mode;  
    --
    IF nw_xsp_exists(pi_nw_type    => pi_nw_type
                    ,pi_xsp        => pi_new_new_xsp
                    ,pi_sub_class  => pi_new_new_subclass) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    IF sub_class_exists(pi_sub_class => pi_new_new_subclass
                       ,pi_nw_type   => pi_nw_type) <> 'Y' 
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
    IF lr_db_xrv_rec.xrv_nw_type != pi_nw_type
     OR (lr_db_xrv_rec.xrv_nw_type IS NULL AND pi_nw_type IS NOT NULL)
     OR (lr_db_xrv_rec.xrv_nw_type IS NOT NULL AND pi_nw_type IS NULL)
     --    
     OR (lr_db_xrv_rec.xrv_old_sub_class != pi_sub_class)
     OR (lr_db_xrv_rec.xrv_old_sub_class IS NULL AND pi_sub_class IS NOT NULL)
     OR (lr_db_xrv_rec.xrv_old_sub_class IS NOT NULL AND pi_sub_class IS NULL)     
          --
     OR (lr_db_xrv_rec.xrv_old_xsp != pi_xsp)
     OR (lr_db_xrv_rec.xrv_old_xsp IS NULL AND pi_xsp IS NOT NULL)
     OR (lr_db_xrv_rec.xrv_old_xsp IS NOT NULL AND pi_xsp IS NULL)
          --
     OR (lr_db_xrv_rec.xrv_new_sub_class != pi_old_new_subclass)
     OR (lr_db_xrv_rec.xrv_new_sub_class IS NULL AND pi_old_new_subclass IS NOT NULL)
     OR (lr_db_xrv_rec.xrv_new_sub_class IS NOT NULL AND pi_old_new_subclass IS NULL)
          --
     OR (lr_db_xrv_rec.xrv_new_xsp != pi_old_new_xsp)
     OR (lr_db_xrv_rec.xrv_new_xsp IS NULL AND pi_old_new_xsp IS NOT NULL)
     OR (lr_db_xrv_rec.xrv_new_xsp IS NOT NULL AND pi_old_new_xsp IS NULL)
     
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_new_subclass != pi_new_new_subclass
       OR (pi_old_new_subclass IS NULL AND pi_new_new_subclass IS NOT NULL)
       OR (pi_old_new_subclass IS NOT NULL AND pi_new_new_subclass IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_new_xsp != pi_new_new_xsp
       OR (pi_old_new_xsp IS NULL AND pi_new_new_xsp IS NOT NULL)
       OR (pi_old_new_xsp IS NOT NULL AND pi_new_new_xsp IS NULL)
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
        UPDATE nm_xsp_reversal
           SET xrv_new_xsp = pi_new_new_xsp
              ,xrv_new_sub_class = pi_new_new_subclass
         WHERE xrv_nw_type = pi_nw_type
           AND xrv_old_xsp = pi_xsp
           AND xrv_old_sub_class = pi_sub_class;
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
  END update_xsp_reversal;  

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_xsp_reversal(pi_nw_type             IN      nm_xsp_reversal.xrv_nw_type%TYPE
                               ,pi_sub_class           IN      nm_xsp_reversal.xrv_old_sub_class%TYPE
                               ,pi_xsp                 IN      nm_xsp_reversal.xrv_old_xsp%TYPE
                               ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor         OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;   
    --
    IF xsp_reversal_exists(pi_nw_type    => pi_nw_type
                          ,pi_xsp        => pi_xsp
                          ,pi_sub_class  => pi_sub_class) <> 'Y'      
     THEN
                             
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);    
    END IF;
    --
    DELETE
      FROM nm_xsp_reversal
     WHERE xrv_nw_type = pi_nw_type
       AND xrv_old_sub_class = pi_sub_class
       AND xrv_old_xsp = pi_xsp;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_xsp_reversal;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_type(pi_asset_type         IN      nm_inv_types.nit_inv_type%TYPE
                             ,pi_pnt_or_cont        IN      nm_inv_types.nit_pnt_or_cont%TYPE
                             ,pi_linear             IN      nm_inv_types.nit_linear%TYPE
                             ,pi_x_sect_allow_flag  IN      nm_inv_types.nit_x_sect_allow_flag%TYPE
                             ,pi_elec_drain_carr    IN      nm_inv_types.nit_elec_drain_carr%TYPE
                             ,pi_contiguous         IN      nm_inv_types.nit_contiguous%TYPE
                             ,pi_replaceable        IN      nm_inv_types.nit_replaceable%TYPE
                             ,pi_exclusive          IN      nm_inv_types.nit_exclusive%TYPE
                             ,pi_category           IN      nm_inv_types.nit_category%TYPE
                             ,pi_descr              IN      nm_inv_types.nit_descr%TYPE
                             ,pi_use_xy             IN      nm_inv_types.nit_use_xy%TYPE
                             ,pi_multiple_allowed   IN      nm_inv_types.nit_multiple_allowed%TYPE
                             ,pi_screen_seq         IN      nm_inv_types.nit_screen_seq%TYPE
                             ,pi_start_date         IN      nm_inv_types.nit_start_date%TYPE
                             ,pi_end_date           IN      nm_inv_types.nit_end_date%TYPE
                             ,pi_short_descr        IN      nm_inv_types.nit_short_descr%TYPE
                             ,pi_table_name         IN      nm_inv_types.nit_table_name%TYPE
                             ,pi_lr_ne_column_name  IN      nm_inv_types.nit_lr_ne_column_name%TYPE
                             ,pi_lr_st_chain        IN      nm_inv_types.nit_lr_st_chain%TYPE
                             ,pi_lr_end_chain       IN      nm_inv_types.nit_lr_end_chain%TYPE
                             ,pi_admin_type         IN      nm_inv_types.nit_admin_type%TYPE 
                             ,pi_icon_name          IN      nm_inv_types.nit_icon_name%TYPE        
                             ,pi_top_of_hier        IN      nm_inv_types.nit_top%TYPE
                             ,pi_end_loc_only       IN      nm_inv_types.nit_end_loc_only%TYPE
                             ,pi_ft_pk_column       IN      nm_inv_types.nit_foreign_pk_column%TYPE
                             ,po_message_severity       OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_view_name nm_inv_types.nit_view_name%TYPE;
    lv_flex_item_flag nm_inv_types.nit_flex_item_flag%TYPE;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Point or Continuous'
                               ,pi_parameter_value => pi_pnt_or_cont);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Linear'
                               ,pi_parameter_value => pi_linear);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'XSP Allowed'
                               ,pi_parameter_value => pi_x_sect_allow_flag);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Elec Drain Carr'
                               ,pi_parameter_value => pi_elec_drain_carr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Contiguous'
                               ,pi_parameter_value => pi_contiguous);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Replaceable'
                               ,pi_parameter_value => pi_replaceable);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Exclusive'
                               ,pi_parameter_value => pi_exclusive); 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Category'
                               ,pi_parameter_value => pi_category);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_descr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Use XY'
                               ,pi_parameter_value => pi_use_xy);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Multiple Allowed'
                               ,pi_parameter_value => pi_multiple_allowed);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Type'
                               ,pi_parameter_value => pi_admin_type);
    
    /*
    ||Do validation checks on y/n flags
    */
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Linear'
                          ,pi_parameter_value => pi_linear);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'XSP Allowed'
                          ,pi_parameter_value => pi_x_sect_allow_flag);
    --    
    awlrs_util.validate_yn(pi_parameter_desc  => 'Replaceable'
                          ,pi_parameter_value => pi_replaceable);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Contiguous'
                          ,pi_parameter_value => pi_contiguous);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Exclusive'
                          ,pi_parameter_value => pi_exclusive);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Use XY'
                          ,pi_parameter_value => pi_use_xy);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Multiple Allowed'
                          ,pi_parameter_value => pi_multiple_allowed);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'End Locations'
                          ,pi_parameter_value => pi_end_loc_only);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Top of hierarchy'
                          ,pi_parameter_value => pi_top_of_hier);    
    /*
    ||Validate domain codes
    */
    hig.valid_fk_hco(pi_hco_domain => 'ELEC_DRAIN_CARR'
                    ,pi_hco_code   => pi_elec_drain_carr);
    --
    IF pi_pnt_or_cont NOT IN ('P','C') THEN
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 30
                   ,pi_supplementary_info => 'Point or Continuous');
    END IF;  
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) = 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 64
                     ,pi_supplementary_info => 'Asset Type exists');    
    END IF;
    --
    IF asset_category_exists(pi_asset_category => pi_category) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 29
                     ,pi_supplementary_info => 'Asset Category does not exist');    
    END IF;
    --
    IF admin_type_exists(pi_admin_type => pi_admin_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 29
                     ,pi_supplementary_info => 'Admin type does not exist');    
    END IF; 
    --    
    IF pi_lr_ne_column_name IS NOT NULL 
     AND col_name_exists(pi_asset_type   => pi_asset_type
                        ,pi_col_name       => pi_lr_ne_column_name) <> 'Y'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 30
                      ,pi_supplementary_info => 'LR Column Name');    
    END IF;
    --
    IF pi_ft_pk_column IS NOT NULL
     AND col_name_exists(pi_asset_type   => pi_asset_type
                        ,pi_col_name     => pi_ft_pk_column) <> 'Y'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 30
                      ,pi_supplementary_info => 'FK primary Key');    
    END IF;
    --
    IF pi_lr_st_chain IS NOT NULL
     AND col_name_exists(pi_asset_type   => pi_asset_type
                        ,pi_col_name     => pi_lr_st_chain) <> 'Y'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 30
                      ,pi_supplementary_info => 'LR Start Chain');    
    END IF;
    --
    IF pi_lr_end_chain IS NOT NULL
     AND col_name_exists(pi_asset_type   => pi_asset_type
                        ,pi_col_name       => pi_lr_end_chain) <> 'Y'
      THEN
         hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   => 30
                      ,pi_supplementary_info => 'LR End Chain');    
    END IF;
    --
    IF pi_table_name IS NOT NULL AND tab_name_exists(pi_tab_name => pi_table_name) <> 'Y'
     THEN
       hig.raise_ner(pi_appl => 'HIG'
                    ,pi_id   => 30
                    ,pi_supplementary_info => 'Table Name');    
    END IF;
    /*
    || Derive the View name
    */
    lv_view_name := nm3inv.derive_inv_type_view_name (pi_asset_type);
    lv_flex_item_flag := 'N'; --like form we default to N.
    /*
    ||insert into asset_domain. Upper things that are upper case.
    */
    INSERT 
      INTO nm_inv_types_all
           (nit_inv_type
           ,nit_pnt_or_cont
           ,nit_x_sect_allow_flag
           ,nit_elec_drain_carr
           ,nit_contiguous
           ,nit_replaceable
           ,nit_exclusive
           ,nit_category
           ,nit_descr
           ,nit_linear
           ,nit_use_xy
           ,nit_multiple_allowed
           ,nit_end_loc_only
           ,nit_screen_seq
           ,nit_view_name
           ,nit_start_date
           ,nit_end_date
           ,nit_short_descr
           ,nit_flex_item_flag
           ,nit_table_name
           ,nit_lr_ne_column_name
           ,nit_lr_st_chain
           ,nit_lr_end_chain
           ,nit_admin_type
           ,nit_icon_name
           ,nit_top
           ,nit_foreign_pk_column
           )
    VALUES (UPPER(pi_asset_type)
           ,pi_pnt_or_cont
           ,pi_x_sect_allow_flag
           ,pi_elec_drain_carr
           ,pi_contiguous
           ,pi_replaceable
           ,pi_exclusive
           ,pi_category
           ,pi_descr
           ,pi_linear
           ,pi_use_xy
           ,pi_multiple_allowed
           ,pi_end_loc_only
           ,pi_screen_seq
           ,lv_view_name
           ,pi_start_date
           ,pi_end_date
           ,pi_short_descr
           ,lv_flex_item_flag
           ,UPPER(pi_table_name)
           ,UPPER(pi_lr_ne_column_name)
           ,UPPER(pi_lr_st_chain)
           ,UPPER(pi_lr_end_chain)
           ,UPPER(pi_admin_type)
           ,UPPER(pi_icon_name)
           ,pi_top_of_hier
           ,UPPER(pi_ft_pk_column)  
           );     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_asset_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_type(pi_asset_type             IN      nm_inv_types_all.nit_inv_type%TYPE
                             ,pi_old_pnt_or_cont        IN      nm_inv_types_all.nit_pnt_or_cont%TYPE
                             ,pi_old_linear             IN      nm_inv_types_all.nit_linear%TYPE
                             ,pi_old_x_sect_allow_flag  IN      nm_inv_types_all.nit_x_sect_allow_flag%TYPE
                             ,pi_old_elec_drain_carr    IN      nm_inv_types_all.nit_elec_drain_carr%TYPE
                             ,pi_old_contiguous         IN      nm_inv_types_all.nit_contiguous%TYPE
                             ,pi_old_replaceable        IN      nm_inv_types_all.nit_replaceable%TYPE
                             ,pi_old_exclusive          IN      nm_inv_types_all.nit_exclusive%TYPE
                             ,pi_old_category           IN      nm_inv_types_all.nit_category%TYPE
                             ,pi_old_descr              IN      nm_inv_types_all.nit_descr%TYPE
                             ,pi_old_use_xy             IN      nm_inv_types_all.nit_use_xy%TYPE
                             ,pi_old_multiple_allowed   IN      nm_inv_types_all.nit_multiple_allowed%TYPE
                             ,pi_old_screen_seq         IN      nm_inv_types_all.nit_screen_seq%TYPE
                             ,pi_old_end_date           IN      nm_inv_types_all.nit_end_date%TYPE
                             ,pi_old_short_descr        IN      nm_inv_types_all.nit_short_descr%TYPE
                             ,pi_old_table_name         IN      nm_inv_types_all.nit_table_name%TYPE
                             ,pi_old_lr_ne_column_name  IN      nm_inv_types_all.nit_lr_ne_column_name%TYPE
                             ,pi_old_lr_st_chain        IN      nm_inv_types_all.nit_lr_st_chain%TYPE
                             ,pi_old_lr_end_chain       IN      nm_inv_types_all.nit_lr_end_chain%TYPE
                             ,pi_old_admin_type         IN      nm_inv_types_all.nit_admin_type%TYPE 
                             ,pi_old_icon_name          IN      nm_inv_types_all.nit_icon_name%TYPE        
                             ,pi_old_top_of_hier        IN      nm_inv_types_all.nit_top%TYPE
                             ,pi_old_end_loc_only       IN      nm_inv_types_all.nit_end_loc_only%TYPE
                             ,pi_old_ft_pk_column       IN      nm_inv_types_all.nit_foreign_pk_column%TYPE
                             ,pi_new_pnt_or_cont        IN      nm_inv_types_all.nit_pnt_or_cont%TYPE
                             ,pi_new_linear             IN      nm_inv_types_all.nit_linear%TYPE
                             ,pi_new_x_sect_allow_flag  IN      nm_inv_types_all.nit_x_sect_allow_flag%TYPE
                             ,pi_new_elec_drain_carr    IN      nm_inv_types_all.nit_elec_drain_carr%TYPE
                             ,pi_new_contiguous         IN      nm_inv_types_all.nit_contiguous%TYPE
                             ,pi_new_replaceable        IN      nm_inv_types_all.nit_replaceable%TYPE
                             ,pi_new_exclusive          IN      nm_inv_types_all.nit_exclusive%TYPE
                             ,pi_new_category           IN      nm_inv_types_all.nit_category%TYPE
                             ,pi_new_descr              IN      nm_inv_types_all.nit_descr%TYPE
                             ,pi_new_use_xy             IN      nm_inv_types_all.nit_use_xy%TYPE
                             ,pi_new_multiple_allowed   IN      nm_inv_types_all.nit_multiple_allowed%TYPE
                             ,pi_new_screen_seq         IN      nm_inv_types_all.nit_screen_seq%TYPE
                             ,pi_new_end_date           IN      nm_inv_types_all.nit_end_date%TYPE
                             ,pi_new_short_descr        IN      nm_inv_types_all.nit_short_descr%TYPE
                             ,pi_new_table_name         IN      nm_inv_types_all.nit_table_name%TYPE
                             ,pi_new_lr_ne_column_name  IN      nm_inv_types_all.nit_lr_ne_column_name%TYPE
                             ,pi_new_lr_st_chain        IN      nm_inv_types_all.nit_lr_st_chain%TYPE
                             ,pi_new_lr_end_chain       IN      nm_inv_types_all.nit_lr_end_chain%TYPE
                             ,pi_new_admin_type         IN      nm_inv_types_all.nit_admin_type%TYPE 
                             ,pi_new_icon_name          IN      nm_inv_types_all.nit_icon_name%TYPE        
                             ,pi_new_top_of_hier        IN      nm_inv_types_all.nit_top%TYPE
                             ,pi_new_end_loc_only       IN      nm_inv_types_all.nit_end_loc_only%TYPE
                             ,pi_new_ft_pk_column       IN      nm_inv_types_all.nit_foreign_pk_column%TYPE            
                             ,po_message_severity           OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor             OUT sys_refcursor)
    IS
    --    
    lr_db_nit_rec    nm_inv_types_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_nit_rec
        FROM nm_inv_types_all
       WHERE nit_inv_type = pi_asset_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Type does not exist');
          --      
    END get_db_rec;
    --
  BEGIN       
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --    
    get_db_rec;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Point or Continuous'
                               ,pi_parameter_value => pi_new_pnt_or_cont);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Linear'
                               ,pi_parameter_value => pi_new_linear);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'XSP Allowed'
                               ,pi_parameter_value => pi_new_x_sect_allow_flag);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Elec Drain Carr'
                               ,pi_parameter_value => pi_new_elec_drain_carr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Contiguous'
                               ,pi_parameter_value => pi_new_contiguous);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Replaceable'
                               ,pi_parameter_value => pi_new_replaceable);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Exclusive'
                               ,pi_parameter_value => pi_new_exclusive); 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Category'
                               ,pi_parameter_value => pi_new_category);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_new_descr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Use XY'
                               ,pi_parameter_value => pi_new_use_xy);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Multiple Allowed'
                               ,pi_parameter_value => pi_new_multiple_allowed);                               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Admin Type'
                               ,pi_parameter_value => pi_new_admin_type);                                
    
    /*
    ||Do validation checks on y/n flags
    */
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Linear'
                          ,pi_parameter_value => pi_new_linear);
    --                          
    awlrs_util.validate_yn(pi_parameter_desc  => 'XSP Allowed'
                          ,pi_parameter_value => pi_new_x_sect_allow_flag);
    --                          
    awlrs_util.validate_yn(pi_parameter_desc  => 'Contiguous'
                          ,pi_parameter_value => pi_new_contiguous);
    --                          
    awlrs_util.validate_yn(pi_parameter_desc  => 'Replaceable'
                          ,pi_parameter_value => pi_new_replaceable);
    --                          
    awlrs_util.validate_yn(pi_parameter_desc  => 'Exclusive'
                          ,pi_parameter_value => pi_new_exclusive);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Use XY'
                          ,pi_parameter_value => pi_new_use_xy);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Multiple Allowed'
                          ,pi_parameter_value => pi_new_multiple_allowed);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'End Locations'
                          ,pi_parameter_value => pi_new_end_loc_only);
    --  
    awlrs_util.validate_yn(pi_parameter_desc  => 'Top of hierarchy'
                          ,pi_parameter_value => pi_new_top_of_hier);

    --    
    IF pi_new_pnt_or_cont NOT IN ('P','C') THEN
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 30
                   ,pi_supplementary_info => 'Point or Continuous');
    END IF;  
    --
    IF asset_category_exists(pi_asset_category => pi_new_category) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 29
                     ,pi_supplementary_info => 'Asset Category does not exist');    
    END IF;
    --
    IF admin_type_exists(pi_admin_type => pi_new_admin_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 29
                     ,pi_supplementary_info => 'Admin type does not exist');    
    END IF; 
    /*
    ||Validate domain codes
    */
    IF pi_new_elec_drain_carr != pi_old_elec_drain_carr 
     THEN
        hig.valid_fk_hco(pi_hco_domain => 'ELEC_DRAIN_CARR'
                        ,pi_hco_code   => pi_new_elec_drain_carr);
    END IF;
    --
    IF pi_old_lr_ne_column_name != pi_new_lr_ne_column_name
     OR (pi_old_lr_ne_column_name IS NULL AND pi_new_lr_ne_column_name IS NOT NULL)
     OR (pi_old_lr_ne_column_name IS NOT NULL AND pi_new_lr_ne_column_name IS NULL)
     THEN
       IF col_name_exists(pi_asset_type           => pi_asset_type
                         ,pi_col_name             => pi_new_lr_ne_column_name) <> 'Y'
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 30
                       ,pi_supplementary_info => 'LR Column Name');    
       END IF;
    END IF;
    --
    IF pi_old_ft_pk_column != pi_new_ft_pk_column
     OR (pi_old_ft_pk_column IS NULL AND pi_new_ft_pk_column IS NOT NULL)
     OR (pi_old_ft_pk_column IS NOT NULL AND pi_new_ft_pk_column IS NULL)
     THEN
       IF col_name_exists(pi_asset_type           => pi_asset_type
                         ,pi_col_name             => pi_new_ft_pk_column) <> 'Y'
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 30
                       ,pi_supplementary_info => 'FK primary Key');    
       END IF;
    END IF;
    --
    IF pi_old_lr_st_chain != pi_new_lr_st_chain
     OR (pi_old_lr_st_chain IS NULL AND pi_new_lr_st_chain IS NOT NULL)
     OR (pi_old_lr_st_chain IS NOT NULL AND pi_new_lr_st_chain IS NULL)
     THEN
       IF col_name_exists(pi_asset_type           => pi_asset_type
                         ,pi_col_name             => pi_new_lr_st_chain) <> 'Y'
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 30
                       ,pi_supplementary_info => 'LR Start Chain');    
       END IF;
    END IF;
    --
    IF pi_old_lr_end_chain != pi_new_lr_end_chain
     OR (pi_old_lr_end_chain IS NULL AND pi_new_lr_end_chain IS NOT NULL)
     OR (pi_old_lr_end_chain IS NOT NULL AND pi_new_lr_end_chain IS NULL)
     THEN
       IF col_name_exists(pi_asset_type           => pi_asset_type
                         ,pi_col_name             => pi_new_lr_end_chain) <> 'Y'
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 30
                       ,pi_supplementary_info => 'LR End Chain');    
       END IF;
    END IF;
    --
    IF pi_old_table_name != pi_new_table_name
     OR (pi_old_table_name IS NULL AND pi_new_table_name IS NOT NULL)
     OR (pi_old_table_name IS NOT NULL AND pi_new_table_name IS NULL)
      THEN
         IF tab_name_exists(pi_tab_name => pi_new_table_name) <> 'Y'
          THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 30
                         ,pi_supplementary_info => 'Table Name');    
         END IF;
    END IF;
    --    
    /*
    ||Compare old with DB
    */
    IF lr_db_nit_rec.nit_pnt_or_cont != pi_old_pnt_or_cont
     OR (lr_db_nit_rec.nit_pnt_or_cont IS NULL AND pi_old_pnt_or_cont IS NOT NULL)
     OR (lr_db_nit_rec.nit_pnt_or_cont IS NOT NULL AND pi_old_pnt_or_cont IS NULL)
     --    
     OR (lr_db_nit_rec.nit_linear != pi_old_linear)
     OR (lr_db_nit_rec.nit_linear IS NULL AND pi_old_linear IS NOT NULL)
     OR (lr_db_nit_rec.nit_linear IS NOT NULL AND pi_old_linear IS NULL)     
     --
     OR (lr_db_nit_rec.nit_x_sect_allow_flag != pi_old_x_sect_allow_flag)
     OR (lr_db_nit_rec.nit_x_sect_allow_flag IS NULL AND pi_old_x_sect_allow_flag IS NOT NULL)
     OR (lr_db_nit_rec.nit_x_sect_allow_flag IS NOT NULL AND pi_old_x_sect_allow_flag IS NULL)
     --
     OR (lr_db_nit_rec.nit_elec_drain_carr != pi_old_elec_drain_carr)
     OR (lr_db_nit_rec.nit_elec_drain_carr IS NULL AND pi_old_elec_drain_carr IS NOT NULL)
     OR (lr_db_nit_rec.nit_elec_drain_carr IS NOT NULL AND pi_old_elec_drain_carr IS NULL)
     --
     OR (lr_db_nit_rec.nit_contiguous != pi_old_contiguous)
     OR (lr_db_nit_rec.nit_contiguous IS NULL AND pi_old_contiguous IS NOT NULL)
     OR (lr_db_nit_rec.nit_contiguous IS NOT NULL AND pi_old_contiguous IS NULL)
     --    
     OR (lr_db_nit_rec.nit_replaceable != pi_old_replaceable)
     OR (lr_db_nit_rec.nit_replaceable IS NULL AND pi_old_replaceable IS NOT NULL)
     OR (lr_db_nit_rec.nit_replaceable IS NOT NULL AND pi_old_replaceable IS NULL)     
     --
     OR (lr_db_nit_rec.nit_exclusive != pi_old_exclusive)
     OR (lr_db_nit_rec.nit_exclusive IS NULL AND pi_old_exclusive IS NOT NULL)
     OR (lr_db_nit_rec.nit_exclusive IS NOT NULL AND pi_old_exclusive IS NULL)
     --
     OR (lr_db_nit_rec.nit_category != pi_old_category)
     OR (lr_db_nit_rec.nit_category IS NULL AND pi_old_category IS NOT NULL)
     OR (lr_db_nit_rec.nit_category IS NOT NULL AND pi_old_category IS NULL)
     --
     OR (lr_db_nit_rec.nit_descr != pi_old_descr)
     OR (lr_db_nit_rec.nit_descr IS NULL AND pi_old_descr IS NOT NULL)
     OR (lr_db_nit_rec.nit_descr IS NOT NULL AND pi_old_descr IS NULL)
     --    
     OR (lr_db_nit_rec.nit_use_xy != pi_old_use_xy)
     OR (lr_db_nit_rec.nit_use_xy IS NULL AND pi_old_use_xy IS NOT NULL)
     OR (lr_db_nit_rec.nit_use_xy IS NOT NULL AND pi_old_use_xy IS NULL)     
     --
     OR (lr_db_nit_rec.nit_multiple_allowed != pi_old_multiple_allowed)
     OR (lr_db_nit_rec.nit_multiple_allowed IS NULL AND pi_old_multiple_allowed IS NOT NULL)
     OR (lr_db_nit_rec.nit_multiple_allowed IS NOT NULL AND pi_old_multiple_allowed IS NULL)
     --
     OR (lr_db_nit_rec.nit_screen_seq != pi_old_screen_seq)
     OR (lr_db_nit_rec.nit_screen_seq IS NULL AND pi_old_screen_seq IS NOT NULL)
     OR (lr_db_nit_rec.nit_screen_seq IS NOT NULL AND pi_old_screen_seq IS NULL)
     --    
     OR (lr_db_nit_rec.nit_end_date != pi_old_end_date)
     OR (lr_db_nit_rec.nit_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_nit_rec.nit_end_date IS NOT NULL AND pi_old_end_date IS NULL)     
     --
     OR (lr_db_nit_rec.nit_short_descr != pi_old_short_descr)
     OR (lr_db_nit_rec.nit_short_descr IS NULL AND pi_old_short_descr IS NOT NULL)
     OR (lr_db_nit_rec.nit_short_descr IS NOT NULL AND pi_old_short_descr IS NULL)
     --
     OR (lr_db_nit_rec.nit_table_name != pi_old_table_name)
     OR (lr_db_nit_rec.nit_table_name IS NULL AND pi_old_table_name IS NOT NULL)
     OR (lr_db_nit_rec.nit_table_name IS NOT NULL AND pi_old_table_name IS NULL)     
     --
     OR (lr_db_nit_rec.nit_lr_ne_column_name != pi_old_lr_ne_column_name)
     OR (lr_db_nit_rec.nit_lr_ne_column_name IS NULL AND pi_old_lr_ne_column_name IS NOT NULL)
     OR (lr_db_nit_rec.nit_lr_ne_column_name IS NOT NULL AND pi_old_lr_ne_column_name IS NULL)
     --
     OR (lr_db_nit_rec.nit_lr_st_chain != pi_old_lr_st_chain)
     OR (lr_db_nit_rec.nit_lr_st_chain IS NULL AND pi_old_lr_st_chain IS NOT NULL)
     OR (lr_db_nit_rec.nit_lr_st_chain IS NOT NULL AND pi_old_lr_st_chain IS NULL)
     --
     OR (lr_db_nit_rec.nit_lr_end_chain != pi_old_lr_end_chain)
     OR (lr_db_nit_rec.nit_lr_end_chain IS NULL AND pi_old_lr_end_chain IS NOT NULL)
     OR (lr_db_nit_rec.nit_lr_end_chain IS NOT NULL AND pi_old_lr_end_chain IS NULL)          
     --
     OR (lr_db_nit_rec.nit_admin_type != pi_old_admin_type)
     OR (lr_db_nit_rec.nit_admin_type IS NULL AND pi_old_admin_type IS NOT NULL)
     OR (lr_db_nit_rec.nit_admin_type IS NOT NULL AND pi_old_admin_type IS NULL)
     --
     OR (lr_db_nit_rec.nit_icon_name != pi_old_icon_name)
     OR (lr_db_nit_rec.nit_icon_name IS NULL AND pi_old_icon_name IS NOT NULL)
     OR (lr_db_nit_rec.nit_icon_name IS NOT NULL AND pi_old_icon_name IS NULL)          
     --
     OR (lr_db_nit_rec.nit_top != pi_old_top_of_hier)
     OR (lr_db_nit_rec.nit_top IS NULL AND pi_old_top_of_hier IS NOT NULL)
     OR (lr_db_nit_rec.nit_top IS NOT NULL AND pi_old_top_of_hier IS NULL)     
     --
     OR (lr_db_nit_rec.nit_end_loc_only != pi_old_end_loc_only)
     OR (lr_db_nit_rec.nit_end_loc_only IS NULL AND pi_old_end_loc_only IS NOT NULL)
     OR (lr_db_nit_rec.nit_end_loc_only IS NOT NULL AND pi_old_end_loc_only IS NULL)
     --
     OR (lr_db_nit_rec.nit_foreign_pk_column != pi_old_ft_pk_column)
     OR (lr_db_nit_rec.nit_foreign_pk_column IS NULL AND pi_old_ft_pk_column IS NOT NULL)
     OR (lr_db_nit_rec.nit_foreign_pk_column IS NOT NULL AND pi_old_ft_pk_column IS NULL)          
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_pnt_or_cont != pi_new_pnt_or_cont
       OR (pi_old_pnt_or_cont IS NULL AND pi_new_pnt_or_cont IS NOT NULL)
       OR (pi_old_pnt_or_cont IS NOT NULL AND pi_new_pnt_or_cont IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_linear != pi_new_linear
       OR (pi_old_linear IS NULL AND pi_new_linear IS NOT NULL)
       OR (pi_old_linear IS NOT NULL AND pi_new_linear IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_x_sect_allow_flag != pi_new_x_sect_allow_flag
       OR (pi_old_x_sect_allow_flag IS NULL AND pi_new_x_sect_allow_flag IS NOT NULL)
       OR (pi_old_x_sect_allow_flag IS NOT NULL AND pi_new_x_sect_allow_flag IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_elec_drain_carr != pi_new_elec_drain_carr
       OR (pi_old_elec_drain_carr IS NULL AND pi_new_elec_drain_carr IS NOT NULL)
       OR (pi_old_elec_drain_carr IS NOT NULL AND pi_new_elec_drain_carr IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_contiguous != pi_new_contiguous
       OR (pi_old_contiguous IS NULL AND pi_new_contiguous IS NOT NULL)
       OR (pi_old_contiguous IS NOT NULL AND pi_new_contiguous IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_replaceable != pi_new_replaceable
       OR (pi_old_replaceable IS NULL AND pi_new_replaceable IS NOT NULL)
       OR (pi_old_replaceable IS NOT NULL AND pi_new_replaceable IS NULL)
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
      IF pi_old_category != pi_new_category
       OR (pi_old_category IS NULL AND pi_new_category IS NOT NULL)
       OR (pi_old_category IS NOT NULL AND pi_new_category IS NULL)
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
      IF pi_old_use_xy != pi_new_use_xy
       OR (pi_old_use_xy IS NULL AND pi_new_use_xy IS NOT NULL)
       OR (pi_old_use_xy IS NOT NULL AND pi_new_use_xy IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_multiple_allowed != pi_new_multiple_allowed
       OR (pi_old_multiple_allowed IS NULL AND pi_new_multiple_allowed IS NOT NULL)
       OR (pi_old_multiple_allowed IS NOT NULL AND pi_new_multiple_allowed IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_screen_seq != pi_new_screen_seq
       OR (pi_old_screen_seq IS NULL AND pi_new_screen_seq IS NOT NULL)
       OR (pi_old_screen_seq IS NOT NULL AND pi_new_screen_seq IS NULL)
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
      IF pi_old_short_descr != pi_new_short_descr
       OR (pi_old_short_descr IS NULL AND pi_new_short_descr IS NOT NULL)
       OR (pi_old_short_descr IS NOT NULL AND pi_new_short_descr IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_table_name != pi_new_table_name
       OR (pi_old_table_name IS NULL AND pi_new_table_name IS NOT NULL)
       OR (pi_old_table_name IS NOT NULL AND pi_new_table_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_lr_ne_column_name != pi_new_lr_ne_column_name
       OR (pi_old_lr_ne_column_name IS NULL AND pi_new_lr_ne_column_name IS NOT NULL)
       OR (pi_old_lr_ne_column_name IS NOT NULL AND pi_new_lr_ne_column_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_lr_st_chain != pi_new_lr_st_chain
       OR (pi_old_lr_st_chain IS NULL AND pi_new_lr_st_chain IS NOT NULL)
       OR (pi_old_lr_st_chain IS NOT NULL AND pi_new_lr_st_chain IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_lr_end_chain != pi_new_lr_end_chain
       OR (pi_old_lr_end_chain IS NULL AND pi_new_lr_end_chain IS NOT NULL)
       OR (pi_old_lr_end_chain IS NOT NULL AND pi_new_lr_end_chain IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_admin_type != pi_new_admin_type
       OR (pi_old_admin_type IS NULL AND pi_new_admin_type IS NOT NULL)
       OR (pi_old_admin_type IS NOT NULL AND pi_new_admin_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_icon_name != pi_new_icon_name
       OR (pi_old_icon_name IS NULL AND pi_new_icon_name IS NOT NULL)
       OR (pi_old_icon_name IS NOT NULL AND pi_new_icon_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_top_of_hier != pi_new_top_of_hier
       OR (pi_old_top_of_hier IS NULL AND pi_new_top_of_hier IS NOT NULL)
       OR (pi_old_top_of_hier IS NOT NULL AND pi_new_top_of_hier IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_end_loc_only != pi_new_end_loc_only
       OR (pi_old_end_loc_only IS NULL AND pi_new_end_loc_only IS NOT NULL)
       OR (pi_old_end_loc_only IS NOT NULL AND pi_new_end_loc_only IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_ft_pk_column != pi_new_ft_pk_column
       OR (pi_old_ft_pk_column IS NULL AND pi_new_ft_pk_column IS NOT NULL)
       OR (pi_old_ft_pk_column IS NOT NULL AND pi_new_ft_pk_column IS NULL)
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
        UPDATE nm_inv_types_all
           SET nit_pnt_or_cont       = pi_new_pnt_or_cont       
              ,nit_linear            = pi_new_linear            
              ,nit_x_sect_allow_flag = pi_new_x_sect_allow_flag 
              ,nit_elec_drain_carr   = pi_new_elec_drain_carr   
              ,nit_contiguous        = pi_new_contiguous        
              ,nit_replaceable       = pi_new_replaceable       
              ,nit_exclusive         = pi_new_exclusive         
              ,nit_category          = pi_new_category          
              ,nit_descr             = pi_new_descr             
              ,nit_use_xy            = pi_new_use_xy            
              ,nit_multiple_allowed  = pi_new_multiple_allowed  
              ,nit_screen_seq        = pi_new_screen_seq             
              ,nit_end_date          = TRUNC(pi_new_end_date)          
              ,nit_short_descr       = pi_new_short_descr         
              ,nit_table_name        = UPPER(pi_new_table_name)      
              ,nit_lr_ne_column_name = UPPER(pi_new_lr_ne_column_name) 
              ,nit_lr_st_chain       = UPPER(pi_new_lr_st_chain)    
              ,nit_lr_end_chain      = UPPER(pi_new_lr_end_chain)      
              ,nit_admin_type        = UPPER(pi_new_admin_type)        
              ,nit_icon_name         = UPPER(pi_new_icon_name)      
              ,nit_top               = pi_new_top_of_hier       
              ,nit_end_loc_only      = pi_new_end_loc_only        
              ,nit_foreign_pk_column = UPPER(pi_new_ft_pk_column)                  
         WHERE nit_inv_type = pi_asset_type;
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
  END update_asset_type;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_type(pi_asset_type          IN      nm_inv_types_all.nit_inv_type%TYPE
                             ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor         OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y'      
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type doesnt exist');    
    END IF;
    --
    UPDATE nm_inv_types_all
       SET nit_end_date = TRUNC(SYSDATE)
     WHERE nit_inv_type = pi_asset_type
       AND nit_end_date IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_type;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_attribute(pi_asset_type         IN      nm_inv_type_attribs.ita_inv_type%TYPE    
                                  ,pi_attrib_name        IN      nm_inv_type_attribs.ita_attrib_name%TYPE
                                  ,pi_disp_seq_no        IN      nm_inv_type_attribs.ita_disp_seq_no%TYPE 
                                  ,pi_mandatory_yn       IN      nm_inv_type_attribs.ita_mandatory_yn%TYPE 
                                  ,pi_format             IN      nm_inv_type_attribs.ita_format%TYPE 
                                  ,pi_fld_length         IN      nm_inv_type_attribs.ita_fld_length%TYPE 
                                  ,pi_dec_places         IN      nm_inv_type_attribs.ita_dec_places%TYPE 
                                  ,pi_scrn_text          IN      nm_inv_type_attribs.ita_scrn_text%TYPE 
                                  ,pi_id_domain          IN      nm_inv_type_attribs.ita_id_domain%TYPE 
                                  ,pi_dtp_code           IN      nm_inv_type_attribs.ita_dtp_code%TYPE
                                  ,pi_max                IN      nm_inv_type_attribs.ita_max%TYPE 
                                  ,pi_min                IN      nm_inv_type_attribs.ita_min%TYPE 
                                  ,pi_view_attri         IN      nm_inv_type_attribs.ita_view_attri%TYPE 
                                  ,pi_view_col_name      IN      nm_inv_type_attribs.ita_view_col_name%TYPE 
                                  ,pi_start_date         IN      nm_inv_type_attribs.ita_start_date%TYPE 
                                  ,pi_end_date           IN      nm_inv_type_attribs.ita_end_date%TYPE 
                                  ,pi_queryable_yn       IN      nm_inv_type_attribs.ita_queryable%TYPE 
                                  ,pi_ukpms_param_no     IN      nm_inv_type_attribs.ita_ukpms_param_no%TYPE 
                                  ,pi_units              IN      nm_inv_type_attribs.ita_units%TYPE 
                                  ,pi_format_mask        IN      nm_inv_type_attribs.ita_format_mask%TYPE 
                                  ,pi_exclusive_yn       IN      nm_inv_type_attribs.ita_exclusive%TYPE 
                                  ,pi_keep_history_yn    IN      nm_inv_type_attribs.ita_keep_history_yn%TYPE 
                                  ,pi_query              IN      nm_inv_type_attribs.ita_query%TYPE 
                                  ,pi_displayed_yn       IN      nm_inv_type_attribs.ita_displayed%TYPE 
                                  ,pi_disp_width         IN      nm_inv_type_attribs.ita_disp_width%TYPE 
                                  ,pi_inspectable_yn     IN      nm_inv_type_attribs.ita_inspectable%TYPE 
                                  ,pi_case               IN      nm_inv_type_attribs.ita_case%TYPE
                                  ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types_all%ROWTYPE;
    lv_validate_yn VARCHAR2(1);
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sequence'
                               ,pi_parameter_value => pi_disp_seq_no);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Format'
                               ,pi_parameter_value => pi_format);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Field Length'
                               ,pi_parameter_value => pi_fld_length);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Screen Text'
                               ,pi_parameter_value => pi_scrn_text);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'View Attribute'
                               ,pi_parameter_value => pi_view_attri);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Column Name'
                               ,pi_parameter_value => pi_view_col_name);                        
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date); 
    --                                
    /*
    ||Do validation checks on y/n flags
    */
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_mandatory_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Keep History'
                          ,pi_parameter_value => pi_keep_history_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Queryable'
                          ,pi_parameter_value => pi_queryable_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Exclusive'
                          ,pi_parameter_value => pi_exclusive_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Inspectable'
                          ,pi_parameter_value => pi_inspectable_yn);                          
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Displayed'
                          ,pi_parameter_value => pi_displayed_yn);                          
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    /*
    ||Validate domain codes
    */
    --
    hig.valid_fk_hco(pi_hco_domain => 'DATA_FORMAT'
                    ,pi_hco_code   => pi_format);    
    --
    hig.valid_fk_hco(pi_hco_domain => 'ATTRIBUTE_CASE'
                    ,pi_hco_code   => pi_case);  
    --
    IF pi_format_mask IS NOT NULL
     THEN
        hig.valid_fk_hco(pi_hco_domain => 'DATE_FORMAT_MASK'
                        ,pi_hco_code   => pi_format_mask);    
    END IF;   
    --
    IF col_name_exists(pi_asset_type           => pi_asset_type
                      ,pi_col_name             => pi_attrib_name) <> 'Y'
     THEN
       hig.raise_ner(pi_appl => 'HIG'
                    ,pi_id   => 30
                    ,pi_supplementary_info => 'Column Name');    
    END IF;
    --
	  IF nm3inv.attrib_in_use(pi_inv_type    => pi_asset_type
	  	                     ,pi_attrib_name => pi_attrib_name)	                     
	   THEN
       hig.raise_ner(pi_appl => 'NET'
                    ,pi_id   => 61);
	  END IF;
    /*
    ||make sure view colname doesnt exist
    */
    IF asset_attribute_exists(pi_asset_type     => pi_asset_type
                             ,pi_view_attribute => pi_view_attri) = 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'View attribute on : '|| pi_scrn_text);    
    END IF;    
    /*
    ||If domain set then validate should be Y.
    */
    IF pi_id_domain IS NOT NULL
     THEN
       /*
       ||validate the domain
       */
       IF asset_domain_exists(pi_asset_domain => pi_id_domain) <> 'Y' 
        THEN
           hig.raise_ner(pi_appl => 'HIG'
                        ,pi_id   => 29
                        ,pi_supplementary_info => 'Asset Domain does not exist');    
       END IF;       
       --
       lv_validate_yn := 'Y';
    ELSE
       lv_validate_yn := 'N';
    END IF;
    --
    /*
    ||validate units 
    */
    IF pi_units IS NOT NULL 
     THEN
       IF unit_exists(pi_unit_id => pi_units) != 'Y' 
        THEN
		       hig.raise_ner(pi_appl => 'HIG'
		       	            ,pi_id   => 30
                        ,pi_supplementary_info => 'Units');        
       END IF;
    END IF;
    --
    IF nm3flx.is_reserved_word(pi_view_col_name) 
     OR nm3flx.is_reserved_word(pi_view_attri)
      THEN
		    hig.raise_ner(pi_appl => 'NET'
		    	            ,pi_id   => 455);
    END IF;
    --
    IF pi_min IS NOT NULL 
     AND pi_max IS NOT NULL 
     AND pi_min > pi_max 
      THEN
        hig.raise_ner(pi_appl => 'NET'
        						 ,pi_id   => 455);
    END IF;
    --
    lr_nit := nm3get.get_nit_all(pi_nit_inv_type => pi_asset_type);  
    --     
	  check_format(pi_table_name => lr_nit.nit_table_name
                ,pi_col_name   => pi_attrib_name
	              ,pi_length     => pi_fld_length
                ,pi_dec_places => pi_dec_places);
    --
    INSERT 
      INTO nm_inv_type_attribs_all
           (ita_inv_type              
           ,ita_attrib_name           
           ,ita_dynamic_attrib        
           ,ita_disp_seq_no           
           ,ita_mandatory_yn          
           ,ita_format                
           ,ita_fld_length            
           ,ita_dec_places            
           ,ita_scrn_text             
           ,ita_id_domain             
           ,ita_validate_yn           
           ,ita_dtp_code              
           ,ita_max                   
           ,ita_min                   
           ,ita_view_attri            
           ,ita_view_col_name         
           ,ita_start_date            
           ,ita_end_date              
           ,ita_queryable             
           ,ita_ukpms_param_no        
           ,ita_units                 
           ,ita_format_mask           
           ,ita_exclusive             
           ,ita_keep_history_yn       
           ,ita_query                 
           ,ita_displayed             
           ,ita_disp_width            
           ,ita_inspectable           
           ,ita_case)
    VALUES (pi_asset_type              
           ,UPPER(pi_attrib_name)
           ,'N'--pi_dynamic_attrib_yn is N in form always
           ,pi_disp_seq_no           
           ,NVL(pi_mandatory_yn,'N') 
           ,UPPER(pi_format)
           ,pi_fld_length            
           ,pi_dec_places            
           ,pi_scrn_text             
           ,UPPER(pi_id_domain)             
           ,NVL(lv_validate_yn,'N')           
           ,UPPER(pi_dtp_code)
           ,pi_max                   
           ,pi_min                   
           ,UPPER(pi_view_attri)
           ,UPPER(pi_view_col_name)
           ,TRUNC(pi_start_date)            
           ,TRUNC(pi_end_date)
           ,NVL(pi_queryable_yn,'N')
           ,pi_ukpms_param_no        
           ,pi_units                 
           ,UPPER(pi_format_mask)
           ,NVL(pi_exclusive_yn,'N')
           ,NVL(pi_keep_history_yn,'N')
           ,pi_query                 
           ,NVL(pi_displayed_yn,'N')
           ,pi_disp_width            
           ,NVL(pi_inspectable_yn,'N')
           ,UPPER(pi_case));     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_asset_attribute;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_attribute(pi_asset_type            IN      nm_inv_type_attribs.ita_inv_type%TYPE    
                                  ,pi_attrib_name           IN      nm_inv_type_attribs.ita_attrib_name%TYPE
                                  ,pi_old_disp_seq_no       IN      nm_inv_type_attribs.ita_disp_seq_no%TYPE 
                                  ,pi_old_mandatory_yn      IN      nm_inv_type_attribs.ita_mandatory_yn%TYPE 
                                  ,pi_old_format            IN      nm_inv_type_attribs.ita_format%TYPE 
                                  ,pi_old_fld_length        IN      nm_inv_type_attribs.ita_fld_length%TYPE 
                                  ,pi_old_dec_places        IN      nm_inv_type_attribs.ita_dec_places%TYPE 
                                  ,pi_old_scrn_text         IN      nm_inv_type_attribs.ita_scrn_text%TYPE 
                                  ,pi_old_id_domain         IN      nm_inv_type_attribs.ita_id_domain%TYPE 
                                  ,pi_old_dtp_code          IN      nm_inv_type_attribs.ita_dtp_code%TYPE  
                                  ,pi_old_max               IN      nm_inv_type_attribs.ita_max%TYPE 
                                  ,pi_old_min               IN      nm_inv_type_attribs.ita_min%TYPE 
                                  ,pi_old_view_attri        IN      nm_inv_type_attribs.ita_view_attri%TYPE 
                                  ,pi_old_view_col_name     IN      nm_inv_type_attribs.ita_view_col_name%TYPE 
                                  ,pi_old_start_date        IN      nm_inv_type_attribs.ita_start_date%TYPE 
                                  ,pi_old_end_date          IN      nm_inv_type_attribs.ita_end_date%TYPE 
                                  ,pi_old_queryable_yn      IN      nm_inv_type_attribs.ita_queryable%TYPE 
                                  ,pi_old_ukpms_param_no    IN      nm_inv_type_attribs.ita_ukpms_param_no%TYPE 
                                  ,pi_old_units             IN      nm_inv_type_attribs.ita_units%TYPE 
                                  ,pi_old_format_mask       IN      nm_inv_type_attribs.ita_format_mask%TYPE 
                                  ,pi_old_exclusive_yn      IN      nm_inv_type_attribs.ita_exclusive%TYPE 
                                  ,pi_old_keep_history_yn   IN      nm_inv_type_attribs.ita_keep_history_yn%TYPE 
                                  ,pi_old_displayed_yn      IN      nm_inv_type_attribs.ita_displayed%TYPE 
                                  ,pi_old_disp_width        IN      nm_inv_type_attribs.ita_disp_width%TYPE 
                                  ,pi_old_inspectable_yn    IN      nm_inv_type_attribs.ita_inspectable%TYPE 
                                  ,pi_old_case              IN      nm_inv_type_attribs.ita_case%TYPE
                                  ,pi_new_disp_seq_no       IN      nm_inv_type_attribs.ita_disp_seq_no%TYPE 
                                  ,pi_new_mandatory_yn      IN      nm_inv_type_attribs.ita_mandatory_yn%TYPE 
                                  ,pi_new_format            IN      nm_inv_type_attribs.ita_format%TYPE 
                                  ,pi_new_fld_length        IN      nm_inv_type_attribs.ita_fld_length%TYPE 
                                  ,pi_new_dec_places        IN      nm_inv_type_attribs.ita_dec_places%TYPE 
                                  ,pi_new_scrn_text         IN      nm_inv_type_attribs.ita_scrn_text%TYPE 
                                  ,pi_new_id_domain         IN      nm_inv_type_attribs.ita_id_domain%TYPE 
                                  ,pi_new_dtp_code          IN      nm_inv_type_attribs.ita_dtp_code%TYPE
                                  ,pi_new_max               IN      nm_inv_type_attribs.ita_max%TYPE 
                                  ,pi_new_min               IN      nm_inv_type_attribs.ita_min%TYPE 
                                  ,pi_new_view_attri        IN      nm_inv_type_attribs.ita_view_attri%TYPE 
                                  ,pi_new_view_col_name     IN      nm_inv_type_attribs.ita_view_col_name%TYPE 
                                  ,pi_new_start_date        IN      nm_inv_type_attribs.ita_start_date%TYPE 
                                  ,pi_new_end_date          IN      nm_inv_type_attribs.ita_end_date%TYPE 
                                  ,pi_new_queryable_yn      IN      nm_inv_type_attribs.ita_queryable%TYPE 
                                  ,pi_new_ukpms_param_no    IN      nm_inv_type_attribs.ita_ukpms_param_no%TYPE 
                                  ,pi_new_units             IN      nm_inv_type_attribs.ita_units%TYPE 
                                  ,pi_new_format_mask       IN      nm_inv_type_attribs.ita_format_mask%TYPE 
                                  ,pi_new_exclusive_yn      IN      nm_inv_type_attribs.ita_exclusive%TYPE 
                                  ,pi_new_keep_history_yn   IN      nm_inv_type_attribs.ita_keep_history_yn%TYPE 
                                  ,pi_new_displayed_yn      IN      nm_inv_type_attribs.ita_displayed%TYPE 
                                  ,pi_new_disp_width        IN      nm_inv_type_attribs.ita_disp_width%TYPE 
                                  ,pi_new_inspectable_yn    IN      nm_inv_type_attribs.ita_inspectable%TYPE 
                                  ,pi_new_case              IN      nm_inv_type_attribs.ita_case%TYPE
                                  ,po_message_severity         OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor           OUT  sys_refcursor)
    IS
    --
    lr_db_nit_rec    nm_inv_types_all%ROWTYPE;
    lr_db_ita_rec    nm_inv_type_attribs_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    lv_validate_yn VARCHAR2(1);
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_ita_rec
        FROM nm_inv_type_attribs_all
       WHERE ita_inv_type = pi_asset_type
         AND ita_attrib_name = pi_attrib_name
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Attribute does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sequence'
                               ,pi_parameter_value => pi_new_disp_seq_no);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Format'
                               ,pi_parameter_value => pi_new_format);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Field Length'
                               ,pi_parameter_value => pi_new_fld_length);   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Screen Text'
                               ,pi_parameter_value => pi_new_scrn_text);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'View Attribute'
                               ,pi_parameter_value => pi_new_view_attri);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Column Name'
                               ,pi_parameter_value => pi_new_view_col_name);                        
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date); 
    --                                
    /*
    ||Do validation checks on y/n flags
    */
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_new_mandatory_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Keep History'
                          ,pi_parameter_value => pi_new_keep_history_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Queryable'
                          ,pi_parameter_value => pi_new_queryable_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Exclusive'
                          ,pi_parameter_value => pi_new_exclusive_yn);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Inspectable'
                          ,pi_parameter_value => pi_new_inspectable_yn);                          
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Displayed'
                          ,pi_parameter_value => pi_new_displayed_yn);                          
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF pi_old_format != pi_new_format
     THEN
        hig.valid_fk_hco(pi_hco_domain => 'DATA_FORMAT'
                        ,pi_hco_code   => pi_new_format);  
    END IF;      
    --
    IF pi_old_case != pi_new_case
     THEN
        hig.valid_fk_hco(pi_hco_domain => 'ATTRIBUTE_CASE'
                        ,pi_hco_code   => pi_new_case);  
    END IF;       
    --
    IF pi_old_format_mask != pi_new_format_mask
     OR (pi_old_format_mask IS NULL AND pi_new_format_mask IS NOT NULL)
     OR (pi_old_format_mask IS NOT NULL AND pi_new_format_mask IS NULL)
     THEN
        hig.valid_fk_hco(pi_hco_domain => 'DATE_FORMAT_MASK'
                        ,pi_hco_code   => pi_new_format_mask);  
    END IF; 
    /*
    ||validate units 
    */
    IF pi_old_units != pi_new_units
     OR (pi_old_units IS NULL AND pi_new_units IS NOT NULL)
     OR (pi_old_units IS NOT NULL AND pi_new_units IS NULL)
     THEN
       IF unit_exists(pi_unit_id => pi_new_units) != 'Y' 
        THEN
		       hig.raise_ner(pi_appl => 'HIG'
		       	            ,pi_id   => 30
                        ,pi_supplementary_info => 'Units');        
       END IF;
    END IF;
    --
    /*
    ||make sure view colname doesnt exist
    */
    IF pi_old_view_attri <> pi_new_view_attri 
     THEN
        IF asset_attribute_exists(pi_asset_type     => pi_asset_type
                                 ,pi_view_attribute => pi_new_view_attri) = 'Y' 
         THEN
            hig.raise_ner(pi_appl => 'HIG'
                         ,pi_id   => 29
                         ,pi_supplementary_info => 'View attribute on : '|| pi_new_scrn_text);    
        END IF;    
    END IF;
    /*
    ||If domain set then validate should be Y.
    */
    IF pi_new_id_domain IS NOT NULL
     THEN
       IF pi_new_id_domain <> pi_old_id_domain 
        THEN
          /*
          ||validate the domain
          */
          IF asset_domain_exists(pi_asset_domain => pi_new_id_domain) <> 'Y' 
           THEN
              hig.raise_ner(pi_appl => 'HIG'
                           ,pi_id   => 29
                           ,pi_supplementary_info => 'Asset Domain does not exist');    
          END IF;       
          --
          lv_validate_yn := 'Y';
       ELSE
          lv_validate_yn := 'N';
       END IF;     
       lv_validate_yn := 'Y';
    ELSE
       lv_validate_yn := 'N';
    END IF;
    --
    IF nm3flx.is_reserved_word(pi_new_view_col_name) 
     OR nm3flx.is_reserved_word(pi_new_view_attri)
      THEN
		    hig.raise_ner(pi_appl => 'NET'
		    	            ,pi_id   => 455);
    END IF;
    --
    IF pi_new_min IS NOT NULL 
     AND pi_new_max IS NOT NULL 
     AND pi_new_min > pi_new_max 
      THEN
        hig.raise_ner(pi_appl => 'NET'
        						 ,pi_id   => 455);
    END IF;
    --
    lr_db_nit_rec := nm3get.get_nit_all(pi_nit_inv_type => pi_asset_type);  
    --     
	  check_format(pi_table_name => lr_db_nit_rec.nit_table_name
                ,pi_col_name   => pi_attrib_name
	              ,pi_length     => pi_new_fld_length
                ,pi_dec_places => pi_new_dec_places);
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_ita_rec.ita_disp_seq_no != pi_old_disp_seq_no
     OR (lr_db_ita_rec.ita_disp_seq_no IS NULL AND pi_old_disp_seq_no IS NOT NULL)
     OR (lr_db_ita_rec.ita_disp_seq_no IS NOT NULL AND pi_old_disp_seq_no IS NULL)     
     --
     OR (lr_db_ita_rec.ita_mandatory_yn != pi_old_mandatory_yn)
     OR (lr_db_ita_rec.ita_mandatory_yn IS NULL AND pi_old_mandatory_yn IS NOT NULL)
     OR (lr_db_ita_rec.ita_mandatory_yn IS NOT NULL AND pi_old_mandatory_yn IS NULL)
     --
     OR (lr_db_ita_rec.ita_format != pi_old_format)
     OR (lr_db_ita_rec.ita_format IS NULL AND pi_old_format IS NOT NULL)
     OR (lr_db_ita_rec.ita_format IS NOT NULL AND pi_old_format IS NULL)
     --
     OR (lr_db_ita_rec.ita_fld_length != pi_old_fld_length)
     OR (lr_db_ita_rec.ita_fld_length IS NULL AND pi_old_fld_length IS NOT NULL)
     OR (lr_db_ita_rec.ita_fld_length IS NOT NULL AND pi_old_fld_length IS NULL)
     --    
     OR (lr_db_ita_rec.ita_dec_places != pi_old_dec_places)
     OR (lr_db_ita_rec.ita_dec_places IS NULL AND pi_old_dec_places IS NOT NULL)
     OR (lr_db_ita_rec.ita_dec_places IS NOT NULL AND pi_old_dec_places IS NULL)     
     --
     OR (lr_db_ita_rec.ita_scrn_text != pi_old_scrn_text)
     OR (lr_db_ita_rec.ita_scrn_text IS NULL AND pi_old_scrn_text IS NOT NULL)
     OR (lr_db_ita_rec.ita_scrn_text IS NOT NULL AND pi_old_scrn_text IS NULL)
     --
     OR (lr_db_ita_rec.ita_id_domain != pi_old_id_domain)
     OR (lr_db_ita_rec.ita_id_domain IS NULL AND pi_old_id_domain IS NOT NULL)
     OR (lr_db_ita_rec.ita_id_domain IS NOT NULL AND pi_old_id_domain IS NULL)
     --
     OR (lr_db_ita_rec.ita_dtp_code != pi_old_dtp_code)
     OR (lr_db_ita_rec.ita_dtp_code IS NULL AND pi_old_dtp_code IS NOT NULL)
     OR (lr_db_ita_rec.ita_dtp_code IS NOT NULL AND pi_old_dtp_code IS NULL)
     --    
     OR (lr_db_ita_rec.ita_max != pi_old_max)
     OR (lr_db_ita_rec.ita_max IS NULL AND pi_old_max IS NOT NULL)
     OR (lr_db_ita_rec.ita_max IS NOT NULL AND pi_old_max IS NULL)     
     --
     OR (lr_db_ita_rec.ita_min != pi_old_min)
     OR (lr_db_ita_rec.ita_min IS NULL AND pi_old_min IS NOT NULL)
     OR (lr_db_ita_rec.ita_min IS NOT NULL AND pi_old_min IS NULL)
     --
     OR (lr_db_ita_rec.ita_view_attri != pi_old_view_attri)
     OR (lr_db_ita_rec.ita_view_attri IS NULL AND pi_old_view_attri IS NOT NULL)
     OR (lr_db_ita_rec.ita_view_attri IS NOT NULL AND pi_old_view_attri IS NULL)
     --
     OR (lr_db_ita_rec.ita_view_col_name != pi_old_view_col_name)
     OR (lr_db_ita_rec.ita_view_col_name IS NULL AND pi_old_view_col_name IS NOT NULL)
     OR (lr_db_ita_rec.ita_view_col_name IS NOT NULL AND pi_old_view_col_name IS NULL)
     --    
     OR (lr_db_ita_rec.ita_start_date != pi_old_start_date)
     OR (lr_db_ita_rec.ita_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_ita_rec.ita_start_date IS NOT NULL AND pi_old_start_date IS NULL)     
     --
     OR (lr_db_ita_rec.ita_end_date != pi_old_end_date)
     OR (lr_db_ita_rec.ita_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_ita_rec.ita_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     OR (lr_db_ita_rec.ita_queryable != pi_old_queryable_yn)
     OR (lr_db_ita_rec.ita_queryable IS NULL AND pi_old_queryable_yn IS NOT NULL)
     OR (lr_db_ita_rec.ita_queryable IS NOT NULL AND pi_old_queryable_yn IS NULL)
     --
     OR (lr_db_ita_rec.ita_ukpms_param_no != pi_old_ukpms_param_no)
     OR (lr_db_ita_rec.ita_ukpms_param_no IS NULL AND pi_old_ukpms_param_no IS NOT NULL)
     OR (lr_db_ita_rec.ita_ukpms_param_no IS NOT NULL AND pi_old_ukpms_param_no IS NULL)     
     --
     OR (lr_db_ita_rec.ita_units != pi_old_units)
     OR (lr_db_ita_rec.ita_units IS NULL AND pi_old_units IS NOT NULL)
     OR (lr_db_ita_rec.ita_units IS NOT NULL AND pi_old_units IS NULL)
     --
     OR (lr_db_ita_rec.ita_format_mask != pi_old_format_mask)
     OR (lr_db_ita_rec.ita_format_mask IS NULL AND pi_old_format_mask IS NOT NULL)
     OR (lr_db_ita_rec.ita_format_mask IS NOT NULL AND pi_old_format_mask IS NULL)
     --
     OR (lr_db_ita_rec.ita_exclusive != pi_old_exclusive_yn)
     OR (lr_db_ita_rec.ita_exclusive IS NULL AND pi_old_exclusive_yn IS NOT NULL)
     OR (lr_db_ita_rec.ita_exclusive IS NOT NULL AND pi_old_exclusive_yn IS NULL)          
     --
     OR (lr_db_ita_rec.ita_keep_history_yn != pi_old_keep_history_yn)
     OR (lr_db_ita_rec.ita_keep_history_yn IS NULL AND pi_old_keep_history_yn IS NOT NULL)
     OR (lr_db_ita_rec.ita_keep_history_yn IS NOT NULL AND pi_old_keep_history_yn IS NULL)
     --
     OR (lr_db_ita_rec.ita_displayed != pi_old_displayed_yn)
     OR (lr_db_ita_rec.ita_displayed IS NULL AND pi_old_displayed_yn IS NOT NULL)
     OR (lr_db_ita_rec.ita_displayed IS NOT NULL AND pi_old_displayed_yn IS NULL)     
     --
     OR (lr_db_ita_rec.ita_disp_width != pi_old_disp_width)
     OR (lr_db_ita_rec.ita_disp_width IS NULL AND pi_old_disp_width IS NOT NULL)
     OR (lr_db_ita_rec.ita_disp_width IS NOT NULL AND pi_old_disp_width IS NULL)
     --
     OR (lr_db_ita_rec.ita_inspectable != pi_old_inspectable_yn)
     OR (lr_db_ita_rec.ita_inspectable IS NULL AND pi_old_inspectable_yn IS NOT NULL)
     OR (lr_db_ita_rec.ita_inspectable IS NOT NULL AND pi_old_inspectable_yn IS NULL)
     --
     OR (lr_db_ita_rec.ita_case != pi_old_case)
     OR (lr_db_ita_rec.ita_case IS NULL AND pi_old_case IS NOT NULL)
     OR (lr_db_ita_rec.ita_case IS NOT NULL AND pi_old_case IS NULL)          
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_disp_seq_no != pi_new_disp_seq_no
       OR (pi_old_disp_seq_no IS NULL AND pi_new_disp_seq_no IS NOT NULL)
       OR (pi_old_disp_seq_no IS NOT NULL AND pi_new_disp_seq_no IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_mandatory_yn != pi_new_mandatory_yn
       OR (pi_old_mandatory_yn IS NULL AND pi_new_mandatory_yn IS NOT NULL)
       OR (pi_old_mandatory_yn IS NOT NULL AND pi_new_mandatory_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_format != pi_new_format
       OR (pi_old_format IS NULL AND pi_new_format IS NOT NULL)
       OR (pi_old_format IS NOT NULL AND pi_new_format IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_fld_length != pi_new_fld_length
       OR (pi_old_fld_length IS NULL AND pi_new_fld_length IS NOT NULL)
       OR (pi_old_fld_length IS NOT NULL AND pi_new_fld_length IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_dec_places != pi_new_dec_places
       OR (pi_old_dec_places IS NULL AND pi_new_dec_places IS NOT NULL)
       OR (pi_old_dec_places IS NOT NULL AND pi_new_dec_places IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_scrn_text != pi_new_scrn_text
       OR (pi_old_scrn_text IS NULL AND pi_new_scrn_text IS NOT NULL)
       OR (pi_old_scrn_text IS NOT NULL AND pi_new_scrn_text IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_id_domain != pi_new_id_domain
       OR (pi_old_id_domain IS NULL AND pi_new_id_domain IS NOT NULL)
       OR (pi_old_id_domain IS NOT NULL AND pi_new_id_domain IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_dtp_code != pi_new_dtp_code
       OR (pi_old_dtp_code IS NULL AND pi_new_dtp_code IS NOT NULL)
       OR (pi_old_dtp_code IS NOT NULL AND pi_new_dtp_code IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_max != pi_new_max
       OR (pi_old_max IS NULL AND pi_new_max IS NOT NULL)
       OR (pi_old_max IS NOT NULL AND pi_new_max IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_min != pi_new_min
       OR (pi_old_min IS NULL AND pi_new_min IS NOT NULL)
       OR (pi_old_min IS NOT NULL AND pi_new_min IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_view_attri != pi_new_view_attri
       OR (pi_old_view_attri IS NULL AND pi_new_view_attri IS NOT NULL)
       OR (pi_old_view_attri IS NOT NULL AND pi_new_view_attri IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_view_col_name != pi_new_view_col_name
       OR (pi_old_view_col_name IS NULL AND pi_new_view_col_name IS NOT NULL)
       OR (pi_old_view_col_name IS NOT NULL AND pi_new_view_col_name IS NULL)
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
      IF pi_old_queryable_yn != pi_new_queryable_yn
       OR (pi_old_queryable_yn IS NULL AND pi_new_queryable_yn IS NOT NULL)
       OR (pi_old_queryable_yn IS NOT NULL AND pi_new_queryable_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_ukpms_param_no != pi_new_ukpms_param_no
       OR (pi_old_ukpms_param_no IS NULL AND pi_new_ukpms_param_no IS NOT NULL)
       OR (pi_old_ukpms_param_no IS NOT NULL AND pi_new_ukpms_param_no IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_units != pi_new_units
       OR (pi_old_units IS NULL AND pi_new_units IS NOT NULL)
       OR (pi_old_units IS NOT NULL AND pi_new_units IS NULL)
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
      IF pi_old_exclusive_yn != pi_new_exclusive_yn
       OR (pi_old_exclusive_yn IS NULL AND pi_new_exclusive_yn IS NOT NULL)
       OR (pi_old_exclusive_yn IS NOT NULL AND pi_new_exclusive_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_keep_history_yn != pi_new_keep_history_yn
       OR (pi_old_keep_history_yn IS NULL AND pi_new_keep_history_yn IS NOT NULL)
       OR (pi_old_keep_history_yn IS NOT NULL AND pi_new_keep_history_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_displayed_yn != pi_new_displayed_yn
       OR (pi_old_displayed_yn IS NULL AND pi_new_displayed_yn IS NOT NULL)
       OR (pi_old_displayed_yn IS NOT NULL AND pi_new_displayed_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_disp_width != pi_new_disp_width
       OR (pi_old_disp_width IS NULL AND pi_new_disp_width IS NOT NULL)
       OR (pi_old_disp_width IS NOT NULL AND pi_new_disp_width IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_inspectable_yn != pi_new_inspectable_yn
       OR (pi_old_inspectable_yn IS NULL AND pi_new_inspectable_yn IS NOT NULL)
       OR (pi_old_inspectable_yn IS NOT NULL AND pi_new_inspectable_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_case != pi_new_case
       OR (pi_old_case IS NULL AND pi_new_case IS NOT NULL)
       OR (pi_old_case IS NOT NULL AND pi_new_case IS NULL)
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
        UPDATE nm_inv_type_attribs_all
           SET ita_disp_seq_no      = pi_new_disp_seq_no          
              ,ita_mandatory_yn     = pi_new_mandatory_yn         
              ,ita_format           = UPPER(pi_new_format) 
              ,ita_fld_length       = pi_new_fld_length           
              ,ita_dec_places       = pi_new_dec_places           
              ,ita_scrn_text        = pi_new_scrn_text            
              ,ita_id_domain        = UPPER(pi_new_id_domain)     
              ,ita_validate_yn      = lv_validate_yn          
              ,ita_dtp_code         = UPPER(pi_new_dtp_code) 
              ,ita_max              = pi_new_max                  
              ,ita_min              = pi_new_min                  
              ,ita_view_attri       = UPPER(pi_new_view_attri) 
              ,ita_view_col_name    = UPPER(pi_new_view_col_name) 
              ,ita_start_date       = TRUNC(pi_new_start_date)      
              ,ita_end_date         = TRUNC(pi_new_end_date)           
              ,ita_queryable        = pi_new_queryable_yn
              ,ita_ukpms_param_no   = pi_new_ukpms_param_no       
              ,ita_units            = pi_new_units                
              ,ita_format_mask      = UPPER(pi_new_format_mask) 
              ,ita_exclusive        = pi_new_exclusive_yn
              ,ita_keep_history_yn  = pi_new_keep_history_yn                
              ,ita_displayed        = pi_new_displayed_yn
              ,ita_disp_width       = pi_new_disp_width           
              ,ita_inspectable      = pi_new_inspectable_yn          
              ,ita_case             = UPPER(pi_new_case)
        WHERE ita_inv_type = lr_db_ita_rec.ita_inv_type
          AND ita_attrib_name = lr_db_ita_rec.ita_attrib_name;
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
  END update_asset_attribute; 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_attribute(pi_asset_type          IN      nm_inv_type_attribs.ita_inv_type%TYPE    
                                  ,pi_attrib_name         IN      nm_inv_type_attribs.ita_attrib_name%TYPE
                                  ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor         OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;   
    --
    IF asset_attribute_exists(pi_asset_type  => pi_asset_type
                             ,pi_attrib_name => pi_attrib_name) <> 'Y'      
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset attribute doesnt exist');    
    END IF;
    --
    DELETE 
      FROM nm_inv_type_attrib_bandings
     WHERE itb_inv_type = pi_asset_type 
       AND itb_attrib_name = pi_attrib_name;
    --
    UPDATE nm_inv_type_attribs_all
       SET ita_end_date = TRUNC(SYSDATE)
     WHERE ita_inv_type = pi_asset_type
       AND ita_attrib_name = pi_attrib_name
       AND ita_end_date IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_attribute;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_network(pi_asset_type         IN      nm_inv_nw_all.nin_nit_inv_code%TYPE    
                                ,pi_nw_type            IN      nm_inv_nw_all.nin_nw_type%TYPE
                                ,pi_mandatory_yn       IN      nm_inv_nw_all.nin_loc_mandatory%TYPE 
                                ,pi_start_date         IN      nm_inv_nw_all.nin_start_date%TYPE 
                                ,pi_end_date           IN      nm_inv_nw_all.nin_end_date%TYPE 
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types_all%ROWTYPE;
    lv_validate_yn VARCHAR2(1);
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;    
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'NW Type'
                               ,pi_parameter_value => pi_nw_type);                      
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date); 
    --                                
    /*
    ||Do validation checks on y/n flags
    */
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Location Mandatory'
                          ,pi_parameter_value => pi_mandatory_yn);                         
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF asset_nw_exists(pi_asset_type => pi_asset_type
                      ,pi_nw_type    => pi_nw_type) = 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Network already exists');    
    END IF;
    --
    INSERT 
      INTO nm_inv_nw_all
           (nin_nit_inv_code              
           ,nin_nw_type           
           ,nin_loc_mandatory        
           ,nin_start_date           
           ,nin_end_date)
    VALUES (pi_asset_type              
           ,UPPER(pi_nw_type)
           ,pi_mandatory_yn
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
  END create_asset_network;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_network(pi_asset_type         IN      nm_inv_nw_all.nin_nit_inv_code%TYPE    
                                ,pi_old_nw_type        IN      nm_inv_nw_all.nin_nw_type%TYPE
                                ,pi_old_mandatory_yn   IN      nm_inv_nw_all.nin_loc_mandatory%TYPE 
                                ,pi_old_end_date       IN      nm_inv_nw_all.nin_end_date%TYPE 
                                ,pi_new_nw_type        IN      nm_inv_nw_all.nin_nw_type%TYPE
                                ,pi_new_mandatory_yn   IN      nm_inv_nw_all.nin_loc_mandatory%TYPE 
                                ,pi_new_end_date       IN      nm_inv_nw_all.nin_end_date%TYPE
                                ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
    lr_db_nin_rec    nm_inv_nw_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_nin_rec
        FROM nm_inv_nw_all
       WHERE nin_nit_inv_code = pi_asset_type
         AND nin_nw_type = pi_old_nw_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Network does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'NW Type'
                               ,pi_parameter_value => pi_new_nw_type);                      
    --                                
    /*
    ||Do validation checks on y/n flags
    */
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Location Mandatory'
                          ,pi_parameter_value => pi_new_mandatory_yn);                         
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF pi_old_nw_type <> pi_new_nw_type
     THEN
       IF asset_nw_exists(pi_asset_type => pi_asset_type
                         ,pi_nw_type    => pi_new_nw_type) = 'Y' 
        THEN
           hig.raise_ner(pi_appl => 'HIG'
                        ,pi_id   => 64
                        ,pi_supplementary_info => 'Asset Network already exists');    
       END IF;
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_nin_rec.nin_nw_type != pi_old_nw_type
     OR (lr_db_nin_rec.nin_nw_type IS NULL AND pi_old_nw_type IS NOT NULL)
     OR (lr_db_nin_rec.nin_nw_type IS NOT NULL AND pi_old_nw_type IS NULL)
     --    
     OR (lr_db_nin_rec.nin_loc_mandatory != pi_old_mandatory_yn)
     OR (lr_db_nin_rec.nin_loc_mandatory IS NULL AND pi_old_mandatory_yn IS NOT NULL)
     OR (lr_db_nin_rec.nin_loc_mandatory IS NOT NULL AND pi_old_mandatory_yn IS NULL)     
     --
     OR (lr_db_nin_rec.nin_end_date != pi_old_end_date)
     OR (lr_db_nin_rec.nin_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_nin_rec.nin_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --      
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_nw_type != pi_new_nw_type
       OR (pi_old_nw_type IS NULL AND pi_new_nw_type IS NOT NULL)
       OR (pi_old_nw_type IS NOT NULL AND pi_new_nw_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_mandatory_yn != pi_new_mandatory_yn
       OR (pi_old_mandatory_yn IS NULL AND pi_new_mandatory_yn IS NOT NULL)
       OR (pi_old_mandatory_yn IS NOT NULL AND pi_new_mandatory_yn IS NULL)
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
        UPDATE nm_inv_nw_all
           SET nin_nw_type       = pi_new_nw_type      
              ,nin_loc_mandatory = pi_new_mandatory_yn
              ,nin_end_date      = TRUNC(pi_new_end_date)
         WHERE nin_nit_inv_code  = lr_db_nin_rec.nin_nit_inv_code
           AND nin_nw_type       = lr_db_nin_rec.nin_nw_type;
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
  END update_asset_network; 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_network(pi_asset_type          IN      nm_inv_nw_all.nin_nit_inv_code%TYPE    
                                ,pi_nw_type             IN      nm_inv_nw_all.nin_nw_type%TYPE
                                ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    IF asset_nw_exists(pi_asset_type  => pi_asset_type
                      ,pi_nw_type     => pi_nw_type) <> 'Y'      
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Network doesnt exist');    
    END IF;
    --
    UPDATE nm_inv_nw_all
       SET nin_end_date = TRUNC(SYSDATE)
     WHERE nin_nit_inv_code = pi_asset_type
       AND nin_nw_type = pi_nw_type
       AND nin_end_date IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_network;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_role(pi_asset_type         IN      nm_inv_type_roles.itr_inv_type%TYPE    
                             ,pi_role               IN      nm_inv_type_roles.itr_hro_role%TYPE
                             ,pi_mode               IN      nm_inv_type_roles.itr_mode%TYPE
                             ,po_message_severity       OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types_all%ROWTYPE;
    lv_validate_yn VARCHAR2(1);
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_role);                      
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value => pi_mode);                       
    --
    IF asset_role_exists(pi_asset_type => pi_asset_type
                        ,pi_role       => pi_role) = 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 64
                     ,pi_supplementary_info => 'Asset Role exists');    
    END IF;
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF role_exists(pi_role => pi_role) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Role does not exist');    
    END IF;
    --
    INSERT 
      INTO nm_inv_type_roles
           (itr_inv_type              
           ,itr_hro_role      
           ,itr_mode)
    VALUES (pi_asset_type              
           ,pi_role
           ,pi_mode);     
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_asset_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_role(pi_asset_type         IN      nm_inv_type_roles.itr_inv_type%TYPE    
                             ,pi_old_role           IN      nm_inv_type_roles.itr_hro_role%TYPE
                             ,pi_old_mode           IN      nm_inv_type_roles.itr_mode%TYPE
                             ,pi_new_role           IN      nm_inv_type_roles.itr_hro_role%TYPE
                             ,pi_new_mode           IN      nm_inv_type_roles.itr_mode%TYPE
                             ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
    lr_db_itr_rec    nm_inv_type_roles%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_itr_rec
        FROM nm_inv_type_roles
       WHERE itr_inv_type = pi_asset_type
         AND itr_hro_role = pi_old_role
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Network does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Role'
                               ,pi_parameter_value => pi_new_role);                      
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Mode'
                               ,pi_parameter_value => pi_new_mode);                       
    --
    IF pi_old_role <> pi_new_role
     THEN
       IF asset_role_exists(pi_asset_type => pi_asset_type
                           ,pi_role       => pi_new_role) = 'Y' 
        THEN
           hig.raise_ner(pi_appl               => 'HIG'
                        ,pi_id                 => 64
                        ,pi_supplementary_info => 'Asset Role exists');    
       END IF;
    END IF;
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF role_exists(pi_role => pi_new_role) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Role does not exist');    
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_itr_rec.itr_hro_role != pi_old_role
     OR (lr_db_itr_rec.itr_hro_role IS NULL AND pi_old_role IS NOT NULL)
     OR (lr_db_itr_rec.itr_hro_role IS NOT NULL AND pi_old_role IS NULL)
     --    
     OR (lr_db_itr_rec.itr_mode != pi_old_mode)
     OR (lr_db_itr_rec.itr_mode IS NULL AND pi_old_mode IS NOT NULL)
     OR (lr_db_itr_rec.itr_mode IS NOT NULL AND pi_old_mode IS NULL)     
     --      
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
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
        UPDATE nm_inv_type_roles
           SET itr_hro_role  = pi_new_role     
              ,itr_mode      = pi_new_mode
         WHERE itr_inv_type  = lr_db_itr_rec.itr_inv_type
           AND itr_hro_role  = lr_db_itr_rec.itr_hro_role;
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
  END update_asset_role; 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_role(pi_asset_type          IN      nm_inv_type_roles.itr_inv_type%TYPE    
                             ,pi_role                IN      nm_inv_type_roles.itr_hro_role%TYPE
                             ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor         OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --
    IF asset_role_exists(pi_asset_type  => pi_asset_type
                        ,pi_role        => pi_role) <> 'Y'      
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Role doesnt exist');    
    END IF;
    --
    DELETE 
      FROM nm_inv_type_roles
     WHERE itr_inv_type = pi_asset_type
       AND itr_hro_role = pi_role;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_role;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset_grouping(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE    
                                 ,pi_parent_asset_type  IN      nm_inv_type_groupings_all.itg_parent_inv_type%TYPE
                                 ,pi_mandatory_yn       IN      nm_inv_type_groupings_all.itg_mandatory%TYPE
                                 ,pi_relation           IN      nm_inv_type_groupings_all.itg_relation%TYPE
                                 ,pi_start_date         IN      nm_inv_type_groupings_all.itg_start_date%TYPE
                                 ,pi_end_date           IN      nm_inv_type_groupings_all.itg_end_date%TYPE
                                 ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types_all%ROWTYPE;
    lv_validate_yn VARCHAR2(1);
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Asset Type'
                               ,pi_parameter_value => pi_parent_asset_type);                      
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Relation'
                               ,pi_parameter_value => pi_relation);                                 
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Location Mandatory'
                          ,pi_parameter_value => pi_mandatory_yn); 
    --                          
    IF asset_grouping_exists(pi_asset_type              => pi_asset_type
                            ,pi_parent_asset_type       => pi_parent_asset_type
                            ,pi_start_date              => pi_start_date) = 'Y' 
     THEN
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 64
                     ,pi_supplementary_info => 'Asset Grouping exists');    
    END IF;
    --
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF asset_type_exists(pi_asset_type => pi_parent_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Parent Asset Type does not exist');    
    END IF;    
    --
    hig.valid_fk_hco(pi_hco_domain => 'INV_RELATION'
                    ,pi_hco_code   => pi_relation);
    --
    INSERT 
      INTO nm_inv_type_groupings_all
           (itg_inv_type      
           ,itg_parent_inv_type
           ,itg_mandatory
           ,itg_relation
           ,itg_start_date
           ,itg_end_date)
    VALUES (pi_asset_type              
           ,pi_parent_asset_type
           ,pi_mandatory_yn
           ,pi_relation
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
  END create_asset_grouping;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset_grouping(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                                 ,pi_parent_asset_type  IN      nm_inv_type_groupings_all.itg_parent_inv_type%TYPE
                                 ,pi_start_date         IN      nm_inv_type_groupings_all.itg_start_date%TYPE  
                                 ,pi_old_mandatory_yn   IN      nm_inv_type_groupings_all.itg_mandatory%TYPE
                                 ,pi_old_relation       IN      nm_inv_type_groupings_all.itg_relation%TYPE
                                 ,pi_old_end_date       IN      nm_inv_type_groupings_all.itg_end_date%TYPE
                                 ,pi_new_mandatory_yn   IN      nm_inv_type_groupings_all.itg_mandatory%TYPE
                                 ,pi_new_relation       IN      nm_inv_type_groupings_all.itg_relation%TYPE
                                 ,pi_new_end_date       IN      nm_inv_type_groupings_all.itg_end_date%TYPE                                 
                                 ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
    lr_db_itg_rec    nm_inv_type_groupings_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_itg_rec
        FROM nm_inv_type_groupings_all
       WHERE itg_inv_type = pi_asset_type
         AND itg_parent_inv_type = pi_parent_asset_type
         AND itg_start_date = pi_start_date
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Asset Grouping does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --    
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_asset_type);               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Relation'
                               ,pi_parameter_value => pi_new_relation);                      
    --    
    awlrs_util.validate_yn(pi_parameter_desc  => 'Location Mandatory'
                          ,pi_parameter_value => pi_new_mandatory_yn); 
    --                          
    IF asset_type_exists(pi_asset_type => pi_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Type does not exist');    
    END IF;
    --
    IF asset_type_exists(pi_asset_type => pi_parent_asset_type) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Parent Asset Type does not exist');    
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_itg_rec.itg_mandatory != pi_old_mandatory_yn
     OR (lr_db_itg_rec.itg_mandatory IS NULL AND pi_old_mandatory_yn IS NOT NULL)
     OR (lr_db_itg_rec.itg_mandatory IS NOT NULL AND pi_old_mandatory_yn IS NULL)
     --    
     OR (lr_db_itg_rec.itg_relation != pi_old_relation)
     OR (lr_db_itg_rec.itg_relation IS NULL AND pi_old_relation IS NOT NULL)
     OR (lr_db_itg_rec.itg_relation IS NOT NULL AND pi_old_relation IS NULL)     
     --
     OR (lr_db_itg_rec.itg_end_date != pi_old_end_date)
     OR (lr_db_itg_rec.itg_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_itg_rec.itg_end_date IS NOT NULL AND pi_old_end_date IS NULL)     
     --      
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_mandatory_yn != pi_new_mandatory_yn
       OR (pi_old_mandatory_yn IS NULL AND pi_new_mandatory_yn IS NOT NULL)
       OR (pi_old_mandatory_yn IS NOT NULL AND pi_new_mandatory_yn IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_relation != pi_new_relation
       OR (pi_old_relation IS NULL AND pi_new_relation IS NOT NULL)
       OR (pi_old_relation IS NOT NULL AND pi_new_relation IS NULL)
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
        UPDATE nm_inv_type_groupings_all
           SET itg_mandatory  = pi_new_mandatory_yn
              ,itg_relation   = pi_new_relation
              ,itg_end_date   = TRUNC(pi_new_end_date)
         WHERE itg_inv_type = pi_asset_type
           AND itg_parent_inv_type = pi_parent_asset_type
           AND itg_start_date = pi_start_date;
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
  END update_asset_grouping; 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_asset_grouping(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                                 ,pi_parent_asset_type  IN      nm_inv_type_groupings_all.itg_parent_inv_type%TYPE
                                 ,pi_start_date         IN      nm_inv_type_groupings_all.itg_start_date%TYPE  
                                 ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    IF asset_grouping_exists(pi_asset_type        => pi_asset_type
                            ,pi_parent_asset_type => pi_parent_asset_type
                            ,pi_start_date        => pi_start_date) <> 'Y'      
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Asset Grouping doesnt exist');    
    END IF;
    --
    UPDATE nm_inv_type_groupings_all
       SET itg_end_date = TRUNC(SYSDATE)
     WHERE itg_inv_type = pi_asset_type
       AND itg_parent_inv_type = pi_parent_asset_type
       AND itg_start_date = pi_start_date
       AND itg_end_date IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_asset_grouping;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE gen_asset_views(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                           ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor        OUT  sys_refcursor)
    IS
    --
    lv_view_name VARCHAR2(30);
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    nm3inv.Create_inv_view(pi_asset_type, FALSE, lv_view_name);
	  --create view joined to network
	  nm3inv.Create_inv_view(pi_asset_type, TRUE, lv_view_name);
	  --create inv on a route view
	  nm3inv_view.create_inv_on_route_view (pi_asset_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END gen_asset_views;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_view(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                          ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor        OUT  sys_refcursor
                          ,po_cursor                OUT  sys_refcursor)
    IS
    --
    lv_view_name VARCHAR2(30);
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT nm3inv.get_create_inv_view_text(pi_asset_type)
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
  END get_asset_view;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_tree(pi_asset_type         IN      nm_inv_type_groupings_all.itg_inv_type%TYPE
                          ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor        OUT  sys_refcursor
                          ,po_cursor                OUT  sys_refcursor)
    IS
    --
    lv_view_name VARCHAR2(30);
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT 1                   level_
            ,pi_asset_type       label_
            ,pi_asset_type       asset_type
            ,null                parent_asset_type
        FROM dual
       UNION
      SELECT level+1              level_
            ,itg_inv_type         label_
            ,itg_inv_type         asset_type 
            ,itg_parent_inv_type  parent_asset_type
        FROM nm_inv_type_groupings 
     CONNECT BY PRIOR itg_inv_type = itg_parent_inv_type 
       START WITH itg_parent_inv_type = pi_asset_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_asset_tree;
  
  --
END awlrs_metaast_api;