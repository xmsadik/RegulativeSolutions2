  METHOD send_logs_to_user.
    DATA lv_body TYPE string.
    DATA lv_company_mail TYPE zetr_t_cmpin-email.
    SELECT SINGLE defaultemailaddress
      FROM I_BusinessUserVH
      WHERE UserID = @iv_user
      INTO @DATA(lv_email).
    CHECK sy-subrc = 0 AND lv_email IS NOT INITIAL.

    lv_body = '<table style="width: 100%" border="1">' &&
              '<tbody>' &&
              '<tr>' &&
              '<td style="width: 12%;"><strong>Şirket</strong></td>' &&
              '<td style="width: 12%;"><strong>Belge</strong></td>' &&
              '<td style="width: 12%;"><strong>Yıl</strong></td>' &&
              '<td style="width: 12%;"><strong>Senaryo</strong></td>' &&
              '<td style="width: 52%;"><strong>Durum</strong></td>' &&
              '</tr>'.
    LOOP AT it_invoices INTO DATA(ls_invoice).
      IF lv_company_mail IS INITIAL.
        SELECT SINGLE email
          FROM zetr_t_cmpin
          WHERE bukrs = @ls_invoice-companycode
          INTO @lv_company_mail.
      ENDIF.
      lv_body = lv_body && '<tr>' &&
                           '<td style="width: 12%;">' && ls_invoice-companycode && '</td>' &&
                           '<td style="width: 12%;">' && ls_invoice-documentnumber && '</td>' &&
                           '<td style="width: 12%;">' && ls_invoice-fiscalyear && '</td>' &&
                           '<td style="width: 12%;">' && ls_invoice-profileid && '</td>' &&
                           '<td style="width: 52%;">' && ls_invoice-statusdetail && '</td>' &&
                           '</tr>'.
    ENDLOOP.
    lv_body = lv_body && '</tbody>' &&
                         '</table>' .

    TRY.
        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
        lo_mail->add_recipient( CONV #( lv_email ) ).
        IF lv_company_mail IS NOT INITIAL.
          lo_mail->set_sender( CONV #( lv_company_mail ) ).
        ENDIF.
        lo_mail->set_subject( 'Arka Planda Gönderdiğiniz Faturalar Hk.' ).
        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = lv_body
                                                                  iv_content_type = 'text/html' ) ).
        lo_mail->send( ).
      CATCH cx_bcs_mail INTO DATA(lx_mail).
    ENDTRY.
  ENDMETHOD.