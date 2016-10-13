CREATE OR REPLACE PACKAGE BODY awlrs_close_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_close_api.pkb-arc   1.0   13 Oct 2016 09:31:20   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_close_api.pkb  $
  --       Date into PVCS   : $Date:   13 Oct 2016 09:31:20  $
  --       Date fetched Out : $Modtime:   13 Oct 2016 09:19:56  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_close_api';
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
  PROCEDURE do_close(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                    ,pi_reason           IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,pi_effective_date   IN  DATE DEFAULT TO_DATE(SYS_CONTEXT('NM3CORE','EFFECTIVE_DATE'),'DD-MON-YYYY')
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT do_close_sp;
    --
    nm3close.do_close(p_ne_id          => pi_ne_id
		                 ,p_effective_date => pi_effective_date
		                 ,p_neh_descr      => pi_reason);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
        ROLLBACK TO do_close_sp;
  END do_close;
  
END awlrs_close_api;
/
