Checking that bop2c handles Registers correctly.

The input of the circuit is an enable bit, connected to the registers that have
one.

First, let's see what happens, if this enable is always false.

  $ ./hello_register.exe <<EOF
  > 0
  > 0
  > 0
  > 0
  0101
  1001
  0101
  1001

Then, let's see what happens, if this enable is always true.

  $ ./hello_register.exe <<EOF
  > 1
  > 1
  > 1
  > 1
  0101
  1010
  0101
  1010

We alternate, sometimes enabling, sometimes not.

  $ ./hello_register.exe <<EOF
  > 0
  > 1
  > 1
  > 0
  > 0
  > 1
  > 1
  > 1
  0101
  1001
  0110
  1001
  0101
  1001
  0110
  1001
