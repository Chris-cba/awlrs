------------------------------------------------------------------
-- awlrs1010_awlrs1170_ddl_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1010_awlrs1170_ddl_upg.sql-arc   1.0   Apr 08 2019 13:44:44   Barbara.Odriscoll  $
--       Module Name      : $Workfile:   awlrs1010_awlrs1170_ddl_upg.sql  $
--       Date into PVCS   : $Date:   Apr 08 2019 13:44:44  $
--       Date fetched Out : $Modtime:   Apr 08 2019 11:46:18  $
--       Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2019 Bentley Systems Incorporated. All rights reserved.

SET ECHO OFF
SET LINESIZE 120
SET HEADING OFF
SET FEEDBACK OFF
------------------------------------------------------------------
SET TERM ON
PROMPT Metadata table for NSG Path Tool
SET TERM OFF
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_path_group_themes'
                  ||'(apgt_group_theme_name  VARCHAR2(30) NOT NULL'
                  ||',apgt_datum_theme_name  VARCHAR2(30) NOT NULL)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX apgt_fk_datum_nth_ind ON awlrs_path_group_themes(apgt_datum_theme_name)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_path_group_themes ADD(CONSTRAINT apgt_fk_datum_nth FOREIGN KEY(apgt_datum_theme_name) REFERENCES nm_themes_all(nth_theme_name))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX apgt_fk_group_nth_ind ON awlrs_path_group_themes(apgt_group_theme_name)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_path_group_themes ADD(CONSTRAINT apgt_fk_group_nth FOREIGN KEY(apgt_group_theme_name) REFERENCES nm_themes_all(nth_theme_name))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_path_group_themes ADD(CONSTRAINT apgt_pk PRIMARY KEY(apgt_group_theme_name))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

------------------------------------------------------------------
SET TERM ON
PROMPT Saved Search Table Changes
SET TERM OFF
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -1430);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_saved_search_criteria '
                  ||'ADD(assc_net_filter_ne_id     NUMBER(38) '
                     ||',assc_net_filter_nse_id    NUMBER(38) '
                     ||',assc_net_filter_marker_id NUMBER(38) '
                     ||',assc_net_filter_from      NUMBER '
                     ||',assc_net_filter_to        NUMBER) ';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/
------------------------------------------------------------------
SET TERM ON
PROMPT awlrs_plm_merge_attribs table
SET TERM OFF
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE   'CREATE TABLE AWLRS_PLM_MERGE_ATTRIBS'
                  ||'(APMA_INV_TYPE         VARCHAR2(4)   NOT NULL,'
                  ||' APMA_ATTRIB_NAME      VARCHAR2(30)  NOT NULL,'
                  ||' APMA_MRG_ATTRIB_NAME  VARCHAR2(80)  NOT NULL,'
                  ||' APMA_FUNC_SEQ_NO      NUMBER,'
                  ||' APMA_UPDATABLE        VARCHAR2(1)   DEFAULT ''N'' NOT NULL)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX APMA_NIT_FK_IND ON AWLRS_PLM_MERGE_ATTRIBS(APMA_INV_TYPE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_PLM_MERGE_ATTRIBS ADD(CONSTRAINT APMA_NIT_FK FOREIGN KEY(APMA_INV_TYPE) REFERENCES NM_INV_TYPES_ALL (NIT_INV_TYPE)ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_PLM_MERGE_ATTRIBS ADD(CONSTRAINT APMA_PK PRIMARY KEY(APMA_INV_TYPE,APMA_ATTRIB_NAME))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

------------------------------------------------------------------
SET TERM ON
PROMPT Table for Lateral Offsets
SET TERM OFF
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE nm_theme_offset_views'
                  ||'(ntov_nth_theme_id      NUMBER(38) NOT NULL'
                  ||',ntov_offset_view_name  VARCHAR2(30) NOT NULL)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE nm_theme_offset_views ADD(CONSTRAINT ntov_pk PRIMARY KEY (ntov_nth_theme_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE nm_theme_offset_views ADD(CONSTRAINT ntoc_nth_fk FOREIGN KEY (ntov_nth_theme_id) REFERENCES nm_themes_all(nth_theme_id) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

