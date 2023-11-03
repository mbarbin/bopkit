let main =
  Command.basic
    ~summary:"remove duplicates from an input where each line appears twice"
    (let open Command.Let_syntax in
     let%map_open () = return () in
     fun () ->
       let i = ref 0 in
       with_return (fun { return } ->
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

let () = Command_unix_for_opam.run main
