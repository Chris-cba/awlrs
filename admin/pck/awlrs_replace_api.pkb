CREATE OR REPLACE PACKAGE BODY awlrs_replace_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_replace_api.pkb-arc   1.4   13 Dec 2016 13:04:14   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_replace_api.pkb  $
  --       Date into PVCS   : $Date:   13 Dec 2016 13:04:14  $
  --       Date fetched Out : $Modtime:   13 Dec 2016 11:39:04  $
  --       Version          : $Revision:   1.4  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.4  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_replace_api';
  --
  g_disp_derived    BOOLEAN := TRUE;
  g_disp_inherited  BOOLEAN := FALSE;
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
  PROCEDURE do_replace(pi_ne_id               IN     nm_elements_all.ne_id%TYPE
                      ,pi_reason              IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                      ,pi_new_element_attribs IN     awlrs_element_api.flex_attr_tab
                      ,pi_effective_date      IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                      ,po_new_ne_id           IN OUT nm_elements_all.ne_id%TYPE
                      ,po_message_severity       OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT do_replace_sp;
    --
    init_element_globals;
    --
    lr_ne := nm3get.get_ne(pi_ne_id);
    --
    awlrs_element_api.build_element_rec(pi_nt_type    => lr_ne.ne_nt_type
                                       ,pi_global     => 'awlrs_replace_api.g_new_element'
                                       ,pi_attributes => pi_new_element_attribs);
    --
    nm3replace.do_replace(p_ne_id          => pi_ne_id
                         ,p_ne_id_new      => po_new_ne_id
                         ,p_effective_date => pi_effective_date
                         ,p_ne_unique      => g_new_element.ne_unique
                         ,p_ne_owner       => g_new_element.ne_owner
                         ,p_ne_name_1      => g_new_element.ne_name_1
                         ,p_ne_name_2      => g_new_element.ne_name_2
                         ,p_ne_prefix      => g_new_element.ne_prefix
                         ,p_ne_number      => g_new_element.ne_number
                         ,p_ne_sub_type    => g_new_element.ne_sub_type
                         ,p_ne_group       => g_new_element.ne_group
                         ,p_ne_sub_class   => g_new_element.ne_sub_class
                         ,p_ne_nsg_ref     => g_new_element.ne_nsg_ref
                         ,p_ne_version_no  => g_new_element.ne_version_no
                         ,p_neh_descr      => pi_reason);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO do_replace_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_replace;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_replace(pi_ne_id                    IN     nm_elements_all.ne_id%TYPE
                      ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                      ,pi_new_element_column_names IN     awlrs_element_api.attrib_column_name_tab
                      ,pi_new_element_prompts      IN     awlrs_element_api.attrib_prompt_tab
                      ,pi_new_element_char_values  IN     awlrs_element_api.attrib_char_value_tab
                      ,pi_effective_date           IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
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
                     ,pi_supplementary_info => 'awlrs_replace_api.do_replace');
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
    do_replace(pi_ne_id               => pi_ne_id
              ,pi_reason              => pi_reason
              ,pi_new_element_attribs => lt_new_element_attribs
              ,pi_effective_date      => pi_effective_date
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
  END do_replace;

END awlrs_replace_api;
/
