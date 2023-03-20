open! Core

type +'a t =
  | Empty
  | List of 'a list
  | Concat of 'a t * 'a t

let empty = Empty
let of_list list = if List.is_empty list then Empty else List list

let append a b =
  match a with
  | Empty -> b
  | a ->
    (match b with
     | Empty -> a
     | b -> Concat (a, b))
;;

let concat list =
  match List.reduce list ~f:append with
  | None -> Empty
  | Some t -> t
;;

let concat_map list ~f = concat (List.map list ~f)

let rec iter t ~f =
  match t with
  | Empty -> ()
  | List list -> List.iter list ~f
  | Concat (a, b) ->
    iter a ~f;
    iter b ~f
;;

let to_list t =
  let q = Queue.create () in
  iter t ~f:(fun e -> Queue.enqueue q e);
  Queue.to_list q
;;
