CREATE OR REPLACE PACKAGE BODY awlrs_plm_api 
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_plm_api.pkb-arc   1.0   May 31 2018 15:25:34   Peter.Bibby  $
  --       Module Name      : $Workfile:   awlrs_plm_api.pkb  $
  --       Date into PVCS   : $Date:   May 31 2018 15:25:34  $
  --       Date fetched Out : $Modtime:   May 31 2018 15:23:52  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_plm_api';
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
    SELECT NVL(MAX(IIT_POSITION),0) + 1
      INTO lv_retval
      FROM nm_inv_items
     WHERE iit_inv_type = lv_inv_type
       AND iit_foreign_key = pi_parent_primary_key
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
    CURSOR get_layers(cp_inv_type   IN nm_inv_types_all.nit_inv_type%TYPE
                     ,cp_parent_key IN nm_inv_items_all.iit_primary_key%TYPE)
        IS
    SELECT iit_ne_id
          ,ROWNUM new_position
      FROM nm_inv_items
     WHERE iit_inv_type = cp_inv_type
       AND iit_foreign_key = cp_parent_key
     ORDER
        BY iit_position
         ;
    --
    TYPE layer_tab IS TABLE OF get_layers%ROWTYPE;
    lt_layers  layer_tab;
    --
  BEGIN
    --
    OPEN  get_layers(lv_inv_type, pi_parent_primary_key);
    FETCH get_layers
     BULK COLLECT
     INTO lt_layers;
    CLOSE get_layers;
    --
    FORALL i IN 1..lt_layers.COUNT
    UPDATE nm_inv_items_all
       SET iit_position = lt_layers(i).new_position
     WHERE iit_ne_id = lt_layers(i).iit_ne_id
         ;
    --
  END resequence_layers;
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
  BEGIN
    --
    awlrs_asset_api.add_asset_location(pi_iit_ne_id        => pi_iit_ne_id
                                      ,pi_nit_inv_type     => pi_nit_inv_type
                                      ,pi_ne_id            => pi_ne_id
                                      ,pi_begin_mp         => pi_begin_mp
                                      ,pi_end_mp           => pi_end_mp
                                      ,pi_startdate        => pi_startdate
                                      ,pi_append_replace   => 'R'
                                      ,po_message_severity => po_message_severity
                                      ,po_message_cursor   => lv_message_cursor);
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
  PROCEDURE create_construction_records(pi_admin_unit               IN     nm_admin_units_all.nau_admin_unit%TYPE
                                       ,pi_description              IN     nm_inv_items_all.iit_descr%TYPE
                                       ,pi_start_date               IN     nm_inv_items_all.iit_start_date%TYPE
                                       ,pi_end_date                 IN     nm_inv_items_all.iit_end_date%TYPE
                                       ,pi_notes                    IN     nm_inv_items_all.iit_note%TYPE
                                       ,pi_attrib_names             IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_attrib_scrn_texts        IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_attrib_char_values       IN     awlrs_asset_api.attrib_value_tab
                                       ,pi_xsps                     IN     xsp_tab
                                       ,pi_ne_ids                   IN     iit_ne_id_tab
                                       ,pi_begin_mps                IN     location_from_offset_tab
                                       ,pi_end_mps                  IN     location_to_offset_tab
					                             ,pi_layer_attrib_idx         IN     iit_ne_id_tab											  
					                             ,pi_layer_attrib_names       IN     awlrs_asset_api.attrib_name_tab
                                       ,pi_layer_attrib_scrn_texts  IN     awlrs_asset_api.attrib_scrn_text_tab
                                       ,pi_layer_attrib_char_values IN     awlrs_asset_api.attrib_value_tab												  
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
    lv_message_cursor           sys_refcursor;	
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
                               ,pi_ne_id              => pi_ne_ids(j)
                               ,pi_begin_mp           => pi_begin_mps(j)
                               ,pi_end_mp             => pi_end_mps(j)
                               ,po_iit_ne_id          => lv_iit_ne_id
                               ,po_message_severity   => lv_severity
                               ,po_message_tab        => lt_messages);						   
	  	  --
	      IF lv_severity = awlrs_util.c_msg_cat_success
         THEN
           --
	  	     lt_iit_ne_ids(lt_iit_ne_ids.COUNT+1) := lv_iit_ne_id;
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
                add_layer(pi_parent_id          => lv_iit_ne_id
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
      IF lt_attrib_names(i) = 'IIT_POSITION'
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
          lt_attrib_names(pi_attrib_names.COUNT+1) := 'IIT_POSITION';
          lt_attrib_scrn_texts(pi_attrib_scrn_texts.COUNT+1) := nm3inv.get_attrib_scrn_text(pi_inv_type    => lv_layer_type
                                                                                           ,pi_attrib_name => 'IIT_POSITION');
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
    TYPE layer_tab IS TABLE OF nm_inv_items_all%ROWTYPE;
    lt_layers  layer_tab;
    --
    lt_messages  awlrs_message_tab := awlrs_message_tab();
    --
    CURSOR get_layers(cp_parent_id  IN nm_inv_items_all.iit_ne_id%TYPE
                     ,cp_layer_type IN nm_inv_types_all.nit_inv_type%TYPE)
        IS
    SELECT *
      FROM nm_inv_items
     WHERE iit_inv_type = cp_layer_type
       AND iit_foreign_key = (SELECT iit_primary_key
                                FROM nm_inv_items
                               WHERE iit_ne_id = cp_parent_id)
     ORDER
        BY iit_position
         ;
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
    OPEN  get_layers(pi_source_parent_id, lv_layer_type);
    FETCH get_layers
     BULK COLLECT
     INTO lt_layers;
    CLOSE get_layers;
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
    lv_cons_type               nm_inv_items_all.iit_inv_type%TYPE := get_cons_rec_type;
    lv_layer_type              nm_inv_items_all.iit_inv_type%TYPE := get_layer_type;
    lv_query_id                NUMBER;
    lv_new_cons_rec_extent_id  NUMBER;
    lv_replacement_extent_id   NUMBER;
    lv_iit_ne_id               nm_inv_items_all.iit_ne_id%TYPE;
    lv_severity                hig_codes.hco_code%TYPE := awlrs_util.c_msg_cat_success;
    lv_homo_warning_code       VARCHAR2(1000);
    lv_homo_warning_msg        VARCHAR2(1000);
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
    CURSOR get_layers(cp_parent_id  IN nm_inv_items_all.iit_ne_id%TYPE
                     ,cp_layer_type IN nm_inv_types_all.nit_inv_type%TYPE)
        IS
    SELECT *
      FROM nm_inv_items
     WHERE iit_inv_type = cp_layer_type
       AND iit_foreign_key = (SELECT iit_primary_key
                                FROM nm_inv_items
                               WHERE iit_ne_id = cp_parent_id)
     ORDER
        BY iit_position DESC
         ;
    --
    TYPE iit_tab IS TABLE OF nm_inv_items_all%ROWTYPE INDEX BY BINARY_INTEGER;
    lt_layers      iit_tab;
    lt_new_layers  iit_tab;
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
      OPEN  get_layers(lt_cons_recs(i).iit_ne_id, lv_layer_type);
      FETCH get_layers
       BULK COLLECT
       INTO lt_layers;
      CLOSE get_layers;
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
            lt_new_layers.DELETE;
            --
            FOR j IN 1..lt_layers.COUNT LOOP
              CASE
                WHEN lv_depth_to_remove = 0
                 THEN
                    /*
                    ||The depth removed has been processed so
                    ||just add the layer as it is.
                    */
                    lt_new_layers(lt_new_layers.COUNT+1) := lt_layers(j);
                    --
                WHEN lt_layers(j).iit_num_attrib16 <= lv_depth_to_remove
                 THEN
                    /*
                    ||The depth of the layer is less than the
                    ||depth still to be removed so do not add it.
                    */
                    lv_depth_to_remove := lv_depth_to_remove - lt_layers(j).iit_num_attrib16;
                    --
                WHEN lt_layers(j).iit_num_attrib16 > lv_depth_to_remove
                 THEN
                    /*
                    ||The depth of the layer is greater than the
                    ||depth still to be removed so add the layer
                    ||with a reduced depth.
                    */
                    lt_new_layers(lt_new_layers.COUNT+1) := lt_layers(j);
                    lt_new_layers(lt_new_layers.COUNT).iit_num_attrib16 := lt_new_layers(lt_new_layers.COUNT).iit_num_attrib16 - lv_depth_to_remove;
                    lv_depth_to_remove := 0;
              END CASE;
            END LOOP;
          END;
          /*
          ||Insert the new layers.
          */
          FOR j IN 1..lt_new_layers.COUNT LOOP
            --
            lt_new_layers(j).iit_ne_id := ne_id_seq.NEXTVAL;
            lt_new_layers(j).iit_primary_key := lt_new_layers(j).iit_ne_id;
            lt_new_layers(j).iit_foreign_key := lv_iit_ne_id;
            lt_new_layers(j).iit_start_date := TRUNC(pi_start_date);
            lt_new_layers(j).iit_x_sect := lt_cons_recs(i).iit_x_sect;
            --
            nm3ins.ins_iit(p_rec_iit => lt_new_layers(j));
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
  END replace_construction_records;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_construction_records(pi_iit_ne_ids IN  iit_ne_id_tab
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
    --
    --Not using the AWLRS asset one as may need to bring in alterate columns like detaled xsp.
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
    --
    --Not using the awlrs asset one as may need to bring in alternate columns like detaled xsp.
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
       WHERE iit.iit_ne_id IN(SELECT ne_id FROM TABLE(CAST(lt_ids AS nm_ne_id_array)))
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
    lv_parent_key      nm_inv_items_all.iit_primary_key%TYPE;
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
                                ,po_message_severity       => po_message_severity
                                ,po_message_cursor         => po_message_cursor);
  --
  END update_contruction_layer;
  --TO DO amend so can stop certain attributes coming out.
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
    --
  BEGIN
    --
    awlrs_asset_api.get_flex_attribs(pi_iit_ne_id        => pi_iit_ne_id
                                    ,pi_inv_type         => pi_inv_type
                                    ,pi_disp_derived     => pi_disp_derived
                                    ,pi_disp_inherited   => pi_disp_inherited
                                    ,po_message_severity => lv_severity
                                    ,po_message_cursor   => lv_message_cursor
                                    ,po_cursor           => lv_cursor);
    --
    po_message_severity := lv_severity;
    po_message_cursor := lv_message_cursor;
    po_cursor := lv_cursor;
    --
  END get_flex_attribs;
  --
END awlrs_plm_api;
/
