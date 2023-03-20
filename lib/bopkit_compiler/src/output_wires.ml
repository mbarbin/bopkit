open! Core

type output_wire = Bopkit_circuit.Output_wire.t
type t = output_wire list Map.M(String).t

let empty = Map.empty (module String)

let rec insert_elt elt = function
  | [] -> [ elt ]
  | hd :: tl as ll ->
    (match Bopkit_circuit.Output_wire.compare elt hd |> Ordering.of_int with
     | Less -> elt :: ll
     | Equal -> ll
     | Greater -> hd :: insert_elt elt tl)
;;

let add (t : t) ~key ~data =
  Map.update t key ~f:(function
    | None -> [ data ]
    | Some elts -> insert_elt data elts)
;;

let find_or_empty t ~key =
  match Map.find t key with
  | Some v -> v
  | None -> []
;;
