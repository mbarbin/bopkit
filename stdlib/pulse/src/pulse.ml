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
    (let%map_open.Command cycles_per_second =
       Arg.named
         [ "cycles-per-second" ]
         Param.string
         ~docv:"max|%d"
         ~doc:"Number of cycles per second."
       >>| function
       | "max" -> `Max
       | d ->
         `Value
           (match Int.of_string_opt d with
            | Some d -> d
            | None -> raise_s [%sexp "(max|%d) value expected for [cycles-per-second]"])
     and midnight =
       Arg.named_with_default
         [ "as-if-started-at-midnight" ]
         Param.bool
         ~default:false
         ~doc:"Catch-up as if it had run from midnight."
     in
     let bopkit_sleeper =
       match cycles_per_second with
       | `Max -> None
       | `Value f ->
         Bopkit_sleeper.create
           ~frequency:(Float.of_int f)
           ~as_if_started_at_midnight:midnight
         |> Option.return
     in
     Bopkit_block.create ~name:"pulse" ~main:(pulse ~bopkit_sleeper) ())
;;
