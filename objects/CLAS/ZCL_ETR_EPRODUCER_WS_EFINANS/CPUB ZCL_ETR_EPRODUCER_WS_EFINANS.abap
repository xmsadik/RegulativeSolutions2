CLASS zcl_etr_eproducer_ws_efinans DEFINITION
  PUBLIC
  INHERITING FROM zcl_etr_eproducer_ws
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS mc_erpcode_parameter TYPE zetr_e_cuspa VALUE 'ERPCODE' ##NO_TEXT.
    METHODS:
      outgoing_invoice_send REDEFINITION,
      outgoing_invoice_get_status REDEFINITION,
      outgoing_invoice_download REDEFINITION,
      outgoing_invoice_cancel REDEFINITION.