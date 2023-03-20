open! Core
module Digital_calendar = Digital_calendar
module Digital_watch = Digital_watch
module Seven_segment_code = Seven_segment_code

module type DEVICE_S = sig
  type t

  val init : unit -> t
  val update : t -> bool array -> unit
end

let make_command (module Device : DEVICE_S) ~length ~name =
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

let digital_calendar =
  make_command (module Digital_calendar) ~length:91 ~name:"digital-calendar"
;;

let digital_watch = make_command (module Digital_watch) ~length:42 ~name:"digital-watch"
