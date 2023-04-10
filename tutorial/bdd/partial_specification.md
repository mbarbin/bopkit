# Synthesizing a circuit from a partial specification

Let's go over a second example. This time, the function is only partially
specified. This means that some of the output bits have been left unspecified,
and are marked with the character '*'.

```sh
$ cat starred.txt
101*1*1
01011**
***1011
*010*11
```

This specification file has 4 words, so it could represent a memory of 2 bits of
address, but actually, let's interpret it as the partial specification for a
memory of 4 bits of address. In addition to the bits marked with '*', all the
remaining of the specification is interpreted as unspecified as well.

## Synthesis

Let's synthesize the circuit from this partial specification:

```sh
$ bopkit bdd synthesize -AD 4 -WL 7 -f starred.txt
// Block synthesized by bopkit from "starred.txt"
// Gate count: [105|8|6] (5.714 %)

Bloc(a:[4]) = out:[7]
with unused = a[2..3]
where
  s1 = not(a[0]);
  out[0] = s1;
  s2 = not(a[1]);
  s3 = mux(a[0], s2, 0);
  out[1] = s3;
  s4 = mux(a[0], a[1], 1);
  out[2] = s4;
  s5 = mux(a[0], s2, 1);
  out[3] = s5;
  s6 = mux(a[0], 1, s2);
  out[4] = s6;
  out[5] = 1;
  out[6] = 1;
end where;
```

## Testing the synthesized circuit with bopkit bdd checker

### Introducing bopkit bdd checker

This time we'll use a testing program to checks the result of the circuit.
That's what `bopkit bdd checker` is about!

```sh
$ bopkit bdd checker -help
external block

  bopkit bdd checker

This block takes in a BDD truth table, an address and a result. It checks
whether the result agrees with the truth table, and if not raises an
exception. It is meant to be used as unit-test in a bopkit simulation.

=== flags ===

  -AD N                      . number of bits of addresses
  -WL N                      . number of bits of output words
  -f FILE                    . the file to load
  [-c N]                     . stop at cycle N
  [-ni]                      . block will read no input
  [-no]                      . block will print no output
  [-verbose]                 . be more verbose
  [-help], -?                . print this help text and exit

```

Let's try it manually on an example - the first line of the truth table.

As a reminder this line is:

```sh
$ head -n 1 starred.txt
101*1*1
```

The first 4 bits will be the address of that first line (zero), followed by the
7 bits of the word we'd like to check:

```sh
$ echo '00001011101' | bopkit bdd checker -AD 4 -WL 7 -f starred.txt

```

Now let's try with an invalid input (an invalid bit at the very last position):

```sh
$ echo '00001011100' | bopkit bdd checker -AD 4 -WL 7 -f starred.txt
Conflict for bdd at addr '0000' (0)
Expected = '101*1*1'
Received = '1011100'
("External block exception" ((name bdd-checker) (index_cycle 1))
 ((line 00001011100))
 (TEST_FAILURE ((address 0000) (expected 101*1*1) (received 1011100))))
[1]
```

### Use bdd checker in a circuit

Now we'll plug the checker into a simulation, by connecting it as an external
block. See it done in this file:

<!-- $MDX file=check_starred.bop -->
```bopkit
// We include the file synthesized by `bopkit bdd`.
#include "starred.bop"

/**
 * FILENAME is the image file we had originally. We'll use it to check the
 * output of the circuit thanks to `bopkit bdd checker`.
 */
#define FILENAME "starred.txt"
#define AD 4
#define WL 7

Test(a:[AD]) = ()
where
  // Here we call the synthesized block via the #include which is at the
  // beginning of the file.
  block[1]:[WL] = Bloc(a:[AD]);

  // Here, just for fun we simulate the synthesized file with another call to
  // the simulator. This is equivalent to the call above. When using the simulator
  // in external blocks, the option [-p] must be added.
  block[2]:[WL] =
    external("bopkit simu starred-tree.bop -p 2>/dev/null", a:[AD]);

  // Here we check the result of both blocks with the bdd checker. It would
  // raise an exception and stops the simulation in case of an invalid result.
  for i = 1 to 2
    external("bopkit bdd checker -AD %{AD} -WL %{WL} -f %{FILENAME}",
      a:[AD],
      block[i]:[WL]);
  end for;
end where;
```

And now we just have to let the simulation run through a complete input cycle to
check it all.

```sh
$ bopkit simu check_starred.bop -num-counter-cycle 1
   Cycle | a[0] a[1] a[2] a[3] |
       0 | 0 0 0 0 |
       1 | 1 0 0 0 |
       2 | 0 1 0 0 |
       3 | 1 1 0 0 |
       4 | 0 0 1 0 |
       5 | 1 0 1 0 |
       6 | 0 1 1 0 |
       7 | 1 1 1 0 |
       8 | 0 0 0 1 |
       9 | 1 0 0 1 |
      10 | 0 1 0 1 |
      11 | 1 1 0 1 |
      12 | 0 0 1 1 |
      13 | 1 0 1 1 |
      14 | 0 1 1 1 |
      15 | 1 1 1 1 |
```

The command exited with code [0].
