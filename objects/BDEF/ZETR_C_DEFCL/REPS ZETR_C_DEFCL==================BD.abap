projection;
strict ( 2 );
use draft; // Draft yeteneklerini UI katmanına taşıyoruz

define behavior for ZETR_C_DEFCL alias LedgerProcess
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;
}