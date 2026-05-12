  METHOD get_incoming_invoices.
    DATA: lt_service_return TYPE mty_incoming_documents,
          lt_icinv          TYPE TABLE OF zetr_t_icinv,
          lv_tabix          TYPE sy-tabix.

    FIELD-SYMBOLS: <ls_service_return> TYPE mty_incoming_document,
                   <ls_list>           TYPE zetr_t_icinv.


    lt_service_return = get_incoming_invoices_int( iv_date_from = iv_date_from
                                                   iv_date_to = iv_date_to ).

    IF lt_service_return[] IS NOT INITIAL.
      SELECT *
        FROM zetr_t_icinv
        FOR ALL ENTRIES IN @lt_service_return
        WHERE  invno = @lt_service_return-faturano
           AND taxid = @lt_service_return-mukellefvkn
           AND bukrs = @ms_company_parameters-bukrs
        INTO TABLE @lt_icinv.

      LOOP AT lt_service_return ASSIGNING <ls_service_return>.
        lv_tabix = sy-tabix.
        READ TABLE lt_icinv TRANSPORTING NO FIELDS WITH KEY invno = <ls_service_return>-faturano
                                                            taxid = <ls_service_return>-mukellefvkn.
        IF sy-subrc EQ 0 .
          DELETE lt_service_return INDEX lv_tabix.
        ELSE.
          TRY.
              DATA(lv_uuid) = cl_system_uuid=>create_uuid_c22_static( ).
              APPEND INITIAL LINE TO rt_list ASSIGNING <ls_list>.
              <ls_list>-docui = lv_uuid.
            CATCH cx_uuid_error.
              CONTINUE.
          ENDTRY.
          <ls_list>-invno = <ls_service_return>-faturano.
          IF <ls_service_return>-duzenlenmetarihi IS NOT INITIAL.
            <ls_list>-bldat = <ls_service_return>-duzenlenmetarihi+0(8).
          ENDIF.
          <ls_list>-recdt = <ls_service_return>-insertdate.
          <ls_list>-bukrs = ms_company_parameters-bukrs.
          <ls_list>-taxid = <ls_service_return>-mukellefvkn.
          <ls_list>-wrbtr = <ls_service_return>-odenecektutar.
          <ls_list>-waers = <ls_service_return>-parabirimi.
          <ls_list>-fwste = <ls_service_return>-vergilertutari.
          <ls_list>-prfid = 'EARSIV'.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.