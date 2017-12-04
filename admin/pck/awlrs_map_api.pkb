CREATE OR REPLACE PACKAGE BODY awlrs_map_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_map_api.pkb-arc   1.32   04 Dec 2017 16:17:02   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_map_api.pkb  $
  --       Date into PVCS   : $Date:   04 Dec 2017 16:17:02  $
  --       Date fetched Out : $Modtime:   01 Dec 2017 16:59:38  $
  --       Version          : $Revision:   1.32  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT VARCHAR2 (2000) := '$Revision:   1.32  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_map_api';
  --
  g_min_x  NUMBER;
  g_min_y  NUMBER;
  g_max_x  NUMBER;
  g_max_y  NUMBER;
  --
  g_debug  hig_option_values.hov_value%TYPE;
  --
  gt_epsg  nm3type.tab_number;
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
  FUNCTION get_marker_filename(pi_style_name IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN pi_style_name||'.gif';
    --
  END get_marker_filename;

  --
  ---------------------------------------------------------------------------
  --
  FUNCTION get_custom_tag_value(pi_theme_name IN VARCHAR2
                               ,pi_tag_name   IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_retval nm3type.max_varchar2;
    --
    CURSOR get_tag_value(cp_theme_name IN VARCHAR2
                        ,cp_tag_name IN VARCHAR2)
        IS
    SELECT tag_value
      FROM (SELECT LTRIM(RTRIM(EXTRACTVALUE(a.column_value,'/tag/name'))) tag_name
                  ,LTRIM(RTRIM(EXTRACTVALUE(a.column_value,'/tag/value'))) tag_value
              FROM user_sdo_themes themes
                  ,XMLTABLE('/styling_rules/custom_tags/tag'
                            PASSING XMLTYPE(themes.styling_rules)) a
             WHERE themes.name = cp_theme_name) custom_tags
     WHERE tag_name = cp_tag_name
         ;
  BEGIN
    --
    OPEN  get_tag_value(pi_theme_name
                       ,pi_tag_name);
    FETCH get_tag_value
     INTO lv_retval;
    CLOSE get_tag_value;
    --
    RETURN lv_retval;
    --
  EXCEPTION
   WHEN others
    THEN
       RETURN NULL;
  END get_custom_tag_value;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_theme_types(pi_theme_name IN  nm_themes_all.nth_theme_name%TYPE
                           ,po_cursor     OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT CASE
             WHEN nw_themes.network_type IS NOT NULL
              THEN
                 nw_themes.admin_type
             WHEN nith_nit_id IS NOT NULL
              THEN
                 nit_admin_type
             ELSE
                 NULL
           END admin_type
          ,nw_themes.network_type
          ,nw_themes.element_type             network_element_type
          ,nw_themes.is_linear                network_is_linear
          ,nw_themes.is_inclusion_parent_type network_is_incl_parent_type
          ,nw_themes.group_type               network_group_type
          ,nw_themes.partial_allowed          network_partial_membership
          ,nw_themes.node_type
          ,nw_themes.unit_id
          ,nith_nit_id asset_type
          ,CASE WHEN nit_table_name IS NOT NULL THEN 'Y' ELSE 'N' END ft_asset_type
          ,nit_multiple_allowed multiple_locs_allowed
          ,nit_top top_of_hierarchy
          ,(SELECT itg_relation
              FROM nm_inv_type_groupings
             WHERE itg_inv_type = nith_nit_id) hierarchy_relation
          ,nth_dependency dependent_geometry
          ,nth_location_updatable location_updatable
          ,CASE
             WHEN nw_themes.network_type IS NOT NULL
              THEN
                 (SELECT 'Y' editable
                    FROM nm_types
                   WHERE nt_type = nw_themes.network_type
                     AND EXISTS(SELECT 1
                                  FROM hig_user_roles
                                      ,nm_theme_roles
                                 WHERE nthr_theme_id = nth_theme_id
                                   AND nthr_mode = 'NORMAL'
                                   AND nthr_role = hur_role
                                   AND hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME'))
                     AND EXISTS(SELECT 1
                                  FROM nm_user_aus
                                      ,nm_admin_units
                                 WHERE nua_user_id = SYS_CONTEXT('NM3CORE','USER_ID')
                                   AND nua_mode = 'NORMAL'
                                   AND nua_admin_unit = nau_admin_unit
                                   AND nau_admin_type = nt_admin_type))
             WHEN nith_nit_id IS NOT NULL
              THEN
                 (SELECT 'Y' editable
                    FROM dual
                   WHERE nit_inv_type = nith_nit_id
                     AND nit_update_allowed = 'Y'
                     AND nit_table_name IS NULL
                     AND awlrs_util.inv_category_is_updatable(nit_category) = 'TRUE'
                     AND EXISTS(SELECT 1
                                  FROM hig_user_roles
                                      ,nm_inv_type_roles
                                 WHERE itr_inv_type = nit_inv_type
                                   AND itr_mode = 'NORMAL'
                                   AND itr_hro_role = hur_role
                                   AND hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME'))
                     AND EXISTS(SELECT 1
                                  FROM hig_user_roles
                                      ,nm_theme_roles
                                 WHERE nthr_theme_id = nth_theme_id
                                   AND nthr_mode = 'NORMAL'
                                   AND nthr_role = hur_role
                                   AND hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME'))
                     AND EXISTS(SELECT 1
                                  FROM nm_user_aus
                                      ,nm_admin_units
                                 WHERE nua_user_id = SYS_CONTEXT('NM3CORE','USER_ID')
                                   AND nua_mode = 'NORMAL'
                                   AND nua_admin_unit = nau_admin_unit
                                   AND nau_admin_type = nit_admin_type))
             ELSE
                 NULL
           END is_editable
          ,nth_feature_table     feature_table
          ,nth_feature_pk_column feature_pk_column
      FROM nm_themes_all
          ,nm_inv_themes
          ,nm_inv_types_all
          ,(SELECT nt_admin_type     admin_type
                  ,nlt_nt_type       network_type
                  ,CASE
                     WHEN nt_datum = 'Y'
                      THEN
                         'S'
                     ELSE
                         'G'
                   END               element_type
                  ,'Y'               is_linear
                  ,CASE
                     WHEN nti_nw_parent_type IS NOT NULL
                      THEN
                         'Y'
                     ELSE
                         'N'
                   END               is_inclusion_parent_type
                  ,nlt_gty_type      group_type
                  ,ngt_partial       partial_allowed
                  ,nt_node_type      node_type
                  ,nnth_nth_theme_id theme_id
                  ,un_unit_id        unit_id
              FROM nm_nw_themes
                  ,nm_linear_types
                  ,nm_types
                  ,nm_type_inclusion
                  ,nm_units
                  ,nm_group_types_all
             WHERE nnth_nlt_id = nlt_id
               AND nlt_nt_type = nt_type
               AND nt_type = nti_nw_parent_type(+)
               AND nt_length_unit = un_unit_id(+)
               AND nlt_gty_type = ngt_group_type(+)
            UNION ALL
            SELECT nt_admin_type      admin_type
                  ,nat_nt_type        network_type
                  ,CASE
                     WHEN ngt_sub_group_allowed = 'Y'
                      THEN
                         'P'
                     ELSE
                         'G'
                   END                element_type
                  ,'N'                is_linear
                  ,CASE
                     WHEN nti_nw_parent_type IS NOT NULL
                      THEN
                         'Y'
                     ELSE
                         'N'
                   END                is_inclusion_parent_type
                  ,nat_gty_group_type group_type
                  ,ngt_partial        partial_allowed
                  ,nt_node_type       node_type
                  ,nath_nth_theme_id  theme_id
                  ,un_unit_id         unit_id
              FROM nm_area_themes
                  ,nm_area_types
                  ,nm_types
                  ,nm_type_inclusion
                  ,nm_units
                  ,nm_group_types_all
             WHERE nath_nat_id = nat_id
               AND nat_nt_type = nt_type
               AND nt_type = nti_nw_parent_type(+)
               AND nt_length_unit = un_unit_id(+)
               AND nat_gty_group_type = ngt_group_type) nw_themes
     WHERE nth_theme_name = pi_theme_name
       AND nth_theme_id = nw_themes.theme_id(+)
       AND nth_theme_id = nith_nth_theme_id(+)
       AND nith_nit_id = nit_inv_type(+)
         ;
    --
  END get_theme_types;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_theme_types(pi_theme_name IN  nm_themes_all.nth_theme_name%TYPE)
    RETURN theme_types_tab IS
    --
    lt_retval  theme_types_tab;
    --
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    get_theme_types(pi_theme_name => pi_theme_name
                   ,po_cursor     => lv_cursor);
    --
    FETCH lv_cursor
     BULK COLLECT
     INTO lt_retval;
    CLOSE lv_cursor;
    --
    RETURN lt_retval;
    --
  END get_theme_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_feature_details(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                               ,pi_feature_ids      IN  nm3type.tab_number
                               ,pi_order_column     IN  VARCHAR2 DEFAULT NULL
                               ,pi_order_asc_desc   IN  VARCHAR2 DEFAULT NULL
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_theme_types  theme_types_tab;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    lr_nth  nm_themes_all%ROWTYPE;
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
    lv_tooltip_columns   nm3type.max_varchar2;
    lv_sql               nm3type.max_varchar2;
    lv_default_order_by  VARCHAR2(30);
    --
  BEGIN
    --
    lr_nth := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    --
    lv_tooltip_columns := get_custom_tag_value(pi_theme_name => pi_theme_name
                                              ,pi_tag_name   => 'TooltipColumns');
    --
    FOR i IN 1..pi_feature_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_feature_ids(i));
      --
    END LOOP;
    --
    IF lv_tooltip_columns IS NOT NULL
     THEN
        lv_sql :=  'SELECT DISTINCT('||lr_nth.nth_feature_pk_column||') id'
        ||CHR(10)||'      ,'||lv_tooltip_columns
        ||CHR(10)||'  FROM '||lr_nth.nth_feature_table
        ||CHR(10)||' WHERE '||lr_nth.nth_feature_pk_column||' IN(SELECT ne_id FROM TABLE(CAST(:id_tab AS nm_ne_id_array)))'
        ;
    ELSE
        /*
        ||No tooltip defined so return a standard cursor depending on the asset/network type.
        */
        lr_theme_types := get_theme_types(pi_theme_name => pi_theme_name);
        --
        IF lr_theme_types(1).network_type IS NOT NULL
         THEN
            lv_sql :=  'SELECT ne_id         id'
            ||CHR(10)||'      ,ne_nt_type    type'
            ||CHR(10)||'      ,CASE ne_nt_type'
            ||CHR(10)||'         WHEN ''ESU'' THEN ne_name_1'
            ||CHR(10)||'         WHEN ''NSGN'' THEN ne_number'
            ||CHR(10)||'         ELSE ne_unique'
            ||CHR(10)||'       END           name'
            ||CHR(10)||'      ,ne_descr      description'
            ||CHR(10)||'      ,DECODE(nt_linear,''Y'', NVL(nm3net.get_ne_length(ne_id),0), NULL) length'
            ||CHR(10)||'      ,un_unit_id    unit_id'
            ||CHR(10)||'      ,un_unit_name  unit_name'
            ||CHR(10)||'  FROM nm_elements_all'
            ||CHR(10)||'      ,nm_types'
            ||CHR(10)||'      ,nm_units'
            ||CHR(10)||'      ,nm_unit_domains'
            ||CHR(10)||' WHERE ud_domain_name(+) = ''LENGTH'''
            ||CHR(10)||'   AND ud_domain_id(+) = un_domain_id'
            ||CHR(10)||'   AND un_unit_id(+) = nt_length_unit'
            ||CHR(10)||'   AND nt_type = ne_nt_type'
            ||CHR(10)||'   AND ne_id IN(SELECT ne_id FROM TABLE(CAST(:id_tab AS nm_ne_id_array)))'
            ;
        ELSIF lr_theme_types(1).asset_type IS NOT NULL
         THEN
            --
            lr_nit := nm3get.get_nit(pi_nit_inv_type => lr_theme_types(1).asset_type);
            --
            IF lr_nit.nit_table_name IS NULL
             THEN
                lv_sql :=  'SELECT iit_ne_id       id'
                ||CHR(10)||'      ,iit_inv_type    type'
                ||CHR(10)||'      ,nit_descr       type_description'
                ||CHR(10)||'      ,iit_primary_key name'
                ||CHR(10)||'      ,iit_descr       description'
                ||CHR(10)||'      ,nau_unit_code   admin_unit_code'
                ||CHR(10)||'      ,nau_name        admin_unit_name'
                ||CHR(10)||'  FROM nm_admin_units_all'
                ||CHR(10)||'      ,nm_inv_types_all'
                ||CHR(10)||'      ,nm_inv_items_all'
                ||CHR(10)||' WHERE iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(:id_tab AS nm_ne_id_array)))'
                ||CHR(10)||'   AND iit_inv_type = nit_inv_type'
                ||CHR(10)||'   AND iit_admin_unit = nau_admin_unit'
                ;
            ELSE
                lv_sql :=  'SELECT '||lr_nit.nit_foreign_pk_column||' id'
                ||CHR(10)||'      ,'||nm3flx.string(lr_nit.nit_inv_type)||' type'
                ||CHR(10)||'      ,'||nm3flx.string(lr_nit.nit_descr)||' type_description'
                ||CHR(10)||'      ,'||lr_nit.nit_foreign_pk_column||' name'
                ||CHR(10)||'  FROM '||lr_nit.nit_table_name
                ||CHR(10)||' WHERE '||lr_nit.nit_foreign_pk_column||' IN (SELECT ne_id FROM TABLE(CAST(:id_tab AS nm_ne_id_array)))'
                ;
            END IF;
        ELSE
            --Layer does not represent an Asset Type or a Network Type
            hig.raise_ner(pi_appl => 'AWLRS'
                         ,pi_id   => 6);
            --
        END IF;
    END IF;
    --
    IF pi_order_column IS NOT NULL
     THEN
        OPEN po_cursor FOR 'SELECT *'
                ||CHR(10)||'  FROM ('||lv_sql||')'
                ||CHR(10)||' ORDER BY '||NVL(LOWER(pi_order_column),lv_default_order_by)||' '||NVL(LOWER(pi_order_asc_desc),'asc')
       USING lt_ids
           ;
    ELSE
        OPEN po_cursor FOR lv_sql USING lt_ids;
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
  END get_feature_details;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_usm(pi_map_name IN VARCHAR2)
    RETURN user_sdo_maps%ROWTYPE IS
    --
    lr_usm  user_sdo_maps%ROWTYPE;
    --
  BEGIN
    --
    SELECT *
      INTO lr_usm
      FROM user_sdo_maps
     WHERE name = pi_map_name
         ;
    --
    RETURN lr_usm;
    --
  EXCEPTION
   WHEN no_data_found
    THEN
       --Invalid Map name supplied
       hig.raise_ner(pi_appl               => 'AWLRS'
                    ,pi_id                 => 7
                    ,pi_supplementary_info => pi_map_name);
   WHEN others
    THEN
       RAISE;
  END get_usm;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gtype_to_layer_type(pi_gtype IN nm_theme_gtypes.ntg_gtype%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_geometry_type  VARCHAR2(2);
    lv_retval         VARCHAR2(100);
    --
  BEGIN
    --
    lv_geometry_type := SUBSTR(pi_gtype,3,2);
    --
    CASE
      WHEN lv_geometry_type IN('03','07')
       THEN
          lv_retval := 'POLYGON';
      WHEN lv_geometry_type IN('02','06')
       THEN
          lv_retval := 'LINE';
      WHEN lv_geometry_type IN('01','05')
       THEN
          lv_retval := 'POINT';
      ELSE
          --Unsuported geometry type
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 8
                       ,pi_supplementary_info => pi_gtype);
    END CASE;
    --
    RETURN lv_retval;
    --
  END gtype_to_layer_type;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_layer_type_in_clause(pi_layer_type IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_retval         VARCHAR2(200);
    --
  BEGIN
    --
    CASE pi_layer_type
      WHEN 'POLYGON'
       THEN
          lv_retval := 'IN(''2003'',''3003'',''3303'',''2007'',''3007'',''3307'')';
      WHEN 'LINE'
       THEN
          lv_retval := 'IN(''2002'',''3002'',''3302'',''2006'',''3006'',''3306'')';
      WHEN 'POINT'
       THEN
          lv_retval := 'IN(''2001'',''3001'',''3301'',''2005'',''3005'',''3305'')';
      ELSE
          --Unsuported Layer Type
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 9
                       ,pi_supplementary_info => pi_layer_type);
    END CASE;
    --
    RETURN lv_retval;
    --
  END get_layer_type_in_clause;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION gtype_to_gml_msGeometry_type(pi_gtype IN nm_theme_gtypes.ntg_gtype%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_geometry_type  VARCHAR2(2);
    lv_retval         VARCHAR2(100);
    --
  BEGIN
    --
    lv_geometry_type := SUBSTR(pi_gtype,3,2);
    --
    CASE lv_geometry_type
      WHEN '03'
       THEN
          lv_retval := 'polygon';
      WHEN '07'
       THEN
          lv_retval := 'multipolygon';
      WHEN '02'
       THEN
          lv_retval := 'line';
      WHEN '06'
       THEN
          lv_retval := 'multiline';
      WHEN '01'
       THEN
          lv_retval := 'point';
      WHEN '05'
       THEN
          lv_retval := 'multipoint';
      ELSE
          --Unsuported geometry type
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 8
                       ,pi_supplementary_info => pi_gtype);
    END CASE;
    --
    RETURN lv_retval;
    --
  END gtype_to_gml_msGeometry_type;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION alpha_to_decimal(pi_alpha IN NUMBER)
    RETURN NUMBER IS
  BEGIN
    RETURN (pi_alpha / 255);
  END alpha_to_decimal;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION alpha_to_percentage(pi_alpha IN NUMBER)
    RETURN NUMBER IS
  BEGIN
    RETURN alpha_to_decimal(pi_alpha => pi_alpha) * 100;
  END alpha_to_percentage;

  --
  ---------------------------------------------------------------------------
  --
  PROCEDURE add_map_epsg(pi_epsg IN NUMBER)
    IS
    --
    lv_found BOOLEAN := FALSE;
    --
  BEGIN
    --
    FOR i IN 1..gt_epsg.COUNT LOOP
      --
      IF gt_epsg(i) = pi_epsg
       THEN
          lv_found := TRUE;
          EXIT;
      END IF;
      --
    END LOOP;
    --
    IF NOT lv_found
     THEN
        gt_epsg(gt_epsg.COUNT+1) := pi_epsg;
    END IF;
    --
  END add_map_epsg;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_srid_and_epsg(pi_table_name      IN  VARCHAR2
                             ,pi_column_name     IN  VARCHAR2
                             ,pi_raise_not_found IN  BOOLEAN DEFAULT TRUE
                             ,po_srid            OUT NUMBER
                             ,po_epsg            OUT NUMBER)
    IS
    --
    lv_srid  NUMBER;
    lv_epsg  NUMBER;
    --
  BEGIN
    /*
    ||Try to get the SRID from the SDO metadata.
    */
    lv_srid := nm3sdo.get_table_srid(p_table_name  => pi_table_name
                                    ,p_column_name => pi_column_name);
    po_srid := lv_srid;
    /*
    ||If no SRID is set use the default from product option.
    */
    IF lv_srid IS NULL
     THEN
        lv_srid := hig.get_sysopt('AWLMAPSRID');
    END IF;
    /*
    ||Convert the SRID.
    */
    lv_epsg := sdo_cs.map_oracle_srid_to_epsg(lv_srid);
    --
    IF lv_epsg IS NULL
     AND pi_raise_not_found
     THEN
        --Unable to derive EPSG from SRID
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 12
                     ,pi_supplementary_info => lv_srid);
    END IF;
    --
    po_epsg := lv_epsg;
    --
  END get_srid_and_epsg;

  --
  ---------------------------------------------------------------------------
  --
  FUNCTION update_map_extent(pi_theme_id IN nm_themes_all.nth_theme_id%TYPE)
    RETURN VARCHAR2 IS
    --
    lr_extent  awlrs_sdo.extent_rec;
    --
  BEGIN
    --
    lr_extent := awlrs_sdo.get_theme_extent(pi_theme_id => pi_theme_id);
    --
    IF g_min_x IS NULL
     OR lr_extent.min_x < g_min_x
     THEN
        g_min_x := lr_extent.min_x;
    END IF;
    --
    IF g_min_y IS NULL
     OR lr_extent.min_y < g_min_y
     THEN
        g_min_y := lr_extent.min_y;
    END IF;
    --
    IF g_max_x IS NULL
     OR lr_extent.max_x > g_max_x
     THEN
        g_max_x := lr_extent.max_x;
    END IF;
    --
    IF g_max_y IS NULL
     OR lr_extent.max_y > g_max_y
     THEN
        g_max_y := lr_extent.max_y;
    END IF;
    --
    RETURN lr_extent.min_x||' '||lr_extent.min_y||' '||lr_extent.max_x||' '||lr_extent.max_y;
    --
  END update_map_extent;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_wms_themes(pi_definition IN CLOB)
    RETURN wms_themes_tab IS
    --
    lt_themes  wms_themes_tab;
    --
  BEGIN
    /*
    ||NB. Oracle MapBuilder stores min and max scale
    ||in reverse hence the query below flips them.
    */
    SELECT nwt_id
          ,nwt_name
          ,nwt_is_background
          ,nwt_transparency
          ,nwt_visible_on_startup
          ,description
          ,service_url
          ,auth_user
          ,auth_password
          ,layers
          ,version
          ,srs
          ,format
          ,bgcolor
          ,transparent
          ,styles
          ,exceptions
          ,capabilities_url
          ,REPLACE(UPPER(map_themes.name), ' ','') trimmed_name
          ,ROUND(DECODE(map_themes.max_scale,'-Infinity',NULL,DECODE(scale_mode, NULL, map_themes.max_scale/0.0254, map_themes.max_scale))) min_scale
          ,ROUND(DECODE(map_themes.min_scale,'Infinity' ,NULL,DECODE(scale_mode, NULL, map_themes.min_scale/0.0254, map_themes.min_scale))) max_scale
      BULK COLLECT
      INTO lt_themes
      FROM (SELECT rownum display_seq
                  ,a.name
                  ,a.min_scale
                  ,a.max_scale
                  ,a.scale_mode
              FROM XMLTABLE('/map_definition/theme'
                            PASSING XMLTYPE(pi_definition)
                            COLUMNS name      VARCHAR2(32)  path '@name'
                                   ,min_scale VARCHAR2(100) path '@min_scale'
                                   ,max_scale VARCHAR2(100) path '@max_scale'
                                   ,scale_mode VARCHAR2(100) path '@scale_mode') a) map_themes
          ,v_nm_wms_themes
     WHERE map_themes.name = nwt_name
     ORDER
        BY display_seq
         ;
    --
    RETURN lt_themes;
    --
  EXCEPTION
   WHEN no_data_found
    THEN
       RETURN lt_themes;
   WHEN others
    THEN
       RAISE;
  END get_wms_themes;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_wms_layers(pi_definition IN CLOB)
    RETURN clob_tab IS
    --
    lt_layer_text  clob_tab;
    --
    lt_wms_themes  wms_themes_tab;
    --
    lv_layer_text            CLOB;
    lv_legend_group          nm3type.max_varchar2;
    lv_displayed_on_startup  VARCHAR2(10);
    --
  BEGIN
    /*
    ||Get the themes for the map.
    */
    lt_wms_themes := get_wms_themes(pi_definition => pi_definition);
    /*
    ||Generate the layer data for each theme.
    */
    FOR i IN 1..lt_wms_themes.COUNT LOOP
      /*
      ||Get the Legend Group tag.
      */
      lv_legend_group := get_custom_tag_value(pi_theme_name => lt_wms_themes(i).nwt_name
                                             ,pi_tag_name   => 'LegendGroup');
      /*
      ||Get the DisplayedAtStartup custom tag.
      ||If it is not specified use the value from nm_wms_themes.
      */
      lv_displayed_on_startup := UPPER(NVL(get_custom_tag_value(pi_theme_name => lt_wms_themes(i).nwt_name
                                                               ,pi_tag_name   => 'DisplayedAtStartup')
                                          ,lt_wms_themes(i).nwt_visible_on_startup));
      /*
      ||Write the Layer definition.
      */
      lv_layer_text := '  LAYER'
            ||CHR(10)||'    NAME "'||lt_wms_themes(i).trimmed_name||'"'
            ||CHR(10)||'    METADATA'
            /* Metadata for the theme to be exposed by mapserver. */
            ||CHR(10)||'      "wms_title"                "'||lt_wms_themes(i).nwt_name||'"'
            ||CHR(10)||'      "wms_enable_request"       "*"'
            /* Application sepcific metadata. */
            ||CHR(10)||'      "network_is_linear"        "N"'
            ||CHR(10)||'      "network_partial_members"  "N"'
            ||CHR(10)||'      "is_editable"              "N"'
            ||CHR(10)||'      "show_in_map"              "N"'
            ||CHR(10)||'      "displayed_at_startup"     "'||lv_displayed_on_startup||'"'
            ||CHR(10)||'      "displayed_in_legend"      "Y"'
            ||CHR(10)||'      "legend_group"             "'||lv_legend_group||'"'
            /* Metadata for the WMS Theme being consumed. */
            ||CHR(10)||'      "wms_name"                 "'||lt_wms_themes(i).layers||'"'
            ||CHR(10)||'      "wms_style"                "'||lt_wms_themes(i).styles||'"'
            ||CHR(10)||'      "wms_bgcolor"              "'||lt_wms_themes(i).bgcolor||'"'
            ||CHR(10)||'      "wms_transparent"          "'||UPPER(lt_wms_themes(i).transparent)||'"'
            ||CHR(10)||'      "wms_server_version"       "'||lt_wms_themes(i).version||'"'
            ||CHR(10)||'      "wms_srs"                  "'||lt_wms_themes(i).srs||'"'
            ||CHR(10)||'      "wms_format"               "'||lt_wms_themes(i).format||'"'
            ||CHR(10)||'      "wms_exceptions_format"    "'||lt_wms_themes(i).exceptions||'"'
            ||CHR(10)||'      "wms_auth_type"            "any"'
            ||CHR(10)||'      "wms_auth_username"        "'||lt_wms_themes(i).auth_user||'"'
            ||CHR(10)||'      "wms_auth_password"        "'||lt_wms_themes(i).auth_password||'"'
            ||CHR(10)||'    END'
            ||CASE g_debug WHEN 'Y' THEN CHR(10)||'    DEBUG 5' ELSE NULL END
            ||CHR(10)||'    TYPE RASTER'
            ||CHR(10)||'    STATUS OFF'
            ||CHR(10)||'    CONNECTIONTYPE WMS'
            ||CHR(10)||'    CONNECTION "'||lt_wms_themes(i).service_url||'"'
            ||CHR(10)||'  END #layer'
            ||CHR(10)
      ;
      --
      lt_layer_text(lt_layer_text.COUNT + 1) := lv_layer_text;
      --
    END LOOP;
    --
    RETURN lt_layer_text;
    --
  END generate_wms_layers;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_themes(pi_definition IN CLOB)
    RETURN themes_tab IS
    --
    lt_themes themes_tab;
    --
  BEGIN
    /*
    ||NB. Oracle MapBuilder stores min and max scale
    ||in reverse hence the query below flips them.
    */
    SELECT nth_theme_id
          ,map_themes.name name
          ,REPLACE(UPPER(map_themes.name),' ','') trimmed_name
          ,ROUND(DECODE(map_themes.max_scale,'-Infinity',NULL,DECODE(scale_mode, NULL, map_themes.max_scale/0.0254, map_themes.max_scale))) min_scale
          ,ROUND(DECODE(map_themes.min_scale,'Infinity' ,NULL,DECODE(scale_mode, NULL, map_themes.min_scale/0.0254, map_themes.min_scale))) max_scale
          ,nth_feature_pk_column
          ,nth_feature_shape_column
          ,nth_feature_table
          ,nth_label_column
          ,ROUND(DECODE(map_themes.label_max_scale,'-Infinity',NULL,DECODE(scale_mode, NULL, map_themes.label_max_scale/0.0254, map_themes.label_max_scale))) label_min_scale
          ,ROUND(DECODE(map_themes.label_min_scale,'Infinity' ,NULL,DECODE(scale_mode, NULL, map_themes.label_min_scale/0.0254, map_themes.label_min_scale))) label_max_scale
          ,ust.styling_rules
          ,ust.geometry_column
      BULK COLLECT
      INTO lt_themes
      FROM (SELECT rownum display_seq
                  ,a.name
                  ,a.min_scale
                  ,a.max_scale
                  ,a.label_min_scale
                  ,a.label_max_scale
                  ,a.scale_mode
              FROM XMLTABLE('/map_definition/theme'
                            PASSING XMLTYPE(pi_definition)
                            COLUMNS name             VARCHAR2(32)  path '@name'
                                   ,min_scale        VARCHAR2(100) path '@min_scale'
                                   ,max_scale        VARCHAR2(100) path '@max_scale'
                                   ,label_min_scale  VARCHAR2(100) path '@label_min_scale'
                                   ,label_max_scale  VARCHAR2(100) path '@label_max_scale'
                                   ,scale_mode       VARCHAR2(100) path '@scale_mode') a) map_themes
          ,user_sdo_themes ust
          ,nm_themes_all nth
     WHERE map_themes.name = ust.name
       AND ust.name = nth.nth_theme_name
       AND EXISTS(SELECT 1
                    FROM hig_user_roles
                        ,nm_theme_roles
                   WHERE nthr_theme_id = nth.nth_theme_id
                     AND nthr_role = hur_role
                     AND hur_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME'))
     ORDER
        BY display_seq
         ;
    --
    RETURN lt_themes;
    --
  EXCEPTION
   WHEN no_data_found
    THEN
       RETURN lt_themes;
   WHEN others
    THEN
       RAISE;
  END get_themes;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_node_layer(pi_node_type IN nm_node_types.nnt_type%TYPE
                         ,pi_themes    IN themes_tab)
    RETURN nm_themes_all.nth_theme_name%TYPE IS
    --
    lv_retval nm_themes_all.nth_theme_name%TYPE;
    --
  BEGIN
    --
    FOR i IN 1..pi_themes.COUNT LOOP
      --
      IF pi_themes(i).nth_feature_table = 'V_NM_NO_'||pi_node_type||'_SDO'
       THEN
          lv_retval := pi_themes(i).trimmed_name;
          EXIT;
      END IF;
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END get_node_layer;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION is_node_layer(pi_feature_table IN nm_themes_all.nth_feature_table%TYPE)
    RETURN BOOLEAN IS
  BEGIN
    --
    RETURN (pi_feature_table LIKE 'V_NM_NO_%_SDO');
    --
  END is_node_layer;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_group_member_types(pi_ne_type    IN nm_elements_all.ne_type%TYPE
                                 ,pi_group_type IN nm_group_types_all.ngt_group_type%TYPE)
    RETURN VARCHAR2 IS
    --
    lt_types  nm3type.tab_varchar30;
    lv_retval  nm3type.max_varchar2;
    --
    CURSOR get_nt_types(cp_group_type  nm_group_types_all.ngt_group_type%TYPE)
        IS
    SELECT nng_nt_type
      FROM nm_nt_groupings
     WHERE nng_group_type = cp_group_type
         ;
    --
    CURSOR get_group_types(cp_group_type  nm_group_types_all.ngt_group_type%TYPE)
        IS
    SELECT ngr_child_group_type
      FROM nm_group_relations
     WHERE ngr_parent_group_type = cp_group_type
         ;
    --
  BEGIN
    --
    IF pi_ne_type = 'G'
     THEN
        OPEN  get_nt_types(pi_group_type);
        FETCH get_nt_types
         BULK COLLECT
         INTO lt_types;
        CLOSE get_nt_types;
    ELSIF pi_ne_type = 'P'
     THEN
        OPEN  get_group_types(pi_group_type);
        FETCH get_group_types
         BULK COLLECT
         INTO lt_types;
        CLOSE get_group_types;
    END IF;
    --
    FOR i IN 1..lt_types.COUNT LOOP
      --
      lv_retval := lv_retval||CASE WHEN i > 1 THEN ',' ELSE NULL END||lt_types(i);
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END get_group_member_types;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_child_inv_types(pi_inv_type    IN nm_inv_items_all.iit_inv_type%TYPE)
    RETURN VARCHAR2 IS
    --
    lt_types  nm3type.tab_varchar30;
    lv_retval  nm3type.max_varchar2;
    --
    CURSOR get_child_inv_types
        IS
    SELECT nit_inv_type
      FROM nm_inv_types
     WHERE nit_table_name IS NULL
       AND nit_update_allowed = 'Y'
       AND EXISTS (SELECT 1
                     FROM hig_user_roles ur
                         ,nm_inv_type_roles ir
                         ,nm_user_aus usr
                         ,nm_admin_units au
                         ,nm_admin_groups nag
                         ,hig_users hus
                    WHERE hus.hus_username = SYS_CONTEXT('NM3_SECURITY_CTX','USERNAME')
                      AND ur.hur_role = ir.itr_hro_role
                      AND ur.hur_username = hus.hus_username
                      AND ir.itr_inv_type = nit_inv_type
                      AND usr.nua_admin_unit = au.nau_admin_unit
                      AND au.nau_admin_unit = nag_child_admin_unit
                      AND au.nau_admin_type = nit_admin_type
                      AND usr.nua_admin_unit = nag_parent_admin_unit
                      AND usr.nua_user_id = hus.hus_user_id)
       AND nit_inv_type IN (SELECT itg_inv_type
                              FROM nm_inv_type_groupings
                             WHERE itg_parent_inv_type = pi_inv_type
                               AND itg_inv_type != pi_inv_type)
     ORDER BY nit_inv_type
         ;

    --
  BEGIN
    --
    OPEN  get_child_inv_types;
    FETCH get_child_inv_types
     BULK COLLECT
     INTO lt_types;
    CLOSE get_child_inv_types;
    --
    FOR i IN 1..lt_types.COUNT LOOP
      --
      lv_retval := lv_retval||CASE WHEN i > 1 THEN ',' ELSE NULL END||lt_types(i);
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END get_child_inv_types;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_asset_loc_types(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN VARCHAR2 IS
    --
    TYPE type_rec IS RECORD(nt_type   nm_types.nt_type%TYPE
                           ,nt_datum  nm_types.nt_datum%TYPE);
    TYPE type_tab IS TABLE OF type_rec;
    lt_types  type_tab;
    --
    lv_type    nm_types.nt_type%TYPE;
    lv_retval  nm3type.max_varchar2;
    --
    CURSOR get_nw_types(cp_inv_type nm_inv_types_all.nit_inv_type%TYPE)
        IS
    SELECT nin_nw_type
          ,nt_datum
      FROM nm_inv_nw_all
          ,nm_types
     WHERE nin_nit_inv_code = cp_inv_type
       AND nin_nw_type = nt_type
         ;
    --
  BEGIN
    --
    IF pi_inv_type IS NOT NULL
     THEN
        OPEN  get_nw_types(pi_inv_type);
        FETCH get_nw_types
         BULK COLLECT
         INTO lt_types;
        CLOSE get_nw_types;
        --
        FOR i IN 1..lt_types.COUNT LOOP
          --
          DECLARE
            /*
            ||nm3net.get_datum_nt may raise an exception if the
            ||given group type has no underlying datum type
            ||for this purpose we don't want to raise it.
            */
            no_datum_type EXCEPTION;
            PRAGMA EXCEPTION_INIT(no_datum_type, -20030);
            --
          BEGIN
            --
            IF lt_types(i).nt_datum = 'Y'
             THEN
                lv_type := lt_types(i).nt_type;
            ELSE
                lv_type := nm3net.get_datum_nt(pi_gty => lt_types(i).nt_type);
            END IF;
            --
            IF (lv_retval IS NULL
                OR INSTR(lv_retval,lv_type) = 0)
             AND lv_type IS NOT NULL
             THEN
                lv_retval := lv_retval||CASE WHEN lv_retval IS NULL THEN NULL ELSE ',' END||lv_type;
            END IF;
            --
          EXCEPTION
            WHEN no_datum_type
             THEN
                NULL;
          END;
        END LOOP;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END get_asset_loc_types;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_theme_rules(pi_xml IN XMLTYPE)
    RETURN xml_tab IS
    --
    lt_retval  xml_tab;
    --
  BEGIN
    /*
    ||NB. we only support the use of one rule for a theme at the moment.
    */
    SELECT *
      BULK COLLECT
      INTO lt_retval
      FROM XMLTABLE('/styling_rules/rule' PASSING pi_xml) rules
     WHERE rownum = 1
         ;
    --
    RETURN lt_retval;
    --
  EXCEPTION
   WHEN no_data_found
    THEN
       RETURN lt_retval;
   WHEN others
    THEN
       RAISE;
  END get_theme_rules;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_style_value(pi_style IN VARCHAR2
                          ,pi_field IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_pos  NUMBER;
    lv_str  nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_pos := INSTR(pi_style,pi_field);
    --
    IF lv_pos > 0
     THEN
        --
        lv_str := SUBSTR(pi_style, lv_pos + LENGTH(pi_field));
        --
        IF INSTR(lv_str,';') = 0
         THEN
            lv_str := SUBSTR(lv_str, 1, LENGTH(lv_str));
        ELSE
            lv_str := SUBSTR(lv_str, 1, INSTR(lv_str,';') - 1);
        END IF;
        --
    END IF;
    --
    RETURN lv_str;
    --
  END get_style_value;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_default_style(pi_geom_column  IN VARCHAR2
                            ,pi_layer_type   IN VARCHAR2
                            ,pi_style        IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_fill            nm3type.max_varchar2;
    lv_stroke          nm3type.max_varchar2;
    lv_stroke_width    nm3type.max_varchar2;
    lv_default_colour  VARCHAR2(7) := '#FF0000';
    --
    lv_retval nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_fill := get_style_value(pi_style => pi_style
                              ,pi_field => 'fill:');
    --
    lv_stroke := get_style_value(pi_style => pi_style
                                ,pi_field => 'stroke:');
    --
    lv_stroke_width := NVL(get_style_value(pi_style => pi_style
                                          ,pi_field => 'stroke-width:'),'3.0');
    --
    CASE pi_layer_type
      WHEN 'POINT'
       THEN
          lv_retval := '      STYLE'
            ||CHR(10)||'        COLOR "'||NVL(NVL(lv_fill,lv_stroke),lv_default_colour)||'"'
            ||CHR(10)||'        OUTLINECOLOR "'||NVL(NVL(lv_stroke,lv_fill),lv_default_colour)||'"'
            ||CHR(10)||'        OUTLINEWIDTH '||lv_stroke_width
            ||CHR(10)||'        SIZE '||lv_stroke_width
            ||CHR(10)||'        SYMBOL "circle_filled"'
            ||CHR(10)||'      END #STYLE'
          ;
      WHEN 'POLYGON'
       THEN
          lv_retval := '      STYLE'
            ||CHR(10)||'        COLOR "'||NVL(NVL(lv_fill,lv_stroke),lv_default_colour)||'"'
            ||CHR(10)||'        OUTLINECOLOR "'||NVL(NVL(lv_stroke,lv_fill),lv_default_colour)||'"'
            ||CHR(10)||'        OUTLINEWIDTH '||lv_stroke_width
            ||CHR(10)||'      END #STYLE'
          ;
      WHEN 'LINE'
       THEN
          lv_retval := '      STYLE'
            ||CHR(10)||'        COLOR "'||NVL(NVL(lv_stroke,lv_fill),lv_default_colour)||'"'
            ||CHR(10)||'        WIDTH '||lv_stroke_width
            ||CHR(10)||'      END #STYLE'
          ;
      ELSE
          --Unsuported Layer Type
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 9
                       ,pi_supplementary_info => pi_layer_type||' provided to function get_default_style');
    END CASE;
    --
    RETURN lv_retval;
    --
  END get_default_style;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_line_style(pi_class         IN VARCHAR2
                         ,pi_style         IN VARCHAR2
                         ,pi_dash          IN VARCHAR2
                         ,pi_base_linecap  IN VARCHAR2 DEFAULT NULL
                         ,pi_base_linejoin IN VARCHAR2 DEFAULT NULL
                         ,pi_base_width    IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS
    --
    lv_fill             nm3type.max_varchar2;
    lv_fill_opacity     nm3type.max_varchar2;
    lv_stroke_width     nm3type.max_varchar2;
    lv_stroke_linecap   nm3type.max_varchar2;
    lv_stroke_linejoin  nm3type.max_varchar2;
    --
    lv_retval nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||Get data from the style attribute.
    ||NB. Mapserver does not support End Caps or Hatched\Fenced lines
    ||so this information, where present, is ignored.
    */
    lv_fill := get_style_value(pi_style => pi_style
                              ,pi_field => 'fill:');
    --
    lv_stroke_width := get_style_value(pi_style => pi_style
                                      ,pi_field => 'stroke-width:');
    --
    lv_stroke_linecap := NVL(pi_base_linecap,get_style_value(pi_style => pi_style
                                                            ,pi_field => 'stroke-linecap:'));
    --
    lv_stroke_linejoin := NVL(pi_base_linejoin,get_style_value(pi_style => pi_style
                                                              ,pi_field => 'stroke-linejoin:'));
    /*
    ||If dealing with a Wing Line recalculate the width.
    */
    IF pi_base_width IS NOT NULL
     AND pi_class = 'parallel'
     THEN
        lv_stroke_width := pi_base_width + (lv_stroke_width * 2);
        --
        lv_retval := '      STYLE'
          ||CHR(10)||'        COLOR "'||lv_fill||'"'
          ||CHR(10)||'        WIDTH '||lv_stroke_width
          ||CHR(10)||'        LINECAP '||NVL(lv_stroke_linecap,'ROUND')
          ||CHR(10)||'        LINEJOIN '||NVL(lv_stroke_linejoin,'ROUND')
          ||CHR(10)||'      END #STYLE'
        ;
        /*
        ||The following does not work with mapserver 6.4.1 but would work
        ||once we upgrade to 7.0.4
        */
        --lv_retval := '      STYLE'
        --  ||CHR(10)||'        OUTLINECOLOR "'||lv_fill||'"'
        --  ||CHR(10)||'        WIDTH '||(lv_stroke_width * 2)
        --  ||CHR(10)||'        GEOMTRANSFORM (buffer([shape],'||((pi_base_width/2)+1)||'))'
        --  ||CHR(10)||'      END #STYLE'
        --;
    ELSE
        --
        lv_fill_opacity := get_style_value(pi_style => pi_style
                                          ,pi_field => 'fill-opacity:');
        --
        lv_retval := '      STYLE'
          ||CHR(10)||'        COLOR "'||lv_fill||'"'
          ||CHR(10)||'        WIDTH '||NVL(lv_stroke_width,'1.0')
          ||CHR(10)||'        LINECAP '||NVL(lv_stroke_linecap,'ROUND')
          ||CHR(10)||'        LINEJOIN '||NVL(lv_stroke_linejoin,'ROUND')
        ;
        IF lv_fill_opacity IS NOT NULL
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        OPACITY '||alpha_to_decimal(TO_NUMBER(lv_fill_opacity))
            ;
        END IF;
        --
        IF pi_dash IS NOT NULL
         THEN
            IF pi_class = 'hashmark'
             THEN
                lv_retval := lv_retval
                  ||CHR(10)||'        SYMBOL "vert_line"'
                  ||CHR(10)||'        SIZE '||(TO_NUMBER(SUBSTR(pi_dash,INSTR(pi_dash,',')+1,LENGTH(pi_dash))) * 2)
                  ||CHR(10)||'         GAP -'||SUBSTR(pi_dash,1,INSTR(pi_dash,',')-1)
                ;
            ELSE
                lv_retval := lv_retval
                  ||CHR(10)||'        PATTERN'
                  ||CHR(10)||'         '||REPLACE(pi_dash,',',' ')
                  ||CHR(10)||'        END #PATTERN'
                ;
            END IF;
        END IF;
        --
        lv_retval := lv_retval
          ||CHR(10)||'      END #STYLE'
        ;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END get_line_style;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_marker_style(pi_style_name IN VARCHAR2
                           ,pi_style_def  IN XMLTYPE
                           ,pi_style      IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_retval               nm3type.max_varchar2;
    lv_marker_fill          nm3type.max_varchar2;
    lv_marker_stroke        nm3type.max_varchar2;
    lv_marker_stroke_width  nm3type.max_varchar2;
    lv_marker_width         nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_marker_fill := get_style_value(pi_style => pi_style
                                     ,pi_field => ';fill:');
    lv_marker_stroke := get_style_value(pi_style => pi_style
                                       ,pi_field => 'stroke:');
    lv_marker_stroke_width := get_style_value(pi_style => pi_style
                                             ,pi_field => 'stroke-width:');
    --
    lv_retval := '      STYLE';
    --
    IF pi_style_def.existsnode('/svg/g/image') = 1
     THEN
        --
        lv_retval := lv_retval
          ||CHR(10)||'        SYMBOL "%fileprefix%'||get_marker_filename(pi_style_name => pi_style_name)||'"'
        ;
        --
        lv_marker_width := get_style_value(pi_style => pi_style
                                          ,pi_field => 'width:');
        --
    ELSE
        --
        IF lv_marker_fill IS NOT NULL
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        COLOR "'||lv_marker_fill||'"'
            ;
        END IF;
        --
        IF lv_marker_stroke IS NOT NULL
         THEN
            /*
            ||Note. WIDTH is used here rather than OUTLINEWIDTH as mapserver seems to draw
            ||an addition outline in the fill colour if OUTLINEWIDTH is used.
            */
            lv_retval := lv_retval
              ||CHR(10)||'        OUTLINECOLOR "'||lv_marker_stroke||'"'
              ||CHR(10)||'        WIDTH '||NVL(lv_marker_stroke_width,'1.0')
            ;
        END IF;
        --
        IF pi_style_def.existsnode('/svg/g/circle') = 1
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        SYMBOL "circle_filled"'
            ;
        ELSIF pi_style_def.existsnode('/svg/g/rect') = 1
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        SYMBOL "square_filled"'
            ;
        ELSIF pi_style_def.existsnode('/svg/g/polyline') = 1
         OR pi_style_def.existsnode('/svg/g/polygon') = 1
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        SYMBOL "'||pi_style_name||'"'
            ;
        END IF;
        --
        lv_marker_width := get_style_value(pi_style => pi_style
                                          ,pi_field => ';width:');
        --
    END IF;
    --
    IF lv_marker_width IS NOT NULL
     THEN
        lv_retval := lv_retval
          ||CHR(10)||'        SIZE '||lv_marker_width
        ;
    END IF;
    --
    lv_retval := lv_retval
          ||CHR(10)||'      END #STYLE'
    ;
    --
    RETURN lv_retval;
    --
  END get_marker_style;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_line_marker_style(pi_style IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_marker_name          nm3type.max_varchar2;
    lv_marker_pos           nm3type.max_varchar2;
    lv_marker_fill          nm3type.max_varchar2;
    lv_marker_stroke        nm3type.max_varchar2;
    lv_marker_stroke_width  nm3type.max_varchar2;
    lv_marker_size          nm3type.max_varchar2;
    lv_multi_marker         nm3type.max_varchar2;
    --
    lv_marker_style_def  XMLTYPE;
    --
    lv_retval nm3type.max_varchar2;
    --
    CURSOR get_uss(cp_style_name IN VARCHAR2)
        IS
    SELECT definition
      FROM user_sdo_styles
     WHERE name = cp_style_name
         ;
    --
    lr_marker_uss       get_uss%ROWTYPE;
    --
    CURSOR get_svg_data(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(cp_xml,'/svg/g/@style') g_style
      FROM dual
         ;
    --
    lr_marker_svg_data  get_svg_data%ROWTYPE;
    --
  BEGIN
    /*
    ||Get data from the style attribute.
    ||NB. Mapserver does not support End Caps or Hatched\Fenced lines
    ||so this information, where present, is ignored.
    */
    lv_marker_name := get_style_value(pi_style => pi_style
                                     ,pi_field => 'marker-name:');
    IF lv_marker_name IS NOT NULL
     THEN
        --
        OPEN  get_uss(lv_marker_name);
        FETCH get_uss
         INTO lr_marker_uss;
        CLOSE get_uss;
        --
        lv_marker_style_def := XMLTYPE(lr_marker_uss.definition);
        --
        OPEN  get_svg_data(lv_marker_style_def);
        FETCH get_svg_data
         INTO lr_marker_svg_data;
        CLOSE get_svg_data;
        --
        lv_marker_fill := get_style_value(pi_style => lr_marker_svg_data.g_style
                                         ,pi_field => 'fill:');
        --
        lv_marker_stroke := get_style_value(pi_style => lr_marker_svg_data.g_style
                                           ,pi_field => 'stroke:');
        --
        lv_marker_stroke_width := get_style_value(pi_style => lr_marker_svg_data.g_style
                                                 ,pi_field => 'stroke-width:');
        --
        lv_marker_pos := get_style_value(pi_style => pi_style
                                        ,pi_field => 'marker-position:');
        --
        lv_marker_size := get_style_value(pi_style => pi_style
                                         ,pi_field => 'marker-size:');
        --
        lv_multi_marker := get_style_value(pi_style => pi_style
                                          ,pi_field => 'multiple-marker:');
        --
        lv_retval := '      STYLE'
          ||CHR(10)||'        ANGLE AUTO'
          ||CHR(10)||'        SIZE '||lv_marker_size
        ;
        IF lv_marker_pos = 'all_points'
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        GEOMTRANSFORM "vertices"'
            ;
        ELSIF lv_marker_pos = 'end_points'
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        GEOMTRANSFORM "start"'
            ;
        ELSIF lv_multi_marker IS NOT NULL
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        GAP -'||(lv_marker_size*10)
              ||CHR(10)||'        INITIALGAP '||(lv_marker_size+1)
            ;                     
        ELSE
            lv_retval := lv_retval
              ||CHR(10)||'        GEOMTRANSFORM "labelpnt"'
            ;          
        END IF;
        --
        IF lv_marker_style_def.existsnode('/svg/g/image') = 1
         THEN
            lv_retval := lv_retval
              ||CHR(10)||'        COLOR 0 0 0'
              ||CHR(10)||'        SYMBOL "%fileprefix%'||get_marker_filename(pi_style_name => lv_marker_name)||'"'
            ;
        ELSE
            IF lv_marker_fill IS NOT NULL
             THEN
                lv_retval := lv_retval
                  ||CHR(10)||'        COLOR "'||lv_marker_fill||'"'
                ;
            END IF;
            --
            IF lv_marker_stroke IS NOT NULL
             THEN
                /*
                ||Note. WIDTH is used here rather than OUTLINEWIDTH as mapserver seems to draw
                ||an addition outline in the fill colour if OUTLINEWIDTH is used.
                */
                lv_retval := lv_retval
                  ||CHR(10)||'        OUTLINECOLOR "'||lv_marker_stroke||'"'
                  ||CHR(10)||'        WIDTH '||NVL(lv_marker_stroke_width,'1.0')
                ;
            END IF;
            --
            IF lv_marker_style_def.existsnode('/svg/g/circle') = 1
             THEN
                lv_retval := lv_retval
                  ||CHR(10)||'        SYMBOL "circle_filled"'
                ;
            ELSIF lv_marker_style_def.existsnode('/svg/g/rect') = 1
             THEN
                lv_retval := lv_retval
                  ||CHR(10)||'        SYMBOL "square_filled"'
                ;
            ELSIF lv_marker_style_def.existsnode('/svg/g/polyline') = 1
             OR lv_marker_style_def.existsnode('/svg/g/polygon') = 1
             THEN
                lv_retval := lv_retval
                  ||CHR(10)||'        SYMBOL "'||CASE lv_marker_pos
                                                   WHEN 'end_points'
                                                    THEN
                                                       lv_marker_name||'_START'
                                                   ELSE
                                                       lv_marker_name
                                                 END||'"'
                ;
            END IF;
            --
        END IF;
        --
        lv_retval := lv_retval
          ||CHR(10)||'      END #STYLE'
        ;
        --
        IF lv_marker_pos = 'end_points'
         THEN
            lv_retval := lv_retval||CHR(10)||REPLACE(REPLACE(lv_retval
                                                            ,'GEOMTRANSFORM "start"'
                                                            ,'GEOMTRANSFORM "end"')
                                                    ,lv_marker_name||'_START'
                                                    ,lv_marker_name||'_END');
        END IF;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END get_line_marker_style;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_label_style(pi_style_name   IN VARCHAR2
                          ,pi_text_column  IN VARCHAR2
                          ,pi_min_scale    IN VARCHAR2
                          ,pi_max_scale    IN VARCHAR2
                          ,pi_layer_type   IN VARCHAR2)
    RETURN VARCHAR2 IS
    --
    lv_retval  nm3type.max_varchar2;
    --
    lv_font_family        nm3type.max_varchar2;
    lv_font_size          nm3type.max_varchar2;
    lv_font_style         nm3type.max_varchar2;
    lv_font_weight        nm3type.max_varchar2;
    lv_font_fill          nm3type.max_varchar2;
    lv_font_fill_opacity  nm3type.max_varchar2;
    lv_sticky             nm3type.max_varchar2;
    --
    CURSOR get_uss(cp_style_name IN VARCHAR2)
        IS
    SELECT type
          ,description
          ,definition
          ,geometry
      FROM user_sdo_styles
     WHERE name = cp_style_name
         ;
    --
    lr_uss  get_uss%ROWTYPE;
    --
    CURSOR get_svg_data(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(cp_xml,'/svg/g/@class') g_class
          ,EXTRACTVALUE(cp_xml,'/svg/g/@style') g_style
          ,EXTRACTVALUE(cp_xml,'/svg/g/@float-width') g_float_width
          ,EXTRACTVALUE(cp_xml,'/svg/g/@float-color') g_float_color
          ,EXTRACTVALUE(cp_xml,'/svg/g/@float-color-opacity') g_float_color_opacity
          ,EXTRACTVALUE(cp_xml,'/svg/g/@sticky') g_sticky
      FROM dual
         ;
    --
    lr_svg_data  get_svg_data%ROWTYPE;
    --

  BEGIN
    /*
    ||Get the data from user_sdo_styles.
    */
    OPEN  get_uss(pi_style_name);
    FETCH get_uss
     INTO lr_uss;
    CLOSE get_uss;
    --
    CASE lr_uss.type
      WHEN 'TEXT'
       THEN
          --
          OPEN  get_svg_data(XMLTYPE(lr_uss.definition));
          FETCH get_svg_data
           INTO lr_svg_data;
          CLOSE get_svg_data;
          --
          lv_font_family := get_style_value(pi_style => lr_svg_data.g_style
                                           ,pi_field => 'font-family:');
          lv_font_size := get_style_value(pi_style => lr_svg_data.g_style
                                         ,pi_field => 'font-size:');
          lv_font_style := get_style_value(pi_style => lr_svg_data.g_style
                                          ,pi_field => 'font-style:');
          lv_font_weight := get_style_value(pi_style => lr_svg_data.g_style
                                           ,pi_field => 'font-weight:');
          lv_font_fill := get_style_value(pi_style => lr_svg_data.g_style
                                         ,pi_field => 'fill:');
          /*
          ||Add bold to font name if needed.
          */
          IF lv_font_weight IS NOT NULL
           THEN
              lv_font_family := lv_font_family||'-'||lv_font_weight;
          END IF;
          /*
          ||Add italic to font name if needed.
          */
          IF lv_font_style IS NOT NULL
           AND lv_font_style != 'plain'
           THEN
              lv_font_family := lv_font_family||'-'||lv_font_style;
          END IF;
          /*
          ||MapServer LABEL does not have a setting for Opacity.
          */
          --lv_font_fill_opacity := get_style_value(pi_style => lr_svg_data.g_style
          --                                       ,pi_field => 'fill-opacity:');
          --
          lv_retval := '      LABEL'
            ||CHR(10)||'        ANGLE '||CASE pi_layer_type WHEN 'POINT' THEN 'AUTO' ELSE 'FOLLOW' END
            ||CHR(10)||'        FONT "'||REPLACE(lv_font_family,' ','')||'"'
            ||CHR(10)||'        SIZE '||REGEXP_REPLACE(lv_font_size,'[^0-9]','')
            ||CHR(10)||'        COLOR "'||lv_font_fill||'"'
            ||CHR(10)||'        OFFSET 0 0'
          ;
          --
          IF lr_svg_data.g_float_width IS NOT NULL
           THEN
              lv_retval := lv_retval
                ||CHR(10)||'        OUTLINECOLOR "'||lr_svg_data.g_float_color||'"'
                ||CHR(10)||'        OUTLINEWIDTH '||lr_svg_data.g_float_width
              ;
          END IF;
          --
          IF lr_svg_data.g_sticky IS NOT NULL
           THEN
              lv_retval := lv_retval
                ||CHR(10)||'        FORCE TRUE';
          END IF;
          --
          IF pi_max_scale IS NOT NULL
           THEN
              lv_retval := lv_retval||CHR(10)||'        MAXSCALEDENOM '||pi_max_scale;
          END IF;
          --
          IF pi_min_scale IS NOT NULL
           THEN
              lv_retval := lv_retval||CHR(10)||'        MINSCALEDENOM '||pi_min_scale;
          END IF;
          --
          IF pi_layer_type = 'LINE'
           THEN
              lv_retval := lv_retval
                ||CHR(10)||'        REPEATDISTANCE 800'
                ||CHR(10)||'        MINDISTANCE 800';
          END IF;
          --
          lv_retval := lv_retval
            ||CHR(10)||'        POSITION '||CASE pi_layer_type WHEN 'POINT' THEN 'AUTO' ELSE 'CC' END
            ||CHR(10)||'        SHADOWSIZE 1 1'
            ||CHR(10)||'        TYPE TRUETYPE'
            ||CHR(10)||'        TEXT ("['||pi_text_column||']")'
            ||CHR(10)||'      END #LABEL'
          ;
          --
      ELSE
          --Invalid Style Type supplied as Text Style
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 11
                       ,pi_supplementary_info => pi_style_name);
    END CASE;
    --
    RETURN lv_retval;
    --
  END get_label_style;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_geom_style(pi_style_name      IN VARCHAR2
                         ,pi_geom_column     IN VARCHAR2
                         ,pi_layer_type      IN VARCHAR2
                         ,pi_rule_column     IN VARCHAR2 DEFAULT NULL
                         ,pi_label_column    IN VARCHAR2 DEFAULT NULL
                         ,pi_label_style     IN VARCHAR2 DEFAULT NULL
                         ,pi_label_min_scale IN VARCHAR2 DEFAULT NULL
                         ,pi_label_max_scale IN VARCHAR2 DEFAULT NULL)
    RETURN nm3type.max_varchar2 IS
    --
    lv_retval  nm3type.max_varchar2;
    --
    lv_fill            nm3type.max_varchar2;
    lv_fill_opacity    nm3type.max_varchar2;
    lv_stroke          nm3type.max_varchar2;
    lv_stroke_width    nm3type.max_varchar2;
    lv_stroke_opacity  nm3type.max_varchar2;
    lv_width           nm3type.max_varchar2;
    --
    lv_style_def  XMLTYPE;
    --
    lt_bucket_values  nm3type.tab_varchar32767;
    --
    CURSOR get_uss(cp_style_name IN VARCHAR2)
        IS
    SELECT type
          ,description
          ,definition
          ,geometry
      FROM user_sdo_styles
     WHERE name = cp_style_name
         ;
    --
    lr_uss  get_uss%ROWTYPE;
    --
    CURSOR get_svg_data(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(cp_xml,'/svg/g/@class') g_class
          ,EXTRACTVALUE(cp_xml,'/svg/g/@style') g_style
          ,EXTRACTVALUE(cp_xml,'/svg/g/@dash')  g_dash
      FROM dual
         ;
    --
    lr_svg_data  get_svg_data%ROWTYPE;
    --
    CURSOR get_svg_lines(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(lines.column_value,'/line/@class') line_class
          ,EXTRACTVALUE(lines.column_value,'/line/@style') line_style
          ,EXTRACTVALUE(lines.column_value,'/line/@dash') line_dash
      FROM XMLTABLE('/svg/g/line' PASSING cp_xml) lines
         ;
    --
    TYPE svg_line_data_tab IS TABLE OF get_svg_lines%ROWTYPE INDEX BY BINARY_INTEGER;
    lt_svg_line_data svg_line_data_tab;
    --
    CURSOR get_adv_style_data(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(collection_buckets.column_value,'CollectionBucket') bucket_value
          ,EXTRACTVALUE(collection_buckets.column_value,'CollectionBucket/@label') bucket_label
          ,EXTRACTVALUE(collection_buckets.column_value,'CollectionBucket/@style') bucket_style
      FROM XMLTABLE('/AdvancedStyle/BucketStyle/Buckets/CollectionBucket' PASSING cp_xml) collection_buckets
         ;
    --
    TYPE adv_style_data_tab IS TABLE OF get_adv_style_data%ROWTYPE INDEX BY BINARY_INTEGER;
    lt_adv_style_data adv_style_data_tab;
    --
  BEGIN
    /*
    ||Get the data from user_sdo_styles.
    */
    OPEN  get_uss(pi_style_name);
    FETCH get_uss
     INTO lr_uss;
    CLOSE get_uss;
    --
    IF lr_uss.definition IS NULL
     THEN
        --Unsuported Style Type
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 10
                     ,pi_supplementary_info => pi_style_name);
    END IF;
    --
    lv_style_def := XMLTYPE(lr_uss.definition);
    --
    CASE lr_uss.type
      WHEN 'AREA'
       THEN
          NULL;
      WHEN 'LINE'
       THEN
          --
          OPEN  get_svg_data(lv_style_def);
          FETCH get_svg_data
           INTO lr_svg_data;
          CLOSE get_svg_data;
          --
          IF pi_layer_type IS NOT NULL
           AND pi_layer_type != 'LINE'
           THEN
              /*
              ||Layer has multiple GTypes and the GType being
              ||Processed is not a Line so return a default
              ||symboliser based loosely on the Line Style
              ||Properties.
              */
              lv_retval := get_default_style(pi_geom_column => pi_geom_column
                                            ,pi_layer_type  => pi_layer_type
                                            ,pi_style       => lr_svg_data.g_style);
          ELSE
              lv_retval := get_line_style(pi_class => lr_svg_data.g_class
                                         ,pi_style => lr_svg_data.g_style
                                         ,pi_dash  => lr_svg_data.g_dash);
              --
              OPEN  get_svg_lines(lv_style_def);
              FETCH get_svg_lines
               BULK COLLECT
               INTO lt_svg_line_data;
              CLOSE get_svg_lines;
              --
              FOR i IN 1..lt_svg_line_data.COUNT LOOP
                IF lt_svg_line_data(i).line_style IS NOT NULL
                 THEN
                    /*
                    ||Parallel line class needs to be written first.
                    */
                    IF lt_svg_line_data(i).line_class = 'parallel'
                     THEN
                        lv_retval := get_line_style(pi_class         => lt_svg_line_data(i).line_class
                                                   ,pi_style         => lt_svg_line_data(i).line_style
                                                   ,pi_dash          => lt_svg_line_data(i).line_dash
                                                   ,pi_base_linecap  => NVL(get_style_value(pi_style => lr_svg_data.g_style
                                                                                           ,pi_field => 'stroke-linecap:')
                                                                           ,'ROUND')
                                                   ,pi_base_linejoin => NVL(get_style_value(pi_style => lr_svg_data.g_style
                                                                                           ,pi_field => 'stroke-linejoin:')
                                                                           ,'ROUND')
                                                   ,pi_base_width    => get_style_value(pi_style => lr_svg_data.g_style
                                                                                       ,pi_field => 'stroke-width:'))
                                     ||CHR(10)||lv_retval;
                    ELSE
                        lv_retval := lv_retval
                          ||CHR(10)||get_line_style(pi_class      => lt_svg_line_data(i).line_class
                                                   ,pi_style      => lt_svg_line_data(i).line_style
                                                   ,pi_dash       => lt_svg_line_data(i).line_dash
                                                   ,pi_base_linecap  => NVL(get_style_value(pi_style => lr_svg_data.g_style
                                                                                           ,pi_field => 'stroke-linecap:')
                                                                           ,'ROUND')
                                                   ,pi_base_linejoin => NVL(get_style_value(pi_style => lr_svg_data.g_style
                                                                                           ,pi_field => 'stroke-linejoin:')
                                                                           ,'ROUND'));
                    END IF;
                END IF;
              END LOOP;
              /*
              ||If an arrow is defined process it.
              */
              lv_retval := lv_retval||CHR(10)||get_line_marker_style(pi_style => lr_svg_data.g_style);
          END IF;
          --
      WHEN 'MARKER'
       THEN
          --
          OPEN  get_svg_data(lv_style_def);
          FETCH get_svg_data
           INTO lr_svg_data;
          CLOSE get_svg_data;
          --
          IF pi_layer_type IS NOT NULL
           AND pi_layer_type != 'POINT'
           THEN
              /*
              ||Layer has multiple GTypes and the GType being
              ||Processed is not a Point so return a default
              ||symboliser based loosely on the Marker Style
              ||Properties.
              */
              lv_retval := get_default_style(pi_geom_column => pi_geom_column
                                            ,pi_layer_type  => pi_layer_type
                                            ,pi_style       => lr_svg_data.g_style);
          ELSE
              --
              lv_retval := get_marker_style(pi_style_name => pi_style_name
                                           ,pi_style_def  => lv_style_def
                                           ,pi_style      => lr_svg_data.g_style);
              --
          END IF;
          --
      WHEN 'COLOR'
       THEN
          --
          OPEN  get_svg_data(lv_style_def);
          FETCH get_svg_data
           INTO lr_svg_data;
          CLOSE get_svg_data;
          --
          IF pi_layer_type IS NOT NULL
           AND pi_layer_type != 'POLYGON'
           THEN
              /*
              ||Layer has multiple GTypes and the GType being
              ||Processed is not a Polygon so return a default
              ||symboliser based loosely on the Color Style
              ||Properties.
              */
              lv_retval := get_default_style(pi_geom_column => pi_geom_column
                                            ,pi_layer_type  => pi_layer_type
                                            ,pi_style       => lr_svg_data.g_style);
          ELSE
              --
              lv_fill := get_style_value(pi_style => lr_svg_data.g_style
                                        ,pi_field => 'fill:');
              lv_fill_opacity := get_style_value(pi_style => lr_svg_data.g_style
                                                ,pi_field => 'fill-opacity:');
              lv_stroke := get_style_value(pi_style => lr_svg_data.g_style
                                          ,pi_field => 'stroke:');
              lv_stroke_width := get_style_value(pi_style => lr_svg_data.g_style
                                                ,pi_field => 'stroke-width:');
              lv_stroke_opacity := get_style_value(pi_style => lr_svg_data.g_style
                                                  ,pi_field => 'stroke-opacity:');
              --
              lv_retval := '      STYLE';
              --
              IF lv_fill IS NOT NULL
               THEN
                  lv_retval := lv_retval
                    ||CHR(10)||'        COLOR "'||lv_fill||'"'
                  ;
              END IF;
              --
              IF lv_stroke IS NOT NULL
               THEN
                  lv_retval := lv_retval
                    ||CHR(10)||'        OUTLINECOLOR "'||lv_stroke||'"'
                    ||CHR(10)||'        WIDTH '||NVL(lv_stroke_width,'1.0')
                  ;
              END IF;
              --
              lv_retval := lv_retval
                    ||CHR(10)||'      END #STYLE'
              ;
              --
          END IF;
          --
      WHEN 'TEXT'
       THEN
          NULL;
      WHEN 'ADVANCED'
       THEN
          --
          OPEN  get_adv_style_data(lv_style_def);
          FETCH get_adv_style_data
           BULK COLLECT
           INTO lt_adv_style_data;
          CLOSE get_adv_style_data;
          --
          FOR i IN 1..lt_adv_style_data.COUNT LOOP
            /*
            ||Start the Rule.
            */
            lv_retval := lv_retval||CHR(10)||'    CLASS'
                                  ||CHR(10)||'      NAME "'||NVL(lt_adv_style_data(i).bucket_label,lt_adv_style_data(i).bucket_value)||'"'
            ;
            lt_bucket_values := awlrs_util.tokenise_string(pi_string => lt_adv_style_data(i).bucket_value);
            IF lt_bucket_values.COUNT > 1
             THEN
                lv_retval := lv_retval||CHR(10)||'      EXPRESSION (';
                FOR j IN 1..lt_bucket_values.COUNT LOOP
                  lv_retval := lv_retval||CASE WHEN j = 1 THEN NULL ELSE ' OR ' END||'"['||pi_rule_column||']" = "'||lt_bucket_values(j)||'"';
                END LOOP;
                lv_retval := lv_retval||')';
            ELSE
                lv_retval := lv_retval||CHR(10)||'      EXPRESSION ("['||pi_rule_column||']" = "'||lt_adv_style_data(i).bucket_value||'")';
            END IF;
            /*
            ||Get the Symbolizer data.
            */
            lv_retval := lv_retval||CHR(10)||get_geom_style(pi_style_name  => lt_adv_style_data(i).bucket_style
                                                           ,pi_geom_column => pi_geom_column
                                                           ,pi_layer_type  => pi_layer_type);
            /*
            ||Write the label data if required.
            */
            IF pi_label_column IS NOT NULL
             AND pi_label_style IS NOT NULL
             THEN
                lv_retval := lv_retval||CHR(10)||get_label_style(pi_style_name  => pi_label_style
                                                                ,pi_text_column => pi_label_column
                                                                ,pi_min_scale   => pi_label_min_scale
                                                                ,pi_max_scale   => pi_label_max_scale
                                                                ,pi_layer_type  => pi_layer_type);
            END IF;
            /*
            ||Close the Class.
            */
            lv_retval := lv_retval||CHR(10)||'    END #CLASS';
            --
        END LOOP;
      ELSE
          --Unsuported Style Type
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 10
                       ,pi_supplementary_info => pi_style_name);
    END CASE;
    --
    RETURN lv_retval;
    --
  END get_geom_style;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_layer_class(pi_theme IN themes_rec
                               ,pi_gtype IN NUMBER)
    RETURN VARCHAR2 IS
    --
    lt_layer_class  nm3type.tab_varchar32767;
    lt_gtypes       awlrs_sdo.gtype_tab;
    --
    lt_rules xml_tab;
    --
    lv_layer_text          nm3type.max_varchar2;
    lv_feature_style_type  user_sdo_styles.type%TYPE;
    --
    CURSOR get_rule_data(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(cp_xml,'/rule/@column')         rule_column
          ,EXTRACTVALUE(cp_xml,'/rule/features/@style') feature_style
          ,EXTRACTVALUE(cp_xml,'/rule/label/@column')   label_column
          ,EXTRACTVALUE(cp_xml,'/rule/label/@style')    label_style
      FROM dual
         ;
    --
    lr_rule_data  get_rule_data%ROWTYPE;
    --
    CURSOR get_uss(cp_style_name IN VARCHAR2)
        IS
    SELECT type
      FROM user_sdo_styles
     WHERE name = cp_style_name
         ;
    --
  BEGIN
    /*
    ||Get the rules xml.
    */
    lt_rules := get_theme_rules(pi_xml => XMLTYPE(pi_theme.styling_rules));
    --
    FOR k IN 1..lt_rules.COUNT LOOP
      /*
      ||Extract the rule data.
      */
      OPEN  get_rule_data(lt_rules(k));
      FETCH get_rule_data
       INTO lr_rule_data;
      CLOSE get_rule_data;
      /*
      ||Get the data from user_sdo_styles.
      */
      OPEN  get_uss(lr_rule_data.feature_style);
      FETCH get_uss
       INTO lv_feature_style_type;
      CLOSE get_uss;
      --
      IF lv_feature_style_type = 'ADVANCED'
       THEN
          lv_layer_text := lv_layer_text||get_geom_style(pi_style_name      => lr_rule_data.feature_style
                                                        ,pi_geom_column     => pi_theme.geometry_column
                                                        ,pi_layer_type      => gtype_to_layer_type(pi_gtype => pi_gtype)
                                                        ,pi_rule_column     => lr_rule_data.rule_column
                                                        ,pi_label_column    => lr_rule_data.label_column
                                                        ,pi_label_style     => lr_rule_data.label_style
                                                        ,pi_label_min_scale => pi_theme.label_min_scale
                                                        ,pi_label_max_scale => pi_theme.label_max_scale);
      ELSE
          /*
          ||Start the Class.
          */
          lv_layer_text := lv_layer_text||CASE lv_layer_text WHEN NULL THEN NULL ELSE CHR(10) END||'    CLASS'
                                        ||CHR(10)||'      NAME "'||pi_theme.trimmed_name||'"'
          ;
          /*
          ||Get the Symbolizer data.
          */
          lv_layer_text := lv_layer_text||CHR(10)||get_geom_style(pi_style_name  => lr_rule_data.feature_style
                                                                 ,pi_geom_column => pi_theme.geometry_column
                                                                 ,pi_layer_type  => gtype_to_layer_type(pi_gtype => pi_gtype));
          /*
          ||Write the label data if required.
          */
          IF lr_rule_data.label_column IS NOT NULL
           THEN
              lv_layer_text := lv_layer_text||CHR(10)||get_label_style(pi_style_name  => lr_rule_data.label_style
                                                                      ,pi_text_column => lr_rule_data.label_column
                                                                      ,pi_min_scale   => pi_theme.label_min_scale
                                                                      ,pi_max_scale   => pi_theme.label_max_scale
                                                                      ,pi_layer_type  => gtype_to_layer_type(pi_gtype => pi_gtype));
          END IF;
          /*
          ||Close the Class.
          */
          lv_layer_text := lv_layer_text||CHR(10)||'    END #CLASS';
          --
      END IF;
      --
    END LOOP; --lt_rules
    --
    RETURN lv_layer_text;
    --
  END generate_layer_class;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_layers(pi_definition     IN CLOB
                          ,pi_all_ft_cols    IN VARCHAR2 DEFAULT 'N'
                          ,pi_effective_date IN DATE DEFAULT NULL)
    RETURN clob_tab IS
    --
    lt_layer_text   clob_tab;
    lt_themes       themes_tab;
    lt_gtypes       awlrs_sdo.gtype_tab;
    lt_theme_types  theme_types_tab;
    --
    lr_theme_types  theme_types_rec;
    --
    lv_layer_text                  CLOB;
    lv_layer_type                  VARCHAR2(100);
    lv_theme_extent                VARCHAR2(500);
    lv_gml_msGeometry_type         VARCHAR2(100);
    lv_wfs_featureid               VARCHAR2(100);
    lv_group                       VARCHAR2(200);
    lv_group_name                  VARCHAR2(200);
    lv_name                        VARCHAR2(200);
    lv_title                       VARCHAR2(200);
    lv_theme_extra_cols            nm3type.max_varchar2;
    lv_epsg                        NUMBER;
    lv_srid                        NUMBER;
    lv_using_srid                  VARCHAR2(20);
    lv_group_memb_types            nm3type.max_varchar2;
    lv_layer_node_layer            nm_themes_all.nth_theme_name%TYPE;
    lv_layer_asset_loc_types       nm3type.max_varchar2;
    lv_layer_child_inv_types       nm3type.max_varchar2;
    lv_layer_show_in_map           VARCHAR2(10);
    lv_displayed_on_startup        VARCHAR2(10);
    lv_displayed_in_legend         VARCHAR2(10);
    lv_legend_group                nm3type.max_varchar2;
    lv_tooltip_template_defined    BOOLEAN;
    lv_tooltip_columns             nm3type.max_varchar2;
    lv_gtype_restriction           VARCHAR2(100);
    lv_where_and                   VARCHAR2(10) := ' WHERE ';
    --
    ---------------------------------------------------------------------------
    --
    FUNCTION get_theme_label_col(pi_theme_name IN VARCHAR2
                                ,pi_pk_column  IN VARCHAR2)
      RETURN VARCHAR2 IS
      --
      lv_retval VARCHAR2(100);
      --
    BEGIN
      --
      SELECT theme_styles.label_column
        INTO lv_retval
        FROM user_sdo_themes themes
            ,XMLTABLE('/styling_rules/rule/label'
                      PASSING XMLTYPE(themes.styling_rules)
                      COLUMNS label_column VARCHAR2(32) path '@column') theme_styles
       WHERE themes.name = pi_theme_name
         AND UPPER(theme_styles.label_column) != UPPER(pi_pk_column)
         AND ROWNUM = 1
           ;
      --
      RETURN lv_retval;
      --
    EXCEPTION
     WHEN no_data_found
      THEN
         RETURN NULL;
     WHEN others
      THEN
         RAISE;
    END get_theme_label_col;

    --
    ---------------------------------------------------------------------------
    --
    FUNCTION get_theme_extra_cols(pi_theme_name IN VARCHAR2
                                 ,pi_pk_column  IN VARCHAR2
                                 ,pi_alias      IN VARCHAR2)
      RETURN VARCHAR2 IS
      --
      lt_columns  nm3type.tab_varchar30;
      --
      lv_label_col  nm3type.max_varchar2;
      lv_retval     nm3type.max_varchar2;
      --
    BEGIN
      --
      lv_label_col := get_theme_label_col(pi_theme_name => pi_theme_name
                                         ,pi_pk_column  => pi_pk_column);
      --
      IF lv_label_col IS NOT NULL
       THEN
          lv_retval := ', '||pi_alias||lv_label_col;
      END IF;
      --
      SELECT DISTINCT pi_alias||theme_styles.label_column
        BULK COLLECT
        INTO lt_columns
        FROM user_sdo_themes themes
            ,XMLTABLE('/styling_rules/rule'
                      PASSING XMLTYPE(themes.styling_rules)
                      COLUMNS label_column VARCHAR2(30) path '@column') theme_styles
       WHERE themes.name = pi_theme_name
         AND UPPER(theme_styles.label_column) NOT IN(UPPER(pi_pk_column),UPPER(NVL(lv_label_col,'~~~~~')))
           ;
      --
      FOR i IN 1..lt_columns.COUNT LOOP
        IF lt_columns(i) IS NOT NULL
         THEN
            lv_retval := lv_retval||', '||lt_columns(i);
        END IF;
      END LOOP;
      --
      RETURN lv_retval;
      --
    EXCEPTION
     WHEN no_data_found
      THEN
         RETURN NULL;
     WHEN others
      THEN
         RAISE;
    END get_theme_extra_cols;

    --
    ---------------------------------------------------------------------------
    --
    FUNCTION get_theme_wfs_key_col(pi_theme_name IN VARCHAR2
                                  ,pi_pk_column  IN VARCHAR2)
      RETURN VARCHAR2 IS
      --
      lv_retval VARCHAR2(100);
      --
    BEGIN
      --
      SELECT key_column
        INTO lv_retval
        FROM (SELECT NVL(EXTRACTVALUE(XMLTYPE(styling_rules),'/styling_rules/@key_column'),'ROWID') key_column
                FROM user_sdo_themes
               WHERE name = pi_theme_name)
       WHERE key_column != UPPER(pi_pk_column)
           ;
      --
      RETURN lv_retval;
      --
    EXCEPTION
     WHEN no_data_found
      THEN
         RETURN NULL;
     WHEN others
      THEN
         RAISE;
    END get_theme_wfs_key_col;
    --
  BEGIN
    /*
    ||Get the themes for the map.
    */
    lt_themes := get_themes(pi_definition => pi_definition);
    /*
    ||Generate the layer data for each theme.
    */
    FOR i IN 1..lt_themes.COUNT LOOP
      /*
      ||Get the types represented by the layer.
      */
      lt_theme_types := get_theme_types(pi_theme_name => lt_themes(i).name);
      IF lt_theme_types.COUNT > 0
       THEN
          --
          lr_theme_types := lt_theme_types(1);
          --
          IF lr_theme_types.network_element_type IS NOT NULL
           AND lr_theme_types.network_group_type IS NOT NULL
           THEN
              lv_group_memb_types := get_group_member_types(pi_ne_type    => lr_theme_types.network_element_type
                                                           ,pi_group_type => lr_theme_types.network_group_type);
          ELSE
              lv_group_memb_types := NULL;
          END IF;
          --
          IF lr_theme_types.node_type IS NOT NULL
           THEN
              lv_layer_node_layer := get_node_layer(pi_node_type => lr_theme_types.node_type
                                                   ,pi_themes    => lt_themes);
          ELSE
              lv_layer_node_layer := NULL;
          END IF;
          --
          IF lr_theme_types.asset_type IS NOT NULL
           THEN
              lv_layer_child_inv_types := get_child_inv_types(pi_inv_type => lr_theme_types.asset_type);
              lv_layer_asset_loc_types := get_asset_loc_types(pi_inv_type => lr_theme_types.asset_type);         
          ELSE
              lv_layer_child_inv_types := NULL;
              lv_layer_asset_loc_types := NULL;
          END IF;
          --
      ELSE
          --
          lr_theme_types := NULL;
          lv_group_memb_types := NULL;
          lv_layer_node_layer := NULL;
          lv_layer_child_inv_types := NULL;
          lv_layer_asset_loc_types := NULL;
          --
      END IF;
      /*
      ||Update the Map Extent global variables.
      */
      lv_theme_extent := update_map_extent(pi_theme_id => lt_themes(i).nth_theme_id);
      /*
      ||Get the EPSG.
      */
      get_srid_and_epsg(pi_table_name  => lt_themes(i).nth_feature_table
                       ,pi_column_name => lt_themes(i).nth_feature_shape_column
                       ,po_srid        => lv_srid
                       ,po_epsg        => lv_epsg);
      add_map_epsg(pi_epsg => lv_epsg);
      IF lv_srid IS NOT NULL
       THEN
          lv_using_srid := ' SRID '||lv_srid;
      ELSE
          lv_using_srid := NULL;
      END IF;
      /*
      ||Get the style data from user_sdo_themes and user_sdo_styles.
      */
      lv_theme_extra_cols := get_theme_extra_cols(pi_theme_name => lt_themes(i).name
                                                 ,pi_pk_column  => lt_themes(i).nth_feature_pk_column
                                                 ,pi_alias      => 'ft.');
      /*
      ||Determine whether a tooltip template is defined.
      */
      lv_tooltip_template_defined := (get_custom_tag_value(pi_theme_name => lt_themes(i).name
                                                          ,pi_tag_name   => 'TooltipTemplate') IS NOT NULL);
      /*
      ||Get the tooltip columns.
      */
      lv_tooltip_columns := get_custom_tag_value(pi_theme_name => lt_themes(i).name
                                                ,pi_tag_name   => 'TooltipColumns');
      --
      IF lv_tooltip_columns IS NOT NULL
       THEN
          lv_theme_extra_cols := lv_theme_extra_cols||','||lv_tooltip_columns;
      END IF;
      /*
      ||Get the key_column for the wfs_featureid.
      */
      lv_wfs_featureid := NVL(get_theme_wfs_key_col(pi_theme_name => lt_themes(i).name
                                                   ,pi_pk_column  => lt_themes(i).nth_feature_pk_column)
                             ,lt_themes(i).nth_feature_pk_column);
      /*
      ||Get the DisplayedAtStartup custom tag.
      */
      lv_displayed_on_startup := UPPER(NVL(get_custom_tag_value(pi_theme_name => lt_themes(i).name
                                                               ,pi_tag_name   => 'DisplayedAtStartup')
                                          ,'Y'));
      /*
      ||Get the DisplayInLegend custom tag.
      */
      lv_displayed_in_legend := UPPER(NVL(get_custom_tag_value(pi_theme_name => lt_themes(i).name
                                                              ,pi_tag_name   => 'DisplayInLegend')
                                         ,'Y'));
      /*
      ||Get the ShowInMap tag.
      */
      lv_layer_show_in_map := UPPER(NVL(get_custom_tag_value(pi_theme_name => lt_themes(i).name
                                                            ,pi_tag_name   => 'ShowInMap')
                                       ,'N'));
      /*
      ||Get the Legend Group tag.
      */
      lv_legend_group := get_custom_tag_value(pi_theme_name => lt_themes(i).name
                                             ,pi_tag_name   => 'LegendGroup');
      /*
      ||Get the Geometry Types.
      */
      lt_gtypes := awlrs_sdo.get_gtypes(pi_theme_id => lt_themes(i).nth_theme_id);
      --
      IF lt_gtypes.COUNT > 1
       THEN
          lv_group := lt_themes(i).trimmed_name;
          lv_group_name := lt_themes(i).name;
      ELSE
          lv_group := NULL;
          lv_group_name := NULL;
      END IF;
      /*
      ||Write the Layer definition.
      */
      FOR j IN 1..lt_gtypes.COUNT LOOP
        --
        lv_layer_type := gtype_to_layer_type(pi_gtype => lt_gtypes(j).gtype);
        lv_gml_msGeometry_type := gtype_to_gml_msGeometry_type(pi_gtype => lt_gtypes(j).gtype);
        --
        IF lv_group IS NOT NULL
         THEN
            lv_name  := lt_themes(i).trimmed_name||'_'||lv_layer_type;
            lv_title := lt_themes(i).name||' '||lv_layer_type;
            lv_gtype_restriction := 'ft.'||LOWER(lt_themes(i).nth_feature_shape_column)||'.sdo_gtype '||get_layer_type_in_clause(pi_layer_type => lv_layer_type);
        ELSE
            lv_name  := lt_themes(i).trimmed_name;
            lv_title := lt_themes(i).name;
            lv_gtype_restriction := NULL;
        END IF;
        --
        lv_where_and := ' WHERE ';
        --
        lv_layer_text := '  LAYER'
              ||CHR(10)||'    NAME "'||lv_name||'"'
        ;
        IF lv_group IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'    GROUP "'||lv_group||'"';
        END IF;
        --
        lv_layer_text := lv_layer_text
              ||CHR(10)||'    METADATA'
              ||CHR(10)||'      "wms_title"                   "'||lv_title||'"'
              ||CHR(10)||'      "wms_enable_request"          "*"'
              ||CHR(10)||'      "wms_extent"                  "'||lv_theme_extent||'"'
              ||CHR(10)||'      "wfs_title"                   "'||lv_title||'"'
              ||CHR(10)||'      "wfs_featureid"               "'||lv_wfs_featureid||'"'
              ||CHR(10)||'      "wfs_enable_request"          "*"'
              ||CHR(10)||'      "wfs_getfeature_formatlist"   "SHAPEZIP,CSV,JSON"'
              ||CHR(10)||'      "gml_featureid"               "'||lt_themes(i).nth_feature_pk_column||'"'
              ||CHR(10)||'      "gml_include_items"           "all"'
              ||CHR(10)||'      "gml_geometries"              "msGeometry"'
              ||CHR(10)||'      "gml_msGeometry_type"         "'||lv_gml_msGeometry_type||'"'
        ;
        --
        IF lv_group_name IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "layer_group_name"            "'||lv_group_name||'"';
        END IF;
        --
        IF lr_theme_types.admin_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "admin_type"                  "'||lr_theme_types.admin_type||'"';
        END IF;
        --
        IF lr_theme_types.network_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_type"                "'||lr_theme_types.network_type||'"';
        END IF;
        --
        IF lr_theme_types.network_element_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_element_type"        "'||lr_theme_types.network_element_type||'"';
        END IF;
        --
        IF lr_theme_types.network_is_linear IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_is_linear"           "'||lr_theme_types.network_is_linear||'"';
        END IF;
        --
        IF lr_theme_types.network_is_incl_parent_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_is_incl_parent_type" "'||lr_theme_types.network_is_incl_parent_type||'"';
        END IF;
        --
        IF lr_theme_types.network_group_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_group_type"          "'||lr_theme_types.network_group_type||'"';
        END IF;
        --
        IF lv_group_memb_types IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_group_memb_types"    "'||lv_group_memb_types||'"';
        END IF;
        --
        IF lr_theme_types.network_partial_memb IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_partial_members"     "'||lr_theme_types.network_partial_memb||'"';
        END IF;
        --
        IF lr_theme_types.unit_id IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_units"               "'||lr_theme_types.unit_id||'"';
        END IF;
        --
        IF lr_theme_types.node_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "network_node_type"           "'||lr_theme_types.node_type||'"';
        END IF;
        --
        IF lv_layer_node_layer IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "node_layer_name"             "'||lv_layer_node_layer||'"';
        END IF;
        --
        IF lr_theme_types.asset_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "asset_type"                  "'||lr_theme_types.asset_type||'"';
        END IF;
        --
        IF lr_theme_types.asset_type IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "ft_asset_type"               "'||lr_theme_types.ft_asset_type||'"';
        END IF;
        --
        IF lv_layer_asset_loc_types IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "asset_loc_types"             "'||lv_layer_asset_loc_types||'"';
        END IF;
        --
        IF lr_theme_types.multiple_locs_allowed IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "multiple_locs_allowed"       "'||lr_theme_types.multiple_locs_allowed||'"';
        END IF;
        --
        IF lr_theme_types.top_of_hierarchy IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "top_of_hierarchy"            "'||lr_theme_types.top_of_hierarchy||'"';
        END IF;
        --
        IF lr_theme_types.hierarchy_relation IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "hierarchy_relation"          "'||lr_theme_types.hierarchy_relation||'"';
        END IF;
        --
        IF lv_layer_child_inv_types IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "child_inv_types"             "'||lv_layer_child_inv_types||'"';
        END IF;
        --
        IF lr_theme_types.asset_type IS NOT NULL
         AND lr_theme_types.dependent_geometry IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "dependent_geometry"          "'||lr_theme_types.dependent_geometry||'"';
        END IF;
        --
        --
        IF lr_theme_types.asset_type IS NOT NULL
         AND lr_theme_types.location_updatable IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'      "location_updatable"          "'||lr_theme_types.location_updatable||'"';
        END IF;
        --        
        lv_layer_text := lv_layer_text
              ||CHR(10)||'      "is_editable"                 "'||NVL(lr_theme_types.editable,'N')||'"'
              ||CHR(10)||'      "show_in_map"                 "'||lv_layer_show_in_map||'"'
              ||CHR(10)||'      "displayed_at_startup"        "'||lv_displayed_on_startup||'"'
              ||CHR(10)||'      "displayed_in_legend"         "'||lv_displayed_in_legend||'"'
              ||CHR(10)||'      "legend_group"                "'||lv_legend_group||'"'
              ||CHR(10)||'    END'
              ||CASE g_debug WHEN 'Y' THEN CHR(10)||'    DEBUG 5' ELSE NULL END
              ||CHR(10)||'    TYPE '||lv_layer_type
              ||CHR(10)||'    STATUS OFF'
              ||CHR(10)||'    CONNECTIONTYPE PLUGIN'
              ||CHR(10)||'    PROCESSING "CLOSE_CONNECTION=DEFER"'
              ||CHR(10)||'    PLUGIN "msplugin_oracle.dll"'
              ||CHR(10)||'    CONNECTION "%user%/%pwd%@%dbhost%"'
        ;
        IF pi_all_ft_cols = 'Y'
         THEN
            lv_layer_text := lv_layer_text
              ||CHR(10)||'    DATA "'||LOWER(lt_themes(i).nth_feature_shape_column)||' FROM (SELECT ft.*'
            ;
        ELSE
            lv_layer_text := lv_layer_text
              ||CHR(10)||'    DATA "'||LOWER(lt_themes(i).nth_feature_shape_column)||' FROM (SELECT ft.'||LOWER(lt_themes(i).nth_feature_pk_column)
            ;
        END IF;
        --
        IF pi_all_ft_cols != 'Y'
         AND lv_theme_extra_cols IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||lv_theme_extra_cols;
        END IF;
        /*
        ||If the layer represents Datums we need to be sure we have
        ||the start and end node in the select statement.
        */
        IF lr_theme_types.network_element_type = 'S'
         THEN
            lv_layer_text := lv_layer_text||', nl.ne_length element_length, nl.ne_no_start start_node, nl.ne_no_end end_node';
        END IF;
        --
        IF pi_all_ft_cols = 'Y'
         THEN
            lv_layer_text := lv_layer_text||' FROM '||LOWER(lt_themes(i).nth_feature_table)||' ft';
        ELSE
            lv_layer_text := lv_layer_text||', ft.'||LOWER(lt_themes(i).nth_feature_shape_column)
                               ||' FROM '||LOWER(lt_themes(i).nth_feature_table)||' ft';
        END IF;
        /*
        ||If the layer represents Datums we need to be sure we have
        ||the start and end node in the select statement.
        */
        IF lr_theme_types.network_element_type = 'S'
         THEN
            lv_layer_text := lv_layer_text||', nm_elements_all nl WHERE nl.ne_id = ft.'||LOWER(lt_themes(i).nth_feature_pk_column);
            lv_where_and := ' AND ';
        END IF;
        --
        IF lv_gtype_restriction IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||lv_where_and||lv_gtype_restriction;
            lv_where_and := ' AND ';
        END IF;
        --
        IF pi_effective_date IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||lv_where_and||'awlrs_util.set_effective_date(TO_DATE('''||TO_CHAR(TRUNC(pi_effective_date),'DD-MM-YYYY')||''',''DD-MM-YYYY'')) = 1';
            lv_where_and := ' AND ';
        ELSE
            lv_layer_text := lv_layer_text||lv_where_and||'awlrs_util.set_effective_date(SYSDATE) = 1';
            lv_where_and := ' AND ';
        END IF;
        --
        lv_layer_text := lv_layer_text||') USING UNIQUE '||lt_themes(i).nth_feature_pk_column||lv_using_srid||'"'
              ||CHR(10)||'    VALIDATION'
              ||CHR(10)||'      "user"                     "^.*"'
              ||CHR(10)||'      "pwd"                      "^.*"'
              ||CHR(10)||'      "featurekey"               "^.*"'
              ||CHR(10)||'      "featurekeyvalues"         "^.*"'
              ||CHR(10)||'      "spatialfilter"            "^.*"'
              ||CHR(10)||'      "default_featurekey"       "1"'
              ||CHR(10)||'      "default_featurekeyvalues" "1"'
              ||CHR(10)||'      "default_spatialfilter"    ""'
              ||CHR(10)||'    END'
        ;
        --
        lv_layer_text := lv_layer_text||generate_layer_class(pi_theme => lt_themes(i)
                                                            ,pi_gtype => lt_gtypes(j).gtype);
        --
        IF lt_themes(i).max_scale IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'    MAXSCALEDENOM '||lt_themes(i).max_scale;
        END IF;
        --
        IF lt_themes(i).min_scale IS NOT NULL
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'    MINSCALEDENOM '||lt_themes(i).min_scale;
        END IF;
        --
        IF lv_tooltip_template_defined
         THEN
            lv_layer_text := lv_layer_text||CHR(10)||'    TEMPLATE "'||lt_themes(i).trimmed_name||'Template.html"';
        END IF;
        --
        lv_layer_text := lv_layer_text
              ||CHR(10)||'    PROJECTION'
              ||CHR(10)||'      "init=epsg:'||lv_epsg||'"'
              ||CHR(10)||'    END'
              ||CHR(10)||'    PROCESSING "LABEL_NO_CLIP=on"'
              ||CHR(10)||'    PROCESSING "NATIVE_FILTER=(%featurekey% in (%featurekeyvalues%))"'
              ||CHR(10)||'  END #layer'
              ||CHR(10)||''
        ;
        --
        lt_layer_text(lt_layer_text.COUNT + 1) := lv_layer_text;
        --
      END LOOP;
      --
    END LOOP;
    --
    RETURN lt_layer_text;
    --
  END generate_layers;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_symbols(pi_map_name IN VARCHAR2)
    RETURN CLOB IS
    --
    lv_style_def  XMLTYPE;
    lv_retval     CLOB;
    lv_symbol     CLOB;
    lv_cnt        BINARY_INTEGER;
    lv_fill       nm3type.max_varchar2;
    --
    CURSOR get_markers(cp_map_name IN VARCHAR2)
        IS
    SELECT uss.name
          ,uss.definition
      FROM user_sdo_styles uss
          ,(SELECT DISTINCT name
              FROM (SELECT uss1.name
                      FROM user_sdo_styles uss1
                          ,(SELECT style_name
                              FROM (SELECT styling_rules
                                      FROM user_sdo_themes
                                     WHERE name IN(SELECT map_themes.name
                                                     FROM user_sdo_maps maps
                                                         ,XMLTABLE('/map_definition/theme'
                                                                   PASSING XMLTYPE(maps.definition)
                                                                   COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                    WHERE maps.name = cp_map_name)) theme_rules
                                  ,XMLTABLE('/styling_rules/rule'
                                            PASSING XMLTYPE(theme_rules.styling_rules)
                                            COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles1
                     WHERE styles1.style_name = uss1.name
                       AND uss1.type = 'MARKER'
                       AND NVL(dbms_lob.getlength(uss1.image),0) = 0
                     UNION ALL
                    SELECT uss2.name
                      FROM user_sdo_styles uss2
                          ,(SELECT bucket_style
                              FROM (SELECT adv_uss.definition
                                      FROM user_sdo_styles adv_uss
                                          ,(SELECT style_name
                                              FROM (SELECT styling_rules
                                                      FROM user_sdo_themes
                                                     WHERE name IN(SELECT map_themes.name
                                                                     FROM user_sdo_maps maps
                                                                         ,XMLTABLE('/map_definition/theme'
                                                                                   PASSING XMLTYPE(maps.definition)
                                                                                   COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                                    WHERE maps.name = cp_map_name)) theme_rules
                                                  ,XMLTABLE('/styling_rules/rule'
                                                            PASSING XMLTYPE(theme_rules.styling_rules)
                                                            COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles2
                                     WHERE styles2.style_name = adv_uss.name
                                       AND adv_uss.type = 'ADVANCED') adv_defs
                                  ,XMLTABLE('/AdvancedStyle/BucketStyle/Buckets/CollectionBucket'
                                            PASSING XMLTYPE(adv_defs.definition)
                                            COLUMNS bucket_style VARCHAR2(100) path '@style') collection_buckets) adv_styles
                     WHERE adv_styles.bucket_style = uss2.name
                       AND uss2.type = 'MARKER'
                       AND NVL(dbms_lob.getlength(uss2.image),0) = 0)) map_styles
     WHERE map_styles.name = uss.name
    ;
    --
    CURSOR get_line_markers(cp_map_name IN VARCHAR2)
        IS
    SELECT uss.name
          ,uss.definition
      FROM user_sdo_styles uss
          ,(SELECT DISTINCT name
              FROM (SELECT awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss1.definition),'/svg/g/@style'),'marker-name:') name
                      FROM user_sdo_styles uss1
                          ,(SELECT style_name
                              FROM (SELECT styling_rules
                                      FROM user_sdo_themes
                                     WHERE name IN(SELECT map_themes.name
                                                     FROM user_sdo_maps maps
                                                         ,XMLTABLE('/map_definition/theme'
                                                                   PASSING XMLTYPE(maps.definition)
                                                                   COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                    WHERE maps.name = cp_map_name)) theme_rules
                                  ,XMLTABLE('/styling_rules/rule'
                                            PASSING XMLTYPE(theme_rules.styling_rules)
                                            COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles1
                     WHERE styles1.style_name = uss1.name
                       AND uss1.type = 'LINE'
                       AND awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss1.definition),'/svg/g/@style'),'marker-name:') IS NOT NULL
                     UNION ALL
                    SELECT awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss2.definition),'/svg/g/@style'),'marker-name:') name
                      FROM user_sdo_styles uss2
                          ,(SELECT bucket_style
                              FROM (SELECT adv_uss.definition
                                      FROM user_sdo_styles adv_uss
                                          ,(SELECT style_name
                                              FROM (SELECT styling_rules
                                                      FROM user_sdo_themes
                                                     WHERE name IN(SELECT map_themes.name
                                                                     FROM user_sdo_maps maps
                                                                         ,XMLTABLE('/map_definition/theme'
                                                                                   PASSING XMLTYPE(maps.definition)
                                                                                   COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                                    WHERE maps.name = cp_map_name)) theme_rules
                                                  ,XMLTABLE('/styling_rules/rule'
                                                            PASSING XMLTYPE(theme_rules.styling_rules)
                                                            COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles2
                                     WHERE styles2.style_name = adv_uss.name
                                       AND adv_uss.type = 'ADVANCED') adv_defs
                                  ,XMLTABLE('/AdvancedStyle/BucketStyle/Buckets/CollectionBucket'
                                            PASSING XMLTYPE(adv_defs.definition)
                                            COLUMNS bucket_style VARCHAR2(100) path '@style') collection_buckets) adv_styles
                     WHERE adv_styles.bucket_style = uss2.name
                       AND uss2.type = 'LINE'
                       AND awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss2.definition),'/svg/g/@style'),'marker-name:') IS NOT NULL)) map_styles
     WHERE map_styles.name = uss.name
    ;
    --
    TYPE marker_rec IS RECORD(name        user_sdo_styles.name%TYPE
                             ,definition  user_sdo_styles.definition%TYPE);
    TYPE marker_tab IS TABLE OF marker_rec;
    lt_markers  marker_tab;
    lt_line_markers  marker_tab;
    --
    CURSOR get_svg_data(cp_xml IN XMLTYPE)
        IS
    SELECT EXTRACTVALUE(cp_xml,'/svg/g/@class') g_class
          ,EXTRACTVALUE(cp_xml,'/svg/g/@style') g_style
          ,EXTRACTVALUE(cp_xml,'/svg/g/*/@points') g_points
      FROM dual
         ;
    --
    lr_svg_data  get_svg_data%ROWTYPE;
    --
    lt_points  nm3type.tab_varchar32767;
    --
    FUNCTION already_processed(pi_markers IN marker_tab
                              ,pi_name    IN user_sdo_styles.name%TYPE)
      RETURN BOOLEAN IS
      --
      lv_found  BOOLEAN := FALSE;
      --
    BEGIN
      --
      FOR i IN 1..pi_markers.COUNT LOOP
        --
        IF pi_markers(i).name = pi_name
         THEN
            lv_found := TRUE;
            EXIT;
        END IF;
        --
      END LOOP;
      --
      RETURN lv_found;
      --
    END already_processed;
    --
  BEGIN
    /*
    ||Start the file and add standard symbols.
    */
    lv_retval := '  SYMBOL'
      ||CHR(10)||'    NAME "circle_filled"'
      ||CHR(10)||'    TYPE ELLIPSE'
      ||CHR(10)||'    FILLED TRUE'
      ||CHR(10)||'    POINTS'
      ||CHR(10)||'      1 1'
      ||CHR(10)||'    END'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  SYMBOL'
      ||CHR(10)||'    NAME "square_filled"'
      ||CHR(10)||'    TYPE VECTOR'
      ||CHR(10)||'    FILLED TRUE'
      ||CHR(10)||'    POINTS'
      ||CHR(10)||'      0 1'
      ||CHR(10)||'      0 0'
      ||CHR(10)||'      1 0'
      ||CHR(10)||'      1 1'
      ||CHR(10)||'      0 1'
      ||CHR(10)||'    END'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  SYMBOL'
      ||CHR(10)||'    NAME "vert_line"'
      ||CHR(10)||'    TYPE vector'
      ||CHR(10)||'    POINTS'
      ||CHR(10)||'      0 0'
      ||CHR(10)||'      0 10'
      ||CHR(10)||'    END'
      ||CHR(10)||'  END'
    ;
    /*
    ||Get markers used by themes in the given map.
    */
    OPEN  get_markers(pi_map_name);
    FETCH get_markers
     BULK COLLECT
     INTO lt_markers;
    CLOSE get_markers;
    /*
    ||Convert the markers to symbols.
    */
    FOR i IN 1..lt_markers.COUNT LOOP
      --
      lv_style_def := XMLTYPE(lt_markers(i).definition);
      --
      OPEN  get_svg_data(lv_style_def);
      FETCH get_svg_data
       INTO lr_svg_data;
      CLOSE get_svg_data;
      --
      IF lr_svg_data.g_points IS NOT NULL
       THEN
          --
          lv_symbol := NULL;
          --
          lv_fill := get_style_value(pi_style => lr_svg_data.g_style
                                    ,pi_field => 'fill:');
          --
          lt_points := awlrs_util.tokenise_string(pi_string => lr_svg_data.g_points);
          --
          lv_symbol := lv_symbol
            ||CHR(10)||''
            ||CHR(10)||'  SYMBOL'
            ||CHR(10)||'    NAME "'||lt_markers(i).name||'"'
            ||CHR(10)||'    TYPE vector'
            ||CHR(10)||'    POINTS'
          ;
          --
          lv_cnt := 1;
          WHILE lv_cnt < lt_points.COUNT LOOP
            lv_symbol := lv_symbol||CHR(10)||'     '||lt_points(lv_cnt);
            lv_cnt := lt_points.NEXT(lv_cnt);
            lv_symbol := lv_symbol||' '||lt_points(lv_cnt);
            lv_cnt := lt_points.NEXT(lv_cnt);
          END LOOP;
          --
          lv_symbol := lv_symbol
            ||CHR(10)||'    END'
          ;
          --
          IF lv_fill IS NOT NULL
           THEN
              lv_symbol := lv_symbol
                ||CHR(10)||'    FILLED TRUE'
              ;
          END IF;
          --
          lv_symbol := lv_symbol
            ||CHR(10)||'  END'
          ;
          --
          lv_retval := lv_retval||lv_symbol;
          --
      END IF;
      --
    END LOOP;
    /*
    ||Get line markers used by themes in the given map.
    */
    OPEN  get_line_markers(pi_map_name);
    FETCH get_line_markers
     BULK COLLECT
     INTO lt_line_markers;
    CLOSE get_line_markers;
    /*
    ||Convert the markers to symbols.
    */
    FOR i IN 1..lt_line_markers.COUNT LOOP
      --
      lv_style_def := XMLTYPE(lt_line_markers(i).definition);
      --
      OPEN  get_svg_data(lv_style_def);
      FETCH get_svg_data
       INTO lr_svg_data;
      CLOSE get_svg_data;
      --
      IF lr_svg_data.g_points IS NOT NULL
       THEN
          --
          lv_symbol := NULL;
          --
          lv_fill := get_style_value(pi_style => lr_svg_data.g_style
                                    ,pi_field => 'fill:');
          --
          lt_points := awlrs_util.tokenise_string(pi_string => lr_svg_data.g_points);
          --
          lv_symbol := lv_symbol
            ||CHR(10)||'  SYMBOL'
            ||CHR(10)||'    NAME "'||lt_line_markers(i).name||'"'
            ||CHR(10)||'    TYPE vector'
            ||CHR(10)||'    POINTS'
          ;
          --
          lv_cnt := 1;
          WHILE lv_cnt < lt_points.COUNT LOOP
            lv_symbol := lv_symbol||CHR(10)||'     '||lt_points(lv_cnt);
            lv_cnt := lt_points.NEXT(lv_cnt);
            lv_symbol := lv_symbol||' '||lt_points(lv_cnt);
            lv_cnt := lt_points.NEXT(lv_cnt);
          END LOOP;
          --
          lv_symbol := lv_symbol
            ||CHR(10)||'    END'
          ;
          --
          IF lv_fill IS NOT NULL
           THEN
              lv_symbol := lv_symbol
                ||CHR(10)||'    FILLED TRUE'
              ;
          END IF;
          --
          lv_symbol := lv_symbol
            ||CHR(10)||'  END'
          ;
          --
          IF NOT already_processed(pi_markers => lt_markers
                                  ,pi_name    => lt_line_markers(i).name)
           THEN
              /*
              ||Add the basic marker.
              */
              lv_retval := lv_retval||CHR(10)||lv_symbol;
          END IF;
          /*
          ||Add the start and end markers.
          */
          lv_retval := lv_retval||CHR(10)||REPLACE(lv_symbol,'NAME "'||lt_line_markers(i).name||'"','NAME "'||lt_line_markers(i).name||'_START"'||CHR(10)||'    ANCHORPOINT 0 0.5');
          lv_retval := lv_retval||CHR(10)||REPLACE(lv_symbol,'NAME "'||lt_line_markers(i).name||'"','NAME "'||lt_line_markers(i).name||'_END"'||CHR(10)||'    ANCHORPOINT 1 0.5');
          --
      END IF;
      --
    END LOOP;
    --
    RETURN lv_retval;
    --
  END generate_symbols;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION generate_map_file(pi_map_name       IN VARCHAR2
                            ,pi_proj_lib       IN VARCHAR2
                            ,pi_all_ft_cols    IN VARCHAR2 DEFAULT 'N'
                            ,pi_effective_date IN DATE DEFAULT NULL)
    RETURN CLOB IS
    --
    lv_retval  CLOB;
    --
    lr_usm  user_sdo_maps%ROWTYPE;
    --
    lt_wms_layers  clob_tab;
    lt_layers      clob_tab;
    --
    lv_output_epsg  hig_option_values.hov_value%TYPE := hig.get_sysopt('AWLMAPEPSG');
    lv_wms_srs  nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||Get the map details;
    */
    lr_usm := get_usm(pi_map_name => pi_map_name);
    /*
    ||Set the debug global.
    */
    g_debug := NVL(hig.get_sysopt('AWLMAPDBUG'),'N');
    /*
    ||Get the layer details.
    */
    lt_wms_layers := generate_wms_layers(pi_definition => lr_usm.definition);
    lt_layers := generate_layers(pi_definition     => lr_usm.definition
                                ,pi_all_ft_cols    => pi_all_ft_cols
                                ,pi_effective_date => pi_effective_date);
    /*
    ||Create the wms_srs text.
    */
    IF gt_epsg.COUNT = 0
     THEN
        gt_epsg(1) := lv_output_epsg;
    END IF;
    --
    FOR i IN 1..gt_epsg.COUNT LOOP
      --
      lv_wms_srs := lv_wms_srs||'EPSG:'||gt_epsg(i)||' ';
      --
    END LOOP;
    /*
    ||Add the output projection to the epsg list if needed.
    */
    IF gt_epsg.COUNT < 2
     OR gt_epsg(gt_epsg.COUNT) != lv_output_epsg
     THEN
        lv_wms_srs := lv_wms_srs||'EPSG:'||lv_output_epsg||' ';
    END IF;
    /*
    ||Write the map file.
    */
    lv_retval := 'MAP'
      ||CHR(10)||'  NAME "'||lr_usm.name||'"'
      ||CHR(10)||'  EXTENT '||g_min_x||' '||g_min_y||' '||g_max_x||' '||g_max_y
      ||CHR(10)||'  UNITS DD'
      ||CHR(10)||'  IMAGECOLOR 255 255 255'
      ||CHR(10)||'  FONTSET "fonts.list"'
    ;
    IF g_debug = 'Y'
     THEN
        lv_retval := lv_retval||CHR(10)||'  CONFIG "MS_ERRORFILE" "%user%.log"'
                              ||CHR(10)||'  DEBUG 5'
                              ||CHR(10)||''
        ;
    END IF;
    --
    lv_retval := lv_retval
      ||CHR(10)||'  WEB'
      ||CHR(10)||'    METADATA'
      ||CHR(10)||'      "ows_enable_request"          "*"'
      ||CHR(10)||'      "wms_onlineresource"          "http://localhost/cgi-bin/mapserv"'
      ||CHR(10)||'      "wfs_onlineresource"          "http://localhost/cgi-bin/mapserv"'
      ||CHR(10)||'      "wms_title"                   "WMS '||NVL(lr_usm.description,lr_usm.name)||'"'
      ||CHR(10)||'      "wfs_title"                   "WFS '||NVL(lr_usm.description,lr_usm.name)||'"'
      ||CHR(10)||'      "wms_srs"                     "'||lv_wms_srs||'"'
      ||CHR(10)||'      "wfs_srs"                     "'||lv_wms_srs||'"'
      ||CHR(10)||'      "wfs_abstract"                "Bentley AWLRS Service."'
      ||CHR(10)||'      "wfs_request_method"          "GET"'
      ||CHR(10)||'      "wfs_enable_request"          "*"'
      ||CHR(10)||'      "wms_enable_request"          "*"'
      ||CHR(10)||'      "wms_feature_info_mime_type"  "text/html"'
      ||CHR(10)||'      "tile_map_edge_buffer"        "64"' --rendering buffer in pixels
      ||CHR(10)||'    END'
      ||CHR(10)||'  END'
      ||CHR(10)||'  CONFIG "PROJ_LIB" "'||pi_proj_lib||'"'
      ||CHR(10)||'  CONFIG MS_ENCRYPTION_KEY "mapserver.key"'
      ||CHR(10)||'  PROJECTION'
      ||CHR(10)||'    "init=epsg:'||lv_output_epsg||'"'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  OUTPUTFORMAT'
      ||CHR(10)||'    NAME "png"'
      ||CHR(10)||'    DRIVER AGG/PNG'
      ||CHR(10)||'    MIMETYPE "image/png"'
      ||CHR(10)||'    IMAGEMODE RGBA'
      ||CHR(10)||'    EXTENSION "png"'
      ||CHR(10)||'    FORMATOPTION "GAMMA=0.75"'
      ||CHR(10)||'    TRANSPARENT ON'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  OUTPUTFORMAT'
      ||CHR(10)||'    NAME "JSON"'
      ||CHR(10)||'    DRIVER "OGR/GeoJSON"'
      ||CHR(10)||'    MIMETYPE "application/x-javascript"'
      ||CHR(10)||'    FORMATOPTION "LCO:COORDINATE_PRECISION=4"'
      ||CHR(10)||'    FORMATOPTION "STORAGE=memory"'
      ||CHR(10)||'    FORMATOPTION "FORM=simple"'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  OUTPUTFORMAT'
      ||CHR(10)||'    NAME "CSV"'
      ||CHR(10)||'    DRIVER "OGR/CSV"'
      ||CHR(10)||'    MIMETYPE "text/csv"'
      ||CHR(10)||'    FORMATOPTION "LCO:GEOMETRY=AS_WKT"'
      ||CHR(10)||'    FORMATOPTION "STORAGE=filesystem"'
      ||CHR(10)||'    FORMATOPTION "FORM=simple"'
      ||CHR(10)||'    FORMATOPTION "FILENAME=result.csv"'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  OUTPUTFORMAT'
      ||CHR(10)||'    NAME "SHAPEZIP"'
      ||CHR(10)||'    DRIVER "OGR/ESRI Shapefile"'
      ||CHR(10)||'    MIMETYPE "application/shapefile"'
      ||CHR(10)||'    FORMATOPTION "STORAGE=filesystem"'
      ||CHR(10)||'    FORMATOPTION "FORM=zip"'
      ||CHR(10)||'    FORMATOPTION "LCO:SPATIAL_INDEX=YES"'
      ||CHR(10)||'    FORMATOPTION "FILENAME=result.zip"'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||'  LEGEND'
      ||CHR(10)||'    KEYSIZE 22 12'
      ||CHR(10)||'    KEYSPACING 8 8'
      ||CHR(10)||'    LABEL'
      ||CHR(10)||'      FONT "MicrosoftSansSerifRegular"'
      ||CHR(10)||'      SIZE 10'
      ||CHR(10)||'      TYPE TRUETYPE'
      ||CHR(10)||'    END # LABEL'
      ||CHR(10)||'    STATUS OFF'
      ||CHR(10)||'  END'
      ||CHR(10)||''
      ||CHR(10)||generate_symbols(pi_map_name => pi_map_name)
      ||CHR(10)||''
    ;
    /*
    ||Add the layers.
    */
    FOR i IN 1..lt_wms_layers.COUNT LOOP
      --
      lv_retval := lv_retval||CHR(10)||lt_wms_layers(i);
      --
    END LOOP;
    --
    FOR i IN 1..lt_layers.COUNT LOOP
      --
      lv_retval := lv_retval||CHR(10)||lt_layers(i);
      --
    END LOOP;
    /*
    ||Complete the map file.
    */
    lv_retval := lv_retval||CHR(10)||'END #mapfile';
    /*
    ||Return the map file.
    */
    RETURN lv_retval;
    --
  END generate_map_file;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_map_file(pi_map_name         IN  VARCHAR2
                        ,pi_proj_lib         IN  VARCHAR2
                        ,pi_all_ft_cols      IN  VARCHAR2 DEFAULT 'N'
                        ,pi_effective_date   IN  DATE DEFAULT NULL
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor
                        ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT awlrs_map_api.generate_map_file(pi_map_name       => pi_map_name
                                          ,pi_proj_lib       => pi_proj_lib
                                          ,pi_all_ft_cols    => pi_all_ft_cols
                                          ,pi_effective_date => pi_effective_date)
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
  END get_map_file;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_marker_files(pi_map_name         IN  VARCHAR2
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT awlrs_map_api.get_marker_filename(uss.name) file_name
          ,uss.image file_content
      FROM user_sdo_styles uss
     WHERE uss.name IN(SELECT uss1.name
                         FROM user_sdo_styles uss1
                             ,(SELECT style_name
                                 FROM (SELECT styling_rules
                                         FROM user_sdo_themes
                                        WHERE name IN(SELECT map_themes.name
                                                        FROM user_sdo_maps maps
                                                            ,XMLTABLE('/map_definition/theme'
                                                                      PASSING XMLTYPE(maps.definition)
                                                                      COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                       WHERE maps.name = pi_map_name)) theme_rules
                                     ,XMLTABLE('/styling_rules/rule'
                                               PASSING XMLTYPE(theme_rules.styling_rules)
                                               COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles1
                        WHERE styles1.style_name = uss1.name
                          AND uss1.type = 'MARKER'
                          AND dbms_lob.getlength(uss1.image) > 0
                       UNION ALL
                       SELECT uss2.name
                         FROM user_sdo_styles uss2
                             ,(SELECT bucket_style
                                 FROM (SELECT adv_uss.definition
                                         FROM user_sdo_styles adv_uss
                                             ,(SELECT style_name
                                                 FROM (SELECT styling_rules
                                                         FROM user_sdo_themes
                                                        WHERE name IN(SELECT map_themes.name
                                                                        FROM user_sdo_maps maps
                                                                            ,XMLTABLE('/map_definition/theme'
                                                                                      PASSING XMLTYPE(maps.definition)
                                                                                      COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                                       WHERE maps.name = pi_map_name)) theme_rules
                                                     ,XMLTABLE('/styling_rules/rule'
                                                               PASSING XMLTYPE(theme_rules.styling_rules)
                                                               COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles2
                                        WHERE styles2.style_name = adv_uss.name
                                          AND adv_uss.type = 'ADVANCED') adv_defs
                                     ,XMLTABLE('/AdvancedStyle/BucketStyle/Buckets/CollectionBucket'
                                               PASSING XMLTYPE(adv_defs.definition)
                                               COLUMNS bucket_style VARCHAR2(100) path '@style') collection_buckets) adv_styles
                        WHERE adv_styles.bucket_style = uss2.name
                          AND uss2.type = 'MARKER'
                          AND dbms_lob.getlength(uss2.image) > 0
                       UNION ALL
                       SELECT uss3.name
                         FROM user_sdo_styles uss3
                             ,(SELECT DISTINCT name
                                 FROM (SELECT awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss4.definition),'/svg/g/@style'),'marker-name:') name
                                         FROM user_sdo_styles uss4
                                             ,(SELECT style_name
                                                 FROM (SELECT styling_rules
                                                         FROM user_sdo_themes
                                                        WHERE name IN(SELECT map_themes.name
                                                                        FROM user_sdo_maps maps
                                                                            ,XMLTABLE('/map_definition/theme'
                                                                                      PASSING XMLTYPE(maps.definition)
                                                                                      COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                                       WHERE maps.name = pi_map_name)) theme_rules
                                                     ,XMLTABLE('/styling_rules/rule'
                                                               PASSING XMLTYPE(theme_rules.styling_rules)
                                                               COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles1
                                        WHERE styles1.style_name = uss4.name
                                          AND uss4.type = 'LINE'
                                          AND awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss4.definition),'/svg/g/@style'),'marker-name:') IS NOT NULL
                                        UNION ALL
                                       SELECT awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss5.definition),'/svg/g/@style'),'marker-name:') name
                                         FROM user_sdo_styles uss5
                                             ,(SELECT bucket_style
                                                 FROM (SELECT adv_uss2.definition
                                                         FROM user_sdo_styles adv_uss2
                                                             ,(SELECT style_name
                                                                 FROM (SELECT styling_rules
                                                                         FROM user_sdo_themes
                                                                        WHERE name IN(SELECT map_themes.name
                                                                                        FROM user_sdo_maps maps
                                                                                            ,XMLTABLE('/map_definition/theme'
                                                                                                      PASSING XMLTYPE(maps.definition)
                                                                                                      COLUMNS name  VARCHAR2(100) path '@name') map_themes
                                                                                       WHERE maps.name = pi_map_name)) theme_rules
                                                                     ,XMLTABLE('/styling_rules/rule'
                                                                               PASSING XMLTYPE(theme_rules.styling_rules)
                                                                               COLUMNS style_name VARCHAR2(100) path '/rule/features/@style')) styles2
                                                        WHERE styles2.style_name = adv_uss2.name
                                                          AND adv_uss2.type = 'ADVANCED') adv_defs
                                                     ,XMLTABLE('/AdvancedStyle/BucketStyle/Buckets/CollectionBucket'
                                                               PASSING XMLTYPE(adv_defs.definition)
                                                               COLUMNS bucket_style VARCHAR2(100) path '@style') collection_buckets) adv_styles
                                        WHERE adv_styles.bucket_style = uss5.name
                                          AND uss5.type = 'LINE'
                                          AND awlrs_map_api.get_style_value(EXTRACTVALUE(XMLTYPE(uss5.definition),'/svg/g/@style'),'marker-name:') IS NOT NULL)) map_styles
                        WHERE map_styles.name = uss3.name
                          AND dbms_lob.getlength(uss3.image) > 0)
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
  END get_marker_files;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_tooltip_template(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT tag_value file_content
      FROM (SELECT LTRIM(RTRIM(EXTRACTVALUE(a.column_value,'/tag/name'))) tag_name
                  ,LTRIM(RTRIM(EXTRACTVALUE(a.column_value,'/tag/value'))) tag_value
              FROM user_sdo_themes themes
                  ,XMLTABLE('/styling_rules/custom_tags/tag'
                            PASSING XMLTYPE(themes.styling_rules)) a
             WHERE themes.name = pi_theme_name) custom_tags
     WHERE tag_name = 'TooltipTemplate'
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
  END get_tooltip_template;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_tooltip_templates(pi_map_name         IN  VARCHAR2
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT REPLACE(UPPER(name), ' ','')||'Template.html' file_name
          ,tag_value                                     file_content
      FROM (SELECT themes.name
                  ,LTRIM(RTRIM(EXTRACTVALUE(a.column_value,'/tag/name'))) tag_name
                  ,LTRIM(RTRIM(EXTRACTVALUE(a.column_value,'/tag/value'))) tag_value
              FROM user_sdo_themes themes
                  ,XMLTABLE('/styling_rules/custom_tags/tag'
                            PASSING XMLTYPE(themes.styling_rules)) a
             WHERE themes.name IN (SELECT map_themes.name
                                     FROM user_sdo_maps usm
                                         ,XMLTABLE('/map_definition/theme'
                                                   PASSING XMLTYPE(definition)
                                                   COLUMNS name VARCHAR2(32) path '@name') map_themes
                                    WHERE usm.name = pi_map_name)) custom_tags
     WHERE tag_name = 'TooltipTemplate'
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
  END get_tooltip_templates;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE save_home_extent(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                            ,pi_data             IN  awlrs_saved_map_configs.asmc_data%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    MERGE INTO awlrs_saved_map_configs asmc
      USING (SELECT SYS_CONTEXT('NM3CORE', 'USER_ID') user_id
                   ,pi_product param_product
                   ,pi_product||' HOME EXTENT' param_name
                   ,'Y' param_home_extent
                   ,pi_data param_data
               FROM dual) param
         ON (asmc.asmc_home_extent = param_home_extent
             AND asmc.asmc_product = param.param_product
             AND asmc.asmc_name = param.param_name
             AND asmc.asmc_user_id = param.user_id)
      WHEN MATCHED
       THEN
          UPDATE SET asmc.asmc_data = param.param_data
      WHEN NOT MATCHED
       THEN
          INSERT(asmc_id
                ,asmc_user_id
                ,asmc_product
                ,asmc_name
                ,asmc_home_extent
                ,asmc_data)
          VALUES(asmc_id_seq.NEXTVAL
                ,param.user_id
                ,param.param_product
                ,param.param_name
                ,'Y'
                ,param.param_data)
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END save_home_extent;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_home_extent_data(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asmc_data
      FROM awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_product = pi_product
       AND asmc_home_extent = 'Y'
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
  END get_home_extent_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE save_map_config(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                           ,pi_name             IN  awlrs_saved_map_configs.asmc_name%TYPE
                           ,pi_data             IN  awlrs_saved_map_configs.asmc_data%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    MERGE INTO awlrs_saved_map_configs asmc
      USING (SELECT SYS_CONTEXT('NM3CORE', 'USER_ID') user_id
                   ,pi_product param_product
                   ,pi_name param_name
                   ,pi_data param_data
               FROM dual) param
         ON (asmc.asmc_product = param.param_product
             AND asmc.asmc_name = param.param_name
             AND asmc.asmc_user_id = param.user_id)
      WHEN MATCHED
       THEN
          UPDATE SET asmc.asmc_data = param.param_data
      WHEN NOT MATCHED
       THEN
          INSERT(asmc_id
                ,asmc_user_id
                ,asmc_product
                ,asmc_name
                ,asmc_home_extent
                ,asmc_data)
          VALUES(asmc_id_seq.NEXTVAL
                ,param.user_id
                ,param.param_product
                ,param.param_name
                ,'N'
                ,param.param_data)
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END save_map_config;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_map_config(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                             ,pi_name             IN  awlrs_saved_map_configs.asmc_name%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    DELETE awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_product = pi_product
       AND asmc_name = pi_name
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_map_config;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_map_config(pi_id               IN  awlrs_saved_map_configs.asmc_id%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    DELETE awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_id = pi_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_map_config;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_map_config_data(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                               ,pi_name             IN  awlrs_saved_map_configs.asmc_name%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asmc_id
          ,asmc_name
          ,asmc_data
      FROM awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_product = pi_product
       AND asmc_name = pi_name
       AND asmc_home_extent = 'N'
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
  END get_map_config_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_map_config_data(pi_id               IN  awlrs_saved_map_configs.asmc_id%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asmc_id
          ,asmc_name
          ,asmc_data
      FROM awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_id = pi_id
       AND asmc_home_extent = 'N'
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
  END get_map_config_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_map_configs(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asmc_id
          ,asmc_name
      FROM awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_product = pi_product
       AND asmc_home_extent = 'N'
     ORDER
        BY asmc_name
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
  END get_map_configs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_map_configs_with_data(pi_product          IN  awlrs_saved_map_configs.asmc_product%TYPE
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT asmc_id
          ,asmc_name
          ,asmc_data
      FROM awlrs_saved_map_configs
     WHERE asmc_user_id = SYS_CONTEXT('NM3CORE', 'USER_ID')
       AND asmc_product = pi_product
       AND asmc_home_extent = 'N'
     ORDER
        BY asmc_name
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
  END get_map_configs_with_data;

--
-----------------------------------------------------------------------------
--
END awlrs_map_api;
/
