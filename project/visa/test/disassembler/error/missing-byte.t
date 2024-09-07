Some visa instructions are encoded on 1 byte, some on 2 bytes. It is invalid for
an instruction that expects to be encoded on 2 bytes not to followed by its
second part.

  $ visa disassemble missing-byte.bin
  File "missing-byte.bin", line 1, characters 0-8:
  1 | 00010000
      ^^^^^^^^
  Error: Invalid executable.
  Operation 'Jmp' is expected to be followed by another byte.
  [123]
