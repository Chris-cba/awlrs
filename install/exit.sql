-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/exit.sql-arc   1.1   02 Feb 2017 10:03:58   Mike.Huitson  $
--       Module Name      : $Workfile:   exit.sql  $
--       Date into PVCS   : $Date:   02 Feb 2017 10:03:58  $
--       Date fetched Out : $Modtime:   02 Feb 2017 09:51:20  $
--       Version          : $Revision:   1.1  $
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
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
