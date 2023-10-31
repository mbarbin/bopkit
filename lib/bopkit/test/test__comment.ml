let%expect_test "categorise" =
  let test text =
    match Comment.parse text with
    | None -> print_string "not-a-comment"
    | Some t ->
      let rendering = Comment.render t in
      List.iter rendering ~f:print_endline;
      let t2 = Comment.parse_exn (String.concat ~sep:"\n" rendering) in
      if not (Comment.equal t t2)
      then
        raise_s
          [%sexp
            "Comment does not round trip", [%here], { t : Comment.t; t2 : Comment.t }]
  in
  test "";
  [%expect {| not-a-comment |}];
  test "/";
  [%expect {| not-a-comment |}];
  test "//";
  [%expect {| // |}];
  test "// Hey";
  [%expect {| // Hey |}];
  test "//Hey*/";
  [%expect {| // Hey*/ |}];
  test "/*/Hey*/";
  [%expect {|
    /* /Hey
     */ |}];
  test
    {|
// This starts like a comment
But then it has another line which is not part of a comment
|};
  [%expect {| not-a-comment |}];
  test "/*/";
  [%expect {| not-a-comment |}];
  test "/**/";
  [%expect {| /* */ |}];
  test "/***/";
  [%expect {|
    /**
     */ |}];
  test "/* */";
  [%expect {|
    /* */ |}];
  test "/** */";
  [%expect {|
    /**
     */ |}];
  test "/* A one line with the enclosing syntax of multiple lines comment */";
  [%expect
    {|
    /* A one line with the enclosing syntax of multiple lines comment
     */ |}];
  test "/** A documentation comment that fits on 1 line. */";
  [%expect {|
    /**
     * A documentation comment that fits on 1 line.
     */ |}];
  test
    {|
/*Some
      multiple line thing
  with non aligned text
              hello */
|};
  [%expect
    {|
    /* Some
     * multiple line thing
     * with non aligned text
     * hello
     */ |}];
  test {|
/**
 * This is some documentation comment
 * That is already rendered.
 */
|};
  [%expect
    {|
    /**
     * This is some documentation comment
     * That is already rendered.
     */ |}];
  test
    {|
/**
  * This is some documentation comment
  * That is already rendered sligthly differently.
  */
|};
  [%expect
    {|
    /**
     * This is some documentation comment
     * That is already rendered sligthly differently.
     */ |}];
  test {|
/* This is some non documentation comment
 * That is already rendered.
 */
|};
  [%expect
    {|
    /* This is some non documentation comment
     * That is already rendered.
     */ |}];
  test
    {|
/* This is some non documentation comment
 * That is already rendered sligthly differently. */
|};
  [%expect
    {|
    /* This is some non documentation comment
     * That is already rendered sligthly differently.
     */ |}];
  test
    {|
/**
 * This is some documentation comment
 *
 *
 * It has some empty lines in it.
 *
 * Including one at the end:
 *
 */
|};
  [%expect
    {|
    /**
     * This is some documentation comment
     *
     *
     * It has some empty lines in it.
     *
     * Including one at the end:
     */ |}];
  test
    {|
/*
 * This is some non-documentation comment
 *
 *
 * It has some empty lines in it.
 *
 * Including one at the end:
 *
 */
|};
  [%expect
    {|
    /* This is some non-documentation comment
     *
     *
     * It has some empty lines in it.
     *
     * Including one at the end:
     */ |}];
  (* Tests related to trailing whitespaces. *)
  test "//   A comment with whitespaces at the end of it.            ";
  [%expect {| // A comment with whitespaces at the end of it. |}];
  test
    {|
/*
 * A multiline comment    
 * With trailing whitespaces also        
 *
 */
|};
  [%expect {|
    /* A multiline comment
     * With trailing whitespaces also
     */ |}];
  (* Tests related to letting the user do some preformatting, with |
     guidline syntax. *)
  test
    {|
/* So, because the leading whitespace are stripped,
 * if someone is trying to write things with alignment,
 * it won't work.
 *
 *     Check     out      this
 *               for      example.
 */
|};
  [%expect
    {|
    /* So, because the leading whitespace are stripped,
     * if someone is trying to write things with alignment,
     * it won't work.
     *
     * Check     out      this
     * for      example.
     */ |}];
  test
    {|
/* However, it is enough to prefix these lines by a '|' character
 * to preserve the original alignment of the content. Such as done
 * here:
 *
 * |     Check     out      this
 * |               for      example.
 */
|};
  [%expect
    {|
    /* However, it is enough to prefix these lines by a '|' character
     * to preserve the original alignment of the content. Such as done
     * here:
     *
     * |     Check     out      this
     * |               for      example.
     */ |}];
  test {|
/// Single line comments can be documentation comments too!
|};
  [%expect {| /// Single line comments can be documentation comments too! |}];
  ()
;;
