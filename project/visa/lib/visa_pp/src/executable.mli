(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

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
