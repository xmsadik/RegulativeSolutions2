  METHOD mail_incoming_invoices.
    DATA: lt_taxid_range     TYPE RANGE OF zetr_e_taxid,
          lt_document_list   TYPE mty_incoming_full_list,
          lt_documents_email TYPE mty_incoming_full_list.

    SELECT *
      FROM zetr_t_emlst
      FOR ALL ENTRIES IN @it_list
      WHERE bukrs = @it_list-bukrs
        AND emtim = '1'
        AND ( taxid = '' OR taxid = @it_list-taxid )
      INTO TABLE @DATA(lt_email_list).
    CHECK sy-subrc = 0.

    SELECT *
      FROM zetr_ddl_i_incoming_invoices
      FOR ALL ENTRIES IN @it_list
      WHERE DocumentUUID = @it_list-docui
      INTO TABLE @lt_document_list.

    LOOP AT lt_email_list INTO DATA(ls_email).
      CLEAR: lt_taxid_range, lt_documents_email.
      IF ls_email-taxid IS NOT INITIAL.
        CHECK line_exists( it_list[ taxid = ls_email-taxid ] ).
        lt_taxid_range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_email-taxid ) ).
      ENDIF.

      LOOP AT lt_document_list INTO DATA(ls_document_line) WHERE taxid IN lt_taxid_range.
        APPEND ls_document_line TO lt_documents_email.
      ENDLOOP.

      DATA(lv_html) = convert_incinv_list_to_html( lt_documents_email ).
      lv_html = '<p>Merhaba</p><p>Tarafınıza iletilen faturalar aşağıdaki gibidir</p><br>' && lv_html.

      TRY.
          DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
          lo_mail->add_recipient( CONV #( ls_email-email ) ).
          lo_mail->set_subject( 'Gelen e-Faturalar Hk.' ).
          lo_mail->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = lv_html
                                                                    iv_content_type = 'text/html' ) ).
          IF ls_email-inpdf = abap_true OR ls_email-inubl = abap_true.
            LOOP AT lt_document_list INTO ls_document_line.
              TRY.
                  DATA(lo_invoice_operations) = zcl_etr_invoice_operations=>factory( iv_company = ls_document_line-CompanyCode ).

                  IF ls_email-inpdf = abap_true.
                    DATA(lv_content) = lo_invoice_operations->incoming_einvoice_download( iv_document_uid = ls_document_line-DocumentUUID
                                                                                          iv_content_type = 'PDF'
                                                                                          iv_create_log   = '' ).
                    lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance( iv_content      = lv_content
                                                                                      iv_content_type = 'application/pdf'
                                                                                      iv_filename     = ls_document_line-invoiceid && '.pdf' ) ).
                  ENDIF.
                  IF ls_email-inubl = abap_true.
                    lv_content = lo_invoice_operations->incoming_einvoice_download( iv_document_uid = ls_document_line-DocumentUUID
                                                                                    iv_content_type = 'UBL'
                                                                                    iv_create_log   = '' ).
                    lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance( iv_content      = lv_content
                                                                                      iv_content_type = 'text/xml'
                                                                                      iv_filename     = ls_document_line-invoiceid && '.xml' ) ).
                  ENDIF.
                CATCH zcx_etr_regulative_exception.
              ENDTRY.
            ENDLOOP.
          ENDIF.
          lo_mail->send( ).
        CATCH cx_bcs_mail INTO DATA(lx_mail).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.