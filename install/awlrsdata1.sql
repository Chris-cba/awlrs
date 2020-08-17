-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrsdata1.sql-arc   1.23   Aug 17 2020 13:00:12   Peter.Bibby  $
--       Module Name      : $Workfile:   awlrsdata1.sql  $
--       Date into PVCS   : $Date:   Aug 17 2020 13:00:12  $
--       Date fetched Out : $Modtime:   Aug 17 2020 11:27:06  $
--       Version          : $Revision:   1.23  $
--       Table Owner      : AWLRS_METADATA
--       Generation Date  : 17-AUG-2020 11:27
--
--   Product metadata script
--   As at Release 4.7.1.0
--
-------------------------------------------------------------------------
--   Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
--   TABLES PROCESSED
--   ================
--   HIG_PRODUCTS
--   HIG_DOMAINS
--   HIG_CODES
--   HIG_OPTION_LIST
--   HIG_OPTION_VALUES
--   HIG_SEQUENCE_ASSOCIATIONS
--   HIG_MODULES
--   NM_INV_CATEGORY_MODULES
--   AWLRS_FAV_ENTITY_TYPES
--   AWLRS_FAV_ENTITY_TYPE_LABELS
--
-----------------------------------------------------------------------------
--
SET define OFF;
SET feedback OFF;
---------------------------------
-- START OF GENERATED METADATA --
---------------------------------
--
----------------------------------------------------------------------------------------
-- HIG_PRODUCTS
--
-- select * from awlrs_metadata.hig_products
-- order by hpr_product
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_products
SET TERM OFF
--
INSERT
  INTO HIG_PRODUCTS
      (HPR_PRODUCT
      ,HPR_PRODUCT_NAME
      ,HPR_VERSION
      ,HPR_PATH_NAME
      ,HPR_KEY
      ,HPR_SEQUENCE)
SELECT 'AWLRS'
      ,'AW ALIM Linear Referencing Services'
      ,'1.0.0.0'
      ,''
      ,65
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_PRODUCTS
                   WHERE HPR_PRODUCT = 'AWLRS');
--
----------------------------------------------------------------------------------------
-- HIG_DOMAINS
--
-- select * from awlrs_metadata.hig_domains
-- order by hdo_domain
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_domains
SET TERM OFF
--
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
                   WHERE HDO_DOMAIN = 'AWLMESUNIT');
--
----------------------------------------------------------------------------------------
-- HIG_CODES
--
-- select * from awlrs_metadata.hig_codes
-- order by hco_domain
--         ,hco_code
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_codes
SET TERM OFF
--
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
                     AND HCO_CODE = 'FEET');
--
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
                     AND HCO_CODE = 'IMPERIAL');
--
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
                     AND HCO_CODE = 'KILOMETERS');
--
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
                     AND HCO_CODE = 'METERS');
--
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
                     AND HCO_CODE = 'METRIC');
--
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
                     AND HCO_CODE = 'MILES');
--
----------------------------------------------------------------------------------------
-- HIG_OPTION_LIST
--
-- select * from awlrs_metadata.hig_option_list
-- order by hol_id
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_option_list
SET TERM OFF
--
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
SELECT 'AWLFAVNAME'
      ,'AWLRS'
      ,'Favourites Root Folder'
      ,'The name displayed for the Favourites root folder.'
      ,''
      ,'VARCHAR2'
      ,'Y'
      ,'Y'
      ,100
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLFAVNAME');
--
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
SELECT 'AWLMAPDBUG'
      ,'AWLRS'
      ,'Mapserver Debug'
      ,'When set to Y the generated map file will contain the MS_ERRORFILE paramater that causes a log file to be generated by Mapserver.'
      ,'Y_OR_N'
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,1
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLMAPDBUG');
--
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
SELECT 'AWLMAPEPSG'
      ,'AWLRS'
      ,'AWLRS Map Output Projection'
      ,'The EPSG output projection to use for any AWLRS Maps.'
      ,''
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLMAPEPSG');
--
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
SELECT 'AWLMAPNAME'
      ,'AWLRS'
      ,'AWLRS Map Name'
      ,'The name of the base map to be used by AWLRS.'
      ,''
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLMAPNAME');
--
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
SELECT 'AWLMAPSRID'
      ,'AWLRS'
      ,'AWLRS Map Default SRID'
      ,'The default SRID to be used when generating the map file for any AWLRS maps if no SRID has been set for the spatial tables.'
      ,''
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLMAPSRID');
--
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
                   WHERE HOL_ID = 'AWLMESUNIT');
--
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
      ,'Lateral Offset LRMs'
      ,'A comma spearated list of LRMs (linear group type codes) to use to aggregate geometries before creating the offset geometry. Aggregating by an LRM can help to eliminate gaps and overlaps in the resulting geometries. A value of ''<NA>'' will result in the aggregated views not being generated.'
      ,''
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,2000
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLOFFSLRM');
--
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
                   WHERE HOL_ID = 'AWLPTHMINB');
--
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
                   WHERE HOL_ID = 'AWLPTHPERC');
--
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
      ,'AWLRS Maintain History Default'
      ,'When perfoming certain network operations, such as Split, Merge and Reshape, on a Datum in AWLRS the user has the option to maintain history, this option defines the default position of the switch when the dialog is displayed, when set to Y the switch will default to On otherwise it will default to Off.'
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
      ,'AWLRS Rescale Default'
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
--
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
                   WHERE HOL_ID = 'AWLRECALRE');
--
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
SELECT 'AWLUIDBUG'
      ,'AWLRS'
      ,'UI Debug'
      ,'When set to Y the full error stack, backtrace and call stack will be returned to the UI for any handled exceptions.'
      ,'Y_OR_N'
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,1
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWLUIDBUG');
--
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
SELECT 'AWL_RCMRGQ'
      ,'AWLRS'
      ,'Pavement Cons Merge Query'
      ,'ID of merge query used to generate Pavement construction data.'
      ,''
      ,'VARCHAR2'
      ,'N'
      ,'N'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_LIST
                   WHERE HOL_ID = 'AWL_RCMRGQ');
--
----------------------------------------------------------------------------------------
-- HIG_OPTION_VALUES
--
-- select * from awlrs_metadata.hig_option_values
-- order by hov_id
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_option_values
SET TERM OFF
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLFAVNAME'
      ,'Favorites'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLFAVNAME');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLMAPDBUG'
      ,'N'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLMAPDBUG');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLMAPEPSG'
      ,'<PLEASE SET>'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLMAPEPSG');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLMAPNAME'
      ,'AWLRS_MAP'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLMAPNAME');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLMAPSRID'
      ,'<PLEASE SET>'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLMAPSRID');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLMESUNIT'
      ,'METRIC'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLMESUNIT');
--
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
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLPTHMINB'
      ,'1000'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLPTHMINB');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLPTHPERC'
      ,'20'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLPTHPERC');
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
--
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
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLRECALRE'
      ,'N'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLRECALRE');
--
INSERT
  INTO HIG_OPTION_VALUES
      (HOV_ID
      ,HOV_VALUE)
SELECT 'AWLUIDBUG'
      ,'N'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_OPTION_VALUES
                   WHERE HOV_ID = 'AWLUIDBUG');
--
----------------------------------------------------------------------------------------
-- HIG_SEQUENCE_ASSOCIATIONS
--
-- select * from awlrs_metadata.hig_sequence_associations
-- order by hsa_table_name
--         ,hsa_column_name
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_sequence_associations
SET TERM OFF
--
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
                     AND HSA_COLUMN_NAME = 'AAMR_ID');
--
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
                     AND HSA_COLUMN_NAME = 'AAMR_JOB_ID');
--
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
                     AND HSA_COLUMN_NAME = 'AEL_ID');
--
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
                     AND HSA_COLUMN_NAME = 'AELP_ID');
--
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_FAVOURITES_ENTITIES'
      ,'AFE_AF_ID'
      ,'AF_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_FAVOURITES_ENTITIES'
                     AND HSA_COLUMN_NAME = 'AFE_AF_ID');
--
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_FAVOURITES_FOLDERS'
      ,'AFF_AF_ID'
      ,'AF_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_FAVOURITES_FOLDERS'
                     AND HSA_COLUMN_NAME = 'AFF_AF_ID');
--
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
--
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_PERSISTENCE'
      ,'AP_ID'
      ,'AP_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_PERSISTENCE'
                     AND HSA_COLUMN_NAME = 'AP_ID');
--
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
                     AND HSA_COLUMN_NAME = 'ASAC_ID');
--
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
                     AND HSA_COLUMN_NAME = 'ASMC_ID');
--
INSERT
  INTO HIG_SEQUENCE_ASSOCIATIONS
      (HSA_TABLE_NAME
      ,HSA_COLUMN_NAME
      ,HSA_SEQUENCE_NAME
      ,HSA_LAST_REBUILD_DATE)
SELECT 'AWLRS_SAVED_SEARCH_CRITERIA'
      ,'ASSC_ID'
      ,'ASSC_ID_SEQ'
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_SEQUENCE_ASSOCIATIONS
                   WHERE HSA_TABLE_NAME = 'AWLRS_SAVED_SEARCH_CRITERIA'
                     AND HSA_COLUMN_NAME = 'ASSC_ID');
--
----------------------------------------------------------------------------------------
-- HIG_MODULES
--
-- select * from awlrs_metadata.hig_modules
-- order by hmo_module
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_modules
SET TERM OFF
--
INSERT
  INTO HIG_MODULES
      (HMO_MODULE
      ,HMO_TITLE
      ,HMO_FILENAME
      ,HMO_MODULE_TYPE
      ,HMO_FASTPATH_OPTS
      ,HMO_FASTPATH_INVALID
      ,HMO_USE_GRI
      ,HMO_APPLICATION
      ,HMO_MENU)
SELECT 'AWLRS0001'
      ,'AW ALIM Linear Referencing Services'
      ,'awlrs0001'
      ,'WEB'
      ,''
      ,'Y'
      ,'N'
      ,'AWLRS'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_MODULES
                   WHERE HMO_MODULE = 'AWLRS0001');
--
----------------------------------------------------------------------------------------
-- NM_INV_CATEGORY_MODULES
--
-- select * from awlrs_metadata.nm_inv_category_modules
-- order by icm_nic_category
--         ,icm_hmo_module
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT nm_inv_category_modules
SET TERM OFF
--
INSERT
  INTO NM_INV_CATEGORY_MODULES
      (ICM_NIC_CATEGORY
      ,ICM_HMO_MODULE
      ,ICM_UPDATABLE)
SELECT 'I'
      ,'AWLRS0001'
      ,'Y'
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_INV_CATEGORY_MODULES
                   WHERE ICM_NIC_CATEGORY = 'I'
                     AND ICM_HMO_MODULE = 'AWLRS0001');
--
----------------------------------------------------------------------------------------
-- AWLRS_FAV_ENTITY_TYPES
--
-- select * from awlrs_metadata.awlrs_fav_entity_types
-- order by afet_entity_type
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT awlrs_fav_entity_types
SET TERM OFF
--
INSERT
  INTO AWLRS_FAV_ENTITY_TYPES
      (AFET_ENTITY_TYPE
      ,AFET_DISPLAY_NAME
      ,AFET_TABLE_NAME
      ,AFET_PK_COLUMN)
SELECT 'ASSET'
      ,'Asset'
      ,''
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM AWLRS_FAV_ENTITY_TYPES
                   WHERE AFET_ENTITY_TYPE = 'ASSET');
--
INSERT
  INTO AWLRS_FAV_ENTITY_TYPES
      (AFET_ENTITY_TYPE
      ,AFET_DISPLAY_NAME
      ,AFET_TABLE_NAME
      ,AFET_PK_COLUMN)
SELECT 'NETWORK'
      ,'Network'
      ,''
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM AWLRS_FAV_ENTITY_TYPES
                   WHERE AFET_ENTITY_TYPE = 'NETWORK');
--
----------------------------------------------------------------------------------------
-- AWLRS_FAV_ENTITY_TYPE_LABELS
--
-- select * from awlrs_metadata.awlrs_fav_entity_type_labels
-- order by afetl_entity_type
--         ,afetl_label_column
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT awlrs_fav_entity_type_labels
SET TERM OFF
--
----------------------------------------------------------------------------------------
--
COMMIT;
--
SET feedback ON
SET define ON
--
-------------------------------
-- END OF GENERATED METADATA --
-------------------------------
--
