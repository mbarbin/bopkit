open! Core

type t

val create : colors:Colors.t -> size:int -> x:int -> y:int -> t
val init : t -> unit
val update : t -> src:bool array -> src_pos:int -> unit
