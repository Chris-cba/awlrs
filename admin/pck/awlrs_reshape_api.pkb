CREATE OR REPLACE PACKAGE BODY awlrs_reshape_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_reshape_api.pkb-arc   1.15   Jan 30 2020 10:09:32   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_reshape_api.pkb  $
  --       Date into PVCS   : $Date:   Jan 30 2020 10:09:32  $
  --       Date fetched Out : $Modtime:   Jan 29 2020 16:24:58  $
  --       Version          : $Revision:   1.15  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.15  $';

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
                         ,pi_new_start_date           IN     nm_elements_all.ne_start_date%TYPE
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
                                           ,pi_new_start_date      => pi_new_start_date
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
                           ,pi_do_rescale_parents       IN     VARCHAR2 DEFAULT 'N'
                           ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                           ,pi_effective_date           IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                           ,pi_run_checks               IN     VARCHAR2 DEFAULT 'Y'
                           ,pi_circular_group_ids       IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)
                           ,pi_circular_start_ne_ids    IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)
                           ,po_circular_route_cursor       OUT sys_refcursor
                           ,po_new_ne_id                IN OUT nm_elements_all.ne_id%TYPE
                           ,po_message_severity            OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lv_ne_id       nm_elements_all.ne_id%TYPE := pi_ne_id;
    lv_new_ne_id   nm_elements_all.ne_id%TYPE;
    lv_severity    hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_start_ne_id nm_elements_all.ne_id%TYPE;
    lv_cursor      sys_refcursor;
    --
    lr_ne          nm_elements_all%ROWTYPE;
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
    lt_parent_ids      nm_ne_id_array := nm_ne_id_array();
    lt_circular_routes nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reshape_element1_sp;
    /*
    ||TFS 1068280
    ||If replace and rescale are both set to Yes then do the rescale before and after the operation
    */
    IF (pi_do_rescale_parents = 'Y' AND pi_do_replace = 'Y')
     THEN
        --
        IF pi_circular_group_ids.COUNT != pi_circular_start_ne_ids.COUNT
         THEN
            --If these arrays are passed check counts are the same.
            hig.raise_ner(pi_appl               => 'AWLRS'
                         ,pi_id                 => 5
                         ,pi_supplementary_info => 'awlrs_reshape_api.reshape_element');
        END IF;
        --
        OPEN  get_linear_groups(lv_ne_id);
        FETCH get_linear_groups
         BULK COLLECT
         INTO lt_groups;
        CLOSE get_linear_groups;
        --
        FOR i IN 1..lt_groups.COUNT LOOP
           --
           lt_parent_ids.EXTEND;
           lt_parent_ids(lt_parent_ids.COUNT) := nm_ne_id_type(lt_groups(i).group_id);
           --
        END LOOP;
        /*
        || From the list of routes 
        || check if any are circular
        || and check if the new nodes will make it circular
        */
        lr_ne := nm3net.get_ne(pi_ne_id => lv_ne_id);
        --
        awlrs_element_api.get_parent_circular_routes(pi_parent_ne_ids       => lt_parent_ids
                                                    ,pi_datum_start_node_id => NVL(pi_new_start_node,lr_ne.ne_no_start)
                                                    ,pi_datum_end_node_id   => NVL(pi_new_end_node,lr_ne.ne_no_end)
                                                    ,po_cursor              => lv_cursor);  
        --
        FETCH lv_cursor
         BULK COLLECT
         INTO lt_circular_routes; 
        CLOSE lv_cursor;
        --
        /*
        ||Check the counts are correct for circ routes. If not then throw back in new cursor.
        */
        IF lt_circular_routes.COUNT = pi_circular_group_ids.COUNT 
         AND lt_circular_routes.COUNT = pi_circular_start_ne_ids.COUNT
         THEN
            FOR i IN 1..lt_groups.COUNT LOOP
              --
              lv_start_ne_id := null;
              --
              FOR j IN 1..pi_circular_group_ids.COUNT LOOP
                IF pi_circular_group_ids(j) = lt_groups(i).group_id
                 THEN 
                    lv_start_ne_id := pi_circular_start_ne_ids(j);
                    EXIT;
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
         ELSE
            /*
            || There is a mismatch of the circular routes we know exist and what the ui is sending through
            || This needs to be thrown back to the user as ciruclar route and all routes ids in the error cursor.
            */
            awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'AWLRS'
                                             ,pi_ner_id             => 60
                                             ,pi_supplementary_info => NULL
                                             ,pi_category           => awlrs_util.c_msg_cat_circular_route
                                             ,po_message_tab        => lt_messages); 
            --
            lv_severity := awlrs_util.c_msg_cat_circular_route;
            --
            OPEN po_circular_route_cursor  FOR
            SELECT nm_elements_all.ne_id group_id
                  ,ne_gty_group_type     group_type
                  ,ne_unique             unique_name
                  ,ne_descr              description
                  ,ne_start_date         start_date
                  ,(SELECT nm_ne_id_of
                      FROM nm_members
                     WHERE nm_ne_id_in = nm_elements_all.ne_id
                       AND nm_seq_no = 1) circ_start_ne_id   
              FROM nm_elements_all
                  ,TABLE(CAST(lt_circular_routes AS nm_ne_id_array)) circular_route_tab
             WHERE nm_elements_all.ne_id = circular_route_tab.ne_id;
         END IF;
    END IF;
    --
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN
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
                         ,pi_new_start_date           => TRUNC(pi_effective_date)
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
        ||Rescale any linear groups the element belongs to.
        */
        IF lv_severity = awlrs_util.c_msg_cat_success
         AND pi_do_rescale_parents = 'Y'
         THEN
            --
            IF pi_do_replace = 'Y'
             THEN
                lt_groups.DELETE;
            END IF;
            --
            OPEN  get_linear_groups(lv_ne_id);
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
                     IF pi_circular_start_ne_ids(j) = pi_ne_id
                      THEN
                        /*
                        ||The start element is the one that may have been replaced so use the new element in the post rescale.
                        */
                        lv_start_ne_id := lv_ne_id;
                     END IF; 
                     EXIT;
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
                         ,pi_use_history      => 'N'
                         ,po_message_severity => lv_severity
                         ,po_message_tab      => lt_messages);
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
    END IF;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity IN(awlrs_util.c_msg_cat_error
                     ,awlrs_util.c_msg_cat_ask_continue
                     ,awlrs_util.c_msg_cat_circular_route)
     THEN
        ROLLBACK TO reshape_element1_sp;
        po_new_ne_id := NULL;
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
