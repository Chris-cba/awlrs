------------------------------------------------------------------
-- awlrs1002_awlrs1003_ddl_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1002_awlrs1003_ddl_upg.sql-arc   1.0   08 Mar 2017 16:18:52   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrs1002_awlrs1003_ddl_upg.sql  $
--       Date into PVCS   : $Date:   08 Mar 2017 16:18:52  $
--       Date fetched Out : $Modtime:   08 Mar 2017 15:28:38  $
--       Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.

SET ECHO OFF
SET LINESIZE 120
SET HEADING OFF
SET FEEDBACK OFF
------------------------------------------------------------------
SET TERM ON
PROMPT Save Search Criteria
SET TERM OFF
DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE assc_id_seq');
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
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_SAVED_SEARCH_CRITERIA'
                  ||'(ASSC_ID          NUMBER(38) NOT NULL'
                  ||',ASSC_USER_ID     NUMBER(9) NOT NULL'
                  ||',ASSC_THEME_NAME  VARCHAR2(30) NOT NULL'
                  ||',ASSC_NAME        VARCHAR2(200) NOT NULL'
                  ||',ASSC_DESCRIPTION VARCHAR2(1000)'
                  ||',ASSC_CRITERIA    XMLTYPE NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_SAVED_SEARCH_CRITERIA ADD(CONSTRAINT ASSC_PK PRIMARY KEY(ASSC_ID))';
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
  EXECUTE IMMEDIATE ('ALTER TABLE AWLRS_SAVED_SEARCH_CRITERIA ADD(CONSTRAINT ASSC_UK UNIQUE(ASSC_USER_ID,ASSC_NAME))');
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
  EXECUTE IMMEDIATE 'CREATE INDEX ASSC_FK_HUS_IND ON AWLRS_SAVED_SEARCH_CRITERIA(ASSC_USER_ID)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_SAVED_SEARCH_CRITERIA ADD(CONSTRAINT ASSC_FK_HUS FOREIGN KEY(ASSC_USER_ID) REFERENCES HIG_USERS(HUS_USER_ID) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX ASSC_FK_NTH_IND ON AWLRS_SAVED_SEARCH_CRITERIA(ASSC_THEME_NAME)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_SAVED_SEARCH_CRITERIA ADD(CONSTRAINT ASSC_FK_NTH FOREIGN KEY(ASSC_THEME_NAME) REFERENCES NM_THEMES_ALL(NTH_THEME_NAME) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

