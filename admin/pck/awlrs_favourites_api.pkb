CREATE OR REPLACE PACKAGE BODY awlrs_favourites_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_favourites_api.pkb-arc   1.9   Aug 20 2020 11:34:06   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_favourites_api.pkb  $
  --       Date into PVCS   : $Date:   Aug 20 2020 11:34:06  $
  --       Date fetched Out : $Modtime:   Aug 20 2020 11:31:34  $
  --       Version          : $Revision:   1.9  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '$Revision:   1.9  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_favourites_api';
  --
  c_root_folder  CONSTANT VARCHAR2(10) := '_ROOT';
  --
  TYPE entities_checked_rec IS RECORD(entity_type      awlrs_fav_entity_types.afet_entity_type%TYPE
                                     ,entity_sub_type  awlrs_favourites_entities.afe_entity_sub_type%TYPE
                                     ,entity_id        awlrs_favourites_entities.afe_entity_id%TYPE
                                     ,has_children     BOOLEAN);
  TYPE entities_checked_tab IS TABLE OF entities_checked_rec INDEX BY BINARY_INTEGER;
  gt_entities_checked  entities_checked_tab;
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
  FUNCTION create_root_folder(pi_product IN awlrs_favourites_folders.aff_product%TYPE)
    RETURN awlrs_favourites_folders.aff_af_id%TYPE IS PRAGMA AUTONOMOUS_TRANSACTION;
    --
    lv_retval  awlrs_favourites_folders.aff_af_id%TYPE;
    --
  BEGIN
    --
    lv_retval := af_id_seq.nextval;
    --
    INSERT
      INTO awlrs_favourites_folders
          (aff_af_id
          ,aff_user_id
          ,aff_product
          ,aff_name
          ,aff_seq_no
          ,aff_default)
    VALUES(lv_retval
          ,sys_context('NM3CORE','USER_ID')
          ,pi_product
          ,pi_product||c_root_folder
          ,1
          ,'Y')
         ;
    --
    COMMIT;
    --
    RETURN lv_retval;
    --
  END create_root_folder;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_root_folder_id(pi_product IN awlrs_favourites_folders.aff_product%TYPE)
    RETURN awlrs_favourites_folders.aff_af_id%TYPE IS
    --
    lv_retval  awlrs_favourites_folders.aff_af_id%TYPE;
    --
    CURSOR get_folder(cp_product IN awlrs_favourites_folders.aff_product%TYPE
                     ,cp_name    IN awlrs_favourites_folders.aff_name%TYPE)
        IS
    SELECT aff_af_id
      FROM awlrs_favourites_folders
     WHERE aff_user_id = sys_context('NM3CORE','USER_ID')
       AND aff_product = cp_product
       AND aff_parent_af_id IS NULL
       AND aff_name = cp_name
         ;
    --
  BEGIN
    --
    OPEN  get_folder(pi_product
                    ,pi_product||c_root_folder);
    FETCH get_folder
     INTO lv_retval;
    CLOSE get_folder;
    --
    IF lv_retval IS NULL
     THEN
        lv_retval := create_root_folder(pi_product => pi_product);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_root_folder_id;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_next_seq_no_in_folder(pi_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    RETURN awlrs_favourites_folders.aff_seq_no%TYPE IS
    --
    lv_retval awlrs_favourites_folders.aff_seq_no%TYPE;
    --
  BEGIN
    --
    SELECT NVL(MAX(seq_no),0) + 1
      INTO lv_retval
      FROM (SELECT aff_seq_no seq_no
              FROM awlrs_favourites_folders
             WHERE aff_parent_af_id = pi_aff_af_id
            UNION ALL
            SELECT afe_seq_no seq_no
              FROM awlrs_favourites_entities
             WHERE afe_parent_af_id = pi_aff_af_id)
         ;
    --
    RETURN lv_retval;
    --
  END get_next_seq_no_in_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_parent_folder(pi_product      IN awlrs_favourites_folders.aff_product%TYPE
                               ,pi_parent_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    IS
    --
    lv_aff_af_id  awlrs_favourites_folders.aff_af_id%TYPE;
    --
    CURSOR get_parent(cp_product      IN awlrs_favourites_folders.aff_product%TYPE
                     ,cp_parent_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT aff_af_id
      FROM awlrs_favourites_folders
     WHERE aff_af_id = cp_parent_af_id
       AND aff_product = cp_product
         ;
    --
  BEGIN
    --
    OPEN  get_parent(pi_product
                    ,pi_parent_af_id);
    FETCH get_parent
     INTO lv_aff_af_id;
    CLOSE get_parent;
    --
    IF lv_aff_af_id IS NULL
     THEN
        /*
        ||Parameter value is invalid
        */
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 283
                     ,pi_supplementary_info => 'Parent Folder - Product: '||pi_product||' Id: '||pi_parent_af_id);
    END IF;
    --
  END check_parent_folder;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_entity(pi_afe_af_id IN awlrs_favourites_entities.afe_af_id%TYPE)
    RETURN awlrs_favourites_entities%ROWTYPE IS
    --
    lr_retval awlrs_favourites_entities%ROWTYPE;
    --
  BEGIN
    --
    SELECT *
      INTO lr_retval
      FROM awlrs_favourites_entities
     WHERE afe_af_id = pi_afe_af_id
         ;
    --
    RETURN lr_retval;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        hig.raise_ner(pi_appl               => nm3type.c_hig
                     ,pi_id                 => 67
                     ,pi_supplementary_info => 'awlrs_favourites_entities(afe_af_id) => '||pi_afe_af_id);
  END get_entity;
  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_item(pi_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    RETURN fav_item_rec IS
    --
    lr_retval fav_item_rec;
    --
    CURSOR get_item(cp_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT folder_or_entity
          ,id
          ,parent_id
          ,seq_no
          ,product
      FROM (SELECT 'FOLDER' folder_or_entity
                  ,aff_af_id id
                  ,aff_parent_af_id parent_id
                  ,aff_seq_no seq_no
                  ,aff_product product
              FROM awlrs_favourites_folders
             WHERE aff_af_id = cp_af_id
            UNION ALL
            SELECT 'ENTITY' folder_or_entity
                  ,afe_af_id id
                  ,afe_parent_af_id parent_id
                  ,afe_seq_no seq_no
                  ,NULL product
              FROM awlrs_favourites_entities
             WHERE afe_af_id = cp_af_id)
         ;
  BEGIN
    /*
    ||Get the details of the folder or entity.
    */
    OPEN  get_item(pi_af_id);
    FETCH get_item
     INTO lr_retval;
    --
    IF get_item%NOTFOUND
     THEN
        --
        CLOSE get_item;
        /*
        ||Parameter value is invalid
        */
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 283
                     ,pi_supplementary_info => 'Folder - Id: '||pi_af_id);
        --
    END IF;
    --
    CLOSE get_item;
    --
    RETURN lr_retval;
    --
  END get_item;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_item_seq_within_folder(pi_af_id      IN awlrs_favourites_folders.aff_af_id%TYPE
                                      ,pi_new_seq_no IN awlrs_favourites_folders.aff_seq_no%TYPE)
    IS
    --
    lv_target_seq_no  awlrs_favourites_folders.aff_seq_no%TYPE;
    lv_new_seq_no     awlrs_favourites_folders.aff_seq_no%TYPE := 1;
    --
    lr_item  fav_item_rec;
    --
    CURSOR get_other_items(cp_parent_id IN awlrs_favourites_folders.aff_parent_af_id%TYPE
                          ,cp_af_id     IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT folder_or_entity
          ,af_id
          ,rownum row_no
      FROM (SELECT 'ENTITY' folder_or_entity
                  ,afe_af_id af_id
                  ,afe_seq_no seq_no
              FROM awlrs_favourites_entities
             WHERE afe_parent_af_id = cp_parent_id
            UNION ALL
            SELECT 'FOLDER' folder_or_entity
                  ,aff_af_id af_id
                  ,aff_seq_no seq_no
              FROM awlrs_favourites_folders
             WHERE aff_parent_af_id = cp_parent_id
             ORDER
                BY seq_no)
    WHERE af_id != cp_af_id
         ;
    --
    TYPE other_items_tab IS TABLE OF get_other_items%ROWTYPE;
    lt_other_items  other_items_tab;
    --
    TYPE items_rec IS RECORD(af_id  awlrs_favourites_folders.aff_af_id%TYPE
                            ,seq_no awlrs_favourites_folders.aff_seq_no%TYPE);
    TYPE items_tab IS TABLE OF items_rec INDEX BY BINARY_INTEGER;
    lt_entities  items_tab;
    lt_folders   items_tab;
    --
  BEGIN
    /*
    ||Get the details of the folder or entity.
    */
    lr_item := get_item(pi_af_id => pi_af_id);
    /*
    ||Get the children of the parent folder.
    */
    OPEN  get_other_items(lr_item.parent_id
                         ,pi_af_id);
    FETCH get_other_items
     BULK COLLECT
     INTO lt_other_items;
    CLOSE get_other_items;
    /*
    ||Set the target sequence number.
    */
    CASE
      WHEN pi_new_seq_no < 1
       THEN
          /*
          ||Move to first.
          */
          lv_target_seq_no := 1;
          --
      WHEN pi_new_seq_no > lt_other_items.COUNT
       THEN
          /*
          ||Move to last.
          */
          lv_target_seq_no := lt_other_items.COUNT+1;
          --
      ELSE
          /*
          ||Move somewhere between the first and last items.
          */
          lv_target_seq_no := pi_new_seq_no;
          --
    END CASE;
    /*
    ||Add the item with the new seq no.
    */
    IF lr_item.folder_or_entity = 'ENTITY'
     THEN
        lt_entities(lt_entities.COUNT+1).af_id := pi_af_id;
        lt_entities(lt_entities.COUNT).seq_no := lv_target_seq_no;
    ELSE
        lt_folders(lt_folders.COUNT+1).af_id := pi_af_id;
        lt_folders(lt_folders.COUNT).seq_no := lv_target_seq_no;
    END IF;
    /*
    ||Add the other items with adjusted seq_no.
    */
    FOR i IN 1..lt_other_items.COUNT LOOP
      --
      IF lt_other_items(i).row_no < lv_target_seq_no
       THEN
          lv_new_seq_no := lt_other_items(i).row_no;
      ELSE
          lv_new_seq_no := lt_other_items(i).row_no + 1;
      END IF;
      --
      IF lt_other_items(i).folder_or_entity = 'ENTITY'
       THEN
          lt_entities(lt_entities.COUNT+1).af_id := lt_other_items(i).af_id;
          lt_entities(lt_entities.COUNT).seq_no := lv_new_seq_no;
      ELSE
          lt_folders(lt_folders.COUNT+1).af_id := lt_other_items(i).af_id;
          lt_folders(lt_folders.COUNT).seq_no := lv_new_seq_no;
      END IF;
      --
    END LOOP;
    /*
    ||Update the sequence numbers.
    */
    FORALL i IN 1..lt_entities.COUNT
    UPDATE awlrs_favourites_entities
       SET afe_seq_no = lt_entities(i).seq_no
     WHERE afe_af_id = lt_entities(i).af_id
         ;
    --
    FORALL i IN 1..lt_folders.COUNT
    UPDATE awlrs_favourites_folders
       SET aff_seq_no = lt_folders(i).seq_no
     WHERE aff_af_id = lt_folders(i).af_id
         ;
    --
  END set_item_seq_within_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_item_seq_within_folder(pi_af_id            IN  awlrs_favourites_folders.aff_af_id%TYPE
                                      ,pi_new_seq_no       IN  awlrs_favourites_folders.aff_seq_no%TYPE
                                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    set_item_seq_within_folder(pi_af_id      => pi_af_id
                              ,pi_new_seq_no => pi_new_seq_no);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_item_seq_within_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_item_seq_within_folder(pi_af_id             IN  awlrs_favourites_folders.aff_af_id%TYPE
                                      ,pi_relative_position IN  awlrs_favourites_folders.aff_seq_no%TYPE
                                      ,po_message_severity  OUT hig_codes.hco_code%TYPE
                                      ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lv_seq_no  awlrs_favourites_folders.aff_seq_no%TYPE;
    --
    CURSOR get_current_seq(cp_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT seq_no
      FROM (SELECT aff_seq_no seq_no
              FROM awlrs_favourites_folders
             WHERE aff_af_id = cp_af_id
            UNION ALL
            SELECT afe_seq_no seq_no
              FROM awlrs_favourites_entities
             WHERE afe_af_id = cp_af_id)
         ;
    --
  BEGIN
    /*
    ||Get the details of the folder or entity.
    */
    OPEN  get_current_seq(pi_af_id);
    FETCH get_current_seq
     INTO lv_seq_no;
    --
    IF get_current_seq%NOTFOUND
     THEN
        --
        CLOSE get_current_seq;
        /*
        ||Parameter value is invalid
        */
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 283
                     ,pi_supplementary_info => 'Folder - Id: '||pi_af_id);
        --
    END IF;
    --
    CLOSE get_current_seq;
    /*
    ||Get the children of the parent folder.
    */
    set_item_seq_within_folder(pi_af_id      => pi_af_id
                              ,pi_new_seq_no => lv_seq_no + pi_relative_position);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_item_seq_within_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE resequence_folder(pi_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    IS
    --
    CURSOR get_items(cp_parent_id IN awlrs_favourites_folders.aff_parent_af_id%TYPE)
        IS
    SELECT folder_or_entity
          ,af_id
          ,rownum row_no
      FROM (SELECT 'ENTITY' folder_or_entity
                  ,afe_af_id af_id
                  ,afe_seq_no seq_no
              FROM awlrs_favourites_entities
             WHERE afe_parent_af_id = cp_parent_id
            UNION ALL
            SELECT 'FOLDER' folder_or_entity
                  ,aff_af_id af_id
                  ,aff_seq_no seq_no
              FROM awlrs_favourites_folders
             WHERE aff_parent_af_id = cp_parent_id
             ORDER
                BY seq_no)
         ;
    --
    TYPE get_items_tab IS TABLE OF get_items%ROWTYPE;
    lt_items  get_items_tab;
    --
    TYPE items_rec IS RECORD(af_id  awlrs_favourites_folders.aff_af_id%TYPE
                            ,seq_no awlrs_favourites_folders.aff_seq_no%TYPE);
    TYPE items_tab IS TABLE OF items_rec INDEX BY BINARY_INTEGER;
    lt_entities  items_tab;
    lt_folders   items_tab;
    --
  BEGIN
    /*
    ||Get the folders children.
    */
    OPEN  get_items(pi_aff_af_id);
    FETCH get_items
     BULK COLLECT
     INTO lt_items;
    CLOSE get_items;
    /*
    ||Resequence the children to remove any gaps.
    */
    FOR i IN 1..lt_items.COUNT LOOP
      --
      IF lt_items(i).folder_or_entity = 'ENTITY'
       THEN
          lt_entities(lt_entities.COUNT+1).af_id := lt_items(i).af_id;
          lt_entities(lt_entities.COUNT).seq_no := lt_items(i).row_no;
      ELSE
          lt_folders(lt_folders.COUNT+1).af_id := lt_items(i).af_id;
          lt_folders(lt_folders.COUNT).seq_no := lt_items(i).row_no;
      END IF;
      --
    END LOOP;
    --
    FORALL i IN 1..lt_entities.COUNT
    UPDATE awlrs_favourites_entities
       SET afe_seq_no = lt_entities(i).seq_no
     WHERE afe_af_id = lt_entities(i).af_id
         ;
    --
    FORALL i IN 1..lt_folders.COUNT
    UPDATE awlrs_favourites_folders
       SET aff_seq_no = lt_folders(i).seq_no
     WHERE aff_af_id = lt_folders(i).af_id
         ;
    --
  END resequence_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE move_item_to_folder(pi_af_id            IN awlrs_favourites_folders.aff_af_id%TYPE
                               ,pi_new_parent_af_id IN awlrs_favourites_folders.aff_parent_af_id%TYPE
                               ,pi_new_seq_no       IN awlrs_favourites_folders.aff_seq_no%TYPE)
    IS
    --
    lv_check  awlrs_favourites_folders.aff_af_id%TYPE;
    --
    lr_item        fav_item_rec;
    lr_old_parent  fav_item_rec;
    --
    CURSOR check_children(cp_af_id      IN awlrs_favourites_folders.aff_af_id%TYPE
                         ,cp_new_parent IN awlrs_favourites_folders.aff_parent_af_id%TYPE)
        IS
    SELECT aff_af_id
      FROM awlrs_favourites_folders
     WHERE aff_af_id = cp_new_parent
   CONNECT BY PRIOR aff_af_id = aff_parent_af_id
     START WITH aff_af_id = cp_af_id
         ;
    --
  BEGIN
    /*
    ||Get the item details.
    */
    lr_item := get_item(pi_af_id => pi_af_id);
    /*
    ||Make sure the folder is not being moved
    ||to a child of itself.
    */
    OPEN  check_children(pi_af_id
                        ,pi_new_parent_af_id);
    FETCH check_children
     INTO lv_check;
    IF check_children%FOUND
     THEN
        CLOSE check_children;
        --Cannot move folder to a child of itself.
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 90);
    END IF;
    CLOSE check_children;
    /*
    ||Check the new parent id exists and belongs to the same product.
    */
    lr_old_parent := get_item(pi_af_id => lr_item.parent_id);
    check_parent_folder(pi_product      => lr_old_parent.folder_product
                       ,pi_parent_af_id => pi_new_parent_af_id);
    /*
    ||Move the item to the new folder.
    */
    IF lr_item.folder_or_entity = 'ENTITY'
     THEN
        --
        UPDATE awlrs_favourites_entities
           SET afe_parent_af_id = pi_new_parent_af_id
         WHERE afe_af_id = pi_af_id
             ;
        --
    ELSE
        --
        UPDATE awlrs_favourites_folders
           SET aff_parent_af_id = pi_new_parent_af_id
         WHERE aff_af_id = pi_af_id
             ;
        --
    END IF;
    /*
    ||Set the sequence within the new folder.
    */
    set_item_seq_within_folder(pi_af_id      => pi_af_id
                              ,pi_new_seq_no => pi_new_seq_no);
    /*
    ||Resequence the old folder.
    */
    resequence_folder(pi_aff_af_id => lr_item.parent_id);
    --
  END move_item_to_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE move_item_to_folder(pi_af_id            IN  awlrs_favourites_folders.aff_af_id%TYPE
                               ,pi_new_parent_af_id IN  awlrs_favourites_folders.aff_parent_af_id%TYPE
                               ,pi_new_seq_no       IN  awlrs_favourites_folders.aff_seq_no%TYPE DEFAULT 1
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    move_item_to_folder(pi_af_id            => pi_af_id
                       ,pi_new_parent_af_id => pi_new_parent_af_id
                       ,pi_new_seq_no       => NVL(pi_new_seq_no,1));
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END move_item_to_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_item(pi_af_id            IN  awlrs_favourites_folders.aff_af_id%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_item  fav_item_rec;
    --
  BEGIN
    /*
    ||Get the details of the folder or entity.
    */
    lr_item := get_item(pi_af_id => pi_af_id);
    /*
    ||Delete the record.
    */
    IF lr_item.folder_or_entity = 'ENTITY'
     THEN
        --
        DELETE
          FROM awlrs_favourites_entities
         WHERE afe_af_id = pi_af_id
             ;
        --
    ELSE
        --
        DELETE
          FROM awlrs_favourites_folders
         WHERE aff_af_id = pi_af_id
             ;
        --
    END IF;
    /*
    ||Resequence the remaining children of the Parent folder.
    */
    resequence_folder(pi_aff_af_id => lr_item.parent_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_item;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_folder_default(pi_product   IN awlrs_favourites_folders.aff_product%TYPE
                              ,pi_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    IS
    --
  BEGIN
    /*
    ||Update the current default folder.
    */
    UPDATE awlrs_favourites_folders
       SET aff_default = 'N'
     WHERE aff_user_id = sys_context('NM3CORE','USER_ID')
       AND aff_product = pi_product
       AND aff_default = 'Y'
       AND aff_af_id != pi_aff_af_id
         ;
    /*
    ||Update the new default folder.
    */
    UPDATE awlrs_favourites_folders
       SET aff_default = 'Y'
     WHERE aff_user_id = sys_context('NM3CORE','USER_ID')
       AND aff_product = pi_product
       AND aff_af_id = pi_aff_af_id
       AND aff_default = 'N'
         ;
    --
  END set_folder_default;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE set_folder_default(pi_product          IN  awlrs_favourites_folders.aff_product%TYPE
                              ,pi_aff_af_id        IN  awlrs_favourites_folders.aff_af_id%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    set_folder_default(pi_product   => pi_product
                      ,pi_aff_af_id => pi_aff_af_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END set_folder_default;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_folder(pi_product          IN     awlrs_favourites_folders.aff_product%TYPE
                      ,pi_parent_af_id     IN     awlrs_favourites_folders.aff_parent_af_id%TYPE
                      ,pi_name             IN     awlrs_favourites_folders.aff_name%TYPE
                      ,pi_default          IN     awlrs_favourites_folders.aff_default%TYPE DEFAULT 'N'
                      ,po_aff_af_id        IN OUT awlrs_favourites_folders.aff_af_id%TYPE
                      ,po_message_severity    OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor      OUT sys_refcursor)
    IS
    --
    lv_aff_af_id     awlrs_favourites_folders.aff_af_id%TYPE;
    lv_parent_af_id  awlrs_favourites_folders.aff_parent_af_id%TYPE;
    lv_seq_no        awlrs_favourites_folders.aff_seq_no%TYPE;
    --
    CURSOR chk_fav(cp_product      IN awlrs_favourites_folders.aff_product%TYPE
                  ,cp_parent_af_id IN awlrs_favourites_folders.aff_parent_af_id%TYPE
                  ,cp_name         IN awlrs_favourites_folders.aff_name%TYPE)
        IS
    SELECT aff_af_id
      FROM awlrs_favourites_folders
     WHERE aff_user_id = sys_context('NM3CORE','USER_ID')
       AND aff_product = cp_product
       AND aff_parent_af_id = cp_parent_af_id
       AND aff_name = cp_name
         ;
    --
  BEGIN
    /*
    ||Validate the parameters.
    */
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Product'
                               ,pi_parameter_value => pi_product);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Name'
                               ,pi_parameter_value => pi_name);
    --
    awlrs_util.validate_yn(pi_parameter_desc  => 'Default'
                          ,pi_parameter_value => pi_default);
    /*
    ||If no parent id supplied add to the root folder, otherwise
    ||make sure the given parent folder exists.
    */
    IF pi_parent_af_id IS NULL
     THEN
        lv_parent_af_id := get_root_folder_id(pi_product => pi_product);
    ELSE
        check_parent_folder(pi_product      => pi_product
                           ,pi_parent_af_id => pi_parent_af_id);
        lv_parent_af_id := pi_parent_af_id;
    END IF;
    /*
    ||Check to see if a folder with the same name already exists in the parent folder.
    */
    OPEN  chk_fav(pi_product
                 ,lv_parent_af_id
                 ,pi_name);
    FETCH chk_fav
     INTO lv_aff_af_id;
    CLOSE chk_fav;
    /*
    ||If a folder with the given name does not exist within the parent folder create it.
    */
    IF lv_aff_af_id IS NULL
     THEN
        --
        lv_seq_no := get_next_seq_no_in_folder(pi_aff_af_id => lv_parent_af_id);
        lv_aff_af_id := af_id_seq.nextval;
        --
        INSERT
          INTO awlrs_favourites_folders
              (aff_af_id
              ,aff_parent_af_id
              ,aff_user_id
              ,aff_product
              ,aff_name
              ,aff_seq_no
              ,aff_default)
        VALUES(lv_aff_af_id
              ,lv_parent_af_id
              ,sys_context('NM3CORE','USER_ID')
              ,pi_product
              ,pi_name
              ,lv_seq_no
              ,pi_default)
             ;
        --
    END IF;
    --
    IF pi_default = 'Y'
     THEN
        --
        set_folder_default(pi_product   => pi_product
                          ,pi_aff_af_id => lv_aff_af_id);
        --
    END IF;
    --
    po_aff_af_id := lv_aff_af_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE rename_folder(pi_aff_af_id        IN  awlrs_favourites_folders.aff_parent_af_id%TYPE
                         ,pi_new_name         IN  awlrs_favourites_folders.aff_name%TYPE
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_aff_af_id     awlrs_favourites_folders.aff_af_id%TYPE;
    lv_parent_af_id  awlrs_favourites_folders.aff_parent_af_id%TYPE;
    --
    CURSOR get_parent_id(cp_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT aff_parent_af_id
      FROM awlrs_favourites_folders
     WHERE aff_af_id = cp_aff_af_id
         ;
    --
    CURSOR chk_name(cp_parent_af_id IN awlrs_favourites_folders.aff_parent_af_id%TYPE
                   ,cp_name         IN awlrs_favourites_folders.aff_name%TYPE)
        IS
    SELECT aff_af_id
      FROM awlrs_favourites_folders
     WHERE aff_parent_af_id = cp_parent_af_id
       AND aff_name = cp_name
         ;
    --
  BEGIN
    /*
    ||Validate the parameters.
    */
    awlrs_util.validate_notnull(pi_parameter_desc  => 'New Name'
                               ,pi_parameter_value => pi_new_name);
    /*
    ||Get the parent id.
    */
    OPEN  get_parent_id(pi_aff_af_id);
    FETCH get_parent_id
     INTO lv_parent_af_id;
    --
    IF get_parent_id%NOTFOUND
     THEN
        --
        CLOSE get_parent_id;
        /*
        ||Parameter value is invalid
        */
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 283
                     ,pi_supplementary_info => ' Folder - Id: '||pi_aff_af_id);
        --
    END IF;
    --
    CLOSE get_parent_id;
    --
    IF lv_parent_af_id IS NULL
     THEN
        /*
        ||Cannot rename folder
        */
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 88
                     ,pi_supplementary_info => NVL(hig.get_user_or_sys_opt('AWLFAVNAME'),'Favorites'));
    END IF;
    /*
    ||Check to see if a folder with the same name already exists in the parent folder.
    */
    OPEN  chk_name(lv_parent_af_id
                  ,pi_new_name);
    FETCH chk_name
     INTO lv_aff_af_id;
    CLOSE chk_name;
    /*
    ||If a folder with the given name does not exist within the parent folder create it.
    */
    IF lv_aff_af_id IS NULL
     THEN
        --
        UPDATE awlrs_favourites_folders
           SET aff_name = pi_new_name
         WHERE aff_af_id = pi_aff_af_id
             ;
        --
    ELSE
        /*
        ||Parent folder already contains a folder with this name.
        */
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 89);
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
  END rename_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_table_record(pi_table_name IN user_tab_cols.table_name%TYPE
                              ,pi_pk_column  IN user_tab_cols.column_name%TYPE
                              ,pi_pk_value   IN awlrs_favourites_entities.afe_entity_id%TYPE)
    IS
    --
    lv_pk_value    awlrs_favourites_entities.afe_entity_id%TYPE;
    --
  BEGIN
    /*
    ||Validate the table and column names passed in.
    ||This will only validate that the supplied values
    ||are valid sql names not that the table or column
    ||actually exist so the query may raise an error.
    */
    awlrs_util.validate_simple_sql_name(pi_name               => pi_table_name
                                       ,pi_supplementary_info => 'pi_table_name');
    --
    awlrs_util.validate_simple_sql_name(pi_name               => pi_pk_column
                                       ,pi_supplementary_info => 'pi_pk_column');
    --
    EXECUTE IMMEDIATE 'SELECT '||pi_pk_column
                     ||' FROM '||pi_table_name
                    ||' WHERE '||pi_pk_column||' = :value'
      INTO lv_pk_value
      USING pi_pk_value
    ;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        hig.raise_ner(pi_appl               => nm3type.c_hig
                     ,pi_id                 => 67
                     ,pi_supplementary_info => pi_table_name||'('||pi_pk_column||')'||CHR(10)||pi_pk_column||' => '||pi_pk_value);
  END check_table_record;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE check_entity(pi_entity_type     IN awlrs_favourites_entities.afe_entity_type%TYPE
                        ,pi_entity_sub_type IN awlrs_favourites_entities.afe_entity_sub_type%TYPE
                        ,pi_entity_id       IN awlrs_favourites_entities.afe_entity_id%TYPE)
    IS
    --
    lr_ne    nm_elements_all%ROWTYPE;
    lr_nit   nm_inv_types_all%ROWTYPE;
    lr_iit   nm_inv_items_all%ROWTYPE;
    lr_afet  awlrs_fav_entity_types%ROWTYPE;
    --
    CURSOR get_afet(cp_entity_type IN awlrs_fav_entity_types.afet_entity_type%TYPE)
        IS
    SELECT *
      FROM awlrs_fav_entity_types
     WHERE afet_entity_type = cp_entity_type
         ;
  BEGIN
    /*
    ||Get the Entity Type
    */
    OPEN  get_afet(pi_entity_type);
    FETCH get_afet
     INTO lr_afet;
    CLOSE get_afet;
    --
    IF lr_afet.afet_entity_type IS NULL
     THEN
        /*
        ||Unsupported Entity Type.
        */
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 87
                     ,pi_supplementary_info => pi_entity_type);
        --
    END IF;
    /*
    ||Check for the existence of the entity.
    */
    CASE lr_afet.afet_entity_type
     WHEN 'NETWORK'
      THEN
         --
         lr_ne := nm3get.get_ne_all(pi_ne_id => pi_entity_id);
         --
         IF lr_ne.ne_nt_type != pi_entity_sub_type
          THEN
             --
             hig.raise_ner(pi_appl               => nm3type.c_hig
                          ,pi_id                 => 67
                          ,pi_supplementary_info => 'nm_elements_all (NE_PK)'||CHR(10)||'ne_id => '||pi_entity_id||CHR(10)||'ne_nt_type => '||pi_entity_sub_type);
             --
         END IF;
         --
     WHEN 'ASSET'
      THEN
         --
         lr_nit := nm3get.get_nit_all(pi_nit_inv_type => pi_entity_sub_type);
         --
         IF lr_nit.nit_table_name IS NULL
          THEN
             --
             lr_iit := nm3get.get_iit_all(pi_iit_ne_id => pi_entity_id);
             --
             IF lr_iit.iit_inv_type != lr_nit.nit_inv_type
              THEN
                 --
                 hig.raise_ner(pi_appl               => nm3type.c_hig
                              ,pi_id                 => 67
                              ,pi_supplementary_info => 'nm_inv_items_all (INV_ITEMS_ALL_PK)'||CHR(10)||'iit_ne_id => '||pi_entity_id);
                 --
             END IF;
             --
         ELSE
             --
             check_table_record(pi_table_name => lr_nit.nit_table_name
                               ,pi_pk_column  => lr_nit.nit_foreign_pk_column
                               ,pi_pk_value   => pi_entity_id);
             --
         END IF;
         --
     ELSE
         --
         check_table_record(pi_table_name => lr_afet.afet_table_name
                           ,pi_pk_column  => lr_afet.afet_pk_column
                           ,pi_pk_value   => pi_entity_id);
         --
    END CASE;
    --
  END check_entity;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE add_entity(pi_product          IN     awlrs_favourites_folders.aff_product%TYPE
                      ,pi_parent_af_id     IN     awlrs_favourites_folders.aff_af_id%TYPE
                      ,pi_entity_type      IN     awlrs_favourites_entities.afe_entity_type%TYPE
                      ,pi_entity_sub_type  IN     awlrs_favourites_entities.afe_entity_sub_type%TYPE
                      ,pi_entity_id        IN     awlrs_favourites_entities.afe_entity_id%TYPE
                      ,po_afe_af_id        IN OUT awlrs_favourites_entities.afe_af_id%TYPE
                      ,po_message_severity    OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor      OUT sys_refcursor)
    IS
    --
    lv_afe_af_id     awlrs_favourites_folders.aff_af_id%TYPE;
    lv_parent_af_id  awlrs_favourites_folders.aff_parent_af_id%TYPE;
    lv_seq_no        awlrs_favourites_folders.aff_seq_no%TYPE;
    --
    CURSOR chk_fav(cp_parent_af_id    IN awlrs_favourites_folders.aff_af_id%TYPE
                  ,cp_entity_type     IN awlrs_favourites_entities.afe_entity_type%TYPE
                  ,cp_entity_sub_type IN awlrs_favourites_entities.afe_entity_sub_type%TYPE
                  ,cp_entity_id       IN awlrs_favourites_entities.afe_entity_id%TYPE)
        IS
    SELECT afe_af_id
      FROM awlrs_favourites_entities
     WHERE afe_parent_af_id = cp_parent_af_id
       AND afe_entity_type = cp_entity_type
       AND NVL(afe_entity_sub_type,'~~~~~') = NVL(cp_entity_sub_type,'~~~~~')
       AND afe_entity_id = cp_entity_id
         ;
    --
  BEGIN
    /*
    ||Validate the parameters.
    */
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Product'
                               ,pi_parameter_value => pi_product);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Entity Type'
                               ,pi_parameter_value => pi_entity_type);
    --
    awlrs_util.validate_notnull(pi_parameter_desc  => 'Entity Id'
                               ,pi_parameter_value => pi_entity_id);
    IF pi_entity_type IN('NETWORK','ASSET')
     THEN
        awlrs_util.validate_notnull(pi_parameter_desc  => 'Entity Sub Type'
                                   ,pi_parameter_value => pi_entity_sub_type);
    END IF;
    /*
    ||If no parent id supplied add to the root folder, otherwise
    ||make sure the given parent folder exists.
    */
    IF pi_parent_af_id IS NULL
     THEN
        lv_parent_af_id := get_root_folder_id(pi_product => pi_product);
    ELSE
        check_parent_folder(pi_product      => pi_product
                           ,pi_parent_af_id => pi_parent_af_id);
        lv_parent_af_id := pi_parent_af_id;
    END IF;
    /*
    ||Check the Entity exists.
    */
    check_entity(pi_entity_type     => pi_entity_type
                ,pi_entity_sub_type => pi_entity_sub_type
                ,pi_entity_id       => pi_entity_id);
    /*
    ||Check to see if the Entity already exists in the folder.
    */
    OPEN  chk_fav(lv_parent_af_id
                 ,pi_entity_type
                 ,pi_entity_sub_type
                 ,pi_entity_id);
    FETCH chk_fav
     INTO lv_afe_af_id;
    CLOSE chk_fav;
    /*
    ||If the Entity does not exist in the folder add it.
    */
    IF lv_afe_af_id IS NULL
     THEN
        --
        lv_seq_no := get_next_seq_no_in_folder(pi_aff_af_id => lv_parent_af_id);
        lv_afe_af_id := af_id_seq.nextval;
        --
        INSERT
          INTO awlrs_favourites_entities
              (afe_af_id
              ,afe_parent_af_id
              ,afe_seq_no
              ,afe_entity_type
              ,afe_entity_sub_type
              ,afe_entity_id)
        SELECT lv_afe_af_id
              ,lv_parent_af_id
              ,lv_seq_no
              ,pi_entity_type
              ,pi_entity_sub_type
              ,pi_entity_id
          FROM dual
         WHERE NOT EXISTS(SELECT 1
                            FROM awlrs_favourites_entities
                           WHERE afe_parent_af_id = lv_parent_af_id
                             AND afe_entity_type = pi_entity_type
                             AND NVL(afe_entity_sub_type,'~~~~~') = NVL(pi_entity_sub_type,'~~~~~')
                             AND afe_entity_id = pi_entity_id)
             ;
    END IF;
    --
    po_afe_af_id:= lv_afe_af_id;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END add_entity;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_child_folder_count(pi_parent_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    RETURN PLS_INTEGER IS
    --
    lv_retval  PLS_INTEGER;
    --
  BEGIN
    --
    SELECT COUNT(*)
      INTO lv_retval
      FROM awlrs_favourites_folders
     WHERE aff_parent_af_id = pi_parent_af_id
         ;
    --
    RETURN lv_retval;
    --
  END get_child_folder_count;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_child_entity_count(pi_parent_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    RETURN PLS_INTEGER IS
    --
    lv_retval  PLS_INTEGER;
    --
  BEGIN
    --
    SELECT COUNT(*)
      INTO lv_retval
      FROM awlrs_favourites_entities
     WHERE afe_parent_af_id = pi_parent_af_id
         ;
    --
    RETURN lv_retval;
    --
  END get_child_entity_count;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_entity_label_sql(pi_table_name IN user_tab_cols.table_name%TYPE
                               ,pi_pk_column  IN user_tab_cols.column_name%TYPE
                               ,pi_pk_val_col IN user_tab_cols.column_name%TYPE DEFAULT NULL
                               ,pi_label_cols IN afetl_tab)
    RETURN VARCHAR2 IS
    --
    lv_sql         nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||Validate the table and column names passed in.
    ||This will only validate that the supplied values
    ||are valid sql names not that the table or column
    ||actually exist so the query may raise an error.
    */
    awlrs_util.validate_simple_sql_name(pi_name               => pi_table_name
                                       ,pi_supplementary_info => 'pi_table_name');
    --
    awlrs_util.validate_simple_sql_name(pi_name               => pi_pk_column
                                       ,pi_supplementary_info => 'pi_pk_column');
    --
    lv_sql := 'SELECT ';
    --
    IF pi_table_name = 'NM_ELEMENTS_ALL'
     THEN
        lv_sql := lv_sql||' NVL(ne_gty_group_type,ne_nt_type)||'' : ''||';
    END IF;
    --
    FOR i IN 1..pi_label_cols.COUNT LOOP
      --
      awlrs_util.validate_simple_sql_name(pi_name               => pi_label_cols(i).afetl_label_column
                                         ,pi_supplementary_info => 'label column');
      --
      lv_sql := lv_sql||pi_label_cols(i).afetl_label_column||CASE WHEN i = pi_label_cols.COUNT THEN NULL ELSE '||'' '||pi_label_cols(i).afetl_label_separator||' ''||' END;
      --
    END LOOP;
    --
    lv_sql := lv_sql||' FROM '||pi_table_name
                   ||' WHERE '||pi_pk_column||' = '||NVL(pi_pk_val_col,':value')
    ;
    --
    RETURN lv_sql;
    --
  END get_entity_label_sql;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_entity_label(pi_table_name IN user_tab_cols.table_name%TYPE
                           ,pi_pk_column  IN user_tab_cols.column_name%TYPE
                           ,pi_pk_value   IN awlrs_favourites_entities.afe_entity_id%TYPE
                           ,pi_label_cols IN afetl_tab)
    RETURN VARCHAR2 IS
    --
    lv_sql         nm3type.max_varchar2;
    lv_retval      nm3type.max_varchar2;
    --
  BEGIN
    /*
    ||Get the SQL to execute.
    */
    lv_sql := get_entity_label_sql(pi_table_name => pi_table_name
                                  ,pi_pk_column  => pi_pk_column
                                  ,pi_label_cols => pi_label_cols);
    /*
    ||Run the query.
    */
    EXECUTE IMMEDIATE lv_sql
      INTO lv_retval
      USING pi_pk_value
    ;
    --
    RETURN lv_retval;
    --
  EXCEPTION
    WHEN no_data_found
     THEN
        hig.raise_ner(pi_appl               => nm3type.c_hig
                     ,pi_id                 => 67
                     ,pi_supplementary_info => pi_table_name||'('||pi_pk_column||')'||CHR(10)||pi_pk_column||' => '||pi_pk_value);
  END get_entity_label;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_entity_label(pi_entity_type     IN awlrs_fav_entity_types.afet_entity_type%TYPE
                           ,pi_entity_sub_type IN awlrs_favourites_entities.afe_entity_sub_type%TYPE
                           ,pi_entity_id       IN awlrs_favourites_entities.afe_entity_id%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval  nm3type.max_varchar2;
    --
    lr_ne    nm_elements_all%ROWTYPE;
    lr_nit   nm_inv_types_all%ROWTYPE;
    lr_iit   nm_inv_items_all%ROWTYPE;
    lr_afet  awlrs_fav_entity_types%ROWTYPE;
    --
    lt_afetl  afetl_tab;
    --
    CURSOR get_afet(cp_entity_type IN awlrs_fav_entity_types.afet_entity_type%TYPE)
        IS
    SELECT *
      FROM awlrs_fav_entity_types
     WHERE afet_entity_type = cp_entity_type
         ;
    --
    CURSOR get_afetl(cp_entity_type     IN awlrs_fav_entity_type_labels.afetl_entity_type%TYPE
                    ,cp_entity_sub_type IN awlrs_fav_entity_type_labels.afetl_entity_sub_type%TYPE)
        IS
    SELECT *
      FROM awlrs_fav_entity_type_labels
     WHERE afetl_entity_type = cp_entity_type
       AND NVL(afetl_entity_sub_type,'~~~~~') = NVL(cp_entity_sub_type,'~~~~~')
     ORDER
        BY afetl_seq_no
         ;
    --
  BEGIN
    --
    OPEN  get_afetl(pi_entity_type
                   ,pi_entity_sub_type);
    FETCH get_afetl
     BULK COLLECT
     INTO lt_afetl;
    CLOSE get_afetl;
    --
    CASE pi_entity_type
     WHEN 'NETWORK'
      THEN
         /*
         ||Entity is a Network Element so return the Group\Network Type and Unique
         ||unless this has been overriden using the awlrs_fav_entity_type_labels table.
         */
         IF lt_afetl.COUNT = 0
          THEN
             --
             lr_ne := nm3get.get_ne_all(pi_ne_id => pi_entity_id);
             --
             CASE lr_ne.ne_nt_type
               WHEN 'NSGN'
                THEN
                   lv_retval := NVL(lr_ne.ne_gty_group_type,lr_ne.ne_nt_type)||' : '||lr_ne.ne_number;
               WHEN 'ESU'
                THEN
                   lv_retval := NVL(lr_ne.ne_gty_group_type,lr_ne.ne_nt_type)||' : '||lr_ne.ne_name_1;
               ELSE
                   lv_retval := NVL(lr_ne.ne_gty_group_type,lr_ne.ne_nt_type)||' : '||lr_ne.ne_unique;
             END CASE;
             --
         ELSE
             --
             lv_retval := get_entity_label(pi_table_name => 'NM_ELEMENTS_ALL'
                                          ,pi_pk_column  => 'NE_ID'
                                          ,pi_pk_value   => pi_entity_id
                                          ,pi_label_cols => lt_afetl);
             --
         END IF;
     WHEN 'ASSET'
      THEN
         --
         lr_nit := nm3get.get_nit_all(pi_nit_inv_type => pi_entity_sub_type);
         --
         IF lr_nit.nit_table_name IS NULL
          THEN
             /*
             ||Entity is an exor Inventory Asset so return the Asset Type and Primary Key
             ||unless this has been overriden using the awlrs_fav_entity_type_labels table.
             */
             IF lt_afetl.COUNT = 0
              THEN
                 --
                 lr_iit := nm3get.get_iit_all(pi_iit_ne_id => pi_entity_id);
                 --
                 lv_retval := lr_iit.iit_primary_key;
                 --
             ELSE
                 --
                 lv_retval := get_entity_label(pi_table_name => 'NM_INV_ITEMS_ALL'
                                              ,pi_pk_column  => 'IIT_NE_ID'
                                              ,pi_pk_value   => pi_entity_id
                                              ,pi_label_cols => lt_afetl);
                 --
             END IF;
             --
         ELSE
             /*
             ||Entity is an FT Asset so return the Asset Type and Primary Key
             ||unless this has been overriden using the awlrs_fav_entity_type_labels table.
             */
             IF lt_afetl.COUNT = 0
              THEN
                 --
                 lt_afetl(1).afetl_label_column := lr_nit.nit_foreign_pk_column;
                 --
             END IF;
             --
             lv_retval := get_entity_label(pi_table_name => lr_nit.nit_table_name
                                          ,pi_pk_column  => lr_nit.nit_foreign_pk_column
                                          ,pi_pk_value   => pi_entity_id
                                          ,pi_label_cols => lt_afetl);
             --
         END IF;
         --
         lv_retval := lr_nit.nit_inv_type||' : '||lv_retval;
         --
     ELSE
         /*
         ||Entity is of a custom type so return the label as per the configuration.
         */
         OPEN  get_afet(pi_entity_type);
         FETCH get_afet
          INTO lr_afet;
         CLOSE get_afet;
         --
         IF lr_afet.afet_entity_type IS NULL
          THEN
             /*
             ||Unsupported Entity Type.
             */
             hig.raise_ner(pi_appl => 'AWLRS'
                          ,pi_id   => 87
                          ,pi_supplementary_info => pi_entity_type);
             --
         END IF;
         --
         lv_retval := pi_entity_type||' : '||get_entity_label(pi_table_name => lr_afet.afet_table_name
                                                             ,pi_pk_column  => lr_afet.afet_pk_column
                                                             ,pi_pk_value   => pi_entity_id
                                                             ,pi_label_cols => lt_afetl);
         --
    END CASE;
    --
    RETURN lv_retval;
    --
  END get_entity_label;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION gen_entity_label_sql(pi_entity_type IN awlrs_fav_entity_types.afet_entity_type%TYPE DEFAULT NULL)
    RETURN VARCHAR2 IS
    --
    lv_retval  nm3type.max_varchar2;
    --
    lr_ne    nm_elements_all%ROWTYPE;
    lr_nit   nm_inv_types_all%ROWTYPE;
    lr_iit   nm_inv_items_all%ROWTYPE;
    --
    TYPE afet_tab IS TABLE OF awlrs_fav_entity_types%ROWTYPE;
    lt_afet  afet_tab;
    --
    lt_afetl  afetl_tab;
    --
    CURSOR get_afet
        IS
    SELECT *
      FROM awlrs_fav_entity_types
     WHERE afet_entity_type NOT IN('NETWORK','ASSET')
         ;
    --
    CURSOR get_net_sub_types
        IS
    SELECT DISTINCT(afetl_entity_sub_type) sub_type
      FROM awlrs_fav_entity_type_labels
     WHERE afetl_entity_type = 'NETWORK'
         ;
    --
    TYPE net_sub_type_tab IS TABLE OF get_net_sub_types%ROWTYPE;
    lt_net_sub_types  net_sub_type_tab;
    --
    CURSOR get_nit_sub_types
        IS
    SELECT nit_inv_type
          ,nit_table_name
          ,nit_foreign_pk_column
      FROM nm_inv_types
     WHERE nit_inv_type IN(SELECT afe_entity_sub_type
                             FROM awlrs_favourites_entities
                            WHERE afe_entity_type = 'ASSET')
         ;
    --
    TYPE nit_sub_types_tab IS TABLE OF get_nit_sub_types%ROWTYPE;
    lt_nit  nit_sub_types_tab;
    --
    CURSOR get_afetl(cp_entity_type     IN awlrs_fav_entity_type_labels.afetl_entity_type%TYPE
                    ,cp_entity_sub_type IN awlrs_fav_entity_type_labels.afetl_entity_sub_type%TYPE)
        IS
    SELECT *
      FROM awlrs_fav_entity_type_labels
     WHERE afetl_entity_type = cp_entity_type
       AND NVL(afetl_entity_sub_type,'~~~~~') = NVL(cp_entity_sub_type,'~~~~~')
     ORDER
        BY afetl_seq_no
         ;
    --
  BEGIN
    --
    lv_retval := 'CASE afe_entity_type ';
    /*
    ||Network.
    */
    IF pi_entity_type IS NULL
     OR pi_entity_type = 'NETWORK'
     THEN
        --
        lv_retval := lv_retval||'WHEN ''NETWORK'' THEN ';
        --
        OPEN  get_net_sub_types;
        FETCH get_net_sub_types
         BULK COLLECT
         INTO lt_net_sub_types;
        CLOSE get_net_sub_types;
        --
        IF lt_net_sub_types.COUNT > 0
         THEN
            lv_retval := lv_retval||'CASE afe_entity_sub_type ';
        END IF;
        --
        FOR i IN 1..lt_net_sub_types.COUNT LOOP
          --
          OPEN  get_afetl('NETWORK'
                         ,lt_net_sub_types(i).sub_type);
          FETCH get_afetl
           BULK COLLECT
           INTO lt_afetl;
          CLOSE get_afetl;
          --
          lv_retval := lv_retval||'WHEN '''||lt_net_sub_types(i).sub_type||''' THEN ('
                                ||get_entity_label_sql(pi_table_name => 'NM_ELEMENTS_ALL'
                                                      ,pi_pk_column  => 'NE_ID'
                                                      ,pi_pk_val_col => 'AFE_ENTITY_ID'
                                                      ,pi_label_cols => lt_afetl)
                                ||') ';
          --
        END LOOP;
        --
        IF lt_net_sub_types.COUNT > 0
         THEN
            lv_retval := lv_retval||'ELSE ';
        END IF;
        --
        lv_retval := lv_retval||'(SELECT NVL(ne_gty_group_type,ne_nt_type)||'' : ''||CASE ne_nt_type WHEN ''NSGN'' THEN ne_number WHEN ''ESU'' THEN ne_name_1 ELSE ne_unique END FROM nm_elements_all WHERE ne_id = afe_entity_id) ';
        --
        IF lt_net_sub_types.COUNT > 0
         THEN
            lv_retval := lv_retval||'END ';
        END IF;
        --
    END IF;
    /*
    ||Assets.
    */
    IF pi_entity_type IS NULL
     OR pi_entity_type = 'ASSET'
     THEN
        --
        lv_retval := lv_retval||'WHEN ''ASSET'' THEN ';
        --
        OPEN  get_nit_sub_types;
        FETCH get_nit_sub_types
         BULK COLLECT
         INTO lt_nit;
        CLOSE get_nit_sub_types;
        --
        IF lt_nit.COUNT > 0
         THEN
            lv_retval := lv_retval||'CASE afe_entity_sub_type ';
        END IF;
        --
        FOR i IN 1..lt_nit.COUNT LOOP
          --
          OPEN  get_afetl('ASSET'
                         ,lt_nit(i).nit_inv_type);
          FETCH get_afetl
           BULK COLLECT
           INTO lt_afetl;
          CLOSE get_afetl;
          --
          IF lt_afetl.COUNT > 0
           OR lt_nit(i).nit_table_name IS NOT NULL
           THEN
              --
              IF lt_afetl.COUNT = 0
               THEN
                  --
                  lt_afetl(1).afetl_label_column := lt_nit(i).nit_foreign_pk_column;
                  --
              END IF;
              --
              lv_retval := lv_retval||'WHEN '''||lt_nit(i).nit_inv_type||''' THEN afe_entity_sub_type||'' : ''||('
                                    ||get_entity_label_sql(pi_table_name => NVL(lt_nit(i).nit_table_name,'NM_INV_ITEMS_ALL')
                                                          ,pi_pk_column  => NVL(lt_nit(i).nit_foreign_pk_column,'IIT_NE_ID')
                                                          ,pi_pk_val_col => 'AFE_ENTITY_ID'
                                                          ,pi_label_cols => lt_afetl)
                                    ||') ';
              --
          END IF;
          --lv_retval := lr_nit.nit_inv_type||' : '||lv_retval;
        END LOOP;
        --
        IF lt_nit.COUNT > 0
         THEN
            lv_retval := lv_retval||'ELSE ';
        END IF;
        --
        lv_retval := lv_retval||'(SELECT iit_inv_type||'' : ''||iit_primary_key FROM nm_inv_items_all WHERE iit_ne_id = afe_entity_id) ';
        --
        IF lt_nit.COUNT > 0
         THEN
            lv_retval := lv_retval||'END ';
        END IF;
        --
    END IF;
    /*
    ||Other Entity Types.
    */
    OPEN  get_afet;
    FETCH get_afet
     BULK COLLECT
     INTO lt_afet;
    CLOSE get_afet;
    --
    FOR i IN 1..lt_afet.COUNT LOOP
      --
      IF pi_entity_type IS NULL
       OR pi_entity_type = lt_afet(i).afet_entity_type
       THEN
          OPEN  get_afetl(lt_afet(i).afet_entity_type
                         ,NULL);
          FETCH get_afetl
           BULK COLLECT
           INTO lt_afetl;
          CLOSE get_afetl;
          --
          lv_retval := lv_retval||'WHEN '''||lt_afet(i).afet_entity_type||''' THEN '''||lt_afet(i).afet_display_name||'''||'' : ''||('
                                ||get_entity_label_sql(pi_table_name => lt_afet(i).afet_table_name
                                                      ,pi_pk_column  => lt_afet(i).afet_pk_column
                                                      ,pi_pk_val_col => 'AFE_ENTITY_ID'
                                                      ,pi_label_cols => lt_afetl)
                                ||') ';
          --
      END IF;
      --
    END LOOP;
    --
    lv_retval := lv_retval||'END label';
    --
    RETURN lv_retval;
    --
  END gen_entity_label_sql;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_folder_child_count(pi_parent_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    RETURN PLS_INTEGER IS
    --
  BEGIN
    --
    RETURN get_child_folder_count(pi_parent_af_id => pi_parent_af_id)
           + get_child_entity_count(pi_parent_af_id => pi_parent_af_id);
    --
  END get_folder_child_count;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION gen_network_label_sql
    RETURN VARCHAR2 IS
    --
    lv_retval  nm3type.max_varchar2;
    --
    lt_afetl  afetl_tab;
    --
    CURSOR get_net_sub_types
        IS
    SELECT DISTINCT(afetl_entity_sub_type) sub_type
      FROM awlrs_fav_entity_type_labels
     WHERE afetl_entity_type = 'NETWORK'
         ;
    --
    TYPE net_sub_type_tab IS TABLE OF get_net_sub_types%ROWTYPE;
    lt_net_sub_types  net_sub_type_tab;
    --
    CURSOR get_afetl(cp_entity_type     IN awlrs_fav_entity_type_labels.afetl_entity_type%TYPE
                    ,cp_entity_sub_type IN awlrs_fav_entity_type_labels.afetl_entity_sub_type%TYPE)
        IS
    SELECT *
      FROM awlrs_fav_entity_type_labels
     WHERE afetl_entity_type = cp_entity_type
       AND NVL(afetl_entity_sub_type,'~~~~~') = NVL(cp_entity_sub_type,'~~~~~')
     ORDER
        BY afetl_seq_no
         ;
    --
  BEGIN
    --
    lv_retval := lv_retval||'NVL(cne.ne_gty_group_type,cne.ne_nt_type)||'' : ''||';
    --
    OPEN  get_net_sub_types;
    FETCH get_net_sub_types
     BULK COLLECT
     INTO lt_net_sub_types;
    CLOSE get_net_sub_types;
    --
    IF lt_net_sub_types.COUNT > 0
     THEN
        lv_retval := lv_retval||'CASE cne.ne_nt_type ';
    END IF;
    --
    FOR i IN 1..lt_net_sub_types.COUNT LOOP
      --
      OPEN  get_afetl('NETWORK'
                     ,lt_net_sub_types(i).sub_type);
      FETCH get_afetl
       BULK COLLECT
       INTO lt_afetl;
      CLOSE get_afetl;
      --
      lv_retval := lv_retval||'WHEN '''||lt_net_sub_types(i).sub_type||''' THEN ';
      --
      FOR i IN 1..lt_afetl.COUNT LOOP
        --
        awlrs_util.validate_simple_sql_name(pi_name               => lt_afetl(i).afetl_label_column
                                           ,pi_supplementary_info => 'label column');
        --
        lv_retval := lv_retval||'cne.'||lt_afetl(i).afetl_label_column||CASE WHEN i = lt_afetl.COUNT THEN NULL ELSE '||'' '||lt_afetl(i).afetl_label_separator||' ''||' END;
        --
      END LOOP;
      --
    END LOOP;
    --
    IF lt_net_sub_types.COUNT > 0
     THEN
        lv_retval := lv_retval||' ELSE ';
    END IF;
    --
    lv_retval := lv_retval||'CASE cne.ne_nt_type WHEN ''NSGN'' THEN cne.ne_number WHEN ''ESU'' THEN cne.ne_name_1 ELSE cne.ne_unique END ';
    --
    IF lt_net_sub_types.COUNT > 0
     THEN
        lv_retval := lv_retval||'END ';
    END IF;
    --
    RETURN lv_retval;
    --
  END gen_network_label_sql;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_network_element_data(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                                    ,po_message_cursor   OUT sys_refcursor
                                    ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_entity_type_display_name  awlrs_fav_entity_types.afet_display_name%TYPE;
    --
    CURSOR get_display_name
        IS
    SELECT afet_display_name
      FROM awlrs_fav_entity_types
     WHERE afet_entity_type = 'NETWORK'
         ;
    --
  BEGIN
    --
    OPEN  get_display_name;
    FETCH get_display_name
     INTO lv_entity_type_display_name;
    CLOSE get_display_name;
    --
    OPEN po_cursor FOR 'SELECT folder_or_entity'
                           ||',af_id'
                           ||',parent_af_id'
                           ||',label'
                           ||',NVL(seq_no,rownum) seq_no'
                           ||',entity_type'
                           ||',:display_name entity_type_display_name'
                           ||',entity_sub_type'
                           ||',entity_network_group_type'
                           ||',entity_id'
                           ||',child_count'
                      ||' FROM (SELECT CAST(''ENTITY'' AS VARCHAR2(6)) folder_or_entity'
                                   ||',CAST(NULL AS NUMBER(38)) af_id'
                                   ||',CAST(NULL AS NUMBER(38)) parent_af_id'
                                   ||','||gen_network_label_sql||'||CASE WHEN cne.ne_gty_group_type IS NULL THEN '' : From ''||nm_begin_mp||'' To ''||nm_end_mp||'' (''||un_unit_name||'')'' ELSE NULL END label'
                                   ||',CASE WHEN ngt_linear_flag = ''Y'' THEN nm_seq_no ELSE NULL END seq_no'
                                   ||',CAST(''NETWORK'' AS VARCHAR2(100)) entity_type'
                                   ||',cne.ne_nt_type entity_sub_type'
                                   ||',cne.ne_gty_group_type entity_network_group_type'
                                   ||',cne.ne_id entity_id'
                                   ||',CASE'
                                     ||' WHEN cne.ne_gty_group_type IS NOT NULL'
                                      ||' THEN'
                                         ||' (SELECT COUNT(*)'
                                            ||' FROM nm_members m2'
                                           ||' WHERE m2.nm_ne_id_in = cne.ne_id'
                                             ||' AND m2.nm_type = ''G'')'
                                     ||' ELSE'
                                         ||' 0'
                                   ||' END child_count'
                                  ||' FROM nm_elements pne'
                                       ||',nm_group_types_all'
                                       ||',nm_members m1'
                                       ||',nm_elements cne'
                                       ||',nm_types'
                                       ||',nm_units'
                                 ||' WHERE pne.ne_id = :ne_id'
                                   ||' AND pne.ne_gty_group_type = ngt_group_type'
                                   ||' AND pne.ne_id = m1.nm_ne_id_in'
                                   ||' AND m1.nm_type = ''G'''
                                   ||' AND m1.nm_ne_id_of = cne.ne_id'
                                   ||' AND cne.ne_nt_type = nt_type'
                                   ||' AND nt_length_unit = un_unit_id(+)'
                                 ||' ORDER'
                                    ||' BY CASE WHEN ngt_linear_flag = ''Y'' THEN m1.nm_seq_no ELSE NULL END'
                                       ||',CASE WHEN ngt_linear_flag = ''N'' THEN CASE WHEN cne.ne_nt_type = ''NSGN'' THEN cne.ne_number WHEN cne.ne_nt_type = ''ESU'' THEN cne.ne_name_1 ELSE cne.ne_unique END ELSE NULL END)'
      USING lv_entity_type_display_name
           ,pi_ne_id
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
  END get_network_element_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_network_element_data(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                                          ,pi_skip_n_rows      IN  PLS_INTEGER
                                          ,pi_pagesize         IN  PLS_INTEGER
                                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                                          ,po_message_cursor   OUT sys_refcursor
                                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_lower_index               PLS_INTEGER;
    lv_upper_index               PLS_INTEGER;
    lv_row_restriction           nm3type.max_varchar2;
    lv_entity_type_display_name  awlrs_fav_entity_types.afet_display_name%TYPE;
    --
    CURSOR get_display_name
        IS
    SELECT afet_display_name
      FROM awlrs_fav_entity_types
     WHERE afet_entity_type = 'NETWORK'
         ;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT folder_or_entity'
                                                ||',af_id'
                                                ||',parent_af_id'
                                                ||',label'
                                                ||',NVL(seq_no,rownum) seq_no'
                                                ||',entity_type'
                                                ||',:display_name entity_type_display_name'
                                                ||',entity_sub_type'
                                                ||',entity_network_group_type'
                                                ||',entity_id'
                                                ||',child_count'
                                           ||' FROM (SELECT CAST(''ENTITY'' AS VARCHAR2(6)) folder_or_entity'
                                                        ||',CAST(NULL AS NUMBER(38)) af_id'
                                                        ||',CAST(NULL AS NUMBER(38)) parent_af_id'
                                                        ||',awlrs_favourites_api.get_entity_label(''NETWORK'',cne.ne_nt_type,cne.ne_id)||CASE WHEN cne.ne_gty_group_type IS NULL THEN '' : From ''||nm_begin_mp||'' To ''||nm_end_mp||'' (''||un_unit_name||'')'' ELSE NULL END label'
                                                        ||',CASE WHEN ngt_linear_flag = ''Y'' THEN nm_seq_no ELSE NULL END seq_no'
                                                        ||',CAST(''NETWORK'' AS VARCHAR2(100)) entity_type'
                                                        ||',cne.ne_nt_type entity_sub_type'
                                                        ||',cne.ne_gty_group_type entity_network_group_type'
                                                        ||',cne.ne_id entity_id'
                                                        ||',CASE'
                                                          ||' WHEN cne.ne_gty_group_type IS NOT NULL'
                                                           ||' THEN'
                                                              ||' (SELECT COUNT(*)'
                                                                 ||' FROM nm_members m2'
                                                                ||' WHERE m2.nm_ne_id_in = cne.ne_id'
                                                                  ||' AND m2.nm_type = ''G'')'
                                                          ||' ELSE'
                                                              ||' 0'
                                                        ||' END child_count'
                                                   ||' FROM nm_elements pne'
                                                        ||',nm_group_types_all'
                                                        ||',nm_members m1'
                                                        ||',nm_elements cne'
                                                        ||',nm_types'
                                                        ||',nm_units'
                                                  ||' WHERE pne.ne_id = :ne_id'
                                                    ||' AND pne.ne_gty_group_type = ngt_group_type'
                                                    ||' AND pne.ne_id = m1.nm_ne_id_in'
                                                    ||' AND m1.nm_type = ''G'''
                                                    ||' AND m1.nm_ne_id_of = cne.ne_id'
                                                    ||' AND cne.ne_nt_type = nt_type'
                                                    ||' AND nt_length_unit = un_unit_id(+)'
                                                  ||' ORDER'
                                                  ||' BY CASE WHEN ngt_linear_flag = ''Y'' THEN m1.nm_seq_no ELSE NULL END'
                                                  ||',CASE WHEN ngt_linear_flag = ''N'' THEN CASE WHEN cne.ne_nt_type = ''NSGN'' THEN cne.ne_number WHEN cne.ne_nt_type = ''ESU'' THEN cne.ne_name_1 ELSE cne.ne_unique END ELSE NULL END)'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT folder_or_entity'
                                               ||',af_id'
                                               ||',parent_af_id'
                                               ||',label'
                                               ||',seq_no'
                                               ||',entity_type'
                                               ||',entity_type_display_name'
                                               ||',entity_sub_type'
                                               ||',entity_network_group_type'
                                               ||',entity_id'
                                               ||',child_count'
                                               ||',row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql||') a)'
    ;
    --
  BEGIN
    --
    OPEN  get_display_name;
    FETCH get_display_name
     INTO lv_entity_type_display_name;
    CLOSE get_display_name;
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
      ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING lv_entity_type_display_name
             ,pi_ne_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING lv_entity_type_display_name
             ,pi_ne_id
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
  END get_paged_network_element_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_paged_element_data(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
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
    lv_lower_index      PLS_INTEGER;
    lv_upper_index      PLS_INTEGER;
    lv_row_restriction  nm3type.max_varchar2;
    lv_order_by         nm3type.max_varchar2;
    lv_filter           nm3type.max_varchar2;
    --
    lv_driving_sql  nm3type.max_varchar2 := 'SELECT id'
                                                ||',seq_no'
                                                ||',network_type'
                                                ||',group_type'
                                                ||',name_'
                                                ||',from_offset'
                                                ||',to_offset'
                                                ||',child_count'
                                          ||' FROM (SELECT cne.ne_id id'
                                                       ||',cne.ne_nt_type network_type'
                                                       ||',cne.ne_gty_group_type group_type'
                                                       ||',CASE WHEN cne.ne_nt_type = ''NSGN'' THEN cne.ne_number WHEN cne.ne_nt_type = ''ESU'' THEN cne.ne_name_1 ELSE cne.ne_unique END name_'
                                                       ||',m1.nm_begin_mp from_offset'
                                                       ||',m1.nm_end_mp to_offset'
                                                       ||',CASE WHEN ngt_linear_flag = ''Y'' THEN nm_seq_no ELSE NULL END seq_no'
                                                       ||',CASE'
                                                         ||' WHEN cne.ne_gty_group_type IS NOT NULL'
                                                          ||' THEN'
                                                             ||' (SELECT COUNT(*)'
                                                                ||' FROM nm_members m2'
                                                               ||' WHERE m2.nm_ne_id_in = cne.ne_id'
                                                                 ||' AND m2.nm_type = ''G'')'
                                                         ||' ELSE'
                                                             ||' 0'
                                                       ||' END child_count'
                                                  ||' FROM nm_elements pne'
                                                       ||',nm_group_types_all'
                                                       ||',nm_members m1'
                                                       ||',nm_elements cne'
                                                 ||' WHERE pne.ne_id = :ne_id'
                                                   ||' AND pne.ne_gty_group_type = ngt_group_type'
                                                   ||' AND pne.ne_id = m1.nm_ne_id_in'
                                                   ||' AND m1.nm_type = ''G'''
                                                   ||' AND m1.nm_ne_id_of = cne.ne_id)'
    ;
    lv_cursor_sql  nm3type.max_varchar2 := 'SELECT id'
                                               ||',seq_no'
                                               ||',network_type'
                                               ||',group_type'
                                               ||',name_'
                                               ||',from_offset'
                                               ||',to_offset'
                                               ||',child_count'
                                               ||',row_count'
                                          ||' FROM (SELECT rownum ind'
                                                      ||' ,a.*'
                                                      ||' ,COUNT(1) OVER(ORDER BY 1 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_count'
                                                  ||' FROM ('||lv_driving_sql
    ;
    --
    lt_column_data  awlrs_util.column_data_tab;
    --
    PROCEDURE set_column_data(po_column_data IN OUT awlrs_util.column_data_tab)
      IS
    BEGIN
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'id'
                                ,pi_query_col    => 'id'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'seq_no'
                                ,pi_query_col    => 'seq_no'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'network_type'
                                ,pi_query_col    => 'network_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'group_type'
                                ,pi_query_col    => 'group_type'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'name_'
                                ,pi_query_col    => 'name_'
                                ,pi_datatype     => awlrs_util.c_varchar2_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'from_offset'
                                ,pi_query_col    => 'from_offset'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'to_offset'
                                ,pi_query_col    => 'to_offset'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      awlrs_util.add_column_data(pi_cursor_col   => 'child_count'
                                ,pi_query_col    => 'child_count'
                                ,pi_datatype     => awlrs_util.c_number_col
                                ,pi_mask         => NULL
                                ,pio_column_data => po_column_data);
      --
      --<Repeat for each column that should allow filtering>
      --
    END set_column_data;
    --
  BEGIN
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
                                 ,pi_where_or_and => 'WHERE' --Depends on lv_driving_sql if it has a where clause already then AND otherwise WHERE
                                 ,po_where_clause => lv_filter);
        --
    END IF;
    --
    lv_cursor_sql := lv_cursor_sql
      ||CHR(10)||lv_filter
      ||CHR(10)||' ORDER BY '||NVL(lv_order_by,'seq_no,name_')||') a)'
      ||CHR(10)||lv_row_restriction
    ;
    --
    IF pi_pagesize IS NOT NULL
     THEN
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_ne_id
             ,lv_lower_index
             ,lv_upper_index;
    ELSE
        OPEN po_cursor FOR lv_cursor_sql
        USING pi_ne_id
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
  END get_paged_element_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_asset_data(pi_inv_type         IN  nm_inv_types_all.nit_inv_type%TYPE
                          ,pi_iit_ne_id        IN  nm_inv_items_all.iit_ne_id%TYPE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor
                          ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_entity_type_display_name  awlrs_fav_entity_types.afet_display_name%TYPE;
    --
    CURSOR get_display_name
        IS
    SELECT afet_display_name
      FROM awlrs_fav_entity_types
     WHERE afet_entity_type = 'ASSET'
         ;
    --
  BEGIN
    --
    OPEN  get_display_name;
    FETCH get_display_name
     INTO lv_entity_type_display_name;
    CLOSE get_display_name;
    --
    OPEN po_cursor FOR
    SELECT folder_or_entity
          ,af_id
          ,parent_af_id
          ,label
          ,rownum seq_no
          ,entity_type
          ,lv_entity_type_display_name entity_type_display_name
          ,entity_sub_type
          ,NULL entity_network_group_type
          ,entity_id
          ,child_count
      FROM (SELECT CAST('ENTITY' AS VARCHAR2(6)) folder_or_entity
                  ,CAST(NULL AS NUMBER(38)) af_id
                  ,CAST(NULL AS NUMBER(38)) parent_af_id
                  ,awlrs_favourites_api.get_entity_label('ASSET',iitc.iit_inv_type,iitc.iit_ne_id) label
                  ,CAST('ASSET' AS VARCHAR2(100)) entity_type
                  ,iitc.iit_inv_type entity_sub_type
                  ,iitc.iit_ne_id entity_id
                  ,(SELECT COUNT(*)
                      FROM nm_inv_item_groupings
                     WHERE iig_parent_id = iitc.iit_ne_id) child_count
              FROM nm_inv_items iitp
                  ,nm_inv_item_groupings
                  ,nm_inv_items iitc
             WHERE iitp.iit_ne_id = pi_iit_ne_id
               AND iitp.iit_inv_type = pi_inv_type
               AND iitp.iit_ne_id = iig_parent_id
               AND iig_item_id = iitc.iit_ne_id)
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
  END get_asset_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_folder_data(pi_aff_af_id        IN  awlrs_favourites_folders.aff_af_id%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM (SELECT CAST('ENTITY' AS VARCHAR2(6)) folder_or_entity
                  ,afe_af_id af_id
                  ,afe_parent_af_id parent_af_id
                  ,awlrs_favourites_api.get_entity_label(afe_entity_type,afe_entity_sub_type,afe_entity_id) label
                  ,afe_seq_no seq_no
                  ,afe_entity_type entity_type
                  ,afet_display_name entity_type_display_name
                  ,afe_entity_sub_type entity_sub_type
                  ,CASE
                     WHEN afe_entity_type = 'NETWORK'
                      THEN
                         (SELECT ne_gty_group_type
                            FROM nm_elements_all
                           WHERE ne_id = afe_entity_id)
                     ELSE
                         NULL
                   END entity_network_group_type
                  ,afe_entity_id entity_id
                  ,CASE
                     WHEN afe_entity_type = 'NETWORK'
                      THEN
                         (SELECT COUNT(*)
                            FROM nm_members
                           WHERE nm_ne_id_in = (SELECT ne_id
                                                  FROM nm_elements
                                                 WHERE ne_id = afe_entity_id
                                                   AND ne_gty_group_type IS NOT NULL)
                             AND nm_type = 'G')
                     WHEN afe_entity_type = 'ASSET'
                      THEN
                         (SELECT COUNT(*)
                            FROM nm_inv_items
                                ,nm_inv_item_groupings
                           WHERE iit_ne_id = afe_entity_id
                             AND iit_inv_type = afe_entity_sub_type
                             AND iit_ne_id = iig_parent_id)
                     ELSE
                         0
                   END child_count
              FROM awlrs_favourites_entities
                  ,awlrs_fav_entity_types
             WHERE afe_parent_af_id = pi_aff_af_id
               AND afe_entity_type = afet_entity_type
            UNION ALL
            SELECT CAST('FOLDER' AS VARCHAR2(6)) folder_or_entity
                  ,aff_af_id af_id
                  ,aff_parent_af_id parent_af_id
                  ,aff_name label
                  ,aff_seq_no seq_no
                  ,NULL entity_type
                  ,NULL entity_type_display_name
                  ,NULL entity_sub_type
                  ,NULL entity_network_group_type
                  ,NULL entity_id
                  ,awlrs_favourites_api.get_folder_child_count(aff_af_id) child_count
              FROM awlrs_favourites_folders
             WHERE aff_parent_af_id = pi_aff_af_id)
     ORDER
        BY seq_no
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
  END get_folder_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_root_data(pi_product          IN  awlrs_favourites_folders.aff_product%TYPE
                         ,po_message_severity OUT hig_codes.hco_code%TYPE
                         ,po_message_cursor   OUT sys_refcursor
                         ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    get_folder_data(pi_aff_af_id        => get_root_folder_id(pi_product => pi_product)
                   ,po_message_severity => po_message_severity
                   ,po_message_cursor   => po_message_cursor
                   ,po_cursor           => po_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_root_data;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_root_folder(pi_product IN awlrs_favourites_folders.aff_product%TYPE)
    RETURN item_data_rec IS
    --
    lr_retval item_data_rec;
    --
    CURSOR get_data(cp_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT 'FOLDER' folder_or_entity
          ,aff_af_id af_id
          ,aff_parent_af_id parent_af_id
          ,NVL(hig.get_user_or_sys_opt('AWLFAVNAME'),'Favorites') label
          ,aff_seq_no seq_no
          ,CAST(NULL AS VARCHAR2(100)) entity_type
          ,CAST(NULL AS VARCHAR2(100)) entity_type_display_name
          ,CAST(NULL AS VARCHAR2(100)) entity_sub_type
          ,CAST(NULL AS VARCHAR2(4)) entity_network_group_type
          ,CAST(NULL AS NUMBER(38)) entity_id
          ,awlrs_favourites_api.get_folder_child_count(aff_af_id) child_count
      FROM awlrs_favourites_folders
     WHERE aff_af_id = cp_aff_af_id
     ORDER
        BY seq_no
         ;
    --
  BEGIN
    --
    OPEN  get_data(get_root_folder_id(pi_product => pi_product));
    FETCH get_data
     INTO lr_retval;
    CLOSE get_data;
    --
    RETURN lr_retval;
    --
  END get_root_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_root_folder(pi_product          IN  awlrs_favourites_folders.aff_product%TYPE
                           ,po_message_severity OUT hig_codes.hco_code%TYPE
                           ,po_message_cursor   OUT sys_refcursor
                           ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_root_folder_id  awlrs_favourites_folders.aff_af_id%TYPE;
    --
  BEGIN
    --
    lv_root_folder_id := get_root_folder_id(pi_product => pi_product);
    --
    OPEN po_cursor FOR
    SELECT CAST('FOLDER' AS VARCHAR2(6)) folder_or_entity
          ,aff_af_id af_id
          ,aff_parent_af_id parent_af_id
          ,NVL(hig.get_user_or_sys_opt('AWLFAVNAME'),'Favorites') label
          ,aff_seq_no seq_no
          ,CAST(NULL AS VARCHAR2(100)) entity_type
          ,CAST(NULL AS VARCHAR2(100)) entity_type_display_name
          ,CAST(NULL AS VARCHAR2(100)) entity_sub_type
          ,CAST(NULL AS VARCHAR2(4)) entity_network_group_type
          ,CAST(NULL AS NUMBER(38)) entity_id
          ,awlrs_favourites_api.get_folder_child_count(aff_af_id) child_count
      FROM awlrs_favourites_folders
     WHERE aff_af_id = lv_root_folder_id
     ORDER
        BY seq_no
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
  END get_root_folder;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_folder_hierarchy(pi_product          IN  awlrs_favourites_folders.aff_product%TYPE
                                ,po_message_severity OUT hig_codes.hco_code%TYPE
                                ,po_message_cursor   OUT sys_refcursor
                                ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_root_folder_id  awlrs_favourites_folders.aff_af_id%TYPE;
    --
  BEGIN
    --
    lv_root_folder_id := get_root_folder_id(pi_product => pi_product);
    --
    OPEN po_cursor FOR
    SELECT aff_af_id
          ,aff_parent_af_id
          ,level
          ,CASE WHEN aff_parent_af_id IS NULL THEN NVL(hig.get_user_or_sys_opt('AWLFAVNAME'),'Favorites') ELSE aff_name END aff_name
          ,aff_default
      FROM awlrs_favourites_folders
   CONNECT BY PRIOR aff_af_id = aff_parent_af_id
     START WITH aff_af_id = lv_root_folder_id
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
  END get_folder_hierarchy;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_folder_data(pi_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
    RETURN item_data_tab IS
    --
    lt_retval item_data_tab;
    --
    CURSOR get_data(cp_aff_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
        IS
    SELECT *
      FROM (SELECT CAST('ENTITY' AS VARCHAR2(6)) folder_or_entity
                  ,afe_af_id af_id
                  ,afe_parent_af_id parent_af_id
                  ,awlrs_favourites_api.get_entity_label(afe_entity_type,afe_entity_sub_type,afe_entity_id) label
                  ,afe_seq_no seq_no
                  ,afe_entity_type entity_type
                  ,afet_display_name entity_type_display_name
                  ,afe_entity_sub_type entity_sub_type
                  ,CASE
                     WHEN afe_entity_type = 'NETWORK'
                      THEN
                         (SELECT ne_gty_group_type
                            FROM nm_elements_all
                           WHERE ne_id = afe_entity_id)
                     ELSE
                         NULL
                   END entity_network_group_type
                  ,afe_entity_id entity_id
                  ,CASE
                     WHEN afe_entity_type = 'NETWORK'
                      THEN
                         (SELECT COUNT(*)
                            FROM nm_members
                           WHERE nm_ne_id_in = (SELECT ne_id
                                                  FROM nm_elements
                                                 WHERE ne_id = afe_entity_id
                                                   AND ne_gty_group_type IS NOT NULL)
                             AND nm_type = 'G')
                     WHEN afe_entity_type = 'ASSET'
                      THEN
                         (SELECT COUNT(*)
                            FROM nm_inv_items
                                ,nm_inv_item_groupings
                           WHERE iit_ne_id = afe_entity_id
                             AND iit_inv_type = afe_entity_sub_type
                             AND iit_ne_id = iig_parent_id)
                     ELSE
                         0
                   END child_count
              FROM awlrs_favourites_entities
                  ,awlrs_fav_entity_types
             WHERE afe_parent_af_id = cp_aff_af_id
               AND afe_entity_type = afet_entity_type
            UNION ALL
            SELECT CAST('FOLDER' AS VARCHAR2(6)) folder_or_entity
                  ,aff_af_id af_id
                  ,aff_parent_af_id parent_af_id
                  ,aff_name label
                  ,aff_seq_no seq_no
                  ,CAST(NULL AS VARCHAR2(100)) entity_type
                  ,CAST(NULL AS VARCHAR2(100)) entity_type_display_name
                  ,CAST(NULL AS VARCHAR2(100)) entity_sub_type
                  ,CAST(NULL AS VARCHAR2(4)) entity_network_group_type
                  ,CAST(NULL AS NUMBER(38)) entity_id
                  ,awlrs_favourites_api.get_folder_child_count(aff_af_id) child_count
              FROM awlrs_favourites_folders
             WHERE aff_parent_af_id = cp_aff_af_id)
     ORDER
        BY seq_no DESC
         ;
  BEGIN
    --
    OPEN  get_data(pi_aff_af_id);
    FETCH get_data
      BULK COLLECT
     INTO lt_retval;
    CLOSE get_data;
    --
    RETURN lt_retval;
    --
  END get_folder_data;

  --
  ------------------------------------------------------------------------------
  --
  PROCEDURE filter_entity_children(pi_entity_type         IN     awlrs_fav_entity_types.afet_entity_type%TYPE
                                  ,pi_entity_sub_type     IN     awlrs_favourites_entities.afe_entity_sub_type%TYPE
                                  ,pi_entity_id           IN     awlrs_favourites_entities.afe_entity_id%TYPE
                                  ,pi_filter              IN     VARCHAR2
                                  ,pi_level               IN     PLS_INTEGER DEFAULT 1
                                  ,po_entity_has_children IN OUT BOOLEAN)
    IS
    --
    TYPE entity_rec IS RECORD(id          NUMBER
                             ,sub_type    awlrs_favourites_entities.afe_entity_sub_type%TYPE
                             ,label       VARCHAR2(32767)
                             ,child_count PLS_INTEGER);
    TYPE entity_tab IS TABLE OF entity_rec INDEX BY BINARY_INTEGER;
    lt_children  entity_tab;
    lt_parents  entity_tab;
    --
    CURSOR get_elements(cp_ne_id IN nm_elements_all.ne_id%TYPE)
        IS
    SELECT nm_ne_id_of id
          ,cne.ne_nt_type sub_type
          ,awlrs_favourites_api.get_entity_label('NETWORK',cne.ne_nt_type,cne.ne_id) label
          ,CASE
             WHEN cne.ne_gty_group_type IS NOT NULL
              THEN
                 (SELECT COUNT(*)
                     FROM nm_members m2
                    WHERE m2.nm_ne_id_in = cne.ne_id
                      AND m2.nm_type = 'G')
             ELSE
                 0
           END child_count
      FROM nm_members
          ,nm_elements cne
     WHERE nm_ne_id_in = cp_ne_id
       AND nm_type = 'G'
       AND nm_ne_id_of = cne.ne_id
         ;
    --
    CURSOR get_assets(cp_inv_type  IN nm_inv_types_all.nit_inv_type%TYPE
                     ,cp_iit_ne_id IN nm_inv_items_all.iit_ne_id%TYPE)
        IS
    SELECT iitc.iit_ne_id id
          ,iitc.iit_inv_type sub_type
          ,awlrs_favourites_api.get_entity_label('ASSET',iitc.iit_inv_type,iitc.iit_ne_id) label
          ,(SELECT COUNT(*)
              FROM nm_inv_item_groupings
             WHERE iig_parent_id = iitc.iit_ne_id) child_count
      FROM nm_inv_items iitp
          ,nm_inv_item_groupings
          ,nm_inv_items iitc
     WHERE iitp.iit_ne_id = cp_iit_ne_id
       AND iitp.iit_inv_type = cp_inv_type
       AND iitp.iit_ne_id = iig_parent_id
       AND iig_item_id = iitc.iit_ne_id
         ;
    --
  BEGIN
    /*
    ||This procedure will exit on the first match found since there is no
    ||need to find every match.
    */
    IF pi_level = 1
     THEN
        po_entity_has_children := FALSE;
    END IF;
    --
    CASE pi_entity_type
     WHEN 'NETWORK'
      THEN
         --
         OPEN  get_elements(pi_entity_id);
         FETCH get_elements
          BULK COLLECT
          INTO lt_children;
         CLOSE get_elements;
         --
     WHEN 'ASSET'
      THEN
         --
         OPEN  get_assets(pi_entity_sub_type
                         ,pi_entity_id);
         FETCH get_assets
          BULK COLLECT
          INTO lt_children;
         CLOSE get_assets;
         --
     ELSE
         /*
         ||Support for displaying children of entities is limited to
         ||Network and Assets so do nothing.
         */
         NULL;
         --
    END CASE;
    /*
    ||Check the children for a match.
    */
    FOR i IN 1..lt_children.COUNT LOOP
      /*
      ||If a child matches exit the loop and set the output to TRUE.
      */
      IF UPPER(lt_children(i).label) LIKE '%'||UPPER(pi_filter)||'%'
       THEN
          po_entity_has_children := TRUE;
          EXIT;
      END IF;
      /*
      ||Keep a record of children that are also parents.
      */
      IF lt_children(i).child_count > 0
       THEN
          --
          lt_parents(lt_parents.COUNT+1) := lt_children(i);
          --
      END IF;
      --
    END LOOP;
    /*
    ||If any of the children are also parents check their children.
    */
    IF NOT po_entity_has_children
     THEN
        --
        FOR i IN 1..lt_parents.COUNT LOOP
          --
          filter_entity_children(pi_entity_type         => pi_entity_type
                                ,pi_entity_sub_type     => lt_parents(i).sub_type
                                ,pi_entity_id           => lt_parents(i).id
                                ,pi_filter              => pi_filter
                                ,pi_level               => pi_level + 1
                                ,po_entity_has_children => po_entity_has_children);
          --
          IF po_entity_has_children
           THEN
              EXIT;
          END IF;
          --
        END LOOP;
        --
    END IF;
    --
  END filter_entity_children;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_all_folder_data(pi_aff_af_id IN     awlrs_favourites_folders.aff_af_id%TYPE
                               ,pi_filter    IN     VARCHAR2
                               ,pi_check_entity_children IN VARCHAR2
                               ,po_data      IN OUT NOCOPY item_data_tab)
    IS
    --
    lv_entity_has_children  BOOLEAN := FALSE;
    lv_entity_found         BOOLEAN := FALSE;
    --
    lt_aff      aff_tab;
    lt_item_tab item_data_tab;
    --
    FUNCTION get_child_folders(pi_parent_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
      RETURN aff_tab IS
      --
      lt_retval aff_tab;
      --
    BEGIN
      --
      SELECT *
        BULK COLLECT
        INTO lt_retval
        FROM awlrs_favourites_folders
       WHERE aff_parent_af_id = pi_parent_af_id
       ORDER
          BY aff_seq_no DESC
           ;
      --
      RETURN lt_retval;
      --
    END get_child_folders;
    --
    FUNCTION po_data_contains_child(pi_af_id IN awlrs_favourites_folders.aff_af_id%TYPE)
      RETURN BOOLEAN IS
      --
      lv_retval BOOLEAN := FALSE;
      --
    BEGIN
      --
      FOR i IN 1..po_data.COUNT LOOP
        --
        IF po_data(i).parent_af_id = pi_af_id
         THEN
            lv_retval := TRUE;
            EXIT;
        END IF;
        --
      END LOOP;
      --
      RETURN lv_retval;
      --
    END po_data_contains_child;
    --
  BEGIN
    --
    lt_aff := get_child_folders(pi_parent_af_id => pi_aff_af_id);
    --
    FOR i IN 1..lt_aff.COUNT LOOP
      --
      get_all_folder_data(pi_aff_af_id => lt_aff(i).aff_af_id
                         ,pi_filter    => pi_filter
                         ,pi_check_entity_children => pi_check_entity_children
                         ,po_data      => po_data);
      --
    END LOOP;
    --
    lt_item_tab := get_folder_data(pi_aff_af_id => pi_aff_af_id);
    --
    FOR i IN 1..lt_item_tab.COUNT LOOP
      /*
      ||Check the children of any Entities for a match.
      */
      lv_entity_has_children := FALSE;
      --
      IF pi_check_entity_children = 'Y'
       AND pi_filter IS NOT NULL
       AND lt_item_tab(i).folder_or_entity = 'ENTITY'
       AND lt_item_tab(i).child_count > 0
       THEN
          --
          lv_entity_found := FALSE;
          --
          FOR j IN 1..gt_entities_checked.COUNT LOOP
            --
            IF gt_entities_checked(j).entity_type = lt_item_tab(i).entity_type
             AND gt_entities_checked(j).entity_sub_type = lt_item_tab(i).entity_sub_type
             AND gt_entities_checked(j).entity_id = lt_item_tab(i).entity_id
             THEN
                --
                lv_entity_has_children := gt_entities_checked(j).has_children;
                lv_entity_found := TRUE;
                EXIT;
                --
            END IF;
            --
          END LOOP;
          --
          IF NOT lv_entity_found
           THEN
              --
              filter_entity_children(pi_entity_type         => lt_item_tab(i).entity_type
                                    ,pi_entity_sub_type     => lt_item_tab(i).entity_sub_type
                                    ,pi_entity_id           => lt_item_tab(i).entity_id
                                    ,pi_filter              => pi_filter
                                    ,po_entity_has_children => lv_entity_has_children);
              --
              gt_entities_checked(gt_entities_checked.COUNT+1).entity_type := lt_item_tab(i).entity_type;
              gt_entities_checked(gt_entities_checked.COUNT).entity_sub_type := lt_item_tab(i).entity_sub_type;
              gt_entities_checked(gt_entities_checked.COUNT).entity_id := lt_item_tab(i).entity_id;
              gt_entities_checked(gt_entities_checked.COUNT).has_children := lv_entity_has_children;
              --
          END IF;
          --
      END IF;
      --
      IF UPPER(lt_item_tab(i).label) LIKE '%'||UPPER(pi_filter)||'%'
       OR lv_entity_has_children
       OR po_data_contains_child(pi_af_id => lt_item_tab(i).af_id)
       THEN
          po_data(po_data.COUNT+1) := lt_item_tab(i);
      END IF;
      --
    END LOOP;
    --
  END get_all_folder_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_data(pi_product               IN  awlrs_favourites_folders.aff_product%TYPE
                    ,pi_filter                IN  VARCHAR2 DEFAULT NULL
                    ,pi_check_entity_children IN  VARCHAR2 DEFAULT 'N'
                    ,po_message_severity      OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor        OUT sys_refcursor
                    ,po_cursor                OUT sys_refcursor)
    IS
    --
    lv_ind  BINARY_INTEGER;
    --
    lt_data          item_data_tab;
    lt_ordered_data  item_data_tab;
    --
  BEGIN
    --
    gt_entities_checked.DELETE;
    --
    get_all_folder_data(pi_aff_af_id => get_root_folder_id(pi_product => pi_product)
                       ,pi_filter    => pi_filter
                       ,pi_check_entity_children => pi_check_entity_children
                       ,po_data      => lt_data);
    --
    IF lt_data.COUNT > 0
     THEN
        --
        lt_ordered_data(1) := get_root_folder(pi_product => pi_product);
        --
        lv_ind := lt_data.LAST;
        WHILE(lv_ind IS NOT NULL) LOOP
          --
          lt_ordered_data(lt_ordered_data.COUNT+1) := lt_data(lv_ind);
          lv_ind := lt_data.PRIOR(lv_ind);
          --
        END LOOP;
        --
    END IF;
    --
    OPEN po_cursor FOR
    SELECT *
      FROM TABLE(lt_ordered_data)
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
  END get_data;

END awlrs_favourites_api;
/