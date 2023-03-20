open! Core

type t =
  { gate_kind : Bopkit_circuit.Gate_kind.t
  ; input_width : int
  ; output_width : int
  }
[@@deriving sexp_of]

type env = t Map.M(String).t

let initial_env =
  lazy
    (let ll =
       let open Bopkit_circuit.Gate_kind in
       [ "not", (Not, (1, 1))
       ; "~", (Not, (1, 1))
       ; "and", (And, (2, 1))
       ; "or", (Or, (2, 1))
       ; "id", (Id, (1, 1))
       ; "xor", (Xor, (2, 1))
       ; "mux", (Mux, (3, 1))
       ; "reg", (Reg { initial_value = false }, (1, 1))
       ; "Z", (Reg { initial_value = false }, (1, 1))
       ; "nreg", (Reg { initial_value = true }, (1, 1))
       ; "nZ", (Reg { initial_value = true }, (1, 1))
       ; (* version des registres avec un enable *)
         "regen", (Reg { initial_value = false }, (2, 1))
       ; "Zen", (Reg { initial_value = false }, (2, 1))
       ; "nregen", (Reg { initial_value = true }, (2, 1))
       ; "nZen", (Reg { initial_value = true }, (2, 1))
       ; "clock", (Clock, (0, 1))
       ; "gnd", (Gnd, (0, 1))
       ; "vdd", (Vdd, (0, 1))
       ]
     in
     List.fold_left
       ll
       ~init:(Map.empty (module String))
       ~f:(fun env (key, (gate_kind, (input_width, output_width))) ->
         Map.set env ~key ~data:{ gate_kind; input_width; output_width }))
;;
