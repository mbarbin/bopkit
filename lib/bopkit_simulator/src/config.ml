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
  let open Command.Std in
  let+ num_cycles =
    let+ num_cycles =
      Arg.named_opt
        [ "num-cycles"; "n" ]
        Param.int
        ~doc:"Number of cycles to run (default: infinity)."
      >>| Option.map ~f:(fun i -> Num_cycles.Cycles i)
    and+ num_counter_cycles =
      Arg.named_opt
        [ "num-counter-cycles" ]
        Param.int
        ~doc:"Number of counter cycles to run. Enforces: $(b,--counter-input)."
      >>| Option.map ~f:(fun i -> Num_cycles.Counter_cycles i)
    in
    match List.filter_opt [ num_cycles; num_counter_cycles ] with
    | [] -> Num_cycles.Unbounded
    | [ a ] -> a
    | _ :: _ :: _ ->
      Err.raise
        ~exit_code:Err.Exit_code.cli_error
        [ Pp.text "Cannot specify both --num-cycles and --num-counter-cycles" ]
  and+ counter_input =
    Arg.flag [ "counter-input" ] ~doc:"Use a counter as circuit inputs."
  and+ output_kind =
    let+ output_only_on_change =
      let+ flag =
        Arg.flag [ "output-only-on-change" ] ~doc:"Only print output when it changes."
      in
      if flag then Some (Output_kind.Default { output_only_on_change = true }) else None
    and+ output_only =
      let+ flag = Arg.flag [ "output-only"; "o" ] ~doc:"Only show output on stdout." in
      if flag then Some (Output_kind.Default { output_only_on_change = false }) else None
    and+ show_input =
      let+ flag =
        Arg.flag [ "show-input" ] ~doc:"Also show input on stdout (this is the default)."
      in
      if flag then Some Output_kind.Show_input else None
    and+ external_block =
      let+ flag =
        Arg.flag [ "external-block"; "p" ] ~doc:"Behave as an external-block."
      in
      if flag then Some Output_kind.As_external_block else None
    in
    match
      List.filter_opt [ output_only_on_change; show_input; output_only; external_block ]
    with
    | [] -> default.output_kind
    | [ a ] -> a
    | _ :: _ :: _ ->
      Err.raise
        ~exit_code:Err.Exit_code.cli_error
        [ Pp.text "Cannot specify multiple output kinds." ]
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
