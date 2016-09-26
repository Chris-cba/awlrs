-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/exit.sql-arc   1.0   26 Sep 2016 18:20:44   Mike.Huitson  $
--       Module Name      : $Workfile:   exit.sql  $
--       Date into PVCS   : $Date:   26 Sep 2016 18:20:44  $
--       Date fetched Out : $Modtime:   26 Sep 2016 10:34:10  $
--       Version          : $Revision:   1.0  $
-------------------------------------------------------------------------
--   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
UNDEFINE leave_it
COL leave_it new_value leave_it noprint
PROMPT
PROMPT
PROMPT Upgrade process aborted at user request.
PROMPT
ACCEPT leave_it PROMPT "Press RETURN to exit SQL*PLUS"
PROMPT
EXIT;
