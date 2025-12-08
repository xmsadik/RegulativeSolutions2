  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_output TYPE STANDARD TABLE OF zetr_ddl_p_outgoing_invoices.
    lt_output = CORRESPONDING #( it_original_data ).
    CHECK lt_output IS NOT INITIAL.

    LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<ls_output>).
      IF line_exists( it_requested_calc_elements[ table_line = 'DOCUMENTDISPLAYURL' ] ).
        <ls_output>-DocumentDisplayURL = 'https://' && zcl_etr_regulative_common=>get_ui_url( ) && '/ui#'.
        CASE <ls_output>-DocumentType(4).
          WHEN 'VBRK'.
            <ls_output>-DocumentDisplayURL = <ls_output>-DocumentDisplayURL &&
                                             'BillingDocument-displayBillingDocument?BillingDocument=' && <ls_output>-DocumentNumber.
          WHEN 'MKPF'.
            <ls_output>-DocumentDisplayURL = <ls_output>-DocumentDisplayURL &&
                                             'SupplierInvoice-displayAdvanced?SupplierInvoice=' && <ls_output>-DocumentNumber &&
                                             '&FiscalYear=' && <ls_output>-FiscalYear.
          WHEN 'BKPF'.
            <ls_output>-DocumentDisplayURL = <ls_output>-DocumentDisplayURL &&
                                             'GLAccount-displayGLLineItemReportingView?AccountingDocument=' && <ls_output>-DocumentNumber &&
                                             '&CompanyCode=' && <ls_output>-CompanyCode &&
                                             '&FiscalYear=' && <ls_output>-FiscalYear.
        ENDCASE.
      ENDIF.

      IF line_exists( it_requested_calc_elements[ table_line = 'PDFCONTENTURL' ] ) OR
         line_exists( it_requested_calc_elements[ table_line = 'HTMLCONTENTURL' ] ) OR
         line_exists( it_requested_calc_elements[ table_line = 'UBLCONTENTURL' ] ).
        TRY.
            cl_system_uuid=>convert_uuid_c22_static(
              EXPORTING
                uuid = <ls_output>-documentuuid
              IMPORTING
                uuid_c36 = DATA(lv_uuid) ).
          CATCH cx_uuid_error.
        ENDTRY.
        <ls_output>-PDFContentUrl = "'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                                    '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' &&
                                    lv_uuid && ''',ContentType=''PDF'',DocumentType=''OUTINVDOC'')/$value'.
        <ls_output>-HTMLContentUrl = "'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                                    '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' &&
                                    lv_uuid && ''',ContentType=''HTML'',DocumentType=''OUTINVDOC'')/$value'.
        <ls_output>-UBLContentUrl = "'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                                    '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' &&
                                    lv_uuid && ''',ContentType=''UBL'',DocumentType=''OUTINVDOC'')/$value'.
      ENDIF.

      IF line_exists( it_requested_calc_elements[ table_line = 'HTMLCONTENT' ] ) OR
         line_exists( it_requested_calc_elements[ table_line = 'UBLCONTENT' ] ).
        CLEAR: <ls_output>-HTMLContent, <ls_output>-UBLContent.
        DO 2 TIMES.
          DATA(lv_conty) = COND zetr_e_dctyp( WHEN sy-index = 1 THEN 'HTML' ELSE 'UBL' ).
          DATA(lv_field) = COND string( WHEN sy-index = 1 THEN 'HTMLContent' ELSE 'UBLContent' ).
          ASSIGN COMPONENT lv_field OF STRUCTURE <ls_output> TO FIELD-SYMBOL(<lv_content>).
          CHECK Sy-subrc = 0.
          SELECT SINGLE contn
            FROM zetr_t_arcd
            WHERE docui = @<ls_output>-DocumentUUID
              AND conty = @lv_conty
            INTO @DATA(lv_content).
          IF lv_content IS INITIAL.
            TRY.
                DATA(lo_invoice_operations) = zcl_etr_invoice_operations=>factory( <ls_output>-companycode ).
                lv_content = lo_invoice_operations->outgoing_invoice_download( iv_document_uid = <ls_output>-DocumentUUID
                                                                               iv_content_type = lv_conty
                                                                               iv_create_log = abap_false ).
                <lv_content> = cl_abap_conv_codepage=>create_in( )->convert( source = lv_content ).
              CATCH zcx_etr_regulative_exception INTO DATA(lx_etr_regulative_exception).
                lv_content = cl_abap_conv_codepage=>create_out( )->convert( replace( val = '<html><body><h1>Hata Olustu / Error Occured</h1>' &&
                                                                                           '<p>' && lx_etr_regulative_exception->get_text( ) && '</p>' &&
                                                                                           '<p>' && xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->as( xco_cp_time=>format->iso_8601_extended )->value && '</p>' &&
                                                                                           '<p>' && <ls_output>-DocumentNumber && '</p>' &&
                                                                                           '</body></html>'
                                                                                            sub = |\n|
                                                                                            with = ``
                                                                                            occ = 0  ) ).
                <lv_content> = cl_abap_conv_codepage=>create_in( )->convert( source = lv_content ).
            ENDTRY.
          ELSE.
            <lv_content> = cl_abap_conv_codepage=>create_in( )->convert( source = lv_content ).
          ENDIF.
        ENDDO.
      ENDIF.
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_output ).
  ENDMETHOD.