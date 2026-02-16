  METHOD incoming_einvoice_download.
    SELECT SINGLE docui, bukrs, archv, invii AS docii, invui AS duich, invno AS docno, envui, taxid, prfid
      FROM zetr_t_icinv
      WHERE docui = @iv_document_uid
      INTO @DATA(ls_document).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_etr_regulative_exception
        MESSAGE e005(zetr_common).
    ELSEIF ls_document-archv IS NOT INITIAL.
      SELECT SINGLE contn
        FROM zetr_t_arcd
        WHERE docui = @ls_document-docui
          AND conty = @iv_content_type
        INTO @rv_document.
    ELSE.
      CASE ls_document-prfid.
        WHEN 'EARSIV'.
          DATA(lo_earchive_service) = zcl_etr_earchive_ws=>factory( iv_company = ls_document-bukrs ).
          rv_document = lo_earchive_service->incoming_invoice_download( is_document_numbers = CORRESPONDING #( ls_document )
                                                                        iv_content_type = iv_content_type ).
        WHEN OTHERS.
          DATA(lo_einvoice_service) = zcl_etr_einvoice_ws=>factory( iv_company = ls_document-bukrs ).
          rv_document = lo_einvoice_service->incoming_invoice_download( is_document_numbers = CORRESPONDING #( ls_document )
                                                                        iv_content_type = iv_content_type ).
      ENDCASE.
      IF iv_content_type = 'UBL'.
        CALL TRANSFORMATION zetr_xml_formatter
          SOURCE XML rv_document
          RESULT XML rv_document.
      ENDIF.
      CHECK iv_create_log = abap_true.
      zcl_etr_regulative_log=>create_single_log(
        EXPORTING
          iv_log_code    = zcl_etr_regulative_log=>mc_log_codes-download
          iv_document_id = ls_document-docui ).
    ENDIF.
  ENDMETHOD.