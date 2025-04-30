"Database Table declaration."

@EndUserText.label : 'invoice and product details'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zinvoice_bk {

  key invoice_id : abap.char(20) not null;
  customer_name  : abap.char(100);
  item           : abap.char(100);
  cuky_field     : abap.cuky;
  @Semantics.amount.currencyCode : 'zinvoice_bk.cuky_field'
  amount         : abap.curr(16,2);
  invoice_date   : abap.dats;
  status         : abap.char(10);

}
