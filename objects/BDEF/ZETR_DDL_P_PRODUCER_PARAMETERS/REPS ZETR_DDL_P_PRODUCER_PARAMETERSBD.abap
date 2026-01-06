projection;
strict ( 2 );
use side effects;

define behavior for zetr_ddl_p_producer_parameters //alias <alias_name>
{
  use create;
  use update;
  use delete;

  use association _customParameters { create; }
  use association _invoiceSerials { create; }
  use association _xsltTemplates { create; }
  use association _invoiceRules { create; }
}

define behavior for zetr_ddl_p_producer_custom //alias <alias_name>
{
  use update;
  use delete;

  use association _eProducerParameters;
}

define behavior for zetr_ddl_p_producer_rules //alias <alias_name>
{
  use update;
  use delete;

  use association _eProducerParameters;
}

define behavior for zetr_ddl_p_producer_serials //alias <alias_name>
{
  use update;
  use delete;

  use association _eProducerParameters;
  use association _numberStatus { create; }
  use action createNumbers;
}

define behavior for zetr_ddl_p_producer_numstat //alias <alias_name>
{
  use update;
  use delete;

  use association _producerSerials;
  use association _eproducerParameters;
}

define behavior for zetr_ddl_p_producer_xslttemp //alias <alias_name>
{
  use update;
  use delete;

  use association _eProducerParameters;
}