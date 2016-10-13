-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrspkh.sql-arc   1.1   13 Oct 2016 09:49:22   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrspkh.sql  $
--       Date into PVCS   : $Date:   13 Oct 2016 09:49:22  $
--       Date fetched Out : $Modtime:   13 Oct 2016 09:47:58  $
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
       ||'&terminator'||'awlrs_util.pkh' run_file
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
       ||'&terminator'||'awlrs_sdo.pkh' run_file
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
       ||'&terminator'||'awlrs_map_api.pkh' run_file
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
       ||'&terminator'||'awlrs_persistence_api.pkh' run_file
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
       ||'&terminator'||'awlrs_element_api.pkh' run_file
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
       ||'&terminator'||'awlrs_split_api.pkh' run_file
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
       ||'&terminator'||'awlrs_merge_api.pkh' run_file
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
       ||'&terminator'||'awlrs_replace_api.pkh' run_file
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
       ||'&terminator'||'awlrs_close_api.pkh' run_file
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
       ||'&terminator'||'awlrs_node_api.pkh' run_file
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
       ||'&terminator'||'awlrs_undo_api.pkh' run_file
  FROM dual
     ;
SET feedback ON
START '&run_file'
SET feedback OFF
-------------------------------------------------------------------------
-- New proc above here
-------------------------------------------------------------------------
SET term ON


