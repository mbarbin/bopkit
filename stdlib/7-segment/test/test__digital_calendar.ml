open! Core
open! Seven_segment_display

let%expect_test "digital-calendar-decoded" =
  let dst = Array.create ~len:91 false in
  let test (d : Digital_calendar.Decoded.t) =
    Digital_calendar.Decoded.blit d ~dst;
    let d' = Digital_calendar.decode dst in
    if not ([%equal: Digital_calendar.Decoded.t] d d')
    then
      raise_s
        [%sexp
          "Digital_calendar.Decoded does not round trip"
          , { d : Digital_calendar.Decoded.t
            ; d' : Digital_calendar.Decoded.t
            ; dst : Bit_array.Short_sexp.t
            }];
    print_endline (Digital_calendar.Decoded.to_string d')
  in
  Expect_test_helpers_core.require_does_raise [%here] (fun () ->
    test { hour = 17; minute = 54; second = 37; day = 1; month = 4; year = 2023 });
  [%expect
    {|
    ("Digital_calendar.Decoded does not round trip"
     ((d (
        (hour   17)
        (minute 54)
        (second 37)
        (day    1)
        (month  4)
        (year   2023)))
      (d' (
        (hour   17)
        (minute 54)
        (second 37)
        (day    1)
        (month  4)
        (year   23)))
      (dst
       0000111010111111001101101101000011100001100000000000011010111111100110101111101011110111011))) |}];
  test { hour = 17; minute = 54; second = 37; day = 1; month = 4; year = 23 };
  [%expect {| 01/04/23 - 17:54:37 |}];
  ()
;;
