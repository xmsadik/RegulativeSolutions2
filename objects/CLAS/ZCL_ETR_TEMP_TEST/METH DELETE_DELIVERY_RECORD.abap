  METHOD delete_delivery_record.

    rv_success = abap_false.

    IF iv_belnr IS INITIAL OR iv_docui IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_confirm_delete = abap_false.
      RETURN.
    ENDIF.

    SELECT SINGLE *
      FROM zetr_t_ogdlv
      WHERE docui = @iv_docui
        AND belnr = @iv_belnr
      INTO @DATA(ls_record).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DELETE FROM zetr_t_ogdlv
      WHERE docui = @iv_docui
        AND belnr = @iv_belnr.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      rv_success = abap_true.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDMETHOD.