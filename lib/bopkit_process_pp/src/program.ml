type t = Bopkit_process.Program.t

let pp_ident (ident : Bopkit_process.Ident.t With_loc.t) =
  Pp.verbatim (ident.symbol |> Bopkit_process.Ident.to_string)
;;

let pp_operator_name (operator_name : Bopkit_process.Operator_name.t With_loc.t) =
  Pp.verbatim (operator_name.symbol |> Bopkit_process.Operator_name.to_string)
;;

let pp_argument (argument : Bopkit_process.Program.Argument.t) =
  match argument with
  | Ident { ident } -> pp_ident ident
  | Constant { value } -> Pp.verbatim (Int.to_string value)
;;

let pp_comments comments =
  let open Pp.O in
  Pp.concat
    (List.map comments ~f:(fun comment ->
       let comment = comment |> String.strip in
       Pp.verbatim comment ++ Pp.newline))
;;

let pp_assignment
  { Bopkit_process.Program.Assignment.comments; result; operator_name; arguments }
  =
  let open Pp.O in
  let operator = pp_operator_name operator_name in
  let operation =
    match arguments with
    | [| arg1; arg2 |] ->
      Pp.concat [ pp_argument arg1; Pp.space; operator; Pp.space; pp_argument arg2 ]
    | _ ->
      operator
      ++ Pp.space
      ++ Pp.concat ~sep:Pp.space (arguments |> Array.to_list |> List.map ~f:pp_argument)
  in
  Pp.concat [ pp_comments comments; pp_ident result; Pp.verbatim " = "; operation ]
;;

let pp { Bopkit_process.Program.input; output; assignments; head_comments; tail_comments }
  =
  let open Pp.O in
  let io keyword idents =
    Pp.concat
      [ Pp.verbatim keyword ++ Pp.space
      ; Pp.concat ~sep:(Pp.verbatim ", ") (idents |> Array.to_list |> List.map ~f:pp_ident)
      ]
    |> Pp.hbox
  in
  pp_comments head_comments
  ++ (io "input" input
      ++ Pp.concat
           (List.map assignments ~f:(fun assignment ->
              Pp.newline ++ pp_assignment assignment))
      |> Pp.box ~indent:2)
  ++ Pp.newline
  ++ io "output" output
  ++ Pp.newline
  ++ pp_comments tail_comments
;;
