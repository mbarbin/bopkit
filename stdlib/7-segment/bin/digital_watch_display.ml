let () =
  Cmdlang_to_cmdliner.run
    Seven_segment_display.digital_watch_display
    ~name:"digital_watch_display"
    ~version:"%%VERSION%%"
;;
