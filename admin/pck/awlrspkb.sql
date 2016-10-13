-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrspkb.sql-arc   1.1   13 Oct 2016 09:49:18   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrspkb.sql  $
--       Date into PVCS   : $Date:   13 Oct 2016 09:49:18  $
--       Date fetched Out : $Modtime:   13 Oct 2016 09:48:18  $
--       Version          : $Revision:   1.1  $
-------------------------------------------------------------------------
--   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
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
-------------------------------------------------------------------------
-- New proc above here
-------------------------------------------------------------------------
SET term ON
