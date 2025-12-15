(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t =
  | Single_line of
      { is_documentation_comment : bool
      ; text : string
      }
  | Multiple_lines of
      { is_documentation_comment : bool
      ; lines : string list
      }
[@@deriving equal, sexp_of]

let parse text =
  let text = String.strip text in
  if String.length text < 2
  then None
  else if not (Char.equal text.[0] '/')
  then None
  else (
    let newlines = String.count text ~f:(fun c -> Char.equal c '\n') in
    match text.[1] with
    | '/' ->
      if newlines = 0
      then (
        let is_documentation_comment =
          String.length text >= 3 && Char.equal text.[2] '/'
        in
        let text =
          String.chop_prefix_exn
            text
            ~prefix:(if is_documentation_comment then "///" else "//")
          |> String.strip
        in
        Some (Single_line { is_documentation_comment; text }))
      else None
    | '*' ->
      (match String.is_suffix text ~suffix:"*/" with
       | false -> None
       | true ->
         if String.length text = 3
         then None
         else (
           let is_documentation_comment =
             Char.equal text.[2] '*' && String.length text >= 5
           in
           let text =
             String.chop_prefix_exn
               text
               ~prefix:(if is_documentation_comment then "/**" else "/*")
             |> String.chop_suffix_exn ~suffix:"*/"
           in
           let lines =
             text
             |> String.split_lines
             |> List.map ~f:(fun line ->
               let line = String.strip line in
               let line =
                 String.chop_prefix line ~prefix:"*" |> Option.value ~default:line
               in
               String.strip line)
             |> List.drop_while ~f:String.is_empty
             |> List.rev
             |> List.drop_while ~f:String.is_empty
             |> List.rev
           in
           Some (Multiple_lines { is_documentation_comment; lines })))
    | _ -> None)
;;

let parse_exn comment =
  match parse comment with
  | Some t -> t
  | None ->
    raise_s
      [%sexp
        "Internal error. A program fragment was parsed as a comment by the parser, but \
         later not recognized as such. Please report upstream."
      , [%here]
      , { comment : string }]
;;

let render = function
  | Single_line { is_documentation_comment; text } ->
    let prefix = if is_documentation_comment then "///" else "//" in
    [ (if String.is_empty text then prefix else Printf.sprintf "%s %s" prefix text) ]
  | Multiple_lines { is_documentation_comment; lines } ->
    if is_documentation_comment
    then
      List.concat
        [ [ "/**" ]
        ; List.map lines ~f:(fun line ->
            if String.is_empty line then " *" else " * " ^ line)
        ; [ " */" ]
        ]
    else (
      match lines with
      | [] -> [ "/* */" ]
      | hd :: tl ->
        List.concat
          [ [ "/* " ^ hd ]
          ; List.map tl ~f:(fun line ->
              if String.is_empty line then " *" else " * " ^ line)
          ; [ " */" ]
          ])
;;
