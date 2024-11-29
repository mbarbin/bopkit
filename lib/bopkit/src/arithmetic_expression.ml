type t =
  | VAR of string
  | CST of int
  | ADD of t * t
  | SUB of t * t
  | DIV of t * t
  | MULT of t * t
  | MOD of t * t
  | EXP of t * t
  | LOG of t
  | MIN of t * t
  | MAX of t * t
[@@deriving equal, sexp_of]

let log2 =
  let rec aux accu n =
    let nsur2 = n / 2 in
    if nsur2 = 0 then accu else aux (Int.succ accu) nsur2
  in
  aux 0
;;

let vars t =
  let rec aux accu t =
    match (t : t) with
    | VAR s -> s :: accu
    | CST _ -> accu
    | ADD (a, b)
    | SUB (a, b)
    | DIV (a, b)
    | MULT (a, b)
    | MOD (a, b)
    | EXP (a, b)
    | MIN (a, b)
    | MAX (a, b) -> aux (aux accu a) b
    | LOG a -> aux accu a
  in
  aux [] t |> List.dedup_and_sort ~compare:String.compare |> Appendable_list.of_list
;;

let eval t ~parameters =
  Or_eval_error.with_return (fun ~error ->
    let rec eval : t -> int = function
      | VAR s ->
        (match Parameters.find parameters ~parameter_name:s with
         | Some (Int i) -> i
         | Some (String _) ->
           error.return
             (Type_clash
                { message =
                    Printf.sprintf
                      "Parameter '%s' is of type string but an int is expected"
                      s
                })
         | None ->
           error.return
             (Free_variable { name = s; candidates = Parameters.keys parameters }))
      | CST c -> c
      | ADD (a, b) -> eval a + eval b
      | SUB (a, b) -> eval a - eval b
      | DIV (a, b) -> eval a / eval b
      | MULT (a, b) -> eval a * eval b
      | MOD (a, b) -> eval a % eval b
      | EXP (a, b) -> Int.pow (eval a) (eval b)
      | MIN (a, b) -> min (eval a) (eval b)
      | MAX (a, b) -> max (eval a) (eval b)
      | LOG e -> log2 (eval e)
    in
    eval t)
;;

let pp t =
  let open Pp.O in
  let concat li = Pp.box (Pp.concat ~sep:Pp.space li) in
  let rec aux = function
    | ADD (t1, t2) -> concat [ aux t1; Pp.verbatim "+"; aux_closed t2 ]
    | SUB (t1, t2) ->
      (match t1 with
       | CST 0 -> Pp.verbatim "-" ++ aux_closed t2
       | _ -> concat [ aux t1; Pp.verbatim "-"; aux_closed t2 ])
    | t -> aux_closed t
  and aux_closed = function
    | DIV (t1, t2) -> concat [ aux_closed t1; Pp.verbatim "/"; aux_priority t2 ]
    | MULT (t1, t2) -> concat [ aux_closed t1; Pp.verbatim "*"; aux_priority t2 ]
    | MOD (t1, t2) -> concat [ aux_closed t1; Pp.verbatim "mod"; aux_priority t2 ]
    | t -> aux_priority t
  and aux_priority = function
    | LOG t -> concat [ Pp.verbatim "log"; aux_terminal t ]
    | EXP (t1, t2) -> concat [ aux_priority t1; Pp.verbatim "^"; aux_terminal t2 ]
    | t -> aux_terminal t
  and aux_terminal = function
    | CST i -> Pp.verbatim (Int.to_string i)
    | VAR var -> Pp.verbatim var
    | MIN (t1, t2) ->
      Pp.verbatim "min(" ++ aux t1 ++ Pp.verbatim "," ++ aux t2 ++ Pp.verbatim ")"
    | MAX (t1, t2) ->
      Pp.verbatim "max(" ++ aux t1 ++ Pp.verbatim "," ++ aux t2 ++ Pp.verbatim ")"
    | t -> Pp.verbatim "(" ++ aux t ++ Pp.verbatim ")"
  in
  aux t
;;
