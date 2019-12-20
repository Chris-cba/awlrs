CREATE OR REPLACE PACKAGE BODY awlrs_close_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_close_api.pkb-arc   1.5   Dec 20 2019 14:00:44   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_close_api.pkb  $
  --       Date into PVCS   : $Date:   Dec 20 2019 14:00:44  $
  --       Date fetched Out : $Modtime:   Dec 20 2019 10:34:14  $
  --       Version          : $Revision:   1.5  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.5  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_close_api';
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
  PROCEDURE do_close(pi_ne_id                 IN     nm_elements_all.ne_id%TYPE
                    ,pi_reason                IN     nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_effective_date        IN     DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,pi_do_maintain_history   IN     VARCHAR2 DEFAULT 'N'
                    ,pi_circular_group_ids    IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)
                    ,pi_circular_start_ne_ids IN     awlrs_util.ne_id_tab DEFAULT CAST(NULL AS awlrs_util.ne_id_tab)
                    ,po_message_severity         OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor           OUT sys_refcursor)
    IS
    --
    lv_severity    hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_start_ne_id nm_elements_all.ne_id%TYPE;
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
    SAVEPOINT do_close_sp;
    /*
    ||If maintain history is set to yes then rescale all parent groups pre operation and post operation. 
    ||If there are circular routes then an array should have been passed with the start element id.
    */
    IF pi_do_maintain_history = 'Y'
     THEN
        --
        IF pi_circular_group_ids.COUNT != pi_circular_start_ne_ids.COUNT
         THEN
            --If these arrays are passed check counts are the same.
            hig.raise_ner(pi_appl               => 'AWLRS'
                         ,pi_id                 => 5
                         ,pi_supplementary_info => 'awlrs_close_api.do_close');
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
        DECLARE
          e_record_locked EXCEPTION;
		    	PRAGMA exception_init(e_record_locked, -54);
        BEGIN
          nm3close.do_close(p_ne_id          => pi_ne_id
		                       ,p_effective_date => pi_effective_date
		                       ,p_neh_descr      => pi_reason);
        EXCEPTION
          WHEN e_record_locked
           THEN
              hig.raise_ner(pi_appl => 'HIG'
                           ,pi_id   => 33); 
        END;
    END IF;
    /*
    ||Rescale any linear groups the element belongs to.
    */
    IF lv_severity = awlrs_util.c_msg_cat_success
     AND pi_do_maintain_history = 'Y'
     THEN
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
        ROLLBACK TO do_close_sp;
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
        ROLLBACK TO do_close_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_close;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE close_group(pi_ne_id            IN  nm_elements.ne_id%TYPE
                       ,pi_effective_date   IN  DATE      
                       ,pi_close_all        IN  VARCHAR2 DEFAULT 'N'
                       ,pi_end_date_datums  IN  VARCHAR2
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT enddate_group_sp;
    --
    DECLARE
      --
      e_route_locked EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_route_locked, -54);
      e_end_date EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_end_date, -20984);
      --  
    BEGIN
      nm3close.multi_element_close(pi_type            => nm3close.get_c_route
                                  ,pi_id              => pi_ne_id
                                  ,pi_effective_date  => TRUNC(pi_effective_date)
                                  ,pi_close_all       => pi_close_all
                                  ,pi_end_date_datums => pi_end_date_datums);
    EXCEPTION
      WHEN e_route_locked
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33); 
      WHEN e_end_date
        THEN
          hig.raise_ner(pi_appl => 'NET'
                       ,pi_id   => 13); 
    END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO enddate_group_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END close_group;

END awlrs_close_api;
/
