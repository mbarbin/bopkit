open! Core

let main =
  Bopkit_block.Method.main
    ~input_arity:(Bus { width = 7 })
    ~output_arity:(Tuple_2 (Bus { width = 4 }, Bus { width = 4 }))
    ~f:(fun ~input ~output:(remainder, quotient) ->
      let i = Bit_array.to_int input in
      Bit_array.blit_int ~src:(i % 10) ~dst:remainder;
      Bit_array.blit_int ~src:(i / 10) ~dst:quotient;
      ())
;;

let () =
  Bopkit_block.run
    (let open Command.Let_syntax in
     let%map_open () = return () in
     Bopkit_block.create ~name:"div10" ~main ())
;;
