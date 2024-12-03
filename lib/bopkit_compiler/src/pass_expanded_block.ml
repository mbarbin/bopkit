let using_any ~loc =
  Err.raise
    ~loc
    [ Pp.text "Do not use '_' as a ident for a block, input or output."
    ; Pp.text "It is reserved for unused variables."
    ]
;;

let unknown_block_name ~loc ~name ~candidates =
  Err.raise
    ~loc
    [ Pp.textf "Unknown block name '%s'." name ]
    ~hints:(Err.did_you_mean name ~candidates)
;;

exception Non_distinct of string

let stringSet_of_list_distinct not_allowed li =
  let f set x =
    if Set.mem set x || List.mem not_allowed x ~equal:String.equal
    then raise (Non_distinct x)
    else Set.add set x
  in
  List.fold_left li ~f ~init:(Set.empty (module String))
;;

let string_of_call : Expanded_block.call -> string = function
  | Block { name } -> name
  | Primitive { gate_kind } ->
    (match gate_kind with
     | Clock -> "Clock"
     | Id -> "Id"
     | Not -> "Not"
     | And -> "And"
     | Or -> "Or"
     | Xor -> "Xor"
     | Mux -> "Mux"
     | Rom _ -> "rom_?"
     | Ram _ -> "ram_?"
     | Reg _ | Regr _ | Regt -> "Reg"
     | External _ -> "external"
     | Gnd -> "Gnd"
     | Vdd -> "Vdd"
     | Input -> "Input"
     | Output -> "Output")
;;

(* Cycle hints are stored in this global variable. It is reset for each
   new circuit. If no cycle is detected at the end of the circuit compilation,
   this information is simply discarded. Otherwise it is shown in the hope that
   the indications will help the circuit author to locate their cycle. *)
let global_cycle_hints = Queue.create ()

let detect_cycle_in_block (fd : Expanded_block.t) =
  let visited = Hash_set.create (module String) in
  let parents = ref [] in
  let edges =
    let rec aux acc = function
      | [] -> acc
      | { Expanded_block.loc = _; call = typ; inputs = ent; outputs = sor } :: q ->
        (match typ with
         | Primitive { gate_kind = Reg _ | Regr _ | Regt } -> aux acc q
         | _ ->
           (* Each output depends on all inputs. Each output is necessarily only
              occurring here, otherwise it would be flagged as a conflicting
              connection error. *)
           let f_fold acc s = Map.set acc ~key:s ~data:(typ, ent) in
           aux (List.fold_left sor ~init:acc ~f:f_fold) q)
    in
    aux (Map.empty (module String)) fd.nodes
  in
  let rec f_iter v =
    if List.exists ~f:(fun (_, u) -> String.equal u v) !parents
    then (
      let indications = Queue.create () in
      let add_cycle_indication s = Queue.enqueue indications s in
      let rec affiche_cycle acc last = function
        | [] -> List.iter acc ~f:(fun s -> add_cycle_indication s)
        | (typ, u) :: q ->
          let s =
            Printf.sprintf
              "%s\n"
              (Printf.sprintf "  ..%s.. = ..%s(..%s..);" u (string_of_call typ) last)
          in
          if String.equal u v
          then List.iter (s :: acc) ~f:(fun s -> add_cycle_indication s)
          else affiche_cycle (s :: acc) u q
      in
      affiche_cycle [] v !parents;
      Queue.enqueue global_cycle_hints (fd, Queue.to_list indications))
    else if not (Hash_set.mem visited v)
    then dfs v
  and dfs v =
    Hash_set.add visited v;
    (* iteration sur les voisins : ic sur les entrees dont dependent cette sortie *)
    match Map.find edges v with
    | None -> ()
    | Some (typ, ent) ->
      parents := (typ, v) :: !parents;
      List.iter ent ~f:f_iter;
      parents := List.tl !parents |> Option.value_exn ~here:[%here]
  in
  List.iter fd.local_variables ~f:f_iter;
  Array.iter fd.input_names ~f:f_iter;
  Array.iter fd.output_names ~f:f_iter;
  fd
;;

let create_block
      (fd : Bopkit.Expanded_netlist.block)
      ~(primitives : Primitive.env)
      ~(env : Expanded_block.env)
  =
  let loc = fd.loc in
  let name, entree_list, sortie_list, unused, corps_c =
    ( fd.name
    , fd.inputs.expanded
    , fd.outputs.expanded
    , fd.unused_variables.expanded
    , fd.nodes )
  in
  if String.equal name "_" then using_any ~loc;
  if Map.mem primitives name
  then
    Err.raise
      ~loc
      [ Pp.textf "Invalid block name. '%s' is a primitive and cannot be redefined." name ]
  else if Map.mem env name
  then
    Err.raise
      ~loc
      [ Pp.textf "Duplicated block name '%s'. A block with this name already exists." name
      ]
  else (
    let ensemble_entree, ensemble_sortie =
      try
        ( stringSet_of_list_distinct [ "_" ] entree_list
        , stringSet_of_list_distinct [ "_" ] sortie_list )
      with
      | Non_distinct s when String.equal s "_" -> using_any ~loc
      | Non_distinct s ->
        Err.raise
          ~loc
          [ Pp.textf
              "Duplicated block variable '%s'. Input/Output names should be unique."
              s
          ]
    in
    let unused_decl =
      match stringSet_of_list_distinct [ "_" ] unused with
      | unused -> Set.add unused "_"
      | exception Non_distinct s when String.equal s "_" ->
        Err.raise
          ~loc
          [ Pp.text "Do not declare '_' as an unused variable. It is implicit." ]
          ~hints:[ Pp.text "Simply remove '_' from the unused variables declaration." ]
      | exception Non_distinct s ->
        Err.raise
          ~loc
          [ Pp.textf
              "Duplicated block unused variable '%s'. Unused variable names should be \
               unique."
              s
          ]
    in
    let variables_spec = Set.union ensemble_entree ensemble_sortie in
    (* creer les ensembles des variables utilisees comme entree, comme sorties *)
    (* une variable ne peut pas etre branchée a deux sortie de primitives,
       sauf si c'est "_" qui n'est pas utilisee par construction *)
    let f_fold
          (set_e, set_s)
          { Bopkit.Expanded_netlist.loc = _
          ; call = _
          ; inputs = { expanded = e_l; _ }
          ; outputs = { expanded = s_l; _ }
          }
      =
      ( List.fold_left e_l ~init:set_e ~f:Set.add
      , List.fold_left s_l ~init:set_s ~f:(fun set s ->
          if Set.mem set s && String.( <> ) s "_"
          then
            Err.raise
              ~loc
              [ Pp.textf
                  "In block '%s': conflicting connections of block variable '%s'."
                  name
                  s
              ]
              ~hints:
                [ Pp.textf
                    "A variable may appear at most once in the set of block variables \
                     that are connected to node outputs but it is here connected to the \
                     output of several nodes."
                ]
          else Set.add set s) )
    in
    let entrees_appel, sorties_appel =
      List.fold_left
        corps_c
        ~init:(Set.empty (module String), Set.empty (module String))
        ~f:f_fold
    in
    let variables_locales =
      Set.diff (Set.union entrees_appel sorties_appel) variables_spec
    in
    let actually_unused_variables =
      Set.diff
        (Set.union ensemble_entree sorties_appel)
        (Set.union_list
           (module String)
           [ Set.singleton (module String) "_"; ensemble_sortie; entrees_appel ])
      |> Set.to_list
    in
    (* Warning et Error *)
    let variable_inutile x =
      if Set.mem entrees_appel x
      then (
        if Set.mem unused_decl x
        then
          Err.error
            ~loc
            [ Pp.textf
                "Block variable '%s' belongs to the block unused variables but it is \
                 used."
                x
            ]
            ~hints:
              (Pp.text "Remove it from the unused variables declaration."
               :: Err.did_you_mean x ~candidates:actually_unused_variables))
      else if not (Set.mem unused_decl x || Char.equal x.[0] '?')
      then
        Err.warning
          ~loc
          [ Pp.textf "Unused block variable '%s'." x ]
          ~hints:
            [ Pp.textf
                "You can suppress this warning by adding the variable name to the list \
                 of this block's unused variables: with unused = (... , %s)"
                x
            ]
    and variable_non_assignee x =
      if not (Set.mem sorties_appel x)
      then
        Err.error
          ~loc
          [ Pp.textf "Block variable '%s' is not assigned to any node output." x ]
    and entree_modifiee x =
      if Set.mem sorties_appel x
      then
        Err.error
          ~loc
          [ Pp.textf
              "In block '%s', input variable '%s' is connected to a node output. Block \
               inputs should be read-only in the body the block."
              name
              x
          ]
    in
    (* Warning : *)
    (* si une variable local ne sert a rien *)
    Set.iter variables_locales ~f:variable_inutile;
    (* si un argument de la fonction ne sert a rien *)
    Set.iter ensemble_entree ~f:variable_inutile;
    (*  Error   *)
    (* si l'ensemble des entrees et des sorties ne sont pas disjoints *)
    (* par l'absurde : comme ce serait une sortie, elle doit etre modifiee
       donc c'est qu'une entree est modifiee : redondant *)
    (* si une entree de la fonction est modifiee *)
    Set.iter ensemble_entree ~f:entree_modifiee;
    (* si une sortie n'est pas specifiee *)
    Set.iter ensemble_sortie ~f:variable_non_assignee;
    (* si une variable local est observee mais pas assignee *)
    Set.iter variables_locales ~f:variable_non_assignee;
    Set.iter unused_decl ~f:(fun unused_var ->
      if
        (not (String.equal unused_var "_"))
        && (not (Set.mem sorties_appel unused_var))
        && not (Set.mem ensemble_entree unused_var)
      then
        Err.error
          ~loc
          [ Pp.textf
              "In block '%s', variable '%s' is declared as unused but is actually \
               unbound."
              name
              unused_var
          ]
          ~hints:
            (Pp.text "Remove it from the unused variables declaration."
             :: Err.did_you_mean unused_var ~candidates:actually_unused_variables));
    (* Creation du corps en verifiant les arites *)
    let corps =
      (* Le corps d'une fonction est par convention la liste des appels. *)
      (* On construit un appel effectif (une ligne de base de la net-list). *)
      (* C'est un triplet (type_appel, entrees_effct, sorties_effct) *)
      (* WARNING call name devient de type Block ou PipeCall *)
      let make_appel
            { Bopkit.Expanded_netlist.loc
            ; call
            ; inputs = { expanded = ent; _ }
            ; outputs = { expanded = sor; _ }
            }
        =
        match call with
        | External_block
            { name = bloc_name; method_name; external_arguments = string_args } ->
          { Expanded_block.loc
          ; call =
              Primitive
                { gate_kind =
                    External
                      { loc
                      ; name = bloc_name
                      ; method_name
                      ; arguments = string_args
                      ; protocol_prefix = Core.Set_once.create ()
                      ; index = Core.Set_once.create ()
                      }
                }
          ; inputs = ent
          ; outputs = sor
          }
        | Block { name = call_name } ->
          (* First, let's see if this is a call to a primitive. *)
          (match Map.find primitives call_name with
           | Some { gate_kind = prim; input_width = e; output_width = s } ->
             if e <> List.length ent
             then
               Err.error
                 ~loc
                 [ Pp.textf
                     "The primitive '%s' expects %d inputs but is applied to %d \
                      variables."
                     call_name
                     e
                     (List.length ent)
                 ]
             else if s <> List.length sor
             then
               Err.error
                 ~loc
                 [ Pp.textf
                     "The primitive '%s' has %d outputs but is connected to %d variables."
                     call_name
                     s
                     (List.length sor)
                 ]
             else ();
             { loc; call = Primitive { gate_kind = prim }; inputs = ent; outputs = sor }
           | None ->
             (* It wasn't a primitive, so it must be a call to a block. Otherwise it's an error. *)
             (match Map.find env call_name with
              | None ->
                unknown_block_name
                  ~loc
                  ~name:call_name
                  ~candidates:(Map.keys primitives @ Map.keys env)
              | Some { Expanded_block.input_names; output_names; _ } ->
                let input_width = Array.length input_names in
                let output_width = Array.length output_names in
                if input_width <> List.length ent
                then
                  Err.error
                    ~loc
                    [ Pp.textf
                        "Block '%s' expects %d inputs but is applied to %d variables."
                        call_name
                        input_width
                        (List.length ent)
                    ]
                else if output_width <> List.length sor
                then
                  Err.error
                    ~loc
                    [ Pp.textf
                        "Block '%s' has %d outputs but is connected to %d variables."
                        call_name
                        output_width
                        (List.length sor)
                    ]
                else ();
                { loc; call = Block { name = call_name }; inputs = ent; outputs = sor }))
      in
      List.map corps_c ~f:make_appel
    in
    detect_cycle_in_block
      { loc
      ; name
      ; local_variables = variables_locales |> Set.to_list
      ; input_names = entree_list |> Array.of_list
      ; output_names = sortie_list |> Array.of_list
      ; nodes = corps
      })
;;

let create_env list ~primitives =
  Err.debug (lazy [ Pp.text "Analyzing circuit's blocks." ]);
  List.fold_left
    list
    ~init:(Map.empty (module String))
    ~f:(fun env fd ->
      let t = create_block fd ~primitives ~env in
      Map.set env ~key:t.name ~data:t)
;;
