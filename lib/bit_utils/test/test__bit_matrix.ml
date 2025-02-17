let%expect_test "init" =
  let test t = print_s [%sexp (t : Bit_matrix.t)] in
  test (Bit_matrix.init_matrix_linear ~dimx:0 ~dimy:0 ~f:(Fn.const false));
  [%expect {| () |}];
  test (Bit_matrix.init_matrix_linear ~dimx:0 ~dimy:3 ~f:(Fn.const false));
  [%expect {| () |}];
  test (Bit_matrix.init_matrix_linear ~dimx:3 ~dimy:0 ~f:(Fn.const false));
  [%expect
    {|
    (()
     ()
     ())
    |}];
  let t = Bit_matrix.init_matrix_linear ~dimx:3 ~dimy:5 ~f:(fun i -> i % 2 = 1) in
  Bit_matrix.to_text_channel t stdout;
  [%expect
    {|
    01010
    10101
    01010 |}]
;;

let%expect_test "of_bit_array" =
  let bit_array = Array.init 24 ~f:(fun i -> i % 2 = 1) in
  let test t = Bit_matrix.to_text_channel t stdout in
  (* Shorter than input *)
  test (Bit_matrix.of_bit_array ~dimx:2 ~dimy:6 bit_array);
  [%expect
    {|
    010101
    010101 |}];
  (* Equal size of input *)
  test (Bit_matrix.of_bit_array ~dimx:3 ~dimy:8 bit_array);
  [%expect
    {|
    01010101
    01010101
    01010101 |}];
  (* Longer than input *)
  test (Bit_matrix.of_bit_array ~dimx:4 ~dimy:9 bit_array);
  [%expect
    {|
    010101010
    101010101
    010101000
    000000000 |}]
;;

let%expect_test "of_text_file" =
  let path = Stdlib.Filename.temp_file "test__bit_matrix" "text" |> Fpath.v in
  Out_channel.with_file (path |> Fpath.to_string) ~f:(fun oc ->
    Out_channel.output_string oc "// Hello comment\n";
    Out_channel.output_string oc "010101010101\n";
    Out_channel.output_string oc "011111111110\n");
  let test ~dimx ~dimy =
    let t = Bit_matrix.of_text_file ~dimx ~dimy ~path in
    Bit_matrix.to_text_channel t stdout
  in
  test ~dimx:2 ~dimy:12;
  [%expect
    {|
    010101010101
    011111111110 |}];
  test ~dimx:3 ~dimy:24;
  [%expect
    {|
    010101010101011111111110
    000000000000000000000000
    000000000000000000000000 |}];
  test ~dimx:4 ~dimy:4;
  [%expect
    {|
    0101
    0101
    0101
    0111 |}];
  Unix.unlink (path |> Fpath.to_string);
  ()
;;
