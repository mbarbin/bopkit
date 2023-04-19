open! Core

(** A type used to decorate AST nodes built by parser so as to allow located
    error messages. *)

type t = Stdune.Loc.t =
  { start : Source_code_position.t
  ; stop : Source_code_position.t
  }
[@@deriving equal, sexp_of]

(** By default set to [false], this may be temporarily turned to [true] to
    operates some comparison that ignores positions. *)
val equal_ignores_positions : bool ref

(** By default set to [false], this may be temporarily turned to [true] to
    inspect positions in the dump of a program. *)
val include_sexp_of_positions : bool ref

(** To be called in the right hand side of a Menhir rule, using the [$loc]
    special keyword provided by Menhir. For example:

   {v
     ident:
      | ident=IDENT { Loc.create $loc }
     ;
   v}
*)
val create : Source_code_position.t * Source_code_position.t -> t

val of_pos : Source_code_position.t -> t

(** Build the first line of error messages to produce to stderr using the same
    syntax as used by the OCaml compiler. If your editor has logic to recognize
    it, it will allow to jump to the source file. *)
val to_string : t -> string

val to_file_colon_line : t -> string
val dummy_pos : t
val in_file : filename:string -> t
val in_file_at_line : filename:string -> line:int -> t

(** Same as [dummy_pos] but try and keep the original filename. *)
val with_dummy_pos : t -> t

val filename : t -> string
val line : t -> int
