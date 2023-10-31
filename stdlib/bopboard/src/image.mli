(** The images needed to create the board are installed with the bopboard
    executable as additional runtime resources via dune-sites. See
    {!module:Bopkit_sites} for information regarding the install location.

    [t] is an enumerated type which we use in the folder images/ to verify that
    we have all the images we need and that the names of the files match
    what's hardcoded by [basename]. *)

type t =
  | Ladybgleft
  | Ladybgmid
  | Ladybgright
  | Ladyoff
  | Ladyon
  | Pushbg
  | Pushdown
  | Pushup
  | Switchbg
  | Switchdown
  | Switchup
[@@deriving enumerate, equal, sexp_of]

val basename : t -> string
