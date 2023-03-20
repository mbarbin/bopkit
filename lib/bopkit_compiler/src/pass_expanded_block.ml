open! Core

let using_any ~error_log ~loc =
  Error_log.raise
    error_log
    ~loc
    [ Pp.text "Do not use '_' as a ident for a block, input or output."
    ; Pp.text "It is reserved for unused variables."
    ]
;;

let unknown_block_name ~error_log ~loc ~name ~candidates =
  Error_log.raise
    error_log
    ~loc
    [ Pp.textf "Unknown block name '%s'." name ]
    ~hints:(Error_log.did_you_mean name ~candidates)
;;

exception NonDistincts of string

let stringSet_of_list_distincts interdit li =
  let f set x =
    if Set.mem set x || List.mem interdit x ~equal:String.equal
    then raise (NonDistincts x)
    else Set.add set x
  in
  List.fold_left li ~f ~init:(Set.empty (module String))
;;

let string_of_call : Expanded_block.call -> string = function
  | Block { name } -> name
  | Primitive { gate_kind } ->
    (match gate_kind with
     | Id -> "id"
     | Not -> "not"
     | And -> "and"
     | Or -> "or"
     | Xor -> "xor"
     | Mux -> "mux"
     | Rom _ -> "rom_?"
     | Ram _ -> "ram_?"
     | Reg _ | Regr _ | Regt -> "reg"
     | External _ -> "external"
     | _ -> "?")
;;

(* on met les indications dans la file *)
let global_indications_cycle = Queue.create ()

let detect_cycle_in_fonction (fd : Expanded_block.t) =
  (* fonction description *)
  let vars = fd.variables_locales @ fd.entrees_formelles @ fd.sorties_formelles in
  let visited = Hash_set.create (module String) in
  let parents = ref [] in
  let liaisons =
    (* parcours du corps pour construire les arretes *)
    let rec aux accu = function
      | [] -> accu
      | { Expanded_block.call = typ; inputs = ent; outputs = sor } :: q ->
        (match typ with
         | Primitive { gate_kind = Reg _ | Regr _ | Regt } -> aux accu q
         | _ ->
           (* chaque sortie depend de toutes les entrees *)
           (* chaque sortie se trouve uniquement la : (branchement conflictuels) *)
           let f_fold acc s = Map.set acc ~key:s ~data:(typ, ent) in
           aux (List.fold_left sor ~init:accu ~f:f_fold) q)
    in
    aux (Map.empty (module String)) fd.nodes
  in
  let rec f_iter v =
    if List.exists ~f:(fun (_, u) -> String.equal u v) !parents
    then (
      let indications = Queue.create () in
      let add_indications_cycle s = Queue.enqueue indications s in
      let rec affiche_cycle accu last = function
        | [] -> List.iter accu ~f:(fun s -> add_indications_cycle s)
        | (typ, u) :: q ->
          let s =
            Printf.sprintf
              "%s\n"
              (Printf.sprintf "  ..%s.. = ..%s(..%s..);" u (string_of_call typ) last)
          in
          if String.equal u v
          then List.iter (s :: accu) ~f:(fun s -> add_indications_cycle s)
          else affiche_cycle (s :: accu) u q
      in
      affiche_cycle [] v !parents;
      Queue.enqueue global_indications_cycle (fd, Queue.to_list indications))
    else if not (Hash_set.mem visited v)
    then dfs v
  and dfs v =
    Hash_set.add visited v;
    (* iteration sur les voisins : ic sur les entrees dont dependent cette sortie *)
    match Map.find liaisons v with
    | None -> ()
    | Some (typ, ent) ->
      parents := (typ, v) :: !parents;
      List.iter ~f:f_iter ent;
      parents := List.tl !parents |> Option.value_exn ~here:[%here]
  in
  List.iter ~f:f_iter vars;
  fd
;;

let create_block
  (fd : Bopkit.Expanded_netlist.block)
  ~error_log
  ~(primitives : Primitive.env)
  ~(env : Expanded_block.env)
  =
  let loc = fd.loc in
  let filename, name, entree_list, sortie_list, unused, corps_c =
    ( fd.loc |> Loc.filename
    , fd.name
    , (* ICI, ce qui nous interresse est la premiere composante, pas les infos *)
      fd.inputs.expanded
    , fd.outputs.expanded
    , fd.unused_variables.expanded
    , fd.nodes )
  in
  if String.equal name "_" then using_any ~error_log ~loc;
  if Map.mem primitives name
  then
    Error_log.raise
      error_log
      ~loc
      [ Pp.textf "Invalid block name. '%s' is a primitive and cannot be redefined." name ]
  else if Map.mem env name
  then
    Error_log.raise
      error_log
      ~loc
      [ Pp.textf "Duplicated block name '%s'. A block with this name already exists." name
      ]
  else (
    let ensemble_entree, ensemble_sortie =
      try
        ( stringSet_of_list_distincts [ "_" ] entree_list
        , stringSet_of_list_distincts [ "_" ] sortie_list )
      with
      | NonDistincts s when String.equal s "_" -> using_any ~error_log ~loc
      | NonDistincts s ->
        Error_log.raise
          error_log
          ~loc
          [ Pp.textf
              "Duplicated block variable '%s'. Input/Output names should be unique."
              s
          ]
    in
    let unused_decl = Set.of_list (module String) ("_" :: unused) in
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
            Error_log.raise
              error_log
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
    (* Warning et Error *)
    let variable_inutile x =
      (* verifier en meme temps si une variable declaree comme unused est utilisee *)
      if Set.mem entrees_appel x
      then (
        if Set.mem unused_decl x
        then
          Error_log.error
            error_log
            ~loc
            [ Pp.textf
                "Block variable '%s' belongs to the block unused variables but it is \
                 used."
                x
            ])
      else if not (Set.mem unused_decl x || Char.equal x.[0] '?')
      then
        Error_log.warning
          error_log
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
        Error_log.error
          error_log
          ~loc
          [ Pp.textf
              "Block variable '%s' is used but is not assigned to any node output."
              x
          ]
    and entree_modifiee x =
      if Set.mem sorties_appel x
      then
        Error_log.error
          error_log
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
          { Expanded_block.call =
              Primitive
                { gate_kind =
                    External
                      { loc
                      ; name = bloc_name
                      ; method_name
                      ; arguments = string_args
                      ; protocol_prefix = Set_once.create ()
                      ; index = Set_once.create ()
                      }
                }
          ; inputs = ent
          ; outputs = sor
          }
        | Block { name = call_name } ->
          (* d'abord, on voit si c'est un appel a une primitive *)
          (match Map.find primitives call_name with
           | Some { gate_kind = prim; input_width = e; output_width = s } ->
             if e <> List.length ent
             then
               Error_log.error
                 error_log
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
               Error_log.error
                 error_log
                 ~loc
                 [ Pp.textf
                     "The primitive '%s' has %d outputs but is connected to %d variables."
                     call_name
                     s
                     (List.length sor)
                 ]
             else ();
             { call = Primitive { gate_kind = prim }; inputs = ent; outputs = sor }
           (* Ce n'est pas une primitive *)
           | None ->
             (* Alors essayons de voir si c'est un appel de fonction *)
             (match Map.find env call_name with
              | Some desAnt ->
                let e = desAnt.arite_entree
                and s = desAnt.arite_sortie in
                if e <> List.length ent
                then
                  Error_log.error
                    error_log
                    ~loc
                    [ Pp.textf
                        "Block '%s' expects %d inputs but is applied to %d variables."
                        call_name
                        e
                        (List.length ent)
                    ]
                else if s <> List.length sor
                then
                  Error_log.error
                    error_log
                    ~loc
                    [ Pp.textf
                        "Block '%s' has %d outputs but is connected to %d variables."
                        call_name
                        s
                        (List.length sor)
                    ]
                else ();
                { call = Block { name = call_name }; inputs = ent; outputs = sor }
              (* Sinon, il s'agit d'un appel a une fonction non definie *)
              | None ->
                unknown_block_name
                  ~error_log
                  ~loc
                  ~name:call_name
                  ~candidates:(Map.keys primitives @ Map.keys env)))
      in
      List.map corps_c ~f:make_appel
    in
    detect_cycle_in_fonction
      { loc
      ; fichier = filename
      ; name
      ; arite_entree = List.length entree_list
      ; arite_sortie = List.length sortie_list
      ; variables_locales = Set.to_list variables_locales
      ; entrees_formelles = entree_list
      ; sorties_formelles = sortie_list
      ; nodes = corps
      })
;;

let create_env list ~error_log ~primitives =
  Error_log.debug error_log [ Pp.text "Analysing circuit's blocks." ];
  List.fold_left
    list
    ~init:(Map.empty (module String))
    ~f:(fun env fd ->
      let t = create_block fd ~error_log ~primitives ~env in
      Map.set env ~key:t.name ~data:t)
;;
