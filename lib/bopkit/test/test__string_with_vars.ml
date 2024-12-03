let%expect_test "eval" =
  let test str parameters =
    let parameters =
      List.map parameters ~f:(fun (name, value) -> { Parameter.name; value })
    in
    let parsed = String_with_vars.parse str in
    print_s [%sexp (parsed : String_with_vars.Parts.t Or_eval_error.t)];
    match parsed with
    | Error _ -> ()
    | Ok t ->
      let s = String_with_vars.eval t ~parameters in
      print_s [%sexp (s : string Or_eval_error.t)]
  in
  test "" [];
  [%expect
    {|
    (Ok ((parts ())))
    (Ok "") |}];
  test "Hello" [];
  [%expect
    {|
    (Ok ((parts ((Text Hello)))))
    (Ok Hello) |}];
  test "Hello %N}" [];
  [%expect
    {|
    (Ok ((parts ((Text "Hello %N}")))))
    (Ok "Hello %N}") |}];
  test "Hello %(N)" [];
  [%expect
    {|
    (Ok ((parts ((Text "Hello %(N)")))))
    (Ok "Hello %(N)") |}];
  test "Hello %{N}" [ "Ni", Parameter.Value.Int 2 ];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  N)))))
    (Error (Free_variable (name N) (candidates (Ni)))) |}];
  test "Hello %{N}" [ "N", String "World" ];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  N)))))
    (Ok "Hello World") |}];
  test "%{N} Hello" [];
  [%expect
    {|
    (Ok ((
      parts (
        (Var  N)
        (Text " Hello")))))
    (Error (Free_variable (name N) (candidates ()))) |}];
  test "%{N}" [];
  [%expect
    {|
    (Ok ((parts ((Var N)))))
    (Error (Free_variable (name N) (candidates ()))) |}];
  test "%{}" [];
  [%expect
    {|
    (Error (Syntax_error (in_ %{}))) |}];
  test "%{V" [];
  [%expect
    {|
    (Error (Syntax_error (in_ %{V))) |}];
  test "Hello %V" [];
  [%expect
    {|
    (Ok ((parts ((Text "Hello %V")))))
    (Ok "Hello %V") |}];
  test "Hello }%V}" [];
  [%expect
    {|
    (Ok ((parts ((Text "Hello }%V}")))))
    (Ok "Hello }%V}") |}];
  test "Hello %{hey%{nest}bou}" [];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  hey%{nest)
        (Text bou})))))
    (Error (Free_variable (name hey%{nest) (candidates ()))) |}];
  test "Hello %{hey$(nest)bou}" [];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  "hey$(nest)bou")))))
    (Error (Free_variable (name "hey$(nest)bou") (candidates ()))) |}];
  ()
;;

(* Test for deprecated syntax. *)
let%expect_test "eval" =
  let test str parameters =
    let parameters =
      List.map parameters ~f:(fun (name, value) -> { Parameter.name; value })
    in
    let parsed = String_with_vars.parse str in
    print_s [%sexp (parsed : String_with_vars.Parts.t Or_eval_error.t)];
    match parsed with
    | Error _ -> ()
    | Ok t ->
      let s = String_with_vars.eval t ~parameters in
      print_s [%sexp (s : string Or_eval_error.t)]
  in
  test "" [];
  [%expect
    {|
    (Ok ((parts ())))
    (Ok "") |}];
  test "Hello" [];
  [%expect
    {|
    (Ok ((parts ((Text Hello)))))
    (Ok Hello) |}];
  test "Hello $(N)" [];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  N)))))
    (Error (Free_variable (name N) (candidates ()))) |}];
  test "Hello $(N)" [ "N", String "World" ];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  N)))))
    (Ok "Hello World") |}];
  test "$(N) Hello" [];
  [%expect
    {|
    (Ok ((
      parts (
        (Var  N)
        (Text " Hello")))))
    (Error (Free_variable (name N) (candidates ()))) |}];
  test "$(N)" [];
  [%expect
    {|
    (Ok ((parts ((Var N)))))
    (Error (Free_variable (name N) (candidates ()))) |}];
  test "$()" [];
  [%expect
    {|
    (Error (Syntax_error (in_ "$()"))) |}];
  test "$(V" [];
  [%expect
    {|
    (Error (Syntax_error (in_ "$(V"))) |}];
  test "Hello $V" [];
  [%expect
    {|
    (Ok ((parts ((Text "Hello $V")))))
    (Ok "Hello $V") |}];
  test "Hello )$V)" [];
  [%expect
    {|
    (Ok ((parts ((Text "Hello )$V)")))))
    (Ok "Hello )$V)") |}];
  test "Hello $(hey$(nest)bou)" [];
  [%expect
    {|
    (Ok ((
      parts (
        (Text "Hello ")
        (Var  "hey$(nest")
        (Text "bou)")))))
    (Error (Free_variable (name "hey$(nest") (candidates ()))) |}];
  ()
;;
