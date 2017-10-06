------------------------------------------------------------------
-- awlrs1007_awlrs1008_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1007_awlrs1008_metadata_upg.sql-arc   1.0   Oct 06 2017 09:30:20   Peter.Bibby  $
--      Module Name      : $Workfile:   awlrs1007_awlrs1008_metadata_upg.sql  $
--      Date into PVCS   : $Date:   Oct 06 2017 09:30:20  $
--      Date fetched Out : $Modtime:   Oct 06 2017 09:01:54  $
--      Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.

SET ECHO OFF
SET LINESIZE 120
SET HEADING OFF
SET FEEDBACK OFF

DECLARE
  l_temp nm3type.max_varchar2;
BEGIN
  -- Dummy call to HIG to instantiate it
  l_temp := hig.get_version;
  l_temp := nm_debug.get_version;
EXCEPTION
  WHEN others
   THEN
 Null;
END;
/

BEGIN
  nm_debug.debug_off;
END;
/

------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

