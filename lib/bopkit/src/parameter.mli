open! Core

(** Parameters are language construct that allows some flexibility in the
    definition of blocs, adding parameters to external blocks commands, etc.
    Example:

    {[
      #define N 4

      Bloc_not[N] (a:[N]) = s:[N]
      where
        for i = 0 to N-1
          s[i] = not(a[i]);
        end for;
      end where;
    ]}

    Parameters can be bound to integers or strings.
*)

module Value : sig
  type t =
    | Int of int
    | String of string
  [@@deriving compare, equal, hash, sexp_of]

  (** Either the int, or the quoted string. *)
  val to_syntax : t -> string
end

type t =
  { name : string
  ; value : Value.t
  }
[@@deriving equal, sexp_of]

(** Defining a syntax with which parameters may be passed via the command line.
  *)
val arg_type : t Command.Arg_type.t
