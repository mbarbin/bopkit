open! Or_error.Let_syntax

let%expect_test "return Ok" =
  Error_log.For_test.report (fun error_log ->
    ignore (error_log : Error_log.t);
    return ());
  [%expect {||}];
  ()
;;

let%expect_test "return Error" =
  Error_log.For_test.report (fun error_log ->
    ignore (error_log : Error_log.t);
    Or_error.error_s [%sexp "Error message"]);
  [%expect {|
    "Error message"
    [1] |}];
  ()
;;

let%expect_test "raise" =
  let loc = Loc.in_file_at_line ~filename:"my-file.ext" ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.raise
      error_log
      ~loc
      [ Pp.textf "This is an error with some %s message." "error"
      ; Pp.textf "Unbound value 'vra'"
      ]
      ~hints:
        (Pp.text "And some hints too"
         :: Error_log.did_you_mean "vra" ~candidates:[ "var"; "hello"; "world" ]));
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Error: This is an error with some error message.
    Unbound value 'vra'
    Hint: And some hints too
    Hint: did you mean var?
    [1] |}];
  ()
;;

let%expect_test "error" =
  let loc = Loc.in_file_at_line ~filename:"my-file.ext" ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.error
      error_log
      ~loc:(Loc.in_file_at_line ~filename:"my-file.ext" ~line:1)
      [ Pp.textf
          "Error log allows you to report several errors if you want to, rather than \
           stopping the execution at the first one."
      ];
    Error_log.error
      error_log
      ~loc
      [ Pp.textf "This is an error with some %s message." "error"
      ; Pp.textf "Unbound value 'vra'"
      ]
      ~hints:
        (Pp.text "And some hints too"
         :: Error_log.did_you_mean "vra" ~candidates:[ "var"; "hello"; "world" ]);
    return ());
  [%expect
    {|
    File "my-file.ext", line 1, characters 0-0:
    Error: Error log allows you to report several errors if you want to, rather
    than stopping the execution at the first one.
    File "my-file.ext", line 3, characters 0-0:
    Error: This is an error with some error message.
    Unbound value 'vra'
    Hint: And some hints too
    Hint: did you mean var?
    [1] |}];
  ()
;;

let%expect_test "warning" =
  let loc = Loc.in_file_at_line ~filename:"my-file.ext" ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.warning
      error_log
      ~loc
      [ Pp.textf "This is an warning with some %s message." "warning"
      ; Pp.textf "Unbound value 'vra'"
      ]
      ~hints:
        (Pp.text "And some hints too"
         :: Error_log.did_you_mean "vra" ~candidates:[ "var"; "hello"; "world" ]);
    return ());
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Warning: This is an warning with some warning message.
    Unbound value 'vra'
    Hint: And some hints too
    Hint: did you mean var? |}];
  ()
;;
