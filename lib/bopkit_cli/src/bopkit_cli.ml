let print_sites_cmd =
  Command.make
    ~summary:"Print stdlib sites."
    (let open Command.Std in
     let+ () = Arg.return () in
     let open Bopkit_sites.Sites in
     print_s
       [%sexp { stdlib : string list; bopboard : string list; stdbin : string list }])
;;

let fmt_cmd =
  Auto_format.fmt_cmd
    (module struct
      let language_id = "bopkit"
      let extensions = [ ".bop" ]
    end)
    (module Bopkit.Netlist)
    (module Bopkit_parser)
    (module Bopkit_pp.Netlist)
;;

let main =
  Command.group
    ~summary:"Bopkit command line."
    [ "bdd", Bopkit_bdd_cli.main
    ; "bop2c", Cmd_bop2c.main
    ; "check", Cmd_check.main
    ; "counter", Bopkit_counter.Counter.main
    ; "digital-calendar", Seven_segment_display.Main.digital_calendar
    ; "digital-watch", Seven_segment_display.Main.digital_watch
    ; "echo", Cmd_echo.main
    ; "fmt", fmt_cmd
    ; "print-sites", print_sites_cmd
    ; "process", Bopkit_process_cli.main
    ; "pulse", Bopkit_pulse.Pulse.main
    ; "simu", Cmd_simu.main
    ]
;;
