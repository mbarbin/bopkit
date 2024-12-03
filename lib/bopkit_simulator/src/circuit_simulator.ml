module One_cycle_result = struct
  type t =
    | Continue
    | Quit
end

let bits_of_string s =
  let exception Bits_of_string in
  match
    Array.init (String.length s) ~f:(fun i ->
      match s.[i] with
      | '1' -> true
      | '0' -> false
      | _ -> raise Bits_of_string)
  with
  | t -> Some t
  | exception Bits_of_string -> None
;;

(* Returns the decimal value encoded by the [len] bits of [src] that starts at
   [pos], starting from the least significant bit. *)
let decimal_of_partial_array ~src:t ~pos:offset ~len:long =
  let len = Array.length t
  and index_fin = offset + long in
  if index_fin > len
  then failwith "decimal_of_partial_array"
  else (
    let rec aux accu i =
      if i < offset
      then accu
      else aux ((2 * accu) + if Array.unsafe_get t i then 1 else 0) (Int.pred i)
    in
    aux 0 (Int.pred index_fin))
;;

module Pending_input = struct
  type t =
    { input : string
    ; loc : Loc.t
    }
end

module External_process = struct
  type t =
    { loc : Loc.t
    ; command : string
    ; output_pipe : In_channel.t
    ; input_pipe : Out_channel.t
    ; mutable pending_input : Pending_input.t option
      (* [pending_input] is used to improve error messages in the case of a
       process terminating before responding to an input. *)
    }
end

type t =
  { circuit : Bopkit_circuit.Circuit.t
  ; mutable external_process : External_process.t array
  ; regr_indexes : int array
  ; input : Bit_array.t
  ; output : Bit_array.t
  }

let of_circuit ~(circuit : Bopkit_circuit.Circuit.t) =
  let cds = circuit.cds in
  let regr_indexes =
    Array.foldi cds ~init:[] ~f:(fun index accu node ->
      match node.gate_kind with
      | Regr _ -> index :: accu
      | _ -> accu)
    |> Array.of_list
  in
  let input =
    let gate = cds.(0) in
    match gate.gate_kind with
    | Input -> gate.output
    | gate_kind ->
      raise_s
        [%sexp
          "Expected first gate of circuit to be its input"
        , { gate_kind : Bopkit_circuit.Gate_kind.t }]
  in
  let output =
    match
      Array.find cds ~f:(fun gate ->
        match gate.gate_kind with
        | Output -> true
        | _ -> false)
    with
    | Some gate -> gate.input
    | None -> failwith "No Output node found in the cds"
  in
  { circuit; external_process = [||]; regr_indexes; input; output }
;;

let input t = t.input
let output t = t.output
let cds t = t.circuit.cds
let rom_memories t = t.circuit.rom_memories
let external_blocks t = t.circuit.external_blocks
let main t = t.circuit.main

let init t =
  let () =
    let env = Core_unix.environment () in
    let key = "PATH" in
    let path =
      Array.find_map env ~f:(fun s ->
        match String.lsplit2 s ~on:'=' with
        | Some (path, value) -> Option.some_if (String.equal path key) value
        | None -> None)
      |> Option.value ~default:""
    in
    Core_unix.putenv
      ~key
      ~data:(String.concat ~sep:":" (Bopkit_sites.Sites.stdbin @ [ path ]))
  in
  let external_blocks_table = Hashtbl.create (module String) in
  let external_processes : External_process.t Queue.t = Queue.create () in
  let external_index = ref 0 in
  Array.iter (cds t) ~f:(fun gate ->
    match gate.gate_kind with
    | External { loc; name; method_name; arguments; protocol_prefix; index } ->
      let { Bopkit.Expanded_netlist.loc = _
          ; name
          ; attributes = _
          ; init_messages
          ; methods
          ; command
          }
        =
        match
          Array.find
            (external_blocks t)
            ~f:(fun (block : Bopkit.Expanded_netlist.external_block) ->
              String.equal block.name name)
        with
        | Some x -> x
        | None ->
          Err.raise
            ~loc
            [ Pp.textf "The external block '%s' is undefined." name ]
            ~hints:[ Pp.text "Did you forget to include a file in which it is defined?" ]
      in
      let protocol_method =
        match method_name with
        | None -> None
        | Some method_name ->
          (match
             List.find methods ~f:(fun m -> String.equal method_name m.method_name)
           with
           | Some { method_name; attributes = _ } -> Some method_name
           | None ->
             Err.warning
               ~loc
               [ Pp.textf
                   "External block method '%s.%s' is not defined and will be passed to \
                    the external process as is. Note that this will probably not be \
                    allowed in a future version."
                   name
                   method_name
               ]
               ~hints:[ Pp.text "Declare the method in the external block definition." ];
             Some method_name)
      in
      let protocol_arguments =
        match arguments with
        | [] -> None
        | _ :: _ ->
          let arguments =
            List.map arguments ~f:(fun arg -> Printf.sprintf "\"%s\"" arg)
          in
          Some (arguments |> String.concat ~sep:" ")
      in
      let this_protocol_prefix =
        match protocol_method, protocol_arguments with
        | None, None -> ""
        | Some m, None -> m ^ " "
        | None, Some args -> args ^ " "
        | Some m, Some args -> m ^ " " ^ args ^ " "
      in
      (match Hashtbl.find external_blocks_table name with
       | Some block_index ->
         Err.debug
           ~loc
           (lazy [ Pp.textf "External process[%d] already started." block_index ]);
         (* Even though this gate is unique in the cds, it is possible that its
            gate_kind has been shared between several gates. This happens when a
            block is called multiple times at different part of the program.
            Given that it comes from the same syntactic place, it's index and
            protocol prefix will be the same. *)
         Core.Set_once.set_if_none index [%here] block_index;
         Core.Set_once.set_if_none protocol_prefix [%here] this_protocol_prefix
       | None ->
         let this_index = !external_index in
         Int.incr external_index;
         Err.debug
           ~loc
           (lazy [ Pp.textf "Starting external process[%d] = '%s'." this_index command ]);
         Hashtbl.set external_blocks_table ~key:name ~data:this_index;
         let output_pipe, input_pipe = Core_unix.open_process command in
         let external_process =
           { External_process.loc
           ; command
           ; output_pipe
           ; input_pipe
           ; pending_input = None
           }
         in
         Queue.enqueue external_processes external_process;
         Core.Set_once.set_exn index [%here] this_index;
         Core.Set_once.set_exn protocol_prefix [%here] this_protocol_prefix;
         With_return.with_return (fun return ->
           List.iter init_messages ~f:(fun message ->
             Out_channel.output_lines input_pipe [ message ];
             Out_channel.flush input_pipe;
             external_process.pending_input <- Some { loc; input = message };
             match In_channel.input_line output_pipe with
             | Some (_ : string) -> external_process.pending_input <- None
             | None ->
               Err.error
                 ~loc
                 [ Pp.textf "External process[%d] ('%s')" this_index command
                 ; Pp.textf "received: '%s' and exited abnormally." message
                 ];
               return.return ())))
    | _ -> ());
  Array.iter (external_blocks t) ~f:(fun { name = a; loc; _ } ->
    (* As it stands, this warning is inconvenient. First, it is only produced at
       runtime, and not during the [check] command. Moreover, it is based on
       actual use, which makes some noise when some blocks are only used if
       DEBUG=1. Perhaps a better warning would be based on looking for all
       expressions in the netlist, and warning during [check] only for external
       blocks define in the same file, and if they never appear, regardless of
       parameters. Disabled for now. *)
    if (not (Hashtbl.mem external_blocks_table a)) && false
    then Err.warning ~loc [ Pp.textf "Unused external block '%s'" a ]);
  t.external_process <- Queue.to_array external_processes;
  Err.info [ Pp.textf " Simulation <'%s'>" (main t).txt ]
;;

let or_exit_error e =
  (match (e : Core_unix.Exit_or_signal.t) with
   | Ok () -> Ok ()
   | Error (`Signal signal) ->
     if Core.Signal.equal signal Core.Signal.int then Ok () else e
   | Error (`Exit_non_zero _) -> e)
  |> Core_unix.Exit_or_signal.or_error
;;

let quit t =
  let uncaught_exceptions = Queue.create () in
  for i = 0 to Int.pred (Array.length t.external_process) do
    let process = t.external_process.(i) in
    Err.debug
      ~loc:process.loc
      (lazy [ Pp.textf "Closing external process[%d] = '%s'." i process.command ]);
    match
      Core_unix.close_process (process.output_pipe, process.input_pipe) |> or_exit_error
    with
    | Ok () -> ()
    | Error e ->
      let loc =
        match process.pending_input with
        | None -> process.loc
        | Some t -> t.loc
      in
      Err.error
        ~loc
        [ Pp.textf "External process[%d] ('%s')" i process.command
        ; Pp.textf
            "%sexited abnormally:"
            (match process.pending_input with
             | None -> ""
             | Some { loc = _; input } -> Printf.sprintf "received: '%s' and " input)
        ; Pp.textf "%s" (Error.to_string_hum e)
        ]
    | exception End_of_file ->
      Err.debug
        ~loc:process.loc
        (lazy
          [ Pp.textf
              "Closing external process[%d] = '%s'. (status : %s [%d])"
              i
              process.command
              "broken pipe"
              (-1)
          ])
    | exception e ->
      prerr_endline "Circuit#quit error";
      Queue.enqueue uncaught_exceptions e
  done;
  if not (Queue.is_empty uncaught_exceptions)
  then
    raise_s
      [%sexp
        "Uncaught exceptions during external process termination"
      , (Queue.to_list uncaught_exceptions : exn list)]
;;

(* For each [Regr], update its matching [Regt]. Called at the end of each cycle. *)
let update_registers t =
  let cds = cds t in
  Array.iter t.regr_indexes ~f:(fun i ->
    let gate = cds.(i) in
    match gate.gate_kind with
    | Regr { index_of_regt = n } ->
      (* The bit input.(1) of a Regr gate is its [enable] bit. *)
      if gate.input.(1) then cds.(n).output.(0) <- gate.input.(0)
    | _ -> ())
;;

let fct_id ~input ~output =
  Array.unsafe_blit ~src:input ~src_pos:0 ~dst:output ~dst_pos:0 ~len:(Array.length input)
;;

let fct_not ~input ~output = Array.unsafe_set output 0 (not (Array.unsafe_get input 0))

let fct_and ~input ~output =
  Array.unsafe_set output 0 (Array.unsafe_get input 0 && Array.unsafe_get input 1)
;;

let fct_or ~input ~output =
  Array.unsafe_set output 0 (Array.unsafe_get input 0 || Array.unsafe_get input 1)
;;

let fct_xor ~input ~output =
  Array.unsafe_set output 0 Bool.(Array.unsafe_get input 0 <> Array.unsafe_get input 1)
;;

let fct_mux ~input ~output =
  Array.unsafe_set
    output
    0
    (if Array.unsafe_get input 0
     then Array.unsafe_get input 1
     else Array.unsafe_get input 2)
;;

let fct_rom t ~input ~output ~index =
  let address = Bit_array.to_int input in
  Array.blit
    ~src:(rom_memories t).(index).(address)
    ~src_pos:0
    ~dst:output
    ~dst_pos:0
    ~len:(Array.length output)
;;

(* The arguments of a ram call with address width e and data width s
   are:

   {v
     output[s] = RAM(read_address[e], write_address[e], enable, data[s])
   v}
*)
let fct_ram (_ : t) ~(gate : Bopkit_circuit.Gate.t) =
  match gate.gate_kind with
  | Ram { loc = _; name = _; address_width; data_width; contents } ->
    let read_address_pos = 0 in
    let write_address_pos = read_address_pos + address_width in
    let enable_pos = write_address_pos + address_width in
    let data_pos = enable_pos + 1 in
    let enable = gate.input.(enable_pos) in
    if enable
    then (
      (* There was a proposal for the gate to return the value set in memory in
         this case, but currently this breaks the micro processor visa. This
         needs further investigation. Currently left untouched, which means it
         will continue to return the value that was last read. *)
      let write_adresse =
        decimal_of_partial_array ~src:gate.input ~pos:write_address_pos ~len:address_width
      in
      Array.blit
        ~src:gate.input
        ~src_pos:data_pos
        ~dst:(Array.unsafe_get contents write_adresse)
        ~dst_pos:0
        ~len:data_width)
    else (
      let read_adresse =
        decimal_of_partial_array ~src:gate.input ~pos:read_address_pos ~len:address_width
      in
      Array.blit
        ~src:(Array.unsafe_get contents read_adresse)
        ~src_pos:0
        ~dst:gate.output
        ~dst_pos:0
        ~len:data_width)
  | _ -> assert false
;;

let fct_external (t : t) ~(gate : Bopkit_circuit.Gate.t) =
  match gate.gate_kind with
  | External { loc; name = _; method_name = _; arguments = _; protocol_prefix; index } ->
    let index = Core.Set_once.get_exn index [%here] in
    let process = t.external_process.(index) in
    let protocol =
      Core.Set_once.get_exn protocol_prefix [%here] ^ Bit_array.to_string gate.input
    in
    With_return.with_return (fun return ->
      Out_channel.output_lines process.input_pipe [ protocol ];
      Out_channel.flush process.input_pipe;
      process.pending_input <- Some { loc; input = protocol };
      let reponse =
        match In_channel.input_line process.output_pipe with
        | Some line -> line
        | None -> return.return One_cycle_result.Quit
      in
      let len_sortie = String.length reponse in
      let protocole_sortie =
        match bits_of_string reponse with
        | Some b -> b
        | None ->
          Err.error
            ~loc
            [ Pp.textf "External process[%d] ('%s')" index process.command
            ; Pp.textf " received: '%s'" protocol
            ; Pp.textf "responded: '%s'" reponse
            ];
          return.return One_cycle_result.Quit
      in
      let expected_len = Array.length gate.output in
      if len_sortie < expected_len
      then (
        Err.error
          ~loc
          [ Pp.textf "External process[%d] ('%s')" index process.command
          ; Pp.textf " received: '%s'" protocol
          ; Pp.textf "responded: '%s'" reponse
          ; Pp.textf
              "Simulation expected %d bits but received %d."
              expected_len
              len_sortie
          ];
        return.return One_cycle_result.Quit)
      else (
        process.pending_input <- None;
        Array.blit
          ~src:protocole_sortie
          ~src_pos:0
          ~dst:gate.output
          ~dst_pos:0
          ~len:expected_len;
        One_cycle_result.Continue))
  | _ -> assert false
;;

let propagate_output t ~(gate : Bopkit_circuit.Gate.t) =
  let cds = cds t in
  Array.iter2_exn gate.output gate.output_wires ~f:(fun output output_wires ->
    List.iter
      output_wires
      ~f:(fun { Bopkit_circuit.Output_wire.gate_index; input_index } ->
        cds.(gate_index).input.(input_index) <- output))
;;

let one_cycle t ~blit_input ~output_handler =
  With_return.with_return (fun { return } ->
    blit_input ~dst:t.input;
    Array.iter
      (cds t)
      ~f:(fun ({ Bopkit_circuit.Gate.gate_kind; input; output; _ } as gate) ->
        (match gate_kind with
         | Input | Output | Clock | Gnd | Vdd | Reg _ | Regr _ | Regt -> ()
         | Id -> fct_id ~input ~output
         | Not -> fct_not ~input ~output
         | And -> fct_and ~input ~output
         | Or -> fct_or ~input ~output
         | Xor -> fct_xor ~input ~output
         | Mux -> fct_mux ~input ~output
         | Rom { index; _ } -> fct_rom t ~input ~output ~index
         | Ram _ -> fct_ram t ~gate
         | External _ ->
           (match fct_external t ~gate with
            | Continue -> ()
            | Quit as quit -> return quit));
        propagate_output t ~gate);
    update_registers t;
    output_handler ~input:(input t) ~output:(output t);
    One_cycle_result.Continue)
;;
