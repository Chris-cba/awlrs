------------------------------------------------------------------
-- awlrs1003_awlrs1004_ddl_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1003_awlrs1004_ddl_upg.sql-arc   1.1   10 May 2017 19:43:12   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrs1003_awlrs1004_ddl_upg.sql  $
--       Date into PVCS   : $Date:   10 May 2017 19:43:12  $
--       Date fetched Out : $Modtime:   10 May 2017 19:41:16  $
--       Version          : $Revision:   1.1  $
--
------------------------------------------------------------------
--  Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.

SET ECHO OFF
SET LINESIZE 120
SET HEADING OFF
SET FEEDBACK OFF
------------------------------------------------------------------
SET TERM ON
PROMPT Persistence Table FK
SET TERM OFF
ALTER TABLE AWLRS_PERSISTENCE DROP CONSTRAINT AP_FK_HUS
/

ALTER TABLE AWLRS_PERSISTENCE ADD(CONSTRAINT AP_FK_HUS FOREIGN KEY(AP_USER_ID) REFERENCES HIG_USERS(HUS_USER_ID) ON DELETE CASCADE)
/

------------------------------------------------------------------
SET TERM ON
PROMPT Saved Map Configs Table
SET TERM OFF
DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE asmc_id_seq');
EXCEPTION
 WHEN already_exists
  THEN
     NULL;
 WHEN others
  THEN
    RAISE;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_SAVED_MAP_CONFIGS'
                  ||' (ASMC_ID          NUMBER(38) NOT NULL'
                  ||' ,ASMC_USER_ID     NUMBER(9) NOT NULL'
                  ||' ,ASMC_PRODUCT     VARCHAR2(6) NOT NULL'
                  ||' ,ASMC_NAME        VARCHAR2(200) NOT NULL' 
                  ||' ,ASMC_HOME_EXTENT VARCHAR2(1) NOT NULL'
                  ||' ,ASMC_DATA        CLOB NOT NULL)'
  ;
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_SAVED_MAP_CONFIGS ADD(CONSTRAINT ASMC_PK PRIMARY KEY(ASMC_ID))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-02261);
  --
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_SAVED_MAP_CONFIGS ADD(CONSTRAINT ASMC_UK UNIQUE (ASMC_USER_ID,ASMC_PRODUCT,ASMC_NAME))';
EXCEPTION
 WHEN already_exists
  THEN
     NULL;
 WHEN others
  THEN
    RAISE;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX ASMC_FK_HUS_IND ON AWLRS_SAVED_MAP_CONFIGS(ASMC_USER_ID)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_SAVED_MAP_CONFIGS ADD (CONSTRAINT ASMC_FK_HUS FOREIGN KEY(ASMC_USER_ID) REFERENCES HIG_USERS(HUS_USER_ID) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

