// At the moment, labels in macro are not allowed in the syntax. Their
// use is likely problematic because using the macro twice would yield
// an invalid program due to the duplicated label.
macro var x
  LABEL: sleep
  load $x, R0
end
var #1
jpm @LABEL
