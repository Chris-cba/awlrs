CREATE OR REPLACE PACKAGE BODY awlrs_persistence_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_persistence_api.pkb-arc   1.2   21 Oct 2016 14:56:06   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_persistence_api.pkb  $
  --       Date into PVCS   : $Date:   21 Oct 2016 14:56:06  $
  --       Date fetched Out : $Modtime:   21 Oct 2016 14:54:14  $
  --       Version          : $Revision:   1.2  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.2  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_persistence_api';
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
  PROCEDURE persist_data(pi_product          IN  awlrs_persistence.ap_product%TYPE
                        ,pi_key              IN  awlrs_persistence.ap_key%TYPE
                        ,pi_data             IN  awlrs_persistence.ap_data%TYPE
                        ,po_message_severity OUT hig_codes.hco_code%TYPE
                        ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT persist_data_sp;
    --
    MERGE INTO awlrs_persistence per
      USING (SELECT sys_context('NM3CORE', 'USER_ID') user_id
                   ,pi_product param_product
                   ,pi_key param_key
                   ,pi_data param_data
               FROM dual) param
         ON (per.ap_product = param.param_product
             AND per.ap_key = param.param_key
             AND per.ap_user_id = param.user_id)
      WHEN MATCHED
       THEN
          UPDATE SET per.ap_data = param.param_data
      WHEN NOT MATCHED
       THEN
          INSERT(ap_id
                ,ap_user_id
                ,ap_product
                ,ap_key
                ,ap_data)
          VALUES(ap_id_seq.NEXTVAL
                ,param.param_product
                ,param.user_id
                ,param.param_key
                ,param.param_data)
    ;
    --
    COMMIT;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO persist_data_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END persist_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE delete_data(pi_product          IN  awlrs_persistence.ap_product%TYPE
                       ,pi_key              IN  awlrs_persistence.ap_key%TYPE
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT delete_data_sp;
    --
    DELETE awlrs_persistence
     WHERE ap_product = pi_product
       AND ap_key = pi_key
       AND ap_user_id = sys_context('NM3CORE', 'USER_ID')
         ;
    --
    COMMIT;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO delete_data_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END delete_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_data(pi_product          IN  awlrs_persistence.ap_product%TYPE
                    ,pi_key              IN  awlrs_persistence.ap_key%TYPE
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor
                    ,po_cursor           OUT sys_refcursor)
    IS
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ap_data
      FROM awlrs_persistence
     WHERE ap_user_id = sys_context('NM3CORE', 'USER_ID')
       AND ap_product = pi_product
       AND ap_key = pi_key
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
  --
END awlrs_persistence_api;
/
