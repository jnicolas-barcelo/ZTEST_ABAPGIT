*&---------------------------------------------------------------------*
*& Report ZBP_MIGS4_SUB2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbp_migs4_sub2.

* Local type
TYPES: BEGIN OF lty_bp_vendor_ids,
         partner_guid TYPE bu_partner_guid,
         vendor       TYPE lifnr,
         del_flag     TYPE boole-boole,
       END OF lty_bp_vendor_ids.

* Local data declarations
DATA:
  lv_msg               TYPE char255,
*    lv_lifnr                  type lfa1-lifnr,
  lv_dbcnt             TYPE char10,
*    lv_partner_guid           type but000-partner_guid,
  db_vendor            TYPE cursor,
  ls_bp_vendor_ids     TYPE lty_bp_vendor_ids,
  lt_bp_vendor_ids     TYPE TABLE OF lty_bp_vendor_ids,
  ls_entries_to_delete LIKE cvi_vend_link,
  lt_entries_to_delete LIKE TABLE OF ls_entries_to_delete.

TYPES: BEGIN OF ty_but000,
         partner_guid TYPE bu_partner_guid,
       END OF ty_but000.

DATA : lt_but000 TYPE STANDARD TABLE OF ty_but000.

TYPES: BEGIN OF ty_lfa1,
         lifnr TYPE lifnr,
       END OF ty_lfa1.

DATA : lt_lfa1 TYPE STANDARD TABLE OF ty_lfa1.

CONSTANTS: lc_x        TYPE boole-boole VALUE 'X',
           lc_pkg_size TYPE char5       VALUE '10000'.

PARAMETERS testmode TYPE boole_d AS CHECKBOX DEFAULT 'X'.

CLEAR: lv_msg,
       lv_dbcnt,
       ls_bp_vendor_ids,
       ls_entries_to_delete.

REFRESH lt_entries_to_delete.

OPEN CURSOR db_vendor FOR
     SELECT partner_guid vendor FROM cvi_vend_link.

DO.
  CLEAR ls_bp_vendor_ids.
  REFRESH lt_bp_vendor_ids.
  REFRESH lt_but000.
  REFRESH lt_lfa1.
  FETCH NEXT CURSOR db_vendor INTO CORRESPONDING FIELDS OF TABLE lt_bp_vendor_ids
                                PACKAGE SIZE lc_pkg_size.
  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    SELECT partner_guid FROM but000 INTO TABLE lt_but000 FOR ALL ENTRIES IN lt_bp_vendor_ids WHERE partner_guid = lt_bp_vendor_ids-partner_guid.
    SORT lt_but000 BY partner_guid.

    SELECT lifnr FROM lfa1 INTO TABLE lt_lfa1 FOR ALL ENTRIES IN lt_bp_vendor_ids WHERE lifnr = lt_bp_vendor_ids-vendor.
    SORT lt_lfa1 BY lifnr.

    LOOP AT lt_bp_vendor_ids INTO ls_bp_vendor_ids.
*        clear lv_partner_guid.
*        select single partner_guid FROM  but000
*                                  INTO  lv_partner_guid
*                                  WHERE partner_guid = ls_bp_vendor_ids-partner_guid.
      READ TABLE lt_but000 WITH KEY partner_guid = ls_bp_vendor_ids-partner_guid TRANSPORTING NO FIELDS BINARY SEARCH.

      IF sy-subrc <> 0.
        ls_bp_vendor_ids-del_flag = lc_x.
      ELSE.
*            clear lv_lifnr.
*            select single lifnr FROM  lfa1
*                    INTO  lv_lifnr
*                    WHERE lifnr = ls_bp_vendor_ids-vendor.
        READ TABLE lt_lfa1 WITH KEY lifnr = ls_bp_vendor_ids-vendor TRANSPORTING NO FIELDS BINARY SEARCH.

        IF sy-subrc <> 0.
          ls_bp_vendor_ids-del_flag = lc_x.
        ENDIF.
      ENDIF.
      IF ls_bp_vendor_ids-del_flag = lc_x.
        CLEAR ls_entries_to_delete.
        ls_entries_to_delete-partner_guid = ls_bp_vendor_ids-partner_guid.
        ls_entries_to_delete-vendor = ls_bp_vendor_ids-vendor.
        APPEND ls_entries_to_delete TO lt_entries_to_delete.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDDO.

CLOSE CURSOR db_vendor.

IF testmode IS INITIAL.
  IF lt_entries_to_delete IS NOT INITIAL.
    DELETE cvi_vend_link FROM TABLE lt_entries_to_delete.
    WRITE : 'Non Test Run Mode'.
    lv_dbcnt = sy-dbcnt.
    lv_msg = TEXT-002.
    CONCATENATE lv_msg TEXT-003 INTO lv_msg SEPARATED BY space.
    CONCATENATE lv_msg lv_dbcnt INTO lv_msg SEPARATED BY space.
    COMMIT WORK.
    WRITE TEXT-005.
    NEW-LINE.
    ULINE.
    WRITE : 'Business partner GUID'.
    WRITE :36 'Venor Number'.

    LOOP AT lt_entries_to_delete INTO ls_entries_to_delete.
      NEW-LINE.
      WRITE: ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-vendor.
      CLEAR: ls_entries_to_delete.
    ENDLOOP.
  ELSE.
    lv_msg = TEXT-001.
  ENDIF.
  WRITE lv_msg.
ELSE.
  IF lt_entries_to_delete IS NOT INITIAL.
    WRITE : 'Test Run Mode'.
    WRITE TEXT-004.
    NEW-LINE.
    ULINE.
    WRITE : 'Business partner GUID'.
    WRITE :36 'Vendor Number'.

    LOOP AT lt_entries_to_delete INTO ls_entries_to_delete.
      NEW-LINE.
      WRITE: ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-vendor.
      CLEAR: ls_entries_to_delete.
    ENDLOOP.
  ENDIF.
ENDIF.
