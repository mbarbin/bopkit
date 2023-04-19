open! Core

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

let param =
  let open Command.Let_syntax in
  let%map_open num_cycles =
    let num_cycles =
      flag
        "num-cycles"
        ~aliases:[ "n" ]
        (optional int)
        ~doc:"N number of cycles to run (default: infinity)"
      >>| Option.map ~f:(fun i -> Num_cycles.Cycles i)
    and num_counter_cycles =
      flag
        "num-counter-cycles"
        (optional int)
        ~doc:"N number of counter cycles to run. Enforces: -counter-input"
      >>| Option.map ~f:(fun i -> Num_cycles.Counter_cycles i)
    in
    choose_one
      [ num_cycles; num_counter_cycles ]
      ~if_nothing_chosen:(Default_to Unbounded)
  and counter_input = flag "counter-input" no_arg ~doc:" use a counter as circuit inputs"
  and output_kind =
    let output_only_on_change =
      if%map flag "output-only-on-change" no_arg ~doc:" only print output when it changes"
      then Some (Output_kind.Default { output_only_on_change = true })
      else None
    and output_only =
      if%map
        flag "output-only" ~aliases:[ "-o" ] no_arg ~doc:" only show output on stdout"
      then Some (Output_kind.Default { output_only_on_change = false })
      else None
    and show_input =
      if%map
        flag "show-input" no_arg ~doc:" also show input on stdout (this is the default)"
      then Some Output_kind.Show_input
      else None
    and external_block =
      if%map
        flag "external-block" ~aliases:[ "p" ] no_arg ~doc:" behave as an external-block"
      then Some Output_kind.As_external_block
      else None
    in
    choose_one
      [ output_only_on_change; show_input; output_only; external_block ]
      ~if_nothing_chosen:(Default_to default.output_kind)
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
