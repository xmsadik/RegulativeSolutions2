  METHOD download_registered_taxpayers3.
    DATA: lv_request_xml   TYPE string,
          lv_taxpayers_xml TYPE string,
          lt_partask_in    TYPE cl_abap_parallel=>t_in_inst_tab.
    lv_taxpayers_xml = zcl_etr_regulative_common=>check_regex( iv_regex = '<return>(.*)</return>'
                                                              iv_text  = run_service( |<?xml version = '1.0' encoding = 'UTF-8'?>| &&
                                                                                      |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.connector.uut.cs.com.tr/">| &&
                                                                                      |<soapenv:Header>| &&
                                                                                      |<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">| &&
                                                                                      |<wsse:UsernameToken>| &&
                                                                                      |<wsse:Username>{ ms_company_parameters-wsusr }</wsse:Username>| &&
                                                                                      |<wsse:Password>{ ms_company_parameters-wspwd }</wsse:Password>| &&
                                                                                      |</wsse:UsernameToken>| &&
                                                                                      |</wsse:Security>| &&
                                                                                      |</soapenv:Header>| &&
                                                                                      |<soapenv:Body>| &&
                                                                                      |<ser:kayitliKullaniciListeleExtended>| &&
                                                                                      |<urun>EFATURA</urun>| &&
                                                                                      |<gecmisEklensin></gecmisEklensin>| &&
                                                                                      |</ser:kayitliKullaniciListeleExtended>| &&
                                                                                      |</soapenv:Body>| &&
                                                                                      |</soapenv:Envelope>| ) ).

    zcl_etr_regulative_common=>unzip_file_single(
      EXPORTING
        iv_zipped_file_xstr = xco_cp=>string( lv_taxpayers_xml )->as_xstring( xco_cp_binary=>text_encoding->base64 )->value
      IMPORTING
        ev_output_data_str = lv_taxpayers_xml ).

    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_taxpayers_xml WITH ``.
    REPLACE ALL OCCURRENCES OF '</eFaturaKayitliKullaniciListe>' IN lv_taxpayers_xml WITH ``.
    FIND FIRST OCCURRENCE OF '<eFaturaKayitliKullanici>' IN lv_taxpayers_xml MATCH OFFSET DATA(lv_offset)
                                                                             MATCH LENGTH DATA(lv_length).
    IF lv_offset > 0.
      lv_taxpayers_xml = lv_taxpayers_xml+lv_offset(*).
    ENDIF.

    WHILE lv_taxpayers_xml IS NOT INITIAL.
      CLEAR lv_request_xml.
      DO 1000 TIMES.
        FIND FIRST OCCURRENCE OF '</eFaturaKayitliKullanici>' IN lv_taxpayers_xml MATCH OFFSET lv_offset
                                                                                  MATCH LENGTH lv_length.
        IF sy-subrc = 0.
          lv_offset += lv_length.
          lv_request_xml = lv_request_xml && lv_taxpayers_xml(lv_offset).
          lv_taxpayers_xml = lv_taxpayers_xml+lv_offset(*).
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      lv_request_xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' &&
                       '<eFaturaKayitliKullaniciListe>' &&
                       lv_request_xml &&
                       '</eFaturaKayitliKullaniciListe>'.
      APPEND NEW lcl_invoice_user_partask( lv_request_xml ) TO lt_partask_in.
      CLEAR lv_request_xml.
    ENDWHILE.
    IF lv_request_xml IS NOT INITIAL.
      lv_request_xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' &&
                       '<eFaturaKayitliKullaniciListe>' &&
                       lv_request_xml &&
                       '</eFaturaKayitliKullaniciListe>'.
      APPEND NEW lcl_invoice_user_partask( lv_request_xml ) TO lt_partask_in.
    ENDIF.
    FREE: lv_taxpayers_xml, lv_request_xml.

    NEW cl_abap_parallel( )->run_inst(
      EXPORTING
        p_in_tab = lt_partask_in
      IMPORTING
        p_out_tab = DATA(lt_partask_out) ).
    LOOP AT lt_partask_out INTO DATA(ls_partask_out) WHERE inst IS NOT INITIAL.
      APPEND LINES OF CAST lcl_invoice_user_partask( ls_partask_out-inst )->get_result( ) TO rt_list.
    ENDLOOP.


*    CALL TRANSFORMATION zetr_inv_userlist_efn
*      SOURCE XML lv_taxpayers_xml
*      RESULT efaturakayitlikullaniciliste = ls_user_list.
*    SORT ls_user_list-efaturakayitlikullanici BY vkntckn.
*
*    FREE: lv_taxpayers_xml, lv_zipped_file.
*
*    DATA lv_taxid TYPE string.
*    DATA lt_list_bg TYPE mty_users_t.
*
*    LOOP AT ls_user_list-efaturakayitlikullanici INTO DATA(ls_list).
**      IF lv_taxid <> ls_list-vkntckn AND lines( lt_list_bg ) > 100000.
*      IF lv_taxid <> ls_list-vkntckn AND lines( lt_list_bg ) > 1000.
*        save_registered_taxpayers_bckg( it_list = lt_list_bg ).
*        CLEAR lt_list_bg.
**        FREE lt_list_bg.
*      ELSEIF lv_taxid <> ls_list-vkntckn.
*        lv_taxid = ls_list-vkntckn.
*      ENDIF.
*      APPEND ls_list TO lt_list_bg.
**      DELETE ls_user_list-efaturakayitlikullanici.
*    ENDLOOP.
*
*    IF lt_list_bg IS NOT INITIAL.
*      save_registered_taxpayers_bckg( it_list = lt_list_bg ).
**      CLEAR lt_list_bg.
*      FREE lt_list_bg.
*    ENDIF.
  ENDMETHOD.