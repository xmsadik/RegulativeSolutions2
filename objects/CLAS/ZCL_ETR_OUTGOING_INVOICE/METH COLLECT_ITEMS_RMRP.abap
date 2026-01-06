  METHOD collect_items_rmrp.
    DATA: ls_invoice_items TYPE mty_item_collect.

    LOOP AT ms_invrec_data-itemdata INTO DATA(ls_itemdata).
      CLEAR ls_invoice_items.
      ls_invoice_items-posnr = ls_itemdata-invoice_doc_item.
      READ TABLE ms_invrec_data-ekpo
        INTO DATA(ls_ekpo)
        WITH TABLE KEY ebeln = ls_itemdata-po_number
                       ebelp = ls_itemdata-po_item.
      IF ls_ekpo-maktx IS NOT INITIAL.
        ls_invoice_items-arktx = ls_ekpo-maktx.
      ELSEIF ls_ekpo-txz01 IS NOT INITIAL.
        ls_invoice_items-arktx = ls_ekpo-txz01.
      ELSE.
        ls_invoice_items-arktx = ls_itemdata-item_text.
      ENDIF.
      ls_invoice_items-matnr = ls_ekpo-matnr.
      ls_invoice_items-fkimg = ls_itemdata-quantity.
      ls_invoice_items-vrkme = ls_itemdata-po_unit.
      ls_invoice_items-netwr = ls_itemdata-item_amount.
      ls_invoice_items-mwskz = ls_itemdata-tax_code.
      ls_invoice_items-waers = ms_invrec_data-headerdata-currency.
      IF ms_document-itmcl IS NOT INITIAL.
        COLLECT ls_invoice_items INTO mt_invoice_items.
      ELSE.
        APPEND ls_invoice_items TO mt_invoice_items.
      ENDIF.
    ENDLOOP.

    LOOP AT ms_invrec_data-glaccountdata INTO DATA(ls_glaccountdata).
      CLEAR ls_invoice_items.
      ls_invoice_items-posnr = ls_itemdata-invoice_doc_item.
      ls_invoice_items-arktx = ls_glaccountdata-item_text.
      IF ls_invoice_items-arktx IS INITIAL.
        ls_invoice_items-arktx = ls_glaccountdata-glaccount_name.
      ENDIF.
      ls_invoice_items-fkimg = 1.
      ls_invoice_items-vrkme = 'ST'.
      ls_invoice_items-netwr = ls_glaccountdata-item_amount.
      ls_invoice_items-mwskz = ls_glaccountdata-tax_code.
      ls_invoice_items-waers = ms_invrec_data-headerdata-currency.
      IF ms_document-itmcl IS NOT INITIAL.
        COLLECT ls_invoice_items INTO mt_invoice_items.
      ELSE.
        APPEND ls_invoice_items TO mt_invoice_items.
      ENDIF.
    ENDLOOP.

    LOOP AT ms_invrec_data-materialdata INTO DATA(ls_materialdata).
      CLEAR ls_invoice_items.
      ls_invoice_items-posnr = ls_itemdata-invoice_doc_item.
      ls_invoice_items-arktx = ls_materialdata-material_text.
      ls_invoice_items-matnr = ls_materialdata-material.
      ls_invoice_items-fkimg = ls_materialdata-quantity.
      ls_invoice_items-vrkme = ls_materialdata-base_uom.
      ls_invoice_items-netwr = ls_materialdata-item_amount.
      ls_invoice_items-mwskz = ls_materialdata-tax_code.
      ls_invoice_items-waers = ms_invrec_data-headerdata-currency.
      IF ms_document-itmcl IS NOT INITIAL.
        CLEAR ls_invoice_items-posnr.
        COLLECT ls_invoice_items INTO mt_invoice_items.
      ELSE.
        APPEND ls_invoice_items TO mt_invoice_items.
      ENDIF.
    ENDLOOP.

    IF ms_document-prfid = 'EABELGE'.
      READ TABLE ms_invrec_data-bseg INTO DATA(ls_bseg) INDEX 1.
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM zetr_t_fiacc
          WHERE ktopl = @ms_invrec_data-t001-ktopl
            AND saknr = @ls_bseg-hkont
          INTO @DATA(ls_glaccount_data).

        LOOP AT mt_invoice_items INTO DATA(ls_item).
          ls_item-othtx = ls_item-netwr * ls_glaccount_data-taxrt / 100.
          ls_item-othtr = ls_glaccount_data-taxrt.
          ls_item-othtt = ls_glaccount_data-taxty.
          CLEAR: ls_item-mwskz, ls_item-mwsbp.
          MODIFY mt_invoice_items FROM ls_item.
        ENDLOOP.
      ELSE.
        READ TABLE ms_invrec_data-withholdingtaxdata INTO DATA(ls_withholding_taxdata) INDEX 1.
        IF sy-subrc = 0.
          SELECT SINGLE *
            FROM zetr_ddl_i_tax_code_matching
            WHERE TaxProcedure = @ms_invrec_data-t001-kalsm
              AND TaxCode = @ls_withholding_taxdata-WithholdingTaxCode
            INTO @DATA(ls_tax_code_matching).
          IF sy-subrc = 0.
            LOOP AT mt_invoice_items INTO ls_item.
              ls_item-othtx = ls_item-netwr * ls_tax_code_matching-TaxRate / 100.
              ls_item-othtr = ls_tax_code_matching-TaxRate.
              ls_item-othtt = ls_tax_code_matching-TaxType.
              CLEAR: ls_item-mwskz, ls_item-mwsbp.
              MODIFY mt_invoice_items FROM ls_item.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.