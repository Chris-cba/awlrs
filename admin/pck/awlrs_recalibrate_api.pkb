CREATE OR REPLACE PACKAGE BODY awlrs_recalibrate_api
AS
  -------------------------------------------------------------------------
  --   PVCS Identifiers :-
  --
  --       PVCS id          : $Header:   //new_vm_latest/archives/awlrs/admin/pck/awlrs_recalibrate_api.pkb-arc   1.0   14 Nov 2016 13:51:28   Mike.Huitson  $
  --       Module Name      : $Workfile:   awlrs_recalibrate_api.pkb  $
  --       Date into PVCS   : $Date:   14 Nov 2016 13:51:28  $
  --       Date fetched Out : $Modtime:   14 Nov 2016 13:49:52  $
  --       Version          : $Revision:   1.0  $
  -------------------------------------------------------------------------
  --   Copyright (c) 2016 Bentley Systems Incorporated. All rights reserved.
  -------------------------------------------------------------------------
  --
  --g_body_sccsid is the SCCS ID for the package body
  g_body_sccsid  CONSTANT VARCHAR2 (2000) := '\$Revision:   1.0  $';

  g_package_name  CONSTANT VARCHAR2 (30) := 'awlrs_recalibrate_api';
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_version
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN g_sccsid;
  END get_version;

  --
  -----------------------------------------------------------------------------
  --
  FUNCTION get_body_version
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN g_body_sccsid;
  END get_body_version;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_recalibration(pi_ne_id             IN  nm_elements_all.ne_id%TYPE
                            ,pi_start_point       IN  NUMBER
                            ,pi_new_length_to_end IN  NUMBER
                            ,pi_reason            IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                            ,po_message_severity  OUT hig_codes.hco_code%TYPE
                            ,po_message_cursor    OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    e_record_locked exception;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    e_nothing_to_do exception;
    PRAGMA EXCEPTION_INIT(e_nothing_to_do, -20054);
    --
  BEGIN
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.is_nt_datum(p_nt_type => lr_ne.ne_nt_type) != 'Y'
     THEN
        --Operation can only be performed on a datum element.
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 119);
    END IF;
    --
    IF pi_start_point < 0
     OR pi_start_point > lr_ne.ne_length
     THEN
        --From measure must be between than 0 and the current element length.
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 30);
    END IF;
    --
    BEGIN
      --
      nm3recal.recalibrate_section(pi_ne_id             => pi_ne_id
                                  ,pi_begin_mp          => pi_start_point
                                  ,pi_new_length_to_end => pi_new_length_to_end
                                  ,pi_neh_descr         => pi_reason);
      --
    EXCEPTION
      WHEN e_nothing_to_do
       THEN
          --Old and new lengths are the same
          hig.raise_ner(pi_appl => 'AWLRS'
                       ,pi_id   => 31);
      WHEN e_record_locked
       THEN
          --Record locked by another user. Try again later.
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33);
    END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_recalibration;

  --
  -----------------------------------------------------------------------------
  --
  PROCEDURE do_shift(pi_ne_id            IN  nm_elements_all.ne_id%TYPE
                    ,pi_start_point      IN  NUMBER
                    ,pi_shift_distance   IN  NUMBER
                    ,pi_reason           IN  nm_element_history.neh_descr%TYPE DEFAULT NULL
                    ,po_message_severity OUT hig_codes.hco_code%TYPE
                    ,po_message_cursor   OUT sys_refcursor)
    IS
    --
    lr_ne  nm_elements_all%ROWTYPE;
    --
    e_record_locked exception;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    --
  BEGIN
    --
    lr_ne := nm3net.get_ne(pi_ne_id => pi_ne_id);
    --
    IF nm3net.is_nt_datum(p_nt_type => lr_ne.ne_nt_type) != 'Y'
     THEN
        --Operation can only be performed on a datum element.
        hig.raise_ner(pi_appl => 'NET'
                     ,pi_id   => 119);
    END IF;
    --
    IF pi_start_point IS NULL
     THEN
        --Please enter a value for the start point
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 34);
    END IF;
    --
    IF pi_shift_distance IS NULL
     THEN
        --Please enter a value for the shift distance
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 35);
    END IF;
    --
    IF pi_start_point + pi_shift_distance < 0
     THEN
        --The start point and shift distance place
        --the shift point before the start of the element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 32);
    ELSIF pi_start_point + pi_shift_distance > lr_ne.ne_length
     THEN
        --The start point and shift distance place
        --the shift point after the end of the element
        hig.raise_ner(pi_appl => 'AWLRS'
                     ,pi_id   => 33);
    END IF;
    --
    BEGIN
      --
      nm3recal.shift_section(pi_ne_id          => pi_ne_id
                            ,pi_begin_mp       => pi_start_point
                            ,pi_shift_distance => pi_shift_distance
                            ,pi_neh_descr      => pi_reason);
      --
    EXCEPTION
      WHEN e_record_locked
       THEN
          hig.raise_ner(pi_appl => 'HIG'
                       ,pi_id   => 33);
    END;
    --
    awlrs_util.get_default_success_cursor(po_message_severity => po_message_severity
                                         ,po_cursor           => po_message_cursor);
    --
  EXCEPTION
    WHEN others
     THEN
        awlrs_util.handle_exception(po_message_severity => po_message_severity
                                   ,po_cursor           => po_message_cursor);
  END do_shift;

END awlrs_recalibrate_api;
/
