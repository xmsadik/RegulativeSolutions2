CLASS zcl_etr_delivery_send_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES BEGIN OF mty_delivery_line.
    TYPES CompanyCode TYPE bukrs.
    TYPES DocumentNumber TYPE belnr_d.
    TYPES FiscalYear TYPE gjahr.
    TYPES ProfileID TYPE zetr_e_inprf.
    TYPES StatusDetail TYPE zetr_e_staex.
    TYPES END OF mty_delivery_line.
    TYPES mty_delivery_list TYPE STANDARD TABLE OF mty_delivery_line.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .