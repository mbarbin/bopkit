let () =
  Cmdlang_cmdliner_runner.run
    Seven_segment_display.digital_calendar_display
    ~name:"digital_calendar_display"
    ~version:"%%VERSION%%"
;;
