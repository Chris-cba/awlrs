------------------------------------------------------------------
-- awlrs1001_awlrs1002_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1001_awlrs1002_metadata_upg.sql-arc   1.1   03 Mar 2017 11:49:54   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrs1001_awlrs1002_metadata_upg.sql  $
--       Date into PVCS   : $Date:   03 Mar 2017 11:49:54  $
--       Date fetched Out : $Modtime:   03 Mar 2017 11:48:22  $
--       Version          : $Revision:   1.1  $
--
------------------------------------------------------------------
--	Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.

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
PROMPT nm_errors
SET TERM OFF
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,42
      ,null
      ,'Please provide either a measure or a node id.'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 42)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,43
      ,null
      ,'Invalid filter function'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 43)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,44
      ,null
      ,'Please specify a search string'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 44)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,45
      ,null
      ,'Two values must be supplied for filter function'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 45)
/


------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

