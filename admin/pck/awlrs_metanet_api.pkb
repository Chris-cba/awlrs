/* Formatted on 06/06/2019 16:27:19 (QP5 v5.300) */
CREATE OR REPLACE PACKAGE BODY awlrs_metanet_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_metanet_api.pkb-arc   1.11   Jun 18 2020 16:51:08   Barbara.Odriscoll  $
  --       Date into PVCS   : $Date:   Jun 18 2020 16:51:08  $
  --       Module Name      : $Workfile:   awlrs_metanet_api.pkb  $
  --       Date fetched Out : $Modtime:   Jun 18 2020 09:21:54  $
  --       Version          : $Revision:   1.11  $
  --
  -----------------------------------------------------------------------------------
  -- Copyright (c) 2019 Bentley Systems Incorporated.  All rights reserved.
  -----------------------------------------------------------------------------------
  --

  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT  VARCHAR2(2000) := '"$Revision:   1.11  $"';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_metanet_api';
  --
  --Constant Variables
  c_Xref_Rel_Type CONSTANT Hig_Domains.Hdo_Domain%TYPE := 'XREF_REL_TYPE';
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
  PROCEDURE get_node_types(po_message_severity OUT  hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT  SYS_REFCURSOR
                          ,po_cursor           OUT  SYS_REFCURSOR)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nnt_type            node_type
          ,nnt_name            name
          ,nnt_descr           description
          ,nnt_no_name_format  node_name_format
      FROM nm_node_types
     ORDER BY nnt_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_node_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_node_type(pi_node_type           IN      nm_node_types.nnt_type%TYPE
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT SYS_REFCURSOR
                         ,po_cursor                  OUT SYS_REFCURSOR)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nnt_type            node_type
          ,nnt_name            name
          ,nnt_descr           description
          ,nnt_no_name_format  node_name_format
      FROM nm_node_types
     WHERE nnt_type = pi_node_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_node_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_node_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                ,pi_filter_operators     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                ,pi_filter_values_1      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                ,pi_filter_values_2      IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                ,pi_order_columns        IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                ,pi_order_asc_desc       IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                ,pi_skip_n_rows          IN     PLS_INTEGER
                                ,pi_pagesize             IN     PLS_INTEGER
                                ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor          OUT SYS_REFCURSOR
                                ,po_cursor                  OUT SYS_REFCURSOR)
    IS
      --
      lv_lower_index      PLS_INTEGER;
      lv_upper_index      PLS_INTEGER;
      lv_row_restriction  nm3type.max_varchar2;
      lv_order_by         nm3type.max_varchar2;
      lv_filter           nm3type.max_varchar2;
      --
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nnt_type            node_type
                                                    ,nnt_name            name
                                                    ,nnt_descr           description
                                                    ,nnt_no_name_format  node_name_format         
                                              FROM   nm_node_types ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  node_type'
                                                  ||',name'
                                                  ||',description'
                                                  ||',node_name_format'
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
      awlrs_util.add_column_data(pi_cursor_col => 'node_type'
                                ,pi_query_col  => 'nnt_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'name'
                                ,pi_query_col  => 'nnt_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nnt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'node_name_format'
                                ,pi_query_col  => 'nnt_no_name_format'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nnt_type')||') a)'
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_node_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_node_name_format(pi_parameter_desc  IN hig_options.hop_id%TYPE
                                     ,pi_parameter_value IN hig_options.hop_value%TYPE)
  IS
  --
  lv_temp nm_node_types.nnt_no_name_format%TYPE;
  --
  BEGIN
    --
  IF pi_parameter_value IS NOT NULL THEN
    --
       lv_temp := TO_CHAR(0, pi_parameter_value);

       IF INSTR(lv_temp, '#') != 0  THEN

           hig.raise_ner(pi_appl               => 'HIG'
                        ,pi_id                 => 70
                        );
       END IF;
    --
  END IF;
  --

  END validate_node_name_format;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION node_type_exists(pi_node_type IN nm_node_types.nnt_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_node_type IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_node_types
         WHERE nnt_type = UPPER(pi_node_type);
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
  END node_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION unit_type_exists(pi_units   IN  nm_types.nt_length_unit%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_units IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_units
         WHERE un_unit_id   = pi_units;
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
  END unit_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION admin_type_exists(pi_admin_type  IN  nm_types.nt_admin_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_au_types
     WHERE nat_admin_type =  pi_admin_type;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END admin_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION group_type_exists(pi_group_type   IN nm_group_types_all.ngt_group_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_group_type IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_group_types
         WHERE ngt_group_type = UPPER(pi_group_type);
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
  END group_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION group_type_exists(pi_network_type IN nm_group_types_all.ngt_nt_type%TYPE
                            ,pi_group_type   IN nm_group_types_all.ngt_group_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_group_type IS NOT NULL
      THEN
        SELECT 'Y'
          INTO lv_exists
          FROM nm_group_types
         WHERE ngt_nt_type    = UPPER(pi_network_type)
           AND ngt_group_type = UPPER(pi_group_type);
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
  END group_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION nt_grouping_exists(pi_group_type IN  nm_group_types_all.ngt_group_type%TYPE
                             ,pi_nt_type    IN  nm_nt_groupings_all.nng_nt_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_nt_groupings
     WHERE nng_group_type = UPPER(pi_group_type)
       AND nng_nt_type    = UPPER(pi_nt_type);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END nt_grouping_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION group_relation_exists(pi_parent_group_type IN  nm_group_relations_all.ngr_parent_group_type%TYPE   
                                ,pi_child_group_type  IN  nm_group_relations_all.ngr_child_group_type%TYPE)
       RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_group_relations
     WHERE ngr_parent_group_type = UPPER(pi_parent_group_type)
       AND ngr_child_group_type  = UPPER(pi_child_group_type);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END group_relation_exists;
  --
  -----------------------------------------------------------------------------
  --
  
  FUNCTION network_type_exists(pi_network_type IN  nm_types.nt_type%TYPE)
       RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_types
     WHERE nt_type = UPPER(pi_network_type);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END network_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  
  FUNCTION sub_class_exists(pi_nt_type      IN   nm_type_subclass.nsc_nw_type%TYPE
                           ,pi_sub_class    IN   nm_type_subclass.nsc_sub_class%TYPE)
       RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_type_subclass
     WHERE nsc_nw_type   = UPPER(pi_nt_type)
       AND nsc_sub_class = UPPER(pi_sub_class);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END sub_class_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION column_type_exists(pi_column_type  IN  nm_type_columns.ntc_column_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM hig_codes 
     WHERE hco_domain = 'DATA_FORMAT'
       AND hco_code   =  UPPER(pi_column_type);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END column_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION column_name_exists(pi_column_name  IN  nm_type_columns.ntc_column_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_column_name IS NOT NULL 
     THEN  
        SELECT 'Y'
          INTO lv_exists
          FROM all_tab_columns
         WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
           AND table_name  = 'NM_ELEMENTS'
           AND UPPER(column_name) = UPPER(pi_column_name);
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
  END column_name_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION seq_name_exists(pi_seq_name IN  nm_type_columns.ntc_seq_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_seq_name IS NOT NULL 
     THEN  
        SELECT 'Y'
          INTO lv_exists
          FROM all_sequences 
         WHERE sequence_owner = sys_context('NM3CORE','APPLICATION_OWNER')
           AND sequence_name  = pi_seq_name;
    ELSE  
        lv_exists := 'Y';  
    END IF;         
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      RETURN lv_exists;
      --
  END seq_name_exists;
    
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION domain_exists(pi_domain IN hig_codes.hco_domain%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    IF pi_domain IS NOT NULL 
     THEN  
        SELECT 'Y'
          INTO lv_exists
          FROM hig_domains 
         WHERE hdo_domain = UPPER(pi_domain);
    ELSE  
        lv_exists := 'Y';  
    END IF; 
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
  PROCEDURE create_node_type(pi_node_type         IN     nm_node_types.nnt_type%TYPE
                            ,pi_name              IN     nm_node_types.nnt_name%TYPE
                            ,pi_description       IN     nm_node_types.nnt_descr%TYPE
                            ,pi_node_name_format  IN     nm_node_types.nnt_no_name_format%TYPE
                            ,po_message_severity     OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor       OUT SYS_REFCURSOR)
    IS
    --
  BEGIN
    --
    SAVEPOINT create_node_type_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Type'
                                      ,pi_parameter_value => pi_node_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Name'
                                      ,pi_parameter_value => pi_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Description'
                                      ,pi_parameter_value => pi_description);
    --
    validate_node_name_format(pi_parameter_desc  => 'Node Name Format'
                             ,pi_parameter_value => pi_node_name_format);
    --
    IF node_type_exists(pi_node_type => pi_node_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Node Type:  '||pi_node_type);
    END IF;
    --
    /*
    ||insert into nm_node_types.
    */
    INSERT
      INTO nm_node_types
           (nnt_type
           ,nnt_name
           ,nnt_descr
           ,nnt_no_name_format
           )
    VALUES (UPPER(pi_node_type)
           ,UPPER(pi_name)
           ,pi_description
           ,pi_node_name_format
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_node_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_node_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_node_type(pi_old_node_type         IN     nm_node_types.nnt_type%TYPE
                            ,pi_old_name              IN     nm_node_types.nnt_name%TYPE
                            ,pi_old_description       IN     nm_node_types.nnt_descr%TYPE
                            ,pi_old_node_name_format  IN     nm_node_types.nnt_no_name_format%TYPE
                            ,pi_new_node_type         IN     nm_node_types.nnt_type%TYPE
                            ,pi_new_name              IN     nm_node_types.nnt_name%TYPE
                            ,pi_new_description       IN     nm_node_types.nnt_descr%TYPE
                            ,pi_new_node_name_format  IN     nm_node_types.nnt_no_name_format%TYPE
                            ,po_message_severity         OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor           OUT SYS_REFCURSOR)
    IS
    --
    lr_db_rec        nm_node_types%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_node_types
       WHERE nnt_type = pi_old_node_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Node Type does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_node_type_sp;
    --
    awlrs_util.check_historic_mode;   
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Type'
                                      ,pi_parameter_value => pi_new_node_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Name'
                                      ,pi_parameter_value => pi_new_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Description'
                                      ,pi_parameter_value => pi_new_description);
    --
    validate_node_name_format(pi_parameter_desc  => 'Node Name Format'
                             ,pi_parameter_value => pi_new_node_name_format);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nnt_type != pi_old_node_type
     OR (lr_db_rec.nnt_type IS NULL AND pi_old_node_type IS NOT NULL)
     OR (lr_db_rec.nnt_type IS NOT NULL AND pi_old_node_type IS NULL)
     --
     OR (lr_db_rec.nnt_name != pi_old_name)
     OR (lr_db_rec.nnt_name IS NULL AND pi_old_name IS NOT NULL)
     OR (lr_db_rec.nnt_name IS NOT NULL AND pi_old_name IS NULL)
     --
     OR (UPPER(lr_db_rec.nnt_descr) != UPPER(pi_old_description))
     OR (lr_db_rec.nnt_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_rec.nnt_descr IS NOT NULL AND pi_old_description IS NULL)
     --
     OR (lr_db_rec.nnt_no_name_format != pi_old_node_name_format)
     OR (lr_db_rec.nnt_no_name_format IS NULL AND pi_old_node_name_format IS NOT NULL)
     OR (lr_db_rec.nnt_no_name_format IS NOT NULL AND pi_old_node_name_format IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_node_type != pi_new_node_type
       OR (pi_old_node_type IS NULL AND pi_new_node_type IS NOT NULL)
       OR (pi_old_node_type IS NOT NULL AND pi_new_node_type IS NULL)
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
      IF UPPER(pi_old_description) != UPPER(pi_new_description)
       OR (pi_old_description IS NULL AND pi_new_description IS NOT NULL)
       OR (pi_old_description IS NOT NULL AND pi_new_description IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_node_name_format != pi_new_node_name_format
       OR (pi_old_node_name_format IS NULL AND pi_new_node_name_format IS NOT NULL)
       OR (pi_old_node_name_format IS NOT NULL AND pi_new_node_name_format IS NULL)
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
        UPDATE nm_node_types
           SET nnt_name           = UPPER(pi_new_name)
              ,nnt_descr          = pi_new_description
              ,nnt_no_name_format = pi_new_node_name_format
         WHERE nnt_type           = pi_old_node_type;
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
        ROLLBACK TO update_node_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_node_type;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION nm_nodes_exist(pi_node_type  IN  nm_node_types.nnt_type%TYPE)
      RETURN VARCHAR2
    IS
      lv_exists VARCHAR2(1):= 'N';
      lv_cnt    NUMBER;
    BEGIN
      --
      SELECT COUNT(no_node_id)
        INTO lv_cnt
        FROM nm_nodes
       WHERE no_node_type = pi_node_type;        
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
    END nm_nodes_exist;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION nm_types_exist(pi_node_type  IN  nm_node_types.nnt_type%TYPE)
      RETURN VARCHAR2
    IS
      lv_exists VARCHAR2(1):= 'N';
      lv_cnt    NUMBER;
    BEGIN
      --
      SELECT COUNT(nt_type)
        INTO lv_cnt
        FROM nm_types
       WHERE nt_node_type = pi_node_type;
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
    END nm_types_exist;
    
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_node_type(pi_node_type         IN      nm_node_types.nnt_type%TYPE
                            ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor       OUT  SYS_REFCURSOR)
    IS
    --
  BEGIN
    --
    SAVEPOINT delete_node_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF node_type_exists(pi_node_type => pi_node_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Node Type:  '||pi_node_type);
    END IF;
    --
    IF nm_nodes_exist(pi_node_type => pi_node_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 2
                     ,pi_supplementary_info => 'Nodes');
    END IF;
    
    IF nm_types_exist(pi_node_type => pi_node_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 2
                     ,pi_supplementary_info => 'Network Types');
    END IF;                 
    --
    DELETE
      FROM nm_node_types
     WHERE nnt_type = UPPER(pi_node_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_node_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_node_type;
  
  --
  -----------------------------------------------------------------------------
  --
  
  PROCEDURE get_network_types_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT  sys_refcursor
                                 ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type     
          ,nt_descr             
      FROM nm_types
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
  END get_network_types_lov;
                           
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_type_lov(pi_nt_type           IN     nm_types.nt_type%TYPE
                                ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor       OUT sys_refcursor
                                ,po_cursor               OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type     
          ,nt_descr             
      FROM nm_types
     WHERE nt_type =  pi_nt_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_type_lov;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_types_lov(pi_nt_datum         IN      nm_types.nt_datum%TYPE 
                                 ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT  sys_refcursor
                                 ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type     
          ,nt_descr             
      FROM nm_types
     WHERE nt_datum = pi_nt_datum
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
  END get_network_types_lov;                          

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_type_lov(pi_nt_type           IN     nm_types.nt_type%TYPE
                                ,pi_nt_datum          IN     nm_types.nt_datum%TYPE 
                                ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor       OUT sys_refcursor
                                ,po_cursor               OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type     
          ,nt_descr             
      FROM nm_types
     WHERE nt_type  = pi_nt_type
       AND nt_datum = pi_nt_datum;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_type_lov;                             
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_group_types(pi_nt_type           IN      nm_types.nt_type%TYPE
                                   ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor       OUT  sys_refcursor
                                   ,po_cursor               OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type     
          ,ngt_descr             
      FROM nm_group_types_all
     WHERE ngt_nt_type = NVL(pi_nt_type,ngt_nt_type) 
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
  END get_network_group_types;                                   

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_group_type(pi_nt_type           IN     nm_types.nt_type%TYPE
                                  ,pi_ngt_group_type    IN     nm_group_types_all.ngt_group_type%TYPE
                                  ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT sys_refcursor
                                  ,po_cursor               OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type     
          ,ngt_descr             
      FROM nm_group_types_all
     WHERE ngt_nt_type    = NVL(pi_nt_type,ngt_nt_type) 
       AND ngt_group_type = pi_ngt_group_type;    
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_group_type;
   
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_admin_type(pi_nt_type  IN   nm_types.nt_type%TYPE) RETURN nm_types.nt_admin_type%TYPE
  IS
  --
  l_nm_type_rec nm_types%ROWTYPE;
  l_retval      nm_types.nt_admin_type%TYPE;
  --	
  BEGIN
  --
  l_nm_type_rec := nm3net.get_nt(pi_nt_type);
  
  l_retval := l_nm_type_rec.nt_admin_type;

  RETURN l_retval;
     
  END get_nt_admin_type;  
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_unit_name(pi_nt_type  IN   nm_types.nt_type%TYPE) RETURN nm_units.un_unit_name%TYPE
  IS
  --
  l_nm_type_rec nm_types%ROWTYPE;
  l_retval nm_units.un_unit_name%TYPE;
  --	
  BEGIN
  --
  l_nm_type_rec := nm3net.get_nt(pi_nt_type);
  
  l_retval := nm3unit.get_unit_name(l_nm_type_rec.nt_length_unit);

  RETURN l_retval;
     
  END get_nt_unit_name;  
  
    --
  -----------------------------------------------------------------------------
  -- 
  PROCEDURE get_group_types(po_message_severity OUT  hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT  sys_refcursor
                           ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_search_group_no     seq_no 
          ,ngt_group_type          group_type
          ,ngt_descr               description
          ,TRUNC(ngt_start_date)   start_date  
          ,TRUNC(ngt_end_date)     end_date
          ,ngt_nt_type             network_type
          ,awlrs_metanet_api.get_nt_admin_type(ngt_nt_type) admin_type
          ,awlrs_metanet_api.get_nt_unit_name(ngt_nt_type)  units 
          ,ngt_exclusive_flag      exclusive_flag
          ,ngt_linear_flag         linear_flag
          ,ngt_partial             partial
          ,ngt_sub_group_allowed   sub_group_allowed
          ,ngt_mandatory           mandatory
          ,ngt_reverse_allowed     reverse_allowed
          ,ngt_icon_name           icon_name          
      FROM nm_group_types_all
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
  END get_group_types;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_type(pi_group_type           IN     nm_group_types_all.ngt_group_type%TYPE
                          ,po_message_severity        OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor          OUT sys_refcursor
                          ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_search_group_no     seq_no 
          ,ngt_group_type          group_type
          ,ngt_descr               description
          ,TRUNC(ngt_start_date)   start_date  
          ,TRUNC(ngt_end_date)     end_date
          ,ngt_nt_type             network_type
          ,awlrs_metanet_api.get_nt_admin_type(ngt_nt_type) admin_type
          ,awlrs_metanet_api.get_nt_unit_name(ngt_nt_type)  units 
          ,ngt_exclusive_flag      exclusive_flag
          ,ngt_linear_flag         linear_flag
          ,ngt_partial             partial
          ,ngt_sub_group_allowed   sub_group_allowed
          ,ngt_mandatory           mandatory
          ,ngt_reverse_allowed     reverse_allowed
          ,ngt_icon_name           icon_name          
      FROM nm_group_types_all
     WHERE ngt_group_type = pi_group_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_type;                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_group_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT ngt_search_group_no     seq_no 
                                                    ,ngt_group_type          group_type
                                                    ,ngt_descr               description
                                                    ,TRUNC(ngt_start_date)   start_date
                                                    ,TRUNC(ngt_end_date)     end_date
                                                    ,ngt_nt_type             network_type
                                                    ,awlrs_metanet_api.get_nt_admin_type(ngt_nt_type) admin_type
                                                    ,awlrs_metanet_api.get_nt_unit_name(ngt_nt_type)  units
                                                    ,ngt_exclusive_flag      exclusive_flag
                                                    ,ngt_linear_flag         linear_flag
                                                    ,ngt_partial             partial
                                                    ,ngt_sub_group_allowed   sub_group_allowed
                                                    ,ngt_mandatory           mandatory
                                                    ,ngt_reverse_allowed     reverse_allowed
                                                    ,ngt_icon_name           icon_name          
                                                FROM nm_group_types_all ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  seq_no'
                                                  ||',group_type'
                                                  ||',description'
                                                  ||',start_date'
                                                  ||',end_date'
                                                  ||',network_type'
                                                  ||',admin_type'
                                                  ||',units'
                                                  ||',exclusive_flag'
                                                  ||',linear_flag'
                                                  ||',partial'
                                                  ||',sub_group_allowed'
                                                  ||',mandatory'
                                                  ||',reverse_allowed'
                                                  ||',icon_name'
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
      awlrs_util.add_column_data(pi_cursor_col => 'seq_no'
                                ,pi_query_col  => 'ngt_search_group_no'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'group_type'
                                ,pi_query_col  => 'ngt_group_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'ngt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'ngt_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'ngt_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'network_type'
                                ,pi_query_col  => 'ngt_nt_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'admin_type'
                                ,pi_query_col  => 'awlrs_metanet_api.get_nt_admin_type(ngt_nt_type)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'units'
                                ,pi_query_col  => 'awlrs_metanet_api.get_nt_unit_name(ngt_nt_type)'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'exclusive_flag'
                                ,pi_query_col  => 'ngt_exclusive_flag'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'linear_flag'
                                ,pi_query_col  => 'ngt_linear_flag'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'partial'
                                ,pi_query_col  => 'ngt_partial'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'sub_group_allowed'
                                ,pi_query_col  => 'ngt_sub_group_allowed'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'mandatory'
                                ,pi_query_col  => 'ngt_mandatory'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'reverse_allowed'
                                ,pi_query_col  => 'ngt_reverse_allowed'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'icon_name'
                                ,pi_query_col  => 'ngt_icon_name'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ngt_group_type')||') a)'
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_group_types;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_groupings(pi_group_type       IN      nm_nt_groupings_all.nng_group_type%TYPE
                            ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor      OUT  sys_refcursor
                            ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nng.nng_group_type        group_type
          ,nng.nng_nt_type           nt_type
          ,nt.nt_descr               nt_type_descr
          ,TRUNC(nng.nng_start_date) start_date
          ,TRUNC(nng.nng_end_date)   end_date
      FROM nm_nt_groupings_all nng
          ,nm_types nt
     WHERE nng.nng_group_type = pi_group_type 
       AND nng.nng_nt_type    = nt.nt_type
     ORDER BY nng.nng_nt_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_groupings;                             

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_grouping(pi_group_type           IN     nm_nt_groupings_all.nng_group_type%TYPE
                           ,pi_nt_type              IN     nm_nt_groupings_all.nng_nt_type%TYPE
                           ,po_message_severity        OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor          OUT sys_refcursor
                           ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nng.nng_group_type        group_type
          ,nng.nng_nt_type           nt_type
          ,nt.nt_descr               nt_type_descr
          ,TRUNC(nng.nng_start_date) start_date
          ,TRUNC(nng.nng_end_date)   end_date
      FROM nm_nt_groupings_all nng
          ,nm_types nt
     WHERE nng.nng_group_type = pi_group_type
       AND nng.nng_nt_type    = pi_nt_type 
       AND nng.nng_nt_type    = nt.nt_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_grouping;                         
                           
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nt_groupings(pi_group_type           IN     nm_nt_groupings_all.nng_group_type%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT nng.nng_group_type        group_type
                                                    ,nng.nng_nt_type           nt_type
                                                    ,nt.nt_descr               nt_type_descr
                                                    ,TRUNC(nng.nng_start_date) start_date
                                                    ,TRUNC(nng.nng_end_date)   end_date
                                                FROM nm_nt_groupings_all nng
                                                    ,nm_types nt
                                               WHERE nng.nng_group_type = :pi_group_type 
                                                 AND nng.nng_nt_type    = nt.nt_type ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  group_type'
                                                  ||',nt_type'
                                                  ||',nt_type_descr'
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
      awlrs_util.add_column_data(pi_cursor_col => 'group_type'
                                ,pi_query_col  => 'nng_group_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nt_type'
                                ,pi_query_col  => 'nng_nt_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'nt_type_descr'
                                ,pi_query_col  => 'nt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'nng_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'nng_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nng_group_type')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_group_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_group_type
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
  END get_paged_nt_groupings; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_relations(pi_parent_group_type   IN      nm_group_relations_all.ngr_parent_group_type%TYPE
                               ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor         OUT  sys_refcursor
                               ,po_cursor                 OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngr.ngr_parent_group_type parent_group_type
          ,ngr.ngr_child_group_type  child_group_type
          ,ngt.ngt_descr             child_group_type_descr
          ,TRUNC(ngr.ngr_start_date) start_date
          ,TRUNC(ngr.ngr_end_date)   end_date
      FROM nm_group_relations_all ngr
          ,nm_group_types_all ngt
     WHERE ngr.ngr_parent_group_type = pi_parent_group_type 
     AND   ngr.ngr_child_group_type  = ngt.ngt_group_type
     ORDER BY ngr.ngr_child_group_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_relations;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_relations_tree(pi_parent_group_type   IN      nm_group_relations_all.ngr_parent_group_type%TYPE
                                    ,po_message_severity       OUT  hig_codes.hco_code%TYPE
                                    ,po_message_cursor         OUT  sys_refcursor
                                    ,po_cursor                 OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT 1                                           initial_state
          ,1                                           treedepth
          ,ngt_descr                                   group_descr
          ,REPLACE(UPPER(ngt_icon_name), '.ICO', '')   icon
          ,ngt_group_type                              group_type
          ,null                                        parent_group_type
    FROM  nm_group_types_all
    WHERE ngt_group_type = pi_parent_group_type
    UNION ALL 
    SELECT 1                                           initial_state
          ,level+ 1                                    treedepth
          ,nm3net.get_gty_descr(ngr_child_group_type)  group_descr
          ,REPLACE(UPPER(nm3net.get_gty_icon(ngr_child_group_type)), '.ICO', '') icon
          ,ngr_child_group_type                        group_type
          ,ngr_parent_group_type                       parent_group_type  
    FROM nm_group_relations_all 
    CONNECT BY NOCYCLE PRIOR ngr_child_group_type  = ngr_parent_group_type
    START WITH       ngr_parent_group_type = pi_parent_group_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_relations_tree;                                                               

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_relation(pi_parent_group_type   IN     nm_group_relations_all.ngr_parent_group_type%TYPE
                              ,pi_child_group_type    IN     nm_group_relations_all.ngr_child_group_type%TYPE
                              ,po_message_severity       OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor         OUT sys_refcursor
                              ,po_cursor                 OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngr.ngr_parent_group_type parent_group_type
          ,ngr.ngr_child_group_type  child_group_type
          ,ngt.ngt_descr             child_group_type_descr
          ,TRUNC(ngr.ngr_start_date) start_date
          ,TRUNC(ngr.ngr_end_date)   end_date
      FROM nm_group_relations_all ngr
          ,nm_group_types_all ngt
     WHERE ngr.ngr_parent_group_type = pi_parent_group_type 
     AND   ngr.ngr_child_group_type  = pi_child_group_type
     AND   ngr.ngr_child_group_type  = ngt.ngt_group_type;
     --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_relation;                               
                           
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_group_relations(pi_parent_group_type    IN     nm_group_relations_all.ngr_parent_group_type%TYPE
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
      lv_driving_sql  nm3type.max_varchar2 :='SELECT ngr.ngr_parent_group_type parent_group_type
                                                    ,ngr.ngr_child_group_type  child_group_type
                                                    ,ngt.ngt_descr             child_group_type_descr
                                                    ,TRUNC(ngr.ngr_start_date) start_date
                                                    ,TRUNC(ngr.ngr_end_date)   end_date
                                                FROM nm_group_relations_all ngr
                                                    ,nm_group_types_all ngt
                                               WHERE ngr.ngr_parent_group_type = :pi_parent_group_type 
                                               AND   ngr.ngr_child_group_type  = ngt.ngt_group_type ';
      --
      lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  parent_group_type'
                                                  ||',child_group_type'
                                                  ||',child_group_type_descr'
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
      awlrs_util.add_column_data(pi_cursor_col => 'parent_group_type'
                                ,pi_query_col  => 'ngr_parent_group_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'child_group_type'
                                ,pi_query_col  => 'ngr_child_group_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'child_group_type_descr'
                                ,pi_query_col  => 'ngt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'ngr_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'ngr_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ngr_parent_group_type')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_parent_group_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_parent_group_type
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
  END get_paged_group_relations;                                                                                        
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_child_group_types_lov(pi_parent_group_type  IN      nm_group_types_all.ngt_group_type%TYPE
                                     ,pi_parent_admin_type  IN      nm_types.nt_admin_type%TYPE
                                     ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                                     ,po_message_cursor        OUT  sys_refcursor
                                     ,po_cursor                OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type,
           ngt_descr
    FROM   nm_group_types,
           nm_types
    WHERE  ngt_group_type != pi_parent_group_type
      AND  ngt_nt_type     = nt_type
      AND  nt_admin_type   = pi_parent_admin_type      
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
  END get_child_group_types_lov;                                

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_child_group_type_lov(pi_child_group_type   IN     nm_group_types_all.ngt_group_type%TYPE
                                    ,pi_parent_admin_type  IN     nm_types.nt_admin_type%TYPE
                                    ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor        OUT sys_refcursor
                                    ,po_cursor                OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type,
           ngt_descr
    FROM   nm_group_types,
           nm_types
    WHERE  ngt_group_type  = pi_child_group_type
      AND  ngt_nt_type     = nt_type
      AND  nt_admin_type   = pi_parent_admin_type           
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
  END get_child_group_type_lov;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_group_type_view(pi_nt_type            IN      nm_types.nt_type%TYPE
                                  ,pi_group_type         IN      nm_group_types_all.ngt_group_type%TYPE   
                                  ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                                  ,po_message_cursor        OUT  sys_refcursor)
                                  
  IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    nm3inv_view.create_view_for_nt_type(pi_nt_type  => pi_nt_type
                                       ,pi_gty_type => pi_group_type);  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_type_view; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_nt_type_view(pi_nt_type            IN      nm_types.nt_type%TYPE
                               ,po_message_severity      OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor        OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;  
    --
    nm3inv_view.create_view_for_nt_type(pi_nt_type  => pi_nt_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_nt_type_view;                             
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_group_asset_data(pi_nt_type                  IN      nm_types.nt_type%TYPE
                                   ,pi_group_type               IN      nm_group_types_all.ngt_group_type%TYPE   
                                   ,pi_delete_existing_inv_type IN      varchar2
                                   ,po_message_severity            OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    nm3inv_view.create_ft_inv_for_nt_type (pi_nt_type                  => pi_nt_type
                                          ,pi_inv_type                 => pi_group_type
                                          ,pi_delete_existing_inv_type => pi_delete_existing_inv_type = 'Y'
                                          );                                   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_asset_data; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_ft_inv_for_nt(pi_nt_type                   IN      nm_types.nt_type%TYPE
                                ,pi_inv_type                  IN      nm_types.nt_type%TYPE  
                                ,pi_delete_existing_inv_type  IN      varchar2
                                ,po_message_severity             OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor               OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_util.check_historic_mode; 
    --  
    nm3inv_view.create_ft_inv_for_nt_type (pi_nt_type                  => pi_nt_type
                                          ,pi_inv_type                 => pi_inv_type
                                          ,pi_delete_existing_inv_type => pi_delete_existing_inv_type = 'Y'
                                          );                                   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN   
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_ft_inv_for_nt;                                
                                        
                                   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_group_type_flags(pi_linear_flag       IN     nm_group_types_all.ngt_linear_flag%TYPE
                                     ,pi_partial           IN     nm_group_types_all.ngt_partial%TYPE
                                     ,pi_sub_group_allowed IN     nm_group_types_all.ngt_sub_group_allowed%TYPE
                                     ,pi_mandatory         IN     nm_group_types_all.ngt_mandatory%TYPE)
  IS
  --
  BEGIN
    --
  IF ((pi_linear_flag = 'Y' AND pi_sub_group_allowed = 'Y') 
       OR 
        (pi_partial = 'Y' AND pi_sub_group_allowed = 'Y')
       OR 
        (pi_sub_group_allowed = 'Y' AND pi_mandatory = 'Y')) 
      Then
       hig.raise_ner(pi_appl               => 'NET'
                    ,pi_id                 =>  321
                    ,pi_supplementary_info => 'When Sub Group Allowed = ''Y'', Linear, Partial and Mandatory must all be set to ''N'''
                    );
                     

  END IF;
  --
  END validate_group_type_flags; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_network_type(pi_new_network_type  IN  nm_group_types_all.ngt_nt_type%TYPE
                                 ,pi_old_network_type  IN  nm_group_types_all.ngt_nt_type%TYPE)
  IS
  --
  l_num  NUMBER;
  --
  CURSOR c1 IS
        SELECT 1
        FROM   nm_group_relations_all,
               nm_group_types_all,
               nm_types
        WHERE  ngr_child_group_type = pi_new_network_type
        AND	   ngr_parent_group_type = ngt_group_type
        AND    ngt_nt_type = nt_type
        AND    nt_admin_type <> awlrs_metanet_api.get_nt_admin_type(pi_old_network_type);
  --
  BEGIN
  --
  IF pi_new_network_type <> pi_old_network_type THEN
  --
    IF nm3net.group_type_in_use(pi_old_network_type) THEN	--user not allowed to change
	   hig.raise_ner(pi_appl => 'NET'
                    ,pi_id   =>  5);
    ELSE
       OPEN c1;
		  FETCH c1 INTO l_num;
	   CLOSE c1;
	
       IF l_num IS NOT NULL THEN	--network type must have same admin unit type as parent
		  hig.raise_ner(pi_appl => 'NET'
                       ,pi_id   =>  7);
       END IF;                
    
    END IF;                     
  
  END IF;
  
  --
  END validate_network_type; 
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_group_type(pi_group_type        IN     nm_group_types_all.ngt_group_type%TYPE   
                             ,pi_description       IN     nm_group_types_all.ngt_descr%TYPE  
                             ,pi_exclusive_flag    IN     nm_group_types_all.ngt_exclusive_flag%TYPE
                             ,pi_seq_no            IN     nm_group_types_all.ngt_search_group_no%TYPE
                             ,pi_linear_flag       IN     nm_group_types_all.ngt_linear_flag%TYPE
                             ,pi_network_type      IN     nm_group_types_all.ngt_nt_type%TYPE
                             ,pi_partial           IN     nm_group_types_all.ngt_partial%TYPE
                             ,pi_start_date        IN     nm_group_types_all.ngt_start_date%TYPE 
                             ,pi_end_date          IN     nm_group_types_all.ngt_end_date%TYPE
                             ,pi_sub_group_allowed IN     nm_group_types_all.ngt_sub_group_allowed%TYPE
                             ,pi_mandatory         IN     nm_group_types_all.ngt_mandatory%TYPE
                             ,pi_reverse_allowed   IN     nm_group_types_all.ngt_reverse_allowed%TYPE
                             ,pi_icon_name         IN     nm_group_types_all.ngt_icon_name%TYPE                            
                             ,po_message_severity     OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT sys_refcursor)
                             
  IS
    --
  BEGIN
    --
    SAVEPOINT create_group_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value => pi_group_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Description'
                               ,pi_parameter_value => pi_description);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Exclusive'
                               ,pi_parameter_value => pi_exclusive_flag);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Linear'
                           ,pi_parameter_value => pi_linear_flag);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Partial'
                          ,pi_parameter_value => pi_partial);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Sub Group Allowed'
                         ,pi_parameter_value => pi_sub_group_allowed);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_mandatory);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Reverse Allowed'
                          ,pi_parameter_value => pi_reverse_allowed);
    --  
    validate_group_type_flags(pi_linear_flag       =>  pi_linear_flag
                             ,pi_partial           =>  pi_partial
                             ,pi_sub_group_allowed =>  pi_sub_group_allowed
                             ,pi_mandatory         =>  pi_mandatory);                             
    --
    IF group_type_exists(pi_group_type   => pi_group_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Group Type:  '||pi_group_type);
    END IF;
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_network_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Network Type:  '||pi_network_type);
    END IF;
    --
    /*
    ||insert into nm_group_types_all.
    */
    INSERT
      INTO nm_group_types_all
           (ngt_group_type
           ,ngt_descr
           ,ngt_exclusive_flag
           ,ngt_search_group_no
           ,ngt_linear_flag
           ,ngt_nt_type
           ,ngt_partial
           ,ngt_start_date
           ,ngt_end_date
           ,ngt_sub_group_allowed
           ,ngt_mandatory
           ,ngt_reverse_allowed
           ,ngt_icon_name
           )
    VALUES (UPPER(pi_group_type)
           ,pi_description
           ,pi_exclusive_flag
           ,pi_seq_no
           ,pi_linear_flag
           ,UPPER(pi_network_type)
           ,pi_partial
           ,pi_start_date
           ,pi_end_date
           ,pi_sub_group_allowed
           ,pi_mandatory
           ,pi_reverse_allowed
           ,pi_icon_name
           );
    --  
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_group_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_type;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_group_type(pi_old_group_type        IN     nm_group_types_all.ngt_group_type%TYPE   
                             ,pi_old_description       IN     nm_group_types_all.ngt_descr%TYPE  
                             ,pi_old_exclusive_flag    IN     nm_group_types_all.ngt_exclusive_flag%TYPE
                             ,pi_old_seq_no            IN     nm_group_types_all.ngt_search_group_no%TYPE
                             ,pi_old_linear_flag       IN     nm_group_types_all.ngt_linear_flag%TYPE
                             ,pi_old_network_type      IN     nm_group_types_all.ngt_nt_type%TYPE
                             ,pi_old_partial           IN     nm_group_types_all.ngt_partial%TYPE
                             ,pi_old_start_date        IN     nm_group_types_all.ngt_start_date%TYPE
                             ,pi_old_end_date          IN     nm_group_types_all.ngt_end_date%TYPE
                             ,pi_old_sub_group_allowed IN     nm_group_types_all.ngt_sub_group_allowed%TYPE
                             ,pi_old_mandatory         IN     nm_group_types_all.ngt_mandatory%TYPE
                             ,pi_old_reverse_allowed   IN     nm_group_types_all.ngt_reverse_allowed%TYPE
                             ,pi_old_icon_name         IN     nm_group_types_all.ngt_icon_name%TYPE
                             ,pi_new_group_type        IN     nm_group_types_all.ngt_group_type%TYPE   
                             ,pi_new_description       IN     nm_group_types_all.ngt_descr%TYPE  
                             ,pi_new_exclusive_flag    IN     nm_group_types_all.ngt_exclusive_flag%TYPE
                             ,pi_new_seq_no            IN     nm_group_types_all.ngt_search_group_no%TYPE
                             ,pi_new_linear_flag       IN     nm_group_types_all.ngt_linear_flag%TYPE
                             ,pi_new_network_type      IN     nm_group_types_all.ngt_nt_type%TYPE
                             ,pi_new_partial           IN     nm_group_types_all.ngt_partial%TYPE
                             ,pi_new_start_date        IN     nm_group_types_all.ngt_start_date%TYPE
                             ,pi_new_end_date          IN     nm_group_types_all.ngt_end_date%TYPE
                             ,pi_new_sub_group_allowed IN     nm_group_types_all.ngt_sub_group_allowed%TYPE
                             ,pi_new_mandatory         IN     nm_group_types_all.ngt_mandatory%TYPE
                             ,pi_new_reverse_allowed   IN     nm_group_types_all.ngt_reverse_allowed%TYPE
                             ,pi_new_icon_name         IN     nm_group_types_all.ngt_icon_name%TYPE  
                             ,po_message_severity         OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor           OUT sys_refcursor)

  IS
    --
    lr_db_rec        nm_group_types_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_group_types_all
       WHERE ngt_group_type = pi_old_group_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Group Type does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_group_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value => pi_new_group_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Description'
                               ,pi_parameter_value => pi_new_description);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Exclusive'
                               ,pi_parameter_value => pi_new_exclusive_flag);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Linear'
                           ,pi_parameter_value => pi_new_linear_flag);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Partial'
                          ,pi_parameter_value => pi_new_partial);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Sub Group Allowed'
                          ,pi_parameter_value => pi_new_sub_group_allowed);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_new_mandatory);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Reverse Allowed'
                          ,pi_parameter_value => pi_new_reverse_allowed);
    --
    validate_group_type_flags(pi_linear_flag       =>  pi_new_linear_flag
                             ,pi_partial           =>  pi_new_partial
                             ,pi_sub_group_allowed =>  pi_new_sub_group_allowed
                             ,pi_mandatory         =>  pi_new_mandatory); 
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_new_network_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Network Type:  '||pi_new_network_type);
    ELSE                 
        validate_network_type(pi_new_network_type => pi_new_network_type
                             ,pi_old_network_type => pi_old_network_type);
    END IF;                     
    --                                               
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.ngt_group_type != pi_old_group_type
     OR (lr_db_rec.ngt_group_type IS NULL AND pi_old_group_type IS NOT NULL)
     OR (lr_db_rec.ngt_group_type IS NOT NULL AND pi_old_group_type IS NULL)
     --
     OR (UPPER(lr_db_rec.ngt_descr) != UPPER(pi_old_description))
     OR (lr_db_rec.ngt_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_rec.ngt_descr IS NOT NULL AND pi_old_description IS NULL)
     --
     OR (lr_db_rec.ngt_exclusive_flag != pi_old_exclusive_flag)
     OR (lr_db_rec.ngt_exclusive_flag IS NULL AND pi_old_exclusive_flag IS NOT NULL)
     OR (lr_db_rec.ngt_exclusive_flag IS NOT NULL AND pi_old_exclusive_flag IS NULL)
     --
     OR (lr_db_rec.ngt_search_group_no != pi_old_seq_no)
     OR (lr_db_rec.ngt_search_group_no IS NULL AND pi_old_seq_no IS NOT NULL)
     OR (lr_db_rec.ngt_search_group_no IS NOT NULL AND pi_old_seq_no IS NULL)
     --
     OR (lr_db_rec.ngt_linear_flag != pi_old_linear_flag)
     OR (lr_db_rec.ngt_linear_flag IS NULL AND pi_old_linear_flag IS NOT NULL)
     OR (lr_db_rec.ngt_linear_flag IS NOT NULL AND pi_old_linear_flag IS NULL)
     --
     OR (lr_db_rec.ngt_nt_type != pi_old_network_type)
     OR (lr_db_rec.ngt_nt_type IS NULL AND pi_old_network_type IS NOT NULL)
     OR (lr_db_rec.ngt_nt_type IS NOT NULL AND pi_old_network_type IS NULL)
     --
     OR (lr_db_rec.ngt_partial != pi_old_partial)
     OR (lr_db_rec.ngt_partial IS NULL AND pi_old_partial IS NOT NULL)
     OR (lr_db_rec.ngt_partial IS NOT NULL AND pi_old_partial IS NULL)
     --
     OR (lr_db_rec.ngt_start_date != pi_old_start_date)
     OR (lr_db_rec.ngt_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_rec.ngt_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --
     OR (lr_db_rec.ngt_end_date != pi_old_end_date)
     OR (lr_db_rec.ngt_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_rec.ngt_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     OR (lr_db_rec.ngt_sub_group_allowed != pi_old_sub_group_allowed)
     OR (lr_db_rec.ngt_sub_group_allowed IS NULL AND pi_old_sub_group_allowed IS NOT NULL)
     OR (lr_db_rec.ngt_sub_group_allowed IS NOT NULL AND pi_old_sub_group_allowed IS NULL)
     --
     OR (lr_db_rec.ngt_mandatory != pi_old_mandatory)
     OR (lr_db_rec.ngt_mandatory IS NULL AND pi_old_mandatory IS NOT NULL)
     OR (lr_db_rec.ngt_mandatory IS NOT NULL AND pi_old_mandatory IS NULL)
     --
     OR (lr_db_rec.ngt_reverse_allowed != pi_old_reverse_allowed)
     OR (lr_db_rec.ngt_reverse_allowed IS NULL AND pi_old_reverse_allowed IS NOT NULL)
     OR (lr_db_rec.ngt_reverse_allowed IS NOT NULL AND pi_old_reverse_allowed IS NULL)
     --
     OR (lr_db_rec.ngt_icon_name != pi_old_icon_name)
     OR (lr_db_rec.ngt_icon_name IS NULL AND pi_old_icon_name IS NOT NULL)
     OR (lr_db_rec.ngt_icon_name IS NOT NULL AND pi_old_icon_name IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_group_type != pi_new_group_type
       OR (pi_old_group_type IS NULL AND pi_new_group_type IS NOT NULL)
       OR (pi_old_group_type IS NOT NULL AND pi_new_group_type IS NULL)
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
      IF pi_old_exclusive_flag != pi_new_exclusive_flag
       OR (pi_old_exclusive_flag IS NULL AND pi_new_exclusive_flag IS NOT NULL)
       OR (pi_old_exclusive_flag IS NOT NULL AND pi_new_exclusive_flag IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_seq_no != pi_new_seq_no
       OR (pi_old_seq_no IS NULL AND pi_new_seq_no IS NOT NULL)
       OR (pi_old_seq_no IS NOT NULL AND pi_new_seq_no IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_linear_flag != pi_new_linear_flag
       OR (pi_old_linear_flag IS NULL AND pi_new_linear_flag IS NOT NULL)
       OR (pi_old_linear_flag IS NOT NULL AND pi_new_linear_flag IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_network_type != pi_new_network_type
       OR (pi_old_network_type IS NULL AND pi_new_network_type IS NOT NULL)
       OR (pi_old_network_type IS NOT NULL AND pi_new_network_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_partial != pi_new_partial
       OR (pi_old_partial IS NULL AND pi_new_partial IS NOT NULL)
       OR (pi_old_partial IS NOT NULL AND pi_new_partial IS NULL)
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
      IF pi_old_sub_group_allowed != pi_new_sub_group_allowed
       OR (pi_old_sub_group_allowed IS NULL AND pi_new_sub_group_allowed IS NOT NULL)
       OR (pi_old_sub_group_allowed IS NOT NULL AND pi_new_sub_group_allowed IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_mandatory != pi_new_mandatory
       OR (pi_old_mandatory IS NULL AND pi_new_mandatory IS NOT NULL)
       OR (pi_old_mandatory IS NOT NULL AND pi_new_mandatory IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_reverse_allowed != pi_new_reverse_allowed
       OR (pi_old_reverse_allowed IS NULL AND pi_new_reverse_allowed IS NOT NULL)
       OR (pi_old_reverse_allowed IS NOT NULL AND pi_new_reverse_allowed IS NULL)
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
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE nm_group_types_all
           SET ngt_descr             = pi_new_description
              ,ngt_exclusive_flag    = pi_new_exclusive_flag
              ,ngt_search_group_no   = pi_new_seq_no
              ,ngt_linear_flag       = pi_new_linear_flag
              ,ngt_nt_type           = UPPER(pi_new_network_type)
              ,ngt_partial           = pi_new_partial
              --,ngt_start_date        = pi_new_start_date   -- Start date can not be updated --
              ,ngt_end_date          = pi_new_end_date
              ,ngt_sub_group_allowed = pi_new_sub_group_allowed
              ,ngt_mandatory         = pi_new_mandatory
              ,ngt_reverse_allowed   = pi_new_reverse_allowed
              ,ngt_icon_name         = pi_new_icon_name
         WHERE ngt_group_type        = pi_old_group_type;
         
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
        ROLLBACK TO update_group_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_group_type;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_group_type(pi_group_type        IN      nm_group_types_all.ngt_group_type%TYPE   
                             ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor       OUT  sys_refcursor)
                             
   IS
    --
    CURSOR c_nt_groupings IS
    SELECT COUNT(nng_nt_type) 
      FROM nm_nt_groupings_all
     WHERE nng_group_type = UPPER(pi_group_type); 
    --
    lv_cnt  NUMBER;
    --    
  BEGIN
    --
    SAVEPOINT delete_group_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF group_type_exists(pi_group_type => pi_group_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Group Type:  '||pi_group_type);
    END IF;                 
    --
    OPEN  c_nt_groupings;
    FETCH c_nt_groupings
     INTO lv_cnt;
    CLOSE c_nt_groupings;

    IF lv_cnt = 0 THEN
    --
       DELETE
         FROM nm_group_types_all
        WHERE ngt_group_type = UPPER(pi_group_type);
    ELSE
      --
         hig.raise_ner(pi_appl => 'NET'
                      ,pi_id   =>  2);
      --
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_group_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_group_type;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_nt_grouping(pi_group_type        IN     nm_nt_groupings_all.nng_group_type%TYPE   
                              ,pi_nt_type           IN     nm_nt_groupings_all.nng_nt_type%TYPE
                              ,pi_start_date        IN     nm_nt_groupings_all.nng_start_date%TYPE 
                              ,pi_end_date          IN     nm_nt_groupings_all.nng_end_date%TYPE
                              ,po_message_severity     OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT create_nt_grouping_sp;
    --    
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value => pi_group_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    IF nt_grouping_exists(pi_group_type => pi_group_type
                         ,pi_nt_type    => pi_nt_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Group Type:  '||pi_group_type||', Nt Type: '||pi_nt_type);
    END IF;
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_nt_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Network Type Grouping:  '||pi_nt_type);
    END IF;
    -- 
    /*
    ||insert into nm_nt_groupings_all.
    */
    INSERT
      INTO nm_nt_groupings_all
           (nng_group_type
           ,nng_nt_type
           ,nng_start_date
           ,nng_end_date
           )
    VALUES (UPPER(pi_group_type)
           ,UPPER(pi_nt_type)
           ,pi_start_date
           ,pi_end_date
           );
    --  
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_nt_grouping_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_nt_grouping;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_nt_grouping(pi_old_group_type   IN     nm_nt_groupings_all.nng_group_type%TYPE  
                              ,pi_old_nt_type      IN     nm_nt_groupings_all.nng_nt_type%TYPE
                              ,pi_old_start_date   IN     nm_nt_groupings_all.nng_start_date%TYPE 
                              ,pi_old_end_date     IN     nm_nt_groupings_all.nng_end_date%TYPE
                              ,pi_new_group_type   IN     nm_nt_groupings_all.nng_group_type%TYPE  
                              ,pi_new_nt_type      IN     nm_nt_groupings_all.nng_nt_type%TYPE
                              ,pi_new_start_date   IN     nm_nt_groupings_all.nng_start_date%TYPE 
                              ,pi_new_end_date     IN     nm_nt_groupings_all.nng_end_date%TYPE
                              ,po_message_severity    OUT hig_codes.hco_code%TYPE  
                              ,po_message_cursor      OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_nt_groupings_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_nt_groupings_all
       WHERE nng_group_type = pi_old_group_type
         AND nng_nt_type    = pi_old_nt_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Network Grouping does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_nt_grouping_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value => pi_new_group_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_new_nt_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Network Type Grouping:  '||pi_new_nt_type);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nng_group_type != pi_old_group_type
     OR (lr_db_rec.nng_group_type IS NULL AND pi_old_group_type IS NOT NULL)
     OR (lr_db_rec.nng_group_type IS NOT NULL AND pi_old_group_type IS NULL)
     --
     OR (lr_db_rec.nng_nt_type != pi_old_nt_type)
     OR (lr_db_rec.nng_nt_type IS NULL AND pi_old_nt_type IS NOT NULL)
     OR (lr_db_rec.nng_nt_type IS NOT NULL AND pi_old_nt_type IS NULL)
     --
     OR (lr_db_rec.nng_start_date != pi_old_start_date)
     OR (lr_db_rec.nng_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_rec.nng_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --
     OR (lr_db_rec.nng_end_date != pi_old_end_date)
     OR (lr_db_rec.nng_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_rec.nng_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_group_type != pi_new_group_type
       OR (pi_old_group_type IS NULL AND pi_new_group_type IS NOT NULL)
       OR (pi_old_group_type IS NOT NULL AND pi_new_group_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nt_type != pi_new_nt_type
       OR (pi_old_nt_type IS NULL AND pi_new_nt_type IS NOT NULL)
       OR (pi_old_nt_type IS NOT NULL AND pi_new_nt_type IS NULL)
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
        UPDATE nm_nt_groupings_all
           SET nng_nt_type    = UPPER(pi_new_nt_type)
              ,nng_end_date   = pi_new_end_date
         WHERE nng_group_type = pi_old_group_type
           AND nng_nt_type    = pi_old_nt_type;        
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
        ROLLBACK TO update_nt_grouping_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_nt_grouping;    
  
  --
  -----------------------------------------------------------------------------
  --                            
  PROCEDURE delete_nt_grouping(pi_group_type        IN      nm_nt_groupings_all.nng_group_type%TYPE  
                              ,pi_nt_type           IN      nm_nt_groupings_all.nng_nt_type%TYPE
                              ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_nt_grouping_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF nt_grouping_exists(pi_group_type => pi_group_type
                         ,pi_nt_type    => pi_nt_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Network Grouping does not exist for Group Type:  '||pi_group_type||', Nt Type: '||pi_nt_type);
    END IF;
    --    
    UPDATE nm_nt_groupings_all
       SET nng_end_date     = TRUNC(SYSDATE)
     WHERE nng_group_type   = UPPER(pi_group_type)
       AND nng_nt_type      = UPPER(pi_nt_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_nt_grouping_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_nt_grouping;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_group_relation(pi_parent_group_type IN     nm_group_relations_all.ngr_parent_group_type%TYPE   
                                 ,pi_child_group_type  IN     nm_group_relations_all.ngr_child_group_type%TYPE
                                 ,pi_start_date        IN     nm_group_relations_all.ngr_start_date%TYPE 
                                 ,pi_end_date          IN     nm_group_relations_all.ngr_end_date%TYPE
                                 ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT sys_refcursor)
   IS
    --
  BEGIN
    --
    SAVEPOINT create_group_relation_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Group Type'
                               ,pi_parameter_value => pi_parent_group_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    IF group_relation_exists(pi_parent_group_type => pi_parent_group_type
                            ,pi_child_group_type  => pi_child_group_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Parent Group Type:  '||pi_parent_group_type||', Child Group Type: '||pi_child_group_type
                                            ||', Start Date: '|| pi_start_date);
    END IF;
    --
    --lov validation--
    IF group_type_exists(pi_group_type => pi_child_group_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Group Type:  '||pi_child_group_type);
    END IF;
    --                 
    /*
    ||insert into nm_group_relations_all.
    */
    INSERT
      INTO nm_group_relations_all
           (ngr_parent_group_type
           ,ngr_child_group_type
           ,ngr_start_date
           ,ngr_end_date
           )
    VALUES (UPPER(pi_parent_group_type)
           ,UPPER(pi_child_group_type)
           ,pi_start_date
           ,pi_end_date
           );
    --
    IF NOT nm3net.check_for_ngr_loops(pi_parent_group_type => UPPER(pi_parent_group_type)
                                     ,pi_child_group_type  => UPPER(pi_child_group_type))
     THEN
       hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 83
                     ,pi_supplementary_info  => 'Loop In Group Data created by: '||pi_child_group_type);
    END IF;                                 
    -- 
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK to create_group_relation_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_relation;                                 
                              
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_group_relation(pi_old_parent_group_type IN     nm_group_relations_all.ngr_parent_group_type%TYPE
                                 ,pi_old_child_group_type  IN     nm_group_relations_all.ngr_child_group_type%TYPE
                                 ,pi_old_start_date        IN     nm_group_relations_all.ngr_start_date%TYPE 
                                 ,pi_old_end_date          IN     nm_group_relations_all.ngr_end_date%TYPE
                                 ,pi_new_parent_group_type IN     nm_group_relations_all.ngr_parent_group_type%TYPE 
                                 ,pi_new_child_group_type  IN     nm_group_relations_all.ngr_child_group_type%TYPE
                                 ,pi_new_start_date        IN     nm_group_relations_all.ngr_start_date%TYPE 
                                 ,pi_new_end_date          IN     nm_group_relations_all.ngr_end_date%TYPE
                                 ,po_message_severity         OUT hig_codes.hco_code%TYPE  
                                 ,po_message_cursor           OUT sys_refcursor)

  IS
    --
    lr_db_rec        nm_group_relations_all%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_group_relations_all
       WHERE ngr_parent_group_type = pi_old_parent_group_type
         AND ngr_child_group_type  = pi_old_child_group_type
         AND TRUNC(ngr_start_date)  = TRUNC(pi_old_start_date)
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Group Relationship does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_group_relation_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_enddate_isnull(pi_enddate => pi_old_end_date);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Group Type'
                               ,pi_parameter_value => pi_new_parent_group_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);
    --
    --lov validation--
    IF group_type_exists(pi_group_type => pi_new_child_group_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Child Group Relation:  '||pi_new_child_group_type);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.ngr_parent_group_type != pi_old_parent_group_type
     OR (lr_db_rec.ngr_parent_group_type IS NULL AND pi_old_parent_group_type IS NOT NULL)
     OR (lr_db_rec.ngr_parent_group_type IS NOT NULL AND pi_old_parent_group_type IS NULL)
     --
     OR (lr_db_rec.ngr_child_group_type != pi_old_child_group_type)
     OR (lr_db_rec.ngr_child_group_type IS NULL AND pi_old_child_group_type IS NOT NULL)
     OR (lr_db_rec.ngr_child_group_type IS NOT NULL AND pi_old_child_group_type IS NULL)
     --
     OR (lr_db_rec.ngr_start_date != pi_old_start_date)
     OR (lr_db_rec.ngr_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_rec.ngr_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --
     OR (lr_db_rec.ngr_end_date != pi_old_end_date)
     OR (lr_db_rec.ngr_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_rec.ngr_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_parent_group_type != pi_new_parent_group_type
       OR (pi_old_parent_group_type IS NULL AND pi_new_parent_group_type IS NOT NULL)
       OR (pi_old_parent_group_type IS NOT NULL AND pi_new_parent_group_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_child_group_type != pi_new_child_group_type
       OR (pi_old_child_group_type IS NULL AND pi_new_child_group_type IS NOT NULL)
       OR (pi_old_child_group_type IS NOT NULL AND pi_new_child_group_type IS NULL)
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
        UPDATE nm_group_relations_all
           SET ngr_parent_group_type  = UPPER(pi_new_parent_group_type)
              ,ngr_child_group_type   = UPPER(pi_new_child_group_type)
              ,ngr_end_date           = pi_new_end_date
         WHERE ngr_parent_group_type  = pi_old_parent_group_type
           AND ngr_child_group_type   = pi_old_child_group_type
           AND TRUNC(ngr_start_date)  = TRUNC(pi_old_start_date);         
        --
        IF NOT nm3net.check_for_ngr_loops(pi_parent_group_type => UPPER(pi_new_parent_group_type)
                                         ,pi_child_group_type  => UPPER(pi_new_child_group_type))
          THEN
               hig.raise_ner(pi_appl => 'HIG'
                            ,pi_id   => 83
                            ,pi_supplementary_info  => 'Loop In Group Data created by: '||pi_new_child_group_type);
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
        ROLLBACK to update_group_relation_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_group_relation;                                   
  --
  -----------------------------------------------------------------------------
  --                            
  PROCEDURE delete_group_relation(pi_parent_group_type IN     nm_group_relations_all.ngr_parent_group_type%TYPE   
                                 ,pi_child_group_type  IN     nm_group_relations_all.ngr_child_group_type%TYPE
                                 ,pi_start_date        IN     nm_group_relations_all.ngr_start_date%TYPE 
                                 ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                                 ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_group_relation_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    IF group_relation_exists(pi_parent_group_type => pi_parent_group_type
                            ,pi_child_group_type  => pi_child_group_type) <> 'Y'
       THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Group Relationship does not exist for Parent Group Type:  '||pi_parent_group_type||', Child Group Type: '
                                               ||pi_child_group_type||', Start Date: '|| pi_start_date);
    END IF;
    --    
    UPDATE nm_group_relations_all
       SET ngr_end_date           = TRUNC(SYSDATE)
     WHERE ngr_parent_group_type  = UPPER(pi_parent_group_type)
       AND ngr_child_group_type   = UPPER(pi_child_group_type)
       AND TRUNC(ngr_start_date)  = UPPER(pi_start_date);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_group_relation_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_group_relation;       
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_types(po_message_severity OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT  sys_refcursor
                             ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type             network_type
          ,nt_unique           unique_name
          ,nt_descr            description
          ,nt_node_type        node_type
          ,nt_datum            is_datum
          ,nt_linear           is_linear
          ,nt_pop_unique       is_unique
          ,nt_length_unit      unit_code
          ,un_unit_name        unit_descr
          ,nt_admin_type       admin_type 
      FROM nm_types
          ,nm_units
     WHERE nt_length_unit = un_unit_id(+)    
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
  END get_network_types;                             

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_type(pi_nt_type             IN      nm_types.nt_type%TYPE
                            ,po_message_severity        OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor          OUT sys_refcursor
                            ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nt_type             network_type
          ,nt_unique           unique_name
          ,nt_descr            description
          ,nt_node_type        node_type
          ,nt_datum            is_datum
          ,nt_linear           is_linear
          ,nt_pop_unique       is_unique
          ,nt_length_unit      unit_code
          ,un_unit_name        unit_descr
          ,nt_admin_type       admin_type 
      FROM nm_types
          ,nm_units
     WHERE nt_type        = pi_nt_type     
       AND nt_length_unit = un_unit_id(+);        
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_type;                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
  lv_driving_sql  nm3type.max_varchar2 :='SELECT nt_type             network_type
                                                ,nt_unique           unique_name
                                                ,nt_descr            description
                                                ,nt_node_type        node_type
                                                ,nt_datum            is_datum
                                                ,nt_linear           is_linear
                                                ,nt_pop_unique       is_unique
                                                ,nt_length_unit      unit_code
                                                ,un_unit_name        unit_descr
                                                ,nt_admin_type       admin_type 
                                           FROM  nm_types
                                                ,nm_units
                                           WHERE nt_length_unit = un_unit_id(+)' ;
  --
  lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  network_type'
                                              ||',unique_name'
                                              ||',description'
                                              ||',node_type'
                                              ||',is_datum'
                                              ||',is_linear'
                                              ||',is_unique'
                                              ||',unit_code'
                                              ||',unit_descr'
                                              ||',admin_type'
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
      awlrs_util.add_column_data(pi_cursor_col => 'network_type'
                                ,pi_query_col  => 'nt_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'unique_name'
                                ,pi_query_col  => 'nt_unique'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'node_type'
                                ,pi_query_col  => 'nt_node_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'is_datum'
                                ,pi_query_col  => 'nt_datum'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'is_linear'
                                ,pi_query_col  => 'nt_linear'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'is_unique'
                                ,pi_query_col  => 'nt_pop_unique'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'unit_code'
                                ,pi_query_col  => 'nt_length_unit'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'unit_descr'
                                ,pi_query_col  => 'un_unit_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'admin_type' 
                                ,pi_query_col  => 'nt_admin_type'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nt_type')||') a)'
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_network_types;       

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit_names_lov(pi_unit_domain        IN     nm_units.un_domain_id%TYPE  DEFAULT 1
                              ,po_message_severity      OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor        OUT sys_refcursor
                              ,po_cursor                OUT sys_refcursor)                            
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT un_unit_id
          ,un_unit_name     
      FROM nm_units
     WHERE un_domain_id = pi_unit_domain
     ORDER BY un_unit_id;  
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit_names_lov;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_unit_name_lov(pi_nt_unit            IN     nm_units.un_unit_id%TYPE
                             ,pi_unit_domain        IN     nm_units.un_domain_id%TYPE  DEFAULT 1
                             ,po_message_severity      OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor        OUT sys_refcursor
                             ,po_cursor                OUT sys_refcursor)                            
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT un_unit_id
          ,un_unit_name     
      FROM nm_units
     WHERE un_domain_id = pi_unit_domain
       AND un_unit_id   = pi_nt_unit; 
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_unit_name_lov;                         
  
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
    OPEN po_cursor FOR
    SELECT nnt_type            node_type
          ,nnt_descr           description
      FROM nm_node_types
     ORDER BY nnt_type;
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
  PROCEDURE get_node_type_lov(pi_node_type           IN      nm_node_types.nnt_type%TYPE
                             ,po_message_severity        OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor          OUT sys_refcursor
                             ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nnt_type            node_type
          ,nnt_descr           description
      FROM nm_node_types
     WHERE nnt_type =  pi_node_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_node_type_lov;                              
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_types_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT  sys_refcursor
                               ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nat_admin_type      admin_type
          ,nat_descr           description
      FROM nm_au_types
     ORDER BY nat_admin_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_types_lov;                                     

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_admin_type_lov(pi_admin_type           IN      nm_au_types.nat_admin_type%TYPE
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)

  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nat_admin_type      admin_type
          ,nat_descr           description
      FROM nm_au_types
     WHERE nat_admin_type =  pi_admin_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_admin_type_lov;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_network_type(pi_network_type      IN     nm_types.nt_type%TYPE
                               ,pi_unique_name       IN     nm_types.nt_unique%TYPE
                               ,pi_description       IN     nm_types.nt_descr%TYPE
                               ,pi_node_type         IN     nm_types.nt_node_type%TYPE
                               ,pi_is_datum          IN     nm_types.nt_datum%TYPE
                               ,pi_is_linear         IN     nm_types.nt_linear%TYPE
                               ,pi_is_unique         IN     nm_types.nt_pop_unique%TYPE
                               ,pi_units             IN     nm_types.nt_length_unit%TYPE
                               ,pi_admin_type        IN     nm_types.nt_admin_type%TYPE
                               ,po_message_severity     OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT sys_refcursor)
  
  IS
    --
  BEGIN
    --
    SAVEPOINT create_network_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_network_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Unique Name'
                               ,pi_parameter_value => pi_unique_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_description);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Is Datum'
                          ,pi_parameter_value => pi_is_datum);
    --
    IF pi_is_datum = 'Y' THEN
        awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Type'
                                   ,pi_parameter_value => pi_node_type);
    END IF;                               
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Is Linear'
                          ,pi_parameter_value => pi_is_linear);
    --   
    IF pi_is_linear = 'Y' THEN
        awlrs_util.validate_notnull(pi_parameter_desc  => 'Units'
                                   ,pi_parameter_value => pi_units);
    END IF;                               
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Pop Unique'
                          ,pi_parameter_value => pi_is_unique);
    --
    IF network_type_exists(pi_network_type => pi_network_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Network Type:  '||pi_network_type);
    END IF;
    --
    --lov validation--
    IF node_type_exists(pi_node_type => pi_node_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Node Type:  '||pi_node_type);
    END IF;
    --
    IF unit_type_exists(pi_units => pi_units) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Unit Type:  '||pi_units);
    END IF;
    --
    IF admin_type_exists(pi_admin_type => pi_admin_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Admin Type:  '||pi_admin_type);
    END IF;
    --
    /*
    ||insert into nm_types.
    */
    INSERT
      INTO nm_types
           (nt_type
           ,nt_unique
           ,nt_descr
           ,nt_node_type
           ,nt_datum
           ,nt_linear
           ,nt_pop_unique
           ,nt_length_unit
           ,nt_admin_type
           )
    VALUES (UPPER(pi_network_type)
           ,UPPER(pi_unique_name)
           ,pi_description
           ,pi_node_type
           ,pi_is_datum
           ,pi_is_linear
           ,pi_is_unique
           ,pi_units
           ,pi_admin_type
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_network_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_network_type;     
  
  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE update_network_type(pi_old_network_type      IN     nm_types.nt_type%TYPE
                               ,pi_old_unique_name       IN     nm_types.nt_unique%TYPE
                               ,pi_old_description       IN     nm_types.nt_descr%TYPE
                               ,pi_old_node_type         IN     nm_types.nt_node_type%TYPE
                               ,pi_old_is_datum          IN     nm_types.nt_datum%TYPE
                               ,pi_old_is_linear         IN     nm_types.nt_linear%TYPE
                               ,pi_old_is_unique         IN     nm_types.nt_pop_unique%TYPE
                               ,pi_old_units             IN     nm_types.nt_length_unit%TYPE
                               ,pi_old_admin_type        IN     nm_types.nt_admin_type%TYPE
                               ,pi_new_network_type      IN     nm_types.nt_type%TYPE
                               ,pi_new_unique_name       IN     nm_types.nt_unique%TYPE
                               ,pi_new_description       IN     nm_types.nt_descr%TYPE
                               ,pi_new_node_type         IN     nm_types.nt_node_type%TYPE
                               ,pi_new_is_datum          IN     nm_types.nt_datum%TYPE
                               ,pi_new_is_linear         IN     nm_types.nt_linear%TYPE
                               ,pi_new_is_unique         IN     nm_types.nt_pop_unique%TYPE
                               ,pi_new_units             IN     nm_types.nt_length_unit%TYPE
                               ,pi_new_admin_type        IN     nm_types.nt_admin_type%TYPE
                               ,po_message_severity         OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor           OUT sys_refcursor)                                                                                                                                                    
  
  IS
    --
    lr_db_rec        nm_types%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_types
       WHERE nt_type = pi_old_network_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Network Type does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_network_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_new_network_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Unique Name'
                               ,pi_parameter_value => pi_new_unique_name);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_new_description);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Is Datum'
                          ,pi_parameter_value => pi_new_is_datum);
    --
    IF pi_new_is_datum = 'Y' THEN
        awlrs_util.validate_notnull(pi_parameter_desc  => 'Node Type'
                                   ,pi_parameter_value => pi_new_node_type);
    END IF;                               
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Is Linear'
                          ,pi_parameter_value => pi_new_is_linear);
    --   
    IF pi_new_is_linear = 'Y' THEN
        awlrs_util.validate_notnull(pi_parameter_desc  => 'Units'
                                   ,pi_parameter_value => pi_new_units);
    END IF;                               
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Pop Unique'
                          ,pi_parameter_value => pi_new_is_unique);
    --
    --lov validation--
    IF node_type_exists(pi_node_type => pi_new_node_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Node Type:  '||pi_new_node_type);
    END IF;
    --
    IF unit_type_exists(pi_units => pi_new_units) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Unit Type:  '||pi_new_units);
    END IF;
    --
    IF admin_type_exists(pi_admin_type => pi_new_admin_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Admin Type:  '||pi_new_admin_type);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nt_type != pi_old_network_type
     OR (lr_db_rec.nt_type IS NULL AND pi_old_network_type IS NOT NULL)
     OR (lr_db_rec.nt_type IS NOT NULL AND pi_old_network_type IS NULL)
     --
     OR (lr_db_rec.nt_unique != pi_old_unique_name)
     OR (lr_db_rec.nt_unique IS NULL AND pi_old_unique_name IS NOT NULL)
     OR (lr_db_rec.nt_unique IS NOT NULL AND pi_old_unique_name IS NULL)
     --
     OR (UPPER(lr_db_rec.nt_descr) != UPPER(pi_old_description))
     OR (lr_db_rec.nt_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_rec.nt_descr IS NOT NULL AND pi_old_description IS NULL)
     --
     OR (lr_db_rec.nt_node_type != pi_old_node_type)
     OR (lr_db_rec.nt_node_type IS NULL AND pi_old_node_type IS NOT NULL)
     OR (lr_db_rec.nt_node_type IS NOT NULL AND pi_old_node_type IS NULL)
     --
     OR (lr_db_rec.nt_datum != pi_old_is_datum)
     OR (lr_db_rec.nt_datum IS NULL AND pi_old_is_datum IS NOT NULL)
     OR (lr_db_rec.nt_datum IS NOT NULL AND pi_old_is_datum IS NULL)
     --
     OR (lr_db_rec.nt_linear != pi_old_is_linear)
     OR (lr_db_rec.nt_linear IS NULL AND pi_old_is_linear IS NOT NULL)
     OR (lr_db_rec.nt_linear IS NOT NULL AND pi_old_is_linear IS NULL)
     --
     OR (lr_db_rec.nt_pop_unique != pi_old_is_unique)
     OR (lr_db_rec.nt_pop_unique IS NULL AND pi_old_is_unique IS NOT NULL)
     OR (lr_db_rec.nt_pop_unique IS NOT NULL AND pi_old_is_unique IS NULL)
     --
     OR (lr_db_rec.nt_length_unit != pi_old_units)
     OR (lr_db_rec.nt_length_unit IS NULL AND pi_old_units IS NOT NULL)
     OR (lr_db_rec.nt_length_unit IS NOT NULL AND pi_old_units IS NULL)
     --
     OR (lr_db_rec.nt_admin_type != pi_old_admin_type)
     OR (lr_db_rec.nt_admin_type IS NULL AND pi_old_admin_type IS NOT NULL)
     OR (lr_db_rec.nt_admin_type IS NOT NULL AND pi_old_admin_type IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_network_type != pi_new_network_type
       OR (pi_old_network_type IS NULL AND pi_new_network_type IS NOT NULL)
       OR (pi_old_network_type IS NOT NULL AND pi_new_network_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_unique_name != pi_new_unique_name
       OR (pi_old_unique_name IS NULL AND pi_new_unique_name IS NOT NULL)
       OR (pi_old_unique_name IS NOT NULL AND pi_new_unique_name IS NULL)
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
      IF pi_old_node_type != pi_new_node_type
       OR (pi_old_node_type IS NULL AND pi_new_node_type IS NOT NULL)
       OR (pi_old_node_type IS NOT NULL AND pi_new_node_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_is_datum != pi_new_is_datum
       OR (pi_old_is_datum IS NULL AND pi_new_is_datum IS NOT NULL)
       OR (pi_old_is_datum IS NOT NULL AND pi_new_is_datum IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_is_linear != pi_new_is_linear
       OR (pi_old_is_linear IS NULL AND pi_new_is_linear IS NOT NULL)
       OR (pi_old_is_linear IS NOT NULL AND pi_new_is_linear IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_is_unique != pi_new_is_unique
       OR (pi_old_is_unique IS NULL AND pi_new_is_unique IS NOT NULL)
       OR (pi_old_is_unique IS NOT NULL AND pi_new_is_unique IS NULL)
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
      IF pi_old_admin_type != pi_new_admin_type
       OR (pi_old_admin_type IS NULL AND pi_new_admin_type IS NOT NULL)
       OR (pi_old_admin_type IS NOT NULL AND pi_new_admin_type IS NULL)
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
        UPDATE nm_types
           SET nt_type         = UPPER(pi_new_network_type)
              ,nt_unique       = UPPER(pi_new_unique_name)
              ,nt_descr        = pi_new_description
              ,nt_node_type    = pi_new_node_type
              ,nt_datum        = pi_new_is_datum
              ,nt_linear       = pi_new_is_linear
              ,nt_pop_unique   = pi_new_is_unique
              ,nt_length_unit  = pi_new_units
              ,nt_admin_type   = pi_new_admin_type
         WHERE nt_type         = pi_old_network_type;
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
        ROLLBACK TO update_network_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_network_type;
  
  --
  -----------------------------------------------------------------------------
  --                             
  PROCEDURE delete_network_type(pi_network_type      IN     nm_types.nt_type%TYPE
                               ,po_message_severity     OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor       OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_network_type_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    IF network_type_exists(pi_network_type => pi_network_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Network Type:  '||pi_network_type);
    END IF;
    --
    DELETE
      FROM nm_types
     WHERE nt_type = UPPER(pi_network_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_network_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_network_type;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_columns(pi_nt_type             IN      nm_type_columns.ntc_nt_type%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ntc_nt_type             network_type
          ,ntc_column_name         column_name
          ,ntc_seq_no              seq_no
          ,ntc_prompt              prompt
          ,ntc_column_type         column_type
          ,ntc_str_length          length
          ,ntc_displayed           displayed
          ,ntc_mandatory           mandatory
          ,ntc_domain              domain
          ,ntc_seq_name            seq_name
          ,ntc_unique_seq          unique_seq
          ,ntc_separator           separator
          ,ntc_format              format
          ,ntc_unique_format       unique_format
          ,ntc_default             default_value
          ,ntc_string_start        string_start
          ,ntc_string_end          string_end
          ,ntc_inherit             inherit
          ,ntc_query               query 
      FROM nm_type_columns
     WHERE ntc_nt_type = pi_nt_type
     ORDER BY ntc_seq_no;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_columns;                                
                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_column(pi_nt_type             IN      nm_type_columns.ntc_nt_type%TYPE
                              ,pi_nt_column_name      IN      nm_type_columns.ntc_column_name%TYPE  
                              ,po_message_severity        OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor          OUT sys_refcursor
                              ,po_cursor                  OUT sys_refcursor)

  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ntc_nt_type             network_type
          ,ntc_column_name         column_name
          ,ntc_seq_no              seq_no
          ,ntc_prompt              prompt
          ,ntc_column_type         column_type
          ,ntc_str_length          length
          ,ntc_displayed           displayed
          ,ntc_mandatory           mandatory
          ,ntc_domain              domain
          ,ntc_seq_name            seq_name
          ,ntc_unique_seq          unique_seq
          ,ntc_separator           separator
          ,ntc_format              format
          ,ntc_unique_format       unique_format
          ,ntc_default             default_value
          ,ntc_string_start        string_start
          ,ntc_string_end          string_end
          ,ntc_inherit             inherit
          ,ntc_query               query 
      FROM nm_type_columns
     WHERE ntc_nt_type     = pi_nt_type
       AND ntc_column_name = pi_nt_column_name
     ORDER BY ntc_seq_no;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_column;                                                        

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nt_type_columns(pi_nt_type              IN     nm_type_columns.ntc_nt_type%TYPE
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
  lv_driving_sql  nm3type.max_varchar2 :='SELECT ntc_nt_type             network_type
                                                ,ntc_column_name         column_name
                                                ,ntc_seq_no              seq_no
                                                ,ntc_prompt              prompt
                                                ,ntc_column_type         column_type
                                                ,ntc_str_length          length
                                                ,ntc_displayed           displayed
                                                ,ntc_mandatory           mandatory
                                                ,ntc_domain              domain
                                                ,ntc_seq_name            seq_name
                                                ,ntc_unique_seq          unique_seq
                                                ,ntc_separator           separator
                                                ,ntc_format              format
                                                ,ntc_unique_format       unique_format
                                                ,ntc_default             default_value
                                                ,ntc_string_start        string_start
                                                ,ntc_string_end          string_end
                                                ,ntc_inherit             inherit
                                                ,ntc_query               query 
                                            FROM nm_type_columns
                                           WHERE ntc_nt_type = :pi_nt_type ';
  --
  lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  network_type'
                                              ||',column_name'
                                              ||',seq_no'
                                              ||',prompt'
                                              ||',column_type'
                                              ||',length'
                                              ||',displayed'
                                              ||',mandatory'
                                              ||',domain'
                                              ||',seq_name'
                                              ||',unique_seq'
                                              ||',separator'
                                              ||',format'
                                              ||',unique_format'
                                              ||',default_value'
                                              ||',string_start'
                                              ||',string_end'
                                              ||',inherit'
                                              ||',query'
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
      awlrs_util.add_column_data(pi_cursor_col => 'seq_no'
                                ,pi_query_col  => 'ntc_seq_no'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'column_name'
                                ,pi_query_col  => 'ntc_column_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'column_type'
                                ,pi_query_col  => 'ntc_column_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'displayed'
                                ,pi_query_col  => 'ntc_displayed'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'prompt'
                                ,pi_query_col  => 'ntc_prompt'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'mandatory'
                                ,pi_query_col  => 'ntc_mandatory'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ntc_seq_no')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_nt_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_nt_type
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
  END get_paged_nt_type_columns;      
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION nt_column_exists(pi_nt_type          IN     nm_type_columns.ntc_nt_type%TYPE
                           ,pi_column_name      IN     nm_type_columns.ntc_column_name%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_type_columns
     WHERE ntc_nt_type     = UPPER(pi_nt_type)
       AND ntc_column_name = UPPER(pi_column_name);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
        
  END nt_column_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_data_val_columns(pi_domain           IN     nm_type_columns.ntc_domain%TYPE
                                     ,pi_seq_name         IN     nm_type_columns.ntc_seq_name%TYPE
                                     ,pi_default_value    IN     nm_type_columns.ntc_default%TYPE
                                     ,pi_query            IN     nm_type_columns.ntc_query%TYPE)
  IS
  
  BEGIN
    
    IF  (pi_domain IS NOT NULL AND (pi_query IS NOT NULL OR pi_seq_name IS NOT NULL OR pi_default_value IS NOT NULL))
  	 OR (pi_query  IS NOT NULL AND (pi_domain IS NOT NULL OR pi_seq_name IS NOT NULL OR pi_default_value IS NOT NULL))
  	 OR (pi_seq_name IS NOT NULL AND (pi_query IS NOT NULL OR pi_domain IS NOT NULL OR pi_default_value IS NOT NULL))
  	 OR (pi_default_value IS NOT NULL AND (pi_domain IS NOT NULL OR pi_seq_name IS NOT NULL OR pi_query IS NOT NULL)) 
  	  THEN
  	     hig.raise_ner(pi_appl => 'AWLRS'
                      ,pi_id   =>  75);  
  	END IF;  
  
  END validate_data_val_columns;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_string_start_end(pi_string_start  IN   nm_type_columns.ntc_string_start%TYPE
                                     ,pi_string_end    IN   nm_type_columns.ntc_string_end%TYPE)
  IS
  
  BEGIN
    
    IF (pi_string_start IS NOT NULL AND pi_string_end IS NOT NULL)
  	  THEN
  	    IF pi_string_start > pi_string_end 
  	      THEN 
  	         hig.raise_ner(pi_appl => 'AWLRS'
                          ,pi_id   =>  76);  
        END IF;                  
  	END IF;  
  
  END validate_string_start_end;    
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_default_value(pi_default_value IN OUT nm_type_columns.ntc_default%TYPE)
  IS
  
  l_default_value nm_type_columns.ntc_default%TYPE  :=  pi_default_value;
  BEGIN
    
  IF pi_default_value IS NOT NULL
     AND NOT(nm3nwval.is_nm_elements_col(p_column => pi_default_value))
	 AND NOT(nm3flx.can_string_be_select_from_tab(pi_string       => pi_default_value
                                                 ,pi_table        => 'NM_ELEMENTS'
                                                 ,pi_remove_binds => TRUE))
    AND NOT(nm3flx.can_string_be_select_from_dual(p_string => pi_default_value))
  THEN
    IF nm3flx.can_string_be_select_from_dual(p_string => pi_default_value)
    THEN
      --value works with quotes so add them
      pi_default_value := nm3flx.string(pi_default_value);
    ELSE
    	 hig.raise_ner(pi_appl => 'HIG'
                      ,pi_id   =>  110
                      ,pi_supplementary_info  => 'Default Value:  '||pi_default_value);  
    END IF;
  END IF;

  END validate_default_value;                                       
  
  --
  -----------------------------------------------------------------------------
  --
  
  PROCEDURE create_nt_type_column(pi_nt_type          IN     nm_type_columns.ntc_nt_type%TYPE
                                 ,pi_column_name      IN     nm_type_columns.ntc_column_name%TYPE
                                 ,pi_seq_no           IN     nm_type_columns.ntc_seq_no%TYPE
                                 ,pi_prompt           IN     nm_type_columns.ntc_prompt%TYPE
                                 ,pi_column_type      IN     nm_type_columns.ntc_column_type%TYPE
                                 ,pi_length           IN     nm_type_columns.ntc_str_length%TYPE
                                 ,pi_displayed        IN     nm_type_columns.ntc_displayed%TYPE
                                 ,pi_mandatory        IN     nm_type_columns.ntc_mandatory%TYPE
                                 ,pi_domain           IN     nm_type_columns.ntc_domain%TYPE
                                 ,pi_seq_name         IN     nm_type_columns.ntc_seq_name%TYPE
                                 ,pi_unique_seq       IN     nm_type_columns.ntc_unique_seq%TYPE
                                 ,pi_separator        IN     nm_type_columns.ntc_separator%TYPE
                                 ,pi_format           IN     nm_type_columns.ntc_format%TYPE
                                 ,pi_unique_format    IN     nm_type_columns.ntc_unique_format%TYPE
                                 ,pi_default_value    IN     nm_type_columns.ntc_default%TYPE
                                 ,pi_string_start     IN     nm_type_columns.ntc_string_start%TYPE
                                 ,pi_string_end       IN     nm_type_columns.ntc_string_end%TYPE
                                 ,pi_inherit          IN     nm_type_columns.ntc_inherit%TYPE
                                 ,pi_query            IN     nm_type_columns.ntc_query%TYPE
                                 ,pi_updatable        IN     nm_type_columns.ntc_updatable%TYPE  DEFAULT 'Y'
                                 ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT sys_refcursor)
  IS
  
  lv_default_value nm_type_columns.ntc_default%TYPE  :=  pi_default_value;
    --
  BEGIN
    --
    SAVEPOINT create_nt_type_column_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_nt_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Seq No'
                               ,pi_parameter_value => pi_seq_no);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Length'
                               ,pi_parameter_value => pi_length);   
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Displayed'
                          ,pi_parameter_value => pi_displayed);   
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_mandatory);   
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Inherit'
                          ,pi_parameter_value => pi_inherit);   
    --
    validate_data_val_columns(pi_domain         =>  pi_domain
                             ,pi_seq_name       =>  pi_seq_name
                             ,pi_default_value  =>  pi_default_value
                             ,pi_query          =>  pi_query);
    --
    validate_string_start_end(pi_string_start => pi_string_start
                             ,pi_string_end   => pi_string_end);
    --
    validate_default_value(pi_default_value => lv_default_value);                                                   
    --
    IF nt_column_exists(pi_nt_type     => pi_nt_type
                       ,pi_column_name => pi_column_name) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Network Type Column:  '||pi_nt_type||' - '||pi_column_name);
    END IF;
    --
    --lov validation
    IF column_type_exists(pi_column_type => pi_column_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Column Type:  '||pi_column_type);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_column_name) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Column Name:  '||pi_column_name);
    END IF;
    --
    IF seq_name_exists(pi_seq_name => pi_seq_name) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Sequence Name:  '||pi_seq_name);
    END IF;
    --
    IF domain_exists(pi_domain => pi_domain) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Domain:  '||pi_domain);
    END IF;
    --
    /*
    ||insert into nm_type_columns.
    */
    INSERT
      INTO nm_type_columns
           (ntc_nt_type
           ,ntc_column_name
           ,ntc_column_type
           ,ntc_seq_no
           ,ntc_displayed
           ,ntc_str_length
           ,ntc_mandatory
           ,ntc_domain
           ,ntc_query  
           ,ntc_inherit
           ,ntc_string_start
           ,ntc_string_end
           ,ntc_seq_name
           ,ntc_format
           ,ntc_prompt
           ,ntc_default   
           ,ntc_default_type 
           ,ntc_separator   
           ,ntc_unique_seq
           ,ntc_unique_format
           ,ntc_updatable
           )
    VALUES (UPPER(pi_nt_type)
           ,UPPER(pi_column_name)
           ,pi_column_type
           ,pi_seq_no
           ,pi_displayed
           ,pi_length
           ,pi_mandatory
           ,pi_domain
           ,pi_query
           ,pi_inherit
           ,pi_string_start
           ,pi_string_end
           ,pi_seq_name
           ,pi_format
           ,pi_prompt
           ,lv_default_value
           ,Null
           ,pi_separator
           ,pi_unique_seq
           ,pi_unique_format
           ,pi_updatable
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_nt_type_column_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_nt_type_column;                                                                       
  
  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE update_nt_type_column(pi_old_nt_type          IN     nm_type_columns.ntc_nt_type%TYPE
                                 ,pi_old_column_name      IN     nm_type_columns.ntc_column_name%TYPE
                                 ,pi_old_seq_no           IN     nm_type_columns.ntc_seq_no%TYPE
                                 ,pi_old_prompt           IN     nm_type_columns.ntc_prompt%TYPE
                                 ,pi_old_column_type      IN     nm_type_columns.ntc_column_type%TYPE
                                 ,pi_old_length           IN     nm_type_columns.ntc_str_length%TYPE
                                 ,pi_old_displayed        IN     nm_type_columns.ntc_displayed%TYPE
                                 ,pi_old_mandatory        IN     nm_type_columns.ntc_mandatory%TYPE
                                 ,pi_old_domain           IN     nm_type_columns.ntc_domain%TYPE
                                 ,pi_old_seq_name         IN     nm_type_columns.ntc_seq_name%TYPE
                                 ,pi_old_unique_seq       IN     nm_type_columns.ntc_unique_seq%TYPE
                                 ,pi_old_separator        IN     nm_type_columns.ntc_separator%TYPE
                                 ,pi_old_format           IN     nm_type_columns.ntc_format%TYPE
                                 ,pi_old_unique_format    IN     nm_type_columns.ntc_unique_format%TYPE
                                 ,pi_old_default_value    IN     nm_type_columns.ntc_default%TYPE
                                 ,pi_old_string_start     IN     nm_type_columns.ntc_string_start%TYPE
                                 ,pi_old_string_end       IN     nm_type_columns.ntc_string_end%TYPE
                                 ,pi_old_inherit          IN     nm_type_columns.ntc_inherit%TYPE
                                 ,pi_old_query            IN     nm_type_columns.ntc_query%TYPE
                                 ,pi_new_nt_type          IN     nm_type_columns.ntc_nt_type%TYPE
                                 ,pi_new_column_name      IN     nm_type_columns.ntc_column_name%TYPE
                                 ,pi_new_seq_no           IN     nm_type_columns.ntc_seq_no%TYPE
                                 ,pi_new_prompt           IN     nm_type_columns.ntc_prompt%TYPE
                                 ,pi_new_column_type      IN     nm_type_columns.ntc_column_type%TYPE
                                 ,pi_new_length           IN     nm_type_columns.ntc_str_length%TYPE
                                 ,pi_new_displayed        IN     nm_type_columns.ntc_displayed%TYPE
                                 ,pi_new_mandatory        IN     nm_type_columns.ntc_mandatory%TYPE
                                 ,pi_new_domain           IN     nm_type_columns.ntc_domain%TYPE
                                 ,pi_new_seq_name         IN     nm_type_columns.ntc_seq_name%TYPE
                                 ,pi_new_unique_seq       IN     nm_type_columns.ntc_unique_seq%TYPE
                                 ,pi_new_separator        IN     nm_type_columns.ntc_separator%TYPE
                                 ,pi_new_format           IN     nm_type_columns.ntc_format%TYPE
                                 ,pi_new_unique_format    IN     nm_type_columns.ntc_unique_format%TYPE
                                 ,pi_new_default_value    IN     nm_type_columns.ntc_default%TYPE
                                 ,pi_new_string_start     IN     nm_type_columns.ntc_string_start%TYPE
                                 ,pi_new_string_end       IN     nm_type_columns.ntc_string_end%TYPE
                                 ,pi_new_inherit          IN     nm_type_columns.ntc_inherit%TYPE
                                 ,pi_new_query            IN     nm_type_columns.ntc_query%TYPE
                                 ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor          OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_type_columns%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    lv_default_value  nm_type_columns.ntc_default%TYPE  :=  pi_new_default_value;
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_type_columns
       WHERE ntc_nt_type     = UPPER(pi_old_nt_type)
         AND ntc_column_name = UPPER(pi_old_column_name)
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Network Type Column does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_nt_type_column_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_new_nt_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Seq No'
                               ,pi_parameter_value => pi_new_seq_no);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Length'
                               ,pi_parameter_value => pi_new_length);   
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Displayed'
                          ,pi_parameter_value => pi_new_displayed);   
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_new_mandatory);   
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Inherit'
                          ,pi_parameter_value => pi_new_inherit);   
    --
    validate_data_val_columns(pi_domain         =>  pi_new_domain
                             ,pi_seq_name       =>  pi_new_seq_name
                             ,pi_default_value  =>  pi_new_default_value
                             ,pi_query          =>  pi_new_query);
    --
    validate_string_start_end(pi_string_start => pi_new_string_start
                             ,pi_string_end   => pi_new_string_end);
    --
    validate_default_value(pi_default_value => lv_default_value);                                                   
    --
    --lov validation
    IF column_type_exists(pi_column_type => pi_new_column_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Column Type:  '||pi_new_column_type);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_new_column_name) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Column Name:  '||pi_new_column_name);
    END IF;
    --
    IF seq_name_exists(pi_seq_name => pi_new_seq_name) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Sequence Name:  '||pi_new_seq_name);
    END IF;
    --
    IF domain_exists(pi_domain => pi_new_domain) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Domain:  '||pi_new_domain);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.ntc_nt_type != pi_old_nt_type
     OR (lr_db_rec.ntc_nt_type IS NULL AND pi_old_nt_type IS NOT NULL)
     OR (lr_db_rec.ntc_nt_type IS NOT NULL AND pi_old_nt_type IS NULL)
     --
     OR (lr_db_rec.ntc_column_name != pi_old_column_name)
     OR (lr_db_rec.ntc_column_name IS NULL AND pi_old_column_name IS NOT NULL)
     OR (lr_db_rec.ntc_column_name IS NOT NULL AND pi_old_column_name IS NULL)
     --
     OR (lr_db_rec.ntc_seq_no != pi_old_seq_no)
     OR (lr_db_rec.ntc_seq_no IS NULL AND pi_old_seq_no IS NOT NULL)
     OR (lr_db_rec.ntc_seq_no IS NOT NULL AND pi_old_seq_no IS NULL)
     --
     OR (lr_db_rec.ntc_prompt != pi_old_prompt)
     OR (lr_db_rec.ntc_prompt IS NULL AND pi_old_prompt IS NOT NULL)
     OR (lr_db_rec.ntc_prompt IS NOT NULL AND pi_old_prompt IS NULL)
     --
     OR (lr_db_rec.ntc_column_type != pi_old_column_type)
     OR (lr_db_rec.ntc_column_type IS NULL AND pi_old_column_type IS NOT NULL)
     OR (lr_db_rec.ntc_column_type IS NOT NULL AND pi_old_column_type IS NULL)
     --
     OR (lr_db_rec.ntc_str_length != pi_old_length)
     OR (lr_db_rec.ntc_str_length IS NULL AND pi_old_length IS NOT NULL)
     OR (lr_db_rec.ntc_str_length IS NOT NULL AND pi_old_length IS NULL)
     --
     OR (lr_db_rec.ntc_displayed != pi_old_displayed)
     OR (lr_db_rec.ntc_displayed IS NULL AND pi_old_displayed IS NOT NULL)
     OR (lr_db_rec.ntc_displayed IS NOT NULL AND pi_old_displayed IS NULL)
     --
     OR (lr_db_rec.ntc_mandatory != pi_old_mandatory)
     OR (lr_db_rec.ntc_mandatory IS NULL AND pi_old_mandatory IS NOT NULL)
     OR (lr_db_rec.ntc_mandatory IS NOT NULL AND pi_old_mandatory IS NULL)
     --
     OR (lr_db_rec.ntc_domain != pi_old_domain)
     OR (lr_db_rec.ntc_domain IS NULL AND pi_old_domain IS NOT NULL)
     OR (lr_db_rec.ntc_domain IS NOT NULL AND pi_old_domain IS NULL)
     --
     OR (lr_db_rec.ntc_seq_name != pi_old_seq_name)
     OR (lr_db_rec.ntc_seq_name IS NULL AND pi_old_seq_name IS NOT NULL)
     OR (lr_db_rec.ntc_seq_name IS NOT NULL AND pi_old_seq_name IS NULL)
     --
     OR (lr_db_rec.ntc_unique_seq != pi_old_unique_seq)
     OR (lr_db_rec.ntc_unique_seq IS NULL AND pi_old_unique_seq IS NOT NULL)
     OR (lr_db_rec.ntc_unique_seq IS NOT NULL AND pi_old_unique_seq IS NULL)
     --
     OR (lr_db_rec.ntc_separator != pi_old_separator)
     OR (lr_db_rec.ntc_separator IS NULL AND pi_old_separator IS NOT NULL)
     OR (lr_db_rec.ntc_separator IS NOT NULL AND pi_old_separator IS NULL)
     --
     OR (lr_db_rec.ntc_format != pi_old_format)
     OR (lr_db_rec.ntc_format IS NULL AND pi_old_format IS NOT NULL)
     OR (lr_db_rec.ntc_format IS NOT NULL AND pi_old_format IS NULL)
     --
     OR (lr_db_rec.ntc_unique_format != pi_old_unique_format)
     OR (lr_db_rec.ntc_unique_format IS NULL AND pi_old_unique_format IS NOT NULL)
     OR (lr_db_rec.ntc_unique_format IS NOT NULL AND pi_old_unique_format IS NULL)
     --
     OR (lr_db_rec.ntc_default != pi_old_default_value)
     OR (lr_db_rec.ntc_default IS NULL AND pi_old_default_value IS NOT NULL)
     OR (lr_db_rec.ntc_default IS NOT NULL AND pi_old_default_value IS NULL)
     --
     OR (lr_db_rec.ntc_string_start != pi_old_string_start)
     OR (lr_db_rec.ntc_string_start IS NULL AND pi_old_string_start IS NOT NULL)
     OR (lr_db_rec.ntc_string_start IS NOT NULL AND pi_old_string_start IS NULL)
     --
     OR (lr_db_rec.ntc_string_end != pi_old_string_end)
     OR (lr_db_rec.ntc_string_end IS NULL AND pi_old_string_end IS NOT NULL)
     OR (lr_db_rec.ntc_string_end IS NOT NULL AND pi_old_string_end IS NULL)
     --
     OR (lr_db_rec.ntc_inherit != pi_old_inherit)
     OR (lr_db_rec.ntc_inherit IS NULL AND pi_old_inherit IS NOT NULL)
     OR (lr_db_rec.ntc_inherit IS NOT NULL AND pi_old_inherit IS NULL)
     --
     OR (lr_db_rec.ntc_query != pi_old_query)
     OR (lr_db_rec.ntc_query IS NULL AND pi_old_query IS NOT NULL)
     OR (lr_db_rec.ntc_query IS NOT NULL AND pi_old_query IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nt_type != pi_new_nt_type
       OR (pi_old_nt_type IS NULL AND pi_new_nt_type IS NOT NULL)
       OR (pi_old_nt_type IS NOT NULL AND pi_new_nt_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_column_name != pi_new_column_name
       OR (pi_old_column_name IS NULL AND pi_new_column_name IS NOT NULL)
       OR (pi_old_column_name IS NOT NULL AND pi_new_column_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_seq_no != pi_new_seq_no
       OR (pi_old_seq_no IS NULL AND pi_new_seq_no IS NOT NULL)
       OR (pi_old_seq_no IS NOT NULL AND pi_new_seq_no IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_prompt != pi_new_prompt
       OR (pi_old_prompt IS NULL AND pi_new_prompt IS NOT NULL)
       OR (pi_old_prompt IS NOT NULL AND pi_new_prompt IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_column_type != pi_new_column_type
       OR (pi_old_column_type IS NULL AND pi_new_column_type IS NOT NULL)
       OR (pi_old_column_type IS NOT NULL AND pi_new_column_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_length != pi_new_length
       OR (pi_old_length IS NULL AND pi_new_length IS NOT NULL)
       OR (pi_old_length IS NOT NULL AND pi_new_length IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_displayed != pi_new_displayed
       OR (pi_old_displayed IS NULL AND pi_new_displayed IS NOT NULL)
       OR (pi_old_displayed IS NOT NULL AND pi_new_displayed IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_mandatory != pi_new_mandatory
       OR (pi_old_mandatory IS NULL AND pi_new_mandatory IS NOT NULL)
       OR (pi_old_mandatory IS NOT NULL AND pi_new_mandatory IS NULL)
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
      IF pi_old_seq_name != pi_new_seq_name
       OR (pi_old_seq_name IS NULL AND pi_new_seq_name IS NOT NULL)
       OR (pi_old_seq_name IS NOT NULL AND pi_new_seq_name IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_unique_seq != pi_new_unique_seq
       OR (pi_old_unique_seq IS NULL AND pi_new_unique_seq IS NOT NULL)
       OR (pi_old_unique_seq IS NOT NULL AND pi_new_unique_seq IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_separator != pi_new_separator
       OR (pi_old_separator IS NULL AND pi_new_separator IS NOT NULL)
       OR (pi_old_separator IS NOT NULL AND pi_new_separator IS NULL)
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
      IF pi_old_unique_format != pi_new_unique_format
       OR (pi_old_unique_format IS NULL AND pi_new_unique_format IS NOT NULL)
       OR (pi_old_unique_format IS NOT NULL AND pi_new_unique_format IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_default_value != pi_new_default_value
       OR (pi_old_default_value IS NULL AND pi_new_default_value IS NOT NULL)
       OR (pi_old_default_value IS NOT NULL AND pi_new_default_value IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_string_start != pi_new_string_start
       OR (pi_old_string_start IS NULL AND pi_new_string_start IS NOT NULL)
       OR (pi_old_string_start IS NOT NULL AND pi_new_string_start IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_string_end != pi_new_string_end
       OR (pi_old_string_end IS NULL AND pi_new_string_end IS NOT NULL)
       OR (pi_old_string_end IS NOT NULL AND pi_new_string_end IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_inherit != pi_new_inherit
       OR (pi_old_inherit IS NULL AND pi_new_inherit IS NOT NULL)
       OR (pi_old_inherit IS NOT NULL AND pi_new_inherit IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_query != pi_new_query
       OR (pi_old_query IS NULL AND pi_new_query IS NOT NULL)
       OR (pi_old_query IS NOT NULL AND pi_new_separator IS NULL)
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
        UPDATE nm_type_columns
           SET ntc_seq_no        = pi_new_seq_no
              ,ntc_prompt        = pi_new_prompt
              ,ntc_column_type   = pi_new_column_type   
              ,ntc_str_length    = pi_new_length
              ,ntc_displayed     = pi_new_displayed
              ,ntc_mandatory     = pi_new_mandatory
              ,ntc_domain        = pi_new_domain
              ,ntc_seq_name      = pi_new_seq_name
              ,ntc_unique_seq    = pi_new_unique_seq
              ,ntc_separator     = pi_new_separator
              ,ntc_format        = pi_new_format 
              ,ntc_unique_format = pi_new_unique_format
              ,ntc_default       = lv_default_value
              ,ntc_string_start  = pi_new_string_start
              ,ntc_string_end    = pi_new_string_end
              ,ntc_inherit       = pi_new_inherit
              ,ntc_query         = pi_new_query
         WHERE ntc_nt_type       = UPPER(pi_new_nt_type)
           AND ntc_column_name   = UPPER(pi_new_column_name);          
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
        ROLLBACK TO update_nt_type_column_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_nt_type_column;                                 
                                     
  --
  -----------------------------------------------------------------------------
  --                                                                              
  PROCEDURE delete_nt_type_column(pi_nt_type          IN     nm_type_columns.ntc_nt_type%TYPE
                                 ,pi_column_name      IN     nm_type_columns.ntc_column_name%TYPE
                                 ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor      OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_nt_type_column_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    IF nt_column_exists(pi_nt_type     => pi_nt_type
                       ,pi_column_name => pi_nt_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Network Type Column:  '||pi_nt_type||' - '||pi_column_name);
    END IF;
    --
    DELETE
      FROM nm_type_columns
     WHERE ntc_nt_type     = UPPER(pi_nt_type)
       AND ntc_column_name = UPPER(pi_column_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_nt_type_column_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_nt_type_column;                                  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_subclasses(pi_nt_type             IN     nm_type_subclass.nsc_nw_type%TYPE
                                  ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor         OUT sys_refcursor
                                  ,po_cursor                 OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nsc_nw_type             network_type
          ,nsc_sub_class           sub_class
          ,nsc_seq_no              seq_no
          ,nsc_descr               description
      FROM nm_type_subclass
     WHERE UPPER(nsc_nw_type) = UPPER(pi_nt_type)
     ORDER BY nsc_seq_no;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_subclasses;                                   
                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_subclass(pi_nt_type            IN     nm_type_subclass.nsc_nw_type%TYPE
                                ,pi_sub_class          IN     nm_type_subclass.nsc_sub_class%TYPE
                                ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor        OUT sys_refcursor
                                ,po_cursor                OUT sys_refcursor)
 IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nsc_nw_type             network_type
          ,nsc_sub_class           sub_class
          ,nsc_seq_no              seq_no
          ,nsc_descr               description
      FROM nm_type_subclass
     WHERE UPPER(nsc_nw_type)   = UPPER(pi_nt_type)
       AND UPPER(nsc_sub_class) = UPPER(pi_sub_class);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_subclass;                                  
                                                            

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nt_type_subclasses(pi_nt_type            IN     nm_type_subclass.nsc_nw_type%TYPE
                                        ,pi_filter_columns     IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_operators   IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_values_1    IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_filter_values_2    IN     nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_order_columns      IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_order_asc_desc     IN     nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                        ,pi_skip_n_rows        IN     PLS_INTEGER
                                        ,pi_pagesize           IN     PLS_INTEGER
                                        ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor        OUT sys_refcursor
                                        ,po_cursor                OUT sys_refcursor)
                                        
  IS
  --
  lv_lower_index      PLS_INTEGER;
  lv_upper_index      PLS_INTEGER;
  lv_row_restriction  nm3type.max_varchar2;
  lv_order_by         nm3type.max_varchar2;
  lv_filter           nm3type.max_varchar2;
  --
  lv_driving_sql  nm3type.max_varchar2 :='SELECT nsc_nw_type             network_type
                                                ,nsc_sub_class           sub_class
                                                ,nsc_seq_no              seq_no
                                                ,nsc_descr               description
                                            FROM nm_type_subclass
                                           WHERE UPPER(nsc_nw_type) = UPPER(:pi_nt_type) ';
  --
  lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  network_type'
                                              ||',sub_class'
                                              ||',seq_no'
                                              ||',description'
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
      awlrs_util.add_column_data(pi_cursor_col => 'seq_no'
                                ,pi_query_col  => 'nsc_seq_no'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'sub_class'
                                ,pi_query_col  => 'nsc_sub_class'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nsc_descr'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nsc_seq_no')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_nt_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_nt_type
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
  END get_paged_nt_type_subclasses;      
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_nt_sub_class(pi_nt_type          IN     nm_type_subclass.nsc_nw_type%TYPE
                               ,pi_sub_class        IN     nm_type_subclass.nsc_sub_class%TYPE
                               ,pi_description      IN     nm_type_subclass.nsc_descr%TYPE
                               ,pi_seq_no           IN     nm_type_subclass.nsc_seq_no%TYPE
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT create_nt_sub_class_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_nt_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sub Class'
                               ,pi_parameter_value => pi_sub_class);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Seq No'
                               ,pi_parameter_value => pi_seq_no);
    --
    
    IF sub_class_exists(pi_nt_type   => pi_nt_type
                       ,pi_sub_class => pi_sub_class) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Sub Class:  '||pi_sub_class);
    END IF;
    --
    /*
    ||insert into nm_type_subclass.
    */
    INSERT
      INTO nm_type_subclass
           (nsc_nw_type
           ,nsc_sub_class
           ,nsc_descr
           ,nsc_seq_no
           )
    VALUES (UPPER(pi_nt_type)
           ,UPPER(pi_sub_class)
           ,UPPER(pi_description)
           ,pi_seq_no
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_nt_sub_class_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_nt_sub_class;    
  
  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE update_nt_sub_class(pi_old_nt_type      IN     nm_type_subclass.nsc_nw_type%TYPE
                               ,pi_old_sub_class    IN     nm_type_subclass.nsc_sub_class%TYPE
                               ,pi_old_description  IN     nm_type_subclass.nsc_descr%TYPE
                               ,pi_old_seq_no       IN     nm_type_subclass.nsc_seq_no%TYPE
                               ,pi_new_nt_type      IN     nm_type_subclass.nsc_nw_type%TYPE
                               ,pi_new_sub_class    IN     nm_type_subclass.nsc_sub_class%TYPE
                               ,pi_new_description  IN     nm_type_subclass.nsc_descr%TYPE
                               ,pi_new_seq_no       IN     nm_type_subclass.nsc_seq_no%TYPE
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor)

  IS
    --
    lr_db_rec        nm_type_subclass%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_type_subclass
       WHERE nsc_nw_type   = pi_old_nt_type
         AND nsc_sub_class = pi_old_sub_class
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Sub Class does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_nt_sub_class_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_new_nt_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Sub Class'
                               ,pi_parameter_value => pi_new_sub_class);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Seq No'
                               ,pi_parameter_value => pi_new_seq_no);
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nsc_nw_type != pi_old_nt_type
     OR (lr_db_rec.nsc_nw_type IS NULL AND pi_old_nt_type IS NOT NULL)
     OR (lr_db_rec.nsc_nw_type IS NOT NULL AND pi_old_nt_type IS NULL)
     --
     OR (lr_db_rec.nsc_sub_class != pi_old_sub_class)
     OR (lr_db_rec.nsc_sub_class IS NULL AND pi_old_sub_class IS NOT NULL)
     OR (lr_db_rec.nsc_sub_class IS NOT NULL AND pi_old_sub_class IS NULL)
     --
     OR (UPPER(lr_db_rec.nsc_descr) != UPPER(pi_old_description))
     OR (lr_db_rec.nsc_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_rec.nsc_descr IS NOT NULL AND pi_old_description IS NULL)
     --
     OR (lr_db_rec.nsc_seq_no != pi_old_seq_no)
     OR (lr_db_rec.nsc_seq_no IS NULL AND pi_old_seq_no IS NOT NULL)
     OR (lr_db_rec.nsc_seq_no IS NOT NULL AND pi_old_seq_no IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nt_type != pi_new_nt_type
       OR (pi_old_nt_type IS NULL AND pi_new_nt_type IS NOT NULL)
       OR (pi_old_nt_type IS NOT NULL AND pi_new_nt_type IS NULL)
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
      IF pi_old_description != pi_new_description
       OR (pi_old_description IS NULL AND pi_new_description IS NOT NULL)
       OR (pi_old_description IS NOT NULL AND pi_new_description IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_seq_no != pi_new_seq_no
       OR (pi_old_seq_no IS NULL AND pi_new_seq_no IS NOT NULL)
       OR (pi_old_seq_no IS NOT NULL AND pi_new_seq_no IS NULL)
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
        UPDATE nm_type_subclass
           SET nsc_sub_class = UPPER(pi_new_sub_class)
              ,nsc_descr     = UPPER(pi_new_description)
              ,nsc_seq_no    = pi_new_seq_no            
         WHERE nsc_nw_type   = pi_old_nt_type
           AND nsc_sub_class = pi_old_sub_class;
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
        ROLLBACK TO update_nt_sub_class_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_nt_sub_class;                                
  
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION xsp_restraint_exists(pi_nt_type    IN nm_xsp.nwx_nw_type%TYPE
                               ,pi_sub_class  IN nm_xsp.nwx_nsc_sub_class%TYPE)
      RETURN VARCHAR2
    IS
      lv_exists VARCHAR2(1):= 'N';
      lv_cnt    NUMBER;
    BEGIN
      --
      SELECT COUNT(nwx_nw_type)
        INTO lv_cnt
        FROM nm_xsp
       WHERE nwx_nw_type       = pi_nt_type
         AND nwx_nsc_sub_class = pi_sub_class;
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
  -----------------------------------------------------------------------------
  --                                                                              
  PROCEDURE delete_nt_sub_class(pi_nt_type          IN     nm_type_subclass.nsc_nw_type%TYPE
                               ,pi_sub_class        IN     nm_type_subclass.nsc_sub_class%TYPE
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor)
  
 IS
    --
  BEGIN
    --
    SAVEPOINT delete_nt_sub_class_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    IF sub_class_exists(pi_nt_type   => pi_nt_type
                       ,pi_sub_class => pi_sub_class  ) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Sub Class:  '||pi_sub_class);
    END IF;
    --
    IF  xsp_restraint_exists(pi_nt_type    => pi_nt_type
                            ,pi_sub_class  => pi_sub_class)  = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 2
                     ,pi_supplementary_info => 'XSP Restraints');
    END IF;
    --
    DELETE
      FROM nm_type_subclass
     WHERE nsc_nw_type   = UPPER(pi_nt_type)
       AND nsc_sub_class = UPPER(pi_sub_class);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_nt_sub_class_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_nt_sub_class;                                                                                                  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_inclusions(pi_nt_child_type      IN     nm_type_inclusion.nti_nw_child_type%TYPE
                                  ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor         OUT sys_refcursor
                                  ,po_cursor                 OUT sys_refcursor)
                                  
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nti_nw_parent_type      nt_parent_type
          ,nti_nw_child_type       nt_child_type   
          ,nti_parent_column       parent_column
          ,nti_child_column        child_column
          ,nti_auto_create         auto_create
          ,nti_code_control_column code_control_column
      FROM nm_type_inclusion
     WHERE nti_nw_child_type = pi_nt_child_type
     ORDER BY nti_nw_parent_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_inclusions;                                  
                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_inclusion(pi_nt_child_type      IN     nm_type_inclusion.nti_nw_child_type%TYPE
                                 ,pi_nt_parent_type     IN     nm_type_inclusion.nti_nw_parent_type%TYPE
                                 ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor        OUT sys_refcursor
                                 ,po_cursor                OUT sys_refcursor)

  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nti_nw_parent_type      nt_parent_type
          ,nti_nw_child_type       nt_child_type   
          ,nti_parent_column       parent_column
          ,nti_child_column        child_column
          ,nti_auto_create         auto_create
          ,nti_code_control_column code_control_column
      FROM nm_type_inclusion
     WHERE nti_nw_child_type  = pi_nt_child_type
       AND nti_nw_parent_type = pi_nt_parent_type;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_inclusion;                                                               

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nt_type_inclusions(pi_nt_child_type        IN     nm_type_inclusion.nti_nw_child_type%TYPE
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
  lv_driving_sql  nm3type.max_varchar2 :='SELECT nti_nw_parent_type      nt_parent_type
                                                ,nti_nw_child_type       nt_child_type   
                                                ,nti_parent_column       parent_column
                                                ,nti_child_column        child_column
                                                ,nti_auto_create         auto_create
                                                ,nti_code_control_column code_control_column
                                            FROM nm_type_inclusion
                                           WHERE nti_nw_child_type = :pi_nt_child_type ';
  --
  lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  nt_parent_type'
                                              ||',nt_child_type'
                                              ||',parent_column'
                                              ||',child_column'
                                              ||',auto_create'
                                              ||',code_control_column'
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
      awlrs_util.add_column_data(pi_cursor_col => 'nt_parent_type'
                                ,pi_query_col  => 'nti_nw_parent_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'parent_column'
                                ,pi_query_col  => 'nti_parent_column'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'child_column'
                                ,pi_query_col  => 'nti_child_column'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'code_control_column'
                                ,pi_query_col  => 'nti_code_control_column'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'auto_create'
                                ,pi_query_col  => 'nti_auto_create'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nti_nw_parent_type')||') a)'
                       ||CHR(10)||lv_row_restriction
      ;
      --
      IF pi_pagesize IS NOT NULL
       THEN
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_nt_child_type
               ,lv_lower_index
               ,lv_upper_index;
      ELSE
          OPEN po_cursor FOR lv_cursor_sql
          USING pi_nt_child_type
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
  END get_paged_nt_type_inclusions;     
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_columns_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT  sys_refcursor
                                   ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hco_code
          ,SUBSTR(data_type,1,10) data_type
          ,data_length
      FROM hig_codes
          ,all_tab_columns
     WHERE HCO_DOMAIN = 'NM_ELEMENTS_COLUMNS'
       AND table_name = 'NM_ELEMENTS'
       AND column_name = HCO_CODE
       AND owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
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
  END get_nt_type_columns_lov;                                   

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE type_inclusion_cols_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT  sys_refcursor
                                   ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --   
    OPEN po_cursor FOR
    SELECT column_name  code
          ,column_name  code_descr
      FROM all_tab_columns
     WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
       AND table_name = 'NM_ELEMENTS'
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
  END type_inclusion_cols_lov;                                   
  --
  -----------------------------------------------------------------------------
  --Not sure if needed, doesn't bring anything to the party--
  PROCEDURE get_nt_type_column_lov(pi_column_name          IN     nm_type_inclusion.nti_parent_column%TYPE
                                  ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor          OUT sys_refcursor
                                  ,po_cursor                  OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT  column_name
           ,SUBSTR(data_type,1,10) data_type 
            ,data_length
      FROM  all_tab_columns
     WHERE  owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
       AND  table_name  = 'NM_ELEMENTS'
       AND  UPPER(column_name) = UPPER(pi_column_name);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_column_lov;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_type_column_seqs_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT  sys_refcursor
                                       ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT sequence_name 
      FROM all_sequences 
     WHERE sequence_owner = sys_context('NM3CORE','APPLICATION_OWNER')
    ORDER BY sequence_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_column_seqs_lov;                                        

  --
  -----------------------------------------------------------------------------
  --Not sure if needed, doesn't bring anything to the party--
  PROCEDURE get_nt_type_column_seq_lov(pi_seq_name         IN     nm_type_columns.ntc_seq_name%TYPE
                                      ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor      OUT sys_refcursor
                                      ,po_cursor              OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT sequence_name 
      FROM all_sequences 
     WHERE sequence_owner = sys_context('NM3CORE','APPLICATION_OWNER')
       AND sequence_name  = pi_seq_name;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_type_column_seq_lov;                                                                                          
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_nt_column_seq_lov(pi_filter_columns   IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
  lv_driving_sql  nm3type.max_varchar2 :='SELECT sequence_name 
                                            FROM all_sequences 
                                           WHERE sequence_owner = sys_context(''NM3CORE'',''APPLICATION_OWNER'')' ;
  --
  lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  sequence_name'
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
      awlrs_util.add_column_data(pi_cursor_col => 'sequence_name'
                                ,pi_query_col  => 'sequence_name'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sequence_name')||') a)'
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_nt_column_seq_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  
  FUNCTION nt_inclusion_exists(pi_nti_parent_type       IN     nm_type_inclusion.nti_nw_parent_type%TYPE
                              ,pi_nti_child_type        IN     nm_type_inclusion.nti_nw_child_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_type_inclusion  
     WHERE nti_nw_parent_type = UPPER(pi_nti_parent_type)
       AND nti_nw_child_type  = UPPER(pi_nti_child_type);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END nt_inclusion_exists;
  
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION nt_inclusion_uk_exists(pi_nti_child_type     IN    nm_type_inclusion.nti_nw_child_type%TYPE
                                 ,pi_nti_child_column   IN    nm_type_inclusion.nti_child_column%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_type_inclusion
     WHERE nti_nw_child_type = UPPER(pi_nti_child_type)
       AND nti_child_column  = UPPER(pi_nti_child_column);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END nt_inclusion_uk_exists;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_nt_inclusion(pi_nti_parent_type       IN     nm_type_inclusion.nti_nw_parent_type%TYPE
                               ,pi_nti_child_type        IN     nm_type_inclusion.nti_nw_child_type%TYPE
                               ,pi_nti_parent_column     IN     nm_type_inclusion.nti_parent_column%TYPE
                               ,pi_nti_child_column      IN     nm_type_inclusion.nti_child_column%TYPE
                               ,pi_nti_auto_create       IN     nm_type_inclusion.nti_auto_create%TYPE
                               ,pi_nti_code_control_col  IN     nm_type_inclusion.nti_code_control_column%TYPE
                               ,po_message_severity         OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT create_nt_inclusion_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Type'
                               ,pi_parameter_value => pi_nti_parent_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Child Type'
                               ,pi_parameter_value => pi_nti_child_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Auto Create'
                               ,pi_parameter_value => pi_nti_auto_create);
    --
    IF nt_inclusion_exists(pi_nti_parent_type =>  pi_nti_parent_type
                          ,pi_nti_child_type  =>  pi_nti_child_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Parent Type:  '||pi_nti_parent_type);
    END IF;
    --
    IF nt_inclusion_uk_exists(pi_nti_child_type    =>  pi_nti_child_type
                             ,pi_nti_child_column  =>  pi_nti_child_column) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64
                     ,pi_supplementary_info  => 'Child Type and Column combination:  '||pi_nti_child_type||' - '||pi_nti_child_column);
    END IF;
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_nti_parent_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Parent Type:  '||pi_nti_parent_type);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_nti_parent_column) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Parent Column:  '||pi_nti_parent_column);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_nti_child_column) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Child Column:  '||pi_nti_child_column);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_nti_code_control_col) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Code Control Column:  '||pi_nti_code_control_col);
    END IF;
    --
    /*
    ||insert into nm_type_inclusion.
    */
    INSERT
      INTO nm_type_inclusion
           (nti_nw_parent_type
           ,nti_nw_child_type
           ,nti_parent_column
           ,nti_child_column
           ,nti_auto_create
           ,nti_code_control_column
           )  
    VALUES (UPPER(pi_nti_parent_type)
           ,UPPER(pi_nti_child_type)
           ,UPPER(pi_nti_parent_column)
           ,UPPER(pi_nti_child_column)
           ,pi_nti_auto_create
           ,pi_nti_code_control_col
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_nt_inclusion_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_nt_inclusion;                    
                               
  --
  -----------------------------------------------------------------------------
  --   
  PROCEDURE update_nt_inclusion(pi_old_nti_parent_type       IN     nm_type_inclusion.nti_nw_parent_type%TYPE
                               ,pi_old_nti_child_type        IN     nm_type_inclusion.nti_nw_child_type%TYPE
                               ,pi_old_nti_parent_column     IN     nm_type_inclusion.nti_parent_column%TYPE
                               ,pi_old_nti_child_column      IN     nm_type_inclusion.nti_child_column%TYPE
                               ,pi_old_nti_auto_create       IN     nm_type_inclusion.nti_auto_create%TYPE
                               ,pi_old_nti_code_control_col  IN     nm_type_inclusion.nti_code_control_column%TYPE
                               ,pi_new_nti_parent_type       IN     nm_type_inclusion.nti_nw_parent_type%TYPE
                               ,pi_new_nti_child_type        IN     nm_type_inclusion.nti_nw_child_type%TYPE
                               ,pi_new_nti_parent_column     IN     nm_type_inclusion.nti_parent_column%TYPE
                               ,pi_new_nti_child_column      IN     nm_type_inclusion.nti_child_column%TYPE
                               ,pi_new_nti_auto_create       IN     nm_type_inclusion.nti_auto_create%TYPE
                               ,pi_new_nti_code_control_col  IN     nm_type_inclusion.nti_code_control_column%TYPE
                               ,po_message_severity             OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor               OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_type_inclusion%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_type_inclusion
       WHERE nti_nw_parent_type = pi_old_nti_parent_type
         AND nti_nw_child_type  = pi_old_nti_child_type
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Inclusion does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_nt_inclusion_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Parent Type'
                               ,pi_parameter_value => pi_new_nti_parent_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Child Type'
                               ,pi_parameter_value => pi_new_nti_child_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Auto Create'
                               ,pi_parameter_value => pi_new_nti_auto_create);
    --
    IF nt_inclusion_exists(pi_nti_parent_type =>  pi_new_nti_parent_type
                          ,pi_nti_child_type  =>  pi_new_nti_child_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Parent Type:  '||pi_new_nti_parent_type);
    END IF;
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_new_nti_parent_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Parent Type:  '||pi_new_nti_parent_type);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_new_nti_parent_column) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Parent Column:  '||pi_new_nti_parent_column);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_new_nti_child_column) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Child Column:  '||pi_new_nti_child_column);
    END IF;
    --
    IF column_name_exists(pi_column_name => pi_new_nti_code_control_col) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info  => 'Code Control Column:  '||pi_new_nti_code_control_col);
    END IF;                      
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nti_nw_parent_type != pi_old_nti_parent_type
     OR (lr_db_rec.nti_nw_parent_type IS NULL AND pi_old_nti_parent_type IS NOT NULL)
     OR (lr_db_rec.nti_nw_parent_type IS NOT NULL AND pi_old_nti_parent_type IS NULL)
     --
     OR (lr_db_rec.nti_nw_child_type != pi_old_nti_child_type)
     OR (lr_db_rec.nti_nw_child_type IS NULL AND pi_old_nti_child_type IS NOT NULL)
     OR (lr_db_rec.nti_nw_child_type IS NOT NULL AND pi_old_nti_child_type IS NULL)
     --
     OR (lr_db_rec.nti_parent_column != pi_old_nti_parent_column)
     OR (lr_db_rec.nti_parent_column IS NULL AND pi_old_nti_parent_column IS NOT NULL)
     OR (lr_db_rec.nti_parent_column IS NOT NULL AND pi_old_nti_parent_column IS NULL)
     --
     OR (lr_db_rec.nti_child_column != pi_old_nti_child_column)
     OR (lr_db_rec.nti_child_column IS NULL AND pi_old_nti_child_column IS NOT NULL)
     OR (lr_db_rec.nti_child_column IS NOT NULL AND pi_old_nti_child_column IS NULL)
     --
     OR (lr_db_rec.nti_auto_create != pi_old_nti_auto_create)
     OR (lr_db_rec.nti_auto_create IS NULL AND pi_old_nti_auto_create IS NOT NULL)
     OR (lr_db_rec.nti_auto_create IS NOT NULL AND pi_old_nti_auto_create IS NULL)
     --
     OR (lr_db_rec.nti_code_control_column != pi_old_nti_code_control_col)
     OR (lr_db_rec.nti_code_control_column IS NULL AND pi_old_nti_code_control_col IS NOT NULL)
     OR (lr_db_rec.nti_code_control_column IS NOT NULL AND pi_old_nti_code_control_col IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nti_parent_type != pi_new_nti_parent_type
       OR (pi_old_nti_parent_type IS NULL AND pi_new_nti_parent_type IS NOT NULL)
       OR (pi_old_nti_parent_type IS NOT NULL AND pi_new_nti_parent_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nti_child_type != pi_new_nti_child_type
       OR (pi_old_nti_child_type IS NULL AND pi_new_nti_child_type IS NOT NULL)
       OR (pi_old_nti_child_type IS NOT NULL AND pi_new_nti_child_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nti_parent_column != pi_old_nti_parent_column
       OR (pi_old_nti_parent_column IS NULL AND pi_old_nti_parent_column IS NOT NULL)
       OR (pi_old_nti_parent_column IS NOT NULL AND pi_old_nti_parent_column IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nti_child_column != pi_new_nti_child_column
       OR (pi_old_nti_child_column IS NULL AND pi_new_nti_child_column IS NOT NULL)
       OR (pi_old_nti_child_column IS NOT NULL AND pi_new_nti_child_column IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nti_auto_create != pi_new_nti_auto_create
       OR (pi_old_nti_auto_create IS NULL AND pi_new_nti_auto_create IS NOT NULL)
       OR (pi_old_nti_auto_create IS NOT NULL AND pi_new_nti_auto_create IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_nti_code_control_col != pi_new_nti_code_control_col
       OR (pi_old_nti_code_control_col IS NULL AND pi_new_nti_code_control_col IS NOT NULL)
       OR (pi_old_nti_code_control_col IS NOT NULL AND pi_new_nti_code_control_col IS NULL)
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
        UPDATE nm_type_inclusion
           SET nti_parent_column       = UPPER(pi_new_nti_parent_column)
              ,nti_child_column        = UPPER(pi_new_nti_child_column)
              ,nti_auto_create         = pi_new_nti_auto_create 
              ,nti_code_control_column = pi_new_nti_code_control_col
         WHERE nti_nw_parent_type      = pi_old_nti_parent_type
         AND nti_nw_child_type         = pi_old_nti_child_type;
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
        ROLLBACK TO update_nt_inclusion_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_nt_inclusion;     
                              
  --
  -----------------------------------------------------------------------------
  --                                                                              
  PROCEDURE delete_nt_inclusion(pi_nti_parent_type       IN     nm_type_inclusion.nti_nw_parent_type%TYPE
                               ,pi_nti_child_type        IN     nm_type_inclusion.nti_nw_child_type%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor)                              
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_nt_inclusion_sp;
    --
    awlrs_util.check_historic_mode;  
    --
    IF nt_inclusion_exists(pi_nti_parent_type =>  pi_nti_parent_type
                             ,pi_nti_child_type  =>  pi_nti_child_type)<> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 30
                     ,pi_supplementary_info  => 'Inclusion:  '||pi_nti_parent_type||' - '||pi_nti_child_type);
    END IF;
    --
    DELETE
      FROM nm_type_inclusion
     WHERE nti_nw_parent_type =  UPPER(pi_nti_parent_type)
       AND nti_nw_child_type  =  UPPER(pi_nti_child_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO delete_nt_inclusion_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_nt_inclusion;       
   
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_ad_types(po_message_severity OUT  hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT  sys_refcursor
                                ,po_cursor           OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nad.nad_id                 nad_id
          ,nad.nad_nt_type            network_type
          ,nt.nt_descr                network_type_descr 
          ,nad.nad_gty_type           group_type
          ,ngt.ngt_descr              group_type_descr
          ,nad.nad_inv_type           inv_type
          ,nit.nit_descr              inv_type_descr
          ,nad.nad_descr              description
          ,nad.nad_start_date         start_date
          ,nad.nad_end_date           end_date
          ,nad.nad_primary_ad         primary_ad
          ,nad.nad_display_order      display_order
          ,nad.nad_single_row         single_row
          ,nad.nad_mandatory          mandatory 
      FROM nm_nw_ad_types nad
          ,nm_types nt
          ,nm_group_types_all ngt
          ,nm_inv_types_all nit
     WHERE nad.nad_nt_type  = nt.nt_type  
       AND nad.nad_gty_type = ngt.ngt_group_type(+)    
       AND nad.nad_inv_type = nit.nit_inv_type
     ORDER BY nad.nad_nt_type
             ,nad.nad_gty_type 
             ,nad.nad_display_order;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_ad_types;                                 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_ad_type(pi_nt_type             IN      nm_nw_ad_types.nad_nt_type%TYPE
                               ,pi_group_type          IN      nm_nw_ad_types.nad_gty_type%TYPE
                               ,pi_inv_type            IN      nm_nw_ad_types.nad_nt_type%TYPE
                               ,po_message_severity        OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor          OUT sys_refcursor
                               ,po_cursor                  OUT sys_refcursor)
   IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nad.nad_id                 nad_id
          ,nad.nad_nt_type            network_type
          ,nt.nt_descr                network_type_descr 
          ,nad.nad_gty_type           group_type
          ,ngt.ngt_descr              group_type_descr
          ,nad.nad_inv_type           inv_type
          ,nit.nit_descr              inv_type_descr
          ,nad.nad_descr              description
          ,nad.nad_start_date         start_date
          ,nad.nad_end_date           end_date
          ,nad.nad_primary_ad         primary_ad
          ,nad.nad_display_order      display_order
          ,nad.nad_single_row         single_row
          ,nad.nad_mandatory          mandatory 
      FROM nm_nw_ad_types nad
          ,nm_types nt
          ,nm_group_types_all ngt
          ,nm_inv_types_all nit
     WHERE nad.nad_nt_type      = pi_nt_type
       AND nad.nad_nt_type      = nt.nt_type  
       AND (   nad.nad_gty_type = pi_group_type
            OR pi_group_type IS NULL AND nad.nad_gty_type IS NULL 
           )
       AND nad.nad_gty_type     = ngt.ngt_group_type(+)
       AND nad.nad_inv_type     = pi_inv_type
       AND nad.nad_inv_type     = nit.nit_inv_type
     ORDER BY nad.nad_nt_type
             ,nad.nad_gty_type 
             ,nad.nad_display_order;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_ad_type;                                 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_types_lov(pi_nt_type          IN      nm_nw_ad_types.nad_nt_type%TYPE
                               ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT  sys_refcursor
                               ,po_cursor              OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type
          ,ngt_descr
     FROM  nm_group_types
    WHERE  ngt_nt_type = pi_nt_type 
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
  END get_group_types_lov;                                
                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_type_lov(pi_group_type       IN     nm_nw_ad_types.nad_gty_type%TYPE
                              ,po_message_severity    OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor      OUT sys_refcursor
                              ,po_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ngt_group_type
          ,ngt_descr
     FROM  nm_group_types
    WHERE  ngt_group_type = UPPER(pi_group_type);   
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_type_lov;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_inv_types_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT  sys_refcursor
                             ,po_cursor           OUT  sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr
      FROM nm_inv_types
     WHERE nit_category = 'G'
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
  END get_inv_types_lov;                             
                               
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_inv_type_lov(pi_inv_type         IN     nm_nw_ad_types.nad_inv_type%TYPE
                            ,po_message_severity    OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor      OUT sys_refcursor
                            ,po_cursor              OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr
      FROM nm_inv_types
     WHERE nit_inv_type = pi_inv_type
       AND nit_category = 'G'
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
  END get_inv_type_lov;                                                   

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_ad_types(pi_filter_columns       IN     nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
  lv_driving_sql  nm3type.max_varchar2 :='SELECT nad.nad_id                 nad_id
                                                ,nad.nad_nt_type            network_type
                                                ,nt.nt_descr                network_type_descr 
                                                ,nad.nad_gty_type           group_type
                                                ,ngt.ngt_descr              group_type_descr
                                                ,nad.nad_inv_type           inv_type
                                                ,nit.nit_descr              inv_type_descr
                                                ,nad.nad_descr              description
                                                ,nad.nad_start_date         start_date
                                                ,nad.nad_end_date           end_date
                                                ,nad.nad_primary_ad         primary_ad
                                                ,nad.nad_display_order      display_order
                                                ,nad.nad_single_row         single_row
                                                ,nad.nad_mandatory          mandatory 
                                            FROM nm_nw_ad_types nad
                                                ,nm_types nt
                                                ,nm_group_types_all ngt
                                                ,nm_inv_types_all nit
                                           WHERE nad.nad_nt_type  = nt.nt_type  
                                             AND nad.nad_gty_type = ngt.ngt_group_type(+)    
                                             AND nad.nad_inv_type = nit.nit_inv_type ';
  --
  lv_cursor_sql  nm3type.max_varchar2 := 'SELECT  nad_id'
                                              ||',network_type'
                                              ||',network_type_descr'
                                              ||',group_type'
                                              ||',group_type_descr'
                                              ||',inv_type'
                                              ||',inv_type_descr'
                                              ||',description'
                                              ||',start_date'
                                              ||',end_date'
                                              ||',primary_ad'
                                              ||',display_order'
                                              ||',single_row'
                                              ||',mandatory'
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
      awlrs_util.add_column_data(pi_cursor_col => 'nad_id'
                                ,pi_query_col  => 'nad_id'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'network_type'
                                ,pi_query_col  => 'nad_nt_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'network_type_descr'
                                ,pi_query_col  => 'nt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'group_type'
                                ,pi_query_col  => 'nad_gty_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'group_type_descr'
                                ,pi_query_col  => 'ngt_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'inv_type'
                                ,pi_query_col  => 'nad_inv_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'inv_type_descr'
                                ,pi_query_col  => 'nit_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'description'
                                ,pi_query_col  => 'nad_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'start_date'
                                ,pi_query_col  => 'nad_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'end_date'
                                ,pi_query_col  => 'nad_end_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => 'DD-MON-YYYY'
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'primary_ad'
                                ,pi_query_col  => 'nad_primary_ad'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'display_order' 
                                ,pi_query_col  => 'nad_display_order'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'single_row'
                                ,pi_query_col  => 'nad_single_row'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'mandatory' 
                                ,pi_query_col  => 'nad_mandatory'
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
                       ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'nad_nt_type, nad_gty_type, nad_display_order')||') a)'
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
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_network_ad_types;                                     
  
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION network_ad_type_exists(pi_network_type  IN  nm_nw_ad_types.nad_nt_type%TYPE
                                 ,pi_inv_type      IN  nm_nw_ad_types.nad_inv_type%TYPE)
       RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_nw_ad_types
     WHERE nad_nt_type  = UPPER(pi_network_type)
       AND nad_inv_type = UPPER(pi_inv_type);
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END network_ad_type_exists;
  
  --
  -----------------------------------------------------------------------------
  -- 
  FUNCTION network_ad_type_exists(pi_nad_id  IN  nm_nw_ad_types.nad_id%TYPE)
                                 
       RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_nw_ad_types
     WHERE nad_id = pi_nad_id;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
        RETURN lv_exists;
  END network_ad_type_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION inv_type_exists(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM nm_inv_types
     WHERE nit_inv_type = pi_inv_type;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END inv_type_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_primary_ad(pi_primary_ad  IN  nm_nw_ad_types.nad_primary_ad%TYPE
                               ,pi_single_row  IN  nm_nw_ad_types.nad_single_row%TYPE
                               ,pi_mandatory   IN  nm_nw_ad_types.nad_mandatory%TYPE)
  IS
  --
  BEGIN
    --                    
    IF pi_primary_ad = 'Y'
      AND (pi_single_row = 'N' OR pi_mandatory = 'N')
        THEN
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   =>  80
                       ,pi_supplementary_info  => 'Single Row: '||pi_single_row||' , Mandatory: '||pi_mandatory);
    END IF;  
    --              
  END validate_primary_ad;  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_network_ad_type(pi_network_type      IN     nm_nw_ad_types.nad_nt_type%TYPE
                                  ,pi_group_type        IN     nm_nw_ad_types.nad_gty_type%TYPE
                                  ,pi_inv_type          IN     nm_nw_ad_types.nad_inv_type%TYPE
                                  ,pi_description       IN     nm_nw_ad_types.nad_descr%TYPE
                                  ,pi_start_date        IN     nm_nw_ad_types.nad_start_date%TYPE
                                  ,pi_end_date          IN     nm_nw_ad_types.nad_end_date%TYPE
                                  ,pi_primary_ad        IN     nm_nw_ad_types.nad_primary_ad%TYPE
                                  ,pi_display_order     IN     nm_nw_ad_types.nad_display_order%TYPE
                                  ,pi_single_row        IN     nm_nw_ad_types.nad_single_row%TYPE
                                  ,pi_mandatory         IN     nm_nw_ad_types.nad_mandatory%TYPE
                                  ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT create_network_ad_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_network_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Inventory Type'
                               ,pi_parameter_value => pi_inv_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_start_date);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Primary AD'
                          ,pi_parameter_value => pi_primary_ad);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Display Order'
                               ,pi_parameter_value => pi_display_order);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Single Row'
                          ,pi_parameter_value => pi_single_row);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_mandatory);
    --
    validate_primary_ad(pi_primary_ad => pi_primary_ad
                       ,pi_single_row => pi_single_row
                       ,pi_mandatory  => pi_mandatory); 
    --
    IF network_ad_type_exists(pi_network_type => pi_network_type
                             ,pi_inv_type     => pi_inv_type) = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   =>  370
                     ,pi_supplementary_info  => 'Network Type:  '||pi_network_type||', Inventory Type: '||pi_inv_type);
    END IF;
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_network_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  29
                     ,pi_supplementary_info  => 'Network Type: '||pi_network_type);
    END IF;
    --
    IF group_type_exists(pi_network_type => pi_network_type
                        ,pi_group_type   => pi_group_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  29
                     ,pi_supplementary_info  => 'Group Type: '||pi_group_type);
    END IF;
    --
    IF inv_type_exists(pi_inv_type => pi_inv_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  29
                     ,pi_supplementary_info  => 'Inventory Type: '||pi_inv_type);
    END IF;
    --
    /*
    ||insert into nm_nw_ad_types.
    */
    INSERT
      INTO nm_nw_ad_types
           (nad_id
           ,nad_inv_type
           ,nad_nt_type
           ,nad_gty_type
           ,nad_descr
           ,nad_start_date
           ,nad_end_date
           ,nad_primary_ad
           ,nad_display_order
           ,nad_single_row
           ,nad_mandatory
           )
    VALUES (nad_id_seq.nextval
           ,UPPER(pi_inv_type)
           ,UPPER(pi_network_type)
           ,UPPER(pi_group_type)
           ,UPPER(pi_description)
           ,pi_start_date
           ,pi_end_date
           ,pi_primary_ad
           ,pi_display_order
           ,pi_single_row
           ,pi_mandatory
           );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        ROLLBACK TO create_network_ad_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_network_ad_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_network_ad_type(pi_old_nad_id            IN     nm_nw_ad_types.nad_id%TYPE                                  
                                  ,pi_old_network_type      IN     nm_nw_ad_types.nad_nt_type%TYPE
                                  ,pi_old_group_type        IN     nm_nw_ad_types.nad_gty_type%TYPE
                                  ,pi_old_inv_type          IN     nm_nw_ad_types.nad_inv_type%TYPE
                                  ,pi_old_description       IN     nm_nw_ad_types.nad_descr%TYPE
                                  ,pi_old_start_date        IN     nm_nw_ad_types.nad_start_date%TYPE
                                  ,pi_old_end_date          IN     nm_nw_ad_types.nad_end_date%TYPE
                                  ,pi_old_primary_ad        IN     nm_nw_ad_types.nad_primary_ad%TYPE
                                  ,pi_old_display_order     IN     nm_nw_ad_types.nad_display_order%TYPE
                                  ,pi_old_single_row        IN     nm_nw_ad_types.nad_single_row%TYPE
                                  ,pi_old_mandatory         IN     nm_nw_ad_types.nad_mandatory%TYPE
                                  ,pi_new_nad_id            IN     nm_nw_ad_types.nad_id%TYPE                                  
                                  ,pi_new_network_type      IN     nm_nw_ad_types.nad_nt_type%TYPE
                                  ,pi_new_group_type        IN     nm_nw_ad_types.nad_gty_type%TYPE
                                  ,pi_new_inv_type          IN     nm_nw_ad_types.nad_inv_type%TYPE
                                  ,pi_new_description       IN     nm_nw_ad_types.nad_descr%TYPE
                                  ,pi_new_start_date        IN     nm_nw_ad_types.nad_start_date%TYPE
                                  ,pi_new_end_date          IN     nm_nw_ad_types.nad_end_date%TYPE
                                  ,pi_new_primary_ad        IN     nm_nw_ad_types.nad_primary_ad%TYPE
                                  ,pi_new_display_order     IN     nm_nw_ad_types.nad_display_order%TYPE
                                  ,pi_new_single_row        IN     nm_nw_ad_types.nad_single_row%TYPE
                                  ,pi_new_mandatory         IN     nm_nw_ad_types.nad_mandatory%TYPE
                                  ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor           OUT sys_refcursor)
  IS
    --
    lr_db_rec        nm_nw_ad_types%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_nw_ad_types
       WHERE nad_id = pi_old_nad_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 =>  85
                       ,pi_supplementary_info => 'Network AD Type does not exist');
          --
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT update_network_ad_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Nad Id'
                               ,pi_parameter_value => pi_new_nad_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type'
                               ,pi_parameter_value => pi_new_network_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Asset Type'
                               ,pi_parameter_value => pi_new_inv_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Start Date'
                               ,pi_parameter_value => pi_new_start_date);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Primary AD'
                          ,pi_parameter_value => pi_new_primary_ad);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Display Order'
                               ,pi_parameter_value => pi_new_display_order);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Single Row'
                          ,pi_parameter_value => pi_new_single_row);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Mandatory'
                          ,pi_parameter_value => pi_new_mandatory);
    --
    validate_primary_ad(pi_primary_ad => pi_new_primary_ad
                       ,pi_single_row => pi_new_single_row
                       ,pi_mandatory  => pi_new_mandatory); 
    --
    --lov validation--
    IF network_type_exists(pi_network_type => pi_new_network_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  29
                     ,pi_supplementary_info  => 'Network Type: '||pi_new_network_type);
    END IF;
    --
    IF group_type_exists(pi_network_type => pi_new_network_type
                        ,pi_group_type   => pi_new_group_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  29
                     ,pi_supplementary_info  => 'Group Type: '||pi_new_group_type);
    END IF;
    --
    IF inv_type_exists(pi_inv_type => pi_new_inv_type) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  29
                     ,pi_supplementary_info  => 'Inventory Type: '||pi_new_inv_type);
    END IF;
    --
    get_db_rec;
    --
    /*
    ||Compare Old with DB
    */
    IF lr_db_rec.nad_id != pi_old_nad_id
     OR (lr_db_rec.nad_id IS NULL AND pi_old_nad_id IS NOT NULL)
     OR (lr_db_rec.nad_id IS NOT NULL AND pi_old_nad_id IS NULL)
     --
     OR (lr_db_rec.nad_nt_type != pi_old_network_type)
     OR (lr_db_rec.nad_nt_type IS NULL AND pi_old_network_type IS NOT NULL)
     OR (lr_db_rec.nad_nt_type IS NOT NULL AND pi_old_network_type IS NULL)
     --
     OR (lr_db_rec.nad_gty_type != pi_old_group_type)
     OR (lr_db_rec.nad_gty_type IS NULL AND pi_old_group_type IS NOT NULL)
     OR (lr_db_rec.nad_gty_type IS NOT NULL AND pi_old_group_type IS NULL)
     --
     OR (lr_db_rec.nad_inv_type != pi_old_inv_type)
     OR (lr_db_rec.nad_inv_type IS NULL AND pi_old_inv_type IS NOT NULL)
     OR (lr_db_rec.nad_inv_type IS NOT NULL AND pi_old_inv_type IS NULL)
     --
     OR (UPPER(lr_db_rec.nad_descr) != UPPER(pi_old_description))
     OR (lr_db_rec.nad_descr IS NULL AND pi_old_description IS NOT NULL)
     OR (lr_db_rec.nad_descr IS NOT NULL AND pi_old_description IS NULL)
     --
     OR (lr_db_rec.nad_start_date != pi_old_start_date)
     OR (lr_db_rec.nad_start_date IS NULL AND pi_old_start_date IS NOT NULL)
     OR (lr_db_rec.nad_start_date IS NOT NULL AND pi_old_start_date IS NULL)
     --
     OR (lr_db_rec.nad_end_date != pi_old_end_date)
     OR (lr_db_rec.nad_end_date IS NULL AND pi_old_end_date IS NOT NULL)
     OR (lr_db_rec.nad_end_date IS NOT NULL AND pi_old_end_date IS NULL)
     --
     OR (lr_db_rec.nad_primary_ad != pi_old_primary_ad)
     OR (lr_db_rec.nad_primary_ad IS NULL AND pi_old_primary_ad IS NOT NULL)
     OR (lr_db_rec.nad_primary_ad IS NOT NULL AND pi_old_primary_ad IS NULL)
     --
     OR (lr_db_rec.nad_display_order != pi_old_display_order)
     OR (lr_db_rec.nad_display_order IS NULL AND pi_old_display_order IS NOT NULL)
     OR (lr_db_rec.nad_display_order IS NOT NULL AND pi_old_display_order IS NULL)
     --
     OR (lr_db_rec.nad_single_row != pi_old_single_row)
     OR (lr_db_rec.nad_single_row IS NULL AND pi_old_single_row IS NOT NULL)
     OR (lr_db_rec.nad_single_row IS NOT NULL AND pi_old_single_row IS NULL)
     --
     OR (lr_db_rec.nad_mandatory != pi_old_mandatory)
     OR (lr_db_rec.nad_mandatory IS NULL AND pi_old_mandatory IS NOT NULL)
     OR (lr_db_rec.nad_mandatory IS NOT NULL AND pi_old_mandatory IS NULL)
     --
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare Old with New
      */
      IF pi_old_nad_id != pi_new_nad_id
       OR (pi_old_nad_id IS NULL AND pi_new_nad_id IS NOT NULL)
       OR (pi_old_nad_id IS NOT NULL AND pi_new_nad_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_network_type != pi_new_network_type
       OR (pi_old_network_type IS NULL AND pi_new_network_type IS NOT NULL)
       OR (pi_old_network_type IS NOT NULL AND pi_new_network_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_group_type != pi_new_group_type
       OR (pi_old_group_type IS NULL AND pi_new_group_type IS NOT NULL)
       OR (pi_old_group_type IS NOT NULL AND pi_new_group_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_inv_type != pi_new_inv_type
       OR (pi_old_inv_type IS NULL AND pi_new_inv_type IS NOT NULL)
       OR (pi_old_inv_type IS NOT NULL AND pi_new_inv_type IS NULL)
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
      IF pi_old_primary_ad != pi_new_primary_ad
       OR (pi_old_primary_ad IS NULL AND pi_new_primary_ad IS NOT NULL)
       OR (pi_old_primary_ad IS NOT NULL AND pi_new_primary_ad IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_display_order != pi_new_display_order
       OR (pi_old_display_order IS NULL AND pi_new_display_order IS NOT NULL)
       OR (pi_old_display_order IS NOT NULL AND pi_new_display_order IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_single_row != pi_new_single_row
       OR (pi_old_single_row IS NULL AND pi_new_single_row IS NOT NULL)
       OR (pi_old_single_row IS NOT NULL AND pi_new_single_row IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_mandatory != pi_new_mandatory
       OR (pi_old_mandatory IS NULL AND pi_new_mandatory IS NOT NULL)
       OR (pi_old_mandatory IS NOT NULL AND pi_new_mandatory IS NULL)
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
        UPDATE nm_nw_ad_types
           SET nad_nt_type       = UPPER(pi_new_network_type)
              ,nad_gty_type      = UPPER(pi_new_group_type)  
              ,nad_inv_type      = UPPER(pi_new_inv_type)
              ,nad_descr         = UPPER(pi_new_description)
              ,nad_start_date    = pi_new_start_date
              ,nad_end_date      = pi_new_end_date
              ,nad_primary_ad    = pi_new_primary_ad
              ,nad_display_order = pi_new_display_order
              ,nad_single_row    = pi_new_single_row
              ,nad_mandatory     = pi_new_mandatory
         WHERE nad_id            = pi_old_nad_id;
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
        ROLLBACK TO update_network_ad_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_network_ad_type;                                                                                                           

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_network_ad_type(pi_nad_id            IN     nm_nw_ad_types.nad_id%TYPE
                                  ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    SAVEPOINT delete_network_ad_type_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF network_ad_type_exists(pi_nad_id => pi_nad_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   =>  30
                     ,pi_supplementary_info  => 'Nad Id: '||pi_nad_id);
    END IF;
    --    
    UPDATE nm_nw_ad_types
       SET nad_end_date = TRUNC(SYSDATE)
     WHERE nad_id       = pi_nad_id;      
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_network_ad_type_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_network_ad_type;   
  
  --
  -----------------------------------------------------------------------------
  -- 
PROCEDURE validate_nw_types(po_val_message_Tab   OUT   nm3type.tab_varchar2000
                           ,po_message_severity  OUT   hig_codes.hco_code%TYPE
                           ,po_message_cursor    OUT   sys_refcursor    
                            )
  IS
  lt_msg_tab nm3type.tab_varchar2000;
  --
  BEGIN
  --
    lt_msg_tab := nm3nwval.validate_network_metadata;
    --
    IF lt_msg_tab.COUNT = 0
      THEN
        po_val_message_tab(1) := 'Network types are valid.';        
    ELSE
        po_val_message_tab := lt_msg_tab;      
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
    
  END validate_nw_types;                                                           
  --                                  

END awlrs_metanet_api;
/