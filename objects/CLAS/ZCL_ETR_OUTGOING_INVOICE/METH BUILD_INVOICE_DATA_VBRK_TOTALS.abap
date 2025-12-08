  METHOD build_invoice_data_vbrk_totals.
    LOOP AT ms_invoice_ubl-invoiceline INTO DATA(ls_invoice_line).
      ms_invoice_ubl-legalmonetarytotal-lineextensionamount-content += ls_invoice_line-lineextensionamount-content.
      LOOP AT ls_invoice_line-allowancecharge INTO DATA(ls_allowance_charge).
        IF ls_allowance_charge-chargeindicator-content = 'false'.
          ms_invoice_ubl-legalmonetarytotal-allowancetotalamount-content += ls_allowance_charge-amount-content.
          ms_invoice_ubl-legalmonetarytotal-lineextensionamount-content += ls_allowance_charge-amount-content.
        ELSE.
          ms_invoice_ubl-legalmonetarytotal-chargetotalamount-content += ls_allowance_charge-amount-content.
          ms_invoice_ubl-legalmonetarytotal-lineextensionamount-content -= ls_allowance_charge-amount-content.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    build_invoice_data_vbrk_tax( ).

    ms_invoice_ubl-legalmonetarytotal-lineextensionamount-currencyid = ms_billing_data-vbrk-waerk.
    ms_invoice_ubl-legalmonetarytotal-taxexclusiveamount-content = ms_billing_data-vbrk-netwr.
    ms_invoice_ubl-legalmonetarytotal-taxexclusiveamount-currencyid = ms_billing_data-vbrk-waerk.
    ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content = ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content + ms_billing_data-vbrk-netwr.
    ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-currencyid = ms_billing_data-vbrk-waerk.
    IF ms_document-invty NE 'IHRACKAYIT'.
      ms_invoice_ubl-legalmonetarytotal-payableamount-content = ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content.
      LOOP AT ms_invoice_ubl-withholdingtaxtotal INTO DATA(ls_tax_total).
        ms_invoice_ubl-legalmonetarytotal-payableamount-content = ms_invoice_ubl-legalmonetarytotal-payableamount-content - ls_tax_total-taxamount-content.
      ENDLOOP.
    ELSE.
      ms_invoice_ubl-legalmonetarytotal-payableamount-content = ms_billing_data-vbrk-netwr.
    ENDIF.
    ms_invoice_ubl-legalmonetarytotal-payableamount-currencyid = ms_billing_data-vbrk-waerk.
    IF ms_invoice_ubl-legalmonetarytotal-allowancetotalamount-content IS NOT INITIAL.
      ms_invoice_ubl-legalmonetarytotal-allowancetotalamount-currencyid = ms_billing_data-vbrk-waerk.
    ENDIF.
    IF ms_invoice_ubl-legalmonetarytotal-chargetotalamount-content IS NOT INITIAL.
      ms_invoice_ubl-legalmonetarytotal-chargetotalamount-currencyid = ms_billing_data-vbrk-waerk.
    ENDIF.
  ENDMETHOD.