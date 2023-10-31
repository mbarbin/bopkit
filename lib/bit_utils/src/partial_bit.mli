type t = bool option [@@deriving compare, equal, quickcheck, sexp_of]

(** Check whether the partial bit agrees with a fully specified value. If the
    bit is specified, it will expect the given boolean to be equal to its
    specification. If the bit is unspecified, there is no conflict. The
    function returns [true] in case of conflicts. *)
val conflicts : t -> with_:bool -> bool
