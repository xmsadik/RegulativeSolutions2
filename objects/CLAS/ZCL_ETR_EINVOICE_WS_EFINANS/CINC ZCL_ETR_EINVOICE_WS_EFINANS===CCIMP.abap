*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_invoice_user_partask DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES if_abap_parallel .
    METHODS constructor
      IMPORTING
        iv_users_xml TYPE string.
    METHODS get_result
      RETURNING
        VALUE(rt_result) TYPE zcl_etr_einvoice_ws=>mty_taxpayers_list.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mt_result TYPE zcl_etr_einvoice_ws=>mty_taxpayers_list.
    DATA ms_user_list TYPE zcl_etr_einvoice_ws_efinans=>mty_user_list.
ENDCLASS.

CLASS lcl_invoice_user_partask IMPLEMENTATION.

  METHOD if_abap_parallel~do.
    DATA ls_taxpayer TYPE zetr_t_inv_ruser.
    LOOP AT ms_user_list-efaturakayitlikullanici INTO DATA(ls_user).
      CLEAR ls_taxpayer.
      CASE ls_user-tip.
        WHEN 'Özel'.
          ls_taxpayer-txpty = 'OZEL'.
        WHEN OTHERS.
          ls_taxpayer-txpty = 'KAMU'.
      ENDCASE.
      IF ls_user-kayitzamani IS NOT INITIAL.
        ls_taxpayer-regdt = ls_user-kayitzamani(8).
        ls_taxpayer-regtm = ls_user-kayitzamani+8(6).
      ENDIF.
      ls_taxpayer-title = ls_user-unvan.
      ls_taxpayer-taxid = ls_user-vkntckn.
      IF ls_user-aktifetiket IS NOT INITIAL.
        LOOP AT ls_user-aktifetiket INTO DATA(ls_alias).
          ls_taxpayer-aliass = ls_alias-etiket.
          APPEND ls_taxpayer TO mt_result.
        ENDLOOP.
      ELSE.
        APPEND ls_taxpayer TO mt_result.
      ENDIF.
    ENDLOOP.
    CLEAR ms_user_list.
  ENDMETHOD.

  METHOD constructor.
    CALL TRANSFORMATION zetr_inv_userlist_efn
      SOURCE XML iv_users_xml
      RESULT efaturakayitlikullaniciliste = ms_user_list.
  ENDMETHOD.

  METHOD get_result.
    RETURN mt_result.
  ENDMETHOD.

ENDCLASS.