module Topo_parameter :
  Bopkit_topological_sort.Node
  with type t = Bopkit.Netlist.parameter
   and type key = string = struct
  type t = Bopkit.Netlist.parameter
  type key = string

  let key (m : t) = m.name

  let parents (m : t) =
    let ok_eval_exn res =
      Bopkit.Or_eval_error.ok res ~f:(fun t -> Bopkit.Eval_error.raise ~loc:m.loc t)
    in
    match m.parameter_value with
    | DefCondInt (cond_exp, exp1, exp2) ->
      Appendable_list.concat
        [ Bopkit.Conditional_expression.vars cond_exp
        ; Bopkit.Arithmetic_expression.vars exp1
        ; Bopkit.Arithmetic_expression.vars exp2
        ]
    | DefInt exp -> Bopkit.Arithmetic_expression.vars exp
    | DefCondString (cond_exp, com1, com2) ->
      let v1 = Bopkit.Conditional_expression.vars cond_exp
      and v2 =
        Bopkit.String_with_vars.vars (Bopkit.String_with_vars.parse com1 |> ok_eval_exn)
      and v3 =
        Bopkit.String_with_vars.vars (Bopkit.String_with_vars.parse com2 |> ok_eval_exn)
      in
      Appendable_list.concat [ v1; v2; v3 ]
    | DefString com ->
      Bopkit.String_with_vars.vars (Bopkit.String_with_vars.parse com |> ok_eval_exn)
  ;;
end

let sort parameters =
  Bopkit_topological_sort.sort (module Topo_parameter) (module String) parameters
;;

let pass parameters =
  let parameters =
    (* We add a variable to allow the user to know on which OS it is executing. *)
    let current_os =
      { Bopkit.Netlist.loc = Loc.none
      ; comments = Bopkit.Comments.none
      ; name = "CURRENT_OS"
      ; parameter_value =
          (match Sys.os_type with
           | "Unix" -> DefInt (CST 0)
           | "Win32" -> DefInt (CST 1)
           | _ -> DefInt (CST 2))
      }
    in
    sort (current_os :: parameters)
  in
  List.fold_left parameters ~init:[] ~f:(fun env (m : Bopkit.Netlist.parameter) ->
    let ok_eval_exn res = Bopkit.Or_eval_error.ok_exn res ~loc:m.loc in
    let eval_expr e =
      Bopkit.Arithmetic_expression.eval e ~parameters:env |> ok_eval_exn
    in
    let eval_cond c =
      Bopkit.Conditional_expression.eval c ~parameters:env |> ok_eval_exn
    in
    let parameter_value : Bopkit.Parameter.Value.t =
      match m.parameter_value with
      | DefInt expr_parameter -> Int (eval_expr expr_parameter)
      | DefCondInt (if_, then_, else_) ->
        let val_if = eval_cond if_ in
        Int (eval_expr (if val_if then then_ else else_))
      | DefString s ->
        String
          (Bopkit.String_with_vars.eval
             (Bopkit.String_with_vars.parse s |> ok_eval_exn)
             ~parameters:env
           |> ok_eval_exn)
      | DefCondString (if_, then_, else_) ->
        let val_if = eval_cond if_ in
        String
          (Bopkit.String_with_vars.eval
             (Bopkit.String_with_vars.parse (if val_if then then_ else else_)
              |> ok_eval_exn)
             ~parameters:env
           |> ok_eval_exn)
    in
    { Bopkit.Parameter.name = m.name; value = parameter_value } :: env)
;;
