type t = Bopkit.Netlist.t
type token = Parser.token

let lexer = Lexer.read
let parser = Parser.netlist
