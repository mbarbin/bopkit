%{
  open Bopkit
  open Netlist
%}

%start <Bopkit.Netlist.t> netlist

%%

netlist:
  | list(include_file) list(parameter_define) list(declaration_memoire) list(bloc_externe) list(fonction) _tag=EOF
    { { Netlist.
        include_files = $1
      ; parameters = $2
      ; memories = $3
      ; external_blocks = $4
      ; blocks = $5
      ; eof_comments = Comments.make ~attached_to:($startpos(_tag))
      }
    }
;

//setCPS:
//  |              { () }
//  | SETCPS INT   { Inputtools.cps := $2 }
//;


fonction:
  | ident_list_option ident=IDENT variables_list EGAL variables_list
    unused_list
    _hd=WHERE
      nodes=liste_noeud
    END _tl=WHERE POINT_VIRG
      {
	  { loc = Loc.create $loc(ident)
          ; head_comments = Comments.make ~attached_to:($startpos(_hd))
          ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
	  ; name = Standard { name = ident }
          ; attributes = $1
	  ; inputs = $3
	  ; outputs = $5
	  ; unused_variables = $6
	  ; nodes
	  }
      }
  | ident_list_option ident=IDENT indexation_list arguments_fonctionnels_option variables_list EGAL variables_list
    unused_list
    _hd=WHERE
      nodes=liste_noeud
    END _tl=WHERE POINT_VIRG
      {
	      { loc = Loc.create $loc(ident)
              ; head_comments = Comments.make ~attached_to:($startpos(_hd))
              ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
	      ; name = Parametrized { name = ident; parameters =  (Syntax_util.parse_filter_decl ident $3);  functional_parameters = $4 }
	      ; attributes = $1
              ; inputs = $5
              ; outputs = $7
	      ; unused_variables = $8
	      ; nodes
	      }
      }
  | ident_list_option ident=IDENT indexation_list variables_list EGAL variables_list
    unused_list
    _hd=WHERE
      nodes=liste_noeud
    END _tl=WHERE POINT_VIRG
      {
	      { loc = Loc.create $loc(ident)
              ; head_comments = Comments.make ~attached_to:($startpos(_hd))
              ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
	      ; name = Parametrized { name = ident; parameters = (Syntax_util.parse_filter_decl ident $3);  functional_parameters = [] }
              ; attributes = $1
	      ; inputs = $4
	      ; outputs = $6
	      ; unused_variables = $7
	      ; nodes
	      }
      }
  | ident_list_option ident=IDENT arguments_fonctionnels_option variables_list EGAL variables_list
    unused_list
    _hd=WHERE
      nodes=liste_noeud
    END _tl=WHERE POINT_VIRG
      {
	      { loc = Loc.create $loc(ident)
              ; head_comments = Comments.make ~attached_to:($startpos(_hd))
              ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
	      ; name = Parametrized { name = ident; parameters = []; functional_parameters = $3 }
	      ; attributes = $1
	      ; inputs = $4
              ; outputs = $6
	      ; unused_variables = $7
	      ; nodes
	      }
      }
;

ident_list :
  |           { [] }
  | IDENT     { [$1] }
  | IDENT VIRG ident_list { $1::$3 }
;

%public ident_list_option:
  |                               { [] }
  | LCROCHET ident_list RCROCHET  { $2 }
;

%public arguments_fonctionnels_option :
  | SPPETIT ident_list SPGRAND    { $2 }
;

argument_fonctionnel_effectif :
  | name=IDENT
    { { name; name_is_quoted = false } }
  | name=STRING
    { { name; name_is_quoted = true } }
;

arguments_fonctionnels_effectifs :
  |                                                                      { [] }
  | argument_fonctionnel_effectif                                        { [$1] }
  | argument_fonctionnel_effectif VIRG arguments_fonctionnels_effectifs { $1::$3 }
;

arguments_fonctionnels_effectifs_option :
  |                                                  { [] }
  | SPPETIT arguments_fonctionnels_effectifs SPGRAND { $2 }
;

ident_point_option :
  | IDENT              { $1 }
  | ident_point        { $1 }
;

ident_point :
  | IDENT POINT IDENT       { $3 } /* en attente : { $1^"."^$3 } */
;

unused_list:
  |                                               { [] }
  | WITH UNUSED EGAL variables_list               { $4 }
;

%public liste_noeud:
  |                                               { [] }
  | un_noeud liste_noeud                          { $1::$2 }
;

token_external:
  | TOK_PIPE  { () }
  | EXTERNAL { () }
;

un_noeud:
// Raccourcis pour id
  | outputs=variables_list EGAL variables=variables_list POINT_VIRG
    { Bopkit.Control_structure.Node
      { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(outputs))
      ; call = Block { name = "id"; arguments = []; functional_arguments = [] }
      ; inputs = [ Variables
                     { loc = Loc.create $loc(variables)
                     ; comments = Comments.none
                     ; variables
                     } ]
      ; outputs
      }
    }

  | outputs=variables_list EGAL sucre_gnd_vdd_list POINT_VIRG
    { Bopkit.Control_structure.Node
      { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(outputs))
      ; call = Block { name = "id"; arguments = []; functional_arguments = [] }
      ; inputs = $3
      ; outputs
      }
    }

    // Arguments fonctionnels seuls, sans parametres, avec IDENT classique

//  | variables_list EGAL IDENT arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN POINT_VIRG
//     { SIMPLE ((Message.get_net_list ()),$symbolstartpos.Lexing.pos_lnum,
//         { portee_noeud = Block ($3, [], $4); inputs = $6; outputs = $1}) }

    // argument fonctionnnels seuls, sans parametres, avec IDENT pointé ou classique

  | outputs=variables_list _e=EGAL ident_point_option arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN POINT_VIRG
    { Bopkit.Control_structure.Node
      { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_e))
      ; call = Block { name = $3; arguments = []; functional_arguments = $4 }
      ; inputs = $6
      ; outputs
      }
    }


    // Sans rien du tout
//  | variables_list EGAL ident_point_option LPAREN imbriq_list RPAREN POINT_VIRG
//      { SIMPLE ((Message.get_net_list ()),$symbolstartpos.Lexing.pos_lnum,
//          { portee_noeud = Block ($3, [], []); inputs = $5; outputs = $1}) }

    // argument fonctionnel avec indexation, avec IDENT classique

 | outputs=variables_list _e=EGAL IDENT indexation_list arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN POINT_VIRG
    { Bopkit.Control_structure.Node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(_e))
       ; call =
           Block
             { name = $3
             ; arguments = Syntax_util.parse_filter_call $3 $4
             ; functional_arguments = $5
             }
       ; inputs = $7
       ; outputs
       }
    }

    // argument fonctionnel avec indexation, avec IDENT pointé

  | outputs=variables_list _e=EGAL ident_point indexation_list arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_e))
         ; call =
             Block
              { name = $3
              ; arguments = Syntax_util.parse_filter_call $3 $4
              ; functional_arguments = $5
              }
         ; inputs = $7
         ; outputs
         }
      }

    // Indexation seule, sans argument fonctionnel

//  | variables_list EGAL ident_point indexation_list LPAREN imbriq_list RPAREN POINT_VIRG
  //    { SIMPLE ((Message.get_net_list ()),$symbolstartpos.Lexing.pos_lnum, Block ($3, (Syntax_util.parse_filter_call $3 $4), []), $6, $1) }

 // RESTE : PIPE, EXTERNAL

  | outputs=variables_list _e=EGAL token_external LPAREN STRING RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_e))
         ; call = Pipe { command = $5; output_size = Inferred }
         ; inputs = []
         ; outputs
         }
      }

  | outputs=variables_list _e=EGAL token_external LPAREN STRING VIRG imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_e))
         ; call = Pipe { command = $5; output_size = Inferred }
         ; inputs = $7
         ; outputs
         }
      }

  | _e=token_external LPAREN command=STRING RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_e))
         ; call = Pipe { command; output_size = Inferred }
         ; inputs = []
         ; outputs = []
         }
      }

  | _e=token_external LPAREN command=STRING VIRG inputs=imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_e))
         ; call = Pipe { command; output_size = Inferred }
         ; inputs
         ; outputs = []
         }
      }

  | outputs=variables_list _e=EGAL DOLLAR IDENT LPAREN string_list_virg imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
        { loc = Loc.create $loc
        ; comments = Comments.make ~attached_to:($startpos(_e))
        ; call =
            External_block
             { name = $4
             ; method_name = None
             ; method_name_is_quoted = false
             ; external_arguments = $6
             ; output_size = Inferred
             }
        ; inputs = $7
        ; outputs
        }
      }

  | outputs=variables_list _e=EGAL DOLLAR IDENT POINT IDENT LPAREN string_list_virg imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_e))
         ; call =
             External_block
               { name = $4
               ; method_name = Some $6
               ; method_name_is_quoted = false
               ; external_arguments = $8
               ; output_size = Inferred
               }
         ; inputs = $9
         ; outputs
         }
       }

  | outputs=variables_list _e=EGAL DOLLAR IDENT POINT STRING LPAREN string_list_virg imbriq_list RPAREN POINT_VIRG
    { Bopkit.Control_structure.Node
      { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_e))
      ; call =
          External_block
            { name = $4
            ; method_name = Some $6
            ; method_name_is_quoted = true
            ; external_arguments = $8
            ; output_size = Inferred
            }
      ; inputs = $9
      ; outputs
      }
    }

  | _tag=DOLLAR IDENT LPAREN string_list_virg imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
        { loc = Loc.create $loc
        ; comments = Comments.make ~attached_to:($startpos(_tag))
        ; call =
            External_block
              { name = $2
              ; method_name = None
              ; method_name_is_quoted = false
              ; external_arguments = $4
              ; output_size = Inferred
              }
        ; inputs = $5
        ; outputs = []
        }
      }

  | _tag=DOLLAR IDENT POINT IDENT LPAREN string_list_virg imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
        { loc = Loc.create $loc
        ; comments = Comments.make ~attached_to:($startpos(_tag))
        ; call =
          External_block
           { name = $2
           ; method_name = Some $4
           ; method_name_is_quoted = false
           ; external_arguments = $6
           ; output_size = Inferred
           }
        ; inputs = $7
        ; outputs = []
        }
      }

  | _tag=DOLLAR IDENT POINT STRING LPAREN string_list_virg imbriq_list RPAREN POINT_VIRG
      { Bopkit.Control_structure.Node
         { loc = Loc.create $loc
         ; comments = Comments.make ~attached_to:($startpos(_tag))
         ; call =
           External_block
            { name = $2
            ; method_name = Some $4
            ; method_name_is_quoted = true
            ; external_arguments = $6
            ; output_size = Inferred
            }
         ; inputs = $7
         ; outputs = []
         }
      }

  | _hd=FOR IDENT EGAL expr_arith TO expr_arith liste_noeud END _tl=FOR POINT_VIRG
    { Bopkit.Control_structure.For_loop
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; ident = $2
        ; left_bound = $4
        ; right_bound = $6
        ; nodes = $7
        }
    }

  | _hd=FOR IDENT EGAL expr_arith liste_noeud END _tl=FOR POINT_VIRG
    { Bopkit.Control_structure.For_loop
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; ident = $2
        ; left_bound = $4
        ; right_bound = $4
        ; nodes = $5
        }
     }

  | _hd=IF expr_bool THEN liste_noeud _el=ELSE liste_noeud END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.make ~attached_to:($startpos(_el))
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_cond = $2
        ; then_nodes = $4
        ; else_nodes = $6
        }
    }

  | _hd=IF expr_bool THEN liste_noeud END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.none
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_cond = $2
        ; then_nodes = $4
        ; else_nodes = []
        }
    }

  | _hd=IF expr_arith THEN liste_noeud _el=ELSE liste_noeud END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.make ~attached_to:($startpos(_el))
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_cond = CONST $2
        ; then_nodes = $4
        ; else_nodes = $6
        }
    }

  | _hd=IF expr_arith THEN liste_noeud END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.none
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_cond = CONST $2
        ; then_nodes = $4
        ; else_nodes = []
        }
    }
;

string_list_virg :
  |                              { [] }
  | STRING                       { [$1] }
  | STRING VIRG string_list_virg { $1::$3 }
;

%public variables_list:
    LPAREN arguments RPAREN                            { $2 }
  | arguments                                          { $1 }
;

arguments:
  |                                                    { [] }
  | argument                                           { [$1] }
  | argument VIRG arguments                            { $1::$3 }
;

%public argument:
  | IDENT
    { Signal { name = $1 } }
  | IDENT indexation_list
    { Bus
        { loc = Loc.create $loc
        ; name = $1
        ; indexes = $2
        }
    }
;

%public indexation_list:
  | indexation                                         { [$1] }
  | indexation indexation_list                         { $1::$2 }
;

indexation:
  | DEUX_POINTS LCROCHET expr_arith RCROCHET           { Segment $3 }
  | LCROCHET expr_arith POINTPOINT expr_arith RCROCHET { Interval ($2, $4) }
  | LCROCHET expr_arith RCROCHET                       { Index $2 }
;

imbriq_list:
  |                                                    { [] }
  | imbriq                                             { [$1] }
  | imbriq VIRG imbriq_list                            { $1::$3 }
;

output_size:
  | LCROCHET expr=expr_arith RCROCHET { Specified expr }
  | { Inferred }
;

%public imbriq:
  | variable=argument
    { Variables
      { loc = Loc.create $loc(variable)
      ; comments = Comments.make ~attached_to:($startpos(variable))
      ; variables = [ variable ]
      }
    }

  | _d=LPAREN variables=arguments RPAREN
    { Variables
      { loc = Loc.create $loc(variables)
      ; comments = Comments.make ~attached_to:($startpos(_d))
      ; variables
      }
    }

  | _d=token_external output_size=output_size LPAREN command=STRING RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(_d))
       ; call = Pipe { command; output_size }
       ; inputs = []
       }
    }

  | _d=token_external output_size=output_size LPAREN command=STRING VIRG inputs=imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(_d))
       ; call = Pipe { command; output_size }
       ; inputs
       }
    }

  | _d=DOLLAR name=IDENT output_size=output_size LPAREN external_arguments=string_list_virg inputs=imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(_d))
       ; call =
         External_block
           { name
           ; method_name = None
           ; method_name_is_quoted = false
           ; external_arguments
           ; output_size
           }
       ; inputs
       }
    }

  | _d=DOLLAR name=IDENT POINT method_name=IDENT output_size=output_size LPAREN external_arguments=string_list_virg inputs=imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(_d))
       ; call =
         External_block
           { name
           ; method_name = Some method_name
           ; method_name_is_quoted = false
           ; external_arguments
           ; output_size
           }
        ; inputs
        }
    }

  | _d=DOLLAR name=IDENT POINT method_name=STRING output_size=output_size LPAREN external_arguments=string_list_virg inputs=imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(_d))
       ; call =
         External_block
           { name
           ; method_name = Some method_name
           ; method_name_is_quoted = true
           ; external_arguments
           ; output_size
           }
       ; inputs
       }
    }

  | sucre_gnd_vdd { $1 }

  | name=ident_point_option arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(name))
       ; call = Block { name; arguments = []; functional_arguments = $2 }
       ; inputs = $4
       }
    }

  | name=IDENT indexation_list arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(name))
       ; call =
           Block
             { name
             ; arguments = Syntax_util.parse_filter_call name $2
             ; functional_arguments = $3
             }
       ; inputs = $5
       }
    }

  | name=ident_point indexation_list arguments_fonctionnels_effectifs_option LPAREN imbriq_list RPAREN
    { Nested_node
       { loc = Loc.create $loc
       ; comments = Comments.make ~attached_to:($startpos(name))
       ; call =
          Block
            { name
            ; arguments = Syntax_util.parse_filter_call name $2
            ; functional_arguments = $3
            }
       ; inputs = $5
       }
    }
;

sucre_gnd_vdd:
  | INT
    { match $1 with
      | ( 0 | 1 ) as bit ->
        Nested_node
          { loc = Loc.create $loc
          ; comments = Comments.none
          ; call =
              Block
                { name = (if bit = 0 then "gnd" else "vdd")
                ; arguments = []
                ; functional_arguments = []
                }
          ; inputs = []
          }
      | _ -> raise Parsing.Parse_error
    }
  | LEX_SUB INT // Sucre syntaxique pour vdd (-1)
    { match $2 with
      | 1 ->
        Nested_node
          { loc = Loc.create $loc
          ; comments = Comments.none
          ; call = Block { name = "vdd"; arguments = []; functional_arguments = [] }
          ; inputs = []
          }
      | _ -> raise Parsing.Parse_error
    }
;

sucre_gnd_vdd_list:
  | sucre_gnd_vdd                                      { [$1] }
  | sucre_gnd_vdd VIRG sucre_gnd_vdd_list              { $1::$3 }
;

