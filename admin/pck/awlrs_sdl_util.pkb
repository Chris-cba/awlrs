CREATE OR REPLACE PACKAGE BODY awlrs_sdl_util IS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       pvcsid           : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_sdl_util.pkb-arc   1.0   Mar 12 2020 20:22:54   Vikas.Mhetre  $
  --       Module Name      : $Workfile:   awlrs_sdl_util.pkb  $
  --       Date into PVCS   : $Date:   Mar 12 2020 20:22:54  $
  --       Date fetched Out : $Modtime:   Mar 12 2020 18:53:10  $
  --       PVCS Version     : $Revision:   1.0  $
  --
  --   Author : Vikas Mhetre
  --
  -----------------------------------------------------------------------------
  -- Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
  ----------------------------------------------------------------------------
  --
  g_body_sccsid    CONSTANT VARCHAR2 (2000) := '$Revision:   1.0  $';
  g_package_name   CONSTANT VARCHAR2 (30) := 'awlrs_sdl_util';
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version RETURN VARCHAR2 IS
  BEGIN
     RETURN g_sccsid;
  END get_version;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version RETURN VARCHAR2 IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE can_user_run_module(pi_module           IN  hig_modules.hmo_module%TYPE
                               ,po_message_severity OUT hig_codes.hco_code%TYPE
                               ,po_message_cursor   OUT sys_refcursor)
  IS
  --
  BEGIN
    --
    IF NOT (nm3user.user_can_run_module(p_module => pi_module))
    THEN
    --
      hig.raise_ner(pi_appl               => 'HIG'
                   ,pi_id                 => 126
                   ,pi_supplementary_info => 'Required SDL Role does not associated with the User');
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
  END can_user_run_module;
  --
  -----------------------------------------------------------------------------
  --
END awlrs_sdl_util;
/
