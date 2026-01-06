  METHOD map_invoice_to_credit.
    ms_credit_ubl-UBLExtensions = ms_invoice_ubl-UBLExtensions.
    ms_credit_ubl-UBLVersionID = ms_invoice_ubl-UBLVersionID.
    ms_credit_ubl-CustomizationID = ms_invoice_ubl-CustomizationID.
    ms_credit_ubl-ProfileID = ms_invoice_ubl-ProfileID.
    ms_credit_ubl-Id = ms_invoice_ubl-Id.
    ms_credit_ubl-CopyIndicator = ms_invoice_ubl-CopyIndicator.
    ms_credit_ubl-UUId = ms_invoice_ubl-UUId.
    ms_credit_ubl-IssueDate = ms_invoice_ubl-IssueDate.
    ms_credit_ubl-IssueTime = ms_invoice_ubl-IssueTime.
    ms_credit_ubl-CreditNoteTypeCode = ms_invoice_ubl-InvoiceTypeCode.
    ms_credit_ubl-Note = ms_invoice_ubl-Note.
    ms_credit_ubl-DocumentCurrencyCode = ms_invoice_ubl-DocumentCurrencyCode.
    ms_credit_ubl-TaxCurrencyCode = ms_invoice_ubl-TaxCurrencyCode.
    ms_credit_ubl-PricingCurrencyCode = ms_invoice_ubl-PricingCurrencyCode.
    ms_credit_ubl-PaymentCurrencyCode = ms_invoice_ubl-PaymentCurrencyCode.
    ms_credit_ubl-PaymentAlternativeCurrencyCode = ms_invoice_ubl-PaymentAlternativeCurrencyCode.
    ms_credit_ubl-AccountingCost = ms_invoice_ubl-AccountingCost.
    ms_credit_ubl-LineCountNumeric = ms_invoice_ubl-LineCountNumeric.
    IF ms_invoice_ubl-InvoicePeriod IS NOT INITIAL.
      APPEND ms_invoice_ubl-InvoicePeriod TO ms_credit_ubl-InvoicePeriod.
    ENDIF.
    ms_credit_ubl-OrderReference = ms_invoice_ubl-OrderReference.
    ms_credit_ubl-BillingReference = ms_invoice_ubl-BillingReference.
    ms_credit_ubl-DespatchDocumentReference = ms_invoice_ubl-DespatchDocumentReference.
    ms_credit_ubl-ReceiptDocumentReference = ms_invoice_ubl-ReceiptDocumentReference.
    ms_credit_ubl-ContractDocumentReference = ms_invoice_ubl-ContractDocumentReference.
    ms_credit_ubl-AdditionalDocumentReference = ms_invoice_ubl-AdditionalDocumentReference.
    ms_credit_ubl-OriginatorDocumentReference = ms_invoice_ubl-OriginatorDocumentReference.
    ms_credit_ubl-Signature = ms_invoice_ubl-Signature.
    ms_credit_ubl-AccountingSupplierParty = ms_invoice_ubl-AccountingSupplierParty.
    ms_credit_ubl-AccountingCustomerParty = ms_invoice_ubl-AccountingCustomerParty.
    ms_credit_ubl-BuyerCustomerParty = ms_invoice_ubl-BuyerCustomerParty.
    ms_credit_ubl-SellerSupplierParty = ms_invoice_ubl-SellerSupplierParty.
    ms_credit_ubl-TaxRepresentativeParty = ms_invoice_ubl-TaxRepresentativeParty.
    ms_credit_ubl-Delivery = ms_invoice_ubl-Delivery.
    ms_credit_ubl-PaymentMeans = ms_invoice_ubl-PaymentMeans.
    IF ms_invoice_ubl-PaymentTerms IS NOT INITIAL.
      APPEND ms_invoice_ubl-PaymentTerms TO ms_credit_ubl-PaymentTerms.
    ENDIF.
    ms_credit_ubl-TaxExchangeRate = ms_invoice_ubl-TaxExchangeRate.
    ms_credit_ubl-PricingExchangeRate = ms_invoice_ubl-PricingExchangeRate.
    ms_credit_ubl-PaymentExchangeRate = ms_invoice_ubl-PaymentExchangeRate.
    ms_credit_ubl-PaymentAlternativeExchangeRate = ms_invoice_ubl-PaymentAlternativeExchangeRate.
    ms_credit_ubl-AllowanceCharge = ms_invoice_ubl-AllowanceCharge.
    ms_credit_ubl-TaxTotal = ms_invoice_ubl-TaxTotal.
    ms_credit_ubl-LegalMonetaryTotal = ms_invoice_ubl-LegalMonetaryTotal.
    LOOP AT ms_invoice_ubl-InvoiceLine INTO DATA(ls_invoice_line).
      APPEND INITIAL LINE TO ms_credit_ubl-CreditNoteLine ASSIGNING FIELD-SYMBOL(<ls_credit_line>).
      <ls_credit_line>-id = ls_invoice_line-id.
      <ls_credit_line>-Note = ls_invoice_line-Note.
      <ls_credit_line>-CreditedQuantity = ls_invoice_line-InvoicedQuantity.
      <ls_credit_line>-LineExtensionAmount = ls_invoice_line-LineExtensionAmount.
      <ls_credit_line>-OrderLineReference = ls_invoice_line-OrderLineReference.
      <ls_credit_line>-DespatchLineReference = ls_invoice_line-DespatchLineReference.
      <ls_credit_line>-ReceiptLineReference = ls_invoice_line-ReceiptLineReference.
      <ls_credit_line>-Delivery = ls_invoice_line-Delivery.
      IF ls_invoice_line-TaxTotal IS NOT INITIAL.
        APPEND ls_invoice_line-TaxTotal TO <ls_credit_line>-TaxTotal.
      ENDIF.
      <ls_credit_line>-AllowanceCharge = ls_invoice_line-AllowanceCharge.
      <ls_credit_line>-Item = ls_invoice_line-Item.
      <ls_credit_line>-Price = ls_invoice_line-Price.
    ENDLOOP.
  ENDMETHOD.