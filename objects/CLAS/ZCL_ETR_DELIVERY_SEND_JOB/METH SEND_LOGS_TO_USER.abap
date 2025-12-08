  METHOD send_logs_to_user.
    DATA lv_body TYPE string.
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
    LOOP AT it_deliveries INTO DATA(ls_delivery).
      lv_body = lv_body && '<tr>' &&
                           '<td style="width: 12%;">' && ls_delivery-companycode && '</td>' &&
                           '<td style="width: 12%;">' && ls_delivery-documentnumber && '</td>' &&
                           '<td style="width: 12%;">' && ls_delivery-fiscalyear && '</td>' &&
                           '<td style="width: 12%;">' && ls_delivery-profileid && '</td>' &&
                           '<td style="width: 52%;">' && ls_delivery-statusdetail && '</td>' &&
                           '</tr>'.
    ENDLOOP.
    lv_body = lv_body && '</tbody>' &&
                         '</table>' .

    TRY.
        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
        lo_mail->add_recipient( CONV #( lv_email ) ).
        lo_mail->set_subject( 'Arka Planda Gönderdiğiniz İrsaliyeler Hk.' ).
        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = lv_body
                                                                  iv_content_type = 'text/html' ) ).
        lo_mail->send( ).
      CATCH cx_bcs_mail INTO DATA(lx_mail).
    ENDTRY.
  ENDMETHOD.