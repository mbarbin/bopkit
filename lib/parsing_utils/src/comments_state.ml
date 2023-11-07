module Comment_node = struct
  type 'a t' =
    | Resolved of 'a
    | Unresolved of
        { pos_cnum : int
        ; f : string list -> 'a
        }

  and 'a t = { mutable value : 'a t' }

  let equal equal_a t1 t2 =
    let t1 = t1.value in
    let t2 = t2.value in
    phys_equal t1 t2
    ||
    match t1, t2 with
    | Resolved a1, Resolved a2 -> equal_a a1 a2
    | _ -> false
  ;;

  let sexp_of_t sexp_of_a t =
    match t.value with
    | Resolved a -> [%sexp (a : a)]
    | Unresolved { pos_cnum; f = _ } -> [%sexp Unresolved { pos_cnum : int; f = "_" }]
  ;;

  type packed = T : 'a t -> packed

  let return a = { value = Resolved a }

  let value_exn t =
    match t.value with
    | Resolved a -> a
    | Unresolved { pos_cnum; f = _ } ->
      raise_s [%sexp "Comment_node hasn't been resolved", [%here], { pos_cnum : int }]
  ;;
end

type 'a comment_node = 'a Comment_node.t

module Token_kind = struct
  type t =
    | Comment of { comment : string }
    | Cut
  [@@deriving sexp_of]
end

module Token = struct
  type t =
    { pos_cnum : int
    ; token_kind : Token_kind.t
    }
  [@@deriving sexp_of]
end

module Doubly_linked = Core.Doubly_linked

(* The first tokens are the most recent. *)
type t =
  { tokens : Token.t Doubly_linked.t
  ; comment_nodes : Comment_node.packed Queue.t
  }

let debug = ref false

let the_t : t Lazy.t =
  lazy { tokens = Doubly_linked.create (); comment_nodes = Queue.create () }
;;

let insert_token t (token : Token.t) =
  if !debug
  then
    prerr_endline
      (Printf.sprintf
         "DEBUG: insert_token %s"
         (Sexp.to_string_hum [%sexp (token : Token.t)]));
  let (_ : Token.t Doubly_linked.Elt.t) =
    match Doubly_linked.find_elt t.tokens ~f:(fun t -> t.pos_cnum <= token.pos_cnum) with
    | None ->
      (* All token are strictly more recent, add this one to the back. *)
      Doubly_linked.insert_last t.tokens token
    | Some elt ->
      (match
         let previous_token = Doubly_linked.Elt.value elt in
         if previous_token.pos_cnum < token.pos_cnum
         then `Insert_before
         else (
           assert (previous_token.pos_cnum = token.pos_cnum);
           (* If they're both a cut, only keep the existing one. Otherwise we
              decide which order makes the most sense once for all here. *)
           match previous_token.token_kind, token.token_kind with
           | Cut, Cut -> (* Keep the existing one. *) `Do_not_insert
           | Cut, Comment _ -> `Insert_before
           | Comment _, Cut -> `Insert_after
           | Comment _, Comment _ ->
             (* The token inserted last is deemed more recent. *)
             `Insert_before)
       with
       | `Do_not_insert -> elt
       | `Insert_before -> Doubly_linked.insert_before t.tokens elt token
       | `Insert_after -> Doubly_linked.insert_after t.tokens elt token)
  in
  ()
;;

let add_comment ~lexbuf ~comment =
  let pos_cnum = Lexing.lexeme_start lexbuf in
  let t = force the_t in
  insert_token t { pos_cnum; token_kind = Comment { comment } }
;;

let add_cut_at_position ~pos_cnum =
  let t = force the_t in
  insert_token t { pos_cnum; token_kind = Cut }
;;

let comment_node ~attached_to ~f =
  let t = force the_t in
  let pos_cnum = attached_to.Lexing.pos_cnum in
  add_cut_at_position ~pos_cnum;
  let comment_node = { Comment_node.value = Unresolved { pos_cnum; f } } in
  Queue.enqueue t.comment_nodes (T comment_node);
  comment_node
;;

let extract_comments t ~pos_cnum =
  (* Find the closest cut at or before [pos_cnum], and then take all
     comments that are between this cut, and the previous cut in the
     structure, without removing the cuts themselves. *)
  let comments =
    match Doubly_linked.find_elt t.tokens ~f:(fun t -> t.pos_cnum <= pos_cnum) with
    | None -> []
    | Some closest_cut ->
      let rec aux acc elt =
        match Doubly_linked.next t.tokens elt with
        | None -> acc
        | Some elt ->
          (match (Doubly_linked.Elt.value elt).token_kind with
           | Cut -> acc
           | Comment { comment } -> aux ((elt, comment) :: acc) elt)
      in
      let comments = aux [] closest_cut in
      List.iter comments ~f:(fun (elt, _) -> Doubly_linked.remove t.tokens elt);
      List.map comments ~f:snd
  in
  if !debug
  then
    prerr_endline
      (Printf.sprintf
         "DEBUG: retrieve_comments pos_cnum=%d => %d comments"
         pos_cnum
         (List.length comments));
  comments
;;

let reset () =
  if !debug then prerr_endline "DEBUG: reset";
  let { tokens; comment_nodes } = force the_t in
  Doubly_linked.clear tokens;
  Queue.clear comment_nodes
;;

let attach_comments () =
  let t = force the_t in
  Queue.iter t.comment_nodes ~f:(function T comment_node ->
    (match comment_node.value with
     | Resolved _ -> ()
     | Unresolved { pos_cnum; f } ->
       let comments = extract_comments t ~pos_cnum in
       comment_node.value <- Resolved (f comments)));
  Queue.clear t.comment_nodes
;;

let wrap ~f =
  reset ();
  Exn.protect ~f ~finally:attach_comments
;;
