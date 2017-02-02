CREATE OR REPLACE PACKAGE BODY awlrs_close_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_close_api.pkb-arc   1.4   02 Feb 2017 10:02:10   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_close_api.pkb  $
  --       Date into PVCS   : $Date:   02 Feb 2017 10:02:10  $
  --       Date fetched Out : $Modtime:   02 Feb 2017 09:50:24  $
  --       Version          : $Revision:   1.4  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.4  $';

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
    DECLARE
      e_record_locked EXCEPTION;
			PRAGMA exception_init(e_record_locked, -54);
    BEGIN
      nm3close.do_close(p_ne_id          => pi_ne_id
		                   ,p_effective_date => pi_effective_date
		                   ,p_neh_descr      => pi_reason);
    EXCEPTION
      WHEN e_record_locked
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33); 
    END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO do_close_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_close;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE close_group(pi_ne_id            IN  nm_elements.ne_id%TYPE
                       ,pi_effective_date   IN  DATE      
                       ,pi_close_all        IN  VARCHAR2 DEFAULT 'N'
                       ,pi_end_date_datums  IN  VARCHAR2
                       ,po_message_severity OUT hig_codes.hco_code%TYPE
                       ,po_message_cursor   OUT sys_refcursor)
    IS
    --
  BEGIN
    /*
    ||Set a save point.
    */
    SAVEPOINT enddate_group_sp;
    --
    DECLARE
      --
      e_route_locked EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_route_locked, -54);
      e_end_date EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_end_date, -20984);
      --  
    BEGIN
      nm3close.multi_element_close(pi_type            => nm3close.get_c_route
                                  ,pi_id              => pi_ne_id
                                  ,pi_effective_date  => TRUNC(pi_effective_date)
                                  ,pi_close_all       => pi_close_all
                                  ,pi_end_date_datums => pi_end_date_datums);
    EXCEPTION
      WHEN e_route_locked
        THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33); 
      WHEN e_end_date
        THEN
          hig.raise_ner(pi_appl => 'NET'
                       ,pi_id   => 13); 
    END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        ROLLBACK TO enddate_group_sp;
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END close_group;

END awlrs_close_api;
/
