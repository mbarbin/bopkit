type t = Partial_bit.t array [@@deriving compare, equal, quickcheck, sexp_of]

let enqueue_01star_char ~src:string ~dst:q =
  String.iter string ~f:(fun char ->
    match char with
    | '0' -> Queue.enqueue q (Some false)
    | '1' -> Queue.enqueue q (Some true)
    | '*' -> Queue.enqueue q None
    | _ -> ())
;;

let of_01star_chars_in_string s =
  let q = Queue.create () in
  enqueue_01star_char ~src:s ~dst:q;
  Queue.to_array q
;;

let to_string t =
  String.init (Array.length t) ~f:(fun i -> Bit_string_encoding.Bit_option.to_char t.(i))
;;

let of_text_file ~filename =
  let q = Queue.create () in
  In_channel.with_file filename ~f:(fun ic ->
    with_return (fun { return } ->
      while true do
        match In_channel.input_line ic with
        | None -> return ()
        | Some line ->
          (* Skip this line if it is a comment. *)
          if not (String.is_prefix line ~prefix:"//")
          then enqueue_01star_char ~src:line ~dst:q
      done));
  Queue.to_array q
;;

let to_text_channel t oc = Printf.fprintf oc "%s\n" (to_string t)

let to_text_file t ~filename =
  Out_channel.with_file filename ~f:(fun oc -> to_text_channel t oc)
;;

let conflicts t ~with_:bits =
  let bound = pred (min (Array.length t) (Array.length bits)) in
  let rec aux i =
    if i > bound
    then false
    else if Partial_bit.conflicts t.(i) ~with_:bits.(i)
    then true
    else aux (succ i)
  in
  aux 0
;;
