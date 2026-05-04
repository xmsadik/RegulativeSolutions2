  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_output TYPE STANDARD TABLE OF zetr_ddl_p_incoming_delcont.
    lt_output = CORRESPONDING #( it_original_data ).
    LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<ls_output>).
      TRY.
          cl_system_uuid=>convert_uuid_c22_static(
            EXPORTING
              uuid = <ls_output>-documentuuid
            IMPORTING
              uuid_c36 = DATA(lv_uuid) ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
      <ls_output>-ContentUrl = 'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                               '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_DELIVERIES/Contents(DocumentUUID=guid''' &&
                               lv_uuid && ''',ContentType=''' && <ls_output>-ContentType &&
                               ''',DocumentType=''' && <ls_output>-DocumentType && ''')/$value'.
    ENDLOOP.

    IF lines( lt_output ) = 1.
      READ TABLE lt_output
        ASSIGNING <ls_output>
        INDEX 1.
      IF sy-subrc = 0.
        SELECT SINGLE contn
          FROM zetr_t_arcd
          WHERE docui = @<ls_output>-DocumentUUID
            AND conty = @<ls_output>-ContentType
            AND docty = @<ls_output>-DocumentType
          INTO @<ls_output>-Content.
        IF <ls_output>-Content IS INITIAL.
          TRY.
              DATA(lo_delivery_operations) = zcl_etr_delivery_operations=>factory( <ls_output>-companycode ).
              CASE <ls_output>-DocumentType.
                WHEN 'OUTDLVRES'.
                  <ls_output>-Content = lo_delivery_operations->outgoing_delivery_respdown( iv_document_uid = <ls_output>-DocumentUUID
                                                                                            iv_content_type = <ls_output>-ContentType ).
                WHEN OTHERS.
                  <ls_output>-Content = lo_delivery_operations->outgoing_delivery_download( iv_document_uid = <ls_output>-DocumentUUID
                                                                                            iv_content_type = <ls_output>-ContentType ).
                  DATA(lv_document_content) = <ls_output>-Content.

                  IF <ls_output>-ContentType = 'PDF'.
                    TRY.
                        DATA(lv_response) = lo_delivery_operations->outgoing_delivery_respdown( iv_document_uid = <ls_output>-DocumentUUID
                                                                                                iv_content_type = <ls_output>-ContentType ).
                        IF lv_response IS NOT INITIAL.
                          DATA(lo_merger) = cl_rspo_pdf_merger=>create_instance( ).
                          lo_merger->add_document( <ls_output>-Content ).
                          lo_merger->add_document( lv_response ).
                          <ls_output>-Content = lo_merger->merge_documents( ).
                        ENDIF.
                      CATCH cx_root.
                        <ls_output>-Content = lv_document_content.
                    ENDTRY.
                  ENDIF.
              ENDCASE.
            CATCH zcx_etr_regulative_exception INTO DATA(lx_etr_regulative_exception).
              <ls_output>-Content = cl_abap_conv_codepage=>create_out( )->convert(
                                                                                   replace( val = '<!DOCTYPE html><html><body><h1>Hata Olustu / Error Occured</h1><p>' &&
                                                                                                   lx_etr_regulative_exception->get_text( ) &&
                                                                                                   '</p></body></html>'
                                                                                            sub = |\n|
                                                                                            with = ``
                                                                                            occ = 0  ) ).
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.
    ct_calculated_data = CORRESPONDING #( lt_output ).
  ENDMETHOD.