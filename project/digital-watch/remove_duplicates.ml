let main =
  Command.make
    ~summary:"Remove duplicates from an input where each line appears twice."
    (let open Command.Std in
     let+ () = Arg.return () in
     let i = ref 0 in
     With_return.with_return (fun { return } ->
       let input_line () =
         match In_channel.(input_line stdin) with
         | Some line -> line
         | None -> return ()
       in
       while true do
         let s1 = input_line () in
         let s2 = input_line () in
         if String.equal s1 s2
         then (
           i := !i + 2;
           print_endline s1)
         else
           raise_s
             [%sexp "unexpected line", { line = (!i : int); s1 : string; s2 : string }]
       done))
;;

let () = Cmdlang_cmdliner_runner.run main ~name:"remove_duplicate" ~version:"%%VERSION%%"
