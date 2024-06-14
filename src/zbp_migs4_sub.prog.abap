*&---------------------------------------------------------------------*
*&  Include           ZBP_MIGS4_SUB
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_EJECUTAR_PROGRAMA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_ejecutar_programa.

  CASE g_pes1-pressed_tab.
    WHEN c_pes1-tab1.
*     Comprobamos todos los puntos seleccionados por el usuario.
      PERFORM f_chequeos_migracion.

*     Mostramos el ALV principal.
      PERFORM f_mostar_alv.

    WHEN c_pes1-tab2.
    WHEN c_pes1-tab3.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "f_ejecutar_programa
*&---------------------------------------------------------------------*
*&      Form  F_MARCAR_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_marcar_todo .

**  "INI ZPRY_PRS4 03.04.2024 54217049T
*  p_1 = p_2 = p_3 = p_4 = p_5 = p_6 = p_7 = p_8 = p_9 = abap_true.
  p_1 = p_2 = p_3 = p_4 = p_5 = p_6 = p_7 = p_8 = p_9 = p_10b = p_11b = p_12b = abap_true.
**  "FIN ZPRY_PRS4

ENDFORM.                    "f_marcar_todo
*&---------------------------------------------------------------------*
*&      Form  F_DESMARCAR_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_desmarcar_todo.

**  "INI ZPRY_PRS4 03.04.2024 54217049T
*  CLEAR: p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9.
  CLEAR: p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9, p_10b, p_11b, p_12b.
**  "FIN ZPRY_PRS4

ENDFORM.                    "f_desmarcar_todo
*&---------------------------------------------------------------------*
*&      Form  F_MOSTAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_mostar_alv.

  PERFORM f_cargar_catalogo.

  PERFORM f_llamar_alv.
ENDFORM.                    "f_mostar_alv
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo .
  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_numero      TEXT-001  char_r   8  space     space    space,
                                  c_prueba      TEXT-002  char_l  55  space     space    space,
                                  c_semaforo    TEXT-003  char_c   8  space     space    space,
                                  c_comentario  TEXT-004  char_l  55  space     space    space.

ENDFORM.                    "f_cargar_catalogo
*&---------------------------------------------------------------------*
*&      Form  F_AGREGAR_CAMPOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_agregar_campos USING p_fieldname   p_coltext   p_just
                            p_outputlen   p_ref_table p_ref_field
                            p_emphasize.
  DATA: lw_catalogo          TYPE lvc_s_fcat.
  CLEAR lw_catalogo.

  lw_catalogo-fieldname     = p_fieldname.
  IF p_coltext IS NOT INITIAL.
    lw_catalogo-coltext       = p_coltext.
  ENDIF.
  lw_catalogo-just          = p_just.
  IF p_outputlen IS NOT INITIAL.
    lw_catalogo-outputlen     = p_outputlen.
  ENDIF.
  IF p_ref_table IS NOT INITIAL AND p_ref_field IS NOT INITIAL.
    lw_catalogo-ref_table     = p_ref_table.
    lw_catalogo-ref_field     = p_ref_field.
  ENDIF.
  lw_catalogo-emphasize     = p_emphasize.
  APPEND lw_catalogo TO i_catalogo.

ENDFORM.      "F_AGREGAR_CAMPOS
*&---------------------------------------------------------------------*
*&      Form  F_LLAMAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_llamar_alv.

  CALL FUNCTION c_alv_grid
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = c_user_command
      it_fieldcat_lvc         = i_catalogo
      i_save                  = char_x
    TABLES
      t_outtab                = i_alv_principal
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc EQ 0.
    CLEAR: i_kna1[], i_lfa1[].
  ENDIF.

ENDFORM.                    "f_llamar_alv
*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_user_command USING r_ucomm     TYPE syucomm
                          rs_selfield TYPE slis_selfield.

  DATA lw_alv_principal TYPE ty_alv_principal.
  CLEAR lw_alv_principal.

  CASE r_ucomm.
    WHEN c_ic1.
      IF rs_selfield-fieldname EQ c_semaforo.
        READ TABLE i_alv_principal INDEX rs_selfield-tabindex
          INTO lw_alv_principal.
        IF sy-subrc EQ 0.
          CASE lw_alv_principal-numero.
            WHEN 1.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-012.
                PERFORM f_chequeo_prueba_1.
                PERFORM f_progreso USING 100 TEXT-012.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 1.
*               Añadimos catálogo prueba 1.
                PERFORM f_cargar_catalogo_1.

*               Mostramos ALV prueba 1.
                PERFORM f_mostar_log USING i_kna1_log.
              ENDIF.
            WHEN 2.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-015.
                PERFORM f_chequeo_prueba_2.
                PERFORM f_progreso USING 100 TEXT-015.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 2.
*               Añadimos catálogo prueba 2.
                PERFORM f_cargar_catalogo_2.

*               Mostramos ALV prueba 2.
                PERFORM f_mostar_log USING i_lfa1_log.
              ENDIF.

            WHEN 3.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-016.
                PERFORM f_chequeo_prueba_3.
                PERFORM f_progreso USING 100 TEXT-016.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 3.
*               Añadimos catálogo prueba 3.
                PERFORM f_cargar_catalogo_3.

*               Mostramos ALV prueba 3.
                PERFORM f_mostar_log USING i_cruce_log.
              ENDIF.
            WHEN 4.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-017.
                PERFORM f_chequeo_prueba_4.
                PERFORM f_progreso USING 100 TEXT-017.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 4.
*               Añadimos catálogo prueba 4.
                PERFORM f_cargar_catalogo_4.

*               Mostramos ALV prueba 4.
                PERFORM f_mostar_log USING i_cp_log.
              ENDIF.
            WHEN 5.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-018.
                PERFORM f_chequeo_prueba_5.
                PERFORM f_progreso USING 100 TEXT-018.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 5.
*               Añadimos catálogo prueba 5 (mismo que el 4).
                PERFORM f_cargar_catalogo_4.

*               Mostramos ALV prueba 5.
                PERFORM f_mostar_log USING i_cp_db_log.
              ENDIF.
            WHEN 6.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-019.
                PERFORM f_chequeo_prueba_6.
                PERFORM f_progreso USING 100 TEXT-019.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 6.
*               Añadimos catálogo prueba 6.
                PERFORM f_cargar_catalogo_6.

*               Mostramos ALV prueba 6.
                PERFORM f_mostar_log USING i_bnka_log.
              ENDIF.
            WHEN 7.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-020.
                PERFORM f_chequeo_prueba_7.
                PERFORM f_progreso USING 100 TEXT-020.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 7.
*               Añadimos catálogo prueba 7.
                PERFORM f_cargar_catalogo_7.

*               Mostramos ALV prueba 7.
                PERFORM f_mostar_log USING i_nif_log.
              ENDIF.
            WHEN 8.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-021.
                PERFORM f_chequeo_prueba_8.
                PERFORM f_progreso USING 100 TEXT-021.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 8.
*               Añadimos catálogo prueba 8.
                PERFORM f_cargar_catalogo_8.

*               Mostramos ALV prueba 8.
                PERFORM f_mostar_log USING i_postal_log.
              ENDIF.
            WHEN 9.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-022.
                PERFORM f_chequeo_prueba_9.
                PERFORM f_progreso USING 100 TEXT-022.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 9.
*               Añadimos catálogo prueba 9.
                PERFORM f_cargar_catalogo_9.

*               Mostramos ALV prueba 9.
                PERFORM f_mostar_log USING i_correoe_log.
              ENDIF.
**            "INI ZPRY_PRS4 03.04.2024 54217049T
            WHEN 10.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-055.
                PERFORM f_chequeo_prueba_10b.
                PERFORM f_progreso USING 100 TEXT-055.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 10b.
*               Añadimos catálogo prueba 10b.
                PERFORM f_cargar_catalogo_10b.

*               Mostramos ALV prueba 10b.
                PERFORM f_mostar_log USING i_stcd1_log.
              ENDIF.
            WHEN 11.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-055.
                PERFORM f_chequeo_prueba_11b.
                PERFORM f_progreso USING 100 TEXT-055.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 11b.
*               Añadimos catálogo prueba 11b.
                PERFORM f_cargar_catalogo_11b.

*               Mostramos ALV prueba 11b.
                PERFORM f_mostar_log USING i_pstlz_log.
              ENDIF.
            WHEN 12.
              IF lw_alv_principal-semaforo EQ icon_dummy.
*               Lanzamos la prueba.
                PERFORM f_progreso USING 50  TEXT-062.
                PERFORM f_chequeo_prueba_12b.
                PERFORM f_progreso USING 100 TEXT-062.

*               Refrescamos el informe.
                PERFORM f_refrescar_informe.
              ELSEIF lw_alv_principal-semaforo EQ icon_system_cancel.
*               Mostramos resultado prueba 12b.
*               Añadimos catálogo prueba 12b.
                PERFORM f_cargar_catalogo_12b.

*               Mostramos ALV prueba 12b.
                PERFORM f_mostar_log USING i_anred_log.
              ENDIF.
**            "FIN ZPRY_PRS4
            WHEN 13."10. "" ZPRY_PRS4 03.04.2024 54217049T
*              READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                WITH KEY semaforo = icon_dummy.
*              IF sy-subrc EQ 0.
*                MESSAGE text-042 TYPE char_i.
*              ELSE.
*                READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                  WITH KEY semaforo = icon_system_cancel.
*                IF sy-subrc EQ 0.
*                  MESSAGE text-043 TYPE char_i.
*                ELSE.
              CALL TRANSACTION 'CVI_FS_CHECK_CUS_ENH'.
*                ENDIF.
*              ENDIF.
            WHEN 14."11. ""ZPRY_PRS4 03.04.2024 54217049T
*              READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                WITH KEY semaforo = icon_dummy.
*              IF sy-subrc EQ 0.
*                MESSAGE text-042 TYPE char_i.
*              ELSE.
*                READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                  WITH KEY semaforo = icon_system_cancel.
*                IF sy-subrc EQ 0.
*                  MESSAGE text-043 TYPE char_i.
*                ELSE.
              SUBMIT precheck_upgradation_report VIA SELECTION-SCREEN AND RETURN.
*                ENDIF.
*              ENDIF.
*            WHEN 13.
*              READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                WITH KEY semaforo = icon_dummy.
*              IF sy-subrc EQ 0.
*                MESSAGE text-042 TYPE char_i.
*              ELSE.
*                READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                  WITH KEY semaforo = icon_system_cancel.
*                IF sy-subrc EQ 0.
*                  MESSAGE text-043 TYPE char_i.
*                ELSE.
*                  CALL TRANSACTION 'MDS_LOAD_COCKPIT'.
*                ENDIF.
*              ENDIF.
*            WHEN 14.
*              READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                WITH KEY semaforo = icon_dummy.
*              IF sy-subrc EQ 0.
*                MESSAGE text-042 TYPE char_i.
*              ELSE.
*                READ TABLE i_alv_principal TRANSPORTING NO FIELDS
*                  WITH KEY semaforo = icon_system_cancel.
*                IF sy-subrc EQ 0.
*                  MESSAGE text-043 TYPE char_i.
*                ELSE.
*                  CALL TRANSACTION 'MDS_PPO2'.
*                ENDIF.
*              ENDIF.
            WHEN OTHERS.
          ENDCASE.

        ENDIF.
      ENDIF.

  ENDCASE.
ENDFORM.                    "f_user_command
*&---------------------------------------------------------------------*
*&      Form  F_MOSTAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KNA1_LOG  text
*----------------------------------------------------------------------*
FORM f_mostar_log  USING p_tabla.
  FIELD-SYMBOLS: <p_tabla_alv> TYPE STANDARD TABLE.

* Asignamos la tabla correspondiente.
  ASSIGN p_tabla TO <p_tabla_alv>.

  CALL FUNCTION c_alv_grid
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat_lvc    = i_catalogo
      i_save             = char_x
    TABLES
      t_outtab           = <p_tabla_alv>
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc EQ 0.
  ENDIF.

ENDFORM.                    "f_mostar_log
*&---------------------------------------------------------------------*
*&      Form  F_REFRESCAR_INFORME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_refrescar_informe.

  DATA: lo_ref1 TYPE REF TO cl_gui_alv_grid,
        ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL FUNCTION c_globals
    IMPORTING
      e_grid = lo_ref1.

  CALL METHOD lo_ref1->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.                    "f_refrescar_informe
*&---------------------------------------------------------------------*
*&      Form  F_OCULTAR_CAMPOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_ocultar_campos .
  IF g_pes1-pressed_tab NE c_pes1-tab1.
    LOOP AT SCREEN.
      screen-input     = 0. " Campo editable
      screen-invisible = 1. " Campo invisible
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "f_ocultar_campos
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEOS_MIGRACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeos_migracion.
  CLEAR i_alv_principal[].

  PERFORM f_progreso USING 0 TEXT-031.

* 1. Revisión de duplicados Clientes por NIF
  IF p_1 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 10 text-012.
    PERFORM f_progreso USING 7 TEXT-012.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_1.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 1 TEXT-012 TEXT-014 icon_dummy.
  ENDIF.

* 2. Revisión de duplicados Proveedor NIF.
  IF p_2 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 20 text-015.
    PERFORM f_progreso USING 14 TEXT-015.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_2.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 2 TEXT-015 TEXT-014 icon_dummy.
  ENDIF.

* 3. Vinculación Cliente - Proveedor.
  IF p_3 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 30 text-016.
    PERFORM f_progreso USING 21 TEXT-016.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_3.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 3 TEXT-016 TEXT-014 icon_dummy.
  ENDIF.

* 4. Chequeo de datos generales de Dirección Cliente - Proveedor.
  IF p_4 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 40 text-017.
    PERFORM f_progreso USING 28 TEXT-017.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_4.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 4 TEXT-017 TEXT-014 icon_dummy.
  ENDIF.

* 5. Chequeo de datos Pagos Cliente - Proveedor.
  IF p_5 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 50 text-018.
    PERFORM f_progreso USING 35 TEXT-018.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_5.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 5 TEXT-018 TEXT-014 icon_dummy.
  ENDIF.

* 6. Chequeo de la información del Directorio Bancario.
  IF p_6 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 60 text-019.
    PERFORM f_progreso USING 42 TEXT-019.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_6.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 6 TEXT-019 TEXT-014 icon_dummy.
  ENDIF.

* 7. Verificación de tipo de NIF - Configuración de Tipo de NIF en BPs.
  IF p_7 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 70 text-020.
    PERFORM f_progreso USING 49 TEXT-020.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_7.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 7 TEXT-020 TEXT-014 icon_dummy.
  ENDIF.

* 8. Verificación formato estándar por País de Código Postal.
  IF p_8 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 80 text-021.
    PERFORM f_progreso USING 56 TEXT-021.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_8.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 8 TEXT-021 TEXT-014 icon_dummy.
  ENDIF.

* 9. Verificación del formato de correo electrónico.
  IF p_9 IS NOT INITIAL.
*   Realizamos las comprobaciones.
**    "INI ZPRY_PRS4 03.04.2024 54217049T
*    PERFORM f_progreso USING 90 text-022.
    PERFORM f_progreso USING 63 TEXT-022.
**    "FIN ZPRY_PRS4
    PERFORM f_chequeo_prueba_9.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 9 TEXT-022 TEXT-014 icon_dummy.
  ENDIF.

**  "INI ZPRY_PRS4 03.04.2024 54217049T
* 10b. Verificación formato estándar por país de CIF.
  IF p_10b IS NOT INITIAL.
*   Realizamos las comprobaciones.
    PERFORM f_progreso USING 70 TEXT-055.
    PERFORM f_chequeo_prueba_10b.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 10 TEXT-055 TEXT-014 icon_dummy.
  ENDIF.

* 11b. Validación de código postal obligatorio.
  IF p_11b IS NOT INITIAL.
*   Realizamos las comprobaciones.
    PERFORM f_progreso USING 77 TEXT-056.
    PERFORM f_chequeo_prueba_11b.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 11 TEXT-056 TEXT-014 icon_dummy.
  ENDIF.

* 12b. Terceros con tratamiento Señor/a.
  IF p_12b IS NOT INITIAL.
*   Realizamos las comprobaciones.
    PERFORM f_progreso USING 84 TEXT-062.
    PERFORM f_chequeo_prueba_12b.
  ELSE.
*   Añadimos al ALV principal: Prueba no realizada.
    PERFORM f_log_principal USING 12 TEXT-062 TEXT-014 icon_dummy.
  ENDIF.
**  "FIN ZPRY_PRS4

** 10. Verificación del formato de número de teléfono.
*  IF p_10 IS NOT INITIAL.
**   Realizamos las comprobaciones.
*    PERFORM f_progreso USING 100 text-023.
**   Añadimos al ALV principal.
*    PERFORM f_log_principal USING 10 text-023 text-030 icon_system_okay.
*  ELSE.
**   Añadimos al ALV principal: Prueba no realizada.
**    PERFORM f_log_principal USING 10 text-023 text-014 icon_dummy.
*    PERFORM f_log_principal USING 10 text-023 text-030 icon_system_okay.
*  ENDIF.

* Funciones extras.
**  "INI ZPRY_PRS4 03.04.2024 54217049T
*  PERFORM f_log_principal USING 10 text-024 space icon_system_okay.
*  PERFORM f_log_principal USING 11 text-025 space icon_system_okay.
  PERFORM f_log_principal USING 13 TEXT-024 space icon_system_okay.
  PERFORM f_log_principal USING 14 TEXT-025 space icon_system_okay.
**  "FIN ZPRY_PRS4

*  PERFORM f_log_principal USING 13 text-026 text-030 icon_system_okay.
*  PERFORM f_log_principal USING 14 text-027 text-030 icon_system_okay.

ENDFORM.                    "f_chequeos_migracion
*&---------------------------------------------------------------------*
*&      Form  F_PROGRESO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PORCENTAJE  text
*----------------------------------------------------------------------*
FORM f_progreso USING p_porcentaje p_texto.

  CALL FUNCTION c_progress
    EXPORTING
      percentage = p_porcentaje
      text       = p_texto.

ENDFORM.                    "f_progreso
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_1.
  DATA: li_kna1_stcd1 TYPE TABLE OF ty_kna1,
        li_kna1_stcd2 TYPE TABLE OF ty_kna1,
        li_kna1_stceg TYPE TABLE OF ty_kna1,
        li_kna1_stcd3 TYPE TABLE OF ty_kna1,
        li_kna1_stcd4 TYPE TABLE OF ty_kna1,
        li_kna1_stcd5 TYPE TABLE OF ty_kna1,
        lv_index      TYPE sy-tabix,
        lv_index_b    TYPE sy-tabix,
        lw_kna1       TYPE ty_kna1,
        lw_kna1_aux   TYPE ty_kna1,
        lv_cabecera   TYPE c.

  CLEAR: i_kna1[], i_kna1_log[], li_kna1_stcd1[], li_kna1_stcd2[],
          li_kna1_stceg[], li_kna1_stcd3[], li_kna1_stcd4[],
          li_kna1_stcd5[], lw_kna1, lw_kna1_aux, lv_cabecera.

* Seleccionamos de KNA1.
  SELECT kunnr land1 name2 name1 pstlz regio adrnr ktokd lifnr loevm
          stcd1 stcd2 stceg stcd3 stcd4 stcd5
          anred ""INI ZPRY_PRS4 03.04.2024 54217049T
    FROM kna1
    INTO TABLE i_kna1
    WHERE kunnr IN s_kunnr
      AND lifnr IN s_lifnr
      AND ( stcd1 IN s_stcd1
      OR   stceg IN s_stcd1
      OR   stcd3 IN s_stcd1 ).
  IF sy-subrc EQ 0.

    li_kna1_stcd1[] = i_kna1[].
    DELETE li_kna1_stcd1 WHERE stcd1 EQ space.
    SORT li_kna1_stcd1 BY stcd1.

    li_kna1_stcd2[] = i_kna1[].
    DELETE li_kna1_stcd2 WHERE stcd2 EQ space.
    SORT li_kna1_stcd2 BY stcd2.

    li_kna1_stceg[] = i_kna1[].
    DELETE li_kna1_stceg WHERE stceg EQ space.
    SORT li_kna1_stceg BY stceg.

    li_kna1_stcd3[] = i_kna1[].
    DELETE li_kna1_stcd3 WHERE stcd3 EQ space.
    SORT li_kna1_stcd3 BY stcd3.

    li_kna1_stcd4[] = i_kna1[].
    DELETE li_kna1_stcd4 WHERE stcd4 EQ space.
    SORT li_kna1_stcd4 BY stcd4.

*    li_kna1_stcd5[] = i_kna1[].
*    DELETE li_kna1_stcd5 WHERE stcd5 EQ space.
*    SORT li_kna1_stcd5 BY stcd5.

    LOOP AT i_kna1 INTO lw_kna1.
      CLEAR lv_cabecera.

*     Comprobamos que no haya repetidos en STCD1.
      IF lw_kna1-stcd1 IS NOT INITIAL.
        CLEAR: lw_kna1_aux, lv_index.
        READ TABLE li_kna1_stcd1 TRANSPORTING NO FIELDS
          WITH KEY stcd1 = lw_kna1-stcd1.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_kna1_stcd1 INTO lw_kna1_aux FROM lv_index
            WHERE kunnr NE lw_kna1-kunnr
              AND stcd1 EQ lw_kna1-stcd1.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_1 USING lw_kna1-kunnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                        lw_kna1-stcd1 TEXT-006.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_1 USING lw_kna1_aux-kunnr lw_kna1_aux-ktokd lw_kna1_aux-loevm lw_kna1_aux-name1 lw_kna1_aux-name2
                                      lw_kna1_aux-stcd1 TEXT-006.
            DELETE li_kna1_stcd1 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCD2.
      IF lw_kna1-stcd2 IS NOT INITIAL.
        CLEAR: lw_kna1_aux, lv_index.
        READ TABLE li_kna1_stcd2 TRANSPORTING NO FIELDS
          WITH KEY stcd2 = lw_kna1-stcd2.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_kna1_stcd2 INTO lw_kna1_aux FROM lv_index
            WHERE kunnr NE lw_kna1-kunnr
              AND stcd2 EQ lw_kna1-stcd2.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_1 USING lw_kna1-kunnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                        lw_kna1-stcd2 TEXT-007.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_1 USING lw_kna1_aux-kunnr lw_kna1_aux-ktokd lw_kna1_aux-loevm lw_kna1_aux-name1 lw_kna1_aux-name2
                                      lw_kna1_aux-stcd2 TEXT-007.
            DELETE li_kna1_stcd2 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCEG.
      IF lw_kna1-stceg IS NOT INITIAL.
        CLEAR: lw_kna1_aux, lv_index.
        READ TABLE li_kna1_stceg TRANSPORTING NO FIELDS
          WITH KEY stceg = lw_kna1-stceg.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_kna1_stceg INTO lw_kna1_aux FROM lv_index
            WHERE kunnr NE lw_kna1-kunnr
              AND stceg EQ lw_kna1-stceg.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_1 USING lw_kna1-kunnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                        lw_kna1-stceg TEXT-008.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_1 USING lw_kna1_aux-kunnr lw_kna1_aux-ktokd lw_kna1_aux-loevm lw_kna1_aux-name1 lw_kna1_aux-name2
                                      lw_kna1_aux-stceg TEXT-008.
            DELETE li_kna1_stceg INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCD3.
      IF lw_kna1-stcd3 IS NOT INITIAL.
        CLEAR: lw_kna1_aux, lv_index.
        READ TABLE li_kna1_stcd3 TRANSPORTING NO FIELDS
          WITH KEY stcd3 = lw_kna1-stcd3.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_kna1_stcd3 INTO lw_kna1_aux FROM lv_index
            WHERE kunnr NE lw_kna1-kunnr
              AND stcd3 EQ lw_kna1-stcd3.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_1 USING lw_kna1-kunnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                        lw_kna1-stcd3 TEXT-009.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_1 USING lw_kna1_aux-kunnr lw_kna1_aux-ktokd lw_kna1_aux-loevm lw_kna1_aux-name1 lw_kna1_aux-name2
                                      lw_kna1_aux-stcd3 TEXT-009.
            DELETE li_kna1_stcd3 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCD4.
      IF lw_kna1-stcd4 IS NOT INITIAL.
        CLEAR: lw_kna1_aux, lv_index.
        READ TABLE li_kna1_stcd4 TRANSPORTING NO FIELDS
          WITH KEY stcd4 = lw_kna1-stcd4.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_kna1_stcd4 INTO lw_kna1_aux FROM lv_index
            WHERE kunnr NE lw_kna1-kunnr
              AND stcd4 EQ lw_kna1-stcd4.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_1 USING lw_kna1-kunnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                        lw_kna1-stcd4 TEXT-010.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_1 USING lw_kna1_aux-kunnr lw_kna1_aux-ktokd lw_kna1_aux-loevm lw_kna1_aux-name1 lw_kna1_aux-name2
                                      lw_kna1_aux-stcd4 TEXT-010.
            DELETE li_kna1_stcd4 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

**     Comprobamos que no haya repetidos en STCD5.
*      IF lw_kna1-stcd5 IS NOT INITIAL.
*        CLEAR: lw_kna1_aux, lv_index.
*        READ TABLE li_kna1_stcd5 TRANSPORTING NO FIELDS
*          WITH KEY stcd4 = lw_kna1-stcd5.
*        IF sy-subrc EQ 0.
*          lv_index = sy-tabix.
*          LOOP AT li_kna1_stcd5 INTO lw_kna1_aux FROM lv_index
*            WHERE kunnr NE lw_kna1-kunnr
*              AND stcd5 EQ lw_kna1-stcd5.
*            lv_index_b = sy-tabix.
**           Añadimos al log.
*            IF lv_cabecera IS INITIAL.
*              PERFORM f_add_log_1 USING lw_kna1-kunnr   lw_kna1-stcd5     text-011.
*              lv_cabecera = abap_true.
*            ENDIF.
*            PERFORM f_add_log_1 USING lw_kna1_aux-kunnr lw_kna1_aux-stcd5 text-011.
*            DELETE li_kna1_stcd5 INDEX lv_index_b.
*          ENDLOOP.
*        ENDIF.
*      ENDIF.

    ENDLOOP.

    IF i_kna1_log[] IS NOT INITIAL.
*     Añadimos ERROR al ALV principal.
      PERFORM f_log_principal USING 1 TEXT-012 TEXT-013 icon_system_cancel.
    ELSE.
*     Añadimos al ALV principal.
      PERFORM f_log_principal USING 1 TEXT-012 TEXT-030 icon_system_okay.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_1
*&---------------------------------------------------------------------*
*&      Form  F_LOG_PRINCIPAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_NUMERO  text
*      -->P_P_PRUEBA  text
*      -->P_P_COMENTARIO  text
*      -->P_P_SEMAFORO  text
*----------------------------------------------------------------------*
FORM f_log_principal  USING p_numero
                            p_prueba
                            p_comentario
                            p_semaforo.

  DATA: lw_alv_principal     TYPE ty_alv_principal.
  CLEAR lw_alv_principal.

  lw_alv_principal-numero     = p_numero.
  lw_alv_principal-prueba     = p_prueba.
  lw_alv_principal-comentario = p_comentario.
  lw_alv_principal-semaforo   = p_semaforo.
  READ TABLE i_alv_principal TRANSPORTING NO FIELDS
    WITH KEY numero = p_numero.
  IF sy-subrc EQ 0.
    MODIFY i_alv_principal FROM lw_alv_principal INDEX sy-tabix
      TRANSPORTING comentario semaforo.
  ELSE.
    APPEND lw_alv_principal TO i_alv_principal.
  ENDIF.

ENDFORM.                    "f_log_principal
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_1  USING p_kunnr
                        p_ktokd
                        p_loevm
                        p_name1
                        p_name2
                        p_stcd
                        p_text.

  DATA: lw_kna1_log TYPE ty_kna1_log.
  CLEAR lw_kna1_log.

  lw_kna1_log-kunnr = p_kunnr.
  lw_kna1_log-ktokd = p_ktokd.
  lw_kna1_log-loevm = p_loevm.
  lw_kna1_log-name1 = p_name1.
  lw_kna1_log-name2 = p_name2.
  lw_kna1_log-stcd5 = p_stcd.
  CONCATENATE TEXT-005 p_text INTO lw_kna1_log-comentario
    SEPARATED BY space.

  READ TABLE i_kna1_log TRANSPORTING NO FIELDS
    WITH KEY kunnr = lw_kna1_log-kunnr
              stcd5 = lw_kna1_log-stcd5.
  IF sy-subrc NE 0.
    APPEND lw_kna1_log TO i_kna1_log.
  ENDIF.

ENDFORM.                    "f_add_log_1
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_2  USING p_lifnr
                        p_ktokk
                        p_loevm
                        p_name1
                        p_name2
                        p_stcd
                        p_text.

  DATA: lw_lfa1_log TYPE ty_lfa1_log.
  CLEAR lw_lfa1_log.

  lw_lfa1_log-lifnr = p_lifnr.
  lw_lfa1_log-ktokk = p_ktokk.
  lw_lfa1_log-loevm = p_loevm.
  lw_lfa1_log-name1 = p_name1.
  lw_lfa1_log-name2 = p_name2.
  lw_lfa1_log-stcd5 = p_stcd.

  CONCATENATE TEXT-005 p_text INTO lw_lfa1_log-comentario
    SEPARATED BY space.

  READ TABLE i_lfa1_log TRANSPORTING NO FIELDS
    WITH KEY lifnr = lw_lfa1_log-lifnr
              stcd5 = lw_lfa1_log-stcd5.
  IF sy-subrc NE 0.
    APPEND lw_lfa1_log TO i_lfa1_log.
  ENDIF.

ENDFORM.                    "f_add_log_2
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_2.
  DATA: li_lfa1_stcd1 TYPE TABLE OF ty_lfa1,
        li_lfa1_stcd2 TYPE TABLE OF ty_lfa1,
        li_lfa1_stceg TYPE TABLE OF ty_lfa1,
        li_lfa1_stcd3 TYPE TABLE OF ty_lfa1,
        li_lfa1_stcd4 TYPE TABLE OF ty_lfa1,
        li_lfa1_stcd5 TYPE TABLE OF ty_lfa1,
        lv_index      TYPE sy-tabix,
        lv_index_b    TYPE sy-tabix,
        lw_lfa1       TYPE ty_lfa1,
        lw_lfa1_aux   TYPE ty_lfa1,
        lv_cabecera   TYPE c.

  CLEAR: i_lfa1[], i_lfa1_log[], li_lfa1_stcd1[], li_lfa1_stcd2[],
          li_lfa1_stceg[], li_lfa1_stcd3[], li_lfa1_stcd4[],
          li_lfa1_stcd5[],lw_lfa1, lw_lfa1_aux, lv_cabecera.

* Seleccionamos de LFA1.
  SELECT lifnr land1 name2 name1 pstlz regio adrnr ktokk kunnr loevm
          stcd1 stcd2 stceg stcd3 stcd4 stcd5
          anred ""INI ZPRY_PRS4 03.04.2024 54217049T
    FROM lfa1
    INTO TABLE i_lfa1
    WHERE lifnr IN s_lifnr
      AND kunnr IN s_kunnr
      AND ( stcd1 IN s_stcd1
      OR   stceg IN s_stcd1
      OR   stcd3 IN s_stcd1 ).
  IF sy-subrc EQ 0.

    li_lfa1_stcd1[] = i_lfa1[].
    DELETE li_lfa1_stcd1 WHERE stcd1 EQ space.
    SORT li_lfa1_stcd1 BY stcd1.

    li_lfa1_stcd2[] = i_lfa1[].
    DELETE li_lfa1_stcd2 WHERE stcd2 EQ space.
    SORT li_lfa1_stcd2 BY stcd2.

    li_lfa1_stceg[] = i_lfa1[].
    DELETE li_lfa1_stceg WHERE stceg EQ space.
    SORT li_lfa1_stceg BY stceg.

    li_lfa1_stcd3[] = i_lfa1[].
    DELETE li_lfa1_stcd3 WHERE stcd3 EQ space.
    SORT li_lfa1_stcd3 BY stcd3.

    li_lfa1_stcd4[] = i_lfa1[].
    DELETE li_lfa1_stcd4 WHERE stcd4 EQ space.
    SORT li_lfa1_stcd4 BY stcd4.

*    li_lfa1_stcd5[] = i_lfa1[].
*    DELETE li_lfa1_stcd5 WHERE stcd5 EQ space.
*    SORT li_lfa1_stcd5 BY stcd5.

    LOOP AT i_lfa1 INTO lw_lfa1.
      CLEAR lv_cabecera.

*     Comprobamos que no haya repetidos en STCD1.
      IF lw_lfa1-stcd1 IS NOT INITIAL.
        CLEAR: lw_lfa1_aux, lv_index.
        READ TABLE li_lfa1_stcd1 TRANSPORTING NO FIELDS
          WITH KEY stcd1 = lw_lfa1-stcd1.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_lfa1_stcd1 INTO lw_lfa1_aux FROM lv_index
            WHERE lifnr NE lw_lfa1-lifnr
              AND stcd1 EQ lw_lfa1-stcd1.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_2 USING lw_lfa1-lifnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2
                                        lw_lfa1-stcd1 TEXT-006.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_2 USING lw_lfa1_aux-lifnr lw_lfa1_aux-ktokk lw_lfa1_aux-loevm lw_lfa1_aux-name1 lw_lfa1_aux-name2
                                      lw_lfa1_aux-stcd1 TEXT-006.
            DELETE li_lfa1_stcd1 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCD2.
      IF lw_lfa1-stcd2 IS NOT INITIAL.
        CLEAR: lw_lfa1_aux, lv_index.
        READ TABLE li_lfa1_stcd2 TRANSPORTING NO FIELDS
          WITH KEY stcd2 = lw_lfa1-stcd2.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_lfa1_stcd2 INTO lw_lfa1_aux FROM lv_index
            WHERE lifnr NE lw_lfa1-lifnr
              AND stcd2 EQ lw_lfa1-stcd2.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_2 USING lw_lfa1-lifnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2
                                        lw_lfa1-stcd2  TEXT-007.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_2 USING lw_lfa1_aux-lifnr lw_lfa1_aux-ktokk lw_lfa1_aux-loevm lw_lfa1_aux-name1 lw_lfa1_aux-name2
                                      lw_lfa1_aux-stcd2 TEXT-007.
            DELETE li_lfa1_stcd2 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCEG.
      IF lw_lfa1-stceg IS NOT INITIAL.
        CLEAR: lw_lfa1_aux, lv_index.
        READ TABLE li_lfa1_stceg TRANSPORTING NO FIELDS
          WITH KEY stceg = lw_lfa1-stceg.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_lfa1_stceg INTO lw_lfa1_aux FROM lv_index
            WHERE lifnr NE lw_lfa1-lifnr
              AND stceg EQ lw_lfa1-stceg.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_2 USING lw_lfa1-lifnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2
                                        lw_lfa1-stceg     TEXT-008.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_2 USING lw_lfa1_aux-lifnr lw_lfa1_aux-ktokk lw_lfa1_aux-loevm lw_lfa1_aux-name1 lw_lfa1_aux-name2
                                      lw_lfa1_aux-stceg TEXT-008.
            DELETE li_lfa1_stceg INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCD3.
      IF lw_lfa1-stcd3 IS NOT INITIAL.
        CLEAR: lw_lfa1_aux, lv_index.
        READ TABLE li_lfa1_stcd3 TRANSPORTING NO FIELDS
          WITH KEY stcd3 = lw_lfa1-stcd3.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_lfa1_stcd3 INTO lw_lfa1_aux FROM lv_index
            WHERE lifnr NE lw_lfa1-lifnr
              AND stcd3 EQ lw_lfa1-stcd3.
            lv_index_b = sy-tabix.
*           Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_2 USING lw_lfa1-lifnr  lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2
                                        lw_lfa1-stcd3  TEXT-009.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_2 USING lw_lfa1_aux-lifnr lw_lfa1_aux-ktokk  lw_lfa1_aux-loevm lw_lfa1_aux-name1 lw_lfa1_aux-name2
                                      lw_lfa1_aux-stcd3 TEXT-009.
            DELETE li_lfa1_stcd3 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Comprobamos que no haya repetidos en STCD4.
      IF lw_lfa1-stcd4 IS NOT INITIAL.
        CLEAR: lw_lfa1_aux, lv_index.
        READ TABLE li_lfa1_stcd4 TRANSPORTING NO FIELDS
          WITH KEY stcd4 = lw_lfa1-stcd4.
        IF sy-subrc EQ 0.
          lv_index = sy-tabix.
          LOOP AT li_lfa1_stcd4 INTO lw_lfa1_aux FROM lv_index
            WHERE lifnr NE lw_lfa1-lifnr
              AND stcd4 EQ lw_lfa1-stcd4.
            lv_index_b = sy-tabix.
*         Añadimos al log.
            IF lv_cabecera IS INITIAL.
              PERFORM f_add_log_2 USING lw_lfa1-lifnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2
                                        lw_lfa1-stcd4 TEXT-010.
              lv_cabecera = abap_true.
            ENDIF.
            PERFORM f_add_log_2 USING lw_lfa1_aux-lifnr lw_lfa1_aux-ktokk lw_lfa1_aux-loevm lw_lfa1_aux-name1 lw_lfa1_aux-name2
                                      lw_lfa1_aux-stcd4 TEXT-010.
            DELETE li_lfa1_stcd4 INDEX lv_index_b.
          ENDLOOP.
        ENDIF.
      ENDIF.

**     Comprobamos que no haya repetidos en STCD5.
*      IF lw_lfa1-stcd5 IS NOT INITIAL.
*        CLEAR: lw_lfa1_aux, lv_index.
*        READ TABLE li_lfa1_stcd5 TRANSPORTING NO FIELDS
*          WITH KEY stcd5 = lw_lfa1-stcd5.
*        IF sy-subrc EQ 0.
*          lv_index = sy-tabix.
*          LOOP AT li_lfa1_stcd5 INTO lw_lfa1_aux FROM lv_index
*            WHERE lifnr NE lw_lfa1-lifnr
*              AND stcd5 EQ lw_lfa1-stcd5.
*            lv_index_b = sy-tabix.
**           Añadimos al log.
*            IF lv_cabecera IS INITIAL.
*              PERFORM f_add_log_2 USING lw_lfa1-lifnr   lw_lfa1-stcd4     text-011.
*              lv_cabecera = abap_true.
*            ENDIF.
*            PERFORM f_add_log_2 USING lw_lfa1_aux-lifnr lw_lfa1_aux-stcd4 text-011.
*            DELETE li_lfa1_stcd5 INDEX lv_index_b.
*          ENDLOOP.
*        ENDIF.
*      ENDIF.

    ENDLOOP.

    IF i_lfa1_log[] IS NOT INITIAL.
*     Añadimos ERROR al ALV principal.
      PERFORM f_log_principal USING 2 TEXT-015 TEXT-013 icon_system_cancel.
    ELSE.
*     Añadimos al ALV principal.
      PERFORM f_log_principal USING 2 TEXT-015 TEXT-030 icon_system_okay.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_2
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_1.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_kunnr      TEXT-029  char_r  18  space     space    space,
                                  c_ktokd      TEXT-050  char_l  20  space     space    space,
                                  c_loevm      TEXT-054  char_l  15  space     space    space,
                                  c_name1      TEXT-052  char_l  20  space     space    space,
                                  c_name2      TEXT-053  char_l  20  space     space    space,
                                  c_stcd5      TEXT-028  char_l  30  space     space    space,
                                  c_comentario TEXT-004  char_l  55  space     space    space.


ENDFORM.                    "f_cargar_catalogo_1
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_2 .

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_lifnr      TEXT-029  char_r  18  space     space    space,
                                  c_ktokk      TEXT-050  char_l  20  space     space    space,
                                  c_loevm      TEXT-054  char_l  15  space     space    space,
                                  c_name1      TEXT-052  char_l  20  space     space    space,
                                  c_name2      TEXT-053  char_l  20  space     space    space,
                                  c_stcd5      TEXT-028  char_l  30  space     space    space,
                                  c_comentario TEXT-004  char_l  55  space     space    space.


ENDFORM.                    "f_cargar_catalogo_2
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_3.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_stcd5      'NIF'        char_r  14  space     space    space,
                                  'KKUNNR'     'KNA1-KUNNR' char_l  15  space     space    space,
                                  'KLIFNR'     'KNA1-LIFNR' char_l  15  space     space    space,
                                  'KTOKD'      'KNA1-KOTKD' char_l  15  space     space    space,
                                  'KLOEVM'     'KNA1-LOEVM' char_l  15  space     space    space,
                                  'KNAME1'     'KNA1-NAME1' char_l  15  space     space    space,
                                  'KNAME2'     'KNA1-NAME2' char_l  15  space     space    space,
                                  'LLIFNR'     'LFA1-LIFNR' char_l  15  space     space    space,
                                  'LKUNNR'     'LFA1-KUNNR' char_l  15  space     space    space,
                                  'KTOKK'      'LFA1-KOTKK' char_l  15  space     space    space,
                                  'LLOEVM'     'LFA1-LOEVM' char_l  15  space     space    space,
                                  'LNAME1'     'LFA1-NAME1' char_l  15  space     space    space,
                                  'LNAME2'     'LFA1-NAME2' char_l  15  space     space    space.

ENDFORM.                    "f_cargar_catalogo_3
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_4.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_kunnr      'KUNNR'      char_l  14  space     space    space,
                                  c_lifnr      'LIFNR'      char_l  15  space     space    space,
                                  c_comentario TEXT-044     char_l  65  space     space    space.

ENDFORM.                    "f_cargar_catalogo_4
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_6.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_kunnr      TEXT-035     char_l  19  space     space    space,
                                  'BANKS'      'BANKS'      char_l  15  space     space    space,
                                  'BANKL'      'BANKL'      char_l  15  space     space    space,
                                  c_comentario TEXT-004     char_l  55  space     space    space.

ENDFORM.                    "f_cargar_catalogo_6
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_7.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: 'TAXTYPE'    'TAXTYPE'    char_l  19  space     space    space,
                                  c_comentario TEXT-004     char_l  55  space     space    space.

ENDFORM.                    "f_cargar_catalogo_7
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_8
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_8.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_kunnr      TEXT-035     char_l  19  space     space    space,
                                  'LAND1'      'LAND1'      char_l  15  space     space    space,
                                  'PSTLZ'      'PSTLZ'      char_l  15  space     space    space,
                                  'REGIO'      'REGIO'      char_l  15  space     space    space,
                                  c_comentario TEXT-004     char_l  45  space     space    space.

ENDFORM.                    "f_cargar_catalogo_8
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_9
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_9.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_kunnr      TEXT-035     char_l  19  space     space    space,
                                  'SMTP_ADDR'  TEXT-041     char_l  35  space     space    space,
                                  c_comentario TEXT-004     char_l  45  space     space    space.

ENDFORM.                    "f_cargar_catalogo_9
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_CUADRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_cuadre.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_kunnr      TEXT-035     char_l  19  space     space    space,
                                  'KTOKD'      TEXT-050     char_l  16  space     space    space,
                                  c_comentario TEXT-004     char_l  45  space     space    space.

ENDFORM.                    "f_cargar_catalogo_cuadre
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_BP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_bp.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: 'PARTNER'    'BP'         char_l  15  space     space    space,
                                  'BU_GROUP'   TEXT-051     char_l  15  space     space    space.

ENDFORM.                    "f_cargar_catalogo_bp
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_CHEQUEO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_chequeo.

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: 'NIF'             'NIF'               char_l  15  space     space    space,
                                  'PARTNER'         'BP'                char_l  15  space     space    space,
                                  'BANKDETAILID'    'ID datos'          char_l   5  space     space    space,
                                  'BANKS'           'Clave de país'     char_l   5  space     space    space,
                                  'BANKL'           'Código bancario'   char_l  10  space     space    space,
                                  'BANKN'           'Nº cuenta'         char_l  15  space     space    space,
                                  'BKONT'           'Clave de control'  char_l   5  space     space    space,
                                  'IBAN'            'IBAN'              char_l  20  space     space    space,
                                  'KUNNR'           'Cliente'           char_l  15  space     space    space,
                                  'BANKDETAILID_K'  'ID datos'          char_l   5  space     space    space,
                                  'BANKS_K'         'Clave de país'     char_l   5  space     space    space,
                                  'BANKL_K'         'Código bancario'   char_l  10  space     space    space,
                                  'BANKN_K'         'Nº cuenta'         char_l  15  space     space    space,
                                  'BKONT_K'         'Clave de control'  char_l   5  space     space    space,
                                  'IBAN_K'          'IBAN'              char_l  20  space     space    space,
                                  'ASOCIADO'        'Asociación C/P'    char_l  12  space     space    space,
                                  'LIFNR'           'Proveedor'         char_l  15  space     space    space,
                                  'BANKDETAILID_L'  'ID datos'          char_l   5  space     space    space,
                                  'BANKS_L'         'Clave de país'     char_l   5  space     space    space,
                                  'BANKL_L'         'Código bancario'   char_l  10  space     space    space,
                                  'BANKN_L'         'Nº cuenta'         char_l  15  space     space    space,
                                  'BKONT_L'         'Clave de control'  char_l   5  space     space    space,
                                  'IBAN_L'          'IBAN'              char_l  20  space     space    space.

ENDFORM.                    "f_cargar_catalogo_chequeo
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_3.

  DATA: lw_kna1 TYPE ty_kna1,
        lw_lfa1 TYPE ty_lfa1.


  CLEAR: i_kna1[], i_lfa1[], i_cruce_log[], lw_kna1, lw_lfa1.

  IF i_kna1[] IS INITIAL.
    SELECT kunnr land1 name2 name1 pstlz regio adrnr ktokd lifnr loevm "#EC CI_NOFIELD.
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
            anred ""INI ZPRY_PRS4 03.04.2024 54217049T
      FROM kna1
      INTO TABLE i_kna1
      WHERE ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_lfa1[] IS INITIAL.
    SELECT lifnr land1 name2 name1 pstlz regio adrnr ktokk kunnr loevm "#EC CI_NOFIELD.
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
            anred ""INI ZPRY_PRS4 03.04.2024 54217049T
      FROM lfa1
      INTO TABLE i_lfa1
      WHERE ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  LOOP AT i_kna1 INTO lw_kna1.
    IF lw_kna1-stcd1 IS NOT INITIAL.
      LOOP AT i_lfa1 INTO lw_lfa1
        WHERE stcd1 EQ lw_kna1-stcd1
            OR stceg EQ lw_kna1-stcd1
            OR stcd3 EQ lw_kna1-stcd1.

        IF  lw_kna1-kunnr NE lw_lfa1-kunnr
        OR  lw_kna1-lifnr NE lw_lfa1-lifnr.
*         Añadimos al log.
          PERFORM f_add_log_3 USING lw_kna1-stcd1 lw_kna1-kunnr lw_kna1-lifnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                    lw_lfa1-lifnr lw_lfa1-kunnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2.
        ENDIF.

        CLEAR lw_lfa1.
      ENDLOOP.

    ELSEIF lw_kna1-stceg IS NOT INITIAL.
      LOOP AT i_lfa1 INTO lw_lfa1 WHERE stcd1 EQ lw_kna1-stceg
                                      OR stceg EQ lw_kna1-stceg
                                      OR stcd3 EQ lw_kna1-stceg.

        IF  lw_kna1-kunnr NE lw_lfa1-kunnr
        OR  lw_kna1-lifnr NE lw_lfa1-lifnr.
*         Añadimos al log.
          PERFORM f_add_log_3 USING lw_kna1-stceg lw_kna1-kunnr lw_kna1-lifnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                    lw_lfa1-lifnr lw_lfa1-kunnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2.

        ENDIF.

        CLEAR lw_lfa1.
      ENDLOOP.

    ELSEIF lw_kna1-stcd3 IS NOT INITIAL.
      LOOP AT i_lfa1 INTO lw_lfa1 WHERE stcd1 EQ lw_kna1-stcd3
                                      OR stceg EQ lw_kna1-stcd3
                                      OR stcd3 EQ lw_kna1-stcd3.

        IF  lw_kna1-kunnr NE lw_lfa1-kunnr
        OR  lw_kna1-lifnr NE lw_lfa1-lifnr.
*         Añadimos al log.
          PERFORM f_add_log_3 USING lw_kna1-stcd3 lw_kna1-kunnr lw_kna1-lifnr lw_kna1-ktokd lw_kna1-loevm lw_kna1-name1 lw_kna1-name2
                                    lw_lfa1-lifnr lw_lfa1-kunnr lw_lfa1-ktokk lw_lfa1-loevm lw_lfa1-name1 lw_lfa1-name2.

        ENDIF.

        CLEAR lw_lfa1.
      ENDLOOP.
    ENDIF.

    CLEAR lw_kna1.
  ENDLOOP.

  IF i_cruce_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 3 TEXT-016 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 3 TEXT-016 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_3
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_3  USING p_stcd5
                        p_kkunnr
                        p_klifnr
                        p_ktokd
                        p_kloevm
                        p_kname1
                        p_kname2
                        p_llifnr
                        p_lkunnr
                        p_ktokk
                        p_lloevm
                        p_lname1
                        p_lname2.

  DATA: lw_cruce TYPE ty_cruce.
  CLEAR lw_cruce.

  lw_cruce-stcd5  = p_stcd5.
  lw_cruce-kkunnr = p_kkunnr.
  lw_cruce-klifnr = p_klifnr.
  lw_cruce-ktokd  = p_ktokd.
  lw_cruce-kloevm = p_kloevm.
  lw_cruce-kname1 = p_kname2.
  lw_cruce-kname2 = p_kname1.
  lw_cruce-llifnr = p_llifnr.
  lw_cruce-lkunnr = p_lkunnr.
  lw_cruce-ktokk  = p_ktokk.
  lw_cruce-lloevm = p_lloevm.
  lw_cruce-lname1 = p_lname2.
  lw_cruce-lname2 = p_lname1.
  APPEND lw_cruce TO i_cruce_log.

ENDFORM.                    "f_add_log_3
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_4.
  DATA: lw_kna1_cliente   TYPE ty_cliente_proveedor,
        lw_lfa1_proveedor TYPE ty_cliente_proveedor,
        lv_texto          TYPE string.

  CLEAR: i_kna1_cliente[], i_lfa1_proveedor[], i_cp_log[],
          lw_kna1_cliente, lw_lfa1_proveedor, lv_texto.


  SELECT k~kunnr k~lifnr k~stcd1 addrnumber date_from nation date_to
          title ad~name1 ad~name2 ad~name3 ad~name4 name_text name_co
          city1 city2 city_code cityp_code home_city cityh_code chckstatus
          regiogroup post_code1 post_code2 post_code3 pcode1_ext
          pcode2_ext pcode3_ext po_box dont_use_p po_box_num po_box_loc
          city_code2 po_box_reg po_box_cty postalarea transpzone street
          dont_use_s streetcode streetabbr house_num1 house_num2 house_num3
          str_suppl1 str_suppl2 str_suppl3 location building
          floor roomnumber country langu region addr_group flaggroups
          pers_addr sort1 sort2 sort_phn deflt_comm tel_number tel_extens
          fax_number fax_extens flagcomm2 flagcomm3 flagcomm4 flagcomm5
          flagcomm6 flagcomm7 flagcomm8 flagcomm9 flagcomm10 flagcomm11
          flagcomm12 flagcomm13 addrorigin mc_name1 mc_city1 mc_street
          extension1 extension2 time_zone taxjurcode address_id langu_crea
    FROM kna1 AS k
    INNER JOIN adrc AS ad ON k~adrnr EQ ad~addrnumber
    INTO TABLE i_kna1_cliente
    WHERE k~kunnr IN s_kunnr
      AND k~lifnr IN s_lifnr
      AND ( k~stcd1 IN s_stcd1
      OR   k~stceg IN s_stcd1
      OR   k~stcd3 IN s_stcd1 ).
  IF sy-subrc EQ 0.
    DELETE i_kna1_cliente WHERE lifnr EQ space.
  ENDIF.

  SELECT l~kunnr l~lifnr l~stcd1 addrnumber date_from nation date_to
          title ad~name1 ad~name2 ad~name3 ad~name4 name_text name_co
          city1 city2 city_code cityp_code home_city cityh_code chckstatus
          regiogroup post_code1 post_code2 post_code3 pcode1_ext
          pcode2_ext pcode3_ext po_box dont_use_p po_box_num po_box_loc
          city_code2 po_box_reg po_box_cty postalarea transpzone street
          dont_use_s streetcode streetabbr house_num1 house_num2 house_num3
          str_suppl1 str_suppl2 str_suppl3 location building
          floor roomnumber country langu region addr_group flaggroups
          pers_addr sort1 sort2 sort_phn deflt_comm tel_number tel_extens
          fax_number fax_extens flagcomm2 flagcomm3 flagcomm4 flagcomm5
          flagcomm6 flagcomm7 flagcomm8 flagcomm9 flagcomm10 flagcomm11
          flagcomm12 flagcomm13 addrorigin mc_name1 mc_city1 mc_street
          extension1 extension2 time_zone taxjurcode address_id langu_crea
    FROM lfa1 AS l
    INNER JOIN adrc AS ad ON l~adrnr EQ ad~addrnumber
    INTO TABLE i_lfa1_proveedor
    WHERE l~lifnr IN s_lifnr
      AND l~kunnr IN s_kunnr
      AND ( l~stcd1 IN s_stcd1
      OR   l~stceg IN s_stcd1
      OR   l~stcd3 IN s_stcd1 ).
  IF sy-subrc EQ 0.
    DELETE i_lfa1_proveedor WHERE kunnr EQ space.
  ENDIF.

  LOOP AT i_kna1_cliente INTO lw_kna1_cliente.
    READ TABLE i_lfa1_proveedor INTO lw_lfa1_proveedor
      WITH KEY kunnr = lw_kna1_cliente-kunnr
                lifnr = lw_kna1_cliente-lifnr.
    IF sy-subrc EQ 0.
*      IF lw_kna1_cliente-addrnumber NE
*         lw_lfa1_proveedor-addrnumber.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-ADDRNUMBER' space.
*      ENDIF.

      IF lw_kna1_cliente-date_from NE
          lw_lfa1_proveedor-date_from.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-DATE_FROM' space.
      ENDIF.

      IF lw_kna1_cliente-nation NE
          lw_lfa1_proveedor-nation.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NATION' space.
      ENDIF.

      IF lw_kna1_cliente-date_to NE
          lw_lfa1_proveedor-date_to.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-DATE_TO' space.
      ENDIF.

      IF lw_kna1_cliente-title NE
          lw_lfa1_proveedor-title.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-TITLE' space.
      ENDIF.

      IF lw_kna1_cliente-name1 NE
          lw_lfa1_proveedor-name1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NAME1' space.
      ENDIF.


      IF lw_kna1_cliente-name2 NE
          lw_lfa1_proveedor-name2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NAME2' space.
      ENDIF.

      IF lw_kna1_cliente-name3 NE
          lw_lfa1_proveedor-name3.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NAME3' space.
      ENDIF.

      IF lw_kna1_cliente-name4 NE
          lw_lfa1_proveedor-name4.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NAME4' space.
      ENDIF.

      IF lw_kna1_cliente-name_text NE
          lw_lfa1_proveedor-name_text.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NAME_TEXT' space.
      ENDIF.

      IF lw_kna1_cliente-name_co NE
          lw_lfa1_proveedor-name_co.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-NAME_CO' space.
      ENDIF.

      IF lw_kna1_cliente-city1 NE
          lw_lfa1_proveedor-city1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-CITY1' space.
      ENDIF.

      IF lw_kna1_cliente-city2 NE
          lw_lfa1_proveedor-city2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-CITY2' space.
      ENDIF.

      IF lw_kna1_cliente-city_code NE
          lw_lfa1_proveedor-city_code.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-CITY_CODE' space.
      ENDIF.

      IF lw_kna1_cliente-home_city NE
          lw_lfa1_proveedor-home_city.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-HOME_CITY' space.
      ENDIF.

      IF lw_kna1_cliente-cityh_code NE
          lw_lfa1_proveedor-cityh_code.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-CITYH_CODE' space.
      ENDIF.

      IF lw_kna1_cliente-chckstatus NE
          lw_lfa1_proveedor-chckstatus.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-CHCKSTATUS' space.
      ENDIF.

      IF lw_kna1_cliente-regiogroup NE
          lw_lfa1_proveedor-regiogroup.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-REGIOGROUP' space.
      ENDIF.

      IF lw_kna1_cliente-regiogroup NE
          lw_lfa1_proveedor-regiogroup.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-REGIOGROUP' space.
      ENDIF.

      IF lw_kna1_cliente-post_code1 NE
          lw_lfa1_proveedor-post_code1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-POST_CODE1' space.
      ENDIF.

      IF lw_kna1_cliente-post_code2 NE
          lw_lfa1_proveedor-post_code2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-POST_CODE2' space.
      ENDIF.

      IF lw_kna1_cliente-post_code3 NE
          lw_lfa1_proveedor-post_code3.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-POST_CODE3' space.
      ENDIF.

      IF lw_kna1_cliente-pcode1_ext NE
          lw_lfa1_proveedor-pcode1_ext.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PCODE1_EXT' space.
      ENDIF.

      IF lw_kna1_cliente-pcode2_ext NE
          lw_lfa1_proveedor-pcode2_ext.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PCODE2_EXT' space.
      ENDIF.

      IF lw_kna1_cliente-pcode3_ext NE
          lw_lfa1_proveedor-pcode3_ext.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PCODE3_EXT' space.
      ENDIF.

      IF lw_kna1_cliente-po_box NE
          lw_lfa1_proveedor-po_box.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PO_BOX' space.
      ENDIF.

      IF lw_kna1_cliente-dont_use_p NE
          lw_lfa1_proveedor-dont_use_p.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-DONT_USE_P' space.
      ENDIF.

      IF lw_kna1_cliente-po_box_num NE
          lw_lfa1_proveedor-po_box_num.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PO_BOX_NUM' space.
      ENDIF.

      IF lw_kna1_cliente-po_box_loc NE
          lw_lfa1_proveedor-po_box_loc.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PO_BOX_LOC' space.
      ENDIF.

      IF lw_kna1_cliente-city_code2 NE
          lw_lfa1_proveedor-city_code2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-CITY_CODE2' space.
      ENDIF.

      IF lw_kna1_cliente-po_box_reg NE
          lw_lfa1_proveedor-po_box_reg.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PO_BOX_REG' space.
      ENDIF.

      IF lw_kna1_cliente-po_box_cty NE
          lw_lfa1_proveedor-po_box_cty.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PO_BOX_CTY' space.
      ENDIF.

      IF lw_kna1_cliente-postalarea NE
          lw_lfa1_proveedor-postalarea.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-POSTALAREA' space.
      ENDIF.

      IF lw_kna1_cliente-transpzone NE
          lw_lfa1_proveedor-transpzone.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-TRANSPZONE' space.
      ENDIF.

      IF lw_kna1_cliente-street NE
          lw_lfa1_proveedor-street.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-STREET' space.
      ENDIF.

      IF lw_kna1_cliente-dont_use_s NE
          lw_lfa1_proveedor-dont_use_s.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-DONT_USE_S' space.
      ENDIF.

      IF lw_kna1_cliente-streetcode NE
          lw_lfa1_proveedor-streetcode.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-STREETCODE' space.
      ENDIF.

      IF lw_kna1_cliente-streetabbr NE
          lw_lfa1_proveedor-streetabbr.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-STREETABBR' space.
      ENDIF.

      IF lw_kna1_cliente-house_num1 NE
          lw_lfa1_proveedor-house_num1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-HOUSE_NUM1' space.
      ENDIF.

      IF lw_kna1_cliente-house_num2 NE
          lw_lfa1_proveedor-house_num2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-HOUSE_NUM2' space.
      ENDIF.

      IF lw_kna1_cliente-house_num3 NE
          lw_lfa1_proveedor-house_num3.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-HOUSE_NUM3' space.
      ENDIF.

      IF lw_kna1_cliente-str_suppl1 NE
          lw_lfa1_proveedor-str_suppl1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-STR_SUPPL1' space.
      ENDIF.

      IF lw_kna1_cliente-str_suppl2 NE
          lw_lfa1_proveedor-str_suppl2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-STR_SUPPL2' space.
      ENDIF.

      IF lw_kna1_cliente-str_suppl3 NE
          lw_lfa1_proveedor-str_suppl3.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-STR_SUPPL3' space.
      ENDIF.

      IF lw_kna1_cliente-location NE
          lw_lfa1_proveedor-location.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-LOCATION' space.
      ENDIF.

      IF lw_kna1_cliente-building NE
          lw_lfa1_proveedor-building.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-BUILDING' space.
      ENDIF.

      IF lw_kna1_cliente-floor NE
          lw_lfa1_proveedor-floor.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-FLOOR' space.
      ENDIF.

      IF lw_kna1_cliente-roomnumber NE
          lw_lfa1_proveedor-roomnumber.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-ROOMNUMBER' space.
      ENDIF.

      IF lw_kna1_cliente-country NE
          lw_lfa1_proveedor-country.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-COUNTRY' space.
      ENDIF.

      IF lw_kna1_cliente-langu NE
          lw_lfa1_proveedor-langu.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-LANGU' space.
      ENDIF.

      IF lw_kna1_cliente-region NE
          lw_lfa1_proveedor-region.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-REGION' space.
      ENDIF.

      IF lw_kna1_cliente-addr_group NE
          lw_lfa1_proveedor-addr_group.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-ADDR_GROUP' space.
      ENDIF.

      IF lw_kna1_cliente-flaggroups NE
          lw_lfa1_proveedor-flaggroups.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-FLAGGROUPS' space.
      ENDIF.

      IF lw_kna1_cliente-pers_addr NE
          lw_lfa1_proveedor-pers_addr.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-PERS_ADDR' space.
      ENDIF.

      IF lw_kna1_cliente-sort1 NE
          lw_lfa1_proveedor-sort1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-SORT1' space.
      ENDIF.

      IF lw_kna1_cliente-sort2 NE
          lw_lfa1_proveedor-sort2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-SORT2' space.
      ENDIF.

      IF lw_kna1_cliente-sort_phn NE
          lw_lfa1_proveedor-sort_phn.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-SORT_PHN' space.
      ENDIF.

      IF lw_kna1_cliente-deflt_comm NE
          lw_lfa1_proveedor-deflt_comm.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-DEFLT_COMM' space.
      ENDIF.

*      IF lw_kna1_cliente-tel_number NE
*         lw_lfa1_proveedor-tel_number.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-TEL_NUMBER' space.
*      ENDIF.

      IF lw_kna1_cliente-tel_extens NE
          lw_lfa1_proveedor-tel_extens.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-TEL_EXTENS' space.
      ENDIF.

*      IF lw_kna1_cliente-fax_number NE
*         lw_lfa1_proveedor-fax_number.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FAX_NUMBER' space.
*      ENDIF.

      IF lw_kna1_cliente-fax_extens NE
          lw_lfa1_proveedor-fax_extens.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-FAX_EXTENS' space.
      ENDIF.

*      IF lw_kna1_cliente-flagcomm2 NE
*         lw_lfa1_proveedor-flagcomm2.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM2' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm3 NE
*         lw_lfa1_proveedor-flagcomm3.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM3' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm4 NE
*         lw_lfa1_proveedor-flagcomm4.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM4' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm5 NE
*         lw_lfa1_proveedor-flagcomm5.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM5' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm6 NE
*         lw_lfa1_proveedor-flagcomm6.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM6' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm7 NE
*         lw_lfa1_proveedor-flagcomm7.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM7' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm8 NE
*         lw_lfa1_proveedor-flagcomm8.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM8' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm9 NE
*         lw_lfa1_proveedor-flagcomm9.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM9' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm10 NE
*         lw_lfa1_proveedor-flagcomm10.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM10' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm11 NE
*         lw_lfa1_proveedor-flagcomm11.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM11' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm12 NE
*         lw_lfa1_proveedor-flagcomm12.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM12' space.
*      ENDIF.
*
*      IF lw_kna1_cliente-flagcomm13 NE
*         lw_lfa1_proveedor-flagcomm13.
**       Añadimos al log.
*        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                  'ADRC-FLAGCOMM13' space.
*      ENDIF.

      IF lw_kna1_cliente-addrorigin NE
          lw_lfa1_proveedor-addrorigin.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-ADDRORIGIN' space.
      ENDIF.

      IF lw_kna1_cliente-mc_name1 NE
          lw_lfa1_proveedor-mc_name1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-MC_NAME1' space.
      ENDIF.

      IF lw_kna1_cliente-mc_city1 NE
          lw_lfa1_proveedor-mc_city1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-MC_CITY1' space.
      ENDIF.

      IF lw_kna1_cliente-mc_street NE
          lw_lfa1_proveedor-mc_street.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-MC_STREET' space.
      ENDIF.

      IF lw_kna1_cliente-extension1 NE
          lw_lfa1_proveedor-extension1.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-EXTENSION1' space.
      ENDIF.

      IF lw_kna1_cliente-extension2 NE
          lw_lfa1_proveedor-extension2.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-EXTENSION2' space.
      ENDIF.

      IF lw_kna1_cliente-time_zone NE
          lw_lfa1_proveedor-time_zone.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-TIME_ZONE' space.
      ENDIF.

      IF lw_kna1_cliente-taxjurcode NE
          lw_lfa1_proveedor-taxjurcode.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-TAXJURCODE' space.
      ENDIF.

      IF lw_kna1_cliente-address_id NE
          lw_lfa1_proveedor-address_id.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-ADDRESS_ID' space.
      ENDIF.

      IF lw_kna1_cliente-langu_crea NE
          lw_lfa1_proveedor-langu_crea.
*       Añadimos al log.
        PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
                                  'ADRC-LANGU_CREA' space.
      ENDIF.
*    ELSE.
**     Añadimos al log.
*      CLEAR lv_texto.
*      CONCATENATE 'No existe proveedor' lw_kna1_cliente-lifnr 'para cliente' lw_kna1_cliente-kunnr
*        INTO lv_texto SEPARATED BY space.
*      PERFORM f_add_log_4 USING lw_kna1_cliente-kunnr lw_kna1_cliente-lifnr
*                                space lv_texto.
    ENDIF.
  ENDLOOP.

  IF i_cp_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 4 TEXT-017 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 4 TEXT-017 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_4
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_4  USING p_kunnr
                        p_lifnr
                        p_campo
                        p_mensaje.

  DATA: lw_cp_log TYPE ty_cliente_proveedor_log.
  CLEAR lw_cp_log.

  lw_cp_log-kunnr = p_kunnr.
  lw_cp_log-lifnr = p_lifnr.
  IF p_mensaje IS NOT INITIAL.
    lw_cp_log-comentario = p_mensaje.
  ELSE.
*    CONCATENATE p_campo text-032 INTO lw_cp_log-comentario
*      SEPARATED BY space.
    lw_cp_log-comentario = p_campo.
  ENDIF.
  APPEND lw_cp_log TO i_cp_log.

ENDFORM.                    "f_add_log_4
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_5.
  DATA: lw_kna1_cliente_db   TYPE ty_cliente_db,
        lw_lfa1_proveedor_db TYPE ty_proveedor_db,
        lv_texto             TYPE string.

  CLEAR: i_kna1_cliente_db[], i_lfa1_proveedor_db[], i_cp_db_log[],
          lw_kna1_cliente_db, lw_lfa1_proveedor_db, lv_texto.

  SELECT k~kunnr k~lifnr kn~banks kn~bankl kn~bankn kn~bkont kn~bvtyp
          kn~xezer kn~bkref kn~koinh kn~ebpp_accname kn~ebpp_bvstatus
          kn~kovon kn~kobis
    FROM kna1 AS k
    INNER JOIN knbk AS kn ON k~kunnr EQ kn~kunnr
    INTO TABLE i_kna1_cliente_db
    WHERE k~kunnr IN s_kunnr
      AND k~lifnr IN s_lifnr
      AND ( k~stcd1 IN s_stcd1
      OR   k~stceg IN s_stcd1
      OR   k~stcd3 IN s_stcd1 ).
  IF sy-subrc EQ 0.
    DELETE i_kna1_cliente_db WHERE lifnr EQ space.
  ENDIF.

  SELECT l~lifnr l~kunnr lf~banks lf~bankl lf~bankn lf~bkont lf~bvtyp
          lf~xezer lf~bkref lf~koinh lf~ebpp_accname lf~ebpp_bvstatus
          lf~kovon lf~kobis
    FROM lfa1 AS l
    INNER JOIN lfbk AS lf ON l~lifnr EQ lf~lifnr
    INTO TABLE i_lfa1_proveedor_db
    WHERE l~lifnr IN s_lifnr
      AND l~kunnr IN s_kunnr
      AND ( l~stcd1 IN s_stcd1
      OR   l~stceg IN s_stcd1
      OR   l~stcd3 IN s_stcd1 ).
  IF sy-subrc EQ 0.
    DELETE i_lfa1_proveedor_db WHERE kunnr EQ space.
  ENDIF.

  LOOP AT i_kna1_cliente_db INTO lw_kna1_cliente_db.
    READ TABLE i_lfa1_proveedor_db INTO lw_lfa1_proveedor_db
      WITH KEY kunnr          = lw_kna1_cliente_db-kunnr
                lifnr          = lw_kna1_cliente_db-lifnr
                banks          = lw_kna1_cliente_db-banks
                bankl          = lw_kna1_cliente_db-bankl
                bankn          = lw_kna1_cliente_db-bankn
                bkont          = lw_kna1_cliente_db-bkont
                bvtyp          = lw_kna1_cliente_db-bvtyp
                xezer          = lw_kna1_cliente_db-xezer
                bkref          = lw_kna1_cliente_db-bkref
                koinh          = lw_kna1_cliente_db-koinh
                ebpp_accname   = lw_kna1_cliente_db-ebpp_accname
                ebpp_bvstatus  = lw_kna1_cliente_db-ebpp_bvstatus
                kovon          = lw_kna1_cliente_db-kovon
                kobis          = lw_kna1_cliente_db-kobis.
    IF sy-subrc NE 0.
*     Añadimos al log.
      PERFORM f_add_log_5 USING lw_kna1_cliente_db-kunnr lw_kna1_cliente_db-lifnr
                                lw_kna1_cliente_db space.
    ENDIF.
  ENDLOOP.

  LOOP AT i_lfa1_proveedor_db INTO lw_lfa1_proveedor_db.
    READ TABLE i_kna1_cliente_db INTO lw_kna1_cliente_db
      WITH KEY kunnr          = lw_lfa1_proveedor_db-kunnr
                lifnr          = lw_lfa1_proveedor_db-lifnr
                banks          = lw_lfa1_proveedor_db-banks
                bankl          = lw_lfa1_proveedor_db-bankl
                bankn          = lw_lfa1_proveedor_db-bankn
                bkont          = lw_lfa1_proveedor_db-bkont
                bvtyp          = lw_lfa1_proveedor_db-bvtyp
                xezer          = lw_lfa1_proveedor_db-xezer
                bkref          = lw_lfa1_proveedor_db-bkref
                koinh          = lw_lfa1_proveedor_db-koinh
                ebpp_accname   = lw_lfa1_proveedor_db-ebpp_accname
                ebpp_bvstatus  = lw_lfa1_proveedor_db-ebpp_bvstatus
                kovon          = lw_lfa1_proveedor_db-kovon
                kobis          = lw_lfa1_proveedor_db-kobis.
    IF sy-subrc NE 0.
*     Añadimos al log.
      PERFORM f_add_log_5 USING lw_lfa1_proveedor_db-kunnr lw_lfa1_proveedor_db-lifnr
                                lw_lfa1_proveedor_db space.
    ENDIF.
  ENDLOOP.

  IF i_cp_db_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 5 TEXT-018 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 5 TEXT-018 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_5
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_5  USING p_kunnr
                        p_lifnr
                        p_campo TYPE ty_cliente_db
                        p_mensaje.

  DATA: lw_cp_db_log TYPE ty_cliente_proveedor_db_log.
  CLEAR lw_cp_db_log.

  lw_cp_db_log-kunnr = p_kunnr.
  lw_cp_db_log-lifnr = p_lifnr.
  IF p_mensaje IS NOT INITIAL.
    lw_cp_db_log-comentario = p_mensaje.
  ELSE.
*    CONCATENATE p_campo text-032 INTO lw_cp_db_log-comentario
*      SEPARATED BY space.
    CONCATENATE p_campo-banks p_campo-bankl p_campo-bankn
                p_campo-bkont p_campo-bvtyp
            INTO lw_cp_db_log-comentario
      SEPARATED BY space.
  ENDIF.
  APPEND lw_cp_db_log TO i_cp_db_log.

ENDFORM.                    "f_add_log_5
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_6.
  TYPES: BEGIN OF lty_bnka,
           banks TYPE bnka-banks,
           bankl TYPE bnka-bankl,
         END   OF lty_bnka.

  DATA: li_bnka_knbk TYPE TABLE OF lty_bnka,
        li_bnka_lfbk TYPE TABLE OF lty_bnka,
        lw_knbk      TYPE ty_knbk,
        lw_lfbk      TYPE ty_lfbk.

  CLEAR: li_bnka_knbk[], li_bnka_lfbk[], i_bnka_log[],
          i_knbk[], i_lfbk[], lw_knbk, lw_lfbk.

* Datos de cliente.
  IF i_kna1[] IS INITIAL.
    SELECT kunnr land1 pstlz regio adrnr lifnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
**      "INI ZPRY_PRS4 03.04.2024 54217049T
            anred
*      INTO TABLE i_kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
**      "FIN ZPRY_PRS4
      FROM kna1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_kna1[] IS NOT INITIAL.
    SELECT kunnr banks bankl
      FROM knbk
      INTO TABLE i_knbk
        FOR ALL ENTRIES IN i_kna1
      WHERE kunnr EQ i_kna1-kunnr.
    IF sy-subrc EQ 0.
      SELECT banks bankl
        FROM bnka
        INTO TABLE li_bnka_knbk
          FOR ALL ENTRIES IN i_knbk
        WHERE banks EQ i_knbk-banks
          AND bankl EQ i_knbk-bankl.
      IF sy-subrc EQ 0.
      ENDIF.
    ENDIF.
  ENDIF.

* Datos de proveedor.
  IF i_lfa1[] IS INITIAL.
    SELECT lifnr land1 pstlz regio adrnr kunnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
**      "INI ZPRY_PRS4 03.04.2024 54217049T
            anred
*      INTO TABLE i_lfa1
      INTO CORRESPONDING FIELDS OF TABLE i_lfa1
**      "FIN ZPRY_PRS4
      FROM lfa1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_lfa1[] IS NOT INITIAL.
    SELECT lifnr banks bankl
      FROM lfbk
      INTO TABLE i_lfbk
        FOR ALL ENTRIES IN i_lfa1
      WHERE lifnr EQ i_lfa1-lifnr.
    IF sy-subrc EQ 0.
      SELECT banks bankl
        FROM bnka
        INTO TABLE li_bnka_lfbk
          FOR ALL ENTRIES IN i_lfbk
        WHERE banks EQ i_lfbk-banks
          AND bankl EQ i_lfbk-bankl.
      IF sy-subrc EQ 0.
      ENDIF.
    ENDIF.
  ENDIF.

  SORT li_bnka_knbk BY banks bankl.
  SORT li_bnka_lfbk BY banks bankl.

* Comprobaciones.
  LOOP AT i_knbk INTO lw_knbk.
    READ TABLE li_bnka_knbk TRANSPORTING NO FIELDS
      WITH KEY banks = lw_knbk-banks
                bankl = lw_knbk-bankl BINARY SEARCH.
    IF sy-subrc NE 0.
*     Añadimos al log.
      PERFORM f_add_log_6 USING lw_knbk-kunnr lw_knbk-banks lw_knbk-bankl
                                TEXT-033.
    ENDIF.
  ENDLOOP.

  LOOP AT i_lfbk INTO lw_lfbk.
    READ TABLE li_bnka_lfbk TRANSPORTING NO FIELDS
      WITH KEY banks = lw_lfbk-banks
                bankl = lw_lfbk-bankl BINARY SEARCH.
    IF sy-subrc NE 0.
*     Añadimos al log.
      PERFORM f_add_log_6 USING lw_lfbk-lifnr lw_lfbk-banks lw_lfbk-bankl
                                TEXT-034.
    ENDIF.
  ENDLOOP.

  IF i_bnka_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 6 TEXT-019 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 6 TEXT-019 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_6
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_6  USING p_kunnr
                        p_banks
                        p_bankl
                        p_mensaje.

  DATA: lw_bnka_log TYPE ty_bnka_log.
  CLEAR lw_bnka_log.

  lw_bnka_log-kunnr      = p_kunnr.
  lw_bnka_log-banks      = p_banks.
  lw_bnka_log-bankl      = p_bankl.
  lw_bnka_log-comentario = p_mensaje.

  APPEND lw_bnka_log TO i_bnka_log.

ENDFORM.                    "f_add_log_6
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_7.
  TYPES: BEGIN OF ty_tfktaxnumtype,
           taxtype TYPE tfktaxnumtype-taxtype,
         END   OF ty_tfktaxnumtype.

  DATA: li_kna1_lfa1     TYPE TABLE OF ty_kna1,
        li_kna1_lfa1_aux TYPE TABLE OF ty_kna1,
        li_tfka          TYPE TABLE OF ty_tfktaxnumtype,
        li_tfka_real     TYPE TABLE OF ty_tfktaxnumtype,
        lw_tfka          TYPE ty_tfktaxnumtype,
        lw_kna1_lfa1     TYPE ty_kna1,
        lv_lines         TYPE i.

  CLEAR: li_kna1_lfa1[], li_kna1_lfa1_aux[], li_tfka[], li_tfka_real[],
          i_nif_log[], lw_tfka, lw_kna1_lfa1, lv_lines.

* Seleccionamos de KNA1.
  IF i_kna1[] IS INITIAL.
    SELECT kunnr land1 pstlz regio adrnr lifnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
      FROM kna1
      INTO TABLE li_kna1_lfa1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ELSE.
    CLEAR lv_lines.
    DESCRIBE TABLE i_kna1 LINES lv_lines.
    APPEND LINES OF i_kna1 FROM 1 TO lv_lines TO li_kna1_lfa1.
  ENDIF.

* Seleccionamos de LFA1.
  IF i_lfa1[] IS INITIAL.
    SELECT lifnr land1 pstlz regio adrnr kunnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
      FROM lfa1
      APPENDING TABLE li_kna1_lfa1
      WHERE lifnr IN s_lifnr
        AND kunnr IN s_kunnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ELSE.
    CLEAR lv_lines.
    DESCRIBE TABLE i_lfa1 LINES lv_lines.
    APPEND LINES OF i_lfa1 FROM 1 TO lv_lines TO li_kna1_lfa1.
  ENDIF.

* Eliminamos duplicados de paises.
  SORT li_kna1_lfa1 BY land1.
  DELETE ADJACENT DUPLICATES FROM li_kna1_lfa1 COMPARING land1.

* Comprobación.
  LOOP AT li_kna1_lfa1 INTO lw_kna1_lfa1.
    IF lw_kna1_lfa1-stcd1 IS NOT INITIAL.
      CLEAR lw_tfka.
      CONCATENATE lw_kna1_lfa1-land1 '1' INTO lw_tfka-taxtype.
      APPEND lw_tfka TO li_tfka.
    ENDIF.

    IF lw_kna1_lfa1-stcd3 IS NOT INITIAL.
      CLEAR lw_tfka.
      CONCATENATE lw_kna1_lfa1-land1 '3' INTO lw_tfka-taxtype.
      APPEND lw_tfka TO li_tfka.
    ENDIF.

    IF lw_kna1_lfa1-stceg IS NOT INITIAL.
      CLEAR lw_tfka.
      CONCATENATE lw_kna1_lfa1-land1 '0' INTO lw_tfka-taxtype.
      APPEND lw_tfka TO li_tfka.
    ENDIF.
  ENDLOOP.

* Eliminamos duplicados de claves.
  SORT li_tfka BY taxtype.
  DELETE ADJACENT DUPLICATES FROM li_tfka COMPARING taxtype.

* Seleccionamos las claves.
  SELECT taxtype
    FROM tfktaxnumtype
    INTO TABLE li_tfka_real
      FOR ALL ENTRIES IN li_tfka
    WHERE taxtype EQ li_tfka-taxtype.
  IF sy-subrc EQ 0.
  ENDIF.

* Comprobamos las claves.
  LOOP AT li_tfka INTO lw_tfka.
    READ TABLE li_tfka_real TRANSPORTING NO FIELDS
      WITH KEY taxtype = lw_tfka-taxtype.
    IF sy-subrc NE 0.
*     Añadimos al log.
      PERFORM f_add_log_7 USING lw_tfka-taxtype TEXT-036.
    ENDIF.
  ENDLOOP.

  IF i_nif_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 7 TEXT-020 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 7 TEXT-020 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_7
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_7  USING p_clave
                        p_mensaje.

  DATA: lw_nif_log TYPE ty_nif_log.
  CLEAR lw_nif_log.

  lw_nif_log-taxtype    = p_clave.
  lw_nif_log-comentario = p_mensaje.
  APPEND lw_nif_log TO i_nif_log.

ENDFORM.                    "f_add_log_7
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_8
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_8.
  DATA: lw_kna1   TYPE ty_kna1,
        lw_lfa1   TYPE ty_lfa1,
        lw_postal TYPE  adrs_post.

  CLEAR: i_postal_log[], lw_kna1, lw_lfa1, lw_postal.

* Seleccionamos de KNA1.
  IF i_kna1[] IS INITIAL.
    SELECT kunnr land1 pstlz regio adrnr lifnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
**     "INI ZPRY_PRS4 03.04.2024 54217049T
            anred
*      INTO TABLE i_kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
**      "FIN ZPRY_PRS4
      FROM kna1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

* Seleccionamos de LFA1.
  IF i_lfa1[] IS INITIAL.
    SELECT lifnr land1 pstlz regio adrnr kunnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
**      "INI ZPRY_PRS4 03.04.2024 54217049T
            anred
*      INTO TABLE i_lfa1
      INTO CORRESPONDING FIELDS OF TABLE i_lfa1
**      "FIN ZPRY_PRS4
      FROM lfa1
      WHERE lifnr IN s_lifnr
        AND kunnr IN s_kunnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

* Eliminamos blancos.
**  "INI ZPRY_PRS4 03.04.2024 54217049T
*  DELETE i_kna1 WHERE pstlz NE space.
*  DELETE i_lfa1 WHERE pstlz NE space.
  DELETE i_kna1 WHERE pstlz EQ space.
  DELETE i_lfa1 WHERE pstlz EQ space.
**  "FIN ZPRY_PRS4

  LOOP AT i_kna1 INTO lw_kna1.
    CLEAR lw_postal.

    lw_postal-post_code1 = lw_kna1-pstlz.
    lw_postal-region     = lw_kna1-regio.
    lw_postal-country    = lw_kna1-land1.

    CALL FUNCTION c_addr
      EXPORTING
        country                        = lw_kna1-land1
        postal_address                 = lw_postal
      EXCEPTIONS
        country_not_valid              = 1
        region_not_valid               = 2
        postal_code_city_not_valid     = 3
        postal_code_po_box_not_valid   = 4
        postal_code_company_not_valid  = 5
        po_box_missing                 = 6
        postal_code_po_box_missing     = 7
        postal_code_missing            = 8
        postal_code_pobox_comp_missing = 9
        po_box_region_not_valid        = 10
        po_box_country_not_valid       = 11
        pobox_and_poboxnum_filled      = 12
        OTHERS                         = 13.
    IF sy-subrc NE 0.
*     Añadimos al log.
      PERFORM f_add_log_8 USING lw_kna1-kunnr lw_kna1-land1 lw_kna1-pstlz
                                lw_kna1-regio TEXT-037.
    ENDIF.
  ENDLOOP.

  LOOP AT i_lfa1 INTO lw_lfa1.
    CLEAR lw_postal.

    lw_postal-post_code1 = lw_lfa1-pstlz.
    lw_postal-region     = lw_lfa1-regio.
    lw_postal-country    = lw_lfa1-land1.

    CALL FUNCTION c_addr
      EXPORTING
        country                        = lw_lfa1-land1
        postal_address                 = lw_postal
      EXCEPTIONS
        country_not_valid              = 1
        region_not_valid               = 2
        postal_code_city_not_valid     = 3
        postal_code_po_box_not_valid   = 4
        postal_code_company_not_valid  = 5
        po_box_missing                 = 6
        postal_code_po_box_missing     = 7
        postal_code_missing            = 8
        postal_code_pobox_comp_missing = 9
        po_box_region_not_valid        = 10
        po_box_country_not_valid       = 11
        pobox_and_poboxnum_filled      = 12
        OTHERS                         = 13.
    IF sy-subrc NE 0.
*     Añadimos al log.
**      "INI ZPRY_PRS4 03.04.2024 54217049T
*      PERFORM f_add_log_8 USING lw_kna1-kunnr lw_kna1-land1 lw_kna1-pstlz
*                                lw_kna1-regio text-038.
      PERFORM f_add_log_8 USING lw_lfa1-lifnr lw_lfa1-land1 lw_lfa1-pstlz
                                lw_lfa1-regio TEXT-038.
**      "FIN ZPRY_PRS4
    ENDIF.
  ENDLOOP.

  IF i_postal_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 8 TEXT-021 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 8 TEXT-021 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_8
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_8
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_8  USING p_kunnr
                        p_land1
                        p_pstlz
                        p_regio
                        p_mensaje.

  DATA: lw_postal_log TYPE ty_postal_log.
  CLEAR lw_postal_log.

  lw_postal_log-kunnr      = p_kunnr.
  lw_postal_log-land1      = p_land1.
  lw_postal_log-pstlz      = p_pstlz.
  lw_postal_log-regio      = p_regio.
  lw_postal_log-comentario = p_mensaje.
  APPEND lw_postal_log TO i_postal_log.

ENDFORM.                    "f_add_log_8
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_9
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_9.
  TYPES: BEGIN OF lty_adr6,
           addrnumber TYPE adr6-addrnumber,
           smtp_addr  TYPE adr6-smtp_addr,
         END   OF lty_adr6.

  DATA: li_adr6 TYPE TABLE OF lty_adr6,
        lw_adr6 TYPE lty_adr6,
        lw_kna1 TYPE ty_kna1,
        lw_lfa1 TYPE ty_lfa1,
        lw_sxad TYPE sx_address.

  CLEAR: i_correoe_log[], li_adr6[], lw_adr6.

  IF i_kna1[] IS INITIAL.
*   Seleccionamos de KNA1.
    SELECT kunnr land1 pstlz regio adrnr lifnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
**      "INI ZPRY_PRS4 03.04.2024 54217049T
            anred
*      INTO TABLE i_kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
**      "FIN ZPRY_PRS4
      FROM kna1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_kna1[] IS NOT INITIAL.
    SELECT addrnumber smtp_addr
      FROM adr6
      INTO TABLE li_adr6
        FOR ALL ENTRIES IN i_kna1
      WHERE addrnumber EQ i_kna1-adrnr
        AND smtp_addr  NE space.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_lfa1[] IS INITIAL.
*   Seleccionamos de LFA1.
    SELECT lifnr land1 pstlz regio adrnr kunnr
            stcd1 stcd2 stceg stcd3 stcd4 stcd5
**      "INI ZPRY_PRS4 03.04.2024 54217049T
            anred
*      INTO TABLE i_lfa1
      INTO CORRESPONDING FIELDS OF TABLE i_lfa1
**      "FIN ZPRY_PRS4
      FROM lfa1
      WHERE lifnr IN s_lifnr
        AND kunnr IN s_kunnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_lfa1[] IS NOT INITIAL.
    SELECT addrnumber smtp_addr
      FROM adr6
      APPENDING TABLE li_adr6
        FOR ALL ENTRIES IN i_lfa1
      WHERE addrnumber  EQ i_lfa1-adrnr
        AND smtp_addr   NE space.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.


* Comprobamos.
  LOOP AT i_kna1 INTO lw_kna1.
    READ TABLE li_adr6 INTO lw_adr6
      WITH KEY addrnumber = lw_kna1-adrnr.
    IF sy-subrc EQ 0.
      CLEAR lw_sxad.
      lw_sxad-type    = c_int.
      lw_sxad-address = lw_adr6-smtp_addr.
      CALL FUNCTION c_address
        EXPORTING
          address_unstruct    = lw_sxad
        EXCEPTIONS
          error_address_type  = 1
          error_address       = 2
          error_group_address = 3
          OTHERS              = 4.
      IF sy-subrc NE 0.
*       Añadimos al log.
        PERFORM f_add_log_9 USING lw_kna1-kunnr lw_adr6-smtp_addr TEXT-039.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT i_lfa1 INTO lw_lfa1.
    READ TABLE li_adr6 INTO lw_adr6
      WITH KEY addrnumber = lw_lfa1-adrnr.
    IF sy-subrc EQ 0.
      CLEAR lw_sxad.
      lw_sxad-type    = c_int.
      lw_sxad-address = lw_adr6-smtp_addr.
      CALL FUNCTION c_address
        EXPORTING
          address_unstruct    = lw_sxad
        EXCEPTIONS
          error_address_type  = 1
          error_address       = 2
          error_group_address = 3
          OTHERS              = 4.
      IF sy-subrc NE 0.
*       Añadimos al log.
        PERFORM f_add_log_9 USING lw_lfa1-lifnr lw_adr6-smtp_addr TEXT-040.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF i_correoe_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 9 TEXT-022 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 9 TEXT-022 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    "f_chequeo_prueba_9
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_9
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_KNA1_KUNNR  text
*      -->P_TEXT_005  text
*----------------------------------------------------------------------*
FORM f_add_log_9  USING p_kunnr
                        p_smtp
                        p_mensaje.

  DATA: lw_correoe_log TYPE ty_correoe_log.
  CLEAR lw_correoe_log.

  lw_correoe_log-kunnr      = p_kunnr.
  lw_correoe_log-smtp_addr  = p_smtp.
  lw_correoe_log-comentario = p_mensaje.
  APPEND lw_correoe_log TO i_correoe_log.

ENDFORM.                    "f_add_log_9
*&---------------------------------------------------------------------*
*&      Form  F_CUADRE_CLIENTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cuadre_clientes.

  PERFORM f_progreso USING 5 TEXT-047.

* Selección de datos para el cuadre.
  PERFORM f_seleccion_cuadre.

* Se informa el catálogo.
  PERFORM f_cargar_catalogo_cuadre.

  PERFORM f_progreso USING 100 TEXT-047.

* Mostramos ALV de cuadre.
  PERFORM f_mostar_log USING i_cuadre_log.

ENDFORM.                    "f_cuadre_clientes
*&---------------------------------------------------------------------*
*&      Form  F_SELECCION_CUADRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_seleccion_cuadre.
  TYPES: BEGIN OF lty_kna1_num,
           kunnr TYPE kna1-kunnr,
           ktokd TYPE kna1-ktokd,
         END OF lty_kna1_num,

         BEGIN OF lty_lfa1_num,
           lifnr TYPE lfa1-lifnr,
           ktokk TYPE lfa1-ktokk,
         END OF lty_lfa1_num,

         BEGIN OF lty_cust,
           customer TYPE cvi_cust_link-customer,
         END OF lty_cust,

         BEGIN OF lty_vend,
           vendor TYPE cvi_vend_link-vendor,
         END OF lty_vend.

  DATA:
    li_kna1_num   TYPE TABLE OF lty_kna1_num,
    li_lfa1_num   TYPE TABLE OF lty_lfa1_num,
    li_cust       TYPE TABLE OF lty_cust,
    li_vend       TYPE TABLE OF lty_vend,
    lw_kna1_num   TYPE lty_kna1_num,
    lw_lfa1_num   TYPE lty_lfa1_num,
    lw_cuadre_log TYPE ty_cuadre_log.

  CLEAR: i_cuadre_log[],
          li_kna1_num[],
          li_lfa1_num[],
          li_cust[],
          li_vend[],
          lw_kna1_num,
          lw_lfa1_num,
          lw_cuadre_log.

  SELECT kunnr                                         "#EC CI_NOWHERE.
          ktokd
    FROM kna1
    INTO TABLE li_kna1_num.
  IF sy-subrc EQ 0.
    SELECT customer                                    "#EC CI_NOWHERE.
      FROM cvi_cust_link
      INTO TABLE li_cust.
    IF  sy-subrc EQ 0.
      SORT li_cust BY customer.
    ENDIF.
  ENDIF.

  SELECT lifnr                                         "#EC CI_NOWHERE.
          ktokk
    FROM lfa1
    INTO TABLE li_lfa1_num.
  IF sy-subrc EQ 0.
    SELECT vendor                                      "#EC CI_NOWHERE.
      FROM cvi_vend_link
      INTO TABLE li_vend.
    IF sy-subrc EQ 0.
      SORT li_vend BY vendor.
    ENDIF.
  ENDIF.

  LOOP AT li_kna1_num INTO lw_kna1_num.
    READ TABLE li_cust TRANSPORTING NO FIELDS
      WITH KEY customer = lw_kna1_num-kunnr.
    IF sy-subrc NE 0.
      CLEAR lw_cuadre_log.
      lw_cuadre_log-kunnr      = lw_kna1_num-kunnr.
      lw_cuadre_log-ktokd      = lw_kna1_num-ktokd.
      lw_cuadre_log-comentario = TEXT-045.
      APPEND lw_cuadre_log TO i_cuadre_log.
    ENDIF.
  ENDLOOP.

  LOOP AT li_lfa1_num INTO lw_lfa1_num.
    READ TABLE li_vend TRANSPORTING NO FIELDS
      WITH KEY vendor = lw_lfa1_num-lifnr.
    IF sy-subrc NE 0.
      CLEAR lw_cuadre_log.
      lw_cuadre_log-kunnr      = lw_lfa1_num-lifnr.
      lw_cuadre_log-ktokd      = lw_lfa1_num-ktokk.
      lw_cuadre_log-comentario = TEXT-046.
      APPEND lw_cuadre_log TO i_cuadre_log.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "f_seleccion_cuadre
*&---------------------------------------------------------------------*
*&      Form  F_BP_CREADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bp_creado.

  PERFORM f_progreso USING 5 TEXT-048.

* Selección de datos para el cuadre.
  PERFORM f_seleccion_bp_creado.

* Se informa el catálogo.
  PERFORM f_cargar_catalogo_bp.

  PERFORM f_progreso USING 100 TEXT-048.

* Mostramos ALV de cuadre.
  PERFORM f_mostar_log USING i_bp_creado_log.

ENDFORM.                    "f_bp_creado
*&---------------------------------------------------------------------*
*&      Form  F_SELECCION_BP_CREADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_seleccion_bp_creado.
  TYPES: BEGIN OF lty_cust,
           customer     TYPE cvi_cust_link-customer,
           partner_guid TYPE cvi_cust_link-partner_guid,
         END OF lty_cust,

         BEGIN OF lty_vend,
           vendor       TYPE cvi_vend_link-vendor,
           partner_guid TYPE cvi_vend_link-partner_guid,
         END   OF lty_vend,

         BEGIN OF lty_but000,
           partner      TYPE but000-partner,
           bu_group     TYPE but000-bu_group,
           partner_guid TYPE but000-partner_guid,
         END   OF lty_but000.

  DATA:
    li_but000    TYPE TABLE OF lty_but000,
    li_cust      TYPE TABLE OF lty_cust,
    li_vend      TYPE TABLE OF lty_vend,
    lw_bp_creado TYPE ty_bp_creado_log,
    lw_but000    TYPE lty_but000.

  CLEAR: i_bp_creado_log[], li_but000[], li_cust[], li_vend[],
          lw_bp_creado, lw_but000.

  SELECT partner                                       "#EC CI_NOWHERE.
          bu_group
          partner_guid
    FROM but000
    INTO TABLE li_but000.
  IF sy-subrc EQ 0.
    SORT li_but000 BY partner_guid.

    SELECT customer
            partner_guid
      FROM cvi_cust_link
      INTO TABLE li_cust
        FOR ALL ENTRIES IN li_but000
      WHERE partner_guid EQ li_but000-partner_guid.
    IF sy-subrc EQ 0.
      SORT li_cust BY partner_guid.
    ENDIF.

    SELECT vendor
            partner_guid
      FROM cvi_vend_link
      INTO TABLE li_vend
        FOR ALL ENTRIES IN li_but000
      WHERE partner_guid EQ li_but000-partner_guid.
    IF sy-subrc EQ 0.
      SORT li_vend BY partner_guid.
    ENDIF.

    LOOP AT li_but000 INTO lw_but000.
      READ TABLE li_cust TRANSPORTING NO FIELDS
        WITH KEY partner_guid = lw_but000-partner_guid
        BINARY SEARCH.
      IF sy-subrc NE 0.
        READ TABLE li_vend TRANSPORTING NO FIELDS
          WITH KEY partner_guid = lw_but000-partner_guid
          BINARY SEARCH.
        IF sy-subrc NE 0.
          CLEAR lw_bp_creado.
          lw_bp_creado-partner  = lw_but000-partner.
          lw_bp_creado-bu_group = lw_but000-bu_group.
          APPEND lw_bp_creado TO i_bp_creado_log.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "f_seleccion_bp_creado
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PAGOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_pagos.

  PERFORM f_progreso USING 5 TEXT-049.

* Selección de datos para el cuadre.
  PERFORM f_seleccion_chequeo_pagos.

* Se informa el catálogo.
  PERFORM f_cargar_catalogo_chequeo.

  PERFORM f_progreso USING 100 TEXT-049.

* Mostramos ALV de cuadre.
  PERFORM f_mostar_log USING i_chequeo_p_log.

ENDFORM.                    "f_chequeo_pagos
*&---------------------------------------------------------------------*
*&      Form  F_SELECCION_CHEQUEO_PAGOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_seleccion_chequeo_pagos.
  TYPES: BEGIN OF lty_kna1,
           kunnr TYPE kna1-kunnr,
           stcd1 TYPE kna1-stcd1,
           stcd3 TYPE kna1-stcd3,
           stceg TYPE kna1-stceg,
           lifnr TYPE kna1-lifnr,
         END OF lty_kna1,

         BEGIN OF lty_knbk,
           kunnr TYPE knbk-kunnr,
           banks TYPE tiban-banks,
           bankl TYPE tiban-bankl,
           bankn TYPE tiban-bankn,
           bkont TYPE tiban-bkont,
           bvtyp TYPE knbk-bvtyp,
         END OF lty_knbk,

         BEGIN OF lty_tiban,
           banks TYPE tiban-banks,
           bankl TYPE tiban-bankl,
           bankn TYPE tiban-bankn,
           bkont TYPE tiban-bkont,
           iban  TYPE tiban-iban,
         END OF lty_tiban,

         BEGIN OF lty_cust,
           partner_guid TYPE cvi_cust_link-partner_guid,
           customer     TYPE cvi_cust_link-customer,
         END OF lty_cust,

         BEGIN OF lty_but000,
           partner      TYPE but000-partner,
           partner_guid TYPE but000-partner_guid,
         END OF lty_but000,

         BEGIN OF lty_lfa1,
           lifnr TYPE lfa1-lifnr,
           stcd1 TYPE lfa1-stcd1,
           stcd3 TYPE lfa1-stcd3,
           stceg TYPE lfa1-stceg,
           kunnr TYPE lfa1-kunnr,
         END OF lty_lfa1,


         BEGIN OF lty_lfbk,
           lifnr TYPE lfbk-lifnr,
           banks TYPE tiban-banks,
           bankl TYPE tiban-bankl,
           bankn TYPE tiban-bankn,
           bkont TYPE tiban-bkont,
           bvtyp TYPE lfbk-bvtyp,
         END OF lty_lfbk,

         BEGIN OF lty_vend,
           partner_guid TYPE cvi_vend_link-partner_guid,
           vendor       TYPE cvi_vend_link-vendor,
         END OF lty_vend,

         BEGIN OF lty_but0bk,
           partner TYPE but0bk-partner,
           bkvid   TYPE but0bk-bkvid,
           banks   TYPE tiban-banks,
           bankl   TYPE tiban-bankl,
           bankn   TYPE tiban-bankn,
           bkont   TYPE tiban-bkont,
         END OF lty_but0bk.

  DATA: li_kna1          TYPE TABLE OF lty_kna1,
        li_knbk          TYPE TABLE OF lty_knbk,
        li_tiban         TYPE TABLE OF lty_tiban,
        li_cust          TYPE TABLE OF lty_cust,
        li_but000        TYPE TABLE OF lty_but000,
        li_lfa1          TYPE TABLE OF lty_lfa1,
        li_lfbk          TYPE TABLE OF lty_lfbk,
        li_vend          TYPE TABLE OF lty_vend,
        li_but0bk        TYPE TABLE OF lty_but0bk,
        li_bankdetails   TYPE TABLE OF bapibus1006_bankdetails,
        li_return        TYPE TABLE OF bapiret2,
        lw_chequeo_p_log TYPE ty_chequeo_p_log,
        lw_tiban         TYPE lty_tiban,
        lw_lfa1          TYPE lty_lfa1,
        lw_lfbk          TYPE lty_lfbk,
        lw_vend          TYPE lty_vend,
        lw_kna1          TYPE lty_kna1,
        lw_knbk          TYPE lty_knbk,
        lw_but000        TYPE lty_but000,
        lw_cust          TYPE lty_cust,
        lw_but0bk        TYPE lty_but0bk.
*        lw_bankdetails   TYPE bapibus1006_bankdetails,
*        lv_partner       TYPE bapibus1006_head-bpartner.

  CLEAR: i_chequeo_p_log[], li_kna1[], li_knbk[], li_tiban[], li_cust[],
          li_but000[], li_lfa1[], li_lfbk[], li_vend[], li_but0bk[],
          li_bankdetails[], li_return[], lw_chequeo_p_log, lw_tiban,
          lw_lfa1, lw_lfbk, lw_vend, lw_kna1, lw_knbk, lw_but000, lw_cust.
*         lw_bankdetails, lv_partner.

* Obtenemos los datos de los clientes, y su bp correspondiente en el caso de existir
  SELECT kunnr stcd1 stcd3 stceg lifnr                 "#EC CI_NOWHERE.
    FROM kna1
    INTO TABLE li_kna1.
  IF sy-subrc EQ 0.
    SELECT kunnr banks bankl bankn
            bkont bvtyp
      FROM knbk
      INTO TABLE li_knbk
      FOR ALL ENTRIES IN li_kna1
      WHERE kunnr EQ li_kna1-kunnr.
    IF sy-subrc EQ 0.
      SORT li_knbk BY banks bankl
                      bankn bkont.

      SELECT banks bankl bankn
              bkont iban
        FROM tiban
        INTO TABLE li_tiban
        FOR ALL ENTRIES IN li_knbk
        WHERE banks EQ li_knbk-banks
          AND bankl EQ li_knbk-bankl
          AND bankn EQ li_knbk-bankn
          AND bkont EQ li_knbk-bkont.
      IF sy-subrc EQ 0.
        SORT li_tiban BY banks bankl
                          bankn bkont.
      ENDIF.

      SELECT partner_guid customer
        FROM cvi_cust_link
        INTO TABLE li_cust
          FOR ALL ENTRIES IN li_kna1
        WHERE customer EQ li_kna1-kunnr.
      IF sy-subrc EQ 0.
        SELECT partner partner_guid
          FROM but000
          INTO TABLE li_but000
          FOR ALL ENTRIES IN li_cust
          WHERE partner_guid EQ li_cust-partner_guid.
        IF sy-subrc EQ 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Obtenemos los datos de los proveedores, y su bp correspondiente en el caso de existir
  SELECT lifnr stcd1 stcd3 stceg kunnr                 "#EC CI_NOWHERE.
    FROM lfa1
    INTO TABLE li_lfa1.
  IF sy-subrc EQ 0.
    SELECT lifnr banks bankl bankn
            bkont bvtyp
      FROM lfbk
      INTO TABLE li_lfbk
      FOR ALL ENTRIES IN li_lfa1
      WHERE lifnr EQ li_lfa1-lifnr.
    IF sy-subrc EQ 0.
      SORT li_lfbk BY banks bankl bankn bkont.

      SELECT banks bankl bankn bkont iban
        FROM tiban
        APPENDING TABLE li_tiban
        FOR ALL ENTRIES IN li_lfbk
        WHERE banks EQ li_lfbk-banks
          AND bankl EQ li_lfbk-bankl
          AND bankn EQ li_lfbk-bankn
          AND bkont EQ li_lfbk-bkont.
      IF sy-subrc EQ 0.
        SORT li_tiban BY banks bankl bankn bkont.
      ENDIF.

      SELECT partner_guid vendor
        FROM cvi_vend_link
        INTO TABLE li_vend
          FOR ALL ENTRIES IN li_lfa1
        WHERE vendor EQ li_lfa1-lifnr.
      IF sy-subrc EQ 0.
        SELECT partner partner_guid
          FROM but000
          APPENDING TABLE li_but000
          FOR ALL ENTRIES IN li_vend
          WHERE partner_guid EQ li_vend-partner_guid.
        IF sy-subrc EQ 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Finalmente obtenemos los correspondientes datos de cada cuenta bancaria
  IF li_but000 IS NOT INITIAL.
    SELECT partner bkvid banks
            bankl   bankn bkont
      FROM but0bk
      INTO TABLE li_but0bk
        FOR ALL ENTRIES IN li_but000
      WHERE partner EQ li_but000-partner.
    IF sy-subrc EQ 0.
      SORT li_but0bk BY partner.
    ENDIF.
  ENDIF.

  PERFORM f_progreso USING 60 TEXT-049.

  SORT li_tiban BY banks bankl bankn bkont.
  SORT li_cust  BY partner_guid.
  SORT li_kna1  BY kunnr.
  SORT li_knbk  BY kunnr banks bankl bankn bkont.
  SORT li_lfbk  BY lifnr banks bankl bankn bkont.
  SORT li_vend  BY partner_guid.
  SORT li_lfa1  BY lifnr.

* Ordenamos las correspondientes tablas internas para la correcta búsqueda de datos
  LOOP AT li_but000 INTO lw_but000.

*   Rellenamos los campos referentes al BP
*    lv_partner = lw_but000-partner.
*
*    CALL FUNCTION c_bapi_bupa
*      EXPORTING
*        businesspartner = lv_partner
*      TABLES
*        bankdetails     = li_bankdetails
*        return          = li_return.

*   Comprobamos que existan cuentas bancarias para el BP y rellenamos dichos campos.
*    READ TABLE li_return TRANSPORTING NO FIELDS
*      WITH KEY type = char_e.
*    IF sy-subrc NE 0.
*     Rellenamos un registro por cada cuenta bancaria
*      LOOP AT li_bankdetails INTO lw_bankdetails.
    LOOP AT li_but0bk INTO lw_but0bk
      WHERE partner EQ lw_but000-partner.

      CLEAR lw_chequeo_p_log.

*     Rellenamos los campos referentes al BP
      lw_chequeo_p_log-partner      = lw_but000-partner. "lv_partner.
      lw_chequeo_p_log-bankdetailid = lw_but0bk-bkvid. "lw_bankdetails-bankdetailid.

      READ TABLE li_tiban INTO lw_tiban
        WITH KEY banks = lw_but0bk-banks "lw_bankdetails-bank_ctry
                  bankl = lw_but0bk-bankl "lw_bankdetails-bank_key
                  bankn = lw_but0bk-bankn "lw_bankdetails-bank_acct
                  bkont = lw_but0bk-bkont "lw_bankdetails-ctrl_key.
                  BINARY SEARCH.
      IF sy-subrc EQ 0.
        lw_chequeo_p_log-banks = lw_but0bk-banks. "lw_bankdetails-bank_ctry.
        lw_chequeo_p_log-bankl = lw_but0bk-bankl. "lw_bankdetails-bank_key.
        lw_chequeo_p_log-bankn = lw_but0bk-bankn. "lw_bankdetails-bank_acct.
        lw_chequeo_p_log-bkont = lw_but0bk-bkont. "lw_bankdetails-ctrl_key.
        lw_chequeo_p_log-iban  = lw_tiban-iban.
      ENDIF.

*     Comprobamos que el BP esté asociado a un cliente y rellenamos dichos campos
      READ TABLE li_cust INTO lw_cust
        WITH KEY partner_guid = lw_but000-partner_guid
          BINARY SEARCH.
      IF sy-subrc EQ 0.
        READ TABLE li_kna1 INTO lw_kna1
          WITH KEY kunnr = lw_cust-customer
            BINARY SEARCH.
        IF sy-subrc EQ 0
          AND lw_kna1 IS NOT INITIAL.
          lw_chequeo_p_log-kunnr = lw_kna1-kunnr.
          IF lw_kna1-stcd1 IS NOT INITIAL.
            lw_chequeo_p_log-nif = lw_kna1-stcd1.
          ELSEIF lw_kna1-stcd3 IS NOT INITIAL.
            lw_chequeo_p_log-nif = lw_kna1-stcd3.
          ELSEIF lw_kna1-stceg IS NOT INITIAL.
            lw_chequeo_p_log-nif = lw_kna1-stceg.
          ENDIF.

*         Buscamos su iban y su identificador
          READ TABLE li_knbk INTO lw_knbk
            WITH KEY kunnr = lw_kna1-kunnr
                      banks = lw_but0bk-banks "lw_bankdetails-bank_ctry
                      bankl = lw_but0bk-bankl "lw_bankdetails-bank_key
                      bankn = lw_but0bk-bankn "lw_bankdetails-bank_acct
                      bkont = lw_but0bk-bkont "lw_bankdetails-ctrl_key
              BINARY SEARCH.
          IF sy-subrc EQ 0.
            READ TABLE li_tiban INTO lw_tiban
              WITH KEY banks = lw_knbk-banks
                        bankl = lw_knbk-bankl
                        bankn = lw_knbk-bankn
                        bkont = lw_knbk-bkont
                        BINARY SEARCH.
            IF sy-subrc EQ 0.
              lw_chequeo_p_log-iban_k           = lw_tiban-iban.
            ENDIF.

            lw_chequeo_p_log-banks_k        = lw_knbk-banks.
            lw_chequeo_p_log-bankl_k        = lw_knbk-bankl.
            lw_chequeo_p_log-bankn_k        = lw_knbk-bankn.
            lw_chequeo_p_log-bkont_k        = lw_knbk-bkont.
            lw_chequeo_p_log-bankdetailid_k = lw_knbk-bvtyp.
          ENDIF.

*         Comprobamos que esté asociado también a un proveedor y rellenamos
*         los campos referentes al proveedor asociado
          IF lw_kna1-lifnr IS NOT INITIAL.
            READ TABLE li_lfa1 INTO lw_lfa1
              WITH KEY lifnr = lw_kna1-lifnr
                BINARY SEARCH.
            IF sy-subrc EQ 0.
              lw_chequeo_p_log-asociado = 'SI'.
              lw_chequeo_p_log-lifnr    = lw_lfa1-lifnr.

*             Buscamos su iban y su identificador
              READ TABLE li_lfbk INTO lw_lfbk
                WITH KEY lifnr = lw_lfa1-lifnr
                          banks = lw_but0bk-banks "lw_bankdetails-bank_ctry
                          bankl = lw_but0bk-bankl "lw_bankdetails-bank_key
                          bankn = lw_but0bk-bankn "lw_bankdetails-bank_acct
                          bkont = lw_but0bk-bkont "lw_bankdetails-ctrl_key.
                  BINARY SEARCH.
              IF sy-subrc EQ 0.
                READ TABLE li_tiban INTO lw_tiban
                  WITH KEY banks = lw_lfbk-banks
                            bankl = lw_lfbk-bankl
                            bankn = lw_lfbk-bankn
                            bkont = lw_lfbk-bkont
                            BINARY SEARCH.
                IF sy-subrc EQ 0.
                  lw_chequeo_p_log-iban_l          = lw_tiban-iban.
                ENDIF.

                lw_chequeo_p_log-banks_l = lw_lfbk-banks.
                lw_chequeo_p_log-bankl_l = lw_lfbk-bankl.
                lw_chequeo_p_log-bankn_l = lw_lfbk-bankn.
                lw_chequeo_p_log-bkont_l = lw_lfbk-bkont.
                lw_chequeo_p_log-bankdetailid_l   = lw_lfbk-bvtyp.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
*       En caso de no estar asociado a un cliente comprobamos que el BP esté asociado a un proveedor y rellenamos dichos campos
        READ TABLE li_vend INTO lw_vend
          WITH KEY partner_guid = lw_but000-partner_guid
            BINARY SEARCH.
        IF sy-subrc EQ 0.
          READ TABLE li_lfa1 INTO lw_lfa1
            WITH KEY lifnr = lw_vend-vendor
              BINARY SEARCH.
          IF sy-subrc EQ 0.
            lw_chequeo_p_log-lifnr = lw_lfa1-lifnr.
            IF lw_lfa1-stcd1 IS NOT INITIAL.
              lw_chequeo_p_log-nif = lw_lfa1-stcd1.
            ELSEIF lw_lfa1-stcd3 IS NOT INITIAL.
              lw_chequeo_p_log-nif = lw_lfa1-stcd3.
            ELSEIF lw_lfa1-stceg IS NOT INITIAL.
              lw_chequeo_p_log-nif = lw_lfa1-stceg.
            ENDIF.

*           Buscamos su iban y su identificador
            READ TABLE li_lfbk INTO lw_lfbk
              WITH KEY lifnr = lw_lfa1-lifnr
                        banks = lw_but0bk-banks "lw_bankdetails-bank_ctry
                        bankl = lw_but0bk-bankl "lw_bankdetails-bank_key
                        bankn = lw_but0bk-bankn "lw_bankdetails-bank_acct
                        bkont = lw_but0bk-bkont. "lw_bankdetails-ctrl_key.
            IF sy-subrc EQ 0.
              READ TABLE li_tiban INTO lw_tiban
                WITH KEY banks = lw_lfbk-banks
                          bankl = lw_lfbk-bankl
                          bankn = lw_lfbk-bankn
                          bkont = lw_lfbk-bkont
                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lw_chequeo_p_log-iban_l          = lw_tiban-iban.
              ENDIF.

              lw_chequeo_p_log-banks_l = lw_lfbk-banks.
              lw_chequeo_p_log-bankl_l = lw_lfbk-bankl.
              lw_chequeo_p_log-bankn_l = lw_lfbk-bankn.
              lw_chequeo_p_log-bkont_l = lw_lfbk-bkont.
              lw_chequeo_p_log-bankdetailid_l   = lw_lfbk-bvtyp.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lw_chequeo_p_log-iban   IS NOT INITIAL OR
          lw_chequeo_p_log-iban_k IS NOT INITIAL OR
          lw_chequeo_p_log-iban_l IS NOT INITIAL.
*       Insertamos el registro de cada cuenta bancaria en nuestro ALV
        APPEND lw_chequeo_p_log TO i_chequeo_p_log.
      ENDIF.
    ENDLOOP.
*    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_seleccion_chequeo_pagos
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_10B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_10b .

  DATA: lw_kna1 TYPE ty_kna1,
        lw_lfa1 TYPE ty_lfa1.

  CLEAR: i_stcd1_log[].
  REFRESH: i_kna1, i_lfa1.

*   Seleccionamos de KNA1.
  IF i_kna1[] IS INITIAL.
    SELECT kunnr land1 name1 name2 pstlz regio adrnr ktokd lifnr loevm stcd1 stcd2 stceg stcd3 stcd4 stcd5 anred
        FROM kna1
        INTO TABLE i_kna1
        WHERE kunnr IN s_kunnr
          AND lifnr IN s_lifnr
          AND ( stcd1 IN s_stcd1
          OR   stceg IN s_stcd1
          OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

*   Seleccionamos de LFA1.
  IF i_lfa1[] IS INITIAL.
    SELECT lifnr land1 name1 name2 pstlz regio adrnr ktokk kunnr loevm stcd1 stcd2 stceg stcd3 stcd4 stcd5 anred
        FROM lfa1
        INTO TABLE i_lfa1
        WHERE lifnr IN s_lifnr
          AND kunnr IN s_kunnr
          AND ( stcd1 IN s_stcd1
          OR   stceg IN s_stcd1
          OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

* Comprobamos.
  LOOP AT i_kna1 INTO lw_kna1 WHERE stcd1 IS NOT INITIAL.
    CALL FUNCTION c_stcd1
      EXPORTING
        country         = lw_kna1-land1
        tax_code_1      = lw_kna1-stcd1
      EXCEPTIONS
        not_valid       = 1
        different_fprcd = 2.
    IF sy-subrc NE 0.
*       Añadimos al log.
      PERFORM f_add_log_10b USING lw_kna1-kunnr lw_kna1-stcd1 TEXT-057 lw_kna1-land1.
    ENDIF.
  ENDLOOP.

  LOOP AT i_lfa1 INTO lw_lfa1 WHERE stcd1 IS NOT INITIAL.
    CALL FUNCTION c_stcd1
      EXPORTING
        country         = lw_lfa1-land1
        tax_code_1      = lw_lfa1-stcd1
      EXCEPTIONS
        not_valid       = 1
        different_fprcd = 2.
    IF sy-subrc NE 0.
*       Añadimos al log.
      PERFORM f_add_log_10b USING lw_lfa1-lifnr lw_lfa1-stcd1 TEXT-058 lw_lfa1-land1.
    ENDIF.
  ENDLOOP.

  IF i_stcd1_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 10 TEXT-055 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 10 TEXT-055 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    " F_CHEQUEO_PRUEBA_10B
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_11B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_11b .

  DATA: lw_kna1 TYPE ty_kna1,
        lw_lfa1 TYPE ty_lfa1,
        lw_t005 TYPE ty_t005,
        lt_t005 TYPE TABLE OF ty_t005.

  CLEAR: i_pstlz_log[].

  IF i_kna1[] IS INITIAL.
*   Seleccionamos de KNA1.
    SELECT kunnr land1 name1 name2 pstlz regio adrnr ktokd lifnr loevm stcd1 stcd2 stceg stcd3 stcd4 stcd5 anred
      FROM kna1
      INTO TABLE i_kna1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_lfa1[] IS INITIAL.
*   Seleccionamos de LFA1.
    SELECT lifnr land1 name1 name2 pstlz regio adrnr ktokk kunnr loevm stcd1 stcd2 stceg stcd3 stcd4 stcd5 anred
      FROM lfa1
      INTO TABLE i_lfa1
      WHERE lifnr IN s_lifnr
        AND kunnr IN s_kunnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  SELECT land1 xplzs
    FROM t005
    INTO TABLE lt_t005.
  IF sy-subrc EQ 0.
  ENDIF.

* Comprobamos.
  LOOP AT i_kna1 INTO lw_kna1 WHERE pstlz IS INITIAL.
    READ TABLE lt_t005 INTO lw_t005 WITH KEY land1 = lw_kna1-land1.
    IF sy-subrc = 0.
      IF lw_t005-xplzs = 'X' AND lw_kna1-pstlz IS INITIAL.
*        Añadimos al log.
        PERFORM f_add_log_11b USING lw_kna1-kunnr TEXT-060 lw_kna1-land1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT i_lfa1 INTO lw_lfa1 WHERE pstlz IS INITIAL.
    READ TABLE lt_t005 INTO lw_t005 WITH KEY land1 = lw_lfa1-land1.
    IF sy-subrc = 0.
      IF lw_t005-xplzs = 'X' AND lw_lfa1-pstlz IS INITIAL.
*        Añadimos al log.
        PERFORM f_add_log_11b USING lw_lfa1-lifnr TEXT-061 lw_lfa1-land1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF i_pstlz_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 11 TEXT-056 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 11 TEXT-056 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    " F_CHEQUEO_PRUEBA_11B
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_10B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TARGET  text
*      -->P_STCD1  text
*      -->P_MENSAJE  text
*----------------------------------------------------------------------*
FORM f_add_log_10b  USING     p_target
                              p_stcd1
                              p_mensaje
                              p_land.

  DATA: lw_stcd1_log TYPE ty_stcd1_log.
  CLEAR lw_stcd1_log.

  lw_stcd1_log-target     = p_target.
  lw_stcd1_log-stcd1      = p_stcd1.
  lw_stcd1_log-comentario = p_mensaje.
  lw_stcd1_log-land1      = p_land.
  APPEND lw_stcd1_log TO i_stcd1_log.

ENDFORM.                    " F_ADD_LOG_10B
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_10B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_10b .

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_target      TEXT-035     char_l  19  space     space    space,
                                  'STCD1'       TEXT-059     char_l  35  space     space    space,
                                  c_comentario  TEXT-004     char_l  45  space     space    space,
                                  'LAND1'       'PAÍS'       char_l  45  space     space    space.

ENDFORM.                    " F_CARGAR_CATALOGO_10B
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_11B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TARGET  text
*      -->P_MENSAJE  text
*----------------------------------------------------------------------*
FORM f_add_log_11b  USING     p_target
                              p_mensaje
                              p_land.

  DATA: lw_pstlz_log TYPE ty_pstlz_log.
  CLEAR lw_pstlz_log.

  lw_pstlz_log-target     = p_target.
  lw_pstlz_log-comentario = p_mensaje.
  lw_pstlz_log-land1      = p_land.
  APPEND lw_pstlz_log TO i_pstlz_log.

ENDFORM.                    " F_ADD_LOG_11B
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_11B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_11b .

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_target      TEXT-035      char_l  19  space     space    space,
                                  c_comentario  TEXT-004      char_l  45  space     space    space,
                                  'LAND1'       'PAÍS'        char_l  45  space     space    space.

ENDFORM.                    " F_CARGAR_CATALOGO_11B
*&---------------------------------------------------------------------*
*&      Form  F_CHEQUEO_PRUEBA_12B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chequeo_prueba_12b .

  DATA: lw_kna1 TYPE ty_kna1,
        lw_lfa1 TYPE ty_lfa1.

  CLEAR: i_anred_log[].

  IF i_kna1[] IS INITIAL.
*   Seleccionamos de KNA1.
    SELECT kunnr land1 name1 name2 pstlz regio adrnr ktokd lifnr loevm stcd1 stcd2 stceg stcd3 stcd4 stcd5 anred
      FROM kna1
      INTO TABLE i_kna1
      WHERE kunnr IN s_kunnr
        AND lifnr IN s_lifnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

  IF i_lfa1[] IS INITIAL.
*   Seleccionamos de LFA1.
    SELECT lifnr land1 name1 name2 pstlz regio adrnr ktokk kunnr loevm stcd1 stcd2 stceg stcd3 stcd4 stcd5 anred
      FROM lfa1
      INTO TABLE i_lfa1
      WHERE lifnr IN s_lifnr
        AND kunnr IN s_kunnr
        AND ( stcd1 IN s_stcd1
        OR   stceg IN s_stcd1
        OR   stcd3 IN s_stcd1 ).
    IF sy-subrc EQ 0.
    ENDIF.
  ENDIF.

* Comprobamos.
  LOOP AT i_kna1 INTO lw_kna1.
    CASE lw_kna1-anred.
      WHEN 'Señor' OR 'Señora' OR 'Señor y señora' OR 'Sr.' OR 'Sra.'.
        PERFORM f_add_log_12b USING lw_kna1-kunnr TEXT-063.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.


  LOOP AT i_lfa1 INTO lw_lfa1.
    CASE lw_lfa1-anred.
      WHEN 'Señor' OR 'Señora' OR 'Señor y señora' OR 'Sr.' OR 'Sra.'.
        PERFORM f_add_log_12b USING lw_lfa1-lifnr TEXT-063.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  IF i_anred_log[] IS NOT INITIAL.
*   Añadimos ERROR al ALV principal.
    PERFORM f_log_principal USING 12 TEXT-062 TEXT-013 icon_system_cancel.
  ELSE.
*   Añadimos al ALV principal.
    PERFORM f_log_principal USING 12 TEXT-062 TEXT-030 icon_system_okay.
  ENDIF.

ENDFORM.                    " F_CHEQUEO_PRUEBA_12B
*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO_12B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cargar_catalogo_12b .

  CLEAR: i_catalogo[].

  PERFORM f_agregar_campos USING: c_target      TEXT-035     char_l  19  space     space    space,
                                  c_comentario  TEXT-004     char_l  45  space     space    space.

ENDFORM.                    " F_CARGAR_CATALOGO_12B
*&---------------------------------------------------------------------*
*&      Form  F_ADD_LOG_12B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TARGET  text
*      -->P_MENSAJE  text
*----------------------------------------------------------------------*
FORM f_add_log_12b  USING    p_target
                              p_mensaje.

  DATA: lw_anred_log TYPE ty_anred_log.
  CLEAR lw_anred_log.

  lw_anred_log-target     = p_target.
  lw_anred_log-comentario = p_mensaje.
  APPEND lw_anred_log TO i_anred_log.

ENDFORM.                    " F_ADD_LOG_12B
