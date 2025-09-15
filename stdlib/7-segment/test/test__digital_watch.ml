(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let%expect_test "digital-watch-decoded" =
  let dst = Array.create ~len:64 false in
  let test (d : Digital_watch.Decoded.t) =
    Digital_watch.Decoded.blit d ~dst;
    let d' = Digital_watch.decode dst in
    if not ([%equal: Digital_watch.Decoded.t] d d')
    then
      raise_s
        [%sexp
          "Digital_watch.Decoded does not round trip"
        , { d : Digital_watch.Decoded.t
          ; d' : Digital_watch.Decoded.t
          ; dst : Bit_array.Short_sexp.t
          }];
    print_endline (Digital_watch.Decoded.to_string d')
  in
  test { hour = 17; minute = 54; second = 37 };
  [%expect {| 17:54:37 |}];
  ()
;;
