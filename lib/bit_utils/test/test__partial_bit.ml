module T = struct
  type t = bool [@@deriving enumerate, sexp_of]
end

module T_opt = struct
  type t = bool option [@@deriving enumerate, sexp_of]
end

let%expect_test "conflicts" =
  List.iter T_opt.all ~f:(fun t_opt ->
    List.iter T.all ~f:(fun t ->
      Printf.printf
        "%c conflicts with:%c => %b\n"
        (Bit_string_encoding.Bit_option.to_char t_opt)
        (Bit_string_encoding.Bit.to_char t)
        (Partial_bit.conflicts t_opt ~with_:t)));
  [%expect
    {|
    * conflicts with:0 => false
    * conflicts with:1 => false
    0 conflicts with:0 => false
    0 conflicts with:1 => true
    1 conflicts with:0 => true
    1 conflicts with:1 => false |}]
;;
