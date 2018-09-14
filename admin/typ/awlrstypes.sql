-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/typ/awlrstypes.sql-arc   1.2   Sep 14 2018 13:13:08   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrstypes.sql  $
--       Date into PVCS   : $Date:   Sep 14 2018 13:13:08  $
--       Date fetched Out : $Modtime:   Sep 14 2018 13:12:42  $
--       Version          : $Revision:   1.2  $
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
SET TERM ON
PROMPT Dropping Existing Types
SET TERM OFF
--
BEGIN
  EXECUTE IMMEDIATE('DROP TYPE AWLRS_MESSAGE_TAB');
EXCEPTION
  WHEN others
   THEN
      NULL;
END;
/
--
BEGIN
  EXECUTE IMMEDIATE('DROP TYPE AWLRS_MESSAGE');
EXCEPTION
  WHEN others
   THEN
      NULL;
END;
/
--
BEGIN
  EXECUTE IMMEDIATE('DROP TYPE AWLRS_PLM_LAYER_LABEL_TAB');
EXCEPTION
  WHEN others
   THEN
      NULL;
END;
/
--
BEGIN
  EXECUTE IMMEDIATE('DROP TYPE AWLRS_PLM_LAYER_LABEL');
EXCEPTION
  WHEN others
   THEN
      NULL;
END;
/
--
--------------------------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_message_type header
SET TERM OFF
SET DEFINE ON
SET FEEDBACK OFF
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrs_message.tyh' run_file
  FROM dual
     ;
START '&&run_file'
--
--------------------------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_message_tab header
SET TERM OFF
SET DEFINE ON
SET FEEDBACK OFF
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrs_message_tab.tyh' run_file
  FROM dual
     ;
START '&&run_file'
--
--------------------------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_plm_layer_label header
SET TERM OFF
SET DEFINE ON
SET FEEDBACK OFF
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrs_plm_layer_label.tyh' run_file
  FROM dual
     ;
START '&&run_file'
--
--------------------------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_plm_layer_label_tab header
SET TERM OFF
SET DEFINE ON
SET FEEDBACK OFF
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrs_plm_layer_label_tab.tyh' run_file
  FROM dual
     ;
START '&&run_file'
--
--------------------------------------------------------------------------------------------
--
-- *************************************************************************************************************
-- * new types above here                                                                                      *
--                                                                                                             *
-- * Important: if you introduce new types then be aware that this script runs on install and at every upgrade *
-- * so if your type has dependants - these must be dropped in the correct order at the top of this script     *
-- *************************************************************************************************************
--
SET TERM ON





