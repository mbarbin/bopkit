let () =
  Cmdlang_cmdliner_runner.run Subleq_command.main ~name:"subleq" ~version:"%%VERSION%%"
;;
