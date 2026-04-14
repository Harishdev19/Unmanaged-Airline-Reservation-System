" ==============================================================================
" 1. BOOKING LOCAL CLASS - DEFINITION
" ==============================================================================
CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS CalculateDynPrice_015 FOR MODIFY
      IMPORTING keys FOR ACTION Booking~CalculateDynPrice_015 RESULT result.

    METHODS ConfirmBooking_015 FOR MODIFY
      IMPORTING keys FOR ACTION Booking~ConfirmBooking_015 RESULT result.

    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~SetInitialStatus.

    METHODS ValidateFlight_015 FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~ValidateFlight_015.

ENDCLASS.

" ==============================================================================
" 2. BOOKING LOCAL CLASS - IMPLEMENTATION
" ==============================================================================
CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_features.
    " Enable 'Confirm Booking' only if the status is NOT already 'C' (Confirmed)
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( BookingStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    result = VALUE #( FOR bkg IN bookings
                      ( %tky = bkg-%tky
                        %action-ConfirmBooking_015 = COND #( WHEN bkg-BookingStatus = 'C'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    " Basic authorization implementation - allowing all operations for now
  ENDMETHOD.

  METHOD CalculateDynPrice_015.
    " Apply Dynamic Pricing: simulating the 12% peak surge from your Fiori UI
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( BasePrice ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      " Calculate Final Price (BasePrice * 1.12)
      DATA(lv_surge_price) = <booking>-BasePrice * '1.12'.

      MODIFY ENTITIES OF zi_airbooking_015 IN LOCAL MODE
        ENTITY Booking
          UPDATE FIELDS ( FinalPrice )
          WITH VALUE #( ( %tky = <booking>-%tky FinalPrice = lv_surge_price ) ).
    ENDLOOP.

    " Return the updated record to the UI
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT bookings.

    result = VALUE #( FOR bkg IN bookings ( %tky = bkg-%tky %param = bkg ) ).
  ENDMETHOD.

  METHOD ConfirmBooking_015.
    " Change status to 'C' (Confirmed) and assign a PNR Code
    MODIFY ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( BookingStatus PnrCode )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                        BookingStatus = 'C'
                                        PnrCode = 'XV015Y' ) ) " Hardcoded PNR for demo purposes
      FAILED failed
      REPORTED reported.

    " Return the updated record to the UI
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    result = VALUE #( FOR bkg IN bookings ( %tky = bkg-%tky %param = bkg ) ).
  ENDMETHOD.

  METHOD SetInitialStatus.
    " Set default values upon booking creation (Status, Currency, Base Fare, and Auto-ID)
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( BookingStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DELETE bookings WHERE BookingStatus IS NOT INITIAL.
    CHECK bookings IS NOT INITIAL.

    " Generate a simple 8-character Booking ID using 'BK' + HHMMSS time
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_booking_id) = |BK{ lv_time }|.

    MODIFY ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( BookingStatus CurrencyCode BasePrice BookingId )
        WITH VALUE #( FOR bkg IN bookings ( %tky = bkg-%tky
                                            BookingStatus = 'N'
                                            CurrencyCode  = 'INR'
                                            BasePrice     = 4330
                                            BookingId     = lv_booking_id ) ).
  ENDMETHOD.

  METHOD ValidateFlight_015.
    " Validate that the flight number is provided and the departure date is in the future
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( FlightNo DepDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT bookings INTO DATA(booking).
      " Check missing flight number
      IF booking-FlightNo IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message( id       = 'SY'
                                            number   = '002'
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = 'Flight Number is mandatory' ) ) TO reported-booking.
      ENDIF.

      " Check past departure date
      IF booking-DepDate < lv_today AND booking-DepDate IS NOT INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message( id       = 'SY'
                                            number   = '002'
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = 'Departure date cannot be in the past' ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

" ==============================================================================
" 3. PASSENGER LOCAL CLASS - DEFINITION
" ==============================================================================
CLASS lhc_Passenger DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS ValidatePassenger_015 FOR VALIDATE ON SAVE
      IMPORTING keys FOR Passenger~ValidatePassenger_015.

ENDCLASS.

" ==============================================================================
" 4. PASSENGER LOCAL CLASS - IMPLEMENTATION
" ==============================================================================
CLASS lhc_Passenger IMPLEMENTATION.

  METHOD ValidatePassenger_015.
    " Validate that a passport number is provided and DOB is in the past
    READ ENTITIES OF zi_airbooking_015 IN LOCAL MODE
      ENTITY Passenger
        FIELDS ( PassportNo Dob ) WITH CORRESPONDING #( keys )
      RESULT DATA(passengers).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT passengers INTO DATA(passenger).
      " Check missing passport
      IF passenger-PassportNo IS INITIAL.
        APPEND VALUE #( %tky = passenger-%tky ) TO failed-passenger.
        APPEND VALUE #( %tky = passenger-%tky
                        %msg = new_message( id       = 'SY'
                                            number   = '002'
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = 'Passport Number is mandatory' ) ) TO reported-passenger.
      ENDIF.

      " Check invalid Date of Birth
      IF passenger-Dob >= lv_today AND passenger-Dob IS NOT INITIAL.
        APPEND VALUE #( %tky = passenger-%tky ) TO failed-passenger.
        APPEND VALUE #( %tky = passenger-%tky
                        %msg = new_message( id       = 'SY'
                                            number   = '002'
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = 'Date of Birth must be in the past' ) ) TO reported-passenger.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
