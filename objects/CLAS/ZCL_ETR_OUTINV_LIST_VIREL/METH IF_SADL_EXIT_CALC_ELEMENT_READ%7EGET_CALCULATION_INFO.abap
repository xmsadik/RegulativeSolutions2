  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    INSERT `DOCUMENTUUID` INTO TABLE et_requested_orig_elements.
    INSERT `DOCUMENTNUMBER` INTO TABLE et_requested_orig_elements.
    INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
    INSERT `FISCALYEAR` INTO TABLE et_requested_orig_elements.
    INSERT `DOCUMENTTYPE` INTO TABLE et_requested_orig_elements.
    INSERT `STATUSCODE` INTO TABLE et_requested_orig_elements.

    LOOP AT it_requested_calc_elements INTO DATA(lv_element).
      CASE lv_element.
        WHEN 'REVERSED'.
          INSERT `REVERSEDINTERNAL` INTO TABLE et_requested_orig_elements.
        WHEN 'STATUSCRITICALITY'.
          INSERT `STATUSCRITICALITYINTERNAL` INTO TABLE et_requested_orig_elements.
        WHEN 'OVERALLSTATUS'.
          INSERT `OVERALLSTATUSINTERNAL` INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.