@EndUserText.label: 'Consumption View - Booking 015'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_AIRBOOKING_015
  provider contract transactional_query
  as projection on ZI_AIRBOOKING_015
{
  key BookingUuid,
  BookingId,
  PnrCode,
  FlightNo,
  TravelClass,
  DepDate,
  BasePrice,
  FinalPrice,
  CurrencyCode,
  BookingStatus,
  CreatedBy,
  CreatedAt,
  LocalLastChangedAt,
  
  /* Associations */
  _Passengers : redirected to composition child ZC_AIRPAX_015
}
