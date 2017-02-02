-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs_inst.sql-arc   1.2   02 Feb 2017 10:03:12   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrs_inst.sql  $
--       Date into PVCS   : $Date:   02 Feb 2017 10:03:12  $
--       Date fetched Out : $Modtime:   02 Feb 2017 09:51:20  $
--       Version          : $Revision:   1.2  $
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
UNDEFINE exor_base
UNDEFINE run_file
UNDEFINE terminator
COL exor_base new_value exor_base noprint
COL run_file new_value run_file noprint
COL terminator new_value terminator noprint
--
SET verify OFF head OFF term ON
--
CL SCR
PROMPT
PROMPT
PROMPT Please enter the value for exor base. This is the directory under which
PROMPT the exor software resides (eg c:\exor\ on a client PC). If the value
PROMPT entered is not correct, the process will not proceed.
PROMPT There is no default value for this value.
PROMPT
PROMPT IMPORTANT: Please ensure that the exor base value is terminated with
PROMPT the directory seperator for your operating system
PROMPT (eg \ in Windows or / in UNIX).
PROMPT
--
ACCEPT exor_base PROMPT "Enter exor base directory now : "
--
SELECT SUBSTR('&exor_base',(LENGTH('&exor_base'))) terminator
  FROM dual
     ;
--
SELECT DECODE('&terminator','/',NULL
                           ,'\',NULL
                               ,'inv_term') run_file
  FROM dual
     ;
--
SET term OFF
START '&run_file'
SET term ON
--
--Ensure that exor_base is not greater than 30 characters in length
--
SELECT DECODE(SIGN(30-LENGTH('&exor_base')),1,NULL,'exor_base_too_long.sql') run_file
  FROM dual
     ;
SET term OFF
START '&run_file'
SET term ON
--
PROMPT
PROMPT About to install AssetWise ALIM Linear Referencing Services using exor base : &exor_base
PROMPT
ACCEPT ok_res PROMPT "OK to Continue with this setting ? (Y/N) "
--
SELECT DECODE(UPPER('&ok_res'),'Y','&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrs_install'
                                  ,'exit') run_file
  FROM dual
     ;
--
START '&run_file'
--
PROMPT
PROMPT The install scripts could not be found in the directory
PROMPT specified for exor base (&exor_base).
PROMPT
PROMPT Please re-run the installation script and enter the correct directory name.
PROMPT
ACCEPT leave_it PROMPT "Press RETURN to exit from SQL*PLUS"
