CREATE OR REPLACE PACKAGE BODY awlrs_copy_trace_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_copy_trace_api.pkb-arc   1.1   Mar 02 2018 13:23:14   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_copy_trace_api.pkb  $
  --       Date into PVCS   : $Date:   Mar 02 2018 13:23:14  $
  --       Date fetched Out : $Modtime:   Mar 02 2018 13:21:36  $
  --       Version          : $Revision:   1.1  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.1  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_copy_trace_api';
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
  FUNCTION is_used_for_unique(pi_nt_type IN nm_types.nt_type%TYPE
                             ,pi_column  IN nm_type_columns.ntc_column_name%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval VARCHAR2(1);
    --
    CURSOR get_column(cp_nt_type IN nm_types.nt_type%TYPE
                     ,cp_column  IN nm_type_columns.ntc_column_name%TYPE)
        IS
    SELECT CASE 
             WHEN ntc_unique_seq IS NOT NULL
              THEN
                 'Y'
             ELSE
                 'N'
           END CASE
      FROM nm_type_columns
     WHERE ntc_nt_type = cp_nt_type
       AND ntc_column_name = cp_column
         ;
    --
  BEGIN
    --
    IF pi_column = 'NE_UNIQUE'
     THEN
        lv_retval := 'Y';
    ELSE
        --
        OPEN  get_column(pi_nt_type,pi_column);
        FETCH get_column
         INTO lv_retval;
        --
        IF get_column%NOTFOUND
         THEN
            lv_retval := 'N';
        END IF;
        --
        CLOSE get_column;
        --
    END IF;
    --
    RETURN lv_retval;
    --
  END is_used_for_unique;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_file_feature_map(pi_file_descr          IN     awlrs_file_feature_maps.affm_file_descr%TYPE
                                ,pi_datum_nt            IN     awlrs_file_feature_maps.affm_datum_nt%TYPE
                                ,po_file_feature_map_id IN OUT awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_id  awlrs_file_feature_maps.affm_id%TYPE;
    --
  BEGIN
    --
    IF nm3net.is_nt_datum(p_nt_type => pi_datum_nt) != 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 169
                     ,pi_supplementary_info => pi_datum_nt);
    END IF;
    --
    lv_id := affm_id_seq.NEXTVAL;
    --
    INSERT
      INTO awlrs_file_feature_maps
          (affm_id
          ,affm_file_descr
          ,affm_datum_nt) 
    VALUES(lv_id
          ,pi_file_descr
          ,pi_datum_nt)
         ;
    --
    po_file_feature_map_id := lv_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_file_feature_map;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_file_feature_maps(po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM awlrs_file_feature_maps
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
  END get_file_feature_maps;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_group_attrib_map(pi_file_feature_map_id IN     awlrs_file_grp_attrib_map.afgam_affm_id%TYPE
                                ,pi_target_nt           IN     awlrs_file_grp_attrib_map.afgam_target_nt%TYPE
                                ,pi_target_gty          IN     awlrs_file_grp_attrib_map.afgam_target_gty%TYPE
                                ,pi_file_attrib         IN     awlrs_file_grp_attrib_map.afgam_file_attrib%TYPE
                                ,pi_target_attrib       IN     awlrs_file_grp_attrib_map.afgam_target_attrib%TYPE
                                ,po_file_grp_attrib_id  IN OUT awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_id  awlrs_file_grp_attrib_map.afgam_id%TYPE;
    --
  BEGIN
    --
    lv_id := afgam_id_seq.NEXTVAL;
    --
    INSERT
      INTO awlrs_file_grp_attrib_map
          (afgam_id
          ,afgam_affm_id
          ,afgam_target_nt
          ,afgam_target_gty
          ,afgam_file_attrib
          ,afgam_target_attrib) 
    VALUES(lv_id
          ,pi_file_feature_map_id
          ,pi_target_nt
          ,pi_target_gty
          ,pi_file_attrib
          ,pi_target_attrib)
         ;
    --
    po_file_grp_attrib_id := lv_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_group_attrib_map;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_group_attrib_map(pi_affm_id          IN  awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM awlrs_file_grp_attrib_map
     WHERE afgam_affm_id = pi_affm_id
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
  END get_group_attrib_map;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_datum_attrib_map(pi_affm_id          IN  awlrs_file_feature_maps.affm_id%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT afdam_id
          ,afdam_affm_id
          ,afdam_file_attrib
          ,afdam_target_attrib
          ,awlrs_copy_trace_api.is_used_for_unique(affm_datum_nt
                                                  ,afdam_target_attrib) used_in_unique
      FROM awlrs_file_datum_attrib_map
          ,awlrs_file_feature_maps
     WHERE affm_id = pi_affm_id
       AND affm_id = afdam_affm_id
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
  END get_datum_attrib_map;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_auto_inclusion_types(pi_datumn_nt        IN  nm_types.nt_type%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nti_nw_parent_type parent_nt
          ,ngt_group_type     parent_gty
          ,nti_auto_create    auto_create
          ,nt_admin_type      admin_type
      FROM nm_type_inclusion
          ,nm_group_types
          ,nm_types
     WHERE nti_nw_child_type = pi_datumn_nt
       AND nti_nw_parent_type = ngt_nt_type
       AND ngt_nt_type = nt_type
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
  END get_auto_inclusion_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_parent_ne_id(pi_parent_nt        IN  nm_elements.ne_nt_type%TYPE
                            ,pi_ne_unique        IN  nm_elements.ne_unique%TYPE
                            ,pi_ne_owner         IN  nm_elements.ne_owner%TYPE
                            ,pi_ne_name_1        IN  nm_elements.ne_name_1%TYPE
                            ,pi_ne_name_2        IN  nm_elements.ne_name_2%TYPE
                            ,pi_ne_prefix        IN  nm_elements.ne_prefix%TYPE
                            ,pi_ne_number        IN  nm_elements.ne_number%TYPE
                            ,pi_ne_sub_type      IN  nm_elements.ne_sub_type%TYPE
                            ,pi_ne_no_start      IN  nm_elements.ne_no_start%TYPE
                            ,pi_ne_no_end        IN  nm_elements.ne_no_end%TYPE
                            ,pi_ne_sub_class     IN  nm_elements.ne_sub_class%TYPE
                            ,pi_ne_nsg_ref       IN  nm_elements.ne_nsg_ref%TYPE
                            ,pi_ne_version_no    IN  nm_elements.ne_version_no%TYPE
                            ,pi_ne_group         IN  nm_elements.ne_group%TYPE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_unique  nm_elements.ne_unique%TYPE;
    --
  BEGIN
    --
    IF pi_ne_unique IS NOT NULL
     AND NOT nm3net.is_pop_unique(pi_parent_nt)
     THEN
        lv_unique := pi_ne_unique;
    ELSE
        nm3nwval.create_ne_unique(p_ne_unique     => lv_unique    
                                 ,p_ne_nt_type    => pi_parent_nt    
                                 ,p_ne_owner      => pi_ne_owner      
                                 ,p_ne_name_1     => pi_ne_name_1     
                                 ,p_ne_name_2     => pi_ne_name_2     
                                 ,p_ne_prefix     => pi_ne_prefix     
                                 ,p_ne_number     => pi_ne_number     
                                 ,p_ne_sub_type   => pi_ne_sub_type   
                                 ,p_ne_no_start   => pi_ne_no_start   
                                 ,p_ne_no_end     => pi_ne_no_end     
                                 ,p_ne_sub_class  => pi_ne_sub_class  
                                 ,p_ne_nsg_ref    => pi_ne_nsg_ref    
                                 ,p_ne_version_no => pi_ne_version_no 
                                 ,p_ne_group      => pi_ne_group);
    END IF;
    --
    OPEN po_cursor FOR
    SELECT ne_id
          ,ne_unique
      FROM nm_elements
     WHERE ne_nt_type = pi_parent_nt
       AND ne_unique = lv_unique
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
  END get_parent_ne_id;
  
END awlrs_copy_trace_api;
/
