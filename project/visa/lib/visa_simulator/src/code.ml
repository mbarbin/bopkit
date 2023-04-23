open! Core
open! Or_error.Let_syntax

module Statement = struct
  type t =
    { labels : Visa.Label.t With_loc.t list
    ; assembly_instruction : Visa.Assembly_instruction.t
    }
  [@@deriving sexp_of]
end

type t =
  { statements : Statement.t array
  ; labels_resolution : int Map.M(Visa.Label).t
  }
[@@deriving sexp_of]

let of_assembly_constructs
  ~(assembly_constructs : Visa_assembler.Assembly_construct.t list)
  =
  let pending_labels = Queue.create () in
  let statements = Queue.create () in
  List.iter assembly_constructs ~f:(function
    | Label_introduction { label } -> Queue.enqueue pending_labels label
    | Assembly_instruction { assembly_instruction } ->
      let labels = Queue.to_list pending_labels in
      Queue.clear pending_labels;
      Queue.enqueue statements { Statement.labels; assembly_instruction });
  let statements = Queue.to_array statements in
  let labels_resolution =
    let mapping = Hashtbl.create (module Visa.Label) in
    Array.iteri statements ~f:(fun index statement ->
      List.iter statement.labels ~f:(fun label ->
        Hashtbl.set mapping ~key:label.symbol ~data:index));
    mapping |> Hashtbl.to_alist |> Map.of_alist_exn (module Visa.Label)
  in
  { statements; labels_resolution }
;;
