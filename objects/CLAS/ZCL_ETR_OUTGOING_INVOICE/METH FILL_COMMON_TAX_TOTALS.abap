  METHOD fill_common_tax_totals.
    TYPES BEGIN OF ty_taxtotal.
    TYPES tax_code   TYPE string.
    TYPES tax_name   TYPE string.
    TYPES tax_rate   TYPE string.
    TYPES exp_code   TYPE string.
    TYPES exp_name   TYPE string.
    TYPES taxtotal  TYPE wrbtr_cs.
    TYPES taxamount  TYPE wrbtr_cs.
    TYPES tax_base   TYPE wrbtr_cs.
    TYPES witholding TYPE abap_boolean.
    TYPES END OF ty_taxtotal .
    DATA: lt_taxtotal TYPE TABLE OF ty_taxtotal,
          ls_taxtotal TYPE ty_taxtotal,
          lv_taxtotal TYPE wrbtr_cs,
          lv_wthtotal TYPE wrbtr_cs.

    LOOP AT ms_invoice_ubl-invoiceline INTO DATA(ls_invoice_line).
      lv_taxtotal += ls_invoice_line-taxtotal-taxamount-content.
      LOOP AT ls_invoice_line-taxtotal-taxsubtotal INTO DATA(ls_taxsubtotal).
        ls_taxtotal-tax_code  = ls_taxsubtotal-taxcategory-taxscheme-taxtypecode-content.
        ls_taxtotal-tax_name  = ls_taxsubtotal-taxcategory-taxscheme-name-content.
        ls_taxtotal-tax_rate  = ls_taxsubtotal-percent-content.
        ls_taxtotal-exp_code  = ls_taxsubtotal-taxcategory-taxexemptionreasoncode-content.
        ls_taxtotal-exp_name  = ls_taxsubtotal-taxcategory-taxexemptionreason-content.
        ls_taxtotal-taxamount = ls_taxsubtotal-taxamount-content.
        ls_taxtotal-taxtotal = ls_invoice_line-taxtotal-taxamount-content.
        ls_taxtotal-tax_base  = ls_taxsubtotal-taxableamount-content.
        COLLECT ls_taxtotal INTO lt_taxtotal.
        CLEAR ls_taxtotal.
      ENDLOOP.

      LOOP AT ls_invoice_line-withholdingtaxtotal INTO DATA(ls_line_taxtotal).
        lv_wthtotal += ls_line_taxtotal-taxamount-content.
        LOOP AT ls_line_taxtotal-taxsubtotal INTO ls_taxsubtotal.
          ls_taxtotal-tax_code  = ls_taxsubtotal-taxcategory-taxscheme-taxtypecode-content.
          ls_taxtotal-tax_name  = ls_taxsubtotal-taxcategory-taxscheme-name-content.
          ls_taxtotal-tax_rate  = ls_taxsubtotal-percent-content.
          ls_taxtotal-exp_code  = ls_taxsubtotal-taxcategory-taxexemptionreasoncode-content.
          ls_taxtotal-exp_name  = ls_taxsubtotal-taxcategory-taxexemptionreason-content.
          ls_taxtotal-taxamount = ls_taxsubtotal-taxamount-content.
          ls_taxtotal-taxtotal = ls_line_taxtotal-taxamount-content.
          ls_taxtotal-tax_base  = ls_taxsubtotal-taxableamount-content.
          ls_taxtotal-witholding = 'X'.
          COLLECT ls_taxtotal INTO lt_taxtotal.
          CLEAR ls_taxtotal.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    IF ms_invoice_ubl-taxtotal IS INITIAL AND ms_invoice_ubl-withholdingtaxtotal IS INITIAL.
      LOOP AT lt_taxtotal INTO ls_taxtotal.
        ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content = ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content + ls_taxtotal-taxamount.
        IF ls_taxtotal-witholding IS NOT INITIAL.
          IF ms_invoice_ubl-withholdingtaxtotal IS INITIAL.
            APPEND INITIAL LINE TO ms_invoice_ubl-withholdingtaxtotal ASSIGNING FIELD-SYMBOL(<ls_taxtotal>).
            <ls_taxtotal>-taxamount-content = lv_wthtotal.
            <ls_taxtotal>-taxamount-currencyid = ms_invoice_ubl-documentcurrencycode-content.
          ENDIF.
        ELSE.
          IF ms_invoice_ubl-taxtotal IS INITIAL.
            APPEND INITIAL LINE TO ms_invoice_ubl-taxtotal ASSIGNING <ls_taxtotal>.
            <ls_taxtotal>-taxamount-content = lv_taxtotal.
            <ls_taxtotal>-taxamount-currencyid = ms_invoice_ubl-documentcurrencycode-content.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO <ls_taxtotal>-taxsubtotal ASSIGNING FIELD-SYMBOL(<ls_taxsubtotal>).
        <ls_taxsubtotal>-taxcategory-taxscheme-name-content = ls_taxtotal-tax_name.
        <ls_taxsubtotal>-taxcategory-taxscheme-taxtypecode-content = ls_taxtotal-tax_code.
        <ls_taxsubtotal>-taxcategory-taxexemptionreasoncode-content = ls_taxtotal-exp_code.
        <ls_taxsubtotal>-taxcategory-taxexemptionreason-content = ls_taxtotal-exp_name.
        <ls_taxsubtotal>-taxableamount-content = ls_taxtotal-tax_base.
        <ls_taxsubtotal>-taxableamount-currencyid =  ms_invoice_ubl-documentcurrencycode-content.
        <ls_taxsubtotal>-percent-content = ls_taxtotal-tax_rate.
        <ls_taxsubtotal>-taxamount-content = ls_taxtotal-taxamount.
        <ls_taxsubtotal>-taxamount-currencyid =  ms_invoice_ubl-documentcurrencycode-content.
      ENDLOOP.
    ELSE.
      READ TABLE ms_invoice_ubl-taxtotal INTO DATA(ls_existing_taxtotal) INDEX 1.
      IF sy-subrc = 0 AND CONV wrbtr_cs( ls_existing_taxtotal-taxamount-content ) <> lv_taxtotal.
        LOOP AT ls_existing_taxtotal-taxsubtotal INTO DATA(ls_existing_subtotal).
          READ TABLE lt_taxtotal INTO ls_taxtotal
            WITH KEY tax_code = ls_existing_subtotal-taxcategory-taxscheme-taxtypecode-content
                     exp_code = ls_existing_subtotal-taxcategory-taxexemptionreasoncode-content
                     tax_rate = ls_existing_subtotal-percent-content
                     witholding = ''.
          CHECK sy-subrc = 0.
          DATA(lv_diff_amount) = CONV wrbtr_cs( ls_existing_subtotal-taxamount-content - ls_taxtotal-taxamount ).
          CHECK lv_diff_amount IS NOT INITIAL.
          LOOP AT ms_invoice_ubl-invoiceline ASSIGNING FIELD-SYMBOL(<ls_invoiceline>).
            LOOP AT <ls_invoiceline>-taxtotal-taxsubtotal ASSIGNING <ls_taxsubtotal>
              WHERE taxcategory-taxscheme-taxtypecode-content = ls_existing_subtotal-taxcategory-taxscheme-taxtypecode-content
                AND taxcategory-taxexemptionreasoncode-content = ls_existing_subtotal-taxcategory-taxexemptionreasoncode-content
                AND percent-content = ls_existing_subtotal-percent-content.
              IF lv_diff_amount < 0.
                CHECK CONV wrbtr_cs( <ls_taxsubtotal>-taxamount-content ) > abs( lv_diff_amount ).
              ENDIF.
              <ls_taxsubtotal>-taxamount-content = <ls_taxsubtotal>-taxamount-content - lv_diff_amount.
              CLEAR lv_diff_amount.
              EXIT.
            ENDLOOP.
            CHECK lv_diff_amount IS INITIAL.
            EXIT.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.