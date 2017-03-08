-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrsdata1.sql-arc   1.6   08 Mar 2017 16:32:38   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrsdata1.sql  $
--       Date into PVCS   : $Date:   08 Mar 2017 16:32:38  $
--       Date fetched Out : $Modtime:   08 Mar 2017 16:30:32  $
--       Version          : $Revision:   1.6  $
--       Table Owner      : AWLRS_METADATA
--       Generation Date  : 08-MAR-2017 16:30
--
--   Product metadata script
--   As at Release 4.7.1.0
--
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
--   TABLES PROCESSED
--   ================
--   HIG_PRODUCTS
--   HIG_OPTION_LIST
--   HIG_OPTION_VALUES
--   HIG_SEQUENCE_ASSOCIATIONS
--   HIG_MODULES
--   NM_INV_CATEGORY_MODULES
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
      ,null
      ,null
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_PRODUCTS
                   WHERE HPR_PRODUCT = 'AWLRS');
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
