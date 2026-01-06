  METHOD build_invoice_data_rmrp_totals.
    LOOP AT ms_invoice_ubl-invoiceline INTO DATA(ls_invoice_line).
      ms_invoice_ubl-legalmonetarytotal-lineextensionamount-content += ls_invoice_line-lineextensionamount-content.
      ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content += ls_invoice_line-lineextensionamount-content.
      ms_invoice_ubl-legalmonetarytotal-taxexclusiveamount-content += ls_invoice_line-lineextensionamount-content.
    ENDLOOP.

    build_invoice_data_rmrp_tax( ).
    fill_common_tax_totals( ).

    ms_invoice_ubl-legalmonetarytotal-lineextensionamount-currencyid = ms_invrec_data-headerdata-currency.
    ms_invoice_ubl-legalmonetarytotal-taxexclusiveamount-currencyid = ms_invrec_data-headerdata-currency.
    ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-currencyid = ms_invrec_data-headerdata-currency.
    ms_invoice_ubl-legalmonetarytotal-payableamount-content = ms_invrec_data-headerdata-gross_amnt.
    ms_invoice_ubl-legalmonetarytotal-payableamount-currencyid = ms_invrec_data-headerdata-currency.

    CASE ms_document-prfid.
      WHEN 'EABELGE'.
        LOOP AT ms_invoice_ubl-taxtotal INTO DATA(ls_tax_total).
          ms_invoice_ubl-legalmonetarytotal-payableamount-content -= ls_tax_total-taxamount-content.
          ms_invoice_ubl-legalmonetarytotal-taxexclusiveamount-content -= ls_tax_total-taxamount-content.
        ENDLOOP.
      WHEN OTHERS.
        LOOP AT ms_invoice_ubl-taxtotal INTO ls_tax_total.
          ms_invoice_ubl-legalmonetarytotal-taxinclusiveamount-content += ls_tax_total-taxamount-content.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.