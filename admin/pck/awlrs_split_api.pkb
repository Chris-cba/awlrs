CREATE OR REPLACE PACKAGE BODY awlrs_split_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_split_api.pkb-arc   1.2   04 Oct 2016 14:09:22   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_split_api.pkb  $
  --       Date into PVCS   : $Date:   04 Oct 2016 14:09:22  $
  --       Date fetched Out : $Modtime:   04 Oct 2016 14:05:14  $
  --       Version          : $Revision:   1.2  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT VARCHAR2 (2000) := '$Revision:   1.2  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_split_api';
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
    g_new_element_1 := lv_empty_rec;
    g_new_element_2 := lv_empty_rec;
    --
  END init_element_globals;

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
  PROCEDURE do_split(pi_ne_id                IN     nm_elements_all.ne_id%TYPE
                    ,pi_split_offset         IN     NUMBER
                    ,pi_split_at_node_id     IN     nm_nodes.no_node_id%TYPE
                    ,pi_reason               IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_new_element1_attribs IN     awlrs_element_api.flex_attr_tab
                    ,pi_new_element2_attribs IN     awlrs_element_api.flex_attr_tab
                    ,pi_effective_date       IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,po_new_ne_ids           IN OUT awlrs_util.ne_id_tab
                    ,po_message_severity        OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor          OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lv_new_node_id  nm_elements.ne_no_start%TYPE;
    lv_new_np_id    nm_nodes.no_np_id%TYPE;
    lv_create_node  BOOLEAN := TRUE;
    --
    lv_new_elements_cursor  sys_refcursor;
    --
  BEGIN
    --
    init_element_globals;
    --
    lr_ne := nm3get.get_ne(pi_ne_id);
    /*
    ||Make sure the attribute tables have the same number of records.
    */
    IF pi_new_element1_attribs.COUNT != pi_new_element2_attribs.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_split_api.do_split');
    END IF;
    --
    awlrs_element_api.build_element_rec(pi_nt_type    => lr_ne.ne_nt_type
                                       ,pi_global     => 'awlrs_split_api.g_new_element_1'
                                       ,pi_attributes => pi_new_element1_attribs);
    awlrs_element_api.build_element_rec(pi_nt_type    => lr_ne.ne_nt_type
                                       ,pi_global     => 'awlrs_split_api.g_new_element_2'
                                       ,pi_attributes => pi_new_element2_attribs);
    --
    IF pi_split_at_node_id IS NOT NULL
     THEN
        lv_create_node := FALSE;
    END IF;
    --
    nm3split.set_ne_globals(pi_ne_id => pi_ne_id);
    --
    po_new_ne_ids.DELETE;
    --
    nm3split.do_split_datum_or_group(pi_ne_id                  => lr_ne.ne_id
                                    ,pi_ne_type                => lr_ne.ne_type
                                    ,pi_ne_id_1                => po_new_ne_ids(1)
                                    ,pi_ne_id_2                => po_new_ne_ids(2)
                                    ,pi_effective_date         => pi_effective_date
                                    ,pi_split_offset           => pi_split_offset
                                    ,pi_non_ambig_ne_id        => NULL --:split.datum_ne
                                    ,pi_non_ambig_split_offset => NULL --:split.datum_offset
                                    ,pi_split_at_node_id       => pi_split_at_node_id
                                    ,pi_create_node            => lv_create_node
                                    /*
                                    ||SM always creates a new node when splitting at measure and allows the core api to generate the detail.
                                    */
                                    ,pi_node_id                => lv_new_node_id
                                    ,pi_no_node_name           => NULL --:split.cre_node_name
                                    ,pi_no_descr               => NULL --:split.cre_node_descr
                                    ,pi_no_purpose             => NULL --:split.cre_node_purpose
                                    ,pi_np_grid_east           => NULL --:split.cre_node_grid_east
                                    ,pi_np_grid_north          => NULL --:split.cre_node_grid_north
                                    ,pi_no_np_id               => lv_new_np_id
                                    ,pi_ne_unique_1            => g_new_element_1.ne_unique
                                    ,pi_ne_owner_1             => g_new_element_1.ne_owner
                                    ,pi_ne_name_1_1            => g_new_element_1.ne_name_1
                                    ,pi_ne_name_2_1            => g_new_element_1.ne_name_2
                                    ,pi_ne_prefix_1            => g_new_element_1.ne_prefix
                                    ,pi_ne_number_1            => g_new_element_1.ne_number
                                    ,pi_ne_sub_type_1          => g_new_element_1.ne_sub_type
                                    ,pi_ne_group_1             => g_new_element_1.ne_group
                                    ,pi_ne_sub_class_1         => g_new_element_1.ne_sub_class
                                    ,pi_ne_nsg_ref_1           => g_new_element_1.ne_nsg_ref
                                    ,pi_ne_version_no_1        => g_new_element_1.ne_version_no
                                    ,pi_ne_unique_2            => g_new_element_2.ne_unique
                                    ,pi_ne_owner_2             => g_new_element_2.ne_owner
                                    ,pi_ne_name_1_2            => g_new_element_2.ne_name_1
                                    ,pi_ne_name_2_2            => g_new_element_2.ne_name_2
                                    ,pi_ne_prefix_2            => g_new_element_2.ne_prefix
                                    ,pi_ne_number_2            => g_new_element_2.ne_number
                                    ,pi_ne_sub_type_2          => g_new_element_2.ne_sub_type
                                    ,pi_ne_group_2             => g_new_element_2.ne_group
                                    ,pi_ne_sub_class_2         => g_new_element_2.ne_sub_class
                                    ,pi_ne_nsg_ref_2           => g_new_element_2.ne_nsg_ref
                                    ,pi_ne_version_no_2        => g_new_element_2.ne_version_no
                                    ,pi_neh_descr              => pi_reason);
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
  END do_split;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_split(pi_ne_id                     IN     nm_elements_all.ne_id%TYPE
                    ,pi_split_offset              IN     NUMBER
                    ,pi_split_at_node_id          IN     nm_nodes.no_node_id%TYPE
                    ,pi_reason                    IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_new_element1_column_names IN     awlrs_element_api.attrib_column_name_tab
                    ,pi_new_element1_prompts      IN     awlrs_element_api.attrib_prompt_tab
                    ,pi_new_element1_char_values  IN     awlrs_element_api.attrib_char_value_tab
                    ,pi_new_element2_column_names IN     awlrs_element_api.attrib_column_name_tab
                    ,pi_new_element2_prompts      IN     awlrs_element_api.attrib_prompt_tab
                    ,pi_new_element2_char_values  IN     awlrs_element_api.attrib_char_value_tab
                    ,pi_effective_date            IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,po_new_ne_ids                IN OUT awlrs_util.ne_id_tab
                    ,po_message_severity             OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor               OUT sys_refcursor)
    IS
    --
    lt_new_element1_attribs  awlrs_element_api.flex_attr_tab;
    lt_new_element2_attribs  awlrs_element_api.flex_attr_tab;
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    lv_cursor            sys_refcursor;
    --
  BEGIN
    /*
    ||Make sure the attribute tables have the same number of records.
    */
    IF pi_new_element1_column_names.COUNT != pi_new_element1_prompts.COUNT
     OR pi_new_element1_column_names.COUNT != pi_new_element1_char_values.COUNT
     OR pi_new_element1_column_names.COUNT != pi_new_element2_column_names.COUNT
     OR pi_new_element1_column_names.COUNT != pi_new_element2_prompts.COUNT
     OR pi_new_element1_column_names.COUNT != pi_new_element2_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_split_api.do_split');    END IF;
    --
    FOR i IN 1..pi_new_element1_column_names.COUNT LOOP
      --
      lt_new_element1_attribs(i).column_name := pi_new_element1_column_names(i);
      lt_new_element1_attribs(i).prompt      := pi_new_element1_prompts(i);
      lt_new_element1_attribs(i).char_value  := pi_new_element1_char_values(i);
      --
      lt_new_element2_attribs(i).column_name := pi_new_element2_column_names(i);
      lt_new_element2_attribs(i).prompt      := pi_new_element2_prompts(i);
      lt_new_element2_attribs(i).char_value  := pi_new_element2_char_values(i);
      --
    END LOOP;
    --
    do_split(pi_ne_id                => pi_ne_id
            ,pi_split_offset         => pi_split_offset
            ,pi_split_at_node_id     => pi_split_at_node_id
            ,pi_reason               => pi_reason
            ,pi_new_element1_attribs => lt_new_element1_attribs
            ,pi_new_element2_attribs => lt_new_element2_attribs
            ,pi_effective_date       => pi_effective_date
            ,po_new_ne_ids           => po_new_ne_ids
            ,po_message_severity     => lv_message_severity
            ,po_message_cursor       => lv_message_cursor);
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_split;

--
-----------------------------------------------------------------------------
--
END awlrs_split_api;
/
