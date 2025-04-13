{
}

let whitespace = [' ' '\t']+

rule read = parse
 | whitespace { read lexbuf }
 | (['/'] ['/'] [^'\n']*) as text {
     Parser.COMMENT text
   }
 | ['\n']   { Lexing.new_line lexbuf; Parser.NEWLINE }
 | "R0"     { Parser.REGISTER_NAME R0 }
 | "R1"     { Parser.REGISTER_NAME R1 }
 | "macro"  { Parser.MACRO }
 | "define" { Parser.DEFINE }
 | "end"    { Parser.END }
 | ","      { Parser.COMMA }
 | ":"      { Parser.COLON }
 | "nop"    { Parser.INSTRUCTION_NAME NOP }
 | "add"    { Parser.INSTRUCTION_NAME ADD }
 | "and"    { Parser.INSTRUCTION_NAME AND }
 | "swc"    { Parser.INSTRUCTION_NAME SWC }
 | "cmp"    { Parser.INSTRUCTION_NAME CMP }
 | "not"    { Parser.INSTRUCTION_NAME NOT }
 | "gof"    { Parser.INSTRUCTION_NAME GOF }
 | "jmp"    { Parser.INSTRUCTION_NAME JMP }
 | "jmn"    { Parser.INSTRUCTION_NAME JMN }
 | "jmz"    { Parser.INSTRUCTION_NAME JMZ }
 | "store"  { Parser.INSTRUCTION_NAME STORE }
 | "write"  { Parser.INSTRUCTION_NAME WRITE }
 | "load"   { Parser.INSTRUCTION_NAME LOAD }
 | "sleep"  { Parser.INSTRUCTION_NAME SLEEP }
 | ['#'] (['0'-'9']+ as int) { Parser.INT_ARGUMENT (int_of_string int) }
 | (['0'-'9']+) as int { Parser.INT int }
 | ['@'] ((['A'-'Z' 'a'-'z' '0'-'9' '_' '\'' '~']*)
      as name)
    { LABEL_ARGUMENT name }
 | ['$'] ((['A'-'Z' 'a'-'z' '_' '\'' '~']
       ['A'-'Z' 'a'-'z' '0'-'9' '_' '\'' '~']*)
      as name)
    { PARAMETER_ARGUMENT name }
 | (['A'-'Z' 'a'-'z' '_' '\'' '~']
       ['A'-'Z' 'a'-'z' '0'-'9' '_' '\'' '~']*)
      as name
    { IDENT name }
 | eof { EOF }
