CREATE OR REPLACE PACKAGE BODY awlrs_plm_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_plm_api.pkb-arc   1.17   Apr 20 2020 15:55:48   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_plm_api.pkb  $
  --       Date into PVCS   : $Date:   Apr 20 2020 15:55:48  $
  --       Date fetched Out : $Modtime:   Apr 20 2020 15:53:40  $
  --       Version          : $Revision:   1.17  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.17  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_plm_api';
  --
  g_max_layers      PLS_INTEGER;
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
  FUNCTION get_cons_rec_type
    RETURN nm_inv_types_all.nit_inv_type%TYPE IS
  BEGIN
    --
    RETURN NVL(hig.get_sysopt('AWPLMCRTY'),'PCR');
    --
  END get_cons_rec_type;
  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_layer_type
    RETURN nm_inv_types_all.nit_inv_type%TYPE IS
  BEGIN
    --
    RETURN NVL(hig.get_sysopt('AWPLMCLTY'),'PCL');
    --
  END get_layer_type;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_messages(pi_message_cursor IN     sys_refcursor
                        ,po_message_tab    IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lt_messages  awlrs_util.message_tab;
    --
  BEGIN
    --
    FETCH pi_message_cursor
     BULK COLLECT
     INTO lt_messages;
    CLOSE pi_message_cursor;
    --
    FOR i IN 1..lt_messages.COUNT LOOP
      --
      awlrs_util.add_message(pi_category    => lt_messages(i).category
                            ,pi_message     => lt_messages(i).message
                            ,po_message_tab => po_message_tab);
      --
    END LOOP;
    --
  END get_messages;
  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_next_layer_number(pi_parent_primary_key IN nm_inv_items_all.iit_primary_key%TYPE)
    RETURN NUMBER IS
    --
    lv_inv_type  nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    lv_retval    NUMBER;
    --
  BEGIN
    --
    EXECUTE IMMEDIATE 'SELECT NVL(MAX('||c_layer_attrib_name||'),0) + 1'
                     ||' FROM nm_inv_items'
                    ||' WHERE iit_inv_type = :inv_type'
                    ||'   AND iit_foreign_key = :parent_primary_key'
      INTO lv_retval
     USING lv_inv_type
          ,pi_parent_primary_key
         ;
    --
    RETURN lv_retval;
    --
  END get_next_layer_number;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resequence_layers(pi_parent_primary_key IN nm_inv_items_all.iit_primary_key%TYPE)
    IS
    --
    lv_inv_type  nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    --
    TYPE layer_rec IS RECORD(iit_ne_id     nm_inv_items_all.iit_ne_id%TYPE
                            ,new_position  NUMBER);
    TYPE layer_tab IS TABLE OF layer_rec;
    lt_layers  layer_tab;
    --
  BEGIN
    --
    EXECUTE IMMEDIATE 'SELECT iit_ne_id'
                          ||',ROWNUM new_position'
                     ||' FROM nm_inv_items'
                    ||' WHERE iit_inv_type = :inv_type'
                      ||' AND iit_foreign_key = :parent_key'
                    ||' ORDER BY '||c_layer_attrib_name
      BULK COLLECT INTO lt_layers
      USING lv_inv_type, pi_parent_primary_key
    ;
    --
    FOR i IN 1..lt_layers.COUNT LOOP
      EXECUTE IMMEDIATE 'UPDATE nm_inv_items_all SET '||c_layer_attrib_name||' = :new_position WHERE iit_ne_id = :iit_ne_id'
        USING lt_layers(i).new_position
             ,lt_layers(i).iit_ne_id
      ;
    END LOOP;
    --
  END resequence_layers;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION execute_gaz_query(pi_inv_type IN nm_inv_types_all.nit_inv_type%TYPE
                            ,pi_xsps     IN xsp_tab
                            ,pi_ne_id    IN nm_elements_all.ne_id%TYPE
                            ,pi_begin_mp IN nm_members_all.nm_begin_mp%TYPE
                            ,pi_end_mp   IN nm_members_all.nm_end_mp%TYPE)
    RETURN NUMBER IS
    --
    lv_job_id    NUMBER := nm3ddl.sequence_nextval('RTG_JOB_ID_SEQ');
    lv_query_id  NUMBER;
    --
  BEGIN
    --
    INSERT
      INTO nm_gaz_query
          (ngq_id
          ,ngq_source_id
          ,ngq_source
          ,ngq_open_or_closed
          ,ngq_items_or_area
          ,ngq_query_all_items
          ,ngq_begin_mp
          ,ngq_end_mp)
    VALUES(lv_job_id
          ,pi_ne_id
          ,'ROUTE'
          ,'C'
          ,'I'
          ,'N'
          ,pi_begin_mp
          ,pi_end_mp)
         ;
    --
    INSERT
      INTO nm_gaz_query_types
          (ngqt_ngq_id
          ,ngqt_seq_no
          ,ngqt_item_type_type
          ,ngqt_item_type)
    VALUES(lv_job_id
          ,1
          ,'I'
          ,pi_inv_type);
    --
    INSERT
      INTO nm_gaz_query_attribs
          (ngqa_ngq_id
          ,ngqa_ngqt_seq_no
          ,ngqa_seq_no
          ,ngqa_attrib_name
          ,ngqa_operator
          ,ngqa_pre_bracket
          ,ngqa_post_bracket
          ,ngqa_condition)
    VALUES(lv_job_id
          ,1
          ,1
          ,'IIT_X_SECT'
          ,'AND'
          ,NULL
          ,NULL
          ,'IN');
    --
    FOR i IN 1..pi_xsps.COUNT LOOP
      --
      INSERT
        INTO nm_gaz_query_values
            (ngqv_ngq_id
            ,ngqv_ngqt_seq_no
            ,ngqv_ngqa_seq_no
            ,ngqv_sequence
            ,ngqv_value)
      VALUES(lv_job_id
            ,1
            ,1
            ,i
            ,pi_xsps(i));
      --
    END LOOP;
    --
    lv_query_id := nm3gaz_qry.perform_query (lv_job_id);
    --
    RETURN lv_query_id;
    --
  END execute_gaz_query;
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
                        ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                        ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                        ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                        ,po_iit_ne_id          IN OUT nm_inv_items.iit_ne_id%TYPE
                        ,po_message_severity   IN OUT hig_codes.hco_code%TYPE
                        ,po_message_tab        IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_message_cursor  sys_refcursor;
    --
  BEGIN
    --
    awlrs_asset_api.create_asset(pi_asset_type         => pi_asset_type
                                ,pi_primary_key        => pi_primary_key
                                ,pi_admin_unit         => pi_admin_unit
                                ,pi_xsp                => pi_xsp
                                ,pi_description        => pi_description
                                ,pi_start_date         => pi_start_date
                                ,pi_end_date           => pi_end_date
                                ,pi_notes              => pi_notes
                                ,pi_iit_foreign_key    => pi_iit_foreign_key
                                ,pi_attrib_names       => pi_attrib_names
                                ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                                ,pi_attrib_char_values => pi_attrib_char_values
                                ,po_iit_ne_id          => po_iit_ne_id
                                ,po_message_severity   => po_message_severity
                                ,po_message_cursor     => lv_message_cursor);
    --
    get_messages(pi_message_cursor => lv_message_cursor
                ,po_message_tab    => po_message_tab);
    --
  END create_asset;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE locate_asset(pi_iit_ne_id        IN     nm_inv_items_all.iit_ne_id%TYPE
                        ,pi_nit_inv_type     IN     nm_inv_types_all.nit_inv_type%TYPE
                        ,pi_ne_id            IN     nm_elements_all.ne_id%TYPE
                        ,pi_begin_mp         IN     nm_members_all.nm_begin_mp%TYPE
                        ,pi_end_mp           IN     nm_members_all.nm_end_mp%TYPE
                        ,pi_startdate        IN     nm_members_all.nm_start_date%TYPE
                        ,po_message_severity IN OUT hig_codes.hco_code%TYPE
                        ,po_message_tab      IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_message_cursor  sys_refcursor;
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    TYPE datumn_rec IS RECORD(location_mp    VARCHAR2(5)
                             ,element_id     nm_elements_all.ne_id%TYPE
                             ,unique_id      nm_elements_all.ne_unique%TYPE
                             ,description    nm_elements_all.ne_descr%TYPE
                             ,offset         NUMBER
                             ,sub_class      nm_elements_all.ne_sub_class%TYPE
                             ,date_modified  VARCHAR2(22));
    TYPE datumn_tab IS TABLE OF datumn_rec;
    lt_start_datumns  datumn_tab;
    lt_end_datumns    datumn_tab;
    --
    PROCEDURE get_datumn_offset(pi_ne_id      IN     nm_elements_all.ne_id%TYPE
                               ,pi_offset     IN     nm_members_all.nm_begin_mp%TYPE
                               ,pi_st_or_end  IN     VARCHAR2
                               ,pi_sub_class  IN     VARCHAR2
                               ,po_datumn_tab IN OUT datumn_tab)
      IS
      --
      lv_message_severity  hig_codes.hco_code%TYPE;
      lv_message_cursor    sys_refcursor;
      lv_cursor            sys_refcursor;
      --
    BEGIN
      --
      awlrs_asset_api.get_lref_ambig(pi_locate_mp        => pi_st_or_end
                                    ,pi_parent_id        => pi_ne_id
                                    ,pi_offset           => pi_offset
                                    ,pi_sub_class        => pi_sub_class
                                    ,po_message_severity => lv_message_severity
                                    ,po_message_cursor   => lv_message_cursor
                                    ,po_cursor           => lv_cursor);
      --
      FETCH lv_cursor
       BULK COLLECT
       INTO po_datumn_tab;
      CLOSE lv_cursor;
      --
    END get_datumn_offset;
    --
  BEGIN
    /*
    ||TODO - temp solution until UI can provide this data.
    */
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    /*
    ||Get the start Datum and Offset
    */
    get_datumn_offset(pi_ne_id      => pi_ne_id
                     ,pi_offset     => pi_begin_mp
                     ,pi_st_or_end  => 'BEGIN'
                     ,pi_sub_class  => lr_ne.ne_sub_class
                     ,po_datumn_tab => lt_start_datumns);
    /*
    ||Get the end Datum and Offset
    */
    get_datumn_offset(pi_ne_id      => pi_ne_id
                     ,pi_offset     => pi_end_mp
                     ,pi_st_or_end  => 'END'
                     ,pi_sub_class  => lr_ne.ne_sub_class
                     ,po_datumn_tab => lt_end_datumns);
    --
    awlrs_asset_api.add_asset_location(pi_iit_ne_id                => pi_iit_ne_id
                                      ,pi_nit_inv_type             => pi_nit_inv_type
                                      ,pi_ne_id                    => pi_ne_id
                                      ,pi_begin_mp                 => pi_begin_mp
                                      ,pi_end_mp                   => pi_end_mp
                                      ,pi_startdate                => pi_startdate
                                      ,pi_append_replace           => 'R'
                                      ,pi_begin_sect               => lt_start_datumns(1).element_id
                                      ,pi_begin_sect_offset        => lt_start_datumns(1).offset
                                      ,pi_begin_sect_date_modified => TO_DATE(lt_start_datumns(1).date_modified,'DD-MON-YYYY HH24:MI:SS')
                                      ,pi_end_sect                 => lt_end_datumns(1).element_id
                                      ,pi_end_sect_offset          => lt_end_datumns(1).offset
                                      ,pi_end_sect_date_modified   => TO_DATE(lt_end_datumns(1).date_modified,'DD-MON-YYYY HH24:MI:SS')
                                      ,pi_ambiguous_sub_class      => NULL
                                      ,pi_excl_sub_class           => NULL
                                      ,pi_nse_id                   => NULL
                                      ,po_message_severity         => po_message_severity
                                      ,po_message_cursor           => lv_message_cursor);
    --
    get_messages(pi_message_cursor => lv_message_cursor
                ,po_message_tab    => po_message_tab);
    --
  END locate_asset;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_and_locate_asset(pi_asset_type         IN     nm_inv_items_all.iit_inv_type%TYPE
                                   ,pi_primary_key        IN     nm_inv_items_all.iit_primary_key%TYPE
                                   ,pi_admin_unit         IN     nm_admin_units_all.nau_admin_unit%TYPE
                                   ,pi_description        IN     nm_inv_items_all.iit_descr%TYPE
                                   ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE
                                   ,pi_end_date           IN     nm_inv_items_all.iit_end_date%TYPE
                                   ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                                   ,pi_iit_foreign_key    IN     nm_inv_items_all.iit_foreign_key%TYPE
                                   ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                   ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                   ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                   ,pi_xsp                IN     nm_nw_xsp.nwx_x_sect%TYPE
                                   ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                   ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                   ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE
                                   ,po_iit_ne_id          IN OUT nm_inv_items.iit_ne_id%TYPE
                                   ,po_message_severity   IN OUT hig_codes.hco_code%TYPE
                                   ,po_message_tab        IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_iit_ne_id  nm_inv_items_all.iit_ne_id%TYPE;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT create_cons_rec_sp;
    /*
    ||Create the record.
    */
    create_asset(pi_asset_type         => pi_asset_type
                ,pi_primary_key        => pi_primary_key
                ,pi_admin_unit         => pi_admin_unit
                ,pi_xsp                => pi_xsp
                ,pi_description        => pi_description
                ,pi_start_date         => pi_start_date
                ,pi_end_date           => pi_end_date
                ,pi_notes              => pi_notes
                ,pi_iit_foreign_key    => pi_iit_foreign_key
                ,pi_attrib_names       => pi_attrib_names
                ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                ,pi_attrib_char_values => pi_attrib_char_values
                ,po_iit_ne_id          => lv_iit_ne_id
                ,po_message_severity   => lv_severity
                ,po_message_tab        => lt_messages);
    --
    IF lv_severity = awlrs_util.c_msg_cat_success
     THEN
        lt_messages.DELETE;
        /*
        ||Locate the record.
        */
        locate_asset(pi_iit_ne_id        => lv_iit_ne_id
                    ,pi_nit_inv_type     => pi_asset_type
                    ,pi_ne_id            => pi_ne_id
                    ,pi_begin_mp         => pi_begin_mp
                    ,pi_end_mp           => pi_end_mp
                    ,pi_startdate        => pi_start_date
                    ,po_message_severity => lv_severity
                    ,po_message_tab      => lt_messages);
    END IF;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity != awlrs_util.c_msg_cat_success
     THEN
        ROLLBACK TO create_cons_rec_sp;
    ELSE
        po_iit_ne_id := lv_iit_ne_id;
    END IF;
    --
    po_message_severity := lv_severity;
    po_message_tab := lt_messages;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO create_cons_rec_sp;
        RAISE;
  END create_and_locate_asset;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE replace_construction_records(pi_description        IN     nm_inv_items_all.iit_descr%TYPE
                                        ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE
                                        ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                                        ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                        ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                        ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                        ,pi_depth_removed      IN     NUMBER
                                        ,pi_xsps               IN     xsp_tab
                                        ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                        ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                        ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE
                                        ,po_iit_ne_ids         IN OUT iit_ne_id_tab
                                        ,po_message_severity   IN OUT hig_codes.hco_code%TYPE
                                        ,po_message_tab        IN OUT NOCOPY awlrs_message_tab)
    IS
    --
    lv_cons_type               nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_layer_type              nm_inv_items_all.iit_inv_type%TYPE := get_layer_type;
    lv_query_id                NUMBER;
    lv_new_cons_rec_extent_id  NUMBER;
    lv_replacement_extent_id   NUMBER;
    lv_iit_ne_id               nm_inv_items_all.iit_ne_id%TYPE;
    lv_severity                hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_homo_warning_code       VARCHAR2(1000);
    lv_homo_warning_msg        VARCHAR2(1000);
    lv_thickness               NUMBER;
    --
    lt_iit_ne_ids  iit_ne_id_tab;
    lt_messages    awlrs_message_tab := awlrs_message_tab();
    --
    CURSOR get_cons_recs(cp_query_id IN NUMBER)
        IS
    SELECT iit_ne_id
          ,iit_admin_unit
          ,iit_x_sect
      FROM nm_inv_items
     WHERE iit_ne_id IN(SELECT ngqi_item_id
                          FROM nm_gaz_query_item_list
                         WHERE ngqi_job_id = cp_query_id)
         ;
    --
    TYPE cons_rec_tab IS TABLE OF get_cons_recs%ROWTYPE;
    lt_cons_recs  cons_rec_tab;
    --
    FUNCTION calc_new_location(pi_cons_rec_id           IN nm_inv_items_all.iit_ne_id%TYPE
                              ,pi_replacement_extent_id IN NUMBER)
      RETURN NUMBER IS
      --
      lv_asset_job_id       NUMBER;
      lv_protruding_job_id  NUMBER;
      lv_overlap_job_id     NUMBER;
      lv_count              NUMBER;
      lv_retval             NUMBER;
      --
      CURSOR get_count(cp_job_id IN NUMBER)
          IS
      SELECT COUNT(*)
        FROM nm_nw_temp_extents
       WHERE nte_job_id = cp_job_id
           ;
      --
    BEGIN
      /*
      ||Create an extent for the current construction record.
      */
      nm3extent.create_temp_ne(pi_source_id => pi_cons_rec_id
                              ,pi_source    => nm3extent.get_route
                              ,pi_begin_mp  => NULL
                              ,pi_end_mp    => NULL
                              ,po_job_id    => lv_asset_job_id);
      /*
      ||Check to see if the whole location of the current
      ||construction record is to be replaced, in which case
      ||the location of the new construction record is the same
      ||as the current one. Otherwise the new construction record
      ||will only be located where the two extents overlap.
      */
      nm3extent.nte_minus_nte(pi_nte_1      => lv_asset_job_id
                             ,pi_nte_2      => pi_replacement_extent_id
                             ,po_nte_result => lv_protruding_job_id);
      --
      OPEN  get_count(lv_protruding_job_id);
      FETCH get_count
       INTO lv_count;
      CLOSE get_count;
      --
      IF lv_count = 0
       THEN
          /*
          ||If there are no protruding locations then return the whole
          ||extent of the current construction record to be used as the
          ||location of the new one.
          */
          lv_retval := nm3extent.remove_overlaps(pi_nte_id => lv_asset_job_id);
      ELSE
          /*
          ||Otherwise now that we know what is protruding we can calculate
          ||the overlap and return it as the location of the new construction
          ||record.
          */
          nm3extent.nte_minus_nte(pi_nte_1      => lv_asset_job_id
                                 ,pi_nte_2      => lv_protruding_job_id
                                 ,po_nte_result => lv_overlap_job_id);
          lv_retval := nm3extent.remove_overlaps(pi_nte_id => lv_overlap_job_id);
          --
      END IF;
      --
      RETURN lv_retval;
      --
    END calc_new_location;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT replace_cons_recs_sp;
    /*
    ||Create a temp extent to represent the scope of the replacement.
    */
    nm3extent.create_temp_ne(pi_source_id => pi_ne_id
                            ,pi_source    => nm3extent.get_route
                            ,pi_begin_mp  => pi_begin_mp
                            ,pi_end_mp    => pi_end_mp
                            ,po_job_id    => lv_replacement_extent_id);
    /*
    ||Get the construction records on the network \ xsps indicated.
    */
    lv_query_id := execute_gaz_query(pi_inv_type => lv_cons_type
                                    ,pi_xsps     => pi_xsps
                                    ,pi_ne_id    => pi_ne_id
                                    ,pi_begin_mp => pi_begin_mp
                                    ,pi_end_mp   => pi_end_mp);
    /*
    ||Create new construction records to replace them and copy Layers having applied the depth removed.
    */
    OPEN  get_cons_recs(lv_query_id);
    FETCH get_cons_recs
     BULK COLLECT
     INTO lt_cons_recs;
    CLOSE get_cons_recs;
    --
    FOR i IN 1..lt_cons_recs.COUNT LOOP
      /*
      ||Get the Layers from the existing record.
      ||NB. Exclusivity will end date these records
      ||When the new construction record is located
      ||hence we need to get them now rather than
      ||later.
      */
      EXECUTE IMMEDIATE 'SELECT *'
                       ||' FROM nm_inv_items'
                      ||' WHERE iit_inv_type = :layer_type'
                        ||' AND iit_foreign_key = (SELECT iit_primary_key'
                                                 ||' FROM nm_inv_items'
                                                ||' WHERE iit_ne_id = :parent_id)'
                      ||' ORDER BY '||c_layer_attrib_name||' DESC'
        BULK COLLECT INTO gt_layers
        USING lv_layer_type, lt_cons_recs(i).iit_ne_id
      ;
      /*
      ||Create the new construction record.
      */
      create_asset(pi_asset_type         => lv_cons_type
                  ,pi_primary_key        => NULL
                  ,pi_admin_unit         => lt_cons_recs(i).iit_admin_unit
                  ,pi_xsp                => lt_cons_recs(i).iit_x_sect
                  ,pi_description        => pi_description
                  ,pi_start_date         => pi_start_date
                  ,pi_end_date           => NULL
                  ,pi_notes              => pi_notes
                  ,pi_iit_foreign_key    => NULL
                  ,pi_attrib_names       => pi_attrib_names
                  ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                  ,pi_attrib_char_values => pi_attrib_char_values
                  ,po_iit_ne_id          => lv_iit_ne_id
                  ,po_message_severity   => lv_severity
                  ,po_message_tab        => lt_messages);
      --
      IF lv_severity != awlrs_util.c_msg_cat_success
       THEN
          EXIT;
      ELSE
          lt_messages.DELETE;
          /*
          ||Store the new construction record id for output.
          */
          lt_iit_ne_ids(lt_iit_ne_ids.COUNT+1) := lv_iit_ne_id;
          /*
          ||Calculate the location of the new construction record.
          */
          lv_new_cons_rec_extent_id := calc_new_location(pi_cons_rec_id           => lt_cons_recs(i).iit_ne_id
                                                        ,pi_replacement_extent_id => lv_replacement_extent_id);
          /*
          ||Locate the new construction record.
          */
          nm3homo.homo_update(p_temp_ne_id_in  => lv_new_cons_rec_extent_id
                             ,p_iit_ne_id      => lv_iit_ne_id
                             ,p_effective_date => TRUNC(pi_start_date)
                             ,p_warning_code   => lv_homo_warning_code
                             ,p_warning_msg    => lv_homo_warning_msg);
          /*
          ||Apply the depth removed to the Layers.
          */
          DECLARE
            lv_depth_to_remove  NUMBER := pi_depth_removed;
          BEGIN
            --
            gt_new_layers.DELETE;
            --
            FOR j IN 1..gt_layers.COUNT LOOP
              --
              EXECUTE IMMEDIATE 'BEGIN :thickness := awlrs_plm_api.gt_layers(:idx).'||c_thickness_attrib_name||'; END;'
                USING IN OUT lv_thickness, IN j;
              --
              CASE
                WHEN lv_depth_to_remove = 0
                 THEN
                    /*
                    ||The depth removed has been processed so
                    ||just add the layer as it is.
                    */
                    gt_new_layers(gt_new_layers.COUNT+1) := gt_layers(j);
                    --
                WHEN lv_thickness <= lv_depth_to_remove
                 THEN
                    /*
                    ||The depth of the layer is less than the
                    ||depth still to be removed so do not add it.
                    */
                    lv_depth_to_remove := lv_depth_to_remove - lv_thickness;
                    --
                WHEN lv_thickness > lv_depth_to_remove
                 THEN
                    /*
                    ||The depth of the layer is greater than the
                    ||depth still to be removed so add the layer
                    ||with a reduced depth.
                    */
                    gt_new_layers(gt_new_layers.COUNT+1) := gt_layers(j);
                    --
                    EXECUTE IMMEDIATE 'BEGIN awlrs_plm_api.gt_new_layers(awlrs_plm_api.gt_new_layers.COUNT).'||c_thickness_attrib_name
                                         ||' := awlrs_plm_api.gt_new_layers(awlrs_plm_api.gt_new_layers.COUNT).'||c_thickness_attrib_name||' - :depth_to_remove;'
                                    ||'END;'
                      USING lv_depth_to_remove
                    ;
                    --
                    lv_depth_to_remove := 0;
                    --
              END CASE;
            END LOOP;
          END;
          /*
          ||Insert the new layers.
          */
          FOR j IN 1..gt_new_layers.COUNT LOOP
            --
            gt_new_layers(j).iit_ne_id := ne_id_seq.NEXTVAL;
            gt_new_layers(j).iit_primary_key := gt_new_layers(j).iit_ne_id;
            gt_new_layers(j).iit_foreign_key := lv_iit_ne_id;
            gt_new_layers(j).iit_start_date := TRUNC(pi_start_date);
            gt_new_layers(j).iit_x_sect := lt_cons_recs(i).iit_x_sect;
            --
            nm3ins.ins_iit(p_rec_iit => gt_new_layers(j));
            --
          END LOOP;
          --
      END IF;
      --
    END LOOP;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity != awlrs_util.c_msg_cat_success
     THEN
        ROLLBACK TO replace_cons_recs_sp;
    END IF;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity != awlrs_util.c_msg_cat_success
     THEN
        ROLLBACK TO replace_cons_recs_sp;
    ELSE
        po_iit_ne_ids := lt_iit_ne_ids;
    END IF;
    --
    po_message_severity := lv_severity;
    po_message_tab := lt_messages;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO replace_cons_recs_sp;
        RAISE;
  END replace_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE replace_construction_records(pi_description        IN     nm_inv_items_all.iit_descr%TYPE
                                        ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE
                                        ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                                        ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                        ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                        ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                        ,pi_depth_removed      IN     NUMBER
                                        ,pi_xsps               IN     xsp_tab
                                        ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                        ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                        ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE
                                        ,po_iit_ne_ids         IN OUT iit_ne_id_tab
                                        ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                        ,po_message_cursor        OUT sys_refcursor)
    IS
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    replace_construction_records(pi_description        => pi_description
                                ,pi_start_date         => pi_start_date
                                ,pi_notes              => pi_notes
                                ,pi_attrib_names       => pi_attrib_names
                                ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                                ,pi_attrib_char_values => pi_attrib_char_values
                                ,pi_depth_removed      => pi_depth_removed
                                ,pi_xsps               => pi_xsps
                                ,pi_ne_id              => pi_ne_id
                                ,pi_begin_mp           => pi_begin_mp
                                ,pi_end_mp             => pi_end_mp
                                ,po_iit_ne_ids         => po_iit_ne_ids
                                ,po_message_severity   => po_message_severity
                                ,po_message_tab        => lt_messages);
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
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END replace_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_construction_records(pi_admin_unit               IN     nm_admin_units_all.nau_admin_unit%TYPE
                                       ,pi_description              IN     nm_inv_items_all.iit_descr%TYPE
                                       ,pi_start_date               IN     nm_inv_items_all.iit_start_date%TYPE
                                       ,pi_end_date                 IN     nm_inv_items_all.iit_end_date%TYPE
                                       ,pi_notes                    IN     nm_inv_items_all.iit_note%TYPE
                                       ,pi_attrib_names             IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_attrib_scrn_texts        IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_attrib_char_values       IN     awlrs_asset_api.attrib_value_tab
                                       ,pi_xsps                     IN     xsp_tab
                                       ,pi_ne_ids                   IN     awlrs_util.ne_id_tab
                                       ,pi_begin_mps                IN     location_from_offset_tab
                                       ,pi_end_mps                  IN     location_to_offset_tab
                                       ,pi_layer_attrib_idx         IN     iit_ne_id_tab
                                       ,pi_layer_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_layer_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_layer_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                       ,pi_depth_removed            IN     NUMBER DEFAULT NULL
                                       ,po_iit_ne_ids               IN OUT iit_ne_id_tab
                                       ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_inv_type   nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_iit_ne_id  nm_inv_items.iit_ne_id%TYPE;
    lv_pcl_iit_ne_id  nm_inv_items.iit_ne_id%TYPE;
    --
    lt_pcl_iit_ne_ids           iit_ne_id_tab;
    lt_messages                 awlrs_message_tab := awlrs_message_tab();
    lt_layer_iit_ne_ids         iit_ne_id_tab;
    lt_layer_attrib_idx         iit_ne_id_tab;
    lt_layer_attrib_names       awlrs_asset_api.attrib_name_tab;
    lt_layer_attrib_scrn_texts  awlrs_asset_api.attrib_scrn_text_tab;
    lt_layer_attrib_char_values awlrs_asset_api.attrib_value_tab;
    lt_iit_ne_ids               iit_ne_id_tab;
    lt_existing_iit_ne_ids      iit_ne_id_tab;
    lv_message_cursor           sys_refcursor;
    lt_xsps                     xsp_tab;
    --
  BEGIN
    --
    SAVEPOINT add_con_records_sp;
    /*
    ||Check row counts
    */
    IF pi_layer_attrib_idx.COUNT != pi_layer_attrib_names.COUNT
     OR pi_layer_attrib_idx.COUNT != pi_layer_attrib_scrn_texts.COUNT
     OR pi_layer_attrib_idx.COUNT != pi_layer_attrib_char_values.COUNT
     OR pi_attrib_names.COUNT != pi_attrib_scrn_texts.COUNT
     OR pi_attrib_names.COUNT != pi_attrib_char_values.COUNT
      THEN
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 5);
        --
    END IF;
    --
    FOR j in 1..pi_ne_ids.COUNT LOOP
      --
      IF lv_severity != awlrs_util.c_msg_cat_success
       THEN
          EXIT;
      END IF;
      --
      FOR i IN 1..pi_xsps.COUNT LOOP
        --
        IF lv_severity != awlrs_util.c_msg_cat_success
         THEN
            EXIT;
        END IF;
        --
        lv_severity := awlrs_util.c_msg_cat_success;
        lt_messages.DELETE;
        lt_existing_iit_ne_ids.DELETE; --added for replacing.
        --
        IF pi_depth_removed IS NULL
         THEN
            create_and_locate_asset(pi_asset_type         => lv_inv_type
                                   ,pi_primary_key        => NULL
                                   ,pi_admin_unit         => pi_admin_unit
                                   ,pi_description        => pi_description
                                   ,pi_start_date         => pi_start_date
                                   ,pi_end_date           => pi_end_date
                                   ,pi_notes              => pi_notes
                                   ,pi_iit_foreign_key    => NULL
                                   ,pi_attrib_names       => pi_attrib_names
                                   ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                                   ,pi_attrib_char_values => pi_attrib_char_values
                                   ,pi_xsp                => pi_xsps(i)
                                   ,pi_ne_id              => pi_ne_ids(j)
                                   ,pi_begin_mp           => pi_begin_mps(j)
                                   ,pi_end_mp             => pi_end_mps(j)
                                   ,po_iit_ne_id          => lv_iit_ne_id
                                   ,po_message_severity   => lv_severity
                                   ,po_message_tab        => lt_messages);
            /*
            ||Will only be one as this is new.
            */
            lt_existing_iit_ne_ids(1) := lv_iit_ne_id;
        ELSE
            /*
            ||remove depth and find all asset IDs to add new layers for.
            */
            lt_xsps(1) := pi_xsps(i);
            --
            replace_construction_records(pi_description        => pi_description
                                        ,pi_start_date         => pi_start_date
                                        ,pi_notes              => pi_notes
                                        ,pi_attrib_names       => pi_attrib_names
                                        ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                                        ,pi_attrib_char_values => pi_attrib_char_values
                                        ,pi_depth_removed      => pi_depth_removed
                                        ,pi_xsps               => lt_xsps
                                        ,pi_ne_id              => pi_ne_ids(j)
                                        ,pi_begin_mp           => pi_begin_mps(j)
                                        ,pi_end_mp             => pi_end_mps(j)
                                        ,po_iit_ne_ids         => lt_existing_iit_ne_ids
                                        ,po_message_severity   => lv_severity
                                        ,po_message_tab        => lt_messages);
            --
        END IF;
        /*
        ||If more than one asset id then loop through and add layers to all.
        ||if new cons record then there will only be one.
        */
        FOR e IN 1..lt_existing_iit_ne_ids.COUNT LOOP
          --
          IF lv_severity = awlrs_util.c_msg_cat_success
           THEN
              --
              lt_iit_ne_ids(lt_iit_ne_ids.COUNT+1) := lt_existing_iit_ne_ids(e);
              --
              FOR l in 1..pi_layer_attrib_idx.COUNT LOOP
                --
                lt_layer_attrib_names(lt_layer_attrib_names.COUNT+1) := pi_layer_attrib_names(l);
                lt_layer_attrib_scrn_texts(lt_layer_attrib_scrn_texts.COUNT+1) := pi_layer_attrib_scrn_texts(l);
                lt_layer_attrib_char_values(lt_layer_attrib_char_values.COUNT+1) := pi_layer_attrib_char_values(l);
                --
                IF l = pi_layer_attrib_idx.COUNT --last record in array
                 OR pi_layer_attrib_idx(l) <> pi_layer_attrib_idx(l+1) --next value is new layer number
                 THEN
                    /*
                    ||add layer
                    */
                    add_layer(pi_parent_id          => lt_existing_iit_ne_ids(e)
                             ,pi_start_date         => pi_start_date
                             ,pi_notes              => null
                             ,pi_attrib_names       => lt_layer_attrib_names
                             ,pi_attrib_scrn_texts  => lt_layer_attrib_scrn_texts
                             ,pi_attrib_char_values => lt_layer_attrib_char_values
                             ,po_iit_ne_id          => lv_pcl_iit_ne_id
                             ,po_message_severity   => lv_severity
                             ,po_message_cursor     => lv_message_cursor);
                    --
                    lt_layer_attrib_names.DELETE;
                    lt_layer_attrib_scrn_texts.DELETE;
                    lt_layer_attrib_char_values.DELETE;
                    --
                    IF lv_severity = awlrs_util.c_msg_cat_success
                     THEN
                       --
                       lt_pcl_iit_ne_ids(lt_pcl_iit_ne_ids.COUNT+1) := lv_pcl_iit_ne_id;
                       --
                    ELSE
                       --
                       get_messages(pi_message_cursor => lv_message_cursor
                                   ,po_message_tab    => lt_messages);
                       --
                       ROLLBACK TO add_con_records_sp;
                       EXIT;
                       --
                    END IF;
                    --
                END IF;
                --
              END LOOP;
              --
          ELSE
            --
            ROLLBACK TO add_con_records_sp;
            EXIT;
            --
          END IF;
        END LOOP;
        --
      END LOOP;
      --
    END LOOP;
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
        po_iit_ne_ids := lt_iit_ne_ids;
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_replace_cons_records(pi_admin_unit               IN     nm_admin_units_all.nau_admin_unit%TYPE
                                       ,pi_description              IN     nm_inv_items_all.iit_descr%TYPE
                                       ,pi_start_date               IN     nm_inv_items_all.iit_start_date%TYPE
                                       ,pi_end_date                 IN     nm_inv_items_all.iit_end_date%TYPE
                                       ,pi_notes                    IN     nm_inv_items_all.iit_note%TYPE
                                       ,pi_attrib_names             IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_attrib_scrn_texts        IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_attrib_char_values       IN     awlrs_asset_api.attrib_value_tab
                                       ,pi_xsps                     IN     xsp_tab
                                       ,pi_ne_ids                   IN     awlrs_util.ne_id_tab
                                       ,pi_begin_mps                IN     location_from_offset_tab
                                       ,pi_end_mps                  IN     location_to_offset_tab
                                       ,pi_layer_attrib_idx         IN     iit_ne_id_tab
                                       ,pi_layer_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_layer_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_layer_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                       ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lt_iit_ne_ids iit_ne_id_tab;
    --
    --
  BEGIN
    --
    create_construction_records(pi_admin_unit               => pi_admin_unit
                               ,pi_description              => pi_description
                               ,pi_start_date               => pi_start_date
                               ,pi_end_date                 => pi_end_date
                               ,pi_notes                    => pi_notes
                               ,pi_attrib_names             => pi_attrib_names
                               ,pi_attrib_scrn_texts        => pi_attrib_scrn_texts
                               ,pi_attrib_char_values       => pi_attrib_char_values
                               ,pi_xsps                     => pi_xsps
                               ,pi_ne_ids                   => pi_ne_ids
                               ,pi_begin_mps                => pi_begin_mps
                               ,pi_end_mps                  => pi_end_mps
                               ,pi_layer_attrib_idx         => pi_layer_attrib_idx
                               ,pi_layer_attrib_names       => pi_layer_attrib_names
                               ,pi_layer_attrib_scrn_texts  => pi_layer_attrib_scrn_texts
                               ,pi_layer_attrib_char_values => pi_layer_attrib_char_values
                               ,pi_depth_removed            => null
                               ,po_iit_ne_ids               => lt_iit_ne_ids
                               ,po_message_severity         => po_message_severity
                               ,po_message_cursor           => po_message_cursor );
  --
EXCEPTION
  WHEN others
   THEN
      awlrs_util.handle_exception(po_message_severity => po_message_severity
                                 ,po_cursor           => po_message_cursor);
  END create_replace_cons_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_construction_records(pi_admin_unit         IN     nm_admin_units_all.nau_admin_unit%TYPE
                                       ,pi_description        IN     nm_inv_items_all.iit_descr%TYPE
                                       ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE
                                       ,pi_end_date           IN     nm_inv_items_all.iit_end_date%TYPE
                                       ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                                       ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                       ,pi_xsps               IN     xsp_tab
                                       ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                       ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                       ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE
                                       ,po_iit_ne_ids         IN OUT iit_ne_id_tab
                                       ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor        OUT sys_refcursor)
    IS
    --
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_inv_type   nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_iit_ne_id  nm_inv_items.iit_ne_id%TYPE;
    --
    lt_iit_ne_ids  iit_ne_id_tab;
    lt_messages    awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    --
    FOR i IN 1..pi_xsps.COUNT LOOP
      --
      lv_severity := awlrs_util.c_msg_cat_success;
      lt_messages.DELETE;
      --
      create_and_locate_asset(pi_asset_type         => lv_inv_type
                             ,pi_primary_key        => NULL
                             ,pi_admin_unit         => pi_admin_unit
                             ,pi_description        => pi_description
                             ,pi_start_date         => pi_start_date
                             ,pi_end_date           => pi_end_date
                             ,pi_notes              => pi_notes
                             ,pi_iit_foreign_key    => NULL
                             ,pi_attrib_names       => pi_attrib_names
                             ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                             ,pi_attrib_char_values => pi_attrib_char_values
                             ,pi_xsp                => pi_xsps(i)
                             ,pi_ne_id              => pi_ne_id
                             ,pi_begin_mp           => pi_begin_mp
                             ,pi_end_mp             => pi_end_mp
                             ,po_iit_ne_id          => lv_iit_ne_id
                             ,po_message_severity   => lv_severity
                             ,po_message_tab        => lt_messages);
      --
      IF lv_severity = awlrs_util.c_msg_cat_success
       THEN
          lt_iit_ne_ids(lt_iit_ne_ids.COUNT+1) := lv_iit_ne_id;
      ELSE
          EXIT;
      END IF;
      --
    END LOOP;
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
        po_iit_ne_ids := lt_iit_ne_ids;
        awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                             ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reconstruct_cons_records(pi_admin_unit               IN     nm_admin_units_all.nau_admin_unit%TYPE
                                    ,pi_description              IN     nm_inv_items_all.iit_descr%TYPE
                                    ,pi_start_date               IN     nm_inv_items_all.iit_start_date%TYPE
                                    ,pi_end_date                 IN     nm_inv_items_all.iit_end_date%TYPE
                                    ,pi_notes                    IN     nm_inv_items_all.iit_note%TYPE
                                    ,pi_attrib_names             IN     awlrs_asset_api.attrib_name_tab
                                    ,pi_attrib_scrn_texts        IN     awlrs_asset_api.attrib_scrn_text_tab
                                    ,pi_attrib_char_values       IN     awlrs_asset_api.attrib_value_tab
                                    ,pi_xsps                     IN     xsp_tab
                                    ,pi_ne_ids                   IN     awlrs_util.ne_id_tab
                                    ,pi_begin_mps                IN     location_from_offset_tab
                                    ,pi_end_mps                  IN     location_to_offset_tab
                                    ,pi_layer_attrib_idx         IN     iit_ne_id_tab
                                    ,pi_layer_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                    ,pi_layer_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                    ,pi_layer_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                    ,pi_depth_removed            IN     NUMBER
                                    ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lt_iit_ne_ids iit_ne_id_tab;
    --
  BEGIN
    --
    create_construction_records(pi_admin_unit               => pi_admin_unit
                               ,pi_description              => pi_description
                               ,pi_start_date               => pi_start_date
                               ,pi_end_date                 => pi_end_date
                               ,pi_notes                    => pi_notes
                               ,pi_attrib_names             => pi_attrib_names
                               ,pi_attrib_scrn_texts        => pi_attrib_scrn_texts
                               ,pi_attrib_char_values       => pi_attrib_char_values
                               ,pi_xsps                     => pi_xsps
                               ,pi_ne_ids                   => pi_ne_ids
                               ,pi_begin_mps                => pi_begin_mps
                               ,pi_end_mps                  => pi_end_mps
                               ,pi_layer_attrib_idx         => pi_layer_attrib_idx
                               ,pi_layer_attrib_names       => pi_layer_attrib_names
                               ,pi_layer_attrib_scrn_texts  => pi_layer_attrib_scrn_texts
                               ,pi_layer_attrib_char_values => pi_layer_attrib_char_values
                               ,pi_depth_removed            => nvl(pi_depth_removed,0)
                               ,po_iit_ne_ids               => lt_iit_ne_ids
                               ,po_message_severity         => po_message_severity
                               ,po_message_cursor           => po_message_cursor );
  --
EXCEPTION
  WHEN others
   THEN
      awlrs_util.handle_exception(po_message_severity => po_message_severity
                                 ,po_cursor           => po_message_cursor);
  END reconstruct_cons_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE reconstruct_cons_records(pi_admin_unit               IN     nm_admin_units_all.nau_admin_unit%TYPE
                                    ,pi_description              IN     nm_inv_items_all.iit_descr%TYPE
                                    ,pi_start_date               IN     nm_inv_items_all.iit_start_date%TYPE
                                    ,pi_end_date                 IN     nm_inv_items_all.iit_end_date%TYPE
                                    ,pi_notes                    IN     nm_inv_items_all.iit_note%TYPE
                                    ,pi_attrib_names             IN     awlrs_asset_api.attrib_name_tab
                                    ,pi_attrib_scrn_texts        IN     awlrs_asset_api.attrib_scrn_text_tab
                                    ,pi_attrib_char_values       IN     awlrs_asset_api.attrib_value_tab
                                    ,pi_xsps                     IN     xsp_tab
                                    ,pi_ne_ids                   IN     awlrs_util.ne_id_tab
                                    ,pi_begin_mps                IN     location_from_offset_tab
                                    ,pi_end_mps                  IN     location_to_offset_tab
                                    ,pi_gaps_xsps                IN     xsp_tab
                                    ,pi_gaps_ne_ids              IN     awlrs_util.ne_id_tab
                                    ,pi_gaps_begin_mps           IN     location_from_offset_tab
                                    ,pi_gaps_end_mps             IN     location_to_offset_tab
                                    ,pi_layer_attrib_idx         IN     iit_ne_id_tab
                                    ,pi_layer_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                    ,pi_layer_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                    ,pi_layer_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                    ,pi_depth_removed            IN     NUMBER
                                    --,po_iit_ne_ids               IN OUT iit_ne_id_tab GK doesnt want.
                                    ,po_message_severity            OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor              OUT sys_refcursor)
    IS
    --
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lt_iit_ne_ids               iit_ne_id_tab;
    lt_iit_ne_ids_gaps          iit_ne_id_tab;
    lv_message_cursor           sys_refcursor;
    lt_xsps                     xsp_tab;
    lt_gaps_xsps                xsp_tab;
    lt_gaps_ne_ids              awlrs_util.ne_id_tab;
    lt_gaps_begin_mps           location_from_offset_tab;
    lt_gaps_end_mps             location_to_offset_tab;
    --
  BEGIN
    --
    /*
    ||Add standard records
    */
    create_construction_records(pi_admin_unit               => pi_admin_unit
                               ,pi_description              => pi_description
                               ,pi_start_date               => pi_start_date
                               ,pi_end_date                 => pi_end_date
                               ,pi_notes                    => pi_notes
                               ,pi_attrib_names             => pi_attrib_names
                               ,pi_attrib_scrn_texts        => pi_attrib_scrn_texts
                               ,pi_attrib_char_values       => pi_attrib_char_values
                               ,pi_xsps                     => pi_xsps
                               ,pi_ne_ids                   => pi_ne_ids
                               ,pi_begin_mps                => pi_begin_mps
                               ,pi_end_mps                  => pi_end_mps
                               ,pi_layer_attrib_idx         => pi_layer_attrib_idx
                               ,pi_layer_attrib_names       => pi_layer_attrib_names
                               ,pi_layer_attrib_scrn_texts  => pi_layer_attrib_scrn_texts
                               ,pi_layer_attrib_char_values => pi_layer_attrib_char_values
                               ,pi_depth_removed            => pi_depth_removed
                               ,po_iit_ne_ids               => lt_iit_ne_ids
                               ,po_message_severity         => lv_severity
                               ,po_message_cursor           => lv_message_cursor);
    --
    IF lv_severity = awlrs_util.c_msg_cat_success AND  pi_gaps_ne_ids.COUNT > 0 THEN
      /*
      ||Add Gaps so null depth and gaps network elements, xsp and measure
      ||These will need to be passed in on there own as not all XSPs will have gaps
      */
      /*
      ||Check row counts
      */
      IF pi_gaps_ne_ids.COUNT != pi_gaps_xsps.COUNT
       OR pi_gaps_ne_ids.COUNT != pi_gaps_begin_mps.COUNT
       OR pi_gaps_ne_ids.COUNT != pi_gaps_end_mps.COUNT
        THEN
          --
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 5);
          --
      END IF;
      --
      /*
      ||PB TO DO - do we need to handle single null array records or will arrays be empty.
      */
      FOR i in 1..pi_gaps_ne_ids.COUNT LOOP
        --
        lt_gaps_xsps(1) := pi_gaps_xsps(i);
        lt_gaps_ne_ids(1) := pi_gaps_ne_ids(i);
        lt_gaps_begin_mps(1) := pi_gaps_begin_mps(i);
        lt_gaps_end_mps(1) := pi_gaps_end_mps(i);
        --
        /*
        ||create new construction data for gaps.
        */
        create_construction_records(pi_admin_unit               => pi_admin_unit
                                   ,pi_description              => pi_description
                                   ,pi_start_date               => pi_start_date
                                   ,pi_end_date                 => pi_end_date
                                   ,pi_notes                    => pi_notes
                                   ,pi_attrib_names             => pi_attrib_names
                                   ,pi_attrib_scrn_texts        => pi_attrib_scrn_texts
                                   ,pi_attrib_char_values       => pi_attrib_char_values
                                   ,pi_xsps                     => lt_gaps_xsps
                                   ,pi_ne_ids                   => lt_gaps_ne_ids
                                   ,pi_begin_mps                => lt_gaps_begin_mps
                                   ,pi_end_mps                  => lt_gaps_end_mps
                                   ,pi_layer_attrib_idx         => pi_layer_attrib_idx
                                   ,pi_layer_attrib_names       => pi_layer_attrib_names
                                   ,pi_layer_attrib_scrn_texts  => pi_layer_attrib_scrn_texts
                                   ,pi_layer_attrib_char_values => pi_layer_attrib_char_values
                                   ,pi_depth_removed            => null
                                   ,po_iit_ne_ids               => lt_iit_ne_ids_gaps
                                   ,po_message_severity         => lv_severity
                                   ,po_message_cursor           => lv_message_cursor);
        --
        IF lv_severity =  awlrs_util.c_msg_cat_success THEN
          lt_iit_ne_ids(lt_iit_ne_ids.COUNT+1) := lt_iit_ne_ids_gaps(1);
        ELSE
          EXIT;
        END IF;
        --
      END LOOP;
      --
    END IF;
    /*
    ||If there are any messages to return
    */
    IF lv_severity <> awlrs_util.c_msg_cat_success
     THEN
       po_message_severity := lv_severity;
       po_message_cursor := lv_message_cursor;
    ELSE
       awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                            ,po_cursor           => po_message_cursor);
    END IF;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END reconstruct_cons_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_construction_record(pi_admin_unit         IN     nm_admin_units_all.nau_admin_unit%TYPE
                                      ,pi_description        IN     nm_inv_items_all.iit_descr%TYPE
                                      ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE
                                      ,pi_end_date           IN     nm_inv_items_all.iit_end_date%TYPE
                                      ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                                      ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                      ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                      ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                                      ,pi_xsp                IN     nm_nw_xsp.nwx_x_sect%TYPE
                                      ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                      ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                      ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE
                                      ,po_iit_ne_id          IN OUT nm_inv_items.iit_ne_id%TYPE
                                      ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor        OUT sys_refcursor)
    IS
    --
    lv_severity  hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_cursor    sys_refcursor;
    --
    lt_xsps        xsp_tab;
    lt_iit_ne_ids  iit_ne_id_tab;
    --
  BEGIN
    --
    lt_xsps(1) := pi_xsp;
    --
    create_construction_records(pi_admin_unit         => pi_admin_unit
                               ,pi_description        => pi_description
                               ,pi_start_date         => pi_start_date
                               ,pi_end_date           => pi_end_date
                               ,pi_notes              => pi_notes
                               ,pi_attrib_names       => pi_attrib_names
                               ,pi_attrib_scrn_texts  => pi_attrib_scrn_texts
                               ,pi_attrib_char_values => pi_attrib_char_values
                               ,pi_xsps               => lt_xsps
                               ,pi_ne_id              => pi_ne_id
                               ,pi_begin_mp           => pi_begin_mp
                               ,pi_end_mp             => pi_end_mp
                               ,po_iit_ne_ids         => lt_iit_ne_ids
                               ,po_message_severity   => lv_severity
                               ,po_message_cursor     => lv_cursor);
    --
    IF lt_iit_ne_ids.COUNT > 0
     THEN
        po_iit_ne_id := lt_iit_ne_ids(1);
    END IF;
    --
    po_message_severity := lv_severity;
    po_message_cursor   := lv_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_construction_record;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_layer(pi_parent_id          IN     nm_inv_items_all.iit_ne_id%TYPE
                     ,pi_start_date         IN     nm_inv_items_all.iit_start_date%TYPE DEFAULT NULL
                     ,pi_notes              IN     nm_inv_items_all.iit_note%TYPE
                     ,pi_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                     ,pi_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                     ,pi_attrib_char_values IN     awlrs_asset_api.attrib_value_tab
                     ,po_iit_ne_id          IN OUT nm_inv_items.iit_ne_id%TYPE
                     ,po_message_severity      OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor        OUT sys_refcursor)
    IS
    --
    lv_severity    hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_layer_type  nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    lv_iit_ne_id   nm_inv_items_all.iit_ne_id%TYPE;
    lv_layer_no    NUMBER;
    --
    lr_pcr_iit  nm_inv_items_all%ROWTYPE;
    --
    lt_attrib_names        awlrs_asset_api.attrib_name_tab;
    lt_attrib_scrn_texts   awlrs_asset_api.attrib_scrn_text_tab;
    lt_attrib_char_values  awlrs_asset_api.attrib_value_tab;
    lt_messages            awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT add_layer_sp;
    /*
    ||Get the parent construction record.
    */
    lr_pcr_iit := nm3get.get_iit(pi_parent_id);
    /*
    ||Derive the layer number.
    */
    lv_layer_no := get_next_layer_number(pi_parent_primary_key => lr_pcr_iit.iit_primary_key);
    --
    lt_attrib_names       := pi_attrib_names;
    lt_attrib_scrn_texts  := pi_attrib_scrn_texts;
    lt_attrib_char_values := pi_attrib_char_values;
    --
    FOR i IN 1..lt_attrib_names.COUNT LOOP
      --
      IF lt_attrib_names(i) = c_layer_attrib_name
       THEN
          /*
          ||Set the value.
          */
          lt_attrib_char_values(i) := TO_CHAR(lv_layer_no);
          EXIT;
      END IF;
      --
      IF i = lt_attrib_names.COUNT
       THEN
          /*
          ||Attribute not passed in so add it.
          */
          lt_attrib_names(pi_attrib_names.COUNT+1) := c_layer_attrib_name;
          lt_attrib_scrn_texts(pi_attrib_scrn_texts.COUNT+1) := nm3inv.get_attrib_scrn_text(pi_inv_type    => lv_layer_type
                                                                                           ,pi_attrib_name => c_layer_attrib_name);
          lt_attrib_char_values(pi_attrib_char_values.COUNT+1) := lv_layer_no;
          EXIT;
      END IF;
      --
    END LOOP;
    /*
    ||Create the Layer Asset, the AT relationship will
    ||deal with inheriting location from the parent.
    */
    create_asset(pi_asset_type         => lv_layer_type
                ,pi_primary_key        => NULL
                ,pi_admin_unit         => lr_pcr_iit.iit_admin_unit
                ,pi_xsp                => lr_pcr_iit.iit_x_sect
                ,pi_description        => NULL
                ,pi_start_date         => NVL(pi_start_date,lr_pcr_iit.iit_start_date)
                ,pi_end_date           => lr_pcr_iit.iit_end_date
                ,pi_notes              => pi_notes
                ,pi_iit_foreign_key    => lr_pcr_iit.iit_ne_id /* awlrs api expects id not iit_primary_key */
                ,pi_attrib_names       => lt_attrib_names
                ,pi_attrib_scrn_texts  => lt_attrib_scrn_texts
                ,pi_attrib_char_values => lt_attrib_char_values
                ,po_iit_ne_id          => lv_iit_ne_id
                ,po_message_severity   => lv_severity
                ,po_message_tab        => lt_messages);
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity != awlrs_util.c_msg_cat_success
     THEN
        ROLLBACK TO add_layer_sp;
    ELSE
        po_iit_ne_id := lv_iit_ne_id;
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
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_layer;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE enddate_layer(pi_layer_id         IN  nm_inv_items_all.iit_ne_id%TYPE
                         ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                         ,pi_run_checks       IN  VARCHAR2 DEFAULT 'Y'
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_layer_type      nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    lv_parent_key      nm_inv_items_all.iit_primary_key%TYPE;
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    --
  BEGIN
    --
    lv_parent_key := nm3inv.get_inv_item(pi_ne_id => pi_layer_id).iit_foreign_key;
    --
    awlrs_asset_api.asset_close(pi_asset_type       => lv_layer_type
                               ,pi_iit_ne_id        => pi_layer_id
                               ,pi_effective_date   => pi_effective_date
                               ,pi_run_checks       => pi_run_checks
                               ,po_message_severity => lv_severity
                               ,po_message_cursor   => lv_message_cursor);
    --
    resequence_layers(pi_parent_primary_key => lv_parent_key);
    --
    po_message_severity := lv_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END enddate_layer;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE copy_construction_data(pi_source_parent_id  IN  nm_inv_items_all.iit_ne_id%TYPE
                                  ,pi_target_admin_unit IN  nm_admin_units_all.nau_admin_unit%TYPE
                                  ,pi_target_start_date IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                  ,pi_target_xsps       IN  xsp_tab
                                  ,pi_target_ne_id      IN  nm_elements_all.ne_id%TYPE
                                  ,pi_target_begin_mp   IN  nm_members_all.nm_begin_mp%TYPE
                                  ,pi_target_end_mp     IN  nm_members_all.nm_end_mp%TYPE
                                  ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lv_layer_type      nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    lv_severity   hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    --
    lr_cons_rec  nm_inv_items_all%ROWTYPE;
    --
    lt_layers  iit_tab;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT copy_cons_data_sp;
    /*
    ||Get the source Construction Record.
    */
    lr_cons_rec := nm3inv.get_inv_item(pi_ne_id => pi_source_parent_id);
    /*
    ||Get any source Layers.
    */
    EXECUTE IMMEDIATE 'SELECT *'
                     ||' FROM nm_inv_items'
                    ||' WHERE iit_inv_type = :layer_type'
                      ||' AND iit_foreign_key = (SELECT iit_primary_key'
                                               ||' FROM nm_inv_items'
                                              ||' WHERE iit_ne_id = :parent_id)'
                    ||' ORDER BY '||c_layer_attrib_name
      BULK COLLECT INTO lt_layers
      USING lv_layer_type, pi_source_parent_id
    ;
    /*
    ||For each xsp given replicate the source data at the given location.
    */
    FOR i IN 1..pi_target_xsps.COUNT LOOP
      /*
      ||Create the Construction Record.
      */
      lr_cons_rec.iit_ne_id := ne_id_seq.NEXTVAL;
      lr_cons_rec.iit_primary_key := lr_cons_rec.iit_ne_id;
      lr_cons_rec.iit_start_date := TRUNC(pi_target_start_date);
      lr_cons_rec.iit_x_sect := pi_target_xsps(i);
      --
      nm3ins.ins_iit(p_rec_iit => lr_cons_rec);
      /*
      ||Locate the record.
      */
      lt_messages.DELETE;
      locate_asset(pi_iit_ne_id        => lr_cons_rec.iit_ne_id
                  ,pi_nit_inv_type     => lr_cons_rec.iit_inv_type
                  ,pi_ne_id            => pi_target_ne_id
                  ,pi_begin_mp         => pi_target_begin_mp
                  ,pi_end_mp           => pi_target_end_mp
                  ,pi_startdate        => lr_cons_rec.iit_start_date
                  ,po_message_severity => lv_severity
                  ,po_message_tab      => lt_messages);
      /*
      ||If errors occurred abandon the copy.
      */
      IF lv_severity != awlrs_util.c_msg_cat_success
       THEN
          EXIT;
      END IF;
      /*
      ||Create the Layers.
      */
      FOR j IN 1..lt_layers.COUNT LOOP
        --
        lt_layers(j).iit_ne_id := ne_id_seq.NEXTVAL;
        lt_layers(j).iit_primary_key := lt_layers(j).iit_ne_id;
        lt_layers(j).iit_foreign_key := lr_cons_rec.iit_primary_key;
        lt_layers(j).iit_start_date := lr_cons_rec.iit_start_date;
        lt_layers(j).iit_x_sect := lr_cons_rec.iit_x_sect;
        --
        nm3ins.ins_iit(p_rec_iit => lt_layers(j));
        --
      END LOOP;
      --
    END LOOP;
    /*
    ||If errors occurred rollback.
    */
    IF lv_severity != awlrs_util.c_msg_cat_success
     THEN
        ROLLBACK TO copy_cons_data_sp;
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
        ROLLBACK TO copy_cons_data_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END copy_construction_data;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION preview_reconstruct_changes(pi_layers_added       IN     NUMBER
                                      ,pi_depth_removed      IN     NUMBER
                                      ,pi_xsps               IN     xsp_tab
                                      ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                      ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                      ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE)
  RETURN CLOB
  IS
    lv_severity         hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor   sys_refcursor;
    lv_cons_type        nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_layer_type       nm_inv_items_all.iit_inv_type%TYPE := get_layer_type;
    lv_query_id         NUMBER;
    lt_ne_ids           awlrs_util.ne_id_tab;
    lv_preview          CLOB;
    lv_cursor           sys_refcursor;
    lv_nt_type          nm_elements.ne_nt_type%TYPE;
    lv_grp_type         nm_elements.ne_gty_group_type%TYPE;
    lt_messages         awlrs_message_tab := awlrs_message_tab();
    --Type for locations of assets
    TYPE results_rec IS RECORD(asset_id            NUMBER
                              ,element_id          NUMBER
                              ,element_type        VARCHAR2(100)
                              ,element_unique      VARCHAR2(100)
                              ,element_descr       VARCHAR2(100)
                              ,from_offset         NUMBER
                              ,to_offset           NUMBER
                              ,offset_length       NUMBER
                              ,element_length      NUMBER
                              ,element_unit_id     NUMBER
                              ,element_unit_name   VARCHAR2(100)
                              ,element_admin_unit  VARCHAR2(100)
                              ,element_start_date  DATE
                              ,member_start_date   DATE);
    TYPE results_tab IS TABLE OF results_rec;
    lt_results  results_tab;
    --
    CURSOR get_cons_recs(cp_query_id IN NUMBER)
        IS
    SELECT iit_ne_id
          ,iit_admin_unit
          ,iit_x_sect
      FROM nm_inv_items
     WHERE iit_ne_id IN(SELECT ngqi_item_id
                          FROM nm_gaz_query_item_list
                         WHERE ngqi_job_id = cp_query_id)
         ;
    --
    CURSOR get_nw_grp_type(cp_ne_id IN nm_elements.ne_id%TYPE)
        IS
    SELECT ne_nt_type
          ,ne_gty_group_type
      FROM nm_elements
     WHERE ne_id = cp_ne_id
         ;
    --
    TYPE cons_rec_tab IS TABLE OF get_cons_recs%ROWTYPE;
    lt_cons_recs  cons_rec_tab;
    --
    lv_layer_sql  nm3type.max_varchar2 := 'SELECT '||c_layer_attrib_name
                                              ||','||c_thickness_attrib_name
                                        ||'  FROM nm_inv_items'
                                        ||' WHERE iit_inv_type = :layer_type'
                                        ||'   AND iit_foreign_key = (SELECT iit_primary_key'
                                        ||'                            FROM nm_inv_items'
                                        ||'                           WHERE iit_ne_id = :parent_id)'
                                        ||' ORDER'
                                        ||'    BY '||c_layer_attrib_name||' DESC'
    ;
    --
    TYPE layer_rec IS RECORD (layer_no  NUMBER
                             ,thickness NUMBER);
    TYPE layer_tab IS TABLE OF layer_rec;
    lt_layers  layer_tab;
    --
  BEGIN
    --
    lv_preview := 'Depth removal of '||pi_depth_removed|| ' will result in the following amendments on existing records:'||chr(10);
    /*
    ||get nw and group type from passed in network elements
    */
    OPEN  get_nw_grp_type(pi_ne_id);
    FETCH get_nw_grp_type
     INTO lv_nt_type, lv_grp_type;
    CLOSE get_nw_grp_type;
    /*
    ||Get the construction records on the network \ xsps indicated.
    */
    lv_query_id := execute_gaz_query(pi_inv_type => lv_cons_type
                                    ,pi_xsps     => pi_xsps
                                    ,pi_ne_id    => pi_ne_id
                                    ,pi_begin_mp => pi_begin_mp
                                    ,pi_end_mp   => pi_end_mp);
    --
    OPEN  get_cons_recs(lv_query_id);
    FETCH get_cons_recs
     BULK COLLECT
     INTO lt_cons_recs;
    CLOSE get_cons_recs;
    --
    FOR i IN 1..lt_cons_recs.COUNT LOOP
      /*
      ||get location at preferred lrm level in future but for now use passed in types.
      */
      awlrs_asset_api.get_locations(pi_iit_ne_id        => lt_cons_recs(i).iit_ne_id
                                   ,pi_iit_inv_type     => get_cons_rec_type
                                   ,pi_nwtype           => lv_nt_type--
                                   ,pi_grouptype        => lv_grp_type--nm3user.get_preferred_lrm
                                   ,po_message_severity => lv_severity
                                   ,po_message_cursor   => lv_message_cursor
                                   ,po_cursor           => lv_cursor);
      --
      IF lv_severity = awlrs_util.c_msg_cat_success
       THEN
          --
          FETCH lv_cursor
           BULK COLLECT
           INTO lt_results;
          CLOSE lv_cursor;
          --
          FOR r IN 1..lt_results.COUNT LOOP
            /*
            || check its not in whole location .
            */
            IF lt_results(r).element_id = pi_ne_id
             THEN
                IF lt_results(r).from_offset >= pi_begin_mp AND  lt_results(r).to_offset <= pi_end_mp
                 THEN
                    lv_preview := lv_preview
                      ||'Network ID:'|| lt_results(r).element_id
                      ||'  XSP:'||lt_cons_recs(i).iit_x_sect
                      ||'  Begin Chainage:'||GREATEST(lt_results(r).from_offset,pi_begin_mp)
                      ||'  End Chainage:'||LEAST(lt_results(r).to_offset,pi_end_mp)
                    ;
                    /*
                    ||Get the Layers from the existing record.
                    */
                    EXECUTE IMMEDIATE lv_layer_sql BULK COLLECT INTO lt_layers USING lv_layer_type, lt_cons_recs(i).iit_ne_id;
                    /*
                    ||Apply the depth removed to the Layers.
                    */
                    DECLARE
                      lv_depth_to_remove  NUMBER := pi_depth_removed;
                    BEGIN
                      --
                      FOR j IN 1..lt_layers.COUNT LOOP
                        lv_preview := lv_preview||CHR(10)||'             Layer Number:'||lt_layers(j).layer_no;
                        CASE
                          WHEN lv_depth_to_remove = 0
                           THEN
                              /*
                              ||The depth removed has been processed so
                              ||just add the layer as it is.
                              */
                              lv_preview := lv_preview || ' Nothing Removed.';
                              --
                          WHEN lt_layers(j).thickness <= lv_depth_to_remove
                           THEN
                              /*
                              ||The depth of the layer is less than the
                              ||depth still to be removed so do not add it.
                              */
                              lv_depth_to_remove := lv_depth_to_remove - lt_layers(j).thickness;
                              lv_preview := lv_preview || ' Removed.';
                              --
                          WHEN lt_layers(j).thickness > lv_depth_to_remove
                           THEN
                              /*
                              ||The depth of the layer is greater than the
                              ||depth still to be removed so add the layer
                              ||with a reduced depth.
                              */
                              lv_depth_to_remove := 0;
                              lv_preview := lv_preview || ' Partially Removed.';
                              --
                        END CASE;
                      END LOOP;
                    END;
                    --
                    lv_preview := lv_preview||CHR(10);
                    --
                END IF;
                --
            END IF;
            --
          END LOOP;
          --
      END IF;
      --
    END LOOP;
    --
    RETURN lv_preview;
    --
  END preview_reconstruct_changes;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION preview_createreplace_changes(pi_layers_added       IN     NUMBER
                                        ,pi_xsps               IN     xsp_tab
                                        ,pi_ne_id              IN     nm_elements_all.ne_id%TYPE
                                        ,pi_begin_mp           IN     nm_members_all.nm_begin_mp%TYPE
                                        ,pi_end_mp             IN     nm_members_all.nm_end_mp%TYPE)
  RETURN CLOB IS
    --
    lv_severity         hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor   sys_refcursor;
    lv_cons_type        nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_layer_type       nm_inv_items_all.iit_inv_type%TYPE := get_layer_type;
    lv_query_id         NUMBER;
    lt_ne_ids           awlrs_util.ne_id_tab;
    lv_preview          CLOB;
    lv_cursor           sys_refcursor;
    lv_nt_type          nm_elements.ne_nt_type%TYPE;
    lv_grp_type         nm_elements.ne_gty_group_type%TYPE;
    lt_messages         awlrs_message_tab := awlrs_message_tab();
    --Type for locations of assets
    TYPE results_rec IS RECORD(asset_id            NUMBER
                              ,element_id          NUMBER
                              ,element_type        VARCHAR2(100)
                              ,element_unique      VARCHAR2(100)
                              ,element_descr       VARCHAR2(100)
                              ,from_offset         NUMBER
                              ,to_offset           NUMBER
                              ,offset_length       NUMBER
                              ,element_length      NUMBER
                              ,element_unit_id     NUMBER
                              ,element_unit_name   VARCHAR2(100)
                              ,element_admin_unit  VARCHAR2(100)
                              ,element_start_date  DATE
                              ,member_start_date   DATE);
    TYPE results_tab IS TABLE OF results_rec;
    lt_results  results_tab;
    --
    CURSOR get_cons_recs(cp_query_id IN NUMBER)
        IS
    SELECT iit_ne_id
          ,iit_admin_unit
          ,iit_x_sect
      FROM nm_inv_items
     WHERE iit_ne_id IN(SELECT ngqi_item_id
                          FROM nm_gaz_query_item_list
                         WHERE ngqi_job_id = cp_query_id)
         ;
    --
    CURSOR get_nw_grp_type(cp_ne_id IN nm_elements.ne_id%TYPE)
        IS
    SELECT ne_nt_type
          ,ne_gty_group_type
      FROM nm_elements
     WHERE ne_id = cp_ne_id
         ;
    --
    TYPE cons_rec_tab IS TABLE OF get_cons_recs%ROWTYPE;
    lt_cons_recs  cons_rec_tab;
    --
    lv_layer_sql  nm3type.max_varchar2 := 'SELECT '||c_layer_attrib_name
                                              ||','||c_thickness_attrib_name
                                        ||'  FROM nm_inv_items'
                                        ||' WHERE iit_inv_type = :layer_type'
                                        ||'   AND iit_foreign_key = (SELECT iit_primary_key'
                                        ||'                            FROM nm_inv_items'
                                        ||'                           WHERE iit_ne_id = :parent_id)'
                                        ||' ORDER'
                                        ||'    BY '||c_layer_attrib_name||' DESC'
    ;
    --
    TYPE layer_rec IS RECORD (layer_no  NUMBER
                             ,thickness NUMBER);
    TYPE layer_tab IS TABLE OF layer_rec;
    lt_layers  layer_tab;
    --
  BEGIN
    --
    -- lv_preview := lv_preview|| 'Create/Replace of  '||pi_layers_added|| ' layers will result in the following changes:'||chr(10)
    --pb to do shouldnt be loop as only ever one?
    FOR x in 1..pi_xsps.COUNT LOOP
      lv_preview := lv_preview
      ||'Network ID:'|| pi_ne_id
      ||'  XSP:'||pi_xsps(x)
      ||'  Begin Chainage:'||pi_begin_mp
      ||'  End Chainage:'||pi_end_mp||chr(10);
      lv_preview := lv_preview|| pi_layers_added|| ' new layers will be created:'
                    ||chr(10)
                    ||'All existing layers will be end dated'
                    ||chr(10);
      --
      /*
      ||get nw and group type from passed in network elements
      */
      /*OPEN  get_nw_grp_type(pi_ne_id);
      FETCH get_nw_grp_type
       INTO lv_nt_type, lv_grp_type;
      CLOSE get_nw_grp_type;
      /*
      ||Get the construction records on the network \ xsps indicated.
      */
      /*lv_query_id := execute_gaz_query(pi_inv_type => lv_cons_type
                                      ,pi_xsps     => pi_xsps
                                      ,pi_ne_id    => pi_ne_id
                                      ,pi_begin_mp => pi_begin_mp
                                      ,pi_end_mp   => pi_end_mp);
      --
     /* OPEN  get_cons_recs(lv_query_id);
      FETCH get_cons_recs
       BULK COLLECT
       INTO lt_cons_recs;
      CLOSE get_cons_recs;
      --
      FOR i IN 1..lt_cons_recs.COUNT LOOP
        /*
        ||get location at preferred lrm level in future but for now use passed in types.
        */
      /*  awlrs_asset_api.get_locations(pi_iit_ne_id        => lt_cons_recs(i).iit_ne_id
                                     ,pi_iit_inv_type     => get_cons_rec_type
                                     ,pi_nwtype           => lv_nt_type--
                                     ,pi_grouptype        => lv_grp_type--nm3user.get_preferred_lrm
                                     ,po_message_severity => lv_severity
                                     ,po_message_cursor   => lv_message_cursor
                                     ,po_cursor           => lv_cursor);
        --
        IF lv_severity = awlrs_util.c_msg_cat_success
         THEN
           --
           FETCH lv_cursor
            BULK COLLECT
            INTO lt_results;
           CLOSE lv_cursor;
           --
           FOR r IN 1..lt_results.COUNT LOOP
             /*
             || check its not in whole location .
             */
          /*   IF lt_results(r).element_id = pi_ne_id
              THEN
               IF lt_results(r).from_offset >= pi_begin_mp AND lt_results(r).to_offset <= pi_end_mp
                THEN
                   lv_preview := lv_preview
                   ||'Existing Layers from begin chainage:'
                   ||GREATEST(lt_results(r).from_offset,pi_begin_mp)
                   ||lt_results(r).from_offset
                   ||' '
                   ||pi_begin_mp
                   ||' to end chainage:'
                   ||lt_results(r).to_offset
                   ||' '
                   ||pi_end_mp;
                   ||LEAST(lt_results(r).to_offset,pi_end_mp) || '';
                   --
                   /*
                   ||Get the Layers from the existing record.
                   */
              /*     EXECUTE IMMEDIATE lv_layer_sql BULK COLLECT INTO lt_layers USING lv_layer_type, lt_cons_recs(i).iit_ne_id;
                   /*
                   ||Apply the depth removed to the Layers.
                   */
                   --
              /*     FOR j IN 1..lt_layers.COUNT LOOP
                     lv_preview := lv_preview
                     ||CHR(10)||'             Layer Number:'||lt_layers(j).layer_no;
                       IF pi_layers_added >= lt_layers(j).layer_no
                        THEN
                           /*
                           ||The layer will be replaced
                           */
                           --
              /*             lv_preview := lv_preview || ' Replaced';
                       ELSE
                           lv_preview := lv_preview || ' Removed';
                       END IF;
                   END LOOP;
                   --
                   lv_preview := lv_preview||CHR(10);
                   --
               END IF;
             END IF;
           END LOOP;
           --
        END IF;
        --
      END LOOP;*/
    END LOOP;
    --
    RETURN lv_preview;
    --
  END preview_createreplace_changes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE preview_replacement_changes(pi_layers_added       IN     NUMBER
                                       ,pi_depth_removed      IN     NUMBER
                                       ,pi_xsps               IN     xsp_tab
                                       ,pi_ne_ids             IN     awlrs_util.ne_id_tab
                                       ,pi_begin_mps          IN     location_from_offset_tab
                                       ,pi_end_mps            IN     location_to_offset_tab
                                       ,po_message_severity      OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor        OUT sys_refcursor
                                       ,po_cursor                OUT sys_refcursor)
  IS
    lv_preview CLOB;
    lt_xsps    xsp_tab;
  BEGIN
    /*
    ||indexes for ne id and MPs should be the same so index 1 ne id is index 1 begin_mp,end_mp and so on
    */
    IF pi_ne_ids.COUNT != pi_begin_mps.COUNT
     OR pi_ne_ids.COUNT != pi_end_mps.COUNT
      THEN
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 5);
        --
    END IF;
    --
    lv_preview := 'Number of layers to be added:'||pi_layers_added||chr(10);
    --
    FOR i in 1..pi_ne_ids.COUNT LOOP
      --
      IF pi_depth_removed IS NOT NULL -- not null is overlay/reconstruct
       THEN
          /*
          ||Function to work out what is being skimmed partially/fully.
          */
          lv_preview := lv_preview ||CHR(10)||preview_reconstruct_changes(pi_layers_added => pi_layers_added
                                                                         ,pi_depth_removed => pi_depth_removed
                                                                         ,pi_xsps          => pi_xsps --pass in all xsps. no distinction between xsp and ne as per mk
                                                                         ,pi_ne_id         => pi_ne_ids(i)
                                                                         ,pi_begin_mp      => pi_begin_mps(i)
                                                                         ,pi_end_mp        => pi_end_mps(i));
      ELSE --null is create/replace
          /*
          ||Create new records will not need to return information on existing records.
          */
          FOR j in 1..pi_xsps.COUNT LOOP
            lt_xsps.DELETE;
            lt_xsps(1) := pi_xsps(j);
            lv_preview := lv_preview
                          ||CHR(10)||preview_createreplace_changes(pi_layers_added => pi_layers_added
                                                                  ,pi_xsps          => lt_xsps --pass in all xsps. no distinction between xsp and ne as per mk
                                                                  ,pi_ne_id         => pi_ne_ids(i)
                                                                  ,pi_begin_mp      => pi_begin_mps(i)
                                                                  ,pi_end_mp        => pi_end_mps(i));
          END LOOP;
          --
      END IF;
    END LOOP;
    --
    OPEN po_cursor FOR
    SELECT lv_preview
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
  END preview_replacement_changes;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_records(pi_iit_ne_ids IN  iit_ne_id_tab
                                    ,po_cursor     OUT sys_refcursor)
    IS
    --
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    FOR i IN 1..pi_iit_ne_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_iit_ne_ids(i));
      --
    END LOOP;
    --
    --Not using the AWLRS asset one as may need to bring in alternate columns like detaled xsp.
    --
    OPEN po_cursor FOR
    SELECT iit_ne_id                                     asset_id
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
     WHERE iit.iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
         ;
    --
  END get_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_records(pi_iit_ne_ids       IN  iit_ne_id_tab
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_ids     iit_ne_id_tab;
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    get_construction_records(pi_iit_ne_ids => pi_iit_ne_ids
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
  END get_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_record(pi_iit_ne_id            IN  nm_inv_items_all.iit_ne_id%TYPE
                                   ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor       OUT sys_refcursor
                                   ,po_cursor               OUT sys_refcursor)
    IS
    --
    lt_ids iit_ne_id_tab;
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    lt_ids(1) := pi_iit_ne_id;
    --
    get_construction_records(pi_iit_ne_ids  => lt_ids
                            ,po_cursor     => lv_cursor);
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
  END get_construction_record;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_layers(pi_iit_ne_ids IN  iit_ne_id_tab
                                   ,po_cursor OUT sys_refcursor)
    IS
    --
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    FOR i IN 1..pi_iit_ne_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_iit_ne_ids(i));
      --
    END LOOP;
    /*
    ||Not using the awlrs asset one as may need to bring in alternate columns like layer.
    */
    OPEN po_cursor FOR 'SELECT iit_ne_id                                     asset_id'
                     ||'      ,iit_inv_type                                  inv_type'
                     ||'      ,iit_primary_key                               primary_key'
                     ||'      ,iit_x_sect                                    xsp'
                     ||'      ,iit_descr                                     description'
                     ||'      ,nm3user.get_username(iit_peo_invent_by_id)    identified_by'
                     ||'      ,iit_admin_unit                                admin_unit'
                     ||'      ,nm3inv.get_nit_descr(iit_inv_type)            asset_type_description'
                     ||'      ,iit_start_date                                start_date'
                     ||'      ,iit_end_date                                  end_date'
                     ||'      ,iit_note                                      note'
                     ||'      ,iit_foreign_key                               foreign_key'
                     ||'      ,'||c_layer_attrib_name||'                     layer'
                     ||'  FROM nm_inv_items_all iit'
                     ||' WHERE iit.iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(:ids AS nm_ne_id_array)))'
      USING lt_ids
    ;
    --
  END get_construction_layers;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_layers(pi_iit_ne_ids       IN  iit_ne_id_tab
                                   ,po_message_severity OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor   OUT sys_refcursor
                                   ,po_cursor           OUT sys_refcursor)
    IS
    --
    lt_ids     iit_ne_id_tab;
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    get_construction_layers(pi_iit_ne_ids => pi_iit_ne_ids
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
  END get_construction_layers;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_layer(pi_iit_ne_id            IN  nm_inv_items_all.iit_ne_id%TYPE
                                  ,po_message_severity     OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor       OUT sys_refcursor
                                  ,po_cursor               OUT sys_refcursor)
    IS
    --
    lt_ids iit_ne_id_tab;
    lv_cursor  sys_refcursor;
    --
  BEGIN
    --
    lt_ids(1) := pi_iit_ne_id;
    --
    get_construction_layers(pi_iit_ne_ids  => lt_ids
                           ,po_cursor     => lv_cursor);
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
  END get_construction_layer;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE enddate_construction_record(pi_iit_id           IN  nm_inv_items_all.iit_ne_id%TYPE
                                       ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                                       ,pi_run_checks       IN  VARCHAR2 DEFAULT 'Y'
                                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_asset_type      nm_inv_types_all.nit_inv_type%TYPE := get_cons_rec_type;
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    --
  BEGIN
    --
    awlrs_asset_api.asset_close(pi_asset_type       => lv_asset_type
                               ,pi_iit_ne_id        => pi_iit_id
                               ,pi_effective_date   => pi_effective_date
                               ,pi_run_checks       => pi_run_checks
                               ,po_message_severity => lv_severity
                               ,po_message_cursor   => lv_message_cursor);
    --
    po_message_severity := lv_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END enddate_construction_record;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_contruction_record(pi_iit_ne_id              IN  nm_inv_items_all.iit_ne_id%TYPE
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
                                     ,pi_old_attrib_names       IN  awlrs_asset_api.attrib_name_tab
                                     ,pi_attrib_names           IN  awlrs_asset_api.attrib_name_tab
                                     ,pi_old_attrib_scrn_texts  IN  awlrs_asset_api.attrib_scrn_text_tab
                                     ,pi_attrib_scrn_texts      IN  awlrs_asset_api.attrib_scrn_text_tab
                                     ,pi_old_attrib_char_values IN  awlrs_asset_api.attrib_value_tab
                                     ,pi_new_attrib_char_values IN  awlrs_asset_api.attrib_value_tab
                                     ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_message_cursor  sys_refcursor;
    lv_asset_type      nm_inv_types_all.nit_inv_type%TYPE := get_cons_rec_type;
    --
  BEGIN
    --
    awlrs_asset_api.update_asset(pi_iit_ne_id              => pi_iit_ne_id
                                ,pi_asset_type             => lv_asset_type
                                ,pi_old_primary_key        => pi_old_primary_key
                                ,pi_old_admin_unit         => pi_old_admin_unit
                                ,pi_old_xsp                => pi_old_xsp
                                ,pi_old_description        => pi_old_description
                                ,pi_old_start_date         => pi_old_start_date
                                ,pi_old_end_date           => pi_old_end_date
                                ,pi_old_notes              => pi_old_notes
                                ,pi_new_primary_key        => pi_new_primary_key
                                ,pi_new_admin_unit         => pi_new_admin_unit
                                ,pi_new_xsp                => pi_new_xsp
                                ,pi_new_description        => pi_new_description
                                ,pi_new_start_date         => pi_new_start_date
                                ,pi_new_end_date           => pi_new_end_date
                                ,pi_new_notes              => pi_new_notes
                                ,pi_old_attrib_names       => pi_old_attrib_names
                                ,pi_attrib_names           => pi_attrib_names
                                ,pi_old_attrib_scrn_texts  => pi_old_attrib_scrn_texts
                                ,pi_attrib_scrn_texts      => pi_attrib_scrn_texts
                                ,pi_old_attrib_char_values => pi_old_attrib_char_values
                                ,pi_new_attrib_char_values => pi_new_attrib_char_values
                                ,po_message_severity       => po_message_severity
                                ,po_message_cursor         => po_message_cursor);
    --
  END update_contruction_record;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_contruction_layer(pi_iit_ne_id              IN  nm_inv_items_all.iit_ne_id%TYPE
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
                                    ,pi_old_attrib_names       IN  awlrs_asset_api.attrib_name_tab
                                    ,pi_attrib_names           IN  awlrs_asset_api.attrib_name_tab
                                    ,pi_old_attrib_scrn_texts  IN  awlrs_asset_api.attrib_scrn_text_tab
                                    ,pi_attrib_scrn_texts      IN  awlrs_asset_api.attrib_scrn_text_tab
                                    ,pi_old_attrib_char_values IN  awlrs_asset_api.attrib_value_tab
                                    ,pi_new_attrib_char_values IN  awlrs_asset_api.attrib_value_tab
                                    ,po_message_severity       OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor         OUT sys_refcursor)
    IS
    --
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    lv_asset_type      nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    --
  BEGIN
    --
    awlrs_asset_api.update_asset(pi_iit_ne_id              => pi_iit_ne_id
                                ,pi_asset_type             => lv_asset_type
                                ,pi_old_primary_key        => pi_old_primary_key
                                ,pi_old_admin_unit         => pi_old_admin_unit
                                ,pi_old_xsp                => pi_old_xsp
                                ,pi_old_description        => pi_old_description
                                ,pi_old_start_date         => pi_old_start_date
                                ,pi_old_end_date           => pi_old_end_date
                                ,pi_old_notes              => pi_old_notes
                                ,pi_new_primary_key        => pi_new_primary_key
                                ,pi_new_admin_unit         => pi_new_admin_unit
                                ,pi_new_xsp                => pi_new_xsp
                                ,pi_new_description        => pi_new_description
                                ,pi_new_start_date         => pi_new_start_date
                                ,pi_new_end_date           => pi_new_end_date
                                ,pi_new_notes              => pi_new_notes
                                ,pi_old_attrib_names       => pi_old_attrib_names
                                ,pi_attrib_names           => pi_attrib_names
                                ,pi_old_attrib_scrn_texts  => pi_old_attrib_scrn_texts
                                ,pi_attrib_scrn_texts      => pi_attrib_scrn_texts
                                ,pi_old_attrib_char_values => pi_old_attrib_char_values
                                ,pi_new_attrib_char_values => pi_new_attrib_char_values
                                ,po_message_severity       => lv_severity
                                ,po_message_cursor         => lv_message_cursor);
    --
    po_message_severity := lv_severity;
    po_message_cursor := lv_message_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_contruction_layer;
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
    OPEN po_cursor FOR 'SELECT iig_top_id    toplevelid'
                          ||' ,nm3inv.get_inv_type(iig_top_id)  toplevelassettype'
                          ||' ,nm3inv.get_inv_primary_key(iig_top_id) toplevelpk'
                          ||' ,iig_item_id   itemid'
                          ||' ,nm3inv.get_inv_type(iig_item_id) itemlevelassettype'
                          ||' ,iig_parent_id parentid'
                          ||' ,nm3inv.get_inv_type(iig_parent_id) parentlevelassettype'
                          ||' ,nm3inv.get_inv_primary_key(iig_parent_id) parentlevelpk'
                          ||' ,'||c_layer_attrib_name||' layerno'
                          ||' ,'||c_thickness_attrib_name||' thickness'
                      ||' FROM nm_inv_item_groupings'
                           ||',nm_inv_items'
                     ||' WHERE iig_top_id = nm3inv.get_top_item_id(:id)'
                       ||' AND iig_item_id = iit_ne_id'
                     ||' ORDER BY '||c_layer_attrib_name||' DESC'
      USING pi_iit_ne_id
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
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_flex_attribs(pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                            ,pi_inv_type         IN  nm_inv_items_all.iit_inv_type%TYPE
                            ,pi_disp_derived     IN  BOOLEAN DEFAULT TRUE
                            ,pi_disp_inherited   IN  BOOLEAN DEFAULT TRUE
                            ,po_message_severity OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor   OUT sys_refcursor
                            ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_severity        hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_message_cursor  sys_refcursor;
    lv_cursor          sys_refcursor;
    lt_restrict_cols   awlrs_asset_api.view_col_names_tab;
    --
  BEGIN
    /*
    || Restrict returning columns to exclude some PCR and PCL atributes.
    */
    lt_restrict_cols.DELETE;
    --
    IF pi_inv_type = get_layer_type
     THEN
        --
        lt_restrict_cols(1) := 'LAYER';
        --
    END IF;
    --
    awlrs_asset_api.get_flex_attribs(pi_iit_ne_id        => pi_iit_ne_id
                                    ,pi_inv_type         => pi_inv_type
                                    ,pi_disp_derived     => pi_disp_derived
                                    ,pi_disp_inherited   => pi_disp_inherited
                                    ,pi_exclude_cols     => lt_restrict_cols
                                    ,po_message_severity => lv_severity
                                    ,po_message_cursor   => lv_message_cursor
                                    ,po_cursor           => lv_cursor);
    --
    po_message_severity := lv_severity;
    po_message_cursor := lv_message_cursor;
    po_cursor := lv_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_flex_attribs;
  --
  -----------------------------------------------------------------------------
  --
  --
  FUNCTION get_col_mrg_attrib_name(pi_inv_col IN nm_inv_type_attribs.ita_attrib_name%TYPE)
    RETURN user_tab_columns.column_name%TYPE IS
    --
    lv_retval user_tab_columns.column_name%TYPE;
    --
  BEGIN
    --
    SELECT apma_mrg_attrib_name
      INTO lv_retval
      FROM awlrs_plm_merge_attribs
     WHERE apma_attrib_name = UPPER(pi_inv_col)
         ;
    --
    RETURN lv_retval;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 58);
    WHEN too_many_rows
     THEN
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 59);
  END get_col_mrg_attrib_name;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_layer_mrg_attrib_name
    RETURN user_tab_columns.column_name%TYPE IS
  BEGIN
    --
    RETURN get_col_mrg_attrib_name(pi_inv_col => c_layer_attrib_name);
    --
  END get_layer_mrg_attrib_name;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_material_mrg_attrib_name
    RETURN user_tab_columns.column_name%TYPE IS
  BEGIN
    --
    RETURN get_col_mrg_attrib_name(pi_inv_col => c_material_attrib_name);
    --
  END get_material_mrg_attrib_name;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_depth_mrg_attrib_name
    RETURN user_tab_columns.column_name%TYPE IS
  BEGIN
    --
    RETURN get_col_mrg_attrib_name(pi_inv_col => c_thickness_attrib_name);
    --
  END get_depth_mrg_attrib_name;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_max_layers(pi_mrg_job_id     IN nm_mrg_query_results.nqr_mrg_job_id%TYPE
                         ,pi_mrg_section_id IN nm_mrg_sections.nms_mrg_section_id%TYPE DEFAULT NULL
                         ,pi_reset          IN boolean DEFAULT FALSE)
    RETURN pls_integer IS
    --
    lv_sql nm3type.max_varchar2;
    --
  BEGIN
    --
    IF pi_reset
     THEN
        g_max_layers := NULL;
    END IF;
    --
    IF g_max_layers IS NULL
     THEN
        --
        lv_sql :=  'SELECT MAX(to_number(nsv.'||get_layer_mrg_attrib_name||')) max_layers'
        ||CHR(10)||'  FROM nm_mrg_section_inv_values nsv'
        ;
        --
        IF pi_mrg_section_id IS NOT NULL
         THEN
            lv_sql := lv_sql||CHR(10)||'      ,nm_mrg_section_member_inv nsi';
        END IF;
        --
        lv_sql := lv_sql||CHR(10)||' WHERE nsv.nsv_mrg_job_id = :p_mrg_job_id';
        --
        IF pi_mrg_section_id IS NOT NULL
         THEN
            lv_sql := lv_sql
              ||CHR(10)||'   AND nsi.nsi_mrg_section_id = :p_mrg_section_id'
              ||CHR(10)||'   AND nsi.nsi_value_id = nsv.nsv_value_id'
              ||CHR(10)||'   AND nsi.nsi_mrg_job_id = nsv.nsv_mrg_job_id'
            ;
        END IF;
        --
        IF pi_mrg_section_id IS NOT NULL
         THEN
            EXECUTE IMMEDIATE lv_sql INTO g_max_layers USING pi_mrg_job_id,pi_mrg_section_id;
        ELSE
            EXECUTE IMMEDIATE lv_sql INTO g_max_layers USING pi_mrg_job_id;
        END IF;
        --
    END IF;
    --
    RETURN g_max_layers;
    --
  END get_max_layers;
  --
  -----------------------------------------------------------------------------
  --This procedure has been moved from STP. It executes the merge query on ROI
  --and returns the Job ID of the merge results, network type and subclass
  --of the datums within the region.
  -----------------------------------------------------------------------------
  --
  PROCEDURE execute_merge(pi_roi_id           IN  NUMBER
                         ,pi_roi_name         IN  VARCHAR2
                         ,pi_roi_type         IN  VARCHAR2
                         ,pi_roi_begin_mp     IN  NUMBER DEFAULT NULL
                         ,pi_roi_end_mp       IN  NUMBER DEFAULT NULL
                         ,po_mrg_job_id       OUT nm_mrg_query_results.nqr_mrg_job_id%TYPE
                         ,po_nt_type          OUT nm_types.nt_type%TYPE
                         ,po_subclass         OUT nm_elements.ne_sub_class%TYPE
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    c_mrg_qry_descr  CONSTANT nm_mrg_query_results.nqr_description%TYPE :=
                       'Pavement Construction Layers Data For '
                       ||pi_roi_name
                       ||' from '
                       ||pi_roi_begin_mp
                       ||' to '
                       ||pi_roi_end_mp
                       ||'. Created on '
                       ||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS');
    --
    lv_nte_job_id  nm_nw_temp_extents.nte_job_id%TYPE;
    --
    lr_roi_ne_rec  nm_elements%ROWTYPE;
    --
    lv_source         VARCHAR2(100);
    lr_longops        nm3sql.longops_rec;
    lv_sqlcount       PLS_INTEGER;
    lv_admin_unit_id  INTEGER;
    /*
    ||brought over from stp and removed first parameter as never used
    */
    PROCEDURE get_extent_nw_details(po_nt_type    OUT nm_types.nt_type%TYPE
                                   ,po_subclass   OUT nm_elements.ne_sub_class%TYPE)
      IS
      --
      extent_empty EXCEPTION;
      --
      CURSOR cs_nw
          IS
      SELECT /*+ cardinality(dt 1) */
             ne.ne_nt_type,
             ne.ne_sub_class
        FROM nm_datum_criteria_tmp dt
            ,nm_elements ne
       WHERE dt.datum_id = ne.ne_id
           ;
      --
    BEGIN
      --
      OPEN  cs_nw;
      FETCH cs_nw
       INTO po_nt_type
           ,po_subclass;
      IF cs_nw%NOTFOUND
       THEN
          CLOSE cs_nw;
          RAISE extent_empty;
      END IF;
      CLOSE cs_nw;
      --
    EXCEPTION
      WHEN extent_empty
       THEN
          --
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 57);
          --
    END get_extent_nw_details;
    --
  BEGIN
    /*
    ||clear data based on previous mrg
    */
    g_max_layers := NULL;
    --
    lv_admin_unit_id := nm3ausec.get_highest_au_of_au_type(p_au_type => hig.get_sysopt('MRGAUTYPE')
                                                          ,p_user    => USER
                                                          ,p_mode    => 'NORMAL');
    --
    lv_source := nm3extent.get_nte_source_from_roi_type(pi_roi_type);
    --
    IF lv_source = nm3extent.c_route
     THEN
        /*
        ||Group 'ROUTE'
        ||This loads any level group (linear or not) or a single datum
        */
        nm3bulk_mrg.load_group_datums(p_group_id   => pi_roi_id
                                     ,p_group_type => NULL
                                     ,p_sqlcount   => lv_sqlcount);
        --
    ELSIF lv_source = nm3extent.c_saved
     THEN
        /*
        || saved extent 'SAVED'
        */
        nm3bulk_mrg.load_extent_datums(p_group_type => NULL
                                      ,p_nse_id     => pi_roi_id
                                      ,p_sqlcount   => lv_sqlcount);
    END IF;
    --
    get_extent_nw_details(po_nt_type    => po_nt_type
                         ,po_subclass   => po_subclass);
    --
    IF po_subclass IS NULL
     THEN
        --assume subclass is on the route so get it from the ROI
        lr_roi_ne_rec := nm3get.get_ne_all(pi_ne_id => pi_roi_id);
        --
        po_nt_type  := lr_roi_ne_rec.ne_nt_type;
        po_subclass := lr_roi_ne_rec.ne_sub_class;
    END IF;
    /*
    || 2 populate route connectivity
    */
    nm3bulk_mrg.ins_route_connectivity(p_criteria_rowcount => lv_sqlcount
                                      ,p_ignore_poe        => null);
    --
    nm3sql.set_longops(p_rec       => lr_longops,
                       p_increment => 1);
    /*
    || 3,4,5. Run the bulk merge query
    */
    nm3bulk_mrg.std_run(p_nmq_id            => c_rc_mrg_qry
                       ,p_nqr_admin_unit    => lv_admin_unit_id
                       ,p_nqr_source        => lv_source
                       ,p_nqr_source_id     => pi_roi_id
                       ,p_domain_return     => 'C' -- CODE
                       ,p_nmq_descr         => c_mrg_qry_descr
                       ,p_criteria_rowcount => lv_sqlcount
                       ,p_mrg_job_id        => po_mrg_job_id
                       ,p_longops_rec       => lr_longops);  -- stp note - ignored with null rindex value
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor               => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END execute_merge;
  --
  -----------------------------------------------------------------------------
  -- New Get the sections linked to the merge query run from execute merge. Based on ROI
  -- This will be populated afte the execute query is run.
  -- The section ID is the splitter point and if the user clicks down the left hand side for difffernt points of the network
  -- then the get_data will need requerying based on the section id to restrict the values to that area.
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_merge_sections(pi_mrg_job_id       IN  NUMBER
                              ,pi_roi_begin_mp     IN  NUMBER
                              ,pi_roi_end_mp       IN  NUMBER
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT nms_mrg_job_id
          ,nms_mrg_section_id
          ,nms_offset_ne_id
          ,ne_unique
          ,ne_nt_type
          ,nms_begin_offset
          ,nms_end_offset
          ,nms_ne_id_first
          ,nms_begin_mp_first
          ,nms_ne_id_last
          ,nms_end_mp_last
      FROM nm_mrg_sections
          ,nm_elements
     WHERE nms_mrg_job_id = pi_mrg_job_id
       AND nms_offset_ne_id = ne_id
       AND nms_begin_offset < pi_roi_end_mp
       AND nms_end_offset > pi_roi_begin_mp
     ORDER
        BY nms_begin_offset
          ,nms_end_offset
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
  END get_merge_sections;
  --
  -----------------------------------------------------------------------------
  -- In STP get_stp_rc_grid_data is built via build_grid_data_func based on attribute values set in step forms.
  -- refactored to use dynamic sql based on same idea on new plm metadata table.
  -----------------------------------------------------------------------------
  --
  FUNCTION get_plm_rc_grid_data(pi_mrg_job_id     IN  nm_mrg_query_results.nqr_mrg_job_id%TYPE
                               ,pi_mrg_section_id IN  nm_mrg_sections.nms_mrg_section_id%TYPE
                               ,pi_inv_type       IN  nm_inv_types.nit_inv_type%TYPE
                               ,pi_xsp            IN  nm_xsp.nwx_x_sect%TYPE
                               ,pi_layer          IN  nm_inv_items.iit_no_of_units%TYPE
                               ,po_material       OUT nm_inv_items.iit_material%TYPE
                               ,po_depth          OUT nm_inv_items.iit_length%TYPE)
    RETURN VARCHAR2 IS
    --
    lt_data_tab      nm3type.tab_varchar32767;
    lt_material_tab  nm3type.tab_varchar30;
    lt_depth_tab     nm3type.tab_number;
    lv_retval        nm3type.max_varchar2;
    --
    lv_driving_sql     nm3type.max_varchar2;
    lv_select_list     nm3type.max_varchar2;
    lv_data_seperator  VARCHAR2(30) := ' || '||nm3flx.string('-')||' || ';
    --
    TYPE attrib_tab IS TABLE OF awlrs_plm_merge_attribs.apma_mrg_attrib_name%TYPE;
    lt_attribs  attrib_tab;
    --
  BEGIN
    /*
    || get list of columns to select
    */
    SELECT apma_mrg_attrib_name
      BULK COLLECT
      INTO lt_attribs
      FROM awlrs_plm_merge_attribs
     WHERE apma_func_seq_no IS NOT NULL
     ORDER
        BY apma_func_seq_no
         ;
    --
    FOR i IN 1..lt_attribs.COUNT LOOP
      --
      lv_select_list := lv_select_list||lt_attribs(i)||lv_data_seperator;
      --
    END LOOP;
    /*
    ||Remove trailing seperator
    */
    lv_select_list := SUBSTR(lv_select_list, 1, LENGTH(lv_select_list) - LENGTH(lv_data_seperator));
    /*
    |Dynamic SQL to replace the auto generated procedure STP uses.
    */
    lv_driving_sql := 'SELECT '||lv_select_list
           ||CHR(10)||'      ,'||get_material_mrg_attrib_name
           ||CHR(10)||'      ,'||get_depth_mrg_attrib_name
           ||CHR(10)||'  FROM nm_mrg_section_member_inv'
           ||CHR(10)||'      ,nm_mrg_section_inv_values'
           ||CHR(10)||' WHERE nsi_mrg_job_id = :pi_mrg_job_id'
           ||CHR(10)||'   AND nsi_mrg_section_id = :pi_mrg_section_id'
           ||CHR(10)||'   AND nsi_inv_type = :pi_inv_type'
           ||CHR(10)||'   AND nsi_x_sect = :pi_xsp'
           ||CHR(10)||'   AND nsi_mrg_job_id = nsv_mrg_job_id'
           ||CHR(10)||'   AND nsi_value_id = nsv_value_id'
           ||CHR(10)||'   AND '||get_layer_mrg_attrib_name ||' = :pi_layer'
    ;
    /*
    ||bulk collect into arrays
    */
    EXECUTE IMMEDIATE lv_driving_sql
    BULK COLLECT INTO
         lt_data_tab
        ,lt_material_tab
        ,lt_depth_tab
    USING pi_mrg_job_id, pi_mrg_section_id, pi_inv_type, pi_xsp, pi_layer;
    --
    IF lt_data_tab.COUNT = 0
     THEN
        RAISE no_data_found;
    END IF;
    --
    /*
    ||TO DO Not sure what scenerio would result in this. Need to investigate. But for now leave in
    */
    FOR l_i IN 1..lt_data_tab.COUNT LOOP
      lv_retval := lv_retval || lt_data_tab(l_i) || ' || ';
    END LOOP;
    --
    po_material := lt_material_tab(1);
    po_depth    := lt_depth_tab(1);
    --
    RETURN SUBSTR(lv_retval,1,LENGTH(lv_retval) - 3);
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        --
        hig.raise_ner(pi_appl               => nm3type.c_hig
                     ,pi_id                 => 67
                     ,pi_sqlcode            => -20770
                     ,pi_supplementary_info => pi_mrg_job_id
                                               ||':'||pi_mrg_section_id
                                               ||':'||pi_inv_type
                                               ||':'||pi_layer);
        --
  END get_plm_rc_grid_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_merge_data(pi_mrg_job_id       IN  nm_mrg_sections.nms_mrg_job_id%TYPE
                          ,pi_mrg_section_id   IN  nm_mrg_sections.nms_mrg_section_id%TYPE
                          ,pi_nw_type          IN  nm_types.nt_type%TYPE
                          ,pi_sub_class        IN  nm_type_subclass.nsc_sub_class%TYPE
                          ,pi_all_xsps         IN  VARCHAR2 DEFAULT 'N'
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    c_max_layers  CONSTANT PLS_INTEGER := get_max_layers(pi_mrg_job_id     => pi_mrg_job_id
                                                        ,pi_mrg_section_id => pi_mrg_section_id
                                                        ,pi_reset          => TRUE);
    --
    --lv_col_no  PLS_INTEGER := 0;
    --
    lv_grid_data  t_rc_data_cell;
    lv_material   t_rc_material;
    lv_depth      t_rc_depth;
    --
    lv_xsp_has_data  BOOLEAN;
    --
    lv_xsp_depth  NUMBER;
    --
    lv_asset_type       nm_inv_types_all.nit_inv_type%TYPE := get_layer_type;
    lt_plm_layer_asset  awlrs_plm_layer_label_tab := awlrs_plm_layer_label_tab();
    --
    CURSOR get_xsps(cp_nw_type   IN nm_types.nt_type%TYPE
                   ,cp_inv_type  IN nm_inv_types_all.nit_inv_type%TYPE
                   ,cp_sub_class IN nm_type_subclass.nsc_sub_class%TYPE)
        IS
    SELECT xsr.xsr_x_sect_value xsp
      FROM nm_xsp nwx
          ,xsp_restraints xsr
     WHERE xsr.xsr_nw_type = cp_nw_type
       AND nwx.nwx_nw_type = xsr.xsr_nw_type
       AND xsr.xsr_ity_inv_code = cp_inv_type
       AND xsr.xsr_scl_class = cp_sub_class
       AND nwx.nwx_nsc_sub_class = xsr.xsr_scl_class
       AND nwx.nwx_x_sect = xsr.xsr_x_sect_value
     ORDER
        BY nwx.nwx_seq
          ,xsr.xsr_x_sect_value
         ;
    --
    TYPE xsp_tab IS TABLE OF xsp_restraints.xsr_x_sect_value%TYPE;
    lt_xsps  xsp_tab;
    --
  BEGIN
    --
    lt_plm_layer_asset.DELETE;
    /*
    ||Loop through XSPs
    */
    OPEN  get_xsps(pi_nw_type,lv_asset_type,pi_sub_class);
    FETCH get_xsps
     BULK COLLECT
     INTO lt_xsps;
    CLOSE get_xsps;
    --
    FOR i IN 1..lt_xsps.COUNT LOOP
      --
      lv_xsp_has_data := FALSE;
      --
      lv_xsp_depth := 0;
      --
      --lv_col_no := lv_col_no + 1;
      /*
      ||Loop through all Layers
      */
      FOR j IN 1..c_max_layers LOOP
        --
        DECLARE
          no_data EXCEPTION;
          PRAGMA EXCEPTION_INIT(no_data, -20770);
          --
        BEGIN
          /*
          ||Converted to dynamic sql for this procedure
          */
          lv_grid_data := get_plm_rc_grid_data(pi_mrg_job_id     => pi_mrg_job_id
                                              ,pi_mrg_section_id => pi_mrg_section_id
                                              ,pi_inv_type       => lv_asset_type
                                              ,pi_xsp            => lt_xsps(i)
                                              ,pi_layer          => j
                                              ,po_material       => lv_material
                                              ,po_depth          => lv_depth);
          --
          lv_xsp_has_data := TRUE;
          /*
          || populate new type
          */
          lt_plm_layer_asset.EXTEND;
          lt_plm_layer_asset(lt_plm_layer_asset.count) := awlrs_plm_layer_label(lt_xsps(i)
                                                                               ,j
                                                                               ,lv_grid_data
                                                                               ,lv_material
                                                                               ,lv_depth);
        EXCEPTION
          WHEN no_data
           THEN
              IF pi_all_xsps = 'Y'
               THEN
                  lv_grid_data := NULL;
                  lv_material  := NULL;
                  lv_depth     := NULL;
                  lt_plm_layer_asset.EXTEND;
                  lt_plm_layer_asset(lt_plm_layer_asset.count) := awlrs_plm_layer_label(NULL
                                                                                       ,j
                                                                                       ,lv_grid_data
                                                                                       ,lv_material
                                                                                       ,lv_depth);
              ELSE
                  lv_grid_data := NULL;
                  lv_material  := NULL;
                  lv_depth     := NULL;
              END IF;
        END;
        --
        lv_xsp_depth := lv_xsp_depth + NVL(lv_depth, 0);
        --
      END LOOP;
      --
    END LOOP;
    /*
    ||retun type as sys ref cursor
    */
    OPEN po_cursor FOR
    SELECT *
      FROM TABLE(CAST(lt_plm_layer_asset AS awlrs_plm_layer_label_tab))
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
  END get_merge_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_merge_cell_asset_id(pi_ne_id       IN nm_elements_all.ne_id%TYPE
                                   ,pi_from_offset IN nm_gaz_query.ngq_begin_mp%TYPE DEFAULT NULL
                                   ,pi_to_offset   IN nm_gaz_query.ngq_end_mp%TYPE DEFAULT NULL
                                   ,pi_xsp         IN nm_inv_items.iit_x_sect%TYPE
                                   ,pi_layer       IN NUMBER
                                   ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                   ,po_message_cursor      OUT sys_refcursor
                                   ,po_cursor              OUT sys_refcursor) IS
    --
    lv_job_id    NUMBER := nm3ddl.sequence_nextval('RTG_JOB_ID_SEQ');
    lv_result_id NUMBER;
    lv_inv_type  nm_inv_types_all.nit_inv_type%TYPE;
    lv_sql       nm3type.max_varchar2;
    lt_xsps      xsp_tab;
    --
  BEGIN
    --
    lt_xsps(1) := pi_xsp;
    lv_result_id := execute_gaz_query(pi_inv_type      => get_layer_type
                                     ,pi_xsps          => lt_xsps
                                     ,pi_ne_id         => pi_ne_id
                                     ,pi_begin_mp      => pi_from_offset
                                     ,pi_end_mp        => pi_to_offset);
    --
    --should only return the one record.
    --
    lv_sql :=  'SELECT iit_foreign_key                     construction_record_id '
    ||CHR(10)||'      ,iit_ne_id                           construction_layer_id '
    ||CHR(10)||'      ,'||c_layer_attrib_name||' layer_no'
    ||CHR(10)||'  FROM nm_inv_items '
    ||CHR(10)||' WHERE iit_inv_type =  :layer_type'
    ||CHR(10)||'   AND iit_ne_id IN (SELECT ngqi_item_id '
    ||CHR(10)||'                       FROM nm_gaz_query_item_list '
    ||CHR(10)||'                      WHERE ngqi_job_id = :result_id) '
    ||CHR(10)||'   AND '||c_layer_attrib_name ||' = :layer'
    ;
    --
    OPEN po_cursor FOR lv_sql
    USING get_layer_type, lv_result_id, pi_layer
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
  END get_merge_cell_asset_id;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION is_pavement_data(pi_ne_id nm_elements.ne_id%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval VARCHAR2(1);
    lv_inv_type   nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    --
  BEGIN
    SELECT pavement_data
      INTO lv_retval
      FROM (SELECT 'Y' pavement_data--datums
              FROM nm_members
             WHERE nm_obj_type = lv_inv_type
               AND nm_ne_id_of = pi_ne_id
             UNION
            SELECT 'Y' pavement_data--group of datums
              FROM nm_members i
                  ,nm_members g
             WHERE g.nm_ne_id_of = i.nm_ne_id_of
               AND i.nm_obj_type =lv_inv_type
               AND i.nm_type = 'I'
               AND g.nm_ne_id_in = pi_ne_id
               AND g.nm_type = 'G')
    ;
    /*
    ||if statement returns row then return as pcr data;
    */
    RETURN lv_retval;
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      RETURN 'N';
      --
  END is_pavement_data;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_elements(pi_ne_ids awlrs_util.ne_id_tab
                                ,po_cursor OUT sys_refcursor)
    IS
    --.
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    FOR i IN 1..pi_ne_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_ne_ids(i));
      --
    END LOOP;
    --
    OPEN po_cursor FOR
    SELECT ne_id                   element_id
          ,ne_unique               element_name
          ,ne_descr                element_desc
          ,is_pavement_data(ne_id) pavement_data_exists
          ,ne_admin_unit           admin_unit_code
          ,nau_name                admin_unit_name
          ,ne_length               element_length
      FROM nm_elements
          ,nm_admin_units_all
     WHERE ne_id IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
         ;
    --
  END get_network_elements;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_elements(pi_ne_ids           IN  awlrs_util.ne_id_tab
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    get_network_elements(pi_ne_ids => pi_ne_ids
                        ,po_cursor => po_cursor);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_network_elements;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_xsps(pi_ne_ids           IN  awlrs_util.ne_id_tab
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor
                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_inv_type      nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_xsp_inv_type  nm_inv_items_all.iit_inv_type%TYPE := hig.get_sysopt(p_option_id => 'AWLXSPASST');
    --
    lr_nit nm_inv_types%ROWTYPE;
    --
    lt_ids  nm_ne_id_array := nm_ne_id_array();
    --
  BEGIN
    --
    lr_nit := nm3get.get_nit(lv_inv_type);
    --
    FOR i IN 1..pi_ne_ids.COUNT LOOP
      --
      lt_ids.extend;
      lt_ids(i) := nm_ne_id_type(pi_ne_ids(i));
      --
    END LOOP;
    --
    IF lr_nit.nit_x_sect_allow_flag = 'Y'
     THEN
        IF lv_xsp_inv_type IS NOT NULL
         THEN
            /*
            ||Product Option Identifies an Asset Type used to model XSPs so
            ||restrict based on existence of assets of this type at the given locations
            ||as well as valid values for the Construction Record Asset Type.
            */
            OPEN po_cursor FOR
              SELECT DISTINCT nwx_x_sect  xsp
                             ,nwx_descr   xspdesc
                             ,nwx_seq     seq
                FROM nm_nw_xsp
               WHERE nwx_x_sect IN(SELECT nwx_x_sect
                                     FROM nm_elements
                                         ,nm_nw_xsp
                                         ,nm_members im
                                         ,nm_inv_items
                                         ,xsp_restraints
                                    WHERE ne_id IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
                                      AND ne_nt_type = nwx_nw_type
                                      AND ne_sub_class = nwx_nsc_sub_class
                                      AND ne_id = im.nm_ne_id_of
                                      AND im.nm_obj_type = lv_xsp_inv_type
                                      AND im.nm_ne_id_in = iit_ne_id
                                      AND iit_x_sect = nwx_x_sect
                                      AND xsr_ity_inv_code = lv_inv_type
                                      AND nwx_x_sect = xsr_x_sect_value
                                      AND ne_sub_class = xsr_scl_class
                                      AND ne_nt_type = xsr_nw_type
                                   UNION ALL
                                   SELECT nwx_x_sect
                                     FROM nm_members rm
                                         ,nm_elements
                                         ,nm_nw_xsp
                                         ,nm_members im
                                         ,nm_inv_items
                                         ,xsp_restraints
                                    WHERE rm.nm_ne_id_in IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
                                      AND rm.nm_ne_id_of = ne_id
                                      AND ne_nt_type = nwx_nw_type
                                      AND ne_sub_class = nwx_nsc_sub_class
                                      AND ne_id = im.nm_ne_id_of
                                      AND im.nm_obj_type = lv_xsp_inv_type
                                      AND im.nm_ne_id_in = iit_ne_id
                                      AND iit_x_sect = nwx_x_sect
                                      AND xsr_ity_inv_code = lv_inv_type
                                      AND nwx_x_sect = xsr_x_sect_value
                                      AND ne_sub_class = xsr_scl_class
                                      AND ne_nt_type = xsr_nw_type)
               ORDER BY seq, xsp
                   ;
        ELSE
            /*
            ||Return XSPs valid for the Construction Record Asset Type at the given locations.
            */
            OPEN po_cursor FOR
              SELECT DISTINCT nwx_x_sect  xsp
                    ,nwx_descr            xspdesc
                    ,nwx_seq              seq
                FROM nm_nw_xsp
               WHERE nwx_x_sect IN(SELECT nwx_x_sect
                                     FROM nm_nw_xsp
                                         ,nm_elements
                                         ,xsp_restraints
                                    WHERE ne_id IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
                                      AND ne_nt_type = nwx_nw_type
                                      AND ne_sub_class = nwx_nsc_sub_class
                                      AND xsr_ity_inv_code = lv_inv_type
                                      AND nwx_x_sect = xsr_x_sect_value
                                      AND ne_sub_class = xsr_scl_class
                                      AND ne_nt_type = xsr_nw_type
                                   UNION ALL
                                   SELECT nwx_x_sect
                                     FROM nm_nw_xsp
                                         ,nm_elements
                                         ,nm_members
                                         ,xsp_restraints
                                    WHERE nm_ne_id_in IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
                                      AND nm_ne_id_of = ne_id
                                      AND ne_nt_type = nwx_nw_type
                                      AND ne_sub_class = nwx_nsc_sub_class
                                      AND xsr_ity_inv_code = lv_inv_type
                                      AND nwx_x_sect = xsr_x_sect_value
                                      AND ne_sub_class = xsr_scl_class
                                      AND ne_nt_type = xsr_nw_type)
               ORDER BY seq, xsp
                   ;
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
  END get_xsps;

  --
  -----------------------------------------------------------------------------
  --Update the XSP value pre running the PBI query
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_pbi_xsp_value (pi_npq_id IN nm_pbi_query.npq_id%TYPE
                                 ,pi_xsp    IN nm_inv_items_all.iit_x_sect%TYPE) IS
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
  BEGIN
    --
    UPDATE nm_pbi_query_values
       SET nqv_value = pi_xsp
     WHERE nqv_npq_id = pi_npq_id;
    --
    COMMIT;
    --
  END update_pbi_xsp_value;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_gaps(pi_ne_ids             IN  awlrs_util.ne_id_tab
                                 ,pi_xsps               IN  xsp_tab
                                 ,pi_begin_mps          IN  location_from_offset_tab
                                 ,pi_end_mps            IN  location_to_offset_tab
                                 ,po_xsp_job            OUT nm_id_code_tbl)
    IS
    --
    lv_nt_type           nm_elements.ne_nt_type%TYPE;
    lv_grp_type          nm_elements.ne_gty_group_type%TYPE;
    lv_nwextent_id       NUMBER := nm3net.get_next_nte_id;
    lv_nwextent_id2      NUMBER;
    lv_pcrextent_id      NUMBER;
    lv_gapsextent_id     NUMBER;
    lv_pbi_result_job_id NUMBER;
    lv_npq_id            nm_pbi_query.npq_id%TYPE;
    --
    lt_plm_xsp_job  nm_id_code_tbl := nm_id_code_tbl();
    --
    TYPE nte_tab  IS TABLE OF nm_nw_temp_extents%ROWTYPE;
    lt_nte nte_tab := nte_tab();
    --
    CURSOR get_nw_grp_type(cp_ne_id IN nm_elements.ne_id%TYPE)
        IS
    SELECT ne_nt_type
          ,ne_gty_group_type
      FROM nm_elements
     WHERE ne_id = cp_ne_id
         ;
    --
    FUNCTION insert_pbi_query
      RETURN NUMBER IS
      --
      lv_npq_id     nm_pbi_query.npq_id%TYPE;
      lv_nqt_id     nm_pbi_query_types.nqt_seq_no%TYPE;
      lv_pbi_unique nm_pbi_query.npq_unique%TYPE := 'AWL_PLM_CONS_GAPS';
      lv_pbi_descr  nm_pbi_query.npq_descr%TYPE := 'Pre-Defined PBI query for use with Pavement Layers to establish gaps';
      lv_inv_type   nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
      --
    BEGIN
      --
      SELECT npq_id
        INTO lv_npq_id
        FROM nm_pbi_query
       WHERE npq_unique = lv_pbi_unique;
      --
      RETURN lv_npq_id;
      --
    EXCEPTION
      WHEN no_data_found
       THEN
          lv_npq_id := nm3ddl.sequence_nextval('NPQ_ID_SEQ');
          lv_nqt_id := nm3ddl.sequence_nextval('NQT_SEQ_NO_SEQ');
          /*
          ||Create PBI query and standard metadata needed.
          */
          INSERT
            INTO nm_pbi_query
                (npq_id
                ,npq_unique
                ,npq_descr)
          VALUES(lv_npq_id
                ,lv_pbi_unique
                ,lv_pbi_descr)
               ;
          --
          INSERT
            INTO nm_pbi_query_types
                (nqt_npq_id
                ,nqt_seq_no
                ,nqt_item_type_type
                ,nqt_item_type)
          VALUES(lv_npq_id
                ,lv_nqt_id
                ,'I'
                ,lv_inv_type)
               ;
          --
          INSERT
            INTO nm_pbi_query_attribs
                (nqa_npq_id
                ,nqa_nqt_seq_no
                ,nqa_seq_no
                ,nqa_attrib_name
                ,nqa_operator
                ,nqa_pre_bracket
                ,nqa_post_bracket
                ,nqa_condition)
          VALUES(lv_npq_id
                ,lv_nqt_id
                ,1
                ,'IIT_X_SECT'
                ,'AND'
                ,'('
                ,')'
                ,'=')
               ;
          --
          INSERT
            INTO nm_pbi_query_values
                (nqv_npq_id
                ,nqv_nqt_seq_no
                ,nqv_nqa_seq_no
                ,nqv_sequence
                ,nqv_value)
          VALUES(lv_npq_id
                ,lv_nqt_id
                ,1
                ,1
                ,'L')--dummy value will be overridden)
               ;
          COMMIT;
          --
          RETURN lv_npq_id;
          --
    END insert_pbi_query;
    /*
    ||copied from nem to merge the locations into a temp extent and remove overlaps.
    */
    FUNCTION create_temp_ne_from_locs(pi_ne_ids_tab    IN awlrs_util.ne_id_tab
                                     ,pi_begin_mps_tab IN awlrs_plm_api.location_from_offset_tab
                                     ,pi_end_mps_tab   IN awlrs_plm_api.location_to_offset_tab)
      RETURN NUMBER IS
      --
      lv_location_job_id  NUMBER;
      lv_combined_job_id  NUMBER;
      --
    BEGIN
      /*
      ||Make sure the attribute tables have the same number of records.
      */
      IF pi_ne_ids_tab.COUNT != pi_begin_mps_tab.COUNT
       OR pi_ne_ids_tab.COUNT != pi_end_mps_tab.COUNT
       THEN
          --The attribute tables passed in must have matching row counts
          hig.raise_ner(pi_appl               => 'AWLRS'
                       ,pi_id                 => 5);
      END IF;
      --
      FOR i IN 1..pi_ne_ids_tab.COUNT LOOP
        /*
        ||Loop through the locations and add them to the asset extent.
        */
        nm3extent.create_temp_ne(pi_source_id => pi_ne_ids_tab(i)
                                ,pi_source    => nm3extent.get_route
                                ,pi_begin_mp  => pi_begin_mps_tab(i)
                                ,pi_end_mp    => pi_end_mps_tab(i)
                                ,po_job_id    => lv_location_job_id);
        --
        IF lv_combined_job_id IS NULL
         THEN
            lv_combined_job_id := lv_location_job_id;
        ELSE
            nm3extent.combine_temp_nes(pi_job_id_1       => lv_combined_job_id
                                      ,pi_job_id_2       => lv_location_job_id
                                      ,pi_check_overlaps => FALSE);
        END IF;
        --
      END LOOP;
      /*
      ||Not sure what the problem is but if remove overlaps is not
      ||called TWICE here homo_update can raised an overlap error
      ||when the network being added overlaps the existing location(s):
      ||ORA-20519: NM_NW_TEMP_EXTENTS records with overlaps found
      */
      lv_combined_job_id := nm3extent.remove_overlaps(pi_nte_id => nm3extent.remove_overlaps(pi_nte_id => lv_combined_job_id));
      --
      RETURN lv_combined_job_id;
      --
    EXCEPTION
      WHEN others
       THEN
          RAISE;
    END create_temp_ne_from_locs;
    --
  BEGIN
    /*
    || Get NW and Group Types. PB TODO if not the same then error.
    */
    OPEN  get_nw_grp_type(pi_ne_ids(1));
    FETCH get_nw_grp_type
     INTO lv_nt_type, lv_grp_type;
    CLOSE get_nw_grp_type;
    --
    lt_plm_xsp_job.DELETE;
    /*
    ||Get or create PBI query informaition
    */
    lv_npq_id := insert_pbi_query;
    --
    FOR i in 1..pi_xsps.COUNT LOOP
      --
      lt_nte.DELETE;
      --
      IF pi_xsps(i) IS NOT NULL AND lv_npq_id IS NOT NULL
       THEN
          update_pbi_xsp_value(pi_npq_id => lv_npq_id
                              ,pi_xsp    => pi_xsps(i));
      END IF;
      /*
      ||create temp extent for the network sections and remove overlaps
      */
      lv_nwextent_id := create_temp_ne_from_locs(pi_ne_ids_tab    => pi_ne_ids
                                                ,pi_begin_mps_tab => pi_begin_mps
                                                ,pi_end_mps_tab   => pi_end_mps);
      /*
      ||Make a copy of temp extent after overlaps removed
      */
      lv_nwextent_id2:= nm3net.get_next_nte_id;
      --
      SELECT lv_nwextent_id2
            ,nte_ne_id_of
            ,nte_begin_mp
            ,nte_end_mp
            ,nte_cardinality
            ,nte_seq_no
            ,nte_route_ne_id
        BULK COLLECT
        INTO lt_nte
        FROM nm_nw_temp_extents
       WHERE nte_job_id = lv_nwextent_id
           ;
      /*
      ||PBI query to get sections where pcr records exist. PB TODO look at what we do in terms of pbi query
      */
      nm3pbi.execute_pbi_query(pi_query_id      => lv_npq_id
                              ,pi_nte_job_id    => lv_nwextent_id
                              ,pi_description   => 'awlrs_plm_api.get_construction_gaps'
                              ,po_result_job_id => lv_pbi_result_job_id);
      /*
      ||Turn into temp extent
      */
      nm3extent.create_temp_ne (pi_source_id => lv_pbi_result_job_id
                               ,pi_source    => 'PBI'
                               ,pi_begin_mp  => null
                               ,pi_end_mp    => null
                               ,po_job_id    => lv_pcrextent_id);
      /*
      ||Not sure why but the original temp extent is being removed so recreate here before doing minus.
      || this function is slow so make a copy prior to it being removed an insert back into temp extents.
      */
      FORALL i IN lt_nte.FIRST..lt_nte.LAST
        INSERT
          INTO nm_nw_temp_extents
        VALUES lt_nte(i)
             ;
      /*
      ||minus the temp extent of everything and the assets to give us the gaps.
      */
      nm3extent.nte_minus_nte(pi_nte_1      => lv_nwextent_id2
                             ,pi_nte_2      => lv_pcrextent_id
                             ,po_nte_result => lv_gapsextent_id);
      /*
      || add job and XSP for use in translation.
      */
      lt_plm_xsp_job.EXTEND;
      lt_plm_xsp_job(lt_plm_xsp_job.count) := nm_id_code_type(lv_gapsextent_id
                                                             ,pi_xsps(i));
      --
      po_xsp_job := lt_plm_xsp_job;
      --
    END LOOP;
    --
  END get_construction_gaps;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_gaps(pi_ne_ids             IN  awlrs_util.ne_id_tab
                                 ,pi_xsps               IN  xsp_tab
                                 ,pi_begin_mps          IN  location_from_offset_tab
                                 ,pi_end_mps            IN  location_to_offset_tab
                                 ,po_cursor             OUT sys_refcursor
                                 ,po_message_severity   OUT hig_codes.hco_code%TYPE
                                 ,po_message_cursor     OUT sys_refcursor)
    IS
    --
    lv_nt_type           nm_elements.ne_nt_type%TYPE;
    lv_grp_type          nm_elements.ne_gty_group_type%TYPE;
    --
    lt_plm_xsp_job  nm_id_code_tbl := nm_id_code_tbl();
    --
    CURSOR get_nw_grp_type(cp_ne_id IN nm_elements.ne_id%TYPE)
        IS
    SELECT ne_nt_type
          ,ne_gty_group_type
      FROM nm_elements
     WHERE ne_id = cp_ne_id;
    --
  BEGIN
    /*
    || Get NW and Group Types. PB TODO if not the same then error.
    */
    OPEN  get_nw_grp_type(pi_ne_ids(1));
    FETCH get_nw_grp_type
     INTO lv_nt_type, lv_grp_type;
    CLOSE get_nw_grp_type;
    --
    get_construction_gaps(pi_ne_ids             => pi_ne_ids
                         ,pi_xsps               => pi_xsps
                         ,pi_begin_mps          => pi_begin_mps
                         ,pi_end_mps            => pi_end_mps
                         ,po_xsp_job            => lt_plm_xsp_job);
    /*
    ||Use get_connected chunks to translate to network type that was passed in. to do.
    */
    /*
    ||pb added for datums, needs reviewing
    */
    IF lv_grp_type IS NULL
     THEN
        OPEN po_cursor FOR
        SELECT ne.ne_id             element_id
              ,CASE ne.ne_nt_type
                 WHEN 'ESU' THEN ne.ne_name_1
                 WHEN 'NSGN' THEN ne.ne_number
                 ELSE ne.ne_unique
               END                  ne_unique
              ,ne.ne_nt_type        element_type
              ,ne.ne_gty_group_type element_group_type
              ,ne.ne_type           ne_type
              ,nte.nte_begin_mp     element_begin_mp
              ,nte.nte_end_mp       element_end_mp
              ,nte.nte_job_id       job_id
              ,plm.code             xsp
         FROM (SELECT id
                     ,code
                 FROM TABLE(CAST(lt_plm_xsp_job AS nm_id_code_tbl))) plm
             ,nm_elements ne
             ,nm_nw_temp_extents nte
        WHERE nte_job_id = plm.id
          AND nte_ne_id_of = ne_id
          AND ne.ne_type = 'S'
        ORDER BY ne_id
             ,nte_job_id
            ;
    ELSE
        OPEN po_cursor FOR
        SELECT ne.ne_id
              ,CASE ne.ne_nt_type
                 WHEN 'ESU' THEN ne.ne_name_1
                 WHEN 'NSGN' THEN ne.ne_number
                 ELSE ne.ne_unique
               END ne_unique
              ,ne.ne_nt_type
              ,ne.ne_gty_group_type
              ,ne.ne_type
              ,locs.from_offset
              ,locs.to_offset
              ,locs.jobid
              ,locs.xsp
          FROM nm_units nu
              ,nm_types nt
              ,nm_admin_units_all nau
              ,nm_elements ne
              ,(SELECT pl.pl_ne_id ne_id
                      ,pl.pl_start from_offset
                      ,pl.pl_end   to_offset
                      ,rownum      ind
                      ,id jobid
                      ,code xsp
                  FROM (SELECT id
                              ,code
                          FROM TABLE(CAST(lt_plm_xsp_job AS nm_id_code_tbl))) plm
                       ,TABLE(nm3pla.get_connected_chunks(p_nte_job_id => plm.id
                                                         ,p_route_id   => NULL
                                                         ,p_obj_type   => lv_grp_type).npa_placement_array) pl) locs
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
              ,locs.jobid
              ,locs.xsp
         ORDER
            BY locs.ind
              ,locs.jobid
              ,locs.xsp
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
  END get_construction_gaps;
  --
  -----------------------------------------------------------------------------
  --
END awlrs_plm_api;
/