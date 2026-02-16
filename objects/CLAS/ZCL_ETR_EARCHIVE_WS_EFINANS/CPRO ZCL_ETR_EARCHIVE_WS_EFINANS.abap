  PROTECTED SECTION.
    METHODS get_incoming_invoices_int
      IMPORTING
        !iv_date_from       TYPE begda
        !iv_date_to         TYPE endda
        !iv_import_received TYPE zetr_e_imrec OPTIONAL
        !iv_invoice_uuid    TYPE zetr_e_duich OPTIONAL
      RETURNING
        VALUE(rt_invoices)  TYPE mty_incoming_documents
      RAISING
        zcx_etr_regulative_exception.
    METHODS incoming_invoice_get_fields2
      IMPORTING
        it_xml_table TYPE zcl_etr_json_xml_tools=>ty_xml_structure_table
      CHANGING
        cs_invoice   TYPE zetr_t_icinv
        ct_items     TYPE mty_incoming_items.
