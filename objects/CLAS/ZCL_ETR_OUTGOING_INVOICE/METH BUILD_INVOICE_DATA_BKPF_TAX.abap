  METHOD build_invoice_data_bkpf_tax.
    LOOP AT ms_accdoc_data-bset INTO DATA(ls_bset).
      SELECT SINGLE *
        FROM zetr_t_taxmc
        WHERE kalsm = @ms_accdoc_data-t001-kalsm
          AND mwskz = @ls_bset-mwskz
        INTO @DATA(ls_tax_match).
      CHECK sy-subrc = 0.

      IF ls_tax_match-txtyp IS NOT INITIAL.
        SELECT SINGLE *
            FROM zetr_ddl_i_tax_types
            WHERE TaxType = @ls_tax_match-txtyp
            INTO @DATA(ls_parent_tax_data).
        SELECT SINGLE *
          FROM zetr_ddl_i_tax_types
          WHERE TaxType = @ls_tax_match-taxty
          INTO @DATA(ls_tax_data).

        IF ls_tax_data-TaxCategory = 'TEV' AND ( ls_bset-fwste IS NOT INITIAL OR ls_bset-hwste IS NOT INITIAL ) AND
                                               ( ls_bset-fwhol IS INITIAL AND ls_bset-hwhol IS INITIAL ).
          ls_bset-fwhol = ls_bset-fwste.
          ls_bset-hwhol = ls_bset-hwste.
          ls_bset-fwste = ls_bset-fwbas * ls_tax_match-txrtp / 100.
          ls_bset-hwste = ls_bset-hwbas * ls_tax_match-txrtp / 100.
          ls_bset-fwhol = ls_bset-fwste - ls_bset-fwhol.
          ls_bset-hwhol = ls_bset-hwste - ls_bset-hwhol.
        ENDIF.
      ELSE.
        SELECT SINGLE *
            FROM zetr_ddl_i_tax_types
            WHERE TaxType = @ls_tax_match-taxty
            INTO @ls_parent_tax_data.
        ls_tax_data = ls_parent_tax_data.
      ENDIF.

      IF ms_invoice_ubl-taxtotal IS INITIAL.
        APPEND INITIAL LINE TO ms_invoice_ubl-taxtotal ASSIGNING FIELD-SYMBOL(<ls_tax_total>).
      ELSE.
        READ TABLE ms_invoice_ubl-taxtotal ASSIGNING <ls_tax_total> INDEX 1.
      ENDIF.
      <ls_tax_total>-taxamount-currencyid = ms_accdoc_data-bkpf-waers.
      <ls_tax_total>-taxamount-content += COND #( WHEN ls_bset-fwste IS NOT INITIAL THEN ls_bset-fwste ELSE ls_bset-hwste ).

      DATA(lv_tax_type) = COND #( WHEN ls_tax_match-txtyp IS NOT INITIAL THEN ls_tax_match-txtyp
                                                                         ELSE ls_tax_match-taxty ).
      DATA(lv_tax_rate) = COND #( WHEN ls_tax_match-txtyp IS NOT INITIAL THEN ls_tax_match-txrtp
                                                                          ELSE ls_tax_match-taxrt ).
      IF ( ls_bset-fwste IS INITIAL AND ls_bset-hwste IS INITIAL ) OR ms_document-invty = 'IHRACKAYIT'.
        IF ms_document-taxex IS NOT INITIAL.
          SELECT SINGLE *
            FROM zetr_ddl_i_tax_exemptions
            WHERE ExemptionCode = @ms_document-taxex
            INTO @DATA(ls_tax_exemption).
        ELSE.
          SELECT SINGLE *
            FROM zetr_ddl_i_tax_exemptions
            WHERE ExemptionCode = @ls_tax_match-taxex
            INTO @ls_tax_exemption.
        ENDIF.
      ENDIF.

      READ TABLE <ls_tax_total>-taxsubtotal ASSIGNING  FIELD-SYMBOL(<ls_tax_subtotal>)
        WITH KEY taxcategory-taxscheme-taxtypecode-content = lv_tax_type
                 taxcategory-taxexemptionreasoncode-content = ls_tax_exemption-ExemptionCode
                 percent-content = lv_tax_rate.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO <ls_tax_total>-taxsubtotal ASSIGNING <ls_tax_subtotal>.
      ENDIF.
      <ls_tax_subtotal>-taxcategory-taxscheme-name-content = ls_parent_tax_data-LongDescription.
      <ls_tax_subtotal>-taxcategory-taxscheme-taxtypecode-content = lv_tax_type.
      <ls_tax_subtotal>-taxcategory-taxexemptionreasoncode-content = ls_tax_exemption-ExemptionCode.
      <ls_tax_subtotal>-taxcategory-taxexemptionreason-content = ls_tax_exemption-Description.
      <ls_tax_subtotal>-taxableamount-content += COND #( WHEN ls_bset-fwbas IS NOT INITIAL THEN ls_bset-fwbas ELSE ls_bset-hwbas ).
      <ls_tax_subtotal>-taxableamount-currencyid = ms_accdoc_data-bkpf-waers.
      <ls_tax_subtotal>-percent-content = lv_tax_rate.
      <ls_tax_subtotal>-taxamount-content += COND #( WHEN ls_bset-fwste IS NOT INITIAL THEN ls_bset-fwste ELSE ls_bset-hwste ).
      <ls_tax_subtotal>-taxamount-currencyid = ms_accdoc_data-bkpf-waers.

      IF ls_tax_data-TaxCategory = 'TEV'.
        IF ms_invoice_ubl-withholdingtaxtotal IS INITIAL.
          APPEND INITIAL LINE TO ms_invoice_ubl-withholdingtaxtotal ASSIGNING <ls_tax_total>.
        ELSE.
          READ TABLE ms_invoice_ubl-withholdingtaxtotal ASSIGNING <ls_tax_total> INDEX 1.
        ENDIF.
        <ls_tax_total>-taxamount-currencyid = ms_accdoc_data-bkpf-waers.
        <ls_tax_total>-taxamount-content += COND #( WHEN ls_bset-fwhol IS NOT INITIAL THEN ls_bset-fwhol ELSE ls_bset-hwhol ).

        APPEND INITIAL LINE TO <ls_tax_total>-taxsubtotal ASSIGNING <ls_tax_subtotal>.
        <ls_tax_subtotal>-taxcategory-taxscheme-name-content = ls_tax_data-LongDescription.
        <ls_tax_subtotal>-taxcategory-taxscheme-taxtypecode-content = ls_tax_match-taxty.
        <ls_tax_subtotal>-taxableamount-content = COND #( WHEN ls_bset-fwste IS NOT INITIAL THEN ls_bset-fwste ELSE ls_bset-hwste ).
        <ls_tax_subtotal>-taxableamount-currencyid = ms_accdoc_data-bkpf-waers.
        <ls_tax_subtotal>-percent-content = ls_tax_match-taxrt.
        <ls_tax_subtotal>-taxamount-content = COND #( WHEN ls_bset-fwhol IS NOT INITIAL THEN ls_bset-fwhol ELSE ls_bset-hwhol ).
        <ls_tax_subtotal>-taxamount-currencyid = ms_accdoc_data-bkpf-waers.
      ENDIF.

      CLEAR: ls_tax_exemption, lv_tax_type, lv_tax_rate.
    ENDLOOP.

    IF ms_invoice_ubl-taxtotal IS INITIAL.
      APPEND INITIAL LINE TO ms_invoice_ubl-taxtotal ASSIGNING <ls_tax_total>.
      <ls_tax_total>-taxamount-currencyid = ms_accdoc_data-bkpf-waers.
      <ls_tax_total>-taxamount-content = 0.

      APPEND INITIAL LINE TO <ls_tax_total>-taxsubtotal ASSIGNING <ls_tax_subtotal>.
      <ls_tax_subtotal>-taxcategory-taxscheme-name-content = 'KDV'.
      <ls_tax_subtotal>-taxcategory-taxscheme-taxtypecode-content = '0015'.

      IF ms_document-taxex IS NOT INITIAL.
        <ls_tax_subtotal>-taxcategory-taxexemptionreasoncode-content = ms_document-taxex.
        SELECT SINGLE *
          FROM zetr_ddl_i_tax_exemptions
          WHERE ExemptionCode = @ms_document-taxex
          INTO @ls_tax_exemption.
      ELSE.
        <ls_tax_subtotal>-taxcategory-taxexemptionreasoncode-content = '351'.
        SELECT SINGLE *
          FROM zetr_ddl_i_tax_exemptions
          WHERE ExemptionCode = '351'
          INTO @ls_tax_exemption.
      ENDIF.
      <ls_tax_subtotal>-taxcategory-taxexemptionreason-content = ls_tax_exemption-Description.
      <ls_tax_subtotal>-taxableamount-content = ms_accdoc_data-bseg_partner-wrbtr.
      <ls_tax_subtotal>-taxableamount-currencyid = ms_accdoc_data-bkpf-waers.
      <ls_tax_subtotal>-percent-content = ls_tax_match-taxrt.
      <ls_tax_subtotal>-taxamount-content = 0.
      <ls_tax_subtotal>-taxamount-currencyid = ms_accdoc_data-bkpf-waers.
    ENDIF.
  ENDMETHOD.