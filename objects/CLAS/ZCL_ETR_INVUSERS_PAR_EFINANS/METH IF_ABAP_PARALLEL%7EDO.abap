  METHOD if_abap_parallel~do.
    DATA ls_taxpayer TYPE zetr_t_inv_ruser.
    LOOP AT ms_user_list-efaturakayitlikullanici INTO DATA(ls_user).
      CLEAR ls_taxpayer.
      CASE ls_user-tip.
        WHEN 'Özel'.
          ls_taxpayer-txpty = 'OZEL'.
        WHEN OTHERS.
          ls_taxpayer-txpty = 'KAMU'.
      ENDCASE.
      IF ls_user-kayitzamani IS NOT INITIAL.
        ls_taxpayer-regdt = ls_user-kayitzamani(8).
        ls_taxpayer-regtm = ls_user-kayitzamani+8(6).
      ENDIF.
      ls_taxpayer-title = ls_user-unvan.
      ls_taxpayer-taxid = ls_user-vkntckn.
      IF ls_user-aktifetiket IS NOT INITIAL.
        LOOP AT ls_user-aktifetiket INTO DATA(ls_alias).
          ls_taxpayer-aliass = ls_alias-etiket.
          APPEND ls_taxpayer TO mt_result.
        ENDLOOP.
      ELSE.
        APPEND ls_taxpayer TO mt_result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.