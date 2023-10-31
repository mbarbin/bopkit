module T = struct
  type key = string

  type t =
    { name : string
    ; parents : string list
    }

  let key t = t.name
  let parents t ~error_log:_ = Appendable_list.of_list t.parents
end

let%expect_test "sort" =
  let test nodes =
    Error_log.For_test.report (fun error_log ->
      let nodes =
        List.map
          (Bopkit_topological_sort.sort (module T) (module String) nodes ~error_log)
          ~f:(fun node -> node.name)
      in
      print_s [%sexp (nodes : string list)];
      Ok ())
  in
  test [];
  [%expect {| () |}];
  test [ { name = "a"; parents = [] } ];
  [%expect {| (a) |}];
  test [ { name = "a"; parents = [ "b" ] } ];
  [%expect {| (a) |}];
  test
    [ { name = "a"; parents = [ "b" ] }
    ; { name = "b"; parents = [] }
    ; { name = "c"; parents = [ "a" ] }
    ];
  [%expect {| (b a c) |}];
  test
    [ { name = "a"; parents = [ "b" ] }
    ; { name = "b"; parents = [ "c" ] }
    ; { name = "e"; parents = [ "f" ] }
    ; { name = "c"; parents = [ "a" ] }
    ; { name = "f"; parents = [] }
    ];
  [%expect {| (c b a f e) |}];
  test
    [ { name = "a"; parents = [ "b" ] }
    ; { name = "a"; parents = [] }
    ; { name = "b"; parents = [] }
    ; { name = "c"; parents = [ "a" ] }
    ];
  [%expect {| (a b c) |}];
  ()
;;
