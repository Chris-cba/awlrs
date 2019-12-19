CREATE OR REPLACE PACKAGE BODY awlrs_replace_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_replace_api.pkb-arc   1.6   Dec 19 2019 10:37:24   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_replace_api.pkb  $
  --       Date into PVCS   : $Date:   Dec 19 2019 10:37:24  $
  --       Date fetched Out : $Modtime:   Dec 19 2019 10:35:34  $
  --       Version          : $Revision:   1.6  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.6  $';
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
  PROCEDURE do_rescale(pi_ne_id            IN     nm_elements.ne_id%TYPE
                      ,pi_effective_date   IN     DATE
                      ,pi_offset_st        IN     NUMBER
                      ,pi_start_ne_id      IN     nm_elements.ne_id%TYPE DEFAULT NULL
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
                                 ,pi_effective_date   => pi_effective_date
                                 ,pi_offset_st        => pi_offset_st
                                 ,pi_start_ne_id      => pi_start_ne_id
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
  PROCEDURE do_replace(pi_ne_id                 IN     nm_elements_all.ne_id%TYPE
                      ,pi_reason                IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                      ,pi_new_element_attribs   IN     awlrs_element_api.flex_attr_tab
                      ,pi_effective_date        IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                      ,pi_do_maintain_history   IN     VARCHAR2 DEFAULT 'N'
                      ,pi_circular_group_ids    IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)
                      ,pi_circular_start_ne_ids IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)                         
                      ,po_new_ne_id             IN OUT nm_elements_all.ne_id%TYPE
                      ,po_message_severity         OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor           OUT sys_refcursor)
    IS
    --
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;    
    lr_ne              nm_elements_all%ROWTYPE;
    lv_start_ne_id   nm_elements_all.ne_id%TYPE;    
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    CURSOR get_linear_groups(cp_ne_id IN nm_elements_all.ne_id%TYPE)
        IS
    SELECT nm_ne_id_in group_id
          ,NVL(nm3net.get_min_slk(pi_ne_id => nm_ne_id_in),0) min_slk
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
    SAVEPOINT do_replace_sp;
    --
    IF pi_do_maintain_history = 'Y'
     THEN
        --
        IF pi_circular_group_ids.COUNT != pi_circular_start_ne_ids.COUNT
         THEN
            --If these arrays are passed check counts are the same.
            hig.raise_ner(pi_appl               => 'AWLRS'
                         ,pi_id                 => 5
                         ,pi_supplementary_info => 'awlrs_replace_api.do_replace');
        END IF;
        --
        OPEN  get_linear_groups(pi_ne_id);
        FETCH get_linear_groups
         BULK COLLECT
         INTO lt_groups;
        CLOSE get_linear_groups;
        --
        FOR i IN 1..lt_groups.COUNT LOOP
          --
          lv_start_ne_id := null;
          --
          FOR j IN 1..pi_circular_group_ids.COUNT LOOP
            IF pi_circular_group_ids(j) = lt_groups(i).group_id
             THEN 
                lv_start_ne_id := pi_circular_start_ne_ids(j);
            ELSE 
                lv_start_ne_id := null;
            END IF;
          END LOOP;
          --
          lv_severity := awlrs_util.c_msg_cat_success;
          lt_messages.DELETE;
          --
          do_rescale(pi_ne_id            => lt_groups(i).group_id
                    ,pi_effective_date   => pi_effective_date
                    ,pi_offset_st        => lt_groups(i).min_slk
                    ,pi_start_ne_id      => lv_start_ne_id
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
                        ,pi_effective_date   => pi_effective_date
                        ,pi_offset_st        => lt_groups(i).min_slk
                        ,pi_start_ne_id      => lv_start_ne_id
                        ,pi_use_history      => 'N'
                        ,po_message_severity => lv_severity
                        ,po_message_tab      => lt_messages);
              --
          END IF;
          --
          IF lv_severity != awlrs_util.c_msg_cat_success
           THEN
              /*
              ||If an error has occurred rescaling a group end the whole operation. 
              ||This shouldnt happen as the array should be sent but this will capture any changes if done after selection
              */
              IF lv_severity = awlrs_util.c_msg_cat_circular_route
               THEN
                  lt_messages.DELETE;
                  awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'AWLRS'
                                                   ,pi_ner_id             => 60
                                                   ,pi_supplementary_info => NULL
                                                   ,pi_category           => awlrs_util.c_msg_cat_error
                                                   ,po_message_tab        => lt_messages);
              END IF;
              --
              EXIT;
              --
          END IF;
          --
        END LOOP;
    END IF;
    --
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN    
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
    END IF;
    --
    /*
    ||Rescale any linear groups the element belongs to.
    */
    IF pi_do_maintain_history = 'Y' AND lv_severity = awlrs_util.c_msg_cat_success
     THEN
        --
        lt_groups.DELETE;
        --
        OPEN  get_linear_groups(po_new_ne_id);
        FETCH get_linear_groups
         BULK COLLECT
         INTO lt_groups;
        CLOSE get_linear_groups;
        --
        FOR i IN 1..lt_groups.COUNT LOOP
          --
          lv_start_ne_id := null;
          --
          FOR j IN 1..pi_circular_group_ids.COUNT LOOP
            IF pi_circular_group_ids(j) = lt_groups(i).group_id
             THEN 
                lv_start_ne_id := pi_circular_start_ne_ids(j);
            ELSE 
                lv_start_ne_id := null;
            END IF;
          END LOOP;
          --          
          lv_severity := awlrs_util.c_msg_cat_success;
          lt_messages.DELETE;
          --
          do_rescale(pi_ne_id            => lt_groups(i).group_id
                    ,pi_effective_date   => pi_effective_date
                    ,pi_offset_st        => lt_groups(i).min_slk
                    ,pi_start_ne_id      => lv_start_ne_id
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
                        ,pi_effective_date   => pi_effective_date
                        ,pi_offset_st        => lt_groups(i).min_slk
                        ,pi_start_ne_id      => lv_start_ne_id
                        ,pi_use_history      => 'N'
                        ,po_message_severity => lv_severity
                        ,po_message_tab      => lt_messages);
              --
          END IF;
          --
          IF lv_severity != awlrs_util.c_msg_cat_success
           THEN
              /*
              ||If an error has occurred rescaling a group end the whole operation.
              */
              IF lv_severity = awlrs_util.c_msg_cat_circular_route
               THEN
                  lt_messages.DELETE;
                  awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'AWLRS'
                                                   ,pi_ner_id             => 60
                                                   ,pi_supplementary_info => NULL
                                                   ,pi_category           => awlrs_util.c_msg_cat_error
                                                   ,po_message_tab        => lt_messages);
              END IF;
              --
              EXIT;
              --
          END IF;
          --
        END LOOP;
    END IF;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity IN(awlrs_util.c_msg_cat_error
                     ,awlrs_util.c_msg_cat_ask_continue
                     ,awlrs_util.c_msg_cat_circular_route)
     THEN
        ROLLBACK TO do_replace_sp;
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
                      ,pi_do_maintain_history      IN     VARCHAR2 DEFAULT 'N'
                      ,pi_circular_group_ids       IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)
                      ,pi_circular_start_ne_ids    IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)                        
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
    /*
    ||Check the circular route array counts are the same. PB TO DO check error number.
    */
    IF pi_circular_group_ids.COUNT != pi_circular_start_ne_ids.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_replace_api.do_replace');    
    END IF;    
    --
    do_replace(pi_ne_id                 => pi_ne_id
              ,pi_reason                => pi_reason
              ,pi_new_element_attribs   => lt_new_element_attribs
              ,pi_effective_date        => pi_effective_date
              ,pi_do_maintain_history   => pi_do_maintain_history
              ,pi_circular_group_ids    => pi_circular_group_ids
              ,pi_circular_start_ne_ids => pi_circular_start_ne_ids
              ,po_new_ne_id             => po_new_ne_id
              ,po_message_severity      => lv_message_severity
              ,po_message_cursor        => lv_message_cursor);
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
