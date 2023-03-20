open! Core

module Method_kind : sig
  type t =
    | Main
    | Named of
        { method_name : string
        ; arguments : string list
        }
  [@@deriving sexp_of]
end

type t =
  { method_kind : Method_kind.t
  ; bits : string
  }
[@@deriving sexp_of]
