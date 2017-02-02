CREATE OR REPLACE PACKAGE BODY awlrs_bulk_update_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_bulk_update_api.pkb-arc   1.0   02 Feb 2017 09:38:10   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_bulk_update_api.pkb  $
  --       Date into PVCS   : $Date:   02 Feb 2017 09:38:10  $
  --       Date fetched Out : $Modtime:   02 Feb 2017 09:33:40  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_bulk_update_api';
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
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_element_attribs(pi_nt_type         IN nm_types.nt_type%TYPE
                                  ,pi_ne_ids          IN awlrs_util.ne_id_tab
                                  ,pi_element_attribs IN awlrs_element_api.flex_attr_tab)
    IS
    --
    lr_attribute  nm3_bulk_attrib_upd.l_attrib_rec;
    --
    CURSOR get_nav(cp_nt_type  IN VARCHAR2
                  ,cp_col_name IN VARCHAR2
                  ,cp_value    IN VARCHAR2)
        IS
    SELECT nav_disp_ord       
          ,nav_nt_type        
          ,nav_inv_type       
          ,nav_gty_type       
          ,nav_col_name       
          ,nav_col_type       
          ,nav_col_updatable  
          ,nav_parent_type_inc
          ,nav_child_type_inc 
          ,cp_value nav_value  
      FROM nm_attrib_view_vw
     WHERE nav_nt_type = cp_nt_type
       AND nav_col_name = cp_col_name
         ;
    --
  BEGIN
    --
    IF NOT awlrs_util.historic_mode
     THEN
        /*
        ||Initialise the bulk array;
        */
        nm3_bulk_attrib_upd.delete_array;
        /*
        ||Set the element ids for the update.
        */
        FOR i IN 1..pi_ne_ids.COUNT LOOP
          --
          nm3_bulk_attrib_upd.add_remove_ne_id(pi_ne_ids(i),i,'A');
          --
        END LOOP;
        /*
        ||Set the attribute values for the update.
        */
        FOR i IN 1.. pi_element_attribs.COUNT LOOP
          --
          OPEN  get_nav(cp_nt_type  => pi_nt_type
                       ,cp_col_name => pi_element_attribs(i).column_name
                       ,cp_value    => pi_element_attribs(i).char_value);
          FETCH get_nav
           INTO lr_attribute;
          CLOSE get_nav;
          --
          nm3_bulk_attrib_upd.build_att_array(lr_attribute,i);
          --
        END LOOP;
        /*
        ||Perform the update.
        */
        nm3_bulk_attrib_upd.run_ddl;
        --
    ELSE
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 6);
    END IF;
    --
  END update_element_attribs;
  
  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE update_element_attribs(pi_nt_type             IN  nm_types.nt_type%TYPE
                                  ,pi_ne_ids              IN  awlrs_util.ne_id_tab
                                  ,pi_attrib_column_names IN  awlrs_element_api.attrib_column_name_tab
                                  ,pi_attrib_prompts      IN  awlrs_element_api.attrib_prompt_tab
                                  ,pi_attrib_char_values  IN  awlrs_element_api.attrib_char_value_tab
                                  ,po_message_severity    OUT hig_codes.hco_code%TYPE
                                  ,po_message_cursor      OUT sys_refcursor)
    IS
    --
    lt_element_attribs  awlrs_element_api.flex_attr_tab;
    --
  BEGIN
    --
    IF pi_attrib_column_names.COUNT != pi_attrib_prompts.COUNT
     OR pi_attrib_column_names.COUNT != pi_attrib_char_values.COUNT
     THEN
        --The attribute tables passed in must have matching row counts
        hig.raise_ner(pi_appl               => 'AWLRS'
                     ,pi_id                 => 5
                     ,pi_supplementary_info => 'awlrs_element_api.create_element');
    END IF;
    --
    FOR i IN 1..pi_attrib_column_names.COUNT LOOP
      --
      lt_element_attribs(i).column_name := pi_attrib_column_names(i);
      lt_element_attribs(i).prompt      := pi_attrib_prompts(i);
      lt_element_attribs(i).char_value  := pi_attrib_char_values(i);
      --
    END LOOP;
    --
    update_element_attribs(pi_nt_type         => pi_nt_type
                          ,pi_ne_ids          => pi_ne_ids
                          ,pi_element_attribs => lt_element_attribs);
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END update_element_attribs;

END awlrs_bulk_update_api;
/
