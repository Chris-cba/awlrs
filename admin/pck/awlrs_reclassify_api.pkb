CREATE OR REPLACE PACKAGE BODY awlrs_reclassify_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_reclassify_api.pkb-arc   1.0   22 Nov 2016 17:30:38   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_reclassify_api.pkb  $
  --       Date into PVCS   : $Date:   22 Nov 2016 17:30:38  $
  --       Date fetched Out : $Modtime:   22 Nov 2016 17:28:02  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_reclassify_api';
  --
  g_disp_derived    BOOLEAN := TRUE;
  g_disp_inherited  BOOLEAN := TRUE;
  g_disp_primary_ad BOOLEAN := FALSE;
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
  PROCEDURE init_element_global
    IS
    --
    lv_empty_rec  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    g_new_element := lv_empty_rec;
    --
  END init_element_global;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_nt_flex_attribs(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                               ,pi_nt_type          IN  nm_types.nt_type%TYPE
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
  FUNCTION get_nt_flex_attribs(pi_ne_id   IN nm_elements_all.ne_id%TYPE
                              ,pi_nt_type IN nm_types.nt_type%TYPE)
    RETURN awlrs_element_api.flex_attr_tab IS
    --
    lt_attrib_values  awlrs_element_api.flex_attr_tab;
    --
  BEGIN
    --
    lt_attrib_values := awlrs_element_api.get_nt_flex_attribs(pi_ne_id           => pi_ne_id
                                                             ,pi_nt_type         => pi_nt_type
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
  PROCEDURE route_check(pi_ne_id             IN     nm_elements.ne_id%TYPE DEFAULT NULL
                       ,pi_new_start_node_id IN     nm_elements.ne_no_start%TYPE
                       ,pi_new_end_node_id   IN     nm_elements.ne_no_end%TYPE
                       ,pi_new_ne_sub_class  IN     nm_elements.ne_sub_class%TYPE
                       ,pi_new_ne_group      IN     nm_elements.ne_group%TYPE
                       ,po_message_severity  IN OUT hig_codes.hco_code%TYPE
                       ,po_message_tab       IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    e0 exception;
    pragma exception_init(e0, -20100);
    e1 exception;
    pragma exception_init(e1, -20101);
    e2 exception;
    pragma exception_init(e2, -20102);
    e3 exception;
    pragma exception_init(e3, -20103);
    e4 exception;
    pragma exception_init(e4, -20104);
    e5 exception;
    pragma exception_init(e5, -20105);
    e6 exception;
    pragma exception_init(e6, -20106);
    e7 exception;
    pragma exception_init(e7, -20107);
    e8 exception;
    pragma exception_init(e8, -20108);
    e9 exception;
    pragma exception_init(e9, -20109);
    e10 exception;
    pragma exception_init(e10, -20110);
    e11 exception;
    pragma exception_init(e11, -20111);
    e12 exception;
    pragma exception_init(e12, -20112);
    e13 exception;
    pragma exception_init(e13, -20113);
    e14 exception;
    pragma exception_init(e14, -20114);
    --
    PROCEDURE add_message(pi_appl IN nm_errors.ner_appl%TYPE
                         ,pi_id   IN nm_errors.ner_id%TYPE)
      IS
    BEGIN
      awlrs_util.add_ner_to_message_tab(pi_ner_appl    => pi_appl
                                       ,pi_ner_id      => pi_id
                                       ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                       ,po_message_tab => po_message_tab);
      po_message_severity := awlrs_util.c_msg_cat_ask_continue;
    END;
    --
  BEGIN
    --
    nm3nwval.route_check(p_ne_no_start_new  => pi_new_start_node_id
                        ,p_ne_no_end_new    => pi_new_end_node_id
                        ,p_ne_sub_class_new => pi_new_ne_sub_class
                        ,p_ne_group_new     => pi_new_ne_group
                        ,p_ne_id            => pi_ne_id);
    --
  EXCEPTION
    WHEN e0
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 19);
    WHEN e1
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 20);
    WHEN e2
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 21);
    WHEN e3
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 22);
    WHEN e4
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 23);
    WHEN e5
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 24);
    WHEN e6
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 25);
    WHEN e7
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 133);
    WHEN e8
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 134);
    WHEN e9
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 135);
    WHEN e10
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 136);
    WHEN e11
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 137);
    WHEN e12
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 138);
    WHEN e13
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 139);
    WHEN e14
     THEN
        add_message(pi_appl => 'NET'
                   ,pi_id   => 140);
    WHEN others
     THEN
        RAISE;
  END route_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_check(pi_ne_id             IN  nm_elements.ne_id%TYPE
                       ,pi_new_start_node_id IN  nm_elements.ne_no_start%TYPE
                       ,pi_new_end_node_id   IN  nm_elements.ne_no_end%TYPE
                       ,pi_new_ne_sub_class  IN  nm_elements.ne_sub_class%TYPE
                       ,pi_new_ne_group      IN  nm_elements.ne_group%TYPE
                       ,po_message_severity  OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    route_check(pi_ne_id             => pi_ne_id
               ,pi_new_start_node_id => pi_new_start_node_id
               ,pi_new_end_node_id   => pi_new_end_node_id
               ,pi_new_ne_sub_class  => pi_new_ne_sub_class
               ,pi_new_ne_group      => pi_new_ne_group
               ,po_message_severity  => lv_severity
               ,po_message_tab       => lt_messages);
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
  END route_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_check(pi_ne_id                   IN  nm_elements.ne_id%TYPE
                       ,pi_new_start_node_id       IN  nm_elements.ne_no_start%TYPE
                       ,pi_new_end_node_id         IN  nm_elements.ne_no_end%TYPE
                       ,pi_new_attrib_column_names IN  awlrs_element_api.attrib_column_name_tab
                       ,pi_new_attrib_prompts      IN  awlrs_element_api.attrib_prompt_tab
                       ,pi_new_attrib_char_values  IN  awlrs_element_api.attrib_char_value_tab
                       ,po_message_severity        OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lt_element_attribs  awlrs_element_api.flex_attr_tab;
    --
  BEGIN
    /*
    ||Make sure the attribute tables have the same number of records.
    */
    IF pi_new_attrib_column_names.COUNT != pi_new_attrib_prompts.COUNT
     OR pi_new_attrib_column_names.COUNT != pi_new_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_merge_api.do_merge');
    END IF;
    --
    FOR i IN 1..pi_new_attrib_column_names.COUNT LOOP
      --
      lt_element_attribs(i).column_name := pi_new_attrib_column_names(i);
      lt_element_attribs(i).prompt      := pi_new_attrib_prompts(i);
      lt_element_attribs(i).char_value  := pi_new_attrib_char_values(i);
      --
    END LOOP;
    --
    /*
    ||Build the new element record.
    */
    init_element_global;
    --
    g_new_element := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    g_new_element.ne_no_start := pi_new_start_node_id;
    g_new_element.ne_no_end   := pi_new_end_node_id;
    --
    awlrs_element_api.build_element_rec(pi_nt_type    => g_new_element.ne_nt_type
                                       ,pi_global     => 'awlrs_reclassify_api.g_new_element'
                                       ,pi_attributes => lt_element_attribs);
    --
    lr_ne := g_new_element;
    --
    route_check(pi_ne_id             => lr_ne.ne_id
               ,pi_new_start_node_id => lr_ne.ne_no_start
               ,pi_new_end_node_id   => lr_ne.ne_no_end
               ,pi_new_ne_sub_class  => lr_ne.ne_sub_class
               ,pi_new_ne_group      => lr_ne.ne_group
               ,po_message_severity  => lv_severity
               ,po_message_cursor    => lv_message_cursor);
    --
    po_message_severity := lv_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END route_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_element_can_be_reclassed(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                          ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                                          ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    IF awlrs_util.historic_mode
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 6);
    END IF;
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF NOT nm3reclass.ne_type_can_be_reclassed(pi_ne_type => lr_ne.ne_type)
     THEN
        --Cannot perform operation on non-linear network types
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 115);
    END IF;
    --
    nm3reclass.check_element_can_be_reclassed(pi_ne_id          => pi_ne_id
                                             ,pi_effective_date => pi_effective_date);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_element_can_be_reclassed;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reclassify_element(pi_ne_id      IN  nm_elements.ne_id%TYPE
                              ,pi_new_ne_rec IN  nm_elements%ROWTYPE
                              ,pi_reason     IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                              ,po_new_ne_id  OUT nm_elements.ne_id%TYPE)
    IS
    --
    st_node_type_invalid EXCEPTION;
    PRAGMA EXCEPTION_INIT(st_node_type_invalid, -20801);
    --
    end_node_type_invalid EXCEPTION;
    PRAGMA EXCEPTION_INIT(end_node_type_invalid, -20802);
    --
    unique_not_supplied exception;
    PRAGMA EXCEPTION_INIT(unique_not_supplied, -20803);
    --
    closed_element EXCEPTION;
    PRAGMA EXCEPTION_INIT(closed_element, -20804);
    --
    cannot_close EXCEPTION;
    PRAGMA EXCEPTION_INIT(cannot_close, -20805);
    --
    no_length EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_length, -20808);
    --
    different_lengths EXCEPTION;
    PRAGMA EXCEPTION_INIT(different_lengths, -20809);
    --
    section_has_group_type exception;
    PRAGMA EXCEPTION_INIT(section_has_group_type, -20810);
    --
    no_start_node EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_start_node, -20811);
    --
    no_end_node EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_end_node, -20812);
    --
    old_element_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(old_element_not_found, -20822);
    --
    no_changes EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_changes, -20823);
    --
    distance_break EXCEPTION;
    PRAGMA EXCEPTION_INIT(distance_break, -20824);
    --
    xsp_violates EXCEPTION;
    PRAGMA EXCEPTION_INIT(xsp_violates, -20825);
    --
    sub_class_not_valid exception;
    PRAGMA EXCEPTION_INIT(sub_class_not_valid, -20826);
    --
  BEGIN
    --
    nm3reclass.reclassify_element(p_old_ne_id => pi_ne_id
                                 ,p_new_ne    => pi_new_ne_rec
                                 ,p_job_id    => nm3pbi.get_job_id
                                 ,p_gis_call  => TRUE
                                 ,p_new_ne_id => po_new_ne_id
                                 ,p_neh_descr => pi_reason);
    --
  EXCEPTION
    WHEN st_node_type_invalid
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 107);
    WHEN end_node_type_invalid
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 107);
    WHEN unique_not_supplied
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 99);
    WHEN closed_element
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 108);
    WHEN cannot_close
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 109);
    WHEN no_length
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 100);
    WHEN different_lengths
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 111);
    WHEN section_has_group_type
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 112);
    WHEN no_start_node
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 22);
    WHEN no_end_node
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 22);
    WHEN old_element_not_found
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 114);
    WHEN no_changes
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 102);
    WHEN distance_break
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 171);
    WHEN xsp_violates
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 173);
    WHEN sub_class_not_valid
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 183);
    WHEN others
     THEN
        RAISE;
  END reclassify_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reclassify_element(pi_ne_id               IN     nm_elements_all.ne_id%TYPE
                              ,pi_new_network_type    IN     nm_elements_all.ne_nt_type%TYPE
                              ,pi_new_group_type      IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                              ,pi_new_admin_unit_id   IN     nm_elements_all.ne_admin_unit%TYPE
                              ,pi_new_start_node_id   IN     nm_elements_all.ne_no_start%TYPE
                              ,pi_new_end_node_id     IN     nm_elements_all.ne_no_end%TYPE
                              ,pi_new_length          IN     nm_elements_all.ne_length%TYPE
                              ,pi_new_element_attribs IN     awlrs_element_api.flex_attr_tab
                              ,pi_reason              IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                              ,pi_run_checks          IN     VARCHAR2 DEFAULT 'Y'
                              ,po_new_ne_id           IN OUT nm_elements_all.ne_id%TYPE
                              ,po_message_severity       OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_new_ne_id       nm_elements_all.ne_id%TYPE;
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    --
    IF awlrs_util.historic_mode
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 6);
    END IF;
    --
    /*
    ||Build the new element record.
    */
    init_element_global;
    --
    g_new_element := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.is_nt_datum(p_nt_type => g_new_element.ne_nt_type) = 'Y'
     AND pi_new_group_type IS NOT NULL
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 112);     
    END IF;
    --
    IF g_new_element.ne_gty_group_type IS NOT NULL
     THEN
        IF NVL(g_new_element.ne_length,0) != NVL(pi_new_length,0)
         THEN
            hig.raise_ner(pi_appl => 'NET'
                         ,pi_id   => 111);
        END IF;
        --
        IF NVL(g_new_element.ne_no_start,-1) != NVL(pi_new_start_node_id,-1)
         OR NVL(g_new_element.ne_no_end,-1) != NVL(pi_new_end_node_id,-1)
         THEN
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 36);
        END IF;
        --
    END IF;
    --
    g_new_element.ne_nt_type        := pi_new_network_type;
    g_new_element.ne_gty_group_type := pi_new_group_type;
    g_new_element.ne_admin_unit     := pi_new_admin_unit_id;
    g_new_element.ne_no_start       := pi_new_start_node_id;
    g_new_element.ne_no_end         := pi_new_end_node_id;
    g_new_element.ne_length         := pi_new_length;
    --
    awlrs_element_api.build_element_rec(pi_nt_type    => g_new_element.ne_nt_type
                                       ,pi_global     => 'awlrs_reclassify_api.g_new_element'
                                       ,pi_attributes => pi_new_element_attribs);
    --
    lr_ne := g_new_element;
    /*
    ||Run checks to make sure the element can be reclassified unless
    ||the calling code explicitly says otherwise.
    */
    IF pi_run_checks = 'Y'
     THEN
        check_element_can_be_reclassed(pi_ne_id            => pi_ne_id
                                      ,po_message_severity => lv_severity
                                      ,po_message_cursor   => lv_message_cursor);
        IF lv_severity = awlrs_util.c_msg_cat_success
         THEN
            route_check(pi_ne_id             => pi_ne_id
                       ,pi_new_start_node_id => lr_ne.ne_no_start
                       ,pi_new_end_node_id   => lr_ne.ne_no_end
                       ,pi_new_ne_sub_class  => lr_ne.ne_sub_class
                       ,pi_new_ne_group      => lr_ne.ne_group
                       ,po_message_severity  => lv_severity
                       ,po_message_cursor    => lv_message_cursor);
        END IF;
    END IF;
    --
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN
        /*
        ||Do the reclasification.
        */
        reclassify_element(pi_ne_id      => pi_ne_id
                          ,pi_new_ne_rec => lr_ne
                          ,pi_reason     => pi_reason
                          ,po_new_ne_id  => lv_new_ne_id);
        --
        po_new_ne_id := lv_new_ne_id;
        --
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
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
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reclassify_element;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reclassify_element(pi_ne_id               IN     nm_elements_all.ne_id%TYPE
                              ,pi_new_network_type    IN     nm_elements_all.ne_nt_type%TYPE
                              ,pi_new_group_type      IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                              ,pi_new_admin_unit_id   IN     nm_elements_all.ne_admin_unit%TYPE
                              ,pi_new_start_node_id   IN     nm_elements_all.ne_no_start%TYPE
                              ,pi_new_end_node_id     IN     nm_elements_all.ne_no_end%TYPE
                              ,pi_new_length          IN     nm_elements_all.ne_length%TYPE
                              ,pi_attrib_column_names IN     awlrs_element_api.attrib_column_name_tab
                              ,pi_attrib_prompts      IN     awlrs_element_api.attrib_prompt_tab
                              ,pi_attrib_char_values  IN     awlrs_element_api.attrib_char_value_tab
                              ,pi_reason              IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                              ,pi_run_checks          IN     VARCHAR2 DEFAULT 'Y'
                              ,po_new_ne_id           IN OUT nm_elements_all.ne_id%TYPE
                              ,po_message_severity       OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    --
    lt_element_attribs  awlrs_element_api.flex_attr_tab;
    --
  BEGIN
    /*
    ||Make sure the attribute tables have the same number of records.
    */
    IF pi_attrib_column_names.COUNT != pi_attrib_prompts.COUNT
     OR pi_attrib_column_names.COUNT != pi_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_merge_api.do_merge');
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
    reclassify_element(pi_ne_id               => pi_ne_id
                      ,pi_new_network_type    => pi_new_network_type
                      ,pi_new_group_type      => pi_new_group_type
                      ,pi_new_admin_unit_id   => pi_new_admin_unit_id
                      ,pi_new_start_node_id   => pi_new_start_node_id
                      ,pi_new_end_node_id     => pi_new_end_node_id
                      ,pi_new_length          => pi_new_length
                      ,pi_new_element_attribs => lt_element_attribs
                      ,pi_reason              => pi_reason
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
  END reclassify_element;

END awlrs_reclassify_api;
/