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
SLEEP:sleep
minus 255

    // Comments'margin is correctly auto-formatted
store R0, var
jmp @SLEEP
