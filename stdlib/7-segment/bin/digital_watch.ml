let () =
  Cmdlang_cmdliner_runner.run
    Seven_segment_display.Main.digital_watch
    ~name:"digital_watch"
    ~version:"%%VERSION%%"
;;
