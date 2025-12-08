CLASS zcl_etr_invusers_par_efinans DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES if_abap_parallel .
    METHODS constructor
      IMPORTING
        iv_users_xml TYPE string.
    METHODS get_result
      RETURNING
        VALUE(rt_result) TYPE zcl_etr_einvoice_ws=>mty_taxpayers_list.
