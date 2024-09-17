let () =
  Cmdlang_cmdliner_runner.run
    Seven_segment_display.Main.digital_calendar
    ~name:"bopkit"
    ~version:"%%VERSION%%"
;;
