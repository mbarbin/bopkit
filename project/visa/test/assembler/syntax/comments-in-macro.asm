// Comments in their own lines are supported
define var 42
macro minus x
  // At the moment comments in macro are not supported
  load $x, R0
  not R0
  load #1, R1
  add
end
nop
SLEEP:sleep
minus 255
store R0, var
jmp @SLEEP
