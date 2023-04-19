# Digital Watch

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/bopkit-digital-watch.png?raw=true"
    width='384'
    alt="Logo"
  />
</p>

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/digital-watch.png?raw=true"
    alt="Logo"
  />
</p>

This project implements a circuit with an output of 42 bits that drives the
display of the 7-segment digits of a digital watch.

## High-level description of the project

The aim of the project is to implement a bopkit circuit that can keep track of
the current time of day by incrementing counters. The output of the circuit is a
42-bit value that can be connected to a 7-segment display, which shows the
current time in the format of HH:MM:SS.

To visualize the output, we use a simulated 7-segment device implemented with
the OCaml Graphics library and connect it to the simulation using bopkit's
external construct.

Next, we convert the circuit to C using `bop2c` and repeat the simulation to
test the functionality of bop2c. The 7-segment display remains unchanged, but
the circuit is now run by a standalone native C application.

Finally, for some added fun, we connect the bopkit digital watch to a bopboard
and run a simulation where the time on the watch can be set by incrementing the
hours, minutes, and seconds dynamically using the push buttons on the board.

## The 7-segment digital watch display

The 7-segment watch display is an OCaml Graphics application. It is implemented
[here](https://github.com/mbarbin/bopkit/tree/main/stdlib/7-segment/src).

It is available in the command line as:

<!-- $MDX skip -->
```bash
$ bopkit digital-watch display
```

This opens up a OCaml Graphics window, and displays a 7-segment watch that looks
like the one in the screenshot included at the top of this page (the one with
the green digits).

The application expects 42 bits on stdin, and responds by a blank line on stdout
(this is the protocol for an external bopkit app of that interface).

You may try to feed a few inputs to play around with it. It's possible to use
7-segment to display some letters too!

<!-- $MDX skip -->
```bash
$ bopkit digital-watch display
111011011110011011000101100010111110000000 <-- to enter on stdin
```

## The Bopkit circuit

The watch circuit is implemented in
[watch.bop](https://github.com/mbarbin/bopkit/tree/main/project/digital-watch/watch.bop).

We keep all externals blocks out of this file, so it can be compiled to C and
Verilog. So as to be able to regulate the frequency, the main block defined by
this file takes a 1 bit input, which it ignores.

### Producing the output

Simulate for example with:

```bash
$ bopkit simu watch.bop -num-counter-cycles 3 -o
101111110111111011111101111110111111011111
101111110111111011111101111110111111011111
101111110111111011111101111110111110000110
101111110111111011111101111110111110000110
101111110111111011111101111110111110111011
101111110111111011111101111110111110111011
```

### Connecting the output to the device

So we can visualize the output, we connect the output of the simulation into the
7-segment display, using a unix pipe.

So the simulation goes at the expected speed of 2 cycles per second, we use the
option `f 2` of `bopkit counter`, which we use to generate the input bit, and
add it to the pipe command below:

<!-- $MDX skip -->
```bash
$ bopkit counter -N 1 -ni -f 2 | bopkit simu watch.bop -o | bopkit digital-watch display -no
```

### Putting it all together in a circuit

Rather than using unix pipe, we can also use external blocks for all the
components into a file. That's what's done in
[main.bop](https://github.com/mbarbin/bopkit/tree/main/project/digital-watch/main.bop)

So the simulation command for the project becomes simply:
<!-- $MDX skip -->
```bash
$ bopkit simu main.bop
```

## The C circuit

We use `bop2c` to translate the circuit into a standalone C executable:

<!-- $MDX skip -->
```bash
$ bopkit bop2c watch.bop > /tmp/watch.c
```

So we can monitor for regressions, we committed the result of this command, and
check it as part of the `dune runtest` target. See the result in the file
[watch_in_c.c](https://github.com/mbarbin/bopkit/tree/main/project/digital-watch/watch_in_c.c).

You may integrate the C file into a simulation with these commands:

<!-- $MDX skip -->
```bash
$ gcc /tmp/watch.c -o /tmp/watch.out
$ bopkit counter -N 1 -ni -f 2 | /tmp/watch.out | bopkit digital-watch display -no
```

## The digital-watch + bopboard combo

We connect the bopkit digital watch to a bopboard in the file
[watch_with_bopboard.bop](https://github.com/mbarbin/bopkit/tree/main/project/digital-watch/watch_with_bopboard.bop).

<!-- $MDX skip -->
```bash
$ bopkit simu watch_with_bopboard.bop
```

The time on the watch can be incremented by pressing the 3 left most push
buttons of the board, to increment the hours, minutes, and seconds respectively.
