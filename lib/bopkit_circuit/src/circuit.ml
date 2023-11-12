type t =
  { path : Fpath.t
  ; main : string
  ; rom_memories : Bit_matrix.t array
  ; external_blocks : Bopkit.Expanded_netlist.external_block array
  ; cds : Cds.t
  ; input_names : string array
  ; output_names : string array
  }

let verify_input_output_gate_count_exn t =
  let inputs = ref 0 in
  let outputs = ref 0 in
  let () =
    Array.iter t.cds ~f:(fun gate ->
      match gate.gate_kind with
      | Input -> incr inputs
      | Output -> incr outputs
      | _ -> ())
  in
  let inputs = !inputs
  and outputs = !outputs in
  if not (inputs = 1 && outputs = 1)
  then
    raise_s
      [%sexp
        "Expected circuit to have exactly 1 input and 1 output"
        , [%here]
        , { inputs : int; outputs : int }]
;;

let verify_input_position_exn t =
  match t.cds.(0).gate_kind with
  | Input -> ()
  | gate_kind ->
    raise_s
      [%sexp
        "Expected first gate of circuit to be its input"
        , [%here]
        , { gate_kind : Gate_kind.t }]
;;

let create_exn ~path ~main ~rom_memories ~external_blocks ~cds ~input_names ~output_names =
  let t = { path; main; cds; rom_memories; external_blocks; input_names; output_names } in
  verify_input_position_exn t;
  verify_input_output_gate_count_exn t;
  t
;;
