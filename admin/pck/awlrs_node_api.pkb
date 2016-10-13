CREATE OR REPLACE PACKAGE BODY awlrs_node_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_node_api.pkb-arc   1.0   13 Oct 2016 09:32:14   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_node_api.pkb  $
  --       Date into PVCS   : $Date:   13 Oct 2016 09:32:14  $
  --       Date fetched Out : $Modtime:   12 Oct 2016 18:43:00  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_node_api';
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
  PROCEDURE create_node(pi_type       IN     nm_nodes.no_node_type%TYPE
                       ,pi_name       IN     nm_nodes.no_node_name%TYPE
                       ,pi_descr      IN     nm_nodes.no_descr%TYPE
                       ,pi_purpose    IN     nm_nodes_all.no_purpose%TYPE
                       ,pi_point_id   IN     nm_nodes.no_np_id%TYPE
                       ,pi_point_x    IN     nm_points.np_grid_east%TYPE  DEFAULT NULL
                       ,pi_point_y    IN     nm_points.np_grid_north%TYPE DEFAULT NULL
                       ,pi_start_date IN     nm_nodes.no_start_date%TYPE
                       ,po_node_id    IN OUT nm_nodes.no_node_id%TYPE)
    IS
    --
    lv_node_id    nm_nodes.no_node_id%TYPE;
    lv_node_name  nm_nodes.no_node_name%TYPE;
    lv_point_id   nm_nodes.no_np_id%TYPE;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT cre_node_sp;
    --
    lv_node_id := nm3net.get_next_node_id;
    --
    lv_node_name := nm3net.make_node_name(pi_no_type => pi_type
                                         ,pi_no_id   => lv_node_id);
    IF lv_node_name IS NULL
     THEN
        lv_node_name := pi_name;
    END IF;
    --
    IF lv_node_name IS NULL
     THEN
        -- Unable to generate node name and no name supplied
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 1);
    END IF;
    --
    IF pi_point_id IS NOT NULL
     THEN
        lv_point_id := pi_point_id;
    ELSE
        lv_point_id := nm3net.create_point(pi_point_x, pi_point_y);
    END IF;
    --
    nm3net.create_node(pi_no_node_id   => lv_node_id
                      ,pi_np_id        => lv_point_id
                      ,pi_start_date   => TRUNC(pi_start_date)
                      ,pi_no_descr     => pi_descr
                      ,pi_no_node_type => pi_type
                      ,pi_no_node_name => lv_node_name
                      ,pi_no_purpose   => pi_purpose);
    --
    po_node_id := lv_node_id;
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO cre_node_sp;
        RAISE;
  END create_node;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE create_node(pi_type             IN     nm_nodes.no_node_type%TYPE
                       ,pi_name             IN     nm_nodes.no_node_name%TYPE
                       ,pi_descr            IN     nm_nodes.no_descr%TYPE
                       ,pi_purpose          IN     nm_nodes_all.no_purpose%TYPE
                       ,pi_point_id         IN     nm_nodes.no_np_id%TYPE
                       ,pi_point_x          IN     nm_points.np_grid_east%TYPE  DEFAULT NULL
                       ,pi_point_y          IN     nm_points.np_grid_north%TYPE DEFAULT NULL
                       ,pi_start_date       IN     nm_nodes.no_start_date%TYPE
                       ,po_node_id          IN OUT nm_nodes.no_node_id%TYPE
                       ,po_message_severity    OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor      OUT sys_refcursor)
    IS
  BEGIN
    --
    create_node(pi_type       => pi_type
               ,pi_name       => pi_name
               ,pi_descr      => pi_descr
               ,pi_purpose    => pi_purpose
               ,pi_point_id   => pi_point_id
               ,pi_point_x    => pi_point_x
               ,pi_point_y    => pi_point_y
               ,pi_start_date => pi_start_date
               ,po_node_id    => po_node_id);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END create_node;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_node(pi_node_id          IN  nm_nodes.no_node_id%TYPE
                       ,pi_old_name         IN  nm_nodes.no_node_name%TYPE
                       ,pi_old_descr        IN  nm_nodes.no_descr%TYPE
                       ,pi_old_purpose      IN  nm_nodes_all.no_purpose%TYPE
                       ,pi_new_name         IN  nm_nodes.no_node_name%TYPE
                       ,pi_new_descr        IN  nm_nodes.no_descr%TYPE
                       ,pi_new_purpose      IN  nm_nodes_all.no_purpose%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_db_rec  nm_nodes_ALL%ROWTYPE;
    --
    PROCEDURE get_db_rec(pi_node_id IN nm_nodes.no_node_id%TYPE)
      IS
    BEGIN
      --
      SELECT *
        INTO lr_db_rec
        FROM nm_nodes
       WHERE no_node_id = pi_node_id
         FOR UPDATE NOWAIT
           ;
      --
    EXCEPTION
     WHEN no_data_found
      THEN
         --Invalid Node Id supplied
         hig.raise_ner(pi_appl => 'AWLRS'
                      ,pi_id   => 23);
     WHEN others
      THEN
         RAISE;
    END get_db_rec;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT upd_node_sp;
    /*
    ||Get and Lock the record.
    */
    get_db_rec(pi_node_id => pi_node_id);
    /*
    ||Compare old with DB.
    */
    IF (lr_db_rec.no_node_name != pi_old_name
        OR (lr_db_rec.no_node_name IS NULL AND pi_old_name IS NOT NULL)
        OR (lr_db_rec.no_node_name IS NOT NULL AND pi_old_name IS NULL))
     OR (lr_db_rec.no_descr != pi_old_descr
         OR (lr_db_rec.no_descr IS NULL AND pi_old_descr IS NOT NULL)
         OR (lr_db_rec.no_descr IS NOT NULL AND pi_old_descr IS NULL))
     OR (lr_db_rec.no_purpose != pi_old_purpose
         OR (lr_db_rec.no_purpose IS NULL AND pi_old_purpose IS NOT NULL)
         OR (lr_db_rec.no_purpose IS NOT NULL AND pi_old_purpose IS NULL))
     THEN
         --Updated by another user
         hig.raise_ner(pi_appl => 'AWLRS'
                      ,pi_id   => 24);
    END IF;
    /*
    ||Compare new with old.
    */
    IF (pi_old_name = pi_new_name OR (pi_old_name IS NULL AND pi_new_name IS NULL))
     AND (pi_old_descr = pi_new_descr OR (pi_old_descr IS NULL AND pi_new_descr IS NULL))
     AND (pi_old_purpose = pi_new_purpose OR (pi_old_purpose IS NULL AND pi_new_purpose IS NULL))
     THEN
         --No changes to apply
         hig.raise_ner(pi_appl => 'AWLRS'
                      ,pi_id   => 25);
    END IF;
    --
    UPDATE nm_nodes_all
       SET no_node_name = pi_new_name
          ,no_descr = pi_new_descr
          ,no_purpose = pi_new_purpose
     WHERE no_node_id = pi_node_id
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
        ROLLBACK TO upd_node_sp;
  END update_node;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE move_node(pi_node_id          IN  nm_nodes.no_node_id%TYPE
                     ,pi_point_x          IN  nm_points.np_grid_east%TYPE  DEFAULT NULL
                     ,pi_point_y          IN  nm_points.np_grid_north%TYPE DEFAULT NULL
                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                     ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT move_node_sp;
    --
    UPDATE nm_points
       SET np_grid_east = pi_point_x
          ,np_grid_north = pi_point_y
     WHERE np_id = (SELECT no_np_id
                      FROM nm_nodes_all
                     WHERE no_node_id = pi_node_id)
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
        ROLLBACK TO move_node_sp;
  END move_node;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE close_node(pi_no_node_id       IN  nm_nodes.no_node_id%TYPE
                      ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                      ,po_message_severity OUT hig_codes.hco_code%TYPE
                      ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT close_node_sp;
    --
    nm3close.close_node(pi_no_node_id     => pi_no_node_id
                       ,pi_effective_date => pi_effective_date);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
        ROLLBACK TO close_node_sp;
  END close_node;
  
END awlrs_node_api;
/
