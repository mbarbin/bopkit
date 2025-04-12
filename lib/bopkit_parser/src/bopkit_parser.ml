type t = Bopkit.Netlist.t
type token = Parser.token

let lexer = Lexer.read
let parser lexer lexbuf = Comments_parser.wrap ~f:(fun () -> Parser.netlist lexer lexbuf)
