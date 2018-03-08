------------------------------------------------------------------
-- awlrs1009_awlrs1010_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1009_awlrs1010_metadata_upg.sql-arc   1.0   Mar 08 2018 17:49:04   Mike.Huitson  $
--      Module Name      : $Workfile:   awlrs1009_awlrs1010_metadata_upg.sql  $
--      Date into PVCS   : $Date:   Mar 08 2018 17:49:04  $
--      Date fetched Out : $Modtime:   Mar 08 2018 17:20:12  $
--      Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.

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
PROMPT Sequence Associations
SET TERM OFF
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_FILE_DATUM_ATTRIB_MAP'
      ,'AFDAM_ID'
      ,'AFDAM_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_FILE_DATUM_ATTRIB_MAP'
                     AND HSA_COLUMN_NAME = 'AFDAM_ID');
--
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_FILE_FEATURE_MAPS'
      ,'AFFM_ID'
      ,'AFFM_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_FILE_FEATURE_MAPS'
                     AND HSA_COLUMN_NAME = 'AFFM_ID');
--
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_FILE_GRP_ATTRIB_MAP'
      ,'AFGAM_ID'
      ,'AFGAM_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_FILE_GRP_ATTRIB_MAP'
                     AND HSA_COLUMN_NAME = 'AFGAM_ID');
------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

