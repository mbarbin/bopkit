module Arity : sig
  type ('kind, 'signal) t =
    | Empty : (unit, 'signal) t
    | Signal : ('signal, 'signal) t
    | Bus : { width : int } -> (bool array, 'signal) t
    | Remaining_bits : (bool array, bool) t
    | Output_buffer : (Buffer.t, bool ref) t
    | Tuple_2 :
        (('kind1, 'signal) t * ('kind2, 'signal) t)
        -> ('kind1 * 'kind2, 'signal) t
    | Tuple_3 :
        (('kind1, 'signal) t * ('kind2, 'signal) t * ('kind3, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3, 'signal) t
    | Tuple_4 :
        (('kind1, 'signal) t
        * ('kind2, 'signal) t
        * ('kind3, 'signal) t
        * ('kind4, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3 * 'kind4, 'signal) t
    | Tuple_5 :
        (('kind1, 'signal) t
        * ('kind2, 'signal) t
        * ('kind3, 'signal) t
        * ('kind4, 'signal) t
        * ('kind5, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3 * 'kind4 * 'kind5, 'signal) t
    | Tuple_6 :
        (('kind1, 'signal) t
        * ('kind2, 'signal) t
        * ('kind3, 'signal) t
        * ('kind4, 'signal) t
        * ('kind5, 'signal) t
        * ('kind6, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3 * 'kind4 * 'kind5 * 'kind6, 'signal) t
end

module Method : sig
  type 'kind t

  val main
    :  input_arity:('input, bool) Arity.t
    -> output_arity:('output, bool ref) Arity.t
    -> f:(input:'input -> output:'output -> unit)
    -> unit t

  val create
    :  name:string
    -> input_arity:('input, bool) Arity.t
    -> output_arity:('output, bool ref) Arity.t
    -> f:(arguments:string list -> input:'input -> output:'output -> unit)
    -> string list t
end

type t

val create
  :  name:string
  -> main:unit Method.t
  -> ?methods:string list Method.t list
  -> ?is_multi_threaded:bool
  -> unit
  -> t

val main : ?readme:(unit -> string) -> t Command.Param.t -> Command.t
val run : ?readme:(unit -> string) -> t Command.Param.t -> unit
