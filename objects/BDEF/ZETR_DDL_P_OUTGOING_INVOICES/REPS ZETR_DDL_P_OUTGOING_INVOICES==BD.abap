projection;
strict ( 1 );
use side effects;

define behavior for zetr_ddl_p_outgoing_invoices alias OutgoingInvoices
{
  use update;
  use delete;
  use association _invoiceContents;
  use association _invoiceLogs;
  use association _invoiceItems;
  use action sendInvoices;
  use action archiveInvoices;
  use action statusUpdate;
  use action setAsRejected;
  use action sendMailToPartner;
  use action sendMailToSelected;
  use action showSummary;
  use action sendInvoicesBackground;
  use action downloadInvoices;
  use action markAsSent;
  use action generateItemsHeader;
}

define behavior for zetr_ddl_p_outgoing_invcont alias InvoiceContents
{
  use association _outgoingInvoices;
}

define behavior for zetr_ddl_p_outinv_logs alias Logs
{
  use association _outgoingInvoices;
}

define behavior for zetr_ddl_p_outgoing_invitem alias Items
{
  use update;
  use association _outgoingInvoices;
}