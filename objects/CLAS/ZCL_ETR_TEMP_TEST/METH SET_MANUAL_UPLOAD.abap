  METHOD set_manual_upload.
    "Manuel yükleme durumuna göre X veya boş değer ata
    rv_manup = COND #( WHEN iv_is_manual = abap_true
                       THEN 'X'
                       ELSE space ).
  ENDMETHOD.