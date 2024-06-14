*&---------------------------------------------------------------------*
*& Report ZBP_MIGS4_SUB3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbp_migs4_sub3.

* Local type
TYPES: BEGIN OF lty_bp_cust_contact_ids,
         partner_guid  TYPE bu_partner_guid,
         person_guid   TYPE bu_partner_guid,
         customer_cont TYPE parnr,
         del_flag      TYPE boole-boole,
       END OF lty_bp_cust_contact_ids.

* Local data declarations
DATA:
  lv_msg                 TYPE char255,
  lv_dbcnt               TYPE char10,
*    lv_parnr                  type knvk-parnr,
  lv_person              TYPE bu_partner,
  lv_partner             TYPE bu_partner,
  lv_partnertmp          TYPE bu_partner,
  lv_partner_guid        TYPE but000-partner_guid,
  lv_person_guid         TYPE but000-partner_guid,
  db_cust_contact        TYPE cursor,
  ls_bp_cust_contact_ids TYPE lty_bp_cust_contact_ids,
  lt_bp_cust_contact_ids TYPE TABLE OF lty_bp_cust_contact_ids,
  ls_entries_to_delete   LIKE cvi_cust_ct_link,
  lt_entries_to_delete   LIKE TABLE OF ls_entries_to_delete.

TYPES: BEGIN OF ty_but000,
         partner      TYPE bu_partner,
         partner_guid TYPE bu_partner_guid,
       END OF ty_but000.

DATA : lt_but000         TYPE STANDARD TABLE OF ty_but000,
       lt_tmp_but000     TYPE STANDARD TABLE OF ty_but000,
       ls_but000_partner TYPE ty_but000,
       ls_but000_person  TYPE  ty_but000.

TYPES: BEGIN OF ty_knvk,
         parnr TYPE parnr,
       END OF ty_knvk.

DATA : lt_knvk TYPE STANDARD TABLE OF ty_knvk.

CONSTANTS: lc_x        TYPE boole-boole VALUE 'X',
           lc_reltyp   TYPE char6       VALUE 'BUR001',
           lc_pkg_size TYPE char5       VALUE '10000'.

CLEAR: lv_msg,
       lv_dbcnt,
       ls_entries_to_delete.

PARAMETERS testmode TYPE boole_d AS CHECKBOX DEFAULT 'X'.

REFRESH lt_entries_to_delete.

OPEN CURSOR db_cust_contact FOR
     SELECT partner_guid person_guid customer_cont FROM cvi_cust_ct_link.

DO.
  CLEAR ls_bp_cust_contact_ids.
  REFRESH lt_bp_cust_contact_ids.
  REFRESH: lt_but000, lt_tmp_but000, lt_knvk.

  FETCH NEXT CURSOR db_cust_contact INTO CORRESPONDING FIELDS OF TABLE lt_bp_cust_contact_ids
                                    PACKAGE SIZE lc_pkg_size.

  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    SELECT partner partner_guid FROM but000 INTO TABLE lt_tmp_but000 FOR ALL ENTRIES IN lt_bp_cust_contact_ids WHERE partner_guid = lt_bp_cust_contact_ids-partner_guid.
    lt_but000[] = lt_tmp_but000[].

    SELECT partner partner_guid FROM but000 INTO TABLE lt_tmp_but000 FOR ALL ENTRIES IN lt_bp_cust_contact_ids WHERE partner_guid = lt_bp_cust_contact_ids-person_guid.
    APPEND LINES OF lt_tmp_but000 TO lt_but000.

    SORT lt_but000 BY partner_guid.
    DELETE ADJACENT DUPLICATES FROM lt_but000.

    SELECT parnr FROM knvk INTO TABLE lt_knvk FOR ALL ENTRIES IN lt_bp_cust_contact_ids WHERE parnr = lt_bp_cust_contact_ids-customer_cont.
    SORT lt_knvk BY parnr.

    LOOP AT lt_bp_cust_contact_ids INTO ls_bp_cust_contact_ids.
*        clear lv_partner.
*        select single partner FROM  but000
*                                  INTO  lv_partner
*                                  WHERE partner_guid = ls_bp_cust_contact_ids-partner_guid.
      READ TABLE lt_but000 WITH KEY partner_guid = ls_bp_cust_contact_ids-partner_guid INTO ls_but000_partner BINARY SEARCH.
      IF sy-subrc <> 0.
        ls_bp_cust_contact_ids-del_flag = lc_x.
      ELSE.
*          clear lv_person.
*          select single partner FROM  but000
*                                    INTO  lv_person
*                                    WHERE partner_guid = ls_bp_cust_contact_ids-person_guid.
        READ TABLE lt_but000 WITH KEY partner_guid = ls_bp_cust_contact_ids-person_guid INTO ls_but000_person BINARY SEARCH.
        IF sy-subrc <> 0.
          ls_bp_cust_contact_ids-del_flag = lc_x.
        ELSE.
          CLEAR: lv_partnertmp.
          SELECT SINGLE partner1 FROM but051
                                 INTO lv_partnertmp
                                 WHERE ( partner1     = ls_but000_partner-partner "lv_partner
                                         AND partner2 = ls_but000_person-partner "lv_person
                                         AND reltyp   = lc_reltyp )
                                       OR
                                       ( partner1     = ls_but000_person-partner "lv_person
                                         AND partner2 = ls_but000_partner-partner "lv_partner
                                         AND reltyp   = lc_reltyp ).

          IF sy-subrc <> 0.
            ls_bp_cust_contact_ids-del_flag = lc_x.
          ELSE.
*               clear lv_parnr.
*               select single parnr FROM  knvk
*                                  INTO  lv_parnr
*                                  WHERE parnr = ls_bp_cust_contact_ids-customer_cont.
            READ TABLE lt_knvk WITH KEY parnr = ls_bp_cust_contact_ids-customer_cont TRANSPORTING NO FIELDS BINARY SEARCH.
            IF sy-subrc <> 0.
              ls_bp_cust_contact_ids-del_flag = lc_x.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF ls_bp_cust_contact_ids-del_flag = lc_x.
        CLEAR ls_entries_to_delete.
        ls_entries_to_delete-partner_guid = ls_bp_cust_contact_ids-partner_guid.
        ls_entries_to_delete-person_guid = ls_bp_cust_contact_ids-person_guid.
        ls_entries_to_delete-customer_cont = ls_bp_cust_contact_ids-customer_cont.
        APPEND ls_entries_to_delete TO lt_entries_to_delete.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDDO.

CLOSE CURSOR db_cust_contact.

IF testmode IS INITIAL.
  IF lt_entries_to_delete IS NOT INITIAL.
    DELETE cvi_cust_ct_link FROM TABLE lt_entries_to_delete.
    WRITE : 'Non Test Run Mode'.
    lv_dbcnt = sy-dbcnt.
    lv_msg = TEXT-002.
    CONCATENATE lv_msg TEXT-003 INTO lv_msg SEPARATED BY space.
    CONCATENATE lv_msg lv_dbcnt INTO lv_msg SEPARATED BY space.
    COMMIT WORK.
    NEW-LINE.
    ULINE.
    WRITE : 'Business partner GUID'.
    WRITE :36 'Business partner GUID'.
    WRITE :36 'Customer Contact Number'.

    LOOP AT lt_entries_to_delete INTO ls_entries_to_delete.
      NEW-LINE.
      WRITE: ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-customer_cont.
      CLEAR: ls_entries_to_delete.
    ENDLOOP.
  ELSE.
    lv_msg = TEXT-001.
  ENDIF.
  WRITE lv_msg.
ELSE.
  IF lt_entries_to_delete IS NOT INITIAL.
    WRITE : 'Test Run Mode'.
    NEW-LINE.
    ULINE.
    WRITE : 'Business partner GUID'.
    WRITE :36 'Business partner GUID'.
    WRITE :71 'Customer Contact Number'.

    LOOP AT lt_entries_to_delete INTO ls_entries_to_delete.
      NEW-LINE.
      WRITE: ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-partner_guid, space, ls_entries_to_delete-customer_cont.
      CLEAR: ls_entries_to_delete.
    ENDLOOP.
  ENDIF.
ENDIF.
