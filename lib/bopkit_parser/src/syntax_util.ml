(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let remove_first_and_last_char s =
  assert (String.length s >= 2);
  String.sub s ~pos:1 ~len:(String.length s - 2)
;;

let new_lines ~lexbuf s =
  String.iter s ~f:(fun c -> if Char.equal c '\n' then Lexing.new_line lexbuf)
;;

let process_memory_code ~lexbuf ~code =
  let count_newlines = String.count code ~f:(fun c -> Char.equal c '\n') in
  for _ = 1 to count_newlines do
    Lexing.new_line lexbuf
  done;
  let code = remove_first_and_last_char code in
  if count_newlines = 0
  then " " ^ String.strip code ^ " "
  else (
    let last_is_newline = String.is_suffix code ~suffix:"\n" in
    let code =
      code
      |> String.split_lines
      |> List.map ~f:(fun line -> String.rstrip line)
      |> String.concat ~sep:"\n"
    in
    if last_is_newline then code ^ "\n" else code)
;;

let parse_filter_decl fct params =
  List.map params ~f:(function
    | Bopkit.Netlist.Index (Bopkit.Arithmetic_expression.VAR p) -> p
    | _ -> failwith (Printf.sprintf "Fonction %s, erreur dans les parametres" fct))
;;

let parse_filter_call fct params =
  List.map params ~f:(function
    | Bopkit.Netlist.Index e -> e
    | _ -> failwith (Printf.sprintf "Fonction %s, erreur dans les parametres" fct))
;;
