let () =
  Cmdlang_to_cmdliner.run
    Seven_segment_display.Main.digital_calendar
    ~name:"bopkit"
    ~version:"%%VERSION%%"
;;
