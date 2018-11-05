CREATE OR REPLACE PACKAGE BODY awlrs_merge_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_merge_api.pkb-arc   1.12   Nov 05 2018 16:54:28   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_merge_api.pkb  $
  --       Date into PVCS   : $Date:   Nov 05 2018 16:54:28  $
  --       Date fetched Out : $Modtime:   Nov 05 2018 10:38:04  $
  --       Version          : $Revision:   1.12  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT VARCHAR2 (2000) := '$Revision:   1.12  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_merge_api';
  --
  g_disp_derived    BOOLEAN := FALSE;
  g_disp_inherited  BOOLEAN := FALSE;
  g_disp_primary_ad BOOLEAN := FALSE;
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
  PROCEDURE init_element_globals
    IS
    --
    lv_empty_rec  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    g_new_element := lv_empty_rec;
    --
  END init_element_globals;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_for_lost_connectivity(pi_ne_id1           IN     nm_elements_all.ne_id%TYPE
                                       ,pi_ne_id2           IN     nm_elements_all.ne_id%TYPE
                                       ,po_message_severity IN OUT hig_codes.hco_code%TYPE
                                       ,po_message_tab      IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE;
    --
    lost_connectivity  EXCEPTION;
    PRAGMA exception_init(lost_connectivity, -20150);
    --
  BEGIN
    --
    nm3merge.check_for_lost_connectivity(p_ne_id_1 => pi_ne_id1
                                        ,p_ne_id_2 => pi_ne_id2);
    --
  EXCEPTION
    WHEN lost_connectivity
     THEN
        awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                         ,pi_ner_id      => 186
                                         ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                         ,po_message_tab => po_message_tab);
        po_message_severity := awlrs_util.c_msg_cat_ask_continue;
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_message_tab      => po_message_tab);
  END check_for_lost_connectivity;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_for_poe_at_node(pi_ne_id1           IN     nm_elements_all.ne_id%TYPE
                                 ,pi_ne_id2           IN     nm_elements_all.ne_id%TYPE
                                 ,po_message_severity IN OUT hig_codes.hco_code%TYPE
                                 ,po_message_tab      IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    poe_at_node  EXCEPTION;
    --
    lv_shared_node  nm_elements.ne_no_start%TYPE;
    lv_parent_id    nm_elements.ne_id%TYPE;
    lv_sql          VARCHAR2(1000);
    --
    CURSOR get_nti(cp_nt_type nm_type_inclusion.nti_nw_child_type%TYPE)
        IS
    SELECT *
      FROM nm_type_inclusion
     WHERE nti_nw_child_type = cp_nt_type
         ;
    --
    TYPE nti_tab IS TABLE OF nm_type_inclusion%ROWTYPE;
    lt_nti  nti_tab;
    --
  BEGIN
    --
    lv_shared_node := nm3net.get_element_shared_node(pi_ne_id1 => pi_ne_id1
                                                    ,pi_ne_id2 => pi_ne_id2);
    --
    IF lv_shared_node IS NOT NULL
     THEN
        --
        g_element := nm3net.get_ne(pi_ne_id => pi_ne_id1);
        --
        OPEN  get_nti(g_element.ne_nt_type);
        FETCH get_nti
         BULK COLLECT
         INTO lt_nti;
        CLOSE get_nti;
        --
        FOR i IN 1..lt_nti.COUNT LOOP
          --
          lv_sql := 'DECLARE'
         ||CHR(10)||'  CURSOR get_parent(cp_type IN nm_types.nt_type%TYPE)'
         ||CHR(10)||'      IS'
         ||CHR(10)||'  SELECT ne_id'
         ||CHR(10)||'    FROM nm_elements'
         ||CHR(10)||'   WHERE ne_nt_type = cp_type'
         ||CHR(10)||'     AND '||lt_nti(i).nti_parent_column||' = awlrs_merge_api.g_element.'||lt_nti(i).nti_child_column
         ||CHR(10)||'       ;'
         ||CHR(10)||'BEGIN'
         ||CHR(10)||'  OPEN  get_parent(:nt_type);'
         ||CHR(10)||'  FETCH get_parent'
         ||CHR(10)||'   INTO :parent_id;'
         ||CHR(10)||'  CLOSE get_parent;'
         ||CHR(10)||'EXCEPTION'
         ||CHR(10)||'  WHEN no_data_found'
         ||CHR(10)||'   THEN'
         ||CHR(10)||'      hig.raise_ner(pi_appl => ''AWLRS'''
         ||CHR(10)||'                   ,pi_id   => 28);'
         ||CHR(10)||'END;'
          ;
          EXECUTE IMMEDIATE lv_sql USING lt_nti(i).nti_nw_parent_type, OUT lv_parent_id;
          --
          IF nm3net.is_node_poe(pi_route_id => lv_parent_id
                               ,pi_node_id  => lv_shared_node)
           THEN
              RAISE poe_at_node;
          END IF;
          --
        END LOOP;
        --
    END IF;
    --
  EXCEPTION
    WHEN poe_at_node
     THEN
        awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                         ,pi_ner_id      => 96
                                         ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                         ,po_message_tab => po_message_tab);
        po_message_severity := awlrs_util.c_msg_cat_ask_continue;
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_message_tab      => po_message_tab);
  END check_for_poe_at_node;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_elements_can_be_merged(pi_ne_id1           IN  nm_elements_all.ne_id%TYPE
                                        ,pi_ne_id2           IN  nm_elements_all.ne_id%TYPE
                                        ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Run any checks that simply result in an error
    ||that should prevent the user executing the merge.
    */
    nm3merge.check_elements_can_be_merged(pi_ne_id_1        => pi_ne_id1
                                         ,pi_ne_id_2        => pi_ne_id2
                                         ,pi_effective_date => pi_effective_date);
    --
    IF nm3net.is_nt_linear(p_nt_type => nm3net.get_ne(pi_ne_id1).ne_nt_type) != 'Y'
     THEN
        --Cannot perform operation on non-linear network types
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 336);
    END IF;
    --
    /*
    ||If the spatial data for the Elements is contained in ESRI SDE format BLOBS
    ||Then do not allow the operation.
    */
    IF nm3sdm.prevent_operation(p_ne_id => pi_ne_id1)
     OR nm3sdm.prevent_operation(p_ne_id => pi_ne_id2)
     THEN
        --GIS shape in place, network editing function not allowed.
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 65);
    END IF;
    --
    /*
    ||The following checks may require the user to be prompted to confirm
    ||that they wish to continue, any checks that simply result in an
    ||error indicating that the elements are not appropriate for merge
    ||should be executed before these checks.
    */
    check_for_lost_connectivity(pi_ne_id1           => pi_ne_id1
                               ,pi_ne_id2           => pi_ne_id2
                               ,po_message_severity => lv_severity
                               ,po_message_tab      => lt_messages);
    --
    IF lv_severity != awlrs_util.c_msg_cat_error
     THEN
        check_for_poe_at_node(pi_ne_id1           => pi_ne_id1
                             ,pi_ne_id2           => pi_ne_id2
                             ,po_message_severity => lv_severity
                             ,po_message_tab      => lt_messages);
    END IF;
    --
    IF lt_messages.COUNT > 0
     THEN
        awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                     ,po_cursor      => po_message_cursor);
        awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                       ,po_message_severity => po_message_severity);
    ELSE
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_elements_can_be_merged;

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
  PROCEDURE do_rescale(pi_ne_id            IN     nm_elements.ne_id%TYPE
                      ,pi_offset_st        IN     NUMBER
                      ,pi_use_history      IN     VARCHAR2
                      ,po_message_severity IN OUT hig_codes.hco_code%TYPE
                      ,po_message_tab      IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_message_cursor  sys_refcursor;
    --
    lt_messages  awlrs_util.message_tab;
    --
  BEGIN
    --
    awlrs_group_api.rescale_route(pi_ne_id            => pi_ne_id
                                 ,pi_offset_st        => pi_offset_st
                                 ,pi_use_history      => pi_use_history
                                 ,po_message_severity => po_message_severity
                                 ,po_message_cursor   => lv_message_cursor);
    --
    FETCH lv_message_cursor
     BULK COLLECT
     INTO lt_messages;
    CLOSE lv_message_cursor;
    --
    FOR i IN 1..lt_messages.COUNT LOOP
      --
      awlrs_util.add_message(pi_category    => lt_messages(i).category
                            ,pi_message     => lt_messages(i).message
                            ,po_message_tab => po_message_tab);
      --
    END LOOP;
    --
  END do_rescale;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_merge(pi_ne_id1              IN     nm_elements_all.ne_id%TYPE
                    ,pi_ne_id2              IN     nm_elements_all.ne_id%TYPE
                    ,pi_reason              IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_new_element_attribs IN     awlrs_element_api.flex_attr_tab
                    ,pi_do_rescale_parents  IN     VARCHAR2 DEFAULT 'N'
                    ,pi_effective_date      IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,pi_run_checks          IN     VARCHAR2 DEFAULT 'Y'
                    ,po_new_ne_id           IN OUT nm_elements_all.ne_id%TYPE
                    ,po_message_severity       OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lv_new_node_id  nm_elements.ne_no_start%TYPE;
    lv_new_np_id    nm_nodes.no_np_id%TYPE;
    lv_create_node  BOOLEAN := TRUE;
    --
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    --
    record_locked EXCEPTION;
    PRAGMA exception_init(record_locked, -54);
    not_connected EXCEPTION;
    PRAGMA exception_init(not_connected, -20004);
    xsp_violation EXCEPTION;
    PRAGMA exception_init(xsp_violation, -20009);
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    CURSOR get_linear_groups(cp_ne_id IN nm_elements_all.ne_id%TYPE)
        IS
    SELECT nm_ne_id_in group_id
          ,nm3net.get_min_slk(pi_ne_id => nm_ne_id_in) min_slk
      FROM nm_members
     WHERE nm_ne_id_of = cp_ne_id
       AND nm_obj_type IN(SELECT ngt_group_type
                            FROM nm_group_types
                           WHERE ngt_linear_flag = 'Y')
         ;
    --
    TYPE groups_tab IS TABLE OF get_linear_groups%ROWTYPE;
    lt_groups  groups_tab;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT do_merge_sp;
    /*
    ||Run checks to make sure the element can be reclassified unless
    ||the calling code explicitly says otherwise.
    */
    IF pi_run_checks = 'Y'
     THEN
        check_elements_can_be_merged(pi_ne_id1           => pi_ne_id1
                                    ,pi_ne_id2           => pi_ne_id2
                                    ,pi_effective_date   => pi_effective_date
                                    ,po_message_severity => lv_severity
                                    ,po_message_cursor   => lv_message_cursor);
    END IF;
    /*
    ||If the checks are ok do the merge.
    */
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN
        --
        init_element_globals;
        --
        lr_ne := nm3get.get_ne(pi_ne_id1);
        --
        awlrs_element_api.build_element_rec(pi_nt_type    => lr_ne.ne_nt_type
                                           ,pi_global     => 'awlrs_merge_api.g_new_element'
                                           ,pi_attributes => pi_new_element_attribs);
        --
        BEGIN
          nm3merge.do_merge_datum_or_group(pi_ne_id_1           => pi_ne_id1
                                          ,pi_ne_id_2           => pi_ne_id2
                                          ,pi_effective_date    => pi_effective_date
                                          ,pi_merge_at_node     => NULL /* TODO - Do we need to support this? */
                                          ,pi_ne_type           => NULL
                                          ,pi_ne_nt_type        => NULL
                                          ,pi_ne_descr          => NULL
                                          ,pi_ne_length         => NULL
                                          ,pi_ne_admin_unit     => NULL
                                          ,pi_ne_gty_group_type => NULL
                                          ,pi_ne_no_start       => NULL
                                          ,pi_ne_no_end         => NULL
                                          ,pi_ne_unique         => g_new_element.ne_unique
                                          ,pi_ne_owner          => g_new_element.ne_owner
                                          ,pi_ne_name_1         => g_new_element.ne_name_1
                                          ,pi_ne_name_2         => g_new_element.ne_name_2
                                          ,pi_ne_prefix         => g_new_element.ne_prefix
                                          ,pi_ne_number         => g_new_element.ne_number
                                          ,pi_ne_sub_type       => g_new_element.ne_sub_type
                                          ,pi_ne_group          => g_new_element.ne_group
                                          ,pi_ne_sub_class      => g_new_element.ne_sub_class
                                          ,pi_ne_nsg_ref        => g_new_element.ne_nsg_ref
                                          ,pi_ne_version_no     => g_new_element.ne_version_no
                                          ,pi_test_poe_at_node  => 'N'
                                          ,po_ne_id_new         => po_new_ne_id
                                          ,pi_neh_descr         => pi_reason);
        EXCEPTION
          WHEN not_connected
           THEN
              hig.raise_ner(pi_appl => 'NET'
                           ,pi_id   => 168);
          WHEN xsp_violation
           THEN
              hig.raise_ner(pi_appl => 'NET'
                           ,pi_id   => 173);
          WHEN record_locked
           THEN
              hig.raise_ner(pi_appl => 'HIG'
                           ,pi_id   => 33);
        END;
        /*
        ||Rescale any linear groups the element belongs to.
        */
        IF pi_do_rescale_parents = 'Y'
         THEN
            --
            OPEN  get_linear_groups(po_new_ne_id);
            FETCH get_linear_groups
             BULK COLLECT
             INTO lt_groups;
            CLOSE get_linear_groups;
            --
            FOR i IN 1..lt_groups.COUNT LOOP
              --
              lv_severity := awlrs_util.c_msg_cat_success;
              lt_messages.DELETE;
              --
              do_rescale(pi_ne_id            => lt_groups(i).group_id
                        ,pi_offset_st        => lt_groups(i).min_slk
                        ,pi_use_history      => 'Y'
                        ,po_message_severity => lv_severity
                        ,po_message_tab      => lt_messages);
              --
              IF lv_severity = awlrs_util.c_msg_cat_ask_continue
               THEN
                  --
                  lt_messages.DELETE;
                  --
                  do_rescale(pi_ne_id            => lt_groups(i).group_id
                            ,pi_offset_st        => lt_groups(i).min_slk
                            ,pi_use_history      => 'N'
                            ,po_message_severity => lv_severity
                            ,po_message_tab      => lt_messages);
                  --
              END IF;
              --
              IF lv_severity != awlrs_util.c_msg_cat_success
               THEN
                  /*
                  ||If an error has ocured rescaling a group end the whole operation.
                  */
                  EXIT;
                  --
              END IF;
              --
            END LOOP;
        END IF;
        /*
        ||If errors occurred rollback.
        */
        IF lv_severity IN(awlrs_util.c_msg_cat_error,awlrs_util.c_msg_cat_ask_continue)
         THEN
            ROLLBACK TO do_merge_sp;
            po_new_ne_id := NULL;
        END IF;
        /*
        ||If there are any messages to return then create a cursor for them.
        */
        IF lt_messages.COUNT > 0
         THEN
            awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                         ,po_cursor      => po_message_cursor);
            awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                           ,po_message_severity => po_message_severity);
        ELSE
            awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                                 ,po_cursor           => po_message_cursor);
        END IF;
        --
    ELSE
        --
        po_message_severity := lv_severity;
        po_message_cursor := lv_message_cursor;
        --
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO do_merge_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
    --
  END do_merge;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_merge(pi_ne_id1                   IN     nm_elements_all.ne_id%TYPE
                    ,pi_ne_id2                   IN     nm_elements_all.ne_id%TYPE
                    ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_new_element_column_names IN     awlrs_element_api.attrib_column_name_tab
                    ,pi_new_element_prompts      IN     awlrs_element_api.attrib_prompt_tab
                    ,pi_new_element_char_values  IN     awlrs_element_api.attrib_char_value_tab
                    ,pi_do_rescale_parents       IN     VARCHAR2 DEFAULT 'N'
                    ,pi_effective_date           IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,pi_run_checks               IN     VARCHAR2 DEFAULT 'Y'
                    ,po_new_ne_id                IN OUT nm_elements_all.ne_id%TYPE
                    ,po_message_severity            OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lt_new_element_attribs  awlrs_element_api.flex_attr_tab;
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    lv_cursor            sys_refcursor;
    --
  BEGIN
    /*
    ||Make sure the attribute tables have the same number of records.
    */
    IF pi_new_element_column_names.COUNT != pi_new_element_prompts.COUNT
     OR pi_new_element_column_names.COUNT != pi_new_element_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_merge_api.do_merge');
    END IF;
    --
    FOR i IN 1..pi_new_element_column_names.COUNT LOOP
      --
      lt_new_element_attribs(i).column_name := pi_new_element_column_names(i);
      lt_new_element_attribs(i).prompt      := pi_new_element_prompts(i);
      lt_new_element_attribs(i).char_value  := pi_new_element_char_values(i);
      --
    END LOOP;
    --
    do_merge(pi_ne_id1              => pi_ne_id1
            ,pi_ne_id2              => pi_ne_id2
            ,pi_reason              => pi_reason
            ,pi_new_element_attribs => lt_new_element_attribs
            ,pi_do_rescale_parents => pi_do_rescale_parents
            ,pi_effective_date      => pi_effective_date
            ,pi_run_checks          => pi_run_checks
            ,po_new_ne_id           => po_new_ne_id
            ,po_message_severity    => lv_message_severity
            ,po_message_cursor      => lv_message_cursor);
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_merge;

--
-----------------------------------------------------------------------------
--
END awlrs_merge_api;
/
