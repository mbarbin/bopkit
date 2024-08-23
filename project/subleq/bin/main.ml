let () =
  Commandlang_to_cmdliner.run Subleq_command.main ~name:"subleq" ~version:"%%VERSION%%"
;;
