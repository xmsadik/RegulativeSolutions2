  METHOD incoming_invoice_download.
    DATA: lv_request_xml  TYPE string,
          lv_response_xml TYPE string,
          lv_content      TYPE string,
          lv_key          TYPE string.


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
  '<ser:gibEarsivFaturaPdfAl>'
  '<input>{ "firmaVkn":"' mv_company_taxid
            '","mukellefVkn":"' is_document_numbers-taxid
            '","faturaNo":"' is_document_numbers-docno '"}</input>'
  '</ser:gibEarsivFaturaPdfAl>'
  '</soapenv:Body>'
  '</soapenv:Envelope>'
  INTO lv_request_xml.
    lv_response_xml = run_service( lv_request_xml ).

    DATA(lt_xml_table) = zcl_etr_regulative_common=>parse_xml( lv_response_xml ).
    LOOP AT lt_xml_table INTO DATA(ls_xml_line).
      IF ls_xml_line-name  EQ 'key'.
        lv_key = ls_xml_line-value.
      ENDIF.
      IF  lv_key = 'belgeIcerigi' AND ls_xml_line-name EQ 'value'.
        CONCATENATE lv_content
                    ls_xml_line-value
                    INTO lv_content.
      ENDIF.
    ENDLOOP.
    IF lv_content IS NOT INITIAL.
      rv_invoice_data = xco_cp=>string( lv_content )->as_xstring( xco_cp_binary=>text_encoding->base64 )->value.
    ENDIF.
  ENDMETHOD.