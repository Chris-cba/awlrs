CREATE OR REPLACE PACKAGE BODY awlrs_sdl_upload_api IS
  --
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       pvcsid           : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdl_upload_api.pkb-arc   1.1   Mar 18 2020 14:00:54   Vikas.Mhetre  $
  --       Module Name      : $Workfile:   awlrs_sdl_upload_api.pkb  $
  --       Date into PVCS   : $Date:   Mar 18 2020 14:00:54  $
  --       Date fetched Out : $Modtime:   Mar 18 2020 13:48:08  $
  --       PVCS Version     : $Revision:   1.1  $
  --
  --   Author : Vikas Mhetre
  --
  -----------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
  ----------------------------------------------------------------------------
  --
  g_body_sccsid CONSTANT VARCHAR2(2000) := '1.0';
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
  PROCEDURE pre_file_submission(pi_profile_id      IN sdl_file_submissions.sfs_sp_id%TYPE
                               ,pi_submission_name IN sdl_file_submissions.sfs_name%TYPE
                               ,pi_file_attributes IN awlrs_sdl_util.sam_file_attribute_tab)
  IS
    --
    CURSOR chk_submission_name(cp_submission_name IN sdl_file_submissions.sfs_name%TYPE)
        IS
    SELECT 1
      FROM sdl_file_submissions sfs
     WHERE sfs.sfs_name = cp_submission_name;
    --
    CURSOR chk_mapping(cp_profile_id     sdl_profiles.sp_id%TYPE,
                       cp_file_attribute sdl_attribute_mapping.sam_file_attribute_name%type)
        IS
    SELECT 1
      FROM sdl_attribute_mapping sam
     WHERE sam.sam_sp_id = cp_profile_id
       AND sam.sam_file_attribute_name = cp_file_attribute
    ORDER BY sam_col_id;
    --
    CURSOR c_profile(cp_profile_id  sdl_profiles.sp_id%TYPE)
        IS
    SELECT sp.sp_name
          ,sp.sp_loading_view_name
      FROM sdl_profiles sp
     WHERE sp.sp_id = cp_profile_id;
    --
    CURSOR chk_view(cp_view_name  sdl_profiles.sp_loading_view_name%TYPE)
        IS
    SELECT 1
      FROM all_objects
     WHERE object_name = cp_view_name
       AND object_type = 'VIEW';
    --
    lv_exists       NUMBER(1);
    lv_retval       BOOLEAN := FALSE;
    lv_profile_name sdl_profiles.sp_name%TYPE;
    lv_view_name    sdl_profiles.sp_loading_view_name%TYPE;
    --
  BEGIN
    --
    --SAVEPOINT update_datums_records_sp;
    --
     OPEN chk_submission_name(pi_submission_name);
    FETCH chk_submission_name INTO lv_exists;
        lv_retval := chk_submission_name%FOUND;
    CLOSE chk_submission_name;
    --
    IF lv_retval THEN
       RAISE_APPLICATION_ERROR (-20040,
                               'Submission Name ' || pi_submission_name || ' already exists.');
    END IF;
    --
     OPEN c_profile(pi_profile_id);
    FETCH c_profile INTO lv_profile_name, lv_view_name;
    CLOSE c_profile;
    --
    IF NOT awlrs_sdl_profiles_api.check_mapping_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20041,
                               'No Attribute mappings exists for the profile. Please configure valid attribute mappings for the Profile ' || lv_profile_name || ' before uploading a file.');
    END IF;
    --
    IF lv_view_name IS NULL THEN
      lv_view_name := 'V_SDL_' || REPLACE (UPPER(lv_profile_name), ' ', '_') || '_LD';
    END IF;
    --
     OPEN chk_view(lv_view_name);
    FETCH chk_view INTO lv_exists;
        lv_retval := chk_view%FOUND;
    CLOSE chk_view;
    --
    IF NOT lv_retval THEN
       RAISE_APPLICATION_ERROR (-20042,
                               'Profile views does not exists for the profile ' || lv_profile_name || '. Please contact the Administrator to generate Profile views before uploading a file.');
    END IF;
    --
    FOR i in 1..pi_file_attributes.COUNT
    LOOP
      --
       OPEN chk_mapping(pi_profile_id, pi_file_attributes(i));
      FETCH chk_mapping INTO lv_exists;
        lv_retval := chk_mapping%FOUND;
      CLOSE chk_mapping;
      --
      IF NOT lv_retval THEN
         RAISE_APPLICATION_ERROR (-20043,
                                 'No attribute mappings setup exists for file attribute ' || pi_file_attributes(i) || '. Please configure valid attribute mappings for the Profile ' || lv_profile_name || ' before uploading a file.');
      END IF;
    --
    END LOOP;
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
  BEGIN
    --
    pre_file_submission(pi_profile_id, pi_submission_name, pi_file_attributes);
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
           ,sfs_status)
    VALUES (p_batch_id
           ,UPPER(pi_submission_name)
           ,pi_profile_id
           ,SYS_CONTEXT('NM3CORE', 'USER_ID')
           ,pi_file_name
           ,UPPER(pi_layer_name)
           ,pi_file_path
           ,p_status
            );
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
    lv_update      VARCHAR2(4000);
    --
    meta_row        V_SDL_PROFILE_NW_TYPES%ROWTYPE;
    l_unit_factor   NUMBER;
    l_round         NUMBER;
    l_tol           NUMBER;
    --
  BEGIN
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
    -- If no SRID is set use the default from product option.
    IF ln_srid IS NULL
     THEN
        ln_srid := hig.get_sysopt('AWLMAPSRID');
    END IF;
    -- Update METADATA SRID for the recently uploaded layer if the SRID is set to NULL
    UPDATE user_sdo_geom_metadata
       SET srid = ln_srid
     WHERE table_name = lv_table_name
       AND column_name = lv_column_name
       AND (srid IS NULL OR srid != ln_srid);
    -- Update the SRID of loaded geometry in the recently uploaded batch records
    lv_update := 'UPDATE SDL_LOAD_DATA SL' || CHR(10) ||
                 'SET SL.SLD_LOAD_GEOMETRY.SDO_SRID = hig.get_sysopt(''AWLMAPSRID'')' || CHR(10) ||
              -- 'SET SL.SLD_LOAD_GEOMETRY = SDO_CS.TRANSFORM(SL.SLD_LOAD_GEOMETRY,'|| ln_srid || ')' || CHR(10) ||
                 'WHERE SL.SLD_SFS_ID = ' || pi_batch_id || CHR(10) ||
                 'AND ( SL.SLD_LOAD_GEOMETRY.SDO_SRID IS NULL' || CHR(10) ||
                       'OR SL.SLD_LOAD_GEOMETRY.SDO_SRID != ' || ln_srid || ')';
    EXECUTE IMMEDIATE lv_update;
    -- update batch records with the formula set for attributes at profile
    update_attributes_formula(pi_batch_id);
    -- set working geometry
    SELECT m.*
      INTO meta_row
      FROM v_sdl_profile_nw_types m
          ,sdl_file_submissions sfs
     WHERE sfs.sfs_id = pi_batch_id
       AND m.sp_id = sfs.sfs_sp_id;
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
          ,awlrs_sdl_profiles_api.get_profile_name(sfs.sfs_sp_id) profile_name
          ,hv.hco_meaning import_file_type
          ,sfs.sfs_file_name file_name
          ,sfs.sfs_layer_name layer_name
          ,sfs.sfs_date_created action_date
          ,sfs.sfs_date_modified last_action_date
          ,sfs.sfs_status status
      FROM sdl_file_submissions sfs
          ,sdl_profiles sp
          ,hig_codes hv
     WHERE sfs.sfs_sp_id = sp.sp_id
       AND sp.sp_import_file_type = hv.hco_code
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
                                                   ,hv.hco_meaning import_file_type
                                                   ,sfs.sfs_file_name file_name
                                                   ,sfs.sfs_layer_name layer_name
                                                   ,sfs.sfs_date_created action_date
                                                   ,sfs.sfs_date_modified last_action_date
                                                   ,sfs.sfs_status status
                                               FROM sdl_file_submissions sfs
                                                   ,sdl_profiles sp
                                                   ,hig_codes hv
                                              WHERE sfs.sfs_sp_id = sp.sp_id
                                                AND sp.sp_import_file_type = hv.hco_code
                                                AND sfs.sfs_user_id = SYS_CONTEXT(''NM3CORE'', ''USER_ID'')';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT batch_id'
                                              ||' ,submission_name'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,import_file_type'
                                              ||' ,file_name'
                                              ||' ,layer_name'
                                              ||' ,action_date'
                                              ||' ,last_action_date'
                                              ||' ,status'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'import_file_type'
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
  PROCEDURE validate_batch_attributes(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    sdl_process.load_validate(p_batch_id => pi_batch_id);
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
    --
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
    lv_spatial_analysis_completed sdl_file_submissions.sfs_spatial_analysis_completed%TYPE;
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
    --
    CURSOR get_attr(cp_batch_id IN sdl_file_submissions.sfs_id%TYPE)
        IS
    SELECT 'sld_col_' || sam.sam_col_id column_name,
           LOWER(sam.sam_view_column_name) prompt
      FROM sdl_attribute_mapping sam
          ,sdl_profiles sp
          ,sdl_file_submissions sfs
     WHERE sam.sam_sp_id = sp.sp_id
       AND sp.sp_id = sfs.sfs_sp_id
       AND sfs.sfs_id = cp_batch_id
     ORDER BY sam.sam_col_id;
    --
    TYPE attr_rec IS TABLE OF get_attr%ROWTYPE;
    lt_attr  attr_rec;
    --
  BEGIN
    --
    awlrs_util.add_column_data(pi_cursor_col   => 'sld_key'
                              ,pi_query_col    => 'sld_key'
                              ,pi_datatype     => awlrs_util.c_number_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);

    awlrs_util.add_column_data(pi_cursor_col   => 'status_'
                              ,pi_query_col    => 'sld_status'
                              ,pi_datatype     => awlrs_util.c_varchar2_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);

    awlrs_util.add_column_data(pi_cursor_col   => 'pct_inside'
                              ,pi_query_col    => 'slga_pct_inside'
                              ,pi_datatype     => awlrs_util.c_number_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);

    awlrs_util.add_column_data(pi_cursor_col   => 'buffer_size'
                              ,pi_query_col    => 'slga_buffer_size'
                              ,pi_datatype     => awlrs_util.c_number_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);

    awlrs_util.add_column_data(pi_cursor_col   => 'length'
                              ,pi_query_col    => 'ROUND(SDO_LRS.GEOM_SEGMENT_END_MEASURE(sld_working_geometry) - SDO_LRS.GEOM_SEGMENT_START_MEASURE(sld_working_geometry),4)'
                              ,pi_datatype     => awlrs_util.c_number_col
                              ,pi_mask         => NULL
                              ,pio_column_data => po_column_data);
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
    --
  BEGIN
    --
    get_batch_attributes_list(pi_batch_id     => pi_batch_id
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
    SELECT 'SELECT sld_key AS "sld_key", '
           || LISTAGG('sld_col_' || sam.sam_col_id || ' AS "' || LOWER(sam.sam_view_column_name) || '"', ', ') WITHIN
            GROUP(ORDER BY sam_col_id, sam.sam_id)
           || ' FROM '
           || ' ('
           || 'SELECT sld.sld_key sld_key, '
           || LISTAGG('CASE WHEN awlrs_sdl_upload_api.is_attrib_adjusted_for_batch(vo.saaa_sld_key, vo.saaa_sfs_id, ' || sam.sam_id || ') =  ''Y'' THEN vo.saaa_col_' || sam.sam_col_id || ' ELSE sld.sld_col_' || sam.sam_col_id
           || ' END sld_col_' || sam.sam_col_id , ', ') WITHIN GROUP(ORDER BY sam_col_id, sam.sam_id)
           || ' FROM sdl_load_data sld, v_sdl_actual_load_data vo '
           || ' WHERE sld.sld_sfs_id = vo.saaa_sfs_id(+)'
           || '   AND sld.sld_key = vo.saaa_sld_key(+)'
           || '   AND sld.sld_sfs_id = '
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
    lv_retval := 'WITH batch_attribs AS '
                 || '('
                 || lv_retval
                 ||CHR(10)||')'
                 ||CHR(10)||'  WHERE 1=1'
                 ||CHR(10)||'   AND ('||NVL(pi_where_clause,'1=1')||')'
                 ||CHR(10)||'   ORDER BY '||NVL(LOWER(pi_order_column),'"sld_key"')||')'
                 ||CHR(10)||'SELECT '||lv_pagecols
                          ||'"sld_key"'
                          ||lv_alias_list
                 ||CHR(10)||'  FROM batch_attribs';
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
    lv_sql nm3type.max_varchar2;
    --
  BEGIN
    --
    SELECT 'SELECT sld.sld_key, '
           || LISTAGG('CASE WHEN awlrs_sdl_upload_api.is_attrib_adjusted_for_batch(vo.saaa_sld_key, vo.saaa_sfs_id, ' || sam.sam_id || ') =  ''Y'' THEN vo.saaa_col_' || sam.sam_col_id || ' ELSE sld.sld_col_' || sam.sam_col_id
           || ' END ' || LOWER(sam.sam_view_column_name), ', ') WITHIN GROUP(ORDER BY sam_col_id, sam.sam_id)
           || ' FROM sdl_load_data sld, v_sdl_actual_load_data vo '
           || ' WHERE sld.sld_sfs_id = vo.saaa_sfs_id(+)'
           || '   AND sld.sld_key = vo.saaa_sld_key(+)'
           || '   AND sld.sld_sfs_id = '
           || pi_batch_id
           || ' ORDER BY sld_key'
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
           || ' AND sld.sld_status IN (''VALID'',''REVIEW'',''LOAD'',''SKIP'',''NO_ACTION'',''TRANSFERRED'')'
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
           || ' AND sld.sld_status IN (''VALID'',''REVIEW'',''LOAD'',''SKIP'',''NO_ACTION'',''TRANSFERRED'')'
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
      AND status IN ('VALID','REVIEW','LOAD','SKIP','NO_ACTION','INVALID','TRANSFERRED')
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
                                               AND status IN (''VALID'',''REVIEW'',''LOAD'',''SKIP'',''NO_ACTION'',''INVALID'',''TRANSFERRED'')';
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
  PROCEDURE get_update_status_codes(po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT hc.hco_code
          ,hc.hco_code || ' - ' || hc.hco_meaning hco_meaning
      FROM hig_codes hc
          ,hig_domains hd
     WHERE hc.hco_domain = hd.hdo_domain
       AND hd.hdo_product = 'NET'
       AND hd.hdo_domain = 'SDL_REVIEW_ACTION'
       AND hco_code != 'NO_ACTION'
     ORDER BY hc.hco_seq;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_update_status_codes;
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
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    ln_cnt       NUMBER;
    lt_sld_keys  awlrs_sdl_util.sld_key_tab;
    --
  BEGIN
    --
    IF pi_select_all = 'Y' THEN

      SELECT sld_key
      BULK COLLECT INTO lt_sld_keys
      FROM sdl_load_data
      WHERE sld_status IN ('VALID','REVIEW','LOAD','SKIP','NO_ACTION')
      AND sld_sfs_id = pi_batch_id;

    ELSE
      lt_sld_keys := pi_sld_keys;
    END IF;

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

     /* EXCEPTION
        WHEN OTHERS THEN
          NULL;*/
      END;

      -- Update the status of selected Input Load Data record
      UPDATE sdl_load_data sld
         SET sld.sld_status = pi_status
       WHERE sld.sld_sfs_id  = pi_batch_id
         AND sld.sld_key = lt_sld_keys(i)
         AND sld.sld_status IN ('VALID',   -- When the status of record is other than these
                                'REVIEW',  -- do not update the status of the record i.e INVALID, REJECTED
                                'SKIP',
                                'LOAD',
                                'NO_ACTION');

     -- Changing the Status value for the linear group/route/Input Data will change the Status value for all associated Datum rows
     UPDATE sdl_wip_datums swd
        SET swd.status = pi_status
      WHERE swd.batch_id = pi_batch_id
        AND swd.sld_key = lt_sld_keys(i)
        AND swd.status IN ('VALID',
                           'REVIEW',
                           'SKIP',
                           'LOAD',
                           'NO_ACTION'); -- INVALID status not to be changed
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
    lv_severity hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
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
                            'LOAD',
                            'NO_ACTION');
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
                                                           WHERE swd_id = pi_swd_ids(i)))) --19363, 17566
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
  PROCEDURE reset_attribute_validation_flag(pi_batch_id  IN  sdl_file_submissions.sfs_id%TYPE)
  IS
    --
    lv_val_completed  sdl_file_submissions.sfs_attri_validation_completed%TYPE;
    --
  BEGIN

      SELECT sfs_attri_validation_completed
        INTO lv_val_completed
        FROM sdl_file_submissions
       WHERE sfs_id = pi_batch_id;
       --
       -- in case the attribute validationis already validation completed for the submisison
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
  PROCEDURE transfer_load_data(pi_batch_id         IN  sdl_file_submissions.sfs_id%TYPE
                              ,pi_load_option      IN  VARCHAR2 DEFAULT 'AFTER'
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor)
  IS
    --
  BEGIN
    -- pi_load_option = AFTER is the only option as of now so no need to pass it further.
    sdl_process.transfer(p_batch_id => pi_batch_id);
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
           WHEN sp.sp_max_import_level IN ('VALIDATE', 'SPATIAL', 'LOADNE')
           THEN 'Y'
           ELSE 'N'
           END validation_active
          ,sfs.sfs_attri_validation_completed validation_completed
          ,CASE
           WHEN sp.sp_max_import_level IN ('SPATIAL', 'LOADNE')
                AND sfs.sfs_attri_validation_completed = 'Y'
           THEN 'Y'
           ELSE 'N'
           END analysis_active
          ,sfs.sfs_spatial_analysis_completed analysis_completed
          ,CASE
           WHEN sp.sp_max_import_level IN ('LOADNE')
                AND sfs.sfs_spatial_analysis_completed = 'Y'
           THEN 'Y'
           ELSE 'N'
           END transfer_active
          ,sfs.sfs_load_data_completed transfer_completed
    FROM sdl_profiles sp
        ,sdl_file_submissions sfs
        ,hig_codes hc
    WHERE sp.sp_id = sfs.sfs_sp_id
      AND sp.sp_max_import_level = hc.hco_code
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
