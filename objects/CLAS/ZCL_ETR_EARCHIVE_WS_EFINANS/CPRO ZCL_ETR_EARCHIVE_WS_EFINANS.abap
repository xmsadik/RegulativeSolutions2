  PROTECTED SECTION.
    METHODS get_incoming_archives_int
      IMPORTING
        !iv_date_from       TYPE begda
        !iv_date_to         TYPE endda
        !iv_import_received TYPE zetr_e_imrec OPTIONAL
        !iv_invoice_uuid    TYPE zetr_e_duich OPTIONAL
      RETURNING
        VALUE(rt_invoices)  TYPE mty_incoming_documents
      RAISING
        zcx_etr_regulative_exception.
