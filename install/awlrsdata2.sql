-------------------------------------------------------------------------
--   PVCS Identifiers :-
--
--       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/install/awlrsdata2.sql-arc   1.27   Jun 11 2020 13:59:08   Barbara.Odriscoll  $
--       Module Name      : $Workfile:   awlrsdata2.sql  $
--       Date into PVCS   : $Date:   Jun 11 2020 13:59:08  $
--       Date fetched Out : $Modtime:   Jun 11 2020 13:57:20  $
--       Version          : $Revision:   1.27  $
--       Table Owner      : AWLRS_METADATA
--       Generation Date  : 18-MAR-2020 15:44
--
--   Product metadata script
--   As at Release 4.7.1.0
--
-------------------------------------------------------------------------
--   Copyright (c) 2020 Bentley Systems Incorporated. All rights reserved.
-------------------------------------------------------------------------
--
--   TABLES PROCESSED
--   ================
--   NM_ERRORS
--   HIG_STANDARD_FAVOURITES
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
      ,'Cannot find end x,y of the geometry'
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
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,23
      ,null
      ,'Invalid Node Id supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 23);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,24
      ,null
      ,'Record has been changed by another user, please requery to see the changes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 24);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,25
      ,null
      ,'There are no changes to be applied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 25);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,26
      ,null
      ,'Invalid Group of Datums Id supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 26);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,27
      ,null
      ,'Invalid Group of Groups Id supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 27);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,28
      ,null
      ,'Auto Inclusion parent not found'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 28);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,29
      ,null
      ,'Invalid Element Id supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 29);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,30
      ,null
      ,'From measure must be between than 0 and the current element length'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 30);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,31
      ,null
      ,'Old and new lengths are the same'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 31);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,32
      ,null
      ,'The Start Point and Shift Distance place the shift point before the start of the Element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 32);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,33
      ,null
      ,'The Start Point and Shift Distance place the shift point after the end of the Element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 33);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,34
      ,null
      ,'Please enter a value for the Start Point'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 34);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,35
      ,null
      ,'Please enter a value for the Shift Distance'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 35);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,36
      ,null
      ,'Start and End Nodes cannot be updated for a Group'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 36);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,37
      ,null
      ,'Invalid Asset Id supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 37);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,38
      ,null
      ,'The specified Node is not within tollerance of the element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 38);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,39
      ,null
      ,'Membership of an Inclusion Parent Group cannot be modified'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 39);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,40
      ,null
      ,'Update of Start and/or End of a Member is not allowed for non Partial Group Types'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 40);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,41
      ,null
      ,'Invalid Group Member supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 41);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,42
      ,null
      ,'Please provide either a measure or a node id.'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 42);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,43
      ,null
      ,'Invalid filter function'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 43);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,44
      ,null
      ,'Please specify a search string'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 44);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,45
      ,null
      ,'Two values must be supplied for filter function'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 45);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,46
      ,null
      ,'A saved search with this name already exists, would you like to overwrite it?'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 46);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,47
      ,null
      ,'Group is circular, please select a start point'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 47);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,48
      ,null
      ,'Update of Start and/or End of a Member is not allowed for an Inclusion Parent Group'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 48);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,49
      ,null
      ,'The selected Parent Group Type is Exclusive, please use the End-Date Existing Memberships option'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 49);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,50
      ,null
      ,'The Element Ids given must all be of the same Network\Group type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 50);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,51
      ,null
      ,'The selected Parent Group Type is Exclusive, please select a single Parent Group'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 51);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,52
      ,null
      ,'Invalid Extent Id supplied'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 52);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,53
      ,null
      ,'Unable to derive a Datum Theme for the given Group Theme'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 53);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,54
      ,null
      ,'Unable to derive a Group Type for Theme'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 54);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,55
      ,null
      ,'Group Type For Theme must be non linear'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 55);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,56
      ,null
      ,'The Group Type for the given Theme and Element must be the same'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 56);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,57
      ,null
      ,'Region of interest contains no datum elements'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 57);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,58
      ,null
      ,'Column not defined in pavement construction attributes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 58);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,59
      ,null
      ,'Column defined more than once in pavement construction attributes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 59);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,60
      ,null
      ,'Network Element belongs to a Circular Route, please retry with Rescale All set to "Off" and manually run Rescale for the relevant groups'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 60);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,61
      ,null
      ,'Network Element belongs to a Circular Route, please retry with Maintain History set to "Off" and manually run Rescale for the relevant groups'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 61);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,62
      ,null
      ,'Unable to derive datatype of column'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 62);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,63
      ,null
      ,'Only the To Offset can be updated for a Distance Break'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 63);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,64
      ,null
      ,'Asset Attribution Does Not Match'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 64);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,65
      ,null
      ,'Assets have locations beyond the specified element'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 65);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,66
      ,null
      ,'Asset locations are not contiguous'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 66);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,67
      ,null
      ,'All assets must be of the same type'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 67);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,68
      ,null
      ,'Merge of hierarchical assets is not supported'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 68);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,69
      ,null
      ,'Theme must be linear'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 69);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,70
      ,null
      ,'No path'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 70);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,71
      ,null
      ,'No network elements close enough to the xy co-ordinates'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 71);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,72
      ,null
      ,'Network not instantiated, cannot compute the connectivity'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 72);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,73
      ,null
      ,'Points are the same - no distance between them'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 73);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,74
      ,null
      ,'Update not allowed on an end dated record'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 74);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,75
      ,null
      ,'Only one of Domain, Query, Sequence Name or Default can be specified'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 75);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,76
      ,null
      ,'The String End value must be greater than the String Start value'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 76);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,77
      ,null
      ,'Asset deletion summary'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 77);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,78
      ,null
      ,'Unable to delete asset'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 78);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,79
      ,null
      ,'Asset deleted'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 79);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,80
      ,null
      ,'When Primary is set to Y, both Single Row and Mandatory must also be set to Y'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 80);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,81
      ,null
      ,'Including Child Assets:'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 81);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,82
      ,null
      ,'End-Dated assets cannot be merged'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 82);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,83
      ,null
      ,'Invalid User Option'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 83);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,84
      ,null
      ,'Admin Unit Start Date cannot be earlier than the User''s Start Date'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 84);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,85
      ,null
      ,'Route is ill-formed. Please check your changes'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 85);
--
INSERT
  INTO NM_ERRORS
      (NER_APPL
      ,NER_ID
      ,NER_HER_NO
      ,NER_DESCR
      ,NER_CAUSE)
SELECT 'AWLRS'
      ,86
      ,null
      ,'Invalid Package/Procedure name'
      ,''
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM NM_ERRORS
                   WHERE NER_APPL = 'AWLRS'
                     AND NER_ID = 86);
--
----------------------------------------------------------------------------------------
-- HIG_STANDARD_FAVOURITES
--
-- select * from awlrs_metadata.hig_standard_favourites
-- order by hstf_parent
--         ,hstf_child
--
----------------------------------------------------------------------------------------
SET TERM ON
PROMPT hig_standard_favourites
SET TERM OFF
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0301'
      ,'Asset Domains'
      ,'M'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0301');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0305'
      ,'XSP and Reversal Rules'
      ,'M'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0305');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0306'
      ,'Asset XSPs'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0306');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_ASSET'
      ,'NM0410'
      ,'Asset Types'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_ASSET'
                     AND HSTF_CHILD = 'NM0410');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_ASSET'
      ,'Asset Metadata'
      ,'F'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_ASSET');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_NETWORK'
      ,'Network Metadata'
      ,'F'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_NETWORK');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_NSG'
      ,'NSG Metadata'
      ,'F'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_NSG');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_REFERENCE'
      ,'Reference Data'
      ,'F'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_REFERENCE');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_SECURITY'
      ,'Security'
      ,'F'
      ,60
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_SECURITY');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_LAUNCHPAD'
      ,'AWLRS_SPATIAL'
      ,'Spatial Metadata'
      ,'F'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_LAUNCHPAD'
                     AND HSTF_CHILD = 'AWLRS_SPATIAL');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_NETWORK'
      ,'NM0001'
      ,'Node Types'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_NETWORK'
                     AND HSTF_CHILD = 'NM0001');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_NETWORK'
      ,'NM0002'
      ,'Network Types'
      ,'M'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_NETWORK'
                     AND HSTF_CHILD = 'NM0002');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_NETWORK'
      ,'NM0004'
      ,'Group Types'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_NETWORK'
                     AND HSTF_CHILD = 'NM0004');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG1820'
      ,'Units and Conversions'
      ,'M'
      ,70
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG1820');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG1832'
      ,'Users'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG1832');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG1837'
      ,'User Option Administration'
      ,'M'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG1837');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9120'
      ,'Domains'
      ,'M'
      ,20
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9120');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9130'
      ,'Product Options'
      ,'M'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9130');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9135'
      ,'Product and User Option List'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9135');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_REFERENCE'
      ,'HIG9185'
      ,'Error Messages'
      ,'M'
      ,60
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_REFERENCE'
                     AND HSTF_CHILD = 'HIG9185');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1836'
      ,'Roles'
      ,'M'
      ,30
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1836');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1860'
      ,'Admin Units'
      ,'M'
      ,10
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1860');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1870'
      ,'Upgrades'
      ,'M'
      ,60
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1870');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1880'
      ,'Modules'
      ,'M'
      ,40
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1880');
--
INSERT
  INTO HIG_STANDARD_FAVOURITES
      (HSTF_PARENT
      ,HSTF_CHILD
      ,HSTF_DESCR
      ,HSTF_TYPE
      ,HSTF_ORDER)
SELECT 'AWLRS_SECURITY'
      ,'HIG1890'
      ,'Products'
      ,'M'
      ,50
  FROM DUAL
 WHERE NOT EXISTS(SELECT 1
                    FROM HIG_STANDARD_FAVOURITES
                   WHERE HSTF_PARENT = 'AWLRS_SECURITY'
                     AND HSTF_CHILD = 'HIG1890');
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
