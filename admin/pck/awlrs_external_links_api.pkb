CREATE OR REPLACE PACKAGE BODY awlrs_external_links_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_external_links_api.pkb-arc   1.5   Jun 27 2019 12:41:02   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_external_links_api.pkb  $
  --       Date into PVCS   : $Date:   Jun 27 2019 12:41:02  $
  --       Date fetched Out : $Modtime:   Jun 27 2019 12:40:02  $
  --       Version          : $Revision:   1.5  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2018 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.5  $';
  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_external_links_api';
  --
  g_theme_name   nm_themes_all.nth_theme_name%TYPE;
  g_theme_types  awlrs_map_api.theme_types_tab;
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
  FUNCTION get_theme_types(pi_theme_name IN nm_themes_all.nth_theme_name%TYPE)
    RETURN awlrs_map_api.theme_types_tab IS
  BEGIN
    --
    IF g_theme_name IS NULL
     OR g_theme_name != pi_theme_name
     THEN
        g_theme_types := awlrs_map_api.get_theme_types(pi_theme_name => pi_theme_name);
        g_theme_name := pi_theme_name;
    END IF;
    --
    RETURN g_theme_types;
    --
  END;

  --
  ------------------------------------------------------------------------------
  --
  FUNCTION get_url(pi_ael_id           IN awlrs_external_links.ael_id%TYPE
                  ,pi_url_template     IN awlrs_external_links.ael_url_template%TYPE
                  ,pi_entity_type      IN awlrs_external_link_params.aelp_entity_type%TYPE
                  ,pi_entity_type_type IN awlrs_external_link_params.aelp_entity_type_type%TYPE
                  ,pi_entity_id        IN NUMBER)
    RETURN awlrs_external_links.ael_url_template%TYPE IS
    --
    lv_retval           awlrs_external_links.ael_url_template%TYPE := pi_url_template;
    lv_sql              nm3type.max_varchar2;
    lv_source           nm3type.max_varchar2;
    lv_ad_asset_attrib  BOOLEAN := FALSE;
    --
    lr_nit  nm_inv_types_all%ROWTYPE;
    --
    TYPE aelp_tab IS TABLE OF awlrs_external_link_params%ROWTYPE;
    lt_aelp  aelp_tab;
    --
    CURSOR get_aelp(cp_ael_id           IN awlrs_external_links.ael_id%TYPE
                   ,cp_entity_type      IN awlrs_external_link_params.aelp_entity_type%TYPE
                   ,cp_entity_type_type IN awlrs_external_link_params.aelp_entity_type_type%TYPE)
        IS
    SELECT *
      FROM awlrs_external_link_params
     WHERE aelp_ael_id = cp_ael_id
       AND aelp_entity_type = cp_entity_type
       AND aelp_entity_type_type = cp_entity_type_type
     ORDER
        BY aelp_sequence
    ;
    --
  BEGIN
    --
    OPEN  get_aelp(pi_ael_id
                  ,pi_entity_type
                  ,pi_entity_type_type);
    FETCH get_aelp
     BULK COLLECT
     INTO lt_aelp;
    CLOSE get_aelp;
    --
    FOR i IN 1..lt_aelp.COUNT LOOP
      --
      CASE lt_aelp(i).aelp_source_type
        WHEN 'COLUMN'
         THEN
            --
            lv_source := lt_aelp(i).aelp_source;
            --
            IF pi_entity_type = c_network
             AND SUBSTR(lv_source,1,3) = 'IIT'
             THEN
                lv_ad_asset_attrib := TRUE;
            END IF;
            --
        WHEN 'VALUE'
         THEN
            --
            lv_source := ''''||awlrs_util.escape_single_quotes(lt_aelp(i).aelp_source)||'''';
            --
        WHEN 'FUNCTION'
         THEN
            --
            lv_source := awlrs_util.escape_single_quotes(lt_aelp(i).aelp_source)||'('||nm3flx.string(pi_entity_type)||','||nm3flx.string(pi_entity_type_type)||','||pi_entity_id||')';
            --
      END CASE;
      --
      IF lt_aelp(i).aelp_default_value IS NOT NULL
       THEN
          lv_source := 'NVL(TO_CHAR('||lv_source||'),'''||lt_aelp(i).aelp_default_value||''')';
      END IF;
      --
      IF i = 1
       THEN
          lv_sql := 'REPLACE(:lv_retval,''{1}'','||lv_source||')';
      ELSE
          lv_sql := 'REPLACE('||lv_sql||',''{'||i||'}'','||lv_source||')';
      END IF;
      --
    END LOOP;
    --
    IF pi_entity_type = c_network
     THEN
        --
        IF lv_ad_asset_attrib
         THEN
            lv_sql := 'SELECT '||lv_sql||' FROM nm_elements_all,nm_nw_ad_link,nm_inv_items_all WHERE ne_id = :entity_id AND ne_id = nad_ne_id(+) AND nad_primary_ad(+) = ''Y'' AND nad_iit_ne_id = iit_ne_id(+)';
        ELSE
            lv_sql := 'SELECT '||lv_sql||' FROM nm_elements_all WHERE ne_id = :entity_id';
        END IF;
        --
    ELSIF pi_entity_type = c_asset
     THEN
        --
        lr_nit := nm3get.get_nit(pi_nit_inv_type => pi_entity_type_type);
        --
        IF lr_nit.nit_table_name IS NULL
         THEN
            lv_sql := 'SELECT '||lv_sql||' FROM nm_inv_items_all WHERE iit_ne_id = :entity_id';
        ELSE
            lv_sql := 'SELECT '||lv_sql||' FROM '||lr_nit.nit_table_name||' WHERE '||lr_nit.nit_foreign_pk_column||' = :entity_id';
        END IF;
        --
    END IF;
    --
    EXECUTE IMMEDIATE lv_sql INTO lv_retval USING lv_retval, pi_entity_id;
    --
    RETURN lv_retval;
    --
  END get_url;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_url(pi_external_link_name IN  awlrs_external_links.ael_name%TYPE
                   ,pi_theme_name         IN  nm_themes_all.nth_theme_name%TYPE
                   ,pi_feature_id         IN  NUMBER
                   ,po_message_severity   OUT hig_codes.hco_code%TYPE
                   ,po_message_cursor     OUT sys_refcursor
                   ,po_cursor             OUT sys_refcursor)
    IS
    --
    lv_entity_type       awlrs_external_link_params.aelp_entity_type%TYPE;
    lv_entity_type_type  awlrs_external_link_params.aelp_entity_type_type%TYPE;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := get_theme_types(pi_theme_name => pi_theme_name);
    lv_entity_type := CASE
                        WHEN lt_theme_types(1).network_type IS NOT NULL
                         THEN 'NETWORK'
                        ELSE 'ASSET'
                      END;
    lv_entity_type_type := CASE
                             WHEN lt_theme_types(1).network_type IS NOT NULL
                              THEN lt_theme_types(1).network_type
                             ELSE lt_theme_types(1).asset_type
                           END;
    --
    OPEN po_cursor FOR
    SELECT awlrs_external_links_api.get_url(ael_id
                                           ,ael_url_template
                                           ,lv_entity_type
                                           ,lv_entity_type_type
                                           ,pi_feature_id) external_link_url
      FROM awlrs_external_links
     WHERE ael_name = pi_external_link_name
       AND EXISTS(SELECT 'x'
                    FROM awlrs_external_link_params
                   WHERE aelp_ael_id = ael_id
                     AND aelp_entity_type = lv_entity_type
                     AND aelp_entity_type_type = lv_entity_type_type)
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_url;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_external_link_actions(pi_entity_type      IN  awlrs_external_link_params.aelp_entity_type%TYPE
                                     ,pi_entity_type_type IN  awlrs_external_link_params.aelp_entity_type_type%TYPE
                                     ,pi_entity_id        IN  NUMBER
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
    IS
    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT *
      FROM(SELECT ael_name  external_link_name
                 ,awlrs_external_links_api.get_url(ael_id
                                                  ,ael_url_template
                                                  ,pi_entity_type
                                                  ,pi_entity_type_type
                                                  ,pi_entity_id) external_link_url
             FROM awlrs_external_links
            WHERE EXISTS(SELECT 'x'
                           FROM awlrs_external_link_params
                          WHERE aelp_ael_id = ael_id
                            AND aelp_entity_type = pi_entity_type
                            AND aelp_entity_type_type = pi_entity_type_type))
     WHERE external_link_url IS NOT NULL
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_external_link_actions;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_external_link_actions(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                                     ,pi_feature_id       IN  NUMBER
                                     ,po_message_severity OUT hig_codes.hco_code%TYPE
                                     ,po_message_cursor   OUT sys_refcursor
                                     ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    lv_cursor            sys_refcursor;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     AND (lt_theme_types(1).network_type IS NOT NULL
          OR lt_theme_types(1).asset_type IS NOT NULL)
     THEN
        --
        get_external_link_actions(pi_entity_type      => CASE
                                                           WHEN lt_theme_types(1).network_type IS NOT NULL
                                                            THEN 'NETWORK'
                                                           ELSE 'ASSET'
                                                         END
                                 ,pi_entity_type_type => CASE
                                                           WHEN lt_theme_types(1).network_type IS NOT NULL
                                                            THEN lt_theme_types(1).network_type
                                                           ELSE lt_theme_types(1).asset_type
                                                         END
                                 ,pi_entity_id        => pi_feature_id
                                 ,po_message_severity => lv_message_severity
                                 ,po_message_cursor   => lv_message_cursor
                                 ,po_cursor           => lv_cursor);
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
    END IF;
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    po_cursor := lv_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_external_link_actions;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_external_links(pi_entity_type      IN  awlrs_external_link_params.aelp_entity_type%TYPE
                              ,pi_entity_type_type IN  awlrs_external_link_params.aelp_entity_type_type%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --

    --
  BEGIN
    --
    OPEN po_cursor FOR
    SELECT ael_name  external_link_name
      FROM awlrs_external_links
     WHERE EXISTS(SELECT 'x'
                    FROM awlrs_external_link_params
                   WHERE aelp_ael_id = ael_id
                     AND aelp_entity_type = pi_entity_type
                     AND aelp_entity_type_type = pi_entity_type_type)
    ;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_external_links;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE get_external_links(pi_theme_name       IN  nm_themes_all.nth_theme_name%TYPE
                              ,po_message_severity OUT hig_codes.hco_code%TYPE
                              ,po_message_cursor   OUT sys_refcursor
                              ,po_cursor           OUT sys_refcursor)
    IS
    --
    lv_message_severity  hig_codes.hco_code%TYPE;
    lv_message_cursor    sys_refcursor;
    lv_cursor            sys_refcursor;
    --
    lt_theme_types  awlrs_map_api.theme_types_tab;
    --
  BEGIN
    --
    lt_theme_types := get_theme_types(pi_theme_name => pi_theme_name);
    --
    IF lt_theme_types.COUNT > 0
     AND (lt_theme_types(1).network_type IS NOT NULL
          OR lt_theme_types(1).asset_type IS NOT NULL)
     THEN
        --
        get_external_links(pi_entity_type      => CASE
                                                    WHEN lt_theme_types(1).network_type IS NOT NULL
                                                     THEN 'NETWORK'
                                                    ELSE 'ASSET'
                                                  END
                          ,pi_entity_type_type => CASE
                                                    WHEN lt_theme_types(1).network_type IS NOT NULL
                                                     THEN lt_theme_types(1).network_type
                                                    ELSE lt_theme_types(1).asset_type
                                                  END
                          ,po_message_severity => lv_message_severity
                          ,po_message_cursor   => lv_message_cursor
                          ,po_cursor           => lv_cursor);
        --
    ELSE
        --
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 6
                     ,pi_supplementary_info => pi_theme_name);
        --
    END IF;
    --
    po_message_severity := lv_message_severity;
    po_message_cursor := lv_message_cursor;
    po_cursor := lv_cursor;
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END get_external_links;

END awlrs_external_links_api;
/
