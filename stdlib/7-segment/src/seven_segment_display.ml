open! Core
module Digital_calendar = Digital_calendar
module Digital_watch = Digital_watch
module Seven_segment_code = Seven_segment_code

module type DEVICE_S = sig
  type t

  val init : unit -> t
  val update : t -> bool array -> unit

  module Decoded : sig
    type t

    val to_string : t -> string
  end

  val decode : bool array -> Decoded.t
end

let make_display_command (module Device : DEVICE_S) ~length ~name =
  Command.basic
    ~summary:(sprintf "run %s display" name)
    (let open Command.Let_syntax in
     let%map_open with_output = flag "no" no_arg ~doc:" no output" >>| not in
     fun () ->
       let tab = Array.create ~len:length false in
       let m = Device.init () in
       with_return (fun { return } ->
         while true do
           let line =
             match In_channel.(input_line stdin) with
             | Some line -> line
             | None -> return ()
           in
           if String.length line <> length
           then (
             Printf.fprintf
               stderr
               "Length : %d, expected %d.\n"
               (String.length line)
               length;
             Out_channel.flush stderr)
           else (
             for i = 0 to pred length do
               Array.unsafe_set tab i (Char.equal '1' (String.unsafe_get line i))
             done;
             Device.update m tab;
             if with_output
             then (
               Out_channel.newline stdout;
               Out_channel.flush stdout))
         done))
;;

let make_print_command (module Device : DEVICE_S) ~length ~name =
  Command.basic
    ~summary:(sprintf "print %s output" name)
    (let open Command.Let_syntax in
     let%map_open clear_on_reprint =
       flag "clear-on-reprint" no_arg ~doc:" on tty print only 1 line"
     and print_index = flag "print-index" no_arg ~doc:" print cycle index as prefix"
     and print_on_change = flag "print-on-change" no_arg ~doc:" print only on change" in
     fun () ->
       if clear_on_reprint && not (ANSITerminal.isatty.contents Core_unix.stdout)
       then (
         Printf.eprintf "clear-on-reprint can only be used if the terminal is a tty\n%!";
         exit 1);
       let index = ref (-1) in
       let previous_line = ref "" in
       let tab = Array.create ~len:length false in
       with_return (fun { return } ->
         while true do
           let line =
             match In_channel.(input_line stdin) with
             | Some line -> line
             | None -> return ()
           in
           if String.length line <> length
           then (
             Printf.fprintf
               stderr
               "Length : %d, expected %d.\n"
               (String.length line)
               length;
             Out_channel.flush stderr)
           else (
             incr index;
             let has_changed =
               let r = not (String.equal !previous_line line) in
               previous_line := line;
               r
             in
             if has_changed || not print_on_change
             then (
               for i = 0 to pred length do
                 Array.unsafe_set tab i (Char.equal '1' (String.unsafe_get line i))
               done;
               let decoded = Device.decode tab |> Device.Decoded.to_string in
               let output =
                 if print_index then sprintf "%04d: %s" !index decoded else decoded
               in
               if clear_on_reprint
               then (
                 ANSITerminal.move_bol ();
                 ANSITerminal.print_string [] output)
               else print_endline output))
         done;
         if clear_on_reprint then print_endline ""))
;;

let digital_calendar_display =
  make_display_command (module Digital_calendar) ~length:91 ~name:"digital-calendar"
;;

let digital_watch_display =
  make_display_command (module Digital_watch) ~length:42 ~name:"digital-watch"
;;

module Main = struct
  let digital_watch =
    let name = "digital-watch"
    and length = 42 in
    Command.group
      ~summary:name
      [ "display", digital_watch_display
      ; "gen-input", Cmd_digital_watch_gen_input.main
      ; "print", make_print_command (module Digital_watch) ~length ~name
      ]
  ;;

  let digital_calendar =
    let name = "digital-watch"
    and length = 91 in
    Command.group
      ~summary:"digital-calendar"
      [ "display", digital_calendar_display
      ; "gen-input", Cmd_digital_calendar_gen_input.main
      ; "gen-raw-input", Cmd_digital_calendar_gen_raw_input.main
      ; "map-raw-input", Cmd_digital_calendar_map_raw_input.main
      ; "print", make_print_command (module Digital_calendar) ~length ~name
      ]
  ;;
end
