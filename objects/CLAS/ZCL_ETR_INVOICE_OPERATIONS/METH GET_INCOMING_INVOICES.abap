  METHOD get_incoming_invoices.
    DATA(lo_einvoice_service) = zcl_etr_einvoice_ws=>factory( mv_company_code ).
    lo_einvoice_service->get_incoming_invoices(
      EXPORTING
        iv_date_from = iv_date_from
        iv_date_to   = iv_date_to
        iv_import_received = iv_import_received
        iv_invoice_uuid = iv_invoice_uuid
      IMPORTING
        rt_list            = rt_list
        rt_items           = DATA(lt_items) ).
    CHECK rt_list IS NOT INITIAL.
    SELECT docui, invui
      FROM zetr_t_icinv
      FOR ALL ENTRIES IN @rt_list
      WHERE invui = @rt_list-invui
      INTO TABLE @DATA(lt_existing).
    IF sy-subrc = 0.
      LOOP AT lt_existing INTO DATA(ls_existing).
        READ TABLE rt_list INTO DATA(ls_list) WITH KEY invui = ls_existing-invui.
        CHECK sy-subrc = 0.
        CASE iv_import_received.
          WHEN 'X'.
            DELETE FROM zetr_t_icinv WHERE docui = @ls_existing-docui.
            DELETE FROM zetr_t_icini WHERE docui = @ls_existing-docui.
            DELETE FROM zetr_t_arcd WHERE docui = @ls_existing-docui.
            DELETE FROM zetr_t_logs WHERE docui = @ls_existing-docui.
            DATA(lv_deleted) = abap_true.
          WHEN OTHERS.
            DELETE rt_list WHERE invui = ls_list-invui.
            DELETE lt_items WHERE docui = ls_list-docui.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    CHECK rt_list IS NOT INITIAL.

    IF lv_deleted = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.
    save_incoming_invoices( it_list = rt_list
                            it_items = lt_items ).
    mail_incoming_invoices( rt_list ).
  ENDMETHOD.