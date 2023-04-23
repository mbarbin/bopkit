open! Core

type t = Visa.Program.t
type token = Parser.token

let lexer = Lexer.read
let parser_ = Parser.program
