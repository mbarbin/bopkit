(* A program to generate initial values for Visa's RAM memory. *)

let () =
  Command.basic
    ~summary:"generate initial contents for visa's RAM memory"
    (let open Command.Let_syntax in
     let%map_open ofday =
       anon ("HH:MM:SS" %: string) >>| Time_ns.Ofday.of_string >>| Time_ns.Ofday.to_parts
     and date = anon ("YYYY/MM/DD" %: string) >>| Date.of_string in
     fun () ->
       let print name value =
         let tmp = Array.create ~len:8 false in
         Bit_array.blit_int ~src:value ~dst:tmp;
         print_endline (sprintf "%s // %s" (Bit_array.to_string tmp) name)
       in
       print_endline "// Initial memory contents for Visa";
       print_endline
         (sprintf
            "// Generated by: ./get_date.exe %s"
            (Sys.get_argv ()
             |> Array.to_list
             |> List.tl_exn
             |> List.map ~f:(sprintf "'%s'")
             |> String.concat ~sep:" "));
       print "sec" ofday.sec;
       print "min" ofday.min;
       print "hou" ofday.hr;
       print "day" (date |> Date.day |> pred);
       print "mon" (date |> Date.month |> Month.to_int |> pred);
       print "yea" ((date |> Date.year) % 100);
       ())
  |> Command_unix_for_opam.run
;;
