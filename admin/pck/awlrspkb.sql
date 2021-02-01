-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrspkb.sql-arc   1.19   Feb 01 2021 14:51:56   Barbara.Odriscoll  $
--       Module Name      : $Workfile:   awlrspkb.sql  $
--       Date into PVCS   : $Date:   Feb 01 2021 14:51:56  $
--       Date fetched Out : $Modtime:   Nov 19 2020 16:38:50  $
--       Version          : $Revision:   1.19  $
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
SET echo OFF
SET term OFF
SET feedback OFF
--
COL run_file new_value run_file noprint
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_util
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_util.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_sdo
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_sdo.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_alim_doc_man_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_alim_doc_man_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_map_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_map_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_persistence_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_persistence_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_node_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_node_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_element_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_element_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_group_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_group_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_split_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_split_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_merge_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_merge_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_replace_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_replace_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_close_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_close_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_undo_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_undo_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_recalibrate_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_recalibrate_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_reclassify_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_reclassify_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_bulk_update_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_bulk_update_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_asset_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_asset_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_reshape_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_reshape_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_search_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_search_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_copy_trace_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_copy_trace_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_plm_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_plm_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_sdo_offset
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_sdo_offset.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_metasec_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_metasec_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_metaref_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_metaref_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_external_links_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_external_links_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_asset_maint_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_asset_maint_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_metaast_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_metaast_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_metanet_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_metanet_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_user_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_user_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_sdl_util
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_sdl_util.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_sdl_profiles_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_sdl_profiles_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_sdl_upload_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_sdl_upload_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_process_framework_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_process_framework_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_theme_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_theme_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_favourites_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_favourites_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_alerts_api
SET TERM OFF
SET define ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrs_alerts_api.pkw' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
-------------------------------------------------------------------------
-- New proc above here
-------------------------------------------------------------------------
SET term ON
