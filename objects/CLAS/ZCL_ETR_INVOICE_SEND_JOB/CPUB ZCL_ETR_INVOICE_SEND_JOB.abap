CLASS zcl_etr_invoice_send_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES BEGIN OF mty_invoice_line.
    TYPES CompanyCode TYPE bukrs.
    TYPES DocumentNumber TYPE belnr_d.
    TYPES FiscalYear TYPE gjahr.
    TYPES ProfileID TYPE zetr_e_inprf.
    TYPES StatusDetail TYPE zetr_e_staex.
    TYPES END OF MTY_INVOICE_LIne.
    TYPES mty_invoice_list TYPE STANDARD TABLE OF mty_invoice_line.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .