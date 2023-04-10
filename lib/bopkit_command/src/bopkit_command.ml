open! Core

let print_sites_cmd =
  Command.basic
    ~summary:"print stdlib sites"
    (let open Command.Let_syntax in
     let%map_open () = return () in
     fun () ->
       let open Bopkit_sites.Sites in
       print_s
         [%sexp { stdlib : string list; bopboard : string list; stdbin : string list }])
;;

let fmt_cmd =
  Fmt_command.fmt_cmd
    (module Bopkit.Netlist)
    (module Bopkit_syntax)
    (module Bopkit_pp.Netlist)
;;

let main =
  Command.group
    ~summary:"bopkit command line"
    [ "bdd", Bopkit_bdd_command.main
    ; "bop2c", Cmd_bop2c.main
    ; "check", Cmd_check.main
    ; "counter", Bopkit_counter.Counter.main
    ; "digital-calendar", Seven_segment_display.digital_calendar
    ; "digital-watch", Seven_segment_display.digital_watch
    ; "echo", Cmd_echo.main
    ; "fmt", fmt_cmd
    ; "print-sites", print_sites_cmd
    ; "process", Bopkit_process_command.main
    ; "pulse", Bopkit_pulse.Pulse.main
    ; "simu", Cmd_simu.main
    ]
;;
