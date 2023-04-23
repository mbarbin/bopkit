open! Core

module With_labels : sig
  type t = Visa.Executable.With_labels.t

  val pp : t -> unit Pp.t
end

type t = Visa.Executable.t

val pp : t -> unit Pp.t

module Machine_code : sig
  type t = Visa.Executable.Machine_code.t

  val pp : t -> unit Pp.t
end
