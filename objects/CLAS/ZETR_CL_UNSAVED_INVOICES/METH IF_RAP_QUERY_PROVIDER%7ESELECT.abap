  METHOD if_rap_query_provider~select.
    TRY.
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
        DATA ls_selections TYPE zcl_etr_invoice_operations=>mty_invoice_selection.
        DATA lt_output TYPE STANDARD TABLE OF zetr_ddl_i_unsaved_invoices.
        DATA(lo_paging) = io_request->get_paging( ).
        DATA(lv_top) = lo_paging->get_page_size( ).
        DATA(lv_skip) = lo_paging->get_offset( ).
        IF lv_top < 0.
          lv_top = 1.
        ENDIF.

        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'BUKRS'.
              ls_selections-bukrs = CORRESPONDING #( ls_filter-range ).
            WHEN 'BELNR'.
              ls_selections-belnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'GJAHR'.
              ls_selections-gjahr = CORRESPONDING #( ls_filter-range ).
            WHEN 'AWTYP'.
              ls_selections-awtyp = CORRESPONDING #( ls_filter-range ).
            WHEN 'SDDTY'.
              ls_selections-sddty = CORRESPONDING #( ls_filter-range ).
            WHEN 'MMDTY'.
              ls_selections-mmdty = CORRESPONDING #( ls_filter-range ).
            WHEN 'FIDTY'.
              ls_selections-fidty = CORRESPONDING #( ls_filter-range ).
            WHEN 'ERNAM'.
              ls_selections-ernam = CORRESPONDING #( ls_filter-range ).
            WHEN 'ERDAT'.
              ls_selections-erdat = CORRESPONDING #( ls_filter-range ).
            WHEN 'BLDAT'.
              ls_selections-bldat = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.

        zcl_etr_invoice_operations=>outgoing_invoice_mass_save(
          EXPORTING
            is_selection   = ls_selections
            iv_save_source = 'M'
*            iv_max_count   = CONV #( lv_top )
          IMPORTING
            et_invoices    = DATA(lt_invoices) ).
        LOOP AT lt_invoices INTO DATA(ls_invoice).
          IF lv_skip IS NOT INITIAL.
            CHECK sy-tabix > lv_skip.
          ENDIF.

          DATA(ls_output) = CORRESPONDING zetr_ddl_i_unsaved_invoices( ls_invoice ).
          APPEND ls_output TO lt_output.

          IF lines( lt_output ) >= lv_top.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested(  ).
          io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_invoices ) ).
        ENDIF.
        io_response->set_data( it_data = lt_output ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.