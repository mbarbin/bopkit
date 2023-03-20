open! Core

type t =
  | CONST of Arithmetic_expression.t
  | COND_EQ of Arithmetic_expression.t * Arithmetic_expression.t
  | COND_NEQ of Arithmetic_expression.t * Arithmetic_expression.t
  | COND_PP of Arithmetic_expression.t * Arithmetic_expression.t
  | COND_PG of Arithmetic_expression.t * Arithmetic_expression.t
  | COND_SPP of Arithmetic_expression.t * Arithmetic_expression.t
  | COND_SPG of Arithmetic_expression.t * Arithmetic_expression.t
  | COND_NEG of t
  | COND_OR of t * t
  | COND_AND of t * t
[@@deriving equal, sexp_of]

let vars t =
  let rec aux accu t =
    match (t : t) with
    | CONST e1 -> Arithmetic_expression.vars e1
    | COND_EQ (e1, e2)
    | COND_NEQ (e1, e2)
    | COND_PP (e1, e2)
    | COND_PG (e1, e2)
    | COND_SPP (e1, e2)
    | COND_SPG (e1, e2) ->
      Appendable_list.append
        (Arithmetic_expression.vars e1)
        (Arithmetic_expression.vars e2)
    | COND_NEG c1 -> aux accu c1
    | COND_OR (c1, c2) | COND_AND (c1, c2) -> aux (aux accu c1) c2
  in
  aux Appendable_list.empty t
;;

let eval t ~parameters =
  Or_eval_error.with_return (fun ~error ->
    let eval_expr expr =
      Arithmetic_expression.eval expr ~parameters |> Or_eval_error.propagate ~error
    in
    let rec aux : t -> bool = function
      | CONST e1 -> eval_expr e1 <> 0
      | COND_EQ (e1, e2) -> eval_expr e1 = eval_expr e2
      | COND_NEQ (e1, e2) -> eval_expr e1 <> eval_expr e2
      | COND_PP (e1, e2) -> eval_expr e1 <= eval_expr e2
      | COND_PG (e1, e2) -> eval_expr e1 >= eval_expr e2
      | COND_SPP (e1, e2) -> eval_expr e1 < eval_expr e2
      | COND_SPG (e1, e2) -> eval_expr e1 > eval_expr e2
      | COND_NEG c1 -> not (aux c1)
      | COND_OR (c1, c2) -> aux c1 || aux c2
      | COND_AND (c1, c2) -> aux c1 && aux c2
    in
    aux t)
;;

let pp t =
  let aux_arith = Arithmetic_expression.pp in
  let rec aux = function
    | CONST e -> aux_arith e
    | COND_OR (t1, t2) -> Pp.concat [ aux t1; Pp.verbatim " || "; aux_closed t2 ]
    | t -> aux_closed t
  and aux_closed = function
    | COND_AND (t1, t2) ->
      Pp.concat [ aux_closed t1; Pp.verbatim " && "; aux_terminal t2 ]
    | t -> aux_terminal t
  and aux_terminal = function
    | COND_EQ (e1, e2) -> Pp.concat [ aux_arith e1; Pp.verbatim " == "; aux_arith e2 ]
    | COND_NEQ (e1, e2) -> Pp.concat [ aux_arith e1; Pp.verbatim " <> "; aux_arith e2 ]
    | COND_PP (e1, e2) -> Pp.concat [ aux_arith e1; Pp.verbatim " <= "; aux_arith e2 ]
    | COND_PG (e1, e2) -> Pp.concat [ aux_arith e1; Pp.verbatim " >= "; aux_arith e2 ]
    | COND_SPP (e1, e2) -> Pp.concat [ aux_arith e1; Pp.verbatim " < "; aux_arith e2 ]
    | COND_SPG (e1, e2) -> Pp.concat [ aux_arith e1; Pp.verbatim " > "; aux_arith e2 ]
    | COND_NEG (CONST e) -> Pp.concat [ Pp.verbatim "!"; aux_arith e ]
    | COND_NEG t -> Pp.concat [ Pp.verbatim "!("; aux t; Pp.verbatim ")" ]
    | t -> Pp.concat [ Pp.verbatim "("; aux t; Pp.verbatim ")" ]
  in
  aux t
;;
