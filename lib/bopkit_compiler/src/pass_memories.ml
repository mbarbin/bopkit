(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type output =
  { rom_memories : Bit_matrix.t array
  ; memories : Bopkit.Expanded_netlist.memory array
  ; primitives : Primitive.env
  }

let read_code_brut_memoire ~loc memory_content =
  match (memory_content : Bopkit.Netlist.memory_content) with
  | Zero -> [||]
  | Text text ->
    (try Bit_array.of_01_chars_in_string text with
     | e ->
       Err.raise
         ~loc
         [ Pp.text "Invalid memory specification"; Pp.text (Exn.to_string e) ])
  | File path ->
    (try Bit_array.of_text_file ~path with
     | Sys_error _ ->
       Err.raise ~loc [ Pp.textf "%S: memory file not found" (path |> Fpath.to_string) ]
     | e ->
       Err.raise
         ~loc
         [ Pp.textf "Invalid memory file '%s'" (path |> Fpath.to_string)
         ; Pp.text (Exn.to_string e)
         ])
;;

let tab_bits_of_code_brut ~loc name taille lg_mot code =
  let len_attendue = taille * lg_mot
  and len_donnee = Array.length code in
  if len_donnee > len_attendue
  then
    Err.raise
      ~loc
      [ Pp.textf "Memory '%s' specification:" name
      ; Pp.textf "Number of bits expected: %d - given: %d" len_attendue len_donnee
      ]
  else (
    let ff i = if i < len_donnee then code.(i) else false in
    Err.debug
      ~loc
      (lazy
        [ Pp.textf
            "Memory '%s' specification: ( %d / %d ) bits specified"
            name
            len_donnee
            len_attendue
        ]);
    Bit_matrix.init_matrix_linear ~dimx:taille ~dimy:lg_mot ~f:ff)
;;

let pass memories ~parameters =
  let index_rom = ref 0
  and valeurs_memoires = Queue.create ()
  and table_export = Queue.create () in
  (* add_une_memoire : fonction auxiliaire qui rend la table des arites des
     primitives dans laquelle on a ajoute la primitive memoire correspondant
     a la declaration -> Utilisee avec un fold_left *)
  let add_une_memoire
        arit
        ({ Bopkit.Netlist.loc
         ; comments = _
         ; name
         ; memory_kind
         ; address_width
         ; data_width
         ; memory_content
         } :
          Bopkit.Netlist.memory)
    =
    let ok_eval_exn res = Bopkit.Or_eval_error.ok_exn res ~loc in
    let address_width, data_width =
      Bopkit.Or_eval_error.both
        (Bopkit.Arithmetic_expression.eval address_width ~parameters)
        (Bopkit.Arithmetic_expression.eval data_width ~parameters)
      |> ok_eval_exn
    and code : Bopkit.Netlist.memory_content =
      match (memory_content : Bopkit.Netlist.memory_content) with
      | (Text _ | Zero) as o -> o
      | File path ->
        File
          (Bopkit.String_with_vars.eval
             (Bopkit.String_with_vars.parse (path |> Fpath.to_string) |> ok_eval_exn)
             ~parameters
           |> ok_eval_exn
           |> Fpath.v)
    in
    match memory_kind with
    | ROM ->
      let rom_name = Printf.sprintf "rom_%s" name in
      if Map.mem arit rom_name
      then Err.raise ~loc [ Pp.textf "A memory with name '%s' is already defined." name ]
      else (
        Err.debug
          ~loc
          (lazy
            [ Pp.textf
                "Definition of a new memory 'rom_%s(%d, %d)'."
                name
                address_width
                data_width
            ]);
        let code_brut_rom = read_code_brut_memoire ~loc code in
        let taille_adr = Int.pow 2 address_width in
        let code_complet =
          tab_bits_of_code_brut ~loc name taille_adr data_width code_brut_rom
        in
        (* construction du code complet a mettre dans la file *)
        let export =
          Bopkit.Expanded_netlist.
            { loc
            ; name
            ; memory_kind = ROM
            ; address_width
            ; data_width
            ; memory_content = Some code_complet
            }
        in
        Queue.enqueue table_export export;
        Queue.enqueue valeurs_memoires code_complet;
        Int.incr index_rom;
        (* rendre la nouvelle table completee *)
        Map.set
          arit
          ~key:rom_name
          ~data:
            { Primitive.gate_kind = Rom { loc; name; index = Int.pred !index_rom }
            ; input_width = address_width
            ; output_width = data_width
            })
    | RAM ->
      let ram_name = Printf.sprintf "ram_%s" name in
      if Map.mem arit ram_name
      then Err.raise ~loc [ Pp.textf "A memory with name '%s' is already defined." name ]
      else (
        let taille_adr = Int.pow 2 address_width in
        let code_complet, description_code =
          Err.debug
            ~loc
            (lazy
              [ Pp.textf
                  "Definition of a new memory 'ram_%s(%d, %d)'."
                  name
                  address_width
                  data_width
              ]);
          match code with
          | Zero ->
            ( Bit_matrix.init_matrix_linear ~dimx:taille_adr ~dimy:data_width ~f:(fun _ ->
                false)
            , None )
          | (File _ | Text _) as code ->
            let code_brut_ram = read_code_brut_memoire ~loc code in
            let code_sortie =
              tab_bits_of_code_brut ~loc name taille_adr data_width code_brut_ram
            in
            code_sortie, Some code_sortie
        in
        (* completer la table d'export *)
        let export =
          Bopkit.Expanded_netlist.
            { loc
            ; name
            ; memory_kind = RAM
            ; address_width
            ; data_width
            ; memory_content = description_code
            }
        in
        Queue.enqueue table_export export;
        (* rendre la nouvelle table completee *)
        Map.set
          arit
          ~key:ram_name
          ~data:
            { Primitive.gate_kind =
                Ram { loc; name; address_width; data_width; contents = code_complet }
            ; input_width = (2 * address_width) + 1 + data_width
            ; output_width = data_width
            })
  in
  let env_final =
    List.fold_left memories ~init:(force Primitive.initial_env) ~f:add_une_memoire
  in
  let len = Queue.length valeurs_memoires in
  let tab_rom = Array.init len ~f:(fun _ -> Queue.dequeue_exn valeurs_memoires) in
  let len2 = Queue.length table_export in
  let tab_export = Array.init len2 ~f:(fun _ -> Queue.dequeue_exn table_export) in
  { rom_memories = tab_rom; memories = tab_export; primitives = env_final }
;;
