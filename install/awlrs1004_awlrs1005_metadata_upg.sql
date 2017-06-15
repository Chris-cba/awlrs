------------------------------------------------------------------
-- awlrs1004_awlrs1005_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1004_awlrs1005_metadata_upg.sql-arc   1.0   15 Jun 2017 19:26:42   Mike.Huitson  $
--      Module Name      : $Workfile:   awlrs1004_awlrs1005_metadata_upg.sql  $
--      Date into PVCS   : $Date:   15 Jun 2017 19:26:42  $
--      Date fetched Out : $Modtime:   15 Jun 2017 19:24:00  $
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
PROMPT New Error Message
SET TERM OFF
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,48
      ,null
      ,'Update of Start and/or End of a Member is not allowed for an Inclusion Parent Group'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 48);
------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

