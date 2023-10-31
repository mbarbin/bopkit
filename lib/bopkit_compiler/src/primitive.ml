type t =
  { gate_kind : Bopkit_circuit.Gate_kind.t
  ; input_width : int
  ; output_width : int
  }
[@@deriving sexp_of]

type env = t Map.M(String).t

let initial_env =
  lazy
    (List.fold
       (force Bopkit_circuit.Gate_kind.Primitive.all)
       ~init:(Map.empty (module String))
       ~f:(fun env { gate_kind; input_width; output_width; aliases = keys } ->
         List.fold keys ~init:env ~f:(fun env key ->
           Map.set env ~key ~data:{ gate_kind; input_width; output_width })))
;;
