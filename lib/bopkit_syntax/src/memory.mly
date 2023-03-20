%{
  open! Bopkit.Netlist
%}

%type <Bopkit.Netlist.memory> declaration_memoire

%%

%public declaration_memoire:
  | _tag=ROM IDENT LPAREN expr_arith VIRG expr_arith RPAREN EGAL text_or_file
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; memory_kind = ROM
      ; address_width = $4
      ; data_width = $6
      ; memory_content = $9
      }
    }

  | _tag=RAM IDENT LPAREN expr_arith VIRG expr_arith RPAREN EGAL text_or_file
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; memory_kind = RAM
      ; address_width = $4
      ; data_width = $6
      ; memory_content = $9
      }
    }

  | _tag=RAM IDENT LPAREN expr_arith VIRG expr_arith RPAREN
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; name = $2
      ; memory_kind = RAM
      ; address_width = $4
      ; data_width = $6
      ; memory_content = Zero
      }
    }
;

text_or_file:
  | TEXT CODE                                                        { Text $2 }
  | FILE LPAREN STRING RPAREN                                        { File $3 }
;
