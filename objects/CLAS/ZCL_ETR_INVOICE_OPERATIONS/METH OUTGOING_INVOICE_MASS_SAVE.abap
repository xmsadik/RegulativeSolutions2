  METHOD outgoing_invoice_mass_save.
    TYPES: BEGIN OF ty_invoice,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             awtyp TYPE zetr_e_awtyp,
           END OF ty_invoice.
    DATA(ls_selection) = is_selection.
    DATA: lt_invoices     TYPE STANDARD TABLE OF ty_invoice,
          ls_invoice      TYPE ty_invoice,
          ls_invoice_prev TYPE ty_invoice,
          lv_bukrs        TYPE bukrs,
          ls_return       TYPE bapiret2,
          ls_document     TYPE zetr_t_oginv,
          lt_docui_range  TYPE RANGE OF zetr_e_docui.

    IF ls_selection-bukrs IS INITIAL.
      SELECT 'I' AS sign,
             'EQ' AS option,
             bukrs AS low,
             ' ' AS high
        FROM zetr_t_cmpin
        INTO TABLE @ls_selection-bukrs.
    ENDIF.

    IF ls_selection-belnr IS INITIAL AND
       ls_selection-gjahr IS INITIAL AND
       ls_selection-sddty IS INITIAL AND
       ls_selection-mmdty IS INITIAL AND
       ls_selection-fidty IS INITIAL AND
       ls_selection-bldat IS INITIAL AND
       ls_selection-ernam IS INITIAL AND
       ls_selection-erdat IS INITIAL.
      ls_selection-erdat = VALUE #( ( sign = 'I' option = 'EQ' low = cl_abap_context_info=>get_system_date( ) ) ).

      IF 'VBRK' IN ls_selection-awtyp.
        SELECT 'I' AS sign,
               'EQ' AS option,
               sddty AS low,
               ' ' AS high
          FROM zetr_t_eirules
          WHERE rulet = 'P'
            AND awtyp = 'VBRK'
            AND excld = ''

          UNION DISTINCT

          SELECT 'I' AS sign,
               'EQ' AS option,
               sddty AS low,
               ' ' AS high
          FROM zetr_t_earules
          WHERE rulet = 'P'
            AND awtyp = 'VBRK'
            AND excld = ''

          INTO TABLE @ls_selection-sddty.
        DELETE ls_selection-sddty WHERE low IS INITIAL.
      ENDIF.

      IF 'RMRP' IN ls_selection-awtyp.
        SELECT 'I' AS sign,
               'EQ' AS option,
               mmdty AS low,
               ' ' AS high
          FROM zetr_t_eirules
          WHERE rulet = 'P'
            AND awtyp = 'RMRP'
            AND excld = ''

          UNION DISTINCT

          SELECT 'I' AS sign,
               'EQ' AS option,
               mmdty AS low,
               ' ' AS high
          FROM zetr_t_earules
          WHERE rulet = 'P'
            AND awtyp = 'RMRP'
            AND excld = ''

          INTO TABLE @ls_selection-mmdty.
        DELETE ls_selection-mmdty WHERE low IS INITIAL.
      ENDIF.

      IF 'BKPF' IN ls_selection-awtyp.
        SELECT 'I' AS sign,
               'EQ' AS option,
               fidty AS low,
               ' ' AS high
          FROM zetr_t_eirules
          WHERE rulet = 'P'
            AND awtyp = 'BKPF'
            AND excld = ''

          UNION DISTINCT

          SELECT 'I' AS sign,
               'EQ' AS option,
               fidty AS low,
               ' ' AS high
          FROM zetr_t_earules
          WHERE rulet = 'P'
            AND awtyp = 'BKPF'
            AND excld = ''

          INTO TABLE @ls_selection-fidty.
        DELETE ls_selection-fidty WHERE low IS INITIAL.
      ENDIF.
    ENDIF.

    LOOP AT ls_selection-bukrs INTO DATA(ls_bukrs).
      APPEND INITIAL LINE TO et_logs ASSIGNING FIELD-SYMBOL(<ls_log>).
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Company Code->'.
      <ls_log>-message_v2 = ls_bukrs-sign && ls_bukrs-option && ls_bukrs-low && ls_bukrs-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-belnr INTO DATA(ls_belnr).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Document Number->'.
      <ls_log>-message_v2 = ls_belnr-sign && ls_belnr-option && ls_belnr-low && ls_belnr-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-gjahr INTO DATA(ls_gjahr).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Fiscal Year->'.
      <ls_log>-message_v2 = ls_gjahr-sign && ls_gjahr-option && ls_gjahr-low && ls_gjahr-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-awtyp INTO DATA(ls_awtyp).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Ref.Doc.Type->'.
      <ls_log>-message_v2 = ls_awtyp-sign && ls_awtyp-option && ls_awtyp-low && ls_awtyp-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-sddty INTO DATA(ls_sddty).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : SD Doc.Type->'.
      <ls_log>-message_v2 = ls_sddty-sign && ls_sddty-option && ls_sddty-low && ls_sddty-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-mmdty INTO DATA(ls_mmdty).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : MM Doc.Type->'.
      <ls_log>-message_v2 = ls_mmdty-sign && ls_mmdty-option && ls_mmdty-low && ls_mmdty-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-fidty INTO DATA(ls_fidty).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : FI Doc.Type->'.
      <ls_log>-message_v2 = ls_fidty-sign && ls_fidty-option && ls_fidty-low && ls_fidty-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-ernam INTO DATA(ls_ernam).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Created By->'.
      <ls_log>-message_v2 = ls_ernam-sign && ls_ernam-option && ls_ernam-low && ls_ernam-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-erdat INTO DATA(ls_erdat).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Created At->'.
      <ls_log>-message_v2 = ls_erdat-sign && ls_erdat-option && ls_erdat-low && ls_erdat-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.
    LOOP AT ls_selection-bldat INTO DATA(ls_bldat).
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-information.
      <ls_log>-number = '000'.
      <ls_log>-message_v1 = 'Parameter : Document Date->'.
      <ls_log>-message_v2 = ls_bldat-sign && ls_bldat-option && ls_bldat-low && ls_bldat-high.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
    ENDLOOP.

    IF 'BKPF' IN ls_selection-awtyp.
      SELECT companycode AS bukrs,
             accountingdocument AS belnr,
             fiscalyear AS gjahr,
             referencedocumenttype AS awtyp
        FROM i_journalentry AS bkpf
        WHERE companycode IN @ls_selection-bukrs
          AND accountingdocument IN @ls_selection-belnr
          AND fiscalyear IN @ls_selection-gjahr
          AND referencedocumenttype IN ('BKPF','BKPFF','REACI')
          AND accountingdocumenttype IN @ls_selection-fidty
          AND documentdate IN @ls_selection-bldat
          AND accountingdocumentcreationdate IN @ls_selection-erdat
          AND accountingdoccreatedbyuser IN @ls_selection-ernam
          AND isreversal = ''
          AND isreversed = ''
          AND NOT EXISTS ( SELECT docui FROM zetr_t_oginv AS oginv
                             WHERE oginv~bukrs = bkpf~companycode
                               AND oginv~belnr = bkpf~accountingdocument
                               AND oginv~gjahr = bkpf~fiscalyear
                               AND oginv~awtyp = 'BKPF' )
        INTO TABLE @lt_invoices.
    ENDIF.

    IF 'VBRK' IN ls_selection-awtyp.
      SELECT vbrk~companycode AS bukrs,
             vbrk~billingdocument AS belnr,
             CAST( left( vbrk~billingdocumentdate, 4 ) AS NUMC ) AS gjahr,
             'VBRK' AS awtyp
        FROM i_billingdocument AS vbrk
        WHERE vbrk~companycode IN @ls_selection-bukrs
          AND vbrk~billingdocument IN @ls_selection-belnr
          AND CAST( left( vbrk~billingdocumentdate, 4 ) AS NUMC ) IN @ls_selection-gjahr
          AND vbrk~billingdocumenttype IN @ls_selection-sddty
          AND vbrk~creationdate IN @ls_selection-erdat
          AND vbrk~createdbyuser IN @ls_selection-ernam
          AND vbrk~billingdocumentiscancelled = ''
          AND vbrk~cancelledbillingdocument = ''
          AND NOT EXISTS ( SELECT docui FROM zetr_t_oginv AS oginv
                             WHERE oginv~belnr = vbrk~billingdocument
                               AND oginv~awtyp = 'VBRK' )
        APPENDING TABLE @lt_invoices.
    ENDIF.

    IF 'RMRP' IN ls_selection-awtyp.
      SELECT companycode AS bukrs,
             supplierinvoice AS belnr,
             fiscalyear AS gjahr,
             'RMRP' AS awtyp
        FROM i_supplierinvoiceapi01 AS rbkp
        WHERE companycode IN @ls_selection-bukrs
          AND supplierinvoice IN @ls_selection-belnr
          AND fiscalyear IN @ls_selection-gjahr
          AND accountingdocumenttype IN @ls_selection-mmdty
          AND documentdate IN @ls_selection-bldat
          AND creationdate IN @ls_selection-erdat
          AND createdbyuser IN @ls_selection-ernam
          AND reversedocument = ''
          AND NOT EXISTS ( SELECT docui FROM zetr_t_oginv AS oginv
                             WHERE oginv~belnr = rbkp~supplierinvoice
                               AND oginv~gjahr = rbkp~fiscalyear
                               AND oginv~awtyp = 'RMRP' )
        APPENDING TABLE @lt_invoices.
    ENDIF.

    SELECT *
      FROM zetr_ddl_vh_refdoc_type
      WHERE RefDocType IN @ls_selection-awtyp
      INTO TABLE @DATA(lt_refdoc_types).

    IF lt_invoices IS NOT INITIAL.
      SORT lt_invoices STABLE BY bukrs belnr gjahr awtyp.
      DELETE ADJACENT DUPLICATES FROM lt_invoices COMPARING bukrs belnr gjahr awtyp.
      LOOP AT lt_invoices INTO ls_invoice.
        IF iv_max_count IS NOT INITIAL AND sy-tabix > iv_max_count.
          EXIT.
        ENDIF.
        IF ls_invoice-awtyp = ls_invoice_prev-awtyp AND
           ls_invoice-bukrs = ls_invoice_prev-bukrs AND
           ls_invoice-belnr = ls_invoice_prev-belnr AND
           ls_invoice-gjahr = ls_invoice_prev-gjahr.
          CONTINUE.
        ENDIF.
        ls_invoice_prev = ls_invoice.
        SELECT COUNT( * )
          FROM zetr_t_oginv
          WHERE bukrs = @ls_invoice-bukrs
            AND awtyp = @ls_invoice-awtyp
            AND belnr = @ls_invoice-belnr
            AND gjahr = @ls_invoice-gjahr.
        IF sy-subrc = 0.
          APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
          <ls_log>-id = 'ZETR_COMMON'.
          <ls_log>-type = if_abap_behv_message=>severity-information.
          <ls_log>-number = '037'.
          MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
            WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
            INTO <ls_log>-message.
          CONTINUE.
        ENDIF.

        TRY.
            IF lv_bukrs <> ls_invoice-bukrs.
              lv_bukrs = ls_invoice-bukrs.
              DATA(lo_invoice_operations) = zcl_etr_invoice_operations=>factory( ls_invoice-bukrs ).
            ENDIF.

            APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
            <ls_log>-id = 'ZETR_COMMON'.
            <ls_log>-type = if_abap_behv_message=>severity-information.
            <ls_log>-number = '015'.
            <ls_log>-message_v1 = ls_invoice-awtyp.
            <ls_log>-message_v2 = ls_invoice-bukrs.
            <ls_log>-message_v3 = ls_invoice-belnr.
            <ls_log>-message_v4 = ls_invoice-gjahr.
            MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
              WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
              INTO <ls_log>-message.

            CLEAR: ls_return, ls_document.
            lo_invoice_operations->outgoing_invoice_save(
              EXPORTING
                iv_awtyp    = ls_invoice-awtyp
                iv_bukrs    = ls_invoice-bukrs
                iv_belnr    = ls_invoice-belnr
                iv_gjahr    = ls_invoice-gjahr
                iv_svsrc    = iv_save_source
              IMPORTING
                es_return   = ls_return
              RECEIVING
                rs_document = ls_document ).

            IF ls_document IS NOT INITIAL.
              APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
              <ls_log>-id = 'ZETR_COMMON'.
              <ls_log>-type = if_abap_behv_message=>severity-success.
              <ls_log>-number = '073'.
              MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
                WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
                INTO <ls_log>-message.

              APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_document-docui ) TO lt_docui_range.
            ELSE.
              APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
              <ls_log>-id = 'ZETR_COMMON'.
              <ls_log>-type = if_abap_behv_message=>severity-warning.
              <ls_log>-number = '212'.
              MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
                WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
                INTO <ls_log>-message.
              IF ls_return IS NOT INITIAL.
                APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
                <ls_log>-id = ls_return-id.
                <ls_log>-type = SWITCH #( ls_return-type
                                             WHEN 'E' THEN if_bali_constants=>c_severity_error
                                             WHEN 'W' THEN if_bali_constants=>c_severity_warning
                                             WHEN 'I' THEN if_bali_constants=>c_severity_information
                                             WHEN 'S' THEN if_bali_constants=>c_severity_status
                                             ELSE if_bali_constants=>c_severity_error ).
                <ls_log>-number = ls_return-number.
                <ls_log>-message_v1 = ls_return-message_v1.
                <ls_log>-message_v2 = ls_return-message_v2.
                <ls_log>-message_v3 = ls_return-message_v3.
                <ls_log>-message_v4 = ls_return-message_v4.
                MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
                  WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
                  INTO <ls_log>-message.
              ENDIF.
              APPEND INITIAL LINE TO et_invoices ASSIGNING FIELD-SYMBOL(<ls_invoice>).
              <ls_invoice>-bukrs = ls_invoice-bukrs.
              <ls_invoice>-belnr = ls_invoice-belnr.
              <ls_invoice>-gjahr = ls_invoice-gjahr.
              <ls_invoice>-awtyp = ls_invoice-awtyp(4).
              <ls_invoice>-awtyp_text = lt_refdoc_types[ RefDocType = ls_invoice-awtyp(4) ].
              <ls_invoice>-status = <ls_log>-message.
              <ls_invoice>-status_criticality = 1.
            ENDIF.

          CATCH zcx_etr_regulative_exception INTO DATA(lx_regulative_exception).
            APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
            <ls_log>-message = lx_regulative_exception->get_text( ).
            <ls_log>-id = 'ZETR_COMMON'.
            <ls_log>-type = if_abap_behv_message=>severity-error.
            <ls_log>-number = '000'.
            <ls_log>-message_v1 = <ls_log>-message+0(50).
            <ls_log>-message_v2 = <ls_log>-message+50(50).
            <ls_log>-message_v3 = <ls_log>-message+100(50).
            <ls_log>-message_v4 = <ls_log>-message+150(*).
        ENDTRY.
      ENDLOOP.

      IF lt_docui_range IS NOT INITIAL.
        SELECT companycode AS bukrs ,
               documentnumber AS belnr ,
               fiscalyear AS gjahr ,
               documenttype AS awtyp ,
               documenttypetext AS awtyp_text,
               partnernumber AS partner,
               partnername AS partner_name,
               taxid,
               documentdate AS bldat,
               referencedocumenttype AS docty,
               referencedocumenttypetext AS docty_text,
               amount AS wrbtr,
               taxamount AS fwste,
               exchangerate AS kursf,
               currency AS waers,
               profileid AS prfid,
               invoicetype AS invty,
               createdby AS ernam,
               createdate AS erdat,
               createtime AS erzet
          FROM zetr_ddl_i_outgoing_invoices
          WHERE documentuuid IN @lt_docui_range
          INTO TABLE @DATA(Lt_saved_invoices).
        LOOP AT lt_saved_invoices INTO DATA(ls_saved_invoice).
          APPEND INITIAL LINE TO et_invoices ASSIGNING <ls_invoice>.
          <ls_invoice> = CORRESPONDING #( ls_saved_invoice ).
          <ls_invoice>-status = 'Saved'.
          <ls_invoice>-status_criticality = 3.
        ENDLOOP.

        DATA(lv_saved_records) = lines( lt_saved_invoices ).
        APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
        <ls_log>-id = 'ZETR_COMMON'.
        <ls_log>-type = if_abap_behv_message=>severity-warning.
        <ls_log>-number = '082'.
        <ls_log>-message_v1 = CONV #( lv_saved_records ).
        MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
          WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
          INTO <ls_log>-message.
      ENDIF.
    ELSE.
      APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
      <ls_log>-id = 'ZETR_COMMON'.
      <ls_log>-type = if_abap_behv_message=>severity-warning.
      <ls_log>-number = '005'.
      MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
        WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
        INTO <ls_log>-message.
      RETURN.
    ENDIF.

  ENDMETHOD.