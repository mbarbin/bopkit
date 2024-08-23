(* Generating fragments such as this one:

   {[
     (rule
      (target watch_in_c)
      (action
       (run "gcc" -o %{target} %{dep:watch_in_c.c})))
   ]}
*)

let gen_dune_cmd =
  Command.make
    ~summary:
      "generate dune stanza for all c files present in the cwd to be generated by bopkit"
    (let%map_open.Command () = Arg.return () in
     Eio_main.run
     @@ fun env ->
     let files =
       Auto_format.find_files_in_cwd_by_extensions
         ~cwd:(Eio.Stdenv.cwd env)
         ~extensions:[ "bop" ]
     in
     let generate_rules ~file =
       let file_prefix = Stdlib.Filename.chop_extension file in
       let open Sexp in
       let c_file = file_prefix ^ ".c" in
       let list s = List s
       and atom s = Atom s in
       let atoms s = List.map s ~f:atom in
       let to_c =
         list
           [ atom "rule"
           ; list (atoms [ "target"; c_file ])
           ; list (atoms [ "alias"; "runtest" ])
           ; list (atoms [ "mode"; "promote" ])
           ; list
               [ atom "action"
               ; list
                   [ atom "with-stdout-to"
                   ; atom "%{target}"
                   ; list
                       [ atom "run"
                       ; atom "%{bin:bopkit}"
                       ; atom "bop2c"
                       ; atom (Printf.sprintf "%%{dep:%s}" file)
                       ]
                   ]
               ]
           ]
       in
       let gcc =
         list
           [ atom "rule"
           ; list (atoms [ "target"; file_prefix ^ ".exe" ])
           ; list
               [ atom "action"
               ; list
                   [ atom "run"
                   ; atom "gcc"
                   ; atom "-o"
                   ; atom "%{target}"
                   ; atom (Printf.sprintf "%%{dep:%s}" c_file)
                   ]
               ]
           ]
       in
       [ to_c; gcc ]
     in
     Stdlib.Printf.printf
       "; dune file generated by './gen-dune/main.exe' -- do not edit.\n";
     List.iter files ~f:(fun file ->
       List.iter (generate_rules ~file) ~f:(fun sexp ->
         Stdlib.print_endline (Sexp.to_string_hum sexp))))
;;

let () = Commandlang_to_cmdliner.run gen_dune_cmd ~name:"gen-dune" ~version:"%%VERSION%%"
