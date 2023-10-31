(** Control structure acts as macro. They're developed statically during the
    analysis of the input program. *)

type 'a t =
  | Node of 'a
  | For_loop of
      { loc : Loc.t
      ; head_comments : Comments.t
      ; tail_comments : Comments.t
      ; ident : string
      ; left_bound : Arithmetic_expression.t
      ; right_bound : Arithmetic_expression.t
      ; nodes : 'a t list
      }
  | If_then_else of
      { loc : Loc.t
      ; head_comments : Comments.t
      ; then_tail_comments : Comments.t
      ; tail_comments : Comments.t
      ; if_condition : Conditional_expression.t
      ; then_nodes : 'a t list
      ; else_nodes : 'a t list
      }
[@@deriving equal, sexp_of]

val map : 'a t -> f:('a -> 'b) -> 'b t

val expand
  :  'a t
  -> error_log:Error_log.t
  -> parameters:Parameters.t
  -> f:(parameters:Parameters.t -> 'a -> 'b)
  -> 'b list
