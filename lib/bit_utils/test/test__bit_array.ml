open! Core

let%expect_test "of_01_chars_in_string" =
  let test str = print_s [%sexp (Bit_array.of_01_chars_in_string str : Bit_array.t)] in
  test "";
  [%expect {| () |}];
  test "010";
  [%expect {| (false true false) |}];
  test "010\n";
  [%expect {| (false true false) |}];
  test "010 // and some other characters followed by 11 (which should be ignored)";
  [%expect {| (false true false) |}];
  test
    {|
    // Some comment 11110101010
    01|01
    // Other comment 01010101010
    01|01 // And a comment here 0010101
  |};
  [%expect {| (false true false true false true false true) |}];
  ()
;;

let%expect_test "to_string" =
  let test t = print_endline (Bit_array.to_string t) in
  test [||];
  [%expect {||}];
  test [| true; false |];
  [%expect {| 10 |}];
  test (Array.init 10 ~f:(fun i -> i mod 2 = 0));
  [%expect {| 1010101010 |}]
;;

let%expect_test "to_string roundtrip" =
  Expect_test_helpers_core.quickcheck
    [%here]
    Bit_array.quickcheck_generator
    ~sexp_of:[%sexp_of: Bit_array.t]
    ~f:(fun t1 ->
      let t2 = t1 |> Bit_array.to_string |> Bit_array.of_01_chars_in_string in
      if not ([%equal: Bit_array.t] t1 t2)
      then
        raise_s [%sexp "Value does not roundtrip", { t1 : Bit_array.t; t2 : Bit_array.t }])
;;

let%expect_test "text files" =
  let test t =
    let filename = Filename_unix.temp_file "test__bit_array" "text" in
    Bit_array.to_text_file t ~filename;
    let contents = In_channel.read_all filename in
    let t2 = Bit_array.of_text_file ~filename in
    if not ([%equal: Bit_array.t] t t2)
    then raise_s [%sexp "Value does not roundtrip", { t : Bit_array.t; t2 : Bit_array.t }];
    let contents2 = Bit_array.to_string t ^ "\n" in
    if not (String.equal contents contents2)
    then
      raise_s
        [%sexp "String contents not equal", { contents : string; contents2 : string }];
    print_endline contents;
    Core_unix.unlink filename
  in
  test [||];
  [%expect {||}];
  test [| true; true; false |];
  [%expect {| 110 |}];
  test (Array.init 64 ~f:(fun i -> i mod 2 = 1));
  [%expect {| 0101010101010101010101010101010101010101010101010101010101010101 |}];
  ()
;;

let%expect_test "to_int" =
  let test t = print_endline (Bit_array.to_int t |> Int.to_string) in
  test [||];
  [%expect {| 0 |}];
  test [| false |];
  [%expect {| 0 |}];
  test [| true |];
  [%expect {| 1 |}];
  test [| false; true |];
  [%expect {| 2 |}];
  test [| true; false |];
  [%expect {| 1 |}]
;;

let%expect_test "to_signed_int / to_int" =
  Expect_test_helpers_core.quickcheck
    [%here]
    Bit_array.quickcheck_generator
    ~sexp_of:[%sexp_of: Bit_array.t]
    ~f:(fun t ->
      let len = Array.length t in
      let modulo = Int.pow 2 len in
      let is_negative = len > 0 && t.(pred len) in
      let signed_int = Bit_array.to_signed_int t in
      let int = Bit_array.to_int t in
      let expected_signed_int = if is_negative then int - modulo else int in
      if signed_int <> expected_signed_int
      then
        raise_s
          [%sexp
            "Unexpected signed int"
            , { t : Bit_array.t; int : int; expected_signed_int : int; signed_int : int }])
;;

let%expect_test "sequence" =
  let n = 4 in
  let t = Array.create ~len:n false in
  for i = 0 to Int.pow 2 n - 1 do
    Bit_array.blit_int ~src:i ~dst:t;
    let j = Bit_array.to_int t in
    if i <> j then raise_s [%sexp "Unexpected int", { t : Bit_array.t; i : int; j : int }];
    let signed = Bit_array.to_signed_int t in
    Printf.printf "%s | %02d | %02d\n" (Bit_array.to_string t) i signed
  done;
  [%expect
    {|
    0000 | 00 | 00
    1000 | 01 | 01
    0100 | 02 | 02
    1100 | 03 | 03
    0010 | 04 | 04
    1010 | 05 | 05
    0110 | 06 | 06
    1110 | 07 | 07
    0001 | 08 | -8
    1001 | 09 | -7
    0101 | 10 | -6
    1101 | 11 | -5
    0011 | 12 | -4
    1011 | 13 | -3
    0111 | 14 | -2
    1111 | 15 | -1 |}]
;;

let%expect_test "blit_int" =
  let t1 =
    let n = 4 in
    Array.create ~len:n false
  in
  let t2 = [||] in
  let t3 =
    let n = 16 in
    Array.create ~len:n false
  in
  let all_ts = [ t1; t2; t3 ] in
  List.iter all_ts ~f:(fun t ->
    let max = Int.pow 2 (Array.length t) in
    List.iter
      [ Int.min_value; -1000; -33; -1; 0; 10; 17; 23; max; Int.max_value ]
      ~f:(fun i ->
        Bit_array.blit_int ~src:i ~dst:t;
        let j = Bit_array.to_int t in
        if i % max <> j || j < 0 || j >= max
        then
          raise_s
            [%sexp "Unexpected result of blit_int", { t : Bit_array.t; i : int; j : int }]))
;;

let%expect_test "blit_init" =
  let t = Array.create ~len:10 false in
  let last = ref (-1) in
  Bit_array.blit_init ~dst:t ~f:(fun i ->
    (* Check that [f] is called from left to right. *)
    assert (i = !last + 1);
    last := i;
    i mod 2 = 0);
  print_endline (Bit_array.to_string t);
  [%expect {| 1010101010 |}]
;;
