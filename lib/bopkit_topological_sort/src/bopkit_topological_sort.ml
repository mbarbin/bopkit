open! Core

module type Node = sig
  type t
  type key

  val key : t -> key
  val parents : t -> error_log:Error_log.t -> key Appendable_list.t
end

module type Key = sig
  type t [@@deriving sexp_of]

  include Equal.S with type t := t
  include Hashtbl.Key_plain with type t := t
end

module Node_and_key = struct
  type ('key, 'node) t =
    { key : 'key
    ; node : 'node
    }
end

let sort
  (type node key)
  (module Node : Node with type t = node and type key = key)
  (module Key : Key with type t = key)
  (nodes : node list)
  ~error_log
  =
  let nodes_table = Hashtbl.create (module Key) in
  let nodes =
    let rec aux acc = function
      | [] -> acc
      | node :: tl ->
        let acc =
          let key = Node.key node in
          if Hashtbl.mem nodes_table key
          then acc
          else (
            let node = { Node_and_key.key; node } in
            Hashtbl.set nodes_table ~key ~data:node;
            node :: acc)
        in
        aux acc tl
    in
    aux [] (List.rev nodes)
  in
  let visited = Hash_set.create (module Key) in
  let ordered = Queue.create ~capacity:(List.length nodes) () in
  let rec visit { Node_and_key.key; node } =
    if not (Hash_set.mem visited key)
    then (
      Hash_set.add visited key;
      Appendable_list.iter (Node.parents node ~error_log) ~f:(fun parent ->
        Hashtbl.find nodes_table parent |> Option.iter ~f:visit);
      Queue.enqueue ordered node)
  in
  List.iter nodes ~f:visit;
  Queue.to_list ordered
;;
