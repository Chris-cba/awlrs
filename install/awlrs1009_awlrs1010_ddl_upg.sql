------------------------------------------------------------------
-- awlrs1009_awlrs1010_ddl_upg.sql
------------------------------------------------------------------


------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1009_awlrs1010_ddl_upg.sql-arc   1.0   Mar 08 2018 17:49:04   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrs1009_awlrs1010_ddl_upg.sql  $
--       Date into PVCS   : $Date:   Mar 08 2018 17:49:04  $
--       Date fetched Out : $Modtime:   Mar 08 2018 17:20:12  $
--       Version          : $Revision:   1.0  $
--
------------------------------------------------------------------
--  Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.

SET ECHO OFF
SET LINESIZE 120
SET HEADING OFF
SET FEEDBACK OFF
------------------------------------------------------------------
SET TERM ON
PROMPT File Attribute Map tables
SET TERM OFF
DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE affm_id_seq');
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
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_file_feature_maps'
                  ||'(affm_id          NUMBER(38)    NOT NULL'
                  ||',affm_file_descr  VARCHAR2(200) NOT NULL'
                  ||',affm_datum_nt    VARCHAR2(4)   NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_feature_maps ADD(CONSTRAINT affm_pk PRIMARY KEY(affm_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX affm_fk_nt_ind ON awlrs_file_feature_maps(affm_datum_nt)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_feature_maps ADD(CONSTRAINT affm_fk_nt FOREIGN KEY(affm_datum_nt) REFERENCES nm_types(nt_type) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE afgam_id_seq');
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
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_file_grp_attrib_map'
                  ||'(afgam_id             NUMBER(38)    NOT NULL'
                  ||',afgam_affm_id        NUMBER(38)    NOT NULL'
                  ||',afgam_target_nt      VARCHAR2(4)   NOT NULL'
                  ||',afgam_target_gty     VARCHAR2(4)   NOT NULL'
                  ||',afgam_file_attrib    VARCHAR2(30)  NOT NULL'
                  ||',afgam_target_attrib  VARCHAR2(30)  NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_grp_attrib_map ADD(CONSTRAINT afgam_pk PRIMARY KEY(afgam_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX afgam_fk_affm_ind ON awlrs_file_grp_attrib_map(afgam_affm_id)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_grp_attrib_map ADD(CONSTRAINT afgam_fk_affm FOREIGN KEY(afgam_affm_id) REFERENCES awlrs_file_feature_maps(affm_id) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX afgam_fk_nt_ind ON awlrs_file_grp_attrib_map(afgam_target_nt)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_grp_attrib_map ADD(CONSTRAINT afgam_fk_nt FOREIGN KEY(afgam_target_nt) REFERENCES nm_types(nt_type) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX afgam_fk_ngt_ind ON awlrs_file_grp_attrib_map(afgam_target_gty)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_grp_attrib_map ADD(CONSTRAINT afgam_fk_ngt FOREIGN KEY(afgam_target_gty) REFERENCES nm_group_types_all(ngt_group_type) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE afdam_id_seq');
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
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_file_datum_attrib_map'
                  ||'(afdam_id             NUMBER(38)    NOT NULL'
                  ||',afdam_affm_id        NUMBER(38)    NOT NULL'
                  ||',afdam_file_attrib    VARCHAR2(30)  NOT NULL'
                  ||',afdam_target_attrib  VARCHAR2(30)  NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_datum_attrib_map ADD(CONSTRAINT afdam_pk PRIMARY KEY(afdam_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX afdam_fk_affm_ind ON awlrs_file_datum_attrib_map(afdam_affm_id)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_file_datum_attrib_map ADD(CONSTRAINT afdam_fk_affm FOREIGN KEY(afdam_affm_id) REFERENCES awlrs_file_feature_maps(affm_id) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

