-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/inv_term.sql-arc   1.0   26 Sep 2016 18:20:44   Mike.Huitson  $
--       Module Name      : $Workfile:   inv_term.sql  $
--       Date into PVCS   : $Date:   26 Sep 2016 18:20:44  $
--       Date fetched Out : $Modtime:   26 Sep 2016 12:36:32  $
--       Version          : $Revision:   1.0  $
-------------------------------------------------------------------------
--   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
UNDEFINE leave_it
COL leave_it new_value leave_it noprint
SET term ON
PROMPT
PROMPT &exor_base was specified as the exor base location.
PROMPT
PROMPT Value entered for exor base does not end with a recognised directory
PROMPT terminator. 
PROMPT
PROMPT Please re-run the installation script and enter a valid exor base value.
PROMPT
ACCEPT leave_it PROMPT "Press RETURN to exit SQL*PLUS"
PROMPT
EXIT;
