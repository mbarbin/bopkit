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

val vars : t -> string Appendable_list.t
val eval : t -> parameters:Parameters.t -> bool Or_eval_error.t
val pp : t -> _ Pp.t
