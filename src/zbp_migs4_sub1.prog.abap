*&---------------------------------------------------------------------*
*& Report ZBP_MIGS4_SUB1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbp_migs4_sub1.

* Local type
TYPES: BEGIN OF lty_bp_customer_ids,
         partner_guid TYPE bu_partner_guid,
         customer     TYPE kunnr,
         del_flag     TYPE boole-boole,
       END OF lty_bp_customer_ids.

* Local data declarations
DATA:
  lv_msg               TYPE char255,
*    lv_kunnr                  type kna1-kunnr,
  lv_dbcnt             TYPE char10,
*    lv_partner_guid           type but000-partner_guid,
  db_customer          TYPE cursor,
  ls_bp_customer_ids   TYPE lty_bp_customer_ids,
  lt_bp_customer_ids   TYPE TABLE OF lty_bp_customer_ids,
  ls_entries_to_delete LIKE cvi_cust_link,
  lt_entries_to_delete LIKE TABLE OF ls_entries_to_delete.

TYPES: BEGIN OF ty_but000,
         partner_guid TYPE bu_partner_guid,
       END OF ty_but000.

DATA : lt_but000 TYPE STANDARD TABLE OF ty_but000.

TYPES: BEGIN OF ty_kna1,
         kunnr TYPE kunnr,
       END OF ty_kna1.

DATA : lt_kna1 TYPE STANDARD TABLE OF ty_kna1.

CONSTANTS: lc_x        TYPE boole-boole VALUE 'X',
           lc_pkg_size TYPE char5       VALUE '10000'.

PARAMETERS testmode TYPE boole_d AS CHECKBOX DEFAULT 'X'.

CLEAR: lv_msg,
       lv_dbcnt,
       ls_bp_customer_ids,
       ls_entries_to_delete.

REFRESH lt_entries_to_delete.

OPEN CURSOR db_customer FOR
     SELECT partner_guid customer FROM cvi_cust_link.

DO.
  CLEAR ls_bp_customer_ids.
  REFRESH lt_bp_customer_ids.
  REFRESH lt_but000.
  REFRESH lt_kna1.
  FETCH NEXT CURSOR db_customer INTO CORRESPONDING FIELDS OF TABLE lt_bp_customer_ids
                                PACKAGE SIZE lc_pkg_size.
  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    SELECT partner_guid FROM but000 INTO TABLE lt_but000 FOR ALL ENTRIES IN lt_bp_customer_ids WHERE partner_guid = lt_bp_customer_ids-partner_guid.
    SORT lt_but000 BY partner_guid.

    SELECT kunnr FROM kna1 INTO TABLE lt_kna1 FOR ALL ENTRIES IN lt_bp_customer_ids WHERE kunnr = lt_bp_customer_ids-customer.
    SORT lt_kna1 BY kunnr.

    LOOP AT lt_bp_customer_ids INTO ls_bp_customer_ids.
*        clear lv_partner_guid.
*        select single partner_guid FROM  but000
*                                  INTO  lv_partner_guid
*                                  WHERE partner_guid = ls_bp_customer_ids-partner_guid.
      READ TABLE lt_but000 WITH KEY partner_guid = ls_bp_customer_ids-partner_guid TRANSPORTING NO FIELDS BINARY SEARCH.

      IF sy-subrc <> 0.
        ls_bp_customer_ids-del_flag = lc_x.
      ELSE.
*            clear lv_kunnr.
*            select single kunnr FROM  kna1
*                                INTO  lv_kunnr
*                                WHERE kunnr = ls_bp_customer_ids-customer.
        READ TABLE lt_kna1 WITH KEY kunnr = ls_bp_customer_ids-customer TRANSPORTING NO FIELDS BINARY SEARCH.

        IF sy-subrc <> 0.
          ls_bp_customer_ids-del_flag = lc_x.
        ENDIF.
      ENDIF.
      IF ls_bp_customer_ids-del_flag = lc_x.
        CLEAR ls_entries_to_delete.
        ls_entries_to_delete-partner_guid = ls_bp_customer_ids-partner_guid.
        ls_entries_to_delete-customer = ls_bp_customer_ids-customer.
        APPEND ls_entries_to_delete TO lt_entries_to_delete.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDDO.

CLOSE CURSOR db_customer.

IF testmode IS INITIAL.
  IF lt_entries_to_delete IS NOT INITIAL.
    DELETE cvi_cust_link FROM TABLE lt_entries_to_delete.
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
    WRITE :36 'Customer Number'.

    LOOP AT lt_entries_to_delete INTO ls_entries_to_delete.
      NEW-LINE.
      WRITE: ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-customer.
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
    WRITE :36 'Customer Number'.

    LOOP AT lt_entries_to_delete INTO ls_entries_to_delete.
      NEW-LINE.
      WRITE: ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-customer.
      CLEAR: ls_entries_to_delete.
    ENDLOOP.
  ENDIF.
ENDIF.
