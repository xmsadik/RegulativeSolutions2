CLASS lhc_ledgerprocess DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ledgerprocess RESULT result.

ENDCLASS.

CLASS lhc_ledgerprocess IMPLEMENTATION.

  METHOD get_global_authorizations.
    " Şimdilik tüm yetkilere izin veriyoruz
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

ENDCLASS.