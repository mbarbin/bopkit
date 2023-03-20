{
  open! Parser
}

let ident_prefix = ['A'-'Z' 'a'-'z' '_' '\'' '~']
let ident_suffix = ['A'-'Z' 'a'-'z' '0'-'9' '_' '\'' '~']*

rule read = parse
  | eof                                       { EOF }
  | ['\n']                                    { Lexing.new_line lexbuf; read lexbuf }
  | [' ' '\t'] +                              { read lexbuf }
  | (['0'-'1']+) as bits                      { BITS bits }
  | (ident_prefix ident_suffix) as name       { IDENT name }
  | (['\"'] [^'\"']* ['\"']) as str           { STRING (Core.String.sub str ~pos:1 ~len:((String.length str) - 2)) }
