CREATE OR REPLACE PACKAGE BODY awlrs_sdl_profiles_api IS
  --
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       pvcsid           : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdl_profiles_api.pkb-arc   1.4   Mar 17 2020 14:50:50   Vikas.Mhetre  $
  --       Module Name      : $Workfile:   awlrs_sdl_profiles_api.pkb  $
  --       Date into PVCS   : $Date:   Mar 17 2020 14:50:50  $
  --       Date fetched Out : $Modtime:   Mar 17 2020 14:50:18  $
  --       PVCS Version     : $Revision:   1.4  $
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
    lv_insert        nm3type.max_varchar2;
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
    IF lv_default_value IS NULL THEN
      lv_formula := 'l.ne_owner';
    END IF;

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
      lv_insert := 'INSERT INTO sdl_datum_attribute_mapping (sdam_profile_id, sdam_nw_type, sdam_seq_no, sdam_column_name, sdam_default_value, sdam_formula)
                    VALUES ('|| pi_profile_id ||', '''||cur.network_type ||''','|| TO_NUMBER(ln_max_seq + 1) ||', '''||cur.column_name||''', '''||cur.default_value||''', NULL)';
      EXECUTE IMMEDIATE lv_insert;
    END LOOP;
    --
  END default_datum_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE generate_profile_views(pi_profile_id IN sdl_profiles.sp_id%TYPE)
  IS
  --
  BEGIN
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20034,
                               'Generation of profile views not allowed. Profile ' || get_profile_name(pi_profile_id) || ' already has an active file data exists in the system.');
    END IF;
    --
    IF NOT check_mapping_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20035,
                               'No Attribute mappings exists for the profile. Please configure valid attribute mappings for the profile ' || get_profile_name(pi_profile_id) || ' first.');
    END IF;
    --
    sdl_ddl.gen_sdl_profile_views(pi_profile_id);
    --
    UPDATE sdl_profiles
       SET sp_loading_view_name =  'V_SDL_' || REPLACE (UPPER(sp_name), ' ', '_') || '_LD'
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
  BEGIN
    --
    generate_profile_views(pi_profile_id);
    --
    -- default_datum_attribute_mapping to be replaced with a new UI to insert datum attribute mappings
    -- in Manage Profiles screen in future release
    -- Administrator should configure datum mappings along with profile attribute mappings through SDL application
    -- This has been added as a temporary (kind of hardcoded) logic to insert default values for datum mappings
    default_datum_attribute_mapping(pi_profile_id);
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
      FROM dba_views
     WHERE view_name = (SELECT UPPER ('V_SDL_' || REPLACE (sp_name, ' ', '_') || '_LD')
                          FROM sdl_profiles
                         WHERE sp_id = pi_profile_id)
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
  PROCEDURE get_profiles_lookup(po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
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
      OPEN po_cursor FOR
    SELECT sp.sp_id profile_id
          ,sp.sp_name profile_name
          ,sp.sp_desc profile_desc
          ,sp.sp_import_file_type import_file_type_code
          ,hv1.hco_meaning import_file_type
          ,sp.sp_nlt_id nlt_id
          ,nlt.nlt_nt_type ||' - ' || nlt.nlt_descr network_type
          ,sp.sp_max_import_level import_level_code
          ,hv2.hco_meaning import_level
          ,sp.sp_topology_level topology_level_code
          ,hv3.hco_meaning topology_level
          ,sp.sp_default_tolerance tolerance
          ,sp.sp_tol_load_search tolerance_load_search
          ,sp.sp_tol_nw_search tolerance_network_search
          ,sp.sp_tol_search_unit tolerance_search_unit_id
          ,nu.un_unit_name tolerance_search_unit
          ,sp.sp_stop_count stop_count
          ,sp.sp_date_modified last_used
          ,CASE WHEN sp.sp_loading_view_name IS NOT NULL
                THEN 'Y'
                ELSE 'N'
           END is_views_generated
      FROM sdl_profiles sp
          ,nm_linear_types nlt
          ,hig_codes hv1
          ,hig_codes hv2
          ,hig_codes hv3
          ,nm_units nu
     WHERE sp.sp_nlt_id = nlt.nlt_id
       AND sp.sp_import_file_type = hv1.hco_code
       AND sp.sp_max_import_level = hv2.hco_code
       AND sp.sp_topology_level = hv3.hco_code
       AND sp.sp_tol_search_unit = nu.un_unit_id
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
  END get_profile;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_profile(pi_name             IN  sdl_profiles.sp_name%TYPE
                          ,pi_desc             IN  sdl_profiles.sp_desc%TYPE
                          ,pi_file_type        IN  sdl_profiles.sp_import_file_type%TYPE
                          ,pi_import_level     IN  sdl_profiles.sp_max_import_level%TYPE
                          ,pi_tolerance        IN  sdl_profiles.sp_default_tolerance%TYPE
                          ,pi_topology_level   IN  sdl_profiles.sp_topology_level%TYPE
                          ,pi_nlt_id           IN  sdl_profiles.sp_nlt_id%TYPE
                          ,pi_tol_load_search  IN  sdl_profiles.sp_tol_load_search%TYPE
                          ,pi_tol_nw_search    IN  sdl_profiles.sp_tol_nw_search%TYPE
                          ,pi_tol_search_unit  IN  sdl_profiles.sp_tol_search_unit%TYPE
                          ,pi_stop_count       IN  sdl_profiles.sp_stop_count%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor)
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
        ,sp_max_import_level
        ,sp_default_tolerance
        ,sp_topology_level
        ,sp_nlt_id
        ,sp_tol_load_search
        ,sp_tol_nw_search
        ,sp_tol_search_unit
        ,sp_stop_count)
    VALUES
        (pi_name
        ,pi_desc
        ,pi_file_type
        ,pi_import_level
        ,pi_tolerance
        ,pi_topology_level
        ,pi_nlt_id
        ,pi_tol_load_search
        ,pi_tol_nw_search
        ,pi_tol_search_unit
        ,pi_stop_count );
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
                          ,pi_old_nlt_id          IN  sdl_profiles.sp_nlt_id%TYPE
                          ,pi_new_nlt_id          IN  sdl_profiles.sp_nlt_id%TYPE
                          ,pi_old_file_type       IN  sdl_profiles.sp_import_file_type%TYPE
                          ,pi_new_file_type       IN  sdl_profiles.sp_import_file_type%TYPE
                          ,pi_old_import_level    IN  sdl_profiles.sp_max_import_level%TYPE
                          ,pi_new_import_level    IN  sdl_profiles.sp_max_import_level%TYPE
                          ,pi_old_tolerance       IN  sdl_profiles.sp_default_tolerance%TYPE
                          ,pi_new_tolerance       IN  sdl_profiles.sp_default_tolerance%TYPE
                          ,pi_old_topology_level  IN  sdl_profiles.sp_topology_level%TYPE
                          ,pi_new_topology_level  IN  sdl_profiles.sp_topology_level%TYPE
                          ,pi_old_tol_load_search IN  sdl_profiles.sp_tol_load_search%TYPE
                          ,pi_new_tol_load_search IN  sdl_profiles.sp_tol_load_search%TYPE
                          ,pi_old_tol_nw_search   IN  sdl_profiles.sp_tol_nw_search%TYPE
                          ,pi_new_tol_nw_search   IN  sdl_profiles.sp_tol_nw_search%TYPE
                          ,pi_old_tol_search_unit IN  sdl_profiles.sp_tol_search_unit%TYPE
                          ,pi_new_tol_search_unit IN  sdl_profiles.sp_tol_search_unit%TYPE
                          ,pi_old_stop_count      IN  sdl_profiles.sp_stop_count%TYPE
                          ,pi_new_stop_count      IN  sdl_profiles.sp_stop_count%TYPE
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
    validate_notnull(pi_parameter_desc  => 'Profile Name'
                    ,pi_parameter_value => pi_new_name);
    --
    validate_notnull(pi_parameter_desc  => 'Network ID'
                    ,pi_parameter_value => pi_new_nlt_id);
    --
    validate_notnull(pi_parameter_desc  => 'Import File Type'
                    ,pi_parameter_value => pi_new_file_type);
    --
    validate_notnull(pi_parameter_desc  => 'Maximum Import Level'
                    ,pi_parameter_value => pi_new_import_level);
    --
    validate_notnull(pi_parameter_desc  => 'Default Tolerance'
                    ,pi_parameter_value => pi_new_tolerance);
    --
    validate_notnull(pi_parameter_desc  => 'Topology Level'
                    ,pi_parameter_value => pi_new_topology_level);
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
      -- Network ID
      OR (lr_db_rec.sp_nlt_id != pi_old_nlt_id)
      OR (lr_db_rec.sp_nlt_id IS NULL AND pi_old_nlt_id IS NOT NULL)
      OR (lr_db_rec.sp_nlt_id IS NOT NULL AND pi_old_nlt_id IS NULL)
      -- Import File Type
      OR (lr_db_rec.sp_import_file_type != pi_old_file_type)
      OR (lr_db_rec.sp_import_file_type IS NULL AND pi_old_file_type IS NOT NULL)
      OR (lr_db_rec.sp_import_file_type IS NOT NULL AND pi_old_file_type IS NULL)
      -- Maximum Import Level
      OR (lr_db_rec.sp_max_import_level != pi_old_import_level)
      OR (lr_db_rec.sp_max_import_level IS NULL AND pi_old_import_level IS NOT NULL)
      OR (lr_db_rec.sp_max_import_level IS NOT NULL AND pi_old_import_level IS NULL)
      -- Default Tolerance
      OR (lr_db_rec.sp_default_tolerance != pi_old_tolerance)
      OR (lr_db_rec.sp_default_tolerance IS NULL AND pi_old_tolerance IS NOT NULL)
      OR (lr_db_rec.sp_default_tolerance IS NOT NULL AND pi_old_tolerance IS NULL)
      -- Topology Level
      OR (lr_db_rec.sp_topology_level != pi_old_topology_level)
      OR (lr_db_rec.sp_topology_level IS NULL AND pi_old_topology_level IS NOT NULL)
      OR (lr_db_rec.sp_topology_level IS NOT NULL AND pi_old_topology_level IS NULL)
      -- Load Search Tolerance
      OR (lr_db_rec.sp_tol_load_search != pi_old_tol_load_search)
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
      IF pi_old_nlt_id != pi_new_nlt_id
       OR (pi_old_nlt_id IS NULL AND pi_new_nlt_id IS NOT NULL)
       OR (pi_old_nlt_id IS NOT NULL AND pi_new_nlt_id IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_file_type != pi_new_file_type
       OR (pi_old_file_type IS NULL AND pi_new_file_type IS NOT NULL)
       OR (pi_old_file_type IS NOT NULL AND pi_new_file_type IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
    --
      IF pi_old_import_level != pi_new_import_level
       OR (pi_old_import_level IS NULL AND pi_new_import_level IS NOT NULL)
       OR (pi_old_import_level IS NOT NULL AND pi_new_import_level IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_tolerance != pi_new_tolerance
       OR (pi_old_tolerance IS NULL AND pi_new_tolerance IS NOT NULL)
       OR (pi_old_tolerance IS NOT NULL AND pi_new_tolerance IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
      IF pi_old_topology_level != pi_new_topology_level
       OR (pi_old_topology_level IS NULL AND pi_new_topology_level IS NOT NULL)
       OR (pi_old_topology_level IS NOT NULL AND pi_new_topology_level IS NULL)
       THEN
         lv_upd := 'Y';
      END IF;
      --
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
              ,sp_nlt_id = pi_new_nlt_id
              ,sp_import_file_type = pi_new_file_type
              ,sp_max_import_level = pi_new_import_level
              ,sp_default_tolerance = pi_new_tolerance
              ,sp_topology_level = pi_new_topology_level
              ,sp_tol_load_search = pi_new_tol_load_search
              ,sp_tol_nw_search = pi_new_tol_nw_search
              ,sp_tol_search_unit = pi_new_tol_search_unit
              ,sp_stop_count = pi_new_stop_count
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
    --
  BEGIN
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
      OPEN po_cursor FOR
    SELECT sp.sp_id profile_id
          ,sp.sp_name profile_name
          ,sp.sp_desc profile_desc
          ,sp.sp_import_file_type import_file_type_code
          ,hv1.hco_meaning import_file_type
          ,sp.sp_nlt_id nlt_id
          ,nlt.nlt_descr network_type
          ,sp.sp_max_import_level import_level_code
          ,hv2.hco_meaning import_level
          ,sp.sp_topology_level topology_level_code
          ,hv3.hco_meaning topology_level
          ,sp.sp_default_tolerance tolerance
          ,sp.sp_tol_load_search tolerance_load_search
          ,sp.sp_tol_nw_search tolerance_network_search
          ,sp.sp_tol_search_unit tolerance_search_unit_id
          ,nu.un_unit_name tolerance_search_unit
          ,sp.sp_stop_count stop_count
          ,sp.sp_date_modified last_used
          ,CASE WHEN sp.sp_loading_view_name IS NOT NULL
                THEN 'Y'
                ELSE 'N'
           END is_views_generated
      FROM sdl_profiles sp
          ,nm_linear_types nlt
          ,hig_codes hv1
          ,hig_codes hv2
          ,hig_codes hv3
          ,nm_units nu
     WHERE sp.sp_nlt_id = nlt.nlt_id
       AND sp.sp_import_file_type = hv1.hco_code
       AND sp.sp_max_import_level = hv2.hco_code
       AND sp.sp_topology_level = hv3.hco_code
       AND sp.sp_tol_search_unit = nu.un_unit_id
       AND nu.un_domain_id = 1
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
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sp.sp_id profile_id
                                                   ,sp.sp_name profile_name
                                                   ,sp.sp_desc profile_desc
                                                   ,sp.sp_import_file_type import_file_type_code
                                                   ,hv1.hco_meaning import_file_type
                                                   ,sp.sp_nlt_id nlt_id
                                                   ,nlt.nlt_descr network_type
                                                   ,sp.sp_max_import_level import_level_code
                                                   ,hv2.hco_meaning import_level
                                                   ,sp.sp_topology_level topology_level_code
                                                   ,hv3.hco_meaning topology_level
                                                   ,sp.sp_default_tolerance tolerance
                                                   ,sp.sp_tol_load_search tolerance_load_search
                                                   ,sp.sp_tol_nw_search tolerance_network_search
                                                   ,sp.sp_tol_search_unit tolerance_search_unit_id
                                                   ,nu.un_unit_name tolerance_search_unit
                                                   ,sp.sp_stop_count stop_count
                                                   ,sp.sp_date_modified last_used
                                                   ,CASE WHEN sp.sp_loading_view_name IS NOT NULL
                                                         THEN ''Y''
                                                         ELSE ''N''
                                                    END is_views_generated
                                               FROM sdl_profiles sp,
                                                    nm_linear_types nlt,
                                                    hig_codes hv1,
                                                    hig_codes hv2,
                                                    hig_codes hv3,
                                                    nm_units nu
                                              WHERE sp.sp_nlt_id = nlt.nlt_id
                                                AND sp.sp_import_file_type = hv1.hco_code
                                                AND sp.sp_max_import_level = hv2.hco_code
                                                AND sp.sp_topology_level = hv3.hco_code
                                                AND sp.sp_tol_search_unit = nu.un_unit_id
                                                AND nu.un_domain_id = 1';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT profile_id'
                                              ||' ,profile_name'
                                              ||' ,profile_desc'
                                              ||' ,import_file_type_code'
                                              ||' ,import_file_type'
                                              ||' ,nlt_id'
                                              ||' ,network_type'
                                              ||' ,import_level_code'
                                              ||' ,import_level'
                                              ||' ,topology_level_code'
                                              ||' ,topology_level'
                                              ||' ,tolerance'
                                              ||' ,tolerance_load_search'
                                              ||' ,tolerance_network_search'
                                              ||' ,tolerance_search_unit_id'
                                              ||' ,tolerance_search_unit'
                                              ||' ,stop_count'
                                              ||' ,last_used'
                                              ||' ,is_views_generated'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'import_file_type'
                                ,pi_query_col    => 'hv1.hco_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'network_type'
                                ,pi_query_col    => 'nlt_descr'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'import_level'
                                ,pi_query_col    => 'hv2.hco_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'topology_level'
                                ,pi_query_col    => 'hv3.hco_meaning'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'tolerance_load_search'
                                ,pi_query_col    => 'sp_tol_load_search'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'tolerance_network_search'
                                ,pi_query_col    => 'sp_tol_nw_search'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'tolerance_search_unit'
                                ,pi_query_col    => 'un_unit_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'stop_count'
                                ,pi_query_col    => 'sp_stop_count'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'last_used'
                                ,pi_query_col    => 'sp_date_modified'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sp.sp_id')||') a)'
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
    OPEN po_cursor FOR
    SELECT sup.sup_id sup_id
          ,sup.sup_user_id user_id
          ,nm3user.get_username(sup.sup_user_id) username
          ,sup.sup_sp_id profile_id
          ,get_profile_name(sup.sup_sp_id) profile_name
        --,awlrs_sdl_profiles_api.get_profile_name(sup.sup_sp_id) profile_name
     FROM sdl_user_profiles sup
    WHERE sup.sup_sp_id = pi_profile_id
     ORDER BY sup.sup_user_id;
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
  PROCEDURE create_user_profile(pi_user_id          IN  hig_users.hus_user_id%TYPE
                               ,pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
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
         sup_sp_id)
    VALUES
        (pi_user_id,
         pi_profile_id);
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
    validate_notnull(pi_parameter_desc  => 'User'
                    ,pi_parameter_value => pi_new_user_id);
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
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      ELSE
        --
        UPDATE sdl_user_profiles
           SET sup_user_id = pi_new_user_id
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
    OPEN po_cursor FOR
    SELECT hc.hco_code
          ,hc.hco_code || ' - ' || hc.hco_meaning hco_meaning
          ,hc.hco_seq
      FROM hig_codes hc
          ,hig_domains hd
     WHERE hc.hco_domain = hd.hdo_domain
       AND hd.hdo_product = 'NET'
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
  PROCEDURE get_profile_attribute_mapping(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT sam.sam_id sam_id
          ,sam.sam_sp_id profile_id
          ,get_profile_name(sam.sam_sp_id) profile_name
		--,awlrs_sdl_profiles_api.get_profile_name(sam.sam_sp_id) profile_name
          ,sam.sam_col_id col_id
          ,sam.sam_file_attribute_name shapefile_column_name
          ,sam.sam_view_column_name source_attribute_name
          ,sam.sam_attribute_formula source_attrib_formula
          ,sam.sam_ne_column_name target_attribute_name
      FROM sdl_attribute_mapping sam
     WHERE sam.sam_sp_id = pi_profile_id;
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
  PROCEDURE get_paged_attribute_mapping(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT sam.sam_id sam_id,
                                                    sam.sam_sp_id profile_id,
                                                    awlrs_sdl_profiles_api.get_profile_name(sam.sam_sp_id) profile_name,
                                                    sam.sam_col_id col_id,
                                                    sam.sam_file_attribute_name shapefile_column_name,
                                                    sam.sam_view_column_name source_attribute_name,
                                                    sam.sam_attribute_formula source_attrib_formula,
                                                    sam.sam_ne_column_name target_attribute_name
                                               FROM sdl_attribute_mapping sam
                                              WHERE sam.sam_sp_id = :pi_profile_id';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT sam_id'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,col_id'
                                              ||' ,shapefile_column_name'
                                              ||' ,source_attribute_name'
                                              ||' ,source_attrib_formula'
                                              ||' ,target_attribute_name'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'shapefile_column_name'
                                ,pi_query_col    => 'sam_file_attribute_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'source_attribute_name'
                                ,pi_query_col    => 'sam_view_column_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'target_attribute_name'
                                ,pi_query_col    => 'sam_ne_column_name'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'sam.sam_col_id')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_profile_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_profile_id
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
  END get_paged_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_attribute_mapping(pi_profile_id       IN  sdl_attribute_mapping.sam_sp_id%TYPE
                                    ,pi_file_column      IN  sdl_attribute_mapping.sam_file_attribute_name%TYPE
                                    ,pi_view_column      IN  sdl_attribute_mapping.sam_view_column_name%TYPE
                                    ,pi_ne_column        IN  sdl_attribute_mapping.sam_ne_column_name%TYPE
                                    ,pi_attrib_formula   IN  sdl_attribute_mapping.sam_attribute_formula%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor)
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
               sam_col_id,
               sam_file_attribute_name,
               sam_view_column_name,
               sam_ne_column_name,
               sam_attribute_formula)
    VALUES (pi_profile_id
           ,ln_max_col_id + 1
           ,pi_file_column
           ,pi_view_column
           ,pi_ne_column
           ,pi_attrib_formula);
    --
    update_profile_views(pi_profile_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_attribute_mapping(pi_profile_id              IN  sdl_profiles.sp_id%TYPE
                                    ,pi_sam_id                  IN  sdl_attribute_mapping.sam_id%TYPE
                                    ,pi_old_file_attribute_name IN  sdl_attribute_mapping.sam_file_attribute_name%TYPE
                                    ,pi_new_file_attribute_name IN  sdl_attribute_mapping.sam_file_attribute_name%TYPE
                                    ,pi_old_view_column_name    IN  sdl_attribute_mapping.sam_view_column_name%TYPE
                                    ,pi_new_view_column_name    IN  sdl_attribute_mapping.sam_view_column_name%TYPE
                                    ,pi_old_attribute_formula   IN  sdl_attribute_mapping.sam_attribute_formula%TYPE
                                    ,pi_new_attribute_formula   IN  sdl_attribute_mapping.sam_attribute_formula%TYPE
                                    ,pi_old_ne_column_name      IN  sdl_attribute_mapping.sam_ne_column_name%TYPE
                                    ,pi_new_ne_column_name      IN  sdl_attribute_mapping.sam_ne_column_name%TYPE
                                    ,po_message_severity        OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor          OUT sys_refcursor)
  IS
    --
    lr_db_rec   sdl_attribute_mapping%ROWTYPE;
    lv_upd      VARCHAR2(1) := 'N';
    --
    PROCEDURE get_db_rec(pi_profile_id IN sdl_profiles.sp_id%TYPE
                        ,pi_sam_id IN sdl_attribute_mapping.sam_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM sdl_attribute_mapping
       WHERE sam_sp_id = pi_profile_id
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
    validate_notnull(pi_parameter_desc  => 'File Attribute Name'
                    ,pi_parameter_value => pi_new_file_attribute_name);
    --
    validate_notnull(pi_parameter_desc  => 'Source Column Name'
                    ,pi_parameter_value => pi_new_view_column_name);
    --
    validate_notnull(pi_parameter_desc  => 'Target Column Name'
                    ,pi_parameter_value => pi_new_ne_column_name);
    --
    IF active_batch_exists(pi_profile_id) THEN
      RAISE_APPLICATION_ERROR (-20028,
                               'Update not allowed. Attributes are already mapped to an active submission of the Profile '|| get_profile_name(pi_profile_id));
    END IF;
    --
    get_db_rec(pi_profile_id => pi_profile_id, pi_sam_id => pi_sam_id);
    --
    /*
    ||Compare old with DB
    */
    IF lr_db_rec.sam_file_attribute_name != pi_old_file_attribute_name
      OR (lr_db_rec.sam_file_attribute_name IS NULL AND pi_old_file_attribute_name IS NOT NULL)
      OR (lr_db_rec.sam_file_attribute_name IS NOT NULL AND pi_old_file_attribute_name IS NULL)
      -- Source Column Name
      OR (lr_db_rec.sam_view_column_name != pi_old_view_column_name)
      OR (lr_db_rec.sam_view_column_name IS NULL AND pi_old_view_column_name IS NOT NULL)
      OR (lr_db_rec.sam_view_column_name IS NOT NULL AND pi_old_view_column_name IS NULL)
      -- Source Attribute Formula
      OR (lr_db_rec.sam_attribute_formula != pi_old_attribute_formula)
      OR (lr_db_rec.sam_attribute_formula IS NULL AND pi_old_attribute_formula IS NOT NULL)
      OR (lr_db_rec.sam_attribute_formula IS NOT NULL AND pi_old_attribute_formula IS NULL)
      -- Target Column Name
      OR (lr_db_rec.sam_ne_column_name != pi_old_ne_column_name)
      OR (lr_db_rec.sam_ne_column_name IS NULL AND pi_old_ne_column_name IS NOT NULL)
      OR (lr_db_rec.sam_ne_column_name IS NOT NULL AND pi_old_ne_column_name IS NULL)
    THEN
      --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
      IF pi_old_file_attribute_name != pi_new_file_attribute_name
        OR (pi_old_file_attribute_name IS NULL AND pi_new_file_attribute_name IS NOT NULL)
        OR (pi_old_file_attribute_name IS NOT NULL AND pi_new_file_attribute_name IS NULL)
      THEN
        lv_upd := 'Y';
      END IF;
      --
      IF pi_old_view_column_name != pi_new_view_column_name
        OR (pi_old_view_column_name IS NULL AND pi_new_view_column_name IS NOT NULL)
        OR (pi_old_view_column_name IS NOT NULL AND pi_new_view_column_name IS NULL)
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
      IF pi_old_ne_column_name != pi_new_ne_column_name
        OR (pi_old_ne_column_name IS NULL AND pi_new_ne_column_name IS NOT NULL)
        OR (pi_old_ne_column_name IS NOT NULL AND pi_new_ne_column_name IS NULL)
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
        UPDATE sdl_attribute_mapping
           SET sam_file_attribute_name = pi_new_file_attribute_name
              ,sam_view_column_name = pi_new_view_column_name
              ,sam_attribute_formula = pi_new_attribute_formula
              ,sam_ne_column_name = pi_new_ne_column_name
         WHERE sam_sp_id = pi_profile_id
           AND sam_id = pi_sam_id;
        --
      END IF;
    END IF;
    --
    update_profile_views(pi_profile_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_attribute_mapping(pi_profile_id        IN  sdl_profiles.sp_id%TYPE
                                    ,pi_sam_id            IN  sdl_attribute_mapping.sam_id%TYPE
                                    ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor    OUT sys_refcursor)
  IS
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
       AND sam_id = pi_sam_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_attribute_mapping;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_column_lookup(pi_nlt_id           IN  nm_linear_types.nlt_id%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT vc.column_name
          ,vc.field_type
          ,vc.field_length
          ,vc.dec_places
          ,vc.format_mask
          ,SUBSTR(UPPER(REPLACE(vc.column_prompt,' ','_')),1,30) column_prompt
          ,vc.mandatory
          ,vc.group_type
      FROM v_nm_nw_columns vc,
           nm_linear_types nlt
     WHERE vc.network_type = nlt.nlt_nt_type
       AND nlt.nlt_id = pi_nlt_id
    ORDER BY vc.rn ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_column_lookup;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_attribute_adjustment_rules(pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                                          ,po_message_cursor   OUT sys_refcursor
                                          ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    --
      OPEN po_cursor FOR
    SELECT saar.saar_id saar_id
          ,saar.saar_sp_id profile_id
          ,get_profile_name(saar.saar_sp_id) profile_name
        --,awlrs_sdl_profiles_api.get_profile_name(saar.saar_sp_id) profile_name
          ,saar.saar_target_attribute_name target_attribute_name
          ,saar.saar_source_value source_value
          ,saar.saar_adjust_to_value adjust_to_value
          ,saar.saar_created_by created_by
          ,saar.saar_date_created created_on
          ,saar.saar_modified_by modified_by
          ,saar.saar_date_modified modified_on
      FROM sdl_attribute_adjustment_rules saar
     WHERE saar.saar_sp_id = pi_profile_id
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
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT saar.saar_id saar_id,
                                                    saar.saar_sp_id profile_id,
                                                    awlrs_sdl_profiles_api.get_profile_name(saar.saar_sp_id) profile_name,
                                                    saar.saar_target_attribute_name target_attribute_name,
                                                    saar.saar_source_value source_value,
                                                    saar.saar_adjust_to_value adjust_to_value,
                                                    saar.saar_created_by created_by,
                                                    saar.saar_date_created created_on,
                                                    saar.saar_modified_by modified_by,
                                                    saar.saar_date_modified modified_on
                                               FROM sdl_attribute_adjustment_rules saar
                                              WHERE saar.saar_sp_id = :pi_profile_id';
    --
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT saar_id'
                                              ||' ,profile_id'
                                              ||' ,profile_name'
                                              ||' ,target_attribute_name'
                                              ||' ,source_value'
                                              ||' ,adjust_to_value'
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
      awlrs_util.add_column_data(pi_cursor_col   => 'target_attribute_name'
                                ,pi_query_col    => 'saar_target_attribute_name'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'source_value'
                                ,pi_query_col    => 'saar_source_value'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'adjust_to_value'
                                ,pi_query_col    => 'saar_adjust_to_value'
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
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'saar.saar_id')||') a)'
                     ||CHR(10)||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_profile_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_profile_id
             ,lv_lower_index;
    END IF;
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
  --
  PROCEDURE get_attribute_adjustment_rule(pi_saar_id          IN  sdl_attribute_adjustment_rules.saar_id%TYPE
                                         ,pi_profile_id       IN  sdl_profiles.sp_id%TYPE
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
  IS
    --
  BEGIN
    -- probably not used anywhere in web api or UI.. verify and delete
    --
      OPEN po_cursor FOR
    SELECT saar.saar_id saar_id
          ,saar.saar_sp_id profile_id
          ,get_profile_name(saar.saar_sp_id) profile_name
        --,awlrs_sdl_profiles_api.get_profile_name(saar.saar_sp_id) profile_name
          ,saar.saar_target_attribute_name target_attribute_name
          ,saar.saar_source_value source_value
          ,saar.saar_adjust_to_value adjust_to_value
      FROM sdl_attribute_adjustment_rules saar
     WHERE saar.saar_id = pi_saar_id
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
                                         ,pi_target_attrib_name  IN  sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                                         ,pi_source_value        IN  sdl_attribute_adjustment_rules.saar_source_value%TYPE
                                         ,pi_adjust_to_value     IN  sdl_attribute_adjustment_rules.saar_adjust_to_value%TYPE
                                         ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor      OUT sys_refcursor)
  IS
    --
    CURSOR c_rule_exists(cp_profile_id         sdl_profiles.sp_id%TYPE
                        ,cp_target_attrib_name sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                        ,cp_source_value       sdl_attribute_adjustment_rules.saar_source_value%TYPE)
    IS
    SELECT 1
      FROM sdl_attribute_adjustment_rules saar
     WHERE saar.saar_sp_id = cp_profile_id
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
    OPEN  c_rule_exists(pi_profile_id, pi_target_attrib_name, pi_source_value);
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
              ,saar_adjust_to_value)
    VALUES (pi_profile_id
           ,pi_target_attrib_name
           ,pi_source_value
           ,pi_adjust_to_value);
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
                                         ,pi_old_target_attribute_name IN  sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                                         ,pi_new_target_attribute_name IN  sdl_attribute_adjustment_rules.saar_target_attribute_name%TYPE
                                         ,pi_old_source_value          IN  sdl_attribute_adjustment_rules.saar_source_value%TYPE
                                         ,pi_new_source_value          IN  sdl_attribute_adjustment_rules.saar_source_value%TYPE
                                         ,pi_old_adjust_to_value       IN  sdl_attribute_adjustment_rules.saar_adjust_to_value%TYPE
                                         ,pi_new_adjust_to_value       IN  sdl_attribute_adjustment_rules.saar_adjust_to_value%TYPE
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
    IF lr_db_rec.saar_target_attribute_name != pi_old_target_attribute_name
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
    THEN
      --Updated by another user
      hig.raise_ner(pi_appl => 'AWLRS'
                   ,pi_id   => 24);
    ELSE
      /*
      ||Compare old with New
      */
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
      IF lv_upd = 'N'
      THEN
        --There are no changes to be applied
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 25);
      ELSE
        --
        UPDATE sdl_attribute_adjustment_rules
           SET saar_target_attribute_name = pi_new_target_attribute_name
              ,saar_source_value = pi_new_source_value
              ,saar_adjust_to_value = pi_new_adjust_to_value
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
    OPEN po_cursor FOR
    SELECT hco_code domain_code
          ,hco_code || ' - ' || hco_meaning description
      FROM hig_codes
     WHERE hco_domain = (SELECT vnc.domain
                           FROM sdl_attribute_mapping sam
                               ,sdl_profiles sp
                               --,sdl_file_submissions sfs
                               ,v_nm_nw_columns vnc
                               ,nm_linear_types nlt
                          WHERE sam.sam_sp_id = sp.sp_id
                           --AND sp.sp_id = sfs.sfs_sp_id
                            AND sp.sp_nlt_id = nlt.nlt_id
                            AND sam.sam_ne_column_name = vnc.column_name
                            AND vnc.network_type = nlt.nlt_nt_type
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
    OPEN po_cursor FOR
    SELECT ssrl_id
          ,ssrl_sp_id
          ,ssrl_percent_from
          ,ssrl_percent_to
          ,CASE WHEN ssrl_percent_from = -999.999
                THEN '< ' || ROUND(ssrl_percent_to) || '%'
                WHEN ssrl_percent_to = 999.999
                THEN ssrl_percent_from || '%' || ' +'
                ELSE ROUND(ssrl_percent_from) ||'-'|| ROUND(ssrl_percent_to) || '%'
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
END awlrs_sdl_profiles_api;
/