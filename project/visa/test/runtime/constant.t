  $ cat constant.asm
  // Constants can be addresses or values. Let's check it out!
  define a 0
  define b 1
  define one #1
  define two #2
  define four #4
  
  // a <- one + two
  load one, R0
  load two, R1
  add
  store R1, a
  
  // b <- one + two + three
  load four, R0
  add
  store R1, b
  
  // export the values computed to the output device
  load a, R0
  load b, R1
  write R0, 0
  write R1, 1

  $ visa assemble constant.asm | tee constant.bin
  00110000
  10000000
  00111000
  01000000
  01000000
  11011000
  00000000
  00110000
  00100000
  01000000
  11011000
  10000000
  00110100
  00000000
  00111100
  10000000
  11010000
  00000001
  11011000
  10000001

  $ visa disassemble constant.bin
  load #1, R0
  load #2, R1
  add
  store R1, 0
  load #4, R0
  add
  store R1, 1
  load 0, R0
  load 1, R1
  write R0, 0
  write R1, 1

  $ touch constant-initial-memory.txt

  $ bopkit simu visa.bop \
  >   --parameter 'Executable=constant.bin' \
  >   --parameter 'InitialMemory=constant-initial-memory.txt' \
  >   --num-cycles 120 \
  >   --output-only-on-change \
  > | cut -c 1-16
  0000000000000000
  1100000000000000
  1100000011100000

  $ visa run constant.asm --stop-after-n-outputs 2 | cut -c 1-16
  1100000000000000
  1100000011100000
