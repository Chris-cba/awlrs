CREATE OR REPLACE PACKAGE BODY awlrs_group_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_group_api.pkb-arc   1.17   21 Apr 2017 13:16:18   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_group_api.pkb  $
  --       Date into PVCS   : $Date:   21 Apr 2017 13:16:18  $
  --       Date fetched Out : $Modtime:   21 Apr 2017 13:11:16  $
  --       Version          : $Revision:   1.17  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.17  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_group_api';
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
  PROCEDURE get_members(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor
                       ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT group_element_id
          ,member_element_id
          ,member_seq_no
          ,member_network_type
          ,member_unique
          ,member_description
          ,member_length
          ,member_start_node
          ,member_end_node
          ,member_start_mp
          ,member_end_mp
          ,member_partial_ind
          ,member_membership_length
          ,member_offset
          ,CASE WHEN member_poe = 0 THEN NULL WHEN member_poe < 0 THEN 'O' ELSE 'G' END member_poe
          ,member_cardinality
          ,member_start_date
          ,member_end_date
      FROM (SELECT nm_seq_no member_seq_no
                  ,ne.ne_nt_type member_network_type
                  ,ne.ne_unique member_unique
                  ,ne.ne_descr member_description
                  ,nm3net.get_ne_length(ne.ne_id) member_length
                  ,ne.ne_no_start member_start_node
                  ,ne.ne_no_end member_end_node
                  ,nm.nm_begin_mp member_start_mp
                  ,nm.nm_end_mp member_end_mp
                  ,CASE
                     WHEN nm.nm_end_mp = (nm.nm_end_mp - nm.nm_begin_mp)
                      AND nm.nm_begin_mp = 0
                      THEN
                         'N'
                     ELSE
                         'Y'
                   END member_partial_ind
                  ,(nm.nm_end_mp - nm.nm_begin_mp) member_membership_length
                  ,nm.nm_slk member_offset
                  ,nm3net_o.get_node_class(nm.nm_ne_id_in
                                          ,CASE WHEN nm.nm_cardinality = 1 THEN ne.ne_no_start ELSE ne.ne_no_end END).nc_poe member_poe
                  ,nm.nm_cardinality member_cardinality
                  ,nm.nm_start_date member_start_date
                  ,nm.nm_end_date member_end_date
                  ,nm.nm_ne_id_in group_element_id
                  ,nm.nm_ne_id_of member_element_id
              FROM nm_members nm
                  ,nm_elements ne
             WHERE nm.nm_ne_id_in = pi_ne_id
               AND nm.nm_ne_id_of = ne.ne_id
               AND nm.nm_type = 'G')
     ORDER
        BY member_seq_no
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_members;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_members_essentials(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor
                                  ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nm.nm_ne_id_in group_element_id
          ,nm.nm_ne_id_of member_element_id
          ,ne.ne_unique   member_unique
          ,ne.ne_descr    member_description
      FROM nm_members nm
          ,nm_elements ne
     WHERE nm.nm_ne_id_in = pi_ne_id
       AND nm.nm_ne_id_of = ne.ne_id
       AND nm.nm_type = 'G'
     ORDER
        BY nm_seq_no
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_members_essentials;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sub_groups(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nm.nm_ne_id_in       group_ne_id
          ,nm.nm_ne_id_of       subgroup_ne_id
          ,ne.ne_unique         subgroup_unique
          ,ne.ne_descr          subgroup_descr
          ,ne.ne_nt_type        subgroup_network_type
          ,ne.ne_gty_group_type subgroup_group_type
          ,nm.nm_start_date     subgroup_start_date
          ,nm.nm_end_date       subgroup_end_date
      FROM nm_elements ne
          ,nm_members nm
     WHERE nm.nm_ne_id_in = pi_ne_id
       AND nm.nm_ne_id_of = ne.ne_id
     ORDER
        BY ne.ne_unique
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_sub_groups;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_member(pi_group_rec    IN  nm_elements_all%ROWTYPE
                      ,pi_mem_ne_id    IN  nm_elements.ne_id%TYPE
                      ,pi_mem_begin_mp IN  nm_members.nm_begin_mp%TYPE DEFAULT 0
                      ,pi_mem_end_mp   IN  nm_members.nm_end_mp%TYPE DEFAULT 0
                      ,pi_start_date   IN  nm_members.nm_start_date%TYPE)
    IS
    --
    l_mem_ne_rec  nm_elements%ROWTYPE;
    l_nm_rec      nm_members%ROWTYPE;
    --
  BEGIN
    --
    IF awlrs_element_api.is_nt_inclusion_parent(pi_nt_type => pi_group_rec.ne_nt_type)
     THEN
        --Membership of an Inclusion Parent Group cannot be modified
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 39);
    END IF;
    /*
    ||Get the member element record of the datum.
    */
    l_mem_ne_rec := nm3get.get_ne( pi_mem_ne_id );
    /*
    ||Set the membership details.
    */
    l_nm_rec.nm_ne_id_in   := pi_group_rec.ne_id;
    l_nm_rec.nm_ne_id_of   := pi_mem_ne_id;
    l_nm_rec.nm_type       := 'G';
    l_nm_rec.nm_obj_type   := pi_group_rec.ne_gty_group_type;
    l_nm_rec.nm_start_date := TRUNC(NVL(pi_start_date,GREATEST(pi_group_rec.ne_start_date,l_mem_ne_rec.ne_start_date)));
    l_nm_rec.nm_begin_mp   := NVL(pi_mem_begin_mp, 0);
    l_nm_rec.nm_end_mp     := NVL(pi_mem_end_mp,NVL(nm3net.get_ne_length(pi_mem_ne_id),0));
    /*
    IF nm3net.is_nt_linear (l_group_ne_rec.ne_gty_group_type) = 'Y'
     THEN
        l_nm_rec.nm_slk := nm3net.get_new_slk(p_parent_ne_id => l_nm_rec.nm_ne_id_in
                                             ,p_no_start_new => l_mem_ne_rec.ne_no_start
                                             ,p_no_end_new   => l_mem_ne_rec.ne_no_end
                                             ,p_length       => l_mem_ne_rec.ne_length
                                             ,p_sub_class    => l_mem_ne_rec.ne_sub_class
                                             ,p_datum_ne_id  => l_nm_rec.nm_ne_id_of);
        l_nm_rec.nm_true := l_nm_rec.nm_slk;
    ELSE
        l_nm_rec.nm_slk  := NULL;
        l_nm_rec.nm_true := NULL;
    END IF;
    */
    l_nm_rec.nm_slk         := NULL;
    l_nm_rec.nm_true        := NULL;
    l_nm_rec.nm_cardinality := nm3net.get_element_cardinality(p_route_ne_id => pi_group_rec.ne_id
                                                             ,p_datum_ne_id => pi_mem_ne_id);
    l_nm_rec.nm_admin_unit  := nm3get.get_ne(pi_ne_id => pi_mem_ne_id).ne_admin_unit;
    l_nm_rec.nm_end_date    := l_mem_ne_rec.ne_end_date ;
    l_nm_rec.nm_seq_no      := 0;
    l_nm_rec.nm_seg_no      := 0;
    --
    nm3ins.ins_nm(l_nm_rec);
    --
  END add_member;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_member(pi_group_ne_id      IN  nm_elements.ne_id%TYPE
                      ,pi_mem_ne_id        IN  nm_elements.ne_id%TYPE
                      ,pi_mem_begin_mp     IN  nm_members.nm_begin_mp%TYPE DEFAULT 0
                      ,pi_mem_end_mp       IN  nm_members.nm_end_mp%TYPE DEFAULT 0
                      ,pi_start_date       IN  nm_members.nm_start_date%TYPE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_group_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT add_member_sp;
    /*
    ||Get the group element record.
    */
    lr_group_ne := nm3get.get_ne(pi_group_ne_id);
    /*
    ||Add the Member.
    */
    add_member(pi_group_rec    => lr_group_ne
              ,pi_mem_ne_id    => pi_mem_ne_id
              ,pi_mem_begin_mp => pi_mem_begin_mp
              ,pi_mem_end_mp   => pi_mem_end_mp
              ,pi_start_date   => pi_start_date);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO add_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_member;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_members(pi_group_ne_id      IN  nm_elements.ne_id%TYPE
                       ,pi_mem_ne_ids       IN  awlrs_util.ne_id_tab
                       ,pi_mem_begin_mps    IN  awlrs_util.offset_tab
                       ,pi_mem_end_mps      IN  awlrs_util.offset_tab
                       ,pi_start_date       IN  nm_members.nm_start_date%TYPE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_group_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT add_members_sp;
    --
    IF pi_mem_ne_ids.COUNT != pi_mem_begin_mps.COUNT
     OR pi_mem_ne_ids.COUNT != pi_mem_end_mps.COUNT
     THEN
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_group_api.add_members');
    END IF;
    /*
    ||Get the group element record.
    */
    lr_group_ne := nm3get.get_ne(pi_group_ne_id);
    --
    FOR i IN 1..pi_mem_ne_ids.COUNT LOOP
      /*
      ||Add the Member.
      */
      add_member(pi_group_rec    => lr_group_ne
                ,pi_mem_ne_id    => pi_mem_ne_ids(i)
                ,pi_mem_begin_mp => pi_mem_begin_mps(i)
                ,pi_mem_end_mp   => pi_mem_end_mps(i)
                ,pi_start_date   => pi_start_date);
    END LOOP;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO add_members_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_members;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_member(pi_group_ne_id      IN  nm_elements.ne_id%TYPE
                         ,pi_mem_ne_id        IN  nm_elements.ne_id%TYPE
                         ,pi_mem_start_date   IN  nm_members.nm_start_date%TYPE
                         ,pi_old_mem_begin_mp IN  nm_members.nm_begin_mp%TYPE
                         ,pi_old_mem_end_mp   IN  nm_members.nm_end_mp%TYPE
                         ,pi_new_mem_begin_mp IN  nm_members.nm_begin_mp%TYPE
                         ,pi_new_mem_end_mp   IN  nm_members.nm_end_mp%TYPE
                         ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_group_ne  nm_elements_all%ROWTYPE;
    lr_db_rec    nm_members%ROWTYPE;
    --
    PROCEDURE get_db_rec(pi_group_ne_id    IN nm_elements.ne_id%TYPE
                        ,pi_mem_ne_id      IN nm_elements.ne_id%TYPE
                        ,pi_mem_begin_mp   IN nm_members.nm_begin_mp%TYPE
                        ,pi_mem_start_date IN nm_members.nm_start_date%TYPE)
      IS
    BEGIN
      BEGIN
        --
        SELECT *
          INTO lr_db_rec
          FROM nm_members
         WHERE nm_ne_id_in = pi_group_ne_id
           AND nm_ne_id_of = pi_mem_ne_id
           AND nm_begin_mp = pi_mem_begin_mp
           AND nm_start_date = pi_mem_start_date
           FOR UPDATE NOWAIT
             ;
        --
      EXCEPTION
       WHEN no_data_found
        THEN
           --Invalid Group Member supplied
           hig.raise_ner(pi_appl => 'AWLRS'
                        ,pi_id   => 41);
      END;
      --       
    END get_db_rec;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT update_member_sp;
    /*
    ||Get the group element record.
    */
    lr_group_ne := nm3get.get_ne(pi_group_ne_id);
    --
    IF nm3net.is_gty_partial(lr_group_ne.ne_gty_group_type) = 'N'
     THEN
        --Update of Start and/or End of a Member is not allowed for non Partial Group Types
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 40);        
    END IF;
    --
    IF awlrs_element_api.is_nt_inclusion_parent(pi_nt_type => lr_group_ne.ne_nt_type)
     THEN
        --Membership of an Inclusion Parent Group cannot be modified
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 39);
    END IF;
    /*
    ||Lock the row.
    */
    get_db_rec(pi_group_ne_id    => pi_group_ne_id
              ,pi_mem_ne_id      => pi_mem_ne_id
              ,pi_mem_begin_mp   => pi_old_mem_begin_mp
              ,pi_mem_start_date => pi_mem_start_date);
    /*
    ||Compare old with DB.
    ||Start has effectively already been checked as it is part of the primary key.
    */
    IF lr_db_rec.nm_end_mp != pi_old_mem_end_mp
     OR (lr_db_rec.nm_end_mp IS NULL AND pi_old_mem_end_mp IS NOT NULL)
     OR (lr_db_rec.nm_end_mp IS NOT NULL AND pi_old_mem_end_mp IS NULL)
     THEN
        --Updated by another user
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 24);
    END IF;
    /*
    ||Compare new with old.
    */
    IF (pi_old_mem_begin_mp = pi_new_mem_begin_mp OR (pi_old_mem_begin_mp IS NULL AND pi_new_mem_begin_mp IS NULL))
     AND (pi_old_mem_end_mp = pi_new_mem_end_mp OR (pi_old_mem_end_mp IS NULL AND pi_new_mem_end_mp IS NULL))
     THEN
        --There are no changes to be applied
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 25);
    END IF;
    /*
    ||Update the record.
    */
    UPDATE nm_members
       SET nm_begin_mp = pi_new_mem_begin_mp
          ,nm_end_mp = pi_new_mem_end_mp
     WHERE nm_ne_id_in = pi_group_ne_id
       AND nm_ne_id_of = pi_mem_ne_id
       AND nm_begin_mp = pi_old_mem_begin_mp
       AND nm_start_date = pi_mem_start_date
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO update_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_member;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE end_date_membership(pi_group_ne_id      IN  nm_elements.ne_id%TYPE
                               ,pi_mem_ne_id        IN  nm_elements.ne_id%TYPE
                               ,pi_mem_begin_mp     IN  nm_members.nm_begin_mp%TYPE
                               ,pi_mem_start_date   IN  nm_members.nm_start_date%TYPE
                               ,pi_effective_date   IN  DATE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_group_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT enddate_member_sp;
    /*
    ||Get the group element record.
    */
    lr_group_ne := nm3get.get_ne(pi_group_ne_id);
    --
    IF awlrs_element_api.is_nt_inclusion_parent(pi_nt_type => lr_group_ne.ne_nt_type)
     THEN
        --Membership of an Inclusion Parent Group cannot be modified
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 39);
    END IF;
    /*
    ||End date the membership of a member in a Group of Sections.
    */
    UPDATE nm_members
       SET nm_end_date = TRUNC(pi_effective_date)
     WHERE nm_ne_id_in = pi_group_ne_id
       AND nm_ne_id_of = pi_mem_ne_id
       AND nm_begin_mp = pi_mem_begin_mp
       AND nm_start_date = pi_mem_start_date
       AND nm_end_date IS NULL
         ;
    /*
    ||If the member is a distance break then end date it as well as its membership.
    */
    UPDATE nm_elements_all
       SET ne_end_date = TRUNC(pi_effective_date)
     WHERE ne_id = pi_mem_ne_id
       AND ne_type = 'D'
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO enddate_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END end_date_membership;

  --
  -----------------------------------------------------------------------------
  --
  --NB. If the value of pi_run_checks passed in is not 'Y' then the calling code
  --should have already called the procedure with the value as 'Y' and handled any
  --errors or prompts for user confirmation.
  --
  PROCEDURE add_distance_break(pi_route_ne_id      IN  nm_members.nm_ne_id_of%TYPE
                              ,pi_start_node_id    IN  nm_nodes.no_node_id%TYPE
                              ,pi_end_node_id      IN  nm_nodes.no_node_id%TYPE
                              ,pi_start_date       IN  DATE
                              ,pi_length           IN  nm_elements.ne_length%TYPE
                              ,pi_run_checks       IN  VARCHAR2 DEFAULT 'Y'
                              ,po_db_ne_id         OUT nm_members.nm_ne_id_in%TYPE
                              ,po_db_ne_unique     OUT nm_elements.ne_unique%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_ne_id      nm_members.nm_ne_id_in%TYPE;
    lv_ne_unique  nm_elements.ne_unique%TYPE;
    --
    lr_group_ne  nm_elements_all%ROWTYPE;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT add_distbreak_sp;
    /*
    ||Get the group element record.
    */
    lr_group_ne := nm3get.get_ne(pi_route_ne_id);
    --
    IF awlrs_element_api.is_nt_inclusion_parent(pi_nt_type => lr_group_ne.ne_nt_type)
     THEN
        --Membership of an Inclusion Parent Group cannot be modified
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 39);
    END IF;
    --
    IF pi_start_node_id IS NULL
     THEN
        -- Field must be entered
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 22
                     ,pi_supplementary_info => 'Start Node');
        --
    ELSIF pi_end_node_id IS NULL
     THEN
        -- Field must be entered
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 22
                     ,pi_supplementary_info => 'End Node');
        --
    ELSIF pi_length IS NULL
     THEN
        -- Field must be entered
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 22
                     ,pi_supplementary_info => 'Length');
        --
    ELSIF pi_start_date IS NULL
     THEN
        -- Field must be entered
        hig.raise_ner(pi_appl               => 'HIG'
                     ,pi_id                 => 22
                     ,pi_supplementary_info => 'Start Date');
        --
    ELSIF pi_start_node_id = pi_end_node_id
     THEN
        -- Start and end nodes cannot be the same.
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 126);

    END IF;
    --
    IF pi_run_checks = 'Y'
     THEN
        IF nm3net.datum_will_overlap_existing(pi_route          => pi_route_ne_id
                                             ,pi_new_start_node => pi_start_node_id
                                             ,pi_new_end_node   => pi_end_node_id)
         THEN
            awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                             ,pi_ner_id      => 155
                                             ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                             ,po_message_tab => lt_messages);
        END IF;
    END IF;
    --
    IF lt_messages.COUNT > 0
     THEN
        awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                     ,po_cursor      => po_message_cursor);
        awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                       ,po_message_severity => po_message_severity);
    ELSE
        nm3net.insert_distance_break(pi_route_ne_id   => pi_route_ne_id
                                    ,pi_start_node_id => pi_start_node_id
                                    ,pi_end_node_id   => pi_end_node_id
                                    ,pi_start_date    => TRUNC(pi_start_date)
                                    ,pi_length        => pi_length
                                    ,po_db_ne_id      => lv_ne_id
                                    ,po_db_ne_unique  => lv_ne_unique);
        --
        po_db_ne_id := lv_ne_id;
        po_db_ne_unique := lv_ne_unique;
        --
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN others
      THEN
        ROLLBACK TO add_distbreak_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_distance_break;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE warn_if_route_ill_formed(po_message_severity  IN OUT hig_codes.hco_code%TYPE
                                    ,po_message_tab       IN OUT NOCOPY awlrs_message_tab)
    IS
  BEGIN
    /*
    ||Warn the user if the route is ill formed.
    */
    IF NOT(nm3rsc.stranded_element_check)
     THEN
        awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                         ,pi_ner_id      => 154
                                         ,pi_category    => awlrs_util.c_msg_cat_warning
                                         ,po_message_tab => po_message_tab);
        po_message_severity := awlrs_util.c_msg_cat_warning;
    END IF;
    --
  END warn_if_route_ill_formed;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE rescale_route(pi_ne_id          IN nm_elements.ne_id%TYPE
                         ,pi_effective_date IN DATE
                         ,pi_offset_st      IN NUMBER
                         ,pi_start_ne_id    IN nm_elements.ne_id%TYPE DEFAULT NULL
                         ,pi_use_history    IN VARCHAR2)
    IS
    --
    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);
    --
    e_segment_number_error exception;
    PRAGMA EXCEPTION_INIT(e_segment_number_error, -20201);
    --
    e_sequence_number_error exception;
    PRAGMA EXCEPTION_INIT(e_sequence_number_error, -20202);
    --
    e_true_distance_error exception;
    PRAGMA EXCEPTION_INIT(e_true_distance_error, -20203);
    --
    e_cannot_find_slk exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_slk, -20204);
    --
    e_cannot_find_length exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_length, -20205);
    --
  BEGIN
    --
    nm3rsc.rescale_route(pi_ne_id          => pi_ne_id
                        ,pi_effective_date => TRUNC(pi_effective_date)
                        ,pi_offset_st      => pi_offset_st
                        ,pi_st_element_id  => NULL
                        ,pi_use_history    => pi_use_history
                        ,pi_ne_start       => pi_start_ne_id);
    --
  EXCEPTION
    WHEN e_route_locked
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 33);
    WHEN e_segment_number_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 65);
    WHEN e_sequence_number_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 66);
    WHEN e_true_distance_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 67);
    WHEN e_cannot_find_slk
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 68);
    WHEN e_cannot_find_length
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 69);
  END rescale_route;

  --
  -----------------------------------------------------------------------------
  --
  --NB. If the value of pi_use_history passed in is not 'Y' then the calling
  --code should have already called the procedure with the value as 'Y' and 
  --handled any prompts for user confirmation.
  --
  PROCEDURE rescale_route(pi_ne_id            IN  nm_elements.ne_id%TYPE
                         ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                         ,pi_offset_st        IN  NUMBER
                         ,pi_start_ne_id      IN  nm_elements.ne_id%TYPE DEFAULT NULL
                         ,pi_use_history      IN  VARCHAR2
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    e_member_dates_out_of_range EXCEPTION;
	  PRAGMA EXCEPTION_INIT(e_member_dates_out_of_range, -20206);
    --
    e_rescale_loop exception;
    PRAGMA EXCEPTION_INIT(e_rescale_loop, -20207);
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT rescale_route_sp;
    --
    BEGIN
      --
      rescale_route(pi_ne_id          => pi_ne_id
                   ,pi_effective_date => pi_effective_date
                   ,pi_offset_st      => pi_offset_st
                   ,pi_start_ne_id    => pi_start_ne_id
                   ,pi_use_history    => pi_use_history);
      --
    EXCEPTION
      WHEN e_rescale_loop
		   THEN
          /*
          ||Ask the user to select a Datum to start from.
          */
          ROLLBACK TO rescale_route_sp;
          SAVEPOINT rescale_route_sp;
          awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'AWLRS'
                                           ,pi_ner_id      => 47
                                           ,pi_category    => awlrs_util.c_msg_cat_circular_route
                                           ,po_message_tab => lt_messages);
      WHEN e_member_dates_out_of_range
		   THEN
          /*
          ||Ask the user if they wish to continue without
          ||maintaining history.
          */
          ROLLBACK TO rescale_route_sp;
          SAVEPOINT rescale_route_sp;
          awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                           ,pi_ner_id      => 63
                                           ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                           ,po_message_tab => lt_messages);
    END;
    --
    IF lt_messages.COUNT = 0
     THEN
        warn_if_route_ill_formed(po_message_severity => lv_severity
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
        ROLLBACK TO rescale_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END rescale_route;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resequence_route(pi_ne_id       IN nm_elements.ne_id%TYPE
                            ,pi_start_ne_id IN nm_elements.ne_id%TYPE DEFAULT NULL)
    IS
    --
    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);
    --
    e_segment_number_error exception;
    PRAGMA EXCEPTION_INIT(e_segment_number_error, -20201);
    --
    e_sequence_number_error exception;
    PRAGMA EXCEPTION_INIT(e_sequence_number_error, -20202);
    --
    e_true_distance_error exception;
    PRAGMA EXCEPTION_INIT(e_true_distance_error, -20203);
    --
    e_cannot_find_slk exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_slk, -20204);
    --
    e_cannot_find_length exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_length, -20205);
    --
  BEGIN
    --
    nm3rsc.reseq_route(pi_ne_id    => pi_ne_id
                      ,pi_ne_start => pi_start_ne_id);
    --
  EXCEPTION
    WHEN e_route_locked
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 33);
    WHEN e_segment_number_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 65);
    WHEN e_sequence_number_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 66);
    WHEN e_true_distance_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 67);
    WHEN e_cannot_find_slk
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 68);
    WHEN e_cannot_find_length
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 69);
    WHEN others
     THEN
        RAISE;
  END resequence_route;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resequence_route(pi_ne_id            IN  nm_elements.ne_id%TYPE
                            ,pi_start_ne_id      IN  nm_elements.ne_id%TYPE DEFAULT NULL
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    e_rescale_loop exception;
    PRAGMA EXCEPTION_INIT(e_rescale_loop, -20207);
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reseq_route_sp;
    /*
    ||do resequence
    */
    BEGIN
      resequence_route(pi_ne_id       => pi_ne_id
                      ,pi_start_ne_id => pi_start_ne_id);
    EXCEPTION
      WHEN e_rescale_loop
		   THEN
          /*
          ||Ask the user to select a Datum to start from.
          */
          ROLLBACK TO reseq_route_sp;
          SAVEPOINT rescale_route_sp;
          awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'AWLRS'
                                           ,pi_ner_id      => 47
                                           ,pi_category    => awlrs_util.c_msg_cat_circular_route
                                           ,po_message_tab => lt_messages);
    END;
    /*
    ||Return a warning if the route is ill formed.
    */
    IF lt_messages.COUNT = 0
     THEN
        warn_if_route_ill_formed(po_message_severity => lv_severity
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
        ROLLBACK TO reseq_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END resequence_route;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reverse_route(pi_ne_id          IN nm_elements.ne_id%TYPE
                         ,pi_effective_date IN DATE)
    IS
    --
    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);
    --
    e_segment_number_error exception;
    PRAGMA EXCEPTION_INIT(e_segment_number_error, -20201);
    --
    e_sequence_number_error exception;
    PRAGMA EXCEPTION_INIT(e_sequence_number_error, -20202);
    --
    e_true_distance_error exception;
    PRAGMA EXCEPTION_INIT(e_true_distance_error, -20203);
    --
    e_cannot_find_slk exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_slk, -20204);
    --
    e_cannot_find_length exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_length, -20205);
    --
    e_no_xsp_reversal exception;
    PRAGMA EXCEPTION_INIT(e_no_xsp_reversal, -20251);
    --
    e_unique_found exception;
    PRAGMA EXCEPTION_INIT(e_unique_found, -00001);
    --
  BEGIN
    --
    nm3rvrs.reverse_route(pi_ne_id          => pi_ne_id
                         ,pi_effective_date => TRUNC(pi_effective_date));
    --
  EXCEPTION
    WHEN e_route_locked
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 33);
    WHEN e_segment_number_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 65);
    WHEN e_sequence_number_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 66);
    WHEN e_true_distance_error
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 67);
    WHEN e_cannot_find_slk
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 68);
    WHEN e_cannot_find_length
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 69);
    WHEN e_no_xsp_reversal
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 64);
    WHEN e_unique_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 64);
  END reverse_route;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reverse_route(pi_ne_id            IN  nm_elements.ne_id%TYPE
                         ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reverse_route_sp;
    --
    reverse_route(pi_ne_id          => pi_ne_id
                 ,pi_effective_date => pi_effective_date);
    --
    IF nm3rvrs.get_g_rvrs_circroute = 'Y'
     THEN
        /*
        ||Circular route - please rescale with no history.
        */
        awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                         ,pi_ner_id      => 300
                                         ,pi_category    => awlrs_util.c_msg_cat_warning
                                         ,po_message_tab => lt_messages);
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
        ROLLBACK TO reverse_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reverse_route;

  --
  -----------------------------------------------------------------------------
  --
  --NB. If the value of pi_use_history passed in is not 'Y' then the calling
  --code should have already called the procedure with the value as 'Y' and 
  --handled any prompts for user confirmation.
  --
  PROCEDURE local_rescale(pi_ne_id_in         IN  nm_elements.ne_id%TYPE
                         ,pi_ne_id_of         IN  nm_elements.ne_id%TYPE
                         ,pi_begin_mp         IN  nm_members.nm_begin_mp%TYPE
                         ,pi_use_history      IN  VARCHAR2 DEFAULT 'Y'
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    e_member_dates_out_of_range EXCEPTION;
	  PRAGMA EXCEPTION_INIT(e_member_dates_out_of_range, -20206);
    --
    e_route_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT local_rescale_sp;
    --
    IF pi_ne_id_in IS NOT NULL
     AND pi_ne_id_of IS NOT NULL
     THEN
        BEGIN
          nm3rsc.local_rescale(pi_ne_id_in       => pi_ne_id_in
                              ,pi_ne_id_of       => pi_ne_id_of
                              ,pi_begin_mp       => pi_begin_mp
                              ,pi_effective_date => TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                              ,pi_use_history    => (pi_use_history = 'Y'));
        EXCEPTION
          WHEN e_member_dates_out_of_range
		       THEN
              awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                               ,pi_ner_id      => 63
                                               ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                               ,po_message_tab => lt_messages);
          WHEN e_route_locked
           THEN
              hig.raise_ner(pi_appl => 'HIG'
                           ,pi_id   => 33);
        END;
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
        ROLLBACK TO local_rescale_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END local_rescale;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_check(pi_ne_id IN nm_elements.ne_id%TYPE)
    IS
    --
    e_right_end_not_compat EXCEPTION;
    --
    e_left_end_not_compat EXCEPTION;
    --
    e_datum_starts_not_campat EXCEPTION;
    --
    e_datum_ends_not_campat EXCEPTION;
    --
    e_too_many_starts EXCEPTION;
    PRAGMA exception_init(e_too_many_starts, -20355);
    --
    e_too_many_ends EXCEPTION;
    PRAGMA exception_init(e_too_many_ends, -20356);
    --
    e_invalid_scl_start EXCEPTION;
    PRAGMA exception_init(e_invalid_scl_start, -20357);
    --
    e_invalid_scl_end EXCEPTION;
    PRAGMA exception_init(e_invalid_scl_end, -20358);
    --
    lv_route_status          PLS_INTEGER;
    lv_offending_datums_msg  nm3type.max_varchar2;
    --
    lt_offending_datums  nm3type.tab_varchar30;
    --
  BEGIN
    --
    IF pi_ne_id IS NOT NULL
     THEN
        nm3route_check.route_check(pi_ne_id            => pi_ne_id
                                  ,po_route_status     => lv_route_status
                                  ,po_offending_datums => lt_offending_datums);
        --check route status
        IF lv_route_status > 0
         THEN
            IF lt_offending_datums.COUNT > 0
             THEN
                --
                lv_offending_datums_msg := CHR(10)||CHR(10);
                --
                FOR i IN 1..lt_offending_datums.COUNT LOOP
                  --
                  lv_offending_datums_msg := lv_offending_datums_msg||lt_offending_datums(i)||', ';
                  --
                END LOOP;
                --
                lv_offending_datums_msg := RTRIM(lv_offending_datums_msg,', ');
                --
            END IF;
            --
            IF lv_route_status = 5
             THEN
                RAISE e_right_end_not_compat;
            ELSIF lv_route_status = 10
             THEN
                RAISE e_left_end_not_compat;
            ELSIF lv_route_status = 15
             THEN
                RAISE e_datum_starts_not_campat;
            ELSIF lv_route_status = 20
             THEN
                RAISE e_datum_ends_not_campat;
            END IF;
        END IF;
    END IF;
    --
  EXCEPTION
    WHEN e_right_end_not_compat
     THEN
        hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 157
                     ,pi_supplementary_info => lv_offending_datums_msg);
    WHEN e_left_end_not_compat
     THEN
        hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 158
                     ,pi_supplementary_info => lv_offending_datums_msg);
    WHEN e_datum_starts_not_campat
     THEN
        hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 159
                     ,pi_supplementary_info => lv_offending_datums_msg);
    WHEN e_datum_ends_not_campat
     THEN
        hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 160
                     ,pi_supplementary_info => lv_offending_datums_msg);
    WHEN e_too_many_starts
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 161);
    WHEN e_too_many_ends
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 162);
    WHEN e_invalid_scl_start
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 163);
    WHEN e_invalid_scl_end
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 164);
  END route_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_check(pi_ne_id            IN nm_elements.ne_id%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    route_check(pi_ne_id => pi_ne_id);
    /*
    ||No errors raised so return a success message.
    */
    awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                     ,pi_ner_id      => 156
                                     ,pi_category    => awlrs_util.c_msg_cat_info
                                     ,po_message_tab => lt_messages);
    --
    awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                 ,po_cursor      => po_message_cursor);
    awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                   ,po_message_severity => po_message_severity);
    --
  EXCEPTION
    WHEN OTHERS
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END route_check;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_route_details(pi_ne_id            IN  nm_elements.ne_id%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_min_offset       NUMBER;
    lv_max_offset       NUMBER;
    lv_max_true_offset  NUMBER;
    lv_total_length     NUMBER;
    lv_group_unit_id    NUMBER;
    lv_group_unit_name  nm_units.un_unit_name%TYPE;
    lv_datum_unit_id    NUMBER;
    lv_datum_unit_name  nm_units.un_unit_name%TYPE;
    lv_member_ne_id     nm_elements_all.ne_id%TYPE;
    --
    lr_ne_group  nm_elements%ROWTYPE;
    --
    CURSOR get_member_id(cp_ne_id IN nm_elements_all.ne_id%TYPE)
        IS
    SELECT nm_ne_id_of
      FROM nm_members
     WHERE nm_ne_id_in = cp_ne_id
       AND nm_type = 'G'
         ;
    --
  BEGIN
    --
    IF pi_ne_id IS NOT NULL
     THEN
        -- get the group element record
        lr_ne_group := nm3get.get_ne(pi_ne_id);
        --
        lv_min_offset         := nm3net.get_min_slk(pi_ne_id);
        lv_max_offset         := nm3net.get_max_slk(pi_ne_id);
        lv_max_true_offset    := nm3net.get_max_true(pi_ne_id);
        lv_total_length := nm3net.get_ne_length(pi_ne_id);
        --
        lv_group_unit_id := nm3net.get_nt_units(p_nt_type => lr_ne_group.ne_nt_type);
        --
        IF lv_group_unit_id IS NOT NULL
         THEN
            lv_group_unit_name := nm3unit.get_unit_name(p_un_id => lv_group_unit_id);
        END IF;
        --
        OPEN  get_member_id(pi_ne_id);
        FETCH get_member_id
         INTO lv_member_ne_id;
        CLOSE get_member_id;
        --
        IF lv_member_ne_id IS NOT NULL
        THEN
           lv_datum_unit_id := nm3net.get_nt_units(p_nt_type => nm3net.get_nt_type(p_ne_id => lv_member_ne_id));
        END IF;
        --
        IF lv_datum_unit_id IS NOT NULL
        THEN
          lv_datum_unit_name := nm3unit.get_unit_name(p_un_id => lv_datum_unit_id);
        END IF;
        --
    END IF;
    --
    OPEN po_cursor FOR
    SELECT lv_min_offset      min_offset
          ,lv_group_unit_name min_offset_units
          ,lv_max_offset      max_offset
          ,lv_group_unit_name max_offset_units
          ,lv_max_true_offset max_true_offset
          ,lv_group_unit_name max_true_offset_units
          ,lv_total_length    total_length
          ,lv_datum_unit_name total_length_units
      FROM dual
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_route_details;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resize_route(pi_ne_id            IN  nm_elements.ne_id%TYPE
                        ,pi_start_ne_id      IN  nm_elements.ne_id%TYPE DEFAULT NULL
                        ,pi_new_length       IN  nm_elements.ne_length%TYPE
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    e_rescale_loop exception;
    PRAGMA EXCEPTION_INIT(e_rescale_loop, -20207);
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT resize_route_sp;
    --
    BEGIN
      nm3rsc.resize_route(pi_ne_id    => pi_ne_id
                         ,pi_new_size => pi_new_length
                         ,pi_ne_start => pi_start_ne_id);
    EXCEPTION
      WHEN e_rescale_loop
		   THEN
          /*
          ||Ask the user to select a Datum to start from.
          */
          ROLLBACK TO resize_route_sp;
          SAVEPOINT rescale_route_sp;
          awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'AWLRS'
                                           ,pi_ner_id      => 47
                                           ,pi_category    => awlrs_util.c_msg_cat_circular_route
                                           ,po_message_tab => lt_messages);
    END;
    /*
    ||Return a warning if the route is ill formed.
    */
    IF lt_messages.COUNT = 0
     THEN
        warn_if_route_ill_formed(po_message_severity => lv_severity
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
        ROLLBACK TO resize_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END resize_route;

--
-----------------------------------------------------------------------------
--
END awlrs_group_api;
/