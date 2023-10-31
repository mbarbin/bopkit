let%expect_test "of_01star_chars_in_string" =
  let test str =
    print_s
      [%sexp (Partial_bit_array.of_01star_chars_in_string str : Partial_bit_array.t)]
  in
  test "";
  [%expect {| () |}];
  test "010";
  [%expect {| ((false) (true) (false)) |}];
  test "010\n";
  [%expect {| ((false) (true) (false)) |}];
  test "//010 and some other characters followed by 11";
  [%expect {| ((false) (true) (false) (true) (true)) |}];
  test "*010*\n";
  [%expect {| (() (false) (true) (false) ()) |}]
;;

let%expect_test "to_string" =
  let test t = print_endline (Partial_bit_array.to_string t) in
  test [||];
  [%expect {||}];
  test [| Some true; Some false; None |];
  [%expect {| 10* |}];
  test (Array.init 10 ~f:(fun i -> if i mod 2 = 0 then Some (i mod 3 = 0) else None));
  [%expect {| 1*0*0*1*0* |}]
;;

let%expect_test "to_string roundtrip" =
  Expect_test_helpers_core.quickcheck
    [%here]
    Partial_bit_array.quickcheck_generator
    ~sexp_of:[%sexp_of: Partial_bit_array.t]
    ~f:(fun t1 ->
      let t2 =
        t1 |> Partial_bit_array.to_string |> Partial_bit_array.of_01star_chars_in_string
      in
      if not ([%equal: Partial_bit_array.t] t1 t2)
      then
        raise_s
          [%sexp
            "Value does not roundtrip"
            , { t1 : Partial_bit_array.t; t2 : Partial_bit_array.t }])
;;

let%expect_test "text files" =
  let test t =
    let filename = Filename_unix.temp_file "test__bit_array" "text" in
    Partial_bit_array.to_text_file t ~filename;
    let contents = In_channel.read_all filename in
    let t2 = Partial_bit_array.of_text_file ~filename in
    if not ([%equal: Partial_bit_array.t] t t2)
    then
      raise_s
        [%sexp
          "Value does not roundtrip"
          , { t : Partial_bit_array.t; t2 : Partial_bit_array.t }];
    let contents2 = Partial_bit_array.to_string t ^ "\n" in
    if not (String.equal contents contents2)
    then
      raise_s
        [%sexp "String contents not equal", { contents : string; contents2 : string }];
    print_endline contents;
    Core_unix.unlink filename
  in
  test [||];
  [%expect {||}];
  test [| Some true; Some true; None; Some false |];
  [%expect {| 11*0 |}];
  test (Array.init 64 ~f:(fun i -> if i mod 7 = 1 then None else Some (i mod 3 = 1)));
  [%expect {| 0*001001*010010*100100*001001*010010*100100*001001*010010*100100 |}];
  ()
;;

let%expect_test "conflicts" =
  let test a b =
    let conflicts =
      Partial_bit_array.conflicts
        (Partial_bit_array.of_01star_chars_in_string a)
        ~with_:(Bit_array.of_01_chars_in_string b)
    in
    Printf.printf "%S conflicts with:%S => %b\n" a b conflicts
  in
  test "" "";
  [%expect {| "" conflicts with:"" => false |}];
  test "" "0";
  [%expect {| "" conflicts with:"0" => false |}];
  test "0" "";
  [%expect {| "0" conflicts with:"" => false |}];
  test "0" "0";
  [%expect {| "0" conflicts with:"0" => false |}];
  test "*" "0";
  [%expect {| "*" conflicts with:"0" => false |}];
  test "*" "1";
  [%expect {| "*" conflicts with:"1" => false |}];
  test "*01" "10";
  [%expect {| "*01" conflicts with:"10" => false |}];
  test "*01**111" "1011011111111";
  [%expect {| "*01**111" conflicts with:"1011011111111" => false |}];
  ()
;;
