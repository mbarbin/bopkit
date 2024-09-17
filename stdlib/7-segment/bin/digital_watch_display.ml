let () =
  Cmdlang_cmdliner_runner.run
    Seven_segment_display.digital_watch_display
    ~name:"digital_watch_display"
    ~version:"%%VERSION%%"
;;
