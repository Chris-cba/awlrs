CREATE OR REPLACE PACKAGE BODY awlrs_sdl_profiles_api IS
  --
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       pvcsid           : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdl_profiles_api.pkb-arc   1.14   Mar 04 2021 13:28:42   Vikas.Mhetre  $
  --       Module Name      : $Workfile:   awlrs_sdl_profiles_api.pkb  $
  --       Date into PVCS   : $Date:   Mar 04 2021 13:28:42  $
  --       Date fetched Out : $Modtime:   Mar 04 2021 13:24:40  $
  --       PVCS Version     : $Revision:   1.14  $
  --
  --   Author : Vikas Mhetre
  --
  -----------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
  ----------------------------------------------------------------------------
  --
  g_body_sccsid CONSTANT VARCHAR2(2000) := '$Revision:   1.14  $';
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
  FUNCTION get_profile_name(pi_profile_id IN sdl_profiles.sp_id%TYPE)
    RETURN sdl_profiles.sp_name%TYPE
  IS
  --
    CURSOR c_profile
        IS
    SELECT sp_name
      FROM sdl_profiles
     WHERE sp_id = pi_profile_id;
  --
    lv_ret_name sdl_profiles.sp_name%TYPE;
  --
  BEGIN
  --
  --  awlrs_sdl_util.validate_user_role;
  --
    OPEN  c_profile;
    FETCH c_profile INTO lv_ret_name;
    CLOSE c_profile;
  --
    RETURN lv_ret_name;
  --
  END get_profile_name;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_profile_file_type(pi_batch_id IN sdl_file_submissions.sfs_id%TYPE)
    RETURN sdl_profiles.sp_import_file_type%TYPE
  IS
  --
    CURSOR c_prof
        IS
    SELECT sp_import_file_type
      FROM sdl_profiles sp
     WHERE sp.sp_id = pi_batch_id;
  --
    lv_ret_name sdl_profiles.sp_import_file_type%TYPE;
  --
  BEGIN
  --
    OPEN  c_prof;
    FETCH c_prof INTO lv_ret_name;
    CLOSE c_prof;
  --
    RETURN lv_ret_name;
  --
  END get_profile_file_type;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION active_batch_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE)
    RETURN BOOLEAN
  IS
    --
    CURSOR chk_batch(cp_profile_id sdl_profiles.sp_id%TYPE)
        IS
    SELECT COUNT(1)
      FROM sdl_file_submissions sfs
     WHERE sfs.sfs_sp_id = cp_profile_id
       AND EXISTS (SELECT 1
                     FROM sdl_load_data sld
                    WHERE sld.sld_sfs_id = sfs.sfs_id);
    --
    lv_exists  NUMBER(10);
    --
  BEGIN
    --
     OPEN chk_batch(pi_profile_id);
    FETCH chk_batch INTO lv_exists;
    CLOSE chk_batch;
    --
    IF lv_exists > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    --
  END active_batch_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION check_mapping_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE)
    RETURN BOOLEAN
  IS
    --
    CURSOR chk_mapping(cp_profile_id sdl_profiles.sp_id%TYPE)
        IS
    SELECT COUNT(1)
      FROM sdl_attribute_mapping sam
     WHERE sam.sam_sp_id = cp_profile_id;
    --
    lv_exists  NUMBER(10);
    --
  BEGIN
    --
    --awlrs_sdl_util.validate_user_role;
    --
     OPEN chk_mapping(pi_profile_id);
    FETCH chk_mapping INTO lv_exists;
    CLOSE chk_mapping;
    --
    IF lv_exists > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    --
  END check_mapping_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION check_mapping_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE
                               ,pi_spfc_id    IN sdl_profile_file_columns.spfc_id%TYPE)
    RETURN BOOLEAN
  IS
    --
    CURSOR chk_mapping IS
    SELECT COUNT(1)
      FROM sdl_attribute_mapping sam
          ,sdl_profile_file_columns spfc
          ,sdl_destination_header sdh
     WHERE sam.sam_sp_id = spfc.spfc_sp_id
       AND spfc.spfc_sp_id = sdh.sdh_sp_id
       AND sam.sam_file_attribute_name = spfc.spfc_col_name
       AND spfc.spfc_container = sdh.sdh_source_container
       AND sam.sam_sdh_id = sdh.sdh_id
       AND sam.sam_sp_id = pi_profile_id
       AND spfc.spfc_id = pi_spfc_id;
    --
    lv_exists  NUMBER(10);
    --
  BEGIN
    --
    --awlrs_sdl_util.validate_user_role;
    --
     OPEN chk_mapping;
    FETCH chk_mapping INTO lv_exists;
    CLOSE chk_mapping;
    --
    IF lv_exists > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    --
  END check_mapping_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION active_user_batch_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE
                                   ,pi_user_id    IN sdl_user_profiles.sup_user_id%TYPE)
    RETURN BOOLEAN
  IS
    --
    CURSOR chk_batch(cp_profile_id sdl_profiles.sp_id%TYPE
                    ,cp_user_id    sdl_user_profiles.sup_user_id%TYPE)
        IS
    SELECT COUNT(1)
      FROM sdl_file_submissions sfs
     WHERE sfs.sfs_sp_id = cp_profile_id
       AND sfs.sfs_user_id = cp_user_id
       AND EXISTS (SELECT 1
                     FROM sdl_load_data sld
                    WHERE sld.sld_sfs_id = sfs.sfs_id);
    --
    lv_exists  NUMBER(10);
    --
  BEGIN
    --
     OPEN chk_batch(pi_profile_id, pi_user_id);
    FETCH chk_batch INTO lv_exists;
    CLOSE chk_batch;
    --
    IF lv_exists > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    --
  END active_user_batch_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION active_rule_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE
                             ,pi_saar_id    IN sdl_attribute_adjustment_rules.saar_id%TYPE)
    RETURN BOOLEAN
  IS
    --
    CURSOR chk_rule(cp_profile_id sdl_profiles.sp_id%TYPE
                   ,cp_saar_id    sdl_attribute_adjustment_rules.saar_id%TYPE)
        IS
    SELECT COUNT(1)
      FROM sdl_attribute_adjustment_rules saar
     WHERE saar_sp_id = cp_profile_id
       AND saar_id    = cp_saar_id
       AND EXISTS (SELECT 1
                     FROM sdl_attribute_adjustment_audit saaa,
                          sdl_load_data sld
                    WHERE saaa.saaa_saar_id = saar.saar_id
                      AND saaa.saaa_sld_key = sld.sld_key
                      AND sld.sld_adjustment_rule_applied = 'Y');
    --
    lv_exists  NUMBER(10);
    --
  BEGIN
    --
     OPEN chk_rule(pi_profile_id, pi_saar_id);
    FETCH chk_rule INTO lv_exists;
    CLOSE chk_rule;
    --
    IF lv_exists > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    --
  END active_rule_exists;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE active_setup_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE)
  IS
    --
    ln_exists NUMBER;
    --
  BEGIN
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_user_profiles
                      WHERE sup_sp_id = pi_profile_id);
      --
      RAISE_APPLICATION_ERROR (-20021,
                              'User profile setup exists for the profile '|| get_profile_name(pi_profile_id));
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;
    END;
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_attribute_mapping
                      WHERE sam_sp_id = pi_profile_id);
      --
      RAISE_APPLICATION_ERROR (-20022,
                              'Attribute mapping setup exists for the profile '|| get_profile_name(pi_profile_id));
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;
    END;
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_attribute_adjustment_rules
                      WHERE saar_sp_id = pi_profile_id);
      --
      RAISE_APPLICATION_ERROR (-20023,
                              'Attribute Adjustment Rule setup exists for the profile '|| get_profile_name(pi_profile_id));
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;
    END;
    --
  END active_setup_exists;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION csv_headers_exists(pi_profile_id IN sdl_profiles.sp_id%TYPE) RETURN VARCHAR2
  IS
    --
    lv_headers VARCHAR2(1) := 'Y';
    --
  BEGIN
    --
    SELECT spsh.spsh_attrib_value
      INTO lv_headers
      FROM sdl_profile_source_header spsh
          ,sdl_source_type_attribs ssta
          ,sdl_profiles sp
     WHERE sp.sp_id = spsh.spsh_sp_id
       AND spsh.spsh_ssta_id = ssta.ssta_id
       AND sp.sp_import_file_type = ssta.ssta_source_type
       AND sp.sp_import_file_type = 'CSV'
       AND ssta.ssta_attribute = 'HEADERS'
       AND sp.sp_id = pi_profile_id;
     --
     RETURN lv_headers;
     --
  EXCEPTION
    WHEN OTHERS THEN
      RETURN lv_headers;
  END csv_headers_exists;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE default_datum_attribute_mapping (pi_profile_id IN sdl_attribute_adjustment_rules.saar_sp_id%TYPE)
  IS
    --
    CURSOR c_remaining_columns(p_profile_id NUMBER) IS
    SELECT network_type, column_name, mandatory, field_type, format_mask, domain, lov_query,
           CASE WHEN domain IS NOT NULL
                THEN (SELECT hco_code FROM hig_codes WHERE hco_domain = domain AND ROWNUM = 1)
                WHEN field_type = 'NUMBER'
                THEN TO_CHAR(1)
                WHEN field_type = 'VARCHAR2'
                THEN 'Z'
                WHEN field_type = 'DATE'
                THEN TO_CHAR(SYSDATE, format_mask)
                ELSE 'X'
            END default_value
      FROM v_nm_nw_columns
     WHERE network_type = (SELECT datum_nt_type FROM v_sdl_profile_nw_types WHERE sp_id = p_profile_id)
       AND column_name NOT IN ('NE_ADMIN_UNIT', 'NE_SUB_CLASS', 'NE_START_DATE', 'NE_OWNER', 'NE_NAME_1', 'NE_NAME_2',
                               'NE_GROUP', 'NE_PREFIX', 'NE_NSG_REF', 'NE_VERSION_NO', 'NE_DESCR')
       AND (mandatory = 'Y' OR domain IS NOT NULL)
     ORDER BY column_name;
    --
    lv_datum_type    sdl_datum_attribute_mapping.sdam_nw_type%TYPE;
    lv_column_name   sdl_datum_attribute_mapping.sdam_column_name%TYPE;
    lv_default_value sdl_datum_attribute_mapping.sdam_default_value%TYPE;
    lv_formula       sdl_datum_attribute_mapping.sdam_formula%TYPE;
    ln_max_seq       sdl_datum_attribute_mapping.sdam_seq_no%TYPE;
    lv_exists        VARCHAR2(1) := 'N';
    --
    FUNCTION get_domain_default_value (pi_datum_type    sdl_datum_attribute_mapping.sdam_nw_type%TYPE,
                                       pi_column_name   sdl_datum_attribute_mapping.sdam_column_name%TYPE)
    RETURN VARCHAR2
    IS
      lv_default_value sdl_datum_attribute_mapping.sdam_default_value%TYPE;
    BEGIN
      SELECT (SELECT hco_code
                FROM hig_codes
               WHERE hco_domain = domain
                 AND ROWNUM = 1)
        INTO lv_default_value
        FROM v_nm_nw_columns
       WHERE network_type = pi_datum_type
         AND column_name = pi_column_name
         AND domain IS NOT NULL;

      RETURN lv_default_value;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END get_domain_default_value;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    SELECT datum_nt_type
      INTO lv_datum_type
      FROM v_sdl_profile_nw_types
     WHERE sp_id = pi_profile_id;
    -- NE_ADMIN_UNIT
    lv_column_name := 'NE_ADMIN_UNIT';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 1, lv_column_name, NVL(lv_default_value,1), NULL);
    -- NE_SUB_CLASS
    lv_column_name := 'NE_SUB_CLASS';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 2, lv_column_name, NVL(lv_default_value,'S'), NULL);
    -- NE_START_DATE
    lv_column_name := 'NE_START_DATE';
    lv_formula := '';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);
    IF lv_default_value IS NULL THEN
      lv_formula := 'l.ne_start_date';
    END IF;

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 3, lv_column_name, lv_default_value, lv_formula);
    -- NE_OWNER
    lv_column_name := 'NE_OWNER';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 4, lv_column_name, NVL(lv_default_value,'L'), NULL);
    -- NE_NAME_1
    lv_column_name := 'NE_NAME_1';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 5, lv_column_name, NVL(lv_default_value,'AS-BUILT'), NULL);
    -- NE_NAME_2
    lv_column_name := 'NE_NAME_2';
    lv_formula := '';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);
    --
    BEGIN
      SELECT 'Y'
        INTO lv_exists
        FROM sdl_attribute_mapping
       WHERE sam_sp_id = pi_profile_id
         AND sam_ne_column_name = 'NE_OWNER';
    EXCEPTION
      WHEN OTHERS THEN
        lv_exists := 'N';
    END;
    --
    IF lv_default_value IS NULL AND lv_exists = 'Y' THEN
      lv_formula := 'l.ne_owner';
    ELSE
      lv_formula := '';
      IF lv_default_value IS NULL THEN
        lv_default_value := '00';
      END IF;
    END IF;
    --
    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 6, lv_column_name, lv_default_value, lv_formula);
    -- NE_GROUP
    lv_column_name := 'NE_GROUP';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 7, lv_column_name, NVL(lv_default_value,'O'), NULL);
    -- NE_PREFIX
    lv_column_name := 'NE_PREFIX';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 8, lv_column_name, NVL(lv_default_value, 'NULL'), NULL);
    -- NE_NSG_REF
    lv_column_name := 'NE_NSG_REF';
    lv_formula := '';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);
    IF lv_default_value IS NULL THEN
      lv_formula := 'sdo_lrs.geom_segment_start_measure(d.geom)';
    END IF;

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 9, lv_column_name, lv_default_value, lv_formula);
    -- NE_VERSION_NO
    lv_column_name := 'NE_VERSION_NO';
    lv_formula := '';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);
    IF lv_default_value IS NULL THEN
      lv_formula := 'sdo_lrs.geom_segment_end_measure(d.geom)';
    END IF;

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 10, lv_column_name, lv_default_value, lv_formula);
    -- NE_DESCR
    lv_column_name := 'NE_DESCR';
    lv_formula := '';
    lv_default_value := get_domain_default_value(lv_datum_type, lv_column_name);
    IF lv_default_value IS NULL THEN
      lv_formula := '''RD - ''||l.ne_unique||'' - ''||to_char(round(sdo_lrs.geom_segment_start_measure(d.geom),2))||'' TO ''||to_char(round(sdo_lrs.geom_segment_end_measure(d.geom),2))';
    END IF;

    INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
    VALUES (pi_profile_id, lv_datum_type, 11, lv_column_name, lv_default_value, lv_formula);
    --
    -- Other Mandatory Datum Columns
    SELECT MAX(sdam_seq_no)
      INTO ln_max_seq
      FROM sdl_datum_attribute_mapping
     WHERE sdam_profile_id = pi_profile_id;
    -- See if there are any mandatory datum columns that are still missing
    FOR cur IN c_remaining_columns(pi_profile_id)
    LOOP
      INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
      VALUES (pi_profile_id ,cur.network_type , TO_NUMBER(ln_max_seq + 1), cur.column_name,cur.default_value, NULL);
    END LOOP;
    --
  END default_datum_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE generate_profile_views(pi_profile_id IN sdl_profiles.sp_id%TYPE)
  IS
    --
    ln_cnt NUMBER;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    IF NOT check_mapping_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20035,
                               'No Attribute mappings exists for the profile. Please configure valid attribute mappings for the profile ' || get_profile_name(pi_profile_id) || ' first.');
    END IF;
    --
    IF get_profile_file_type(pi_profile_id) = 'CSV' THEN -- this probably should be for asset types
      --
      SELECT COUNT(1)
        INTO ln_cnt
        FROM sdl_file_submissions sfs
       WHERE sfs.sfs_sp_id = pi_profile_id;
      --
      IF ln_cnt >= 1 THEN
        RAISE_APPLICATION_ERROR (-20034,
                                 'Generation of profile table/views not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active file data exists in the system.');
      END IF;
      --
      sdl_inv_ddl.create_tdl_profile_tables (p_sp_id => pi_profile_id);
      sdl_inv_ddl.create_tdl_profile_views (p_sp_id => pi_profile_id);
    ELSE
      --
      IF active_batch_exists(pi_profile_id) THEN
        RAISE_APPLICATION_ERROR (-20034,
                                 'Generation of profile views not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active file data exists in the system.');
      END IF;
      --
      sdl_ddl.gen_sdl_profile_views(pi_profile_id);
    END IF;
    --
    -- this update of sp_loading_view_name needs to re-consider awhen multiple containers allowed for a profile.
    UPDATE sdl_profiles
       SET sp_loading_view_name = CASE WHEN sp_import_file_type = 'CSV'
                                       THEN 'TDL_' || REPLACE (UPPER(sp_name), ' ', '_') || '_LD'
                                       ELSE 'V_SDL_' || REPLACE (UPPER(sp_name), ' ', '_') || '_LD'
                                   END
     WHERE sp_id = pi_profile_id;
    --
  END generate_profile_views;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE generate_profile_views(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_count NUMBER;
    lv_g_i_d VARCHAR2(1);
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    IF get_profile_file_type(pi_profile_id) != 'CSV'  THEN -- shapefile, file geodatabase
      --
      -- default_datum_attribute_mapping to be replaced with a new UI to insert datum attribute mappings
      -- in Manage Profiles screen in future release
      -- Administrator should configure datum mappings along with profile attribute mappings through SDL application
      -- This has been added as a temporary (kind of hardcoded) logic to insert default values for datum mappings
      SELECT COUNT(1)
        INTO ln_count
        FROM sdl_datum_attribute_mapping s
       WHERE s.sdam_profile_id = pi_profile_id;
      --
      IF ln_count > 0 THEN -- If datum mappings already exists re-create it
        DELETE sdl_datum_attribute_mapping s WHERE s.sdam_profile_id = pi_profile_id;
      END IF;
      --
      SELECT nlt_g_i_d
        INTO lv_g_i_d
        FROM v_sdl_profile_nw_types
       WHERE sp_id = pi_profile_id;
       --
      IF lv_g_i_d = 'G' THEN
        default_datum_attribute_mapping(pi_profile_id);
      END IF;
      --
    END IF;
    --
    generate_profile_views(pi_profile_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END generate_profile_views;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_profile_views(pi_profile_id IN sdl_profiles.sp_id%TYPE)
  IS
    --
    ln_dummy  NUMBER(1);
    --
  BEGIN
    --
    SELECT 1
      INTO ln_dummy
      FROM dba_objects
     WHERE object_name = (SELECT CASE WHEN sp_import_file_type = 'CSV'
                                      THEN UPPER ('TDL_' || REPLACE (sp_name, ' ', '_') || '_LD')
                                      ELSE UPPER ('V_SDL_' || REPLACE (sp_name, ' ', '_') || '_LD')
                                      END
                          FROM sdl_profiles
                         WHERE sp_id = pi_profile_id)
       AND object_type IN ('TABLE', 'VIEW')
       AND owner = SYS_CONTEXT ('NM3CORE', 'APPLICATION_OWNER');
    --
    IF SQL%FOUND THEN
      generate_profile_views(pi_profile_id       => pi_profile_id);
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END update_profile_views;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_file_load_attribute_list(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    -- used in UI to get source name while loading the file
    -- need to see use when a profile has multiple container configuration
      OPEN po_cursor FOR
    SELECT sam.sam_sp_id profile_id
          ,CASE WHEN sp.sp_import_file_type = 'CSV'
                THEN spfc.spfc_col_id
                ELSE sam.sam_col_id
            END col_id
          ,sam.sam_file_attribute_name file_column
          ,CASE WHEN sp.sp_import_file_type = 'CSV'
                THEN sam.sam_file_attribute_name
                ELSE sam.sam_view_column_name
            END file_column_alias
          ,spfc.spfc_col_datatype col_datatype
          ,spfc.spfc_col_size col_size
          ,spfc.spfc_date_format date_format
      FROM sdl_profiles sp
          ,sdl_attribute_mapping sam
          ,sdl_profile_file_columns spfc
          ,sdl_destination_header sdh
     WHERE sp.sp_id = sam.sam_sp_id
       AND sp.sp_id = spfc.spfc_sp_id
       AND sam.sam_sdh_id = sdh.sdh_id
       AND spfc.spfc_container = sdh.sdh_source_container
       AND spfc.spfc_col_name = sam.sam_file_attribute_name
       AND sp.sp_id = pi_profile_id
     ORDER BY DECODE(sp.sp_import_file_type, 'CSV', spfc.spfc_col_id, sam.sam_col_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_file_load_attribute_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profiles_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
   -- awlrs_sdl_util.validate_user_role;
    --
      OPEN po_cursor FOR
    SELECT sp.sp_id profile_id
          ,sp.sp_name profile_name
          ,sp.sp_import_file_type file_type
     FROM sdl_profiles sp
    WHERE EXISTS (SELECT 1
                    FROM sdl_user_profiles sup
                   WHERE sup.sup_sp_id = sp.sp_id
                     AND sup.sup_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID'))
    ORDER BY sp.sp_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profiles_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor
                       ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    -- awlrs_sdl_util.validate_user_role;r
    --
      OPEN po_cursor FOR
    SELECT sp.sp_id profile_id
          ,sp.sp_name profile_name
          ,sp.sp_desc profile_desc
          ,CASE WHEN sp.sp_loading_view_name IS NOT NULL
                THEN 'Y'
                ELSE 'N'
           END is_views_generated
          ,sp.sp_import_file_type source_file_type_code -- import_file_type_code
          ,hv1.hco_meaning source_file_type -- import_file_type

          ,sp.sp_date_modified last_used
          ,sp_attribute_edit_allowed attribute_edit_allowed
      FROM sdl_profiles sp
          ,hig_codes hv1
     WHERE sp.sp_import_file_type = hv1.hco_code
       AND hv1.hco_domain = 'SDL_FILE_TYPE'
       AND sp.sp_id = pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_profile(pi_name             IN  sdl_profiles.sp_name%TYPE
                          ,pi_desc             IN  sdl_profiles.sp_desc%TYPE
                          ,pi_file_type        IN  sdl_profiles.sp_import_file_type%TYPE
                          ,pi_attribute_edit_allowed IN sdl_profiles.sp_attribute_edit_allowed%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_exists NUMBER;
    ln_srid_number VARCHAR2(1) := 'Y';
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
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
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_profiles
                      WHERE sp_name = pi_name);
      --
      RAISE_APPLICATION_ERROR (-20036,
                              'Profile name ' || pi_name ||' is already exists.');
      --
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    --
    INSERT INTO sdl_profiles
        (sp_name
        ,sp_desc
        ,sp_import_file_type
        ,sp_destination_cs
        ,sp_attribute_edit_allowed)
    VALUES
        (pi_name
        ,pi_desc
        ,pi_file_type
        ,CASE WHEN ln_srid_number = 'Y' 
              THEN hig.get_sysopt('AWLMAPSRID')
              ELSE NULL
        END
        ,pi_attribute_edit_allowed);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_profile(pi_profile_id          IN  sdl_profiles.sp_id%TYPE
                          ,pi_old_name            IN  sdl_profiles.sp_name%TYPE
                          ,pi_new_name            IN  sdl_profiles.sp_name%TYPE
                          ,pi_old_desc            IN  sdl_profiles.sp_desc%TYPE
                          ,pi_new_desc            IN  sdl_profiles.sp_desc%TYPE
                          ,pi_old_file_type       IN  sdl_profiles.sp_import_file_type%TYPE
                          ,pi_new_file_type       IN  sdl_profiles.sp_import_file_type%TYPE
                          ,pi_old_attrib_edit_allowed IN sdl_profiles.sp_attribute_edit_allowed%TYPE
                          ,pi_new_attrib_edit_allowed IN sdl_profiles.sp_attribute_edit_allowed%TYPE
                          ,po_message_severity    OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT sys_refcursor)
  IS
    --
    lr_db_rec sdl_profiles%ROWTYPE;
    lv_upd    VARCHAR2(1) := 'N';
    ln_exists NUMBER;
    --
    PROCEDURE get_db_rec(pi_profile_id IN sdl_profiles.sp_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_profiles
       WHERE sp_id = pi_profile_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Profile does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    validate_notnull(pi_parameter_desc  => 'Profile Name'
                    ,pi_parameter_value => pi_new_name);
    --
    validate_notnull(pi_parameter_desc  => 'Import File Type'
                    ,pi_parameter_value => pi_new_file_type);
    --
    validate_notnull(pi_parameter_desc  => 'Attribute Edit Allowed'
                    ,pi_parameter_value => pi_new_attrib_edit_allowed);
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_profiles
                      WHERE sp_name = pi_new_name
                        AND pi_old_name != pi_new_name);
      --
      RAISE_APPLICATION_ERROR (-20037,
                              'Profile name ' || pi_new_name ||' is already exists.');
      --
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20024,
                               'Update not allowed. Profile ' || get_profile_name(pi_profile_id) || ' has active file data exists in the system');
    END IF;
    --
    get_db_rec(pi_profile_id => pi_profile_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_rec.sp_name != pi_old_name
      OR (lr_db_rec.sp_name IS NULL AND pi_old_name IS NOT NULL)
      OR (lr_db_rec.sp_name IS NOT NULL AND pi_old_name IS NULL)
      -- Profile Description
      OR (lr_db_rec.sp_desc != pi_old_desc)
      OR (lr_db_rec.sp_desc IS NULL AND pi_old_desc IS NOT NULL)
      OR (lr_db_rec.sp_desc IS NOT NULL AND pi_old_desc IS NULL)
      -- Import File Type
      OR (lr_db_rec.sp_import_file_type != pi_old_file_type)
      OR (lr_db_rec.sp_import_file_type IS NULL AND pi_old_file_type IS NOT NULL)
      OR (lr_db_rec.sp_import_file_type IS NOT NULL AND pi_old_file_type IS NULL)
      -- Attribute Edit Allowed
      OR (lr_db_rec.sp_attribute_edit_allowed != pi_old_attrib_edit_allowed)
      OR (lr_db_rec.sp_attribute_edit_allowed IS NULL AND pi_old_attrib_edit_allowed IS NOT NULL)
      OR (lr_db_rec.sp_attribute_edit_allowed IS NOT NULL AND pi_old_attrib_edit_allowed IS NULL)
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
      --
      IF pi_old_file_type != pi_new_file_type
       OR (pi_old_file_type IS NULL AND pi_new_file_type IS NOT NULL)
       OR (pi_old_file_type IS NOT NULL AND pi_new_file_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_attrib_edit_allowed != pi_new_attrib_edit_allowed
       OR (pi_old_attrib_edit_allowed IS NULL AND pi_new_attrib_edit_allowed IS NOT NULL)
       OR (pi_old_attrib_edit_allowed IS NOT NULL AND pi_new_attrib_edit_allowed IS NULL)
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
        UPDATE sdl_profiles
           SET sp_name = pi_new_name
              ,sp_desc = pi_new_desc
              ,sp_import_file_type = pi_new_file_type
              ,sp_attribute_edit_allowed = pi_new_attrib_edit_allowed
         WHERE sp_id = pi_profile_id;
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
  END update_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_profile(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                          ,po_message_severity  OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor    OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20025,
                               'Delete not allowed. Profile ' || get_profile_name(pi_profile_id) || ' has active file data exists in the system');
    END IF;
    --
    active_setup_exists(pi_profile_id);
    --
    DELETE sdl_spatial_review_levels
     WHERE ssrl_sp_id = pi_profile_id;
    --
    DELETE sdl_profile_file_columns
     WHERE spfc_sp_id = pi_profile_id;
    --
    DELETE sdl_profile_source_header
     WHERE spsh_sp_id = pi_profile_id;
    --
    DELETE sdl_datum_attribute_mapping
     WHERE sdam_profile_id = pi_profile_id;
    --
    DELETE sdl_profiles
     WHERE sp_id = pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_view_name(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
     SELECT sp_id profile_id
           ,sp_loading_view_name loading_view_name
      FROM sdl_profiles
     WHERE sp_id = pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_view_name;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_types_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
     SELECT nlt_id
           ,nlt_nt_type ||' - ' || nlt_descr network_type
      FROM nm_linear_types
     ORDER BY nlt_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_types_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_tol_search_unit_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor
                                      ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT n.un_unit_id
           ,n.un_unit_id ||' - ' || n.un_unit_name tolerance_search_unit
      FROM nm_units n
     WHERE n.un_domain_id = 1 -- Length Units
     ORDER BY n.un_unit_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_tol_search_unit_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profiles_list(po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
      OPEN po_cursor FOR
    SELECT sp.sp_id profile_id
          ,sp.sp_name profile_name
          ,sp.sp_desc profile_desc
          ,CASE WHEN sp.sp_loading_view_name IS NOT NULL
                THEN 'Y'
                ELSE 'N'
           END is_views_generated
          ,sp.sp_import_file_type source_file_type_code -- import_file_type_code
          ,hv1.hco_meaning source_file_type -- import_file_type
          ,sp.sp_date_modified last_used
          ,sp_attribute_edit_allowed attribute_edit_allowed
      FROM sdl_profiles sp
          ,hig_codes hv1
     WHERE sp.sp_import_file_type = hv1.hco_code
       AND hv1.hco_domain = 'SDL_FILE_TYPE'
     ORDER BY sp.sp_id DESC;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profiles_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_profiles_list(pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sp.sp_id profile_id
                                                   ,sp.sp_name profile_name
                                                   ,sp.sp_desc profile_desc
                                                   ,CASE WHEN sp.sp_loading_view_name IS NOT NULL
                                                         THEN ''Y''
                                                         ELSE ''N''
                                                    END is_views_generated
                                                   ,sp.sp_import_file_type source_file_type_code
                                                   ,hv1.hco_meaning source_file_type
                                                   ,sp.sp_date_modified last_used
                                                   ,sp_attribute_edit_allowed attribute_edit_allowed
                                               FROM sdl_profiles sp,
                                                    hig_codes hv1
                                              WHERE sp.sp_import_file_type = hv1.hco_code
                                                AND hv1.hco_domain = ''SDL_FILE_TYPE''';

    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT profile_id'
                                              ||' ,profile_name'
                                              ||' ,profile_desc'
                                              ||' ,is_views_generated'
                                              ||' ,source_file_type_code'
                                              ||' ,source_file_type'
                                              ||' ,last_used'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'profile_name'
                                ,pi_query_col    => 'sp_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'source_file_type'
                                ,pi_query_col    => 'hv1.hco_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'last_used'
                                ,pi_query_col    => 'sp_date_modified'
                                ,pi_datatype     => awlrs_util.c_date_col
                                ,pi_mask         => awlrs_util.c_date_mask
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'attribute_edit_allowed'
                                ,pi_query_col    => 'sp_attribute_edit_allowed'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sp.sp_id DESC')||') a)';
    --
    lv_cursor_sql := lv_cursor_sql||CHR(10)||' OFFSET '||pi_skip_n_rows||' ROWS ';
    --
    IF pi_pagesize IS NOT NULL
      THEN
        lv_cursor_sql := lv_cursor_sql||CHR(10)||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_profiles_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_users_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT hu.hus_user_id user_id
          ,hu.hus_username username
      FROM hig_users hu
     WHERE EXISTS (SELECT 1
                     FROM hig_user_roles hur
                    WHERE hur.hur_username = hu.hus_username
                      AND hur.hur_role IN ('SDL_ADMIN','SDL_USER')
                      AND hur.hur_start_date BETWEEN hu.hus_start_date AND NVL(hu.hus_end_date, hur.hur_start_date + 1))
    ORDER BY hu.hus_user_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_users_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_user_profiles_list(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor
                                  ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT sup.sup_id sup_id
          ,sup.sup_user_id user_id
          ,nm3user.get_username(sup.sup_user_id) username
          ,sup.sup_sp_id profile_id
          ,get_profile_name(sup.sup_sp_id) profile_name
          ,sup.sup_access_type access_type
          ,hv1.hco_meaning access_type_desc
     FROM sdl_user_profiles sup
         ,hig_codes hv1
    WHERE sup.sup_sp_id = pi_profile_id
      AND sup.sup_access_type = hv1.hco_code
      AND hv1.hco_domain = 'SDL_MAX_IMPORT_LEVEL'
     ORDER BY sup.sup_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_user_profiles_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_user_profiles_list(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sup.sup_id sup_id
                                                   ,sup.sup_user_id user_id
                                                   ,nm3user.get_username(sup.sup_user_id) username
                                                   ,sup.sup_sp_id profile_id
                                                   ,awlrs_sdl_profiles_api.get_profile_name(sup.sup_sp_id) profile_name
                                                   ,sup.sup_access_type access_type
                                                   ,hv1.hco_meaning access_type_desc
                                               FROM sdl_user_profiles sup
                                                   ,hig_codes hv1
                                              WHERE sup.sup_sp_id = :pi_profile_id
                                                AND sup.sup_access_type = hv1.hco_code
                                                AND hv1.hco_domain = ''SDL_MAX_IMPORT_LEVEL''';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT sup_id'
                                              ||' ,user_id'
                                              ||' ,username'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,access_type'
                                              ||' ,access_type_desc'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'username'
                                ,pi_query_col    => 'nm3user.get_username(sup.sup_user_id)'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'access_type_desc'
                                ,pi_query_col    => 'hv1.hco_meaning'
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
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sup.sup_id')||') a)';
    --
    lv_cursor_sql := lv_cursor_sql||CHR(10)||' OFFSET '||pi_skip_n_rows||' ROWS ';
    --
    IF pi_pagesize IS NOT NULL
    THEN
      lv_cursor_sql := lv_cursor_sql||CHR(10)||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql
    USING pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_user_profiles_list;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_user_profile(pi_user_id          IN  hig_users.hus_user_id%TYPE
                               ,pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                               ,pi_access_type      IN  sdl_user_profiles.sup_access_type%TYPE
             ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_exists NUMBER;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_user_profiles s
                      WHERE sup_sp_id = pi_profile_id
                        AND s.sup_user_id = pi_user_id);
      --
      RAISE_APPLICATION_ERROR (-20038,
                              'User ' || nm3user.get_username(pi_user_id) ||' is already assigned to the profile '|| get_profile_name(pi_profile_id) || '.');
      --
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    --
    INSERT INTO sdl_user_profiles
        (sup_user_id,
         sup_sp_id,
         sup_access_type)
    VALUES
        (pi_user_id,
         pi_profile_id,
         pi_access_type);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_user_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_user_profile(pi_profile_id         IN  sdl_profiles.sp_id%TYPE
                               ,pi_sup_id             IN  sdl_user_profiles.sup_id%TYPE
                               ,pi_old_user_id        IN  sdl_user_profiles.sup_user_id%TYPE
                               ,pi_new_user_id        IN  sdl_user_profiles.sup_user_id%TYPE
                               ,pi_old_access_type    IN  sdl_user_profiles.sup_access_type%TYPE
                               ,pi_new_access_type    IN  sdl_user_profiles.sup_access_type%TYPE
                               ,po_message_severity   OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor     OUT sys_refcursor)
  IS
    --
    lr_db_rec     sdl_user_profiles%ROWTYPE;
    lv_upd        VARCHAR2(1) := 'N';
    ln_username   hig_users.hus_username%TYPE;
    --
    PROCEDURE get_db_rec(pi_profile_id IN sdl_profiles.sp_id%TYPE
                        ,pi_sup_id IN sdl_user_profiles.sup_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_user_profiles
       WHERE sup_sp_id = pi_profile_id
         AND sup_id = pi_sup_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'User profile record does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    validate_notnull(pi_parameter_desc  => 'User'
                    ,pi_parameter_value => pi_new_user_id);
    --
    validate_notnull(pi_parameter_desc  => 'Access Type'
                    ,pi_parameter_value => pi_new_access_type);
    --
    SELECT hus.hus_username
      INTO ln_username
      FROM hig_users hus
     WHERE hus.hus_user_id = pi_old_user_id;
    --
    IF active_user_batch_exists(pi_profile_id, pi_old_user_id) THEN
      RAISE_APPLICATION_ERROR (-20026,
                               'Update not allowed. User ' || ln_username ||' is linked to the profile ' || get_profile_name(pi_profile_id) || ' and it has active file data exists in the system');
    END IF;
    --
    get_db_rec(pi_profile_id => pi_profile_id, pi_sup_id => pi_sup_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_rec.sup_user_id != pi_old_user_id
     OR (lr_db_rec.sup_user_id IS NULL AND pi_old_user_id IS NOT NULL)
     OR (lr_db_rec.sup_user_id IS NOT NULL AND pi_old_user_id IS NULL)
      -- Access Type
      OR (lr_db_rec.sup_access_type != pi_old_access_type)
      OR (lr_db_rec.sup_access_type IS NULL AND pi_old_access_type IS NOT NULL)
      OR (lr_db_rec.sup_access_type IS NOT NULL AND pi_old_access_type IS NULL)
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_user_id != pi_new_user_id
       OR (pi_old_user_id IS NULL AND pi_new_user_id IS NOT NULL)
       OR (pi_old_user_id IS NOT NULL AND pi_new_user_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_access_type != pi_new_access_type
       OR (pi_old_access_type IS NULL AND pi_new_access_type IS NOT NULL)
       OR (pi_old_access_type IS NOT NULL AND pi_new_access_type IS NULL)
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
        UPDATE sdl_user_profiles
           SET sup_user_id = pi_new_user_id
              ,sup_access_type = pi_new_access_type
         WHERE sup_sp_id = pi_profile_id
           AND sup_id = pi_sup_id;
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
  END update_user_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_user_profile(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                               ,pi_sup_id            IN  sdl_user_profiles.sup_id%TYPE
                               ,po_message_severity  OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor    OUT sys_refcursor)
  IS
    --
    ln_user_id  sdl_user_profiles.sup_user_id%TYPE;
    lv_username hig_users.hus_username%TYPE;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    SELECT sup.sup_user_id
          ,hus.hus_username
      INTO ln_user_id, lv_username
      FROM sdl_user_profiles sup
          ,hig_users hus
     WHERE sup.sup_user_id = hus.hus_user_id
       AND sup.sup_sp_id = pi_profile_id
       AND sup.sup_id = pi_sup_id;
    --
      IF active_user_batch_exists(pi_profile_id, ln_user_id) THEN
        RAISE_APPLICATION_ERROR (-20027,
                                 'Delete not allowed. User ' || lv_username ||' is linked to the profile ' || get_profile_name(pi_profile_id) || ' and it has active file data exists in the system');
      END IF;
    --
    DELETE sdl_user_profiles
     WHERE sup_sp_id = pi_profile_id
       AND sup_id = pi_sup_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_user_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_product_domain_codes(pi_domain           IN  hig_domains.hdo_domain%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT hc.hco_code
          ,hc.hco_code || ' - ' || hc.hco_meaning hco_meaning
          ,hc.hco_seq
      FROM hig_codes hc
          ,hig_domains hd
     WHERE hc.hco_domain = hd.hdo_domain
     --  AND hd.hdo_product = 'NET'
       AND hd.hdo_domain = pi_domain
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
  END get_product_domain_codes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_source_type_attributes(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor
                                      ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
      OPEN po_cursor FOR
    SELECT ssta.ssta_id attribute_id
          ,ssta.ssta_source_type source_type
          ,ssta.ssta_attribute attribute_name
          ,ssta.ssta_attribute_text attribute_text
          ,ssta.ssta_datatype attribute_datatype
          ,ssta.ssta_size attribute_size
          ,ssta.ssta_default attribute_default_value
          ,ssta.ssta_domain attribute_domain
          ,ssta.ssta_mandatory required
      FROM sdl_source_type_attribs ssta
     WHERE ssta.ssta_source_type = (SELECT sp.sp_import_file_type
                                      FROM sdl_profiles sp
                                     WHERE sp.sp_id = pi_profile_id)
     ORDER BY ssta.ssta_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_source_type_attributes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_source_header(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT spsh.spsh_id header_id
          ,spsh.spsh_sp_id profile_id
          ,spsh.spsh_ssta_id attribute_id
          ,ssta.ssta_attribute attribute_name
          ,spsh.spsh_attrib_value attribute_value
      FROM sdl_profile_source_header spsh
          ,sdl_source_type_attribs ssta
     WHERE spsh.spsh_ssta_id = ssta.ssta_id
       AND spsh.spsh_sp_id = pi_profile_id
     ORDER BY spsh.spsh_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_source_header;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE edit_profile_source_header(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                      ,pi_spsh_clob        IN  CLOB
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    CURSOR c_spsh IS
      WITH old_spsh_rec AS (
        SELECT spsh_id
              ,spsh_sp_id
              ,spsh_ssta_id
              ,spsh_attrib_value
          FROM DUAL,
               JSON_TABLE (pi_spsh_clob, '$.oldProfileSourceHeaders[*]'
                          COLUMNS (spsh_id PATH '$.HeaderId'
                                  ,spsh_sp_id PATH '$.ProfileId'
                                  ,spsh_ssta_id PATH '$.AttributeId'
                                  ,spsh_attrib_value PATH '$.AttributeValue'))),
      new_spsh_rec AS (
        SELECT spsh_id
              ,spsh_sp_id
              ,spsh_ssta_id
              ,spsh_attrib_value
          FROM DUAL,
               JSON_TABLE(pi_spsh_clob, '$.newProfileSourceHeaders[*]'
                          COLUMNS (spsh_id PATH '$.HeaderId'
                                  ,spsh_sp_id PATH '$.ProfileId'
                                  ,spsh_ssta_id PATH '$.AttributeId'
                                  ,spsh_attrib_value PATH '$.AttributeValue')))
      SELECT CASE
               WHEN o.spsh_id IS NOT NULL AND n.spsh_id IS NULL
               THEN 'D'
               WHEN o.spsh_id IS NULL AND n.spsh_id IS NULL
               THEN 'I'
               WHEN o.spsh_id = n.spsh_id
               THEN 'U'
               ELSE 'X'
             END t_action
             ,o.spsh_id             old_header_id
             ,o.spsh_sp_id          old_profile_id
             ,o.spsh_ssta_id        old_attribute_id
             ,o.spsh_attrib_value   old_attribute_value
             ,n.spsh_id             new_header_id
             ,n.spsh_sp_id          new_profile_id
             ,n.spsh_ssta_id        new_attribute_id
             ,n.spsh_attrib_value   new_attribute_value
         FROM old_spsh_rec o
              FULL OUTER JOIN new_spsh_rec n
              ON o.spsh_id = n.spsh_id
              AND NVL(o.spsh_sp_id, pi_profile_id) = NVL(n.spsh_sp_id, pi_profile_id)
         ORDER BY t_action, n.spsh_ssta_id, n.spsh_id;
    --
    lr_db_rec       sdl_profile_source_header%ROWTYPE;
    lv_upd          VARCHAR2(1) := 'N';
    -- lv_count        NUMBER(10);
    lv_no_changes   VARCHAR2(1) := 'N';
    lv_edit_found   VARCHAR2(1) := 'N';
    --

    PROCEDURE get_db_rec(p_spsh_id IN sdl_profile_source_header.spsh_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_profile_source_header
       WHERE spsh_id = p_spsh_id
         AND spsh_sp_id = pi_profile_id
         FOR UPDATE NOWAIT;
      --
      EXCEPTION
        WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Profile File Source Header does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    FOR r_spsh IN c_spsh
    LOOP
      --
      IF r_spsh.t_action = 'U'
      THEN
        --
        get_db_rec(p_spsh_id => r_spsh.old_header_id);
        /*
        ||Compare old with DB
        */
        IF lr_db_rec.spsh_ssta_id != r_spsh.old_attribute_id
          OR (lr_db_rec.spsh_ssta_id IS NULL AND r_spsh.old_attribute_id IS NOT NULL)
          OR (lr_db_rec.spsh_ssta_id IS NOT NULL AND r_spsh.old_attribute_id IS NULL)
          --
          OR (lr_db_rec.spsh_attrib_value != r_spsh.old_attribute_value)
          OR (lr_db_rec.spsh_attrib_value IS NULL AND r_spsh.old_attribute_value IS NOT NULL)
          OR (lr_db_rec.spsh_attrib_value IS NOT NULL AND r_spsh.old_attribute_value IS NULL)
          --
        THEN
          --Updated by another user
          /*hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 24);*/
          RAISE_APPLICATION_ERROR (-20001,
                                   'Record of attribute ' || r_spsh.old_attribute_id ||' has been changed by another user, please requery to see the changes');
        ELSE
          /*
          ||Compare old with New
          */
          IF r_spsh.old_attribute_id != r_spsh.new_attribute_id
            OR (r_spsh.old_attribute_id IS NULL AND r_spsh.new_attribute_id IS NOT NULL)
            OR (r_spsh.old_attribute_id IS NOT NULL AND r_spsh.new_attribute_id IS NULL)
          THEN
            lv_upd := 'Y';
          END IF;
          --
          IF r_spsh.old_attribute_value != r_spsh.new_attribute_value
            OR (r_spsh.old_attribute_value IS NULL AND r_spsh.new_attribute_value IS NOT NULL)
            OR (r_spsh.old_attribute_value IS NOT NULL AND r_spsh.new_attribute_value IS NULL)
          THEN
            lv_upd := 'Y';
          END IF;
          --
          IF lv_upd = 'N' AND lv_edit_found = 'N'
          THEN
            lv_no_changes := 'Y';
            /*  --There are no changes to be applied
                hig.raise_ner(pi_appl => 'AWLRS'
                             ,pi_id   => 25);*/
          ELSE
            --
            lv_edit_found := 'Y';
            --
            UPDATE sdl_profile_source_header
               SET spsh_ssta_id = r_spsh.new_attribute_id
                  ,spsh_attrib_value = r_spsh.new_attribute_value
             WHERE spsh_id = r_spsh.new_header_id
               AND spsh_sp_id = pi_profile_id;
            --
            lv_no_changes := 'N';
            --
          END IF;
        END IF;
      END IF;
      --
      IF r_spsh.t_action = 'I' THEN
      --
        lv_edit_found := 'Y';
        --
        INSERT INTO sdl_profile_source_header
                        (spsh_id
                        ,spsh_sp_id
                        ,spsh_ssta_id
                        ,spsh_attrib_value)
                 VALUES (spsh_id_seq.NEXTVAL
                        ,pi_profile_id
                        ,r_spsh.new_attribute_id
                        ,r_spsh.new_attribute_value);
      --
      END IF;
      --
      IF r_spsh.t_action = 'D' THEN
        -- ideally there would be either Insert OR Update of the Profile Source Header will be
        -- performed from UI however kept the Delete option here in case needed in the future
        --
        lv_edit_found := 'Y';
        --
        DELETE sdl_profile_source_header
        WHERE spsh_id = r_spsh.old_header_id;
        --
      END IF;

    END LOOP;
    --
    IF lv_no_changes = 'Y'
    THEN
      -- There are no changes to be applied
      hig.raise_ner(pi_appl => 'AWLRS'
                   ,pi_id   => 25);
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
  END edit_profile_source_header;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE csv_header_exists(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                             ,po_header            OUT VARCHAR2
                             ,po_message_severity  OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor    OUT sys_refcursor)
  IS
    --
    lv_header VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    BEGIN
      --
      SELECT spsh.spsh_attrib_value csv_header
        INTO lv_header
        FROM sdl_profile_source_header spsh
            ,sdl_source_type_attribs ssta
            ,sdl_profiles sp
       WHERE spsh.spsh_sp_id = sp.sp_id
         AND spsh.spsh_ssta_id = ssta.ssta_id
         AND ssta.ssta_source_type = sp.sp_import_file_type
         AND sp.sp_import_file_type = 'CSV'
         AND ssta.ssta_attribute = 'HEADERS'
         AND sp.sp_id = pi_profile_id;
      --
    EXCEPTION
      WHEN OTHERS THEN
        lv_header := 'N';
    END;
    --
    po_header := lv_header;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END csv_header_exists;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE source_description_active(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                                     ,po_active            OUT VARCHAR2
                                     ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor    OUT sys_refcursor)
  IS
    --
    lv_active VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    BEGIN
      --
      SELECT 'Y'
        INTO lv_active
        FROM sdl_profiles sp
       WHERE sp.sp_id = pi_profile_id
         AND ((EXISTS (SELECT 1
                         FROM sdl_source_type_attribs spsh
                        WHERE spsh.ssta_source_type = sp.sp_import_file_type)
                AND EXISTS (SELECT 1
                              FROM sdl_profile_source_header spsh
                              WHERE spsh.spsh_sp_id = sp.sp_id))
              OR
                NOT EXISTS (SELECT 1
                              FROM sdl_source_type_attribs spsh
                             WHERE spsh.ssta_source_type = sp.sp_import_file_type));
    EXCEPTION
      WHEN OTHERS THEN
        lv_active := 'N';
    END;
    --
    po_active := lv_active;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END source_description_active;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_file_columns(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT spfc.spfc_id spfc_id
          ,spfc.spfc_sp_id profile_id
          ,spfc.spfc_col_id position
          ,spfc.spfc_col_name column_name
          ,spfc.spfc_col_datatype column_type
          ,spfc.spfc_col_size column_size
          ,spfc.spfc_container container
          ,spfc.spfc_mandatory required
          ,spfc.spfc_date_format date_format
      FROM sdl_profile_file_columns spfc
     WHERE spfc.spfc_sp_id = pi_profile_id
     ORDER BY spfc.spfc_col_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_file_columns;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_profile_file_columns(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT spfc.spfc_id spfc_id
                                                   ,spfc.spfc_sp_id profile_id
                                                   ,spfc.spfc_col_id position
                                                   ,spfc.spfc_col_name column_name
                                                   ,spfc.spfc_col_datatype column_type
                                                   ,spfc.spfc_col_size column_size
                                                   ,spfc.spfc_container container
                                                   ,spfc.spfc_mandatory required
                                                   ,spfc.spfc_date_format date_format
                                               FROM sdl_profile_file_columns spfc
                                              WHERE spfc.spfc_sp_id = :pi_profile_id';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT spfc_id'
                                              ||' ,profile_id'
                                              ||' ,position'
                                              ||' ,column_name'
                                              ||' ,column_type'
                                              ||' ,column_size'
                                              ||' ,container'
                                              ||' ,required'
                                              ||' ,date_format'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'column_name'
                                ,pi_query_col    => 'spfc.spfc_col_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'column_type'
                                ,pi_query_col    => 'spfc.spfc_col_datatype'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'container'
                                ,pi_query_col    => 'spfc.spfc_container'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'required'
                                ,pi_query_col    => 'spfc.spfc_mandatory'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'date_format'
                                ,pi_query_col    => 'spfc.spfc_date_format'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'spfc.spfc_col_id')||') a)';
    --
    lv_cursor_sql := lv_cursor_sql||CHR(10)||' OFFSET '||pi_skip_n_rows||' ROWS ';
    --
    IF pi_pagesize IS NOT NULL
    THEN
      lv_cursor_sql := lv_cursor_sql||CHR(10)||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql
    USING pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_profile_file_columns;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_profile_file_columns(pi_profile_id         IN  sdl_profiles.sp_id%TYPE
                                       ,pi_col_id             IN  sdl_profile_file_columns.spfc_col_id%TYPE
                                       ,pi_col_name           IN  sdl_profile_file_columns.spfc_col_name%TYPE
                                       ,pi_col_datatype       IN  sdl_profile_file_columns.spfc_col_datatype%TYPE
                                       ,pi_col_size           IN  sdl_profile_file_columns.spfc_col_size%TYPE
                                       ,pi_container          IN  sdl_profile_file_columns.spfc_container%TYPE
                                       ,pi_mandatory          IN  sdl_profile_file_columns.spfc_mandatory%TYPE
                                       ,pi_date_format        IN  sdl_profile_file_columns.spfc_date_format%TYPE)
  IS
    --
  BEGIN
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20033,
                               'Insert not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active submission exists.');
    END IF;
    --
    INSERT INTO sdl_profile_file_columns
                    (spfc_id
                    ,spfc_sp_id
                    ,spfc_col_id
                    ,spfc_col_name
                    ,spfc_col_datatype
                    ,spfc_col_size
                    ,spfc_container
                    ,spfc_mandatory
                    ,spfc_date_format)
             VALUES (spfc_id_seq.NEXTVAL
                    ,pi_profile_id
                    ,pi_col_id
                    ,pi_col_name
                    ,pi_col_datatype
                    ,pi_col_size
                    ,UPPER(pi_container)
                    ,NVL(pi_mandatory, 'N')
                    ,pi_date_format);
    --
  END create_profile_file_columns;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_profile_file_columns(pi_profile_id       IN sdl_profiles.sp_id%TYPE
                                       ,pi_spfc_id          IN sdl_profile_file_columns.spfc_id%TYPE
                                       ,pi_old_col_id       IN sdl_profile_file_columns.spfc_col_id%TYPE
                                       ,pi_new_col_id       IN sdl_profile_file_columns.spfc_col_id%TYPE
                                       ,pi_old_col_name     IN sdl_profile_file_columns.spfc_col_name%TYPE
                                       ,pi_new_col_name     IN sdl_profile_file_columns.spfc_col_name%TYPE
                                       ,pi_old_col_datatype IN sdl_profile_file_columns.spfc_col_datatype%TYPE
                                       ,pi_new_col_datatype IN sdl_profile_file_columns.spfc_col_datatype%TYPE
                                       ,pi_old_col_size     IN sdl_profile_file_columns.spfc_col_size%TYPE
                                       ,pi_new_col_size     IN sdl_profile_file_columns.spfc_col_size%TYPE
                                       ,pi_old_container    IN sdl_profile_file_columns.spfc_container%TYPE
                                       ,pi_new_container    IN sdl_profile_file_columns.spfc_container%TYPE
                                       ,pi_old_mandatory    IN sdl_profile_file_columns.spfc_mandatory%TYPE
                                       ,pi_new_mandatory    IN sdl_profile_file_columns.spfc_mandatory%TYPE
                                       ,pi_old_date_format  IN sdl_profile_file_columns.spfc_date_format%TYPE
                                       ,pi_new_date_format  IN sdl_profile_file_columns.spfc_date_format%TYPE)
  IS
    --
    lr_db_rec       sdl_profile_file_columns%ROWTYPE;
    lv_upd          VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(p_spfc_id IN sdl_profile_file_columns.spfc_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_profile_file_columns
       WHERE spfc_id = p_spfc_id
         AND spfc_sp_id = pi_profile_id
         FOR UPDATE NOWAIT;
      --
      EXCEPTION
        WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Profile File Column does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    validate_notnull(pi_parameter_desc  => 'Column Name'
                    ,pi_parameter_value => pi_new_col_name);
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20028,
                               'Update not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active submission exists.');
    END IF;
    --
    get_db_rec(p_spfc_id => pi_spfc_id);
    --
    /*
    ||Compare old with DB
    */
   IF lr_db_rec.spfc_col_id != pi_old_col_id
       OR (lr_db_rec.spfc_col_id IS NULL AND pi_old_col_id IS NOT NULL)
       OR (lr_db_rec.spfc_col_id IS NOT NULL AND pi_old_col_id IS NULL)
       --
       OR(lr_db_rec.spfc_col_name != pi_old_col_name)
       OR(lr_db_rec.spfc_col_name IS NULL AND pi_old_col_name IS NOT NULL)
       OR(lr_db_rec.spfc_col_name IS NOT NULL AND pi_old_col_name IS NULL)
       --
       OR(lr_db_rec.spfc_col_datatype != pi_old_col_datatype)
       OR(lr_db_rec.spfc_col_datatype IS NULL AND pi_old_col_datatype IS NOT NULL)
       OR(lr_db_rec.spfc_col_datatype IS NOT NULL AND pi_old_col_datatype IS NULL)
       --
       OR(lr_db_rec.spfc_col_size != pi_old_col_size)
       OR(lr_db_rec.spfc_col_size IS NULL AND pi_old_col_size IS NOT NULL)
       OR(lr_db_rec.spfc_col_size IS NOT NULL AND pi_old_col_size IS NULL)
       --
       OR(lr_db_rec.spfc_container != pi_old_container)
       OR(lr_db_rec.spfc_container IS NULL AND pi_old_container IS NOT NULL)
       OR(lr_db_rec.spfc_container IS NOT NULL AND pi_old_container IS NULL)
       --
       OR(lr_db_rec.spfc_mandatory != pi_old_mandatory)
       OR(lr_db_rec.spfc_mandatory IS NULL AND pi_old_mandatory IS NOT NULL)
       OR(lr_db_rec.spfc_mandatory IS NOT NULL AND pi_old_mandatory IS NULL)
       --
       OR(lr_db_rec.spfc_date_format != pi_old_date_format)
       OR(lr_db_rec.spfc_date_format IS NULL AND pi_old_date_format IS NOT NULL)
       OR(lr_db_rec.spfc_date_format IS NOT NULL AND pi_old_date_format IS NULL)
       --
      THEN
      --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_col_id != pi_new_col_id
         OR (pi_old_col_id IS NULL AND pi_new_col_id IS NOT NULL)
         OR (pi_old_col_id IS NOT NULL AND pi_new_col_id IS NULL)
      THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_col_name != pi_new_col_name
         OR (pi_old_col_name IS NULL AND pi_new_col_name IS NOT NULL)
         OR (pi_old_col_name IS NOT NULL AND pi_new_col_name IS NULL)
      THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_col_datatype != pi_new_col_datatype
         OR (pi_old_col_datatype IS NULL AND pi_new_col_datatype IS NOT NULL)
         OR (pi_old_col_datatype IS NOT NULL AND pi_new_col_datatype IS NULL)
      THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_col_size != pi_new_col_size
         OR (pi_old_col_size IS NULL AND pi_new_col_size IS NOT NULL)
         OR (pi_old_col_size IS NOT NULL AND pi_new_col_size IS NULL)
      THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_container != pi_new_container
         OR (pi_old_container IS NULL AND pi_new_container IS NOT NULL)
         OR (pi_old_container IS NOT NULL AND pi_new_container IS NULL)
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
      IF pi_old_date_format != pi_new_date_format
         OR (pi_old_date_format IS NULL AND pi_new_date_format IS NOT NULL)
         OR (pi_old_date_format IS NOT NULL AND pi_new_date_format IS NULL)
      THEN
         lv_upd := 'Y';
      END IF;
      --
      IF lv_upd = 'N'
      THEN
        --There are no changes to be applied
        /*hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 25);*/
        NULL; -- Only updated records should be sent from UI
      ELSE
      --
        UPDATE sdl_profile_file_columns
           SET spfc_col_id = pi_new_col_id
              ,spfc_col_name = pi_new_col_name
              ,spfc_col_datatype = pi_new_col_datatype
              ,spfc_col_size = pi_new_col_size
              ,spfc_container = pi_new_container
              ,spfc_mandatory = pi_new_mandatory
              ,spfc_date_format = pi_new_date_format
         WHERE spfc_id = pi_spfc_id
           AND spfc_sp_id = pi_profile_id;
      --
      END IF;
    END IF;
    --
  END update_profile_file_columns;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_profile_file_columns(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                                       ,pi_spfc_id           IN  sdl_profile_file_columns.spfc_id%TYPE)
  IS
  --
    CURSOR c_spfc IS
    SELECT ROWNUM col_id, spfc_col_id, spfc_id
     FROM (
         SELECT spfc_col_id, spfc_id
           FROM sdl_profile_file_columns
          WHERE spfc_sp_id = pi_profile_id
            AND spfc_sp_id NOT IN (SELECT sp_id
                                     FROM sdl_profiles
                                    WHERE sp_import_file_type = 'CSV')
           ORDER BY spfc_col_id);
  --
  BEGIN
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20029,
                               'Delete not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active submission exists.');
    END IF;
    --
    IF check_mapping_exists(pi_profile_id, pi_spfc_id) THEN
      RAISE_APPLICATION_ERROR (-20059,
                               'Delete not allowed. Source column has been used as an attribute mapping.');
    END IF;
    --
    DELETE sdl_profile_file_columns
     WHERE spfc_sp_id = pi_profile_id
       AND spfc_id = pi_spfc_id;
    --
    -- Re-sequence the col_ids for the profile file columns of other than CSV file type (Shapefile, file Geodatabase)
    FOR r_spfc IN c_spfc
    LOOP
      UPDATE sdl_profile_file_columns
         SET spfc_col_id  = r_spfc.col_id
       WHERE spfc_id = r_spfc.spfc_id
         AND spfc_sp_id = pi_profile_id;
    END LOOP;
    --
  END delete_profile_file_columns;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE edit_profile_source_columns(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                       ,pi_old_file_cols    IN  CLOB
                                       ,pi_new_file_cols    IN  CLOB
                                       ,pi_del_file_col_ids IN  awlrs_sdl_util.spfc_id_tab
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor)

  IS
    --
    CURSOR c_spfc IS
      WITH old_spfc_rec AS (
        SELECT spfc_id
              ,spfc_sp_id
              ,spfc_col_id
              ,spfc_col_name
              ,spfc_col_datatype
              ,spfc_col_size
              ,spfc_container
              ,spfc_mandatory
              ,spfc_date_format
          FROM DUAL,
               JSON_TABLE (pi_old_file_cols, '$.oldFileCols[*]'
                          COLUMNS (spfc_id PATH '$.SpfcId'
                                  ,spfc_sp_id PATH '$.ProfileId'
                                  ,spfc_col_id PATH '$.Position'
                                  ,spfc_col_name PATH '$.ColumnName'
                                  ,spfc_col_datatype PATH '$.ColumnType'
                                  ,spfc_col_size PATH '$.ColumnSize'
                                  ,spfc_container PATH '$.Container'
                                  ,spfc_mandatory PATH '$.Required'
                                  ,spfc_date_format PATH '$.DateFormat'))),
           new_spfc_rec AS (
        SELECT spfc_id
              ,spfc_sp_id
              ,spfc_col_id
              ,spfc_col_name
              ,spfc_col_datatype
              ,spfc_col_size
              ,spfc_container
              ,spfc_mandatory
              ,spfc_date_format
          FROM DUAL,
               JSON_TABLE(pi_new_file_cols, '$.newFileCols[*]'
                          COLUMNS (spfc_id PATH '$.SpfcId'
                                  ,spfc_sp_id PATH '$.ProfileId'
                                  ,spfc_col_id PATH '$.Position'
                                  ,spfc_col_name PATH '$.ColumnName'
                                  ,spfc_col_datatype PATH '$.ColumnType'
                                  ,spfc_col_size PATH '$.ColumnSize'
                                  ,spfc_container PATH '$.Container'
                                  ,spfc_mandatory PATH '$.Required'
                                  ,spfc_date_format PATH '$.DateFormat')))
      SELECT CASE WHEN o.spfc_id IS NULL AND n.spfc_id IS NULL
                  THEN 'I'
                  WHEN o.spfc_id = n.spfc_id
                  THEN 'U'
          ELSE 'X'
              END t_action
             ,o.spfc_id             old_spfc_id
             ,o.spfc_sp_id          old_spfc_sp_id
             ,o.spfc_col_id         old_spfc_col_id
             ,o.spfc_col_name       old_spfc_col_name
             ,o.spfc_col_datatype   old_spfc_col_datatype
             ,o.spfc_col_size       old_spfc_col_size
             ,o.spfc_container      old_spfc_container
             ,o.spfc_mandatory      old_spfc_mandatory
             ,o.spfc_date_format    old_spfc_date_format
             ,n.spfc_id             new_spfc_id
             ,n.spfc_sp_id          new_spfc_sp_id
             ,n.spfc_col_id         new_spfc_col_id
             ,n.spfc_col_name       new_spfc_col_name
             ,n.spfc_col_datatype   new_spfc_col_datatype
             ,n.spfc_col_size       new_spfc_col_size
             ,n.spfc_container      new_spfc_container
             ,n.spfc_mandatory      new_spfc_mandatory
             ,n.spfc_date_format    new_spfc_date_format
         FROM old_spfc_rec o
              FULL OUTER JOIN new_spfc_rec n
              ON NVL(o.spfc_id,-1) = NVL(n.spfc_id,-1)
              AND NVL(o.spfc_sp_id, pi_profile_id) = NVL(n.spfc_sp_id, pi_profile_id)
         ORDER BY t_action, TO_NUMBER(o.spfc_col_id), TO_NUMBER(n.spfc_col_id);
    --
  BEGIN
    --
    FOR i IN 1..pi_del_file_col_ids.COUNT
    LOOP
      --
      delete_profile_file_columns(pi_profile_id => pi_profile_id
                                 ,pi_spfc_id => pi_del_file_col_ids(i));
      --
    END LOOP;
    --
    FOR r_spfc IN c_spfc
    LOOP
      --
      IF r_spfc.t_action = 'U' THEN
        --REPLACE(UPPER(pi_container), ' ', '_')
        update_profile_file_columns(pi_profile_id => pi_profile_id
                                   ,pi_spfc_id => r_spfc.new_spfc_id
                                   ,pi_old_col_id => r_spfc.old_spfc_col_id
                                   ,pi_new_col_id => r_spfc.new_spfc_col_id
                                   ,pi_old_col_name => r_spfc.old_spfc_col_name
                                   ,pi_new_col_name => REPLACE(UPPER(r_spfc.new_spfc_col_name), ' ', '_')
                                   ,pi_old_col_datatype => r_spfc.old_spfc_col_datatype
                                   ,pi_new_col_datatype => r_spfc.new_spfc_col_datatype
                                   ,pi_old_col_size => r_spfc.old_spfc_col_size
                                   ,pi_new_col_size => r_spfc.new_spfc_col_size
                                   ,pi_old_container => r_spfc.old_spfc_container
                                   ,pi_new_container => REPLACE(UPPER(r_spfc.new_spfc_container), ' ', '_')
                                   ,pi_old_mandatory => r_spfc.old_spfc_mandatory
                                   ,pi_new_mandatory => r_spfc.new_spfc_mandatory
                                   ,pi_old_date_format => r_spfc.old_spfc_date_format
                                   ,pi_new_date_format => r_spfc.new_spfc_date_format);
        --
      END IF;
      --
      IF r_spfc.t_action = 'I' THEN
        --
        create_profile_file_columns(pi_profile_id => pi_profile_id
                                   ,pi_col_id => r_spfc.new_spfc_col_id
                                   ,pi_col_name => REPLACE(UPPER(r_spfc.new_spfc_col_name), ' ', '_')
                                   ,pi_col_datatype => r_spfc.new_spfc_col_datatype
                                   ,pi_col_size => r_spfc.new_spfc_col_size
                                   ,pi_container => REPLACE(UPPER(r_spfc.new_spfc_container), ' ', '_')
                                   ,pi_mandatory => r_spfc.new_spfc_mandatory
                                   ,pi_date_format => r_spfc.new_spfc_date_format);
        --
      END IF;
      --
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
  END edit_profile_source_columns;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_destination_type_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                       ,pi_dest_type_select IN  VARCHAR2 DEFAULT 'N'
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor
                                       ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT destination_type
          ,destination_descr
          ,type
          ,destination_meaning
          ,destination_table
          ,validation_procedure
          ,load_procedure
          ,nld_id
          ,nlt_id
      FROM (SELECT network_type destination_type
                  ,network_descr destination_descr
                  ,type
                  ,network_meaning destination_meaning
                  ,'' destination_table
                  ,'' validation_procedure
                  ,'' load_procedure
                  ,NULL nld_id
                  ,nlt_id
              FROM (SELECT nlt.nlt_id
                          ,nlt.nlt_nt_type network_type
                          ,nlt.nlt_descr network_descr
                          ,CASE WHEN nlt.nlt_g_i_d IN ('G','D')
                                THEN 'NETWORK'
                                WHEN nlt.nlt_g_i_d = 'I'
                                THEN 'ASSET'
                            END type
                           ,nlt.nlt_nt_type ||' - '|| nlt.nlt_descr network_meaning
                       FROM nm_linear_types nlt
                      ORDER BY nlt.nlt_id)
           UNION
          SELECT asset_type destination_type
                ,asset_descr destination_descr
                ,type asset_route
                ,asset_meaning destination_meaning
                ,asset_table_name destination_table
                ,validation_procedure
                ,load_procedure
                ,nld_id
                ,NULL nlt_id
            FROM (SELECT nit.nit_inv_type asset_type
                        ,nit.nit_descr asset_descr
                        ,'ASSET' type
                        ,nit.nit_inv_type ||' - '|| nit.nit_descr asset_meaning
                        ,NVL(nit.nit_view_name, nit.nit_table_name) asset_table_name
                        ,UPPER(nld.nld_validation_proc) validation_procedure
                        ,UPPER(nld.nld_insert_proc) load_procedure
                        ,nld.nld_id nld_id
                    FROM nm_inv_types nit
                        ,nm_load_destinations nld
                   WHERE nld.nld_table_name = NVL(nit.nit_view_name, nit.nit_table_name)
                   ORDER BY nit.nit_inv_type)
         ) dest
     WHERE type = CASE WHEN pi_dest_type_select = 'N'
                       THEN 'NETWORK'
                       WHEN pi_dest_type_select = 'A'
                       THEN 'ASSET'
                       ELSE 'NONE'
                   END
       AND NOT EXISTS (SELECT 1
                           FROM sdl_destination_header sdh
                          WHERE sdh.sdh_destination_type = dest.destination_type
                            AND sdh.sdh_sp_id = pi_profile_id
                            AND ((sdh.sdh_nlt_id = dest.nlt_id AND pi_dest_type_select = 'N')
                              OR pi_dest_type_select = 'A' ))
     ORDER BY DECODE(type, 'NETWORK', 1, 'ASSET', 2, 3);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_destination_type_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_source_container_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor
                                       ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
     SELECT DISTINCT spfc_container source_container
       FROM sdl_profile_file_columns
      WHERE spfc_sp_id = pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_source_container_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_destination_location_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                                           ,po_message_cursor   OUT sys_refcursor
                                           ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT uo.object_name destination_location
          ,nld.nld_id nld_id
          ,UPPER(nld.nld_validation_proc) validation_procedure
          ,UPPER(nld.nld_insert_proc) load_procedure
      FROM nm_load_destinations nld
          ,user_objects uo
     WHERE nld.nld_table_name = uo.object_name
       AND uo.object_type = 'VIEW'
       AND uo.object_name LIKE 'V_LOAD%'
     ORDER BY nld.nld_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_destination_location_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_destination_table_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT nld.nld_table_name destination_table
          ,nld.nld_id nld_id
          ,UPPER(nld.nld_validation_proc) validation_procedure
          ,UPPER(nld.nld_insert_proc) load_procedure
      FROM nm_load_destinations nld
     ORDER BY nld.nld_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_destination_table_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_destination_types(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT sdh.sdh_id dest_header_id
          ,sdh.sdh_sp_id profile_id
          ,sdh.sdh_type sdh_type
          ,sdh.sdh_destination_type destination_type
          ,dest.network_meaning destination_type_descr
          ,sdh.sdh_nlt_id nlt_id
          ,sdh.sdh_source_container source_container
          ,sdh.sdh_destination_location is_destination_location
          ,sdh.sdh_nld_id load_destination_id
          ,sdh.sdh_table_name destination_table
          ,sdh.sdh_insert_procedure load_procedure
          ,sdh.sdh_validation_procedure validation_procedure
          ,CASE WHEN sdh.sdh_type = 'A' THEN
                    'ASSET' 
                WHEN sdh.sdh_type = 'N' THEN 
                    'NETWORK'
                ELSE 'OTHER'
           END network_or_asset
     FROM sdl_destination_header sdh
          ,nm_load_destinations nld
          ,(SELECT nlt_id
                  ,network_type
                  ,network_descr
                  ,network_meaning
              FROM (
                  SELECT NULL nlt_id
                        ,nit.nit_inv_type network_type
                        ,nit.nit_descr network_descr
                        ,nit.nit_inv_type ||' - '|| nit.nit_descr network_meaning
                    FROM nm_inv_types nit
                        ,nm_load_destinations nld
                   WHERE nld.nld_table_name = NVL(nit.nit_view_name, nit.nit_table_name)
                   UNION ALL
                    SELECT nlt.nlt_id
                          ,nlt.nlt_nt_type network_type
                          ,nlt.nlt_descr network_descr
                          ,nlt.nlt_nt_type ||' - '|| nlt.nlt_descr network_meaning
                       FROM nm_linear_types nlt)
                     ) dest
     WHERE sdh.sdh_nld_id = nld.nld_id(+)
       AND sdh.sdh_sp_id = pi_profile_id
       AND dest.network_type = sdh.sdh_destination_type
       AND NVL(dest.nlt_id,-1) = NVL(sdh.sdh_nlt_id,-1)
       AND sdh.sdh_destination_location = 'N'
     ORDER BY sdh.sdh_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_destination_types;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_destination_location(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                            ,pi_destination_type IN  sdl_destination_header.sdh_destination_type%TYPE
                                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                                            ,po_message_cursor   OUT sys_refcursor
                                            ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT sdh.sdh_id dest_header_id
          ,sdh.sdh_sp_id profile_id
          ,sdh.sdh_destination_type destination_type
          ,sdh.sdh_source_container source_container
          ,sdh.sdh_destination_location is_destination_location
          ,sdh.sdh_nld_id load_destination_id
          ,sdh.sdh_table_name destination_location
          ,sdh.sdh_insert_procedure load_procedure
          ,sdh.sdh_validation_procedure validation_procedure
      FROM sdl_destination_header sdh
          ,nm_load_destinations nld
     WHERE sdh.sdh_nld_id = nld.nld_id(+)
       AND sdh.sdh_sp_id = pi_profile_id
       AND sdh.sdh_destination_type = pi_destination_type
       AND sdh.sdh_destination_location = 'Y';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_destination_location;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_destination_type(pi_profile_id           IN  sdl_profiles.sp_id%TYPE
                                   ,pi_sdh_type             IN  sdl_destination_header.sdh_type%TYPE
                                   ,pi_destination_type     IN  sdl_destination_header.sdh_destination_type%TYPE
                                   ,pi_nlt_id               IN  sdl_destination_header.sdh_nlt_id%TYPE
                                   ,pi_source_container     IN  sdl_destination_header.sdh_source_container%TYPE
                                   ,pi_load_destination_id  IN  sdl_destination_header.sdh_nld_id%TYPE
                                   ,pi_table_name           IN  sdl_destination_header.sdh_table_name%TYPE
                                   ,pi_load_procedure       IN  sdl_destination_header.sdh_insert_procedure%TYPE
                                   ,pi_validation_procedure IN  sdl_destination_header.sdh_validation_procedure%TYPE
                                   ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor       OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    INSERT INTO sdl_destination_header
        (sdh_sp_id
        ,sdh_type
        ,sdh_destination_type
        ,sdh_nlt_id
        ,sdh_source_container
        ,sdh_destination_location
        ,sdh_nld_id
        ,sdh_table_name
        ,sdh_insert_procedure
        ,sdh_validation_procedure)
    VALUES
        (pi_profile_id
        ,pi_sdh_type  -- 'N' - Network , 'A' - Asset
        ,pi_destination_type
        ,pi_nlt_id
        ,pi_source_container
        ,'N'
        ,pi_load_destination_id
        ,pi_table_name
        ,pi_load_procedure
        ,pi_validation_procedure);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_destination_type;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_destination_location(pi_profile_id           IN  sdl_profiles.sp_id%TYPE
                                       ,pi_destination_type     IN  sdl_destination_header.sdh_destination_type%TYPE
                                       ,pi_source_container     IN  sdl_destination_header.sdh_source_container%TYPE
                                       ,pi_load_destination_id  IN  sdl_destination_header.sdh_nld_id%TYPE
                                       ,pi_table_name           IN  sdl_destination_header.sdh_table_name%TYPE
                                       ,pi_load_procedure       IN  sdl_destination_header.sdh_insert_procedure%TYPE
                                       ,pi_validation_procedure IN  sdl_destination_header.sdh_validation_procedure%TYPE
                                       ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor       OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    INSERT INTO sdl_destination_header
        (sdh_sp_id
        ,sdh_type
        ,sdh_destination_type
        ,sdh_nlt_id
        ,sdh_source_container
        ,sdh_destination_location
        ,sdh_nld_id
        ,sdh_table_name
        ,sdh_insert_procedure
        ,sdh_validation_procedure)
    VALUES
        (pi_profile_id
        ,NULL -- location entry record for asset type header (CSV,...)
        ,pi_destination_type
        ,NULL
        ,pi_source_container
        ,'Y'
        ,pi_load_destination_id
        ,pi_table_name
        ,pi_load_procedure
        ,pi_validation_procedure);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_destination_location;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_destination_type(pi_dest_header_id           IN  sdl_destination_header.sdh_id%TYPE
                                   ,pi_profile_id               IN  sdl_profiles.sp_id%TYPE
                                   ,pi_old_source_container     IN  sdl_destination_header.sdh_source_container%TYPE
                                   ,pi_new_source_container     IN  sdl_destination_header.sdh_source_container%TYPE
                                   ,pi_old_load_destination_id  IN  sdl_destination_header.sdh_nld_id%TYPE
                                   ,pi_new_load_destination_id  IN  sdl_destination_header.sdh_nld_id%TYPE
                                   ,pi_old_table_name           IN  sdl_destination_header.sdh_table_name%TYPE
                                   ,pi_new_table_name           IN  sdl_destination_header.sdh_table_name%TYPE
                                   ,pi_old_load_procedure       IN  sdl_destination_header.sdh_insert_procedure%TYPE
                                   ,pi_new_load_procedure       IN  sdl_destination_header.sdh_insert_procedure%TYPE
                                   ,pi_old_validation_procedure IN  sdl_destination_header.sdh_validation_procedure%TYPE
                                   ,pi_new_validation_procedure IN  sdl_destination_header.sdh_validation_procedure%TYPE
                                   ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor           OUT sys_refcursor)
  IS
    --
    lr_db_rec     sdl_destination_header%ROWTYPE;
    lv_upd        VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_dest_header_id IN sdl_destination_header.sdh_id%TYPE
                        ,pi_profile_id     IN sdl_profiles.sp_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_destination_header
       WHERE sdh_id = pi_dest_header_id
         AND sdh_sp_id = pi_profile_id
         AND sdh_destination_location = 'N'
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Destination Header Type record does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Source Container'
                    ,pi_parameter_value => pi_new_source_container);
    --
    get_db_rec(pi_dest_header_id => pi_dest_header_id, pi_profile_id => pi_profile_id);
    --
    /*
    ||Compare old with DB
    */
    IF (lr_db_rec.sdh_source_container != pi_old_source_container)
      OR (lr_db_rec.sdh_source_container IS NULL AND pi_old_source_container IS NOT NULL)
      OR (lr_db_rec.sdh_source_container IS NOT NULL AND pi_old_source_container IS NULL)
      --
      OR (lr_db_rec.sdh_nld_id != pi_old_load_destination_id)
      OR (lr_db_rec.sdh_nld_id IS NULL AND pi_old_load_destination_id IS NOT NULL)
      OR (lr_db_rec.sdh_nld_id IS NOT NULL AND pi_old_load_destination_id IS NULL)
      --
      OR (lr_db_rec.sdh_table_name != pi_old_table_name)
      OR (lr_db_rec.sdh_table_name IS NULL AND pi_old_table_name IS NOT NULL)
      OR (lr_db_rec.sdh_table_name IS NOT NULL AND pi_old_table_name IS NULL)
      --
      OR (lr_db_rec.sdh_insert_procedure != pi_old_load_procedure)
      OR (lr_db_rec.sdh_insert_procedure IS NULL AND pi_old_load_procedure IS NOT NULL)
      OR (lr_db_rec.sdh_insert_procedure IS NOT NULL AND pi_old_load_procedure IS NULL)
      --
      OR (lr_db_rec.sdh_validation_procedure != pi_old_validation_procedure)
      OR (lr_db_rec.sdh_validation_procedure IS NULL AND pi_old_validation_procedure IS NOT NULL)
      OR (lr_db_rec.sdh_validation_procedure IS NOT NULL AND pi_old_validation_procedure IS NULL)
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_source_container != pi_new_source_container
       OR (pi_old_source_container IS NULL AND pi_new_source_container IS NOT NULL)
       OR (pi_old_source_container IS NOT NULL AND pi_new_source_container IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_load_destination_id != pi_new_load_destination_id
       OR (pi_old_load_destination_id IS NULL AND pi_new_load_destination_id IS NOT NULL)
       OR (pi_old_load_destination_id IS NOT NULL AND pi_new_load_destination_id IS NULL)
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
      IF pi_old_load_procedure != pi_new_load_procedure
       OR (pi_old_load_procedure IS NULL AND pi_new_load_procedure IS NOT NULL)
       OR (pi_old_load_procedure IS NOT NULL AND pi_new_load_procedure IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_validation_procedure != pi_new_validation_procedure
       OR (pi_old_validation_procedure IS NULL AND pi_new_validation_procedure IS NOT NULL)
       OR (pi_old_validation_procedure IS NOT NULL AND pi_new_validation_procedure IS NULL)
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
        UPDATE sdl_destination_header
           SET sdh_source_container = pi_new_source_container
              ,sdh_nld_id = pi_new_load_destination_id
              ,sdh_table_name = pi_new_table_name
              ,sdh_insert_procedure = pi_new_load_procedure
              ,sdh_validation_procedure = pi_new_validation_procedure
         WHERE sdh_id = pi_dest_header_id
           AND sdh_sp_id = pi_profile_id
           AND sdh_destination_location = 'N';
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
  END update_destination_type;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_destination_location(pi_dest_header_id           IN  sdl_destination_header.sdh_id%TYPE
                                       ,pi_profile_id               IN  sdl_profiles.sp_id%TYPE
                                       ,pi_destination_type         IN  sdl_destination_header.sdh_destination_type%TYPE
                                       ,pi_old_source_container     IN  sdl_destination_header.sdh_source_container%TYPE
                                       ,pi_new_source_container     IN  sdl_destination_header.sdh_source_container%TYPE
                                       ,pi_old_load_destination_id  IN  sdl_destination_header.sdh_nld_id%TYPE
                                       ,pi_new_load_destination_id  IN  sdl_destination_header.sdh_nld_id%TYPE
                                       ,pi_old_table_name           IN  sdl_destination_header.sdh_table_name%TYPE
                                       ,pi_new_table_name           IN  sdl_destination_header.sdh_table_name%TYPE
                                       ,pi_old_load_procedure       IN  sdl_destination_header.sdh_insert_procedure%TYPE
                                       ,pi_new_load_procedure       IN  sdl_destination_header.sdh_insert_procedure%TYPE
                                       ,pi_old_validation_procedure IN  sdl_destination_header.sdh_validation_procedure%TYPE
                                       ,pi_new_validation_procedure IN  sdl_destination_header.sdh_validation_procedure%TYPE
                                       ,po_message_severity         OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor           OUT sys_refcursor)
  IS
    --
    lr_db_rec     sdl_destination_header%ROWTYPE;
    lv_upd        VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_dest_header_id   IN sdl_destination_header.sdh_id%TYPE
                        ,pi_profile_id       IN sdl_profiles.sp_id%TYPE
                        ,pi_destination_type IN sdl_destination_header.sdh_destination_type%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_destination_header
       WHERE sdh_id = pi_dest_header_id
       AND sdh_sp_id = pi_profile_id
       AND sdh_destination_type = pi_destination_type
       AND sdh_destination_location = 'Y'
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Destination Header Location record does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Source Container'
                    ,pi_parameter_value => pi_new_source_container);
    --
    validate_notnull(pi_parameter_desc  => 'Destination Location'
                    ,pi_parameter_value => pi_new_table_name);
  --
    get_db_rec(pi_dest_header_id => pi_dest_header_id, pi_profile_id => pi_profile_id, pi_destination_type => pi_destination_type);
    --
    /*
    ||Compare old with DB
    */
    IF (lr_db_rec.sdh_source_container != pi_old_source_container)
      OR (lr_db_rec.sdh_source_container IS NULL AND pi_old_source_container IS NOT NULL)
      OR (lr_db_rec.sdh_source_container IS NOT NULL AND pi_old_source_container IS NULL)
      --
      OR (lr_db_rec.sdh_nld_id != pi_old_load_destination_id)
      OR (lr_db_rec.sdh_nld_id IS NULL AND pi_old_load_destination_id IS NOT NULL)
      OR (lr_db_rec.sdh_nld_id IS NOT NULL AND pi_old_load_destination_id IS NULL)
      --
      OR (lr_db_rec.sdh_table_name != pi_old_table_name)
      OR (lr_db_rec.sdh_table_name IS NULL AND pi_old_table_name IS NOT NULL)
      OR (lr_db_rec.sdh_table_name IS NOT NULL AND pi_old_table_name IS NULL)
      --
      OR (lr_db_rec.sdh_insert_procedure != pi_old_load_procedure)
      OR (lr_db_rec.sdh_insert_procedure IS NULL AND pi_old_load_procedure IS NOT NULL)
      OR (lr_db_rec.sdh_insert_procedure IS NOT NULL AND pi_old_load_procedure IS NULL)
      --
      OR (lr_db_rec.sdh_validation_procedure != pi_old_validation_procedure)
      OR (lr_db_rec.sdh_validation_procedure IS NULL AND pi_old_validation_procedure IS NOT NULL)
      OR (lr_db_rec.sdh_validation_procedure IS NOT NULL AND pi_old_validation_procedure IS NULL)
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_source_container != pi_new_source_container
       OR (pi_old_source_container IS NULL AND pi_new_source_container IS NOT NULL)
       OR (pi_old_source_container IS NOT NULL AND pi_new_source_container IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_load_destination_id != pi_new_load_destination_id
       OR (pi_old_load_destination_id IS NULL AND pi_new_load_destination_id IS NOT NULL)
       OR (pi_old_load_destination_id IS NOT NULL AND pi_new_load_destination_id IS NULL)
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
      IF pi_old_load_procedure != pi_new_load_procedure
       OR (pi_old_load_procedure IS NULL AND pi_new_load_procedure IS NOT NULL)
       OR (pi_old_load_procedure IS NOT NULL AND pi_new_load_procedure IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_validation_procedure != pi_new_validation_procedure
       OR (pi_old_validation_procedure IS NULL AND pi_new_validation_procedure IS NOT NULL)
       OR (pi_old_validation_procedure IS NOT NULL AND pi_new_validation_procedure IS NULL)
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
        UPDATE sdl_destination_header
           SET sdh_source_container = pi_new_source_container
              ,sdh_nld_id = pi_new_load_destination_id
              ,sdh_table_name = pi_new_table_name
              ,sdh_insert_procedure = pi_new_load_procedure
              ,sdh_validation_procedure = pi_new_validation_procedure
         WHERE sdh_id = pi_dest_header_id
           AND sdh_sp_id = pi_profile_id
           AND sdh_destination_type = pi_destination_type
           AND sdh_destination_location = 'Y';
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
  END update_destination_location;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_destination_type(pi_dest_header_id    IN  sdl_destination_header.sdh_id%TYPE
                                   ,pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                                   ,pi_destination_type  IN  sdl_destination_header.sdh_destination_type%TYPE
                                   ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor    OUT sys_refcursor)
  IS
    --
    ln_exists  NUMBER(4);
    --
  BEGIN
    --
    BEGIN
    --
      SELECT COUNT(1)
        INTO ln_exists
        FROM sdl_attribute_mapping sam
       WHERE sam.sam_sp_id = pi_profile_id
         AND sam.sam_sdh_id = pi_dest_header_id;
      --
      IF ln_exists > 0 THEN
        RAISE_APPLICATION_ERROR (-20050,
                                 'Delete not allowed. Active Attribute mapping exists for the destination type '|| pi_destination_type ||'.');
      END IF;
    END;
    -- Delete the destination type record of the profile
    DELETE sdl_destination_header
     WHERE sdh_id = pi_dest_header_id
       AND sdh_sp_id = pi_profile_id;
    -- Delete Destination location record associated with the destination type of the profile
    DELETE sdl_destination_header
     WHERE sdh_sp_id = pi_profile_id
       AND sdh_destination_type = pi_destination_type
       AND sdh_destination_location = 'Y';
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_destination_type;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_edit_prof_attrib_mapping(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                        ,pi_dest_header_id   IN  sdl_destination_header.sdh_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
    CURSOR c_dest IS
    SELECT dest_type.sdh_destination_type
          ,dest_type.sdh_nlt_id
          ,dest_type.sdh_nld_id dest_nld_id
          ,dest_type.sdh_table_name
          ,dest_loc.sdh_nld_id location_nld_id
          ,dest_loc.sdh_table_name location_table_name
          ,dest_type.sdh_id dest_type_id
          ,dest_loc.sdh_id dest_loc_id
     FROM sdl_destination_header dest_type
         ,sdl_destination_header dest_loc
    WHERE dest_type.sdh_sp_id = dest_loc.sdh_sp_id(+)
      AND dest_type.sdh_destination_type = dest_loc.sdh_destination_type(+)
      AND 'Y'= dest_loc.sdh_destination_location(+)
      AND dest_type.sdh_sp_id = pi_profile_id
      AND dest_type.sdh_id = pi_dest_header_id;
    --
    ln_exists NUMBER(3);
    r_dest    c_dest%ROWTYPE;
    --
  BEGIN
    --
    SELECT COUNT(1)
      INTO ln_exists
      FROM sdl_attribute_mapping sam
     WHERE sam.sam_sp_id = pi_profile_id
       AND (sam.sam_sdh_id IN (SELECT sdh_id
                                FROM sdl_destination_header
                               WHERE sdh_id = pi_dest_header_id)
       OR sam.sam_sdh_id IN (SELECT sdh_id
                                FROM sdl_destination_header
                               WHERE sdh_sp_id = sam.sam_sp_id
                                 AND sdh_id != pi_dest_header_id
                                 AND sdh_destination_type IN (SELECT sdh_destination_type
                                                                FROM sdl_destination_header
                                                               WHERE sdh_id = pi_dest_header_id)));
    --
    IF ln_exists > 0 THEN
      --
      OPEN po_cursor FOR
      SELECT sam.sam_id sam_id
            ,sam.sam_sp_id prof_id
            ,sam.sam_col_id col_id
            ,sam.sam_file_attribute_name src_col
            ,sam.sam_view_column_name dest_col
            ,sam.sam_ne_column_name tab_col
            ,sam.sam_default_value dflt_val
            ,sam.sam_attribute_formula attr_form
            ,CASE WHEN sam.sam_default_value IS NOT NULL
                  THEN 'NVL('||sam.sam_view_column_name||','||sam.sam_default_value||')'
                  ELSE sam.sam_attribute_formula
             END combined_attr_form
            ,sam.sam_sdh_id dest_id
            ,sdh.sdh_destination_type dest_typ
            ,CASE WHEN sdh.sdh_destination_location = 'Y'
                  THEN 'LOCATION'
                  ELSE 'DESTINATION TYPE'
              END dest_loc
        FROM sdl_attribute_mapping sam
            ,sdl_destination_header sdh
       WHERE sam.sam_sp_id = sdh.sdh_sp_id
         AND sam.sam_sdh_id = sdh.sdh_id
         AND sam.sam_sp_id = pi_profile_id
         AND sdh.sdh_destination_type IN (SELECT sdh_destination_type
                                            FROM sdl_destination_header
                                           WHERE sdh_id = pi_dest_header_id)
       ORDER BY sdh.sdh_destination_location, sam.sam_col_id;
      --
    ELSE
      --
       OPEN c_dest;
      FETCH c_dest INTO r_dest;
      CLOSE c_dest;
      --
      IF r_dest.sdh_nlt_id IS NOT NULL THEN
        -- shapefile/file geodatabase file type - route OR datum based profile
        --
          OPEN po_cursor FOR
        SELECT NULL sam_id
              ,pi_profile_id prof_id
              ,ROWNUM col_id
              ,NULL src_col
              ,CASE WHEN vc.column_prompt IS NULL
                    THEN SUBSTR(vc.column_name, 4)
                    ELSE SUBSTR(UPPER(REPLACE(vc.column_prompt,' ','_')),1,30)
               END dest_col
              ,vc.column_name tab_col
              ,NULL dflt_val
              ,NULL attr_form
              ,NULL combined_attr_form
              ,pi_dest_header_id dest_id
              ,r_dest.sdh_destination_type dest_typ
              ,'DESTINATION TYPE' dest_loc
          FROM v_nm_nw_columns vc,
               nm_linear_types nlt
         WHERE vc.network_type = nlt.nlt_nt_type
           AND ((nlt.nlt_g_i_d = 'G' AND vc.group_type = nlt.nlt_gty_type)
                OR nlt.nlt_g_i_d = 'D')
           AND nlt.nlt_id = r_dest.sdh_nlt_id
           AND vc.column_name NOT IN ('NE_NO_START', 'NE_NO_END', 'NE_TYPE', 'NE_NT_TYPE')
           AND NOT EXISTS (SELECT 1
                             FROM sdl_attribute_mapping sam
                            WHERE sam.sam_ne_column_name = vc.column_name
                              AND sam.sam_sp_id = pi_profile_id
                              AND sam.sam_sdh_id = pi_dest_header_id)
        ORDER BY vc.rn;
        --
      ELSE
        -- CSV file type - asset and/or destination location
        --
          OPEN po_cursor FOR
        SELECT NULL sam_id
              ,pi_profile_id prof_id
              ,ct.col_id col_id
              ,NULL src_col
              ,ct.destination_column dest_col
              ,ct.table_column tab_col
              ,ct.default_value dflt_val
              ,NULL attr_form
              ,CASE WHEN ct.default_value IS NOT NULL
                  THEN 'NVL('||ct.destination_column||','||ct.default_value||')'
                  ELSE NULL
             END combined_attr_form
              ,pi_dest_header_id dest_id
              ,r_dest.sdh_destination_type dest_typ
              ,CASE WHEN ct.column_of = 'LOCATION'
                  THEN 'LOCATION'
                  ELSE 'DESTINATION TYPE'
              END dest_loc
         FROM (SELECT column_name destination_column
                     ,column_name table_column
                     ,'ASSET' column_of
                     ,column_id col_id
                     ,nldd_value default_value
                 FROM all_tab_columns,
                      nm_load_destination_defaults
                WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
                  AND table_name = r_dest.sdh_table_name
                  AND nldd_nld_id (+) = r_dest.dest_nld_id
                  AND nldd_column_name (+) = column_name
              UNION ALL
               SELECT column_name destination_column
                     ,column_name table_column
                     ,'LOCATION' column_of
                     ,column_id
                     ,nldd_value default_value
                 FROM all_tab_columns,
                      nm_load_destination_defaults
                WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
                  AND table_name = r_dest.location_table_name
                  AND nldd_nld_id (+) = r_dest.location_nld_id
                  AND nldd_column_name (+) = column_name) ct
        ORDER BY ct.column_of, ct.col_id;
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
  END get_edit_prof_attrib_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_attribute_mapping(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,pi_dest_header_id   IN  sdl_destination_header.sdh_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT sam.sam_id sam_id
          ,sam.sam_sp_id prof_id
          ,sam.sam_col_id col_id
          ,sam.sam_file_attribute_name src_col
          ,sam.sam_view_column_name dest_col
          ,sam.sam_ne_column_name tab_col
          ,sam.sam_default_value dflt_val
          ,sam.sam_attribute_formula attr_form
          ,CASE WHEN sam.sam_default_value IS NOT NULL
                THEN 'NVL('||sam.sam_view_column_name||','||sam.sam_default_value||')'
                ELSE sam.sam_attribute_formula
           END combined_attr_form
          ,sam.sam_sdh_id dest_id
          ,sdh.sdh_destination_type dest_typ
          ,CASE WHEN sdh.sdh_destination_location = 'Y'
                THEN 'LOCATION'
                ELSE 'DESTINATION TYPE'
            END dest_loc
      FROM sdl_attribute_mapping sam
          ,sdl_destination_header sdh
     WHERE sam.sam_sp_id = sdh.sdh_sp_id
       AND sam.sam_sdh_id = sdh.sdh_id
       AND sam.sam_sp_id = pi_profile_id
       AND (pi_dest_header_id IS NULL 
           OR
           (sam.sam_sdh_id IN (SELECT sdh_id
                                FROM sdl_destination_header
                               WHERE sdh_id = pi_dest_header_id)
            OR sam.sam_sdh_id IN (SELECT sdh_id
                                    FROM sdl_destination_header
                                   WHERE sdh_sp_id = sam.sam_sp_id
                                     AND sdh_id != pi_dest_header_id
                                     AND sdh_destination_type IN (SELECT sdh_destination_type
                                                                    FROM sdl_destination_header
                                                                   WHERE sdh_id = pi_dest_header_id))))
     ORDER BY sdh.sdh_destination_location, sam.sam_col_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_attrib_mapping(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                    ,pi_dest_header_id   IN  sdl_destination_header.sdh_id%TYPE
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sam_id sam_id
                                                   ,sam_sp_id prof_id
                                                   ,sam_col_id col_id
                                                   ,sam_file_attribute_name src_col
                                                   ,sam_view_column_name dest_col
                                                   ,sam_ne_column_name tab_col
                                                   ,sam_default_value dflt_val
                                                   ,sam_attribute_formula attr_form
                                                   ,combined_attr_form
                                                   ,sam_sdh_id dest_id
                                                   ,sdh_destination_type dest_typ
                                                   ,dest_loc dest_loc
                                              FROM (
                                             SELECT sam.sam_id
                                                   ,sam.sam_sp_id
                                                   ,sam.sam_col_id
                                                   ,sam.sam_file_attribute_name
                                                   ,sam.sam_view_column_name
                                                   ,sam.sam_ne_column_name
                                                   ,sam.sam_default_value
                                                   ,sam.sam_attribute_formula
                                                   ,CASE WHEN sam.sam_default_value IS NOT NULL
                                                         THEN ''NVL(''||sam.sam_view_column_name||'',''||sam.sam_default_value||'')''
                                                         ELSE sam.sam_attribute_formula
                                                    END combined_attr_form
                                                   ,sam.sam_sdh_id
                                                   ,sdh.sdh_destination_type
                                                   ,CASE WHEN sdh.sdh_destination_location = ''Y''
                                                         THEN ''LOCATION''
                                                         ELSE ''DESTINATION TYPE''
                                                     END dest_loc
                                               FROM sdl_attribute_mapping sam
                                                   ,sdl_destination_header sdh
                                              WHERE sam.sam_sp_id = sdh.sdh_sp_id
                                                AND sam.sam_sdh_id = sdh.sdh_id
                                                AND sam.sam_sp_id = :pi_profile_id
                                                AND (sam.sam_sdh_id IN (SELECT sdh_id
                                                                          FROM sdl_destination_header
                                                                         WHERE sdh_id = :pi_dest_header_id)
                                                     OR sam.sam_sdh_id IN (SELECT sdh_id
                                                                             FROM sdl_destination_header
                                                                            WHERE sdh_sp_id = sam.sam_sp_id
                                                                              AND sdh_id != :pi_dest_header_id
                                                                              AND sdh_destination_type IN (SELECT sdh_destination_type
                                                                                                             FROM sdl_destination_header
                                                                                                            WHERE sdh_id = :pi_dest_header_id))))
                                             WHERE 1 = 1';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT sam_id'
                                              ||' ,prof_id'
                                              ||' ,col_id'
                                              ||' ,src_col'
                                              ||' ,dest_col'
                                              ||' ,tab_col'
                                              ||' ,dflt_val'
                                              ||' ,attr_form'
                                              ||' ,combined_attr_form'
                                              ||' ,dest_id'
                                              ||' ,dest_typ'
                                              ||' ,dest_loc'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'src_col'
                                ,pi_query_col    => 'sam_file_attribute_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'dest_col'
                                ,pi_query_col    => 'sam_view_column_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'tab_col'
                                ,pi_query_col    => 'sam_ne_column_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'combined_attr_form'
                                ,pi_query_col    => 'combined_attr_form'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'dest_loc'
                                ,pi_query_col    => 'dest_loc'
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
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'dest_loc, col_id')||') a)';
    --
    lv_cursor_sql := lv_cursor_sql||CHR(10)||' OFFSET '||pi_skip_n_rows||' ROWS ';
    --
    IF pi_pagesize IS NOT NULL
    THEN
      lv_cursor_sql := lv_cursor_sql||CHR(10)||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql
    USING pi_profile_id
         ,pi_dest_header_id
         ,pi_dest_header_id
         ,pi_dest_header_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_paged_attrib_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_attribute_mapping(pi_profile_id         IN  sdl_attribute_mapping.sam_sp_id%TYPE
                                    ,pi_dest_header_id     IN  sdl_destination_header.sdh_id%TYPE
                                    ,pi_source_column      IN  sdl_attribute_mapping.sam_file_attribute_name%TYPE
                                    ,pi_destination_column IN  sdl_attribute_mapping.sam_view_column_name%TYPE
                                    ,pi_table_column       IN  sdl_attribute_mapping.sam_ne_column_name%TYPE
                                    ,pi_default_value      IN  sdl_attribute_mapping.sam_default_value%TYPE
                                    ,pi_attrib_formula     IN  sdl_attribute_mapping.sam_attribute_formula%TYPE)
  IS
    --
    ln_max_col_id sdl_attribute_mapping.sam_col_id%TYPE;
    --
  BEGIN
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20033,
                               'Insert not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active submission exists.');
    END IF;
    --
    SELECT NVL(MAX(sam_col_id), 0)
      INTO ln_max_col_id
      FROM sdl_attribute_mapping
     WHERE sam_sp_id = pi_profile_id;
    --
    INSERT
      INTO sdl_attribute_mapping
              (sam_sp_id,
               sam_sdh_id,
               sam_col_id,
               sam_file_attribute_name,
               sam_view_column_name,
               sam_ne_column_name,
               sam_default_value,
               sam_attribute_formula)
    VALUES (pi_profile_id
           ,pi_dest_header_id
           ,ln_max_col_id + 1
           ,pi_source_column
           ,pi_destination_column
           ,pi_table_column
           ,pi_default_value
           ,pi_attrib_formula);
    --
    update_profile_views(pi_profile_id);
    --
  END create_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_attribute_mapping(pi_profile_id             IN sdl_profiles.sp_id%TYPE
                                    ,pi_dest_header_id         IN sdl_destination_header.sdh_id%TYPE
                                    ,pi_sam_id                 IN sdl_attribute_mapping.sam_id%TYPE
                                    ,pi_old_source_column      IN sdl_attribute_mapping.sam_file_attribute_name%TYPE
                                    ,pi_new_source_column      IN sdl_attribute_mapping.sam_file_attribute_name%TYPE
                                    ,pi_old_destination_column IN sdl_attribute_mapping.sam_view_column_name%TYPE
                                    ,pi_new_destination_column IN sdl_attribute_mapping.sam_view_column_name%TYPE
                                    ,pi_old_table_column       IN sdl_attribute_mapping.sam_ne_column_name%TYPE
                                    ,pi_new_table_column       IN sdl_attribute_mapping.sam_ne_column_name%TYPE
                                    ,pi_old_default_value      IN sdl_attribute_mapping.sam_default_value%TYPE
                                    ,pi_new_default_value      IN sdl_attribute_mapping.sam_default_value%TYPE
                                    ,pi_old_attribute_formula  IN sdl_attribute_mapping.sam_attribute_formula%TYPE
                                    ,pi_new_attribute_formula  IN sdl_attribute_mapping.sam_attribute_formula%TYPE)
  IS
    --
    lr_db_rec   sdl_attribute_mapping%ROWTYPE;
    lv_upd      VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_profile_id     IN sdl_profiles.sp_id%TYPE
                        ,pi_dest_header_id IN sdl_destination_header.sdh_id%TYPE
                        ,pi_sam_id         IN sdl_attribute_mapping.sam_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_attribute_mapping
       WHERE sam_sp_id = pi_profile_id
         AND sam_sdh_id = pi_dest_header_id
         AND sam_id = pi_sam_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Attribute mapping does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    validate_notnull(pi_parameter_desc  => 'Destination Column'
                    ,pi_parameter_value => pi_new_destination_column);
    --
    validate_notnull(pi_parameter_desc  => 'Table Column'
                    ,pi_parameter_value => pi_new_table_column);
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20028,
                               'Update not allowed. Attributes are already mapped to an active submission of the Profile '|| get_profile_name(pi_profile_id));
    END IF;
    --
    get_db_rec(pi_profile_id => pi_profile_id, pi_dest_header_id => pi_dest_header_id, pi_sam_id => pi_sam_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_rec.sam_file_attribute_name != pi_old_source_column
      OR (lr_db_rec.sam_file_attribute_name IS NULL AND pi_old_source_column IS NOT NULL)
      OR (lr_db_rec.sam_file_attribute_name IS NOT NULL AND pi_old_source_column IS NULL)
      -- Destination Column
      OR (lr_db_rec.sam_view_column_name != pi_old_destination_column)
      OR (lr_db_rec.sam_view_column_name IS NULL AND pi_old_destination_column IS NOT NULL)
      OR (lr_db_rec.sam_view_column_name IS NOT NULL AND pi_old_destination_column IS NULL)
      -- Table Column
      OR (lr_db_rec.sam_ne_column_name != pi_old_table_column)
      OR (lr_db_rec.sam_ne_column_name IS NULL AND pi_old_table_column IS NOT NULL)
      OR (lr_db_rec.sam_ne_column_name IS NOT NULL AND pi_old_table_column IS NULL)
      -- Default Value
      OR (lr_db_rec.sam_default_value != pi_old_default_value)
      OR (lr_db_rec.sam_default_value IS NULL AND pi_old_default_value IS NOT NULL)
      OR (lr_db_rec.sam_default_value IS NOT NULL AND pi_old_default_value IS NULL)
      -- Attribute Formula
      OR (lr_db_rec.sam_attribute_formula != pi_old_attribute_formula)
      OR (lr_db_rec.sam_attribute_formula IS NULL AND pi_old_attribute_formula IS NOT NULL)
      OR (lr_db_rec.sam_attribute_formula IS NOT NULL AND pi_old_attribute_formula IS NULL)
    THEN
      --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_source_column != pi_new_source_column
        OR (pi_old_source_column IS NULL AND pi_new_source_column IS NOT NULL)
        OR (pi_old_source_column IS NOT NULL AND pi_new_source_column IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_destination_column != pi_new_destination_column
        OR (pi_old_destination_column IS NULL AND pi_new_destination_column IS NOT NULL)
        OR (pi_old_destination_column IS NOT NULL AND pi_new_destination_column IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_table_column != pi_new_table_column
        OR (pi_old_table_column IS NULL AND pi_new_table_column IS NOT NULL)
        OR (pi_old_table_column IS NOT NULL AND pi_new_table_column IS NULL)
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
      IF pi_old_attribute_formula != pi_new_attribute_formula
        OR (pi_old_attribute_formula IS NULL AND pi_new_attribute_formula IS NOT NULL)
        OR (pi_old_attribute_formula IS NOT NULL AND pi_new_attribute_formula IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF lv_upd = 'N'
      THEN
        NULL; -- Only updated records should be sent from UI
      ELSE
        --
        UPDATE sdl_attribute_mapping
           SET sam_file_attribute_name = pi_new_source_column
              ,sam_view_column_name = pi_new_destination_column
              ,sam_ne_column_name = pi_new_table_column
              ,sam_default_value = pi_new_default_value
              ,sam_attribute_formula = pi_new_attribute_formula
         WHERE sam_sp_id = pi_profile_id
           AND sam_sdh_id = pi_dest_header_id
           AND sam_id = pi_sam_id;
        --
      END IF;
    END IF;
    --
    update_profile_views(pi_profile_id);
    --
  END update_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_attribute_mapping(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                                    ,pi_dest_header_id    IN  sdl_destination_header.sdh_id%TYPE
                                    ,pi_sam_id            IN  sdl_attribute_mapping.sam_id%TYPE)
  IS
  --
    CURSOR c_sam IS
     SELECT ROWNUM col_id, sam_col_id, sam_id
     FROM (
         SELECT sam_col_id, sam_id
           FROM sdl_attribute_mapping
          WHERE sam_sp_id = pi_profile_id
           AND sam_sdh_id = pi_dest_header_id
         ORDER BY sam_col_id);
  --
  BEGIN
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20029,
                               'Delete not allowed. Attributes are already mapped to an active submission of the Profile '|| get_profile_name(pi_profile_id));
    END IF;
    --
    DELETE sdl_attribute_mapping
     WHERE sam_sp_id = pi_profile_id
    --   AND sam_sdh_id = pi_dest_header_id
       AND sam_id = pi_sam_id;
    --
    -- Re-sequence the col_ids for the profile attribute mapping
    FOR r_sam IN c_sam
    LOOP
      UPDATE sdl_attribute_mapping
         SET sam_col_id  = r_sam.col_id
       WHERE sam_id = r_sam.sam_id
         AND sam_sp_id = pi_profile_id
         AND sam_sdh_id = pi_dest_header_id;
    END LOOP;
    --
  END delete_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE edit_profile_attribute_mapping (pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                           ,pi_dest_header_id   IN  sdl_destination_header.sdh_id%TYPE
                                           ,pi_old_attr_map     IN  CLOB
                                           ,pi_new_attr_map     IN  CLOB
                                           ,pi_del_attr_map_ids IN  awlrs_sdl_util.sam_id_tab
                                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                                           ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    CURSOR c_attr_map IS
      WITH old_rec AS (SELECT sam_id
                             ,source_column
                             ,destination_column
                             ,table_column
                             ,default_value
                             ,attribute_formula
                             ,dest_loc
                             ,dest_loc_id
                         FROM DUAL,
                              JSON_TABLE(pi_old_attr_map
                                          ,'$.oldAttrMaps[*]'
                                             COLUMNS(sam_id PATH '$.SamId'
                                                    ,source_column PATH '$.SrcCol'
                                                    ,destination_column PATH '$.DestCol'
                                                    ,table_column PATH '$.TabCol'
                                                    ,default_value PATH '$.DfltVal'
                                                    ,attribute_formula PATH '$.AttrForm'
                                                    ,dest_loc PATH '$.DestLoc'
                                                    ,dest_loc_id PATH '$.DestId'))),
          new_rec AS (SELECT sam_id
                            ,source_column
                            ,destination_column
                            ,table_column
                            ,default_value
                            ,attribute_formula
                            ,dest_loc
                            ,dest_loc_id
                        FROM DUAL,
                             JSON_TABLE(pi_new_attr_map
                                         ,'$.newAttrMaps[*]'
                                            COLUMNS(sam_id PATH '$.SamId'
                                                   ,source_column PATH '$.SrcCol'
                                                   ,destination_column PATH '$.DestCol'
                                                   ,table_column PATH '$.TabCol'
                                                   ,default_value PATH '$.DfltVal'
                                                   ,attribute_formula PATH '$.AttrForm'
                                                   ,dest_loc PATH '$.DestLoc'
                                                   ,dest_loc_id PATH '$.DestId')))
      SELECT CASE WHEN n.sam_id IS NULL AND o.sam_id IS NULL
                  THEN 'I'
                  WHEN o.sam_id = n.sam_id
                  THEN 'U'
              END t_action
             ,o.sam_id old_sam_id
             ,o.source_column old_source_column
             ,o.destination_column old_destination_column
             ,o.table_column old_table_column
             ,o.default_value old_default_value
             ,o.attribute_formula old_attribute_formula
             ,o.dest_loc old_dest_loc
             ,o.dest_loc_id old_dest_loc_id
             ,n.sam_id new_sam_id
             ,n.source_column new_source_column
             ,n.destination_column new_destination_column
             ,n.table_column new_table_column
             ,n.default_value new_default_value
             ,n.attribute_formula new_attribute_formula
             ,n.dest_loc new_dest_loc
             ,n.dest_loc_id new_dest_loc_id
         FROM old_rec o FULL OUTER JOIN
              new_rec n
           ON NVL(o.sam_id, -1) = NVL(n.sam_id, -1)
        ORDER BY t_action, TO_NUMBER(old_sam_id);
    --
    ln_dest_header_id sdl_destination_header.sdh_id%TYPE;
    --
  BEGIN
    --
    FOR i IN 1..pi_del_attr_map_ids.COUNT
    LOOP
      --
      delete_attribute_mapping(pi_profile_id => pi_profile_id
                              ,pi_dest_header_id => pi_dest_header_id
                              ,pi_sam_id => pi_del_attr_map_ids(i));
      --
    END LOOP;
    --
    FOR r_attr_map IN c_attr_map
    LOOP
      --
      IF r_attr_map.t_action = 'U' THEN
        --
        update_attribute_mapping(pi_profile_id => pi_profile_id
                                ,pi_dest_header_id => r_attr_map.new_dest_loc_id
                                ,pi_sam_id => r_attr_map.new_sam_id
                                ,pi_old_source_column => r_attr_map.old_source_column
                                ,pi_new_source_column => r_attr_map.new_source_column
                                ,pi_old_destination_column => r_attr_map.old_destination_column
                                ,pi_new_destination_column => r_attr_map.new_destination_column
                                ,pi_old_table_column => r_attr_map.old_table_column
                                ,pi_new_table_column => r_attr_map.new_table_column
                                ,pi_old_default_value => r_attr_map.old_default_value
                                ,pi_new_default_value => r_attr_map.new_default_value
                                ,pi_old_attribute_formula => r_attr_map.old_attribute_formula
                                ,pi_new_attribute_formula => r_attr_map.new_attribute_formula);
        --
      END IF;
      --
      IF r_attr_map.t_action = 'I' THEN
        --
        IF r_attr_map.new_dest_loc = 'LOCATION' THEN
          SELECT sdh_id
            INTO ln_dest_header_id
            FROM sdl_destination_header
           WHERE sdh_sp_id = pi_profile_id
             AND sdh_destination_type IN (SELECT sdh_destination_type
                                            FROM sdl_destination_header
                                           WHERE sdh_id = pi_dest_header_id)
             AND sdh_destination_location = 'Y';
        ELSE
          ln_dest_header_id := pi_dest_header_id;
        END IF;
        create_attribute_mapping(pi_profile_id => pi_profile_id
                                ,pi_dest_header_id => ln_dest_header_id
                                ,pi_source_column => r_attr_map.new_source_column
                                ,pi_destination_column => r_attr_map.new_destination_column
                                ,pi_table_column => r_attr_map.new_table_column
                                ,pi_default_value => r_attr_map.new_default_value
                                ,pi_attrib_formula => r_attr_map.new_attribute_formula);
        --
      END IF;
      --
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
  END edit_profile_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_column_of_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT 'DESTINATION TYPE' column_of
      FROM dual
     UNION ALL
    SELECT 'LOCATION' column_of
      FROM dual
    ORDER BY column_of;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_column_of_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_source_column_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                    ,pi_container        IN  sdl_destination_header.sdh_source_container%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT spfc.spfc_col_name source_column
      FROM sdl_profile_file_columns spfc
     WHERE spfc.spfc_sp_id = pi_profile_id
       AND spfc.spfc_container = pi_container
    ORDER BY spfc.spfc_col_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_source_column_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_destination_column_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,pi_dest_header_id   IN  sdl_destination_header.sdh_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
  IS
    --
    CURSOR c_dest IS
    SELECT dest_type.sdh_destination_type
          ,dest_type.sdh_nlt_id
          ,dest_type.sdh_table_name
          ,dest_loc.sdh_table_name location_table_name
          ,dest_type.sdh_id dest_type_id
          ,dest_loc.sdh_id dest_loc_id
          ,dest_loc.sdh_destination_location dest_loc
     FROM sdl_destination_header dest_type
         ,sdl_destination_header dest_loc
    WHERE dest_type.sdh_sp_id = dest_loc.sdh_sp_id(+)
      AND dest_type.sdh_destination_type = dest_loc.sdh_destination_type(+)
      AND 'Y' = dest_loc.sdh_destination_location(+)
      AND dest_type.sdh_sp_id = pi_profile_id
      AND dest_type.sdh_id = pi_dest_header_id;
    --
      r_dest c_dest%ROWTYPE;
    --
  BEGIN
    --
    OPEN c_dest;
    FETCH c_dest INTO r_dest;
    CLOSE c_dest;
    --
      IF r_dest.sdh_nlt_id IS NOT NULL THEN
        -- shapefile/file geodatabase file type - route OR datum based profile
        --
        OPEN po_cursor FOR
        SELECT destination_column
              ,network_column
              ,column_of
          FROM
            (SELECT CASE WHEN vc.column_prompt IS NULL
                         THEN SUBSTR(vc.column_name, 4)
                         ELSE SUBSTR(UPPER(REPLACE(vc.column_prompt,' ','_')),1,30)
                     END destination_column
                   ,vc.column_name network_column
                   ,'DESTINATION TYPE' column_of
                   ,vc.rn column_id
               FROM v_nm_nw_columns vc,
                    nm_linear_types nlt
              WHERE vc.network_type = nlt.nlt_nt_type
                AND vc.column_name NOT IN ('NE_NO_START', 'NE_NO_END', 'NE_TYPE', 'NE_NT_TYPE')
                AND ((nlt.nlt_g_i_d = 'G' AND vc.group_type = nlt.nlt_gty_type)
                     OR nlt.nlt_g_i_d = 'D')
                AND nlt.nlt_id = r_dest.sdh_nlt_id)
         ORDER BY column_id;
        --
      ELSE
        -- CSV file type - asset and/or destination location
        --
        OPEN po_cursor FOR
        SELECT destination_column
              ,network_column
              ,column_of
          FROM
            (SELECT column_name destination_column
                   ,column_name network_column
                   ,'DESTINATION TYPE' column_of
                   ,column_id
               FROM all_tab_columns
              WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
                AND table_name = r_dest.sdh_table_name
              UNION ALL
              SELECT column_name destination_column
                    ,column_name network_column
                    ,'LOCATION' column_of
                    ,column_id
               FROM all_tab_columns
              WHERE owner = Sys_Context('NM3CORE','APPLICATION_OWNER')
                AND table_name = r_dest.location_table_name)
         ORDER BY column_of, column_id;
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
  END get_destination_column_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_dest_type_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT sdh.sdh_id
          ,sdh.sdh_destination_type
          ,dest.network_meaning destination_type_descr
      FROM sdl_destination_header sdh
          ,(SELECT network_type
                  ,network_descr
                  ,network_meaning
                  ,nlt_id
              FROM (
                  SELECT nit.nit_inv_type network_type
                        ,nit.nit_descr network_descr
                        ,nit.nit_inv_type ||' - '|| nit.nit_descr network_meaning
                        ,NULL nlt_id
                    FROM nm_inv_types nit
                        ,nm_load_destinations nld
                   WHERE nld.nld_table_name = NVL(nit.nit_view_name, nit.nit_table_name)
                   UNION ALL
                    SELECT nlt.nlt_nt_type network_type
                          ,nlt.nlt_descr network_descr
                          ,nlt.nlt_nt_type ||' - '|| nlt.nlt_descr network_meaning
                          ,nlt.nlt_id
                       FROM nm_linear_types nlt)
                     ) dest
     WHERE sdh.sdh_destination_type = dest.network_type
       AND sdh.sdh_sp_id = pi_profile_id
       AND sdh.sdh_destination_location = 'N'
       AND (sdh.sdh_nlt_id = dest.nlt_id OR dest.nlt_id IS NULL)
     ORDER BY sdh.sdh_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
    --
  END get_profile_dest_type_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_rule_users_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT user_id
          ,username
      FROM (SELECT -1 user_id
                  ,'ALL' username
              FROM dual
             UNION ALL
            SELECT hu.hus_user_id user_id
                  ,hu.hus_username username
              FROM hig_users hu
             WHERE EXISTS (SELECT 1
                             FROM hig_user_roles hur
                            WHERE hur.hur_username = hu.hus_username
                              AND hur.hur_role IN ('SDL_ADMIN','SDL_USER')
                              AND hur.hur_start_date BETWEEN hu.hus_start_date
                                              AND NVL(hu.hus_end_date, hur.hur_start_date + 1))
               AND EXISTS (SELECT 1
                             FROM sdl_user_profiles
                            WHERE sup_sp_id = pi_profile_id
                              AND sup_user_id = hu.hus_user_id))
    ORDER BY user_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_rule_users_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_attribute_adjustment_rules(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                          ,pi_user_select      IN  VARCHAR2 DEFAULT 'A'
                                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                                          ,po_message_cursor   OUT sys_refcursor
                                          ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    -- pi_user_select 
    -- A -- ALL users
    -- U -- selected user
      OPEN po_cursor FOR
    SELECT saar.saar_id saar_id
          ,saar.saar_sp_id profile_id
          ,get_profile_name(saar.saar_sp_id) profile_name
          ,saar.saar_sdh_id load_dest_id
          ,sdh.sdh_destination_type destination_type
          ,saar.saar_target_attribute_name target_attribute_name
          ,saar.saar_source_value source_value
          ,saar.saar_adjust_to_value adjust_to_value
          ,saar.saar_user_id user_id
          ,CASE WHEN saar.saar_user_id = -1
                THEN 'ALL'
                ELSE nm3user.get_username(saar.saar_user_id)
            END user_name
          ,saar.saar_created_by created_by
          ,saar.saar_date_created created_on
          ,saar.saar_modified_by modified_by
          ,saar.saar_date_modified modified_on
      FROM sdl_attribute_adjustment_rules saar
          ,sdl_destination_header sdh
     WHERE saar.saar_sdh_id = sdh.sdh_id
       AND saar.saar_sp_id = sdh.sdh_sp_id
       AND saar.saar_sp_id = pi_profile_id
       AND ((pi_user_select = 'A')
            OR
            (pi_user_select = 'U' AND (saar.saar_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
                                  OR saar.saar_user_id = -1)))
     ORDER BY saar.saar_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_attribute_adjustment_rules;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_attrib_adjust_rules(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,pi_user_select      IN  VARCHAR2 DEFAULT 'A'
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
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT saar_id
                                                   ,profile_id
                                                   ,profile_name
                                                   ,load_dest_id
                                                   ,destination_type
                                                   ,target_attribute_name
                                                   ,source_value
                                                   ,adjust_to_value
                                                   ,user_id
                                                   ,user_name
                                                   ,created_by
                                                   ,created_on
                                                   ,modified_by
                                                   ,modified_on
                                               FROM
                                            (SELECT saar.saar_id saar_id
                                                   ,saar.saar_sp_id profile_id
                                                   ,awlrs_sdl_profiles_api.get_profile_name(saar.saar_sp_id) profile_name
                                                   ,saar.saar_sdh_id load_dest_id
                                                   ,sdh.sdh_destination_type destination_type
                                                   ,saar.saar_target_attribute_name target_attribute_name
                                                   ,saar.saar_source_value source_value
                                                   ,saar.saar_adjust_to_value adjust_to_value
                                                   ,saar.saar_user_id user_id
                                                   ,CASE WHEN saar.saar_user_id = -1
                                                         THEN ''ALL''
                                                         ELSE nm3user.get_username(saar.saar_user_id)
                                                     END user_name
                                                   ,saar.saar_created_by created_by
                                                   ,saar.saar_date_created created_on
                                                   ,saar.saar_modified_by modified_by
                                                   ,saar.saar_date_modified modified_on
                                               FROM sdl_attribute_adjustment_rules saar
                                                   ,sdl_destination_header sdh
                                              WHERE saar.saar_sdh_id = sdh.sdh_id
                                                AND saar.saar_sp_id = sdh.sdh_sp_id
                                                AND saar.saar_sp_id = :pi_profile_id
                                                AND ((:pi_user_select = ''A'')
                                                      OR
                                                     (:pi_user_select = ''U'' AND (saar.saar_user_id = SYS_CONTEXT(''NM3CORE'', ''USER_ID'')
                                                                             OR saar.saar_user_id = -1))))
											WHERE 1=1';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT saar_id'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,load_dest_id'
                                              ||' ,destination_type'
                                              ||' ,target_attribute_name'
                                              ||' ,source_value'
                                              ||' ,adjust_to_value'
                                              ||' ,user_id'
                                              ||' ,user_name'
                                              ||' ,created_by'
                                              ||' ,created_on'
                                              ||' ,modified_by'
                                              ||' ,modified_on'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'destination_type'
                                ,pi_query_col    => 'destination_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'target_attribute_name'
                                ,pi_query_col    => 'target_attribute_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'source_value'
                                ,pi_query_col    => 'source_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'adjust_to_value'
                                ,pi_query_col    => 'adjust_to_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'user_name'
                                ,pi_query_col    => 'user_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'saar_id')||') a)';
    --
    lv_cursor_sql := lv_cursor_sql||CHR(10)||' OFFSET '||pi_skip_n_rows||' ROWS ';
    --
    IF pi_pagesize IS NOT NULL
    THEN
      lv_cursor_sql := lv_cursor_sql||CHR(10)||' FETCH NEXT '||pi_pagesize||' ROWS ONLY ';
    END IF;
    --
    OPEN po_cursor FOR lv_cursor_sql
    USING pi_profile_id
         ,pi_user_select
         ,pi_user_select;
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
  END get_paged_attrib_adjust_rules;
  --
  -----------------------------------------------------------------------------
  --verify and delete if not being used
  PROCEDURE get_attribute_adjustment_rule(pi_saar_id          IN  sdl_attribute_adjustment_rules.saar_id%TYPE
                                         ,pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    -- probably not used anywhere in web api or UI.. verify and delete
    --
      OPEN po_cursor FOR
    SELECT saar.saar_id saar_id
          ,saar.saar_sp_id profile_id
          ,get_profile_name(saar.saar_sp_id) profile_name
          ,saar.saar_sdh_id load_dest_id
          ,sdh.sdh_destination_type destination_type
          ,saar.saar_target_attribute_name target_attribute_name
          ,saar.saar_source_value source_value
          ,saar.saar_adjust_to_value adjust_to_value
      FROM sdl_attribute_adjustment_rules saar
          ,sdl_destination_header sdh
     WHERE saar.saar_sdh_id = sdh.sdh_id
       AND saar.saar_sp_id = sdh.sdh_sp_id
       AND saar.saar_id = pi_saar_id
       AND saar.saar_sp_id = pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_attribute_adjustment_rule;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_attrib_adjustment_rule(pi_profile_id          IN  sdl_attribute_adjustment_rules.saar_sp_id%TYPE
                                         ,pi_destination_id      IN  sdl_attribute_adjustment_rules.saar_sdh_id%TYPE
                                         ,pi_target_attrib_name  IN  sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                                         ,pi_source_value        IN  sdl_attribute_adjustment_rules.saar_source_value%TYPE
                                         ,pi_adjust_to_value     IN  sdl_attribute_adjustment_rules.saar_adjust_to_value%TYPE
                                         ,pi_rule_user_id        IN  sdl_attribute_adjustment_rules.saar_user_id%TYPE
                                         ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor      OUT sys_refcursor)
  IS
    --
    CURSOR c_rule_exists(cp_profile_id         sdl_profiles.sp_id%TYPE
                        ,cp_destination_id     sdl_attribute_adjustment_rules.saar_sdh_id%TYPE
                        ,cp_target_attrib_name sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                        ,cp_source_value       sdl_attribute_adjustment_rules.saar_source_value%TYPE)
    IS
    SELECT 1
      FROM sdl_attribute_adjustment_rules saar
     WHERE saar.saar_sp_id = cp_profile_id
       AND saar.saar_sdh_id = cp_destination_id
       AND saar.saar_target_attribute_name = cp_target_attrib_name
       AND ((saar.saar_source_value = cp_source_value AND cp_source_value IS NOT NULL)
            OR
            (saar.saar_source_value IS NULL AND cp_source_value IS NULL)
            );
    --
    lv_exists  NUMBER(1);
    lv_retval  BOOLEAN := FALSE;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN  c_rule_exists(pi_profile_id, pi_destination_id, pi_target_attrib_name, pi_source_value);
    FETCH c_rule_exists INTO lv_exists;
    lv_retval := c_rule_exists%FOUND;
    CLOSE c_rule_exists;
    --
    IF lv_retval THEN
      RAISE_APPLICATION_ERROR (-20030,
                               'Adjustment Rule already exists for attribute '|| pi_target_attrib_name || ' and value ' || NVL(pi_source_value,'NULL'));
    END IF;
    --
    INSERT
      INTO sdl_attribute_adjustment_rules
              (saar_sp_id
              ,saar_target_attribute_name
              ,saar_source_value
              ,saar_adjust_to_value
              ,saar_sdh_id
              ,saar_user_id)
    VALUES (pi_profile_id
           ,pi_target_attrib_name
           ,pi_source_value
           ,pi_adjust_to_value
           ,pi_destination_id
           ,pi_rule_user_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_attrib_adjustment_rule;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_attrib_adjustment_rule(pi_profile_id                IN  sdl_profiles.sp_id%TYPE
                                         ,pi_saar_id                   IN  sdl_attribute_adjustment_rules.saar_id%TYPE
                                         ,pi_old_destination_id        IN  sdl_attribute_adjustment_rules.saar_sdh_id%TYPE
                                         ,pi_new_destination_id        IN  sdl_attribute_adjustment_rules.saar_sdh_id%TYPE
                                         ,pi_old_target_attribute_name IN  sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                                         ,pi_new_target_attribute_name IN  sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                                         ,pi_old_source_value          IN  sdl_attribute_adjustment_rules.saar_source_value%TYPE
                                         ,pi_new_source_value          IN  sdl_attribute_adjustment_rules.saar_source_value%TYPE
                                         ,pi_old_adjust_to_value       IN  sdl_attribute_adjustment_rules.saar_adjust_to_value%TYPE
                                         ,pi_new_adjust_to_value       IN  sdl_attribute_adjustment_rules.saar_adjust_to_value%TYPE
                                         ,pi_old_rule_user_id          IN  sdl_attribute_adjustment_rules.saar_user_id%TYPE
                                         ,pi_new_rule_user_id          IN  sdl_attribute_adjustment_rules.saar_user_id%TYPE
                                         ,po_message_severity          OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor            OUT sys_refcursor)
  IS
    --
    lr_db_rec sdl_attribute_adjustment_rules%ROWTYPE;
    lv_upd    VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_profile_id IN sdl_profiles.sp_id%TYPE, pi_saar_id IN sdl_attribute_adjustment_rules.saar_id%TYPE)
    IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_attribute_adjustment_rules
       WHERE saar_sp_id = pi_profile_id
         AND saar_id = pi_saar_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Attribute adjustment rule does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    validate_notnull(pi_parameter_desc  => 'Destination Id'
                    ,pi_parameter_value => pi_new_destination_id);
    --
    validate_notnull(pi_parameter_desc  => 'Target Attribute Name'
                    ,pi_parameter_value => pi_new_target_attribute_name);
    --
    validate_notnull(pi_parameter_desc  => 'Adjust to Value'
                    ,pi_parameter_value => pi_new_adjust_to_value);
    --
    IF active_rule_exists(pi_profile_id, pi_saar_id) THEN
      RAISE_APPLICATION_ERROR (-20031,
                               'Update not allowed. Adjustment Rule ' || pi_saar_id || ' is already applied to an active submission of the Profile '|| get_profile_name(pi_profile_id));
    END IF;
    --
    get_db_rec(pi_profile_id => pi_profile_id, pi_saar_id => pi_saar_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_rec.saar_sdh_id != pi_old_destination_id
      OR (lr_db_rec.saar_sdh_id IS NULL AND pi_old_destination_id IS NOT NULL)
      OR (lr_db_rec.saar_sdh_id IS NOT NULL AND pi_old_destination_id IS NULL)
      -- Target Attribute Name
      OR (lr_db_rec.saar_target_attribute_name != pi_old_target_attribute_name)
      OR (lr_db_rec.saar_target_attribute_name IS NULL AND pi_old_target_attribute_name IS NOT NULL)
      OR (lr_db_rec.saar_target_attribute_name IS NOT NULL AND pi_old_target_attribute_name IS NULL)
      -- Source Value
      OR (lr_db_rec.saar_source_value != pi_old_source_value)
      OR (lr_db_rec.saar_source_value IS NULL AND pi_old_source_value IS NOT NULL)
      OR (lr_db_rec.saar_source_value IS NOT NULL AND pi_old_source_value IS NULL)
      -- Adjust to Value
      OR (lr_db_rec.saar_adjust_to_value != pi_old_adjust_to_value)
      OR (lr_db_rec.saar_adjust_to_value IS NULL AND pi_old_adjust_to_value IS NOT NULL)
      OR (lr_db_rec.saar_adjust_to_value IS NOT NULL AND pi_old_adjust_to_value IS NULL)
      -- User Id
      OR (lr_db_rec.saar_user_id != pi_old_rule_user_id)
      OR (lr_db_rec.saar_user_id IS NULL AND pi_old_rule_user_id IS NOT NULL)
      OR (lr_db_rec.saar_user_id IS NOT NULL AND pi_old_rule_user_id IS NULL)
    THEN
      --Updated by another user
      hig.raise_ner(pi_appl => 'AWLRS'
                   ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_destination_id != pi_new_destination_id
        OR (pi_old_destination_id IS NULL AND pi_new_destination_id IS NOT NULL)
        OR (pi_old_destination_id IS NOT NULL AND pi_new_destination_id IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_target_attribute_name != pi_new_target_attribute_name
        OR (pi_old_target_attribute_name IS NULL AND pi_new_target_attribute_name IS NOT NULL)
        OR (pi_old_target_attribute_name IS NOT NULL AND pi_new_target_attribute_name IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_source_value != pi_new_source_value
        OR (pi_old_source_value IS NULL AND pi_new_source_value IS NOT NULL)
        OR (pi_old_source_value IS NOT NULL AND pi_new_source_value IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_adjust_to_value != pi_new_adjust_to_value
        OR (pi_old_adjust_to_value IS NULL AND pi_new_adjust_to_value IS NOT NULL)
        OR (pi_old_adjust_to_value IS NOT NULL AND pi_new_adjust_to_value IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_rule_user_id != pi_new_rule_user_id
        OR (pi_old_rule_user_id IS NULL AND pi_new_rule_user_id IS NOT NULL)
        OR (pi_old_rule_user_id IS NOT NULL AND pi_new_rule_user_id IS NULL)
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
        UPDATE sdl_attribute_adjustment_rules
           SET saar_sdh_id = pi_new_destination_id
              ,saar_target_attribute_name = pi_new_target_attribute_name
              ,saar_source_value = pi_new_source_value
              ,saar_adjust_to_value = pi_new_adjust_to_value
              ,saar_user_id = pi_new_rule_user_id
         WHERE saar_sp_id = pi_profile_id
           AND saar_id = pi_saar_id;
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
  END update_attrib_adjustment_rule;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_attrib_adjustment_rule(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                                         ,pi_saar_id           IN  sdl_attribute_adjustment_rules.saar_id%TYPE
                                         ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor    OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    IF active_rule_exists(pi_profile_id, pi_saar_id) THEN
      RAISE_APPLICATION_ERROR (-20032,
                               'Delete not allowed. Adjustment Rule ' || pi_saar_id || ' is already applied to an active submission of the Profile '|| get_profile_name(pi_profile_id));
    END IF;
    --
    DELETE sdl_attribute_adjustment_rules
     WHERE saar_sp_id = pi_profile_id
       AND saar_id = pi_saar_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_attrib_adjustment_rule;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_attribute_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT sam_view_column_name attribute_name
          ,sam_col_id column_id
      FROM sdl_attribute_mapping
     WHERE sam_sp_id = pi_profile_id
     ORDER BY sam_col_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_attribute_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_attribute_domain_lookup(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                       ,pi_attribute_name   IN  sdl_attribute_mapping.sam_view_column_name%TYPE
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor
                                       ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT hco_code domain_code
          ,hco_code || ' - ' || hco_meaning description
      FROM hig_codes
     WHERE hco_domain = (SELECT vnc.domain
                           FROM sdl_attribute_mapping sam
                               ,sdl_profiles sp
                               ,sdl_destination_header sdh
                               ,v_nm_nw_columns vnc
                               ,nm_linear_types nlt
                          WHERE sam.sam_sp_id = sp.sp_id
                            AND sam.sam_sdh_id = sdh.sdh_id
                            AND sdh.sdh_nlt_id = nlt.nlt_id
                            AND sdh.sdh_destination_location = 'N'
                            AND sam.sam_ne_column_name = vnc.column_name
                            AND vnc.network_type = nlt.nlt_nt_type
                            AND ((nlt.nlt_g_i_d = 'G' AND vnc.group_type = nlt.nlt_gty_type)
                                 OR nlt.nlt_g_i_d = 'D')
                            AND sp.sp_id = pi_profile_id
                            AND sam.sam_view_column_name = pi_attribute_name
                            AND vnc.domain IS NOT NULL);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_attribute_domain_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_spatial_review_levels(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    OPEN po_cursor FOR
    SELECT ssrl_id
          ,ssrl_sp_id
          ,ssrl_percent_from
          ,ssrl_percent_to
          ,CASE WHEN ssrl_percent_from = -999.999
                THEN 'None'
             --   THEN '< ' || ROUND(ssrl_percent_to) || '%'
                WHEN ssrl_percent_to = 999.999
                THEN ssrl_percent_from || '%' || ' +'
                ELSE ROUND(ssrl_percent_from) ||'% - '|| ROUND(ssrl_percent_to) || '%'
           END percent_range
          ,ssrl_coverage_level
          ,ssrl_default_action
          ,ssrl_date_created
          ,ssrl_created_by
          ,ssrl_date_modified
          ,ssrl_modified_by
      FROM sdl_spatial_review_levels
     WHERE ssrl_sp_id = pi_profile_id
     ORDER BY ssrl_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_spatial_review_levels;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_profile_spatial_info(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT sp.sp_id profile_id
          ,sp.sp_tol_load_search tolerance_load_search
          ,sp.sp_tol_nw_search tolerance_network_search
          ,sp.sp_tol_search_unit tolerance_search_unit_id
          ,nu.un_unit_name tolerance_search_unit
          ,sp.sp_stop_count stop_count
          ,sp.sp_source_cs source_coordinate_system
          ,sp.sp_destination_cs destination_coordinate_system
      FROM sdl_profiles sp
          ,nm_units nu
     WHERE sp.sp_tol_search_unit = nu.un_unit_id
       AND nu.un_domain_id = 1
       AND sp.sp_id = pi_profile_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_profile_spatial_info;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_destination_cs_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT srid cs_srid
          ,srid || ' - ' ||cs_name cs_name
      FROM cs_srs
     ORDER BY srid;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_destination_cs_lookup;
  --
  -----------------------------------------------------------------------------
  --

  PROCEDURE set_spatial_review_action(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                     ,pi_ssrl_id          IN  sdl_spatial_review_levels.ssrl_id%TYPE
                                     ,pi_action           IN  sdl_spatial_review_levels.ssrl_default_action%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor)
  IS
    --
    ln_exists NUMBER;
    --
  BEGIN
    --
    awlrs_sdl_util.validate_user_role;
    --
    BEGIN
      --
      SELECT 1
        INTO ln_exists
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM sdl_wip_datums swd,
                            sdl_file_submissions sfs
                      WHERE swd.batch_id = sfs.sfs_id
                        AND sfs.sfs_sp_id = pi_profile_id);
      --
      RAISE_APPLICATION_ERROR (-20033,
                              'Can not update the default action. Spatial review levels for '|| get_profile_name(pi_profile_id) || ' has already been used for an active submission.');
      --
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;
    END;

    --
    UPDATE sdl_spatial_review_levels
       SET ssrl_default_action = pi_action
     WHERE ssrl_id = pi_ssrl_id
       AND ssrl_sp_id = pi_profile_id
       AND ssrl_default_action != pi_action;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_spatial_review_action;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_profile_spatial_info(pi_profile_id          IN  sdl_profiles.sp_id%TYPE
                                       ,pi_old_tol_load_search IN  sdl_profiles.sp_tol_load_search%TYPE
                                       ,pi_new_tol_load_search IN  sdl_profiles.sp_tol_load_search%TYPE
                                       ,pi_old_tol_nw_search   IN  sdl_profiles.sp_tol_nw_search%TYPE
                                       ,pi_new_tol_nw_search   IN  sdl_profiles.sp_tol_nw_search%TYPE
                                       ,pi_old_tol_search_unit IN  sdl_profiles.sp_tol_search_unit%TYPE
                                       ,pi_new_tol_search_unit IN  sdl_profiles.sp_tol_search_unit%TYPE
                                       ,pi_old_stop_count      IN  sdl_profiles.sp_stop_count%TYPE
                                       ,pi_new_stop_count      IN  sdl_profiles.sp_stop_count%TYPE
                                       ,pi_old_destination_cs  IN  sdl_profiles.sp_destination_cs%TYPE
                                       ,pi_new_destination_cs  IN  sdl_profiles.sp_destination_cs%TYPE
                                       ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor      OUT sys_refcursor)
  IS
    --
    lr_db_rec sdl_profiles%ROWTYPE;
    lv_upd    VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_profile_id IN sdl_profiles.sp_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_profiles
       WHERE sp_id = pi_profile_id
         FOR UPDATE NOWAIT;
      --
    EXCEPTION
      WHEN no_data_found THEN
        --
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 85
                     ,pi_supplementary_info => 'Profile does not exist');
      --
    END get_db_rec;
    --
  BEGIN
    --
    validate_notnull(pi_parameter_desc  => 'Load Search Tolerance'
                    ,pi_parameter_value => pi_new_tol_load_search);
    --
    validate_notnull(pi_parameter_desc  => 'Network Search Tolerance'
                    ,pi_parameter_value => pi_new_tol_nw_search);
    --
    validate_notnull(pi_parameter_desc  => 'Tolerance Search Unit'
                    ,pi_parameter_value => pi_new_tol_search_unit);
    --
    validate_notnull(pi_parameter_desc  => 'Stop Count'
                    ,pi_parameter_value => pi_new_stop_count);
    --
    validate_notnull(pi_parameter_desc  => 'Destination Coordinate System'
                    ,pi_parameter_value => pi_new_destination_cs);
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20024,
                               'Update not allowed. Profile ' || get_profile_name(pi_profile_id) || ' has active file data exists in the system');
    END IF;
    --
    get_db_rec(pi_profile_id => pi_profile_id);
    --
    /*
    ||Compare old with DB
    */
      -- Load Search Tolerance
    IF (lr_db_rec.sp_tol_load_search != pi_old_tol_load_search)
      OR (lr_db_rec.sp_tol_load_search IS NULL AND pi_old_tol_load_search IS NOT NULL)
      OR (lr_db_rec.sp_tol_load_search IS NOT NULL AND pi_old_tol_load_search IS NULL)
      -- Network Search Tolerance
      OR (lr_db_rec.sp_tol_nw_search != pi_old_tol_nw_search)
      OR (lr_db_rec.sp_tol_nw_search IS NULL AND pi_old_tol_nw_search IS NOT NULL)
      OR (lr_db_rec.sp_tol_nw_search IS NOT NULL AND pi_old_tol_nw_search IS NULL)
      -- Tolerance Search Unit
      OR (lr_db_rec.sp_tol_search_unit != pi_old_tol_search_unit)
      OR (lr_db_rec.sp_tol_search_unit IS NULL AND pi_old_tol_search_unit IS NOT NULL)
      OR (lr_db_rec.sp_tol_search_unit IS NOT NULL AND pi_old_tol_search_unit IS NULL)
      -- Stop Count
      OR (lr_db_rec.sp_stop_count != pi_old_stop_count)
      OR (lr_db_rec.sp_stop_count IS NULL AND pi_old_stop_count IS NOT NULL)
      OR (lr_db_rec.sp_stop_count IS NOT NULL AND pi_old_stop_count IS NULL)
      -- Destination Coordinate System
      OR (lr_db_rec.sp_destination_cs != pi_old_destination_cs)
      OR (lr_db_rec.sp_destination_cs IS NULL AND pi_old_destination_cs IS NOT NULL)
      OR (lr_db_rec.sp_destination_cs IS NOT NULL AND pi_old_destination_cs IS NULL)
    THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_tol_load_search != pi_new_tol_load_search
       OR (pi_old_tol_load_search IS NULL AND pi_new_tol_load_search IS NOT NULL)
       OR (pi_old_tol_load_search IS NOT NULL AND pi_new_tol_load_search IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tol_nw_search != pi_new_tol_nw_search
       OR (pi_old_tol_nw_search IS NULL AND pi_new_tol_nw_search IS NOT NULL)
       OR (pi_old_tol_nw_search IS NOT NULL AND pi_new_tol_nw_search IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tol_search_unit != pi_new_tol_search_unit
       OR (pi_old_tol_search_unit IS NULL AND pi_new_tol_search_unit IS NOT NULL)
       OR (pi_old_tol_search_unit IS NOT NULL AND pi_new_tol_search_unit IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_stop_count != pi_new_stop_count
       OR (pi_old_stop_count IS NULL AND pi_new_stop_count IS NOT NULL)
       OR (pi_old_stop_count IS NOT NULL AND pi_new_stop_count IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_destination_cs != pi_new_destination_cs
       OR (pi_old_destination_cs IS NULL AND pi_new_destination_cs IS NOT NULL)
       OR (pi_old_destination_cs IS NOT NULL AND pi_new_destination_cs IS NULL)
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
        UPDATE sdl_profiles
           SET sp_tol_load_search = pi_new_tol_load_search
              ,sp_tol_nw_search = pi_new_tol_nw_search
              ,sp_tol_search_unit = pi_new_tol_search_unit
              ,sp_stop_count = pi_new_stop_count
              ,sp_destination_cs = pi_new_destination_cs
         WHERE sp_id = pi_profile_id;
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
  END update_profile_spatial_info;
  --
  -----------------------------------------------------------------------------
  --
END awlrs_sdl_profiles_api;
/