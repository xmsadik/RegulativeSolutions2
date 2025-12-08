  METHOD outgoing_delivery_mass_save.
    TYPES: BEGIN OF ty_delivery,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             awtyp TYPE zetr_e_awtyp,
           END OF ty_delivery.
    DATA(ls_selection) = is_selection.
    DATA: lt_deliveries    TYPE STANDARD TABLE OF ty_delivery,
          ls_delivery_prev TYPE ty_delivery,
          ls_delivery      TYPE ty_delivery,
          lv_bukrs         TYPE bukrs,
          ls_return        TYPE bapiret2,
          ls_document      TYPE zetr_t_ogdlv,
          lt_docui_range   TYPE RANGE OF zetr_e_docui.

    IF ls_selection-bukrs IS INITIAL.
      SELECT 'I' AS sign,
             'EQ' AS option,
             bukrs AS low,
             ' ' AS high
        FROM zetr_t_edpar
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

      IF 'LIKP' IN ls_selection-awtyp.
        SELECT 'I' AS sign,
               'EQ' AS option,
               sddty AS low,
               ' ' AS high
          FROM zetr_t_edrules
          WHERE rulet = 'P'
            AND awtyp = 'LIKP'
            AND excld = ''

          INTO TABLE @ls_selection-sddty.
        DELETE ls_selection-sddty WHERE low IS INITIAL.
      ENDIF.

      IF 'MKPF' IN ls_selection-awtyp.
        SELECT 'I' AS sign,
               'EQ' AS option,
               mmdty AS low,
               ' ' AS high
          FROM zetr_t_edrules
          WHERE rulet = 'P'
            AND awtyp = 'MKPF'
            AND excld = ''
          INTO TABLE @ls_selection-mmdty.
        DELETE ls_selection-mmdty WHERE low IS INITIAL.
      ENDIF.

      IF 'BKPF' IN ls_selection-awtyp.
        SELECT 'I' AS sign,
               'EQ' AS option,
               fidty AS low,
               ' ' AS high
          FROM zetr_t_edrules
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
          AND NOT EXISTS ( SELECT docui FROM zetr_t_ogdlv
                             WHERE bukrs = bkpf~companycode
                               AND belnr = bkpf~accountingdocument
                               AND gjahr = bkpf~fiscalyear
                               AND awtyp = 'BKPF' )
        INTO TABLE @lt_deliveries.
    ENDIF.

    IF 'LIKP' IN ls_selection-awtyp.
      SELECT s~CompanyCode AS bukrs,
             d~DeliveryDocument AS belnr,
             CAST( left( DocumentDate, 4 ) AS NUMC ) AS gjahr,
             'LIKP' AS awtyp
        FROM i_deliverydocument AS d
        INNER JOIN i_salesorganization AS s
          ON d~salesorganization = s~salesorganization
        WHERE companycode IN @ls_selection-bukrs
          AND DeliveryDocument IN @ls_selection-belnr
          AND CAST( left( billingdocumentdate, 4 ) AS NUMC ) IN @ls_selection-gjahr
          AND deliverydocumenttype IN @ls_selection-sddty
          AND creationdate IN @ls_selection-erdat
          AND createdbyuser IN @ls_selection-ernam
          AND NOT EXISTS ( SELECT docui FROM zetr_t_ogdlv
                            WHERE belnr = d~DeliveryDocument
                              AND awtyp = 'LIKP' )
        APPENDING TABLE @lt_deliveries.
    ENDIF.

    IF 'MKPF' IN ls_selection-awtyp.
      SELECT DISTINCT
             i~companycode AS bukrs,
             m~MaterialDocument AS belnr,
             m~MaterialDocumentYear AS gjahr,
             'MKPF' AS awtyp
        FROM I_MaterialDocumentHeader_2 AS m
        INNER JOIN i_materialdocumentitem_2 AS i
          ON  m~MaterialDocument = i~MaterialDocument
          AND m~MaterialDocumentYear = i~MaterialDocumentYear
        WHERE i~companycode IN @ls_selection-bukrs
          AND m~MaterialDocument IN @ls_selection-belnr
          AND m~MaterialDocumentYear IN @ls_selection-gjahr
          AND m~accountingdocumenttype IN @ls_selection-mmdty
          AND m~creationdate IN @ls_selection-erdat
          AND m~createdbyuser IN @ls_selection-ernam
          AND i~GoodsMovementIsCancelled = ''
          AND NOT EXISTS ( SELECT docui FROM zetr_t_ogdlv
                             WHERE belnr = m~MaterialDocument
                               AND gjahr = m~MaterialDocumentYear
                               AND awtyp = 'MKPF' )
        APPENDING TABLE @lt_deliveries.
    ENDIF.

    SELECT *
      FROM zetr_ddl_vh_refdoc_type
      WHERE RefDocType IN @ls_selection-awtyp
      INTO TABLE @DATA(lt_refdoc_types).

    IF lt_deliveries IS NOT INITIAL.
      SORT lt_deliveries STABLE BY bukrs belnr gjahr awtyp.
      DELETE ADJACENT DUPLICATES FROM lt_deliveries COMPARING bukrs belnr gjahr awtyp.
      LOOP AT lt_deliveries INTO ls_delivery.
        IF iv_max_count IS NOT INITIAL AND sy-tabix > iv_max_count.
          EXIT.
        ENDIF.
        IF ls_delivery-bukrs = ls_delivery_prev-bukrs AND
           ls_delivery-belnr = ls_delivery_prev-belnr AND
           ls_delivery-gjahr = ls_delivery_prev-gjahr AND
           ls_delivery-awtyp = ls_delivery_prev-awtyp.
          CONTINUE.
        ENDIF.
        ls_delivery_prev = ls_delivery.
        SELECT COUNT( * )
          FROM zetr_t_ogdlv
          WHERE bukrs = @ls_delivery-bukrs
            AND awtyp = @ls_delivery-awtyp
            AND belnr = @ls_delivery-belnr
            AND gjahr = @ls_delivery-gjahr.
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
            IF lv_bukrs <> ls_delivery-bukrs.
              lv_bukrs = ls_delivery-bukrs.
              DATA(lo_delivery_operations) = zcl_etr_delivery_operations=>factory( ls_delivery-bukrs ).
            ENDIF.

            APPEND INITIAL LINE TO et_logs ASSIGNING <ls_log>.
            <ls_log>-id = 'ZETR_COMMON'.
            <ls_log>-type = if_abap_behv_message=>severity-information.
            <ls_log>-number = '015'.
            <ls_log>-message_v1 = ls_delivery-awtyp.
            <ls_log>-message_v2 = ls_delivery-bukrs.
            <ls_log>-message_v3 = ls_delivery-belnr.
            <ls_log>-message_v4 = ls_delivery-gjahr.
            MESSAGE ID <ls_log>-id TYPE <ls_log>-type NUMBER <ls_log>-number
              WITH <ls_log>-message_v1 <ls_log>-message_v2 <ls_log>-message_v3 <ls_log>-message_v4
              INTO <ls_log>-message.

            CLEAR: ls_return, ls_document.
            lo_delivery_operations->outgoing_delivery_save(
              EXPORTING
                iv_awtyp    = ls_delivery-awtyp
                iv_bukrs    = ls_delivery-bukrs
                iv_belnr    = ls_delivery-belnr
                iv_gjahr    = ls_delivery-gjahr
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
              APPEND INITIAL LINE TO et_deliveries ASSIGNING FIELD-SYMBOL(<ls_delivery>).
              <ls_delivery>-bukrs = ls_delivery-bukrs.
              <ls_delivery>-belnr = ls_delivery-belnr.
              <ls_delivery>-gjahr = ls_delivery-gjahr.
              <ls_delivery>-awtyp = ls_delivery-awtyp(4).
              <ls_delivery>-awtyp_text = lt_refdoc_types[ RefDocType = ls_delivery-awtyp(4) ].
              <ls_delivery>-status = <ls_log>-message.
              <ls_delivery>-status_criticality = 1.
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
               profileid AS prfid,
               deliverytype AS dlvty,
               createdby AS ernam,
               createdate AS erdat,
               createtime AS erzet
          FROM zetr_ddl_i_outgoing_deliveries
          WHERE documentuuid IN @lt_docui_range
          INTO TABLE @DATA(Lt_saved_deliveries).
        LOOP AT Lt_saved_deliveries INTO DATA(ls_saved_delivery).
          APPEND INITIAL LINE TO et_deliveries ASSIGNING <ls_delivery>.
          <ls_delivery> = CORRESPONDING #( ls_saved_delivery ).
          <ls_delivery>-status = 'Saved'.
          <ls_delivery>-status_criticality = 3.
        ENDLOOP.

        DATA(lv_saved_records) = lines( Lt_saved_deliveries ).
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