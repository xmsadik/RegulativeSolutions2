  METHOD get_data_likp.
    SELECT SINGLE DeliveryDocument AS vbeln,
                  DeliveryDate AS bldat,
                  CreationDate AS erdat,
                  CreationTime AS erzet,
                  DeliveryDocumentType AS lfart,
                  ShipToParty AS kunnr,
                  CreatedByUser AS ernam,
                  overallgoodsmovementstatus AS wbstk,
                  headergrossweight AS brgew,
                  headernetweight AS ntgew,
                  HeaderWeightUnit AS gewei
    FROM I_DeliveryDocument
    WHERE deliverydocument = @ms_document-belnr
    INTO @ms_outdel_data-likp.
    CHECK sy-subrc = 0.

    SELECT lips~DeliveryDocument AS vbeln,
           lips~DeliveryDocumentItem AS posnr,
           lips~ActualDeliveryQuantity AS lfimg,
           lips~DeliveryQuantityUnit AS vrkme,
           lips~DeliveryDocumentItemText AS arktx,
           lips~Material AS matnr,
           lips~ReferenceSDDocument AS vgbel,
           lips~ReferenceSDDocumentItem AS vgpos,
           vbap~MaterialByCustomer AS kdmat,
           vbap~PurchaseOrderByCustomer AS bstkd,
           lips~DistributionChannel AS vtweg,
           lips~Division AS spart,
           lips~SalesOffice AS vkbur,
           lips~SalesGroup AS vkgrp,
           lips~ItemGrossWeight AS brgew,
           lips~ItemNetWeight AS ntgew,
           lips~ItemWeightUnit AS gewei
       FROM i_deliverydocumentitem AS lips
       LEFT OUTER JOIN i_salesdocumentitem AS vbap
        ON  vbap~salesdocument = lips~ReferenceSDDocument
        AND vbap~salesdocumentitem = lips~ReferenceSDDocumentItem
      WHERE DeliveryDocument = @ms_document-belnr
      INTO TABLE @ms_outdel_data-lips.

    SELECT vbpa~SDDocument AS vbeln,
           vbpa~PartnerFunction AS parvw,
           vbpa~AddressID AS adrnr,
           vbpa~Customer AS kunnr,
           vbpa~Supplier AS lifnr,
           vbpa~ReferenceBusinessPartner AS partner
      FROM I_SDDocumentPartner WITH PRIVILEGED ACCESS AS vbpa
      WHERE SDDocument = @ms_document-belnr
      INTO TABLE @ms_outdel_data-vbpa.

    SELECT vbak~SalesDocument AS vbeln,
           vbak~SalesDocumentDate AS audat,
           vbak~PurchaseOrderByCustomer AS bstkd,
           vbpa~Customer AS kunwe,
           vbpa~AddressID AS adrwe
      FROM i_salesdocument AS vbak
      LEFT OUTER JOIN I_SDDocumentPartner WITH PRIVILEGED ACCESS AS vbpa
        ON  vbpa~SDDocument = vbak~SalesDocument
       AND vbpa~PartnerFunction = @mv_delivery_partner_role
      FOR ALL ENTRIES IN @ms_outdel_data-lips
      WHERE salesdocument = @ms_outdel_data-lips-vgbel
      INTO TABLE @ms_outdel_data-vbak.

    SELECT SINGLE companycode AS bukrs,
                  currency AS waers,
                  country AS land1,
                  CASE WHEN CountryChartOfAccounts IS NOT INITIAL THEN CountryChartOfAccounts
                  ELSE chartofaccounts END AS ktopl
      FROM I_CompanyCode
      WHERE companycode = @ms_document-bukrs
      INTO CORRESPONDING FIELDS OF @ms_outdel_data-t001.

    READ TABLE ms_outdel_data-vbpa INTO DATA(ls_vbpa) WITH TABLE KEY by_parvw COMPONENTS Parvw = 'AG'.
    IF sy-subrc = 0.
      ms_outdel_data-address_number = ls_vbpa-adrnr.
      SELECT SINGLE TaxNumber1 AS stcd1,
                    TaxNumber2 AS stcd2,
                    TaxNumber3 AS stcd3,
                    AddressID AS adrnr
        FROM I_Customer
        WHERE Customer = @ls_vbpa-kunnr
        INTO @DATA(ls_partner_data).
      ms_outdel_data-taxid = COND #( WHEN ls_partner_data-stcd3 IS NOT INITIAL THEN ls_partner_data-stcd3 ELSE ls_partner_data-stcd2 ).
      ms_outdel_data-tax_office = ls_partner_data-stcd1.
      ms_outdel_data-address_number = ls_partner_data-adrnr.
    ENDIF.

    IF mv_delivery_partner_role IS NOT INITIAL.
      DATA(lv_partner_role) = mv_delivery_partner_role.
    ELSE.
      lv_partner_role = 'WE'.
    ENDIF.
    READ TABLE ms_outdel_data-vbpa INTO ls_vbpa WITH TABLE KEY by_parvw COMPONENTS parvw = lv_partner_role.
    IF sy-subrc = 0.
      mv_shipto_address = ls_vbpa-adrnr.
    ELSEIF lv_partner_role <> 'WE'.
      LOOP AT ms_outdel_data-vbak INTO DATA(ls_vbak) WHERE adrwe IS NOT INITIAL.
        mv_shipto_address = ls_vbpa-adrnr.
        EXIT.
      ENDLOOP.
      IF sy-subrc <> 0.
        READ TABLE ms_outdel_data-vbpa INTO ls_vbpa WITH TABLE KEY by_parvw COMPONENTS parvw = 'WE'.
        IF sy-subrc = 0.
          mv_shipto_address = ls_vbpa-adrnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.