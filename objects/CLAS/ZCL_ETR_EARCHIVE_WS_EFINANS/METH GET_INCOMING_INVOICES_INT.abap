  METHOD get_incoming_invoices_int.
    DATA: lv_request_xml  TYPE string,
          lv_response_xml TYPE string,
          lv_zipped_file  TYPE xstring,
          lv_xml_file     TYPE string.

    FIELD-SYMBOLS: <ls_list>          TYPE mty_incoming_document,
                   <lv_invoice_field> TYPE any.

    CONCATENATE
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.earsiv.uut.cs.com.tr/">'
    '<soapenv:Header>'
    '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
    '<wsse:UsernameToken>'
    '<wsse:Username>' ms_company_parameters-wsusr '</wsse:Username>'
    '<wsse:Password>' ms_company_parameters-wspwd '</wsse:Password>'
    '</wsse:UsernameToken>'
    '</wsse:Security>'
    '</soapenv:Header>'
    '<soapenv:Body>'
    '<ser:gibEarsivFaturaListesiAl>'
    '<vkn>' mv_company_taxid '</vkn>'
    '<faturaBaslangicTarihi>' iv_date_from '</faturaBaslangicTarihi>'
    '<faturaBitisTarihi>' iv_date_to '</faturaBitisTarihi>'
    '<belgeTipi>GIB_EARSIV_FATURA</belgeTipi>'
    '</ser:gibEarsivFaturaListesiAl>'
    '</soapenv:Body>'
    '</soapenv:Envelope>'
    INTO lv_request_xml.

    lv_response_xml = run_service( iv_request = lv_request_xml
                                   iv_use_alternative_endpoint = abap_true ).

    DATA(lt_xml_table) = zcl_etr_regulative_common=>parse_xml( lv_response_xml ).
    LOOP AT lt_xml_table INTO DATA(ls_xml_line).
      CASE ls_xml_line-name.
        WHEN 'return'.
          APPEND INITIAL LINE TO rt_invoices ASSIGNING <ls_list>.
        WHEN OTHERS.
          TRANSLATE ls_xml_line-name TO UPPER CASE.
          ASSIGN COMPONENT ls_xml_line-name OF STRUCTURE <ls_list> TO <lv_invoice_field>.
          IF sy-subrc = 0.
            <lv_invoice_field> = ls_xml_line-value.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.