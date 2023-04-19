open! Core
module Digital_calendar = Digital_calendar
module Digital_watch = Digital_watch
module Seven_segment_code = Seven_segment_code

(** {1 Display commands } *)

val digital_calendar_display : Command.t
val digital_watch_display : Command.t

(** {1 Main commands } *)

module Main : sig
  val digital_calendar : Command.t
  val digital_watch : Command.t
end
