let () =
  Command_unix.run
    ~version:"%%VERSION%%"
    ~build_info:"%%VCS_COMMIT_ID%%"
    Bopkit_command.main
;;
