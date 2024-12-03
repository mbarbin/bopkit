type t = Gate.t array

let sexp_of_t t =
  Sexp.List
    (Array.mapi t ~f:(fun i gate -> [%sexp (i : int), (gate : Gate.t)]) |> Array.to_list)
;;

let topological_sort (cds : t) =
  let ncds = Array.length cds in
  (* [order] is the new order of gates. For example, [order.(0)] is the index of
     the first node. [order_inv] is the reciprocal bijection. *)
  let order = Array.create ~len:ncds 0 in
  let order_inv = Array.create ~len:ncds 0 in
  let visited = Array.create ~len:ncds false in
  let no = ref (Int.pred ncds) in
  (* Run a dfs traversal and set [order] and [order_inf]. *)
  let rec dfs n =
    visited.(n) <- true;
    Array.iter cds.(n).output_wires ~f:(fun output_wires ->
      List.iter output_wires ~f:(fun { Output_wire.gate_index; _ } ->
        if not visited.(gate_index) then dfs gate_index));
    order.(!no) <- n;
    order_inv.(n) <- !no;
    Int.decr no
  in
  (* Using [order] and [order_inv], update the output_wires of a given gate. *)
  let update_output_wires (gate : Gate.t) =
    for i = 0 to Int.pred (Array.length gate.output_wires) do
      gate.output_wires.(i)
      <- List.map gate.output_wires.(i) ~f:(fun { gate_index = n; input_index = c } ->
           { Output_wire.gate_index = order_inv.(n); input_index = c })
         |> List.sort ~compare:Output_wire.compare
    done;
    match gate.gate_kind with
    | Regr { index_of_regt = n } ->
      { Gate.gate_kind = Regr { index_of_regt = order_inv.(n) }
      ; input = gate.input
      ; output = gate.output
      ; output_wires = gate.output_wires
      }
    | _ -> gate
  in
  let reorder_cds () =
    Array.init ncds ~f:(fun i -> update_output_wires cds.(order.(i)))
  in
  Err.debug (lazy [ Pp.text "Running topological sort of circuit" ]);
  (match cds.(0).gate_kind with
   | Input -> ()
   | gate_kind ->
     raise_s
       [%sexp
         "Unexpected gate_kind at index 0, expected input gate"
       , [%here]
       , { gate_kind : Gate_kind.t }]);
  for i = Int.pred ncds downto 0 do
    if not visited.(i) then dfs i
  done;
  let newcds = reorder_cds () in
  for i = 0 to Int.pred ncds do
    cds.(i) <- newcds.(i)
  done
;;

let detect_cycle (cds : t) =
  let n = Array.length cds in
  let visited = Array.create ~len:n false
  and parents = Array.create ~len:n false in
  let fun_ou a b = a || b in
  let rec iter_func { Output_wire.gate_index = w; _ } =
    if parents.(w) then true else if not visited.(w) then dfs w else false
  and dfs v =
    visited.(v) <- true;
    parents.(v) <- true;
    let retval =
      Array.fold
        ~f:fun_ou
        ~init:false
        (Array.map
           ~f:(fun l -> List.fold_left ~f:fun_ou ~init:false (List.map ~f:iter_func l))
           cds.(v).output_wires)
    in
    parents.(v) <- false;
    retval
  in
  Array.fold
    ~f:fun_ou
    ~init:false
    (Array.init n ~f:(fun i -> if not visited.(i) then dfs i else false))
;;

let split_registers (cds : t) =
  let ncds = Array.length cds in
  let new_node_no = ref ncds in
  let count_registers =
    Array.sum
      (module Int)
      cds
      ~f:(fun gate ->
        match gate.gate_kind with
        | Reg _ -> 1
        | _ -> 0)
  in
  let new_ncds = Array.length cds + count_registers in
  let new_cds = Array.create ~len:new_ncds cds.(0) in
  (* While going through cds, we create the new register transmitters which we
     place at the end of [new_cds]. *)
  Array.iteri cds ~f:(fun i gate ->
    match gate.gate_kind with
    | Reg { initial_value } ->
      let index_of_regt = !new_node_no in
      new_cds.(index_of_regt)
      <- { gate_kind = Regt
         ; input = [||]
         ; output = [| initial_value |]
         ; output_wires = cds.(i).output_wires
         };
      new_cds.(i)
      <- { gate_kind = Regr { index_of_regt }
         ; input = cds.(i).input
         ; output = [||]
         ; output_wires = [||]
         };
      Int.incr new_node_no
    | _ -> new_cds.(i) <- gate);
  new_cds
;;
