-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrsdata2.sql-arc   1.1   30 Sep 2016 11:03:54   Mike.Huitson  $
--       Module Name      : $Workfile:   awlrsdata2.sql  $
--       Date into PVCS   : $Date:   30 Sep 2016 11:03:54  $
--       Date fetched Out : $Modtime:   30 Sep 2016 11:02:46  $
--       Version          : $Revision:   1.1  $
--       Table Owner      : AWLRS_METADATA
--       Generation Date  : 30-SEP-2016 11:02
--
--   Product metadata script
--   As at Release 4.7.0.0
--
-------------------------------------------------------------------------
--   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
--   TABLES PROCESSED
--   ================
--   NM_ERRORS
--
-----------------------------------------------------------------------------
--
SET define OFF;
SET feedback OFF;
---------------------------------
-- START OF GENERATED METADATA --
---------------------------------
--
----------------------------------------------------------------------------------------
-- NM_ERRORS
--
-- select * from awlrs_metadata.nm_errors
-- order by ner_appl
--         ,ner_id
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT nm_errors
SET TERM OFF
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,1
      ,null
      ,'Unable to generate node name and no name supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 1);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,2
      ,null
      ,'Unable to derive an Id for given Element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 2);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,3
      ,null
      ,'Invalid Attribute Supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 3);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,4
      ,null
      ,'Please specify both start and end nodes or a shape for the new Element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 4);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,5
      ,null
      ,'The attribute tables passed in must have matching row counts'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 5);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,6
      ,null
      ,'Layer does not represent an Asset Type or a Network Type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 6);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,7
      ,null
      ,'Invalid Map name supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 7);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,8
      ,null
      ,'Unsuported geometry type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 8);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,9
      ,null
      ,'Unsuported Layer Type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 9);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,10
      ,null
      ,'Unsuported Style Type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 10);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,11
      ,null
      ,'Invalid Style Type supplied as Text Style'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 11);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,12
      ,null
      ,'Unable to derive EPSG from SRID'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 12);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,13
      ,null
      ,'Cannot find start x,y of the geometry'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 13);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,14
      ,null
      ,'Cannot find end x,y of the geometry.'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 14);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,15
      ,null
      ,'Invalid geometry supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 15);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,16
      ,null
      ,'Invalid number of coordinates returned'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 16);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,17
      ,null
      ,'Unable to derive a linear network type for theme id'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 17);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,18
      ,null
      ,'Cannot find a coordinate from the network element and measure provided'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 18);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,19
      ,null
      ,'Invalid undo operation'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 19);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,20
      ,null
      ,'Invalid Message Category'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 20);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,21
      ,null
      ,'Invalid numeric attribute value supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 21);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,22
      ,null
      ,'Invalid attribute value supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 22);
--
----------------------------------------------------------------------------------------
--
COMMIT;
--
SET feedback ON
SET define ON
--
-------------------------------
-- END OF GENERATED METADATA --
-------------------------------
--
