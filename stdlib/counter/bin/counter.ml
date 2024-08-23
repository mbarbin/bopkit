let () =
  Commandlang_to_cmdliner.run
    Bopkit_counter.Counter.main
    ~name:"counter"
    ~version:"%%VERSION%%"
;;
