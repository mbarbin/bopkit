%{
  open! Bopkit.Netlist
%}

%type <Bopkit.Netlist.external_block> bloc_externe

%%

%public bloc_externe:
  | _hd=EXTERNAL attributes=ident_list_option name=IDENT command=STRING
    { { loc = Loc.create $loc
      ; head_comments = Comments.make ~attached_to:($startpos(_hd))
      ; tail_comments = Comments.none
      ; name
      ; attributes
      ; api = []
      ; command
      }
    }
  | _hd=EXTERNAL attributes=ident_list_option name=IDENT command=STRING
      api=init_message_def_method_list
    END _tl=EXTERNAL POINT_VIRG
    { { loc = Loc.create $loc
      ; head_comments = Comments.make ~attached_to:($startpos(_hd))
      ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
      ; name
      ; attributes
      ; api
      ; command
      }
    }
;

init_message_def_method:
  | _d=INIT message=STRING
    { Bopkit.Control_structure.Node (
        Init_message
          { loc = Loc.create $loc
          ; comments = Comments.make ~attached_to:($startpos(_d))
          ; message
          }
      )
    }

  | _d=DEF attributes=ident_list_option method_name=STRING
    { Bopkit.Control_structure.Node (
        Method
          { loc = Loc.create $loc
          ; comments = Comments.make ~attached_to:($startpos(_d))
          ; method_name
          ; method_name_is_quoted = true
          ; attributes
          })
    }

  | _d=DEF attributes=ident_list_option method_name=IDENT
    { Bopkit.Control_structure.Node (
        Method
          { loc = Loc.create $loc
          ; comments = Comments.make ~attached_to:($startpos(_d))
          ; method_name
          ; method_name_is_quoted = false
          ; attributes
          })
    }

  | _hd=FOR ident=IDENT EGAL left_bound=expr_arith TO right_bound=expr_arith
      nodes=init_message_def_method_list
    END _tl=FOR POINT_VIRG
      { Bopkit.Control_structure.For_loop
          { loc = Loc.create $loc
          ; head_comments = Comments.make ~attached_to:($startpos(_hd))
          ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
          ; ident
          ; left_bound
          ; right_bound
          ; nodes
          }
      }

  | _hd=FOR ident=IDENT EGAL bound=expr_arith
      nodes=init_message_def_method_list
    END _tl=FOR POINT_VIRG
      { Bopkit.Control_structure.For_loop
          { loc = Loc.create $loc
          ; head_comments = Comments.make ~attached_to:($startpos(_hd))
          ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
          ; ident
          ; left_bound = bound
          ; right_bound = bound
          ; nodes
          }
      }

  | _hd=IF if_condition=expr_bool THEN
      then_nodes=init_message_def_method_list
    _el=ELSE
      else_nodes=init_message_def_method_list
    END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.make ~attached_to:($startpos(_el))
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_condition
        ; then_nodes
        ; else_nodes
        }
    }

  | _hd=IF if_condition=expr_bool THEN
      then_nodes=init_message_def_method_list
    END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.none
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_condition
        ; then_nodes
        ; else_nodes = []
        }
    }

  | _hd=IF const=expr_arith THEN
      then_nodes=init_message_def_method_list
    _el=ELSE
      else_nodes=init_message_def_method_list
    END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.make ~attached_to:($startpos(_el))
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_condition = CONST const
        ; then_nodes
        ; else_nodes
        }
    }

  | _hd=IF const=expr_arith THEN
      then_nodes=init_message_def_method_list
    END _tl=IF POINT_VIRG
    { Bopkit.Control_structure.If_then_else
        { loc = Loc.create $loc
        ; head_comments = Comments.make ~attached_to:($startpos(_hd))
        ; then_tail_comments = Comments.none
        ; tail_comments = Comments.make ~attached_to:($startpos(_tl))
        ; if_condition = CONST const
        ; then_nodes
        ; else_nodes = []
        }
    }
;

init_message_def_method_list:
  | list=list(init_message_def_method) { list }
;
