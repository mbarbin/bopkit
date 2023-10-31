module Node = struct
  type t =
    { output : Ident.t
    ; muxtree : Muxtree.t
    }
  [@@deriving sexp_of]
end

type t = Node.t list [@@deriving sexp_of]

let of_muxtrees muxtrees =
  let fresh_internal_ident =
    let index = ref 0 in
    fun () ->
      Int.incr index;
      Ident.Internal !index
  in
  let nodes : Node.t Queue.t = Queue.create () in
  let shared_muxtrees = Hashtbl.create (module Muxtree) in
  let share_new_muxtree muxtree =
    let ident = fresh_internal_ident () in
    Hashtbl.set shared_muxtrees ~key:muxtree ~data:ident;
    Queue.enqueue nodes { output = ident; muxtree };
    Muxtree.Signal ident
  in
  let rec aux muxtree =
    let muxtree = Muxtree.normalize muxtree in
    match muxtree with
    | Constant _ | Signal _ -> muxtree
    | Not_signal _ | Mux _ ->
      (match Hashtbl.find shared_muxtrees muxtree with
       | Some ident -> Muxtree.Signal ident
       | None ->
         (match muxtree with
          | Constant _ | Signal _ -> assert false
          | Not_signal _ -> share_new_muxtree muxtree
          | Mux { input = j; vdd = mux_vdd; gnd = mux_gnd } ->
            let aux_vdd = aux mux_vdd
            and aux_gnd = aux mux_gnd in
            let muxtree =
              Muxtree.normalize (Mux { input = j; vdd = aux_vdd; gnd = aux_gnd })
            in
            (match muxtree with
             | Constant _ | Signal _ -> muxtree
             | Not_signal _ | Mux _ ->
               (match Hashtbl.find shared_muxtrees muxtree with
                | Some ident -> Signal ident
                | None -> share_new_muxtree muxtree))))
  in
  List.iteri muxtrees ~f:(fun i muxtree ->
    Queue.enqueue nodes { output = Output i; muxtree = aux muxtree });
  Queue.to_list nodes
;;
