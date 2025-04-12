%{
  open Bopkit.Arithmetic_expression
%}

%type <Bopkit.Arithmetic_expression.t> expr_arith

%%

%public expr_arith:
  | expr_arith LEX_ADD expr_arith_close    { ADD ($1, $3) }
  | expr_arith LEX_SUB expr_arith_close    { SUB ($1, $3) }
  | LEX_SUB expr_arith_close               { SUB (CST 0, $2) }
  | expr_arith_close                       { $1 }
;

expr_arith_close:
  | expr_arith_close LEX_DIV expr_prio     { DIV ($1, $3) }
  | expr_arith_close LEX_MULT expr_prio    { MULT ($1, $3) }
  | expr_arith_close LEX_MOD expr_prio     { MOD ($1, $3) }
  | expr_prio                              { $1 }
;

expr_prio:
  | expr_prio LEX_EXP expr_terminale       { EXP ($1, $3) }
  | LEX_LOG expr_terminale                 { LOG $2 }
  | expr_terminale                         { $1 }

expr_terminale:
  | INT                                                  { CST $1 }
  | IDENT                                                { VAR $1 }
  | LPAREN expr_arith RPAREN                             { $2 }
  | LEX_MAX LPAREN expr_arith VIRG expr_arith RPAREN     { MAX ($3, $5) }
  | LEX_MIN LPAREN expr_arith VIRG expr_arith RPAREN     { MIN ($3, $5) }
;
