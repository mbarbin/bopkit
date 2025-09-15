(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Config = Config
module Expanded_block = Expanded_block
module Primitive = Primitive

let create_block = Pass_expanded_block.create_block

let transistors_of_gate gate_kind =
  match (gate_kind : Bopkit_circuit.Gate_kind.t) with
  | Input | Output | Id -> 0
  | Not -> 2
  | And | Or -> 6
  | Xor -> 8
  | Mux -> 6
  | Rom _ | Ram _ -> 0
  | Reg _ -> 16
  | Regr _ -> 0
  | Regt -> 16
  | Clock | Gnd | Vdd -> 0
  | External _ -> 0
;;

let transistors_of_circuit (t : Bopkit_circuit.Cds.t) =
  Array.sum (module Int) t ~f:(fun e -> transistors_of_gate e.gate_kind)
;;

let has_main_attribute (fd : Bopkit.Netlist.block) =
  List.exists fd.attributes ~f:(function
    | "main" | "Main" -> true
    | _ -> false)
;;

let expand_netlist ~path ~config =
  let loc = Loc.of_file ~path in
  let { Standalone_netlist.paths; parameters; memories; external_blocks; blocks } =
    Pass_includes.pass ~path
  in
  let parameters =
    parameters
    @ List.map (Config.parameters_overrides config) ~f:(fun { name; value } ->
      { Bopkit.Netlist.loc = Loc.none
      ; comments = Bopkit.Comments.none
      ; name
      ; parameter_value =
          (match value with
           | Int i -> DefInt (CST i)
           | String s -> DefString s)
      })
  in
  let main_block_name =
    let default_main = ref None in
    let attributed_main = ref None in
    List.iter blocks ~f:(fun t ->
      match t.name with
      | Parametrized _ -> ()
      | Standard { name } ->
        if has_main_attribute t then attributed_main := Some name;
        default_main := Some name);
    match !attributed_main with
    | Some _ as some -> some
    | None -> !default_main
  in
  let parameters = Pass_parameters.pass parameters in
  let external_blocks =
    List.map external_blocks ~f:(fun external_block ->
      Pass_external_blocks.pass external_block ~parameters)
  in
  let { Pass_memories.rom_memories; memories; primitives } =
    Pass_memories.pass memories ~parameters
  in
  let main_block_name =
    match Option.first_some (Config.main config) main_block_name with
    | Some name -> name
    | None -> Err.raise ~loc [ Pp.textf "Project has no main block." ]
  in
  let { Pass_expanded_netlist.inline_external_blocks; blocks } =
    Pass_expanded_netlist.pass blocks ~primitives ~parameters
  in
  Err.debug
    ~loc
    (lazy
      [ Pp.textf
          "Returning the blocks in this order:\n%s"
          (Sexp.to_string_hum
             [%sexp (List.map blocks ~f:(fun t -> t.name) : string list)])
      ]);
  if Config.print_pass_output config ~pass_name:Expanded_netlist
  then
    Err.debug
      ~loc
      (lazy
        [ Pp.textf "Result of Pass_expanded_netlist:"
        ; Pp.concat_map blocks ~sep:Pp.newline ~f:Bopkit_pp.Expanded_netlist.pp_block
        ]);
  ( primitives
  , Bopkit.Expanded_netlist.
      { paths
      ; rom_memories
      ; memories
      ; external_blocks = external_blocks @ inline_external_blocks
      ; blocks
      ; main_block_name
      } )
;;

let circuit_of_netlist ~path ~config =
  let loc = Loc.of_file ~path in
  Queue.clear Pass_expanded_block.global_cycle_hints;
  let primitives, expanded_netlist = expand_netlist ~path ~config in
  let main_block_name = expanded_netlist.main_block_name in
  let env = Pass_expanded_block.create_env expanded_netlist.blocks ~primitives in
  let () = if Err.had_errors () then Err.exit Err.Exit_code.some_error in
  let expanded_nodes = Pass_expanded_nodes.pass ~env ~main_block_name ~config in
  if Config.print_pass_output config ~pass_name:Expanded_nodes
  then
    Err.debug
      ~loc
      (lazy
        [ Pp.textf "Result of Pass_expanded_nodes:"
        ; Expanded_nodes.pp_debug expanded_nodes
        ]);
  let cds = Pass_cds.pass expanded_nodes in
  let cds = Bopkit_circuit.Cds.split_registers cds in
  if Config.print_pass_output config ~pass_name:Cds_split_registers
  then
    Err.debug
      ~loc
      (lazy
        [ Pp.textf "Result of Pass_cds+split-registers:"
        ; Pp.text (Sexp.to_string_hum [%sexp (cds : Bopkit_circuit.Cds.t)])
        ]);
  let () =
    if Bopkit_circuit.Cds.detect_cycle cds
    then (
      Err.error
        ~loc
        [ Pp.text "The circuit has a cycle." ]
        ~hints:[ Pp.text "Below are some hints to try and find it:" ];
      Queue.iter Pass_expanded_block.global_cycle_hints ~f:(fun (fd, lines) ->
        Err.error
          ~loc:fd.loc
          (Pp.text "In this block, these variables may create a dependency cycle:"
           :: Pp.cut
           :: List.map lines ~f:Pp.verbatim));
      let () = if Err.had_errors () then Err.exit Err.Exit_code.some_error in
      ())
  in
  Bopkit_circuit.Cds.topological_sort cds;
  if Config.print_pass_output config ~pass_name:Cds_topological_sort
  then
    Err.debug
      ~loc
      (lazy
        [ Pp.textf "Result of Pass_cds+topological-sort:"
        ; Pp.text (Sexp.to_string_hum [%sexp (cds : Bopkit_circuit.Cds.t)])
        ]);
  let cds =
    if Config.optimize_cds config then Bopkit_cds_optimizer.optimize cds else cds
  in
  let main = Map.find env main_block_name |> Option.value_exn ~here:[%here] in
  Err.info
    ~loc
    [ Pp.textf
        "Final circuit: %d gates (~%d transistors)."
        (Array.length cds - 2)
        (transistors_of_circuit cds)
    ];
  Bopkit_circuit.Circuit.create_exn
    ~path
    ~main:{ Loc.Txt.txt = main.name; loc = main.loc }
    ~cds
    ~rom_memories:expanded_netlist.rom_memories
    ~external_blocks:(expanded_netlist.external_blocks |> Array.of_list)
    ~input_names:main.input_names
    ~output_names:main.output_names
;;
