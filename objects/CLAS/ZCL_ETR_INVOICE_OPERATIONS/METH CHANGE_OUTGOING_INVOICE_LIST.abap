  METHOD change_outgoing_invoice_list.
    IF line_exists( it_requested_calc_elements[ table_line = 'DOCUMENTDISPLAYURL' ] ).
      cs_list_output-DocumentDisplayURL = 'https://' && zcl_etr_regulative_common=>get_ui_url( ) && '/ui#'.
      CASE cs_list_output-DocumentType(4).
        WHEN 'VBRK'.
          cs_list_output-DocumentDisplayURL = cs_list_output-DocumentDisplayURL &&
                                           'BillingDocument-displayBillingDocument?BillingDocument=' && cs_list_output-DocumentNumber.
        WHEN 'MKPF'.
          cs_list_output-DocumentDisplayURL = cs_list_output-DocumentDisplayURL &&
                                           'SupplierInvoice-displayAdvanced?SupplierInvoice=' && cs_list_output-DocumentNumber &&
                                           '&FiscalYear=' && cs_list_output-FiscalYear.
        WHEN 'BKPF'.
          cs_list_output-DocumentDisplayURL = cs_list_output-DocumentDisplayURL &&
                                           'GLAccount-displayGLLineItemReportingView?AccountingDocument=' && cs_list_output-DocumentNumber &&
                                           '&CompanyCode=' && cs_list_output-CompanyCode &&
                                           '&FiscalYear=' && cs_list_output-FiscalYear.
      ENDCASE.
    ENDIF.

    IF line_exists( it_requested_calc_elements[ table_line = 'REVERSED' ] ) OR
       line_exists( it_requested_calc_elements[ table_line = 'STATUSCRITICALITY' ] ) OR
       line_exists( it_requested_calc_elements[ table_line = 'OVERALLSTATUS' ] ).
      cs_list_output-StatusCriticality = cs_list_output-StatusCriticalityInternal.
      cs_list_output-Reversed = cs_list_output-ReversedInternal.
      cs_list_output-OverallStatus = cs_list_output-OverallStatusInternal.
    ENDIF.

    IF line_exists( it_requested_calc_elements[ table_line = 'PDFCONTENTURL' ] ) OR
       line_exists( it_requested_calc_elements[ table_line = 'HTMLCONTENTURL' ] ) OR
       line_exists( it_requested_calc_elements[ table_line = 'UBLCONTENTURL' ] ).
      TRY.
          cl_system_uuid=>convert_uuid_c22_static(
            EXPORTING
              uuid = cs_list_output-documentuuid
            IMPORTING
              uuid_c36 = DATA(lv_uuid) ).
        CATCH cx_uuid_error.
      ENDTRY.
      cs_list_output-PDFContentUrl = "'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                                  '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' &&
                                  lv_uuid && ''',ContentType=''PDF'',DocumentType=''OUTINVDOC'')/$value'.
      cs_list_output-HTMLContentUrl = "'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                                  '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' &&
                                  lv_uuid && ''',ContentType=''HTML'',DocumentType=''OUTINVDOC'')/$value'.
      cs_list_output-UBLContentUrl = "'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                                  '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' &&
                                  lv_uuid && ''',ContentType=''UBL'',DocumentType=''OUTINVDOC'')/$value'.
    ENDIF.

    IF line_exists( it_requested_calc_elements[ table_line = 'HTMLCONTENT' ] ) OR
       line_exists( it_requested_calc_elements[ table_line = 'UBLCONTENT' ] ).
      CLEAR: cs_list_output-HTMLContent, cs_list_output-UBLContent.
      DO 2 TIMES.
        DATA(lv_conty) = COND zetr_e_dctyp( WHEN sy-index = 1 THEN 'HTML' ELSE 'UBL' ).
        DATA(lv_field) = COND string( WHEN sy-index = 1 THEN 'HTMLContent' ELSE 'UBLContent' ).
        ASSIGN COMPONENT lv_field OF STRUCTURE cs_list_output TO FIELD-SYMBOL(<lv_content>).
        CHECK Sy-subrc = 0.
        SELECT SINGLE contn
          FROM zetr_t_arcd
          WHERE docui = @cs_list_output-DocumentUUID
            AND conty = @lv_conty
          INTO @DATA(lv_content).
        IF lv_content IS INITIAL.
          TRY.
              lv_content = outgoing_invoice_download( iv_document_uid = cs_list_output-DocumentUUID
                                                      iv_content_type = lv_conty
                                                      iv_create_log = abap_false ).
              <lv_content> = cl_abap_conv_codepage=>create_in( )->convert( source = lv_content ).
            CATCH zcx_etr_regulative_exception INTO DATA(lx_etr_regulative_exception).
              lv_content = cl_abap_conv_codepage=>create_out( )->convert( replace( val = '<html><body><h1>Hata Olustu / Error Occured</h1>' &&
                                                                                         '<p>' && lx_etr_regulative_exception->get_text( ) && '</p>' &&
                                                                                         '<p>' && xco_cp=>sy->moment( xco_cp_time=>time_zone->user )->as( xco_cp_time=>format->iso_8601_extended )->value && '</p>' &&
                                                                                         '<p>' && cs_list_output-DocumentNumber && '</p>' &&
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
  ENDMETHOD.