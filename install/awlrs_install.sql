-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrs_install.sql-arc   1.24   Oct 31 2018 15:06:22   Barbara.Odriscoll  $
--       Module Name      : $Workfile:   awlrs_install.sql  $
--       Date into PVCS   : $Date:   Oct 31 2018 15:06:22  $
--       Date fetched Out : $Modtime:   Oct 30 2018 11:57:34  $
--       Version          : $Revision:   1.24  $
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
SET echo OFF
SET linesize 120
SET heading OFF
SET feedback OFF
--
---------------------------------------------------------------------------------------------------
--                  ****************** LOG FILE *******************
-- Grab date/time to append to log file names this is standard to all upgrade/install scripts
--
UNDEFINE log_extension
COL      log_extension new_value log_extension noprint
SET term OFF
SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MISS')||'.log' log_extension
  FROM dual
     ;
--
SET term ON
DEFINE logfile1='awlrs_install_1_&log_extension'
DEFINE logfile2='awlrs_install_2_&log_extension'
SPOOL &logfile1
--
---------------------------------------------------------------------------------------------------
--                  ********** CHECKS  ***********
SELECT 'Installation Date '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
  FROM dual
     ;
--
SELECT 'Install Running on '||LOWER(USER||'@'||instance_name||'.'||host_name)||' - DB ver : '||version
  FROM v$instance
     ;
--
SELECT 'Current version of '||hpr_product||' '||hpr_version
  FROM hig_products
 WHERE hpr_product IN ('HIG','NET')
     ;
--
WHENEVER SQLERROR EXIT
--
-- Check that the user isn't sys or system
--
BEGIN
  --
  IF USER IN ('SYS','SYSTEM')
   THEN
      RAISE_APPLICATION_ERROR(-20000,'You cannot install this product as '||USER);
  END IF;
END;
/
--
-- Check that AWLRS has not already been installed
--
DECLARE
  --
  lv_version  hig_products.hpr_version%TYPE;
  --
  CURSOR chk_prd
      IS
  SELECT hpr_version
    FROM user_tables
        ,hig_products
   WHERE hpr_product = 'AWLRS'
     AND table_name = 'AWLRS_PERSISTENCE'
       ;
  --
BEGIN
  --
  OPEN  chk_prd;
  FETCH chk_prd
   INTO lv_version;
  CLOSE chk_prd;
  --
  IF lv_version IS NOT NULL
   THEN
      raise_application_error(-20000,'AWLRS version '||lv_version||' already installed.');
  END IF;
  --
END;
/
--
-- Check that HIG has been installed at correct version
--
BEGIN
  hig2.product_exists_at_version(p_product => 'HIG'
                                ,p_version => '4.7.0.0');
END;
/

-- Check that if NSG is installled that the relevant NSG fix has also been installed.  For example 1.1.4.1 requires NSG @4.7.0.1 and NSG 4700 Fix 17
--
Declare
  
  l_nsg_exists Boolean;
  n Varchar2(1);

Begin
  
    Begin

       hig2.product_exists_at_version(
                                      p_product        => 'NSG',
                                      p_version        => '4.7.0.1'
                                     );
       l_Nsg_Exists := TRUE;                              
    Exception
       When Others Then
            l_Nsg_Exists := FALSE; -- Not all AWLRS users will have NSG installed --           
    End; 
    
    If l_nsg_Exists Then 
       Begin
           Select  Null
           Into    n
           From    Hig_Upgrades
           Where   Hup_Product     =   'NSG'
           And     From_Version    =   '4.7.0.1'
           And     Upgrade_Script  =   'exnsg04070037en_updt16.sql'
           And     rownum          =   1;
       Exception 
           When No_Data_Found Then
                Raise_Application_Error(-20000,'Please install NSG 4700 Fix 17 before proceding.');
       End;
    End if;   

End;
/
--
                               
                                
WHENEVER SQLERROR CONTINUE
--
---------------------------------------------------------------------------------------------------
--                  ****************   TYPES  *******************
SET TERM ON
prompt Types...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'typ'
       ||'&terminator'||'awlrstypes.sql' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ********************* TABLES *************************
SET TERM ON
Prompt Tables...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrs.tab' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ********************* SEQUENCES *************************
SET TERM ON
Prompt Sequences...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrs.sqs' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ********************* INDEXES *************************
SET TERM ON
Prompt Indexes...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrs.ind' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ********************* CONSTRAINTS *************************
SET TERM ON
Prompt Constraints...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrs.con' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ********************* PACKAGE HEADERS *************************
SET TERM ON
Prompt Package Headers...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrspkh.sql' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ********************* PACKAGE BODIES *************************
SET TERM ON
Prompt Package Bodies...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'admin'||'&terminator'||'pck'
       ||'&terminator'||'awlrspkb.sql' run_file
  FROM dual
/
SET FEEDBACK ON
START '&&run_file'
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ****************   ROLES  *******************
--SET TERM ON
--prompt Roles...
--SET TERM OFF
--SET DEFINE ON
--SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrsroles.sql' run_file
--  FROM dual
--     ;
--SET FEEDBACK ON
--START '&&run_file'
--SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ****************   COMPILE SCHEMA   *******************
SET TERM ON
Prompt Creating Compiling Schema Script...
SET TERM OFF
SPOOL OFF
--
SET DEFINE ON
SELECT '&exor_base'||'nm3'||'&terminator'||'admin'||'&terminator'||'utl'
       ||'&terminator'||'compile_schema.sql' run_file
  FROM dual
     ;
START '&run_file'
--
SPOOL &logfile2
--
SELECT 'Install Date '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
  FROM dual
     ;
--
SELECT 'Install Running on '||LOWER(username||'@'||instance_name||'.'||host_name)||' - DB ver : '||version
  FROM v$instance
      ,user_users
     ;
--
START compile_all.sql
--
---------------------------------------------------------------------------------------------------
--                  ********************* META-DATA *************************
SET TERM ON
Prompt Meta-Data...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrsdata_install.sql' run_file
  FROM dual
     ;
SET FEEDBACK ON
START &&run_file
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ****************   SYNONYMS   *******************
SET TERM ON
Prompt Creating Synonyms That Do Not Exist...
SET TERM OFF
SET FEEDBACK ON
EXECUTE nm3ddl.refresh_all_synonyms;
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ****************   HIG USER ROLES  *******************
SET TERM ON
Prompt Updating HIG_USER_ROLES...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'nm3'||'&terminator'||'install'||'&terminator'||'hig_user_roles.sql' run_file
  FROM dual
     ;
SET FEEDBACK ON
START &&run_file
SET FEEDBACK OFF
--
---------------------------------------------------------------------------------------------------
--                  ****************   VERSION NUMBER   *******************
SET TERM ON
Prompt Setting The Version Number...
SET TERM OFF
BEGIN
  hig2.upgrade('AWLRS','awlrs_install.sql','Installed','1.1.4.1');
END;
/
COMMIT;
--
SELECT 'Product installed at version '||hpr_product||' '||hpr_version details
  FROM hig_products
 WHERE hpr_product IN ('AWLRS')
     ;
--
SPOOL OFF
--
EXIT







