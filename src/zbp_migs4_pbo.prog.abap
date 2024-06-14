*&---------------------------------------------------------------------*
*&  Include           ZBP_MIGS4_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'Z_STATUS_0100'.
  SET TITLEBAR  'Z_TITULO'.
ENDMODULE.                    "status_0100 OUTPUT
*----------------------------------------------------------------------*
*  MODULE pes1_active_tab_set OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE pes1_active_tab_set OUTPUT.
  pes1-activetab = g_pes1-pressed_tab.
  CASE g_pes1-pressed_tab.
    WHEN c_pes1-tab1.
      g_pes1-subscreen = '0101'.
    WHEN c_pes1-tab2.
      g_pes1-subscreen = '0102'.
    WHEN c_pes1-tab3.
      g_pes1-subscreen = '0103'.
    WHEN c_pes1-tab4.
      g_pes1-subscreen = '0104'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                    "pes1_active_tab_set OUTPUT
