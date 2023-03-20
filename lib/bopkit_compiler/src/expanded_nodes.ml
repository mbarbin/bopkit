open! Core

module Node = struct
  type t =
    { gate_kind : Bopkit_circuit.Gate_kind.t
    ; inputs : string array
    ; outputs : string array
    }
  [@@deriving sexp_of]
end

type t = Node.t array

let sexp_of_t t =
  Array.mapi t ~f:(fun i node -> [%sexp (i : int), (node : Node.t)])
  |> Array.to_list
  |> Sexp.List
;;

let output_wires (t : t) =
  Array.foldi t ~init:Output_wires.empty ~f:(fun gate_index acc node ->
    Array.foldi node.inputs ~init:acc ~f:(fun input_index acc input ->
      Output_wires.add acc ~key:input ~data:{ gate_index; input_index }))
;;

let pp_debug t =
  let open Pp.O in
  Pp.concat_map
    (Array.to_list t)
    ~sep:Pp.newline
    ~f:(fun { Node.gate_kind; inputs; outputs } ->
    Pp.concat
      [ Pp.concat_map
          (outputs |> Array.to_list)
          ~sep:(Pp.verbatim "," ++ Pp.space)
          ~f:Pp.verbatim
      ; (if Array.is_empty outputs then Pp.nop else Pp.verbatim " = ")
      ; Bopkit_circuit.Gate_kind.pp_debug gate_kind
      ; Pp.verbatim "("
      ; Pp.concat_map (inputs |> Array.to_list) ~sep:(Pp.verbatim ", ") ~f:Pp.verbatim
      ; Pp.verbatim ");"
      ])
;;
