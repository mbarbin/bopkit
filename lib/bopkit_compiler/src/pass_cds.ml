let pass (e : Expanded_nodes.t) =
  let output_wires = Expanded_nodes.output_wires e in
  Array.map
    e
    ~f:(fun { Expanded_nodes.Node.gate_kind; inputs; outputs } : Bopkit_circuit.Gate.t ->
      match gate_kind with
      | Clock | Vdd ->
        { gate_kind
        ; input = [||]
        ; output = [| true |]
        ; output_wires = [| Output_wires.find_or_empty output_wires ~key:outputs.(0) |]
        }
      | Reg { initial_value } ->
        (* The [output] will be replaced during the split register step.
           In the [input], the bit [1] is the enable. It is set to 1,
           and will stay equal to 1 if this gate only has 1 single
           input, which matches the behavior of register without enable
           bits (they're always enabled). *)
        { gate_kind
        ; input = [| initial_value; true |]
        ; output = [||]
        ; output_wires = [| Output_wires.find_or_empty output_wires ~key:outputs.(0) |]
        }
      | prim ->
        { gate_kind = prim
        ; input = Array.create ~len:(Array.length inputs) false
        ; output = Array.create ~len:(Array.length outputs) false
        ; output_wires =
            Array.map outputs ~f:(fun key -> Output_wires.find_or_empty output_wires ~key)
        })
;;
