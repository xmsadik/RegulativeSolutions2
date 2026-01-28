managed implementation in class zbp_etr_i_defcl unique;
strict ( 2 );
with draft; // Draft özelliği açıldı

define behavior for ZETR_I_DEFCL alias LedgerProcess
persistent table zetr_t_defcl
draft table zetr_t_defcl_d // Bu tabloyu aşağıda tanımlayacağız
lock master total etag erdat // Yeni alan eklemediğimiz için erdat kullanıyoruz
authorization master ( global )
// etag master erdat -> Opsiyonel: Update'lerde çakışma kontrolü için
{
  create;
  update;
  delete;

  field ( readonly : update ) bukrs, gjahr, monat;
  field ( readonly ) ernam, erdat, erzet;

  // Standart Draft Aksiyonları
  draft action Edit;
  draft action Activate;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  mapping for zetr_t_defcl
  {
    bukrs = bukrs;
    gjahr = gjahr;
    monat = monat;
    ernam = ernam;
    erdat = erdat;
    erzet = erzet;
    elprc = elprc;
    stldr = stldr;
    etldr = etldr;
    stldd = stldd;
    stsds = stsds;
    etsds = etsds;
    sgbsn = sgbsn;
    egbsn = egbsn;
    dcdrs = dcdrs;
    heror = heror;
    manup = manup;
    ardnm = ardnm;
  }
}