--
-----------------------------------------------------------------------------
--
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs1010_awlrs12110.sql-arc   1.0   Feb 12 2020 14:23:02   Peter.Bibby  $
--       Module Name      : $Workfile:   awlrs1010_awlrs12110.sql  $
--       Date into PVCS   : $Date:   Feb 12 2020 14:23:02  $
--       Date fetched Out : $Modtime:   Dec 13 2019 13:38:34  $
--       Version          : $Revision:   1.0  $
--
--   Product upgrade script
--
-----------------------------------------------------------------------------
--  Copyright (c) 2019 Bentley Systems Incorporated. All rights reserved.
-----------------------------------------------------------------------------
undefine exor_base
undefine run_file
undefine terminator
COL exor_base new_value exor_base noprint
COL run_file new_value run_file noprint
COL terminator new_value terminator noprint
SET verify OFF head OFF feedback off ECHO off term ON
prompt
prompt
prompt Please enter the value for exor base. This is the directory under which
prompt the exor software resides (eg c:\exor\ on a client PC). IF the value
prompt entered is not correct, the process will not proceed.
prompt There is no default value for this value.
prompt
prompt IMPORTANT: Please ensure that the exor base value is terminated with
prompt the directory seperator for your operating system
prompt (eg \ in windows or / in unix).
prompt
prompt
prompt It is VITALLY IMPORTANT that you allow this upgrade to finish on its own
PROMPT  NEVER "kill" the session because it seems to be taking a long time to run
PROMPT
prompt
ACCEPT exor_base prompt "Enter exor base directory now : "
SELECT SUBSTR('&exor_base',(LENGTH('&exor_base'))) terminator
FROM dual
/
SELECT DECODE('&terminator',
              '/',NULL,
              '\',NULL,
              'inv_term') run_file
FROM dual
/
SET term OFF
start '&run_file'
SET term ON
REM
REM Ensure that exor_base is not greater than 30 characters in length
REM
SELECT DECODE(
              SIGN(30-LENGTH('&exor_base'))
                                          ,1,null
                                          ,'exor_base_too_long.sql') run_file
FROM dual
/
SET term OFF
start '&run_file'
SET term ON
prompt
prompt About TO upgrade using exor base : &exor_base
prompt
ACCEPT ok_res prompt "OK to Continue with this setting ? (Y/N) "
SELECT DECODE(UPPER('&ok_res'),'Y','&exor_base'||'awlrs'||'&terminator'||
        'install'||'&terminator'||'awlrs1010_awlrs12110_upg.sql','exit') run_file
FROM dual
/
start '&run_file'
prompt
prompt The upgrade scripts could not be found in the directory
prompt specified for exor base ().
prompt
prompt Please re-run the upgrade script and enter the correct directory name.
prompt
ACCEPT leave_it prompt "Press RETURN to exit from SQL*PLUS"
EXIT;
