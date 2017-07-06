CREATE OR REPLACE PACKAGE BODY awlrs_bulk_update_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_bulk_update_api.pkb-arc   1.2   06 Jul 2017 21:31:22   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_bulk_update_api.pkb  $
  --       Date into PVCS   : $Date:   06 Jul 2017 21:31:22  $
  --       Date fetched Out : $Modtime:   06 Jul 2017 17:27:18  $
  --       Version          : $Revision:   1.2  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.2  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_bulk_update_api';
  --
  g_disp_derived     BOOLEAN := TRUE;
  g_disp_inherited   BOOLEAN := TRUE;
  g_disp_primary_ad  BOOLEAN := TRUE;
  --
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version
    RETURN VARCHAR2 IS
  BEGIN
    RETURN g_sccsid;
  END get_version;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version
    RETURN VARCHAR2 IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_attribs(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                               ,pi_nt_type          IN  nm_types.nt_type%TYPE
                               ,pi_group_type       IN  nm_group_types_all.ngt_group_type%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    lv_cursor            sys_refcursor;
    --
  BEGIN
    --
    awlrs_element_api.get_nt_flex_attribs(pi_ne_id            => pi_ne_id
                                         ,pi_nt_type          => pi_nt_type
                                         ,pi_group_type       => pi_group_type
                                         ,pi_disp_derived     => g_disp_derived
                                         ,pi_disp_inherited   => g_disp_inherited
                                         ,pi_disp_primary_ad  => g_disp_primary_ad
                                         ,po_message_severity => lv_message_severity
                                         ,po_message_cursor   => lv_message_cursor
                                         ,po_cursor           => lv_cursor);
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    po_cursor := lv_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_nt_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nt_flex_attribs(pi_ne_id      IN nm_elements_all.ne_id%TYPE
                              ,pi_nt_type    IN nm_types.nt_type%TYPE
                              ,pi_group_type IN nm_group_types_all.ngt_group_type%TYPE)
    RETURN awlrs_element_api.flex_attr_tab IS
    --
    lt_attrib_values  awlrs_element_api.flex_attr_tab;
    --
  BEGIN
    --
    lt_attrib_values := awlrs_element_api.get_nt_flex_attribs(pi_ne_id           => pi_ne_id
                                                             ,pi_nt_type         => pi_nt_type
                                                             ,pi_group_type      => pi_group_type
                                                             ,pi_disp_derived    => g_disp_derived
                                                             ,pi_disp_inherited  => g_disp_inherited
                                                             ,pi_disp_primary_ad => g_disp_primary_ad);
    --
    RETURN lt_attrib_values;
    --
  END get_nt_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_element_attribs(pi_nt_type         IN nm_types.nt_type%TYPE
                                  ,pi_group_type      IN nm_group_types_all.ngt_group_type%TYPE
                                  ,pi_ne_ids          IN awlrs_util.ne_id_tab
                                  ,pi_element_attribs IN awlrs_element_api.flex_attr_tab)
    IS
    --
    lr_attribute  nm3_bulk_attrib_upd.l_attrib_rec;
    --
    CURSOR get_nav(cp_nt_type  IN VARCHAR2
                  ,cp_col_name IN VARCHAR2
                  ,cp_value    IN VARCHAR2)
        IS
    SELECT nav_disp_ord
          ,nav_nt_type
          ,nav_inv_type
          ,nav_gty_type
          ,nav_col_name
          ,nav_col_type
          ,nav_col_updatable
          ,nav_parent_type_inc
          ,nav_child_type_inc
          ,cp_value nav_value
      FROM nm_attrib_view_vw
     WHERE nav_nt_type = cp_nt_type
       AND nav_col_name = cp_col_name
         ;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT update_element_attribs_sp;
    --
    IF NOT awlrs_util.historic_mode
     THEN
        /*
        ||Initialise the bulk array;
        */
        nm3_bulk_attrib_upd.delete_array;
        /*
        ||Set the element ids for the update.
        */
        FOR i IN 1..pi_ne_ids.COUNT LOOP
          --
          nm3_bulk_attrib_upd.add_remove_ne_id(pi_ne_ids(i),i,'A');
          --
        END LOOP;
        /*
        ||Set the attribute values for the update.
        */
        FOR i IN 1.. pi_element_attribs.COUNT LOOP
          --
          OPEN  get_nav(cp_nt_type  => pi_nt_type
                       ,cp_col_name => pi_element_attribs(i).column_name
                       ,cp_value    => pi_element_attribs(i).char_value);
          FETCH get_nav
           INTO lr_attribute;
          CLOSE get_nav;
          --
          nm3_bulk_attrib_upd.build_att_array(lr_attribute,i);
          --
        END LOOP;
        /*
        ||Perform the update.
        */
        nm3_bulk_attrib_upd.run_ddl;
        --
    ELSE
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 6);
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_element_attribs_sp;
        RAISE;
  END update_element_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_element_attribs(pi_nt_type             IN  nm_types.nt_type%TYPE
                                  ,pi_group_type          IN  nm_group_types_all.ngt_group_type%TYPE
                                  ,pi_ne_ids              IN  awlrs_util.ne_id_tab
                                  ,pi_attrib_column_names IN  awlrs_element_api.attrib_column_name_tab
                                  ,pi_attrib_prompts      IN  awlrs_element_api.attrib_prompt_tab
                                  ,pi_attrib_char_values  IN  awlrs_element_api.attrib_char_value_tab
                                  ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT sys_refcursor)
    IS
    --
    lt_element_attribs  awlrs_element_api.flex_attr_tab;
    --
  BEGIN
    --
    IF pi_attrib_column_names.COUNT != pi_attrib_prompts.COUNT
     OR pi_attrib_column_names.COUNT != pi_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_bulk_update_api.update_element_attribs');
    END IF;
    --
    FOR i IN 1..pi_attrib_column_names.COUNT LOOP
      --
      lt_element_attribs(i).column_name := pi_attrib_column_names(i);
      lt_element_attribs(i).prompt      := pi_attrib_prompts(i);
      lt_element_attribs(i).char_value  := pi_attrib_char_values(i);
      --
    END LOOP;
    --
    update_element_attribs(pi_nt_type         => pi_nt_type
                          ,pi_group_type      => pi_group_type
                          ,pi_ne_ids          => pi_ne_ids
                          ,pi_element_attribs => lt_element_attribs);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_element_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_parent_group_types(pi_child_nt_type    IN  nm_types.nt_type%TYPE
                                  ,pi_child_group_type IN  nm_group_types_all.ngt_group_type%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor
                                  ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql  nm3type.max_varchar2 := 'SELECT ngt_nt_type           network_type'
                         ||CHR(10)||'      ,ngt_group_type        group_type'
                         ||CHR(10)||'      ,ngt_descr             group_type_descr'
                         ||CHR(10)||'      ,ngt_exclusive_flag    is_exclusive'
                         ||CHR(10)||'      ,ngt_linear_flag       is_linear'
                         ||CHR(10)||'      ,ngt_partial           is_partial'
                         ||CHR(10)||'      ,ngt_sub_group_allowed sub_group_allowed'
                         ||CHR(10)||'      ,ngt_mandatory         mandatory'
                         ||CHR(10)||'  FROM nm_group_types'
    ;
    --
  BEGIN
    --
    IF pi_child_group_type IS NOT NULL
     THEN
        --
        OPEN po_cursor FOR lv_sql
                ||CHR(10)||' WHERE ngt_nt_type != ''NSGN'''
                ||CHR(10)||'   AND ngt_partial != ''Y'''
                ||CHR(10)||'   AND ngt_group_type IN(SELECT ngr_parent_group_type '
                ||CHR(10)||'                           FROM nm_group_relations  '
                ||CHR(10)||'                          WHERE ngr_child_group_type = :group_type )'
                ||CHR(10)||'   AND ngt_group_type NOT IN(SELECT nti_nw_parent_type'
                ||CHR(10)||'                               FROM nm_type_inclusion'
                ||CHR(10)||'                              WHERE nti_nw_child_type = :nt_type)'
        USING pi_child_group_type
             ,pi_child_nt_type
        ;
        --
    ELSE
        --
        OPEN po_cursor FOR lv_sql
                ||CHR(10)||' WHERE ngt_nt_type NOT IN(''NSGN'',''NALI'')'
                ||CHR(10)||'   AND ngt_partial != ''Y'''
                ||CHR(10)||'   AND ngt_group_type IN(SELECT nng_group_type '
                ||CHR(10)||'                           FROM nm_nt_groupings  '
                ||CHR(10)||'                          WHERE nng_nt_type = :nt_type )'
                ||CHR(10)||'   AND ngt_group_type NOT IN(SELECT nti_nw_parent_type'
                ||CHR(10)||'                               FROM nm_type_inclusion'
                ||CHR(10)||'                              WHERE nti_nw_child_type = :nt_type)'
        USING pi_child_nt_type
             ,pi_child_nt_type
        ;
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
  END get_parent_group_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_group_memberships(pi_member_ne_ids               IN  awlrs_util.ne_id_tab
                                    ,pi_group_ne_ids                IN  awlrs_util.ne_id_tab
                                    ,pi_enddate_existing_membership IN  VARCHAR2
                                    ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lv_exclusive  nm_group_types_all.ngt_exclusive_flag%TYPE;
    --
    FUNCTION check_types
      RETURN nm_group_types_all.ngt_exclusive_flag%TYPE IS
      --
      TYPE nt_tab IS TABLE OF nm_types.nt_type%TYPE;
      lt_nt  nt_tab;
      --
      TYPE gty_tab IS TABLE OF nm_group_types_all.ngt_group_type%TYPE;
      lt_gty  gty_tab;
      --
    BEGIN
      --
      SELECT DISTINCT ne.ne_nt_type
        BULK COLLECT
        INTO lt_nt
        FROM TABLE(CAST(nm3_bulk_attrib_upd.l_ne_id_array AS nm_ne_id_array)) x
            ,nm_elements ne
       WHERE x.ne_id = ne.ne_id
           ;
      --
      IF lt_nt.COUNT > 1
       THEN
          /*
          ||The Element Ids given must all be of the same Network\Group type.
          */
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 50
                       ,pi_supplementary_info => 'awlrs_bulk_update_api.update_group_memberships (member ids)');
      END IF;
      --
      SELECT DISTINCT ne.ne_gty_group_type
        BULK COLLECT
        INTO lt_gty
        FROM TABLE(CAST(nm3_bulk_attrib_upd.l_grp_ne_id_array AS nm_ne_id_array)) x
            ,nm_elements ne
       WHERE x.ne_id = ne.ne_id
           ;
      --
      IF lt_gty.COUNT > 1
       THEN
          /*
          ||The Element Ids given must all be of the same Network\Group type.
          */
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 50
                       ,pi_supplementary_info => 'awlrs_bulk_update_api.update_group_memberships (parent ids)');
      END IF;
      --
      RETURN nm3get.get_ngt(pi_ngt_group_type => lt_gty(1)).ngt_exclusive_flag;
      --
    END check_types;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT update_group_memberships_sp;
    --
    IF NOT awlrs_util.historic_mode
     THEN
        IF pi_member_ne_ids.COUNT > 0
         AND pi_group_ne_ids.COUNT > 0
         THEN
            /*
            ||Initialise the bulk array;
            */
            nm3_bulk_attrib_upd.delete_array;
            /*
            ||Set the member ids for the update.
            */
            FOR i IN 1..pi_member_ne_ids.COUNT LOOP
              --
              nm3_bulk_attrib_upd.add_remove_ne_id(pi_member_ne_ids(i),i,'A');
              --
            END LOOP;
            /*
            ||Set the group ids for the update.
            */
            FOR i IN 1..pi_group_ne_ids.COUNT LOOP
              --
              nm3_bulk_attrib_upd.add_remove_grp_ne_id(pi_group_ne_ids(i),i,'A');
              --
            END LOOP;
            /*
            ||Get the exclusive flag for the target group type.
            */
            lv_exclusive := check_types;
            --
            IF lv_exclusive = 'Y'
             AND pi_group_ne_ids.COUNT > 1
             THEN
                hig.raise_ner(pi_appl => 'AWLRS'
                             ,pi_id   => 51);             
            END IF;
            /*
            ||Validate the update.
            */
            DECLARE
              exclusive_group EXCEPTION;
              PRAGMA EXCEPTION_INIT(exclusive_group, -20600);
              non_exclusive_group EXCEPTION;
              PRAGMA EXCEPTION_INIT(non_exclusive_group, -20601);
            BEGIN
              nm3_bulk_attrib_upd.validate_data(lv_exclusive);
            EXCEPTION
              WHEN exclusive_group
               THEN
                  IF pi_enddate_existing_membership != 'Y'
                   THEN
                      /*
                      ||The selected Parent Group Type is Exclusive, please use the End-Date Existing Memberships option.
                      */
                      hig.raise_ner(pi_appl => 'AWLRS'
                                   ,pi_id   => 49);
                  END IF;
              WHEN non_exclusive_group
               THEN
                  /*
                  ||This is been dealt with by having the
                  ||pi_enddate_existing_membership parameter.
                  */
                  NULL;
              WHEN others
               THEN
                  RAISE;
            END;
            /*
            ||Run the update.
            */
            nm3_bulk_attrib_upd.update_groups_members(lv_exclusive,pi_enddate_existing_membership);
            --
        END IF;
    ELSE
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 6);
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_group_memberships_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_group_memberships;

END awlrs_bulk_update_api;
/
