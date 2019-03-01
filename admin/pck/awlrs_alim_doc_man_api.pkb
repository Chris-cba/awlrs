CREATE OR REPLACE PACKAGE BODY awlrs_alim_doc_man_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_alim_doc_man_api.pkb-arc   1.0   Mar 01 2019 11:00:14   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_alim_doc_man_api.pkb  $
  --       Date into PVCS   : $Date:   Mar 01 2019 11:00:14  $
  --       Date fetched Out : $Modtime:   Feb 27 2019 16:14:08  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid   CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_alim_doc_man_api';
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN g_sccsid;
  END get_version;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_gateway(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_retval  doc_gateways.dgt_table_name%TYPE;
    --
    CURSOR get_gateway(cp_theme_name IN nm_themes_all.nth_theme_name%TYPE)
        IS
    SELECT gateway_name
      FROM v_doc_gateway_resolve
     WHERE synonym_name = (SELECT ntdv_gateway_table
                             FROM nm_theme_details_v
                            WHERE ntdv_nth_theme_name = cp_theme_name)
    ;
    --
  BEGIN
    --
    OPEN  get_gateway(pi_theme_name);
    FETCH get_gateway
     INTO lv_retval;
    CLOSE get_gateway;
    --
    RETURN lv_retval;
    --
  END get_gateway;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION doc_gateway_exists(pi_table_name IN doc_gateways.dgt_table_name%TYPE)
    RETURN BOOLEAN IS
    --
    CURSOR chk_tab(cp_table_name IN doc_gateways.dgt_table_name%TYPE)
        IS
    SELECT 1
      FROM v_doc_gateway_resolve
     WHERE synonym_name = cp_table_name
    ;
    --
    lv_exists  NUMBER(1);
    lv_retval  BOOLEAN := FALSE;
    --
  BEGIN
    --
    OPEN  chk_tab(pi_table_name);
    FETCH chk_tab
     INTO lv_exists;
    lv_retval := chk_tab%FOUND;
    CLOSE chk_tab;
    --
    RETURN lv_retval;
    --
  END doc_gateway_exists;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION doc_gateway_exists(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN BOOLEAN IS
    --
    CURSOR chk_tab(cp_theme_name IN nm_themes_all.nth_theme_name%TYPE)
        IS
    SELECT 1
      FROM v_doc_gateway_resolve
     WHERE synonym_name = (SELECT ntdv_gateway_table
                             FROM nm_theme_details_v
                            WHERE ntdv_nth_theme_name = cp_theme_name)
    ;
    --
    lv_exists  NUMBER(1);
    lv_retval  BOOLEAN := FALSE;
    --
  BEGIN
    --
    OPEN  chk_tab(pi_theme_name);
    FETCH chk_tab
     INTO lv_exists;
    lv_retval := chk_tab%FOUND;
    CLOSE chk_tab;
    --
    RETURN lv_retval;
    --
  END doc_gateway_exists;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_url_template(pi_gateway_name IN doc_gateways.dgt_table_name%TYPE)
    RETURN VARCHAR2 IS
    --
  BEGIN
    --
    RETURN hig.get_sysopt('eBAssoURL')||'tab/'||pi_gateway_name||'/feature/{0}?loadTab=DocumentsRelationshipTemplateId';
    --
  END get_url_template;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_url_template(pi_table_name IN doc_gateways.dgt_table_name%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_gateway_name  doc_gateways.dgt_table_name%TYPE;
    lv_retval        nm3type.max_varchar2;
    --
    CURSOR get_gateway(cp_table_name IN doc_gateways.dgt_table_name%TYPE)
        IS
    SELECT gateway_name
      FROM v_doc_gateway_resolve
     WHERE synonym_name = cp_table_name
    ;
    --
  BEGIN
    --
    OPEN  get_gateway(pi_table_name);
    FETCH get_gateway
     INTO lv_gateway_name;
    CLOSE get_gateway;
    --
    IF lv_gateway_name IS NOT NULL
     THEN
        lv_retval := get_url_template(pi_gateway_name => lv_gateway_name);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_url_template;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_url_template(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN VARCHAR2 IS
    --
    lv_gateway_name  doc_gateways.dgt_table_name%TYPE;
    lv_retval        nm3type.max_varchar2;
    --
  BEGIN
    --
    lv_gateway_name := get_gateway(pi_theme_name => pi_theme_name);
    --
    IF lv_gateway_name IS NOT NULL
     THEN
        lv_retval := get_url_template(pi_gateway_name => lv_gateway_name);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_url_template;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_document_count(pi_gateway_name IN doc_gateways.dgt_table_name%TYPE
                             ,pi_id           IN NUMBER)
    RETURN NUMBER IS
    --
    lv_sql     nm3type.max_varchar2;
    lv_retval  NUMBER;
    --
  BEGIN
    --
    lv_sql := 'SELECT docman_get_document_count(ps_feature_id => :id,ps_gateway_name => :gateway) FROM dual';
    --
    EXECUTE IMMEDIATE lv_sql INTO lv_retval USING pi_id, pi_gateway_name;
    --
    RETURN lv_retval;
    --
  END get_document_count;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_document_count(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE
                             ,pi_feature_id IN NUMBER)
    RETURN NUMBER IS
    --
    lv_gateway_name  doc_gateways.dgt_table_name%TYPE;
    lv_retval        NUMBER := 0;
    --
  BEGIN
    --
    lv_gateway_name := get_gateway(pi_theme_name => pi_theme_name);
    --
    IF lv_gateway_name IS NOT NULL
     THEN
        lv_retval := get_document_count(pi_gateway_name => lv_gateway_name
                                       ,pi_id           => pi_feature_id);
    END IF;
    --
    RETURN lv_retval;
    --
  END get_document_count;

END awlrs_alim_doc_man_api;
/
