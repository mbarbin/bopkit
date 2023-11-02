# Bopkit Language Reference

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/bopkit-language-reference.png?raw=true"
    width='384'
    alt="Logo"
  />
</p>

This part of the documentation describes the syntax and the semantics of the netlist language used in bopkit to describe digital synchronous circuits.

:::danger

This section of the doc is a work in progress and is unstable and incomplete.

:::

## Circuit files: *.bop

Circuit definitions are expected to be located in files with extension
`.bop`. A circuit may be broken down into multiple files, which will be assembled to construct a final design.

The language has a few primitives, however it is likely that for any non trivial
project you'll need to refer and include files from bopkit's stdlib.

### Circuit file structure

A bopkit file is composed of 5 sections, which are all optional but must
necessarily be in the following order:

- [includes](includes.md)
- [parameters](parameters.md)
- [memories](memories.md)
- [external blocks](external-blocks.md)
- [blocks](blocks.md)

:::warning

Having the sections out of order will cause a syntax error.

:::

We show below an example file that has exactly 1 element for each of the 5
sections, plus some comments.

The reference for each of the section is located in subsequent pages.

<!-- $MDX file=one-of-each.bop -->
```bopkit
/// This file makes use of the stdlib, so it has the following include line.
#include <stdlib.bop>

/// For the sake of the example, this file depends on a parameter named N.
/// It's an integer and sets the width of the bus that this circuit works with.
#define N 4

/**
 * This circuit makes use of a ROM memory. This specific ROM has 4 words of data
 * of size N. So, its addresses are encoded on 2 bits, and its word width is equal
 * to N. It is initialized in place using the [text] construct.
 */
ROM mem (2, N) = text { 0010 1100 1010 0101 }

/**
 * For the sake of the example, we make use of an external block here. An
 * external block allows a circuit to depends on circuit components that are
 * implemented by third party applications, which should read inputs from stdin,
 * and write outputs to stdout. Here we use an external block based on the [cat]
 * unix util, so it's an external block that returns its input bits unchanged.
 */
external cat "cat"

/**
 * Finally, we introduce an actual block to describe the circuit. The final
 * block present in the file is the circuit's main block, which serves as an entry
 * point. For this demo circuit, we implemented a block that takes 2 bits as input
 * encoding a ROM address, reads the word that is located in its ROM memory at that
 * address, and pipe it through its [cat] external block before returning it.
 */
My_block(a:[2]) = b:[N]
where
  data:[N] = rom_mem(a:[2]);
  b:[N] = $cat(data:[N]);
end where;
```

We can go over a round of simulation with the following invocation:

```sh
$ bopkit simu one-of-each.bop -counter-input -num-counter-cycles 1
   Cycle | a[0] a[1] | b[0] b[1] b[2] b[3]
       0 | 0 0 | 0 0 1 0
       1 | 1 0 | 1 1 0 0
       2 | 0 1 | 1 0 1 0
       3 | 1 1 | 0 1 0 1
```

### Connectivity between blocks

The connectivity between the circuit blocks is represented by
[Signals and buses](signals-and-buses.md).
