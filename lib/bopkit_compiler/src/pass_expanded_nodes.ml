let transf_fresh_inline = Printf.sprintf "$%d$"

let pass ~(env : Expanded_block.env) ~main_block_name ~config : Expanded_nodes.t =
  let fresh_name =
    let index = ref 0 in
    fun () ->
      Int.incr index;
      transf_fresh_inline !index
  in
  let main =
    match Map.find env main_block_name with
    | Some block -> block
    | None ->
      (* The request for that specific block_name as the main entry point may
         have been overridden by the user via the command line, and so it may
         contain some typos. Let's try and give a helpful error message here. *)
      Err.raise
        [ Pp.textf "Failed to find main block name '%s'." main_block_name ]
        ~hints:(Err.did_you_mean main_block_name ~candidates:(Map.keys env))
  in
  let expanded_nodes : Expanded_nodes.Node.t Queue.t = Queue.create () in
  (* Appellee file Q dans le rapport latex *)
  let fonctions_utilisees = Hash_set.create (module String) in
  (* We start by adding the input node at the very beginning. *)
  Queue.enqueue
    expanded_nodes
    { gate_kind = Input; inputs = [||]; outputs = main.input_names };
  let array_of_file_node () =
    (* We terminate by adding the output gate, and returning them all. *)
    Queue.enqueue
      expanded_nodes
      { gate_kind = Output; inputs = main.output_names; outputs = [||] };
    Queue.to_array expanded_nodes
  in
  (* Fonction auxiliaire de substitution du corps d'une fonction anterieure
     dont on donne la description des_ant, et les listes effectives
     (ent_list, sort_list) rencontrees lors de l'appel de cette fonction *)
  let substitution_corps (des_ant : Expanded_block.t) ent_list sort_list =
    let add_subst smap v_old v_new = Map.set smap ~key:v_old ~data:v_new in
    (* Substituer les entrees formelles par les parametres effectifs *)
    let etape1 =
      List.fold2_exn
        (des_ant.input_names |> Array.to_list)
        ent_list
        ~init:(Map.empty (module String))
        ~f:add_subst
    in
    (* Substituer les sorties formelles par les parametres effectifs *)
    let etape2 =
      List.fold2_exn
        (des_ant.output_names |> Array.to_list)
        sort_list
        ~init:etape1
        ~f:add_subst
    in
    (* Substituer les vas locales de la fonction appellée par des freshes *)
    (* ajoutons autant de freshs que de variables locales *)
    let transf_map =
      List.fold_left des_ant.local_variables ~init:etape2 ~f:(fun smap v ->
        Map.set smap ~key:v ~data:(fresh_name ()))
    in
    let subst v =
      match Map.find transf_map v with
      | Some x -> x
      | None -> failwith "Pas possible apres l'analyse proof"
      (* cf commentaire ci-dessus : partition des variables de la fonction *)
    in
    Hash_set.add fonctions_utilisees des_ant.name;
    List.map des_ant.nodes ~f:(fun { loc; call = f; inputs = el; outputs = sl } ->
      { Expanded_block.loc
      ; call = f
      ; inputs = List.map el ~f:subst
      ; outputs = List.map sl ~f:subst
      })
  in
  (* Parcours en profondeur dans l'environnement des fonctions,
     dans un graphe qu'on pourrait appeler le graphe de dependance
     fonctionnelle de la net-list.
     -Modifie file_node par effet de bord,
     -recolte les liaisons necessaires au branchement correct de tous les fils *)

  (* La fonction TRAITE figurant dans le rapport latex.
     Cette fonction travaille par induction sur les listes d'appels des corps.
     Elle renvoit la table des liaisons *)
  let rec aux_node { Expanded_block.loc = _; call; inputs; outputs } =
    match call with
    | Primitive { gate_kind } ->
      Queue.enqueue
        expanded_nodes
        { gate_kind
        ; inputs = inputs |> Array.of_list
        ; outputs = outputs |> Array.of_list
        }
    | Block { name } ->
      let block = Map.find env name |> Option.value_exn ~here:[%here] in
      let nodes = substitution_corps block inputs outputs in
      aux_nodes nodes
  and aux_nodes : Expanded_block.node list -> unit = function
    | [] -> ()
    | node :: tl ->
      aux_node node;
      aux_nodes tl
  in
  Err.debug [ Pp.text "Inlining blocks." ];
  aux_nodes main.nodes;
  Map.iteri env ~f:(fun ~key:name ~data:fd ->
    if (not (String.equal name main_block_name))
       && (not (Hash_set.mem fonctions_utilisees name))
       && Fpath.equal (fd.loc |> Loc.path) (main.loc |> Loc.path)
       && Option.is_none (Config.main config)
    then Err.warning ~loc:fd.loc [ Pp.textf "Unused block '%s'." name ]);
  array_of_file_node ()
;;

(* DEVELOPPEMENT DU CODE, BRISER LA HIERARCHIE *)

(* la partie suivante vise a realiser un inline recursif de tous les
   appels de fonctions antérieures, avec substitution des parametres
   formels, et en remplacant les variables locales par des freshs *)

(* Preuve de la gestion des freshs : On utilise des noms de la forme
   $int$ par incrementation le lexer interdit les identifiant qui
   commencent par $ *)

(* CONSTRUCTION DU PRE-GRAPHE A PARTIR DE L'ENVIRONNEMENT DES FONCTIONS *)

(* On cree toutes les liaisons, et une file des nodes en un parcours lineaire.
   Preuve informelle :
   On raisonne par induction pour la validité du corps.

   A propos de la fonction de substitution :

   On a une partition des variables de la fonction appelée en :
   - Variables d'entree
   - Variables de sortie
   - Variables locales.

   Cela correspond aux trois etapes de construction du stringMap
   utilise comme structure de bijection.

   La verification de typage (arite des fonctions) a deja ete fait
   avant cette etape, donc on est assure du fait que l'ent_list et la sort_list
   ont la bonne longueur par rapport au champs de description de la
   fonction appelée. Cela montre donc que l'exception LengthError
   n'est jamais levée par le Double fold_left

   Une explication de la fonction ci-dessous est fournie dans le rapport
   latex du projet. *)
