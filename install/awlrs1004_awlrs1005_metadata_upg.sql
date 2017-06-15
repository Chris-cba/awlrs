------------------------------------------------------------------
-- awlrs1004_awlrs1005_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1004_awlrs1005_metadata_upg.sql-arc   1.1   15 Jun 2017 21:51:48   Mike.Huitson  $
--      Module Name      : $Workfile:   awlrs1004_awlrs1005_metadata_upg.sql  $
--      Date into PVCS   : $Date:   15 Jun 2017 21:51:48  $
--      Date fetched Out : $Modtime:   15 Jun 2017 21:49:12  $
--      Version          : $Revision:   1.1  $
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
SET TERM ON
PROMPT Product Option AWLRECALHS
SET TERM OFF
INSERT
  INTO HIG_OPTION_LIST
      (HOL_ID
      ,HOL_PRODUCT
      ,HOL_NAME
      ,HOL_REMARKS
      ,HOL_DOMAIN
      ,HOL_DATATYPE
      ,HOL_MIXED_CASE
      ,HOL_USER_OPTION
      ,HOL_MAX_LENGTH)
SELECT 'AWLRECALHS'
      ,'AWLRS'
      ,'AWLRS Recalibrate With History'
      ,'When recaibrating a Datum in AWLRS the user has the option to maintain history, this option defines the default position of the switch when the dialog is displayed, when set to Y the switch will default to On otherwise it will default to Off.'
      ,'Y_OR_N'
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,1
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLRECALHS');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLRECALHS'
      ,'Y'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLRECALHS');
------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

