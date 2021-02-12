CREATE OR REPLACE PACKAGE BODY awlrs_copy_trace_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_copy_trace_api.pkb-arc   1.4   Feb 12 2021 10:19:00   Barbara.Odriscoll  $
  --       Module Name      : $Workfile:   awlrs_copy_trace_api.pkb  $
  --       Date into PVCS   : $Date:   Feb 12 2021 10:19:00  $
  --       Date fetched Out : $Modtime:   Feb 11 2021 14:27:50  $
  --       Version          : $Revision:   1.4  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.4  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_copy_trace_api';
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
  ------------------------------------------------------------------------------
  --
  FUNCTION is_used_for_unique(pi_nt_type IN nm_types.nt_type%TYPE
                             ,pi_column  IN nm_type_columns.ntc_column_name%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval VARCHAR2(1);
    --
    CURSOR get_column(cp_nt_type IN nm_types.nt_type%TYPE
                     ,cp_column  IN nm_type_columns.ntc_column_name%TYPE)
        IS
    SELECT CASE 
             WHEN ntc_unique_seq IS NOT NULL
              THEN
                 'Y'
             ELSE
                 'N'
           END CASE
      FROM nm_type_columns
     WHERE ntc_nt_type = cp_nt_type
       AND ntc_column_name = cp_column
         ;
    --
  BEGIN
    --
    IF pi_column = 'NE_UNIQUE'
     THEN
        lv_retval := 'Y';
    ELSE
        --
        OPEN  get_column(pi_nt_type,pi_column);
        FETCH get_column
         INTO lv_retval;
        --
        IF get_column%NOTFOUND
         THEN
            lv_retval := 'N';
        END IF;
        --
        CLOSE get_column;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END is_used_for_unique;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION file_feature_map_exists(pi_affm_id IN awlrs_file_feature_maps.affm_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM awlrs_file_feature_maps
     WHERE affm_id = pi_affm_id;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END file_feature_map_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION group_attrib_map_exists(pi_afgam_id IN awlrs_file_grp_attrib_map.afgam_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM awlrs_file_grp_attrib_map
     WHERE afgam_id = pi_afgam_id;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END group_attrib_map_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION datum_attrib_map_exists(pi_afdam_id IN awlrs_file_datum_attrib_map.afdam_id%TYPE)
    RETURN VARCHAR2
  IS
    lv_exists VARCHAR2(1):= 'N';
  BEGIN
    --
    SELECT 'Y'
      INTO lv_exists
      FROM awlrs_file_datum_attrib_map
     WHERE afdam_id = pi_afdam_id;
    --
    RETURN lv_exists;
    --
  EXCEPTION
    WHEN no_data_found 
     THEN
        RETURN lv_exists;
  END datum_attrib_map_exists;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE del_file_feature_map(pi_affm_id          IN     awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor      OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    SAVEPOINT del_file_feature_map_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF file_feature_map_exists(pi_affm_id => pi_affm_id) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'File Feature Map does not exist');    
    END IF;
    --
    DELETE 
      FROM awlrs_file_feature_maps
     WHERE affm_id = pi_affm_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO del_file_feature_map_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END del_file_feature_map;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_nt_lov(po_message_severity OUT  hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT  sys_refcursor
                            ,po_cursor           OUT  sys_refcursor)
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
     ORDER BY nt_type
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
  END get_datum_nt_lov;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_attributes_lov(pi_nt_type          IN      nm_type_columns.ntc_nt_type%TYPE
                                      ,po_message_severity    OUT  hig_codes.hco_code%TYPE
                                      ,po_message_cursor      OUT  sys_refcursor
                                      ,po_cursor              OUT  sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ntc_column_name
          ,ntc_prompt
      FROM nm_type_columns ntc
     WHERE ntc_nt_type = pi_nt_type
       AND ntc_displayed = 'Y'
     ORDER
        BY ntc_seq_no;
        
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_attributes_lov;   
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_file_feature_map(pi_file_feature_map_id  IN      awlrs_file_feature_maps.affm_id%TYPE
                                   ,pi_old_descr            IN      awlrs_file_feature_maps.affm_file_descr%TYPE 
                                   ,pi_old_datum_nt         IN      awlrs_file_feature_maps.affm_datum_nt%TYPE
                                   ,pi_new_descr            IN      awlrs_file_feature_maps.affm_file_descr%TYPE
                                   ,pi_new_datum_nt         IN      awlrs_file_feature_maps.affm_datum_nt%TYPE
                                   ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor           OUT sys_refcursor)
    IS
    --    
    lr_db_id_rec     awlrs_file_feature_maps%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_id_rec
        FROM awlrs_file_feature_maps
       WHERE affm_id = pi_file_feature_map_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'File feature map does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT upd_file_feature_map_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Description'
                               ,pi_parameter_value => pi_new_descr);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Datum Network Type`'
                               ,pi_parameter_value => pi_new_datum_nt);               
    --
    IF  file_feature_map_exists(pi_affm_id => pi_file_feature_map_id) <> 'Y'
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
    IF lr_db_id_rec.affm_file_descr != pi_old_descr
     OR (lr_db_id_rec.affm_file_descr IS NULL AND pi_old_descr IS NOT NULL)
     OR (lr_db_id_rec.affm_file_descr IS NOT NULL AND pi_old_descr IS NULL)
     --
     OR (lr_db_id_rec.affm_datum_nt != pi_old_datum_nt)
     OR (lr_db_id_rec.affm_datum_nt IS NULL AND pi_old_datum_nt IS NOT NULL)
     OR (lr_db_id_rec.affm_datum_nt IS NOT NULL AND pi_old_datum_nt IS NULL)
     --           
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_descr != pi_new_descr
       OR (pi_old_descr IS NULL AND pi_new_descr IS NOT NULL)
       OR (pi_old_descr IS NOT NULL AND pi_new_descr IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF UPPER(pi_old_datum_nt) != UPPER(pi_new_datum_nt)
       OR (UPPER(pi_old_datum_nt) IS NULL AND UPPER(pi_new_datum_nt) IS NOT NULL)
       OR (UPPER(pi_old_datum_nt) IS NOT NULL AND UPPER(pi_new_datum_nt) IS NULL)
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
        UPDATE awlrs_file_feature_maps
           SET  affm_file_descr = pi_new_descr
               ,affm_datum_nt   = UPPER(pi_new_datum_nt)
         WHERE affm_id = lr_db_id_rec.affm_id;
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
        ROLLBACK to upd_file_feature_map_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_file_feature_map;  
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_file_feature_map(pi_file_descr          IN     awlrs_file_feature_maps.affm_file_descr%TYPE
                                ,pi_datum_nt            IN     awlrs_file_feature_maps.affm_datum_nt%TYPE
                                ,po_file_feature_map_id IN OUT awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_id  awlrs_file_feature_maps.affm_id%TYPE;
    --
  BEGIN
    --
    IF nm3net.is_nt_datum(p_nt_type => pi_datum_nt) != 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 169
                     ,pi_supplementary_info => pi_datum_nt);
    END IF;
    --
    lv_id := affm_id_seq.NEXTVAL;
    --
    INSERT
      INTO awlrs_file_feature_maps
          (affm_id
          ,affm_file_descr
          ,affm_datum_nt) 
    VALUES(lv_id
          ,pi_file_descr
          ,UPPER(pi_datum_nt))
         ;
    --
    po_file_feature_map_id := lv_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_file_feature_map;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_file_feature_maps(po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM awlrs_file_feature_maps
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
  END get_file_feature_maps;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE del_group_attrib_map(pi_afgam_id            IN     awlrs_file_grp_attrib_map.afgam_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    SAVEPOINT del_group_attrib_map_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF group_attrib_map_exists(pi_afgam_id => pi_afgam_id) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'File Feature Map does not exist');    
    END IF;
    --
    DELETE 
      FROM awlrs_file_grp_attrib_map
     WHERE afgam_id = pi_afgam_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO del_group_attrib_map_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END del_group_attrib_map;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_group_attrib_map(pi_file_feature_map_id IN     awlrs_file_grp_attrib_map.afgam_affm_id%TYPE
                                ,pi_target_nt           IN     awlrs_file_grp_attrib_map.afgam_target_nt%TYPE
                                ,pi_target_gty          IN     awlrs_file_grp_attrib_map.afgam_target_gty%TYPE
                                ,pi_file_attrib         IN     awlrs_file_grp_attrib_map.afgam_file_attrib%TYPE
                                ,pi_target_attrib       IN     awlrs_file_grp_attrib_map.afgam_target_attrib%TYPE
                                ,po_file_grp_attrib_id  IN OUT awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_id  awlrs_file_grp_attrib_map.afgam_id%TYPE;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Feature Map ID'
                               ,pi_parameter_value => pi_file_feature_map_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Network Type`'
                               ,pi_parameter_value => pi_target_nt);               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value => pi_target_gty);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Attribute'
                               ,pi_parameter_value => pi_file_attrib);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Target Attribute'
                               ,pi_parameter_value => pi_target_attrib);
    --
    IF  file_feature_map_exists(pi_affm_id => pi_file_feature_map_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     );    
    END IF;   
    --
    lv_id := afgam_id_seq.NEXTVAL;
    --
    INSERT
      INTO awlrs_file_grp_attrib_map
          (afgam_id
          ,afgam_affm_id
          ,afgam_target_nt
          ,afgam_target_gty
          ,afgam_file_attrib
          ,afgam_target_attrib) 
    VALUES(lv_id
          ,pi_file_feature_map_id
          ,UPPER(pi_target_nt)
          ,UPPER(pi_target_gty)
          ,pi_file_attrib
          ,UPPER(pi_target_attrib))
         ;
    --
    po_file_grp_attrib_id := lv_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_group_attrib_map;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_datum_attrib_map(pi_file_feature_map_id IN     awlrs_file_datum_attrib_map.afdam_affm_id%TYPE
                                ,pi_file_attrib         IN     awlrs_file_datum_attrib_map.afdam_file_attrib%TYPE
                                ,pi_target_attrib       IN     awlrs_file_datum_attrib_map.afdam_target_attrib%TYPE
                                ,po_datum_attrib_map_id IN OUT awlrs_file_datum_attrib_map.afdam_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_id  awlrs_file_datum_attrib_map.afdam_id%TYPE;
    --
  BEGIN
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Feature Map ID'
                               ,pi_parameter_value => pi_file_feature_map_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Attribute`'
                               ,pi_parameter_value => pi_file_attrib);               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Target Attribute'
                               ,pi_parameter_value => pi_target_attrib);
    --
    IF  file_feature_map_exists(pi_affm_id => pi_file_feature_map_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     );    
    END IF;    
    --
    lv_id := afdam_id_seq.NEXTVAL;
    --
    INSERT
      INTO awlrs_file_datum_attrib_map
          (afdam_id
          ,afdam_affm_id
          ,afdam_file_attrib
          ,afdam_target_attrib) 
    VALUES(lv_id
          ,pi_file_feature_map_id
          ,pi_file_attrib
          ,UPPER(pi_target_attrib))
         ;
    --
    po_datum_attrib_map_id := lv_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_datum_attrib_map;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_group_attrib_map(pi_group_attrib_map_id  IN      awlrs_file_grp_attrib_map.afgam_id%TYPE
                                   ,pi_old_affm_id          IN      awlrs_file_grp_attrib_map.afgam_affm_id%TYPE 
                                   ,pi_old_target_nt        IN      awlrs_file_grp_attrib_map.afgam_target_nt%TYPE
                                   ,pi_old_target_gty       IN      awlrs_file_grp_attrib_map.afgam_target_gty%TYPE
                                   ,pi_old_file_attrib      IN      awlrs_file_grp_attrib_map.afgam_file_attrib%TYPE
                                   ,pi_old_target_attrib    IN      awlrs_file_grp_attrib_map.afgam_target_attrib%TYPE
                                   ,pi_new_affm_id          IN      awlrs_file_grp_attrib_map.afgam_affm_id%TYPE 
                                   ,pi_new_target_nt        IN      awlrs_file_grp_attrib_map.afgam_target_nt%TYPE
                                   ,pi_new_target_gty       IN      awlrs_file_grp_attrib_map.afgam_target_gty%TYPE
                                   ,pi_new_file_attrib      IN      awlrs_file_grp_attrib_map.afgam_file_attrib%TYPE
                                   ,pi_new_target_attrib    IN      awlrs_file_grp_attrib_map.afgam_target_attrib%TYPE                                   
                                   ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor           OUT sys_refcursor)
    IS
    --    
    lr_db_id_rec     awlrs_file_grp_attrib_map%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_id_rec
        FROM awlrs_file_grp_attrib_map
       WHERE afgam_id = pi_group_attrib_map_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Group Attrib map does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT upd_group_attrib_map_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Feature Map ID'
                               ,pi_parameter_value => pi_new_affm_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Datum Network Type`'
                               ,pi_parameter_value => pi_new_target_nt);               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Group Type'
                               ,pi_parameter_value => pi_new_target_gty);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Attribute`'
                               ,pi_parameter_value => pi_new_file_attrib);     
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Target Attribute`'
                               ,pi_parameter_value => pi_new_target_attrib);
    --
    IF  file_feature_map_exists(pi_affm_id => pi_new_affm_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     );    
    END IF;   
    --
    IF  group_attrib_map_exists(pi_afgam_id => pi_group_attrib_map_id) <> 'Y'
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
    IF lr_db_id_rec.afgam_affm_id != pi_old_affm_id
     OR (lr_db_id_rec.afgam_affm_id IS NULL AND pi_old_affm_id IS NOT NULL)
     OR (lr_db_id_rec.afgam_affm_id IS NOT NULL AND pi_old_affm_id IS NULL)
     --
     OR (lr_db_id_rec.afgam_target_nt != pi_old_target_nt)
     OR (lr_db_id_rec.afgam_target_nt IS NULL AND pi_old_target_nt IS NOT NULL)
     OR (lr_db_id_rec.afgam_target_nt IS NOT NULL AND pi_old_target_nt IS NULL)
     --       
     OR (lr_db_id_rec.afgam_target_gty != pi_old_target_gty)
     OR (lr_db_id_rec.afgam_target_gty IS NULL AND pi_old_target_gty IS NOT NULL)
     OR (lr_db_id_rec.afgam_target_gty IS NOT NULL AND pi_old_target_gty IS NULL)
     --      
     OR (lr_db_id_rec.afgam_file_attrib != pi_old_file_attrib)
     OR (lr_db_id_rec.afgam_file_attrib IS NULL AND pi_old_file_attrib IS NOT NULL)
     OR (lr_db_id_rec.afgam_file_attrib IS NOT NULL AND pi_old_file_attrib IS NULL)
     --         
     OR (lr_db_id_rec.afgam_target_attrib != pi_old_target_attrib)
     OR (lr_db_id_rec.afgam_target_attrib IS NULL AND pi_old_target_attrib IS NOT NULL)
     OR (lr_db_id_rec.afgam_target_attrib IS NOT NULL AND pi_old_target_attrib IS NULL)
     --       
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_affm_id != pi_new_affm_id
       OR (pi_old_affm_id IS NULL AND pi_new_affm_id IS NOT NULL)
       OR (pi_old_affm_id IS NOT NULL AND pi_new_affm_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF UPPER(pi_old_target_nt) != UPPER(pi_new_target_nt)
       OR (UPPER(pi_old_target_nt) IS NULL AND UPPER(pi_new_target_nt) IS NOT NULL)
       OR (UPPER(pi_old_target_nt) IS NOT NULL AND UPPER(pi_new_target_nt) IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF UPPER(pi_old_target_gty) != UPPER(pi_new_target_gty)
       OR (UPPER(pi_old_target_gty) IS NULL AND UPPER(pi_new_target_gty) IS NOT NULL)
       OR (UPPER(pi_old_target_gty) IS NOT NULL AND UPPER(pi_new_target_gty) IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_file_attrib != pi_new_file_attrib
       OR (pi_old_file_attrib IS NULL AND pi_new_file_attrib IS NOT NULL)
       OR (pi_old_file_attrib IS NOT NULL AND pi_new_file_attrib IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF UPPER(pi_old_target_attrib) != UPPER(pi_new_target_attrib)
       OR (UPPER(pi_old_target_attrib) IS NULL AND UPPER(pi_new_target_attrib) IS NOT NULL)
       OR (UPPER(pi_old_target_attrib) IS NOT NULL AND UPPER(pi_new_target_attrib) IS NULL)
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
        UPDATE awlrs_file_grp_attrib_map
           SET  afgam_affm_id   = pi_new_affm_id
               ,afgam_target_nt = UPPER(pi_new_target_nt)
               ,afgam_target_gty = UPPER(pi_new_target_gty)
               ,afgam_file_attrib = pi_new_file_attrib
               ,afgam_target_attrib = UPPER(pi_new_target_attrib)
         WHERE afgam_id = lr_db_id_rec.afgam_id;
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
        ROLLBACK to upd_group_attrib_map_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_group_attrib_map; 

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_datum_attrib_map(pi_datum_attrib_id      IN      awlrs_file_datum_attrib_map.afdam_id%TYPE
                                   ,pi_old_affm_id          IN      awlrs_file_datum_attrib_map.afdam_affm_id%TYPE 
                                   ,pi_old_file_attrib      IN      awlrs_file_datum_attrib_map.afdam_file_attrib%TYPE
                                   ,pi_old_target_attrib    IN      awlrs_file_datum_attrib_map.afdam_target_attrib%TYPE
                                   ,pi_new_affm_id          IN      awlrs_file_datum_attrib_map.afdam_affm_id%TYPE 
                                   ,pi_new_file_attrib      IN      awlrs_file_datum_attrib_map.afdam_file_attrib%TYPE
                                   ,pi_new_target_attrib    IN      awlrs_file_datum_attrib_map.afdam_target_attrib%TYPE                                 
                                   ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor           OUT sys_refcursor)
    IS
    --    
    lr_db_id_rec     awlrs_file_datum_attrib_map%ROWTYPE;
    lv_upd           VARCHAR2(1) := 'N'; 
    --
    PROCEDURE get_db_rec
      IS
    BEGIN
      --
      SELECT * 
        INTO lr_db_id_rec
        FROM awlrs_file_datum_attrib_map
       WHERE afdam_id = pi_datum_attrib_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found 
       THEN
          --
          hig.raise_ner(pi_appl               => 'HIG'
                       ,pi_id                 => 85
                       ,pi_supplementary_info => 'Datum Attrib map does not exist');
          --      
    END get_db_rec;
    --
  BEGIN
    --
    SAVEPOINT upd_datum_attrib_map_sp;
    --
    awlrs_util.check_historic_mode;
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Feature Map ID'
                               ,pi_parameter_value => pi_new_affm_id);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'File Attribute`'
                               ,pi_parameter_value => pi_new_file_attrib);               
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Target Attribute'
                               ,pi_parameter_value => pi_new_target_attrib);
    --
    IF  file_feature_map_exists(pi_affm_id => pi_new_affm_id) <> 'Y'
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     );    
    END IF;   
    --
    IF  datum_attrib_map_exists(pi_afdam_id => pi_datum_attrib_id) <> 'Y'
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
    IF lr_db_id_rec.afdam_affm_id != pi_old_affm_id
     OR (lr_db_id_rec.afdam_affm_id IS NULL AND pi_old_affm_id IS NOT NULL)
     OR (lr_db_id_rec.afdam_affm_id IS NOT NULL AND pi_old_affm_id IS NULL)
     --
     OR (lr_db_id_rec.afdam_file_attrib != pi_old_file_attrib)
     OR (lr_db_id_rec.afdam_file_attrib IS NULL AND pi_old_file_attrib IS NOT NULL)
     OR (lr_db_id_rec.afdam_file_attrib IS NOT NULL AND pi_old_file_attrib IS NULL)
     --              
     OR (lr_db_id_rec.afdam_target_attrib != pi_old_target_attrib)
     OR (lr_db_id_rec.afdam_target_attrib IS NULL AND pi_old_target_attrib IS NOT NULL)
     OR (lr_db_id_rec.afdam_target_attrib IS NOT NULL AND pi_old_target_attrib IS NULL)
     --       
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_affm_id != pi_new_affm_id
       OR (pi_old_affm_id IS NULL AND pi_new_affm_id IS NOT NULL)
       OR (pi_old_affm_id IS NOT NULL AND pi_new_affm_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_file_attrib != pi_new_file_attrib
       OR (pi_old_file_attrib IS NULL AND pi_new_file_attrib IS NOT NULL)
       OR (pi_old_file_attrib IS NOT NULL AND pi_new_file_attrib IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;     
      --
      IF UPPER(pi_old_target_attrib) != UPPER(pi_new_target_attrib)
       OR (UPPER(pi_old_target_attrib) IS NULL AND UPPER(pi_new_target_attrib) IS NOT NULL)
       OR (UPPER(pi_old_target_attrib) IS NOT NULL AND UPPER(pi_new_target_attrib) IS NULL)
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
        UPDATE awlrs_file_datum_attrib_map
           SET  afdam_affm_id   = pi_new_affm_id
               ,afdam_file_attrib = pi_new_file_attrib
               ,afdam_target_attrib = UPPER(pi_new_target_attrib)
         WHERE afdam_id = lr_db_id_rec.afdam_id;
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
        ROLLBACK to upd_datum_attrib_map_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_datum_attrib_map; 
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_attrib_map(pi_affm_id          IN  awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM awlrs_file_grp_attrib_map
     WHERE afgam_affm_id = pi_affm_id
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
  END get_group_attrib_map;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_attrib_map(pi_affm_id          IN  awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT afdam_id
          ,afdam_affm_id
          ,afdam_file_attrib
          ,afdam_target_attrib
          ,awlrs_copy_trace_api.is_used_for_unique(affm_datum_nt
                                                  ,afdam_target_attrib) used_in_unique
      FROM awlrs_file_datum_attrib_map
          ,awlrs_file_feature_maps
     WHERE affm_id = pi_affm_id
       AND affm_id = afdam_affm_id
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
  END get_datum_attrib_map;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE del_datum_attrib_map(pi_afdam_id         IN  awlrs_file_datum_attrib_map.afdam_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    SAVEPOINT del_datum_attrib_map_sp;
    --
    awlrs_util.check_historic_mode; 
    --
    IF datum_attrib_map_exists(pi_afdam_id => pi_afdam_id) <> 'Y' 
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29
                     ,pi_supplementary_info => 'Datum attribute map does not exist');    
    END IF;
    --
    DELETE
      FROM awlrs_file_datum_attrib_map
     WHERE afdam_id = pi_afdam_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO del_datum_attrib_map_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END del_datum_attrib_map;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_auto_inclusion_types(pi_datumn_nt        IN  nm_types.nt_type%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nti_nw_parent_type parent_nt
          ,ngt_group_type     parent_gty
          ,nti_parent_column  parent_column
          ,nti_child_column   child_column
          ,nti_auto_create    auto_create
          ,nt_admin_type      admin_type
      FROM nm_type_inclusion
          ,nm_group_types
          ,nm_types
     WHERE nti_nw_child_type = pi_datumn_nt
       AND nti_nw_parent_type = ngt_nt_type
       AND ngt_nt_type = nt_type
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
  END get_auto_inclusion_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_parent_ne_id(pi_parent_nt        IN  nm_elements.ne_nt_type%TYPE
                            ,pi_ne_unique        IN  nm_elements.ne_unique%TYPE
                            ,pi_ne_owner         IN  nm_elements.ne_owner%TYPE
                            ,pi_ne_name_1        IN  nm_elements.ne_name_1%TYPE
                            ,pi_ne_name_2        IN  nm_elements.ne_name_2%TYPE
                            ,pi_ne_prefix        IN  nm_elements.ne_prefix%TYPE
                            ,pi_ne_number        IN  nm_elements.ne_number%TYPE
                            ,pi_ne_sub_type      IN  nm_elements.ne_sub_type%TYPE
                            ,pi_ne_no_start      IN  nm_elements.ne_no_start%TYPE
                            ,pi_ne_no_end        IN  nm_elements.ne_no_end%TYPE
                            ,pi_ne_sub_class     IN  nm_elements.ne_sub_class%TYPE
                            ,pi_ne_nsg_ref       IN  nm_elements.ne_nsg_ref%TYPE
                            ,pi_ne_version_no    IN  nm_elements.ne_version_no%TYPE
                            ,pi_ne_group         IN  nm_elements.ne_group%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_unique  nm_elements.ne_unique%TYPE;
    --
  BEGIN
    --
    IF pi_ne_unique IS NOT NULL
     AND NOT nm3net.is_pop_unique(pi_parent_nt)
     THEN
        lv_unique := pi_ne_unique;
    ELSE
        nm3nwval.create_ne_unique(p_ne_unique     => lv_unique    
                                 ,p_ne_nt_type    => pi_parent_nt    
                                 ,p_ne_owner      => pi_ne_owner      
                                 ,p_ne_name_1     => pi_ne_name_1     
                                 ,p_ne_name_2     => pi_ne_name_2     
                                 ,p_ne_prefix     => pi_ne_prefix     
                                 ,p_ne_number     => pi_ne_number     
                                 ,p_ne_sub_type   => pi_ne_sub_type   
                                 ,p_ne_no_start   => pi_ne_no_start   
                                 ,p_ne_no_end     => pi_ne_no_end     
                                 ,p_ne_sub_class  => pi_ne_sub_class  
                                 ,p_ne_nsg_ref    => pi_ne_nsg_ref    
                                 ,p_ne_version_no => pi_ne_version_no 
                                 ,p_ne_group      => pi_ne_group);
    END IF;
    --
    OPEN po_cursor FOR
    SELECT ne_id
          ,ne_unique
      FROM nm_elements
     WHERE ne_nt_type = pi_parent_nt
       AND ne_unique = lv_unique
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
  END get_parent_ne_id;
  
END awlrs_copy_trace_api;
/
