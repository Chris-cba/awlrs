-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrsdata_install.sql-arc   1.1   02 Feb 2017 10:03:20   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrsdata_install.sql  $
--       Date into PVCS   : $Date:   02 Feb 2017 10:03:20  $
--       Date fetched Out : $Modtime:   02 Feb 2017 09:51:20  $
--       Version          : $Revision:   1.1  $
-------------------------------------------------------------------------
--   Copyright (c) 2017 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
SET echo OFF
SET linesize 120
SET heading OFF
SET feedback OFF
--
COL run_file new_value run_file noprint
--
-------------------------------------------------------------------------
--
DECLARE
  l_temp  nm3type.max_varchar2;
BEGIN
  -- Dummy call to HIG to instantiate it
  l_temp := hig.get_version;
  l_temp := nm_debug.get_version;
EXCEPTION
  WHEN others
   THEN
     NULL;
END;
/

--
-------------------------------------------------------------------------
--Call a proc in nm_debug to instantiate it before calling metadata
--scripts. If this is not done any inserts into hig_option_values
--may fail due to mutating trigger when nm_debug checks DEBUGAUTON.
-------------------------------------------------------------------------
--
BEGIN
  nm_debug.debug_off;
END;
/

--
-------------------------------------------------------------------------
--
SET TERM ON
Prompt Running awlrsdata1...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrsdata1' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&run_file'
SET FEEDBACK OFF
--
-------------------------------------------------------------------------
--
SET TERM ON
Prompt Running awlrsdata2...
SET TERM OFF
SET DEFINE ON
SELECT '&exor_base'||'awlrs'||'&terminator'||'install'||'&terminator'||'awlrsdata2' run_file
  FROM dual
     ;
SET FEEDBACK ON
START '&run_file'
SET FEEDBACK OFF
--
-------------------------------------------------------------------------
--
COMMIT;
--
-------------------------------------------------------------------------
--
SET TERM ON
Prompt Rebuilding AWLRS Sequences...
SET TERM OFF
SET FEEDBACK ON
DECLARE
  --
  TYPE hsa_tab IS TABLE OF hig_sequence_associations.hsa_sequence_name%TYPE;
  lt_hsa  hsa_tab;
  --
  CURSOR get_hsa
      IS
  SELECT hsa_sequence_name
    FROM hig_sequence_associations
   WHERE hsa_table_name LIKE 'AWLRS%'
       ;
  --
BEGIN
  --
  OPEN  get_hsa;
  FETCH get_hsa
   BULK COLLECT
   INTO lt_hsa;
  CLOSE get_hsa;
  --
  FOR i IN 1..lt_hsa.COUNT LOOP
    --
    nm3ddl.rebuild_sequence(pi_hsa_sequence_name => lt_hsa(i));
    --
  END LOOP;
  --
END;
/
