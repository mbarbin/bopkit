The files in this directory are not auto-formatted. We test here
indeed the auto-formatting, as well as syntax errors that we desire to
monitor in tests.

  $ bopkit process fmt test
  ================================: comments-and-newlines.bpp
  // Empty lines at the top
  // And in the middle of the file
  // Hello
  input x, y
    // Empty lines in the body of the block
    // Here?
    t = x /\ y
  output t
  // This is a comment
  ================================: comments.bpp
  // This is comment A
  // This is comment B
  input x, y
    // This is comment C
    t = x /\ y
    q = x + t
    // This is comment F
    p = q - 4
  output p
  // This is comment G
  // This is comment H
  ================================: invalid-comment.bpp
  File "invalid-comment.bpp", line 5, characters 0-0: syntax error.
  ================================: syntax-error.bpp
  File "syntax-error.bpp", line 5, characters 10-10: syntax error.
