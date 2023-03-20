open! Core
open! Or_error.Let_syntax

module type S = sig
  type token
  type t

  val lexer : Lexing.lexbuf -> token
  val parser_ : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> t
end

module Internal_result = struct
  type error =
    { loc : Loc.t
    ; exn : Exn.t
    }

  type 'a t = ('a, error) Result.t

  let with_dot m = if String.is_suffix m ~suffix:"." then m else m ^ "."

  let or_error (t : _ t) =
    match t with
    | Ok t -> Ok t
    | Error { loc; exn } ->
      let extra =
        match exn with
        | Failure m -> "\nError: " ^ with_dot m
        | _ -> " syntax error."
      in
      Or_error.errorf "%s%s" (Loc.to_string loc) extra
  ;;

  let ok_exn (t : _ t) ~error_log =
    match t with
    | Ok t -> t
    | Error { loc; exn } ->
      let extra =
        match exn with
        | Failure m -> [ Pp.text (with_dot m) ]
        | _ -> [ Pp.text "Syntax error." ]
      in
      Error_log.raise error_log ~loc extra
  ;;
end

let parse_lexbuf_internal (type t) (module S : S with type t = t) ~filename ~lexbuf =
  Lexing.set_filename lexbuf filename;
  match Comments_state.wrap ~f:(fun () -> S.parser_ S.lexer lexbuf) with
  | program -> Ok program
  | exception exn ->
    let pos = Lexing.lexeme_start_p lexbuf in
    Error { Internal_result.loc = Loc.of_pos pos; exn }
;;

let parse_lexbuf (type t) (module S : S with type t = t) ~filename ~lexbuf =
  parse_lexbuf_internal (module S) ~filename ~lexbuf |> Internal_result.or_error
;;

let parse_lexbuf_exn (type t) (module S : S with type t = t) ~filename ~lexbuf ~error_log =
  parse_lexbuf_internal (module S) ~filename ~lexbuf |> Internal_result.ok_exn ~error_log
;;

let parse_file_internal (type t) (module S : S with type t = t) ~filename =
  let open Result.Let_syntax in
  let loc = Loc.in_file ~filename in
  let%bind ic =
    try In_channel.create filename |> return with
    | Sys_error (m : string) -> Error { Internal_result.loc; exn = Failure m }
  in
  let lexbuf = Lexing.from_channel ic in
  let res = parse_lexbuf_internal (module S) ~filename ~lexbuf in
  In_channel.close ic;
  res
;;

let parse_file (type t) (module S : S with type t = t) ~filename =
  parse_file_internal (module S) ~filename |> Internal_result.or_error
;;

let parse_file_exn (type t) (module S : S with type t = t) ~filename ~error_log =
  parse_file_internal (module S) ~filename |> Internal_result.ok_exn ~error_log
;;
