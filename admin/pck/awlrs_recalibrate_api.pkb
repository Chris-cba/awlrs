CREATE OR REPLACE PACKAGE BODY awlrs_recalibrate_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_recalibrate_api.pkb-arc   1.5   Jan 18 2019 11:09:52   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_recalibrate_api.pkb  $
  --       Date into PVCS   : $Date:   Jan 18 2019 11:09:52  $
  --       Date fetched Out : $Modtime:   Jan 15 2019 17:36:42  $
  --       Version          : $Revision:   1.5  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.5  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_recalibrate_api';
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
  PROCEDURE do_replace(pi_ne_id                    IN     nm_elements_all.ne_id%TYPE
                      ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                      ,pi_new_element_column_names IN     awlrs_element_api.attrib_column_name_tab
                      ,pi_new_element_prompts      IN     awlrs_element_api.attrib_prompt_tab
                      ,pi_new_element_char_values  IN     awlrs_element_api.attrib_char_value_tab
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
  PROCEDURE do_recalibration(pi_ne_id                    IN     nm_elements_all.ne_id%TYPE
                            ,pi_start_point              IN     NUMBER
                            ,pi_new_length_to_end        IN     NUMBER
                            ,pi_reason                   IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                            ,pi_maintain_history         IN     VARCHAR2 DEFAULT 'N'
                            ,pi_new_element_column_names IN     awlrs_element_api.attrib_column_name_tab DEFAULT CAST(NULL AS awlrs_element_api.attrib_column_name_tab)
                            ,pi_new_element_prompts      IN     awlrs_element_api.attrib_prompt_tab DEFAULT CAST(NULL AS awlrs_element_api.attrib_prompt_tab)
                            ,pi_new_element_char_values  IN     awlrs_element_api.attrib_char_value_tab DEFAULT CAST(NULL AS awlrs_element_api.attrib_char_value_tab)
                            ,po_new_ne_id                IN OUT nm_elements_all.ne_id%TYPE
                            ,po_message_severity            OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lv_ne_id  nm_elements_all.ne_id%TYPE;
    lr_ne     nm_elements_all%ROWTYPE;
    --
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    e_record_locked exception;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    e_nothing_to_do exception;
    PRAGMA EXCEPTION_INIT(e_nothing_to_do, -20054);
    --
    CURSOR get_linear_groups(cp_ne_id nm_elements_all.ne_id%TYPE)
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
    SAVEPOINT recalibration_sp;
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.is_nt_datum(p_nt_type => lr_ne.ne_nt_type) != 'Y'
     THEN
        --Operation can only be performed on a datum element.
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 119);
    END IF;
    --
    IF pi_start_point < 0
     OR pi_start_point > lr_ne.ne_length
     THEN
        --From measure must be between than 0 and the current element length.
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 30);
    END IF;
    --
    IF pi_maintain_history = 'Y'
     THEN
        /*
        ||Rescale any linear groups the element belongs to.
        */
        OPEN  get_linear_groups(pi_ne_id);
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
        /*
        ||Do the replace.
        */
        IF lv_severity = awlrs_util.c_msg_cat_success
         THEN
            lt_messages.DELETE;
            do_replace(pi_ne_id                    => pi_ne_id
                      ,pi_reason                   => pi_reason
                      ,pi_new_element_column_names => pi_new_element_column_names
                      ,pi_new_element_prompts      => pi_new_element_prompts
                      ,pi_new_element_char_values  => pi_new_element_char_values
                      ,po_new_ne_id                => lv_ne_id
                      ,po_message_severity         => lv_severity
                      ,po_message_tab              => lt_messages);
        END IF;
        --
    ELSE
        --
        lv_ne_id := pi_ne_id;
        --
    END IF;
    --
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN
        lt_messages.DELETE;
        BEGIN
          --
          nm3recal.recalibrate_section(pi_ne_id             => lv_ne_id
                                      ,pi_begin_mp          => pi_start_point
                                      ,pi_new_length_to_end => pi_new_length_to_end
                                      ,pi_neh_descr         => pi_reason);
          --
        EXCEPTION
          WHEN e_nothing_to_do
           THEN
              --Old and new lengths are the same
              hig.raise_ner(pi_appl => 'AWLRS'
                           ,pi_id   => 31);
          WHEN e_record_locked
           THEN
              --Record locked by another user. Try again later.
              hig.raise_ner(pi_appl => 'HIG'
                           ,pi_id   => 33);
        END;
    END IF;
    /*
    ||
    */
    IF pi_maintain_history = 'Y'
     THEN
        /*
        ||Rescale any linear groups the element belongs to.
        */
        OPEN  get_linear_groups(lv_ne_id);
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
                    ,pi_use_history      => 'N'
                    ,po_message_severity => lv_severity
                    ,po_message_tab      => lt_messages);
          --
          IF lv_severity != awlrs_util.c_msg_cat_success
           THEN
              /*
              ||If an error has occurred rescaling a group end the whole operation.
              */
              EXIT;
              --
          END IF;
          --
        END LOOP;
        --
    END IF;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity IN(awlrs_util.c_msg_cat_error
                     ,awlrs_util.c_msg_cat_ask_continue
                     ,awlrs_util.c_msg_cat_circular_route)
     THEN
        ROLLBACK TO recalibration_sp;
        po_new_ne_id := NULL;
    ELSE
        po_new_ne_id := lv_ne_id;
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
        ROLLBACK TO recalibration_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_recalibration;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_shift(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                    ,pi_start_point      IN  NUMBER
                    ,pi_shift_distance   IN  NUMBER
                    ,pi_reason           IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    e_record_locked exception;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    --
  BEGIN
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.is_nt_datum(p_nt_type => lr_ne.ne_nt_type) != 'Y'
     THEN
        --Operation can only be performed on a datum element.
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 119);
    END IF;
    --
    IF pi_start_point IS NULL
     THEN
        --Please enter a value for the start point
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 34);
    END IF;
    --
    IF pi_shift_distance IS NULL
     THEN
        --Please enter a value for the shift distance
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 35);
    END IF;
    --
    IF pi_start_point + pi_shift_distance < 0
     THEN
        --The start point and shift distance place
        --the shift point before the start of the element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 32);
    ELSIF pi_start_point + pi_shift_distance > lr_ne.ne_length
     THEN
        --The start point and shift distance place
        --the shift point after the end of the element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 33);
    END IF;
    --
    BEGIN
      --
      nm3recal.shift_section(pi_ne_id          => pi_ne_id
                            ,pi_begin_mp       => pi_start_point
                            ,pi_shift_distance => pi_shift_distance
                            ,pi_neh_descr      => pi_reason);
      --
    EXCEPTION
      WHEN e_record_locked
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33);
    END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_shift;

END awlrs_recalibrate_api;
/
