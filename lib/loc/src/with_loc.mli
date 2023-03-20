open! Core

(** When the symbol you want to decorate is not already an argument in a record,
    it may be convenient to use this type as a standard way to decorate a
    symbol with a position.

    As it currently stands, it is not clear which style is preferred in this
    code base, so both [Loc.t] and 'a [With_loc.t] are in use.

    An example using [Loc.t]:

    {[
      type t =
        | T of { loc : Loc.t ; a : A.t; b : B.t; ... }
    ]}

    An example using ['a With_loc.t]:

    {[
      type t = A.t With_loc.t list
    ]}
*)

type 'a t =
  { loc : Loc.t
  ; symbol : 'a
  }
[@@deriving equal, fields, sexp_of]

(** To be called in the right hand side of a Menhir rule, using the [$sloc]
    special keyword provided by Menhir. For example:

   {[
     ident:
      | ident=IDENT { With_loc.create $loc ident }
     ;
   ]}
*)
val create : Source_code_position.t * Source_code_position.t -> 'a -> 'a t

(** Build the first line of error messages to produce to stderr using the same
    syntax as used by the OCaml compiler. If your editor has logic to recognize
    it, it will allow to jump to the source file. *)
val to_string : 'a t -> string

val map : 'a t -> f:('a -> 'b) -> 'b t
val with_dummy_pos : 'a -> 'a t
