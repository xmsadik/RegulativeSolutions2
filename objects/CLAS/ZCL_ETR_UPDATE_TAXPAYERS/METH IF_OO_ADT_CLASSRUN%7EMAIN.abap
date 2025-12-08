  METHOD if_oo_adt_classrun~main.
    DATA: lv_update_invoice  TYPE abap_bool VALUE abap_true,
          lv_update_delivery TYPE abap_bool,
          lv_company         TYPE bukrs VALUE '1000'.

    TRY.
        GET TIME STAMP FIELD DATA(lv_start).
        IF lv_update_invoice = abap_true.
          DATA(lo_invoice_instance) = zcl_etr_invoice_operations=>factory( iv_company = lv_company ).
          DATA(lt_inv_list) = lo_invoice_instance->update_einvoice_users3( ).
          GET TIME STAMP FIELD DATA(lv_end).
          out->write( |Updated { lines( lt_inv_list ) } e-invoice taxpayers in { lv_end - lv_start } seconds.| ).
        ENDIF.

        IF lv_update_delivery = abap_true.
          DATA(lo_delivery_instance) = zcl_etr_delivery_operations=>factory( iv_company = lv_company ).
          lo_delivery_instance->update_edelivery_users( ).
        ENDIF.
      CATCH zcx_etr_regulative_exception INTO DATA(lx_exception).
        out->write( |Error : { lx_exception->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.