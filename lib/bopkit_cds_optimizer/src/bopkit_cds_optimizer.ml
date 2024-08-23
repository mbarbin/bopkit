open Bopkit_circuit

module Tagged_gate = struct
  type t =
    { mutable gate : Gate.t
    ; mutable is_deleted : bool
    }

  let make gate = { gate; is_deleted = false }
end

module Index_mapping = struct
  (* t.(i) is the index of the gate i in a new cds where indices have changed. *)
  type t = int array

  let map_gate_kind (t : t) ~(gate_kind : Gate_kind.t) : Gate_kind.t =
    match gate_kind with
    | Regr { index_of_regt = i } -> Regr { index_of_regt = t.(i) }
    | Input | Output | Id | Not | And | Or | Xor | Mux
    | Rom { loc = _; name = _; index = _ }
    | Ram { loc = _; name = _; address_width = _; data_width = _; contents = _ }
    | Reg { initial_value = _ }
    | Regt | Clock | Gnd | Vdd
    | External
        { loc = _
        ; name = _
        ; method_name = _
        ; arguments = _
        ; protocol_prefix = _
        ; index = _
        } -> gate_kind
  ;;

  let map_output_wire (t : t) ~(output_wire : Output_wire.t) =
    { Output_wire.gate_index = t.(output_wire.gate_index)
    ; input_index = output_wire.input_index
    }
  ;;

  let map_gate (t : t) ~(gate : Gate.t) : Gate.t =
    { gate_kind = map_gate_kind t ~gate_kind:gate.gate_kind
    ; input = gate.input
    ; output = gate.output
    ; output_wires =
        Array.map gate.output_wires ~f:(fun output_wires ->
          List.map output_wires ~f:(fun output_wire -> map_output_wire t ~output_wire))
    }
  ;;
end

let rebuild (tagged_cds : Tagged_gate.t array) =
  (* index_mapping.(i) is the index of the gate i in the optimized cds. *)
  let new_cds_length = Array.count tagged_cds ~f:(fun t -> not t.is_deleted) in
  let new_cds = Array.create ~len:new_cds_length tagged_cds.(0).gate in
  let index_mapping = Array.mapi tagged_cds ~f:(fun i _ -> i) in
  let new_index = ref (-1) in
  Array.iteri tagged_cds ~f:(fun i { gate; is_deleted } ->
    if not is_deleted
    then (
      incr new_index;
      let index = !new_index in
      index_mapping.(i) <- index;
      new_cds.(index) <- gate));
  Array.map new_cds ~f:(fun gate -> Index_mapping.map_gate index_mapping ~gate)
;;

(* If an output_wire points to an [Id] gate, it traverses it, recursively return
   the traversal of its own output_wires. *)
let rec traverse_ids (cds : Cds.t) ~output_wire =
  let { Output_wire.gate_index; input_index } = output_wire in
  let gate = cds.(gate_index) in
  match gate.gate_kind with
  | Id ->
    let output_wires = gate.output_wires.(input_index) in
    List.concat_map output_wires ~f:(fun output_wire -> traverse_ids cds ~output_wire)
  | _ -> [ output_wire ]
;;

let optimize (cds : Cds.t) =
  let tagged_cds = Array.map cds ~f:(fun gate -> Tagged_gate.make gate) in
  Array.iter tagged_cds ~f:(fun t ->
    t.gate
    <- { t.gate with
         output_wires =
           Array.map t.gate.output_wires ~f:(fun output_wires ->
             List.concat_map output_wires ~f:(fun output_wire ->
               traverse_ids cds ~output_wire)
             |> List.sort ~compare:Output_wire.compare)
       };
    match t.gate.gate_kind with
    | (Clock | Gnd | Vdd) as constant ->
      let bit =
        match constant with
        | Clock | Vdd -> true
        | Gnd -> false
        | _ -> assert false
      in
      Array.iter t.gate.output_wires ~f:(fun output_wires ->
        List.iter output_wires ~f:(fun { gate_index; input_index } ->
          cds.(gate_index).input.(input_index) <- bit));
      (* Because these gates have no input, it isn't the case that another gate
         may be pointed to it, thus there is not disconnected output_wires to
         take care of. *)
      t.is_deleted <- true
    | Id -> t.is_deleted <- true
    | Input | Output | Not | And | Or | Xor | Mux
    | Rom { loc = _; name = _; index = _ }
    | Ram { loc = _; name = _; address_width = _; data_width = _; contents = _ }
    | Reg { initial_value = _ }
    | Regr { index_of_regt = _ }
    | Regt
    | External
        { loc = _
        ; name = _
        ; method_name = _
        ; arguments = _
        ; protocol_prefix = _
        ; index = _
        } -> ());
  rebuild tagged_cds
;;
