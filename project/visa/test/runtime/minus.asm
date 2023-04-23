// Define a macro that computes [a - b] and stores the result into R1
macro minus a, b
  load $b, R0
  not R0
  load #1, R1
  add
  swc
  load $a, R1
  add
end

// Invoke the minus macro with some parameters
minus #15, #7
// Export the result to the output-device at address 0
write R1, 0

// Invoke the minus macro with other parameters
minus #185, #57
// Export the result to the output-device at address 1
write R1, 1
