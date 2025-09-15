(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t = Visa.Program.t

let pp_top_level_construct ~(top_level_construct : Visa.Program.Top_level_construct.t) =
  let open Pp.O in
  match top_level_construct with
  | Newline -> Pp.nop
  | Comment { text } ->
    let text = String.chop_prefix text ~prefix:"//" |> Option.value ~default:text in
    Pp.verbatim "// " ++ Pp.verbatim (String.strip text)
  | Constant_definition { constant_name; constant_kind } ->
    Pp.concat
      [ Pp.verbatim "define "
      ; Pp.verbatim (Visa.Constant_name.to_string constant_name.txt)
      ; Pp.verbatim " "
      ; (match constant_kind with
         | Value { value } -> Pp.verbatim (sprintf "#%d" value)
         | Address { address } -> Pp.verbatim (sprintf "%d" (Visa.Address.to_int address)))
      ]
  | Macro_definition { macro_name; parameters; body } ->
    Pp.concat
      [ Pp.concat
          [ Pp.verbatim "macro "
          ; Pp.verbatim (Visa.Macro_name.to_string macro_name.txt)
          ; (if List.is_empty parameters then Pp.nop else Pp.verbatim " ")
          ; Pp.concat
              ~sep:(Pp.verbatim ", ")
              (List.map parameters ~f:(fun p ->
                 Pp.verbatim (Visa.Parameter_name.to_string p)))
          ; Pp.newline
          ; Pp.concat
              ~sep:Pp.newline
              (List.map body ~f:(fun a ->
                 Pp.verbatim (Visa.Assembly_instruction.to_string a)))
          ]
        |> Pp.box ~indent:2
      ; Pp.newline
      ; Pp.verbatim "end"
      ]
  | Label_introduction { label } ->
    Pp.concat [ Pp.verbatim (Visa.Label.to_string label.txt); Pp.verbatim ":" ]
  | Assembly_instruction { assembly_instruction } ->
    Pp.verbatim (Visa.Assembly_instruction.to_string assembly_instruction)
;;

let pp (program : Visa.Program.t) =
  let open Pp.O in
  let ts =
    List.group program ~break:(fun _ t2 ->
      match t2 with
      | Label_introduction _ -> true
      | Newline
      | Comment _
      | Constant_definition _
      | Macro_definition _
      | Assembly_instruction _ -> false)
  in
  let ts =
    List.concat_map ts ~f:(fun ts ->
      let prefix, suffix =
        let g1, g2 =
          List.split_while (List.rev ts) ~f:(function
            | Newline | Comment _ -> true
            | Label_introduction _
            | Constant_definition _
            | Macro_definition _
            | Assembly_instruction _ -> false)
        in
        List.rev g2, List.rev g1
      in
      if List.is_empty suffix then [ ts ] else [ prefix; suffix ])
  in
  let ts =
    List.map ts ~f:(fun ts ->
      match List.hd ts with
      | Some (Label_introduction _) ->
        (* In order to avoid blank lines with indentations, each
           Newline opens its own box. *)
        let subgroups =
          List.group ts ~break:(fun _ t2 ->
            match t2 with
            | Label_introduction _ | Newline -> true
            | Comment _
            | Constant_definition _
            | Macro_definition _
            | Assembly_instruction _ -> false)
        in
        Pp.concat_map subgroups ~f:(fun subgroup ->
          Pp.box
            ~indent:2
            (List.map subgroup ~f:(fun c -> pp_top_level_construct ~top_level_construct:c)
             |> Pp.concat ~sep:Pp.newline)
          ++ Pp.newline)
      | _ ->
        List.map ts ~f:(fun c ->
          pp_top_level_construct ~top_level_construct:c ++ Pp.newline)
        |> Pp.concat)
  in
  Pp.concat ts
;;
