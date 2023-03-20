# Bopkit Examples - Bopboard

## lights.bop

This serves as the hello-world for the bopboard. This is a very small
circuit that connects the lights to the state of the switches.

After having installed bopkit, you may run it with:

```bash
$ bopkit simu lights.bop
```

## ram.bop

This example shows how to run 2 boards and an external memory unit.
The two boards are:

- `addr-board`: The switches of the board encode for the address to read/write;
- `data-board`: The switches of the board encode for the data to write.

In addition, the data-board's lights are connected to its switches so
as to better visualize the data to write.

The address-board's lights are connected to the output of the
memory-unit, and always display the value of the bits that the memory
returns.

By default, the memory unit is always acting in read-mode, except when
the first push button of the address-board is pushed, in which case the
value of the data board is written to the addr-board's value.

This is a fun little demo with 3 graphical windows interacting with
each-other.

```bash
$ bopkit simu ram.bop
```

## bitshift.bop

This small circuit implements a bit shifter. At most one light is lit
at a given time, moving from left to right, and starting over from the
left when it reaches the end of the board, or when `reset` is pushed.

To reset it, press the board's push-0 button.

Note that for this simulation to be more human-friendly, we've reduced
its simulation frequency, using the `pulse` external (This may serve
as an introduction to pulse, see [stdlib/pulse](../../pulse/pulse.bop)
for more details).

```bash
$ bopkit simu bitshift.bop
```
