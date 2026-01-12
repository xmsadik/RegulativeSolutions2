  METHOD change_invoice_common_item.
    CHECK mt_changed_items IS NOT INITIAL.
    DATA: lt_additional_items TYPE STANDARD TABLE OF zif_etr_common_ubl21=>invoicelinetype,
          ls_additional_item  TYPE zif_etr_common_ubl21=>invoicelinetype,
          lv_ratio            TYPE p DECIMALS 5,
          lv_index            TYPE i.

    lv_index = lines( ms_invoice_ubl-invoiceline ).
    LOOP AT ms_invoice_ubl-invoiceline ASSIGNING FIELD-SYMBOL(<ls_invoice_line>) .
      READ TABLE mt_changed_items
        INTO DATA(ls_changed_item)
        WITH KEY linid = <ls_invoice_line>-id-content.
      CHECK sy-subrc = 0.

      IF ls_changed_item-splqt IS NOT INITIAL AND
         <ls_invoice_line>-invoicedquantity-content = ls_changed_item-menge AND
         ls_changed_item-splqt < ls_changed_item-menge.

        lv_ratio = ls_changed_item-splqt / ls_changed_item-menge.

        CLEAR ls_additional_item.
        ls_additional_item = <ls_invoice_line>.
        lv_index += 1.
        ls_additional_item-id-content = lv_index.

        ls_additional_item-invoicedquantity-content = ls_changed_item-splqt.
        <ls_invoice_line>-invoicedquantity-content -= ls_changed_item-splqt.

        ls_additional_item-lineextensionamount-content = <ls_invoice_line>-lineextensionamount-content * lv_ratio.
        <ls_invoice_line>-lineextensionamount-content -= ls_additional_item-lineextensionamount-content.

        ls_additional_item-price-priceamount-content = ls_additional_item-lineextensionamount-content / ls_additional_item-invoicedquantity-content.
        <ls_invoice_line>-price-priceamount-content = <ls_invoice_line>-lineextensionamount-content / <ls_invoice_line>-invoicedquantity-content.

        ls_additional_item-taxtotal-taxamount-content = <ls_invoice_line>-taxtotal-taxamount-content * lv_ratio.
        <ls_invoice_line>-taxtotal-taxamount-content -= ls_additional_item-taxtotal-taxamount-content.
        LOOP AT ls_additional_item-taxtotal-taxsubtotal ASSIGNING FIELD-SYMBOL(<ls_taxsubtotal_additional>).
          READ TABLE <ls_invoice_line>-taxtotal-taxsubtotal
            ASSIGNING FIELD-SYMBOL(<ls_taxsubtotal>)
            WITH KEY taxcategory-taxscheme-taxtypecode-content = <ls_taxsubtotal_additional>-taxcategory-taxscheme-taxtypecode-content.
          CHECK sy-subrc = 0.
          <ls_taxsubtotal_additional>-taxamount-content = <ls_taxsubtotal>-taxamount-content * lv_ratio.
          <ls_taxsubtotal>-taxamount-content -= <ls_taxsubtotal_additional>-taxamount-content.
          <ls_taxsubtotal_additional>-taxableamount-content = <ls_taxsubtotal>-taxableamount-content * lv_ratio.
          <ls_taxsubtotal>-taxableamount-content -= <ls_taxsubtotal_additional>-taxableamount-content.
        ENDLOOP.

        READ TABLE ls_additional_item-withholdingtaxtotal
          ASSIGNING FIELD-SYMBOL(<ls_taxtotal_additional>)
          INDEX 1.
        IF sy-subrc = 0.
          READ TABLE <ls_invoice_line>-withholdingtaxtotal
            ASSIGNING FIELD-SYMBOL(<ls_taxtotal>)
            INDEX 1.

          IF sy-subrc = 0.
            <ls_taxtotal_additional>-taxamount-content = <ls_taxtotal>-taxamount-content * lv_ratio.
            <ls_taxtotal>-taxamount-content -= <ls_taxtotal_additional>-taxamount-content.
            LOOP AT <ls_taxtotal_additional>-taxsubtotal ASSIGNING <ls_taxsubtotal_additional>.
              READ TABLE <ls_taxtotal>-taxsubtotal
                ASSIGNING <ls_taxsubtotal>
                WITH KEY taxcategory-taxscheme-taxtypecode-content = <ls_taxsubtotal_additional>-taxcategory-taxscheme-taxtypecode-content.
              CHECK sy-subrc = 0.
              <ls_taxsubtotal_additional>-taxamount-content = <ls_taxsubtotal>-taxamount-content * lv_ratio.
              <ls_taxsubtotal>-taxamount-content -= <ls_taxsubtotal_additional>-taxamount-content.
              <ls_taxsubtotal_additional>-taxableamount-content = <ls_taxsubtotal>-taxableamount-content * lv_ratio.
              <ls_taxsubtotal>-taxableamount-content -= <ls_taxsubtotal_additional>-taxableamount-content.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_changed_item-selii <> <ls_invoice_line>-item-sellersitemidentification-id-content.
        <ls_invoice_line>-item-sellersitemidentification-id-content = ls_changed_item-selii.
      ENDIF.
      IF ls_changed_item-buyii <> <ls_invoice_line>-item-buyersitemidentification-id-content.
        <ls_invoice_line>-item-buyersitemidentification-id-content = ls_changed_item-buyii.
      ENDIF.
      IF ls_changed_item-manii <> <ls_invoice_line>-item-manufacturersitemidentificatio-id-content.
        <ls_invoice_line>-item-manufacturersitemidentificatio-id-content = ls_changed_item-manii.
      ENDIF.
      IF ls_changed_item-mdesc <> <ls_invoice_line>-item-name-content.
        <ls_invoice_line>-item-name-content = ls_changed_item-mdesc.
      ENDIF.
      IF ls_changed_item-descr <> <ls_invoice_line>-item-description-content.
        <ls_invoice_line>-item-description-content = ls_changed_item-descr.
      ENDIF.
      IF ls_changed_item-model <> <ls_invoice_line>-item-modelname-content.
        <ls_invoice_line>-item-modelname-content = ls_changed_item-model.
      ENDIF.
      IF ls_changed_item-brand <> <ls_invoice_line>-item-brandname-content.
        <ls_invoice_line>-item-brandname-content = ls_changed_item-brand.
      ENDIF.
      READ TABLE <ls_invoice_line>-note ASSIGNING FIELD-SYMBOL(<ls_note>) INDEX 1.
      IF sy-subrc = 0 AND <ls_note>-content <> ls_changed_item-inote.
        <ls_note>-content = ls_changed_item-inote.
      ENDIF.

      change_invoice_common_item_int(
        EXPORTING
          is_changed_item    = ls_changed_item
        CHANGING
          cs_existing_item   = <ls_invoice_line>
          cs_additional_item = ls_additional_item ).

      IF ls_additional_item IS NOT INITIAL.
        APPEND ls_additional_item TO lt_additional_items.
        CLEAR ls_additional_item.
      ENDIF.
    ENDLOOP.
    APPEND LINES OF lt_additional_items TO ms_invoice_ubl-invoiceline.
  ENDMETHOD.