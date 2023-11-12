open! Pp.O

module Fragments = struct
  type t =
    | T :
        { variables : string Queue.t
        ; declarations : 'a Pp.t Queue.t
        ; assignments : (string * string) Queue.t
        ; nodes : 'a Pp.t Queue.t
        ; rams : 'a Pp.t Queue.t
        ; update_registers : 'a Pp.t Queue.t
        }
        -> t
end

let fragments_of_cds ~(cds : Bopkit_circuit.Cds.t) ~error_log =
  let fresh_ram =
    let index = ref (-1) in
    fun () ->
      Int.incr index;
      !index
  in
  let q_variables = Queue.create () in
  let q_declarations = Queue.create () in
  let q_assignments = Queue.create () in
  let q_nodes = Queue.create () in
  let q_rams = Queue.create () in
  let q_update_registers = Queue.create () in
  let output_variables = Hashtbl.create (module Bopkit_circuit.Output_wire) in
  let emit s = Queue.enqueue q_nodes s in
  Array.iteri cds ~f:(fun gate_index gate ->
    let input_width = Array.length gate.input in
    let output_width = Array.length gate.output in
    let inputs =
      Array.mapi gate.input ~f:(fun input_index input_value ->
        match Hashtbl.find output_variables { gate_index; input_index } with
        | Some v -> v
        | None ->
          let constant = if input_value then "1" else "0" in
          Error_log.debug
            error_log
            [ Pp.textf
                "Unassigned input (%d, %d) : Constant = %s"
                gate_index
                input_index
                constant
            ];
          constant)
    in
    let outputs =
      Array.mapi gate.output_wires ~f:(fun output_index output_wires ->
        let s = Printf.sprintf "s_%d_%d" gate_index output_index in
        Queue.enqueue q_variables s;
        List.iter output_wires ~f:(fun output_wire ->
          if Hashtbl.mem output_variables output_wire
          then
            raise_s
              [%sexp
                "Internal error, duplicated output_wires"
                , [%here]
                , { output_wire : Bopkit_circuit.Output_wire.t }]
          else Hashtbl.set output_variables ~key:output_wire ~data:s);
        s)
    in
    match gate.gate_kind with
    | Input ->
      let input_width = output_width in
      Error_log.debug error_log [ Pp.textf "Input Count : %d" input_width ];
      Queue.enqueue q_declarations (C_code.input_declaration ~input_width);
      Queue.enqueue q_declarations (C_code.input ~input_width);
      emit
        (C_code.call ~name:"input" ~args:(Array.map outputs ~f:(fun o -> "&" ^ o))
         ++ Pp.verbatim ";")
    | Output ->
      let output_width = input_width in
      Error_log.debug error_log [ Pp.textf "Output Count : %d" output_width ];
      Queue.enqueue q_declarations (C_code.output_declaration ~output_width);
      Queue.enqueue q_declarations (C_code.output ~output_width);
      emit (C_code.call ~name:"output" ~args:inputs ++ Pp.verbatim ";")
    | Id -> emit (C_code.of_id outputs.(0) inputs.(0))
    | Not -> emit (C_code.of_not outputs.(0) inputs.(0))
    | And -> emit (C_code.of_and outputs.(0) inputs.(0) inputs.(1))
    | Or -> emit (C_code.of_or outputs.(0) inputs.(0) inputs.(1))
    | Xor -> emit (C_code.of_xor outputs.(0) inputs.(0) inputs.(1))
    | Mux -> emit (C_code.of_mux outputs.(0) inputs.(0) inputs.(1) inputs.(2))
    | Rom { loc = _; name = _; index = n } ->
      let args =
        Array.concat [ inputs; outputs ]
        |> Array.mapi ~f:(fun i arg -> if i < input_width then arg else "&" ^ arg)
      in
      emit (C_code.call ~name:(Printf.sprintf "call_rom%d" n) ~args ++ Pp.verbatim ";")
    | Ram { contents; _ } ->
      let num_ram = fresh_ram () in
      Queue.enqueue q_rams (C_code.of_ram ~id:num_ram ~contents);
      let args =
        Array.concat [ inputs; outputs ]
        |> Array.mapi ~f:(fun i arg -> if i < input_width then arg else "&" ^ arg)
      in
      emit
        (C_code.call ~name:(Printf.sprintf "call_ram%d" num_ram) ~args ++ Pp.verbatim ";")
    | Clock -> emit (Pp.verbatim (Printf.sprintf "%s = 1;" outputs.(0)))
    | Gnd -> emit (Pp.verbatim (Printf.sprintf "%s = 0;" outputs.(0)))
    | Vdd -> emit (Pp.verbatim (Printf.sprintf "%s = 1;" outputs.(0)))
    | External { loc; _ } ->
      Error_log.raise
        error_log
        ~loc
        [ Pp.text "External blocks are not supported by bop2c." ]
    | Regt -> ()
    | Regr { index_of_regt = index } ->
      let s_index = Printf.sprintf "s_%d_0" index in
      Queue.enqueue q_assignments (s_index, if cds.(index).output.(0) then "1" else "0");
      Queue.enqueue
        q_update_registers
        (Pp.verbatim
           (if String.equal inputs.(1) "1"
            then Printf.sprintf "%s = %s;" s_index inputs.(0)
            else Printf.sprintf "if (%s) %s = %s;" inputs.(1) s_index inputs.(0)))
    | _ -> ());
  Fragments.T
    { variables = q_variables
    ; declarations = q_declarations
    ; assignments = q_assignments
    ; nodes = q_nodes
    ; rams = q_rams
    ; update_registers = q_update_registers
    }
;;

let emit_c_code ~(circuit : Bopkit_circuit.Circuit.t) ~error_log ~to_:oc =
  let path = circuit.path in
  let main = circuit.main in
  let cds = circuit.cds in
  let roms = circuit.rom_memories in
  let (Fragments.T
        { variables; declarations; assignments; nodes; rams; update_registers })
    =
    fragments_of_cds ~cds ~error_log
  in
  let pp =
    [ Pp.verbatim (Printf.sprintf "/* Program generated by bop2c */") ++ Pp.newline
    ; Pp.verbatim
        (Printf.sprintf
           "/* Original circuit : %s , Main = \"%s\" */"
           (path |> Fpath.to_string)
           main)
      ++ Pp.newline
    ; Pp.newline
    ; Pp.verbatim "#include <stdlib.h>" ++ Pp.newline
    ; Pp.verbatim "#include <stdio.h>" ++ Pp.newline
    ; Pp.newline
    ; (C_code.read_line_from_stdin |> Lazy.force) ++ Pp.newline
    ; Pp.newline
    ; Pp.concat_map (rams |> Queue.to_list) ~sep:Pp.newline ~f:(fun t -> t ++ Pp.newline)
    ; (if Queue.is_empty rams then Pp.nop else Pp.newline)
    ; Pp.concat_map
        (roms |> Array.mapi ~f:(fun i e -> i, e) |> Array.to_list)
        ~sep:Pp.newline
        ~f:(fun (i, contents) -> C_code.of_rom ~id:i ~contents ++ Pp.newline)
    ; (if Array.is_empty roms then Pp.nop else Pp.newline)
    ; Pp.concat_map (declarations |> Queue.to_list) ~sep:Pp.newline ~f:(fun t ->
        t ++ Pp.newline)
    ; (if Queue.is_empty declarations then Pp.nop else Pp.newline)
    ; (if Queue.is_empty variables
       then Pp.nop
       else
         [ Pp.verbatim "unsigned char "
         ; Pp.concat_map
             (variables |> Queue.to_list)
             ~sep:(Pp.verbatim "," ++ Pp.space)
             ~f:(fun var -> Pp.verbatim var)
         ; Pp.verbatim ";"
         ; Pp.newline
         ]
         |> Pp.concat
         |> Pp.box ~indent:2)
    ; (if Queue.is_empty variables then Pp.nop else Pp.newline)
    ; [ Pp.verbatim "int main(int argc, char **argv) {" ++ Pp.newline
      ; Pp.verbatim "int ncy = 1, index_cy = 0, r = 0;" ++ Pp.newline
      ; Pp.verbatim "if (argc > 1) r = sscanf(argv[1], \"%d\", &ncy);" ++ Pp.newline
      ; Pp.concat_map (assignments |> Queue.to_list) ~sep:Pp.newline ~f:(fun (v, value) ->
          Pp.verbatim (Printf.sprintf "%s = %s;" v value))
      ; (if Queue.is_empty assignments then Pp.nop else Pp.newline)
      ; [ Pp.verbatim "while (index_cy < ncy) {" ++ Pp.newline
        ; Pp.verbatim "if (r) index_cy++;" ++ Pp.newline
        ; Pp.concat (nodes |> Queue.to_list) ~sep:Pp.newline
        ; (if Queue.is_empty update_registers
           then Pp.nop
           else
             Pp.concat
               [ Pp.newline
               ; Pp.verbatim "/* Update registers. */" ++ Pp.newline
               ; Pp.concat (update_registers |> Queue.to_list) ~sep:Pp.newline
               ])
        ]
        |> Pp.concat
        |> Pp.box ~indent:2
      ; Pp.newline
      ; Pp.verbatim "}" ++ Pp.newline
      ; Pp.verbatim "return(0);"
      ]
      |> Pp.concat
      |> Pp.box ~indent:2
    ; Pp.newline
    ; Pp.verbatim "}" ++ Pp.newline
    ]
    |> Pp.concat
  in
  Out_channel.output_string oc (pp |> Pp_extended.to_string);
  Out_channel.flush oc
;;
