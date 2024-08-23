(* Optimization: we don't specify the results when dividing by zero. *)

let main n =
  let t = ref 0 in
  let num_addr = Int.pow 2 (2 * n) in
  let tmp_s = Array.create ~len:n false in
  let star = String.make n '*' in
  (* print s <- a/b *)
  let div_opt_fct a b ~output =
    let int_a = Bit_array.to_int a in
    let int_b = Bit_array.to_int b in
    if int_b = 0
    then Buffer.add_string output star (* bits don't care *)
    else (
      Bit_array.blit_int ~src:(int_a / int_b) ~dst:tmp_s;
      Buffer.add_string output (Bit_array.to_string tmp_s))
  in
  Bopkit_block.Method.main
    ~input_arity:(Tuple_2 (Bus { width = n }, Bus { width = n }))
    ~output_arity:Output_buffer
    ~f:(fun ~input:(a, b) ~output ->
      if !t >= num_addr
      then Stdlib.exit 0
      else (
        Int.incr t;
        div_opt_fct a b ~output))
;;

let () =
  Bopkit_block.run
    (let%map_open.Command n = Arg.named [ "N" ] Param.int ~doc:"architecture" in
     Bopkit_block.create ~name:"div_opt" ~main:(main n) ())
;;
