(* s <- a/b *)
let div_fct ~dst int_a int_b =
  Bit_array.blit_int
    ~dst
    ~src:
      (if int_b = 0 then 0 (* Non specified, for example set to 0. *) else int_a / int_b)
;;

let test n =
  let tmp_s = Array.create ~len:n false in
  Bopkit_block.Method.create
    ~name:"test"
    ~input_arity:(Tuple_3 (Bus { width = n }, Bus { width = n }, Bus { width = n }))
    ~output_arity:Empty
    ~f:(fun ~arguments:_ ~input:(a, b, s) ~output:() ->
      let int_a = Bit_array.to_int a in
      let int_b = Bit_array.to_int b in
      div_fct ~dst:tmp_s int_a int_b;
      if int_b <> 0 && not (Bit_array.equal tmp_s s)
      then raise_s [%sexp "Test div Failed"])
;;

let main n =
  Bopkit_block.Method.main
    ~input_arity:(Tuple_2 (Bus { width = n }, Bus { width = n }))
    ~output_arity:(Bus { width = n })
    ~f:(fun ~input:(a, b) ~output ->
      let int_a = Bit_array.to_int a in
      let int_b = Bit_array.to_int b in
      div_fct ~dst:output int_a int_b)
;;

let () =
  Bopkit_block.run
    (let open Command.Let_syntax in
     let%map_open n = flag "N" (required int) ~doc:" architecture" in
     Bopkit_block.create ~name:"div" ~main:(main n) ~methods:[ test n ] ())
;;
