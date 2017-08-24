CREATE OR REPLACE PACKAGE BODY awlrs_reshape_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_reshape_api.pkb-arc   1.6   24 Aug 2017 13:05:40   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_reshape_api.pkb  $
  --       Date into PVCS   : $Date:   24 Aug 2017 13:05:40  $
  --       Date fetched Out : $Modtime:   24 Aug 2017 13:04:50  $
  --       Version          : $Revision:   1.6  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.6  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_reshape_api';
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
  PROCEDURE do_reclassify(pi_ne_id                    IN     nm_elements_all.ne_id%TYPE
                         ,pi_run_checks               IN     VARCHAR2
                         ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                         ,pi_new_element_column_names IN     awlrs_element_api.attrib_column_name_tab
                         ,pi_new_element_prompts      IN     awlrs_element_api.attrib_prompt_tab
                         ,pi_new_element_char_values  IN     awlrs_element_api.attrib_char_value_tab
                         ,pi_new_start_node           IN     nm_elements_all.ne_no_start%TYPE
                         ,pi_new_end_node             IN     nm_elements_all.ne_no_end%TYPE
                         ,po_new_ne_id                IN OUT nm_elements_all.ne_id%TYPE
                         ,po_message_severity         IN OUT hig_codes.hco_code%TYPE
                         ,po_message_tab              IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_message_cursor  sys_refcursor;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lt_messages  awlrs_util.message_tab;
    --
  BEGIN
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    awlrs_reclassify_api.reclassify_element(pi_ne_id               => pi_ne_id
                                           ,pi_new_network_type    => lr_ne.ne_nt_type
                                           ,pi_new_group_type      => lr_ne.ne_gty_group_type
                                           ,pi_new_admin_unit_id   => lr_ne.ne_admin_unit
                                           ,pi_new_start_node_id   => pi_new_start_node
                                           ,pi_new_end_node_id     => pi_new_end_node
                                           ,pi_new_length          => nm3net.get_ne_length(p_ne_id => pi_ne_id)
                                           ,pi_new_start_date      => lr_ne.ne_start_date
                                           ,pi_attrib_column_names => pi_new_element_column_names
                                           ,pi_attrib_prompts      => pi_new_element_prompts
                                           ,pi_attrib_char_values  => pi_new_element_char_values
                                           ,pi_reason              => pi_reason
                                           ,pi_run_checks          => pi_run_checks
                                           ,po_new_ne_id           => po_new_ne_id
                                           ,po_message_severity    => po_message_severity
                                           ,po_message_cursor      => lv_message_cursor);
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
  END do_reclassify;

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
                      ,po_message_severity         IN OUT hig_codes.hco_code%TYPE
                      ,po_message_tab              IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_message_cursor  sys_refcursor;
    --
    lt_messages  awlrs_util.message_tab;
    --
  BEGIN
    --
    awlrs_replace_api.do_replace(pi_ne_id                    => pi_ne_id
                                ,pi_reason                   => pi_reason
                                ,pi_new_element_column_names => pi_new_element_column_names
                                ,pi_new_element_prompts      => pi_new_element_prompts
                                ,pi_new_element_char_values  => pi_new_element_char_values
                                ,pi_effective_date           => pi_effective_date
                                ,po_new_ne_id                => po_new_ne_id
                                ,po_message_severity         => po_message_severity
                                ,po_message_cursor           => lv_message_cursor);
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
  END do_replace;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_reshape(pi_theme_name       IN     nm_themes_all.nth_theme_name%TYPE
                      ,pi_ne_id            IN     nm_elements_all.ne_id%TYPE
                      ,pi_shape_wkt        IN     CLOB
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
    awlrs_element_api.reshape_element(pi_theme_name       => pi_theme_name
                                     ,pi_ne_id            => pi_ne_id
                                     ,pi_shape_wkt        => pi_shape_wkt
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
  END do_reshape;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_recalibration(pi_ne_id                   IN     nm_elements_all.ne_id%TYPE
                            ,pi_recal_start_point       IN     NUMBER DEFAULT NULL
                            ,pi_recal_new_length_to_end IN     NUMBER DEFAULT NULL
                            ,pi_reason                  IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                            ,po_message_severity        IN OUT hig_codes.hco_code%TYPE
                            ,po_message_tab             IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_message_cursor  sys_refcursor;
    lv_new_ne_id       nm_elements_all.ne_id%TYPE;
    --
    lt_messages  awlrs_util.message_tab;
    --
  BEGIN
    --
    awlrs_recalibrate_api.do_recalibration(pi_ne_id             => pi_ne_id
                                          ,pi_start_point       => pi_recal_start_point
                                          ,pi_new_length_to_end => pi_recal_new_length_to_end
                                          ,pi_reason            => pi_reason
                                          ,po_new_ne_id         => lv_new_ne_id
                                          ,po_message_severity  => po_message_severity
                                          ,po_message_cursor    => lv_message_cursor);
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
  END do_recalibration;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reshape_element(pi_theme_name               IN     nm_themes_all.nth_theme_name%TYPE
                           ,pi_ne_id                    IN     nm_elements_all.ne_id%TYPE
                           ,pi_shape_wkt                IN     CLOB
                           ,pi_do_replace               IN     VARCHAR2 DEFAULT 'N'
                           ,pi_do_reclassify            IN     VARCHAR2 DEFAULT 'N'
                           ,pi_new_element_column_names IN     awlrs_element_api.attrib_column_name_tab DEFAULT CAST(NULL AS awlrs_element_api.attrib_column_name_tab)
                           ,pi_new_element_prompts      IN     awlrs_element_api.attrib_prompt_tab DEFAULT CAST(NULL AS awlrs_element_api.attrib_prompt_tab)
                           ,pi_new_element_char_values  IN     awlrs_element_api.attrib_char_value_tab DEFAULT CAST(NULL AS awlrs_element_api.attrib_char_value_tab)
                           ,pi_new_start_node           IN     nm_elements_all.ne_no_start%TYPE DEFAULT NULL
                           ,pi_new_end_node             IN     nm_elements_all.ne_no_end%TYPE DEFAULT NULL
                           ,pi_do_recalibrate           IN     VARCHAR2 DEFAULT 'N'
                           ,pi_recal_start_point        IN     NUMBER DEFAULT NULL
                           ,pi_recal_new_length_to_end  IN     NUMBER DEFAULT NULL
                           ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                           ,pi_effective_date           IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                           ,pi_run_checks               IN     VARCHAR2 DEFAULT 'Y'
                           ,po_new_ne_id                IN OUT nm_elements_all.ne_id%TYPE
                           ,po_message_severity            OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lv_ne_id      nm_elements_all.ne_id%TYPE := pi_ne_id;
    lv_new_ne_id  nm_elements_all.ne_id%TYPE;
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reshape_element1_sp;
    /*
    ||Run Reclassify/Replace if required.
    */
    IF pi_do_reclassify = 'Y'
     THEN
        --
        do_reclassify(pi_ne_id                    => lv_ne_id
                     ,pi_run_checks               => pi_run_checks
                     ,pi_reason                   => pi_reason
                     ,pi_new_element_column_names => pi_new_element_column_names
                     ,pi_new_element_prompts      => pi_new_element_prompts
                     ,pi_new_element_char_values  => pi_new_element_char_values
                     ,pi_new_start_node           => pi_new_start_node
                     ,pi_new_end_node             => pi_new_end_node
                     ,po_new_ne_id                => lv_new_ne_id
                     ,po_message_severity         => lv_severity
                     ,po_message_tab              => lt_messages);
        --
        IF lv_severity NOT IN(awlrs_util.c_msg_cat_error,awlrs_util.c_msg_cat_ask_continue)
         THEN 
            lv_ne_id := lv_new_ne_id;
        END IF;
        --
    ELSIF pi_do_replace = 'Y'
     THEN
        --
        do_replace(pi_ne_id                    => lv_ne_id
                  ,pi_reason                   => pi_reason
                  ,pi_new_element_column_names => pi_new_element_column_names
                  ,pi_new_element_prompts      => pi_new_element_prompts
                  ,pi_new_element_char_values  => pi_new_element_char_values
                  ,pi_effective_date           => TRUNC(pi_effective_date)
                  ,po_new_ne_id                => lv_new_ne_id
                  ,po_message_severity         => lv_severity
                  ,po_message_tab              => lt_messages);
        --
        IF lv_severity != awlrs_util.c_msg_cat_error
         THEN 
            lv_ne_id := lv_new_ne_id;
        END IF;
        --
    END IF;
    /*
    ||If all is well update the shape.
    */
    IF lv_severity NOT IN(awlrs_util.c_msg_cat_error,awlrs_util.c_msg_cat_ask_continue)
     THEN
        --
        do_reshape(pi_theme_name       => pi_theme_name
                  ,pi_ne_id            => lv_ne_id
                  ,pi_shape_wkt        => pi_shape_wkt
                  ,po_message_severity => lv_severity
                  ,po_message_tab      => lt_messages);
        /*
        ||If all is well run Recalibrate if required.
        */
        IF lv_severity != awlrs_util.c_msg_cat_error
         AND pi_do_recalibrate = 'Y'
         THEN
            --
            do_recalibration(pi_ne_id                   => lv_ne_id
                            ,pi_recal_start_point       => pi_recal_start_point
                            ,pi_recal_new_length_to_end => pi_recal_new_length_to_end
                            ,pi_reason                  => pi_reason
                            ,po_message_severity        => lv_severity
                            ,po_message_tab             => lt_messages);
            --
        END IF;
        --
    END IF;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity IN(awlrs_util.c_msg_cat_error,awlrs_util.c_msg_cat_ask_continue)
     THEN
        ROLLBACK TO reshape_element1_sp;
    ELSE
        po_new_ne_id := lv_new_ne_id;
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
        ROLLBACK TO reshape_element1_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reshape_element;
  --
END awlrs_reshape_api;
/
