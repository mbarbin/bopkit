let () =
  Cmdlang_cmdliner_runner.run
    Bopkit_counter.Counter.main
    ~name:"counter"
    ~version:"%%VERSION%%"
;;
