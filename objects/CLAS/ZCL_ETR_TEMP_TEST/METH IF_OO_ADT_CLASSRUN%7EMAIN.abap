  METHOD if_oo_adt_classrun~main.

    DATA ls_invoice TYPE zif_etr_invoice_ubl21=>invoicetype.

    SELECT SINGLE docui FROM zetr_t_icinv WHERE invno = 'A092025000024297' INTO @DATA(lv_uuid).
    CHECK sy-subrc = 0.


    TRY.
        SELECT SINGLE contn FROM zetr_t_arcd WHERE docui = @lv_uuid AND conty = 'UBL' INTO @DATA(lv_invoice).
        CALL TRANSFORMATION zetr_xml_formatter
          SOURCE XML lv_invoice
          RESULT XML lv_invoice.
        CALL TRANSFORMATION zetr_ubl21_invoice
          SOURCE XML lv_invoice
          RESULT root = ls_invoice.
      CATCH cx_root INTO DATA(lx_root).
        out->write( lx_root->get_text( ) ).
    ENDTRY.

    DATA: lv_belnr   TYPE belnr_d,
          lv_docui   TYPE sysuuid_c22,
          lv_confirm TYPE abap_bool.

    " Debug modda değerleri girin:
    " lv_belnr, lv_docui, lv_confirm = abap_true
    "  BREAK-POINT.

    IF lv_belnr IS INITIAL OR lv_docui IS INITIAL.
      out->write( 'HATA: Belge numarası ve UUID değeri girilmelidir!' ).
      RETURN.
    ENDIF.

    IF lv_confirm = abap_false.
      out->write( 'UYARI: Silme işlemi onaylanmadı. lv_confirm = abap_true yapın!' ).
      RETURN.
    ENDIF.

    DATA(lv_result) = delete_delivery_record(
      iv_belnr = lv_belnr
      iv_docui = lv_docui
      iv_confirm_delete = lv_confirm
    ).

    IF lv_result = abap_true.
      out->write( |Kayıt başarıyla silindi - BELNR: { lv_belnr }, DOCUI: { lv_docui }| ).
    ELSE.
      out->write( 'Kayıt silinemedi veya bulunamadı.' ).
    ENDIF.

  ENDMETHOD.