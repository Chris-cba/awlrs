CREATE OR REPLACE PACKAGE BODY awlrs_merge_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_merge_api.pkb-arc   1.0   26 Sep 2016 18:17:30   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_merge_api.pkb  $
  --       Date into PVCS   : $Date:   26 Sep 2016 18:17:30  $
  --       Date fetched Out : $Modtime:   26 Sep 2016 12:56:34  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT VARCHAR2 (2000) := '$Revision:   1.0  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_merge_api';
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
  PROCEDURE check_elements_can_be_merged(pi_ne_id1           IN  nm_elements_all.ne_id%TYPE
                                        ,pi_ne_id2           IN  nm_elements_all.ne_id%TYPE
                                        ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    nm3merge.check_elements_can_be_merged(pi_ne_id_1        => pi_ne_id1
                                         ,pi_ne_id_2        => pi_ne_id2
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
  END check_elements_can_be_merged;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_for_lost_connectivity(pi_ne_id1           IN  nm_elements_all.ne_id%TYPE
                                       ,pi_ne_id2           IN  nm_elements_all.ne_id%TYPE
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    nm3merge.check_for_lost_connectivity(p_ne_id_1 => pi_ne_id1
                                        ,p_ne_id_2 => pi_ne_id2);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_for_lost_connectivity;

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
                                         ,pi_disp_derived     => FALSE
                                         ,pi_disp_inherited   => FALSE
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
    lt_attrib_values := awlrs_element_api.get_nt_flex_attribs(pi_ne_id          => pi_ne_id
                                                             ,pi_nt_type        => pi_nt_type
                                                             ,pi_disp_derived   => FALSE
                                                             ,pi_disp_inherited => FALSE);
    --
    RETURN lt_attrib_values;
    --
  END get_nt_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_merge(pi_ne_id1              IN  nm_elements_all.ne_id%TYPE
                    ,pi_ne_id2              IN  nm_elements_all.ne_id%TYPE
                    ,pi_reason              IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_new_element_attribs IN  awlrs_element_api.flex_attr_tab
                    ,pi_test_poe_at_node    IN  VARCHAR2
                    ,pi_effective_date      IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,po_message_severity    OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor      OUT sys_refcursor
                    ,po_cursor              OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lv_new_node_id  nm_elements.ne_no_start%TYPE;
    lv_new_np_id    nm_nodes.no_np_id%TYPE;
    lv_create_node  BOOLEAN := TRUE;
    --
    lt_new_ids  awlrs_util.ne_id_tab;
    --
    lv_new_elements_cursor  sys_refcursor;
    --
  BEGIN
    --
    init_element_globals;
    --
    lr_ne := nm3get.get_ne(pi_ne_id1);
    --
    awlrs_element_api.build_element_rec(pi_nt_type    => lr_ne.ne_nt_type
                                       ,pi_global     => 'awlrs_merge_api.g_new_element'
                                       ,pi_attributes => pi_new_element_attribs);
    --
    lt_new_ids(1) := NULL;
    --
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
                                    ,pi_test_poe_at_node  => pi_test_poe_at_node
                                    ,po_ne_id_new         => lt_new_ids(1)
                                    ,pi_neh_descr         => pi_reason);
    /*
    ||Return a cursor containing the details of the new element.
    */
    awlrs_element_api.get_elements(pi_ne_ids => lt_new_ids
                                  ,po_cursor => lv_new_elements_cursor);
    po_cursor := lv_new_elements_cursor;
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
  END do_merge;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_merge(pi_ne_id1                   IN  nm_elements_all.ne_id%TYPE
                    ,pi_ne_id2                   IN  nm_elements_all.ne_id%TYPE
                    ,pi_reason                   IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_new_element_column_names IN  awlrs_element_api.attrib_column_name_tab
                    ,pi_new_element_prompts      IN  awlrs_element_api.attrib_prompt_tab
                    ,pi_new_element_char_values  IN  awlrs_element_api.attrib_char_value_tab
                    ,pi_test_poe_at_node         IN  VARCHAR2
                    ,pi_effective_date           IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,po_message_severity         OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor           OUT sys_refcursor
                    ,po_cursor                   OUT sys_refcursor)
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
        raise_application_error(-20001,'awlrs_merge_api.do_merge: The attribute tables passed in must have matching row counts.');
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
            ,pi_test_poe_at_node    => pi_test_poe_at_node
            ,pi_effective_date      => pi_effective_date
            ,po_message_severity    => lv_message_severity
            ,po_message_cursor      => lv_message_cursor
            ,po_cursor              => lv_cursor);
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
  END do_merge;

--
-----------------------------------------------------------------------------
--
END awlrs_merge_api;
/
