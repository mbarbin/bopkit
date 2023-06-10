  $ cat minus.asm
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

  $ visa assemble minus.asm | tee minus.bin
  00110000
  11100000
  01100000
  00111000
  10000000
  01000000
  00100000
  00111000
  11110000
  01000000
  11011000
  00000001
  00110000
  10011100
  01100000
  00111000
  10000000
  01000000
  00100000
  00111000
  10011101
  01000000
  11011000
  10000001

  $ visa disassemble minus.bin
  load #7, R0
  not R0
  load #1, R1
  add
  swc
  load #15, R1
  add
  write R1, 0
  load #57, R0
  not R0
  load #1, R1
  add
  swc
  load #185, R1
  add
  write R1, 1

  $ touch minus-initial-memory.txt

  $ bopkit simu visa.bop \
  >   -parameter 'Executable=minus.bin' \
  >   -parameter 'InitialMemory=minus-initial-memory.txt' \
  >   -num-cycles 120 \
  >   -output-only-on-change \
  > | cut -c 1-16
  0000000000000000
  0001000000000000
  0001000000000001

  $ visa run minus.asm -stop-after-n-outputs 2 | cut -c 1-16
  0001000000000000
  0001000000000001
