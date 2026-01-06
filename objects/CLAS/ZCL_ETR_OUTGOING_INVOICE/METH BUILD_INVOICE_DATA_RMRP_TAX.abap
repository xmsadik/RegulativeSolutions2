  METHOD build_invoice_data_rmrp_tax.
    CASE ms_document-prfid.
      WHEN 'EABELGE'.
        IF ms_invrec_data-bseg IS INITIAL.
          LOOP AT ms_invrec_data-withholdingtaxDATA INTO DATA(ls_invrec_wthtax).
            SELECT SINGLE *
              FROM zetr_t_taxmc
              WHERE kalsm = @ms_invrec_data-t001-kalsm
                AND mwskz = @ls_invrec_wthtax-WithholdingTaxCode
              INTO @DATA(ls_tax_match).
            CHECK sy-subrc = 0.

            SELECT SINGLE *
              FROM zetr_ddl_i_tax_types
              WHERE TaxType = @ls_tax_match-taxty
              INTO @DATA(ls_tax_data).

            APPEND INITIAL LINE TO ms_invoice_ubl-taxtotal ASSIGNING FIELD-SYMBOL(<ls_tax_total>).
            <ls_tax_total>-taxamount-currencyid = ms_invrec_data-headerdata-currency.
            <ls_tax_total>-taxamount-content = COND #( WHEN ls_invrec_wthtax-ManuallyEnteredWhldgTaxAmount IS NOT INITIAL
                                                         THEN ls_invrec_wthtax-ManuallyEnteredWhldgTaxAmount
                                                       ELSE ms_invrec_data-headerdata-gross_amnt * ls_tax_match-taxrt / 100 ).

            APPEND INITIAL LINE TO <ls_tax_total>-taxsubtotal ASSIGNING FIELD-SYMBOL(<ls_tax_subtotal>).
            <ls_tax_subtotal>-taxcategory-taxscheme-name-content = ls_tax_data-LongDescription.
            <ls_tax_subtotal>-taxcategory-taxscheme-taxtypecode-content = ls_tax_match-taxty.
            <ls_tax_subtotal>-taxableamount-content = COND #( WHEN ls_invrec_wthtax-WithholdingTaxBaseAmount IS NOT INITIAL
                                                                THEN ls_invrec_wthtax-WithholdingTaxBaseAmount
                                                              ELSE ms_invrec_data-headerdata-gross_amnt ).
            <ls_tax_subtotal>-taxableamount-currencyid = ms_invrec_data-headerdata-currency.
            <ls_tax_subtotal>-percent-content = ls_tax_match-taxrt.
            <ls_tax_subtotal>-taxamount-content = COND #( WHEN ls_invrec_wthtax-ManuallyEnteredWhldgTaxAmount IS NOT INITIAL
                                                            THEN ls_invrec_wthtax-ManuallyEnteredWhldgTaxAmount
                                                          ELSE ms_invrec_data-headerdata-gross_amnt * ls_tax_match-taxrt / 100 ).
            <ls_tax_subtotal>-taxamount-currencyid = ms_invrec_data-headerdata-currency.
          ENDLOOP.
        ELSE.
          LOOP AT ms_invrec_data-bseg INTO DATA(ls_bseg).
            SELECT SINGLE *
              FROM zetr_ddl_i_finance_accounts
              WHERE ChartOfAccounts = @ms_invrec_data-t001-ktopl
                AND GLAccount = @ls_bseg-hkont
              INTO @DATA(ls_finance_account).
            CHECK sy-subrc = 0.

            SELECT SINGLE *
              FROM zetr_ddl_i_tax_types
              WHERE TaxType = @ls_finance_account-TaxType
              INTO @ls_tax_data.

            APPEND INITIAL LINE TO ms_invoice_ubl-taxtotal ASSIGNING <ls_tax_total>.
            <ls_tax_total>-taxamount-currencyid = ms_invrec_data-headerdata-currency.
            <ls_tax_total>-taxamount-content = ls_bseg-wrbtr.

            APPEND INITIAL LINE TO <ls_tax_total>-taxsubtotal ASSIGNING <ls_tax_subtotal>.
            <ls_tax_subtotal>-taxcategory-taxscheme-name-content = ls_tax_data-LongDescription.
            <ls_tax_subtotal>-taxcategory-taxscheme-taxtypecode-content = ls_tax_data-TaxType.
            <ls_tax_subtotal>-taxableamount-content = ms_invrec_data-headerdata-gross_amnt.
            <ls_tax_subtotal>-taxableamount-currencyid = ms_invrec_data-headerdata-currency.
            <ls_tax_subtotal>-percent-content = ls_finance_account-taxrate.
            <ls_tax_subtotal>-taxamount-content = ls_bseg-wrbtr.
            <ls_tax_subtotal>-taxamount-currencyid = ms_invrec_data-headerdata-currency.
          ENDLOOP.
        ENDIF.
      WHEN OTHERS.
        LOOP AT ms_invrec_data-taxdata INTO DATA(ls_invrec_tax).
          SELECT SINGLE *
            FROM zetr_t_taxmc
            WHERE kalsm = @ms_invrec_data-t001-kalsm
              AND mwskz = @ls_invrec_tax-taxcode
            INTO @ls_tax_match.
          CHECK sy-subrc = 0.

          SELECT SINGLE *
            FROM zetr_ddl_i_tax_types
            WHERE TaxType = @ls_tax_match-taxty
            INTO @ls_tax_data.

          IF ms_invoice_ubl-taxtotal IS INITIAL.
            APPEND INITIAL LINE TO ms_invoice_ubl-taxtotal ASSIGNING <ls_tax_total>.
          ENDIF.
          <ls_tax_total>-taxamount-currencyid = ms_invrec_data-headerdata-currency.
          <ls_tax_total>-taxamount-content += ls_invrec_tax-TaxAmount.

          APPEND INITIAL LINE TO <ls_tax_total>-taxsubtotal ASSIGNING <ls_tax_subtotal>.
          <ls_tax_subtotal>-taxcategory-taxscheme-name-content = ls_tax_data-LongDescription.
          <ls_tax_subtotal>-taxcategory-taxscheme-taxtypecode-content = ls_tax_match-taxty.
          IF ls_invrec_tax-TaxAmount IS INITIAL.
            IF ms_document-taxex IS NOT INITIAL.
              SELECT SINGLE *
                FROM zetr_ddl_i_tax_exemptions
                WHERE ExemptionCode = @ms_document-taxex
                INTO @DATA(ls_tax_exemption).
              <ls_tax_subtotal>-taxcategory-taxexemptionreasoncode-content = ms_document-taxex.
            ELSE.
              SELECT SINGLE *
                FROM zetr_ddl_i_tax_exemptions
                WHERE ExemptionCode = @ls_tax_match-taxex
                INTO @ls_tax_exemption.
              <ls_tax_subtotal>-taxcategory-taxexemptionreasoncode-content = ls_tax_match-taxex.
            ENDIF.
            <ls_tax_subtotal>-taxcategory-taxexemptionreason-content = ls_tax_exemption-Description.
          ENDIF.
          <ls_tax_subtotal>-taxableamount-content = ls_invrec_tax-TaxBaseAmountInTransCrcy.
          <ls_tax_subtotal>-taxableamount-currencyid = ms_invrec_data-headerdata-currency.
          <ls_tax_subtotal>-percent-content = ls_tax_match-taxrt.
          <ls_tax_subtotal>-taxamount-content = ls_invrec_tax-TaxAmount.
          <ls_tax_subtotal>-taxamount-currencyid = ms_invrec_data-headerdata-currency.
        ENDLOOP.
    ENDCASE.

    IF ms_invoice_ubl-taxtotal IS INITIAL.
      fill_common_tax_totals( ).
    ENDIF.
  ENDMETHOD.