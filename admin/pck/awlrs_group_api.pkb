CREATE OR REPLACE PACKAGE BODY awlrs_group_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_group_api.pkb-arc   1.0   Oct 24 2016 10:31:42   Vikas.Mhetre  $
  --       Module Name      : $Workfile:   awlrs_group_api.pkb  $
  --       Date into PVCS   : $Date:   Oct 24 2016 10:31:42  $
  --       Date fetched Out : $Modtime:   Oct 24 2016 10:21:24  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.0  $';
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
  PROCEDURE create_group_element(pi_theme_name          IN     nm_themes_all.nth_theme_name%TYPE
                                ,pi_network_type        IN     nm_elements_all.ne_nt_type%TYPE
                                ,pi_description         IN     nm_elements_all.ne_descr%TYPE
                                ,pi_admin_unit_id       IN     nm_elements_all.ne_admin_unit%TYPE
                                ,pi_start_date          IN     nm_elements_all.ne_start_date%TYPE     DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                ,pi_end_date            IN     nm_elements_all.ne_end_date%TYPE       DEFAULT NULL
                                ,pi_group_type          IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                                ,pi_start_node_id       IN     nm_elements_all.ne_no_start%TYPE       DEFAULT NULL
                                ,pi_end_node_id         IN     nm_elements_all.ne_no_end%TYPE         DEFAULT NULL
                                ,pi_attrib_column_names IN     awlrs_element_api.attrib_column_name_tab
                                ,pi_attrib_prompts      IN     awlrs_element_api.attrib_prompt_tab
                                ,pi_attrib_char_values  IN     awlrs_element_api.attrib_char_value_tab
                                ,po_ne_id               IN OUT nm_elements_all.ne_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor) IS
  BEGIN
    --
    awlrs_element_api.create_element(pi_theme_name          => pi_theme_name
                                    ,pi_network_type        => pi_network_type
                                    ,pi_element_type        => 'G'
                                    ,pi_description         => pi_description
                                    ,pi_length              => ''
                                    ,pi_admin_unit_id       => pi_admin_unit_id
                                    ,pi_start_date          => pi_start_date
                                    ,pi_end_date            => pi_end_date
                                    ,pi_group_type          => pi_group_type
                                    ,pi_start_node_id       => pi_start_node_id
                                    ,pi_end_node_id         => pi_end_node_id
                                    ,pi_attrib_column_names => pi_attrib_column_names
                                    ,pi_attrib_prompts      => pi_attrib_prompts
                                    ,pi_attrib_char_values  => pi_attrib_char_values
                                    ,pi_shape_wkt           => ''
                                    ,po_ne_id               => po_ne_id
                                    ,po_message_severity    => po_message_severity
                                    ,po_message_cursor      => po_message_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_element;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_element(pi_ne_id             IN nm_elements_all.ne_id%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor) IS

    lv_cursor  sys_refcursor;
  BEGIN

    IF nm3net.element_is_a_group(pi_ne_id) THEN 
      awlrs_element_api.get_element(pi_ne_id            => pi_ne_id
                                   ,po_message_severity => po_message_severity
                                   ,po_message_cursor   => po_message_cursor
                                   ,po_cursor           => lv_cursor);
      po_cursor := lv_cursor;
    ELSE
       -- Invalid Group of Datums Id supplied
       hig.raise_ner(pi_appl => 'AWLRS'
                    ,pi_id   => 26);
    END IF;

    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_element;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE end_date_group(pi_ne_id             IN nm_elements.ne_id%TYPE
                          ,pi_effective_date    IN DATE      
                          ,pi_close_all         IN VARCHAR2
                          ,pi_end_date_datums   IN VARCHAR2
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ) IS
    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);
    e_end_date exception;
    PRAGMA EXCEPTION_INIT(e_end_date, -20984);

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT enddate_group_sp;
    --
    nm3close.multi_element_close(pi_type            => nm3close.get_c_route
                                ,pi_id              => pi_ne_id
                                ,pi_effective_date  => pi_effective_date
                                ,pi_close_all       => pi_close_all
                                ,pi_end_date_datums => pi_end_date_datums);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN e_route_locked
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 33); 
    WHEN e_end_date
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 13); 
    WHEN others
      THEN
        ROLLBACK TO enddate_group_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END end_date_group;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_members(pi_ne_id             IN nm_elements_all.ne_id%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor
                       ,po_cursor           OUT sys_refcursor) IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT group_ne_id, 
           mem_ne_id, 
           mem_seq,
           mem_unique,
           mem_start_node,
           mem_end_node,
           mem_start_mp,
           mem_end_mp,
           mem_partial_ind,
           mem_length, 
           mem_offset,       
           CASE WHEN mem_poe = 0 
                THEN NULL
                WHEN mem_poe < 0
                THEN 'O'
                ELSE 'G'
           END mem_poe,
           mem_cardinality,
           mem_start_date,
           mem_end_date
      FROM (SELECT nm_seq_no                       mem_seq,
                   ne.ne_unique                    mem_unique,
                   ne.ne_no_start                  mem_start_node, 
                   ne.ne_no_end                    mem_end_node,
                   nm.nm_begin_mp                  mem_start_mp,
                   nm.nm_end_mp                    mem_end_mp,
                   CASE WHEN (nm.nm_end_mp = (nm.nm_end_mp - nm.nm_begin_mp)
                              AND nm.nm_begin_mp = 0)
                        THEN 'N'
                        ELSE 'Y'
                   END                             mem_partial_ind,
                   (nm.nm_end_mp - nm.nm_begin_mp) mem_length, 
                   nm.nm_slk                       mem_offset,       
                   nm3net_o.get_node_class(nm.nm_ne_id_in, CASE WHEN nm.nm_cardinality = 1 
                                                                THEN ne.ne_no_start
                                                                ELSE ne.ne_no_end
                                                           END).nc_poe   mem_poe,
                   CASE WHEN nm.nm_cardinality = 1
                        THEN 'Y'
                        ELSE 'N'
                   END mem_cardinality,
                   nm.nm_start_date mem_start_date, 
                   nm.nm_end_date mem_end_date,                                           
                   nm.nm_ne_id_in group_ne_id, 
                   nm.nm_ne_id_of mem_ne_id, 
                   nm.nm_type, 
                   nm.nm_obj_type,
                   nm.nm_admin_unit, 
                   nm.nm_date_created, 
                   nm.nm_date_modified, 
                   nm.nm_modified_by, 
                   nm_created_by,        
                   nm_seg_no, 
                   nm_true, 
                   nm_end_slk, 
                   nm_end_true 
              FROM nm_members nm, 
                   nm_elements ne
             WHERE nm.nm_ne_id_of = ne.ne_id
               AND nm.nm_type = 'G'
               AND nm.nm_ne_id_in = pi_ne_id
               AND nm_start_date <= TO_DATE (SYS_CONTEXT ('NM3CORE', 'EFFECTIVE_DATE'),'DD-MON-YYYY')
               AND NVL(nm_end_date, TO_DATE ('99991231', 'YYYYMMDD')) > TO_DATE (SYS_CONTEXT ('NM3CORE', 'EFFECTIVE_DATE'),'DD-MON-YYYY')   
            );   
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
  PROCEDURE add_membership(pi_group_ne_id          IN nm_elements.ne_id%TYPE
                          ,pi_mem_ne_id            IN nm_elements.ne_id%TYPE
                          ,pi_mem_begin_mp         IN nm_members.nm_begin_mp%TYPE
                          ,pi_mem_end_mp           IN nm_members.nm_end_mp%TYPE
                          ,pi_start_date           IN nm_members.nm_start_date%TYPE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                          ,po_message_severity    OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor      OUT sys_refcursor
                          ) IS

    l_group_ne_rec    nm_elements%ROWTYPE;
    l_mem_ne_rec      nm_elements%ROWTYPE;
    l_nm_rec          nm_members%ROWTYPE;

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT add_member_sp;

    -- get the group element record 
    l_group_ne_rec := nm3get.get_ne( pi_group_ne_id );

    -- get the member element record of the datum
    l_mem_ne_rec := nm3get.get_ne( pi_mem_ne_id );

    -- get the membership details
    l_nm_rec.nm_ne_id_in      := pi_group_ne_id;
    l_nm_rec.nm_ne_id_of      := pi_mem_ne_id;
    l_nm_rec.nm_type          := 'G';
    l_nm_rec.nm_obj_type      := l_group_ne_rec.ne_gty_group_type;
    l_nm_rec.nm_start_date    := NVL(pi_start_date, greatest(l_group_ne_rec.ne_start_date, l_mem_ne_rec.ne_start_date));

    IF nm3net.is_gty_partial (l_group_ne_rec.ne_nt_type) = 'Y'
    THEN 
      l_nm_rec.nm_begin_mp      := pi_mem_begin_mp;
      l_nm_rec.nm_end_mp        := pi_mem_end_mp;
    ELSE
      l_nm_rec.nm_begin_mp      := NVL(pi_mem_begin_mp, 0);
      l_nm_rec.nm_end_mp        := NVL(pi_mem_end_mp, NVL(nm3net.get_ne_length(pi_mem_ne_id),0));
    END IF;

    /*
    IF nm3net.is_nt_linear (l_group_ne_rec.ne_nt_type) = 'Y'
    THEN
      l_nm_rec.nm_slk         := nm3net.get_new_slk (p_parent_ne_id => l_nm_rec.nm_ne_id_in
                                                    ,p_no_start_new => l_mem_ne_rec.ne_no_start
                                                    ,p_no_end_new   => l_mem_ne_rec.ne_no_end
                                                    ,p_length       => l_mem_ne_rec.ne_length
                                                    ,p_sub_class    => l_mem_ne_rec.ne_sub_class
                                                    ,p_datum_ne_id  => l_nm_rec.nm_ne_id_of
                                                    );
      l_nm_rec.nm_true        := l_nm_rec.nm_slk;
    ELSE
      l_nm_rec.nm_slk         := NULL;
      l_nm_rec.nm_true        := NULL;
    END IF;
    */

    l_nm_rec.nm_slk         := NULL;
    l_nm_rec.nm_true        := NULL;

    l_nm_rec.nm_cardinality   := nm3net.get_element_cardinality (p_route_ne_id => pi_group_ne_id
                                                                ,p_datum_ne_id => pi_mem_ne_id);

    l_nm_rec.nm_admin_unit    := nm3get.get_ne(pi_ne_id => pi_mem_ne_id).ne_admin_unit;

    l_nm_rec.nm_end_date      := l_mem_ne_rec.ne_end_date ;
    l_nm_rec.nm_seq_no        := 0;
    l_nm_rec.nm_seg_no        := 0;

    nm3ins.ins_nm ( l_nm_rec );

    -- resequence the route to set connectivity
    IF nm3get.get_nt(pi_nt_type => l_group_ne_rec.ne_nt_type).nt_node_type IS NOT NULL THEN
      Nm3rsc.reseq_route(pi_group_ne_id);
    END IF;

    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
  EXCEPTION
    WHEN others
      THEN
        ROLLBACK TO add_member_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);        
  END add_membership; 
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE end_date_membership(pi_group_ne_id       IN nm_elements.ne_id%TYPE
                               ,pi_mem_ne_id         IN nm_elements.ne_id%TYPE
                               ,pi_mem_begin_mp      IN nm_members.nm_begin_mp%TYPE
                               ,pi_mem_start_date    IN nm_members.nm_start_date%TYPE
                               ,pi_effective_date    IN DATE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor) IS

  TYPE l_rec_nmh_tab IS TABLE OF nm_member_history%ROWTYPE INDEX BY BINARY_INTEGER;
  l_rec_nmh       l_rec_nmh_tab;
  
  BEGIN
     /*
     ||Set a save point.
     */
     SAVEPOINT enddate_member_sp;

    -- end date the membership of a member in a Group of Sections
    UPDATE nm_members
       SET nm_end_date = pi_effective_date
     WHERE nm_ne_id_in = pi_group_ne_id
       AND nm_ne_id_of = pi_mem_ne_id
       AND nm_begin_mp = pi_mem_begin_mp
       AND nm_start_date = pi_mem_start_date
       AND nm_end_date IS NULL
    RETURNING
       nm_ne_id_in
      ,nm_ne_id_of
      ,nm_ne_id_of
      ,nm_begin_mp
      ,nm_start_date
      ,nm_type
      ,nm_obj_type
      ,null
    BULK COLLECT INTO l_rec_nmh;

    FOR i IN 1.. l_rec_nmh.count LOOP
      nm3ins.ins_nmh(p_rec_nmh => l_rec_nmh(i));
    END LOOP;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
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
  PROCEDURE check_rescale_date(pi_ne_id             IN nm_elements.ne_id%TYPE,
                               pi_effective_date    IN DATE,
                               po_member_found     OUT BOOLEAN
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor) IS

    CURSOR c_rsc_date( c_ne_id nm_elements.ne_id%TYPE,
                       c_date  DATE ) IS
    SELECT 1 
    FROM   nm_members_all
    WHERE  nm_ne_id_in = c_ne_id
    AND    (nm_start_date >= c_date 
           OR nm_end_date > c_date );

    l_rec_found PLS_INTEGER;

  BEGIN

    OPEN c_rsc_date (c_ne_id => pi_ne_id, 
                     c_date  => pi_effective_date);
    FETCH c_rsc_date INTO l_rec_found;
    IF c_rsc_date%FOUND THEN
      po_member_found := TRUE;
    ELSE
      po_member_found := FALSE;
    END IF;
    -- If po_member_found returns as TRUE then UI should populate an alert 'NET', 63
    -- If user responds to alert as Yes then PROCEDURE rescale_route should be called from UI with pi_use_history parameter as 'N'
    -- else call the PROCEDURE rescale_route from UI with pi_use_history parameter as 'Y'
    CLOSE c_rsc_date;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_rescale_date;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_circular_start_point(pi_group_ne_id IN nm_elements.ne_id%TYPE)
                           RETURN nm_elements.ne_id%TYPE IS
   ln_circle_start nm_elements.ne_id%TYPE;
  BEGIN
    
     SELECT nm_ne_id_of
       INTO ln_circle_start
       FROM nm_members
      WHERE nm_ne_id_in = pi_group_ne_id
        AND nm_type = 'G'
    ORDER BY nm_seq_no;

    RETURN ln_circle_start;

  EXCEPTION
    WHEN OTHERS 
      THEN
        RETURN NULL;
  END get_circular_start_point;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE warn_if_route_ill_formed IS
  BEGIN
    IF NOT(nm3rsc.stranded_element_check)
    THEN
      --warn user route is ill formed
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 154);    
    END IF;
  END warn_if_route_ill_formed;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE rescale_route(pi_ne_id             IN nm_elements.ne_id%TYPE
                         ,pi_effective_date    IN DATE
                         ,pi_offset_st         IN NUMBER
                         ,pi_use_history       IN VARCHAR2
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                        ) IS

   e_route_locked exception;
   PRAGMA EXCEPTION_INIT(e_route_locked, -54);

   e_segment_number_error exception;
   PRAGMA EXCEPTION_INIT(e_segment_number_error, -20201);
  
   e_sequence_number_error exception;
   PRAGMA EXCEPTION_INIT(e_sequence_number_error, -20202);
  
   e_true_distance_error exception;
   PRAGMA EXCEPTION_INIT(e_true_distance_error, -20203);
  
   e_cannot_find_slk exception;
   PRAGMA EXCEPTION_INIT(e_cannot_find_slk, -20204);
  
   e_cannot_find_length exception;
   PRAGMA EXCEPTION_INIT(e_cannot_find_length, -20205);
  
   l_sqlerrm nm3type.max_varchar2 := nm3flx.parse_error_message(SQLERRM);

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT rescale_route_sp;
    --
    --do rescale
    DECLARE
      e_rescale_loop exception;
      PRAGMA EXCEPTION_INIT(e_rescale_loop, -20207);
  
      l_circle_start nm_elements.ne_id%TYPE;
    
    BEGIN  
      nm3rsc.rescale_route(pi_ne_id          => pi_ne_id
                          ,pi_effective_date => pi_effective_date
                          ,pi_offset_st      => pi_offset_st
                          ,pi_st_element_id  => NULL
                          ,pi_use_history    => pi_use_history
                          ,pi_ne_start       => NULL);
    EXCEPTION
    WHEN e_rescale_loop
    THEN  
       -- get circular start point
       l_circle_start := get_circular_start_point(pi_group_ne_id => pi_ne_id);
 
       IF l_circle_start IS NOT NULL
       THEN
         nm3rsc.rescale_route(pi_ne_id          => pi_ne_id
                             ,pi_effective_date => pi_effective_date
                             ,pi_offset_st      => pi_offset_st
                             ,pi_st_element_id  => NULL
                             ,pi_use_history    => pi_use_history
                             ,pi_ne_start       => l_circle_start);
      END IF;
                        
    END;
    --
    warn_if_route_ill_formed;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
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
        ROLLBACK TO rescale_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END rescale_route;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resequence_route(pi_ne_id             IN nm_elements.ne_id%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor  ) IS

    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);

    e_segment_number_error exception;
    PRAGMA EXCEPTION_INIT(e_segment_number_error, -20201);
  
    e_sequence_number_error exception;
    PRAGMA EXCEPTION_INIT(e_sequence_number_error, -20202);
  
    e_true_distance_error exception;
    PRAGMA EXCEPTION_INIT(e_true_distance_error, -20203);
  
    e_cannot_find_slk exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_slk, -20204);
  
    e_cannot_find_length exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_length, -20205);
  
    l_sqlerrm nm3type.max_varchar2 := nm3flx.parse_error_message(SQLERRM);

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reseq_route_sp;
    --
    --do resequence
    DECLARE
      e_rescale_loop exception;
      PRAGMA EXCEPTION_INIT(e_rescale_loop, -20207);
  
      l_circle_start nm_elements.ne_id%TYPE;
    
    BEGIN  
      nm3rsc.reseq_route(pi_ne_id    => pi_ne_id
                        ,pi_ne_start => NULL);
                        
    EXCEPTION
    WHEN e_rescale_loop
    THEN  
       -- get circular start point
       l_circle_start := get_circular_start_point(pi_group_ne_id => pi_ne_id);
 
       IF l_circle_start IS NOT NULL
       THEN
         nm3rsc.reseq_route(pi_ne_id    => pi_ne_id
                           ,pi_ne_start => l_circle_start);
      END IF;
                        
    END;
    --
    warn_if_route_ill_formed;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
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
        ROLLBACK TO reseq_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END resequence_route;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reverse_route(pi_ne_id             IN nm_elements.ne_id%TYPE
                         ,pi_effective_date    IN DATE
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor) IS

    e_route_has_shape exception;

    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);

    e_segment_number_error exception;
    PRAGMA EXCEPTION_INIT(e_segment_number_error, -20201);
  
    e_sequence_number_error exception;
    PRAGMA EXCEPTION_INIT(e_sequence_number_error, -20202);
  
    e_true_distance_error exception;
    PRAGMA EXCEPTION_INIT(e_true_distance_error, -20203);
  
    e_cannot_find_slk exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_slk, -20204);
  
    e_cannot_find_length exception;
    PRAGMA EXCEPTION_INIT(e_cannot_find_length, -20205);

    e_no_xsp_reversal exception;
    PRAGMA EXCEPTION_INIT(e_no_xsp_reversal, -20251);

    e_unique_found exception;
    PRAGMA EXCEPTION_INIT(e_unique_found, -00001);

    l_sqlerrm nm3type.max_varchar2 := nm3flx.parse_error_message(SQLERRM);

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT reverse_route_sp;
    --
    nm3rvrs.reverse_route(pi_ne_id          => pi_ne_id
                         ,pi_effective_date => pi_effective_date
                         );
    /*
    IF nm3rvrs.get_g_rvrs_circroute = 'Y'
    THEN
      -- Circular route - please rescale with no history
      Alert('NET',300);
    END IF;
    */
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --  
  EXCEPTION  
    WHEN e_route_locked
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 33); 
  
    WHEN e_route_has_shape
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 65); 

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

    WHEN others
      THEN
        ROLLBACK TO reverse_route_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);        
  END reverse_route;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_rescale_member(pi_ne_id_in          IN nm_members.nm_ne_id_in%TYPE
                                ,pi_ne_id_of          IN nm_members.nm_ne_id_of%TYPE
                                ,pi_begin_mp          IN nm_members.nm_begin_mp%TYPE
                                ,pi_member_found     OUT BOOLEAN
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ) IS

    CURSOR c_nm(c_ne_id_in       IN nm_members.nm_ne_id_in%TYPE
               ,c_ne_id_of       IN nm_members.nm_ne_id_of%TYPE
               ,c_begin_mp       IN nm_members.nm_begin_mp%TYPE
               ,c_effective_date IN date) IS
      SELECT 1
        FROM nm_members_all nm
       WHERE nm.nm_ne_id_in = c_ne_id_in
         AND nm.nm_ne_id_of = c_ne_id_of
         AND nm.nm_begin_mp = c_begin_mp
         AND (nm.nm_start_date >= c_effective_date
              OR nm.nm_end_date > c_effective_date);

      l_rec_found PLS_INTEGER;

  BEGIN

    OPEN c_nm(c_ne_id_in       => pi_ne_id_in
             ,c_ne_id_of       => pi_ne_id_of
             ,c_begin_mp       => pi_begin_mp
             ,c_effective_date => To_Date(Sys_Context('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY'));
    FETCH c_nm INTO l_rec_found;
    IF c_nm%FOUND THEN
      pi_member_found := TRUE;
    ELSE
      pi_member_found := FALSE;
    END IF;
    -- If pi_member_found returns as TRUE then UI should populate an alert 'NET', 63
    -- If user responds to alert as Yes then PROCEDURE local_rescale should be called from UI with pi_use_history parameter as FALSE
    -- else call the PROCEDURE local_rescale from UI with pi_use_history parameter as TRUE
    CLOSE c_nm;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --  
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_rescale_member;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE local_rescale(pi_ne_id_in          IN nm_elements.ne_id%TYPE
                         ,pi_ne_id_of          IN nm_elements.ne_id%TYPE
                         ,pi_begin_mp          IN nm_members.nm_begin_mp%TYPE
                         ,pi_use_history       IN BOOLEAN
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor) IS
  
    e_route_locked exception;
    PRAGMA EXCEPTION_INIT(e_route_locked, -54);

    l_sqlerrm nm3type.max_varchar2 := nm3flx.parse_error_message(SQLERRM);

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT local_rescale_sp;
    --    
    IF pi_ne_id_in IS NOT NULL 
      AND pi_ne_id_of IS NOT NULL 
    THEN 

    nm3rsc.local_rescale(pi_ne_id_in        => pi_ne_id_in
                         ,pi_ne_id_of       => pi_ne_id_of
                         ,pi_begin_mp       => pi_begin_mp
                         ,pi_effective_date => To_Date(Sys_Context('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                         ,pi_use_history    => pi_use_history);
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --  
  EXCEPTION
    WHEN e_route_locked
      THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 33); 

    WHEN others
      THEN
        ROLLBACK TO local_rescale_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);        
  END local_rescale;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_distance_break (pi_route_ne_id       IN nm_members.nm_ne_id_of%TYPE
                                    ,pi_start_node_id     IN nm_nodes.no_node_id%TYPE
                                    ,pi_end_node_id       IN nm_nodes.no_node_id%TYPE
                                    ,pi_start_date        IN DATE
                                    ,pi_length            IN nm_elements.ne_length%TYPE DEFAULT 0
                                    ,po_overlap_exists   OUT BOOLEAN
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                   ) IS
  BEGIN

    IF pi_start_node_id IS NULL 
       OR pi_end_node_id IS NULL
       OR pi_length IS NULL
       OR pi_start_date IS NULL
    THEN
       -- Field must be entered
       hig.raise_ner(pi_appl => 'HIG'
                    ,pi_id   => 22);

    ELSIF pi_start_node_id = pi_end_node_id
    THEN  
       -- Start and end nodes cannot be the same.
       hig.raise_ner(pi_appl => 'NET'
                    ,pi_id   => 126);

    END IF;

    po_overlap_exists := nm3net.datum_will_overlap_existing(pi_route          => pi_route_ne_id
                                                           ,pi_new_start_node => pi_start_node_id
                                                           ,pi_new_end_node   => pi_end_node_id);

    -- If po_overlap_exists is TRUE, UI should populate an alert of 'NET', 155
    -- If user responds 'YES' to alert, then UI should call add_distance_break procedure
    -- to create a distance break.
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --  
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END validate_distance_break;
  -----------------------------------------------------------------------------

  PROCEDURE add_distance_break (pi_route_ne_id       IN nm_members.nm_ne_id_of%TYPE
                               ,pi_start_node_id     IN nm_nodes.no_node_id%TYPE
                               ,pi_end_node_id       IN nm_nodes.no_node_id%TYPE
                               ,pi_start_date        IN DATE
                               ,pi_length            IN nm_elements.ne_length%TYPE DEFAULT 0
                               ,po_db_ne_id         OUT nm_members.nm_ne_id_in%TYPE
                               ,po_db_ne_unique     OUT nm_elements.ne_unique%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor) IS

    lv_ne_id     nm_members.nm_ne_id_in%TYPE;
    lv_ne_unique nm_elements.ne_unique%TYPE;

  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT add_distbreak_sp;
    --  
    --all checks passed, ok to create distance break    
    nm3net.insert_distance_break(pi_route_ne_id   => pi_route_ne_id
                                ,pi_start_node_id => pi_start_node_id
                                ,pi_end_node_id   => pi_end_node_id
                                ,pi_start_date    => pi_start_date
                                ,pi_length        => pi_length
                                ,po_db_ne_id      => lv_ne_id
                                ,po_db_ne_unique  => lv_ne_unique);

     po_db_ne_id     := lv_ne_id;
     po_db_ne_unique := lv_ne_unique;

    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
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
  PROCEDURE route_check(pi_ne_id                    IN nm_elements.ne_id%TYPE
                       ,po_message_severity        OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor          OUT sys_refcursor) IS

    -- -20351 'Start of Right <unique> exists with no compatible end'
    e_right_end_not_compat exception;
   
    -- -20352 'Start of Left  <unique> exists with no compatible end'
    e_left_end_not_compat exception;
  
    -- -20353 'Start of <unique> and <unique> are incompatible'
    e_datum_starts_not_campat exception;
  
    -- -20354 'End of <unique> and <unique> are incompatible'
    e_datum_ends_not_campat exception;
  
    -- -20355 'Too many start points'
    e_too_many_starts exception;
    PRAGMA EXCEPTION_INIT(e_too_many_starts, -20355);
  
    -- -20356 'Too many end points'
    e_too_many_ends exception;
    PRAGMA EXCEPTION_INIT(e_too_many_ends, -20356);
  
    -- -20357 'Invalid sub class combination at start of route'
    e_invalid_scl_start exception;
    PRAGMA EXCEPTION_INIT(e_invalid_scl_start, -20357);
  
    -- -20358 'Invalid sub class combination at end of route'
    e_invalid_scl_end exception;
    PRAGMA EXCEPTION_INIT(e_invalid_scl_end, -20358);

    l_route_status          PLS_INTEGER;
    l_offending_datums      nm3type.tab_varchar30;
  
    l_offending_datums_msg  VARCHAR2(32767);
  
  BEGIN
    --route check
    IF pi_ne_id IS NOT NULL
    THEN
 
      nm3route_check.route_check(pi_ne_id            => pi_ne_id
                                ,po_route_status     => l_route_status
                                ,po_offending_datums => l_offending_datums);
    
      --check route status
      IF l_route_status > 0
      THEN
        IF l_offending_datums.COUNT > 0
        THEN
          l_offending_datums_msg := CHR(10) || CHR(10);
      
          FOR l_i IN l_offending_datums.FIRST..l_offending_datums.LAST
          LOOP
            l_offending_datums_msg :=    l_offending_datums_msg
                                      || l_offending_datums(l_i)
                                      || ', ';
          END LOOP;
          l_offending_datums_msg := RTRIM(l_offending_datums_msg, ', ');
        END IF;
    
        IF l_route_status = 5
        THEN
          RAISE e_right_end_not_compat;
        
        ELSIF l_route_status = 10
        THEN
          RAISE e_left_end_not_compat;
          
        ELSIF l_route_status = 15
        THEN
          RAISE e_datum_starts_not_campat;
        
        ELSIF l_route_status = 20
        THEN
          RAISE e_datum_ends_not_campat;
        END IF;
      END IF;
   
      --route ok
      hig.raise_ner(pi_appl => 'NET'
                   ,pi_id   => 156);
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN e_right_end_not_compat
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 157
                     ,pi_supplementary_info => l_offending_datums_msg );  
    WHEN e_left_end_not_compat
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 158
                     ,pi_supplementary_info => l_offending_datums_msg ); 
    WHEN e_datum_starts_not_campat
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 159
                     ,pi_supplementary_info => l_offending_datums_msg ); 
    WHEN e_datum_ends_not_campat
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 160
                     ,pi_supplementary_info => l_offending_datums_msg );     
    WHEN e_too_many_starts
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 161
                     ,pi_supplementary_info => l_offending_datums_msg );
    
    WHEN e_too_many_ends
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 162
                     ,pi_supplementary_info => l_offending_datums_msg ); 
    WHEN e_invalid_scl_start
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 163
                     ,pi_supplementary_info => l_offending_datums_msg );     
    WHEN e_invalid_scl_end
      THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 164
                     ,pi_supplementary_info => l_offending_datums_msg ); 
    WHEN OTHERS
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END route_check;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE route_details(pi_ne_id                    IN nm_elements.ne_id%TYPE
                         ,po_min_slk                 OUT nm_members.nm_slk%TYPE
                         ,po_max_slk                 OUT nm_members.nm_slk%TYPE
                         ,po_max_true                OUT nm_members.nm_slk%TYPE
                         ,po_total_route_length      OUT nm_members.nm_slk%TYPE
                         ,po_min_slk_unit            OUT VARCHAR2
                         ,po_max_slk_unit            OUT VARCHAR2
                         ,po_max_true_unit           OUT VARCHAR2
                         ,po_total_route_length_unit OUT VARCHAR2
                         ,po_message_severity        OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor          OUT sys_refcursor) IS
    
    l_group_ne_rec       nm_elements%ROWTYPE;
    l_unit_name          nm_units.un_unit_name%TYPE;

    l_total_length_unit  nm_units.un_unit_id%TYPE;
    l_mem_ne_id          nm_members.nm_ne_id_of%TYPE;

  BEGIN
    
    IF pi_ne_id IS NOT NULL
    THEN    
      -- get the group element record 
      l_group_ne_rec := nm3get.get_ne(pi_ne_id);

      po_min_slk            := nm3net.get_min_slk(pi_ne_id);
      po_max_slk            := nm3net.get_max_slk(pi_ne_id);
      po_max_true           := nm3net.get_max_true(pi_ne_id);
      po_total_route_length := nm3net.get_ne_length(pi_ne_id);
      --
      po_min_slk_unit  := NULL;
      po_max_slk_unit  := NULL;
      po_max_true_unit := NULL;
      po_total_route_length_unit := NULL;
      --
      IF nm3net.get_nt_units(l_group_ne_rec.ne_nt_type) IS NOT NULL
      THEN
        l_unit_name := nm3unit.get_unit_name(nm3net.get_nt_units(l_group_ne_rec.ne_nt_type));
        po_min_slk_unit  := l_unit_name;
        po_max_slk_unit  := l_unit_name;
        po_max_true_unit := l_unit_name;
      END IF;
      
      BEGIN
        SELECT nm_ne_id_of
        INTO l_mem_ne_id
        FROM v_nm_members
        WHERE nm_ne_id_in = pi_ne_id
        AND nm_type = 'G';
      EXCEPTION 
        WHEN OTHERS
          THEN 
            l_mem_ne_id := '';
      END;
      
      IF l_mem_ne_id IS NOT NULL
      THEN
        l_total_length_unit := nm3net.get_nt_units(nm3net.get_nt_type (l_mem_ne_id));
      END IF;
      --

      IF l_total_length_unit IS NOT NULL
      THEN
        l_unit_name := nm3unit.get_unit_name (l_total_length_unit);
        po_total_route_length_unit := l_unit_name;
      END IF;
      --
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END route_details;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_group_of_group(pi_theme_name          IN     nm_themes_all.nth_theme_name%TYPE
                                 ,pi_network_type        IN     nm_elements_all.ne_nt_type%TYPE
                                 ,pi_description         IN     nm_elements_all.ne_descr%TYPE
                                 ,pi_admin_unit_id       IN     nm_elements_all.ne_admin_unit%TYPE
                                 ,pi_start_date          IN     nm_elements_all.ne_start_date%TYPE     DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                 ,pi_end_date            IN     nm_elements_all.ne_end_date%TYPE       DEFAULT NULL
                                 ,pi_group_type          IN     nm_elements_all.ne_gty_group_type%TYPE DEFAULT NULL
                                 ,pi_start_node_id       IN     nm_elements_all.ne_no_start%TYPE       DEFAULT NULL
                                 ,pi_end_node_id         IN     nm_elements_all.ne_no_end%TYPE         DEFAULT NULL
                                 ,pi_attrib_column_names IN     awlrs_element_api.attrib_column_name_tab
                                 ,pi_attrib_prompts      IN     awlrs_element_api.attrib_prompt_tab
                                 ,pi_attrib_char_values  IN     awlrs_element_api.attrib_char_value_tab
                                 ,po_ne_id               IN OUT nm_elements_all.ne_id%TYPE
                                 ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor         OUT sys_refcursor) IS
  BEGIN
    --
    awlrs_element_api.create_element(pi_theme_name          => pi_theme_name
                                    ,pi_network_type        => pi_network_type
                                    ,pi_element_type        => 'P'
                                    ,pi_description         => pi_description
                                    ,pi_length              => ''
                                    ,pi_admin_unit_id       => pi_admin_unit_id
                                    ,pi_start_date          => pi_start_date
                                    ,pi_end_date            => pi_end_date
                                    ,pi_group_type          => pi_group_type
                                    ,pi_start_node_id       => pi_start_node_id
                                    ,pi_end_node_id         => pi_end_node_id
                                    ,pi_attrib_column_names => pi_attrib_column_names
                                    ,pi_attrib_prompts      => pi_attrib_prompts
                                    ,pi_attrib_char_values  => pi_attrib_char_values
                                    ,pi_shape_wkt           => ''
                                    ,po_ne_id               => po_ne_id
                                    ,po_message_severity    => po_message_severity
                                    ,po_message_cursor      => po_message_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_group_of_group;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_of_group(pi_ne_id             IN nm_elements_all.ne_id%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor) IS

    lv_cursor  sys_refcursor;
  BEGIN
    IF nm3net.element_is_a_group_of_groups(pi_ne_id) THEN 
      awlrs_element_api.get_element(pi_ne_id            => pi_ne_id
                                   ,po_message_severity => po_message_severity
                                   ,po_message_cursor   => po_message_cursor
                                   ,po_cursor           => lv_cursor);
      po_cursor := lv_cursor;
    ELSE
       -- Invalid Group of Groups Id supplied
       hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 27);

    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_group_of_group;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE end_date_group_of_group(pi_ne_id             IN nm_elements.ne_id%TYPE
                                   ,pi_effective_date    IN DATE      
                                   ,pi_close_all         IN VARCHAR2
                                   ,pi_end_date_datums   IN VARCHAR2
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ) IS
  BEGIN

    awlrs_group_api.end_date_group(pi_ne_id             => pi_ne_id
                                  ,pi_effective_date    => pi_effective_date
                                  ,pi_close_all         => pi_close_all
                                  ,pi_end_date_datums   => pi_end_date_datums
                                  ,po_message_severity  => po_message_severity
                                  ,po_message_cursor    => po_message_cursor
                                  );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);

  END end_date_group_of_group;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_sub_groups(pi_ne_id             IN nm_elements_all.ne_id%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor) IS
    --
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nm.nm_ne_id_in       group_ne_id,
           nm.nm_ne_id_of       subgroup_ne_id,
           ne.ne_unique         subgroup_unique,
           ne.ne_descr          subgroup_descr,
           ne.ne_gty_group_type subgroup_group_type,
           nm.nm_start_date     subgroup_start_date, 
           nm.nm_end_date       subgroup_end_date,                                           
           nm.nm_begin_mp,
           nm.nm_end_mp,
           (nm.nm_end_mp - nm.nm_begin_mp) mem_length, 
           nm.nm_slk,
           nm.nm_cardinality,
           nm.nm_seq_no,
           nm.nm_type, 
           nm.nm_obj_type,
           nm.nm_admin_unit, 
           nm.nm_date_created, 
           nm.nm_date_modified, 
           nm.nm_modified_by, 
           nm_created_by,        
           nm_seg_no, 
           nm_true, 
           nm_end_slk, 
           nm_end_true 
      FROM nm_members nm, 
           nm_elements ne
     WHERE nm.nm_ne_id_of = ne.ne_id
       AND nm.nm_ne_id_in = pi_ne_id
       AND nm_start_date <= TO_DATE (SYS_CONTEXT ('NM3CORE', 'EFFECTIVE_DATE'),'DD-MON-YYYY')
       AND NVL(nm_end_date, TO_DATE ('99991231', 'YYYYMMDD')) > TO_DATE (SYS_CONTEXT ('NM3CORE', 'EFFECTIVE_DATE'),'DD-MON-YYYY');    
    --
    po_cursor := lv_cursor;
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
  PROCEDURE add_subgroup_member(pi_group_ne_id          IN nm_elements.ne_id%TYPE
                               ,pi_subgroup_ne_id       IN nm_elements.ne_id%TYPE
                               ,pi_subgroup_begin_mp    IN nm_members.nm_begin_mp%TYPE
                               ,pi_subgroup_end_mp      IN nm_members.nm_end_mp%TYPE
                               ,pi_start_date           IN nm_members.nm_start_date%TYPE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                               ,po_message_severity    OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor      OUT sys_refcursor
                               ) IS
  BEGIN
     awlrs_group_api.add_membership(pi_group_ne_id        => pi_group_ne_id
                                   ,pi_mem_ne_id          => pi_subgroup_ne_id
                                   ,pi_mem_begin_mp       => NVL(pi_subgroup_begin_mp,0)
                                   ,pi_mem_end_mp         => NVL(pi_subgroup_end_mp,0)
                                   ,pi_start_date         => pi_start_date
                                   ,po_message_severity   => po_message_severity
                                   ,po_message_cursor     => po_message_cursor
                                   );
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);

  END add_subgroup_member;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE end_date_subgroup_member(pi_group_ne_id          IN nm_elements.ne_id%TYPE
                                    ,pi_subgroup_ne_id       IN nm_elements.ne_id%TYPE
                                    ,pi_subgroup_begin_mp    IN nm_members.nm_begin_mp%TYPE
                                    ,pi_subgroup_start_date  IN nm_members.nm_start_date%TYPE
                                    ,pi_effective_date       IN DATE
                                    ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor      OUT sys_refcursor) IS
  BEGIN

    awlrs_group_api.end_date_membership(pi_group_ne_id       => pi_group_ne_id
                                       ,pi_mem_ne_id         => pi_subgroup_ne_id
                                       ,pi_mem_begin_mp      => pi_subgroup_begin_mp
                                       ,pi_mem_start_date    => pi_subgroup_start_date
                                       ,pi_effective_date    => pi_effective_date
                                       ,po_message_severity  => po_message_severity
                                       ,po_message_cursor    => po_message_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
      THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);

  END end_date_subgroup_member;
  --
  -----------------------------------------------------------------------------
  --
END awlrs_group_api;
/