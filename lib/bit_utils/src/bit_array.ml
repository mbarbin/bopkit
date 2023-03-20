open! Core

type t = bool array [@@deriving compare, equal, quickcheck, sexp_of]

let enqueue_01_char ~src:string ~dst:q =
  String.iter string ~f:(fun char ->
    match char with
    | '0' -> Queue.enqueue q false
    | '1' -> Queue.enqueue q true
    | _ -> ())
;;

let of_01_chars_in_string s =
  let q = Queue.create () in
  enqueue_01_char ~src:s ~dst:q;
  Queue.to_array q
;;

let to_string (t : t) =
  String.init (Array.length t) ~f:(fun i -> Bit_string_encoding.Bit.to_char t.(i))
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
          then enqueue_01_char ~src:line ~dst:q
      done));
  Queue.to_array q
;;

let to_text_channel t oc = Printf.fprintf oc "%s\n" (to_string t)

let to_text_file t ~filename =
  Out_channel.with_file filename ~f:(fun oc -> to_text_channel t oc)
;;

let to_int bits =
  let res = ref 0 in
  for i = pred (Array.length bits) downto 0 do
    res := (!res * 2) + if bits.(i) then 1 else 0
  done;
  !res
;;

let to_signed_int bits =
  let len = Array.length bits in
  let modo = ref 1 in
  let unsigned_int =
    let res = ref 0 in
    for i = pred len downto 0 do
      modo := !modo * 2;
      res := (!res * 2) + if bits.(i) then 1 else 0
    done;
    !res
  in
  if len > 0 && bits.(pred len) then unsigned_int - !modo else unsigned_int
;;

let blit_int ~src:i ~dst:tab =
  let len = Array.length tab in
  let modo = Int.pow 2 len in
  let j = ref (i % modo) in
  for i = 0 to pred len do
    tab.(i) <- !j mod 2 = 1;
    j := !j / 2
  done
;;

let blit_init ~dst:tab ~f:fct =
  let len = Array.length tab in
  for i = 0 to pred len do
    tab.(i) <- fct i
  done
;;

module Short_sexp = struct
  type nonrec t = t

  let sexp_of_t t = Sexp.Atom (to_string t)
end
