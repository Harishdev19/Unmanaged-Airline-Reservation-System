@EndUserText.label: 'Consumption View - Passenger 015'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_AIRPAX_015
  as projection on ZI_AIRPAX_015
{
  key PaxUuid,
  BookingUuid,
  PassengerName,
  EmailAddress,
  PhoneNumber,
  PassportNo,
  Dob,
  Nationality,
  SeatNo,
  LuggageKg,
  PaxStatus,
  LocalLastChangedAt,
  
  /* Associations */
  _Booking : redirected to parent ZC_AIRBOOKING_015
}
