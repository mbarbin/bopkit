module T = struct
  type t = bool [@@deriving enumerate, equal, sexp_of]
end

module T_opt = struct
  type t = bool option [@@deriving enumerate, equal, sexp_of]
end

let%expect_test "T encoding" =
  List.iter T.all ~f:(fun t ->
    let char = Bit_string_encoding.Bit.to_char t in
    let t2 = Bit_string_encoding.Bit.of_char char in
    assert (T.equal t t2);
    print_s [%sexp { t : T.t; char : Char.t }]);
  [%expect {|
    ((t false) (char 0))
    ((t true) (char 1)) |}]
;;

let%expect_test "T_opt encoding" =
  List.iter T_opt.all ~f:(fun t ->
    let char = Bit_string_encoding.Bit_option.to_char t in
    let t2 = Bit_string_encoding.Bit_option.of_char char in
    assert (T_opt.equal t t2);
    print_s [%sexp { t : T_opt.t; char : Char.t }]);
  [%expect
    {|
    ((t ()) (char *))
    ((t (false)) (char 0))
    ((t (true)) (char 1)) |}]
;;
