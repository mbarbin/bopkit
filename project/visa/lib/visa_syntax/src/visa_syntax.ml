type t = Visa.Program.t
type token = Parser.token

let lexer = Lexer.read

let parser_ lexem lexbuf =
  (* I couldn't find a way to indicate in the parser without creating a
     shift/reduce conflict that NEWLINE after label introduction were optional.
     Thus I am post-processing the resulting AST to remove any NEWLINE that
     directly follows a label introduction. *)
  let program = Parser.program lexem lexbuf in
  let rec aux acc (last : Visa.Program.Top_level_construct.t) (program : Visa.Program.t) =
    match program with
    | [] -> List.rev acc
    | hd :: tl ->
      let remove_element =
        match last, hd with
        | Label_introduction _, Newline -> true
        | _ -> false
      in
      aux (if remove_element then acc else hd :: acc) hd tl
  in
  aux [] Newline program
;;
