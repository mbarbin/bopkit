let pulse ~bopkit_sleeper =
  Bopkit_block.Method.main
    ~input_arity:Empty
    ~output_arity:Empty
    ~f:
      (match bopkit_sleeper with
       | None -> fun ~input:() ~output:() -> ()
       | Some bopkit_sleeper ->
         fun ~input:() ~output:() -> Bopkit_sleeper.sleep bopkit_sleeper)
;;

let main =
  Bopkit_block.main
    (let open Command.Let_syntax in
     let%map_open cycles_per_second =
       flag
         "cycles-per-second"
         (required string)
         ~doc:"max|%d number of cycles per second"
       >>| function
       | "max" -> `Max
       | d ->
         `Value
           (match int_of_string d with
            | d -> d
            | exception _ ->
              raise_s [%sexp "(max|%d) value expected for [cycles-per-second]"])
     and midnight =
       flag
         "as-if-started-at-midnight"
         (optional_with_default false bool)
         ~doc:"bool catch-up as if it had run from midnight"
     in
     let bopkit_sleeper =
       match cycles_per_second with
       | `Max -> None
       | `Value f ->
         Bopkit_sleeper.create
           ~frequency:(float_of_int f)
           ~as_if_started_at_midnight:midnight
         |> Option.return
     in
     Bopkit_block.create ~name:"pulse" ~main:(pulse ~bopkit_sleeper) ())
;;
