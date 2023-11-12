The files in this directory are not auto-formatted. We test here
indeed the auto-formatting, as well as syntax errors that we desire to
monitor in tests.

  $ visa fmt test
  ================================: comments-at-end-of-line.asm
  File "comments-at-end-of-line.asm", line 2, characters 14-14: syntax error.
  ================================: comments-in-macro.asm
  File "comments-in-macro.asm", line 4, characters 2-2: syntax error.
  ================================: label-in-macro.asm
  File "label-in-macro.asm", line 5, characters 7-7: syntax error.
  ================================: multiple-empty-lines.asm
  // Comments in their own lines are supported
  define var 42
  
  
  // Passing several lines is currently not reduced.
  macro minus x
    load $x, R0
    not R0
    load #1, R1
    add
  end
  
  
  nop
  SLEEP:
    sleep
    minus 255
  
    // Comments'margin is correctly auto-formatted
    store R0, var
    jmp @SLEEP
