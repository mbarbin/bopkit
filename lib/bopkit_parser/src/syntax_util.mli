(** Functions used by the lexer and parser. Defined in a separate module rather
    than in the lexer file to benefits from better language support (editor,
    ocamlformat). *)

val remove_first_and_last_char : string -> string

(** Count the number of newline char and increment the lexbuf accordingly. *)
val new_lines : lexbuf:Lexing.lexbuf -> string -> unit

(** A helper to clean-up the text given as initial contents for memories. *)
val process_memory_code : lexbuf:Lexing.lexbuf -> code:string -> string

val parse_filter_decl : string -> Bopkit.Netlist.index list -> string list

val parse_filter_call
  :  string
  -> Bopkit.Netlist.index list
  -> Bopkit.Arithmetic_expression.t list
