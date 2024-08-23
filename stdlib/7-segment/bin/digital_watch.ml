let () =
  Commandlang_to_cmdliner.run
    Seven_segment_display.Main.digital_watch
    ~name:"digital_watch"
    ~version:"%%VERSION%%"
;;
