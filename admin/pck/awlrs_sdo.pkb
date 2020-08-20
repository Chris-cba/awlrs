CREATE OR REPLACE PACKAGE BODY awlrs_sdo
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdo.pkb-arc   1.27   Aug 20 2020 17:35:54   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_sdo.pkb  $
  --       Date into PVCS   : $Date:   Aug 20 2020 17:35:54  $
  --       Date fetched Out : $Modtime:   Aug 20 2020 16:11:16  $
  --       Version          : $Revision:   1.27  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.27  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_sdo';
  --
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
  ------------------------------------------------------------------------------
  --
  FUNCTION get_esu_id(pi_shape        IN mdsys.sdo_geometry
                     ,pi_displacement IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    --
    lv_mid_x      NUMBER;
    lv_mid_y      NUMBER;
    lv_esuid      VARCHAR2(30);
    --
    null_shape    EXCEPTION;
    disp_too_big  EXCEPTION;
    no_mid_point  EXCEPTION;
    --
  BEGIN
    --
    IF pi_shape IS NOT NULL
     THEN
        --
        BEGIN
          --
          IF pi_displacement IS NULL
           THEN
              --
              SELECT t.x
                    ,t.y
                INTO lv_mid_x
                    ,lv_mid_y
                FROM TABLE(sdo_util.getvertices(sdo_lrs.locate_pt(pi_shape,sdo_lrs.geom_segment_end_measure(pi_shape)/2,0))) t
                   ;
              --
          ELSE
              --make sure the displacement is not greater than half the length
              IF ABS(pi_displacement) <= 0.5 * (sdo_lrs.geom_segment_end_measure(pi_shape))
               THEN
                  --
                  SELECT t.x
                        ,t.y
                    INTO lv_mid_x
                        ,lv_mid_y
                    FROM TABLE(sdo_util.getvertices(sdo_lrs.locate_pt(pi_shape,(sdo_lrs.geom_segment_end_measure(pi_shape)/2) + pi_displacement,0))) t
                       ;
                  --
              ELSE
                  --
                  hig.raise_ner(pi_appl => nm3type.c_nsg
                               ,pi_id   => 17);
                  --
              END IF;
              --
          END IF;
          --
          lv_esuid := TO_CHAR(lv_mid_x,'0000000')||TO_CHAR(lv_mid_y,'0000000');
          lv_esuid := REPLACE(lv_esuid,' ','');
          --
        EXCEPTION
          WHEN no_data_found
           THEN
              hig.raise_ner(pi_appl => nm3type.c_nsg
                           ,pi_id   => 16);
        END;
        --
    ELSE
        --
        hig.raise_ner(pi_appl => nm3type.c_nsg
                     ,pi_id   => 15);
        --
    END IF;
    --
    RETURN lv_esuid;
    --
  END get_esu_id;

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
  FUNCTION get_std_geom(pi_geom IN mdsys.sdo_geometry)
    RETURN mdsys.sdo_geometry IS
    --
    lv_retval  mdsys.sdo_geometry;
    --
  BEGIN
    --
    lv_retval := pi_geom;
    --
    IF SUBSTR(pi_geom.sdo_gtype,1,1) = '3'
     THEN
        lv_retval := sdo_lrs.convert_to_std_geom(lrs_geom => lv_retval);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_std_geom;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE validate_geometry_type(pi_geometry_type IN VARCHAR2)
    IS
    --
  BEGIN
    --
    IF pi_geometry_type NOT IN(c_geojson,c_gml,c_gml311,c_wkt)
     THEN
        /*
        ||Raise Unsuported geometry type error.
        */
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 8);
    END IF;
    --
  END validate_geometry_type;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION sdo_geom_to(pi_geom            IN mdsys.sdo_geometry
                      ,pi_geometry_type   IN VARCHAR2
                      ,pi_include_measure IN VARCHAR2 DEFAULT 'N')
    RETURN CLOB IS
    --
    lv_geom  mdsys.sdo_geometry;
  BEGIN
    --
    validate_geometry_type(pi_geometry_type => pi_geometry_type);
    --
    IF pi_include_measure = 'Y'
     AND pi_geometry_type IN(c_geojson,c_wkt)
     THEN
        lv_geom := pi_geom;
    ELSE
        lv_geom := get_std_geom(pi_geom);
    END IF;
    --
    RETURN CASE pi_geometry_type
             WHEN c_geojson
              THEN
                 sdo_util.to_geojson(geometry => lv_geom)
             WHEN c_gml
              THEN
                 sdo_util.to_gmlgeometry(geometry => lv_geom)
             WHEN c_gml311
              THEN
                 sdo_util.to_gml311geometry(geometry => lv_geom)
             WHEN c_wkt
              THEN
                 sdo_util.to_wktgeometry(geometry => lv_geom)
             ELSE
                 NULL
           END;
    --
  END sdo_geom_to;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION sdo_geom_to_wkt(pi_geom IN mdsys.sdo_geometry)
    RETURN CLOB IS
    --
  BEGIN
    --
    RETURN sdo_geom_to(pi_geom,c_wkt);
    --
  END sdo_geom_to_wkt;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION wkt_to_sdo_geom(pi_theme_name          IN nm_themes_all.nth_theme_name%TYPE
                          ,pi_shape               IN CLOB
                          ,pi_conv_to_theme_gtype IN BOOLEAN DEFAULT TRUE
                          ,pi_rectify_polygon     IN BOOLEAN DEFAULT FALSE)
    RETURN mdsys.sdo_geometry IS
    --
    lv_shape  mdsys.sdo_geometry;
    lv_lrs    BOOLEAN := FALSE;
    lv_tol    NUMBER;
    lv_valid  nm3type.max_varchar2 := 'FALSE';
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
        lv_tol := nm3sdo.get_table_diminfo(lr_theme.nth_feature_table,lr_theme.nth_feature_shape_column)(1).sdo_tolerance;
        --
        lv_shape := sdo_util.from_wktgeometry(pi_shape);
        --
        IF pi_conv_to_theme_gtype
         THEN
            --
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
            IF lv_lrs
             THEN
                lv_shape := sdo_lrs.convert_to_lrs_geom(lv_shape);
            END IF;
            --
        END IF;
        --
        IF lr_theme_meta.srid IS NOT NULL
         THEN
            lv_shape.sdo_srid := lr_theme_meta.srid;
        END IF;
        --
        lv_valid := nm3sdo.validate_geometry(lv_shape,NULL,lv_tol);
        --
        IF lv_valid != 'TRUE'
         AND lv_shape.sdo_gtype = 2003
         AND pi_rectify_polygon
         THEN
            lv_shape := sdo_util.rectify_geometry(sdo_util.remove_duplicate_vertices(lv_shape,lv_tol),lv_tol);
            lv_valid := nm3sdo.validate_geometry(lv_shape,NULL,lv_tol);
        END IF;
        --
    END IF;
    --
    IF lv_valid != 'TRUE'
     THEN
        IF lv_valid = 'FALSE'
         THEN
            --Invalid geometry supplied
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 15);
        ELSE
            --Invalid geometry supplied
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 15
                         ,pi_supplementary_info => lv_valid);
        END IF;
    END IF;
    --
    RETURN lv_shape;
    --
  END wkt_to_sdo_geom;

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
          ,awlrs_util.apply_max_digits(nm3sdo.get_x_from_pt_geometry(nm3sdo.get_xy_from_measure(ne_id,offset))) snapped_x
          ,awlrs_util.apply_max_digits(nm3sdo.get_y_from_pt_geometry(nm3sdo.get_xy_from_measure(ne_id,offset))) snapped_y
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
  -----------------------------------------------------------------------------
  --
  PROCEDURE snap_asset_to_network(pi_x                IN  NUMBER
                                 ,pi_y                IN  NUMBER
                                 ,pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_sql         nm3type.max_varchar2;
    lv_batch_size  INTEGER := NVL(TO_NUMBER(hig.get_sysopt('SDOBATSIZE')),10);
    --
    lr_asset_theme       nm_themes_all%ROWTYPE;
    lr_asset_theme_meta  user_sdo_geom_metadata%ROWTYPE;
    lr_net_theme         nm_themes_all%ROWTYPE;
    --
    TYPE theme_id_tab IS TABLE OF nm_themes_all.nth_theme_id%TYPE;
    lt_base_theme_ids theme_id_tab;
    --
  BEGIN
    --
    lr_asset_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    lr_asset_theme_meta := nm3sdo.get_theme_metadata(p_nth_id => lr_asset_theme.nth_theme_id);
    /*
    ||Derived from nm3sdo.get_nearest_lref but we want to return a list
    ||not just the nearest one.
    ||First check if there is an over-riding theme snapping rule.
    */
    SELECT DISTINCT NVL(nth_base_table_theme,nth_theme_id)
      BULK COLLECT
      INTO lt_base_theme_ids
      FROM (SELECT a.nth_theme_id
                  ,a.nth_base_table_theme
              FROM nm_theme_snaps
                  ,nm_themes_all b
                  ,nm_themes_all a
             WHERE nts_theme_id = lr_asset_theme.nth_theme_id
               AND a.nth_theme_id = nts_snap_to
               AND b.nth_theme_id = nts_theme_id
               AND EXISTS(SELECT 1
                            FROM nm_nw_themes
                           WHERE nnth_nth_theme_id = a.nth_theme_id)
             ORDER
                BY nts_priority)
         ;
    --
    IF lt_base_theme_ids.COUNT = 0
     THEN
        --
        SELECT DISTINCT NVL(a.nth_base_table_theme,a.nth_theme_id) theme_id
          BULK COLLECT
          INTO lt_base_theme_ids
          FROM nm_base_themes
              ,nm_themes_all b
              ,nm_themes_all a
         WHERE nbth_theme_id = lr_asset_theme.nth_theme_id
           AND b.nth_theme_id = nbth_base_theme
           AND NVL(a.nth_base_table_theme, a.nth_theme_id) = b.nth_theme_id
           AND EXISTS(SELECT 1
                        FROM nm_theme_roles
                       WHERE nthr_theme_id = a.nth_theme_id)
             ;
        --
        IF lt_base_theme_ids.COUNT = 0
         THEN
            SELECT DISTINCT NVL(a.nth_base_table_theme,a.nth_theme_id) theme_id
              BULK COLLECT
              INTO lt_base_theme_ids
              FROM nm_inv_themes
                  ,nm_inv_nw
                  ,nm_linear_types
                  ,nm_nw_themes
                  ,nm_themes_all a
             WHERE nith_nth_theme_id = lr_asset_theme.nth_theme_id
               AND nith_nit_id = nin_nit_inv_code
               AND nin_nw_type = nlt_nt_type
               AND nlt_id = nnth_nlt_id
               AND nnth_nth_theme_id = nth_theme_id
               AND EXISTS(SELECT 1
                            FROM hig_user_roles
                                ,nm_theme_roles
                           WHERE hur_username = SYS_CONTEXT ('NM3_SECURITY_CTX','USERNAME')
                             AND hur_role = nthr_role
                             AND nthr_theme_id = a.nth_theme_id)
                 ;
        END IF;
    END IF;
    --
    IF lt_base_theme_ids.COUNT = 0
     THEN
        --No snaps at this position.
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 286);
    END IF;
    --
    lv_sql :=  'WITH pt AS(SELECT mdsys.sdo_geometry(2001'
    ||CHR(10)||'                                    ,:srid'
    ||CHR(10)||'                                    ,mdsys.sdo_point_type(:p_x,:p_y,NULL)'
    ||CHR(10)||'                                    ,NULL'
    ||CHR(10)||'                                    ,NULL) pnt'
    ||CHR(10)||'             FROM dual)'
    ||CHR(10)||'SELECT snaps.ne_id'
    ||CHR(10)||'      ,ne_unique'
    ||CHR(10)||'      ,ne_descr'
    ||CHR(10)||'      ,ne_nt_type'
    ||CHR(10)||'      ,ne_gty_group_type'
    ||CHR(10)||'      ,ne_type'
    ||CHR(10)||'      ,TO_NUMBER(nm3unit.get_formatted_value(CASE WHEN ne_length IS NOT NULL THEN LEAST(ne_length,sdo_lrs.get_measure(snaps.snap_pnt)) ELSE sdo_lrs.get_measure(snaps.snap_pnt) END'
    ||CHR(10)||'                                            ,nt_length_unit)) offset'
    ||CHR(10)||'      ,nt_length_unit unit_id'
    ||CHR(10)||'      ,un_unit_name unit_name'
    ||CHR(10)||'      ,snap_dist distance'
    ||CHR(10)||'      ,awlrs_util.apply_max_digits(nm3sdo.get_x_from_pt_geometry(snaps.snap_pnt)) snapped_x'
    ||CHR(10)||'      ,awlrs_util.apply_max_digits(nm3sdo.get_y_from_pt_geometry(snaps.snap_pnt)) snapped_y'
    ||CHR(10)||'  FROM nm_elements ne'
    ||CHR(10)||'      ,nm_types'
    ||CHR(10)||'      ,nm_units'
    ||CHR(10)||'      ,(SELECT /*+ first_rows */ *'
    ||CHR(10)||'          FROM ('
    ;
    --
    FOR i IN 1..lt_base_theme_ids.COUNT LOOP
      --
      lr_net_theme := nm3get.get_nth(pi_nth_theme_id => lt_base_theme_ids(i));
      --
      IF i > 1
       THEN
          lv_sql := lv_sql||'        UNION ALL'||CHR(10);
      END IF;
      --
      lv_sql := lv_sql||'SELECT ft.'||lr_net_theme.nth_feature_pk_column||' ne_id'
      ||CHR(10)||'              ,sdo_nn_distance(1) snap_dist'
      ||CHR(10)||'              ,sdo_lrs.project_pt('||lr_net_theme.nth_feature_shape_column
      ||CHR(10)||'                                 ,dim.diminfo'
      ||CHR(10)||'                                 ,pt.pnt) snap_pnt'
      ||CHR(10)||'          FROM (SELECT diminfo FROM user_sdo_geom_metadata where table_name = '''||lr_net_theme.nth_feature_table||''') dim'
      ||CHR(10)||'              ,'||lr_net_theme.nth_feature_table||' ft'
      ||CHR(10)||'              ,pt'
      ||CHR(10)||'         WHERE sdo_nn('||lr_net_theme.nth_feature_shape_column
      ||CHR(10)||'                     ,pt.pnt'
      ||CHR(10)||'                     ,''sdo_batch_size='||lv_batch_size||' unit=meter'''
      ||CHR(10)||'                     ,1) = ''TRUE'''
      ;
      --
    END LOOP;
    --
    lv_sql := lv_sql||')'||CHR(10)||'         ORDER BY snap_dist) snaps'
     ||CHR(10)||' WHERE ROWNUM <= '||lv_batch_size
     ||CHR(10)||'   AND snaps.ne_id = ne.ne_id'
     ||CHR(10)||'   AND ne_nt_type = nt_type'
     ||CHR(10)||'   AND nt_length_unit = un_unit_id'
    ;
    --
    OPEN po_cursor FOR lv_sql
      USING lr_asset_theme_meta.srid
           ,pi_x
           ,pi_y;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END snap_asset_to_network;

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
    SELECT awlrs_util.apply_max_digits(lv_x) x_coord
          ,awlrs_util.apply_max_digits(lv_y) y_coord
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
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_element_vertices(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                ,pi_element_id       IN  nm_elements_all.ne_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_theme  nm_themes_all%ROWTYPE;
    lv_unit_id nm_units.un_unit_id%TYPE;
    --
  BEGIN
    --
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    --
    SELECT nt_length_unit
      INTO lv_unit_id
      FROM nm_elements
          ,nm_types
     WHERE ne_nt_type = nt_type
       AND ne_id = pi_element_id
         ;

    OPEN po_cursor FOR 'WITH element_shape AS(SELECT '||lr_theme.nth_feature_shape_column||' geom'
            ||CHR(10)||'                        FROM '||lr_theme.nth_feature_table
            ||CHR(10)||'                       WHERE '||lr_theme.nth_feature_pk_column||' = :pi_ne_id)'
            ||CHR(10)||'SELECT a.id'
            ||CHR(10)||'      ,awlrs_util.apply_max_digits(a.x) x'
            ||CHR(10)||'      ,awlrs_util.apply_max_digits(a.y) y'
            ||CHR(10)||'      ,TO_NUMBER(nm3unit.get_formatted_value(a.z, :pi_unit_id)) m '
            ||CHR(10)||'  FROM element_shape'
            ||CHR(10)||'      ,TABLE(sdo_util.getvertices(geom)) a'
            ||CHR(10)||' ORDER'
            ||CHR(10)||'    BY a.id'
    USING pi_element_id, lv_unit_id
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
  END get_element_vertices;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_linear_elements_at_point(pi_map_name         IN  hig_option_values.hov_value%TYPE DEFAULT NULL
                                        ,pi_x                IN  NUMBER
                                        ,pi_y                IN  NUMBER
                                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor   OUT sys_refcursor
                                        ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_map_name  hig_option_values.hov_value%TYPE := NVL(pi_map_name,hig.get_sysopt('AWLMAPNAME'));
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
                         ,nlt_gty_type
                         ,ngt_descr
                         ,un_unit_id
                         ,un_unit_name
                     FROM nm_themes_all
                         ,nm_nw_themes
                         ,nm_linear_types
                         ,nm_types
                         ,nm_units
                         ,nm_group_types
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
                      AND nt_length_unit = un_unit_id
                      AND nlt_gty_type = ngt_group_type(+))
    SELECT /*+ index(nm_elements ne_pk) */
           element_id
          ,element_network_type
          ,element_network_type_unique
          ,element_group_type
          ,element_group_type_descr
          ,CASE ne_nt_type
             WHEN 'ESU' THEN ne_name_1
             WHEN 'NSGN' THEN ne_number
             ELSE ne_unique
           END element_unique
          ,ne_descr element_description
          ,element_offset
          ,distance_from_point
          ,element_length_unit_name
          ,ne_start_date element_start_date
          ,CASE
             WHEN element_group_type IS NOT NULL
              AND element_group_type = NVL(SYS_CONTEXT('NM3CORE','PREFERRED_LRM'),nm3type.c_nvl)
              THEN
                 'Y'
             ELSE
                 'N'
           END is_preferred_lrm
      FROM (SELECT a.ntd_pk_id  element_id
                  ,nt_type      element_network_type
                  ,nt_unique    element_network_type_unique
                  ,nlt_gty_type element_group_type
                  ,ngt_descr    element_group_type_descr
                  ,a.ntd_name   element_unique
                  ,TO_NUMBER(nm3unit.get_formatted_value(a.ntd_measure,un_unit_id)) element_offset
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
        BY CASE
             WHEN NVL(element_group_type,nm3type.c_nvl) = NVL(SYS_CONTEXT('NM3CORE','PREFERRED_LRM'),'ALL LRMS')
              THEN 1
             ELSE 2
           END
          ,distance_from_point
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
  ------------------------------------------------------------------------------
  --
  FUNCTION get_location_geometry(pi_element_id  IN nm_elements_all.ne_id%TYPE
                                ,pi_from_offset IN NUMBER
                                ,pi_to_offset   IN NUMBER)
    RETURN mdsys.sdo_geometry IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    lv_pl_array  nm_placement_array;
    lv_retval    mdsys.sdo_geometry;
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
    IF lv_pl_array.npa_placement_array.COUNT > 1
     THEN
        SELECT sdo_aggr_union(mdsys.sdoaggrtype(nm3sdo.get_placement_geometry(nm3pla.get_sub_placement(nm_placement(pl_ne_id
                                                                                                                   ,pl_start
                                                                                                                   ,pl_end
                                                                                                                   ,0)))
                                               ,0.005))
          INTO lv_retval
          FROM TABLE(lv_pl_array.npa_placement_array)
             ;
    ELSE
        lv_retval := nm3sdo.get_placement_geometry(lv_pl_array);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_location_geometry;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_element_geometry_length(pi_element_id   IN nm_elements_all.ne_id%TYPE
                                      ,pi_element_type IN nm_elements_all.ne_type%TYPE
                                      ,pi_unit         IN nm_units.un_unit_name%TYPE)
    RETURN NUMBER IS
    --
    lv_retval  NUMBER;
    --
  BEGIN
    --
    CASE pi_element_type
      WHEN 'S'
       THEN
          --
          lv_retval := sdo_geom.sdo_length(nm3sdo.get_layer_element_geometry(p_ne_id => pi_element_id),0.05,'unit='||pi_unit);
          --
      WHEN 'G'
       THEN
          --
          lv_retval := sdo_geom.sdo_length(nm3sdo.get_shape_from_ne(p_ne_id => pi_element_id),0.05,'unit='||pi_unit);
          --
      ELSE
          --
          lv_retval := NULL;
          --
    END CASE;
    --
    RETURN lv_retval;
    --
  END get_element_geometry_length;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_linear_element_geom_length(pi_element_id IN nm_elements_all.ne_id%TYPE)
    RETURN NUMBER IS
    --
    lv_retval  NUMBER;
    lv_format  nm_units.un_format_mask%TYPE;
    --
  BEGIN
    /*
    ||If the given element is linear then return the geometry length
    ||otherwise the processing will fall into the exception handler and
    ||return NULL.
    ||
    ||Note: this code is reliant on exor unit names matching oracle spatial
    ||unit names which at the time of writing is the case, if this changes
    ||an alternative approach will need to be employed to convert the units
    ||of the co-ordinate system used by the geometry to the units associated
    ||with the Network Type of the Element.
    */
    SELECT awlrs_sdo.get_element_geometry_length(ne_id,ne_type,un_unit_name) geometry_length
          ,un_format_mask
      INTO lv_retval
          ,lv_format
      FROM nm_elements
          ,nm_types
          ,nm_units
     WHERE ne_id = pi_element_id
       AND ne_nt_type = nt_type
       AND nt_linear = 'Y'
       AND nt_length_unit = un_unit_id;
    --
    RETURN CASE WHEN lv_format IS NOT NULL THEN TO_NUMBER(TO_CHAR(lv_retval,lv_format)) ELSE lv_retval END;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        RETURN NULL;
  END get_linear_element_geom_length;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_location_geometry_as(pi_element_id    IN nm_elements_all.ne_id%TYPE
                                   ,pi_from_offset   IN NUMBER
                                   ,pi_to_offset     IN NUMBER
                                   ,pi_geometry_type IN VARCHAR2)
    RETURN CLOB IS
    --
  BEGIN
    --
    RETURN sdo_geom_to(pi_geom          => get_location_geometry(pi_element_id  => pi_element_id
                                                                ,pi_from_offset => pi_from_offset
                                                                ,pi_to_offset   => pi_to_offset)
                      ,pi_geometry_type => pi_geometry_type);
    --
  END get_location_geometry_as;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_location_geometry_wkt(pi_element_id  IN nm_elements_all.ne_id%TYPE
                                    ,pi_from_offset IN NUMBER
                                    ,pi_to_offset   IN NUMBER)
    RETURN CLOB IS
    --
  BEGIN
    --
    RETURN get_location_geometry_as(pi_element_id    => pi_element_id
                                   ,pi_from_offset   => pi_from_offset
                                   ,pi_to_offset     => pi_to_offset
                                   ,pi_geometry_type => c_wkt);
    --
  END get_location_geometry_wkt;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_location_geometry_as(pi_element_id       IN  nm_elements_all.ne_id%TYPE
                                    ,pi_from_offset      IN  NUMBER
                                    ,pi_to_offset        IN  NUMBER
                                    ,pi_geometry_type    IN VARCHAR2
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_retval  CLOB;
    --
  BEGIN
    --
    lv_retval := get_location_geometry_as(pi_element_id    => pi_element_id
                                         ,pi_from_offset   => pi_from_offset
                                         ,pi_to_offset     => pi_to_offset
                                         ,pi_geometry_type => pi_geometry_type);
    --
    OPEN po_cursor FOR
    SELECT lv_retval geometry
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
  END get_location_geometry_as;

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
    lv_retval  CLOB;
    --
  BEGIN
    --
    lv_retval := get_location_geometry_as(pi_element_id    => pi_element_id
                                         ,pi_from_offset   => pi_from_offset
                                         ,pi_to_offset     => pi_to_offset
                                         ,pi_geometry_type => c_wkt);
    --
    OPEN po_cursor FOR
    SELECT lv_retval geom_wkt
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
  END get_location_geometry_wkt;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_unit_id_from_srid(pi_srid IN NUMBER)
    RETURN nm_units.un_unit_id%TYPE IS
    --
    lv_unit  nm_units.un_unit_id%TYPE;
    --
  BEGIN
    --
    SELECT un_unit_id
      INTO lv_unit
      FROM (SELECT CASE
                     WHEN UPPER(un_unit_name) = 'METRES'
                       OR UPPER(un_unit_name) = 'METERS'
                       OR UPPER(un_unit_name) = 'METER'
                       THEN 'METER'
                     WHEN UPPER (un_unit_name) = 'MILES'
                       THEN 'MILE'
                     WHEN UPPER (un_unit_name) = 'KILOMETERS'
                       THEN 'KILOMETER'
                     WHEN UPPER (un_unit_name) = 'DECIMAL DEGREES'
                       OR UPPER (un_unit_name) = 'DEGREES'
                       THEN 'DECIMAL DEGREE'
                     ELSE
                       UPPER(un_unit_name)
                   END un_unit_name
                  ,un_unit_id
              FROM nm_units)
          ,(SELECT srid
                  ,REPLACE(REGEXP_SUBSTR(SUBSTR(wktext,(instr(wktext,'UNIT ['||chr(34),-1)),(length(wktext)-(instr(wktext,'UNIT ['||chr(34),-1))))
                                        ,CHR(34)||'[^'||CHR(34)||']+'||CHR(34))
                          ,CHR(34),'') unit_name
              FROM mdsys.cs_srs
             WHERE srid = pi_srid)
     WHERE '%'||UPPER(unit_name)||'%' LIKE '%'||UPPER(un_unit_name)||'%'
         ;
    --
    RETURN lv_unit;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        /*
        ||Default to Metres.
        */
        RETURN 1;
        --
    WHEN others
     THEN
        RAISE;
  END get_unit_id_from_srid;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE seed_network_subset(pi_theme_id    IN nm_themes_all.nth_theme_id%TYPE
                               ,pi_srid        IN NUMBER
                               ,pi_start_x     IN NUMBER
                               ,pi_start_y     IN NUMBER
                               ,pi_end_x       IN NUMBER
                               ,pi_end_y       IN NUMBER
                               ,pi_buffer_perc IN NUMBER DEFAULT NULL
                               ,pi_min_buffer  IN NUMBER DEFAULT NULL)
    IS
    --
    lv_job_id        NUMBER := nm3net.get_next_nte_id;
    lv_min_x         NUMBER;
    lv_min_y         NUMBER;
    lv_max_x         NUMBER;
    lv_max_y         NUMBER;
    lv_buffer_perc   NUMBER;
    lv_min_buffer    NUMBER;
    lv_buffer        NUMBER;
    lv_buffer_units  NUMBER;
    --
  BEGIN
    /*
    ||Define the mbr.
    */
    lv_min_x := LEAST(pi_start_x,pi_end_x);
    lv_min_y := LEAST(pi_start_y,pi_end_y);
    lv_max_x := GREATEST(pi_start_x,pi_end_x);
    lv_max_y := GREATEST(pi_start_y,pi_end_y);
    /*
    ||Set a buffer around the mbr.
    */
    lv_buffer_perc := NVL(pi_buffer_perc,hig.get_sysopt('AWLRSPTHPERC'));
    lv_min_buffer := NVL(pi_min_buffer,hig.get_sysopt('AWLRSPTHMINB'));
    --
    lv_buffer_units := get_unit_id_from_srid(pi_srid => pi_srid);
    --
    IF lv_buffer_units = 1
     THEN
        lv_buffer := GREATEST(GREATEST(lv_max_x - lv_min_x, lv_max_y - lv_min_y)*(lv_buffer_perc/100)
                             ,lv_min_buffer);
    ELSE
        /*
        ||Minimum buffer size is specified in Metres so convert it
        ||before comparing with the percentage based buffer size.
        */
        lv_buffer := GREATEST(GREATEST(lv_max_x - lv_min_x, lv_max_y - lv_min_y)*(lv_buffer_perc/100)
                             ,nm3unit.convert_unit(p_un_id_in  => 1
                                                  ,p_un_id_out => lv_buffer_units
                                                  ,p_value     => lv_min_buffer));
    END IF;
    /*
    ||Find the network elements that interact with the mbr.
    */
    INSERT
      INTO nm_nw_temp_extents
    SELECT *
      FROM (WITH results
              AS(SELECT buf.*
                       ,ne.ne_type
                   FROM TABLE(nm3sdo.get_objects_in_buffer(pi_theme_id
                                                          ,SDO_GEOMETRY(2003
                                                                       ,pi_srid
                                                                       ,NULL
                                                                       ,SDO_ELEM_INFO_ARRAY(1,1003,3)
                                                                       ,SDO_ORDINATE_ARRAY(lv_min_x,lv_min_y,lv_max_x,lv_max_y))
                                                          ,lv_buffer
                                                          ,lv_buffer_units).ntl_theme_list) buf
                       ,nm_elements ne
                  WHERE ntd_pk_id = ne_id)
           SELECT lv_job_id      nte_job_id
                 ,nm_ne_id_of    nte_ne_id_of
                 ,nm_begin_mp    nte_begin_mp
                 ,nm_end_mp      nte_end_mp
                 ,nm_cardinality nte_cardinality
                 ,nm_seq_no      nte_seq_no
                 ,ntd_pk_id      nte_route_ne_id
             FROM nm_members
                 ,results
            WHERE ntd_pk_id = nm_ne_id_in
              AND nm_type = 'G'
            UNION
           SELECT lv_job_id   nte_job_id
                 ,a.ne_id     nte_ne_id_of
                 ,0           nte_begin_mp
                 ,a.ne_length nte_end_mp
                 ,null        nte_cardinality
                 ,null        nte_seq_no
                 ,null        nte_route_ne_id
             FROM nm_elements a
                 ,results
            WHERE ntd_pk_id = a.ne_id
              AND a.ne_type = 'S')
         ;
    --
    nm_cncts.make_cnct_from_tmp_extent(lv_job_id);
    --
  END seed_network_subset;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_datum_theme_id(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN nm_themes_all.nth_theme_id%TYPE IS
    --
    lv_retval  nm_themes_all.nth_theme_id%TYPE;
    --
    CURSOR get_apgt(cp_theme_name IN nm_themes_all.nth_theme_name%TYPE)
        IS
    SELECT nth_theme_id
      INTO lv_retval
      FROM nm_themes_all
          ,awlrs_path_group_themes
     WHERE apgt_group_theme_name = cp_theme_name
       AND apgt_datum_theme_name = nth_theme_name
         ;
    --
    CURSOR get_base_theme(cp_theme_name IN nm_themes_all.nth_theme_name%TYPE)
        IS
    SELECT nth_theme_id
      FROM nm_themes_all
          ,nm_nw_themes
          ,nm_linear_types
          ,nm_nt_groupings_all
     WHERE nng_group_type =(SELECT nlt_gty_type
                              FROM nm_nw_themes
                                  ,nm_linear_types
                                  ,nm_types
                                  ,nm_type_inclusion
                                  ,nm_group_types_all
                             WHERE nnth_nth_theme_id =(SELECT nth_theme_id FROM nm_themes_all WHERE nth_theme_name = cp_theme_name)
                               AND nnth_nlt_id = nlt_id
                               AND nlt_g_i_d = 'G'
                               AND nlt_nt_type = nt_type
                               AND nt_type = nti_nw_parent_type(+)
                               AND nlt_gty_type = ngt_group_type(+)
                            UNION ALL
                            SELECT nat_gty_group_type
                              FROM nm_area_themes
                                  ,nm_area_types
                                  ,nm_types
                                  ,nm_type_inclusion
                                  ,nm_group_types_all
                             WHERE nath_nth_theme_id  =(SELECT nth_theme_id FROM nm_themes_all WHERE nth_theme_name = cp_theme_name)
                               AND nath_nat_id = nat_id
                               AND nat_nt_type = nt_type
                               AND nt_type = nti_nw_parent_type(+)
                               AND nat_gty_group_type = ngt_group_type)
       AND nng_nt_type = nlt_nt_type
       AND nlt_id = nnth_nlt_id
       AND nnth_nth_theme_id = nth_theme_id
       AND nth_base_table_theme IS NULL
         ;
    --
  BEGIN
    --
    OPEN  get_apgt(pi_theme_name);
    FETCH get_apgt
     INTO lv_retval;
    --
    IF get_apgt%NOTFOUND
     THEN
        OPEN  get_base_theme(pi_theme_name);
        FETCH get_base_theme
         INTO lv_retval;
        --
        IF get_base_theme%NOTFOUND
         THEN
            hig.raise_ner(pi_appl               => 'AWLRS'
                         ,pi_id                 => 53
                         ,pi_supplementary_info => pi_theme_name);
        END IF;
        --
        CLOSE get_base_theme;
    END IF;
    --
    CLOSE get_apgt;
    --
    RETURN lv_retval;
    --
  END get_datum_theme_id;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE create_path(pi_theme_name           IN  nm_themes_all.nth_theme_name%TYPE
                       ,pi_start_x              IN  nm_elements_all.ne_id%TYPE
                       ,pi_start_y              IN  NUMBER
                       ,pi_end_x                IN  nm_elements_all.ne_id%TYPE
                       ,pi_end_y                IN  NUMBER
                       ,pi_buffer_perc          IN  NUMBER DEFAULT NULL
                       ,pi_min_buffer           IN  NUMBER DEFAULT NULL
                       ,pi_restrict_to_ne_id    IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                       ,pi_return_datums        IN  VARCHAR2 DEFAULT 'Y'
                       ,po_message_severity     OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor       OUT sys_refcursor
                       ,po_cursor               OUT sys_refcursor)
    IS
    --
    lr_theme              nm_themes_all%ROWTYPE;
    lr_datum_theme_meta   user_sdo_geom_metadata%ROWTYPE;
    --
    lv_datum_theme_id     nm_themes_all.nth_theme_id%TYPE;
    lv_target_group_type  nm_group_types_all.ngt_group_type%TYPE;
    lv_job_id             nm_nw_temp_extents.nte_job_id%TYPE;
    --
    lt_placement  nm_placement_array;
    --
    FUNCTION theme_is_datum(pi_theme_id IN nm_themes_all.nth_theme_id%TYPE)
      RETURN BOOLEAN IS
      --
      lv_dummy   VARCHAR2(1);
      lv_retval  BOOLEAN;
      --
      CURSOR chk(cp_theme_id IN nm_themes_all.nth_theme_id%TYPE)
          IS
      SELECT 'x'
        FROM nm_linear_types
            ,nm_nw_themes
       WHERE nnth_nth_theme_id = cp_theme_id
         AND nnth_nlt_id = nlt_id
           ;

    BEGIN
      --
      OPEN  chk(pi_theme_id);
      FETCH chk
       INTO lv_dummy;
      lv_retval := chk%FOUND;
      CLOSE chk;
      --
      RETURN lv_retval;
      --
    END;
    --
    FUNCTION get_group_type(pi_theme_id   IN nm_themes_all.nth_theme_id%TYPE
                           ,pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
      RETURN nm_group_types_all.ngt_group_type%TYPE IS
      --
      lv_retval  nm_group_types_all.ngt_group_type%TYPE;
      --
    BEGIN
      --
      SELECT nlt_gty_type
        INTO lv_retval
        FROM nm_linear_types
            ,nm_nw_themes
       WHERE nnth_nth_theme_id = pi_theme_id
         AND nnth_nlt_id = nlt_id
           ;
      --
      RETURN lv_retval;
      --
    EXCEPTION
      WHEN no_data_found
       THEN
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 54
                     ,pi_supplementary_info => pi_theme_name);
      WHEN others
       THEN
          RAISE;
    END get_group_type;
    --
  BEGIN
    /*
    ||Get the Theme Id and SRID.
    */
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    /*
    ||Get the Datum theme we want to path through.
    */
    IF theme_is_datum(pi_theme_id => lr_theme.nth_theme_id)
     THEN
        --
        lv_datum_theme_id := lr_theme.nth_theme_id;
        --
    ELSE
        --
        lv_datum_theme_id := get_datum_theme_id(pi_theme_name => pi_theme_name);
        --
        lv_target_group_type := get_group_type(pi_theme_id   => lr_theme.nth_theme_id
                                              ,pi_theme_name => pi_theme_name);
        --
    END IF;
    --
    lr_datum_theme_meta := nm3sdo.get_theme_metadata(p_nth_id => lv_datum_theme_id);
    /*
    ||Prepare the network to be searched.
    */
    IF pi_restrict_to_ne_id IS NULL
     THEN
        seed_network_subset(pi_theme_id    => lv_datum_theme_id
                           ,pi_srid        => lr_datum_theme_meta.srid
                           ,pi_start_x     => pi_start_x
                           ,pi_start_y     => pi_start_y
                           ,pi_end_x       => pi_end_x
                           ,pi_end_y       => pi_end_y
                           ,pi_buffer_perc => pi_buffer_perc
                           ,pi_min_buffer  => pi_min_buffer);
    ELSE
        --
        lv_job_id := nm3net.get_next_nte_id;
        --
        INSERT
          INTO nm_nw_temp_extents
        SELECT lv_job_id      nte_job_id
              ,nm_ne_id_of    nte_ne_id_of
              ,nm_begin_mp    nte_begin_mp
              ,nm_end_mp      nte_end_mp
              ,nm_cardinality nte_cardinality
              ,nm_seq_no      nte_seq_no
              ,nm_ne_id_in    nte_route_ne_id
          FROM nm_members
         WHERE nm_ne_id_in = pi_restrict_to_ne_id
           AND nm_type = 'G'
             ;
        --
        nm_cncts.make_cnct_from_tmp_extent(lv_job_id);
        --
    END IF;
    /*
    ||Build a ref cursor to return the path.
    */
    IF pi_return_datums = 'Y'
     OR lv_target_group_type IS NULL
     THEN
        /*
        ||Get the placement array first so that any exceptions are
        ||returned through the parameters rather than when the cursor
        ||is fetched.
        */
        lt_placement := awlrs_sdo.get_pl_by_xy(lv_datum_theme_id
                                              ,pi_start_x
                                              ,pi_start_y
                                              ,pi_end_x
                                              ,pi_end_y
                                              ,'N');
        --
        OPEN po_cursor FOR
        WITH all_data
          AS (SELECT ROWNUM ind
                    ,np.*
                FROM TABLE(lt_placement.npa_placement_array) np)
        SELECT ne_id
              ,CASE ne_nt_type
                 WHEN 'ESU' THEN ne_name_1
                 WHEN 'NSGN' THEN ne_number
                 ELSE ne_unique
               END ne_unique
              ,ne_descr
              ,ne_nt_type
              ,ne_gty_group_type
              ,ne_type
              ,pl_start       from_offset
              ,pl_end         to_offset
              ,nt_length_unit unit_id
              ,un_unit_name   unit_name
              ,awlrs_sdo.sdo_geom_to(nm3sdo.get_placement_geometry(nm_placement_array(CAST(COLLECT(nm_placement(ne_id,pl_start,pl_end,0)) AS nm_placement_array_type)))
                                    ,c_wkt) geom_wkt
              ,nau_name ne_admin_unit
              ,GREATEST(pl_start,pl_end) - LEAST(pl_start,pl_end) path_segment_length
              ,nm3net.get_ne_length(ne_id) element_length
          FROM nm_units
              ,nm_types
              ,nm_admin_units_all
              ,nm_elements
              ,all_data
         WHERE pl_ne_id = ne_id
           AND ne_admin_unit = nau_admin_unit
           AND ne_nt_type = nt_type
           AND nt_length_unit = un_unit_id
         GROUP
            BY ne_id
              ,CASE ne_nt_type
                 WHEN 'ESU' THEN ne_name_1
                 WHEN 'NSGN' THEN ne_number
                 ELSE ne_unique
               END
              ,ne_descr
              ,ne_nt_type
              ,ne_gty_group_type
              ,pl_start
              ,pl_end
              ,nt_length_unit
              ,un_unit_name
              ,nt_node_type
              ,ne_type
              ,nau_name
              ,ind
         ORDER
            BY ind
             ;
    ELSE
      --
      lv_job_id := nm3net.get_next_nte_id;
      --
      INSERT
        INTO nm_nw_temp_extents
             (nte_job_id
             ,nte_ne_id_of
             ,nte_begin_mp
             ,nte_end_mp
             ,nte_cardinality
             ,nte_seq_no
             ,nte_route_ne_id)
       SELECT lv_job_id
             ,np.pl_ne_id
             ,np.pl_start
             ,np.pl_end
             ,CASE WHEN np.pl_start <= np.pl_end THEN 1 ELSE -1 END
             ,ROWNUM ind
             ,NULL
         FROM TABLE(awlrs_sdo.get_pl_by_xy(lv_datum_theme_id
                                          ,pi_start_x
                                          ,pi_start_y
                                          ,pi_end_x
                                          ,pi_end_y
                                          ,'N').npa_placement_array) np
            ;
       --
       OPEN po_cursor FOR
       SELECT ne.ne_id
             ,CASE ne.ne_nt_type
                WHEN 'ESU' THEN ne.ne_name_1
                WHEN 'NSGN' THEN ne.ne_number
                ELSE ne.ne_unique
              END ne_unique
             ,ne.ne_descr
             ,ne.ne_nt_type
             ,ne.ne_gty_group_type
             ,ne.ne_type
             ,locs.from_offset
             ,locs.to_offset
             ,nt.nt_length_unit unit_id
             ,nu.un_unit_name   unit_name
             ,awlrs_sdo.get_location_geometry_as(pi_element_id    => ne.ne_id
                                                ,pi_from_offset   => locs.from_offset
                                                ,pi_to_offset     => locs.to_offset
                                                ,pi_geometry_type => c_wkt) geom_wkt
             ,nau.nau_name ne_admin_unit
         FROM nm_units nu
             ,nm_types nt
             ,nm_admin_units_all nau
             ,nm_elements ne
             ,(SELECT pl.pl_ne_id ne_id
                     ,pl.pl_start from_offset
                     ,pl.pl_end   to_offset
                     ,rownum      ind
                 FROM TABLE(nm3pla.get_connected_chunks(p_nte_job_id => lv_job_id
                                                       ,p_route_id   => NULL
                                                       ,p_obj_type   => lv_target_group_type).npa_placement_array) pl) locs
        WHERE locs.ne_id = ne.ne_id
          AND ne.ne_admin_unit = nau.nau_admin_unit
          AND ne.ne_nt_type = nt.nt_type
          AND nt.nt_length_unit = nu.un_unit_id
        GROUP
           BY ne.ne_id
             ,CASE ne.ne_nt_type
                WHEN 'ESU' THEN ne.ne_name_1
                WHEN 'NSGN' THEN ne.ne_number
                ELSE ne.ne_unique
              END
             ,ne.ne_descr
             ,ne.ne_nt_type
             ,ne.ne_gty_group_type
             ,locs.from_offset
             ,locs.to_offset
             ,nt.nt_length_unit
             ,nu.un_unit_name
             ,nt.nt_node_type
             ,ne.ne_type
             ,nau.nau_name
             ,locs.ind
        ORDER
           BY locs.ind
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
  END create_path;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE create_path(pi_theme_name           IN  nm_themes_all.nth_theme_name%TYPE
                       ,pi_start_element_id     IN  nm_elements_all.ne_id%TYPE
                       ,pi_start_element_offset IN  NUMBER
                       ,pi_end_element_id       IN  nm_elements_all.ne_id%TYPE
                       ,pi_end_element_offset   IN  NUMBER
                       ,pi_buffer_perc          IN  NUMBER DEFAULT NULL
                       ,pi_min_buffer           IN  NUMBER DEFAULT NULL
                       ,pi_restrict_to_ne_id    IN  nm_elements_all.ne_id%TYPE DEFAULT NULL
                       ,pi_return_datums        IN  VARCHAR2 DEFAULT 'Y'
                       ,po_message_severity     OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor       OUT sys_refcursor
                       ,po_cursor               OUT sys_refcursor)
    IS
    --
    lr_theme              nm_themes_all%ROWTYPE;
    --
    lv_datum_theme_id     nm_themes_all.nth_theme_id%TYPE;
    --
    lv_start_x  NUMBER;
    lv_start_y  NUMBER;
    lv_end_x    NUMBER;
    lv_end_y    NUMBER;
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    lv_cursor            sys_refcursor;
    --
  BEGIN
    /*
    ||Get the Theme Id and SRID.
    */
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    /*
    ||Get the Datum theme we want to path through.
    */
    IF nm3net.is_nt_linear(p_nt_type => nm3net.get_ne(pi_start_element_id).ne_nt_type) != 'Y'
     THEN
        --Theme must be linear
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 69);
    END IF;
    --
    /*
    ||Get the start coordinates.
    */
    get_point_from_element_offset(pi_theme_id => lr_theme.nth_theme_id
                                 ,pi_ne_id    => pi_start_element_id
                                 ,pi_offset   => pi_start_element_offset
                                 ,po_x        => lv_start_x
                                 ,po_y        => lv_start_y);
    /*
    ||Get the end coordinates.
    */
    get_point_from_element_offset(pi_theme_id => lr_theme.nth_theme_id
                                 ,pi_ne_id    => pi_end_element_id
                                 ,pi_offset   => pi_end_element_offset
                                 ,po_x        => lv_end_x
                                 ,po_y        => lv_end_y);
    /*
    ||Create the path.
    */
    create_path(pi_theme_name           => pi_theme_name
               ,pi_start_x              => lv_start_x
               ,pi_start_y              => lv_start_y
               ,pi_end_x                => lv_end_x
               ,pi_end_y                => lv_end_y
               ,pi_buffer_perc          => pi_buffer_perc
               ,pi_min_buffer           => pi_min_buffer
               ,pi_restrict_to_ne_id    => pi_restrict_to_ne_id
               ,pi_return_datums        => pi_return_datums
               ,po_message_severity     => lv_message_severity
               ,po_message_cursor       => lv_message_cursor
               ,po_cursor               => lv_cursor);
    --
    po_cursor := lv_cursor;
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_path;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE get_element_vertices_nlgod(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                      ,pi_element_id       IN  nm_elements_all.ne_id%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor
                                      ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_group_theme         nm_themes_all%ROWTYPE;
    lr_datum_theme         nm_themes_all%ROWTYPE;
    lv_group_type          nm_group_types_all.ngt_group_type%TYPE;
    lv_element_group_type  nm_group_types_all.ngt_group_type%TYPE;
    lv_datum_theme_id      nm_themes_all.nth_theme_id%TYPE;
    --
  BEGIN
    --
    lr_group_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    /*
    ||Check Theme is non linear group
    */
    BEGIN
      --
      SELECT nat_gty_group_type
        INTO lv_group_type
        FROM nm_area_types
       WHERE nat_id = (SELECT nath_nat_id
                         FROM nm_area_themes
                        WHERE nath_nth_theme_id = lr_group_theme.nth_theme_id)
           ;
      --
    EXCEPTION
      WHEN no_data_found
       THEN
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 55
                       ,pi_supplementary_info => pi_theme_name);
    END;
    /*
    ||Check element Group Type and theme Group Type are the same.
    */
    SELECT ne_gty_group_type
      INTO lv_element_group_type
      FROM nm_elements
     WHERE ne_id = pi_element_id
         ;
    --
    IF lv_group_type <> lv_element_group_type
     THEN
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 56);
    END IF;
    /*
    ||Get Base Theme and Units for the Datum Network
    ||Type from the given Group Type.
    */
    SELECT nth_theme_id
      INTO lv_datum_theme_id
      FROM nm_themes_all
          ,nm_nw_themes
          ,nm_linear_types
          ,nm_nt_groupings_all
     WHERE nng_group_type = lv_group_type
       AND nng_nt_type = nlt_nt_type
       AND nlt_id = nnth_nlt_id
       AND nnth_nth_theme_id = nth_theme_id
       AND nth_base_table_theme IS NULL
         ;
    --
    lr_datum_theme := nm3get.get_nth(pi_nth_theme_id => lv_datum_theme_id);
    --
    OPEN po_cursor FOR 'WITH element_shapes AS(SELECT f.'||lr_datum_theme.nth_feature_shape_column||' geom'
            ||CHR(10)||'                             ,f.'||lr_datum_theme.nth_pk_column||' pkcol'
            ||CHR(10)||'                             ,e.ne_id ne_id'
            ||CHR(10)||'                             ,CASE e.ne_nt_type'
            ||CHR(10)||'                                WHEN ''ESU'' THEN e.ne_name_1'
            ||CHR(10)||'                                WHEN ''NSGN'' THEN e.ne_number'
            ||CHR(10)||'                                ELSE e.ne_unique'
            ||CHR(10)||'                              END ne_unique'
            ||CHR(10)||'                             ,nt.nt_length_unit unit_id'
            ||CHR(10)||'                             ,nu.un_unit_name   unit_name'
            ||CHR(10)||'                         FROM '||lr_datum_theme.nth_feature_table||' f '
            ||CHR(10)||'                             ,nm_units nu'
            ||CHR(10)||'                             ,nm_types nt'
            ||CHR(10)||'                             ,nm_elements e'
            ||CHR(10)||'                             ,nm_members m'
            ||CHR(10)||'                        WHERE m.nm_ne_id_in = :pi_element_id '
            ||CHR(10)||'                          AND m.nm_ne_id_of = e.ne_id'
            ||CHR(10)||'                          AND e.ne_nt_type = nt.nt_type'
            ||CHR(10)||'                          AND nt.nt_length_unit = nu.un_unit_id(+)'
            ||CHR(10)||'                          AND e.ne_id = f.'||lr_datum_theme.nth_feature_pk_column||')'
            ||CHR(10)||'SELECT a.id'
            ||CHR(10)||'      ,awlrs_util.apply_max_digits(a.x) x'
            ||CHR(10)||'      ,awlrs_util.apply_max_digits(a.y) y'
            ||CHR(10)||'      ,TO_NUMBER(nm3unit.get_formatted_value(a.z,element_shapes.unit_id)) m '
            ||CHR(10)||'      ,element_shapes.ne_id'
            ||CHR(10)||'      ,element_shapes.ne_unique'
            ||CHR(10)||'      ,element_shapes.unit_id'
            ||CHR(10)||'      ,element_shapes.unit_name'
            ||CHR(10)||'      ,:theme_name theme_name'
            ||CHR(10)||'  FROM element_shapes'
            ||CHR(10)||'      ,TABLE(sdo_util.getvertices(geom)) a'
            ||CHR(10)||' ORDER'
            ||CHR(10)||'    BY element_shapes.ne_id'
            ||CHR(10)||'      ,a.id'
    USING pi_element_id,lr_datum_theme.nth_theme_name
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
  END get_element_vertices_nlgod;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_batch_of_base_nn(pi_theme    IN NUMBER
                               ,pi_geom     IN mdsys.sdo_geometry
                               ,pi_ne_array IN nm_cnct_ne_array_type)
    RETURN ptr_array IS
    --
    lr_nth       nm_themes_all%ROWTYPE;
    lr_base_nth  nm_themes_all%ROWTYPE;
    lr_usgm      user_sdo_geom_metadata%ROWTYPE;
    --
    lt_retval ptr_array := nm3array.init_ptr_array;
    --
    lv_sql VARCHAR2(2000);
    --
    FUNCTION join_ncne(pi_pa   IN ptr_array_type
                      ,pi_ncne IN nm_cnct_ne_array_type)
      RETURN ptr_array_type IS
      --
      CURSOR c1(c_pa   IN ptr_array_type
               ,c_ncne IN nm_cnct_ne_array_type)
          IS
      SELECT ptr(a.ptr_id
                ,a.ptr_value)
        FROM TABLE(c_pa) a
            ,TABLE(c_ncne) b
       WHERE a.ptr_value = b.ne_id
       ORDER
          BY a.ptr_id
           ;
      --
      lt_retval ptr_array_type := ptr_array_type(ptr(NULL,NULL));
      --
    BEGIN
      --
      OPEN  c1(pi_pa
              ,pi_ncne);
      FETCH c1
       BULK COLLECT
       INTO lt_retval;
      CLOSE c1;
      --
      RETURN lt_retval;
      --
    END join_ncne;
    --
  BEGIN
    --
    lr_nth := nm3get.get_nth(pi_theme);
    lr_base_nth := lr_nth;
    --
    IF lr_base_nth.nth_base_table_theme IS NOT NULL
     THEN
        lr_nth := nm3get.get_nth(lr_nth.nth_base_table_theme);
    END IF;
    --
    lr_usgm := nm3sdo.get_theme_metadata(pi_theme);
    --
    lv_sql := 'SELECT ptr(rownum, ne_id)'
   ||CHR(10)||'  FROM (SELECT ft.'||lr_nth.nth_feature_pk_column||' ne_id'
   ||CHR(10)||'              ,mdsys.SDO_NN_DISTANCE(1) dist'
   ||CHR(10)||'          FROM '||lr_nth.nth_feature_table||' ft '
   ||CHR(10)||'         WHERE sdo_nn('||lr_nth.nth_feature_shape_column
   ||CHR(10)||'                     ,:p_geom'
   ||CHR(10)||'                     ,''SDO_BATCH_SIZE=10'', 1) = ''TRUE'''
   ||CHR(10)||'           AND rownum <= 50)'
   ||CHR(10)||' WHERE dist <= '||NVL(lr_nth.nth_tolerance,10)
    ;
    --
    EXECUTE IMMEDIATE lv_sql BULK COLLECT INTO lt_retval.pa USING pi_geom;
    --
    IF lt_retval.pa.LAST IS NOT NULL
     THEN
        lt_retval.pa := join_ncne(pi_pa   => lt_retval.pa
                                 ,pi_ncne => pi_ne_array );
    END IF;
    --
    RETURN lt_retval;
    --
  END get_batch_of_base_nn;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_path(pi_no_st  IN INTEGER
                   ,pi_no_end IN INTEGER)
    RETURN nm_placement_array IS
    --
    lv_link                nm_cnct_link;
    lv_st                  INTEGER;
    lv_end                 INTEGER;
    lv_current_node_index  INTEGER;
    lv_cost                NUMBER;
    lv_ne_row              INTEGER;
    lv_ne                  INTEGER;
    lv_row_id              NUMBER;
    lv_st_off              NUMBER;
    lv_end_off             NUMBER;
    lv_direction           NUMBER;
    --
    lt_no_considered  ptr_array := nm_cncts.g_cnct.nc_no_ptr;
    --
    lv_retval nm_placement_array;
    --
    FUNCTION get_min_cost_no(pi_considered_tab IN OUT NOCOPY ptr_array)
      RETURN INTEGER IS
      --
      lv_min NUMBER := nm3type.c_big_number;
      lv_id  INTEGER;
      --
    BEGIN
      --
      --nm_debug.debug('Min cost');
      --
      FOR i IN 1..nm_cncts.g_cnct.nc_no_ptr.pa.LAST LOOP
        --
        --nm_debug.debug('Check value = '||to_char(pi_considered_tab.pa(i).ptr_value)||' min = '||to_char(l_min));
        --
        IF pi_considered_tab.pa(i).ptr_value > 0
         THEN
            IF nm_cncts.g_cnct.nc_link.ncla_link(i).cost < lv_min
             THEN
                --
                --nm_debug.debug('New min = '||to_char(i));
                --
                lv_min := nm_cncts.g_cnct.nc_link.ncla_link(i).cost;
                lv_id := i;
                --
            END IF;
        END IF;
      END LOOP;
      --
      RETURN lv_id;
      --
    END get_min_cost_no;
    --
    FUNCTION get_element_between_nodes(pi_node_index_1 IN INTEGER
                                      ,pi_node_index_2 IN INTEGER)
      RETURN NUMBER IS
      --
      lv_retval     NUMBER;
      lv_node_id_1  INTEGER;
      lv_node_id_2  INTEGER;
      --
    BEGIN
      --
      lv_node_id_1 := nm_cncts.g_cnct.nc_no_ptr.pa(pi_node_index_1).ptr_value;
      lv_node_id_2 := nm_cncts.g_cnct.nc_no_ptr.pa(pi_node_index_2).ptr_value;
      --
      FOR i IN 1..nm_cncts.g_cnct.nc_ne_array.ncne_array.LAST LOOP
        --
        IF (nm_cncts.g_cnct.nc_ne_array.ncne_array(i).no_st = lv_node_id_1
            AND nm_cncts.g_cnct.nc_ne_array.ncne_array(i).no_end = lv_node_id_2)
         OR (nm_cncts.g_cnct.nc_ne_array.ncne_array(i).no_st = lv_node_id_2
             AND nm_cncts.g_cnct.nc_ne_array.ncne_array(i).no_end = lv_node_id_1)
         THEN
            --
            lv_retval := nm_cncts.g_cnct.nc_ne_array.ncne_array(i).row_id;
            EXIT;
            --
        END IF;
        --
      END LOOP;
      --
      RETURN lv_retval;
      --
    END get_element_between_nodes;
    --
  BEGIN
    --
    lv_st := nm_cncts.g_cnct.nc_no_array.no_in_array(pi_no_st);
    lv_end := nm_cncts.g_cnct.nc_no_array.no_in_array(pi_no_end);
    --
    --nm_debug.debug('Init the considered array '||to_char(l_no_considered.pa.last));
    --
    lt_no_considered.pa(lv_st).ptr_value := -1;
    --
    --nm_debug.debug('Top loop');
    --
    lv_current_node_index := get_min_cost_no(pi_considered_tab => lt_no_considered);
    --
    WHILE lv_current_node_index IS NOT NULL LOOP
      --
      lt_no_considered.pa(lv_current_node_index).ptr_value := -1;
      --
      --nm_debug.debug('Min cost id = '||to_char(lv_current_node_index));
      --
      FOR potential_next_node_index IN 1..nm_cncts.g_cnct.nc_no_ptr.pa.LAST LOOP
        --
        IF potential_next_node_index != lv_st
         AND potential_next_node_index != lv_current_node_index
         THEN
            --
            lv_ne_row := get_element_between_nodes(pi_node_index_1 => lv_current_node_index
                                                  ,pi_node_index_2 => potential_next_node_index);
            --
            --nm_debug.debug('Testing link between '||to_char(lv_current_node_index)||' and '||to_char(potential_next_node_index)||' = '||to_char(l_ne_row));
            --
            IF lv_ne_row IS NOT NULL
             THEN
                --
                --nm_debug.debug('Passed the not null test');
                --
                lv_cost := nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_ne_row).ne_length;
                --
                IF nm_cncts.g_cnct.nc_link.ncla_link(potential_next_node_index).cost IS NULL
                 OR nm_cncts.g_cnct.nc_link.ncla_link(potential_next_node_index).cost > lv_cost + nm_cncts.g_cnct.nc_link.ncla_link(lv_current_node_index).cost
                 THEN
                    /*
                    ||For an ordered path we need to know the direction of the individual elements relative to the path
                    ||so that the measures can be assigned appropriately, to work within the confines of the types
                    ||used here an element in the reverse direction is indicated with a negative id, this is picked up
                    ||and corrected later before the path is returned.
                    */
                    lv_direction := CASE WHEN nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_ne_row).no_st = lv_current_node_index THEN 1 ELSE -1 END;
                    lv_link := nm_cnct_link(lv_st
                                           ,potential_next_node_index
                                           ,lv_cost + nm_cncts.g_cnct.nc_link.ncla_link(lv_current_node_index).cost
                                           ,nm_cncts.g_cnct.nc_link.ncla_link(lv_current_node_index).path.append(int_array(int_array_type(nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_ne_row).row_id*lv_direction))));
                    --
                    nm_cncts.g_cnct.nc_link.ncla_link(potential_next_node_index) := lv_link;
                    --
                --ELSE
                --    nm_debug.debug('No link');
                END IF;
            END IF;
        END IF;
        --
      END LOOP;
      --
      lv_current_node_index := get_min_cost_no(pi_considered_tab => lt_no_considered);
      --
      --nm_debug.debug('Next for consideration is '||to_char(w));
      --
    END LOOP;
    --
    --nm_debug.debug('End of loop - end = '||to_char(l_end));
    --
    IF nm_cncts.g_cnct.nc_link.ncla_link(lv_end).cost IS NULL
     THEN
        --No path
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 70);
    ELSE
        lv_link := nm_cncts.g_cnct.nc_link.ncla_link(lv_end);
    END IF;
    --
    FOR i IN 1..lv_link.path.ia.LAST LOOP
      --
      IF lv_link.path.ia(i) < 0
       THEN
          /*
          ||Element is in reverse direction relative to the path
          ||so set the offsets appropriately and correct the ne_id.
          */
          lv_row_id := lv_link.path.ia(i) * -1;
          lv_ne := nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_row_id).ne_id;
          lv_st_off := nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_row_id).ne_length;
          lv_end_off := 0;
      ELSE
          lv_row_id := lv_link.path.ia(i);
          lv_ne := nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_row_id).ne_id;
          lv_st_off := 0;
          lv_end_off := nm_cncts.g_cnct.nc_ne_array.ncne_array(lv_row_id).ne_length;
      END IF;
      --
      IF i = 1
       THEN
          lv_retval := nm_placement_array(nm_placement_array_type(nm_placement(lv_ne,lv_st_off,lv_end_off,0)));
      ELSE
          lv_retval := lv_retval.add_element(lv_ne,lv_st_off,lv_end_off);
      END IF;
      --
    END LOOP;
    --
    --nm_debug.debug('Returning path...');
    --nm3pla.dump_placement_array(p_pl_arr => retval);
    --
    RETURN lv_retval;
    --
  END get_path;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION join_ne_array(pi_ptr  IN ptr_array
                        ,pi_ncne IN nm_cnct_ne_array_type)
    RETURN ptr_array IS
    --
    CURSOR c1(c_ptr  IN ptr_array
             ,c_ncne IN nm_cnct_ne_array_type)
        IS
    SELECT ptr(c.ptr_id,c.ptr_value)
      FROM TABLE(c_ptr.pa) c
          ,TABLE(c_ncne) b
     WHERE c.ptr_value = b.ne_id
       AND ROWNUM = 1
     ORDER
        BY c.ptr_id
         ;
    --
    lt_retval ptr_array := nm3array.init_ptr_array;
    --
  BEGIN
    --
    OPEN  c1(pi_ptr
            ,pi_ncne);
    FETCH c1
     BULK COLLECT
     INTO lt_retval.pa;
    CLOSE c1;
    --
    RETURN lt_retval;
    --
  END join_ne_array;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_nearest(pi_nth_id IN INTEGER
                      ,pi_x      IN NUMBER
                      ,pi_y      IN NUMBER)
    RETURN nm_lref IS
    --
    lt_ne  ptr_array:= nm3array.init_ptr_array;
    --
    lv_geom  mdsys.sdo_geometry;
    --
  BEGIN
    --
    lt_ne := get_batch_of_base_nn(pi_theme    => pi_nth_id
                                 ,pi_geom     => nm3sdo.get_2d_pt(pi_x,pi_y)
                                 ,pi_ne_array => nm_cncts.g_cnct.nc_ne_array.ncne_array);
    --
    IF lt_ne.pa.LAST IS NULL OR lt_ne.pa.LAST = 0
     THEN
        --
        --nm_debug.debug('Probs ne.pa.last is '||TO_CHAR(lt_ne.pa.LAST ));
        --
        --No network elements close enough to the xy co-ordinates
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 71);
    END IF;
    --
    lv_geom := nm3sdo.get_projection(p_layer => pi_nth_id
                                    ,p_ne_id => lt_ne.pa(1).ptr_value
                                    ,p_x     => pi_x
                                    ,p_y     => pi_y );
    --
    RETURN nm_lref(lt_ne.pa(1).ptr_value
                  ,nm3unit.get_formatted_value(p_value   => lv_geom.sdo_ordinates(3)
                                              ,p_unit_id => nm3net.get_nt_units_from_ne(lt_ne.pa(1).ptr_value)));
    --
  END get_nearest;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_nearest_node(pi_lref IN nm_lref)
    RETURN INTEGER IS
    --
    lv_retval INTEGER;
    --
  BEGIN
    --
    FOR i IN 1..nm_cncts.g_cnct.nc_ne_array.ncne_array.LAST LOOP
      --
      IF nm_cncts.g_cnct.nc_ne_array.ncne_array(i).ne_id = pi_lref.lr_ne_id
       THEN
          --
          lv_retval := nm_cncts.g_cnct.nc_ne_array.ncne_array(i).no_st;
          --
          IF nm_cncts.g_cnct.nc_ne_array.ncne_array(i).ne_length - pi_lref.lr_offset <  pi_lref.lr_offset
           THEN
              lv_retval := nm_cncts.g_cnct.nc_ne_array.ncne_array(i).no_end;
          END IF;
          --
          EXIT;
          --
      END IF;
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END get_nearest_node;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION add_start_element(pi_pla IN nm_placement_array
                            ,pi_pl  IN nm_placement)
    RETURN nm_placement_array IS
    --
    lv_retval  nm_placement_array;
    --
  BEGIN
    --
    lv_retval := nm_placement_array(nm_placement_array_type(pi_pl));
    --
    FOR i IN 1..pi_pla.npa_placement_array.COUNT LOOP
      --
      lv_retval.npa_placement_array.extend;
      lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST) := pi_pla.npa_placement_array(i);
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END add_start_element;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_pl_by_xy(pi_layer      IN NUMBER
                       ,pi_x1         IN NUMBER
                       ,pi_y1         IN NUMBER
                       ,pi_x2         IN NUMBER
                       ,pi_y2         IN NUMBER
                       ,pi_compl_flag IN VARCHAR2 DEFAULT 'N')
    RETURN nm_placement_array IS
    --
    lv_retval       nm_placement_array;
    lv_start        nm_lref;
    lv_end          nm_lref;
    lv_no_st        INTEGER;
    lv_no_end       INTEGER;
    lt_end_bits     nm_cnct_ne_array;
    lv_st_in_path   BOOLEAN;
    lv_end_in_path  BOOLEAN;
    --
  BEGIN
    --
    IF nm_cncts.is_cnct_instantiated = 0
     THEN
        --Network not instantiated, cannot compute the connectivity
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 72);
    END IF;
    --
    --nm_debug.debug_on;
    --nm_debug.debug('get_pl_by_xy start - first get the nearest element to xy');
    lv_start := get_nearest(pi_nth_id => pi_layer
                           ,pi_x      => pi_x1
                           ,pi_y      => pi_y1);
    --
    lv_end := get_nearest(pi_nth_id => pi_layer
                         ,pi_x      => pi_x2
                         ,pi_y      => pi_y2);
    --nm_debug.debug( 'st = '||TO_CHAR( lv_start.lr_ne_id)||' - '||TO_CHAR(lv_start.lr_offset));
    --nm_debug.debug( 'end= '||TO_CHAR( lv_end.lr_ne_id)||' - '||TO_CHAR(lv_end.lr_offset));
    --
    IF lv_start.lr_ne_id = lv_end.lr_ne_id
     THEN
        /*
        ||Start and End are on the Same Element so return a placement array between the two offsets.
        */
        --nm_debug.debug('same element so no need for walking');
		IF lv_start.lr_offset <> lv_end.lr_offset
         THEN
            RETURN nm_placement_array(nm_placement_array_type(nm_placement(lv_start.lr_ne_id
                                                                          ,lv_start.lr_offset
                                                                          ,lv_end.lr_offset
                                                                          ,0 )));
        ELSE
            --Points are the same - no distance between them
            hig.raise_ner(pi_appl               => 'AWLRS'
                         ,pi_id                 => 73);
        END IF;
    ELSE
        --nm_debug.debug('different element - need for walking');
        IF nm_cncts.g_cnct IS NULL
         THEN
            --nm_debug.debug('not instantiated, instantiate from buffer around line joining points');
            nm_cncts.make_cnct_from_line(l_theme_id => pi_layer
                                        ,p_geom     => mdsys.sdo_geometry(2002
                                                                         ,NULL
                                                                         ,NULL
                                                                         ,mdsys.sdo_elem_info_array(1,2,1)
                                                                         ,mdsys.sdo_ordinate_array(pi_x1,pi_y1,pi_x2,pi_y2))
                                        ,p_scale    => 0.2);
        END IF;
        --
        lv_no_st := get_nearest_node(lv_start);
        lv_no_end := get_nearest_node(lv_end);
        --
        --nm_debug.debug('st no = '||TO_CHAR(lv_no_st));
        --nm_debug.debug('end no= '||TO_CHAR(lv_no_end));
        --
        IF pi_compl_flag = 'Y'
         THEN
            /*
            ||Caller has asked for Complete Elements in the path.
            */
            IF NOT nm_cncts.g_cnct_complete
             THEN
                nm_cncts.instantiate_link_array;
                nm_cncts.complete_link_table;
            END IF;
            --
            --nm_debug.debug('using a completed link');
            --
            lv_retval := nm_cncts.get_path_from_complete_link(p_no_st  => lv_no_st
                                                             ,p_no_end => lv_no_end);
            --
        ELSE
            IF nm_cncts.g_cnct_complete
             THEN
                /*
                ||Global says the path should contain Complete Elements.
                */
                --nm_debug.debug('Get path between nodes '||TO_CHAR(lv_no_st)||' and '||TO_CHAR(lv_no_end));
                lv_retval := nm_cncts.get_path_from_complete_link(p_no_st  => lv_no_st
                                                                 ,p_no_end => lv_no_end);
                --
            ELSE
                IF lv_no_st != lv_no_end
                 THEN
                    /*
                    ||Path can contain Partial Elements at the Start and End.
                    */
                    --nm_debug.debug('using a single node - from '||TO_CHAR(lv_no_st)||' to '||TO_CHAR(lv_no_end));
                    nm_cncts.init_link_from_node(lv_no_st);
                    lv_retval := awlrs_sdo.get_path(pi_no_st  => lv_no_st
                                                   ,pi_no_end => lv_no_end);
                    --
                ELSE
                    /*
                    ||Start and End Nodes are the same so return an empty placement array.
                    */
                    lv_retval := nm_placement_array(nm_placement_array_type(nm_placement(NULL,NULL,NULL,NULL)));
                    --
                END IF;
            END IF;
        END IF;
        /*
        ||Now assess the fragments from the initial start/end point to the start/end node.
        */
        lv_st_in_path := (lv_retval.find_element(pl_ne_id => lv_start.lr_ne_id) > 0 );
        lv_end_in_path := (lv_retval.find_element(pl_ne_id => lv_end.lr_ne_id) > 0 );
        --
        --nm_debug.DEBUG('Find start element in path '||TO_CHAR(lv_start.lr_ne_id));
        --IF lv_st_in_path
        -- THEN
        --    nm_debug.DEBUG('Found');
        --ELSE
        --    nm_debug.DEBUG('not Found');
        --END IF;
        --nm_debug.DEBUG('Find end element in path '||TO_CHAR(lv_end.lr_ne_id ));
        --IF lv_end_in_path
        -- THEN
        --    nm_debug.DEBUG('Found');
        --ELSE
        --    nm_debug.DEBUG('not Found');
        --END IF;
        --
        lt_end_bits := nm_cncts.g_cnct.nc_ne_array.get_elements_in_array(int_array(int_array_type(lv_start.lr_ne_id,lv_end.lr_ne_id)));
        --
        --FOR i IN 1..lt_end_bits.ncne_array.LAST LOOP
        --  nm_debug.debug(TO_CHAR(lt_end_bits.ncne_array(i).row_id)
        --                 ||', '||TO_CHAR(lt_end_bits.ncne_array(i).ne_id)
        --                 ||', '||TO_CHAR(lt_end_bits.ncne_array(i).no_st)
        --                 ||', '||TO_CHAR(lt_end_bits.ncne_array(i).no_end));
        --END LOOP;
        --
        IF NOT lv_st_in_path
         THEN
            /*
            ||The starting element is not already in the path - we may need to add some.
            */
            IF lv_no_st = lt_end_bits.ncne_array(1).no_st
             THEN
                /*
                ||The start node is the start of the path so the fragment from the start node to the starting measure needs to be added.
                */
                --nm_debug.debug( 'start/start - offset (add) = '||TO_CHAR(lv_start.lr_offset));
                --
                IF lv_start.lr_offset > 0
                 THEN
                    lv_retval := add_start_element(pi_pla => lv_retval
                                                  ,pi_pl  => nm_placement(lv_start.lr_ne_id
                                                                         ,lv_start.lr_offset
                                                                         ,0
                                                                         ,0));
                END IF;
                --
            ELSIF lv_no_st = lt_end_bits.ncne_array(1).no_end
             THEN
                /*
                ||The start node is the end of the first element so the fragment from the starting measure to the end node needs to be added.
                */
                --nm_debug.debug( 'start/end - offset (add) = '||TO_CHAR(lv_start.lr_offset)||' length = '||TO_CHAR(lt_end_bits.ncne_array(1).ne_length));
                --
                IF lv_start.lr_offset < lt_end_bits.ncne_array(1).ne_length
                 THEN
                    lv_retval := add_start_element(pi_pla => lv_retval
                                                  ,pi_pl  => nm_placement(lv_start.lr_ne_id
                                                                         ,lv_start.lr_offset
                                                                         ,lt_end_bits.ncne_array(1).ne_length
                                                                         ,0));
                END IF;
                --
            END IF;
            --
        ELSE
            /*
            ||The starting element is already included in the path - we may need to subtract some.
            */
            --nm_debug.debug('Start element is in the path from: '
            --               ||lv_retval.npa_placement_array(lv_retval.npa_placement_array.FIRST).pl_start
            --               ||' to: '||lv_retval.npa_placement_array(lv_retval.npa_placement_array.FIRST).pl_end);
            --
            IF lv_no_st = lt_end_bits.ncne_array(1).no_st
             THEN
                /*
                ||The start node of the path is the start node of the first element in the path
                ||so the bit we need is from the start offset to the length of the element.
                */
                --nm_debug.debug( 'start/start - offset (minus) => Keep chunk from '||TO_CHAR(lv_start.lr_offset)||' to '||lt_end_bits.ncne_array(1).ne_length);
                --
                IF lv_start.lr_offset > 0
                 THEN
                    nm_debug.debug('Removing chunk');
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.FIRST).pl_start := lv_start.lr_offset;
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.FIRST).pl_end := lt_end_bits.ncne_array(1).ne_length;
                END IF;
                --
            ELSIF lv_no_st = lt_end_bits.ncne_array(1).no_end
             THEN
                /*
                ||The start node of the path is the end node of the first element in the path
                ||so the bit we need is from the start offset to 0.
                */
                --nm_debug.debug( 'start/end - offset (minus) => Keep chunk from '||TO_CHAR(lv_start.lr_offset)||' to 0');
                --
                IF lv_start.lr_offset < lt_end_bits.ncne_array(1).ne_length
                 THEN
                    nm_debug.debug('Removing chunk');
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.FIRST).pl_start := lv_start.lr_offset;
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.FIRST).pl_end := 0;
                END IF;
                --
            END IF;
        END IF;
        --
        IF NOT lv_end_in_path
         THEN
            /*
            ||the end element is not already in the path - we may need to add some
            */
            IF lv_no_end = lt_end_bits.ncne_array(2).no_st
             THEN
                /*
                ||The end node of the path is the start node of the missing
                ||element so add a fragment from 0 to the end offset.
                */
                --nm_debug.debug( 'end/start - offset (add) = '||TO_CHAR(lv_end.lr_offset));
                --
                IF lv_end.lr_offset > 0
                 THEN
                    lv_retval := lv_retval.add_element(pl_ne_id   => lv_end.lr_ne_id
                                                      ,pl_start   => 0
                                                      ,pl_end     => lv_end.lr_offset
                                                      ,pl_measure => 0
                                                      ,pl_mrg_mem => FALSE );
                END IF;
                --
            ELSIF lv_no_end = lt_end_bits.ncne_array(2).no_end
             THEN
                /*
                ||The end node of the path is the end node of the missing
                ||element so add a fragment from the element length to the end offset.
                */
                --nm_debug.debug( 'end/end - offset (add) = '||TO_CHAR(lv_end.lr_offset)||' length = '||TO_CHAR(lt_end_bits.ncne_array(2).ne_length));
                --
                IF lv_end.lr_offset < lt_end_bits.ncne_array(2).ne_length
                 THEN
                    lv_retval := lv_retval.add_element(pl_ne_id   => lv_end.lr_ne_id
                                                      ,pl_start   => lt_end_bits.ncne_array(2).ne_length
                                                      ,pl_end     => lv_end.lr_offset
                                                      ,pl_measure => 0
                                                      ,pl_mrg_mem => FALSE );
                END IF;
            END IF;
        ELSE
            /*
            ||The last element is already included in the path - we may need to subtract some.
            */
            --nm_debug.debug('End element is in the path from: '
            --               ||lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST).pl_start
            --               ||' to: '||lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST).pl_end);
            --
            IF lv_no_end = lt_end_bits.ncne_array(2).no_st
             THEN
                /*
                ||The end node of the path is the start node of the last element in the path
                ||so the bit we need is from the element length to the end offset.
                */
                --nm_debug.debug( 'end/start - offset (minus) => Keep chunk from: '||lt_end_bits.ncne_array(2).ne_length||' to: '||lv_end.lr_offset);
                --
                IF lv_end.lr_offset > 0
                 THEN
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST).pl_start := lt_end_bits.ncne_array(2).ne_length;
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST).pl_end := lv_end.lr_offset;
                END IF;
                --
            ELSIF lv_no_end = lt_end_bits.ncne_array(2).no_end
             THEN
                /*
                ||The end node of the path is the end node of the last element in the path
                ||so the bit we need is from the 0 to the end offset.
                */
                --nm_debug.debug( 'end/end - offset (minus) = '||TO_CHAR(lv_end.lr_offset)||' length = '||TO_CHAR(lt_end_bits.ncne_array(2).ne_length));
                --
                IF lv_end.lr_offset < lt_end_bits.ncne_array(2).ne_length
                 THEN
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST).pl_start := 0;
                    lv_retval.npa_placement_array(lv_retval.npa_placement_array.LAST).pl_end := lv_end.lr_offset;
                END IF;
                --
            END IF;
        END IF;
    END IF;
    --
    --nm_debug.debug('end of get_pl_by_xy');
    --
    RETURN lv_retval;
    --
  END get_pl_by_xy;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_datum_theme_rec(pi_nt_type IN nm_types.nt_type%TYPE)
    RETURN nm_themes_all%ROWTYPE IS
    --
    lr_retval  nm_themes_all%ROWTYPE;
    --
    CURSOR get_nth(cp_nt_type IN NM_TYPES.nt_type%TYPE)
        IS
    SELECT nth.*
      FROM nm_themes_all nth
          ,nm_nw_themes
          ,nm_linear_types
     WHERE nth_theme_id = nnth_nth_theme_id
       AND nnth_nlt_id = nlt_id
       AND nlt_g_i_d = 'D'
       AND nlt_nt_type = cp_nt_type
       AND nth_dependency = 'I'
       AND nth_base_table_theme IS NULL
         ;
    --
  BEGIN
    OPEN  get_nth(pi_nt_type);
    FETCH get_nth
     INTO lr_retval;
    CLOSE get_nth;
    --
    RETURN lr_retval;
    --
  END get_datum_theme_rec;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_datum_theme(pi_nt_type IN nm_types.nt_type%TYPE)
    RETURN nm_themes_all.nth_theme_id%TYPE IS
    --
  BEGIN
    --
    RETURN get_datum_theme_rec(pi_nt_type => pi_nt_type).nth_theme_id;
    --
  END get_datum_theme;

  --
  ---------------------------------------------------------------------------
  --
  FUNCTION get_inv_datum_themes(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN nth_tab IS
    --
    TYPE theme_id_tab IS TABLE OF nm_themes_all.nth_theme_id%TYPE;
    lt_theme_ids  theme_id_tab;
    --
    lt_nth  nth_tab;
    --
  BEGIN
    --
    SELECT awlrs_sdo.get_datum_theme(pi_nt_type => nin_nw_type)
      BULK COLLECT
      INTO lt_theme_ids
      FROM nm_inv_nw
     WHERE nin_nit_inv_code = pi_inv_type
         ;
    --
    FOR i IN 1..lt_theme_ids.COUNT LOOP
      --
      lt_nth(lt_nth.COUNT+1) := nm3get.get_nth(lt_theme_ids(i));
      --
    END LOOP;
    --
    RETURN lt_nth;
    --
  END get_inv_datum_themes;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_aggr_geom_by_pk(pi_table_name  IN VARCHAR2
                              ,pi_geom_column IN VARCHAR2
                              ,pi_pk_column   IN VARCHAR2
                              ,pi_pk_value    IN NUMBER)
    RETURN mdsys.sdo_geometry IS
    --
    lv_retval  mdsys.sdo_geometry;
    lv_mod     NUMBER;
    lv_sql     nm3type.max_varchar2;
    --
    lt_mod  nm3type.tab_number;
    --
  BEGIN
    /*
    ||Get the initial group by modulus value.
    ||This will be the next power of 2 above the number
    ||of groups of 50 geometries we are dealing with.
    */
    lv_sql :=  'SELECT POWER(2,CEIL(LOG(2,COUNT(*)/50)))'
    ||CHR(10)||'  FROM '||pi_table_name
    ||CHR(10)||' WHERE '||pi_pk_column||' = :pk_val'
    ;
    EXECUTE IMMEDIATE lv_sql INTO lv_mod USING pi_pk_value;
    /*
    ||Create an array of group by modulus values.
    */
    LOOP
      --
      lt_mod(lt_mod.count+1) := lv_mod;
      /*
      ||Get the previous power of 2.
      */
      lv_mod := lv_mod/2;
      /*
      ||Skip every other power of 2 unless we have arrived at 2.
      */
      IF lv_mod > 2
       THEN
          lv_mod := lv_mod/2;
      END IF;
      --
      IF lv_mod < 2
       THEN
          EXIT;
      END IF;
      --
    END LOOP;
    /*
    ||Build the query.
    */
    IF lt_mod.COUNT = 1
     AND lt_mod(1) <= 1
     THEN
        lv_sql :=  'SELECT sdo_aggr_union(mdsys.sdoaggrtype('||pi_geom_column||',0.5)) aggr_geom'
        ||CHR(10)||'  FROM '||pi_table_name
        ||CHR(10)||' WHERE '||pi_pk_column||' = :pk_val'
        ;
    ELSE
        lv_sql :=  'SELECT sdo_aggr_union(mdsys.sdoaggrtype('||pi_geom_column||',0.5)) aggr_geom'
        ||CHR(10)||'  FROM '||pi_table_name
        ||CHR(10)||' WHERE '||pi_pk_column||' = :pk_val'
        ||CHR(10)||' GROUP BY MOD(rownum,'||lt_mod(1)||')';
        --
        FOR i IN 2..lt_mod.COUNT LOOP
          --
          lv_sql :=  'SELECT sdo_aggr_union(mdsys.sdoaggrtype(aggr_geom,0.5)) aggr_geom'
          ||CHR(10)||'  FROM ('||lv_sql||')'
          ||CHR(10)||' GROUP BY MOD(rownum,'||lt_mod(i)||')';
          --
        END LOOP;
        --
        lv_sql :=  'SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom'
        ||CHR(10)||'  FROM ('||lv_sql||')';
        --
    END IF;
    /*
    ||Execute the query.
    */
    EXECUTE IMMEDIATE lv_sql INTO lv_retval USING pi_pk_value;
    /*
    ||Return the result.
    */
    RETURN lv_retval;
    --
  END get_aggr_geom_by_pk;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_geom_by_pk(pi_table_name  IN VARCHAR2
                         ,pi_geom_column IN VARCHAR2
                         ,pi_pk_column   IN VARCHAR2
                         ,pi_pk_value    IN NUMBER)
    RETURN mdsys.sdo_geometry IS
    --
    lv_retval  mdsys.sdo_geometry;
    lv_sql     nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||Build the query.
    */
    lv_sql :=  'SELECT '||pi_geom_column
    ||CHR(10)||'  FROM '||pi_table_name
    ||CHR(10)||' WHERE '||pi_pk_column||' = :pk_val'
    ;
    /*
    ||Execute the query.
    */
    EXECUTE IMMEDIATE lv_sql INTO lv_retval USING pi_pk_value;
    /*
    ||Return the result.
    */
    RETURN lv_retval;
    --
  EXCEPTION
    WHEN too_many_rows
     THEN
        RETURN get_aggr_geom_by_pk(pi_table_name  => pi_table_name
                                  ,pi_geom_column => pi_geom_column
                                  ,pi_pk_column   => pi_pk_column
                                  ,pi_pk_value    => pi_pk_value);
  END get_geom_by_pk;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_wkt_by_pk(pi_table_name      IN VARCHAR2
                        ,pi_geom_column     IN VARCHAR2
                        ,pi_pk_column       IN VARCHAR2
                        ,pi_pk_value        IN NUMBER
                        ,pi_include_measure IN VARCHAR2 DEFAULT 'N')
    RETURN CLOB IS
    --
  BEGIN
    /*
    ||Return the result.
    */
    RETURN sdo_geom_to(pi_geom => get_geom_by_pk(pi_table_name  => pi_table_name
                                                ,pi_geom_column => pi_geom_column
                                                ,pi_pk_column   => pi_pk_column
                                                ,pi_pk_value    => pi_pk_value)
                      ,pi_geometry_type   => c_wkt
                      ,pi_include_measure => pi_include_measure);
    --
  END get_wkt_by_pk;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_aggr_geom_by_grp(pi_table_name  IN VARCHAR2
                               ,pi_geom_column IN VARCHAR2
                               ,pi_group_id    IN VARCHAR2
                               ,pi_pk_column   IN VARCHAR2
                               ,pi_pk_value    IN NUMBER)
    RETURN mdsys.sdo_geometry IS
    --
    lv_sql     nm3type.max_varchar2;
    lv_retval  mdsys.sdo_geometry;
    --
  BEGIN
    /*
    ||Get the geometries.
    */
    lv_sql := 'SELECT sdo_aggr_lrs_concat(mdsys.sdoaggrtype(geoloc,0.005)) aggr_geom'
             ||' FROM (SELECT /*+ NO_MERGE */'
                           ||'CASE'
                            ||' WHEN nm.nm_cardinality = 1'
                             ||' THEN'
                                ||' sdo.'||LOWER(pi_geom_column)
                            ||' ELSE'
                                ||' sdo_lrs.reverse_geometry(sdo.'||LOWER(pi_geom_column)||')'
                          ||' END geoloc'
                     ||' FROM '||LOWER(pi_table_name)||' sdo,nm_members nm'
                    ||' WHERE sdo.'||LOWER(pi_pk_column)||' = :pk_val'
                      ||' AND sdo.ne_id_of = nm.nm_ne_id_of'
                      ||' AND nm.nm_ne_id_in = :grp_id'
                    ||' ORDER BY nm.nm_seq_no)';
    --
    EXECUTE IMMEDIATE lv_sql INTO lv_retval USING pi_pk_value,pi_group_id;
    /*
    ||Return the result.
    */
    RETURN lv_retval;
    --
  END get_aggr_geom_by_grp;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_features(pi_theme_name        IN  nm_themes_all.nth_theme_name%TYPE
                              ,pi_filter_wkt        IN  CLOB
                              ,pi_inc_wkt_in_cursor IN  VARCHAR2 DEFAULT 'Y'
                              ,po_message_severity  OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor    OUT sys_refcursor
                              ,po_cursor            OUT sys_refcursor)
    IS
    --
    lv_filter_geom  mdsys.sdo_geometry;
    lv_sql          nm3type.max_varchar2;
    --
    lr_theme  nm_themes_all%ROWTYPE;
    --
  BEGIN
    --
    lv_filter_geom := wkt_to_sdo_geom(pi_theme_name          => pi_theme_name
                                     ,pi_shape               => pi_filter_wkt
                                     ,pi_conv_to_theme_gtype => FALSE
                                     ,pi_rectify_polygon     => TRUE);
    --
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    --
    lv_sql :=  'SELECT id';
    --
    IF pi_inc_wkt_in_cursor = 'Y'
     THEN
        lv_sql := lv_sql
          ||CHR(10)||'      ,awlrs_sdo.get_wkt_by_pk(:feature_table'
          ||CHR(10)||'                              ,:shape_column'
          ||CHR(10)||'                              ,:pk_col'
          ||CHR(10)||'                              ,id) shape_wkt'
        ;
    END IF;
    --
    lv_sql := lv_sql
      ||CHR(10)||'  FROM (SELECT DISTINCT '||LOWER(lr_theme.nth_feature_pk_column)||' id'
      ||CHR(10)||'          FROM '||LOWER(lr_theme.nth_feature_table)
      ||CHR(10)||'         WHERE SDO_ANYINTERACT('||LOWER(lr_theme.nth_feature_shape_column)||',:filter_geom) = ''TRUE'')'
    ;
    --
    IF pi_inc_wkt_in_cursor = 'Y'
     THEN
        OPEN po_cursor FOR lv_sql
        USING lr_theme.nth_feature_table
             ,lr_theme.nth_feature_shape_column
             ,lr_theme.nth_feature_pk_column
             ,lv_filter_geom
        ;
    ELSE
        OPEN po_cursor FOR lv_sql
        USING lv_filter_geom
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
  END get_theme_features;

--
------------------------------------------------------------------------------
--
END awlrs_sdo;
/
