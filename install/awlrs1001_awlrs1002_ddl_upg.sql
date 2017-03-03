------------------------------------------------------------------
-- awlrs1001_awlrs1002_ddl_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1001_awlrs1002_ddl_upg.sql-arc   1.1   03 Mar 2017 11:49:52   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrs1001_awlrs1002_ddl_upg.sql  $
--       Date into PVCS   : $Date:   03 Mar 2017 11:49:52  $
--       Date fetched Out : $Modtime:   03 Mar 2017 11:48:16  $
--       Version          : $Revision:   1.1  $
--
------------------------------------------------------------------
--	Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.

SET ECHO OFF
SET LINESIZE 120
SET HEADING OFF
SET FEEDBACK OFF
------------------------------------------------------------------
SET TERM ON
PROMPT awlrs_quick_search_columns
SET TERM OFF
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_QUICK_SEARCH_COLUMNS'
                  ||'(AQSC_THEME_NAME  VARCHAR2(30) NOT NULL'
                  ||',AQSC_COLUMN      VARCHAR2(30) NOT NULL'
                  ||',AQSC_PRIORITY    NUMBER(3)    NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_QUICK_SEARCH_COLUMNS ADD(CONSTRAINT AQSC_PK PRIMARY KEY(AQSC_THEME_NAME,AQSC_COLUMN))';
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
  EXECUTE IMMEDIATE ('ALTER TABLE AWLRS_QUICK_SEARCH_COLUMNS ADD(CONSTRAINT AQSC_UK UNIQUE(AQSC_THEME_NAME,AQSC_PRIORITY))');
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
  EXECUTE IMMEDIATE 'CREATE INDEX AQSC_FK_NTH_IND ON AWLRS_QUICK_SEARCH_COLUMNS(AQSC_THEME_NAME)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_QUICK_SEARCH_COLUMNS ADD(CONSTRAINT AQSC_FK_NTH FOREIGN KEY(AQSC_THEME_NAME) REFERENCES NM_THEMES_ALL(NTH_THEME_NAME) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

