%{
%}

%type <Bopkit.Conditional_expression.t> expr_bool

%%

%public expr_bool:
  | expr_bool LEX_OR expr_bool_close                     { COND_OR ($1, $3) }
  | expr_bool_close                                      { $1 }
;

expr_bool_close:
  | expr_bool_close LEX_AND expr_bool_terminale          { COND_AND ($1, $3) }
//  | POINT_EXCLAM expr_bool_terminale                     { COND_NEG ($2) }
  | expr_bool_terminale                                  { $1 }
;

expr_bool_terminale:
  |  expr_arith EGAL expr_arith                          { COND_EQ ($1, $3) }
  |  expr_arith CONDEGAL expr_arith                      { COND_EQ ($1, $3) }
  |  expr_arith NOTEGAL expr_arith                       { COND_NEQ ($1, $3) }
  |  expr_arith PPETIT expr_arith                        { COND_PP ($1, $3) }
  |  expr_arith PGRAND expr_arith                        { COND_PG ($1, $3) }
  |  expr_arith SPPETIT expr_arith                       { COND_SPP ($1, $3) }
  |  expr_arith SPGRAND expr_arith                       { COND_SPG ($1, $3) }
  |  POINT_EXCLAM expr_arith                             { COND_NEG (CONST $2) }
  |  POINT_EXCLAM LPAREN expr_bool RPAREN                { COND_NEG $3 }
  |  LPAREN expr_bool RPAREN                             { $2 }
;
