(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let%expect_test "of_partial_bit_array" =
  let partial_bit_array =
    Array.init 24 ~f:(fun i -> if i % 5 = 1 then None else Some (i % 2 = 1))
  in
  let test t = Partial_bit_matrix.to_text_channel t stdout in
  (* Shorter than input *)
  test (Partial_bit_matrix.of_partial_bit_array ~dimx:2 ~dimy:6 partial_bit_array);
  [%expect
    {|
    0*0101
    *1010* |}];
  (* Equal size of input *)
  test (Partial_bit_matrix.of_partial_bit_array ~dimx:3 ~dimy:8 partial_bit_array);
  [%expect
    {|
    0*0101*1
    010*0101
    *1010*01 |}];
  (* Longer than input *)
  test (Partial_bit_matrix.of_partial_bit_array ~dimx:4 ~dimy:9 partial_bit_array);
  [%expect
    {|
    0*0101*10
    10*0101*1
    010*01***
    ********* |}]
;;

let%expect_test "of_text_file" =
  let path = Stdlib.Filename.temp_file "test__bit_matrix" "text" |> Fpath.v in
  Out_channel.with_file (path |> Fpath.to_string) ~f:(fun oc ->
    Out_channel.output_string oc "// Hello comment\n";
    Out_channel.output_string oc "010*010*01*1\n";
    Out_channel.output_string oc "0**111*11110\n");
  let test ~dimx ~dimy =
    let t = Partial_bit_matrix.of_text_file ~dimx ~dimy ~path in
    Partial_bit_matrix.to_text_channel t stdout
  in
  test ~dimx:2 ~dimy:12;
  [%expect
    {|
    010*010*01*1
    0**111*11110 |}];
  test ~dimx:3 ~dimy:24;
  [%expect
    {|
    010*010*01*10**111*11110
    ************************
    ************************ |}];
  test ~dimx:4 ~dimy:4;
  [%expect
    {|
    010*
    010*
    01*1
    0**1 |}];
  Unix.unlink (path |> Fpath.to_string);
  ()
;;
