(** Topological sort, e.g. used to reorder parameters, functions, etc.

    Nodes are compared using hashable keys. [sort] only keeps the last version
    of each node (previous versions are discarded), and then order them using a
    stable topological sort. [Node.parents] is only called once per node. *)

module type Node = sig
  type t
  type key

  val key : t -> key
  val parents : t -> error_log:Error_log.t -> key Appendable_list.t
end

module type Key = sig
  type t [@@deriving sexp_of]

  include Equal.S with type t := t
  include Hashtbl.Key.S with type t := t
end

(** Best effort to make parents appear before their children, and otherwise
    stable. If there is a cycle, [sort] doesn't raise (but e.g. the evaluation
    of bopkit parameters is going to find free variables later). *)
val sort
  :  (module Node with type t = 'node and type key = 'key)
  -> (module Key with type t = 'key)
  -> 'node list
  -> error_log:Error_log.t
  -> 'node list
