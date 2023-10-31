let%expect_test "of_partial_bit_array" =
  let partial_bit_array =
    Array.init 24 ~f:(fun i -> if i mod 5 = 1 then None else Some (i mod 2 = 1))
  in
  let test t = Partial_bit_matrix.to_text_channel t stdout in
  (* Shorter than input *)
  test (Partial_bit_matrix.of_partial_bit_array ~dimx:2 ~dimy:6 partial_bit_array);
  [%expect {|
    0*0101
    *1010* |}];
  (* Equal size of input *)
  test (Partial_bit_matrix.of_partial_bit_array ~dimx:3 ~dimy:8 partial_bit_array);
  [%expect {|
    0*0101*1
    010*0101
    *1010*01 |}];
  (* Longer than input *)
  test (Partial_bit_matrix.of_partial_bit_array ~dimx:4 ~dimy:9 partial_bit_array);
  [%expect {|
    0*0101*10
    10*0101*1
    010*01***
    ********* |}]
;;

let%expect_test "of_text_file" =
  let filename = Filename_unix.temp_file "test__bit_matrix" "text" in
  Out_channel.with_file filename ~f:(fun oc ->
    Printf.fprintf oc "// Hello comment\n";
    Printf.fprintf oc "010*010*01*1\n";
    Printf.fprintf oc "0**111*11110\n");
  let test ~dimx ~dimy =
    let t = Partial_bit_matrix.of_text_file ~dimx ~dimy ~filename in
    Partial_bit_matrix.to_text_channel t stdout
  in
  test ~dimx:2 ~dimy:12;
  [%expect {|
    010*010*01*1
    0**111*11110 |}];
  test ~dimx:3 ~dimy:24;
  [%expect
    {|
    010*010*01*10**111*11110
    ************************
    ************************ |}];
  test ~dimx:4 ~dimy:4;
  [%expect {|
    010*
    010*
    01*1
    0**1 |}];
  Core_unix.unlink filename;
  ()
;;
