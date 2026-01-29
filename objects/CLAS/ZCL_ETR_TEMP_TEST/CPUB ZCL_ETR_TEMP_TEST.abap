CLASS zcl_etr_temp_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS delete_delivery_record
      IMPORTING
        iv_belnr          TYPE belnr_d
        iv_docui          TYPE sysuuid_c22
        iv_confirm_delete TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_success) TYPE abap_bool
      RAISING
        cx_static_check.

    TYPES ty_manup TYPE zetr_e_edf_manually_uploaded.

    METHODS set_manual_upload
      IMPORTING
        iv_is_manual    TYPE abap_boolean
      RETURNING
        VALUE(rv_manup) TYPE ty_manup.
