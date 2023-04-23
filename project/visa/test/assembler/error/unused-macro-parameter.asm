macro var x, y
  load $x, R0
end
START:
  sleep
  var #1, R1
  jmp @START
