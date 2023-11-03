(* The substitution of the variables happens during the release packaging
   process, which invokes `dune subst` at the appropriate time. *)
let run cmd = Command_unix.run ~version:"%%VERSION%%" ~build_info:"%%VCS_COMMIT_ID%%" cmd
