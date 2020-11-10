------------------------------------------------------------------
-- awlrs1010_awlrs12160_ddl_upg.sql
------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1010_awlrs12160_ddl_upg.sql-arc   1.0   Nov 10 2020 13:34:20   Barbara.Odriscoll  $
--       Date into PVCS   : $Date:   Nov 10 2020 13:34:20  $
--       Module Name      : $Workfile:   awlrs1010_awlrs12160_ddl_upg.sql  $
--       Date fetched Out : $Modtime:   Nov 10 2020 11:58:14  $
--       Version          : $Revision:   1.0  $
--
-----------------------------------------------------------------------------------
-- Copyright (c) 2020 Bentley Systems Incorporated.  All rights reserved.
-----------------------------------------------------------------------------------
--
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
SET TERM ON
PROMPT AWLRS External Links
SET TERM OFF
DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE ael_id_seq');
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
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE aelp_id_seq');
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
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_external_links'
                  ||'(ael_id            NUMBER(38)     NOT NULL'
                  ||',ael_name          VARCHAR2(100)  NOT NULL'
                  ||',ael_url_template  VARCHAR2(1000) NOT NULL)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_external_links ADD(CONSTRAINT ael_pk PRIMARY KEY (ael_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX ael_uk ON awlrs_external_links(ael_name)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_external_link_params'
                  ||'(aelp_id                NUMBER(38)   NOT NULL'
                  ||',aelp_ael_id            NUMBER(38)   NOT NULL'
                  ||',aelp_entity_type       VARCHAR2(10) NOT NULL'
                  ||',aelp_entity_type_type  VARCHAR2(4)  NOT NULL'
                  ||',aelp_sequence          NUMBER(38)   NOT NULL'
                  ||',aelp_source_type       VARCHAR2(10) NOT NULL'
                  ||',aelp_source            VARCHAR2(1000) NOT NULL'
                  ||',aelp_default_value     VARCHAR2(1000))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_external_link_params ADD(CONSTRAINT aelp_pk PRIMARY KEY (aelp_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX aelp_uk ON awlrs_external_link_params(aelp_ael_id,aelp_entity_type,aelp_entity_type_type,aelp_sequence)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX aelp_ind1 ON awlrs_external_link_params(aelp_entity_type,aelp_entity_type_type)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

------------------------------------------------------------------
SET TERM ON
PROMPT Asset Maintenance Tables
SET TERM OFF
DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE AAMR_ID_SEQ');
EXCEPTION
 WHEN already_exists
  THEN
     NULL;
END;
/

DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE AAMR_JOB_ID_SEQ');
EXCEPTION
 WHEN already_exists
  THEN
     NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_asset_maint_results'
                  ||'(aamr_id          NUMBER(38)  NOT NULL'
                  ||',aamr_job_id      NUMBER(38)  NOT NULL'
                  ||',aamr_inv_type    VARCHAR2(4) NOT NULL'
                  ||',aamr_iit_ne_id   NUMBER(38)  NOT NULL'
                  ||',aamr_ne_id       NUMBER(38)'
                  ||',aamr_from_offset NUMBER'
                  ||',aamr_to_offset   NUMBER)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_asset_maint_results ADD(CONSTRAINT aamr_pk PRIMARY KEY (aamr_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX aamr_ind_1 ON awlrs_asset_maint_results(aamr_job_id)';
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
  EXECUTE IMMEDIATE('CREATE SEQUENCE ASAC_ID_SEQ');
EXCEPTION
 WHEN already_exists
  THEN
     NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE awlrs_saved_asset_criteria'
                  ||'(asac_id          NUMBER(38) NOT NULL'
                  ||',asac_name        VARCHAR2(200) NOT NULL'
                  ||',asac_description VARCHAR2(1000)'
                  ||',asac_criteria    XMLTYPE NOT NULL)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2260);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE awlrs_saved_asset_criteria ADD(CONSTRAINT asac_pk PRIMARY KEY (asac_id))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX aamr_ind_uk ON awlrs_saved_asset_criteria(asac_name)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/
------------------------------------------------------------------
SET TERM ON
PROMPT Favourites Tables
SET TERM OFF
/*
||Favourites Entity Types
*/
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_FAV_ENTITY_TYPES'
                  ||'(AFET_ENTITY_TYPE  VARCHAR2(100) NOT NULL'
                  ||',AFET_DISPLAY_NAME VARCHAR2(100) NOT NULL'
                  ||',AFET_TABLE_NAME   VARCHAR2(30)'
                  ||',AFET_PK_COLUMN    VARCHAR2(30))'
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
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAV_ENTITY_TYPES ADD(CONSTRAINT AFET_PK PRIMARY KEY(AFET_ENTITY_TYPE))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX AFET_IND_UK ON AWLRS_FAV_ENTITY_TYPES(AFET_DISPLAY_NAME)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


/*
||Favourites Entity Type Labels
*/
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_FAV_ENTITY_TYPE_LABELS'
                  ||'(AFETL_ENTITY_TYPE     VARCHAR2(100) NOT NULL'
                  ||',AFETL_ENTITY_SUB_TYPE VARCHAR2(100)'
                  ||',AFETL_SEQ_NO          NUMBER(38)    NOT NULL'
                  ||',AFETL_LABEL_COLUMN    VARCHAR2(30)  NOT NULL'
                  ||',AFETL_LABEL_SEPARATOR VARCHAR2(5)   NOT NULL)'
  ;
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX AFETL_IND_UK ON AWLRS_FAV_ENTITY_TYPE_LABELS(AFETL_ENTITY_TYPE,AFETL_ENTITY_SUB_TYPE,AFETL_LABEL_COLUMN)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX AFETL_FK_AFET_IND ON AWLRS_FAV_ENTITY_TYPE_LABELS(AFETL_ENTITY_TYPE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAV_ENTITY_TYPE_LABELS ADD(CONSTRAINT AFETL_FK_AFET FOREIGN KEY(AFETL_ENTITY_TYPE) REFERENCES AWLRS_FAV_ENTITY_TYPES(AFET_ENTITY_TYPE) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


/*
||Favourites Folders
*/
DECLARE
  --
  already_exists  EXCEPTION;
  PRAGMA exception_init(already_exists,-955);
  --
BEGIN
  EXECUTE IMMEDIATE('CREATE SEQUENCE AF_ID_SEQ');
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
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_FAVOURITES_FOLDERS'
                  ||'(AFF_AF_ID        NUMBER(38)    NOT NULL'
                  ||',AFF_PARENT_AF_ID NUMBER(38)'
                  ||',AFF_USER_ID      NUMBER(38)    NOT NULL'
                  ||',AFF_PRODUCT      VARCHAR2(6)   NOT NULL'
                  ||',AFF_NAME         VARCHAR2(100) NOT NULL'
                  ||',AFF_SEQ_NO       NUMBER(38)    NOT NULL'
                  ||',AFF_DEFAULT      VARCHAR2(1)   NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_FOLDERS ADD(CONSTRAINT AFF_PK PRIMARY KEY(AFF_AF_ID))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX AFF_IND_UK ON AWLRS_FAVOURITES_FOLDERS(AFF_USER_ID,AFF_PRODUCT,AFF_PARENT_AF_ID,AFF_NAME)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX AFF_FK_HUS_IND ON AWLRS_FAVOURITES_FOLDERS(AFF_USER_ID)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_FOLDERS ADD(CONSTRAINT AFF_FK_HUS FOREIGN KEY(AFF_USER_ID) REFERENCES HIG_USERS(HUS_USER_ID) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX AFF_FK_AFF_IND ON AWLRS_FAVOURITES_FOLDERS(AFF_PARENT_AF_ID)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_FOLDERS ADD(CONSTRAINT AFF_FK_AFF FOREIGN KEY(AFF_PARENT_AF_ID) REFERENCES AWLRS_FAVOURITES_FOLDERS(AFF_AF_ID) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2264);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_FOLDERS ADD (CONSTRAINT AFF_DEFAULT_CHK CHECK(AFF_DEFAULT IN(''Y'',''N'')))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


/*
||Favourites
*/
DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init(obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE AWLRS_FAVOURITES_ENTITIES'
                  ||'(AFE_AF_ID           NUMBER(38)    NOT NULL'
                  ||',AFE_PARENT_AF_ID    NUMBER(38)    NOT NULL'
                  ||',AFE_SEQ_NO          NUMBER(38)    NOT NULL'
                  ||',AFE_ENTITY_TYPE     VARCHAR2(100) NOT NULL'
                  ||',AFE_ENTITY_SUB_TYPE VARCHAR2(100)'
                  ||',AFE_ENTITY_ID       NUMBER(38)    NOT NULL)'
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
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_ENTITIES ADD(CONSTRAINT AFE_PK PRIMARY KEY(AFE_AF_ID))';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX AFE_IND_UK ON AWLRS_FAVOURITES_ENTITIES(AFE_PARENT_AF_ID,AFE_ENTITY_TYPE,AFE_ENTITY_SUB_TYPE,AFE_ENTITY_ID)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX AFE_FK_AFF_IND ON AWLRS_FAVOURITES_ENTITIES(AFE_PARENT_AF_ID)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_ENTITIES ADD(CONSTRAINT AFE_FK_AFF FOREIGN KEY(AFE_PARENT_AF_ID) REFERENCES AWLRS_FAVOURITES_FOLDERS(AFF_AF_ID) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -955);
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX AFE_FK_AFET_IND ON AWLRS_FAVOURITES_ENTITIES(AFE_ENTITY_TYPE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/

DECLARE
  obj_exists EXCEPTION;
  PRAGMA exception_init( obj_exists, -2275);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE AWLRS_FAVOURITES_ENTITIES ADD(CONSTRAINT AFE_FK_AFET FOREIGN KEY(AFE_ENTITY_TYPE) REFERENCES AWLRS_FAV_ENTITY_TYPES(AFET_ENTITY_TYPE) ON DELETE CASCADE)';
EXCEPTION
  WHEN obj_exists THEN
    NULL;
END;
/


------------------------------------------------------------------
-- end of script 
------------------------------------------------------------------

