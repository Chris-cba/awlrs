CREATE OR REPLACE PACKAGE BODY awlrs_asset_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_asset_api.pkb-arc   1.45   Nov 09 2020 15:30:48   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_asset_api.pkb  $
  --       Date into PVCS   : $Date:   Nov 09 2020 15:30:48  $
  --       Date fetched Out : $Modtime:   Nov 09 2020 15:13:54  $
  --       Version          : $Revision:   1.45  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.45  $';
  --
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_asset_api';
  --
  gr_nit  nm_inv_types_all%ROWTYPE;
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
  PROCEDURE init_asset_globals
    IS
    --
    lv_empty_rec  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    --
    g_db_iit_rec := lv_empty_rec;
    g_old_iit_rec := lv_empty_rec;
    g_new_iit_rec := lv_empty_rec;
    g_iit_rec := lv_empty_rec;
    --
  END init_asset_globals;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_sections_for_updates(pi_begin_sect               IN nm_elements_all.ne_id%TYPE
                                      ,pi_end_sect                 IN nm_elements_all.ne_id%TYPE
                                      ,pi_begin_sect_date_modified IN DATE
                                      ,pi_end_sect_date_modified   IN DATE)
  IS
    --
    e_section_updated EXCEPTION;
    --
    lr_ne_rec nm_elements%ROWTYPE;
    --
  BEGIN

    -----------------------------------------------------------------------------------------
    --check to make sure start or end sections have not been modified by another user between
    --selection and generation of a temp extent based on them.
    -----------------------------------------------------------------------------------------

    IF pi_begin_sect IS NOT NULL
     THEN
        --
        lr_ne_rec := nm3net.get_ne_all_rowtype(pi_ne_id => pi_begin_sect);
        --
        IF lr_ne_rec.ne_date_modified > pi_begin_sect_date_modified
         THEN
            RAISE e_section_updated;
        END IF;
    END IF;
    --
    IF pi_end_sect IS NOT NULL
     THEN
        --
        lr_ne_rec := nm3net.get_ne_all_rowtype(pi_ne_id => pi_end_sect);
        --
        IF lr_ne_rec.ne_date_modified > pi_end_sect_date_modified
         THEN
            RAISE e_section_updated;
        END IF;
    END IF;
    --
  EXCEPTION
    WHEN e_section_updated
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 133);

  END check_sections_for_updates;

  --
  --------------------------------------------------------------------------------
  --
  PROCEDURE get_lref_ambig(pi_locate_mp     IN     VARCHAR2
                          ,pi_parent_id     IN     nm_elements_all.ne_id%TYPE
                          ,pi_offset        IN     NUMBER
                          ,pi_sub_class     IN     VARCHAR2 DEFAULT NULL
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    /*e_no_datums_at_lref EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_datums_at_lref, -20015);*/
    --
    lv_ne_id       nm_elements_all.ne_id%TYPE;
    lv_offset      NUMBER;
    lt_lrefs       nm_lref_array_type := nm_lref_array_type();
    lr_ne          nm_elements%ROWTYPE;
    --
  BEGIN
    --
    IF nm3net.is_nt_datum(nm3net.get_nt_type(pi_parent_id)) = 'N'
     THEN
       IF pi_locate_mp = 'BEGIN'
        THEN
           nm3wrap.get_ambiguous_lrefs(pi_parent_id => pi_parent_id
                                      ,pi_offset    => pi_offset
                                      ,pi_sub_class => pi_sub_class
                                      ,pi_position  => 'S');
       ELSE
           nm3wrap.get_ambiguous_lrefs(pi_parent_id => pi_parent_id
                                      ,pi_offset    => pi_offset
                                      ,pi_sub_class => pi_sub_class
                                      ,pi_position  => 'E');
       END IF;
       --
       FOR i IN 1..nm3wrap.lref_count
        LOOP
           --
           nm3wrap.lref_get_row(pi_index  => i
                               ,po_ne_id  => lv_ne_id
                               ,po_offset => lv_offset);
           --
           lt_lrefs.EXTEND;
           lt_lrefs(lt_lrefs.count) := nm_lref(lv_ne_id
                                              ,lv_offset);
           --
       END LOOP;
       --
       /*
       ||sub class to update "restrict to sub class if <> S and if not null
       ||date modified to keep track of BEGIN/END pi_locate_mp in variable to call when locate asset and check if section has been updated or not.
       */
       OPEN po_cursor FOR
         SELECT pi_locate_mp location_mp
               ,lr_ne_id     element_id
               ,ne_unique    unique_id
               ,ne_descr     description
               ,lr_offset    offset
               ,ne_sub_class sub_class
               ,TO_CHAR(ne_date_modified,'DD-MON-YYYY HH24:MI:SS') date_modified
           FROM TABLE(CAST(lt_lrefs AS nm_lref_array_type))
               ,nm_elements_all
          WHERE lr_ne_id = ne_id;
       --
    ELSE
      /*
      ||if datum then populate with the details of the datum
      */
      --
      OPEN po_cursor FOR
        SELECT pi_locate_mp    location_mp
              ,ne_id           element_id
              ,ne_unique       unique_id
              ,ne_descr        description
              ,pi_offset       offset
              ,ne_sub_class    sub_class
              ,TO_CHAR(ne_date_modified,'DD-MON-YYYY HH24:MI:SS') date_modified
          FROM nm_elements_all
         WHERE ne_id = pi_parent_id;
         --
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    /*WHEN e_no_datums_at_lref
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 85);*/
    --
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_lref_ambig;

  --
  --------------------------------------------------------------------------------
  --
  PROCEDURE get_ambiguous_subclass(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor
                                  ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
       OPEN po_cursor FOR
         SELECT nsc_sub_class
               ,nsc_descr
          FROM nm_type_subclass
         WHERE nsc_nw_type = nm3net.get_datum_nt(pi_ne_id)
           AND nsc_sub_class <> 'S'
         ORDER BY nsc_seq_no;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_ambiguous_subclass;

  --
  --------------------------------------------------------------------------------
  --
  PROCEDURE get_exclusive_subclass(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                  ,po_message_severity OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor   OUT sys_refcursor
                                  ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
     SELECT nsc_sub_class
           ,nsc_descr
       FROM nm_type_subclass
      WHERE nsc_nw_type = nm3net.get_datum_nt(pi_ne_id)
      ORDER BY nsc_seq_no;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_exclusive_subclass;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION validate_location_limit(pi_itemvalue             IN NUMBER
                                  ,pi_locate_mp             IN VARCHAR2
                                  ,pi_ne_id                 IN nm_Elements.ne_id%TYPE)
    RETURN BOOLEAN IS
    --
    l_ne_rec  nm_elements%ROWTYPE;
    lv_min    NUMBER;
    l_max     NUMBER;
    lr_ne     nm_elements%ROWTYPE;
    --


  BEGIN
    --
    IF pi_ne_id IS NOT NULL
     THEN
        --
        lr_ne := nm3get.get_ne(pi_ne_id);
        --
        IF pi_itemvalue IS NOT NULL
         THEN
            IF pi_locate_mp = 'BEGIN'
             THEN
                -- Use the route min SLK  if it's a route to allow negative location
                IF lr_ne.ne_type = 'G'
                 THEN
                    lv_min := nm3net.get_min_slk(pi_ne_id);
                ELSE
                    lv_min := 0;
                END IF;
                --
                IF lv_min > pi_itemvalue
                 THEN
                    hig.raise_ner(pi_appl => 'NET'
                                 ,pi_id   => 15);
                END IF;
                --
            ELSIF pi_locate_mp = 'END'
             THEN
                -- Use the route max SLK  if it's a route to allow negative location
                IF lr_ne.ne_type = 'G'
                 THEN
                    l_max := nm3net.get_max_slk(pi_ne_id);
                ELSE
                    l_max := nm3net.get_ne_length(pi_ne_id);
                END IF;
                --
                IF pi_itemvalue > l_max
                 THEN
                    hig.raise_ner(pi_appl => 'NET'
                                 ,pi_id   => 15);
                END IF;
                --
            END IF;
            --
        END IF;
        --
    END IF;
    --
    RETURN TRUE;
    --
  END validate_location_limit;

  --
  --------------------------------------------------------------------------------
  --
  FUNCTION get_extent_location(pi_nse_id IN nm_saved_extents.nse_id%TYPE)
    RETURN nm_nw_temp_extents.nte_job_id%TYPE IS
    --
    e_no_extent_selected           EXCEPTION;
    e_extent_updated_since_created EXCEPTION;
    --
    l_job_id nm_nw_temp_extents.nte_job_id%TYPE;
    --
  BEGIN
    --
    IF pi_nse_id IS NOT NULL
     THEN
        --
        IF nm3extent.saved_ne_contents_updated(pi_nse_id => pi_nse_id)
         THEN
            RAISE e_extent_updated_since_created;
        END IF;
        --
        nm3extent.create_temp_ne(pi_source_id => pi_nse_id
                                ,pi_source    => nm3extent.get_saved
                                ,pi_begin_mp  => NULL
                                ,pi_end_mp    => NULL
                                ,po_job_id    => l_job_id);
        --
    ELSE
        --
        RAISE e_no_extent_selected;
        --
    END IF;
    --
    RETURN l_job_id;
    --
  EXCEPTION
    WHEN e_no_extent_selected
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 16);
    WHEN e_extent_updated_since_created
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 191);
  END get_extent_location;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_network_location(pi_iit_ne_id                IN nm_inv_items_all.iit_ne_id%TYPE
                               ,pi_nit_inv_type             IN nm_inv_types_all.nit_inv_type%TYPE
                               ,pi_ne_id                    IN nm_elements_all.ne_id%TYPE
                               ,pi_begin_mp                 IN nm_members_all.nm_begin_mp%TYPE
                               ,pi_end_mp                   IN nm_members_all.nm_end_mp%TYPE
                               ,pi_startdate                IN nm_members_all.nm_start_date%TYPE
                               ,pi_ne_is_datum              IN VARCHAR2
                               ,pi_begin_sect               IN nm_elements_all.ne_id%TYPE
                               ,pi_begin_sect_offset        IN NUMBER
                               ,pi_begin_sect_date_modified IN DATE
                               ,pi_end_Sect                 IN nm_elements_all.ne_id%TYPE
                               ,pi_end_sect_offset          IN NUMBER
                               ,pi_end_sect_date_modified   IN DATE
                               ,pi_ambiguous_sub_class      IN VARCHAR2
                               ,pi_restrict_excl_sub_class  IN VARCHAR2--y/n checkbox
                               ,pi_excl_sub_class           IN nm_elements_all.ne_sub_class%TYPE)
    RETURN nm_nw_temp_extents.nte_job_id%TYPE IS
    --
    lv_pnt_or_cont VARCHAR2(1);
    lv_job_id      nm_nw_temp_extents.nte_job_id%TYPE;
    lv_end_mp      nm_members_all.nm_end_mp%TYPE;
    --new params
    lv_end_sect nm_elements.ne_id%TYPE;
    lv_end_sect_offset NUMBER;
    lv_sub_class       nm_elements_all.ne_sub_class%TYPE;
    --
    e_item_not_entered EXCEPTION;
    e_validation_error EXCEPTION;
    --
  BEGIN
    /*
    ||check ne_id, begin_mp, end_mp null
    */
    IF nm3inv.get_nit_pnt_or_cont(pi_nit_inv_type) = 'P'
     THEN
        lv_pnt_or_cont := 'P';
    ELSE
        lv_pnt_or_cont := 'C';
    END IF;
    --
    IF pi_ne_id IS NULL
     THEN
        RAISE e_item_not_entered;
    END IF;
    --
    IF lv_pnt_or_cont = 'P'
     AND pi_begin_mp <> pi_end_mp
     THEN
        RAISE e_validation_error;
    END IF;
    /*
    ||Continuous checks
    */
    IF pi_begin_mp IS NULL
     THEN
        RAISE e_item_not_entered;
    ELSIF pi_end_mp IS NULL AND lv_pnt_or_cont = 'C'
     THEN
        RAISE e_item_not_entered;
    END IF;
    --
    IF NOT validate_location_limit(pi_itemvalue => pi_begin_mp
                                  ,pi_locate_mp => 'BEGIN'
                                  ,pi_ne_id     => pi_ne_id)
     THEN
        RAISE e_validation_error;
    END IF;
    --
    IF lv_pnt_or_cont = 'C'
     AND NOT validate_location_limit(pi_itemvalue => pi_end_mp
                                    ,pi_locate_mp => 'END'
                                    ,pi_ne_id     => pi_ne_id)
     THEN
        RAISE e_validation_error;
    END IF;
    --
    IF lv_pnt_or_cont = 'P'
     THEN
        lv_end_mp := pi_begin_mp;
        lv_end_sect := pi_begin_sect;
        lv_end_sect_offset := pi_begin_sect_offset;
    ELSE
        --check relative positions of start/end for continuous inventory
        IF pi_ne_is_datum = 'N'
         THEN
            nm3wrap.check_relative_start_end(pi_route        => pi_ne_id
                                            ,pi_start_sect   => pi_begin_sect
                                            ,pi_start_offset => pi_begin_sect_offset
                                            ,pi_end_sect     => pi_end_sect
                                            ,pi_end_offset   => pi_end_sect_offset);
        END IF;
        --
        lv_end_mp := pi_end_mp;
        lv_end_sect := pi_end_sect;
        lv_end_sect_offset := pi_end_sect_offset;
        --
    END IF;
    /*
    ||held locally by ui team derived from lref api when offsets are entered
    ||if null then no check will be produced.
    ||checks if datum has changed since it was selected in the dialog
    */
    check_sections_for_updates(pi_begin_sect               => pi_begin_sect
                              ,pi_end_sect                 => pi_end_Sect
                              ,pi_begin_sect_date_modified => pi_begin_sect_date_modified
                              ,pi_end_sect_date_modified   => pi_end_sect_date_modified);
    --
    IF pi_ne_is_datum = 'N'
     THEN
        --
        IF pi_restrict_excl_sub_class = 'Y'
         THEN
            lv_sub_class := pi_excl_sub_class;
        ELSE
            lv_sub_class := pi_ambiguous_sub_class;
        END IF;
        --
        nm3wrap.create_temp_ne_from_route(pi_route                   => pi_ne_id
                                         ,pi_start_ne_id             => pi_begin_sect
                                         ,pi_start_offset            => pi_begin_sect_offset
                                         ,pi_end_ne_id               => lv_end_sect
                                         ,pi_end_offset              => lv_end_sect_offset
                                         ,pi_sub_class               => lv_sub_class
                                         ,pi_restrict_excl_sub_class => pi_restrict_excl_sub_class
                                         ,pi_homo_check              => TRUE
                                         ,po_job_id                  => lv_job_id);
        --
    ELSE
        --
        nm3extent.create_temp_ne(pi_source_id => pi_ne_id
                                ,pi_source    => nm3extent.get_route
                                ,pi_begin_mp  => pi_begin_mp
                                ,pi_end_mp    => lv_end_mp
                                ,po_job_id    => lv_job_id);
        --
    END IF;
    --
    RETURN lv_job_id;
    --
  EXCEPTION
    WHEN e_item_not_entered
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 29);
    WHEN e_validation_error
     THEN
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 36);
  END get_network_location;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_xsect_allowed(pi_nit_inv_type nm_inv_types.nit_inv_type%TYPE)
    RETURN BOOLEAN IS
    --
    lr_nit nm_inv_types%ROWTYPE;
    --
  BEGIN
    --
    lr_nit := nm3get.get_nit(pi_nit_inv_type);
    --
    RETURN (lr_nit.nit_x_sect_allow_flag = 'Y');
    --
  END is_xsect_allowed;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_attrib_mandatory(pi_inv_type nm_inv_type_attribs_all.ita_inv_type%TYPE
                              ,pi_attrib_name nm_inv_type_attribs_all.ita_attrib_name%TYPE)
    RETURN BOOLEAN IS
    --
    lv_cnt NUMBER ;
    --
  BEGIN
    --
    SELECT count(ita_mandatory_yn)
      INTO lv_cnt
      FROM nm_inv_type_attribs_all
     WHERE ita_inv_type = pi_inv_type
       AND ita_attrib_name = pi_attrib_name
       AND ita_mandatory_yn = 'Y'
         ;
    --
    RETURN (lv_cnt != 0);
    --
  END is_attrib_mandatory;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_subclass_divided_highway(pi_group_type nm_group_types.ngt_group_type%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    IF NVL(hig.get_sysopt('DISAMBIGSC'),'N') = 'N'
     THEN
        lv_retval := 'N';
    ELSE
        SELECT 'Y'
          INTO lv_retval
          FROM nm_group_types
              ,nm_linear_types
         WHERE ngt_group_type = nlt_gty_type
           AND nlt_nt_type = ngt_nt_type
           AND ngt_reverse_allowed = 'N'
           AND EXISTS (SELECT 1
                         FROM nm_type_subclass
                             ,nm_nt_groupings
                        WHERE ngt_group_type = nng_group_type
                          AND nng_nt_type = nsc_nw_type)
           AND ngt_group_type = pi_group_type
             ;
    END IF;
    --
    RETURN lv_retval;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        RETURN lv_retval;
  END is_subclass_divided_highway;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_types(po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr
          ,nit_x_sect_allow_flag
          ,nit_admin_type
          ,nit_contiguous
          ,nit_update_allowed
          ,nit_top
          ,nit_category
      FROM nm_inv_types
     WHERE nit_category = 'I'--IN('I','F')
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
     ORDER
        BY nit_inv_type
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  END get_asset_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_types(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    /*
    ||Get the Asset Types that the user has access to and
    ||can be located on the given Network Element.
    */
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr
          ,nit_x_sect_allow_flag
          ,nit_admin_type
          ,nit_contiguous
          ,nit_update_allowed
          ,nit_top
          ,nit_category
      FROM nm_inv_types
     WHERE nit_category = 'I'--IN('I','F')
       AND EXISTS(SELECT 1
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
       AND nit_inv_type IN(SELECT nin_nit_inv_code
                             FROM nm_inv_nw_all
                            WHERE nin_nw_type IN(WITH element AS(SELECT ne_type
                                                                       ,ne_nt_type
                                                                       ,ne_gty_group_type
                                                                   FROM nm_elements
                                                                  WHERE ne_id = pi_ne_id)
                                                 SELECT ne_nt_type
                                                   FROM element
                                                  WHERE ne_type = 'S'
                                                     OR ne_gty_group_type IS NOT NULL
                                                 UNION ALL
                                                 SELECT nng_nt_type
                                                   FROM nm_nt_groupings
                                                       ,element
                                                  WHERE ne_gty_group_type = nng_group_type
                                                 UNION ALL
                                                 SELECT nng_nt_type
                                                   FROM nm_nt_groupings
                                                  WHERE nng_group_type IN(SELECT ngr_child_group_type
                                                                            FROM nm_group_relations
                                                                                ,element
                                                                         CONNECT BY PRIOR ngr_child_group_type = ngr_parent_group_type
                                                                           START WITH ngr_parent_group_type = ne_gty_group_type)
                                                 UNION ALL
                                                 SELECT ngt_nt_type
                                                   FROM nm_group_types
                                                       ,nm_group_relations
                                                       ,element
                                                  WHERE ngr_child_group_type = ngt_group_type
                                                CONNECT BY PRIOR ngr_child_group_type = ngr_parent_group_type
                                                   START WITH ngr_parent_group_type = ne_gty_group_type))
     ORDER
        BY nit_inv_type
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  END get_asset_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_types(pi_nt_type          IN  nm_types.nt_type%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    /*
    ||Get the Asset Types that the user has access to and
    ||can be located on the given Network Type.
    */
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr
          ,nit_x_sect_allow_flag
          ,nit_admin_type
          ,nit_contiguous
          ,nit_update_allowed
          ,nit_top
          ,nit_category
      FROM nm_inv_types
     WHERE nit_category = 'I'--IN('I','F')
       AND EXISTS(SELECT 1
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
       AND nit_inv_type IN(SELECT nin_nit_inv_code
                             FROM nm_inv_nw
                            WHERE nin_nw_type IN(SELECT nt_type
                                                   FROM nm_types
                                                  WHERE (nt_type = pi_nt_type AND nt_linear = 'Y')
                                                     OR nt_type IN(SELECT nng_nt_type
                                                                     FROM nm_nt_groupings
                                                                    WHERE nng_group_type IN(SELECT ngt_group_type
                                                                                              FROM nm_group_types
                                                                                             WHERE ngt_nt_type = pi_nt_type
                                                                                               AND ngt_linear_flag = 'Y'))))
     ORDER
        BY nit_inv_type
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  END get_asset_types;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_child_asset_types(pi_parent_type      IN  nm_inv_types_all.nit_inv_type%TYPE
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nit_inv_type
          ,nit_descr
          ,nit_x_sect_allow_flag
          ,nit_admin_type
          ,nit_contiguous
          ,nit_update_allowed
          ,nit_top
          ,nit_category
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
                             WHERE itg_parent_inv_type = pi_parent_type
                               AND itg_inv_type != pi_parent_type)
     ORDER
        BY nit_inv_type
         ;
     --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  END get_child_asset_types;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_attrib_value(pi_inv_type IN nm_inv_items.iit_inv_type%TYPE
                           ,pi_ne_id IN NM_INV_ITEMS.iit_ne_id%TYPE
                           ,pi_attrib_name IN NM_INV_TYPE_ATTRIBS.ita_attrib_name%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_sql    nm3type.max_varchar2;
    lv_value  nm3type.max_varchar2;
    --
  BEGIN
    --
    IF NVL(gr_nit.nit_inv_type,'~~~~~') != pi_inv_type
     THEN
        gr_nit := nm3get.get_nit(pi_inv_type);
    END IF;
    --
    IF gr_nit.nit_table_name IS NOT NULL
     THEN
        lv_sql := 'SELECT ' ||pi_attrib_name||' '
               ||CHR(10)||'  FROM  '||gr_nit.nit_table_name
               ||CHR(10)||'  WHERE '||gr_nit.nit_foreign_pk_column||' = :p1'
        ;
        --
        EXECUTE IMMEDIATE lv_sql INTO lv_value USING pi_ne_id;
        --
    ELSE
        lv_value := nm3inv.get_attrib_value(p_ne_id       => pi_ne_id
                                           ,p_attrib_name => pi_attrib_name);
    END IF;
    --
    RETURN lv_value;
    --
  END get_attrib_value;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_asset(pi_iit_ne_id    IN nm_inv_items_all.iit_ne_id%TYPE
                    ,pi_nit_inv_type IN nm_inv_types_all.nit_inv_type%TYPE)
    RETURN nm_inv_items_all%ROWTYPE IS
    --
    lr_retval  nm_inv_items_all%ROWTYPE;
    --
  BEGIN
    /*
    ||Make sure the asset exists.
    */
    lr_retval := nm3get.get_iit_all(pi_iit_ne_id         => pi_iit_ne_id
                                   ,pi_raise_not_found   => TRUE
                                   ,pi_not_found_sqlcode => -20001);
    --
    IF lr_retval.iit_inv_type != pi_nit_inv_type
     THEN
        --invalid Asset ID supplied
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 37);
    END IF;
    --
    RETURN lr_retval;
    --
  END get_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                     ,pi_iit_inv_type     IN  nm_inv_items_all.iit_inv_type%TYPE
                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor   OUT sys_refcursor
                     ,po_cursor           OUT sys_refcursor)
    IS
    --
    lr_iit  nm_inv_items_all%ROWTYPE;
    lr_nit  nm_inv_types_all%ROWTYPE;
    lv_sql  nm3type.max_varchar2;
    --
  BEGIN
    --
    /*
    ||Get the asset type data.
    */
    lr_nit := nm3get.get_nit(pi_iit_inv_type);
    --
    IF lr_nit.nit_table_name IS NOT NULL
     THEN
        lv_sql := 'SELECT '||lr_nit.nit_foreign_pk_column||' ne_id'
       ||CHR(10)||'      ,CAST(:invtype as VARCHAR2(4))       inv_type'
       ||CHR(10)||'      ,CAST('||lr_nit.nit_foreign_pk_column||' as VARCHAR2(50)) primary_key'
       ||CHR(10)||'      ,CAST(NULL as VARCHAR2(4))          xsp'
       ||CHR(10)||'      ,CAST(NULL as VARCHAR2(40))         description'
       ||CHR(10)||'      ,CAST(NULL as VARCHAR2(4000))       identified_by'
       ||CHR(10)||'      ,CAST(NULL as NUMBER(9))            admin_unit'
       ||CHR(10)||'      ,CAST(:invtypedesc as VARCHAR2(4000)) asset_type_description'
       ||CHR(10)||'      ,CAST(NULL as DATE)                 start_date'
       ||CHR(10)||'      ,CAST(NULL as DATE)                 end_date'
       ||CHR(10)||'      ,CAST(NULL as VARCHAR2(40))         note'
       ||CHR(10)||'      ,CAST(NULL as VARCHAR2(50))         foreign_key'
       ||CHR(10)||'  FROM  '||lr_nit.nit_table_name
       ||CHR(10)||'  WHERE '||lr_nit.nit_foreign_pk_column||' = :iit_ne_id'
        ;
        --
        OPEN po_cursor FOR lv_sql USING lr_nit.nit_inv_type, lr_nit.nit_descr, pi_iit_ne_id;
        --
    ELSE
        --
        lr_iit := get_asset(pi_iit_ne_id    => pi_iit_ne_id
                           ,pi_nit_inv_type => pi_iit_inv_type);
        --
        OPEN po_cursor FOR
        SELECT iit_ne_id                                     ne_id
              ,iit_inv_type                                  inv_type
              ,iit_primary_key                               primary_key
              ,iit_x_sect                                    xsp
              ,iit_descr                                     description
              ,nm3user.get_username(iit_peo_invent_by_id)    identified_by
              ,iit_admin_unit                                admin_unit
              ,nm3inv.get_nit_descr(iit_inv_type)            asset_type_description
              ,iit_start_date                                start_date
              ,iit_end_date                                  end_date
              ,iit_note                                      note
              ,iit_foreign_key                               foreign_key
          FROM nm_inv_items_all iit
         WHERE iit.iit_ne_id = pi_iit_ne_id
             ;
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
  END get_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_xsp_validate(pi_iit_ne_id  IN nm_inv_items_all.iit_ne_id%TYPE
                              ,pi_inv_type   IN nm_inv_items_all.iit_inv_type%TYPE
                              ,pi_iit_x_sect IN nm_inv_items_all.iit_x_sect%TYPE)
    IS
    --
    CURSOR c1(cp_id IN nm_inv_items_all.iit_ne_id%TYPE)
        IS
    SELECT 1
      FROM nm_members
     WHERE nm_ne_id_in = cp_id
         ;
    --
    CURSOR c2(cp_id     IN nm_inv_items_all.iit_ne_id%TYPE
             ,cp_x_sect IN nm_inv_items_all.iit_x_sect%TYPE)
        IS
    SELECT 1
      FROM xsp_restraints r
          ,nm_members im
          ,nm_elements
          ,nm_inv_items
          ,nm_members rm
     WHERE xsr_x_sect_value = cp_x_sect
       AND xsr_ity_inv_code = iit_inv_type
       AND iit_ne_id = cp_id
       AND im.nm_ne_id_in = iit_ne_id
       AND ne_id = rm.nm_ne_id_in
       AND rm.nm_ne_id_of = im.nm_ne_id_of
       AND ne_sub_class = xsr_scl_class
       AND ne_nt_type = xsr_nw_type
    UNION ALL
    SELECT 1
      FROM xsp_restraints
          ,nm_members
          ,nm_elements
          ,nm_inv_items
     WHERE xsr_x_sect_value = cp_x_sect
       AND xsr_ity_inv_code = iit_inv_type
       AND iit_ne_id = cp_id
       AND nm_ne_id_in = iit_ne_id
       AND ne_id = nm_ne_id_of
       AND ne_sub_class = xsr_scl_class
       AND ne_nt_type = xsr_nw_type
         ;
    --
    CURSOR C3(cp_inv_type IN nm_inv_items_all.iit_inv_type%TYPE
             ,cp_x_sect   IN nm_inv_items_all.iit_x_sect%TYPE)
        IS
    SELECT 1
      FROM xsp_restraints
     WHERE xsr_x_sect_value = cp_x_sect
       AND xsr_ity_inv_code = cp_inv_type
       AND xsr_scl_class = xsr_scl_class
       AND xsr_nw_type = xsr_nw_type
         ;
       /*AND xsr_scl_class = NVL (pi_xsp_scl_class, xsr_scl_class)
       AND xsr_nw_type = NVL (pi_nw_type, xsr_nw_type);*/
    --
    l_row_found  BOOLEAN;
    l_dummy      PLS_INTEGER;
    --
  BEGIN
    --
    OPEN  c1(pi_iit_ne_id);
    FETCH c1
     INTO l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    --
    IF l_row_found
     THEN
        OPEN  c2(pi_iit_ne_id
                ,pi_iit_x_sect);
        FETCH c2
         INTO l_dummy;
        l_row_found := c2%FOUND;
        CLOSE c2;
    ELSE
        OPEN  c3(pi_inv_type
                ,pi_iit_x_sect);
        FETCH c3
         INTO l_dummy;
        l_row_found := c3%FOUND;
        CLOSE c3;
    END IF;
    --
    IF NOT l_row_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 29);
    END IF;
    --
  END check_xsp_validate;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsps(pi_inv_type         IN  xsp_restraints.xsr_ity_inv_code%TYPE
                    ,pi_scl_class        IN  xsp_restraints.xsr_scl_class%TYPE DEFAULT NULL
                    ,pi_nw_type          IN  xsp_restraints.xsr_nw_type%TYPE DEFAULT NULL
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor
                    ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    IF is_xsect_allowed(pi_inv_type)
     THEN
        OPEN po_cursor FOR
        SELECT xsr_nw_type
              ,xsr_scl_class
              ,xsr_x_sect_value
              ,xsr_descr
          FROM xsp_restraints
         WHERE xsr_ity_inv_code = pi_inv_type
           AND xsr_scl_class = NVL(pi_scl_class,xsr_scl_class)
           AND xsr_nw_type = NVL(pi_nw_type,xsr_nw_type)
         ORDER
            BY xsr_nw_type
              ,xsr_scl_class
              ,xsr_x_sect_value
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
  END get_xsps;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_attribute(pi_inv_type    IN nm_inv_types_all.nit_inv_type%TYPE
                         ,pi_global      IN VARCHAR2
                         ,pi_attrib_name IN nm_inv_type_attribs_all.ita_attrib_name%TYPE
                         ,pi_scrn_text   IN nm_inv_type_attribs_all.ita_scrn_text%TYPE
                         ,pi_value       IN VARCHAR2)
    IS
    --
    lv_sql  nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||When an Asset Type has no attributes defined the UI sends a single
    ||row with no values to check for NULL then set the value.
    */
    IF pi_attrib_name IS NOT NULL
     THEN
        awlrs_util.set_attribute(pi_obj_type    => pi_inv_type
                                ,pi_inv_or_ne   => 'INV'
                                ,pi_global      => pi_global
                                ,pi_column_name => pi_attrib_name
                                ,pi_prompt      => pi_scrn_text
                                ,pi_value       => pi_value);
    END IF;
    --
  END set_attribute;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE build_asset_rec(pi_inv_type   IN nm_inv_types_all.nit_inv_type%TYPE
                           ,pi_global     IN VARCHAR2
                           ,pi_attributes IN flex_attr_tab)
    IS
  BEGIN
    --
    FOR i IN 1..pi_attributes.COUNT LOOP
      --
      set_attribute(pi_inv_type    => pi_inv_type
                   ,pi_global      => pi_global
                   ,pi_attrib_name => pi_attributes(i).attrib_name
                   ,pi_scrn_text   => pi_attributes(i).scrn_text
                   ,pi_value       => pi_attributes(i).char_value);
      --
    END LOOP;
    --
  END build_asset_rec;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_flex_attribs(pi_iit_ne_id      IN  nm_inv_items_all.iit_ne_id%TYPE
                           ,pi_inv_type       IN  nm_inv_items_all.iit_inv_type%TYPE
                           ,pi_disp_derived   IN  BOOLEAN DEFAULT TRUE
                           ,pi_disp_inherited IN  BOOLEAN DEFAULT TRUE
                           ,pi_exclude_cols   IN  view_col_names_tab DEFAULT CAST (null as view_col_names_tab))
    RETURN flex_attr_tab IS
    --
    lv_disp_derived    VARCHAR2(1) := CASE WHEN pi_disp_derived THEN 'Y' ELSE 'N' END;
    lv_disp_inherited  VARCHAR2(1) := CASE WHEN pi_disp_inherited THEN 'Y' ELSE 'N' END;
    --
    lt_column_names  nm_max_varchar_tbl := nm_max_varchar_tbl();
    lt_retval        flex_attr_tab;
    --
    CURSOR get_attribs(cp_inv_type     IN nm_inv_items_all.iit_inv_type%TYPE
                      ,cp_iit_ne_id    IN nm_inv_items_all.iit_ne_id%TYPE
                      ,ct_column_names IN nm_max_varchar_tbl)
        IS
    SELECT column_name
          ,prompt
          ,view_column_name
          ,datatype
          ,format_mask
          ,CAST(field_length AS NUMBER(4)) field_length
          ,CAST(decimal_places AS NUMBER(1)) decimal_places
          ,CAST(min_value AS NUMBER(11,3)) min_value
          ,CAST(max_value AS NUMBER(11,3)) max_value
          ,field_case
          ,CAST(domain_id AS VARCHAR2(40)) domain_id
          ,CAST(domain_bind_column AS VARCHAR2(30)) domain_bind_column
          ,CAST(char_value AS VARCHAR2(500)) char_value
          ,required
          ,updateable
          ,seq_no
      FROM (SELECT ita_attrib_name   column_name
                  ,ita_scrn_text     prompt
                  ,ita_view_col_name view_column_name
                  ,ita_format        datatype
                  ,CASE
                     WHEN ita_format = 'DATE'
                      THEN
                         NVL(ita_format_mask,'DD-MON-YYYY')
                     ELSE
                         ita_format_mask
                   END format_mask
                  ,CASE
                     WHEN ita_format = 'DATE'
                      THEN
                         LENGTH(REPLACE(ita_format_mask,'24',''))
                     ELSE
                         ita_fld_length
                   END field_length
                  ,ita_dec_places    decimal_places
                  ,ita_min           min_value
                  ,ita_max           max_value
                  ,ita_case          field_case
                  ,ita_id_domain     domain_id
                  ,NULL              domain_bind_column
                  ,awlrs_asset_api.get_attrib_value(pi_inv_type    => cp_inv_type
                                                   ,pi_ne_id       => cp_iit_ne_id
                                                   ,pi_attrib_name => ita_attrib_name) char_value
                  ,ita_mandatory_yn  required
                  ,'Y'               updateable
                  ,ita_disp_seq_no   seq_no
              FROM nm_inv_type_attribs
             WHERE ita_inv_type = cp_inv_type
               AND ita_view_col_name NOT IN (SELECT * FROM TABLE(CAST(ct_column_names AS nm_max_varchar_tbl))))
     ORDER
        BY seq_no
          ,column_name
         ;
    --
  BEGIN
    --
    FOR i IN 1..pi_exclude_cols.COUNT LOOP
      --
      lt_column_names.extend;
      lt_column_names(i) := pi_exclude_cols(i);
      --
    END LOOP;
    --
    OPEN  get_attribs(pi_inv_type
                     ,pi_iit_ne_id
                     ,lt_column_names);
    FETCH get_attribs
     BULK COLLECT
     INTO lt_retval;
    CLOSE get_attribs;
    --
    RETURN lt_retval;
    --
  END get_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_flex_attribs(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                            ,pi_inv_type         IN  nm_inv_items_all.iit_inv_type%TYPE
                            ,pi_disp_derived     IN  BOOLEAN DEFAULT TRUE
                            ,pi_disp_inherited   IN  BOOLEAN DEFAULT TRUE
                            ,pi_exclude_cols     IN  view_col_names_tab DEFAULT CAST (null as view_col_names_tab)
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_attribs  flex_attr_tab;
    --
  BEGIN
    --
    lt_attribs := get_flex_attribs(pi_iit_ne_id      => pi_iit_ne_id
                                  ,pi_inv_type       => pi_inv_type
                                  ,pi_disp_derived   => pi_disp_derived
                                  ,pi_disp_inherited => pi_disp_inherited
                                  ,pi_exclude_cols   => pi_exclude_cols);
    --
    OPEN po_cursor FOR
    SELECT t.attrib_name column_name
          ,t.scrn_text prompt
          ,t.view_col_name view_column_name
          ,t.datatype
          ,t.format_mask
          ,t.field_length
          ,t.decimal_places
          ,t.min_value
          ,t.max_value
          ,t.field_case
          ,t.domain_id
          ,t.domain_bind_column
          ,t.char_value
          ,t.required
          ,t.updateable
          ,t.display_sequence
      FROM TABLE(lt_attribs) t
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
    --
  END get_flex_attribs;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_domain_values(pi_domain_names     IN  domain_names_tab
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor
                             ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_names nm_code_tbl := nm_code_tbl();
    --
  BEGIN
    --
    FOR i IN 1..pi_domain_names.COUNT LOOP
      --
      lt_names.extend;
      lt_names(i) := pi_domain_names(i);
      --
    END LOOP;
    --
    OPEN po_cursor FOR
    SELECT ial_domain
          ,ial_value
          ,ial_value||' - '||ial_meaning ial_meaning
      FROM nm_inv_attri_lookup_all
     WHERE ial_domain IN(SELECT * FROM TABLE(CAST(lt_names AS nm_code_tbl)))
       AND TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
             >= NVL(ial_start_date,TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY'))
       AND TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
             <= NVL(ial_end_date,TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY'))
     ORDER
        BY ial_domain
          ,ial_seq
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
    --
  END get_domain_values;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE can_update_asset (pi_asset_type       IN  nm_inv_items_all.iit_inv_type%TYPE
                             ,pi_admin_unit       IN  nm_inv_items_all.iit_admin_unit%TYPE
                             ,po_message_severity OUT hig_codes.hco_code%TYPE
                             ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types_all%ROWTYPE;
    --
  BEGIN
    /*
    ||check user can update item
    */
    lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_asset_type);
    --
    IF NOT invsec.is_inv_item_updatable(p_iit_inv_type           => pi_asset_type
                                       ,p_iit_admin_unit         => pi_admin_unit
                                       ,pi_unrestricted_override => FALSE)
     AND invsec.nic_is_updatable_from_module(pi_category => lr_nit.nit_category
                                            ,pi_module   => awlrs_util.c_awlrs_module)
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 86);
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
    --
  END can_update_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_asset(pi_asset_type         IN     nm_inv_items_all.iit_inv_type%TYPE
                        ,pi_primary_key        IN     nm_inv_items_all.iit_primary_key%TYPE
                        ,pi_admin_unit         IN     nm_inv_items_all.iit_admin_unit%TYPE
                        ,pi_xsp                IN     nm_inv_items_all.iit_x_sect%TYPE
                        ,pi_description        IN     nm_inv_items_all.iit_descr%TYPE
                        ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE
                        ,pi_end_date           IN     nm_inv_items_all.iit_end_date%TYPE
                        ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                        ,pi_iit_foreign_key    IN     nm_inv_items_all.iit_foreign_key%TYPE
                        ,pi_attrib_names       IN     attrib_name_tab
                        ,pi_attrib_scrn_texts  IN     attrib_scrn_text_tab
                        ,pi_attrib_char_values IN     attrib_value_tab
                        ,po_iit_ne_id          IN OUT nm_inv_items.iit_ne_id%TYPE
                        ,po_message_severity      OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor        OUT sys_refcursor)
    IS
    --
    lt_attribs  flex_attr_tab;
    --
    lv_iit_foreign_key nm_inv_items_all.iit_foreign_key%TYPE;
    --
  BEGIN
    --
    SAVEPOINT create_asset_sp;
    /*
    ||Init globals.
    */
    init_asset_globals;
    /*
    ||Create the asset.
    */
    g_iit_rec.iit_ne_id := ne_id_seq.NEXTVAL;
    --
    IF pi_primary_key IS NULL
     THEN
        g_iit_rec.iit_primary_key := g_iit_rec.iit_ne_id;
    END IF;
    --
    IF NOT is_xsect_allowed(pi_asset_type) AND pi_xsp IS NOT NULL
     THEN
        hig.raise_ner(pi_appl               => 'NET'
                     ,pi_id                 => 44);
    END IF;
    /*
    ||hierarchical Asset
    */
    IF pi_iit_foreign_key IS NOT NULL
     THEN
        lv_iit_foreign_key := nm3inv.get_inv_primary_key(p_ne_id => pi_iit_foreign_key);
    END IF;
    --
    g_iit_rec.iit_start_date := TRUNC(pi_start_date);
    g_iit_rec.iit_admin_unit := pi_admin_unit;
    g_iit_rec.iit_inv_type := pi_asset_type;
    g_iit_rec.iit_descr := pi_description;
    g_iit_rec.iit_x_sect := pi_xsp;
    g_iit_rec.iit_foreign_key := lv_iit_foreign_key;
    g_iit_rec.iit_note := pi_notes;
    --
    IF pi_attrib_names.COUNT != pi_attrib_scrn_texts.COUNT
     OR pi_attrib_names.COUNT != pi_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_asset_api.create_asset');
    END IF;
    --
    FOR i IN 1..pi_attrib_names.COUNT LOOP
      --
      lt_attribs(i).attrib_name := pi_attrib_names(i);
      lt_attribs(i).scrn_text   := pi_attrib_scrn_texts(i);
      lt_attribs(i).char_value  := pi_attrib_char_values(i);
      --
      IF is_attrib_mandatory(pi_inv_type     => pi_asset_type
                            ,pi_attrib_name  => pi_attrib_names(i))
       AND (NVL(pi_attrib_char_values(i),'') = '' OR  pi_attrib_char_values(i) IS NULL)
        THEN
          hig.raise_ner(pi_appl               => 'NET'
                       ,pi_id                 => 50
                       ,pi_supplementary_info => pi_attrib_scrn_texts(i));
      END IF;
      /*
      ||populate foreign_key key flexible attribute
      ||As per Gopi is struggling to populate IIT_FOREIGN_KEY on UI when add child so if null add via API.
      */
      IF pi_iit_foreign_key IS NOT NULL AND lt_attribs(i).attrib_name = 'IIT_FOREIGN_KEY' AND lt_attribs(i).char_value IS NULL
       THEN
         lt_attribs(i).char_value := lv_iit_foreign_key;
      END IF  ;
    END LOOP;
    --
    build_asset_rec(pi_inv_type   => g_iit_rec.iit_inv_type
                   ,pi_global     => 'awlrs_asset_api.g_iit_rec'
                   ,pi_attributes => lt_attribs);
    --
    IF pi_xsp IS NOT NULL
     THEN
        check_xsp_validate(pi_iit_ne_id  => g_iit_rec.iit_ne_id
                          ,pi_inv_type   => pi_asset_type
                          ,pi_iit_x_sect => pi_xsp);
    END IF;
    --
    nm3ins.ins_iit_all(p_rec_iit_all => g_iit_rec);
    po_iit_ne_id := g_iit_rec.iit_ne_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO create_asset_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
    --
  END create_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset(pi_iit_ne_id       IN nm_inv_items_all.iit_ne_id%TYPE
                        ,pi_old_primary_key IN nm_inv_items_all.iit_primary_key%TYPE
                        ,pi_old_admin_unit  IN nm_inv_items_all.iit_admin_unit%TYPE
                        ,pi_old_xsp         IN nm_inv_items_all.iit_x_sect%TYPE
                        ,pi_old_description IN nm_inv_items_all.iit_descr%TYPE
                        ,pi_old_start_date  IN nm_inv_items_all.iit_start_date%TYPE
                        ,pi_old_end_date    IN nm_inv_items_all.iit_end_date%TYPE
                        ,pi_old_notes       IN nm_inv_items_all.iit_note%TYPE
                        ,pi_new_primary_key IN nm_inv_items_all.iit_primary_key%TYPE
                        ,pi_new_admin_unit  IN nm_inv_items_all.iit_admin_unit%TYPE
                        ,pi_new_xsp         IN nm_inv_items_all.iit_x_sect%TYPE
                        ,pi_new_description IN nm_inv_items_all.iit_descr%TYPE
                        ,pi_new_start_date  IN nm_inv_items_all.iit_start_date%TYPE
                        ,pi_new_end_date    IN nm_inv_items_all.iit_end_date%TYPE
                        ,pi_new_notes       IN nm_inv_items_all.iit_note%TYPE
                        ,pi_old_attributes  IN flex_attr_tab
                        ,pi_new_attributes  IN flex_attr_tab)
    IS
    --
    lv_old_start_date  DATE := TRUNC(pi_old_start_date);
    lv_new_start_date  DATE := TRUNC(pi_new_start_date);
    lv_old_end_date    DATE := TRUNC(pi_old_end_date);
    lv_new_end_date    DATE := TRUNC(pi_new_end_date);
    --
    PROCEDURE get_db_rec(pi_iit_ne_id IN nm_elements_all.ne_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO g_db_iit_rec
        FROM nm_inv_items
       WHERE iit_ne_id = pi_iit_ne_id
         FOR UPDATE NOWAIT
           ;
      --
    EXCEPTION
     WHEN no_data_found
      THEN
         hig.raise_ner(pi_appl => 'AWLRS'
                      ,pi_id   => 37);
    END get_db_rec;
    --
    PROCEDURE compare_old_with_db
      IS
      --
      lv_sql  nm3type.max_varchar2;
      --
    BEGIN
      /*
      ||Check the fixed attributes, Description,primary key, admin unit, xsp,start date, end date
      */
      IF g_db_iit_rec.iit_descr != pi_old_description
       OR (g_db_iit_rec.iit_descr IS NULL AND pi_old_description IS NOT NULL)
       OR (g_db_iit_rec.iit_descr IS NOT NULL AND pi_old_description IS NULL)
       --pk
       OR (g_db_iit_rec.iit_primary_key != pi_old_primary_key)
       OR (g_db_iit_rec.iit_primary_key IS NULL AND pi_old_primary_key IS NOT NULL)
       OR (g_db_iit_rec.iit_primary_key IS NOT NULL AND pi_old_primary_key IS NULL)
       --au
       OR (g_db_iit_rec.iit_admin_unit != pi_old_admin_unit)
       OR (g_db_iit_rec.iit_admin_unit IS NULL AND pi_old_admin_unit IS NOT NULL)
       OR (g_db_iit_rec.iit_admin_unit IS NOT NULL AND pi_old_admin_unit IS NULL)
       --xsp
       OR (g_db_iit_rec.iit_x_sect != pi_old_xsp)
       OR (g_db_iit_rec.iit_x_sect IS NULL AND pi_old_xsp IS NOT NULL)
       OR (g_db_iit_rec.iit_x_sect IS NOT NULL AND pi_old_xsp IS NULL)
       --sd
       OR (g_db_iit_rec.iit_start_date != lv_old_start_date)
       OR (g_db_iit_rec.iit_start_date IS NULL AND lv_old_start_date IS NOT NULL)
       OR (g_db_iit_rec.iit_start_date IS NOT NULL AND lv_old_start_date IS NULL)
       --ed
       OR (g_db_iit_rec.iit_end_date != lv_old_end_date)
       OR (g_db_iit_rec.iit_end_date IS NULL AND lv_old_end_date IS NOT NULL)
       OR (g_db_iit_rec.iit_end_date IS NOT NULL AND lv_old_end_date IS NULL)
       THEN
          --Updated by another user
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 24);
      END IF;
      /*
      ||Check the flexible attributes
      */
      FOR i IN 1..pi_old_attributes.count LOOP
        --
        lv_sql := NULL;
        --
        lv_sql := 'BEGIN';
        --
        IF awlrs_util.is_date_in_varchar(pi_inv_type    => g_db_iit_rec.iit_inv_type
                                        ,pi_attrib_name => pi_old_attributes(i).attrib_name)
         THEN
            lv_sql := lv_sql
              ||CHR(10)||'  awlrs_util.set_attribute(pi_obj_type    => awlrs_asset_api.g_db_iit_rec.iit_inv_type'
              ||CHR(10)||'                          ,pi_inv_or_ne   => ''INV'''
              ||CHR(10)||'                          ,pi_global      => ''awlrs_asset_api.g_db_iit_rec'''
              ||CHR(10)||'                          ,pi_column_name => '''||pi_old_attributes(i).attrib_name||''''
              ||CHR(10)||'                          ,pi_prompt      => '''||pi_old_attributes(i).scrn_text||''''
              ||CHR(10)||'                          ,pi_value       => awlrs_asset_api.g_db_iit_rec.'||pi_old_attributes(i).attrib_name||');'
            ;
        END IF;
        --
        lv_sql := lv_sql
          ||CHR(10)||'  IF awlrs_asset_api.g_db_iit_rec.'||pi_old_attributes(i).attrib_name||' != awlrs_asset_api.g_old_iit_rec.'||pi_old_attributes(i).attrib_name
          ||CHR(10)||'   OR (awlrs_asset_api.g_db_iit_rec.'||pi_old_attributes(i).attrib_name||' IS NULL AND awlrs_asset_api.g_old_iit_rec.'||pi_old_attributes(i).attrib_name||' IS NOT NULL)'
          ||CHR(10)||'   OR (awlrs_asset_api.g_db_iit_rec.'||pi_old_attributes(i).attrib_name||' IS NOT NULL AND awlrs_asset_api.g_old_iit_rec.'||pi_old_attributes(i).attrib_name||' IS NULL)'
          ||CHR(10)||'   THEN '
          ||CHR(10)||'      hig.raise_ner(pi_appl => ''AWLRS'''
          ||CHR(10)||'                   ,pi_id   => 24);'
          ||CHR(10)||'  END IF;'
          ||CHR(10)||'END;'
        ;
        --
        IF lv_sql IS NOT NULL
         THEN
            EXECUTE IMMEDIATE lv_sql;
        END IF;
        --
      END LOOP;
      --
    END compare_old_with_db;
    --
    PROCEDURE compare_old_with_new
      IS
      --
      lv_sql      nm3type.max_varchar2;
      lv_upd_sql  nm3type.max_varchar2 := 'DECLARE lr_iit nm_inv_items_all%ROWTYPE := awlrs_asset_api.g_new_iit_rec; BEGIN UPDATE nm_inv_items_all SET ';
      lv_upd      VARCHAR2(1) := 'N';
      --
    BEGIN
      --
      IF g_old_iit_rec.iit_primary_key != g_new_iit_rec.iit_primary_key
       THEN
          --
          lv_upd_sql := lv_upd_sql||'iit_primary_key = lr_iit.iit_primary_key';
          lv_upd := 'Y';
          --
      END IF;
      --
      IF g_old_iit_rec.iit_admin_unit != g_new_iit_rec.iit_admin_unit
       THEN
          --
          IF lv_upd = 'Y'
           THEN
              lv_upd_sql := lv_upd_sql || ', ';
          END IF;
          --
          lv_upd_sql := lv_upd_sql||'iit_admin_unit = lr_iit.iit_admin_unit';
          lv_upd := 'Y';
          --
      END IF;
      --
      IF g_old_iit_rec.iit_x_sect != g_new_iit_rec.iit_x_sect
       OR (g_old_iit_rec.iit_x_sect IS NULL AND g_new_iit_rec.iit_x_sect IS NOT NULL)
       OR (g_old_iit_rec.iit_x_sect IS NOT NULL AND g_new_iit_rec.iit_x_sect IS NULL)
       THEN
          --
          IF lv_upd = 'Y'
           THEN
              lv_upd_sql := lv_upd_sql || ', ';
          END IF;
          --
          lv_upd_sql := lv_upd_sql||'iit_x_sect = lr_iit.iit_x_sect';
          lv_upd := 'Y';
          --
      END IF;
      --
      IF g_old_iit_rec.iit_descr != g_new_iit_rec.iit_descr
       OR (g_old_iit_rec.iit_descr IS NULL AND g_new_iit_rec.iit_descr IS NOT NULL)
       OR (g_old_iit_rec.iit_descr IS NOT NULL AND g_new_iit_rec.iit_descr IS NULL)
       THEN
          --
          IF lv_upd = 'Y'
           THEN
              lv_upd_sql := lv_upd_sql || ', ';
          END IF;
          --
          lv_upd_sql := lv_upd_sql||'iit_descr = lr_iit.iit_descr';
          lv_upd := 'Y';
          --
      END IF;
      --
      IF g_old_iit_rec.iit_start_date != g_new_iit_rec.iit_start_date
       THEN
          --
          IF lv_upd = 'Y'
           THEN
              lv_upd_sql := lv_upd_sql || ', ';
          END IF;
          --
          lv_upd_sql := lv_upd_sql||'iit_start_date = lr_iit.iit_start_date';
          lv_upd := 'Y';
          --
      END IF;
      --
      IF g_old_iit_rec.iit_end_date != g_new_iit_rec.iit_end_date
       OR (g_old_iit_rec.iit_end_date IS NULL AND g_new_iit_rec.iit_end_date IS NOT NULL)
       OR (g_old_iit_rec.iit_end_date IS NOT NULL AND g_new_iit_rec.iit_end_date IS NULL)
       THEN
          --
          IF lv_upd = 'Y'
           THEN
              lv_upd_sql := lv_upd_sql || ', ';
          END IF;
          --
          lv_upd_sql := lv_upd_sql||'iit_end_date = lr_iit.iit_end_date';
          lv_upd := 'Y';
          --
      END IF;
      --
      IF g_old_iit_rec.iit_note != g_new_iit_rec.iit_note
       OR (g_old_iit_rec.iit_note IS NULL AND g_new_iit_rec.iit_note IS NOT NULL)
       OR (g_old_iit_rec.iit_note IS NOT NULL AND g_new_iit_rec.iit_note IS NULL)
       THEN
          --
          IF lv_upd = 'Y'
           THEN
              lv_upd_sql := lv_upd_sql || ', ';
          END IF;
          --
          lv_upd_sql := lv_upd_sql||'iit_note = lr_iit.iit_note';
          lv_upd := 'Y';
          --
      END IF;
      --
      FOR i IN 1..pi_new_attributes.count LOOP
        --
        lv_sql := NULL;
        --
        lv_sql := 'BEGIN IF awlrs_asset_api.g_old_iit_rec.'||pi_new_attributes(i).attrib_name||' != awlrs_asset_api.g_new_iit_rec.'||pi_new_attributes(i).attrib_name
                ||' OR (awlrs_asset_api.g_old_iit_rec.'||pi_new_attributes(i).attrib_name||' IS NULL AND awlrs_asset_api.g_new_iit_rec.'||pi_new_attributes(i).attrib_name||' IS NOT NULL)'
                ||' OR (awlrs_asset_api.g_old_iit_rec.'||pi_new_attributes(i).attrib_name||' IS NOT NULL AND awlrs_asset_api.g_new_iit_rec.'||pi_new_attributes(i).attrib_name||' IS NULL)'
                ||' THEN :sql_out := :sql_in||'''||CASE WHEN lv_upd = 'Y' THEN ', ' ELSE NULL END||LOWER(pi_new_attributes(i).attrib_name)||' = lr_iit.'||LOWER(pi_new_attributes(i).attrib_name)||''';'
                ||' :do_update := ''Y''; END IF; END;'
        ;
        EXECUTE IMMEDIATE lv_sql USING OUT lv_upd_sql, IN lv_upd_sql, OUT lv_upd;
        --
      END LOOP;
      --
      IF lv_upd = 'N'
       THEN
          --There are no changes to be applied
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 25);
      END IF;
      --
      IF lv_upd = 'Y'
       THEN
          /*
          ||Complete and execute the asset update statement.
          */
          lv_upd_sql := lv_upd_sql||' WHERE iit_ne_id = :iit_ne_id; END;';
          --
          EXECUTE IMMEDIATE lv_upd_sql USING g_db_iit_rec.iit_ne_id;
          --
      END IF;
      --
    END compare_old_with_new;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT upd_asset_sp;
    /*
    ||Init globals.
    */
    init_asset_globals;
    /*
    ||Get and Lock the record.
    */
    get_db_rec(pi_iit_ne_id => pi_iit_ne_id);
    g_old_iit_rec := g_db_iit_rec;
    g_new_iit_rec := g_db_iit_rec;
    /*
    ||Build and validate the records
    */
    --
    g_old_iit_rec.iit_primary_key := pi_old_primary_key;
    g_new_iit_rec.iit_primary_key := pi_new_primary_key;
    --
    g_old_iit_rec.iit_admin_unit := pi_old_admin_unit;
    g_new_iit_rec.iit_admin_unit := pi_new_admin_unit;
    --
    g_old_iit_rec.iit_x_sect := pi_old_xsp;
    g_new_iit_rec.iit_x_sect := pi_new_xsp;
    --
    g_old_iit_rec.iit_descr := pi_old_description;
    g_new_iit_rec.iit_descr := pi_new_description;
    --
    g_old_iit_rec.iit_start_date := lv_old_start_date;
    g_new_iit_rec.iit_start_date := lv_new_start_date;
    --
    g_old_iit_rec.iit_end_date := lv_old_end_date;
    g_new_iit_rec.iit_end_date := lv_new_end_date;
    --
    g_old_iit_rec.iit_note := pi_old_notes;
    g_new_iit_rec.iit_note := pi_new_notes;
    --
    build_asset_rec(pi_inv_type   => g_db_iit_rec.iit_inv_type
                   ,pi_global     => 'awlrs_asset_api.g_old_iit_rec'
                   ,pi_attributes => pi_old_attributes);
    --
    build_asset_rec(pi_inv_type   => g_db_iit_rec.iit_inv_type
                   ,pi_global     => 'awlrs_asset_api.g_new_iit_rec'
                   ,pi_attributes => pi_new_attributes);
    /*
    ||Compare old with DB.
    */
    compare_old_with_db;
    /*
    ||Compare new with old.
    */
    compare_old_with_new;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO upd_asset_sp;
        RAISE;
  END update_asset;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_asset(pi_iit_ne_id              IN  nm_inv_items_all.iit_ne_id%TYPE
                        ,pi_asset_type             IN  nm_inv_items_all.iit_inv_type%TYPE
                        ,pi_old_primary_key        IN  nm_inv_items_all.iit_primary_key%TYPE
                        ,pi_old_admin_unit         IN  nm_inv_items_all.iit_admin_unit%TYPE
                        ,pi_old_xsp                IN  nm_inv_items_all.iit_x_sect%TYPE
                        ,pi_old_description        IN  nm_inv_items_all.iit_descr%TYPE
                        ,pi_old_start_date         IN  nm_inv_items_all.iit_start_date%TYPE
                        ,pi_old_end_date           IN  nm_inv_items_all.iit_end_date%TYPE
                        ,pi_old_notes              IN  nm_inv_items_all.iit_note%TYPE
                        ,pi_new_primary_key        IN  nm_inv_items_all.iit_primary_key%TYPE
                        ,pi_new_admin_unit         IN  nm_inv_items_all.iit_admin_unit%TYPE
                        ,pi_new_xsp                IN  nm_inv_items_all.iit_x_sect%TYPE
                        ,pi_new_description        IN  nm_inv_items_all.iit_descr%TYPE
                        ,pi_new_start_date         IN  nm_inv_items_all.iit_start_date%TYPE
                        ,pi_new_end_date           IN  nm_inv_items_all.iit_end_date%TYPE
                        ,pi_new_notes              IN  nm_inv_items_all.iit_note%TYPE
                        ,pi_old_attrib_names       IN  attrib_name_tab
                        ,pi_attrib_names           IN  attrib_name_tab
                        ,pi_old_attrib_scrn_texts  IN  attrib_scrn_text_tab
                        ,pi_attrib_scrn_texts      IN  attrib_scrn_text_tab
                        ,pi_old_attrib_char_values IN  attrib_value_tab
                        ,pi_new_attrib_char_values IN  attrib_value_tab
                        ,po_message_severity       OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lt_old_asset_attribs  flex_attr_tab;
    lt_new_asset_attribs  flex_attr_tab;
    --
    lr_nit nm_inv_types%ROWTYPE;
    --
  BEGIN
    --
    IF pi_old_attrib_names.COUNT != pi_old_attrib_scrn_texts.COUNT
     OR pi_old_attrib_names.COUNT != pi_old_attrib_char_values.COUNT
     OR pi_old_attrib_names.COUNT != pi_attrib_names.COUNT
     OR pi_old_attrib_names.COUNT != pi_attrib_scrn_texts.COUNT
     OR pi_old_attrib_names.COUNT != pi_new_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_element_api.create_element');
    END IF;
    --
    lr_nit := nm3get.get_nit(pi_asset_type);
    --
    IF pi_new_end_date IS NOT NULL
     AND pi_old_end_date IS NULL
     AND lr_nit.nit_contiguous = 'Y'
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 125);
    END IF;
    --

    IF pi_old_attrib_names.COUNT = 1
     AND (pi_old_attrib_names(1) is null
     AND pi_attrib_names(1) is null
     AND pi_old_attrib_scrn_texts(1)  is null
     AND pi_attrib_scrn_texts(1) is null
     AND pi_old_attrib_char_values(1) is null
     AND pi_new_attrib_char_values(1) is null)
      THEN
        /*
        || To cope with assets with no flexile attributes. .net has to pass empty array.
        */
        NULL;
        --
    ELSE
      FOR i IN 1..pi_old_attrib_names.COUNT LOOP
        --
        lt_old_asset_attribs(i).attrib_name := pi_old_attrib_names(i);
        lt_old_asset_attribs(i).scrn_text   := pi_old_attrib_scrn_texts(i);
        lt_old_asset_attribs(i).char_value  := pi_old_attrib_char_values(i);
        --
        lt_new_asset_attribs(i).attrib_name := pi_attrib_names(i);
        lt_new_asset_attribs(i).scrn_text   := pi_attrib_scrn_texts(i);
        lt_new_asset_attribs(i).char_value  := pi_new_attrib_char_values(i);
        --
      END LOOP;
    END IF;

    --
    update_asset(pi_iit_ne_id       => pi_iit_ne_id
                ,pi_old_primary_key => pi_old_primary_key
                ,pi_old_admin_unit  => pi_old_admin_unit
                ,pi_old_xsp         => pi_old_xsp
                ,pi_old_description => pi_old_description
                ,pi_old_start_date  => pi_old_start_date
                ,pi_old_end_date    => pi_old_end_date
                ,pi_old_notes       => pi_old_notes
                ,pi_new_primary_key => pi_new_primary_key
                ,pi_new_admin_unit  => pi_new_admin_unit
                ,pi_new_xsp         => pi_new_xsp
                ,pi_new_description => pi_new_description
                ,pi_new_start_date  => pi_new_start_date
                ,pi_new_end_date    => pi_new_end_date
                ,pi_new_notes       => pi_new_notes
                ,pi_old_attributes  => lt_old_asset_attribs
                ,pi_new_attributes  => lt_new_asset_attribs);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_asset;

  --
  -----------------------------------------------------------------------------
  --
  --UI to call this pre adding location. If it returns TRUE for located then
  --ask user whether they wish to append or replace in location call.
  --
  PROCEDURE is_asset_located(pi_asset_type       IN  nm_inv_items_all.iit_inv_type%TYPE
                            ,pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                            ,po_located          OUT VARCHAR2
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor)
    IS
  BEGIN
    --
    IF nm3inv.get_inv_type(pi_asset_type).nit_multiple_allowed = 'Y'
     AND nm3asset.asset_is_located(pi_iit_ne_id)
     THEN
        po_located := 'Y';
    ELSE
        po_located := 'N';
    END IF;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  END is_asset_located;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_contiguity(pi_asset_type   IN     nm_inv_items_all.iit_inv_type%TYPE
                            ,pi_datum        IN     VARCHAR2
                            ,pi_ne_id        IN     nm_elements_all.ne_id%TYPE
                            ,pi_x_sect       IN     nm_inv_items_all.iit_x_sect%TYPE
                            ,po_warning_code IN OUT VARCHAR2)
    IS
    --
    lr_nit  nm_inv_types%ROWTYPE;
    --
    lv_check_contiguity  BOOLEAN := FALSE ;
    --
  BEGIN
    --
    lr_nit := nm3get.get_nit(pi_asset_type);
    --
    IF NVL(lr_nit.nit_contiguous,'N') = 'Y'
     THEN
        lv_check_contiguity := nm3invval.check_contiguity(pi_ne_id
                                                         ,pi_asset_type
                                                         ,pi_x_sect
                                                         ,CASE pi_datum WHEN 'N' THEN 'G' ELSE 'D' END);
    END IF ;
    --
    IF lv_check_contiguity
     THEN
        po_warning_code := 'CONTIGUOUS';
    ELSE
        po_warning_code := NULL;
    END IF ;
    --
  END check_contiguity;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_asset_location(pi_iit            IN     nm_inv_items_all%ROWTYPE
                              ,pi_startdate      IN     DATE
                              ,pi_is_datum       IN     VARCHAR2
                              ,pi_ne_id          IN     nm_elements_all.ne_id%TYPE
                              ,pi_nit_inv_type   IN     nm_inv_types_all.nit_inv_type%TYPE
                              ,pi_job_id         IN     nm_nw_temp_extents.nte_job_id%TYPE
                              ,pi_append_replace IN     VARCHAR2
                              ,po_messages          IN OUT awlrs_message_tab)
    IS
    --
    lv_existing_loc_job_id NUMBER;
    lv_job_id              NUMBER := pi_job_id;
    lv_is_datum            VARCHAR2(1);
    lv_no_overlaps_job_id  NUMBER;
    lv_warning_code        VARCHAR2(1000);
    lv_warning_msg         VARCHAR2(1000);
    --
  BEGIN
    --
    IF pi_append_replace = 'A'
     THEN
        /*
        ||get_existing
        */
        nm3extent.create_temp_ne(pi_source_id => pi_iit.iit_ne_id
                                ,pi_source    => nm3extent.get_route
                                ,pi_begin_mp  => NULL
                                ,pi_end_mp    => NULL
                                ,po_job_id    => lv_existing_loc_job_id);
        --
        nm3extent.combine_temp_nes(pi_job_id_1       => lv_existing_loc_job_id
                                  ,pi_job_id_2       => lv_job_id
                                  ,pi_check_overlaps => FALSE);  --homo will check for overlaps
        --
        lv_job_id := lv_existing_loc_job_id;
        --
    END IF;
    --
    lv_no_overlaps_job_id := nm3extent.remove_overlaps(pi_nte_id => lv_job_id);
    --
    --nm3inv.set_inv_warning_msg(p_msg => NULL);
    --
    nm3homo.homo_update(p_temp_ne_id_in  => lv_no_overlaps_job_id
                       ,p_iit_ne_id      => pi_iit.iit_ne_id
                       ,p_effective_date => TRUNC(pi_startdate)
                       ,p_warning_code   => lv_warning_code
                       ,p_warning_msg    => lv_warning_msg);
    /*
    ||Only if NE is selected. Check contiguity
    */
    IF pi_ne_id IS NOT NULL
     THEN
        check_contiguity(pi_asset_type   => pi_nit_inv_type
                        ,pi_datum        => lv_is_datum
                        ,pi_ne_id        => pi_ne_id
                        ,pi_x_sect       => pi_iit.iit_x_sect
                        ,po_warning_code => lv_warning_code);
        --
        IF lv_warning_code IS NOT NULL
         THEN
            IF lv_warning_code = nm3homo.get_contiguous_warning_const
             THEN
                --contiguous warning
                awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'NET'
                                                 ,pi_ner_id             => 95
                                                 ,pi_supplementary_info => '. This check has been done across the whole of this piece of Network.'
                                                 ,pi_category           => awlrs_util.c_msg_cat_warning
                                                 ,po_message_tab        => po_messages);
            ELSE
                --unknown warning
                awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'NET'
                                                 ,pi_ner_id             => 94
                                                 ,pi_supplementary_info => lv_warning_code
                                                 ,pi_category           => awlrs_util.c_msg_cat_warning
                                                 ,po_message_tab        => po_messages);
            END IF;
        END IF;
        --
    END IF;

  END add_asset_location;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_asset_location(pi_iit                      IN     nm_inv_items_all%ROWTYPE
                              ,pi_nit_inv_type             IN     nm_inv_types_all.nit_inv_type%TYPE
                              ,pi_ne                       IN     nm_elements_all%ROWTYPE
                              ,pi_begin_mp                 IN     nm_members_all.nm_begin_mp%TYPE
                              ,pi_end_mp                   IN     nm_members_all.nm_end_mp%TYPE
                              ,pi_startdate                IN     nm_members_all.nm_start_date%TYPE
                              ,pi_append_replace           IN     VARCHAR2
                              ,pi_begin_sect               IN     nm_elements_all.ne_id%TYPE
                              ,pi_begin_sect_offset        IN     NUMBER
                              ,pi_begin_sect_date_modified IN     DATE
                              ,pi_end_sect                 IN     nm_elements_all.ne_id%TYPE
                              ,pi_end_sect_offset          IN     NUMBER
                              ,pi_end_sect_date_modified   IN     DATE
                              ,pi_ambiguous_sub_class      IN     VARCHAR2
                              ,pi_restrict_excl_sub_class  IN     VARCHAR2
                              ,pi_excl_sub_class           IN     nm_elements_all.ne_sub_class%TYPE
                              ,pi_nse_id                   IN     nm_saved_extents.nse_id%TYPE
                              ,po_message_severity IN OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   IN OUT sys_refcursor)
    IS
    --
    lv_existing_loc_job_id NUMBER;
    lv_job_id              NUMBER;
    lv_is_datum            VARCHAR2(1);
    lv_no_overlaps_job_id  NUMBER;
    lv_warning_code        VARCHAR2(1000);
    lv_warning_msg         VARCHAR2(1000);
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    e_no_permission EXCEPTION;
    e_item_not_entered EXCEPTION;
    e_validation_error EXCEPTION;
    e_extent_not_valid_for_homo EXCEPTION;
    e_nte_edited                EXCEPTION;
    --
    e_no_datums EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_datums, -20212);
    --
    e_nte_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nte_not_found, -20501);
    --
    e_inv_item_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_inv_item_not_found, -20502);
    --
    e_future_inv_affected EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_future_inv_affected, -20503);
    --
    e_old_inv_overlapping_st_end EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_old_inv_overlapping_st_end, -20504);
    --
    e_inv_type_invalid_on_nw EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_inv_type_invalid_on_nw, -20505);
    --
    e_invalid_xsp_inv EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_xsp_inv, -20506);
    --
    e_xsp_required EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_xsp_required, -20507);
    --
    e_invalid_xsp_nw EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_xsp_nw, -20508);
    --
    e_inv_type_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_inv_type_not_found, -20509);
    --
    e_ne_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_ne_not_found, -20510);
    --
    e_homo_start_equals_end EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_homo_start_equals_end, -20512);
    --
    e_multiple_not_allowed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_multiple_not_allowed, -20513);
    --
    e_overlaps EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_overlaps, -20514);
    --
    e_point_loc_cont EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_point_loc_cont, -20515);
    --
    e_dup_nm EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_dup_nm, -20516);
    --
    e_affected_dup_nm EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_affected_dup_nm, -20517);
    --
    e_cannot_loc_child_at EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cannot_loc_child_at, -20518);
    --
    e_overlaps_in_nte EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_overlaps_in_nte, -20519);
    --
    e_start_after_end EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_start_after_end, -20041);
    --
    e_no_connectivity EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_connectivity, -20042);
    --
    e_need_sub_class EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_need_sub_class, -20043);
    --
    e_cont_start_equals_end EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cont_start_equals_end, -20470);
    --
    e_should_not_be_here EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_should_not_be_here, -20901);
    --
    e_loc_already_designated EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_loc_already_designated, -20902);
    --
    e_no_priv_to_set_au EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_priv_to_set_au, -20903);
    --
    e_invalid_au EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_au, -20904);
    --
    e_cross_attr_val_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cross_attr_val_failed, -20760);
    ------------------------
    --traffic manager errors
    ------------------------
    e_tm_err_1 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_1, -20000);
    --
    e_tm_err_2 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_2, -20606);
    --
    e_tm_err_3 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_3, -20721);
    --
    e_tm_err_4 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_4, -20722);
    --
    e_tm_err_5 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_5, -20724);
    --
    e_tm_err_6 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_6, -20725);
    --
    e_tm_err_7 EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_tm_err_7, -20900);
    --
    l_geom  mdsys.sdo_geometry;
    --
  BEGIN
    --
    IF pi_ne.ne_id IS NULL
     AND pi_nse_id IS NULL
     THEN
        RAISE e_item_not_entered;
    END IF;
    --
    /*
    ||create temp_ne by extent or ne
    */
    IF pi_nse_id IS NOT NULL
     THEN
       lv_job_id := get_extent_location(pi_nse_id => pi_nse_id);
    ELSE
       lv_is_datum := nm3net.is_nt_datum(pi_ne.ne_nt_type);
       --
       lv_job_id := get_network_location(pi_iit_ne_id                => pi_iit.iit_ne_id
                                        ,pi_nit_inv_type             => pi_nit_inv_type
                                        ,pi_ne_id                    => pi_ne.ne_id
                                        ,pi_begin_mp                 => pi_begin_mp
                                        ,pi_end_mp                   => pi_end_mp
                                        ,pi_startdate                => pi_startdate
                                        ,pi_ne_is_datum              => lv_is_datum
                                        ,pi_begin_sect               => pi_begin_sect
                                        ,pi_begin_sect_offset        => pi_begin_sect_offset
                                        ,pi_begin_sect_date_modified => pi_begin_sect_date_modified
                                        ,pi_end_Sect                 => pi_end_Sect
                                        ,pi_end_sect_offset          => pi_end_sect_offset
                                        ,pi_end_sect_date_modified   => pi_end_sect_date_modified
                                        ,pi_ambiguous_sub_class      => pi_ambiguous_sub_class
                                        ,pi_restrict_excl_sub_class  => pi_restrict_excl_sub_class
                                        ,pi_excl_sub_class           => pi_excl_sub_class);
    END IF;
    /*
    ||check temp ne is valid for homo update
    */
    IF NOT(nm3extent.temp_ne_valid_for_homo(pi_job_id => lv_job_id))
     THEN
        RAISE e_extent_not_valid_for_homo;
    END IF;
    --
    add_asset_location(pi_iit            => pi_iit
                      ,pi_startdate      => pi_startdate
                      ,pi_is_datum       => lv_is_datum
                      ,pi_ne_id          => pi_ne.ne_id
                      ,pi_nit_inv_type   => pi_nit_inv_type
                      ,pi_job_id         => lv_job_id
                      ,pi_append_replace => pi_append_replace
                      ,po_messages       => lt_messages);
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
    WHEN e_no_permission
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 86);
    WHEN e_item_not_entered
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 22);
    WHEN e_extent_not_valid_for_homo
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 128);
    WHEN e_no_datums
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 129);
    WHEN e_nte_not_found
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 129
                     ,pi_supplementary_info => ' NM_NW_TEMP_EXTENTS');
    WHEN e_inv_item_not_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 67
                     ,pi_supplementary_info => ' NM_INV_ITEMS');
    WHEN e_future_inv_affected
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 38);
    WHEN e_old_inv_overlapping_st_end
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 42);
    WHEN e_inv_type_invalid_on_nw
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 43);
    WHEN e_invalid_xsp_inv
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 44);
    WHEN e_xsp_required
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 45);
    WHEN e_invalid_xsp_nw
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 46);
    WHEN e_inv_type_not_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 67
                     ,pi_supplementary_info => ' NM_INV_TYPES');
    WHEN e_ne_not_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 67
                     ,pi_supplementary_info => ' NM_ELEMENTS');
    WHEN e_homo_start_equals_end
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 86);
    WHEN e_multiple_not_allowed
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 99);
    WHEN e_point_loc_cont
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 105);
    WHEN e_overlaps
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 102);
    WHEN e_dup_nm
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 104);
    WHEN e_affected_dup_nm
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 103);
    WHEN e_cannot_loc_child_at
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 106);
    WHEN e_overlaps_in_nte
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 116);
    WHEN e_start_after_end
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 80);
    WHEN e_no_connectivity
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 81);
    WHEN e_need_sub_class
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 82);
    WHEN e_cont_start_equals_end
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 86);
    WHEN e_should_not_be_here
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 86);
    WHEN e_no_priv_to_set_au
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 86);
    WHEN e_invalid_au
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 88);
    --
  END add_asset_location;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_asset_location(pi_iit_ne_id                IN     nm_inv_items_all.iit_ne_id%TYPE
                              ,pi_nit_inv_type             IN     nm_inv_types_all.nit_inv_type%TYPE
                              ,pi_ne_id                    IN     nm_elements_all.ne_id%TYPE
                              ,pi_begin_mp                 IN     nm_members_all.nm_begin_mp%TYPE
                              ,pi_end_mp                   IN     nm_members_all.nm_end_mp%TYPE
                              ,pi_startdate                IN     nm_members_all.nm_start_date%TYPE
                              ,pi_append_replace           IN     VARCHAR2
                              ,pi_begin_sect               IN     nm_elements_all.ne_id%TYPE
                              ,pi_begin_sect_offset        IN     NUMBER
                              ,pi_begin_sect_date_modified IN     DATE
                              ,pi_end_sect                 IN     nm_elements_all.ne_id%TYPE
                              ,pi_end_sect_offset          IN     NUMBER
                              ,pi_end_sect_date_modified   IN     DATE
                              ,pi_ambiguous_sub_class      IN     VARCHAR2 DEFAULT NULL
                              ,pi_excl_sub_class           IN     nm_elements_all.ne_sub_class%TYPE DEFAULT NULL
                              ,pi_nse_id                   IN     nm_saved_extents.nse_id%TYPE DEFAULT NULL
                              ,po_message_severity           OUT  hig_codes.hco_code%TYPE
                              ,po_message_cursor             OUT  sys_refcursor)
    IS
    --
    lr_ne nm_elements%ROWTYPE;
    lr_iit nm_inv_items_all%ROWTYPE;
    lv_restrict_excl_sub_class VARCHAR2(1);
    --
  BEGIN
    --
    SAVEPOINT add_location_sp;
    --
    lr_iit := get_asset(pi_iit_ne_id    => pi_iit_ne_id
                       ,pi_nit_inv_type => pi_nit_inv_type);
    --
    IF pi_ne_id IS NOT NULL
     THEN
        lr_ne := nm3net.get_ne(pi_ne_id);
    END IF;
    --
    IF pi_excl_sub_class IS NOT NULL
     THEN
        lv_restrict_excl_sub_class := 'Y';
    ELSE
        lv_restrict_excl_sub_class := 'N';
    END IF;
    --
    add_asset_location(pi_iit                      => lr_iit
                      ,pi_ne                       => lr_ne
                      ,pi_nit_inv_type             => pi_nit_inv_type
                      ,pi_begin_mp                 => pi_begin_mp
                      ,pi_end_mp                   => pi_end_mp
                      ,pi_startdate                => pi_startdate
                      ,pi_append_replace           => pi_append_replace
                      ,pi_begin_sect               => pi_begin_sect
                      ,pi_begin_sect_offset        => pi_begin_sect_offset
                      ,pi_begin_sect_date_modified => pi_begin_sect_date_modified
                      ,pi_end_Sect                 => pi_end_Sect
                      ,pi_end_sect_offset          => pi_end_sect_offset
                      ,pi_end_sect_date_modified   => pi_end_sect_date_modified
                      ,pi_ambiguous_sub_class      => pi_ambiguous_sub_class
                      ,pi_restrict_excl_sub_class  => lv_restrict_excl_sub_class
                      ,pi_excl_sub_class           => pi_excl_sub_class
                      ,pi_nse_id                   => pi_nse_id
                      ,po_message_severity         => po_message_severity
                      ,po_message_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO add_location_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_asset_location;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_asset_location_off_nw(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                     ,pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                                     ,pi_inv_type         IN  nm_inv_items.iit_inv_type%TYPE DEFAULT NULL
                                     ,pi_ne_id            IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                     ,pi_offset           IN  nm_inv_items_all.iit_ne_id%TYPE DEFAULT NULL
                                     ,pi_effective_date   IN  nm_members_all.nm_start_date%TYPE
                                     ,pi_shape_wkt        IN  CLOB
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_geom          mdsys.sdo_geometry;
    lv_job_id        NUMBER;
    lv_warning_code  VARCHAR2(1000);
    lv_warning_msg   VARCHAR2(1000);
    lr_theme         nm_themes_all%ROWTYPE;
    lv_datum_ne_id   nm_elements_all.ne_id%TYPE;
    lv_datum_offset  nm_members_all.nm_ne_id_in%TYPE;
    lr_ne_rec        nm_elements%ROWTYPE;
    --
  BEGIN
    /*
    ||Get Theme
    */
    lr_theme := nm3get.get_nth(pi_nth_theme_name => pi_theme_name);
    --
    IF pi_shape_wkt IS NOT NULL
     THEN
        /*
        ||Convert WKT to SDO format.
        */
        lv_geom := awlrs_sdo.wkt_to_sdo_geom(pi_theme_name => pi_theme_name
                                            ,pi_shape      => pi_shape_wkt);
        /*
        ||create shape using same call as SM
        */
        nm3homo_gis.locate_item(pi_gt_theme_id    => lr_theme.nth_theme_id
                               ,pi_item_id        => pi_iit_ne_id
                               ,pi_start_ne_id    => NULL
                               ,pi_start_offset   => NULL
                               ,pi_effective_date => trunc(pi_effective_date)
                               ,pi_geom           => lv_geom);
        --
        /*
        ||If off network and snap to specified then replace network location with specified ne_id
        ||bp and ep offset will be same as only available for xy points.
        */
        IF pi_ne_id IS NOT NULL AND pi_offset IS NOT NULL
         THEN
            --
            /*
            ||Get datum elements if route on first row until dialog amended.
            ||needs refactoring once UI is amended to allow user selection for ambiguous.
            */
            IF nm3net.is_nt_datum(nm3net.get_nt_type(pi_ne_id)) = 'N'
             THEN
                nm3wrap.get_ambiguous_lrefs(pi_parent_id => pi_ne_id
                                           ,pi_offset    => pi_offset
                                           ,pi_sub_class => ''
                                           ,pi_position  => 'S');
                --
                IF nm3wrap.lref_count > 0
                 THEN
                    nm3wrap.lref_get_row(pi_index  => 1
                                        ,po_ne_id  => lv_datum_ne_id
                                        ,po_offset => lv_datum_offset);
                    --
                    lr_ne_rec := nm3net.get_ne_all_rowtype(pi_ne_id => lv_datum_ne_id);
                    --
                END IF;
            ELSE
                --
                lv_datum_ne_id := pi_ne_id;
                lv_datum_offset := pi_offset;
                lr_ne_rec := nm3net.get_ne_all_rowtype(pi_ne_id => lv_datum_ne_id);
                --
            END IF;
            --
            add_asset_location(pi_iit_ne_id                => pi_iit_ne_id
                              ,pi_nit_inv_type             => pi_inv_type
                              ,pi_ne_id                    => pi_ne_id
                              ,pi_begin_mp                 => pi_offset
                              ,pi_end_mp                   => pi_offset
                              ,pi_startdate                => trunc(pi_effective_date)
                              ,pi_append_replace           => 'R'
                              ,pi_begin_sect               => lv_datum_ne_id
                              ,pi_begin_sect_offset        => lv_datum_offset
                              ,pi_begin_sect_date_modified => lr_ne_rec.ne_date_modified
                              ,pi_end_sect                 => lv_datum_ne_id
                              ,pi_end_sect_offset          => lv_datum_offset
                              ,pi_end_sect_date_modified   => lr_ne_rec.ne_date_modified
                              ,pi_ambiguous_sub_class      => NULL
                              ,pi_excl_sub_class           => NULL
                              ,pi_nse_id                   => NULL
                              ,po_message_severity         => po_message_severity
                              ,po_message_cursor           => po_message_cursor);
            --
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
  END add_asset_location_off_nw;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE location_enddate(pi_asset_type       IN  nm_inv_items_all.iit_inv_type%TYPE
                            ,pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                            ,pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                            ,pi_x_sect           IN  nm_inv_items_all.iit_x_sect%TYPE
                            ,pi_end_date         IN  DATE
                            ,pi_datum            IN  VARCHAR2
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
    e_field_required EXCEPTION;
    --
    e_inv_item_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_inv_item_not_found, -20502);
    --
    e_future_inv_affected EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_future_inv_affected, -20503);
    --
    e_inv_type_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_inv_type_not_found, -20509);
    --
    e_cross_attr_val_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cross_attr_val_failed, -20760);
    -- -20530 Location is mandatory for this item or its children.
    e_loc_mand EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_loc_mand, -20530);
    -- -20531 Cannot remove inventory locations which are in a Child AT relationship
    e_child_item EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_child_item, -20531);
    --
    lv_warning_code  VARCHAR2(2000);
    lv_warning_msg   VARCHAR2(2000);
    --
    lr_nit  nm_inv_types%ROWTYPE ;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    IF nm3inv.inv_location_is_mandatory(nm3inv.get_inv_type(p_ne_id => pi_iit_ne_id))
     THEN
        --
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 459);
        --
    END IF;
    --
    nm3inv.set_inv_warning_msg(p_msg => NULL);
    --
    nm3homo.end_inv_location(pi_iit_ne_id        => pi_iit_ne_id
                            ,pi_effective_date   => pi_end_date
                            ,pi_check_for_parent => TRUE
                            ,po_warning_code     => lv_warning_code
                            ,po_warning_msg      => lv_warning_msg);
    --
    lr_nit := nm3get.get_nit(pi_asset_type);
    --
    check_contiguity(pi_asset_type   => pi_asset_type
                    ,pi_datum        => pi_datum
                    ,pi_ne_id        => pi_ne_id
                    ,pi_x_sect       => pi_x_sect
                    ,po_warning_code => lv_warning_code);
    --
    IF lv_warning_code IS NOT NULL
     THEN
        IF lv_warning_code = nm3homo.get_contiguous_warning_const
         THEN
            --contiguous warning
           awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'NET'
                                            ,pi_ner_id             => 95
                                            ,pi_supplementary_info => '. This check has been done across the whole of this piece of Network.'
                                            ,pi_category           => awlrs_util.c_msg_cat_warning
                                            ,po_message_tab        => lt_messages);
        ELSE
            --unknown warning
            awlrs_util.add_ner_to_message_tab(pi_ner_appl           => 'NET'
                                             ,pi_ner_id             => 94
                                             ,pi_supplementary_info => lv_warning_code
                                             ,pi_category           => awlrs_util.c_msg_cat_warning
                                             ,po_message_tab        => lt_messages);
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
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN e_field_required
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 22
                     ,pi_supplementary_info => ' NM_INV_ITEMS');
    WHEN e_inv_item_not_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 67
                     ,pi_supplementary_info => ' NM_INV_ITEMS');
    WHEN e_future_inv_affected
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 178);
    WHEN e_inv_type_not_found
     THEN
        hig.raise_ner(pi_appl => 'HIG'
                     ,pi_id   => 67
                     ,pi_supplementary_info => 'NM_INV_TYPES');
    WHEN e_loc_mand
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 175);
    WHEN e_child_item
     THEN
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 176);
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END location_enddate;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_locations(pi_iit_ne_id IN  nm_inv_items_all.iit_ne_id%TYPE
                         ,po_cursor    OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM nm_members
     WHERE nm_ne_id_in = pi_iit_ne_id
       AND nm_type = 'I'
     ORDER
        BY nm_seq_no
         ;
    --
  END get_locations;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_loc_types(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                                 ,pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                 ,pi_filter           IN  VARCHAR2
                                 ,pi_skip_n_rows      IN  PLS_INTEGER
                                 ,pi_pagesize         IN  PLS_INTEGER
                                 ,po_message_severity OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor   OUT sys_refcursor
                                 ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_plrm_check       nm3type.max_varchar2;
    lv_im_sql           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    lt_pla         nm_placement_array := nm3pla.initialise_placement_array;
    lt_datum_locs  nm3asset.tab_rec_datum_loc_dets;
    --
  BEGIN
    /*
    ||Get the asset type record.
    */
    lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_inv_type);
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := CHR(10)||'                 WHERE UPPER(description) LIKE ''%''||f.filter_value||''%''';
        --
    END IF;
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||If Preferred LRM is set then make the relevant group type
    ||come to the top of the list.
    */
    IF awlrs_util.get_preferred_lrm != awlrs_util.c_all_lrms_code
     THEN
        lv_plrm_check := '                         WHEN group_type IS NOT NULL AND group_type = SYS_CONTEXT(''NM3CORE'',''PREFERRED_LRM'') THEN 0';
    END IF;
    /*
    ||Set the query that will return the assets datum locations.
    */
    IF lr_nit.nit_table_name IS NULL
     THEN
        lv_im_sql := '    ,im AS(SELECT nm_ne_id_of ne_id FROM nm_members WHERE nm_ne_id_in = :pi_iit_ne_id)';
    ELSE
        /*
        ||Get Datums.
        */
        nm3asset.get_inv_datum_location_details(pi_iit_ne_id          => pi_iit_ne_id
                                               ,pi_nit_inv_type       => pi_inv_type
                                               ,po_tab_datum_loc_dets => lt_datum_locs);
        /*
        ||Build a placement array of datums.
        */
        FOR i IN 1..lt_datum_locs.COUNT LOOP
          --
          nm3pla.add_element_to_pl_arr(pio_pl_arr => lt_pla
                                      ,pi_ne_id   => lt_datum_locs(i).datum_ne_id
                                      ,pi_start   => lt_datum_locs(i).nm_begin_mp
                                      ,pi_end     => lt_datum_locs(i).nm_end_mp);
          --
        END LOOP;
        /*
        ||Set the query.
        */
        lv_im_sql := '    ,im AS(SELECT pl_ne_id ne_id FROM TABLE(:pla))';
        --
    END IF;
    /*
    ||Build the cursor.
    */
    lv_cursor_sql := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
          ||CHR(10)||lv_im_sql
          ||CHR(10)||'SELECT network_type'
          ||CHR(10)||'      ,group_type'
          ||CHR(10)||'      ,description'
          ||CHR(10)||'      ,row_count'
          ||CHR(10)||'  FROM (SELECT rownum ind'
          ||CHR(10)||'              ,network_type'
          ||CHR(10)||'              ,group_type'
          ||CHR(10)||'              ,description||CASE WHEN group_type IS NOT NULL AND group_type = SYS_CONTEXT(''NM3CORE'',''PREFERRED_LRM'') THEN '' *'' ELSE NULL END description'
          ||CHR(10)||'              ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
          ||CHR(10)||'          FROM (SELECT network_type'
          ||CHR(10)||'                      ,group_type'
          ||CHR(10)||'                      ,description'
          ||CHR(10)||'                      ,CASE'
          ||CHR(10)||lv_plrm_check
          ||CHR(10)||'                         WHEN f.filter_value IS NULL AND is_linear_group = ''Y'' THEN 2'
          ||CHR(10)||'                         WHEN f.filter_value IS NULL THEN 3'
          ||CHR(10)||'                         WHEN UPPER(description) = f.filter_value THEN 4'
          ||CHR(10)||'                         WHEN UPPER(description) LIKE f.filter_value||''%'' THEN 5'
          ||CHR(10)||'                         ELSE 6'
          ||CHR(10)||'                       END match_quality'
          ||CHR(10)||'                  FROM (SELECT ngt_linear_flag is_linear_group'
          ||CHR(10)||'                              ,ngt_nt_type     network_type'
          ||CHR(10)||'                              ,ngt_group_type  group_type'
          ||CHR(10)||'                              ,ngt_descr       description'
          ||CHR(10)||'                          FROM nm_group_types_all'
          ||CHR(10)||'                         WHERE ngt_group_type IN(SELECT rm.nm_obj_type'
          ||CHR(10)||'                                                   FROM im'
          ||CHR(10)||'                                                       ,nm_members rm'
          ||CHR(10)||'                                                  WHERE im.ne_id = rm.nm_ne_id_of'
          ||CHR(10)||'                                                    AND rm.nm_type = ''G'')'
          ||CHR(10)||'                        UNION ALL'
          ||CHR(10)||'                        SELECT ''N''     is_linear_group'
          ||CHR(10)||'                              ,nt_type   network_type'
          ||CHR(10)||'                              ,NULL      group_type'
          ||CHR(10)||'                              ,nt_unique description'
          ||CHR(10)||'                          FROM nm_types'
          ||CHR(10)||'                         WHERE nt_type IN(SELECT ne.ne_nt_type'
          ||CHR(10)||'                                                FROM im'
          ||CHR(10)||'                                                    ,nm_elements ne'
          ||CHR(10)||'                                               WHERE im.ne_id = ne.ne_id)'
          ||CHR(10)||'                         ORDER BY 4)'
          ||CHR(10)||'                      ,filter_tab f'
                   ||lv_filter
          ||CHR(10)||'                 ORDER BY match_quality,description))'
          ||CHR(10)||lv_row_restriction
    ;
    --
    IF lr_nit.nit_table_name IS NULL
     THEN
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_iit_ne_id
                 ,lv_lower_index
                 ,lv_upper_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,pi_iit_ne_id
                 ,lv_lower_index;
        END IF;
    ELSE
        IF pi_pagesize IS NOT NULL
         THEN
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,lt_pla.npa_placement_array
                 ,lv_lower_index
                 ,lv_upper_index;
        ELSE
            OPEN po_cursor FOR lv_cursor_sql
            USING pi_filter
                 ,lt_pla.npa_placement_array
                 ,lv_lower_index;
        END IF;
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
  END get_list_of_loc_types;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_locations(pi_iit_ne_id    IN nm_inv_items_all.iit_ne_id%TYPE
                        ,pi_iit_inv_type IN nm_inv_items_all.iit_inv_type%TYPE
                        ,pi_nwtype       IN nm_elements.ne_nt_type%TYPE
                        ,pi_grouptype    IN nm_elements.ne_gty_group_type%TYPE)
    RETURN nm_placement_array IS
    --
    lt_pla  nm_placement_array := nm3pla.initialise_placement_array;
    --
    lv_pref_lrm  nm_group_types.ngt_group_type%TYPE := nm3user.get_preferred_lrm;
    --
    lt_datum_locs   nm3asset.tab_rec_datum_loc_dets;
    lt_route_locs   nm3route_ref.tab_rec_route_loc_dets;
    lt_nl_grp_locs  nm3asset.tab_rec_nl_grp_membership;
    --
  BEGIN
    --
    IF pi_grouptype IS NULL
     THEN
        /*
        ||Get Datums.
        */
        nm3asset.get_inv_datum_location_details(pi_iit_ne_id          => pi_iit_ne_id
                                               ,pi_nit_inv_type       => pi_iit_inv_type
                                               ,po_tab_datum_loc_dets => lt_datum_locs);
        --
        FOR i IN 1..lt_datum_locs.COUNT LOOP
          --
          nm3pla.add_element_to_pl_arr(pio_pl_arr => lt_pla
                                      ,pi_ne_id   => lt_datum_locs(i).datum_ne_id
                                      ,pi_start   => lt_datum_locs(i).nm_begin_mp
                                      ,pi_end     => lt_datum_locs(i).nm_end_mp);
          --
        END LOOP;
        --
    ELSIF nm3net.is_nt_linear(pi_nwtype) = 'Y'
     THEN
        /*
        ||Get Linear Groups.
        */
        nm3user.set_preferred_lrm(pi_group_type   => pi_grouptype
                                 ,pi_set_user_opt => FALSE);
        --
        nm3asset.get_inv_route_location_details(pi_iit_ne_id          => pi_iit_ne_id
                                               ,pi_nit_inv_type       => pi_iit_inv_type
                                               ,po_tab_route_loc_dets => lt_route_locs);
        --
        nm3user.set_preferred_lrm(pi_group_type   => lv_pref_lrm
                                 ,pi_set_user_opt => FALSE);
        --
        FOR i IN 1..lt_route_locs.COUNT LOOP
          --
          nm3pla.add_element_to_pl_arr(pio_pl_arr => lt_pla
                                      ,pi_ne_id   => lt_route_locs(i).route_ne_id
                                      ,pi_start   => lt_route_locs(i).nm_slk
                                      ,pi_end     => lt_route_locs(i).nm_end_slk);
          --
        END LOOP;
        --
    ELSE
        /*
        ||Get Non Linear Groups.
        */
        nm3asset.get_non_linear_grp_membership(pi_iit_inv_type              => pi_iit_inv_type
                                              ,pi_iit_ne_id                 => pi_iit_ne_id
                                              ,po_tab_rec_nl_grp_membership => lt_nl_grp_locs);
        --
        FOR i IN 1..lt_nl_grp_locs.COUNT LOOP
          --
          nm3pla.add_element_to_pl_arr(pio_pl_arr => lt_pla
                                      ,pi_ne_id   => lt_nl_grp_locs(i).ne_id
                                      ,pi_start   => NULL
                                      ,pi_end     => NULL);
          --
        END LOOP;
        --
    END IF;
    --
    RETURN lt_pla;
    --
  END get_locations;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_list_of_elements(pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                                ,pi_filter           IN  VARCHAR2
                                ,pi_skip_n_rows      IN  PLS_INTEGER
                                ,pi_pagesize         IN  PLS_INTEGER
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    lv_cursor_sql       nm3type.max_varchar2 := 'WITH filter_tab AS (SELECT UPPER(:filter) filter_value FROM dual)'
                                            ||' SELECT id'
                                                   ||',name'
                                                   ||',min_offset'
                                                   ||',max_offset'
                                                   ||',row_count'
                                              ||' FROM (SELECT rownum ind'
                                                           ||',results.*'
                                                           ||',COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                      ||' FROM (SELECT ne_id id'
                                                                   ||',CASE '
                                                                     ||' WHEN ne_gty_group_type IS NULL THEN nt_unique'
                                                                     ||' ELSE ngt_descr'
                                                                   ||' END||'' - ''||ne_unique||'' - ''||ne_descr name'
                                                                   ||',CASE'
                                                                     ||' WHEN ne_gty_group_type IS NULL THEN 0'
                                                                     ||' WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = ''Y'' THEN (SELECT MIN(nm_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)'
                                                                     ||' ELSE NULL'
                                                                   ||' END min_offset'
                                                                   ||',CASE'
                                                                     ||' WHEN ne_gty_group_type IS NULL THEN ne_length'
                                                                     ||' WHEN ne_gty_group_type IS NOT NULL AND ngt_linear_flag = ''Y'' THEN (SELECT MAX(nm_end_slk) FROM nm_members WHERE nm_ne_id_in = ne_id)'
                                                                     ||' ELSE NULL'
                                                                   ||' END max_offset'
                                                                   ||',CASE'
                                                                     ||' WHEN f.filter_value IS NULL THEN 0'
                                                                     ||' WHEN UPPER(ne_unique) = f.filter_value THEN 1'
                                                                     ||' WHEN UPPER(ne_descr) = f.filter_value THEN 2'
                                                                     ||' WHEN UPPER(ne_unique) LIKE f.filter_value||''%'' THEN 3'
                                                                     ||' WHEN UPPER(ne_descr) LIKE f.filter_value||''%'' THEN 4'
                                                                     ||' ELSE 5'
                                                                   ||' END match_quality'
                                                              ||' FROM nm_group_types'
                                                                   ||',nm_types'
                                                                   ||',nm_elements'
                                                                   ||',filter_tab f'
                                                             ||' WHERE (ne_nt_type, NVL(ne_gty_group_type,''~~~~~'')) IN(WITH datum_types AS(SELECT nin_nw_type network_type'
                                                                                                                                           ||' FROM nm_inv_nw'
                                                                                                                                          ||' WHERE nin_nit_inv_code = :pi_inv_type)'
                                                                                                                     ||' SELECT ngt_nt_type     network_type'
                                                                                                                            ||',ngt_group_type  group_type'
                                                                                                                       ||' FROM nm_group_types_all'
                                                                                                                      ||' WHERE ngt_linear_flag = ''Y'''
                                                                                                                        ||' AND ngt_group_type IN(SELECT nng_group_type'
                                                                                                                                                ||' FROM nm_nt_groupings'
                                                                                                                                               ||' WHERE nng_nt_type IN(SELECT network_type'
                                                                                                                                                                      ||' FROM datum_types))'
                                                                                                                     ||' UNION ALL'
                                                                                                                     ||' SELECT network_type'
                                                                                                                            ||',''~~~~~'' group_type'
                                                                                                                       ||' FROM datum_types)'
                                                               ||' AND ne_nt_type = nt_type'
                                                               ||' AND ne_gty_group_type = ngt_group_type(+)'
    ;
    --
  BEGIN
    /*
    ||Set the filter.
    */
    IF pi_filter IS NOT NULL
     THEN
        --
        lv_filter := ' AND UPPER(ne_unique||'' - ''||ne_descr) LIKE ''%''||f.filter_value||''%''';
        --
    END IF;
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    --
    lv_cursor_sql := lv_cursor_sql
                     ||lv_filter
                     ||' ORDER BY match_quality,ne_unique) results)'
                     ||lv_row_restriction;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_inv_type
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_filter
             ,pi_inv_type
             ,lv_lower_index;
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
  END get_list_of_elements;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_locations(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                         ,pi_iit_inv_type     IN  nm_inv_items_all.iit_inv_type%TYPE
                         ,pi_nwtype           IN  nm_elements.ne_nt_type%TYPE
                         ,pi_grouptype        IN  nm_elements.ne_gty_group_type%TYPE
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                         ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_pla  nm_placement_array := nm3pla.initialise_placement_array;
    --
  BEGIN
    --
    lt_pla := get_locations(pi_iit_ne_id    => pi_iit_ne_id
                           ,pi_iit_inv_type => pi_iit_inv_type
                           ,pi_nwtype       => pi_nwtype
                           ,pi_grouptype    => pi_grouptype);
    --
    OPEN po_cursor FOR
    SELECT *
      FROM (SELECT pi_iit_ne_id     asset_id
                  ,ne.ne_id         element_id
                  ,ne.ne_nt_type    element_type
                  ,CASE ne.ne_nt_type
                     WHEN 'ESU' THEN ne.ne_name_1
                     WHEN 'NSGN' THEN ne.ne_number
                     ELSE ne.ne_unique
                   END              element_unique
                  ,ne.ne_descr      element_descr
                  ,TO_NUMBER(nm3unit.get_formatted_value(locs.pl_start, un_unit_id)) from_offset
                  ,TO_NUMBER(nm3unit.get_formatted_value(locs.pl_end, un_unit_id))   to_offset
                  ,TO_NUMBER(nm3unit.get_formatted_value(CASE
                                                          WHEN locs.pl_end > locs.pl_start
                                                           THEN
                                                              locs.pl_end - locs.pl_start
                                                          ELSE
                                                              locs.pl_start - locs.pl_end
                                                         END
                                                        ,un_unit_id)) offset_length
                  ,nm3net.get_ne_length(ne.ne_id) element_length
                  ,un_unit_id         element_unit_id
                  ,un_unit_name       element_unit_name
                  ,nau_name           element_admin_unit
                  ,ne_start_date      element_start_date
                  ,CASE
                     WHEN pi_grouptype IS NOT NULL
                      THEN
                         (SELECT MIN(im.nm_start_date)
                            FROM nm_members rm
                                ,nm_members im
                           WHERE im.nm_ne_id_in = pi_iit_ne_id
                             AND im.nm_ne_id_of = rm.nm_ne_id_of
                             AND rm.nm_ne_id_in = ne_id
                             AND rm.nm_obj_type = pi_grouptype)
                     ELSE
                         (SELECT MIN(nm_start_date)
                            FROM nm_members
                           WHERE nm_ne_id_in = pi_iit_ne_id
                             AND nm_ne_id_of = ne_id)
                   END member_start_date
              FROM TABLE(lt_pla.npa_placement_array) locs
                  ,nm_admin_units_all
                  ,nm_elements_all ne
                  ,nm_types
                  ,nm_units
                  ,nm_unit_domains
             WHERE ud_domain_name(+) = 'LENGTH'
               AND ud_domain_id(+) = un_domain_id
               AND un_unit_id(+) = nt_length_unit
               AND nt_type = ne_nt_type
               AND ne.ne_admin_unit = nau_admin_unit
               AND NVL(ne.ne_gty_group_type,'~~~~~') = NVL(pi_grouptype,'~~~~~')
               AND ne.ne_nt_type = pi_nwtype
               AND ne.ne_id = locs.pl_ne_id)
     ORDER
        BY element_unique
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
  END get_locations;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_locations(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                               ,pi_iit_inv_type     IN  nm_inv_items_all.iit_inv_type%TYPE
                               ,pi_nwtype           IN  nm_elements.ne_nt_type%TYPE
                               ,pi_grouptype        IN  nm_elements.ne_gty_group_type%TYPE
                               ,pi_filter_columns   IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                               ,pi_filter_operators IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                               ,pi_filter_values_1  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                               ,pi_filter_values_2  IN  nm3type.tab_varchar32767 DEFAULT CAST(NULL AS nm3type.tab_varchar32767)
                               ,pi_order_columns    IN  nm3type.tab_varchar30 DEFAULT CAST(NULL AS nm3type.tab_varchar30)
                               ,pi_order_asc_desc   IN  nm3type.tab_varchar4 DEFAULT CAST(NULL AS nm3type.tab_varchar4)
                               ,pi_skip_n_rows      IN  PLS_INTEGER
                               ,pi_pagesize         IN  PLS_INTEGER
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor
                               ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_pla  nm_placement_array := nm3pla.initialise_placement_array;
    --
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'WITH asset AS (SELECT :asset_id asset_id FROM DUAL)'
                                         ||' SELECT asset_id asset_id'
                                                ||',ne.ne_id element_id'
                                                ||',ne.ne_nt_type element_type'
                                                ||',CASE ne.ne_nt_type'
                                                  ||' WHEN ''ESU'' THEN ne.ne_name_1'
                                                  ||' WHEN ''NSGN'' THEN ne.ne_number'
                                                  ||' ELSE ne.ne_unique'
                                                ||' END element_unique'
                                                ||',ne.ne_descr element_descr'
                                                ||',TO_NUMBER(nm3unit.get_formatted_value(locs.pl_start, un_unit_id)) from_offset'
                                                ||',TO_NUMBER(nm3unit.get_formatted_value(locs.pl_end, un_unit_id)) to_offset'
                                                ||',TO_NUMBER(nm3unit.get_formatted_value(CASE'
                                                                                        ||' WHEN locs.pl_end > locs.pl_start'
                                                                                         ||' THEN'
                                                                                            ||' locs.pl_end - locs.pl_start'
                                                                                        ||' ELSE'
                                                                                            ||' locs.pl_start - locs.pl_end'
                                                                                      ||' END'
                                                                                     ||' ,un_unit_id)) offset_length'
                                                ||',nm3net.get_ne_length(ne.ne_id) element_length'
                                                ||',un_unit_id element_unit_id'
                                                ||',un_unit_name element_unit_name'
                                                ||',nau_name element_admin_unit'
                                                ||',ne_start_date element_start_date'
                                                ||',CASE '
                                                  ||' WHEN ne_gty_group_type IS NOT NULL'
                                                   ||' THEN'
                                                      ||' (SELECT MIN(im.nm_start_date)'
                                                         ||' FROM nm_members rm'
                                                             ||' ,nm_members im'
                                                        ||' WHERE im.nm_ne_id_in = asset_id'
                                                          ||' AND im.nm_ne_id_of = rm.nm_ne_id_of'
                                                          ||' AND rm.nm_ne_id_in = ne_id'
                                                          ||' AND rm.nm_obj_type = ne_gty_group_type)'
                                                  ||' ELSE'
                                                      ||' (SELECT MIN(nm_start_date)'
                                                         ||' FROM nm_members'
                                                        ||' WHERE nm_ne_id_in = asset_id'
                                                          ||' AND nm_ne_id_of = ne_id)'
                                                ||' END member_start_date'
                                           ||' FROM TABLE(CAST(:pla AS nm_placement_array_type)) locs'
                                               ||' ,nm_elements_all ne'
                                               ||' ,nm_admin_units_all'
                                               ||' ,nm_types'
                                               ||' ,nm_units'
                                               ||' ,nm_unit_domains'
                                               ||' ,asset'
                                          ||' WHERE locs.pl_ne_id = ne.ne_id'
                                            ||' AND ne.ne_nt_type = :nwtype'
                                            ||' AND NVL(ne.ne_gty_group_type,''~~~~~'') = NVL(:grouptype,''~~~~~'')'
                                            ||' AND ne.ne_admin_unit = nau_admin_unit'
                                            ||' AND ne_nt_type = nt_type'
                                            ||' AND nt_length_unit = un_unit_id(+)'
                                            ||' AND un_domain_id = ud_domain_id(+)'
                                            ||' AND ud_domain_name(+) = ''LENGTH'''
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT asset_id'
                            ||CHR(10)||'          ,element_id'
                            ||CHR(10)||'          ,element_type'
                            ||CHR(10)||'          ,element_unique'
                            ||CHR(10)||'          ,element_descr'
                            ||CHR(10)||'          ,from_offset'
                            ||CHR(10)||'          ,to_offset'
                            ||CHR(10)||'          ,offset_length'
                            ||CHR(10)||'          ,element_length'
                            ||CHR(10)||'          ,element_unit_id'
                            ||CHR(10)||'          ,element_unit_name'
                            ||CHR(10)||'          ,element_admin_unit'
                            ||CHR(10)||'          ,element_start_date'
                            ||CHR(10)||'          ,member_start_date'
                            ||CHR(10)||'          ,row_count'
                            ||CHR(10)||'      FROM (SELECT rownum ind'
                            ||CHR(10)||'                  ,a.*'
                            ||CHR(10)||'                  ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                            ||CHR(10)||'              FROM ('||lv_driving_sql
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_id'
                                ,pi_query_col  => 'ne_id'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_type'
                                ,pi_query_col  => 'ne_nt_type'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_unique'
                                ,pi_query_col  => 'CASE ne.ne_nt_type WHEN ''ESU'' THEN ne.ne_name_1 WHEN ''NSGN'' THEN ne.ne_number ELSE ne.ne_unique END'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_descr'
                                ,pi_query_col  => 'ne_descr'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'from_offset'
                                ,pi_query_col  => 'TO_NUMBER(nm3unit.get_formatted_value(locs.pl_start, un_unit_id))'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'to_offset'
                                ,pi_query_col  => 'TO_NUMBER(nm3unit.get_formatted_value(locs.pl_end, un_unit_id))'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'offset_length'
                                ,pi_query_col  => 'TO_NUMBER(nm3unit.get_formatted_value(CASE WHEN locs.pl_end > locs.pl_start THEN locs.pl_end - locs.pl_start ELSE locs.pl_start - locs.pl_end END,un_unit_id))'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_length'
                                ,pi_query_col  => 'nm3net.get_ne_length(ne.ne_id)'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_unit_id'
                                ,pi_query_col  => 'un_unit_id'
                                ,pi_datatype   => awlrs_util.c_number_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_unit_name'
                                ,pi_query_col  => 'un_unit_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_admin_unit'
                                ,pi_query_col  => 'nau_name'
                                ,pi_datatype   => awlrs_util.c_varchar2_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'element_start_date'
                                ,pi_query_col  => 'ne_start_date'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col => 'member_start_date'
                                ,pi_query_col  => 'CASE  WHEN ne_gty_group_type IS NOT NULL THEN (SELECT MIN(im.nm_start_date) FROM nm_members rm,nm_members im WHERE im.nm_ne_id_in = asset_id AND im.nm_ne_id_of = rm.nm_ne_id_of AND rm.nm_ne_id_in = ne_id AND rm.nm_obj_type = ne_gty_group_type) ELSE (SELECT MIN(nm_start_date) FROM nm_members WHERE nm_ne_id_in = asset_id AND nm_ne_id_of = ne_id) END'
                                ,pi_datatype   => awlrs_util.c_date_col
                                ,pi_mask       => NULL
                                ,pio_column_data => po_column_data);
      --
    END set_column_data;
    --
  BEGIN
    /*
    ||Get the locations.
    */
    lt_pla := get_locations(pi_iit_ne_id    => pi_iit_ne_id
                           ,pi_iit_inv_type => pi_iit_inv_type
                           ,pi_nwtype       => pi_nwtype
                           ,pi_grouptype    => pi_grouptype);
    /*
    ||Get the page parameters.
    */
    awlrs_util.gen_row_restriction(pi_index_column => 'ind'
                                  ,pi_skip_n_rows  => pi_skip_n_rows
                                  ,pi_pagesize     => pi_pagesize
                                  ,po_lower_index  => lv_lower_index
                                  ,po_upper_index  => lv_upper_index
                                  ,po_statement    => lv_row_restriction);
    /*
    ||Get the Order By clause.
    */
    lv_order_by := awlrs_util.gen_order_by(pi_order_columns  => pi_order_columns
                                          ,pi_order_asc_desc => pi_order_asc_desc);
    /*
    ||Process the filter.
    */
    IF pi_filter_columns.COUNT > 0
     THEN
        --
        set_column_data(po_column_data => lt_column_data);
        --
        awlrs_util.process_filter(pi_columns      => pi_filter_columns
                                 ,pi_column_data  => lt_column_data
                                 ,pi_operators    => pi_filter_operators
                                 ,pi_values_1     => pi_filter_values_1
                                 ,pi_values_2     => pi_filter_values_2
                                 ,pi_where_or_and => 'AND'
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
                     ||CHR(10)||lv_filter
                     ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'element_unique')||') a)'
                     ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_iit_ne_id
             ,lt_pla.npa_placement_array
             ,pi_nwtype
             ,pi_grouptype
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_iit_ne_id
             ,lt_pla.npa_placement_array
             ,pi_nwtype
             ,pi_grouptype
             ,lv_lower_index;
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
  END get_paged_locations;

  --
  -----------------------------------------------------------------------------
  --
  --NB. If the value of pi_run_checks passed in is not 'Y' then the calling code
  --should have already called the procedure with the value as 'Y' and handled any
  --errors or prompts for user confirmation.
  PROCEDURE asset_close(pi_asset_type       IN  nm_inv_items_all.iit_inv_type%TYPE
                       ,pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                       ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                       ,pi_run_checks       IN  VARCHAR2 DEFAULT 'Y'
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types%ROWTYPE;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT asset_close_sp;
    --
    DECLARE
      e_record_locked EXCEPTION;
      PRAGMA exception_init(e_record_locked, -54);
    BEGIN
      --
      lr_nit := nm3get.get_nit(pi_asset_type);
      --
      IF pi_run_checks = 'Y'
       THEN
          IF lr_nit.nit_contiguous = 'Y'
           THEN
              --
              awlrs_util.add_ner_to_message_tab(pi_ner_appl    => 'NET'
                                               ,pi_ner_id      => 125
                                               ,pi_category    => awlrs_util.c_msg_cat_ask_continue
                                               ,po_message_tab => lt_messages);
              --
          END IF;
      END IF;
      --
      IF lt_messages.COUNT > 0
       THEN
          --
          awlrs_util.get_message_cursor(pi_message_tab => lt_messages
                                       ,po_cursor      => po_message_cursor);
          --
          awlrs_util.get_highest_severity(pi_message_tab      => lt_messages
                                         ,po_message_severity => po_message_severity);
          --
      ELSE
          --
          UPDATE nm_inv_items_all
             SET iit_end_date = pi_effective_date
           WHERE iit_inv_type = pi_asset_type
             AND iit_ne_id = pi_iit_ne_id
               ;
          --
          awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                               ,po_cursor           => po_message_cursor);
          --
      END IF;
      --
    EXCEPTION
      WHEN e_record_locked
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33);
    END;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO asset_close_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END asset_close;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE asset_reopen(pi_asset_type       IN  nm_inv_items_all.iit_inv_type%TYPE
                        ,pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_nit nm_inv_types%ROWTYPE;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT asset_reopen_sp;
    --
    UPDATE nm_inv_items_all
       SET iit_end_date = null
     WHERE iit_inv_type = pi_asset_type
       AND iit_ne_id = pi_iit_ne_id
         ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO asset_reopen_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END asset_reopen;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_child_asset_type(pi_inv_type IN nm_inv_types.nit_inv_type%TYPE)
   RETURN BOOLEAN IS
    --
  BEGIN
    --
    RETURN pi_inv_type <> nm3inv.get_top_item_type(pi_inv_type) AND nm3inv.get_itg(pi_inv_type => pi_inv_type).itg_relation <> 'DERIVED';
    --
  END is_child_asset_type;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_groupings(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                         ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
      SELECT iig_top_id    toplevelid
            ,nm3inv.get_inv_type(iig_top_id)  toplevelassettype
            ,nm3inv.get_inv_primary_key(p_ne_id => iig_top_id)toplevelpk
            ,iig_item_id   itemid
            ,nm3inv.get_inv_type(iig_item_id) itemlevelassettype
            ,iig_parent_id parentid
            ,nm3inv.get_inv_type(iig_parent_id) parentlevelassettype
            ,nm3inv.get_inv_primary_key(p_ne_id => iig_parent_id)parentlevelpk
        FROM nm_inv_item_groupings
       WHERE iig_top_id = nm3inv.get_top_item_id(pi_iit_ne_id)
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
  END get_groupings;
  --

END awlrs_asset_api;
/
