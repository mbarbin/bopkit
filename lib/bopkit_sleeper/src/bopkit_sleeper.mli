open! Core

(** A [Bopkit_sleeper.t] is used to regulate the simulation of bop files to a
    desired fixed number of simulated cycles per second.

    There are two parameters to regulate the simulation:

    The first is for setting a maximum number of cycles per seconds, and is
    called the [frequency].

    The second is called [as_if_started_at_midnight] and causes the sleeper to
    act as if we had started the simulation at midnight. This will cause the
    first cycles to go as fast as possible, until the normal rate can be resumed
    when reaching the expected number of cycles at the current time of day. *)

type t

val create : frequency:float -> as_if_started_at_midnight:bool -> t
val sleep : t -> unit
