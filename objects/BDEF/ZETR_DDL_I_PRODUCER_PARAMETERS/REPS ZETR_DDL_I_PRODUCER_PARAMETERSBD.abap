managed implementation in class zbp_etr_ddl_i_producer_paramet unique;
strict ( 2 );

define behavior for zetr_ddl_i_producer_parameters //alias <alias_name>
persistent table zetr_t_eppar
lock master
authorization master ( instance )
//etag master <field_name>
{
  mapping for zetr_t_eppar
    {
      CompanyCode       = bukrs;
      ValidFrom         = datab;
      ValidTo           = datbi;
      Integrator        = intid;
      WSEndpoint        = wsend;
      WSEndpointAlt     = wsena;
      WSUser            = wsusr;
      WSPassword        = wspwd;
      GenerateSerial    = genid;
      Barcode           = barcode;
      InternalNumbering = intnum;
      AutoSendMail      = automail;
    }
  create;
  update;
  delete;
  field ( readonly : update ) CompanyCode;
  association _customParameters { create; }
  association _invoiceSerials { create; }
  association _xsltTemplates { create; }
  association _invoiceRules { create; }
}

define behavior for zetr_ddl_i_producer_custom //alias <alias_name>
persistent table zetr_t_epcus
lock dependent by _eproducerParameters
authorization dependent by _eproducerParameters
//etag master <field_name>
{
  mapping for zetr_t_epcus
    {
      CompanyCode     = bukrs;
      CustomParameter = cuspa;
      Value           = value;
    }
  update;
  delete;
  field ( readonly ) CompanyCode;
  field ( readonly : update ) CustomParameter;
  field ( mandatory ) Value;
  association _eproducerParameters;
}

define behavior for zetr_ddl_i_producer_serials //alias <alias_name>
persistent table zetr_t_epser
lock dependent by _eproducerParameters
authorization dependent by _eproducerParameters
//etag master <field_name>
{
  mapping for zetr_t_epser
    {
      CompanyCode       = bukrs;
      SerialPrefix      = serpr;
      Description       = descr;
      NextSerial        = nxtsp;
      MainSerial        = maisp;
      NumberRangeNumber = numrn;
    }
  update;
  delete;
  field ( readonly ) CompanyCode;
  field ( readonly : update ) SerialPrefix;
  validation checkSerials on save { field NumberRangeNumber; create; update; }
  association _eproducerParameters;
  association _numberStatus { create; }
  action createNumbers parameter ZETR_DDL_I_FISYEAR_SELECTION result [1] $self;
  side effects { action createNumbers affects entity _numberStatus; }
}

define behavior for zetr_ddl_i_producer_numstat //alias <alias_name>
persistent table zetr_t_edocnum
lock dependent by _eproducerParameters
authorization dependent by _eproducerParameters
//etag master <field_name>
{
  mapping for zetr_t_edocnum
    {
      CompanyCode       = bukrs;
      NumberRangeObject = nrobj;
      SerialPrefix      = serpr;
      NumberRangeNumber = numrn;
      FiscalYear        = gjahr;
      NumberStatus      = numst;
    }
  update;
  delete;
  field ( readonly ) CompanyCode, NumberRangeObject, SerialPrefix, NumberRangeNumber, FiscalYear;
  association _producerSerials;
  association _eproducerParameters;
}

define behavior for zetr_ddl_i_producer_xslttemp //alias <alias_name>
persistent table zetr_t_epxslt
lock dependent by _eproducerParameters
authorization dependent by _eproducerParameters
//etag master <field_name>
{
  mapping for zetr_t_epxslt
    {
      CompanyCode     = bukrs;
      XSLTTemplate    = xsltt;
      DefaultTemplate = deflt;
      XSLTContent     = xsltc;
      Filename        = filen;
      Mimetype        = mimet;
    }
  update;
  delete;
  field ( readonly ) CompanyCode;
  field ( readonly : update ) XSLTTemplate;
  association _eproducerParameters;
}

define behavior for zetr_ddl_i_producer_rules //alias <alias_name>
persistent table zetr_t_eprules
lock dependent by _eproducerParameters
authorization dependent by _eproducerParameters
//etag master <field_name>
{
  mapping for zetr_t_eprules
    {
      CompanyCode                    = bukrs;
      RuleType                       = rulet;
      RuleItemNumber                 = rulen;
      RuleDescription                = descr;
      ReferenceDocumentType          = awtyp;
      InvoiceTypeInput               = ityin;
      SalesOrganization              = vkorg;
      DistributionChannel            = vtweg;
      Division                       = spart;
      Plant                          = werks;
      SalesDocumentItemCategory      = pstyv;
      CustomerAccountAssignmentGroup = ktgrd;
      BillingDocumentType            = sddty;
      InvoiceReceiptType             = mmdty;
      AccountingDocumentType         = fidty;
      PurchaseDocumentType           = bsart;
      Partner                        = partner;
      SalesDocument                  = vbeln;
      ProfileID                      = pidou;
      InvoiceType                    = ityou;
      TaxExemption                   = taxex;
      Exclude                        = excld;
      SerialPrefix                   = serpr;
      XSLTTemplate                   = xsltt;
      Note                           = note;
      FieldName                      = fname;
      FieldValue                     = value;
    }
  update;
  delete;
  field ( readonly ) CompanyCode, ProfileID;
  field ( readonly : update ) RuleType, RuleItemNumber;
  association _eproducerParameters;
}