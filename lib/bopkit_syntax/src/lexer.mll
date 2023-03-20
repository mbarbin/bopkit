{
  open Parser
}

let whitespace = [' ' '\t']+
let newline = '\n' | "\r\n"
let ident_prefix = ['A'-'Z' 'a'-'z' '_' '\'' '~']
let ident_suffix = ['A'-'Z' 'a'-'z' '0'-'9' '_' '\'' '~']*

let one_line_comment = ['/'] ['/'] [^'\n']* newline

rule read = parse
  | (['/'] ['*'] ([^'*'] | (['*'] [^'/']))*
       ['*'] ['/']) as comment
    { Comments_state.add_comment ~lexbuf ~comment;
      Syntax_util.new_lines ~lexbuf comment;
      read lexbuf
    }
  | one_line_comment as comment                  { Comments_state.add_comment ~lexbuf ~comment;
                                                   Lexing.new_line lexbuf;
						   read lexbuf }
  | newline                                      { Lexing.new_line lexbuf;
						   read lexbuf }
  | whitespace                                   { read lexbuf }
  | "#define"                                    { DEFINE }
  | "#include"                                   { TAG_INCLUDE }
  | "external"                                   { EXTERNAL }
  | "init"                                       { INIT }
  | "def"                                        { DEF }
  | "with"                                       { WITH }
  | "unused"                                     { UNUSED }
  | "where"                                      { WHERE }
  | "end"                                        { END }
  | "pipe"                                       { TOK_PIPE }
  | "ROM"                                        { ROM }
  | "RAM"                                        { RAM }
  | "text"                                       { TEXT }
  | "file"                                       { FILE }
  | "for"                                        { FOR }
  | "to"                                         { TO }
  | "if"                                         { IF }
  | "then"                                       { THEN }
  | "else"                                       { ELSE }
  | "log"                                        { LEX_LOG }
  | "mod"                                        { LEX_MOD }
  | "min"                                        { LEX_MIN }
  | "max"                                        { LEX_MAX }
  | "&&"                                         { LEX_AND }
  | "||"                                         { LEX_OR }
  | "|"                                          { LEX_OR }
  | "&"                                          { LEX_AND }
  | (['{'] [^'{']* ['}']) as code                { CODE (Syntax_util.process_memory_code ~lexbuf ~code) }
  | (['0'-'9']+) as int                          { INT (int_of_string int) }
  | "+"                                          { LEX_ADD }
  | "-"                                          { LEX_SUB }
  | "/"                                          { LEX_DIV }
  | "^"                                          { LEX_EXP }
  | "**"                                         { LEX_EXP }
  | "*"                                          { LEX_MULT }
  | "("                                          { LPAREN }
  | ")"                                          { RPAREN }
  | "=="                                         { CONDEGAL }
  | "!="                                         { NOTEGAL }
  | "!"                                          { POINT_EXCLAM }
  | "<>"                                         { NOTEGAL }
  | "<="                                         { PPETIT }
  | ">="                                         { PGRAND }
  | "="                                          { EGAL }
  | "<"                                          { SPPETIT }
  | ">"                                          { SPGRAND }
  | ";"                                          { POINT_VIRG }
  | "?"                                          { POINT_INTER }
  | "$"                                          { DOLLAR }
  | ".."                                         { POINTPOINT }
  | ","                                          { VIRG }
  | ":"                                          { DEUX_POINTS }
  | "."                                          { POINT }
  | "["                                          { LCROCHET }
  | "]"                                          { RCROCHET }
  | (ident_prefix ident_suffix) as name          { IDENT name }
  | (['\"'] [^ '\"' '\n']* ['\"']) as str        { STRING (Syntax_util.remove_first_and_last_char str) }
  | eof                                          { EOF }
