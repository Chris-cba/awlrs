CREATE OR REPLACE PACKAGE BODY awlrs_split_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_split_api.pkb-arc   1.14   23 Feb 2017 15:03:08   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_split_api.pkb  $
  --       Date into PVCS   : $Date:   23 Feb 2017 15:03:08  $
  --       Date fetched Out : $Modtime:   15 Feb 2017 18:59:56  $
  --       Version          : $Revision:   1.14  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT VARCHAR2 (2000) := '$Revision:   1.14  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_split_api';
  --
  g_disp_derived    BOOLEAN := FALSE;
  g_disp_inherited  BOOLEAN := FALSE;
  g_disp_primary_ad BOOLEAN := FALSE;
  --
  c_nodes_within_tolerance_sql VARCHAR2(1000) := 'SELECT no_node_name, no_descr, no_node_id'
                                      ||CHR(10)||'  FROM nm_node_usages'
                                      ||CHR(10)||'      ,nm_members'
                                      ||CHR(10)||'      ,nm_nodes'
                                      ||CHR(10)||'      ,nm_route_nodes'
                                      ||CHR(10)||' WHERE node_id = nnu_no_node_id'
                                      ||CHR(10)||'   AND node_type != ''T'''
                                      ||CHR(10)||'   AND nnu_ne_id = nm_ne_id_of'
                                      ||CHR(10)||'   AND nnu_no_node_id = no_node_id'
                                      ||CHR(10)||'   AND nm_ne_id_in = :ne_id'
                                      ||CHR(10)||'   AND nnu_chain = decode(nm_cardinality,-1,nm_end_mp,nm_begin_mp)'
                                      ||CHR(10)||'   AND nm_slk + nm3unit.convert_unit(:datum_units'
                                      ||CHR(10)||'                                    ,:route_units'
                                      ||CHR(10)||'                                    ,nm_begin_mp) BETWEEN (:split_offset - :tolerance)'
                                      ||CHR(10)||'                                                      AND (:split_offset + :tolerance)';
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
  FUNCTION get_nodes_within_tolerance(pi_ne_id       IN nm_elements.ne_id%TYPE
                                     ,pi_datum_units IN nm_units.un_unit_id%TYPE
                                     ,pi_route_units IN nm_units.un_unit_id%TYPE
                                     ,pi_offset      IN NUMBER
                                     ,pi_tolerance   IN NUMBER) 
    RETURN nm3lrs.tab_rec_nodes IS
    --
    lv_cursor  sys_refcursor;
    --
    lt_retval  nm3lrs.tab_rec_nodes;
    --
  BEGIN
    --
    OPEN lv_cursor FOR c_nodes_within_tolerance_sql
    USING pi_ne_id
         ,pi_datum_units
         ,pi_route_units
         ,pi_offset
         ,pi_tolerance
         ,pi_offset
         ,pi_tolerance;
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_retval;
    CLOSE lv_cursor;
    --
    RETURN lt_retval;
    --
  END get_nodes_within_tolerance;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_coinciding_nodes(pi_ne_id      IN  nm_elements_all.ne_id%TYPE
                                ,pi_offset     IN  NUMBER
                                ,po_node_count OUT PLS_INTEGER
                                ,po_cursor     OUT sys_refcursor)
    IS
    --
    lv_empty_cur      VARCHAR2(1000) := 'SELECT no_node_name, no_descr, no_node_id FROM nm_nodes WHERE 1=2';
    lv_datum_nt       nm_types.nt_type%TYPE;
    lv_datum_units    nm_units.un_unit_id%TYPE;
    lv_route_units    nm_units.un_unit_id%TYPE;
    lv_tolerance_opt  hig_option_values.hov_value%TYPE;
    lv_tolerance      PLS_INTEGER;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lt_nodes  nm3lrs.tab_rec_nodes;
    --
  BEGIN
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.element_is_a_group(pi_ne_type => lr_ne.ne_type)
     THEN
        --
        nm3net_o.set_g_ne_id_to_restrict_on(pi_ne_id => lr_ne.ne_id);
        lt_nodes := nm3lrs.get_coinciding_nodes(pi_route_ne_id => lr_ne.ne_id
                                               ,pi_offset      => pi_offset);
        --
        IF lt_nodes.COUNT > 0
         THEN
            /*
            ||Return the coinciding_nodes cursor.
            */
            OPEN po_cursor FOR nm3lrs.get_coinciding_nodes_sql(pi_route_ne_id => lr_ne.ne_id
                                                              ,pi_offset      => pi_offset);
            --set_split_point_fields;
        ELSE
            /*
            ||No coinsiding nodes found to check for nodes within tolerance of the given offset.
            */
            lv_datum_nt := nm3net.get_datum_nt(pi_gty => lr_ne.ne_gty_group_type);
            lv_datum_units := nm3net.get_nt_units(p_nt_type => lv_datum_nt);
            lv_route_units := nm3net.get_nt_units(p_nt_type => lr_ne.ne_nt_type);
            lv_tolerance_opt := hig.get_sysopt('NODETOL');
            lv_tolerance := TO_NUMBER(lv_tolerance_opt);
            --
            lt_nodes := get_nodes_within_tolerance(pi_ne_id       => lr_ne.ne_id
                                                  ,pi_datum_units => lv_datum_units
                                                  ,pi_route_units => lv_route_units
                                                  ,pi_offset      => pi_offset
                                                  ,pi_tolerance   => lv_tolerance);
            IF lt_nodes.COUNT > 0
             THEN
                /*
                ||Return the coinciding_nodes cursor.
                */
                OPEN po_cursor FOR c_nodes_within_tolerance_sql
                USING lr_ne.ne_id
                     ,lv_datum_units
                     ,lv_route_units
                     ,pi_offset
                     ,lv_tolerance
                     ,pi_offset
                     ,lv_tolerance;
            ELSE
                OPEN po_cursor FOR lv_empty_cur;
            END IF;
        END IF;
    END IF;
    --
    po_node_count := lt_nodes.COUNT;
    --
  END get_coinciding_nodes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_coinciding_nodes(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                ,pi_offset           IN  NUMBER
                                ,po_node_count       OUT PLS_INTEGER
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_coinciding_nodes(pi_ne_id      => pi_ne_id
                        ,pi_offset     => pi_offset
                        ,po_node_count => po_node_count
                        ,po_cursor     => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_coinciding_nodes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_offset(pi_group_ne_id  IN     nm_elements_all.ne_id%TYPE
                            ,pi_group_offset IN     NUMBER
                            ,po_datum_ne_id  IN OUT nm_elements_all.ne_id%TYPE
                            ,po_datum_offset IN OUT NUMBER)
    IS
    --
    lv_parent_units  nm_units.un_unit_id%TYPE;
    lv_child_units   nm_units.un_unit_id%TYPE;
    lv_is_datum      VARCHAR2(1);
    --
    lr_ne  nm_elements%ROWTYPE;
    --
    lt_lref  nm3lrs.lref_table;
    --
  BEGIN
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_group_ne_id);
    lv_is_datum := nm3net.is_nt_datum(lr_ne.ne_nt_type);
    --
    IF lv_is_datum = 'Y'
     THEN
        lt_lref(1).r_ne_id  := pi_group_ne_id;
        lt_lref(1).r_offset := pi_group_offset;
    ELSE
        --
        nm3net.get_group_units(pi_ne_id       => pi_group_ne_id
                              ,po_group_units => lv_parent_units
                              ,po_child_units => lv_child_units);
        --
        DECLARE
          no_datum  EXCEPTION;
          PRAGMA    exception_init(no_datum, -20015);
        BEGIN
          nm3lrs.get_ambiguous_lrefs(p_parent_id    => pi_group_ne_id
                                    ,p_parent_units => lv_parent_units
                                    ,p_datum_units  => lv_child_units
                                    ,p_offset       => pi_group_offset
                                    ,p_lrefs        => lt_lref);
        EXCEPTION
          WHEN no_datum
           THEN
              hig.raise_ner(pi_appl => 'NET'
                           ,pi_id   => 85);
        END;
        --
    END IF;
    --
    IF lt_lref(1).r_offset = 0
     OR lt_lref(1).r_offset = nm3net.get_ne_length(p_ne_id => lt_lref(1).r_ne_id)
     THEN
          hig.raise_ner(pi_appl => 'NET'
                       ,pi_id   => 358);
    END IF;
    --
    po_datum_ne_id := lt_lref(1).r_ne_id;
    po_datum_offset := lt_lref(1).r_offset;
    --
  END get_datum_offset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_offset(pi_group_ne_id      IN  nm_elements_all.ne_id%TYPE
                            ,pi_group_offset     IN  NUMBER
                            ,po_datum_offset     OUT NUMBER
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_datum_id  nm_elements_all.ne_id%TYPE;
    lt_ids       awlrs_util.ne_id_tab;
    --
  BEGIN
    --
    lt_ids(1) := NULL;
    --
    get_datum_offset(pi_group_ne_id  => pi_group_ne_id
                    ,pi_group_offset => pi_group_offset
                    ,po_datum_ne_id  => lt_ids(1)
                    ,po_datum_offset => po_datum_offset);
    --
    awlrs_element_api.get_elements(pi_ne_ids => lt_ids
                                  ,po_cursor => po_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
    --
  END get_datum_offset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_element_can_be_split(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                      ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                      ,po_split_datum_only OUT VARCHAR2)
    IS
    --
    lv_group_split  BOOLEAN := TRUE;
    lv_datum_only   VARCHAR2(1) := 'Y';
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Make sure the element can be split.
    */
    BEGIN
      --
      nm3split.check_element_can_be_split(pi_ne_id          => pi_ne_id
                                         ,pi_effective_date => TRUNC(pi_effective_date));
      --
    EXCEPTION
		  WHEN others
       THEN
		      IF SQLERRM LIKE '%Start point of group is ambiguous.%'
		       THEN
              --
		      	  lv_group_split := FALSE;
              --
		      ELSIF UPPER(SQLERRM) LIKE '%NET-0361%'
		      THEN
		          -- Don't allow spilt of route if autoincluded into
              lv_group_split := FALSE;
    		      --
		      ELSE
		      	  RAISE;
		      END IF;
    END;
    /*
    ||If the above check has not already set lv_group_split to FLASE then
    ||check whether the split should only be applied to the underlying Datum.
    ||NB. the name of procedure nm3split.datum_split_required is misleading
    ||it will return true if the ne_id passed in is either:
    ||  * A Datum Element.
    ||  * A Partial Group and the underlying Datum Unique can be derived without user
    ||    input (because when splitting the Group as well as the Datum the attributes
    ||    presented to the user will be those of the Group Type.
    ||All other circumstances will return FALSE.
    */
    IF lv_group_split
     THEN
        BEGIN
          lv_group_split := nm3split.datum_split_required(pi_ne_id            => pi_ne_id
                                                         ,pi_split_at_node_id => null);
        EXCEPTION
          WHEN others
           THEN
              lv_group_split := FALSE;
        END;
    END IF;
    --
    lr_ne := nm3net.get_ne(pi_ne_id);
    IF NOT nm3net.element_is_a_datum(pi_ne_type => lr_ne.ne_type)
     AND lv_group_split
     THEN
        lv_datum_only := 'N';
    END IF;
    --
    po_split_datum_only := lv_datum_only;
    --
  END check_element_can_be_split;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_element_can_be_split(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                      ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                      ,po_split_datum_only OUT VARCHAR2
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_datum_only  VARCHAR2(1) := 'Y';
    --
  BEGIN
    --
    check_element_can_be_split(pi_ne_id            => pi_ne_id
                              ,pi_effective_date   => pi_effective_date
                              ,po_split_datum_only => po_split_datum_only);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        po_split_datum_only := lv_datum_only;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END check_element_can_be_split;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_existing_nodes(pi_ne_id   IN nm_elements_all.ne_id%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    NM3CTX.SET_CONTEXT('PROX_NE_ID', TO_CHAR(pi_ne_id));
    --
    OPEN po_cursor FOR
    SELECT no_node_id
          ,no_node_name
          ,no_descr
          ,TO_CHAR(distance,'9999990.99') distance
      FROM v_node_proximity_check
     ORDER
        BY distance
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
  END get_existing_nodes;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_use_existing_node(pi_ne_id   IN nm_elements_all.ne_id%TYPE
                                      ,pi_node_id IN nm_nodes.no_node_id%TYPE)
    IS
    --
  	CURSOR chk_node(cp_node_id IN nm_nodes.no_node_id%TYPE)
        IS
  	SELECT no_node_id
      FROM v_node_proximity_check
     WHERE no_node_id = cp_node_id
         ;
     --
     lv_node_id    nm_nodes.no_node_id%TYPE;
     lv_node_found  BOOLEAN;
     --
  BEGIN
    --
  	IF pi_node_id IS NOT NULL
  	 THEN
        --
        NM3CTX.SET_CONTEXT('PROX_NE_ID', TO_CHAR(pi_ne_id));
        --  	  
        OPEN  chk_node(pi_node_id);
        FETCH chk_node
         INTO lv_node_id;
        --
        lv_node_found := chk_node%FOUND;        
        CLOSE chk_node;
        --
        IF NOT lv_node_found
         THEN
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 38);
  	    END IF;	
        --
    END IF;
  END validate_use_existing_node;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_split_at_node(pi_ne_id   IN nm_elements_all.ne_id%TYPE
                                  ,pi_node_id IN nm_nodes.no_node_id%TYPE)
    IS
    --
  	CURSOR chk_node(cp_node_id IN nm_nodes.no_node_id%TYPE)
        IS
  	SELECT node_id
      FROM nm_route_nodes
     WHERE node_id = cp_node_id
       AND node_type != 'T'
         ;
     --
     lv_node_id    nm_nodes.no_node_id%TYPE;
     lv_node_found  BOOLEAN;
     --
  BEGIN
  	IF pi_node_id IS NOT NULL
  	 THEN
        nm3net_o.set_g_ne_id_to_restrict_on(pi_ne_id => pi_ne_id);
        --  	  
        OPEN  chk_node(pi_node_id);
        FETCH chk_node
         INTO lv_node_id;
        --
        lv_node_found := chk_node%FOUND;        
        CLOSE chk_node;
        --
        IF NOT lv_node_found
         THEN
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 38);
  	    END IF;	
        --
    END IF;
  END validate_split_at_node;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE validate_split_position(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                   ,pi_split_offset     IN  NUMBER
                                   ,pi_split_at_node_id IN  nm_nodes.no_node_id%TYPE
                                   ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                   ,po_split_datum_only OUT VARCHAR2
                                   ,po_datum_offset     OUT NUMBER
                                   /*,po_node_count       OUT PLS_INTEGER*/
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_datum_cursor     OUT sys_refcursor
                                   /*,po_node_cursor      OUT sys_refcursor*/)
    IS
    --
    lv_is_datum  VARCHAR2(1);
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lt_ids  awlrs_util.ne_id_tab;
    --
  BEGIN
    --
    IF pi_split_at_node_id IS NOT NULL
     AND pi_split_offset IS NOT NULL
     THEN
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 42);
    END IF;
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    lv_is_datum := nm3net.is_nt_datum(lr_ne.ne_nt_type);
    --
    check_element_can_be_split(pi_ne_id            => pi_ne_id
                              ,pi_effective_date   => pi_effective_date
                              ,po_split_datum_only => po_split_datum_only);
    --
    IF pi_split_at_node_id IS NOT NULL
     THEN
        --
        IF lv_is_datum = 'Y'
         THEN
            po_split_datum_only := 'Y';
        ELSE
            po_split_datum_only := 'N';
        END IF;
        --
        validate_split_at_node(pi_ne_id   => pi_ne_id
                              ,pi_node_id => pi_split_at_node_id);
        --
    ELSE
        --
        lt_ids(1) := NULL;
        --
        get_datum_offset(pi_group_ne_id  => pi_ne_id
                        ,pi_group_offset => pi_split_offset
                        ,po_datum_ne_id  => lt_ids(1)
                        ,po_datum_offset => po_datum_offset);
        --
        awlrs_element_api.get_elements(pi_ne_ids => lt_ids
                                      ,po_cursor => po_datum_cursor);
        --
        --get_coinciding_nodes(pi_ne_id      => pi_ne_id
        --                    ,pi_offset     => pi_split_offset
        --                    ,po_node_count => po_node_count
        --                    ,po_cursor     => po_node_cursor);
        --
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        po_split_datum_only := 'Y';
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END validate_split_position;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_split(pi_ne_id                IN     nm_elements_all.ne_id%TYPE
                    ,pi_split_offset         IN     NUMBER
                    ,pi_split_at_node_id     IN     nm_nodes.no_node_id%TYPE
                    ,pi_split_datum_id       IN     nm_elements_all.ne_id%TYPE DEFAULT NULL
                    ,pi_split_datum_offset   IN     NUMBER DEFAULT NULL
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
    lv_datum_only   VARCHAR2(1) := 'Y';
    --
    lv_new_elements_cursor  sys_refcursor;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT do_split_sp;
    /*
    ||Make sure the element can be split.
    */
    check_element_can_be_split(pi_ne_id            => pi_ne_id
                              ,pi_effective_date   => pi_effective_date
                              ,po_split_datum_only => lv_datum_only);
    /*
    ||Check that the given node is valid.
    */
    IF pi_split_at_node_id IS NOT NULL
     THEN
        validate_split_at_node(pi_ne_id   => pi_ne_id
                              ,pi_node_id => pi_split_at_node_id);
    END IF;
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
        lv_new_node_id := pi_split_at_node_id;
    END IF;
    --
    nm3split.set_ne_globals(pi_ne_id => pi_ne_id);
    --
    po_new_ne_ids.DELETE;
    po_new_ne_ids(1) := NULL;
    po_new_ne_ids(2) := NULL;
    --
    nm3split.do_split_datum_or_group(pi_ne_id                  => lr_ne.ne_id
                                    ,pi_ne_type                => lr_ne.ne_type
                                    ,pi_ne_id_1                => po_new_ne_ids(1)
                                    ,pi_ne_id_2                => po_new_ne_ids(2)
                                    ,pi_effective_date         => pi_effective_date
                                    ,pi_split_offset           => pi_split_offset
                                    ,pi_non_ambig_ne_id        => pi_split_datum_id
                                    ,pi_non_ambig_split_offset => pi_split_datum_offset
                                    ,pi_split_at_node_id       => pi_split_at_node_id
                                    ,pi_create_node            => lv_create_node
                                    /*
                                    ||SM always creates a new node when splitting at measure
                                    ||and allows the core api to generate the detail.
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
        ROLLBACK TO do_split_sp;
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
                    ,pi_split_datum_id            IN     nm_elements_all.ne_id%TYPE DEFAULT NULL
                    ,pi_split_datum_offset        IN     NUMBER DEFAULT NULL
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
            ,pi_split_datum_id       => pi_split_datum_id
            ,pi_split_datum_offset   => pi_split_datum_offset
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
