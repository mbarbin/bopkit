type t = Bopkit_process.Program.t
type token = Parser.token

let lexer = Lexer.read
let parser_ = Parser.program
