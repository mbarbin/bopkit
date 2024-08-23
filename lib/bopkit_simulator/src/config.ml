module Num_cycles = struct
  type t =
    | Unbounded
    | Cycles of int
    | Counter_cycles of int
end

module Output_kind = struct
  type t =
    | Default of { output_only_on_change : bool }
    | As_external_block
    | Show_input
end

type t =
  { num_cycles : Num_cycles.t
  ; counter_input : bool
  ; output_kind : Output_kind.t
  }

let default = { num_cycles = Unbounded; counter_input = false; output_kind = Show_input }

let arg =
  let open Command.Let_syntax in
  let%map_open.Command num_cycles =
    let%map num_cycles =
      Arg.named_opt
        [ "num-cycles"; "n" ]
        Param.int
        ~doc:"number of cycles to run (default: infinity)"
      >>| Option.map ~f:(fun i -> Num_cycles.Cycles i)
    and num_counter_cycles =
      Arg.named_opt
        [ "num-counter-cycles" ]
        Param.int
        ~doc:"number of counter cycles to run. Enforces: --counter-input"
      >>| Option.map ~f:(fun i -> Num_cycles.Counter_cycles i)
    in
    match List.filter_opt [ num_cycles; num_counter_cycles ] with
    | [] -> Num_cycles.Unbounded
    | [ a ] -> a
    | _ :: _ :: _ ->
      Err.raise
        ~exit_code:Cli_error
        [ Pp.text "Cannot specify both --num-cycles and --num-counter-cycles" ]
  and counter_input = Arg.flag [ "counter-input" ] ~doc:"use a counter as circuit inputs"
  and output_kind =
    let%map output_only_on_change =
      if%map Arg.flag [ "output-only-on-change" ] ~doc:"only print output when it changes"
      then Some (Output_kind.Default { output_only_on_change = true })
      else None
    and output_only =
      if%map Arg.flag [ "output-only"; "o" ] ~doc:"only show output on stdout"
      then Some (Output_kind.Default { output_only_on_change = false })
      else None
    and show_input =
      if%map
        Arg.flag [ "show-input" ] ~doc:"also show input on stdout (this is the default)"
      then Some Output_kind.Show_input
      else None
    and external_block =
      if%map Arg.flag [ "external-block"; "p" ] ~doc:"behave as an external-block"
      then Some Output_kind.As_external_block
      else None
    in
    match
      List.filter_opt [ output_only_on_change; show_input; output_only; external_block ]
    with
    | [] -> default.output_kind
    | [ a ] -> a
    | _ :: _ :: _ ->
      Err.raise ~exit_code:Cli_error [ Pp.text "Cannot specify multiple output kinds" ]
  in
  { num_cycles
  ; counter_input =
      (counter_input
       ||
       match num_cycles with
       | Counter_cycles _ -> true
       | Cycles _ | Unbounded -> false)
  ; output_kind
  }
;;

let output_kind t = t.output_kind
let counter_input t = t.counter_input

let num_cycles t ~expected_input_length =
  match t.num_cycles with
  | Unbounded -> None
  | Cycles i -> Some i
  | Counter_cycles i -> Some (i * Int.pow 2 expected_input_length)
;;
