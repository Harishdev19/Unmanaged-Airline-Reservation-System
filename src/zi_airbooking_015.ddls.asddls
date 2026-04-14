@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Booking 015'
define root view entity ZI_AIRBOOKING_015
  as select from zair_booking_015
  composition [0..*] of ZI_AIRPAX_015 as _Passengers
{
  key booking_uuid as BookingUuid,
  booking_id as BookingId,
  pnr_code as PnrCode,
  flight_no as FlightNo,
  travel_class as TravelClass,
  dep_date as DepDate,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  base_price as BasePrice,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  final_price as FinalPrice,
  currency_code as CurrencyCode,
  booking_status as BookingStatus,
  
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  _Passengers // Make association public
}
