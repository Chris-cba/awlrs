CREATE OR REPLACE PACKAGE BODY awlrs_sdo
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdo.pkb-arc   1.5   05 Apr 2017 15:09:06   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_sdo.pkb  $
  --       Date into PVCS   : $Date:   05 Apr 2017 15:09:06  $
  --       Date fetched Out : $Modtime:   05 Apr 2017 15:06:40  $
  --       Version          : $Revision:   1.5  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.5  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_sdo';
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
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_start_x_y(pi_shape IN  mdsys.sdo_geometry
                         ,po_x     OUT NUMBER
                         ,po_y     OUT NUMBER)
    IS
    --
    lv_x  NUMBER;
    lv_y  NUMBER;
    --
  BEGIN
    --
    SELECT a.X
          ,a.Y
      INTO lv_x
          ,lv_y
      FROM TABLE(sdo_util.getvertices(pi_shape)) a
     WHERE a.id = 1
         ;
    --
    po_x := lv_x;
    po_y := lv_y;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        --Cannot find start x,y of the geometry
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 13);
    WHEN others
     THEN
        RAISE;
  END get_start_x_y;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_end_x_y(pi_shape IN  mdsys.sdo_geometry
                       ,po_x     OUT NUMBER
                       ,po_y     OUT NUMBER)
    IS
    --
    lv_x  NUMBER;
    lv_y  NUMBER;
    --
  BEGIN
    --
    SELECT a.X
          ,a.Y
      INTO lv_x
          ,lv_y
      FROM TABLE(sdo_util.getvertices(pi_shape)) a
     WHERE a.id = sdo_util.getnumvertices(pi_shape) 
         ;
    --
    po_x := lv_x;
    po_y := lv_y;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        --Cannot find end x,y of the geometry
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 14);
    WHEN others
     THEN
        RAISE;
  END get_end_x_y;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_gtypes(pi_theme_id IN nm_themes_all.nth_theme_id%TYPE)
    RETURN gtype_tab IS
    --
    lt_gtypes gtype_tab;
    --
  BEGIN
    --
    SELECT ntg_theme_id
          ,ntg_gtype
      BULK COLLECT
      INTO lt_gtypes
      FROM nm_theme_gtypes
     WHERE ntg_theme_id = pi_theme_id
     ORDER
        BY ntg_seq_no
         ;
    --
    RETURN lt_gtypes;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        RETURN lt_gtypes;
    WHEN others
     THEN
        RAISE;
  END get_gtypes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_gtypes(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN gtype_tab IS
    --
    lt_gtypes gtype_tab;
    --
  BEGIN
    --
    SELECT ntg_theme_id
          ,ntg_gtype
      BULK COLLECT
      INTO lt_gtypes
      FROM nm_theme_gtypes
     WHERE ntg_theme_id = (SELECT nth_theme_id
                             FROM nm_themes_all
                            WHERE nth_theme_name = pi_theme_name)
     ORDER
        BY ntg_seq_no
         ;
    --
    RETURN lt_gtypes;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        RETURN lt_gtypes;
    WHEN others
     THEN
        RAISE;
  END get_gtypes;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION sdo_geom_to_wkt(pi_geom IN mdsys.sdo_geometry)
    RETURN CLOB IS
    --
    lv_geom   mdsys.sdo_geometry;
    lv_retval CLOB;
    --
  BEGIN
    --
    lv_geom := pi_geom;
    --
    IF SUBSTR(pi_geom.sdo_gtype,1,1) = '3'
     THEN
        lv_geom := sdo_lrs.convert_to_std_geom(lrs_geom => lv_geom);
    END IF;
    --
    RETURN sdo_util.to_wktgeometry(geometry => lv_geom);
    --
  END sdo_geom_to_wkt;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION wkt_to_sdo_geom(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE
                          ,pi_shape      IN CLOB)
    RETURN mdsys.sdo_geometry IS
    --
    lv_shape  mdsys.sdo_geometry;
    lv_lrs    BOOLEAN;
    --
    lr_theme       nm_themes_all%ROWTYPE;
    lr_theme_meta  user_sdo_geom_metadata%ROWTYPE;
    --
    lt_gtypes  gtype_tab;
    --
  BEGIN
    IF sdo_util.validate_wktgeometry(pi_shape) = 'TRUE'
     THEN
        --
        lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
        lr_theme_meta := nm3sdo.get_theme_metadata(p_nth_id => lr_theme.nth_theme_id);
        lt_gtypes := get_gtypes(pi_theme_name => pi_theme_name);
        FOR i IN 1..lt_gtypes.COUNT LOOP
          --
          IF SUBSTR(lt_gtypes(i).gtype,2,1) IN('3','4')
           THEN
              lv_lrs := TRUE;
              EXIT;
          END IF;
          --
        END LOOP;
        --
        lv_shape := sdo_util.from_wktgeometry(pi_shape);
        IF lv_lrs
         THEN
            lv_shape := sdo_lrs.convert_to_lrs_geom(lv_shape); --,0,lr_ne.ne_length);
        END IF;
        --
        IF lr_theme_meta.srid IS NOT NULL
         THEN
            lv_shape.sdo_srid := lr_theme_meta.srid;
        END IF;
        --
    ELSE
       --Invalid geometry supplied
       hig.raise_ner(pi_appl => 'AWLRS'
                    ,pi_id   => 15);
    END IF;
    --
    RETURN lv_shape;
    --
  END;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_theme_extent(pi_theme_id IN nm_themes_all.nth_theme_id%TYPE)
    RETURN extent_rec IS
    --
    TYPE coords_rec IS RECORD(x  NUMBER
                             ,y  NUMBER);
    TYPE coords_tab IS TABLE OF coords_rec;
    lt_coords  coords_tab;
    --
    lr_extent  extent_rec;
    --
  BEGIN
    --
    SELECT t.X
          ,t.Y
      BULK COLLECT
      INTO lt_coords
      FROM TABLE(sdo_util.getvertices(nm3sdo.get_theme_mbr(pi_theme_id))) t
     ORDER
        BY t.id
         ;
    --
    IF lt_coords.COUNT < 2
     OR lt_coords.COUNT > 2
     THEN
        --Invalid number of coordinates returned by nm3sdo.get_theme_mbr
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 16
                     ,pi_supplementary_info => 'by nm3sdo.get_theme_mbr');
    END IF;
    --
    FOR i IN 1..lt_coords.COUNT LOOP
      --
      IF i = 1
       THEN
          lr_extent.min_x := lt_coords(i).x;
          lr_extent.min_y := lt_coords(i).y;
      ELSIF i = 2
       THEN
          lr_extent.max_x := lt_coords(i).x;
          lr_extent.max_y := lt_coords(i).y;
      END IF;
      --
    END LOOP;
    --
    RETURN lr_extent;
    --
  END get_theme_extent;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_nlt_from_theme(pi_theme_id IN nm_themes_all.nth_theme_id%TYPE)
    RETURN nm_linear_types%ROWTYPE IS
    --
    lr_retval nm_linear_types%ROWTYPE;
    --
  BEGIN
    --
    SELECT *
      INTO lr_retval
      FROM nm_linear_types
     WHERE nlt_id IN(SELECT nnth_nlt_id
                       FROM nm_nw_themes
                      WHERE nnth_nth_theme_id = pi_theme_id)
         ;
    --
    RETURN lr_retval;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        --Unable to derive a linear network type for theme id
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 17
                     ,pi_supplementary_info => pi_theme_id);
    WHEN others
     THEN
        RAISE;
  END get_nlt_from_theme;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE snap_to_network(pi_x                IN  NUMBER
                           ,pi_y                IN  NUMBER
                           ,pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                           ,pi_search_radius    IN  NUMBER DEFAULT NULL
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql  nm3type.max_varchar2;
    --
    --TODO this is a work around - get_objects_in_buffer has
    --not been implemented to work with units other than meters.
    lv_nt_unit            nm_types.nt_length_unit%TYPE := 1;
    lv_group_type_clause  VARCHAR2(100);
    --
    lr_nlt         nm_linear_types%ROWTYPE;
    lr_theme       nm_themes_all%ROWTYPE;
    lr_theme_meta  user_sdo_geom_metadata%ROWTYPE;
    --
  BEGIN
    --
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    lr_theme_meta := nm3sdo.get_theme_metadata(p_nth_id => lr_theme.nth_theme_id);
    lr_nlt := get_nlt_from_theme(pi_theme_id => lr_theme.nth_theme_id);
    --
    OPEN po_cursor FOR
    SELECT DISTINCT ne_id
          ,ne_unique
          ,ne_descr
          ,ne_nt_type
          ,ne_gty_group_type
          ,ne_type
          ,offset
          ,unit_id
          ,unit_name
          ,ntd_distance
          ,nm3sdo.get_x_from_pt_geometry(nm3sdo.get_xy_from_measure(ne_id,offset)) snapped_x
          ,nm3sdo.get_y_from_pt_geometry(nm3sdo.get_xy_from_measure(ne_id,offset)) snapped_y
      FROM (SELECT ntd_pk_id ne_id
                  ,CASE ne_nt_type
                     WHEN 'ESU' THEN ne_name_1
                     WHEN 'NSGN' THEN ne_number
                     ELSE ne_unique
                   END ne_unique
                  ,ne_descr
                  ,ne_nt_type
                  ,ne_gty_group_type
                  ,ne_type
                  ,TO_NUMBER(nm3unit.get_formatted_value(nm3sdo.get_measure(lr_theme.nth_theme_id
                                                                           ,ntd_pk_id
                                                                           ,pi_x
                                                                           ,pi_y).lr_offset
                                                        ,nt_length_unit)) offset
                  ,nt_length_unit unit_id
                  ,un_unit_name unit_name
                  ,MIN(ntd_distance) ntd_distance
              FROM (SELECT *
                      FROM TABLE(nm3sdo.get_objects_in_buffer(mdsys.sdo_geometry('POINT('||pi_x||' '||pi_y||')'
                                                                                ,lr_theme_meta.srid)
                                                             ,NVL(pi_search_radius,lr_theme.nth_tolerance)
                                                             ,lv_nt_unit
                                                             ,lr_theme.nth_theme_id).ntl_theme_list))
                  ,nm_elements
                  ,nm_types
                  ,nm_units
             WHERE ntd_pk_id = ne_id
               AND ne_nt_type = lr_nlt.nlt_nt_type
               AND NVL(ne_gty_group_type,'~~~~~') = NVL(lr_nlt.nlt_gty_type,'~~~~~')
               AND ne_nt_type = nt_type
               AND nt_length_unit = un_unit_id
             GROUP
                BY ntd_theme_id
                  ,ne_nt_type
                  ,ne_gty_group_type
                  ,ntd_pk_id
                  ,CASE ne_nt_type
                     WHEN 'ESU' THEN ne_name_1
                     WHEN 'NSGN' THEN ne_number
                     ELSE ne_unique
                   END
                  ,ne_descr
                  ,ntd_name
                  ,nt_length_unit
                  ,un_unit_name
                  ,ne_type)
     ORDER
        BY ntd_distance
          ,ne_id
         ;
    --
  END snap_to_network;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE snap_to_network(pi_x                IN  NUMBER
                           ,pi_y                IN  NUMBER
                           ,pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                           ,pi_search_radius    IN  NUMBER DEFAULT NULL
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    snap_to_network(pi_x             => pi_x
                   ,pi_y             => pi_y
                   ,pi_theme_name    => pi_theme_name
                   ,pi_search_radius => pi_search_radius
                   ,po_cursor        => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                       ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                 ,po_cursor           => po_message_cursor);
  END snap_to_network;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION snap_to_network(pi_x             IN NUMBER
                          ,pi_y             IN NUMBER
                          ,pi_theme_name    IN nm_themes_all.nth_theme_name%TYPE
                          ,pi_search_radius IN NUMBER DEFAULT NULL)
    RETURN snap_to_network_results_tab IS
    --
    lv_cursor  sys_refcursor;
    lt_retval  snap_to_network_results_tab;
    --
  BEGIN
    --
    snap_to_network(pi_x             => pi_x
                   ,pi_y             => pi_y
                   ,pi_theme_name    => pi_theme_name
                   ,pi_search_radius => pi_search_radius
                   ,po_cursor        => lv_cursor);
    --
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_retval;
    CLOSE lv_cursor;
    --
    RETURN lt_retval;
    --
  END snap_to_network;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE snap_to_element(pi_x          IN  NUMBER
                           ,pi_y          IN  NUMBER
                           ,pi_element_id IN  nm_elements_all.ne_id%TYPE
                           ,pi_theme_name IN  nm_themes_all.nth_theme_name%TYPE
                           ,po_offset     OUT NUMBER)
    IS
    --
    lv_lref  nm_lref;
    --
    lr_theme  nm_themes_all%ROWTYPE;
    --
  BEGIN
    --
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    --
    lv_lref := nm3sdo.get_measure(p_layer => lr_theme.nth_theme_id
                                 ,p_ne_id => pi_element_id
                                 ,p_x     => pi_x
                                 ,p_y     => pi_y);
    --
    po_offset := lv_lref.lr_offset;
    --
  END snap_to_element;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE snap_to_element(pi_x                IN  NUMBER
                           ,pi_y                IN  NUMBER
                           ,pi_element_id       IN  nm_elements_all.ne_id%TYPE
                           ,pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_offset  NUMBER;
    --
  BEGIN
    --
    snap_to_element(pi_x          => pi_x
                   ,pi_y          => pi_y
                   ,pi_element_id => pi_element_id
                   ,pi_theme_name => pi_theme_name
                   ,po_offset     => lv_offset);
    --
    OPEN po_cursor FOR
    SELECT pi_element_id element_id
          ,lv_offset offset
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
  END snap_to_element;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_point_from_element_offset(pi_theme_id IN  nm_themes_all.nth_theme_id%TYPE
                                         ,pi_ne_id    IN  nm_elements_all.ne_id%TYPE
                                         ,pi_offset   IN  NUMBER
                                         ,po_x        OUT NUMBER
                                         ,po_y        OUT NUMBER)
    IS
    --
    lv_x  NUMBER;
    lv_y  NUMBER;
    --
  BEGIN
    --
    WITH shape
      AS (SELECT nm3sdo.get_pt_shape_from_ne(pi_theme_id,pi_ne_id,pi_offset).sdo_point shp
            FROM DUAL)
    SELECT a.shp.x x_coord
          ,a.shp.y y_coord
      INTO lv_x
          ,lv_y
      FROM shape a
         ;
    --
    po_x := lv_x;
    po_y := lv_y;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        --Cannot find a coordinate from the network element and measure provided
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 18);
    WHEN others
     THEN
        RAISE;
  END get_point_from_element_offset;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_point_from_element_offset(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                         ,pi_element_id       IN  nm_elements_all.ne_id%TYPE
                                         ,pi_offset           IN  NUMBER
                                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                                         ,po_message_cursor   OUT sys_refcursor
                                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_theme  nm_themes_all%ROWTYPE;
    lv_x      NUMBER;
    lv_y      NUMBER;
    --
  BEGIN
    --
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    --
    get_point_from_element_offset(pi_theme_id => lr_theme.nth_theme_id
                                 ,pi_ne_id    => pi_element_id
                                 ,pi_offset   => pi_offset
                                 ,po_x        => lv_x
                                 ,po_y        => lv_y);
    --
    OPEN po_cursor FOR
    SELECT lv_x x_coord
          ,lv_y y_coord
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
  END get_point_from_element_offset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_linear_elements_at_point(pi_x                IN  NUMBER
                                        ,pi_y                IN  NUMBER
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_map_name  hig_option_values.hov_value%TYPE := hig.get_sysopt('AWLMAPNAME');
    lv_point     mdsys.sdo_geometry;
    --
  BEGIN
    --
    lv_point := nm3sdo.get_2d_pt(p_x => pi_x
                                ,p_y => pi_y);
    --
    OPEN po_cursor FOR
    WITH themes AS(SELECT /*+ index(nm_themes_all nth_uk) */
                          nth_theme_id
                         ,nth_tolerance
                         ,nt_type
                         ,nt_unique
                         ,un_unit_id
                         ,un_unit_name
                     FROM nm_themes_all
                         ,nm_nw_themes
                         ,nm_linear_types
                         ,nm_types
                         ,nm_units
                    WHERE nth_theme_name IN(SELECT vnmd_theme_name
                                              FROM v_nm_msv_map_def
                                             WHERE vnmd_name = lv_map_name)      
                      AND EXISTS(SELECT 1
                                   FROM nm_theme_roles
                                       ,hig_user_roles
                                  WHERE nthr_theme_id = nth_theme_id
                                    AND nthr_role = hur_role
                                    AND hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
                                    AND hur_start_date <= TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY'))
                      AND nth_theme_id = nnth_nth_theme_id
                      AND nnth_nlt_id = nlt_id
                      AND nlt_nt_type = nt_type
                      AND nt_length_unit = un_unit_id)
    SELECT /*+ index(nm_elements ne_pk) */
           element_id
          ,element_network_type
          ,element_network_type_unique
          ,element_unique
          ,ne_descr element_description
          ,element_offset
          ,distance_from_point
          ,element_length_unit_name
      FROM (SELECT a.ntd_pk_id element_id
                  ,nt_type     element_network_type
                  ,nt_unique   element_network_type_unique
                  ,a.ntd_name  element_unique
                  ,nm3unit.get_formatted_value(a.ntd_measure,un_unit_id) element_offset
                  ,nm3unit.convert_unit(1,un_unit_id,a.ntd_distance) distance_from_point
                  ,un_unit_name element_length_unit_name
              FROM themes
                  ,TABLE(nm3sdo.get_objects_in_buffer(nth_theme_id
                                                     ,lv_point
                                                     ,nth_tolerance
                                                     ,1
                                                     ,'TRUE'
                                                     ,NULL).ntl_theme_list) a)
          ,nm_elements
     WHERE element_id = ne_id                                       
     ORDER
        BY distance_from_point
          ,ne_gty_group_type NULLS FIRST
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
  END get_linear_elements_at_point;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_location_geometry_wkt(pi_element_id       IN  nm_elements_all.ne_id%TYPE
                                     ,pi_from_offset      IN  NUMBER
                                     ,pi_to_offset        IN  NUMBER
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lv_pl_array  nm_placement_array;
    --
  BEGIN
    --
    lr_ne := nm3get.get_ne_all(pi_ne_id => pi_element_id);
    --
    IF lr_ne.ne_gty_group_type IS NOT NULL
     AND nm3net.is_gty_linear(p_gty => lr_ne.ne_gty_group_type) = 'N'
     THEN
        lv_pl_array := nm3pla.get_placement_from_ne(pi_element_id);
    ELSE
        lv_pl_array := nm3pla.get_sub_placement(nm_placement(pi_element_id
                                                            ,NVL(pi_from_offset,0)
                                                            ,NVL(pi_to_offset,nm3net.get_ne_length(pi_element_id))
                                                            ,0));
    END IF;
    --
    IF lv_pl_array.npa_placement_array.count > 1
     THEN
        OPEN po_cursor FOR
        SELECT awlrs_sdo.sdo_geom_to_wkt(sdo_aggr_union(mdsys.sdoaggrtype(
                 nm3sdo.get_placement_geometry(nm3pla.get_sub_placement(nm_placement(pl_ne_id
                                                                                    ,pl_start
                                                                                    ,pl_end
                                                                                    ,0))),0.005))) geom_wkt
          FROM TABLE(lv_pl_array.npa_placement_array) 
             ;
    ELSE
        OPEN po_cursor FOR
        SELECT awlrs_sdo.sdo_geom_to_wkt(nm3sdo.get_placement_geometry(lv_pl_array)) geom_wkt
          FROM dual
             ;
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
  END get_location_geometry_wkt;
--
------------------------------------------------------------------------------
--
END awlrs_sdo;
/