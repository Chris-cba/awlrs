-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/typ/awlrstypes.sql-arc   1.3   Dec 11 2019 13:51:44   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrstypes.sql  $
--       Date into PVCS   : $Date:   Dec 11 2019 13:51:44  $
--       Date fetched Out : $Modtime:   Dec 11 2019 13:51:18  $
--       Version          : $Revision:   1.3  $
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
BEGIN
  EXECUTE IMMEDIATE('DROP TYPE awlrs_column_data_tab');
EXCEPTION
  WHEN others
   THEN
      NULL;
END;
/
--
BEGIN
  EXECUTE IMMEDIATE('DROP TYPE awlrs_column_data_rec');
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
SET TERM ON
PROMPT awlrs_column_data_rec header
SET TERM OFF
SET DEFINE ON
SET FEEDBACK OFF
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrs_column_data_rec.tyh' run_file
  FROM dual
     ;
START '&&run_file'
--
--------------------------------------------------------------------------------------------
--
SET TERM ON
PROMPT awlrs_column_data_tab header
SET TERM OFF
SET DEFINE ON
SET FEEDBACK OFF
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrs_column_data_tab.tyh' run_file
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





