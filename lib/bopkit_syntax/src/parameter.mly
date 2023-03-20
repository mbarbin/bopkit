%{
  open! Bopkit.Netlist
%}

%type <Bopkit.Netlist.parameter> parameter_define

%%

%public parameter_define:
  | _tag=DEFINE IDENT expr_arith
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; parameter_value = DefInt $3
      }
    }
  | _tag=DEFINE IDENT LPAREN expr_bool POINT_INTER expr_arith DEUX_POINTS expr_arith RPAREN
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; parameter_value = DefCondInt ($4, $6, $8)
      }
    }
  | _tag=DEFINE IDENT STRING
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; parameter_value = DefString $3
      }
    }
  | _tag=DEFINE IDENT LPAREN expr_bool POINT_INTER STRING DEUX_POINTS STRING RPAREN
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; parameter_value = DefCondString ($4, $6, $8)
      }
    }
;
