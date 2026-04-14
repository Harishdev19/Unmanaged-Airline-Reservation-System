@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Passenger 015'
define view entity ZI_AIRPAX_015
  as select from zair_pax_015
  association to parent ZI_AIRBOOKING_015 as _Booking
    on $projection.BookingUuid = _Booking.BookingUuid
{
  key pax_uuid as PaxUuid,
  booking_uuid as BookingUuid,
  passenger_name as PassengerName,
  email_address as EmailAddress,
  phone_number as PhoneNumber,
  passport_no as PassportNo,
  dob as Dob,
  nationality as Nationality,
  seat_no as SeatNo,
  luggage_kg as LuggageKg,
  pax_status as PaxStatus,
  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  _Booking
}
