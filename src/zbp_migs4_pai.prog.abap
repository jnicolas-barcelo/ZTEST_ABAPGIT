*&---------------------------------------------------------------------*
*&  Include           ZBP_MIGS4_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F15'.
      LEAVE TO SCREEN 0.
    WHEN '&EJECUTAR'.
      PERFORM f_ejecutar_programa.
    WHEN '&MARCAR'.
      PERFORM f_marcar_todo.
    WHEN '&DESMARCAR'.
      PERFORM f_desmarcar_todo.
    WHEN 'P011'.
      CALL TRANSACTION 'CVI_CUSTOMIZING_CHK'.
    WHEN 'P012'.
      SUBMIT precheck_upgradation_report VIA SELECTION-SCREEN AND RETURN.
    WHEN 'P013'.
      CALL TRANSACTION 'MDS_LOAD_COCKPIT'.
    WHEN 'P014'.
      CALL TRANSACTION 'MDS_PPO2'.
    WHEN 'BP01'.
      PERFORM f_cuadre_clientes.
    WHEN 'BP02'.
      PERFORM f_bp_creado.
    WHEN 'BP03'.
      PERFORM f_chequeo_pagos.
    WHEN 'HR01'.
      CALL TRANSACTION 'BUPA_DEL'.
    WHEN 'HR02'.
      SUBMIT zbp_migs4_sub1 VIA SELECTION-SCREEN AND RETURN.
    WHEN 'HR03'.
      SUBMIT zbp_migs4_sub2 VIA SELECTION-SCREEN AND RETURN.
    WHEN 'HR04'.
      SUBMIT zbp_migs4_sub3 VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

ENDMODULE.                    "user_command_0100 INPUT
*&---------------------------------------------------------------------*
*&      Module  PES1_ACTIVE_TAB_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pes1_active_tab_get INPUT.
  IF gt_users IS INITIAL.
* Obtengo el SET de datos con los grupos de cuentas a validar
    CALL FUNCTION 'G_SET_FETCH'
      EXPORTING
        setnr           = '0000ZMIGS4_VAL_BPS'  " Se pone 0000 antes del nombre del SET
      TABLES
        set_lines_basic = gt_users
      EXCEPTIONS
        no_authority    = 1
        set_is_broken   = 2
        set_not_found   = 3
        OTHERS          = 4.

    IF sy-subrc = 0.
      IF line_exists( gt_users[ from = sy-uname ] ).
        gv_superuser = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_pes1-tab1.
      g_pes1-pressed_tab = c_pes1-tab1.
    WHEN c_pes1-tab2.
      IF gv_superuser = abap_false.
        MESSAGE 'Funcionalidad deshabilitada' TYPE 'W'.
      ELSE.
        g_pes1-pressed_tab = c_pes1-tab2.
      ENDIF.
    WHEN c_pes1-tab3.
      IF gv_superuser = abap_false.
        MESSAGE 'Funcionalidad deshabilitada' TYPE 'W'.
      ELSE.
        g_pes1-pressed_tab = c_pes1-tab3.
      ENDIF.
    WHEN c_pes1-tab4.
      IF gv_superuser = abap_false.
        MESSAGE 'Funcionalidad deshabilitada' TYPE 'W'.
      ELSE.
        g_pes1-pressed_tab = c_pes1-tab4.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                    "pes1_active_tab_get INPUT
