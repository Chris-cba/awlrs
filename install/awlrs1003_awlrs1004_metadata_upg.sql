------------------------------------------------------------------
-- awlrs1003_awlrs1004_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1003_awlrs1004_metadata_upg.sql-arc   1.0   04 May 2017 13:56:22   Mike.Huitson  $
--      Module Name      : $Workfile:   awlrs1003_awlrs1004_metadata_upg.sql  $
--      Date into PVCS   : $Date:   04 May 2017 13:56:22  $
--      Date fetched Out : $Modtime:   04 May 2017 13:52:56  $
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
SET TERM ON
PROMPT Saved Map Configs
SET TERM OFF
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_SAVED_MAP_CONFIGS'
      ,'ASMC_ID'
      ,'ASMC_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_SAVED_MAP_CONFIGS'
                     AND HSA_COLUMN_NAME = 'ASMC_ID')
/

------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

