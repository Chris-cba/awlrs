------------------------------------------------------------------
-- awlrs1002_awlrs1003_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1002_awlrs1003_metadata_upg.sql-arc   1.0   08 Mar 2017 16:18:54   Mike.Huitson  $
--      Module Name      : $Workfile:   awlrs1002_awlrs1003_metadata_upg.sql  $
--      Date into PVCS   : $Date:   08 Mar 2017 16:18:54  $
--      Date fetched Out : $Modtime:   08 Mar 2017 15:28:38  $
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
PROMPT Save Search Criteria
SET TERM OFF
INSERT INTO HIG_SEQUENCE_ASSOCIATIONS
       (HSA_TABLE_NAME
       ,HSA_COLUMN_NAME
       ,HSA_SEQUENCE_NAME
       ,HSA_LAST_REBUILD_DATE
       )
SELECT 
        'AWLRS_SAVED_SEARCH_CRITERIA'
       ,'ASSC_ID'
       ,'ASSC_ID_SEQ'
       ,null FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_SAVED_SEARCH_CRITERIA'
                    AND  HSA_COLUMN_NAME = 'ASSC_ID')
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,46
      ,null
      ,'A saved search with this name already exists, would you like to overwrite it?'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 46)
/

------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

