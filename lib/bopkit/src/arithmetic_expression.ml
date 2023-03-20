open! Core

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
    if nsur2 = 0 then accu else aux (succ accu) nsur2
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
           let vs =
             match Sys.getenv s with
             | Some v -> v
             | None ->
               error.return
                 (Free_variable { name = s; candidates = Parameters.keys parameters })
           in
           (match int_of_string vs with
            | i -> i
            | exception _ ->
              error.return
                (Type_clash
                   { message =
                       Printf.sprintf
                         "Parameter '%s' is of type string but an int is expected"
                         s
                   })))
      | CST c -> c
      | ADD (a, b) -> eval a + eval b
      | SUB (a, b) -> eval a - eval b
      | DIV (a, b) -> eval a / eval b
      | MULT (a, b) -> eval a * eval b
      | MOD (a, b) -> eval a mod eval b
      | EXP (a, b) -> Int.pow (eval a) (eval b)
      | MIN (a, b) -> min (eval a) (eval b)
      | MAX (a, b) -> max (eval a) (eval b)
      | LOG e -> log2 (eval e)
    in
    eval t)
;;

let pp t =
  let rec aux formatter = function
    | ADD (t1, t2) -> Format.fprintf formatter "%a + %a" aux t1 aux_closed t2
    | SUB (t1, t2) ->
      (match t1 with
       | CST 0 -> Format.fprintf formatter "-%a" aux_closed t2
       | _ -> Format.fprintf formatter "%a - %a" aux t1 aux_closed t2)
    | t -> aux_closed formatter t
  and aux_closed formatter = function
    | DIV (t1, t2) -> Format.fprintf formatter "%a / %a" aux_closed t1 aux_priority t2
    | MULT (t1, t2) -> Format.fprintf formatter "%a * %a" aux_closed t1 aux_priority t2
    | MOD (t1, t2) -> Format.fprintf formatter "%a mod %a" aux_closed t1 aux_priority t2
    | t -> aux_priority formatter t
  and aux_priority formatter = function
    | LOG t -> Format.fprintf formatter "log %a" aux_terminal t
    | EXP (t1, t2) -> Format.fprintf formatter "%a ^ %a" aux_priority t1 aux_terminal t2
    | t -> aux_terminal formatter t
  and aux_terminal formatter = function
    | CST i -> Format.fprintf formatter "%d" i
    | VAR var -> Format.fprintf formatter "%s" var
    | MIN (t1, t2) -> Format.fprintf formatter "min(%a,%a)" aux t1 aux t2
    | MAX (t1, t2) -> Format.fprintf formatter "max(%a,%a)" aux t1 aux t2
    | t -> Format.fprintf formatter "(%a)" aux t
  in
  Pp.of_fmt aux t
;;
