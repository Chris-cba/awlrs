CREATE OR REPLACE PACKAGE BODY awlrs_undo_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_undo_api.pkb-arc   1.2   06 Oct 2016 13:05:26   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_undo_api.pkb  $
  --       Date into PVCS   : $Date:   06 Oct 2016 13:05:26  $
  --       Date fetched Out : $Modtime:   06 Oct 2016 12:44:04  $
  --       Version          : $Revision:   1.2  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.2  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_undo_api';
  --
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
  PROCEDURE get_undo_data(pi_ne_id      IN  nm_elements.ne_id%TYPE
                         ,po_operation  OUT nm_element_history.neh_operation%TYPE
                         ,po_message    OUT VARCHAR2
                         ,po_ne_id_new1 OUT nm_elements.ne_id%TYPE
                         ,po_ne_id_new2 OUT nm_elements.ne_id%TYPE
                         ,po_ne_id_old1 OUT nm_elements.ne_id%TYPE
                         ,po_ne_id_old2 OUT nm_elements.ne_id%TYPE)
    IS
    --
    CURSOR get_close(cp_ne_id IN nm_elements_all.ne_id%TYPE)
        IS
    SELECT neh_operation
      FROM nm_element_history
     WHERE neh_ne_id_old = cp_ne_id
       AND neh_operation = 'C'
         ;
    --
  BEGIN
    nm3undo.get_undo_data(p_ne_id      => pi_ne_id
                         ,p_operation  => po_operation
                         ,p_ne_id_new1 => po_ne_id_new1
                         ,p_ne_id_new2 => po_ne_id_new2
                         ,p_ne_id_old1 => po_ne_id_old1
                         ,p_ne_id_old2 => po_ne_id_old2);
  EXCEPTION
    WHEN others
     THEN
        IF SQLERRM = 'ORA-20001: No suitable operations to undo'
         THEN
            OPEN  get_close(pi_ne_id);
            FETCH get_close
             INTO po_operation;
            IF get_close%NOTFOUND
             THEN
                po_message := 'No suitable operations to undo.';
            ELSE
                po_ne_id_old1 := pi_ne_id;
            END IF;
            CLOSE get_close;
        ELSE
            RAISE;
        END IF;
  END get_undo_data;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_undo_operation(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_operation       nm_element_history.neh_operation%TYPE;
    lv_operation_type  hig_codes.hco_meaning%TYPE;
    lv_new_ne_id1      nm_elements_all.ne_id%TYPE;
    lv_new_ne_id2      nm_elements_all.ne_id%TYPE;
    lv_old_ne_id1      nm_elements_all.ne_id%TYPE;
    lv_old_ne_id2      nm_elements_all.ne_id%TYPE;
    --
    lv_message  nm3type.max_varchar2;
    --
  BEGIN
    --
    get_undo_data(pi_ne_id      => pi_ne_id
                 ,po_operation  => lv_operation
                 ,po_message    => lv_message
                 ,po_ne_id_new1 => lv_new_ne_id1
                 ,po_ne_id_new2 => lv_new_ne_id2
                 ,po_ne_id_old1 => lv_old_ne_id1
                 ,po_ne_id_old2 => lv_old_ne_id2);
    --
    IF lv_message IS NULL
     THEN
        --
        hig.valid_fk_hco(pi_hco_domain  => 'HISTORY_OPERATION'
	                      ,pi_hco_code    => lv_operation
	                      ,po_hco_meaning => lv_operation_type);
        --
        CASE
          WHEN lv_operation = 'S'
           THEN
              lv_message := 'This datum is the result of a '||lv_operation_type||' operation.'
                 ||CHR(10)||'Datum:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_old_ne_id1)
                 ||CHR(10)||'was split resulting in:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_new_ne_id1)
                 ||CHR(10)||'and:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_new_ne_id2)
              ;
          WHEN lv_operation = 'M'
           THEN
              lv_message := 'This datum is the result of a '||lv_operation_type||' operation.'
                 ||CHR(10)||'Datums:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_old_ne_id1)
                 ||CHR(10)||'and:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_old_ne_id2)
                 ||CHR(10)||'were merged resulting in:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_new_ne_id1)
              ;
          WHEN lv_operation = 'R'
           THEN
              lv_message := 'This datum is the result of a '||lv_operation_type||' operation.'
                 ||CHR(10)||'Datum:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_old_ne_id1)
                 ||CHR(10)||'was replaced resulting in:'
                 ||CHR(10)||nm3net.get_ne_unique(p_ne_id => lv_new_ne_id1)
              ;
          WHEN lv_operation = 'C'
           THEN
              lv_message := 'This datum was closed.';
          ELSE
              lv_message := 'No suitable operations to undo.';
              lv_operation_type := NULL;
        END CASE;
    END IF;
    --
    OPEN po_cursor FOR
    SELECT CAST(lv_operation_type AS VARCHAR2(52)) operation_type
          ,CAST(lv_message AS VARCHAR2(200)) message
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
    --
  END get_undo_operation;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE undo_operation(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                          ,pi_operation        IN  hig_codes.hco_meaning%TYPE
                          ,pi_include_datums   IN  BOOLEAN DEFAULT TRUE
                          ,po_message_severity OUT hig_codes.hco_code%TYPE
                          ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lv_operation       nm_element_history.neh_operation%TYPE;
    lv_operation_type  hig_codes.hco_meaning%TYPE;
    lv_message         nm3type.max_varchar2;
    lv_new_ne_id1      nm_elements_all.ne_id%TYPE;
    lv_new_ne_id2      nm_elements_all.ne_id%TYPE;
    lv_old_ne_id1      nm_elements_all.ne_id%TYPE;
    lv_old_ne_id2      nm_elements_all.ne_id%TYPE;
    --
  BEGIN
    --
    get_undo_data(pi_ne_id      => pi_ne_id
                 ,po_operation  => lv_operation
                 ,po_message    => lv_message
                 ,po_ne_id_new1 => lv_new_ne_id1
                 ,po_ne_id_new2 => lv_new_ne_id2
                 ,po_ne_id_old1 => lv_old_ne_id1
                 ,po_ne_id_old2 => lv_old_ne_id2);
    --
    IF lv_operation IS NOT NULL
     THEN
        hig.valid_fk_hco(pi_hco_domain  => 'HISTORY_OPERATION'
                        ,pi_hco_code    => lv_operation
                        ,po_hco_meaning => lv_operation_type);
    END IF;
    --
    IF NVL(lv_operation_type,nm3type.c_nvl) != pi_operation
     OR lv_message IS NOT NULL
     THEN
        --
        --Invalid undo operation
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 19
                     ,pi_supplementary_info => pi_operation);
        --
    END IF;
    --
    CASE pi_operation
      WHEN 'Split'
       THEN
          nm3undo.unsplit(p_ne_id => lv_old_ne_id1);
      WHEN 'Merge'
       THEN
          nm3undo.unmerge(p_ne_id_1 => lv_old_ne_id1
                         ,p_ne_id_2 => lv_old_ne_id2);
      WHEN 'Replace'
       THEN
          nm3undo.unreplace(p_ne_id => lv_old_ne_id1);
      WHEN 'Close'
       THEN
          /*
          ||TODO nm 4700 fix45 introduces an additional parameter that we should support but it hasn't been QA'd yet.
          */
          nm3undo.unclose(p_ne_id => lv_old_ne_id1);
          --nm3undo.unclose(p_ne_id          => lv_old_ne_id1
          --               ,p_include_datums => pi_include_datums);
      ELSE
          NULL;
    END CASE;
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
  END undo_operation;

--
-----------------------------------------------------------------------------
--
END awlrs_undo_api;
/