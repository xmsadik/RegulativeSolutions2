  METHOD constructor.
    CALL TRANSFORMATION zetr_inv_userlist_efn
      SOURCE XML iv_users_xml
      RESULT efaturakayitlikullaniciliste = ms_user_list.
  ENDMETHOD.