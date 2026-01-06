  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF mty_company_instance,
             companycode TYPE bukrs,
             instance    TYPE REF TO zcl_etr_invoice_operations,
           END OF mty_company_instance.
    DATA lt_output TYPE STANDARD TABLE OF zetr_ddl_p_outgoing_invoices.
    DATA lt_company_instances TYPE STANDARD TABLE OF mty_company_instance.
    lt_output = CORRESPONDING #( it_original_data ).
    CHECK lt_output IS NOT INITIAL.
    lt_company_instances = CORRESPONDING #( lt_output ).
    SORT lt_company_instances BY companycode.
    DELETE ADJACENT DUPLICATES FROM lt_company_instances COMPARING companycode.
    LOOP AT lt_company_instances ASSIGNING FIELD-SYMBOL(<ls_company_instance>).
      TRY.
          <ls_company_instance>-instance = zcl_etr_invoice_operations=>factory( <ls_company_instance>-companycode ).
        CATCH zcx_etr_regulative_exception.
          "handle exception
      ENDTRY.
    ENDLOOP.

    LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<ls_output>).
      READ TABLE lt_company_instances INTO DATA(ls_company_instance)
        WITH KEY companycode = <ls_output>-companycode
        BINARY SEARCH.
      CHECK sy-subrc = 0 AND ls_company_instance-instance IS NOT INITIAL.

      ls_company_instance-instance->change_outgoing_invoice_list(
        EXPORTING
          it_requested_calc_elements = it_requested_calc_elements
        CHANGING
          cs_list_output             = <ls_output> ).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_output ).
  ENDMETHOD.