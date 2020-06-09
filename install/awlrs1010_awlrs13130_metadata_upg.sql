------------------------------------------------------------------
-- awlrs1010_awlrs13130_metadata_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--  PVCS Identifiers :-
--
--      PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1010_awlrs13130_metadata_upg.sql-arc   1.0   Jun 09 2020 12:08:08   Peter.Bibby  $
--      Module Name      : $Workfile:   awlrs1010_awlrs13130_metadata_upg.sql  $
--      Date into PVCS   : $Date:   Jun 09 2020 12:08:08  $
--      Date fetched Out : $Modtime:   Jun 09 2020 11:52:34  $
--      Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.

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
SET TERM ON
PROMPT Distance Break Edit error message
SET TERM OFF
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,63
      ,null
      ,'Only the To Offset can be updated for a Distance Break'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 63)
/
------------------------------------------------------------------
SET TERM ON
PROMPT Asset Maintenance and SDO error messages
SET TERM OFF
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,64
      ,null
      ,'Asset Attribution Does Not Match'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 64)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,65
      ,null
      ,'Assets have locations beyond the specified element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 65)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,66
      ,null
      ,'Asset locations are not contiguous'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 66)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,67
      ,null
      ,'All assets must be of the same type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 67)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,68
      ,null
      ,'Merge of hierarchical assets is not supported'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 68)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,69
      ,null
      ,'Theme must be linear'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 69)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,70
      ,null
      ,'No path'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 70)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,71
      ,null
      ,'No network elements close enough to the xy co-ordinates'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 71)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,72
      ,null
      ,'Network not instantiated, cannot compute the connectivity'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 72)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,73
      ,null
      ,'Points are the same - no distance between them'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 73)
/
------------------------------------------------------------------
SET TERM ON
PROMPT Asset Maintenance Sequence Associations
SET TERM OFF
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_ASSET_MAINT_RESULTS'
      ,'AAMR_ID'
      ,'AAMR_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_ASSET_MAINT_RESULTS'
                     AND HSA_COLUMN_NAME = 'AAMR_ID')
/

INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_ASSET_MAINT_RESULTS'
      ,'AAMR_JOB_ID'
      ,'AAMR_JOB_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_ASSET_MAINT_RESULTS'
                     AND HSA_COLUMN_NAME = 'AAMR_JOB_ID')
/

INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_SAVED_ASSET_CRITERIA'
      ,'ASAC_ID'
      ,'ASAC_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_SAVED_ASSET_CRITERIA'
                     AND HSA_COLUMN_NAME = 'ASAC_ID')
/

------------------------------------------------------------------
SET TERM ON
PROMPT Launchpad metadata
SET TERM OFF
/*
||Launchpad headers
*/
Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_NETWORK'
      ,'Network Metadata'
      ,'F'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_NETWORK')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_ASSET'
      ,'Asset Metadata'
      ,'F'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_ASSET')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_SPATIAL'
      ,'Spatial Metadata'
      ,'F'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_SPATIAL')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_NSG'
      ,'NSG Metadata'
      ,'F'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_NSG')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_REFERENCE'
      ,'Reference Data'
      ,'F'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_REFERENCE')
/
                 
Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_SECURITY'
      ,'Security'
      ,'F'
      ,60
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_SECURITY')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_NETWORK'
      ,'NM0001'
      ,'Node Types'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_NETWORK'
                     AND HSTF_CHILD = 'NM0001')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0301'
      ,'Asset Domains'
      ,'M'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0301')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0305'
      ,'XSP and Reversal Rules'
      ,'M'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0305')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0306'
      ,'Asset XSPs'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0306')
/
      
Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG1820'
      ,'Units and Conversions'
      ,'M'
      ,70
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG1820')
/
              
Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG1837'
      ,'User Option Administration'
      ,'M'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG1837')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9120'
      ,'Domains'
      ,'M'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9120')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9130'
      ,'Product Options'
      ,'M'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9130')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9135'
      ,'Product and User Option List'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9135')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9185'
      ,'Error Messages'
      ,'M'
      ,60
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9185')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1836'
      ,'Roles'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1836')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1860'
      ,'Admin Units'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1860')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1880'
      ,'Modules'
      ,'M'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1880')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1890'
      ,'Products'
      ,'M'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1890')
/

Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1870'
      ,'Upgrades'
      ,'M'
      ,60
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1870')
/
Insert into HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG1832'
      ,'Users'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG1832')
/

------------------------------------------------------------------
SET TERM ON
PROMPT Error Message
SET TERM OFF
INSERT INTO nm_errors
   (ner_appl, ner_id, ner_her_no, ner_descr, ner_cause)
SELECT 'AWLRS'
      ,74
      ,''
      ,'Update not allowed on an end dated record'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM nm_errors
                   WHERE ner_appl = 'AWLRS'
                     AND ner_id = 74)
/
INSERT INTO nm_errors
   (ner_appl, ner_id, ner_her_no, ner_descr, ner_cause)
SELECT 'AWLRS'
      ,75
      ,''
      ,'Only one of Domain, Query, Sequence Name or Default can be specified'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM nm_errors
                   WHERE ner_appl = 'AWLRS'
                     AND ner_id = 75)
/
INSERT INTO nm_errors
   (ner_appl, ner_id, ner_her_no, ner_descr, ner_cause)
SELECT 'AWLRS'
      ,76
      ,''
      ,'The String End value must be greater than the String Start value'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM nm_errors
                   WHERE ner_appl = 'AWLRS'
                     AND ner_id = 76)
/
INSERT INTO nm_errors
   (ner_appl, ner_id, ner_her_no, ner_descr, ner_cause)
SELECT 'AWLRS'
      ,80
      ,''
      ,'When Primary is set to Y, both Single Row and Mandatory must also be set to Y'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM nm_errors
                   WHERE ner_appl = 'AWLRS'
                     AND ner_id = 80)
/
INSERT INTO nm_errors
   (ner_appl, ner_id, ner_her_no, ner_descr, ner_cause)
SELECT 'AWLRS'
      ,84
      ,''
      ,'Admin Unit Start Date cannot be earlier than the User''s Start Date'
      ,''
  FROM DUAL
WHERE NOT EXISTS(SELECT 1
                    FROM nm_errors
                   WHERE ner_appl = 'AWLRS'
                     AND ner_id = 84)
/

------------------------------------------------------------------
SET TERM ON
PROMPT New Errors for Asset Maint
SET TERM OFF
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,78
      ,null
      ,'Unable to delete asset'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 78)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,79
      ,null
      ,'Asset deleted'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 79)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,77
      ,null
      ,'Asset deletion summary'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 77)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,81
      ,null
      ,'Including Child Assets:'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 81)
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,82
      ,null
      ,'End-Dated assets cannot be merged'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 82)
/

------------------------------------------------------------------
SET TERM ON
PROMPT Additional Launchpad metadata
SET TERM OFF
INSERT INTO HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_NETWORK'
      ,'NM0002'
      ,'Network Types'
      ,'M'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_NETWORK'
                     AND HSTF_CHILD = 'NM0002')
/
INSERT INTO HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0410'
      ,'Asset Types'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0410')
/
INSERT INTO HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_NETWORK'
      ,'NM0004'
      ,'Group Types'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_NETWORK'
                     AND HSTF_CHILD = 'NM0004')
/
------------------------------------------------------------------
SET TERM ON
PROMPT Map Measure Tool Units Option
SET TERM OFF
INSERT
  INTO HIG_DOMAINS
      (HDO_DOMAIN
      ,HDO_PRODUCT
      ,HDO_TITLE
      ,HDO_CODE_LENGTH)
SELECT 'AWLMESUNIT'
      ,'AWLRS'
      ,'AWLRS Map Measure Units'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_DOMAINS
                   WHERE HDO_DOMAIN = 'AWLMESUNIT')
/

INSERT
  INTO HIG_CODES
      (HCO_DOMAIN
      ,HCO_CODE
      ,HCO_MEANING
      ,HCO_SYSTEM
      ,HCO_SEQ
      ,HCO_START_DATE
      ,HCO_END_DATE)
SELECT 'AWLMESUNIT'
      ,'IMPERIAL'
      ,'Imperial'
      ,'Y'
      ,2
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_CODES
                   WHERE HCO_DOMAIN = 'AWLMESUNIT'
                     AND HCO_CODE = 'IMPERIAL')
/

INSERT
  INTO HIG_CODES
      (HCO_DOMAIN
      ,HCO_CODE
      ,HCO_MEANING
      ,HCO_SYSTEM
      ,HCO_SEQ
      ,HCO_START_DATE
      ,HCO_END_DATE)
SELECT 'AWLMESUNIT'
      ,'METRIC'
      ,'Metric'
      ,'Y'
      ,1
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_CODES
                   WHERE HCO_DOMAIN = 'AWLMESUNIT'
                     AND HCO_CODE = 'METRIC')
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
SELECT 'AWLMESUNIT'
      ,'AWLRS'
      ,'Map Measure Units'
      ,'The default units to be used in the AWLRS Map measure tools, valid values are Metric or Imperial.'
      ,'AWLMESUNIT'
      ,'VARCHAR2'
      ,'N'
      ,'Y'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLMESUNIT')
/

INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLMESUNIT'
      ,'METRIC'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLMESUNIT')
/

INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,83
      ,null
      ,'Invalid User Option'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 83)
/

------------------------------------------------------------------
SET TERM ON
PROMPT Product Option Defaults
SET TERM OFF
UPDATE hig_option_list
  SET hol_name = 'AWLRS Maintain History Default'
     ,hol_remarks = 'When perfoming certain network operations, such as Split, Merge and Reshape, on a Datum in AWLRS the user has the option to maintain history, this option defines the default position of the switch when the dialog is displayed, when set to Y the switch will default to On otherwise it will default to Off.'
WHERE hol_id in ('AWLRECALHS')
/

UPDATE hig_option_list
  SET hol_name = 'AWLRS Rescale Default'
     ,hol_remarks = 'When perfoming certain network operations, such as Split, Merge and Reshape, on a Datum in AWLRS the user has the option to Rescale all parent groups at the end of the operation, this option defines the default position of the switch when the dialog is displayed, when set to Y the switch will default to On otherwise it will default to Off.'
WHERE hol_id in ('AWLRECALPG')
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
SELECT 'AWLRECALRE'
      ,'AWLRS'
      ,'AWLRS Replace Default'
      ,'When perfoming certain network operations, such as Split, Merge and Reshape, on a Datum in AWLRS the user has the option to Replace the Datum, this option defines the default position of the switch when the dialog is displayed, when set to Y the switch will default to On otherwise it will default to Off.'
      ,'Y_OR_N'
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,1
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLRECALRE')
/

INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLRECALRE'
      ,'N'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLRECALRE')
/
------------------------------------------------------------------
SET TERM ON
PROMPT New Error Message
SET TERM OFF
INSERT INTO nm_errors
   (ner_appl, ner_id, ner_her_no, ner_descr, ner_cause)
SELECT 'AWLRS'
      ,85
      ,''
      ,'Route is ill-formed. Please check your changes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM nm_errors
                   WHERE ner_appl = 'AWLRS'
                     AND ner_id = 85)
/
------------------------------------------------------------------
SET TERM ON
PROMPT Launchpad metadata for GIS Themes
SET TERM OFF
INSERT INTO HIG_STANDARD_FAVOURITES
   (HSTF_PARENT, HSTF_CHILD, HSTF_DESCR, HSTF_TYPE, HSTF_ORDER)
SELECT 'AWLRS_SPATIAL'
      ,'GIS0010'
      ,'GIS Themes'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SPATIAL'
                     AND HSTF_CHILD = 'GIS0010')
/

------------------------------------------------------------------
SET TERM ON
PROMPT Update Lateral Offsets Product Option
SET TERM OFF
UPDATE hig_option_list
   SET hol_remarks = 'A comma spearated list of LRMs (linear group type codes) to use to aggregate geometries before creating the offset geometry. Aggregating by an LRM can help to eliminate gaps and overlaps in the resulting geometries. A value of ''<NA>'' will result in the aggregated views not being generated.'
      ,hol_max_length = 2000
     ,hol_name = 'Lateral Offset LRMs'
 WHERE hol_id = 'AWLOFFSLRM'
/

------------------------------------------------------------------
SET TERM ON
PROMPT Additional Measure Units Domain Values
SET TERM OFF
INSERT
  INTO HIG_CODES
      (HCO_DOMAIN
      ,HCO_CODE
      ,HCO_MEANING
      ,HCO_SYSTEM
      ,HCO_SEQ
      ,HCO_START_DATE
      ,HCO_END_DATE)
SELECT 'AWLMESUNIT'
      ,'FEET'
      ,'Feet'
      ,'Y'
      ,3
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_CODES
                   WHERE HCO_DOMAIN = 'AWLMESUNIT'
                     AND HCO_CODE = 'FEET')
/

INSERT
  INTO HIG_CODES
      (HCO_DOMAIN
      ,HCO_CODE
      ,HCO_MEANING
      ,HCO_SYSTEM
      ,HCO_SEQ
      ,HCO_START_DATE
      ,HCO_END_DATE)
SELECT 'AWLMESUNIT'
      ,'MILES'
      ,'Miles'
      ,'Y'
      ,4
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_CODES
                   WHERE HCO_DOMAIN = 'AWLMESUNIT'
                     AND HCO_CODE = 'MILES')
/

INSERT
  INTO HIG_CODES
      (HCO_DOMAIN
      ,HCO_CODE
      ,HCO_MEANING
      ,HCO_SYSTEM
      ,HCO_SEQ
      ,HCO_START_DATE
      ,HCO_END_DATE)
SELECT 'AWLMESUNIT'
      ,'METERS'
      ,'Meters'
      ,'Y'
      ,5
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_CODES
                   WHERE HCO_DOMAIN = 'AWLMESUNIT'
                     AND HCO_CODE = 'METERS')
/

INSERT
  INTO HIG_CODES
      (HCO_DOMAIN
      ,HCO_CODE
      ,HCO_MEANING
      ,HCO_SYSTEM
      ,HCO_SEQ
      ,HCO_START_DATE
      ,HCO_END_DATE)
SELECT 'AWLMESUNIT'
      ,'KILOMETERS'
      ,'Kilometers'
      ,'Y'
      ,6
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_CODES
                   WHERE HCO_DOMAIN = 'AWLMESUNIT'
                     AND HCO_CODE = 'KILOMETERS')
/

------------------------------------------------------------------
Commit;

------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

