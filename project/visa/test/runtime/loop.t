  $ cat loop.asm
  LOOP:
    load #1, R0
    add
    write R1, 0
    jmp @LOOP

  $ visa to-machine-code loop.asm | tee loop.bin
  00110000
  10000000
  01000000
  11011000
  00000001
  00010000
  00000000

  $ visa disassemble loop.bin
  0:
    load #1, R0
    add
    write R1, 0
    jmp @0

  $ touch loop-initial-memory.txt

  $ bopkit simu visa.bop \
  >   -parameter 'Executable=loop.bin' \
  >   -parameter 'InitialMemory=loop-initial-memory.txt' \
  >   -num-cycles 120 \
  >   -output-only-on-change \
  > | cut -c 1-5
  00000
  10000
  01000
  11000
  00100
  10100
  01100
  11100
  00010
  10010
  01010
  11010
  00110
  10110
  01110
  11110
  00001
  10001

  $ visa run loop.asm -stop-after-n-outputs 17 | cut -c 1-5
  10000
  01000
  11000
  00100
  10100
  01100
  11100
  00010
  10010
  01010
  11010
  00110
  10110
  01110
  11110
  00001
  10001
