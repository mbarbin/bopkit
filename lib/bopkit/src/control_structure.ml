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

let rec map t ~f =
  match (t : _ t) with
  | Node a -> Node (f a)
  | For_loop { loc; head_comments; tail_comments; ident; left_bound; right_bound; nodes }
    ->
    For_loop
      { loc
      ; head_comments
      ; tail_comments
      ; ident
      ; left_bound
      ; right_bound
      ; nodes = List.map nodes ~f:(fun node -> map node ~f)
      }
  | If_then_else
      { loc
      ; head_comments
      ; then_tail_comments
      ; tail_comments
      ; if_condition
      ; then_nodes
      ; else_nodes
      } ->
    If_then_else
      { loc
      ; head_comments
      ; then_tail_comments
      ; tail_comments
      ; if_condition
      ; then_nodes = List.map then_nodes ~f:(fun node -> map node ~f)
      ; else_nodes = List.map else_nodes ~f:(fun node -> map node ~f)
      }
;;

let expand t ~parameters ~f =
  let ok_eval_exn ~loc res = Or_eval_error.ok_exn res ~loc in
  let rec aux parameters = function
    | Node alpha -> [ f ~parameters alpha ]
    | For_loop
        { loc
        ; head_comments = _
        ; tail_comments = _
        ; ident = j
        ; left_bound = exp_inf
        ; right_bound = exp_sup
        ; nodes = node_list
        } ->
      Option.iter (Parameters.find parameters ~parameter_name:j) ~f:(fun previous_value ->
        Err.debug
          ~loc
          [ Pp.textf
              "This shadows the previous value of '%s' (=> %s)."
              j
              (Parameter.Value.to_syntax previous_value)
          ]);
      let inf, sup =
        ( Arithmetic_expression.eval exp_inf ~parameters |> ok_eval_exn ~loc
        , Arithmetic_expression.eval exp_sup ~parameters |> ok_eval_exn ~loc )
      in
      let one_step index li =
        List.concat_map
          li
          ~f:(aux ({ Parameter.name = j; value = Int index } :: parameters))
      in
      Interval.expand { from = inf; to_ = sup } ~f:(fun i -> one_step i node_list)
      |> List.concat
    | If_then_else
        { loc
        ; head_comments = _
        ; then_tail_comments = _
        ; tail_comments = _
        ; if_condition
        ; then_nodes
        ; else_nodes
        } ->
      (if Conditional_expression.eval if_condition ~parameters |> ok_eval_exn ~loc
       then then_nodes
       else else_nodes)
      |> List.concat_map ~f:(aux parameters)
  in
  aux parameters t
;;
