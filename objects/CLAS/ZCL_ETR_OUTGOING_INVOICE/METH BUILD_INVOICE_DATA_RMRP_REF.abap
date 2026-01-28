  METHOD build_invoice_data_rmrp_ref.
*    TYPES BEGIN OF mty_waybill_data.
*    TYPES refdoc_number TYPE belnr_d.
*    TYPES refdoc_ref TYPE xblnr.
*    TYPES refdoc_date TYPE datum.
*    TYPES END OF mty_waybill_data.
*    DATA lt_waybill_data TYPE TABLE OF mty_waybill_data.
*
*    lt_waybill_data = CORRESPONDING #( ms_invrec_data-itemdata ).
*    SORT lt_waybill_data BY refdoc_number.
*    DELETE ADJACENT DUPLICATES FROM lt_waybill_data COMPARING refdoc_number.
*    DELETE lt_waybill_data WHERE refdoc_number IS INITIAL.

*    IF lt_waybill_data IS NOT INITIAL.
*      LOOP AT lt_waybill_data INTO DATA(ls_waybill_data).
*        APPEND INITIAL LINE TO ms_invoice_ubl-despatchdocumentreference ASSIGNING FIELD-SYMBOL(<ls_desdoc_ref>).
*        IF ls_waybill_data-refdoc_ref IS NOT INITIAL.
*          <ls_desdoc_ref>-id-content = ls_waybill_data-refdoc_ref.
*        ELSE.
*          <ls_desdoc_ref>-id-content = ls_waybill_data-refdoc_number.
*        ENDIF.
*        CONCATENATE ls_waybill_data-refdoc_date+0(4)
*                    ls_waybill_data-refdoc_date+4(2)
*                    ls_waybill_data-refdoc_date+6(2)
*          INTO <ls_desdoc_ref>-issuedate-content
*          SEPARATED BY '-'.
*      ENDLOOP.
*    ELSE.
    LOOP AT ms_invrec_data-ekbe INTO DATA(ls_ekbe).
      CHECK ls_ekbe-vgabe = '1' AND ls_ekbe-menge IS NOT INITIAL.
*      READ TABLE ms_invrec_data-mseg
*        WITH TABLE KEY mblnr = ls_ekbe-belnr
*                       mjahr = ls_ekbe-gjahr
*                       zeile = ls_ekbe-buzei
*                       TRANSPORTING NO FIELDS.
*      CHECK sy-subrc IS INITIAL.

      APPEND INITIAL LINE TO ms_invoice_ubl-despatchdocumentreference ASSIGNING FIELD-SYMBOL(<ls_desdoc_ref>).
      IF ls_ekbe-xblnr IS NOT INITIAL.
        <ls_desdoc_ref>-id-content = ls_ekbe-xblnr.
      ELSE.
        <ls_desdoc_ref>-id-content = ls_ekbe-belnr.
      ENDIF.
      CONCATENATE ls_ekbe-budat+0(4)
                  ls_ekbe-budat+4(2)
                  ls_ekbe-budat+6(2)
        INTO <ls_desdoc_ref>-issuedate-content
        SEPARATED BY '-'.
    ENDLOOP.
*    ENDIF.

    SORT ms_invoice_ubl-despatchdocumentreference BY id-content.
    DELETE ADJACENT DUPLICATES FROM ms_invoice_ubl-despatchdocumentreference COMPARING id-content.
  ENDMETHOD.