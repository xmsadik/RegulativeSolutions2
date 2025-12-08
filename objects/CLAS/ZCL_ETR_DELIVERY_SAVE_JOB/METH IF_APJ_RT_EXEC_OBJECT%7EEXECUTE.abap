  METHOD if_apj_rt_exec_object~execute.
    DATA ls_selections TYPE zcl_etr_delivery_operations=>mty_delivery_selection.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_BUKRS'.
          APPEND INITIAL LINE TO ls_selections-bukrs ASSIGNING FIELD-SYMBOL(<ls_bukrs_range>).
          <ls_bukrs_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_BELNR'.
          APPEND INITIAL LINE TO ls_selections-belnr ASSIGNING FIELD-SYMBOL(<ls_belnr_range>).
          <ls_belnr_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_GJAHR'.
          APPEND INITIAL LINE TO ls_selections-gjahr ASSIGNING FIELD-SYMBOL(<ls_gjahr_range>).
          <ls_gjahr_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_AWTYP'.
          APPEND INITIAL LINE TO ls_selections-awtyp ASSIGNING FIELD-SYMBOL(<ls_awtyp_range>).
          <ls_awtyp_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_SDDTY'.
          APPEND INITIAL LINE TO ls_selections-sddty ASSIGNING FIELD-SYMBOL(<ls_sddty_range>).
          <ls_sddty_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_MMDTY'.
          APPEND INITIAL LINE TO ls_selections-mmdty ASSIGNING FIELD-SYMBOL(<ls_mmdty_range>).
          <ls_mmdty_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_FIDTY'.
          APPEND INITIAL LINE TO ls_selections-fidty ASSIGNING FIELD-SYMBOL(<ls_fidty_range>).
          <ls_fidty_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_ERNAM'.
          APPEND INITIAL LINE TO ls_selections-ernam ASSIGNING FIELD-SYMBOL(<ls_ernam_range>).
          <ls_ernam_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_ERDAT'.
          APPEND INITIAL LINE TO ls_selections-erdat ASSIGNING FIELD-SYMBOL(<ls_erdat_range>).
          <ls_erdat_range> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_BLDAT'.
          APPEND INITIAL LINE TO ls_selections-bldat ASSIGNING FIELD-SYMBOL(<ls_bldat_range>).
          <ls_bldat_range> = CORRESPONDING #( ls_parameter ).
      ENDCASE.
    ENDLOOP.
    zcl_etr_delivery_operations=>outgoing_delivery_mass_save(
      EXPORTING
        is_selection   = ls_selections
        iv_save_source = 'J'
      IMPORTING
        et_deliveries  = DATA(lt_deliveries)
        et_logs        = DATA(lt_logs) ).
    CHECK lt_logs IS NOT INITIAL.

    TRY.
        DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object = 'ZETR_ALO_REGULATIVE'
                                                                                      subobject = 'DELIVERY_SAVE_JOB' ) ).

        LOOP AT lt_logs INTO DATA(ls_log).
          DATA(lo_message) = cl_bali_message_setter=>create( severity = SWITCH #( ls_log-type
                                                                         WHEN 'E' THEN if_bali_constants=>c_severity_error
                                                                         WHEN 'W' THEN if_bali_constants=>c_severity_warning
                                                                         WHEN 'I' THEN if_bali_constants=>c_severity_information
                                                                         WHEN 'S' THEN if_bali_constants=>c_severity_status
                                                                         ELSE if_bali_constants=>c_severity_error )
                                                             id = ls_log-id
                                                             number = ls_log-number
                                                             variable_1 = ls_log-message_v1
                                                             variable_2 = ls_log-message_v2
                                                             variable_3 = ls_log-message_v3
                                                             variable_4 = ls_log-message_v4 ).
          lo_log->add_item( lo_message ).
        ENDLOOP.
        cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime.
    ENDTRY.
  ENDMETHOD.