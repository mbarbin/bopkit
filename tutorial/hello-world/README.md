# Hello world

## Hello circuit

This example shows a minimalist circuit with a single gate, to get introduced to
the bopkit simulator.

<!-- $MDX file=hello.bop -->
```bopkit
/**
 * A tiny circuit defining a block called "Hello", with 2 inputs [a], [b] and 1
 * output [s]. [And] is a primitive of the language.
 */
Hello(a, b) = s
where
  s = And(a, b);
end where;
```

### Simulation

To simulate the file, run:

```sh
$ bopkit simu hello.bop
   Cycle | a b | s
```

The default behavior of the simulator is to read inputs on `stdin`. Here the
circuits expects 2 signals, so the simulator will expect input lines of length
2, made of the characters '0' and '1'. For example

```sh
$ echo '01' | bopkit simu hello.bop
   Cycle | a b | s
       0 | 0 1 | 0
```

### Piping an input

To run through more inputs, you may pipe on stdin a program that generates valid
input lines. You can do so using the `bopkit counter` command.

```sh
$ bopkit counter -N 2 -ni -c 4
00
10
01
11
```

This invocation means : print the output of a counter on 2 bits, for 4 cycles,
and then stops. You may connect these applications using:

```sh
$ bopkit counter -N 2 -ni -c 4 | bopkit simu hello.bop
   Cycle | a b | s
       0 | 0 0 | 0
       1 | 1 0 | 0
       2 | 0 1 | 0
       3 | 1 1 | 1
```

### Built-in counter input

Testing circuits with a counter is common, so there's a built-in option in `bopkit
simu` that will do the equivalent of this. Try with the following:

```sh
$ bopkit simu hello.bop -n 8 -counter-input
   Cycle | a b | s
       0 | 0 0 | 0
       1 | 1 0 | 0
       2 | 0 1 | 0
       3 | 1 1 | 1
       4 | 0 0 | 0
       5 | 1 0 | 0
       6 | 0 1 | 0
       7 | 1 1 | 1
```

One nice thing about this option, is that you don't have to worry about the
input width from the command line, `bopkit simu` will automatically instantiate
a counter of the right size, depending on the width of the circuit's input.

## Hello stdlib

Below is a small circuit that expects an input of width 3. It makes use of
Bopkit's standard library. Let's check it out:

<!-- $MDX file=hello-stdlib.bop -->
```bopkit
#include <stdlib.bop>

/**
 * A tiny circuit defining a block called "Hello", with 3 inputs [a], [b], [c]
 * and 1 output [s].
 *
 * [And] is extended in <stdlib.bop> to accept an extra parameter, so it can be
 * used with a greater number of arguments. To be able to use it, we simply added
 * the line above to include the stdlib.
 */
Hello(a, b, c) = s
where
  s = And[3](a, b, c);
end where;
```

### Simulation

We've just seen the option `counter-input`. You can also specify the number of
counter rounds you want to simulate, rather than the actual number of cycles.

Let's try that on `hello-stdlib.bop`:

```sh
$ bopkit simu hello-stdlib.bop -num-counter-cycles 2
   Cycle | a b c | s
       0 | 0 0 0 | 0
       1 | 1 0 0 | 0
       2 | 0 1 0 | 0
       3 | 1 1 0 | 0
       4 | 0 0 1 | 0
       5 | 1 0 1 | 0
       6 | 0 1 1 | 0
       7 | 1 1 1 | 1
       8 | 0 0 0 | 0
       9 | 1 0 0 | 0
      10 | 0 1 0 | 0
      11 | 1 1 0 | 0
      12 | 0 0 1 | 0
      13 | 1 0 1 | 0
      14 | 0 1 1 | 0
      15 | 1 1 1 | 1
```
