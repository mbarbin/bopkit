# Division with bopkit bdd

## Overview

In this example, we use an external block written in OCaml to implement the
division operation between two operands. This block generates a truth table,
where the output for the division by zero is either set to 0, or left
unspecified and marked as * in the files.

Using `bopkit bdd`, we process the generated truth tables and use dune tests to
monitor the resulting circuits. We analyze the number of gates present in the
circuits and compare the reduction in the number of gates when division by zero
is left unspecified versus when it is set to 0.

To see all the files of this tutorial, check out the source code on GitHub at
https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division.

## Generating the truth tables

We have defined an external block in the file
[div.ml](https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division/div.ml).
It's an OCaml program that implements the division operation between two
operands on N bits.

### Via a circuit

We've defined a circuit that fixes the width of the operands and calls the
external block:

<!-- $MDX file=generate.bop -->
```bopkit
#define N 4

Main(a:[N], b:[N]) = s:[N]
where
  // We use the external block to compute the truth table of the division.
  s:[N] = external("./div.exe -N %{N}", a:[N], b:[N]);
end where;
```

<details>
<summary>
We can simulate this circuit to generate the truth table of `div.exe`.
</summary>

```sh
$ bopkit simu generate.bop -num-counter-cycle 1 -o | tail -n 20
0000
0000
1000
1000
0000
0000
0000
0000
0000
0000
0000
0000
0000
0000
0000
0000
0000
0000
0000
1000
```

</details>

### Via the command line

Because this circuit is really only connecting its input into the external
block, we can pipe a counter input directly into the external block to achieve
the same result. That's actually what we do to generate the image with the
partial specification, implemented in the external block
[div_opt.ml](https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division/div_opt.ml).

#### [div.txt](https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division/div.txt)

```sh
$ bopkit counter -ni -c 256 -N 8 | ./div.exe -N 4 | wc -l
256
```

#### [div_opt.txt](https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division/div_opt.txt)

```sh
$ bopkit counter -ni -c 256 -N 8 | ./div_opt.exe -N 4 | wc -l
256
```

## Synthesizing the circuits

Next we synthesize the circuits from the truth tables. The circuits are kind of
lengthy, so we only show the headers below. The header indicates the number of
gates in the circuit. `div_opt.txt` is the table that has the unspecified bits
when dividing by zero.

### [div.bop](https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division/div.bop)

```sh
$ bopkit bdd synthesize -AD 8 -WL 4 -f div.txt | head -n 5
// Block synthesized by bopkit from "div.txt"
// Gate count: [1020|197|67] (6.569 %)

Bloc(a:[8]) = out:[4]
where
```

### [div_opt.bop](https://github.com/mbarbin/bopkit/tree/main/tutorial/bdd/division/div_opt.bop)

```sh
$ bopkit bdd synthesize -AD 8 -WL 4 -f div_opt.txt | head -n 5
// Block synthesized by bopkit from "div_opt.txt"
// Gate count: [1020|185|62] (6.078 %)

Bloc(a:[8]) = out:[4]
where
```

As you can see, there's a little decrease in number of gates used to synthesize
the second circuit (from 67 down to 62). That's not much differences compared to
the theoretical reduction in size from a complete circuit that would implement
that truth table without any signal sharing (theoretical number of 1020 gates as
shown in the header).

## Simulating it all

We've written a circuit that checks different implementations for the division, namely:

- Via an external block in OCaml (the one we used to generate the truth table)
- Via a ROM memory initialized with that truth table
- Via the synthesized block from the full specification
- Via the synthesized block from the partial specification

In addition to showcasing different things in this tutorial, it's a great test
case for bopkit!

<details>
<summary>
Checkout the contents of the full file divcheck.bop
</summary>

<!-- $MDX file=divcheck.bop -->
```bopkit
// A first candidate: the bdd block synthesized from the complete specification.
#include "div.bop"

#define N 4

// A second candidate: a ROM memory that imports the truth table directly.
ROM div (8, 4) = file("div.txt")

// An external block from which we'll use the [test] method for unit testing
// the different means of computing the division.
external div "./div.exe -N %{N}"
  def test "test"
end external;

Main(a:[N], b:[N]) = (s_reference:[4], s_rom:[4], s_bdd:[4], s_bdd_star:[4])
where
  // The reference result coming from the OCaml block.
  s_reference:[N] = $div(a:[N], b:[N]);

  // Via the ROM memory
  s_rom:[N] = rom_div(a:[N], b:[N]);

  // Via the bdd
  s_bdd:[N] = Bloc(a:[N], b:[N]);

  // Via the bdd with partial specification
  s_bdd_star:[N] = external("bopkit simu div_opt.bop -p", a:[N], b:[N]);

  // We test all results with the external block method [test].
  $div.test(a:[N], b:[N], s_rom:[N]);
  $div.test(a:[N], b:[N], s_bdd:[N]);
  $div.test(a:[N], b:[N], s_bdd_star:[N]);
end where;
```

</details>

Let's look at the first 20 lines of that simulation. That's particularly
interesting since the beginning of the counter input assigns 0 for the value of
`b` ( the second operand), so we're effectively dividing `a` by zero.

As you can see from lines 8-15, the synthesized block from the partial
specification has taken the liberty of returning a `1` in its output, contrary
to the other implementations. This does not cause the simulation to fail, since
the `test` method ignores the results when dividing by zero.

```sh
$ bopkit simu divcheck.bop -num-counter-cycles 1 | head -n 20
   Cycle | a[0] a[1] a[2] a[3] b[0] b[1] b[2] b[3] | s_reference[0] s_reference[1] s_reference[2] s_reference[3] s_rom[0] s_rom[1] s_rom[2] s_rom[3] s_bdd[0] s_bdd[1] s_bdd[2] s_bdd[3] s_bdd_star[0] s_bdd_star[1] s_bdd_star[2] s_bdd_star[3]
       0 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       1 | 1 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       2 | 0 1 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       3 | 1 1 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       4 | 0 0 1 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       5 | 1 0 1 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       6 | 0 1 1 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       7 | 1 1 1 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
       8 | 0 0 0 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
       9 | 1 0 0 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      10 | 0 1 0 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      11 | 1 1 0 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      12 | 0 0 1 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      13 | 1 0 1 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      14 | 0 1 1 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      15 | 1 1 1 1 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
      16 | 0 0 0 0 1 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      17 | 1 0 0 0 1 0 0 0 | 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0
      18 | 0 1 0 0 1 0 0 0 | 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0
```
