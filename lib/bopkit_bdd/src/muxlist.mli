open! Core
open! Import

module Node : sig
  type t =
    { output : Ident.t
    ; muxtree : Muxtree.t
    }
  [@@deriving sexp_of]
end

type t = Node.t list [@@deriving sexp_of]

val of_muxtrees : Muxtree.t list -> t
