(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

module Digital_calendar = Digital_calendar
module Digital_watch = Digital_watch
module Seven_segment_code = Seven_segment_code

(** {1 Display commands} *)

val digital_calendar_display : unit Command.t
val digital_watch_display : unit Command.t

(** {1 Main commands} *)

module Main : sig
  val digital_calendar : unit Command.t
  val digital_watch : unit Command.t
end
