  METHOD get_incoming_deliveries.
    DATA(lo_edelivery_service) = zcl_etr_edelivery_ws=>factory( mv_company_code ).
    lo_edelivery_service->get_incoming_deliveries(
      EXPORTING
        iv_date_from       = iv_date_from
        iv_date_to         = iv_date_to
        iv_delivery_uuid   = iv_delivery_uuid
        iv_import_received = iv_import_received
      IMPORTING
        et_items           = et_items
        et_list            = et_list ).
    CHECK et_list IS NOT INITIAL.
    SELECT docui, dlvui
      FROM zetr_t_icdlv
      FOR ALL ENTRIES IN @et_list
      WHERE dlvui = @et_list-dlvui
      INTO TABLE @DATA(lt_existing).
    IF sy-subrc = 0.
      LOOP AT lt_existing INTO DATA(ls_existing).
        READ TABLE et_list INTO DATA(ls_list) WITH KEY dlvui = ls_existing-dlvui.
        CHECK sy-subrc = 0.
        CASE iv_import_received.
          WHEN 'X'.
            DELETE FROM zetr_t_icdlv WHERE docui = @ls_existing-docui.
            DELETE FROM zetr_t_icdli WHERE docui = @ls_existing-docui.
            DELETE FROM zetr_t_arcd WHERE docui = @ls_existing-docui.
            DELETE FROM zetr_t_logs WHERE docui = @ls_existing-docui.
            DATA(lv_deleted) = abap_true.
          WHEN OTHERS.
            DELETE et_list WHERE dlvui = ls_list-dlvui.
            DELETE et_items WHERE docui = ls_list-docui.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    CHECK et_list IS NOT INITIAL.
    save_incoming_deliveries( it_list  = et_list
                              it_items = et_items ).
    mail_incoming_deliveries( it_list = et_list ).
  ENDMETHOD.