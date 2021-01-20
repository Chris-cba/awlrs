CREATE OR REPLACE PACKAGE BODY awlrs_sdl_upload_api IS
  --
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       pvcsid           : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdl_upload_api.pkb-arc   1.4   Jan 20 2021 12:01:04   Vikas.Mhetre  $
  --       Module Name      : $Workfile:   awlrs_sdl_upload_api.pkb  $
  --       Date into PVCS   : $Date:   Jan 20 2021 12:01:04  $
  --       Date fetched Out : $Modtime:   Jan 20 2021 07:51:04  $
  --       PVCS Version     : $Revision:   1.4  $
  --
  --   Author : Vikas Mhetre
  --
  -----------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
  ----------------------------------------------------------------------------
  --
  g_body_sccsid CONSTANT VARCHAR2(2000) := '$Revision:   1.4  $';
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version RETURN VARCHAR2 IS
  BEGIN
    RETURN g_sccsid;
  END get_version;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version RETURN VARCHAR2 IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;
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
  FUNCTION get_submission_profile_id(pi_batch_id IN sdl_file_submissions.sfs_id%TYPE)
    RETURN sdl_profiles.sp_name%TYPE
  IS
  --
    CURSOR c_profile
        IS
    SELECT sp.sp_id
      FROM sdl_profiles sp
          ,sdl_file_submissions sfs
     WHERE sp.sp_id = sfs.sfs_sp_id
       AND sfs.sfs_id = pi_batch_id;
  --
    ln_ret_id sdl_profiles.sp_id%TYPE;
  --
  BEGIN
  --
    OPEN  c_profile;
    FETCH c_profile INTO ln_ret_id;
    CLOSE c_profile;
  --
    RETURN ln_ret_id;
  --
  END get_submission_profile_id;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_submission_profile_name(pi_batch_id IN sdl_file_submissions.sfs_id%TYPE)
    RETURN sdl_profiles.sp_name%TYPE
  IS
  --
    CURSOR c_profile
        IS
    SELECT sp.sp_name
      FROM sdl_profiles sp
          ,sdl_file_submissions sfs
     WHERE sp.sp_id = sfs.sfs_sp_id
       AND sfs.sfs_id = pi_batch_id;
  --
    lv_ret_name sdl_profiles.sp_name%TYPE;
  --
  BEGIN
  --
    OPEN  c_profile;
    FETCH c_profile INTO lv_ret_name;
    CLOSE c_profile;
  --
    RETURN lv_ret_name;
  --
  END get_submission_profile_name;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_submission_load_type(pi_batch_id IN sdl_file_submissions.sfs_id%TYPE)
    RETURN sdl_destination_header.sdh_type%TYPE
  IS
  --
    CURSOR c_sub
        IS
    SELECT sdh.sdh_type
      FROM sdl_destination_header sdh
          ,sdl_file_submissions sfs
     WHERE sdh.sdh_sp_id = sfs.sfs_sp_id
       AND sdh.sdh_id = sfs.sfs_sdh_id
       AND sfs.sfs_id = pi_batch_id;
  --
    lv_ret_name sdl_destination_header.sdh_type%TYPE;
  --
  BEGIN
  --
    OPEN  c_sub;
    FETCH c_sub INTO lv_ret_name;
    CLOSE c_sub;
  --
    RETURN lv_ret_name;
  --
  END get_submission_load_type;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE pre_file_submission(pi_profile_id      IN sdl_file_submissions.sfs_sp_id%TYPE
                               ,pi_submission_name IN sdl_file_submissions.sfs_name%TYPE
                               ,pi_file_attributes IN awlrs_sdl_util.sam_file_attribute_tab
                               ,po_sdh_id          OUT sdl_destination_header.sdh_id%TYPE)
  IS
    --
    CURSOR chk_submission_name(cp_submission_name IN sdl_file_submissions.sfs_name%TYPE)
        IS
    SELECT 1
      FROM sdl_file_submissions sfs
     WHERE sfs.sfs_name = cp_submission_name;
    --
    CURSOR c_profile(cp_profile_id  sdl_profiles.sp_id%TYPE)
        IS
    SELECT sp.sp_name
          ,sp.sp_loading_view_name
          ,sp.sp_import_file_type
      FROM sdl_profiles sp
     WHERE sp.sp_id = cp_profile_id;
    --
    CURSOR chk_view(cp_view_name  sdl_profiles.sp_loading_view_name%TYPE)
        IS
    SELECT 1
      FROM all_objects
     WHERE object_name = cp_view_name
       AND object_type IN ('TABLE', 'VIEW');
    --
    CURSOR chk_mapping(cp_profile_id     sdl_profiles.sp_id%TYPE
                      ,cp_file_attribute sdl_attribute_mapping.sam_file_attribute_name%TYPE)
        IS
    SELECT 1
      FROM sdl_attribute_mapping sam
          ,sdl_profile_file_columns spfc
          ,sdl_destination_header sdh
     WHERE sam.sam_sp_id = spfc.spfc_sp_id
       AND sam.sam_file_attribute_name = spfc.spfc_col_name
       AND sam.sam_sdh_id = sdh.sdh_id
       AND sdh.sdh_source_container = spfc.spfc_container
       AND sam.sam_sp_id = cp_profile_id
       AND UPPER(sam.sam_file_attribute_name) = cp_file_attribute
    ORDER BY sam_col_id;
    --
    ln_exists             NUMBER(1);
    lv_retval             BOOLEAN := FALSE;
    lv_profile_name       sdl_profiles.sp_name%TYPE;
    lv_view_name          sdl_profiles.sp_loading_view_name%TYPE;
    lv_file_type          sdl_profiles.sp_import_file_type%TYPE;
    lv_match              VARCHAR2(1) := 'N';
    lv_mapping            VARCHAR2(1) := 'N';
    ln_source_columns_cnt NUMBER(3);
    --
  BEGIN
    --
    --SAVEPOINT update_datums_records_sp;
    --
     OPEN chk_submission_name(pi_submission_name);
    FETCH chk_submission_name INTO ln_exists;
        lv_retval := chk_submission_name%FOUND;
    CLOSE chk_submission_name;
    --
    IF lv_retval THEN
       RAISE_APPLICATION_ERROR (-20040,
                               'Submission Name ' || pi_submission_name || ' already exists.');
    END IF;
    --
     OPEN c_profile(pi_profile_id);
    FETCH c_profile INTO lv_profile_name, lv_view_name, lv_file_type;
    CLOSE c_profile;
    --
    IF NOT awlrs_sdl_profiles_api.check_mapping_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20041,
                               'No Attribute mappings exists for the profile. Please configure valid attribute mappings for the Profile ' || lv_profile_name || ' before uploading a file.');
    END IF;
    --
    IF lv_view_name IS NULL THEN
      IF lv_file_type = 'CSV' THEN
        lv_view_name := 'TDL_' || REPLACE (UPPER(lv_profile_name), ' ', '_') || '_LD';
      ELSE
        lv_view_name := 'V_SDL_' || REPLACE (UPPER(lv_profile_name), ' ', '_') || '_LD';
      END IF;
    END IF;
    --
     OPEN chk_view(lv_view_name);
    FETCH chk_view INTO ln_exists;
        lv_retval := chk_view%FOUND;
    CLOSE chk_view;
    --
    IF NOT lv_retval THEN
       RAISE_APPLICATION_ERROR (-20042,
                               'Profile views does not exists for the profile ' || lv_profile_name || '. Please contact the Administrator to generate Profile views before uploading a file.');
    END IF;
    --
    -- TDL supports single container single destination type at the moment
    -- so get the header id and link with the submission.
    -- when multiple destination types allowed correct sdh_id for the submission to be determined 
    -- from the next section while reading the file attributes with table mapping pi_file_attributes
    BEGIN
        SELECT sdh_id
          INTO po_sdh_id
          FROM sdl_destination_header sdh
         WHERE sdh.sdh_sp_id = pi_profile_id
           AND sdh.sdh_destination_location = 'N';
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          RAISE_APPLICATION_ERROR (-20061,
                                   'Multiple destination types exists aganist the container of the profile '|| lv_profile_name);
    
    END;   
    --
    IF awlrs_sdl_profiles_api.csv_headers_exists(pi_profile_id) = 'N' THEN
      -- check for CSV file without column headers
      --
      SELECT COUNT(1)
        INTO ln_source_columns_cnt
        FROM sdl_attribute_mapping sam
            ,sdl_profile_file_columns spfc
            ,sdl_destination_header sdh
       WHERE sam.sam_sp_id = spfc.spfc_sp_id
         AND sam.sam_file_attribute_name = spfc.spfc_col_name
         AND sam.sam_sdh_id = sdh.sdh_id
         AND sdh.sdh_source_container = spfc.spfc_container
         AND sam.sam_sp_id = pi_profile_id;
      --
      IF ln_source_columns_cnt < pi_file_attributes.COUNT THEN
        RAISE_APPLICATION_ERROR (-20060,
                                 'There is no source description configured for some source file columns for the profile ' || lv_profile_name || '. File cannot be uploaded.');
      END IF;
      --
      FOR i IN 1..pi_file_attributes.COUNT
      LOOP
        --
        IF UPPER(pi_file_attributes(i)) = 'FIELD_' || i THEN
          lv_match := 'Y';
        ELSE
          lv_match := 'N';
        END IF;
        --
        IF lv_match = 'Y' THEN
          lv_mapping := 'Y';
        END IF;
      --
      END LOOP;
      --
      IF lv_mapping = 'N' THEN
        RAISE_APPLICATION_ERROR (-20061,
                                 'The source is defined with no column headers for the profile ' || lv_profile_name || ' , whereas selected file has column headers present. File cannot be uploaded.');
      END IF;
      --
    ELSE
      -- check for CSV file with column headers and other source type files
      --
      FOR i IN 1..pi_file_attributes.COUNT
      LOOP
        --
         OPEN chk_mapping(pi_profile_id, UPPER(pi_file_attributes(i)));
        FETCH chk_mapping INTO ln_exists;
          IF chk_mapping%FOUND THEN
            lv_match := 'Y';
          ELSE
            lv_match := 'N';
          END IF;
        CLOSE chk_mapping;
        --
        IF lv_match = 'Y' THEN
          lv_mapping := 'Y';
        END IF;
      --
      END LOOP;
      --
      IF lv_mapping = 'N' THEN
        RAISE_APPLICATION_ERROR (-20043,
                                 'There is no match between file column and ' || lv_profile_name || ' profile attribute mappings. File cannot be uploaded.');
      END IF;
      --
    END IF;
    --
  END pre_file_submission;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_file_submission(pi_submission_name  IN  sdl_file_submissions.sfs_name%TYPE
                                  ,pi_profile_id       IN  sdl_file_submissions.sfs_sp_id%TYPE
                                  ,pi_file_name        IN  sdl_file_submissions.sfs_file_name%TYPE
                                  ,pi_layer_name       IN  sdl_file_submissions.sfs_layer_name%TYPE
                                  ,pi_file_path        IN  sdl_file_submissions.sfs_file_path%TYPE
                                  ,pi_file_attributes  IN  awlrs_sdl_util.sam_file_attribute_tab
                                  ,po_batch_id         OUT sdl_file_submissions.sfs_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    p_status   VARCHAR2(10) := 'NEW';
    p_batch_id sdl_file_submissions.sfs_id%TYPE;
    p_sdh_id   sdl_destination_header.sdh_id%TYPE;
  BEGIN
    --
    pre_file_submission(pi_profile_id, pi_submission_name, pi_file_attributes, p_sdh_id);
    --
    SELECT sfs_id_seq.NEXTVAL INTO p_batch_id FROM dual;
    --
    INSERT
      INTO sdl_file_submissions
           (sfs_id
           ,sfs_name
           ,sfs_sp_id
           ,sfs_user_id
           ,sfs_file_name
           ,sfs_layer_name
           ,sfs_file_path
           ,sfs_status
           ,sfs_sdh_id)
    VALUES (p_batch_id
           ,UPPER(pi_submission_name)
           ,pi_profile_id
           ,SYS_CONTEXT('NM3CORE', 'USER_ID')
           ,pi_file_name
           ,UPPER(pi_layer_name)
           ,pi_file_path
           ,p_status
           ,p_sdh_id);
    --
    sdl_audit.log_process_start(p_batch_id, p_status, NULL, NULL, NULL);
    --
    po_batch_id := p_batch_id;
    --
    sdl_audit.log_process_end(p_batch_id, p_status);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_file_submission;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE start_load_batch(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor)
  IS
  BEGIN
    --
    sdl_audit.log_process_start(pi_batch_id, 'LOAD', NULL, NULL, NULL);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END start_load_batch;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_attributes_formula(pi_batch_id IN  sdl_file_submissions.sfs_id%TYPE)
  IS
    --
    lv_set               nm3type.max_varchar2;
    lv_profile_view_name sdl_profiles.sp_loading_view_name%TYPE;
    lv_sql               nm3type.max_varchar2;
    lv_where             nm3type.max_varchar2 := ' WHERE BATCH_ID = ' || pi_batch_id;
    --
  BEGIN
    --
    BEGIN
      --
      SELECT 'SET ' ||
             LISTAGG(sam.sam_view_column_name || ' = ' || sam.sam_attribute_formula, CHR(10)|| '   ,') WITHIN GROUP(ORDER BY sam.sam_col_id)
        INTO lv_set
        FROM sdl_attribute_mapping sam,
             sdl_file_submissions sfs
       WHERE sam.sam_sp_id = sfs.sfs_sp_id
         AND sfs.sfs_id = pi_batch_id
         AND sam.sam_attribute_formula IS NOT NULL
       GROUP BY sfs.sfs_sp_id;
      --
      IF SQL%FOUND THEN
        --
        BEGIN
          --
          SELECT sp.sp_loading_view_name
            INTO lv_profile_view_name
            FROM sdl_profiles sp,
                 sdl_file_submissions sfs
           WHERE sp.sp_id = sfs.sfs_sp_id
             AND sfs.sfs_id = pi_batch_id;
          --
          lv_sql := 'UPDATE ' || lv_profile_view_name
                   || CHR(10) || lv_set
                   || CHR(10) || lv_where;
          --
          EXECUTE IMMEDIATE lv_sql;
          --
        EXCEPTION
          WHEN OTHERS
          THEN NULL;
        END;
        --
      END IF;
      --
    EXCEPTION
      WHEN OTHERS
      THEN NULL;
    END;
    --
  END update_attributes_formula;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE post_file_submission(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_srid        NUMBER;
    lv_table_name  VARCHAR2(30);
    lv_column_name VARCHAR2(30) := 'GEOM';
    --
    meta_row        V_SDL_PROFILE_NW_TYPES%ROWTYPE;
    l_unit_factor   NUMBER;
    l_round         NUMBER;
    l_tol           NUMBER;
    ln_srid_number  VARCHAR2(1) := 'Y';
    --
  BEGIN
    --
    IF get_submission_load_type(pi_batch_id) != 'A' THEN -- for network data loading .. shapefile, file geodatabase
      -- Get the loading table view name of the batch
      SELECT sp_loading_view_name
        INTO lv_table_name
        FROM sdl_profiles
        WHERE sp_id = (SELECT sfs_sp_id
                         FROM sdl_file_submissions
                        WHERE sfs_id = pi_batch_id);
      -- Get the SRID from the SDO metadata.
      ln_srid := nm3sdo.get_table_srid(p_table_name  => lv_table_name
                                      ,p_column_name => lv_column_name);
      --
      BEGIN
        SELECT 'N'
          INTO ln_srid_number
          FROM DUAL
         WHERE NOT REGEXP_LIKE(hig.get_sysopt('AWLMAPSRID'), '^[[:digit:]]+$');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ln_srid_number := 'Y';
      END;
      -- If no SRID is set use the default from product option.
      IF ln_srid IS NULL
      THEN
        --
        IF ln_srid_number = 'Y' AND hig.get_sysopt('AWLMAPSRID') IS NOT NULL THEN
          ln_srid := hig.get_sysopt('AWLMAPSRID');
        ELSIF ln_srid_number = 'N' THEN
          RAISE_APPLICATION_ERROR (-20062,
                                   ': Product option AWLMAPSRID is not configured correctly.');
        ELSIF hig.get_sysopt('AWLMAPSRID') IS NULL THEN
          RAISE_APPLICATION_ERROR (-20063,
                                   ': Product option AWLMAPSRID is not configured.');
        END IF;
      END IF;
      --
      -- Update METADATA SRID for the recently uploaded layer if the SRID is set to NULL
      UPDATE user_sdo_geom_metadata
         SET srid = ln_srid
       WHERE table_name = lv_table_name
         AND column_name = lv_column_name
         AND (srid IS NULL OR srid != ln_srid);
      -- Update the SRID of loaded geometry in the recently uploaded batch records
      UPDATE sdl_load_data sld
         SET sld.sld_load_geometry.sdo_srid = hig.get_sysopt('AWLMAPSRID')
       WHERE sld.sld_sfs_id = pi_batch_id
         AND (sld.sld_load_geometry.sdo_srid IS NULL
              OR sld.sld_load_geometry.sdo_srid != ln_srid);
      -- update batch records with the formula set for attributes at profile
      -- update_attributes_formula(pi_batch_id); -- commented this time being because need to validate the incoming SQL statements
	                                             -- to avoid SQL injection until we find an approach to handle incoming formula.
       -- set working geometry
      BEGIN
        SELECT m.*
          INTO meta_row
          FROM v_sdl_profile_nw_types m
              ,sdl_file_submissions sfs
         WHERE sfs.sfs_id = pi_batch_id
           AND m.sp_id = sfs.sfs_sp_id;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          RAISE_APPLICATION_ERROR (-20064,
                                   ': Multiple destination types exists for the profile.');
      END;
      --
      l_tol := nm3unit.get_tol_from_unit_mask (
                  NVL (meta_row.profile_group_unit_id, meta_row.datum_unit_id));
      --
      l_round := nm3unit.get_rounding (l_tol);
      --
      SELECT conversion_factor
        INTO l_unit_factor
        FROM mdsys.sdo_dist_units
       WHERE sdo_unit = meta_row.datum_unit_name;
      --
      DELETE FROM sdl_validation_results
            WHERE svr_sfs_id = pi_batch_id;
      --
      sdl_validate.set_working_geometry (pi_batch_id, l_unit_factor, l_round);
      --
    ELSE
      --
      NULL; -- post file submission/validations process for CSV
      --
    END IF;
    -- Update batch status to load
    sdl_audit.log_process_end(pi_batch_id, 'LOAD');
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END post_file_submission;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE batch_status_failed(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
  IS
  BEGIN
    --
    UPDATE sdl_file_submissions
       SET sfs_status = 'FAILED'
     WHERE sfs_id = pi_batch_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END batch_status_failed;  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_file_path(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    --
      OPEN po_cursor FOR
    SELECT sfs.sfs_file_path file_path
          ,sfs.sfs_file_name file_name
      FROM sdl_file_submissions sfs
     WHERE sfs.sfs_id = pi_batch_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_batch_file_path;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_submissions_list(po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT sfs.sfs_id batch_id
          ,sfs.sfs_name submission_name
          ,sfs.sfs_sp_id profile_id
          ,sp.sp_name profile_name
          ,sp.sp_import_file_type source_file_type_code
          ,hv.hco_meaning source_file_type
          ,sfs.sfs_file_name file_name
          ,sfs.sfs_layer_name layer_name
          ,sfs.sfs_date_created action_date
          ,sfs.sfs_date_modified last_action_date
          ,sfs.sfs_status status
          ,sp.sp_attribute_edit_allowed attribute_edit_allowed
      FROM sdl_file_submissions sfs
          ,sdl_profiles sp
          ,hig_codes hv
     WHERE sfs.sfs_sp_id = sp.sp_id
       AND sp.sp_import_file_type = hv.hco_code
       AND hv.hco_domain = 'SDL_FILE_TYPE'
       AND sfs.sfs_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
    ORDER BY sfs.sfs_id DESC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_submissions_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_submissions_list(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sfs.sfs_id batch_id
                                                   ,sfs.sfs_name submission_name
                                                   ,sfs.sfs_sp_id profile_id
                                                   ,sp.sp_name profile_name
                                                   ,sp.sp_import_file_type source_file_type_code
                                                   ,hv.hco_meaning source_file_type
                                                   ,sfs.sfs_file_name file_name
                                                   ,sfs.sfs_layer_name layer_name
                                                   ,sfs.sfs_date_created action_date
                                                   ,sfs.sfs_date_modified last_action_date
                                                   ,sfs.sfs_status status
                                                   ,sp.sp_attribute_edit_allowed attribute_edit_allowed
                                               FROM sdl_file_submissions sfs
                                                   ,sdl_profiles sp
                                                   ,hig_codes hv
                                              WHERE sfs.sfs_sp_id = sp.sp_id
                                                AND sp.sp_import_file_type = hv.hco_code
                                                AND hv.hco_domain = ''SDL_FILE_TYPE''
                                                AND sfs.sfs_user_id = SYS_CONTEXT(''NM3CORE'', ''USER_ID'')';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT batch_id'
                                              ||' ,submission_name'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,source_file_type_code'
                                              ||' ,source_file_type'
                                              ||' ,file_name'
                                              ||' ,layer_name'
                                              ||' ,action_date'
                                              ||' ,last_action_date'
                                              ||' ,status'
                                              ||' ,attribute_edit_allowed'
                                              ||' ,row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'submission_name'
                                ,pi_query_col    => 'sfs_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'source_file_type'
                                ,pi_query_col    => 'hco_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'profile_name'
                                ,pi_query_col    => 'sp_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'file_name'
                                ,pi_query_col    => 'sfs_file_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'status'
                                ,pi_query_col    => 'sfs_status'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'layer_name'
                                ,pi_query_col    => 'sfs_layer_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'action_date'
                                ,pi_query_col    => 'sfs_date_created'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => awlrs_util.c_date_mask
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
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sfs.sfs_id DESC')||') a)'
                     ||CHR(10)||lv_row_restriction;
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
  END get_paged_submissions_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_submission(pi_batch_id          IN  sdl_file_submissions.sfs_id%TYPE
                             ,pi_old_sfs_name      IN  sdl_file_submissions.sfs_name%TYPE
                             ,pi_new_sfs_name      IN  sdl_file_submissions.sfs_name%TYPE
                             ,po_message_severity  OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor    OUT sys_refcursor)
  IS
    --
    lr_db_rec     sdl_file_submissions%ROWTYPE;
    lv_upd        VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_batch_id IN sdl_file_submissions.sfs_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_file_submissions
       WHERE sfs_id = pi_batch_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Submission record does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Submission Name'
                    ,pi_parameter_value => pi_new_sfs_name);
    --
    get_db_rec(pi_batch_id => pi_batch_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_rec.sfs_name != pi_old_sfs_name
     OR (lr_db_rec.sfs_name IS NULL AND pi_old_sfs_name IS NOT NULL)
     OR (lr_db_rec.sfs_name IS NOT NULL AND pi_old_sfs_name IS NULL)
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_sfs_name != pi_new_sfs_name
       OR (pi_old_sfs_name IS NULL AND pi_new_sfs_name IS NOT NULL)
       OR (pi_old_sfs_name IS NOT NULL AND pi_new_sfs_name IS NULL)
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
        UPDATE sdl_file_submissions
           SET sfs_name = pi_new_sfs_name
         WHERE sfs_id = pi_batch_id;
        --
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
        --
      END IF;
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
  END update_submission;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_submission(pi_batch_ids        IN  awlrs_sdl_util.sfs_id_tab
                             ,pi_select_all       IN  VARCHAR2 DEFAULT 'N'
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    -- pi_select_all not used
    FOR i IN 1..pi_batch_ids.COUNT
    LOOP
      --
      DELETE FROM sdl_validation_results
      WHERE svr_sfs_id = pi_batch_ids(i);

      DELETE FROM sdl_attribute_adjustment_audit
      WHERE saaa_sfs_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_intsct_geom
      WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_pt_geom
      WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_pt_arrays
      WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_datum_nodes
      WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_nodes
      WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_route_nodes
      WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_wip_self_intersections
      WHERE sld_key IN (SELECT sld_key
                  FROM sdl_load_data
                 WHERE sld_sfs_id = pi_batch_ids(i));

      DELETE FROM sdl_pline_statistics
      WHERE slps_sld_key IN (SELECT sld_key
                       FROM sdl_load_data
                      WHERE sld_sfs_id = pi_batch_ids(i))
        AND slps_swd_id IN (SELECT swd_id
                      FROM sdl_wip_datums
                     WHERE batch_id = pi_batch_ids(i));

      DELETE FROM sdl_geom_accuracy
      WHERE slga_sld_key IN (SELECT sld_key
                       FROM sdl_load_data
                      WHERE sld_sfs_id = pi_batch_ids(i));

      DELETE FROM sdl_wip_datums
      WHERE batch_id = pi_batch_ids(i);

       DELETE FROM sdl_wip_datum_reversals
       WHERE batch_id = pi_batch_ids(i);

      DELETE FROM sdl_process_audit
      WHERE spa_sfs_id = pi_batch_ids(i);

      DELETE FROM sdl_row_status
      WHERE srs_sfs_id = pi_batch_ids(i);

      DELETE FROM sdl_load_data
      WHERE sld_sfs_id = pi_batch_ids(i);

      DELETE FROM sdl_file_submissions
      WHERE sfs_id = pi_batch_ids(i);

    END LOOP;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_submission;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_audit_ui_active(po_ui_active         OUT VARCHAR2
                                       ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor    OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    po_ui_active := NVL(hig.get_sysopt('SDLAUDITUI'),'N');
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_process_audit_ui_active;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_process_audit_info(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
     SELECT spa.spa_id id
           ,spa.spa_process process
           ,CASE WHEN spa.spa_started IS NOT NULL
                   AND spa.spa_ended IS NULL
                 THEN 'Running'
                 WHEN spa.spa_started IS NOT NULL
                   AND spa.spa_ended IS NOT NULL
                 THEN 'Completed'
                 ELSE 'Unknown'
             END status
           ,spa.spa_started start_time
           ,spa.spa_ended end_time
           ,ROUND((CAST(spa.spa_ended AS date) - CAST(spa.spa_started AS date)) * 24 * 60) elapsed_time_in_mins
           ,spa.spa_sld_key sld_key
           ,spa.spa_tolerance tolerance
           ,spa.spa_match_tolerance match_tolerance
           ,spa.spa_buffer buffer
           ,NVL(spa.spa_modified_by, spa.spa_created_by) user_name
       FROM sdl_process_audit spa
      WHERE spa.spa_sfs_id = pi_batch_id
      ORDER BY spa.spa_id DESC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_batch_process_audit_info;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reset_batch_process_status(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                      ,pi_spa_id           IN  sdl_process_audit.spa_id%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      UPDATE sdl_process_audit
         SET spa_ended = SYSTIMESTAMP
       WHERE spa_id = pi_spa_id
         AND spa_sfs_id = pi_batch_id
         AND spa_ended IS NULL;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reset_batch_process_status;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_submission_attribs_details(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                                          ,po_message_cursor   OUT sys_refcursor
                                          ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    IF get_submission_load_type(pi_batch_id) = 'A' THEN -- Asset loading
    --
        OPEN po_cursor FOR
      SELECT spfc.spfc_col_id sam_col_id
            ,sam.sam_view_column_name
            ,INITCAP(REPLACE(sam.sam_view_column_name,'_',' ')) column_prompt
            ,spfc.spfc_col_datatype field_type
            ,spfc.spfc_col_size field_length
            ,'' dec_places
            ,spfc.spfc_date_format format_mask
            ,spfc.spfc_mandatory mandatory
            ,'' domain
        FROM sdl_attribute_mapping sam
            ,sdl_profiles sp
            ,sdl_profile_file_columns spfc
            ,sdl_file_submissions sfs
            ,sdl_destination_header sdh
        WHERE sam.sam_sp_id = sp.sp_id
          AND spfc.spfc_sp_id = sp.sp_id
          AND sp.sp_id = sfs.sfs_sp_id
      --  AND sam.sam_sdh_id = sdh.sdh_id
          AND sfs.sfs_sdh_id = sdh.sdh_id
          AND spfc.spfc_container = sdh.sdh_source_container
          AND spfc.spfc_col_name = sam.sam_file_attribute_name
          AND sfs.sfs_id = pi_batch_id
        ORDER BY spfc.spfc_col_id;
      --
    ELSE
      --
        OPEN po_cursor FOR
      SELECT sam.sam_col_id
            ,sam.sam_view_column_name
            ,NVL(vnc.column_prompt, INITCAP(REPLACE(sam.sam_view_column_name,'_',' ')))column_prompt
            ,vnc.field_type
            ,vnc.field_length
            ,vnc.dec_places
            ,vnc.format_mask
            ,vnc.mandatory
            ,vnc.domain
        FROM sdl_attribute_mapping sam
            ,sdl_profiles sp
            ,sdl_file_submissions sfs
            ,sdl_destination_header sdh
            ,v_nm_nw_columns vnc
            ,nm_linear_types nlt
       WHERE sam.sam_sp_id = sp.sp_id
         AND sp.sp_id = sfs.sfs_sp_id
         AND sam.sam_sdh_id = sdh.sdh_id
         AND sdh.sdh_nlt_id = nlt.nlt_id
         AND sfs.sfs_sdh_id = sdh.sdh_id
         AND sdh.sdh_destination_location = 'N'
         AND sam.sam_ne_column_name = vnc.column_name
         AND vnc.network_type = nlt.nlt_nt_type
         AND ((nlt.nlt_g_i_d = 'G' AND vnc.group_type = nlt.nlt_gty_type)
                 OR nlt.nlt_g_i_d = 'D')
         AND sfs.sfs_id = pi_batch_id
       ORDER BY sam.sam_col_id;
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
  END get_submission_attribs_details;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_load_record_attribs(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                      ,pi_sld_key          IN  sdl_load_data.sld_key%TYPE
                                      ,pi_record_json      IN  CLOB
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_max_col_id  NUMBER(2);
    lv_col_dec     VARCHAR2(2000);
    lv_select_list VARCHAR2(2000);
    lv_into_list   VARCHAR2(2000);
    lv_col_list    VARCHAR2(2000);
    lv_if          nm3type.max_varchar2 := '  IF';
    lv_else        nm3type.max_varchar2;
    lv_update      nm3type.max_varchar2;
    lv_sql         CLOB;
    --
  BEGIN
    --
    SELECT MAX(sam_col_id)
      INTO ln_max_col_id
      FROM sdl_attribute_mapping
     WHERE sam_sp_id = (SELECT sfs_sp_id
                          FROM sdl_file_submissions
                         WHERE sfs_id = pi_batch_id);
    --
    FOR i IN 1..ln_max_col_id
    LOOP
	    --
      lv_col_dec := lv_col_dec || '  old_col_' || i || ' VARCHAR2(2000);'
                               || CHR(10) || '  new_col_' || i || ' VARCHAR2(2000);';
      --
      lv_select_list := lv_select_list || 'old_rec.col_' || i || ', new_rec.col_' || i;
	    --
      lv_into_list := lv_into_list || 'old_col_' || i || ', new_col_' || i;
	    --
      lv_col_list := lv_col_list || 'col_'|| i || ' PATH ''$.Col' || i ||'''';
      --
      lv_if := lv_if || ' lr_db_rec.sld_col_' || i || ' != old_col_' || i
                   || CHR(10) || '    OR (lr_db_rec.sld_col_' || i || ' IS NULL AND old_col_' || i || ' IS NOT NULL)'
                   || CHR(10) || '    OR (lr_db_rec.sld_col_' || i || ' IS NOT NULL AND old_col_' || i || ' IS NULL)';
      --
      lv_else := lv_else || '    IF old_col_' || i || ' != new_col_' || i
                   || CHR(10) || '      OR (old_col_' || i || ' IS NULL AND new_col_' || i || ' IS NOT NULL)'
                   || CHR(10) || '      OR (old_col_' || i || ' IS NOT NULL AND new_col_' || i || ' IS NULL)'
                   || CHR(10) || '    THEN'
                   || CHR(10) || '      lv_upd := ''Y'';'
                   || CHR(10) || '    END IF;';
      --
      lv_update := lv_update ||'sld_col_' || i || ' = new_col_' || i;
      --
      IF i != ln_max_col_id THEN
	    --
        lv_col_dec := lv_col_dec || CHR(10);
        lv_select_list := lv_select_list || CHR(10) || '        ,';
        lv_into_list := lv_into_list || CHR(10) || '        ,';
        lv_col_list := lv_col_list || CHR(10) || '                   ,';
        lv_if := lv_if ||  CHR(10) || '    OR';
        lv_else := lv_else || CHR(10);
        lv_update := lv_update || CHR(10) || '         ,';
		  --
      END IF;
	    --
    END LOOP;
    --
    lv_sql := 'DECLARE'
           || CHR(10) || lv_col_dec
           || CHR(10) || '  lv_upd VARCHAR2(1) := ''N'';'
           || CHR(10) || '  lr_db_rec sdl_load_data%ROWTYPE;'
           || CHR(10) || '  PROCEDURE get_db_rec(pi_sld_key IN sdl_load_data.sld_key%TYPE) IS'
           || CHR(10) || '  BEGIN'
           || CHR(10) || '    SELECT *'
           || CHR(10) || '      INTO lr_db_rec'
           || CHR(10) || '      FROM sdl_load_data'
           || CHR(10) || '     WHERE sld_key = pi_sld_key'
           || CHR(10) || '       FOR UPDATE NOWAIT;'
           || CHR(10) || '  EXCEPTION'
           || CHR(10) || '    WHEN no_data_found THEN'
           || CHR(10) || '      hig.raise_ner(pi_appl               => ''HIG'''
           || CHR(10) || '                   ,pi_id                 => 85'
           || CHR(10) || '                   ,pi_supplementary_info => ''Load record does not exist'');'
           || CHR(10) || '  END get_db_rec;'
           || CHR(10) || 'BEGIN'
           || CHR(10) || '  get_db_rec(pi_sld_key => ' || pi_sld_key || ');'
           || CHR(10) || '  SELECT ' || lv_select_list
           || CHR(10) || '    INTO ' || lv_into_list
           || CHR(10) || '    FROM dual '
           || CHR(10) || '        ,JSON_TABLE(''' || pi_record_json || ''',''$.oldLoadRecordAttrib[*]'''
           || CHR(10) || '           COLUMNS (' || lv_col_list
           || CHR(10) || '          )) old_rec'
           || CHR(10) || '        ,JSON_TABLE(''' || pi_record_json || ''',''$.newLoadRecordAttrib[*]'''
           || CHR(10) || '           COLUMNS (' || lv_col_list
           || CHR(10) || '          )) new_rec;'
           || CHR(10) || '  --'
           || CHR(10) || '  -- Compare old with DB '
           || CHR(10) || lv_if
           || CHR(10) || '  THEN'
           || CHR(10) || '    --Updated by another user'
           || CHR(10) || '    hig.raise_ner(pi_appl => ''AWLRS'', pi_id   => 24);'
           || CHR(10) || '  ELSE'
           || CHR(10) || '    -- Compare old with New '
           || CHR(10) || lv_else
           || CHR(10) || '    IF lv_upd = ''N'' THEN'
           || CHR(10) || '      --There are no changes to be applied'
           || CHR(10) || '      hig.raise_ner(pi_appl => ''AWLRS'', pi_id   => 25);'
           || CHR(10) || '    ELSE'
           || CHR(10) || '      UPDATE sdl_load_data'
           || CHR(10) || '      SET ' || lv_update
           || CHR(10) || '      WHERE sld_key = ' || pi_sld_key || ';'
           || CHR(10) || '    END IF;'
           || CHR(10) || '  END IF;'
           || CHR(10) || 'END;';
    --
    EXECUTE IMMEDIATE lv_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_load_record_attribs;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_batch_attributes(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_sdh_id      sdl_destination_header.sdh_id%TYPE;
    ln_error_count NUMBER(10);
    --
  BEGIN
    --
    IF get_submission_load_type(pi_batch_id) = 'A' THEN -- Asset loading
      -- this should be loop through sdh_id associated with profile of the submission through container
      -- when multiple containers allowed
      -- each container can have one or more destination type
      BEGIN
      SELECT sdh.sdh_id
        INTO ln_sdh_id
        FROM sdl_profiles sp
            ,sdl_file_submissions sfs
            ,sdl_destination_header sdh
       WHERE sp.sp_id = sfs.sfs_sp_id
         AND sp.sp_id = sdh.sdh_sp_id
         AND sdh.sdh_destination_location = 'N'
         AND sfs.sfs_id = pi_batch_id;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
        raise_application_error (-20070,
                                'Profile having multiple containers.');
      END;
      --
      sdl_audit.log_process_start(pi_batch_id, 'ADJUST', NULL, NULL, NULL);
  -- sdl_invval.attribute adjustment rule
      sdl_audit.log_process_end(pi_batch_id, 'ADJUST');
      sdl_audit.log_process_start(pi_batch_id, 'LOAD_VALIDATION', NULL, NULL, NULL);
      sdl_invval.validate_inv_data (p_sp_id => get_submission_profile_id(pi_batch_id),
                                    p_sfs_id => pi_batch_id,
                                    p_sdh_id => ln_sdh_id,
                                    p_error_count => ln_error_count);
      sdl_audit.log_process_end(pi_batch_id, 'LOAD_VALIDATION');
      --
    ELSE -- Network Loading
      --
      sdl_process.load_validate(p_batch_id => pi_batch_id);
      --
    END IF;
    --
    reset_attribute_validation_flag(pi_batch_id);
    --
    reset_spatial_analysis_flag(pi_batch_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END validate_batch_attributes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_attribute_validation_result(pi_batch_id          IN  sdl_file_submissions.sfs_id%TYPE
                                            ,pi_show_option      IN  VARCHAR2  DEFAULT 'ADJUSTED'
                                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                                            ,po_message_cursor   OUT sys_refcursor
                                            ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    -- show option - INVALID = Attribute Validation failures , ADJUSTED = Attribute adjustments,
    -- REJECTED = Rejected, GEOMINVALID = Geometry failures
    ---
      OPEN po_cursor FOR
    SELECT ROWNUM row_num
          ,val_id
          ,sld_key
          ,batch_id
          ,swd_id
          ,rule_id
          ,profile_id
          ,profile_name
          ,validation_type
          ,sam_id
          ,attribute_name
          ,original_value
          ,adjusted_value
          ,status
          ,status_code
          ,message
      FROM (SELECT svr.val_id
                  ,svr.sld_key
                  ,svr.batch_id
                  ,svr.swd_id
                  ,svr.rule_id
                  ,sfs.sfs_sp_id profile_id
                  ,awlrs_sdl_profiles_api.get_profile_name(sfs.sfs_sp_id) profile_name
                  ,svr.validation_type
                  ,svr.sam_id
                  ,svr.attribute_name
                  ,svr.original_value
                  ,svr.adjusted_value
                  ,svr.status
                  ,svr.status_code
                  ,svr.message
             FROM v_sdl_attrib_validation_result svr
                 ,sdl_file_submissions sfs
            WHERE svr.batch_id = sfs.sfs_id
              AND svr.batch_id = pi_batch_id
              AND svr.show_option = pi_show_option
            ORDER BY svr.validation_type, svr.val_id
           )
           ORDER BY ROWNUM;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_attribute_validation_result;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_validation_results(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                        ,pi_show_option      IN  VARCHAR2 DEFAULT 'ADJUSTED'
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT ROWNUM row_num
                                                   ,val_id
                                                   ,sld_key
                                                   ,batch_id
                                                   ,swd_id
                                                   ,rule_id
                                                   ,profile_id
                                                   ,profile_name
                                                   ,validation_type
                                                   ,sam_id
                                                   ,attribute_name
                                                   ,original_value
                                                   ,adjusted_value
                                                   ,status
                                                   ,status_code
                                                   ,message
                                               FROM (SELECT svr.val_id
                                                           ,svr.sld_key
                                                           ,svr.batch_id
                                                           ,svr.swd_id
                                                           ,svr.rule_id
                                                           ,sfs.sfs_sp_id profile_id
                                                           ,awlrs_sdl_profiles_api.get_profile_name(sfs.sfs_sp_id) profile_name
                                                           ,svr.validation_type
                                                           ,svr.sam_id
                                                           ,svr.attribute_name
                                                           ,svr.original_value
                                                           ,svr.adjusted_value
                                                           ,svr.status
                                                           ,svr.status_code
                                                           ,svr.message
                                                      FROM v_sdl_attrib_validation_result svr
                                                          ,sdl_file_submissions sfs
                                                     WHERE svr.batch_id = sfs.sfs_id
                                                       AND svr.batch_id = :pi_batch_id
                                                       AND svr.show_option = :pi_show_option
                                                     ORDER BY svr.validation_type, svr.val_id)
                                                WHERE 1=1';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT row_num'
                                              ||' ,val_id'
                                              ||' ,sld_key'
                                              ||' ,batch_id'
                                              ||' ,swd_id'
                                              ||' ,rule_id'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,validation_type'
                                              ||' ,sam_id'
                                              ||' ,attribute_name'
                                              ||' ,original_value'
                                              ||' ,adjusted_value'
                                              ||' ,status'
                                              ||' ,status_code'
                                              ||' ,message'
                                              ||' ,row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'sld_key'
                                ,pi_query_col    => 'sld_key'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'validation_type'
                                ,pi_query_col    => 'validation_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'attribute_name'
                                ,pi_query_col    => 'attribute_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'status'
                                ,pi_query_col    => 'status'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'swd_id'
                                ,pi_query_col    => 'swd_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'rule_id'
                                ,pi_query_col    => 'rule_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'original_value'
                                ,pi_query_col    => 'original_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'adjusted_value'
                                ,pi_query_col    => 'adjusted_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'message'
                                ,pi_query_col    => 'message'
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
--                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'svr.validation_type, svr.val_id')||') a)'
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'row_num')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
             ,pi_show_option
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
             ,pi_show_option
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
  END get_paged_validation_results;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_applied_adjustment_rules(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    --
    OPEN po_cursor FOR
  SELECT ROWNUM seq_id
        ,sr.saaa_saar_id rule_id
        ,sr.sam_view_column_name attribute_name
        ,sr.saaa_original_value original_value
        ,sr.saaa_adjusted_value adjusted_value
    FROM (SELECT saa.saaa_id
                ,saa.saaa_sfs_id
                ,saa.saaa_saar_id
                ,saa.saaa_sam_id
                ,sam.sam_view_column_name
                ,saa.saaa_original_value
                ,saa.saaa_adjusted_value
                ,ROW_NUMBER() OVER (PARTITION BY saa.saaa_sfs_id
                                                ,saa.saaa_saar_id
                                                ,saa.saaa_sam_id
                                                ,saa.saaa_original_value
                                        ORDER BY saa.saaa_saar_id
                                                ,saa.saaa_id) row_num
           FROM sdl_attribute_adjustment_audit saa
               ,sdl_attribute_adjustment_rules sar
               ,sdl_attribute_mapping sam
          WHERE saa.saaa_saar_id = sar.saar_id
            AND saa.saaa_sam_id = sam.sam_id
            AND sar.saar_sp_id = sam.sam_sp_id
          ORDER BY saa.saaa_saar_id,  saa.saaa_id) sr
   WHERE sr.saaa_sfs_id = pi_batch_id
     AND sr.row_num = 1;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_applied_adjustment_rules;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_applied_adjust_rules(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT ROWNUM seq_id
                                                   ,sr.saaa_saar_id rule_id
                                                   ,sr.sam_view_column_name attribute_name
                                                   ,sr.saaa_original_value original_value
                                                   ,sr.saaa_adjusted_value adjusted_value
                                               FROM (SELECT saa.saaa_id
                                                           ,saa.saaa_sfs_id
                                                           ,saa.saaa_saar_id
                                                           ,saa.saaa_sam_id
                                                           ,sam.sam_view_column_name
                                                           ,saa.saaa_original_value
                                                           ,saa.saaa_adjusted_value
                                                           , ROW_NUMBER() OVER (PARTITION BY saa.saaa_sfs_id
                                                                                            ,saa.saaa_saar_id
                                                                                            ,saa.saaa_sam_id
                                                                                            ,saa.saaa_original_value
                                                                                   ORDER BY saa.saaa_saar_id
                                                                                           ,saa.saaa_id) row_num
                                                       FROM sdl_attribute_adjustment_audit saa
                                                           ,sdl_attribute_adjustment_rules sar
                                                           ,sdl_attribute_mapping sam
                                                      WHERE saa.saaa_saar_id = sar.saar_id
                                                        AND saa.saaa_sam_id = sam.sam_id
                                                        AND sar.saar_sp_id = sam.sam_sp_id
                                                      ORDER BY saa.saaa_saar_id, saa.saaa_id) sr
                                              WHERE sr.saaa_sfs_id = :pi_batch_id
                                                AND sr.row_num = 1';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT seq_id'
                                              ||' ,rule_id'
                                              ||' ,attribute_name'
                                              ||' ,original_value'
                                              ||' ,adjusted_value'
                                              ||' ,row_count'
                                          ||' FROM (SELECT ROWNUM ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'rule_id'
                                ,pi_query_col    => 'saaa_saar_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'attribute_name'
                                ,pi_query_col    => 'sam_view_column_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'original_value'
                                ,pi_query_col    => 'saaa_original_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'adjusted_value'
                                ,pi_query_col    => 'saaa_adjusted_value'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'ROWNUM')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
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
  END get_paged_applied_adjust_rules;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reject_failed_attributes(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor)
  IS
  BEGIN
  --
    UPDATE sdl_load_data
       SET sld_status = 'REJECTED'
     WHERE sld_status = 'INVALID'
       AND sld_sfs_id = pi_batch_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reject_failed_attributes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE complete_attribute_validation(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor)
  IS
  BEGIN
    --
    UPDATE sdl_file_submissions
       SET sfs_attri_validation_completed = 'Y'
     WHERE sfs_id = pi_batch_id
       AND sfs_attri_validation_completed = 'N';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END complete_attribute_validation;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE perform_spatial_analysis(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor)
  IS
    --
   -- lv_spatial_analysis_completed sdl_file_submissions.sfs_spatial_analysis_completed%TYPE;
    --
  BEGIN
    --
    sdl_process.topo_generation(p_batch_id => pi_batch_id);
    --
    sdl_process.datum_validation (p_batch_id => pi_batch_id);
    --
    reset_spatial_analysis_flag(pi_batch_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END perform_spatial_analysis;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_spatial_analysis_results(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT ROWNUM row_num
          ,swd.swd_id swd_id
          ,swd.sld_key
          ,'' unique_value
          ,swd.datum_id datum_id
          ,swd.status status
          ,2 buffer -- Hardcoded here, but sdl_process.g_buffer can be ammended and used
          ,ROUND(swd.pct_match,2) pct_match
          ,swd.manual_override manual_override
          ,ssrl.ssrl_coverage_level fit_grouping
      FROM sdl_wip_datums swd
          ,sdl_file_submissions sfs
          ,sdl_spatial_review_levels ssrl
     WHERE swd.batch_id = sfs.sfs_id
       AND sfs.sfs_sp_id = ssrl.ssrl_sp_id
       AND swd.batch_id = pi_batch_id
       AND NVL(swd.pct_match, -1) BETWEEN ssrl.ssrl_percent_from AND ssrl.ssrl_percent_to
  ORDER BY swd.swd_id, swd.sld_key;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_spatial_analysis_results;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE complete_spatial_analysis(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor)
  IS
    ln_ret NUMBER(1);
  BEGIN
    --
    BEGIN
      --
      SELECT 1
        INTO ln_ret
        FROM DUAL
       WHERE EXISTS ( SELECT 1
                        FROM sdl_load_data sld
                       WHERE sld_sfs_id = pi_batch_id
                         AND sld_status = 'REVIEW');
      --
      IF SQL%FOUND THEN
        raise_application_error (-20044,
                                'Please complete review of REVIEW status records, update it to either LOAD or SKIP before completing the Spatial Fit Analysis.');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    --
    UPDATE sdl_file_submissions
       SET sfs_spatial_analysis_completed = 'Y'
     WHERE sfs_id = pi_batch_id
       AND sfs_spatial_analysis_completed = 'N';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END complete_spatial_analysis;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_batch_column_data(pi_batch_id  IN     sdl_file_submissions.sfs_id%TYPE
                                 ,po_column_data IN OUT awlrs_util.column_data_tab)
  IS
    --
    lv_column   nm3type.max_varchar2;
    lv_prompt   sdl_attribute_mapping.sam_view_column_name%TYPE;
    lv_type     VARCHAR2(10);
    lv_load_type sdl_destination_header.sdh_type%TYPE := get_submission_load_type(pi_batch_id);
    --
    CURSOR get_attr(cp_batch_id IN sdl_file_submissions.sfs_id%TYPE)
    IS
    SELECT CASE WHEN lv_load_type = 'A' -- Asset
                THEN LOWER(sam.sam_file_attribute_name)
                ELSE 'sld_col_' || sam.sam_col_id
           END column_name
          ,LOWER(sam.sam_view_column_name) prompt
      FROM sdl_attribute_mapping sam
          ,sdl_profiles sp
          ,sdl_file_submissions sfs
          ,sdl_profile_file_columns spfc
          ,sdl_destination_header sdh
     WHERE sam.sam_sp_id = sp.sp_id
       AND sp.sp_id = sfs.sfs_sp_id
       AND sp.sp_id = spfc.spfc_sp_id
   --    AND sam.sam_sdh_id = sdh.sdh_id
       AND sfs.sfs_sdh_id = sdh.sdh_id
       AND spfc.spfc_container = sdh.sdh_source_container
       AND sam.sam_file_attribute_name = spfc.spfc_col_name
       AND sfs.sfs_id = cp_batch_id
     ORDER BY spfc.spfc_col_id;
    --
    TYPE attr_rec IS TABLE OF get_attr%ROWTYPE;
    lt_attr  attr_rec;
    --
  BEGIN
    --
    IF lv_load_type = 'A' THEN -- Asset loading
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'tld_id'
                                ,pi_query_col    => 'tld_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    ELSE -- Network loading
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'sld_key'
                                ,pi_query_col    => 'sld_key'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      -- only needed in input data api and not file attributes api
      awlrs_util.add_column_data(pi_cursor_col   => 'status_'
                                ,pi_query_col    => 'sld_status'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'pct_inside'
                                ,pi_query_col    => 'slga_pct_inside'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'buffer_size'
                                ,pi_query_col    => 'slga_buffer_size'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'length'
                                ,pi_query_col    => 'ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(sld_working_geometry) - SDO_LRS.GEOM_SEGMENT_START_MEASURE(sld_working_geometry),4)'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END IF;
    --
    /* Get Dynamic list of batch attributes */
    OPEN  get_attr(pi_batch_id);
    FETCH get_attr BULK COLLECT INTO lt_attr;
    CLOSE get_attr;
    --
    FOR i IN 1..lt_attr.COUNT
    LOOP
      --
      lv_column := lt_attr(i).column_name;
      --
      lv_prompt := lt_attr(i).prompt;
      --
      lv_type := awlrs_util.c_varchar2_col;
      --
      awlrs_util.add_column_data(pi_cursor_col   => lv_prompt
                                ,pi_query_col    => lv_column
                                ,pi_datatype     => lv_type
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END LOOP;
    --
  END set_batch_column_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_attributes_list(pi_batch_id    IN  sdl_file_submissions.sfs_id%TYPE
                                     ,po_alias_list  IN OUT VARCHAR2
                                     ,po_select_list IN OUT VARCHAR2)
  IS
    --
    lv_prompt   nm_type_columns.ntc_prompt%TYPE;
    --
    TYPE attrib_rec IS RECORD(sam_col_id              sdl_attribute_mapping.sam_col_id%TYPE
                             ,sam_file_attribute_name sdl_attribute_mapping.sam_file_attribute_name%TYPE
                             ,sam_view_column_name    sdl_attribute_mapping.sam_view_column_name%TYPE);
    TYPE attrib_tab IS TABLE OF attrib_rec;
    lt_attrib  attrib_tab;
    --
    lv_load_type sdl_destination_header.sdh_type%TYPE := get_submission_load_type(pi_batch_id);
    --
  BEGIN
    /*
    ||Add batch profile attributes
    */
    --
    SELECT sam.sam_col_id
          ,CASE WHEN lv_load_type = 'A' -- Asset loading
                THEN LOWER(sam.sam_file_attribute_name)
                ELSE 'sld_col_' || sam.sam_col_id
            END sam_file_attribute_name
           ,sam.sam_view_column_name
       BULK COLLECT
       INTO lt_attrib
       FROM sdl_attribute_mapping sam
           ,sdl_profiles sp
           ,sdl_file_submissions sfs
           ,sdl_profile_file_columns spfc
           ,sdl_destination_header sdh
      WHERE sam.sam_sp_id = sp.sp_id
        AND sp.sp_id = sfs.sfs_sp_id
        AND sp.sp_id = spfc.spfc_sp_id
     --   AND sam.sam_sdh_id = sdh.sdh_id
        AND sfs.sfs_sdh_id = sdh.sdh_id
        AND spfc.spfc_container = sdh.sdh_source_container
        AND sam.sam_file_attribute_name = spfc.spfc_col_name
        AND sfs.sfs_id = pi_batch_id
      ORDER BY spfc.spfc_col_id;
    --
    FOR i IN 1..lt_attrib.COUNT
    LOOP
      --
      lv_prompt := LOWER(lt_attrib(i).sam_view_column_name);
      --
      po_select_list := po_select_list||CHR(10)||' ,' || lt_attrib(i).sam_file_attribute_name||' "'||lv_prompt||'"';
      --
      po_alias_list := po_alias_list||CHR(10)||' ,'||lv_prompt;
      --
    END LOOP;
    --
  END get_batch_attributes_list;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_batch_attributes_sql(pi_batch_id     IN sdl_file_submissions.sfs_id%TYPE
                                   ,pi_where_clause IN VARCHAR2 DEFAULT NULL
                                   ,pi_order_column IN VARCHAR2 DEFAULT NULL
                                   ,pi_paged        IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2
  IS
    --
    lv_alias_list   nm3type.max_varchar2;
    lv_select_list  nm3type.max_varchar2;
    lv_pagecols     VARCHAR2(200);
    lv_retval       nm3type.max_varchar2;
    lv_load_type    sdl_destination_header.sdh_type%TYPE := get_submission_load_type(pi_batch_id);
    lv_profile_name sdl_profiles.sp_name%TYPE := get_submission_profile_name(pi_batch_id);
    --
  BEGIN
    --
    get_batch_attributes_list(pi_batch_id    => pi_batch_id
                             ,po_alias_list  => lv_alias_list
                             ,po_select_list => lv_select_list);
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    SELECT CASE WHEN lv_load_type = 'A' -- Asset loading
                THEN 'SELECT tld.tld_id "tld_id", '
                     || LISTAGG(LOWER(spfc.spfc_col_name)
                     || ' ' || LOWER(sam.sam_view_column_name), ', ') WITHIN GROUP(ORDER BY spfc.spfc_col_id)
                     || ' FROM tdl_' || LOWER(REPLACE(lv_profile_name, ' ', '_')) || '_ld tld '
                     || ' WHERE tld.tld_sfs_id = '
                     || pi_batch_id
                ELSE 'SELECT sld.sld_key "sld_key", '
                     || LISTAGG('sld.sld_col_' || sam.sam_col_id
                     || ' ' || LOWER(sam.sam_view_column_name), ', ') WITHIN GROUP(ORDER BY sam.sam_col_id, sam.sam_id)
                     || ' FROM sdl_load_data sld '
                     || ' WHERE sld.sld_sfs_id = '
                     || pi_batch_id
                      END
      INTO lv_retval
      FROM sdl_attribute_mapping sam
          ,sdl_profiles sp
          ,sdl_file_submissions sfs
          ,sdl_profile_file_columns spfc
          ,sdl_destination_header sdh
     WHERE sam.sam_sp_id = sp.sp_id
       AND sp.sp_id = sfs.sfs_sp_id
       AND sp.sp_id = spfc.spfc_sp_id
     --  AND sam.sam_sdh_id = sdh.sdh_id
       AND sfs.sfs_sdh_id = sdh.sdh_id
       AND spfc.spfc_container = sdh.sdh_source_container
       AND sam.sam_file_attribute_name = spfc.spfc_col_name
       AND sfs.sfs_id = pi_batch_id;
    --
    IF lv_load_type = 'A' THEN -- Asset Loading
      --
      lv_retval := 'WITH batch_attribs AS '
                   || '('
                   || lv_retval
                   ||CHR(10)||'   AND ('||NVL(pi_where_clause,'1=1')||')'
                   ||CHR(10)||'   ORDER BY '||NVL(LOWER(pi_order_column),'tld_id')||')'
                   ||CHR(10)||'SELECT '||lv_pagecols
                            ||'"tld_id"'
                            ||lv_alias_list
                   ||CHR(10)||'  FROM batch_attribs';
      --
    ELSE -- Network loading
      --
      lv_retval := 'WITH batch_attribs AS '
                   || '('
                   || lv_retval
                   ||CHR(10)||'   AND ('||NVL(pi_where_clause,'1=1')||')'
                   ||CHR(10)||'   ORDER BY '||NVL(LOWER(pi_order_column),'sld_key')||')'
                   ||CHR(10)||'SELECT '||lv_pagecols
                            ||'"sld_key"'
                            ||lv_alias_list
                   ||CHR(10)||'  FROM batch_attribs';
      --
    END IF;
    --
    RETURN lv_retval;
    --
  END get_batch_attributes_sql;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_file_attributes(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_sql          nm3type.max_varchar2;
    lv_load_type    sdl_destination_header.sdh_type%TYPE := get_submission_load_type(pi_batch_id);
    lv_profile_name sdl_profiles.sp_name%TYPE := get_submission_profile_name(pi_batch_id);
    --
  BEGIN
    --
    SELECT CASE WHEN lv_load_type = 'A' -- Asset loading
                THEN 'SELECT tld.tld_id, '
                     || LISTAGG(LOWER(spfc.spfc_col_name)
                     || ' ' || LOWER(sam.sam_view_column_name), ', ') WITHIN GROUP(ORDER BY spfc.spfc_col_id)
                     || ' FROM tdl_' || LOWER(REPLACE(lv_profile_name, ' ', '_')) || '_ld tld '
                     || ' WHERE tld.tld_sfs_id = '
                     || pi_batch_id
                     || ' ORDER BY tld.tld_id'
                ELSE 'SELECT sld.sld_key, '
                     || LISTAGG('sld.sld_col_' || sam.sam_col_id
                     || ' ' || LOWER(sam.sam_view_column_name), ', ') WITHIN GROUP(ORDER BY sam.sam_col_id, sam.sam_id)
                     || ' FROM sdl_load_data sld '
                     || ' WHERE sld.sld_sfs_id = '
                     || pi_batch_id
                     || ' ORDER BY sld.sld_key'
                 END
      INTO lv_sql
      FROM sdl_attribute_mapping sam
          ,sdl_profiles sp
          ,sdl_file_submissions sfs
          ,sdl_profile_file_columns spfc
          ,sdl_destination_header sdh
     WHERE sam.sam_sp_id = sp.sp_id
       AND sp.sp_id = sfs.sfs_sp_id
       AND sp.sp_id = spfc.spfc_sp_id
   --  AND sam.sam_sdh_id = sdh.sdh_id
       AND sfs.sfs_sdh_id = sdh.sdh_id
       AND spfc.spfc_container = sdh.sdh_source_container
       AND sam.sam_file_attribute_name = spfc.spfc_col_name
       AND sfs.sfs_id = pi_batch_id;
     --
    OPEN po_cursor FOR lv_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_batch_file_attributes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_batch_file_attribs(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                        ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                        ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                        ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                        ,pi_skip_n_rows      IN  PLS_INTEGER
                                        ,pi_pagesize         IN  PLS_INTEGER
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /* Get the Order By clause. */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /* Process the filter. */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_batch_column_data(pi_batch_id     => pi_batch_id
                              ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => ''
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_query := 'SELECT *'
                 ||CHR(10)||'  FROM ('||get_batch_attributes_sql(pi_batch_id          => pi_batch_id
                                                                ,pi_where_clause     => lv_filter
                                                                ,pi_order_column     => lv_order_by
                                                                ,pi_paged            => TRUE)||')'
                 ||lv_row_restriction;
    --
    lv_sql :=  'DECLARE'
               ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
               ||CHR(10)||'  lv_lower_index    PLS_INTEGER := :lower_index;'
               ||CHR(10)||'  lv_upper_index    PLS_INTEGER := :upper_index;'
               ||CHR(10)||'BEGIN'
               ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
               ||CHR(10)||'  USING '
               ||CHR(10)||'       lv_lower_index'
                        ||CASE
                          WHEN pi_pagesize IS NOT NULL
                          THEN
                            CHR(10)||'       ,lv_upper_index'
                          ELSE
                            NULL
                          END
               ||CHR(10)||'  ;'
               ||CHR(10)||'END;';
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_lower_index
           ,lv_upper_index
           ,IN OUT po_cursor;
    --
  END get_paged_batch_file_attribs;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_batch_file_attribs(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
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
  BEGIN
  --
    get_paged_batch_file_attribs(pi_batch_id         => pi_batch_id
                                ,pi_filter_columns   => pi_filter_columns
                                ,pi_filter_operators => pi_filter_operators
                                ,pi_filter_values_1  => pi_filter_values_1
                                ,pi_filter_values_2  => pi_filter_values_2
                                ,pi_order_columns    => pi_order_columns
                                ,pi_order_asc_desc   => pi_order_asc_desc
                                ,pi_skip_n_rows      => pi_skip_n_rows
                                ,pi_pagesize         => pi_pagesize
                                ,po_cursor           => po_cursor);
  --
  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                       ,po_cursor           => po_message_cursor);
  --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_batch_file_attribs;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_orig_attributes_list(pi_batch_id    IN  sdl_file_submissions.sfs_id%TYPE
                                    ,po_alias_list  IN OUT VARCHAR2
                                    ,po_select_list IN OUT VARCHAR2)
  IS
    --
    lv_prompt   nm_type_columns.ntc_prompt%TYPE;
    --
    TYPE attrib_rec IS RECORD(sam_col_id           sdl_attribute_mapping.sam_col_id%TYPE
                             ,sam_view_column_name sdl_attribute_mapping.sam_view_column_name%TYPE);
    TYPE attrib_tab IS TABLE OF attrib_rec;
    lt_attrib  attrib_tab;
    --
  BEGIN
    /*
    ||Add batch profile attributes
    */
    SELECT sam.sam_col_id,
           sam.sam_view_column_name
      BULK COLLECT
      INTO lt_attrib
      FROM sdl_attribute_mapping sam
          ,sdl_profiles sp
          ,sdl_file_submissions sfs
     WHERE sam.sam_sp_id = sp.sp_id
       AND sp.sp_id = sfs.sfs_sp_id
       AND sfs.sfs_id = pi_batch_id
     ORDER BY sam.sam_col_id;
    --
    FOR i IN 1..lt_attrib.COUNT
    LOOP
      --
      lv_prompt := LOWER(lt_attrib(i).sam_view_column_name);
      --
      po_select_list := po_select_list||CHR(10)||' ,sld_col_' || lt_attrib(i).sam_col_id||' "'||lv_prompt||'"';
      --
      po_alias_list := po_alias_list||CHR(10)||' ,"'||lv_prompt||'"';
      --
    END LOOP;
    --
  END get_orig_attributes_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_selected_feature_attributes(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                           ,pi_sld_key          IN  sdl_load_data.sld_key%TYPE
                                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                                           ,po_message_cursor   OUT sys_refcursor
                                           ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_sql nm3type.max_varchar2;
    --
  BEGIN
    --
    SELECT 'SELECT ''SPATIAL_ID'' attribute_name, TO_CHAR(' || pi_sld_key || ') attribute_value
              FROM DUAL
             WHERE EXISTS (SELECT 1
                             FROM sdl_load_data
                            WHERE sld_sfs_id = ' || pi_batch_id
                         || ' AND sld_key = ' || pi_sld_key
                         || ') '
           || 'UNION ALL '
           || 'SELECT sam.sam_view_column_name,
                      CASE pivot '
                   || LISTAGG(' WHEN ' || sam.sam_col_id || ' THEN sld_col_' || sam_col_id) WITHIN GROUP(ORDER BY sam.sam_id)
                   || ' ELSE NULL
                      END attribute
               FROM sdl_load_data sld,
                    sdl_attribute_mapping sam,
                    sdl_file_submissions sfs,
                    (SELECT rownum pivot
                       FROM DUAL
                       CONNECT BY LEVEL <= (SELECT COUNT(1)
                                             FROM sdl_attribute_mapping
                                            WHERE sam_sp_id = (SELECT sfs_sp_id
                                                                 FROM sdl_file_submissions
                                                                WHERE sfs_id = ' || pi_batch_id
                                        || '))) pv
            WHERE sam.sam_sp_id = sfs.sfs_sp_id
              AND sfs.sfs_id = sld.sld_sfs_id
              AND sam.sam_col_id = pv.pivot
              AND sld.sld_sfs_id = ' || pi_batch_id
         || ' AND sld.sld_key = ' || pi_sld_key
    INTO lv_sql
    FROM sdl_attribute_mapping sam
        ,sdl_profiles sp
        ,sdl_file_submissions sfs
   WHERE sam.sam_sp_id = sp.sp_id
     AND sp.sp_id = sfs.sfs_sp_id
     AND sfs.sfs_id = pi_batch_id
   GROUP BY sp.sp_name;
    --
    OPEN po_cursor FOR lv_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_selected_feature_attributes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_selected_features_attributes(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                            ,pi_sld_keys         IN  awlrs_sdl_util.sld_key_tab
                                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                                            ,po_message_cursor   OUT sys_refcursor
                                            ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_sql   nm3type.max_varchar2;
    lv_input nm3type.max_varchar2;
    --
  BEGIN
    --
    FOR i in 1..pi_sld_keys.COUNT
    LOOP
      --
      IF i = pi_sld_keys.COUNT THEN
        lv_input := lv_input || pi_sld_keys(i);
      ELSE
        lv_input := lv_input || pi_sld_keys(i) || ', ';
      END IF;
      --
    END LOOP;
    --
    SELECT 'SELECT sld.sld_key SPATIAL_ID, '
             || LISTAGG('sld.sld_col_' || sam.sam_col_id || ' ' || upper(sam.sam_view_column_name), ', ') WITHIN GROUP(ORDER BY sam.sam_id)
             || ' FROM sdl_load_data sld'
             || ' WHERE sld.sld_sfs_id = '
             || pi_batch_id
             || ' AND sld.sld_key IN ( '
             || lv_input
             || ' )'
             || ' ORDER BY sld.sld_key'
      INTO lv_sql
      FROM sdl_attribute_mapping sam,
           sdl_profiles sp,
           sdl_file_submissions sfs
      WHERE sam.sam_sp_id = sp.sp_id
        AND sp.sp_id = sfs.sfs_sp_id
        AND sfs.sfs_id = pi_batch_id
      GROUP BY sp.sp_name;
    --
    OPEN po_cursor FOR lv_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_selected_features_attributes;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_batch_input_data_sql(pi_batch_id     IN sdl_file_submissions.sfs_id%TYPE
                                   ,pi_where_clause IN VARCHAR2 DEFAULT NULL
                                   ,pi_order_column IN VARCHAR2 DEFAULT NULL
                                   ,pi_paged        IN BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2
  IS
    --
    lv_alias_list   nm3type.max_varchar2;
    lv_select_list  nm3type.max_varchar2;
    lv_pagecols     VARCHAR2(200);
    lv_retval       nm3type.max_varchar2;
    --
  BEGIN
    --
    get_orig_attributes_list(pi_batch_id    => pi_batch_id
                            ,po_alias_list  => lv_alias_list
                            ,po_select_list => lv_select_list);
    --
    IF pi_paged
     THEN
        lv_pagecols := 'rownum "ind"'
            ||CHR(10)||'      ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "row_count"'
            ||CHR(10)||'      ,';
    END IF;
    --
    SELECT 'SELECT sld.sld_key "sld_key", '
           || 'sld.sld_status "status_", '
           || 'NVL(sga.slga_pct_inside,-1) "pct_inside", '
           || 'sga.slga_buffer_size "buffer_size", '
           || 'ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(sld_working_geometry) - SDO_LRS.GEOM_SEGMENT_START_MEASURE(sld_working_geometry),4) "length", '
           || LISTAGG('sld.sld_col_' || sam.sam_col_id || ' "' || LOWER(sam.sam_view_column_name) || '"', ', ') WITHIN GROUP(ORDER BY sam.sam_id)
           || ' FROM sdl_load_data sld, sdl_geom_accuracy sga'
           || ' WHERE sld.sld_key = sga.slga_sld_key (+) '
           || ' AND sga.slga_datum_id IS NULL '
--           || ' AND sld.sld_status = ''VALID'''
           || ' AND sld.sld_status IN (''VALID'',''REVIEW'',''LOAD'',''SKIP'',''TRANSFERRED'')'
           || ' AND sld.sld_sfs_id = '
           || pi_batch_id
    INTO lv_retval
    FROM sdl_attribute_mapping sam,
         sdl_profiles sp,
         sdl_file_submissions sfs
    WHERE sam.sam_sp_id = sp.sp_id
      AND sp.sp_id = sfs.sfs_sp_id
      AND sfs.sfs_id = pi_batch_id
   GROUP BY sp.sp_name;
    --
    lv_retval := 'WITH input_data AS '
                 || '('
                 || lv_retval
                 ||CHR(10)||'   AND ('||NVL(pi_where_clause,'1=1')||')'
                 ||CHR(10)||'   ORDER BY '||NVL(LOWER(pi_order_column),'"sld_key"')||')'
                 ||CHR(10)||'SELECT '||lv_pagecols
                          ||'"sld_key"'
                          ||',"status_"'
                          ||',"pct_inside"'
                          ||',"buffer_size"'
                          ||',"length"'
                          ||lv_alias_list
                 ||CHR(10)||'  FROM input_data';
    --
    RETURN lv_retval;
    --
  END get_batch_input_data_sql;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_input_data(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_sql nm3type.max_varchar2;
    --
  BEGIN
    --
    SELECT 'SELECT sld.sld_key, '
           || 'sld.sld_status status, '
           || 'NVL(sga.slga_pct_inside,-1) pct_inside, '
           || 'sga.slga_buffer_size buffer_size, '
           || 'ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(sld_working_geometry) - SDO_LRS.GEOM_SEGMENT_START_MEASURE(sld_working_geometry),4) length, '
           || LISTAGG('sld.sld_col_' || sam.sam_col_id || ' ' || sam.sam_view_column_name, ', ') WITHIN GROUP(ORDER BY sam.sam_id)
           || ' FROM sdl_load_data sld, sdl_geom_accuracy sga'
           || ' WHERE sld.sld_key = sga.slga_sld_key (+) '
           || ' AND sga.slga_datum_id IS NULL '
           || ' AND sld.sld_status IN (''VALID'',''REVIEW'',''LOAD'',''SKIP'',''TRANSFERRED'')'
           || ' AND sld.sld_sfs_id = '
           || pi_batch_id
           || ' ORDER BY sld.sld_key'
    INTO lv_sql
    FROM sdl_attribute_mapping sam,
         sdl_profiles sp,
         sdl_file_submissions sfs
    WHERE sam.sam_sp_id = sp.sp_id
      AND sp.sp_id = sfs.sfs_sp_id
      AND sfs.sfs_id = pi_batch_id
   GROUP BY sp.sp_name;
    --
    OPEN po_cursor FOR lv_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_batch_input_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_batch_input_data(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                      ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                      ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                      ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                      ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                                      ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                                      ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                                      ,pi_skip_n_rows      IN  PLS_INTEGER
                                      ,pi_pagesize         IN  PLS_INTEGER
                                      ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_sql               nm3type.max_varchar2;
    lv_query             nm3type.max_varchar2;
    lv_lower_index       PLS_INTEGER;
    lv_upper_index       PLS_INTEGER;
    lv_row_restriction   nm3type.max_varchar2;
    lv_order_by          nm3type.max_varchar2;
    lv_filter            nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
  BEGIN
    --
    awlrs_util.gen_row_restriction(pi_index_column => '"ind"'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /* Get the Order By clause. */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc
                                          ,pi_enclose_cols   => TRUE);
    /* Process the filter. */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_batch_column_data(pi_batch_id     => pi_batch_id
                              ,po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => ''
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_query := 'SELECT *'
                ||CHR(10)||'  FROM ('||get_batch_input_data_sql(pi_batch_id     => pi_batch_id
                                                               ,pi_where_clause => lv_filter
                                                               ,pi_order_column => lv_order_by
                                                               ,pi_paged        => TRUE)||')'
                ||lv_row_restriction;
    --
    lv_sql := 'DECLARE'
              ||CHR(10)||'  lv_query          nm3type.max_varchar2 := :query;'
              ||CHR(10)||'  lv_lower_index    PLS_INTEGER := :lower_index;'
              ||CHR(10)||'  lv_upper_index    PLS_INTEGER := :upper_index;'
              ||CHR(10)||'BEGIN'
              ||CHR(10)||'  OPEN :cursor_out FOR lv_query'
              ||CHR(10)||'  USING '
              ||CHR(10)||'       lv_lower_index'
                       ||CASE
                         WHEN pi_pagesize IS NOT NULL
                         THEN
                           CHR(10)||'       ,lv_upper_index'
                         ELSE
                           NULL
                         END
              ||CHR(10)||'  ;'
              ||CHR(10)||'END;';
    --
    EXECUTE IMMEDIATE lv_sql
      USING lv_query
           ,lv_lower_index
           ,lv_upper_index
           ,IN OUT po_cursor;
    --
  END get_paged_batch_input_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_batch_input_data(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
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
  BEGIN
  --
    get_paged_batch_input_data(pi_batch_id         => pi_batch_id
                              ,pi_filter_columns   => pi_filter_columns
                              ,pi_filter_operators => pi_filter_operators
                              ,pi_filter_values_1  => pi_filter_values_1
                              ,pi_filter_values_2  => pi_filter_values_2
                              ,pi_order_columns    => pi_order_columns
                              ,pi_order_asc_desc   => pi_order_asc_desc
                              ,pi_skip_n_rows      => pi_skip_n_rows
                              ,pi_pagesize         => pi_pagesize
                              ,po_cursor           => po_cursor);
  --
  awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                       ,po_cursor           => po_message_cursor);
  --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_batch_input_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_detail(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                            ,pi_sld_key          IN  sdl_load_data.sld_key%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT datum_id seq_id
          ,status
          ,fit_percent
          ,datum_length
          ,start_node
          ,end_node
          ,sld_key
          ,swd_id
     FROM (SELECT ROUND(swd.pct_match, 4) fit_percent
                 ,ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(swd.geom) - SDO_LRS.GEOM_SEGMENT_START_MEASURE(swd.geom),4) datum_length
                 ,st.existing_node_id start_node
                 ,en.existing_node_id end_node
                 ,swd.sld_key
                 ,swd.swd_id
                 ,swd.datum_id
                 ,swd.status
                 ,swd.batch_id
             FROM sdl_wip_datums swd
                 ,v_sdl_node_usages snu
                 ,sdl_wip_nodes st
                 ,sdl_wip_nodes en
            WHERE swd.swd_id = snu.swd_id
              AND snu.start_node = st.hashcode
              AND snu.end_node = en.hashcode)
    WHERE batch_id = pi_batch_id
      AND sld_key = pi_sld_key
      AND status IN ('VALID','REVIEW','LOAD','SKIP','INVALID','TRANSFERRED')
  ORDER BY swd_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_datum_detail;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_datum_detail(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                  ,pi_sld_key          IN  sdl_load_data.sld_key%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT datum_id seq_id,
                                                    status,
                                                    fit_percent,
                                                    datum_length,
                                                    start_node,
                                                    end_node,
                                                    sld_key,
                                                    swd_id
                                              FROM (SELECT ROUND(swd.pct_match, 4) fit_percent,
                                                           ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(swd.geom) -
                                                                SDO_LRS.GEOM_SEGMENT_START_MEASURE(swd.geom),4) datum_length,
                                                           st.existing_node_id start_node,
                                                           en.existing_node_id end_node,
                                                           swd.sld_key,
                                                           swd.swd_id,
                                                           swd.datum_id,
                                                           swd.status,
                                                           swd.batch_id
                                                      FROM sdl_wip_datums swd,
                                                           v_sdl_node_usages snu,
                                                           sdl_wip_nodes st,
                                                           sdl_wip_nodes en
                                                     WHERE swd.swd_id = snu.swd_id
                                                       AND snu.start_node = st.hashcode
                                                       AND snu.end_node = en.hashcode)
                                             WHERE batch_id = :pi_batch_id
                                               AND sld_key = :pi_sld_key
                                               AND status IN (''VALID'',''REVIEW'',''LOAD'',''SKIP'',''INVALID'',''TRANSFERRED'')';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT seq_id'
                                              ||' ,status'
                                              ||' ,fit_percent'
                                              ||' ,datum_length'
                                              ||' ,start_node'
                                              ||' ,end_node'
                                              ||' ,sld_key'
                                              ||' ,swd_id'
                                              ||' ,row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'status'
                                ,pi_query_col    => 'status'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'fit_percent'
                                ,pi_query_col    => 'fit_percent'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'datum_length'
                                ,pi_query_col    => 'datum_length'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_node'
                                ,pi_query_col    => 'start_node'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_node'
                                ,pi_query_col    => 'end_node'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'swd_id'
                                ,pi_query_col    => 'swd_id'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'swd_id')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
             ,pi_sld_key
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
             ,pi_sld_key
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
  END get_paged_datum_detail;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_network_detail(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                    ,pi_swd_id           IN  sdl_wip_datums.swd_id%TYPE
                                    ,pi_sld_key          IN  sdl_load_data.sld_key%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT swd_id
            ,sld_key
            ,pct_match
            ,ne_id
            ,ne_descr
            ,ne_pct
            ,ROWNUM seq_id
        FROM ( SELECT t.swd_id
                     ,t.sld_key
                     ,t.pct_match
                     ,t.ne_id
                     ,e.ne_descr
                     ,t.ne_pct
                FROM (SELECT s.ne_id
                            ,b.swd_id
                            ,b.sld_key
                            ,ROUND (b.pct_match, 3) pct_match
                            ,ROUND (SDO_GEOM.sdo_length (
                                      SDO_LRS.convert_to_std_geom (
                                        SDO_LRS.lrs_intersection (s.geoloc,
                                                                  b.d_buffer,
                                                                  0.005)))
                                     / b.d_length * 100, 3) ne_pct
                       FROM v_lb_nlt_geometry2 s
                            ,(SELECT d.swd_id
                                    ,d.sld_key
                                    ,d.pct_match
                                    ,SDO_GEOM.sdo_length (d.geom, 0.005) d_length
                                    ,SDO_GEOM.sdo_buffer (d.geom, 2) d_buffer
                                FROM sdl_wip_datums d
                               WHERE d.swd_id = pi_swd_id
                                 AND d.sld_key = pi_sld_key) b
                      WHERE sdo_anyinteract (s.geoloc, b.d_buffer) = 'TRUE') t
                     ,nm_elements e
               WHERE e.ne_id = t.ne_id
               ORDER BY t.ne_pct DESC );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_datum_network_detail;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_datum_network_detail(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                          ,pi_swd_id           IN  sdl_wip_datums.swd_id%TYPE
                                          ,pi_sld_key          IN  sdl_load_data.sld_key%TYPE
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
    lv_driving_sql  nm3type.max_varchar2;
    --
    lv_cursor_sql  nm3type.max_varchar2;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'swd_id'
                                ,pi_query_col    => 'swd_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'sld_key'
                                ,pi_query_col    => 'sld_key'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'ne_id'
                                ,pi_query_col    => 't.ne_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'ne_descr'
                                ,pi_query_col    => 'ne_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'ne_pct'
                                ,pi_query_col    => 'ne_pct'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
    --
    lv_driving_sql := 'SELECT swd_id
                             ,sld_key
                             ,pct_match
                             ,ne_id
                             ,ne_descr
                             ,ne_pct
                             ,ROWNUM seq_id
                         FROM (SELECT t.swd_id
                                     ,t.sld_key
                                     ,t.pct_match
                                     ,t.ne_id
                                     ,e.ne_descr
                                     ,t.ne_pct
                                 FROM (SELECT s.ne_id
                                             ,b.swd_id
                                             ,b.sld_key
                                             ,ROUND (b.pct_match, 3) pct_match
                                             ,ROUND (SDO_GEOM.sdo_length (
                                                       SDO_LRS.convert_to_std_geom (
                                                       SDO_LRS.lrs_intersection (s.geoloc
                                                                                ,b.d_buffer
                                                                                ,0.005)))
                                                         / b.d_length * 100, 3) ne_pct
                                        FROM v_lb_nlt_geometry2 s
                                            ,(SELECT d.swd_id
                                                    ,d.sld_key
                                                    ,d.pct_match
                                                    ,SDO_GEOM.sdo_length (d.geom, 0.005) d_length
                                                    ,SDO_GEOM.sdo_buffer (d.geom, 2) d_buffer
                                                FROM sdl_wip_datums d
                                               WHERE d.swd_id = :pi_swd_id
                                                 AND d.sld_key = :pi_sld_key) b
                                      WHERE sdo_anyinteract (s.geoloc, b.d_buffer) = ''TRUE'') t
                                     ,nm_elements e
                                WHERE e.ne_id = t.ne_id
                                ORDER BY t.ne_pct DESC )
                           WHERE 1=1';
    --
    lv_cursor_sql := 'SELECT swd_id'
                             ||' ,sld_key'
                             ||' ,pct_match'
                             ||' ,ne_id'
                             ||' ,ne_descr'
                             ||' ,ne_pct'
                             ||' ,seq_id'
                             ||' ,row_count'
                     ||' FROM (SELECT rownum ind'
                                      ||' ,a.*'
                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                              ||' FROM ('||lv_driving_sql;
    --
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'seq_id')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
    THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_swd_id
             ,pi_sld_key
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_swd_id
             ,pi_sld_key
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
  END get_paged_datum_network_detail;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_load_record_status(pi_status           IN  sdl_load_data.sld_status%TYPE
                                     ,pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                     ,pi_sld_keys         IN  awlrs_sdl_util.sld_key_tab
                                     ,pi_select_all       IN  VARCHAR2 DEFAULT 'N'
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    --lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    ln_cnt       NUMBER;
    lt_sld_keys  awlrs_sdl_util.sld_key_tab;
    --
  BEGIN
    --
    IF pi_select_all = 'Y' THEN

      SELECT sld_key
      BULK COLLECT INTO lt_sld_keys
      FROM sdl_load_data
      WHERE sld_status IN ('VALID','REVIEW','LOAD','SKIP')
      AND sld_sfs_id = pi_batch_id;

    ELSE
      lt_sld_keys := pi_sld_keys;
    END IF;
	--
    FOR i in 1..lt_sld_keys.COUNT
    LOOP
      --
      BEGIN
        SELECT COUNT(1)
          INTO ln_cnt
          FROM sdl_wip_datums swd
         WHERE swd.batch_id = pi_batch_id
           AND swd.sld_key = lt_sld_keys(i)
           AND swd.status = 'INVALID';

        IF ln_cnt >= 1 AND pi_status = 'LOAD' THEN
          RAISE_APPLICATION_ERROR (-20046,
                                   'The associated datum/s has an INVALID status record found for Spatial ID ' || lt_sld_keys(i) || '. Can not update the status to LOAD.');
        END IF;
      --
      END;
      -- Update the status of selected Input Load Data record
      UPDATE sdl_load_data sld
         SET sld.sld_status = pi_status
       WHERE sld.sld_sfs_id  = pi_batch_id
         AND sld.sld_key = lt_sld_keys(i)
         AND sld.sld_status IN ('VALID',   -- When the status of record is other than these
                                'REVIEW',  -- do not update the status of the record i.e INVALID, REJECTED
                                'SKIP',
                                'LOAD');

     -- Changing the Status value for the linear group/route/Input Data will change the Status value for all associated Datum rows
     UPDATE sdl_wip_datums swd
        SET swd.status = pi_status
      WHERE swd.batch_id = pi_batch_id
        AND swd.sld_key = lt_sld_keys(i)
        AND swd.status IN ('VALID',
                           'REVIEW',
                           'SKIP',
                           'LOAD'); -- INVALID status not to be changed
      --
    END LOOP;
    --
    reset_spatial_analysis_flag(pi_batch_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_load_record_status;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_datums_status(pi_status           IN  sdl_wip_datums.status%TYPE
                                ,pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                ,pi_swd_ids          IN  awlrs_sdl_util.swd_id_tab
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    --lv_severity hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    ln_cnt      NUMBER;
    --
  BEGIN
    --
    FOR i IN 1..pi_swd_ids.COUNT
    LOOP
      --
      BEGIN
        SELECT COUNT(1)
          INTO ln_cnt
          FROM sdl_wip_datums swd
         WHERE swd.batch_id = pi_batch_id
           AND swd.swd_id = pi_swd_ids(i)
           AND swd.status = 'INVALID';

        IF ln_cnt >= 1 THEN
          RAISE_APPLICATION_ERROR (-20046,
                                   'The datum status of SWD ID ' || pi_swd_ids(i) || ' is INVALID. Can not update the status to ' || pi_status ||'.');
        END IF;

      /*EXCEPTION
        WHEN OTHERS THEN
          NULL;*/
      END;
      --
      -- Update the status of selected Datum record
      UPDATE sdl_wip_datums swd
         SET swd.status = pi_status
       WHERE swd.batch_id = pi_batch_id
         AND swd.swd_id = pi_swd_ids(i)
         AND swd.status IN ('VALID',
                            'REVIEW',
                            'SKIP',
                            'LOAD');
      --
      -- Update the status of associated Input Load data record
      -- If all Datum entries Status are changed to Skip, the associated Linear Group status is changed to Skip
      -- If all Datum entries are changed to Load, the associated Linear Group status is changed to Load
      -- If any of the Datum entries is changed to Review, the associated Linear Group status is changed to Review.
      --
      UPDATE sdl_load_data sld
         SET sld.sld_status = (SELECT CASE row_count
                                        WHEN 1
                                        THEN pi_status
                                        ELSE 'REVIEW'
                                      END
                                 FROM (SELECT COUNT(DISTINCT(status)) row_count
                                         FROM sdl_wip_datums
                                        WHERE sld_key IN (SELECT sld_key
                                                            FROM sdl_wip_datums
                                                           WHERE swd_id = pi_swd_ids(i))))
       WHERE sld.sld_sfs_id  = pi_batch_id
         AND sld.sld_key = (SELECT sld_key
                              FROM sdl_wip_datums
                             WHERE swd_id = pi_swd_ids(i));
    END LOOP;
    --
    reset_spatial_analysis_flag(pi_batch_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_datums_status;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reverse_geometries(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                              ,pi_sld_keys         IN  awlrs_sdl_util.sld_key_tab
                              ,pi_select_all       IN  VARCHAR2 DEFAULT 'N'
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    lt_sld_keys_tab  awlrs_sdl_util.sld_key_tab;
    lt_sld_keys      int_array_type := int_array_type();
    --
  BEGIN
    --
    IF pi_select_all = 'Y' THEN
      --
      SELECT sld_key
      BULK COLLECT INTO lt_sld_keys_tab
      FROM sdl_load_data
      WHERE sld_status IN ('VALID','REVIEW','LOAD','SKIP')
      AND sld_sfs_id = pi_batch_id;
      --
    ELSE
      lt_sld_keys_tab := pi_sld_keys;
    END IF;
    --
    FOR i IN 1..lt_sld_keys_tab.COUNT
    LOOP
      --
      lt_sld_keys.EXTEND;
      lt_sld_keys(i) := lt_sld_keys_tab(i);
      --
    END LOOP;
    --
    sdl_edit.reverse_datum_geometries (lt_sld_keys);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reverse_geometries;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reset_attribute_validation_flag(pi_batch_id  IN  sdl_file_submissions.sfs_id%TYPE)
  IS
    --
    lv_val_completed  sdl_file_submissions.sfs_attri_validation_completed%TYPE;
    --
  BEGIN
    --

      SELECT sfs_attri_validation_completed
        INTO lv_val_completed
        FROM sdl_file_submissions
       WHERE sfs_id = pi_batch_id;
       --
       -- in case the attribute validation is already validation completed for the submission
       -- then re-set the validation completed flag to N
       IF lv_val_completed = 'Y' THEN
         UPDATE sdl_file_submissions
            SET sfs_attri_validation_completed = 'N'
          WHERE sfs_id = pi_batch_id;
         --
       END IF;
    --
  EXCEPTION
    WHEN OTHERS
      THEN
        NULL;
  END reset_attribute_validation_flag;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reset_spatial_analysis_flag(pi_batch_id  IN  sdl_file_submissions.sfs_id%TYPE)
  IS
    --
    lv_spatial_analysis_completed  sdl_file_submissions.sfs_spatial_analysis_completed%TYPE;
    --
  BEGIN
    --
    SELECT sfs_spatial_analysis_completed
      INTO lv_spatial_analysis_completed
      FROM sdl_file_submissions
     WHERE sfs_id = pi_batch_id;
     --
     -- in case the spatial analysis is already completed for the submission
     -- then re-set the spatial analysis completed flag to N
     IF lv_spatial_analysis_completed = 'Y' THEN
       UPDATE sdl_file_submissions
          SET sfs_spatial_analysis_completed = 'N'
        WHERE sfs_id = pi_batch_id;
       --
     END IF;
    --
  EXCEPTION
    WHEN OTHERS
      THEN
        NULL;
  END reset_spatial_analysis_flag;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_destination_types(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor
                                       ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT sdh_dest.sdh_destination_type destination_type
          ,tpc.tpc_container container
          ,sfs.sfs_sp_id profile_id
          ,sdh_dest.sdh_id dest_id
          ,sdh_loc.sdh_id dest_loc_id
      FROM sdl_destination_header sdh_dest
          ,sdl_destination_header sdh_loc
          ,v_tdl_profile_containers tpc
          ,sdl_file_submissions sfs
     WHERE sdh_dest.sdh_sp_id = sdh_loc.sdh_sp_id
       AND sdh_dest.sdh_source_container = sdh_loc.sdh_source_container
       AND sdh_dest.sdh_destination_type = sdh_loc.sdh_destination_type
       AND sdh_dest.sdh_sp_id = tpc.tpc_sp_id
       AND sdh_dest.sdh_source_container = tpc.tpc_container
       AND sdh_dest.sdh_sp_id = sfs.sfs_sp_id
       AND sdh_dest.sdh_destination_location = 'N'
       AND sdh_loc.sdh_destination_location = 'Y'
       AND sfs.sfs_id = pi_batch_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_batch_destination_types;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_load_destination_details(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                        ,pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                        ,pi_dest_id          IN  sdl_destination_header.sdh_id%TYPE
                                        ,pi_destination_type IN  sdl_destination_header.sdh_destination_type%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_view_name VARCHAR2(30);
    lv_sql       nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_view_name := 'V_TDL_'|| pi_profile_id || '_' || pi_dest_id || '_'
                            || pi_destination_type || '_LD';
    --
    SELECT 'SELECT * FROM '
	          || lv_view_name
            || ' WHERE tld_sfs_id = '
            || pi_batch_id
            || ' ORDER BY tld_id'
      INTO lv_sql
      FROM dual;
    --
    OPEN po_cursor FOR lv_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_load_destination_details;
  --
  -----------------------------------------------------------------------------
  -- datum handling to be done with destination header.. might not required
  PROCEDURE get_load_datums_detail(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor
                                  ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT sld_key
          ,swd_id
          ,fit_percent
          ,datum_length
          ,start_node
          ,end_node
     FROM (SELECT ROUND(swd.pct_match, 4) fit_percent
                 ,ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(swd.geom) - SDO_LRS.GEOM_SEGMENT_START_MEASURE(swd.geom),4) datum_length
                 ,st.existing_node_id start_node
                 ,en.existing_node_id end_node
                 ,swd.sld_key
                 ,swd.swd_id
                 ,swd.datum_id
                 ,swd.status
                 ,swd.batch_id
             FROM sdl_wip_datums swd
                 ,v_sdl_node_usages snu
                 ,sdl_wip_nodes st
                 ,sdl_wip_nodes en
            WHERE swd.swd_id = snu.swd_id
              AND snu.start_node = st.hashcode
              AND snu.end_node = en.hashcode)
    WHERE batch_id = pi_batch_id
      AND status = 'LOAD'
  ORDER BY sld_key, swd_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_load_datums_detail;
  --
  -----------------------------------------------------------------------------
  -- datum handling to be done with destination header.. might not required
  PROCEDURE get_paged_load_datums_detail(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sld_key
                                                   ,swd_id
                                                   ,fit_percent
                                                   ,datum_length
                                                   ,start_node
                                                   ,end_node
                                              FROM (SELECT ROUND(swd.pct_match, 4) fit_percent,
                                                           ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(swd.geom) -
                                                                SDO_LRS.GEOM_SEGMENT_START_MEASURE(swd.geom),4) datum_length,
                                                           st.existing_node_id start_node,
                                                           en.existing_node_id end_node,
                                                           swd.sld_key,
                                                           swd.swd_id,
                                                           swd.datum_id,
                                                           swd.status,
                                                           swd.batch_id
                                                      FROM sdl_wip_datums swd,
                                                           v_sdl_node_usages snu,
                                                           sdl_wip_nodes st,
                                                           sdl_wip_nodes en
                                                     WHERE swd.swd_id = snu.swd_id
                                                       AND snu.start_node = st.hashcode
                                                       AND snu.end_node = en.hashcode)
                                             WHERE batch_id = :pi_batch_id
                                               AND status = ''LOAD''';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT sld_key'
                                              ||' ,swd_id'
                                              ||' ,fit_percent'
                                              ||' ,datum_length'
                                              ||' ,start_node'
                                              ||' ,end_node'
                                              ||' ,row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'sld_key'
                                ,pi_query_col    => 'sld_key'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'swd_id'
                                ,pi_query_col    => 'swd_id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'fit_percent'
                                ,pi_query_col    => 'fit_percent'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'datum_length'
                                ,pi_query_col    => 'datum_length'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'start_node'
                                ,pi_query_col    => 'start_node'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'end_node'
                                ,pi_query_col    => 'end_node'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sld_key, swd_id')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_batch_id
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
  END get_paged_load_datums_detail;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE transfer_load_data(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                              ,pi_dest_id          IN  sdl_destination_header.sdh_id%TYPE
                              ,pi_load_option      IN  VARCHAR2 DEFAULT 'AFTER'
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_rows_processed number(38);
    --
  BEGIN
    --
    IF get_submission_load_type(pi_batch_id) = 'A' THEN -- Asset Loading
      --
      sdl_audit.log_process_start(pi_batch_id, 'TRANSFER', NULL, NULL, NULL);
      --
      sdl_inv_load.load_data(p_sp_id => get_submission_profile_id(pi_batch_id)
                            ,p_sfs_id => pi_batch_id
                            ,p_sdh_id => pi_dest_id
                            ,p_rows_processed => ln_rows_processed );
      --
      sdl_audit.log_process_end(pi_batch_id, 'TRANSFER');
      --
    ELSE -- Network loading
      -- pi_load_option = AFTER is the only option as of now so no need to pass it further.
      sdl_process.transfer(p_batch_id => pi_batch_id);
    END IF;
    --
    UPDATE sdl_file_submissions
       SET sfs_load_data_completed = 'Y'
     WHERE sfs_id = pi_batch_id
       AND sfs_load_data_completed = 'N';
    --
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END transfer_load_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_ui_menu_status(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
  IS
    --
    lv_load_type sdl_destination_header.sdh_type%TYPE := get_submission_load_type(pi_batch_id);
    --
  BEGIN
    --
    /* SDL Import Levels defined for domain SDL_MAX_IMPORT_LEVEL
       UPLOAD   - Upload File
       VALIDATE - Validate Attributes and Review
       SPATIAL  - Spatial Analysis and Review
       LOADNE   - Load into Production Network */
    --
      OPEN po_cursor FOR
    SELECT st.validation_active
          ,st.validation_completed
          ,st.analysis_active
          ,st.analysis_completed
          ,st.transfer_active
          ,st.transfer_completed
          ,CASE WHEN st.sfs_status = 'LOAD'
                 AND st.validation_active = 'Y'
                 AND st.validation_completed = 'N'
                 THEN 'Y'
                 ELSE 'N'
            END run_attribute_validation
          ,CASE WHEN st.sfs_status = 'LOAD_VALIDATION'
                 AND st.validation_completed = 'Y'
                 AND st.analysis_active = 'Y'
                 AND st.analysis_completed = 'N'
                THEN 'Y'
                ELSE 'N'
            END run_spatial_analysis
    FROM
    (
    SELECT sfs.sfs_id
          ,sfs.sfs_status
          ,CASE
           WHEN sup.sup_access_type IN ('VALIDATE', 'SPATIAL', 'LOADNE')
                AND sfs.sfs_status != 'FAILED'
           THEN 'Y'
           ELSE 'N'
           END validation_active
          ,sfs.sfs_attri_validation_completed validation_completed
          ,CASE
           WHEN sup.sup_access_type IN ('SPATIAL', 'LOADNE')
                AND sfs.sfs_attri_validation_completed = 'Y'
                AND lv_load_type != 'A'
           THEN 'Y'
           ELSE 'N'
           END analysis_active
          ,sfs.sfs_spatial_analysis_completed analysis_completed
          ,CASE
           WHEN sup.sup_access_type IN ('LOADNE')
                AND ((sfs.sfs_spatial_analysis_completed = 'Y' AND lv_load_type != 'A')
                    OR (sfs.sfs_attri_validation_completed = 'Y' AND lv_load_type = 'A'))
           THEN 'Y'
           ELSE 'N'
           END transfer_active
          ,sfs.sfs_load_data_completed transfer_completed
    FROM sdl_profiles sp
        ,sdl_user_profiles sup
        ,sdl_file_submissions sfs
        ,hig_codes hc
    WHERE sp.sp_id = sup.sup_sp_id
      AND sp.sp_id = sfs.sfs_sp_id
      AND sup.sup_access_type = hc.hco_code
      AND hc.hco_domain = 'SDL_MAX_IMPORT_LEVEL'
    ) st
    WHERE st.sfs_id = pi_batch_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_ui_menu_status;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION check_process_status(pi_batch_id IN  NUMBER,
                                pi_process  IN  VARCHAR2)
    RETURN VARCHAR2
  IS
    --
    lv_status VARCHAR2(20) := 'UNKNOWN';
    --
  BEGIN
    --
    SELECT CASE WHEN spa.spa_ended IS NOT NULL
                THEN 'COMPLETED'
                ELSE 'RUNNING'
           END status
      INTO lv_status
      FROM sdl_process_audit spa
          ,hig_codes hc
     WHERE spa.spa_sfs_id = pi_batch_id
    -- AND NVL(spa.spa_sld_key, -999) = NVL (p_sld_key, -999)
       AND spa.spa_process = pi_process
       AND hc.hco_domain = 'SDL_PROCESSES'
       AND ROWNUM = 1
     ORDER BY spa.spa_started;
    --
    RETURN lv_status;
    --
  EXCEPTION
    WHEN others
     THEN
       RETURN lv_status;
  --
  END check_process_status;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_process_status(pi_batch_id          IN  sdl_file_submissions.sfs_id%TYPE
                              ,pi_current_tab       IN  VARCHAR2
                              ,po_process_completed OUT VARCHAR2
                              ,po_message_severity  OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor    OUT sys_refcursor)
  IS
  --
  BEGIN
    -- when lengthy process running used in UI to keep spinner running until process completed
    IF pi_current_tab = 'ATTRIBVALIDATION' -- Attribute Validation
    THEN
      IF check_process_status(pi_batch_id, 'ADJUST') = 'COMPLETED'
         AND check_process_status(pi_batch_id, 'LOAD_VALIDATION') = 'COMPLETED'
      THEN
        po_process_completed := 'Y'; -- completed
      ELSE
        po_process_completed := 'N'; -- running
      END IF;
    ELSIF pi_current_tab = 'SPATIALFITRESULTS' -- Spatial Fit Analysis
    THEN
      IF check_process_status(pi_batch_id, 'TOPO_GENERATION') = 'COMPLETED'
        AND check_process_status(pi_batch_id, 'DATUM_VALIDATION') = 'COMPLETED'
      THEN
        po_process_completed := 'Y'; -- completed
      ELSE
        po_process_completed := 'N'; -- running
      END IF;
    ELSIF pi_current_tab = 'LOADSPATIALDATA' -- Load Spatial Data
    THEN
      IF check_process_status(pi_batch_id, 'TRANSFER') = 'COMPLETED'
      THEN
        po_process_completed := 'Y'; -- completed
      ELSE
        po_process_completed := 'N'; -- running
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
  END get_process_status;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_batch_geom_coordinates(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor
                                      ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    -- get the coordinates of a batch geometry in a tabular format
    -- to show the map of a selected submission/batch
      OPEN po_cursor FOR
    SELECT tab.x||','||tab.y batch_geom_coordinates
      FROM sdl_file_submissions sfs,
           TABLE(sdo_util.getvertices(sfs.sfs_mbr_geometry)) tab
     WHERE sfs.sfs_id = pi_batch_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_batch_geom_coordinates;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_attrib_adjusted_for_batch(pi_sld_key  IN sdl_load_data.sld_key%TYPE
                                       ,pi_batch_id IN sdl_file_submissions.sfs_id%TYPE
                                       ,pi_sam_id   IN sdl_attribute_mapping.sam_id%TYPE)
    RETURN VARCHAR2
  IS
    --
    CURSOR chk_adjustment(cp_sld_key  sdl_load_data.sld_key%TYPE
                         ,cp_batch_id sdl_file_submissions.sfs_id%TYPE
                         ,cp_sam_id   sdl_attribute_mapping.sam_id%TYPE)
        IS
    SELECT COUNT(1)
      FROM sdl_attribute_adjustment_audit saaa
     WHERE saaa.saaa_sld_key = cp_sld_key
       AND saaa.saaa_sfs_id = cp_batch_id
       AND saaa.saaa_sam_id = cp_sam_id;
    --
    lv_exists  NUMBER(10);
    lv_retval  VARCHAR2(1) := 'N';
    --
  BEGIN
    --
     OPEN chk_adjustment(pi_sld_key, pi_batch_id, pi_sam_id);
    FETCH chk_adjustment INTO lv_exists;
    CLOSE chk_adjustment;
    --
    IF lv_exists > 0 THEN
      lv_retval := 'Y';
    ELSE
      lv_retval := 'N';
    END IF;
    --
    RETURN lv_retval;
    --
  END is_attrib_adjusted_for_batch;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE export_to_shapefile(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                               ,pi_status_option    IN  VARCHAR2  DEFAULT 'INVALID'
                               ,po_query_string     OUT nm3type.max_varchar2
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
  IS
  --
    lv_retval       nm3type.max_varchar2;
  --
  BEGIN
  --
    /*Export to shapefile option for
    INVALID - validation failed
    REJECTED - Rejected*/
    --
	IF pi_status_option NOT IN ('INVALID','REJECTED') THEN
         RAISE_APPLICATION_ERROR (-20047,
                                   'Only Validation failed or Rejected records allowed to export.');
	END IF;
	--
    SELECT 'SELECT sld.sld_load_geometry AS "SLD_GEOM",' ||
           LISTAGG('sld_col_' || sam.sam_col_id || ' AS "' ||
                    UPPER(sam.sam_file_attribute_name) || '"', ', ') WITHIN GROUP(ORDER BY sam_col_id, sam.sam_id)
           || ' FROM sdl_load_data sld '
           || ' WHERE sld.sld_sfs_id = '
           || pi_batch_id
           || ' AND sld.sld_status = '
           || ''''
           || pi_status_option
           || ''''
           || ' AND EXISTS ( SELECT 1 FROM sdl_validation_results svr WHERE svr.svr_sfs_id = sld.sld_sfs_id AND svr.svr_sld_key = sld.sld_key )'
      INTO lv_retval
      FROM sdl_attribute_mapping sam,
           sdl_profiles sp,
           sdl_file_submissions sfs
     WHERE sam.sam_sp_id = sp.sp_id
       AND sp.sp_id = sfs.sfs_sp_id
       AND sfs.sfs_id = pi_batch_id
     GROUP BY sp.sp_name;
    --
    po_query_string := lv_retval;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END export_to_shapefile;
  --
  -----------------------------------------------------------------------------
  --
END awlrs_sdl_upload_api;
/