CREATE OR REPLACE PACKAGE BODY awlrs_sdo_offset
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdo_offset.pkb-arc   1.3   May 05 2020 17:15:20   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_sdo_offset.pkb  $
  --       Date into PVCS   : $Date:   May 05 2020 17:15:20  $
  --       Date fetched Out : $Modtime:   May 05 2020 17:13:36  $
  --       Version          : $Revision:   1.3  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.3  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_sdo_offset';
  --
  c_offset_by_xsp_context  CONSTANT VARCHAR2(30) := 'AWLRS_OFFSET_BY_XSP';
  c_offset_context         CONSTANT VARCHAR2(30) := 'AWLRS_LAYER_OFFSET';
  c_bbox_context           CONSTANT VARCHAR2(30) := 'AWLRS_BBOX';
  c_max_xsp_offset         NUMBER;
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
  PROCEDURE set_max_xsp_offset
    IS
  BEGIN
    --
    SELECT MAX(NVL(nwx_offset,0)) * 1.1
      INTO c_max_xsp_offset
      FROM nm_nw_xsp
         ;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        c_max_xsp_offset := 0;
  END set_max_xsp_offset;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION process_bbox(pi_bbox_string IN VARCHAR2
                       ,pi_offset      IN NUMBER)
    RETURN mdsys.sdo_ordinate_array IS
    --
    lv_offset  NUMBER := ABS(NVL(pi_offset,0));
    lv_retval  mdsys.sdo_ordinate_array;
    --
    lt_values  nm3type.tab_varchar32767;
    --
  BEGIN
    /*
    ||Return the given bounding box as an sdo_ordinate_array
    ||expanded by the given offset.
    */
    lt_values := awlrs_util.tokenise_string(pi_string => pi_bbox_string);
    /*
    ||TODO - Handle error conditions.
    */
    IF lt_values.COUNT = 4
     THEN
        lv_retval := mdsys.sdo_ordinate_array(TO_NUMBER(lt_values(1)) - lv_offset
                                             ,TO_NUMBER(lt_values(2)) - lv_offset
                                             ,TO_NUMBER(lt_values(3)) + lv_offset
                                             ,TO_NUMBER(lt_values(4)) + lv_offset);
    END IF;
    --
    RETURN lv_retval;
    --
  END process_bbox;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION set_context(pi_offset_by_xsp IN VARCHAR2
                      ,pi_offset        IN NUMBER
                      ,pi_bbox_string   IN VARCHAR2)
    RETURN NUMBER IS
  BEGIN
    --
    nm3ctx.set_context(c_offset_by_xsp_context,pi_offset_by_xsp);
    --
    nm3ctx.set_context(c_offset_context,pi_offset);
    --
    nm3ctx.set_context(c_bbox_context,pi_bbox_string);
    --
    RETURN 1;
    --
  END set_context;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_offset_by_xsp
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN NVL(SYS_CONTEXT('NM3SQL',c_offset_by_xsp_context),'N');
    --
  END get_offset_by_xsp;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_offset
    RETURN NUMBER IS
  BEGIN
    --
    RETURN NVL(TO_NUMBER(SYS_CONTEXT('NM3SQL',c_offset_context)),0);
    --
  END get_offset;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_bbox_string
    RETURN NUMBER IS
  BEGIN
    --
    RETURN SYS_CONTEXT('NM3SQL',c_bbox_context);
    --
  END get_bbox_string;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_bbox
    RETURN mdsys.sdo_ordinate_array IS
    --
    lv_offset  NUMBER := TO_NUMBER(SYS_CONTEXT('NM3SQL',c_offset_context));
    --
  BEGIN
    --
    IF SYS_CONTEXT ('NM3SQL', 'AWLRS_OFFSET_BY_XSP') = 'Y'
     THEN
        lv_offset := c_max_xsp_offset;
    END IF;
    --
    RETURN process_bbox(pi_bbox_string => SYS_CONTEXT('NM3SQL',c_bbox_context)
                       ,pi_offset      => lv_offset);
    --
  END get_bbox;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_offset_geom(pi_geometry    IN mdsys.sdo_geometry
                          ,pi_from_offset IN NUMBER
                          ,pi_to_offset   IN NUMBER
                          ,pi_offset      IN NUMBER)
    RETURN mdsys.sdo_geometry DETERMINISTIC IS
    --
    lv_retval mdsys.sdo_geometry;
    --
  BEGIN
    --
    IF NVL(pi_offset,0) != 0
     THEN
        IF SUBSTR(pi_geometry.sdo_gtype,3,2) IN('01','05')
         THEN
            /*
            ||Point.
            */
            lv_retval := sdo_lrs.offset_geom_segment(pi_geometry
                                                    ,pi_from_offset
                                                    ,pi_to_offset
                                                    ,pi_offset
                                                    ,awlrs_sdo.g_sdo_tolerance);
            --
        ELSIF SUBSTR(pi_geometry.sdo_gtype,3,2) IN('02','06')
         THEN
            /*
            ||Line.
            */
            lv_retval := sdo_lrs.offset_geom_segment(pi_geometry
                                                    ,pi_from_offset
                                                    ,pi_to_offset
                                                    ,pi_offset
                                                    ,awlrs_sdo.g_sdo_tolerance);
            --
            IF lv_retval IS NOT NULL
             THEN
                lv_retval := sdo_geom.sdo_arc_densify(sdo_lrs.convert_to_std_geom(lv_retval)
                                                     ,awlrs_sdo.g_sdo_tolerance
                                                     ,'arc_tolerance='||TO_CHAR(awlrs_sdo.g_sdo_arc_tolerance));
            END IF;
            --
        END IF;
    ELSE
        lv_retval := pi_geometry;
    END IF;
    --
    RETURN lv_retval;
    --
  END get_offset_geom;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_datum_shape_sql(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN VARCHAR2 IS
    --
    lt_datum_themes  awlrs_sdo.nth_tab;
    --
    lv_retval nm3type.max_varchar2;
    --
  BEGIN
    --
    lt_datum_themes := awlrs_sdo.get_inv_datum_themes(pi_inv_type => pi_inv_type);
    --
    FOR m IN 1..lt_datum_themes.COUNT LOOP
      --
      IF m > 1
       THEN
          lv_retval := lv_retval||' UNION ALL';
      END IF;
      --
      lv_retval := lv_retval||' SELECT '||LOWER(lt_datum_themes(m).nth_feature_pk_column)||' ne_id'
                                   ||','||LOWER(lt_datum_themes(m).nth_feature_shape_column)||' geom'
                                   ||' FROM '||LOWER(lt_datum_themes(m).nth_feature_table)
      ;
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END get_datum_shape_sql;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_offset_lrms
    RETURN nm_code_tbl IS
    --
    lt_values         nm3type.tab_varchar32767;
    lt_option_values  nm_code_tbl := nm_code_tbl();
    lt_retval         nm_code_tbl;
    --
  BEGIN
    /*
    ||Get a list of LRMs from the Product Option
    */
    lt_values := awlrs_util.tokenise_string(pi_string => hig.get_sysopt('AWLOFFSLRM'));
    FOR i IN 1..lt_values.COUNT LOOP
      --
      lt_option_values.EXTEND;
      lt_option_values(lt_option_values.COUNT) := lt_values(i);
      --
    END LOOP;
    /*
    ||Select the values from the Group Type table to ensure they are all Linear.
    */
    SELECT ngt_group_type
      BULK COLLECT
      INTO lt_retval
      FROM nm_group_types_all
     WHERE ngt_linear_flag = 'Y'
       AND ngt_group_type IN(SELECT column_value FROM TABLE(CAST(lt_option_values AS nm_code_tbl)))
         ;
    --
    RETURN lt_retval;
    --
  END get_offset_lrms;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_offset_views(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    IS
    --
    lr_nit         nm_inv_types_all%ROWTYPE;
    lr_theme_meta  user_sdo_geom_metadata%ROWTYPE;
    --
    lv_theme_id        nm_themes_all.nth_theme_id%TYPE;
    lv_base_view_name  VARCHAR2(30) := 'V_NM_NIT_'||pi_inv_type||'_SDO_OFF';
    lv_dt_view_name    VARCHAR2(30) := 'V_NM_NIT_'||pi_inv_type||'_SDO_DT_OFF';
    lv_view_sql        CLOB;
    lv_xsp_offset_sql  nm3type.max_varchar2;
    --
    CURSOR get_theme_id(cp_feature_table IN VARCHAR2)
        IS
    SELECT nth_theme_id
      FROM nm_themes_all
     WHERE nth_feature_table = cp_feature_table
         ;
    --
  BEGIN
    --
    lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_inv_type);
    --
    OPEN  get_theme_id('V_NM_NIT_'||pi_inv_type||'_SDO');
    FETCH get_theme_id
     INTO lv_theme_id;
    CLOSE get_theme_id;
    /*
    ||Only create the offset views if there is a theme for the base view.
    */
    IF lv_theme_id IS NOT NULL
     THEN
        --
        lr_theme_meta := nm3sdo.get_theme_metadata(p_nth_id => lv_theme_id);
        --
        IF lr_nit.nit_pnt_or_cont = 'P'
         THEN
            /*
            ||Create Point offset views.
            */
            IF lr_nit.nit_x_sect_allow_flag = 'Y'
             THEN
                --
                lv_xsp_offset_sql := CHR(10)||'         WHEN SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') = ''Y'''
                                   ||CHR(10)||'          THEN'
                                   ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(d.geom'
                                   ||CHR(10)||'                                             ,s.nm_begin_mp'
                                   ||CHR(10)||'                                             ,s.nm_end_mp'
                                   ||CHR(10)||'                                             ,(SELECT nwx_offset'
                                   ||CHR(10)||'                                                 FROM nm_nw_xsp'
                                   ||CHR(10)||'                                                     ,nm_elements'
                                   ||CHR(10)||'                                                WHERE ne_id = s.ne_id_of'
                                   ||CHR(10)||'                                                  AND ne_nt_type = nwx_nw_type'
                                   ||CHR(10)||'                                                  AND ne_sub_class = nwx_nsc_sub_class'
                                   ||CHR(10)||'                                                  AND nwx_x_sect = i.iit_x_sect'
                                   ||CHR(10)||'                                               UNION ALL'
                                   ||CHR(10)||'                                               SELECT nwx_offset * nm_cardinality'
                                   ||CHR(10)||'                                                 FROM nm_nw_xsp'
                                   ||CHR(10)||'                                                     ,nm_elements'
                                   ||CHR(10)||'                                                     ,nm_members'
                                   ||CHR(10)||'                                                WHERE nm_ne_id_of = s.ne_id_of'
                                   ||CHR(10)||'                                                  AND nm_type = ''G'''
                                   ||CHR(10)||'                                                  AND nm_ne_id_in = ne_id'
                                   ||CHR(10)||'                                                  AND ne_nt_type = nwx_nw_type'
                                   ||CHR(10)||'                                                  AND ne_sub_class = nwx_nsc_sub_class'
                                   ||CHR(10)||'                                                  AND nwx_x_sect = i.iit_x_sect))'
                ;
                --
            END IF;
            /*
            ||Create equvalent of v_nm_nit_<inv_type>_sdo.
            */
            lv_view_sql := 'CREATE OR REPLACE FORCE VIEW '||lv_base_view_name||' AS'
                ||CHR(10)||'SELECT s.objectid'
                ||CHR(10)||'      ,s.ne_id'
                ||CHR(10)||'      ,s.ne_id_of'
                ||CHR(10)||'      ,s.nm_begin_mp'
                ||CHR(10)||'      ,s.nm_end_mp'
                ||CHR(10)||'      ,CASE'
                         ||lv_xsp_offset_sql
                ||CHR(10)||'         WHEN TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0'
                ||CHR(10)||'          THEN'
                ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(d.geom'
                ||CHR(10)||'                                             ,s.nm_begin_mp'
                ||CHR(10)||'                                             ,s.nm_end_mp'
                ||CHR(10)||'                                             ,TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')))'
                ||CHR(10)||'         ELSE'
                ||CHR(10)||'             s.geoloc'
                ||CHR(10)||'       END geoloc'
                ||CHR(10)||'      ,s.start_date'
                ||CHR(10)||'      ,s.end_date'
                ||CHR(10)||'      ,s.date_created'
                ||CHR(10)||'      ,s.date_modified'
                ||CHR(10)||'      ,s.modified_by'
                ||CHR(10)||'      ,s.created_by'
                ||CHR(10)||'  FROM v_nm_'||LOWER(pi_inv_type)||' i'
                ||CHR(10)||'      ,nm_nit_'||LOWER(pi_inv_type)||'_sdo s'
                ||CHR(10)||'      ,('||get_datum_shape_sql(pi_inv_type => pi_inv_type)||') d'
                ||CHR(10)||' WHERE i.iit_ne_id = s.ne_id'
                ||CHR(10)||'   AND s.start_date <= TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND NVL(s.end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND sdo_filter(s.geoloc'
                ||CHR(10)||'                 ,mdsys.sdo_geometry(2003'
                ||CHR(10)||'                                    ,'||lr_theme_meta.srid
                ||CHR(10)||'                                    ,NULL'
                ||CHR(10)||'                                    ,mdsys.sdo_elem_info_array(1'
                ||CHR(10)||'                                                              ,1003'
                ||CHR(10)||'                                                              ,3)'
                ||CHR(10)||'                                    ,awlrs_sdo_offset.get_bbox)'
                ||CHR(10)||'                 ,''querytype=window'') = ''TRUE'''
                ||CHR(10)||'   AND s.ne_id_of = d.ne_id'
            ;
            --
            nm3ddl.create_object_and_syns(p_object_name => lv_base_view_name
                                         ,p_ddl_text    => lv_view_sql);
            /*
            ||Create equvalent of v_nm_nit_<inv_type>_sdo_dt.
            */
            lv_view_sql := 'CREATE OR REPLACE FORCE VIEW '||lv_dt_view_name||' AS'
                ||CHR(10)||'SELECT i.*'
                ||CHR(10)||'      ,s.objectid'
                ||CHR(10)||'      ,CASE'
                         ||lv_xsp_offset_sql
                ||CHR(10)||'         WHEN TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0'
                ||CHR(10)||'          THEN'
                ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(d.geom'
                ||CHR(10)||'                                             ,s.nm_begin_mp'
                ||CHR(10)||'                                             ,s.nm_end_mp'
                ||CHR(10)||'                                             ,TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')))'
                ||CHR(10)||'         ELSE'
                ||CHR(10)||'             s.geoloc'
                ||CHR(10)||'       END geoloc'
                ||CHR(10)||'  FROM v_nm_'||LOWER(pi_inv_type)||' i'
                ||CHR(10)||'      ,nm_nit_'||LOWER(pi_inv_type)||'_sdo s'
                ||CHR(10)||'      ,('||get_datum_shape_sql(pi_inv_type => pi_inv_type)||') d'
                ||CHR(10)||' WHERE i.iit_ne_id = s.ne_id'
                ||CHR(10)||'   AND s.start_date <= TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND NVL(s.end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND sdo_filter(s.geoloc'
                ||CHR(10)||'                 ,mdsys.sdo_geometry(2003'
                ||CHR(10)||'                                    ,'||lr_theme_meta.srid
                ||CHR(10)||'                                    ,NULL'
                ||CHR(10)||'                                    ,mdsys.sdo_elem_info_array(1'
                ||CHR(10)||'                                                              ,1003'
                ||CHR(10)||'                                                              ,3)'
                ||CHR(10)||'                                    ,awlrs_sdo_offset.get_bbox)'
                ||CHR(10)||'                 ,''querytype=window'') = ''TRUE'''
                ||CHR(10)||'   AND s.ne_id_of = d.ne_id'
            ;
            --
            nm3ddl.create_object_and_syns(p_object_name => lv_dt_view_name
                                         ,p_ddl_text    => lv_view_sql);
            --
        ELSE
            /*
            ||Create Line Offset Views.
            */
            IF lr_nit.nit_x_sect_allow_flag = 'Y'
             THEN
                --
                lv_xsp_offset_sql := '         WHEN SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') = ''Y'''
                ||CHR(10)||'          THEN'
                ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(s.geoloc'
                ||CHR(10)||'                                             ,sdo_lrs.geom_segment_start_measure(s.geoloc)'
                ||CHR(10)||'                                             ,sdo_lrs.geom_segment_end_measure(s.geoloc)'
                ||CHR(10)||'                                             ,(SELECT nwx_offset'
                ||CHR(10)||'                                                 FROM nm_nw_xsp'
                ||CHR(10)||'                                                     ,nm_elements'
                ||CHR(10)||'                                                WHERE ne_id = s.ne_id_of'
                ||CHR(10)||'                                                  AND ne_nt_type = nwx_nw_type'
                ||CHR(10)||'                                                  AND ne_sub_class = nwx_nsc_sub_class'
                ||CHR(10)||'                                                  AND nwx_x_sect = i.iit_x_sect'
                ||CHR(10)||'                                               UNION ALL'
                ||CHR(10)||'                                               SELECT nwx_offset'
                ||CHR(10)||'                                                 FROM nm_nw_xsp'
                ||CHR(10)||'                                                     ,nm_elements'
                ||CHR(10)||'                                                     ,nm_members'
                ||CHR(10)||'                                                WHERE nm_ne_id_in = s.ne_id_of'
                ||CHR(10)||'                                                  AND nm_ne_id_of = ne_id'
                ||CHR(10)||'                                                  AND ne_nt_type = nwx_nw_type'
                ||CHR(10)||'                                                  AND ne_sub_class = nwx_nsc_sub_class'
                ||CHR(10)||'                                                  AND nwx_x_sect = i.iit_x_sect'
                ||CHR(10)||'                                                  AND rownum = 1))' --Group can have multiple members
                ;
            END IF;
            /*
            ||Aggregated Views.
            ||
            ||Create equvalent of v_nm_nit_<inv_type>_sdo.
            ||NB This aggregates geometries by a linear group type before offsetting.
            */
            IF get_offset_lrms().COUNT > 0
             THEN
                lv_view_sql := 'CREATE OR REPLACE FORCE VIEW '||lv_base_view_name||'_AGG AS'
                    ||CHR(10)||'SELECT objectid'
                    ||CHR(10)||'      ,ne_id'
                    ||CHR(10)||'      ,ne_id_of'
                    ||CHR(10)||'      ,nm_begin_mp'
                    ||CHR(10)||'      ,nm_end_mp'
                    ||CHR(10)||'      ,geoloc'
                    ||CHR(10)||'      ,start_date'
                    ||CHR(10)||'      ,end_date'
                    ||CHR(10)||'      ,date_created'
                    ||CHR(10)||'      ,date_modified'
                    ||CHR(10)||'      ,modified_by'
                    ||CHR(10)||'      ,created_by'
                    ||CHR(10)||'  FROM v_nm_nit_'||LOWER(pi_inv_type)||'_sdo'
                    ||CHR(10)||' WHERE 1=2'
                    ||CHR(10)||'UNION ALL'
                    ||CHR(10)||'SELECT NULL objectid'
                    ||CHR(10)||'      ,s.iit_ne_id ne_id'
                    ||CHR(10)||'      ,NULL ne_id_of'
                    ||CHR(10)||'      ,NULL nm_begin_mp'
                    ||CHR(10)||'      ,NULL nm_end_mp'
                    ||CHR(10)||'      ,CASE'
                             ||lv_xsp_offset_sql
                    ||CHR(10)||'         WHEN TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0'
                    ||CHR(10)||'          THEN'
                    ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(s.geoloc'
                    ||CHR(10)||'                                             ,sdo_lrs.geom_segment_start_measure(s.geoloc)'
                    ||CHR(10)||'                                             ,sdo_lrs.geom_segment_end_measure(s.geoloc)'
                    ||CHR(10)||'                                             ,TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')))'
                    ||CHR(10)||'         ELSE'
                    ||CHR(10)||'             s.geoloc'
                    ||CHR(10)||'       END geoloc'
                    ||CHR(10)||'      ,NULL start_date'
                    ||CHR(10)||'      ,NULL end_date'
                    ||CHR(10)||'      ,NULL date_created'
                    ||CHR(10)||'      ,NULL date_modified'
                    ||CHR(10)||'      ,NULL modified_by'
                    ||CHR(10)||'      ,NULL created_by'
                    ||CHR(10)||'  FROM v_nm_'||LOWER(pi_inv_type)||' i'
                    ||CHR(10)||'      ,(SELECT sdo.ne_id iit_ne_id'
                    ||CHR(10)||'              ,gm.nm_ne_id_in ne_id_of'
                    ||CHR(10)||'              ,awlrs_sdo.get_aggr_geom_by_grp(''V_NM_NIT_'||UPPER(pi_inv_type)||'_SDO'''
                    ||CHR(10)||'                                             ,''GEOLOC'''
                    ||CHR(10)||'                                             ,gm.nm_ne_id_in'
                    ||CHR(10)||'                                             ,''NE_ID'''
                    ||CHR(10)||'                                             ,sdo.ne_id) geoloc'
                    ||CHR(10)||'          FROM v_nm_nit_'||LOWER(pi_inv_type)||'_sdo sdo'
                    ||CHR(10)||'              ,nm_members gm'
                    ||CHR(10)||'         WHERE (SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') = ''Y'''
                    ||CHR(10)||'                OR TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0)'
                    ||CHR(10)||'           AND sdo.ne_id_of = gm.nm_ne_id_of'
                    ||CHR(10)||'           AND gm.nm_obj_type IN(SELECT column_value FROM TABLE(CAST(awlrs_sdo_offset.get_offset_lrms AS nm_code_tbl)))'
                    ||CHR(10)||'           AND sdo_filter(sdo.geoloc'
                    ||CHR(10)||'                         ,mdsys.sdo_geometry(2003'
                    ||CHR(10)||'                                            ,'||lr_theme_meta.srid
                    ||CHR(10)||'                                            ,NULL'
                    ||CHR(10)||'                                            ,mdsys.sdo_elem_info_array(1'
                    ||CHR(10)||'                                                                      ,1003'
                    ||CHR(10)||'                                                                      ,3)'
                    ||CHR(10)||'                                            ,awlrs_sdo_offset.get_bbox)'
                    ||CHR(10)||'                         ,''querytype=window'') = ''TRUE'''
                    ||CHR(10)||'         GROUP'
                    ||CHR(10)||'            BY sdo.ne_id'
                    ||CHR(10)||'              ,gm.nm_ne_id_in'
                    ||CHR(10)||'        UNION ALL'
                    ||CHR(10)||'        SELECT sdo.ne_id iit_ne_id'
                    ||CHR(10)||'              ,sdo.ne_id_of'
                    ||CHR(10)||'              ,sdo.geoloc'
                    ||CHR(10)||'          FROM v_nm_nit_'||LOWER(pi_inv_type)||'_sdo sdo'
                    ||CHR(10)||'         WHERE (SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') != ''Y'''
                    ||CHR(10)||'                AND TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) = 0)'
                    ||CHR(10)||'           AND sdo_filter(sdo.geoloc'
                    ||CHR(10)||'                         ,mdsys.sdo_geometry(2003'
                    ||CHR(10)||'                                            ,'||lr_theme_meta.srid
                    ||CHR(10)||'                                            ,NULL'
                    ||CHR(10)||'                                            ,mdsys.sdo_elem_info_array(1'
                    ||CHR(10)||'                                                                      ,1003'
                    ||CHR(10)||'                                                                      ,3)'
                    ||CHR(10)||'                                            ,awlrs_sdo_offset.get_bbox)'
                    ||CHR(10)||'                         ,''querytype=window'') = ''TRUE'') s'
                    ||CHR(10)||' WHERE s.iit_ne_id = i.iit_ne_id'
                ;
                --
                nm3ddl.create_object_and_syns(p_object_name => lv_base_view_name||'_AGG'
                                             ,p_ddl_text    => lv_view_sql);
                /*
                ||Create equvalent of v_nm_nit_<inv_type>_sdo_dt.
                ||NB This aggregates geometries by a linear group type before offsetting.
                */
                lv_view_sql := 'CREATE OR REPLACE FORCE VIEW '||lv_dt_view_name||'_AGG AS'
                    ||CHR(10)||'SELECT i.*'
                    ||CHR(10)||'      ,CASE'
                             ||lv_xsp_offset_sql
                    ||CHR(10)||'         WHEN TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0'
                    ||CHR(10)||'          THEN'
                    ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(s.geoloc'
                    ||CHR(10)||'                                             ,sdo_lrs.geom_segment_start_measure(s.geoloc)'
                    ||CHR(10)||'                                             ,sdo_lrs.geom_segment_end_measure(s.geoloc)'
                    ||CHR(10)||'                                             ,TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')))'
                    ||CHR(10)||'         ELSE'
                    ||CHR(10)||'             s.geoloc'
                    ||CHR(10)||'       END geoloc'
                    ||CHR(10)||'  FROM v_nm_'||LOWER(pi_inv_type)||' i'
                    ||CHR(10)||'      ,(SELECT sdo.ne_id iit_ne_id'
                    ||CHR(10)||'              ,gm.nm_ne_id_in ne_id_of'
                    ||CHR(10)||'              ,awlrs_sdo.get_aggr_geom_by_grp(''V_NM_NIT_'||UPPER(pi_inv_type)||'_SDO'''
                    ||CHR(10)||'                                             ,''GEOLOC'''
                    ||CHR(10)||'                                             ,gm.nm_ne_id_in'
                    ||CHR(10)||'                                             ,''NE_ID'''
                    ||CHR(10)||'                                             ,sdo.ne_id) geoloc'
                    ||CHR(10)||'          FROM v_nm_nit_'||LOWER(pi_inv_type)||'_sdo sdo'
                    ||CHR(10)||'              ,nm_members gm'
                    ||CHR(10)||'         WHERE (SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') = ''Y'''
                    ||CHR(10)||'                OR TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0)'
                    ||CHR(10)||'           AND sdo.ne_id_of = gm.nm_ne_id_of'
                    ||CHR(10)||'           AND gm.nm_obj_type IN(SELECT column_value FROM TABLE(CAST(awlrs_sdo_offset.get_offset_lrms AS nm_code_tbl)))'
                    ||CHR(10)||'           AND sdo_filter(sdo.geoloc'
                    ||CHR(10)||'                         ,mdsys.sdo_geometry(2003'
                    ||CHR(10)||'                                            ,'||lr_theme_meta.srid
                    ||CHR(10)||'                                            ,NULL'
                    ||CHR(10)||'                                            ,mdsys.sdo_elem_info_array(1'
                    ||CHR(10)||'                                                                      ,1003'
                    ||CHR(10)||'                                                                      ,3)'
                    ||CHR(10)||'                                            ,awlrs_sdo_offset.get_bbox)'
                    ||CHR(10)||'                         ,''querytype=window'') = ''TRUE'''
                    ||CHR(10)||'         GROUP'
                    ||CHR(10)||'            BY sdo.ne_id'
                    ||CHR(10)||'              ,gm.nm_ne_id_in'
                    ||CHR(10)||'        UNION ALL'
                    ||CHR(10)||'        SELECT sdo.ne_id iit_ne_id'
                    ||CHR(10)||'              ,sdo.ne_id_of'
                    ||CHR(10)||'              ,sdo.geoloc'
                    ||CHR(10)||'          FROM v_nm_nit_'||LOWER(pi_inv_type)||'_sdo sdo'
                    ||CHR(10)||'         WHERE (SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') != ''Y'''
                    ||CHR(10)||'                AND TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) = 0)'
                    ||CHR(10)||'           AND sdo_filter(sdo.geoloc'
                    ||CHR(10)||'                         ,mdsys.sdo_geometry(2003'
                    ||CHR(10)||'                                            ,'||lr_theme_meta.srid
                    ||CHR(10)||'                                            ,NULL'
                    ||CHR(10)||'                                            ,mdsys.sdo_elem_info_array(1'
                    ||CHR(10)||'                                                                      ,1003'
                    ||CHR(10)||'                                                                      ,3)'
                    ||CHR(10)||'                                            ,awlrs_sdo_offset.get_bbox)'
                    ||CHR(10)||'                         ,''querytype=window'') = ''TRUE'') s'
                    ||CHR(10)||' WHERE s.iit_ne_id = i.iit_ne_id'
                ;
                --
                nm3ddl.create_object_and_syns(p_object_name => lv_dt_view_name||'_AGG'
                                             ,p_ddl_text    => lv_view_sql);
                --
            END IF;
            /*
            ||Non Aggregated Views.
            */
            IF lr_nit.nit_x_sect_allow_flag = 'Y'
             THEN
                --
                lv_xsp_offset_sql := CHR(10)||'         WHEN SYS_CONTEXT(''NM3SQL'','''||c_offset_by_xsp_context||''') = ''Y'''
                ||CHR(10)||'          THEN'
                ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(s.geoloc'
                ||CHR(10)||'                                             ,s.nm_begin_mp'
                ||CHR(10)||'                                             ,s.nm_end_mp'
                ||CHR(10)||'                                             ,(SELECT nwx_offset'
                ||CHR(10)||'                                                 FROM nm_nw_xsp'
                ||CHR(10)||'                                                     ,nm_elements'
                ||CHR(10)||'                                                WHERE ne_id = s.ne_id_of'
                ||CHR(10)||'                                                  AND ne_nt_type = nwx_nw_type'
                ||CHR(10)||'                                                  AND ne_sub_class = nwx_nsc_sub_class'
                ||CHR(10)||'                                                  AND nwx_x_sect = i.iit_x_sect'
                ||CHR(10)||'                                               UNION ALL'
                ||CHR(10)||'                                               SELECT nwx_offset * nm_cardinality nwx_offset'
                ||CHR(10)||'                                                 FROM nm_nw_xsp'
                ||CHR(10)||'                                                     ,nm_elements'
                ||CHR(10)||'                                                     ,nm_members'
                ||CHR(10)||'                                                WHERE nm_ne_id_of = s.ne_id_of'
                ||CHR(10)||'                                                  AND nm_type = ''G'''
                ||CHR(10)||'                                                  AND nm_ne_id_in = ne_id'
                ||CHR(10)||'                                                  AND ne_nt_type = nwx_nw_type'
                ||CHR(10)||'                                                  AND ne_sub_class = nwx_nsc_sub_class'
                ||CHR(10)||'                                                  AND nwx_x_sect = i.iit_x_sect))'
                ;
                --
            END IF;
            /*
            ||Create equvalent of v_nm_nit_<inv_type>_sdo.
            */
            lv_view_sql := 'CREATE OR REPLACE FORCE VIEW '||lv_base_view_name||' AS'
                ||CHR(10)||'SELECT s.objectid'
                ||CHR(10)||'      ,s.ne_id'
                ||CHR(10)||'      ,s.ne_id_of'
                ||CHR(10)||'      ,s.nm_begin_mp'
                ||CHR(10)||'      ,s.nm_end_mp'
                ||CHR(10)||'      ,CASE'
                         ||lv_xsp_offset_sql
                ||CHR(10)||'         WHEN TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0'
                ||CHR(10)||'          THEN'
                ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(s.geoloc'
                ||CHR(10)||'                                             ,s.nm_begin_mp'
                ||CHR(10)||'                                             ,s.nm_end_mp'
                ||CHR(10)||'                                             ,TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')))'
                ||CHR(10)||'         ELSE'
                ||CHR(10)||'             s.geoloc'
                ||CHR(10)||'       END geoloc'
                ||CHR(10)||'      ,s.start_date'
                ||CHR(10)||'      ,s.end_date'
                ||CHR(10)||'      ,s.date_created'
                ||CHR(10)||'      ,s.date_modified'
                ||CHR(10)||'      ,s.modified_by'
                ||CHR(10)||'      ,s.created_by'
                ||CHR(10)||'  FROM v_nm_'||LOWER(pi_inv_type)||' i'
                ||CHR(10)||'      ,nm_nit_'||LOWER(pi_inv_type)||'_sdo s'
                ||CHR(10)||' WHERE i.iit_ne_id = s.ne_id'
                ||CHR(10)||'   AND s.start_date <= TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND NVL(s.end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND sdo_filter(s.geoloc'
                ||CHR(10)||'                 ,mdsys.sdo_geometry(2003'
                ||CHR(10)||'                                    ,'||lr_theme_meta.srid
                ||CHR(10)||'                                    ,NULL'
                ||CHR(10)||'                                    ,mdsys.sdo_elem_info_array(1'
                ||CHR(10)||'                                                              ,1003'
                ||CHR(10)||'                                                              ,3)'
                ||CHR(10)||'                                    ,awlrs_sdo_offset.get_bbox)'
                ||CHR(10)||'                 ,''querytype=window'') = ''TRUE'''
            ;
            --
            nm3ddl.create_object_and_syns(p_object_name => lv_base_view_name
                                         ,p_ddl_text    => lv_view_sql);
            /*
            ||Create equvalent of v_nm_nit_<inv_type>_sdo_dt.
            */
            lv_view_sql := 'CREATE OR REPLACE FORCE VIEW '||lv_dt_view_name||' AS'
                ||CHR(10)||'SELECT i.*'
                ||CHR(10)||'      ,s.objectid'
                ||CHR(10)||'      ,CASE'
                         ||lv_xsp_offset_sql
                ||CHR(10)||'         WHEN TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')) != 0'
                ||CHR(10)||'          THEN'
                ||CHR(10)||'             awlrs_sdo_offset.get_offset_geom(s.geoloc'
                ||CHR(10)||'                                             ,s.nm_begin_mp'
                ||CHR(10)||'                                             ,s.nm_end_mp'
                ||CHR(10)||'                                             ,TO_NUMBER(SYS_CONTEXT(''NM3SQL'','''||c_offset_context||''')))'
                ||CHR(10)||'         ELSE'
                ||CHR(10)||'             s.geoloc'
                ||CHR(10)||'       END geoloc'
                ||CHR(10)||'  FROM v_nm_'||LOWER(pi_inv_type)||' i'
                ||CHR(10)||'      ,nm_nit_'||LOWER(pi_inv_type)||'_sdo s'
                ||CHR(10)||' WHERE i.iit_ne_id = s.ne_id'
                ||CHR(10)||'   AND s.start_date <= TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND NVL(s.end_date,TO_DATE(''99991231'',''YYYYMMDD'')) > TO_DATE(SYS_CONTEXT(''NM3CORE'',''EFFECTIVE_DATE''),''DD-MON-YYYY'')'
                ||CHR(10)||'   AND sdo_filter(s.geoloc'
                ||CHR(10)||'                 ,mdsys.sdo_geometry(2003'
                ||CHR(10)||'                                    ,'||lr_theme_meta.srid
                ||CHR(10)||'                                    ,NULL'
                ||CHR(10)||'                                    ,mdsys.sdo_elem_info_array(1'
                ||CHR(10)||'                                                              ,1003'
                ||CHR(10)||'                                                              ,3)'
                ||CHR(10)||'                                    ,awlrs_sdo_offset.get_bbox)'
                ||CHR(10)||'                 ,''querytype=window'') = ''TRUE'''
            ;
            --
            nm3ddl.create_object_and_syns(p_object_name => lv_dt_view_name
                                         ,p_ddl_text    => lv_view_sql);
            --
        END IF;
        --
        MERGE INTO nm_theme_offset_views d
          USING(SELECT nth_theme_id
                      ,nth_feature_table||'_OFF' view_name
                  FROM nm_themes_all
                 WHERE nth_feature_table IN('V_NM_NIT_'||pi_inv_type||'_SDO','V_NM_NIT_'||pi_inv_type||'_SDO_DT')) s
          ON(d.ntov_nth_theme_id = s.nth_theme_id )
          WHEN MATCHED
            THEN
               UPDATE SET d.ntov_offset_view_name = s.view_name
          WHEN NOT MATCHED
            THEN
               INSERT
               VALUES(s.nth_theme_id
                     ,s.view_name)
        ;
        --
        COMMIT;
        --
    END IF;
    --
  END create_offset_views;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_theme_offset_view(pi_theme_id IN nm_themes_all.nth_theme_id%TYPE)
    RETURN nm_theme_offset_views.ntov_offset_view_name%TYPE IS
    --
    lv_retval  nm_theme_offset_views.ntov_offset_view_name%TYPE;
    --
    CURSOR get_view_name(cp_theme_id IN nm_themes_all.nth_theme_id%TYPE)
        IS
    SELECT ntov_offset_view_name
      FROM nm_theme_offset_views
     WHERE ntov_nth_theme_id = cp_theme_id
         ;
    --
  BEGIN
    --
    OPEN  get_view_name(pi_theme_id);
    FETCH get_view_name
     INTO lv_retval;
    CLOSE get_view_name;
    --
    RETURN lv_retval;
    --
  END get_theme_offset_view;

--
------------------------------------------------------------------------------
--
BEGIN
  --
  set_max_xsp_offset;
  --
END awlrs_sdo_offset;
/
