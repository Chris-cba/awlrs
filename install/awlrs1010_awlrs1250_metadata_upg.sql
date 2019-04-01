------------------------------------------------------------------
-- awlrs1010_awlrs1250_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1010_awlrs1250_metadata_upg.sql-arc   1.0   Apr 01 2019 14:25:44   Mike.Huitson  $
--      Module Name      : $Workfile:   awlrs1010_awlrs1250_metadata_upg.sql  $
--      Date into PVCS   : $Date:   Apr 01 2019 14:25:44  $
--      Date fetched Out : $Modtime:   Apr 01 2019 13:42:24  $
--      Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2019 Bentley Systems Incorporated. All rights reserved.

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
PROMPT NSG Pathing Tool APIs
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
SELECT 'AWLPTHMINB'
      ,'AWLRS'
      ,'Path Buffer Min Size'
      ,'The minimum size (in Metres) of the buffer around the mbr of the two points used to generate a path when building a list of potential candidate network elements.'
      ,''
      ,'NUMBER'
      ,'N'
      ,'N'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLPTHMINB')
/

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
SELECT 'AWLPTHPERC'
      ,'AWLRS'
      ,'Path Buffer Percentage'
      ,'The percentage by which to increase the mbr of the two points used to generate a path when building a list of potential candidate network elements.'
      ,''
      ,'NUMBER'
      ,'N'
      ,'N'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLPTHPERC')
/

INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLPTHMINB'
      ,'1000'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLPTHMINB')
/

INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLPTHPERC'
      ,'20'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLPTHPERC')
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,53
      ,null
      ,'Unable to derive a Datum Theme for the given Group Theme'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 53)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,54
      ,null
      ,'Unable to derive a Group Type for Theme'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 54)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,55
      ,null
      ,'Group Type For Theme must be non linear'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 55)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,56
      ,null
      ,'The Group Type for the given Theme and Element must be the same'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 56)
/

------------------------------------------------------------------
SET TERM ON
PROMPT hig_sequence_associations amendment
SET TERM OFF
UPDATE hig_sequence_associations
  SET hsa_table_name = 'AWLRS_FILE_FEATURE_MAPS'
  WHERE hsa_table_name = 'AWLRS_FILE_FEATURE_MAP';
------------------------------------------------------------------
SET TERM ON
PROMPT PLM errors and product option
SET TERM OFF
INSERT
  INTO HIG_OPTION_LIST
   (HOL_ID, HOL_PRODUCT, HOL_NAME, HOL_REMARKS, HOL_DOMAIN, 
    HOL_DATATYPE, HOL_MIXED_CASE, HOL_USER_OPTION, HOL_MAX_LENGTH)
SELECT  'AWL_RCMRGQ', 'AWLRS', 'Pavement Cons Merge Query', 'ID of merge query used to generate Pavement construction data.', NULL, 
    'VARCHAR2', 'N', 'N', 50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWL_RCMRGQ'
                     AND HOL_PRODUCT = 'AWLRS');  
/*
||Error Messages
*/
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,57
      ,null
      ,'Region of interest contains no datum elements'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 57);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,58
      ,null
      ,'Column not defined in pavement construction attributes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 58);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,59
      ,null
      ,'Column defined more than once in pavement construction attributes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 59);
------------------------------------------------------------------
SET TERM ON
PROMPT Product Option For Lateral Offsets
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
SELECT 'AWLOFFSLRM'
      ,'AWLRS'
      ,'Lateral Offset LRM'
      ,'The LRM to use to aggregate geometries before creating the offset geometry. Aggregating by an LRM can help to eliminate gaps and overlaps in the resulting geometries. A value of ''<NA>'' will result in the aggregated views not being generated'
      ,''
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,4
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLOFFSLRM');

INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLOFFSLRM'
      ,'<NA>'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLOFFSLRM');
------------------------------------------------------------------
SET TERM ON
PROMPT Product Option for Rescale All Parents Default
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
SELECT 'AWLRECALPG'
      ,'AWLRS'
      ,'AWLRS Recalibrate All Parents'
      ,'When perfoming certain network operations, such as Split, Merge and Reshape, on a Datum in AWLRS the user has the option to Rescale all parent groups at the end of the operation, this option defines the default position of the switch when the dialog is displayed, when set to Y the switch will default to On otherwise it will default to Off.'
      ,'Y_OR_N'
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,1
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLRECALPG');

INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLRECALPG'
      ,'N'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLRECALPG');

------------------------------------------------------------------
SET TERM ON
PROMPT New Error Messages
SET TERM OFF
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,60
      ,null
      ,'Network Element belongs to a Circular Route, please retry with Rescale All set to "Off" and manually run Rescale for the relevant groups'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 60)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,61
      ,null
      ,'Network Element belongs to a Circular Route, please retry with Maintain History set to "Off" and manually run Rescale for the relevant groups'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 61)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,62
      ,null
      ,'Unable to derive datatype of column'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 62)
/

------------------------------------------------------------------
SET TERM ON
PROMPT Sequence associations for external links
SET TERM OFF
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_EXTERNAL_LINKS'
      ,'AEL_ID'
      ,'AEL_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_EXTERNAL_LINKS'
                     AND HSA_COLUMN_NAME = 'AEL_ID')
/

INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_EXTERNAL_LINK_PARAMS'
      ,'AELP_ID'
      ,'AELP_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_EXTERNAL_LINK_PARAMS'
                     AND HSA_COLUMN_NAME = 'AELP_ID')
/

------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

