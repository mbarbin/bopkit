// A visa-assembly program to drive the display of a digital-calendar. This
// program was originally implemented by Mathieu Barbin & Ocan Sankur in 2007.

// GLOBAL VARIABLE DECLARATIONS (ADDRESSES).
define february 7
define year 5
define month 4
define day 3
define hour 2
define min 1
define sec 0
define days_in_current_month 8

// For a constant [x], [minus x] stores [-x] into [R1].
macro minus x
  load $x, R0
  not R0
  load #1, R1
  add
end

// Increment [var] by 1. If it equals [modulo] goto [carry_label],
// otherwise goto [return_label].
macro increment var, modulo, return_label, carry_label
  load $var, R0
  load #1, R1
  add
  store R1, $var
  load $modulo, R0
  cmp
  jmn $carry_label
  jmp $return_label
end

macro write_to_device_out local_address, device_address
  load $local_address, R0
  write R0, $device_address
end

// Computing the number of days in february:
COMPUTE_FEBRUARY:
  load year, R0
  load #3, R1
  and
  // If it is divisible by 4
  jmz @29
  jmn @28
29:
  load #29, R0
  jmp @FEB_WRITE
28:
  load #28, R0
FEB_WRITE:
  store R0, february

// MAIN PROGRAM
UPDATE_SEC:
  sleep
  write_to_device_out sec, 0
  write_to_device_out min, 1
  write_to_device_out hour, 2
  write_to_device_out day, 4
  write_to_device_out month, 5
  write_to_device_out year, 6

  // COUNT_SEC
  increment sec, #60, @UPDATE_SEC, @COUNT_MIN

COUNT_MIN:
  load #0, R0
  store R0, sec
  increment min, #60, @UPDATE_SEC, @COUNT_HOUR

COUNT_HOUR:
  load #0, R0
  store R0, min
  increment hour, #24, @UPDATE_SEC, @COUNT_DAY

COUNT_DAY:
  load #0, R0
  store R0, hour
  // Calculate days_in_current_month
  load month, R0

  // Is it February?
  load #1, R1
  cmp
  jmn @FEBRUARY

  // Else: (month <= 6) ==> (even month <=> 31)
  // and : (month >  6) ==> (even month <=> 30)
  minus #6
  load month, R0
  add
  // If it's zero, then month == 6
  jmz @LE6
  // Otherwise we check bit 2^7. If it's 1, this means the result was negative,
  // thus month < 6
  load #128, R0
  and
  cmp
  jmn @LE6
  jmp @G6

DONE:
  increment day, days_in_current_month, @UPDATE_SEC, @COUNT_MONTH

COUNT_MONTH:
  load #0, R0
  store R0, day
  increment month, #12, @UPDATE_SEC, @COUNT_YEAR

COUNT_YEAR:
  load #0, R0
  store R0, month
  increment year, #100, @COMPUTE_FEBRUARY, @NEW_CENTURY

NEW_CENTURY:
  load #0, R0
  store R0, year
  jmp @UPDATE_SEC

// Functions (with Labels) to compute the number of days in the current month:

FEBRUARY:
  load february, R0
  store R0, days_in_current_month
  jmp @DONE

// Case if month > 6.
G6:
  load month, R0
  load #1, R1
  and
  jmz @F30
F31:
  load #31, R0
  jmp @W
F30:
  load #30, R0
W:
  store R0, days_in_current_month
  jmp @DONE

// Case if month <= 6.
LE6:
  load month, R0
  load #1, R1
  and
  jmn @F30
  jmp @F31
