{
  open Parser
}

let whitespace = [' ' '\t']+

let newline = '\r' | '\n' | "\r\n"

let int = ['0'-'9']+

let ident =
  ['A'-'Z' 'a'-'z'
   '0'-'9' '_'
   '\'' '~' '+' '-' '\\' '/' '^' '&' '|' '<' '>' '=' ';' ':' '!' '?' '!' '[' ']'
  ]+

let comment = ['/'] ['/'] [^'\n']* newline

rule read = parse
  | comment as comment              { Lexing.new_line lexbuf; NL (Some comment) }
  | newline                         { Lexing.new_line lexbuf; NL None }
  | whitespace                      { read lexbuf }
  | "input"                         { INPUT }
  | "output"                        { OUTPUT }
  | int as int                      { INT (int_of_string int) }
  | ","                             { COMMA }
  | "="                             { ASSIGN }
  | "<-"                            { ASSIGN }
  | ident as ident                  { IDENT (Bopkit_process.Ident.of_string ident) }
  | eof                             { EOF }
