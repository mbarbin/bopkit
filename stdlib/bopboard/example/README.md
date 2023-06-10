# Bopkit Examples - Bopboard

This page shows a few simple example using the bopboard. You can find the full source in the Bopkit GitHub repository in [this directory](https://github.com/mbarbin/bopkit/tree/main/stdlib/bopboard/example/).

## lights.bop

This serves as the hello-world for the bopboard. This is a very small circuit
that connects the lights to the state of the switches.

After having installed bopkit, you may run it with:

<!-- $MDX skip -->
```bash
$ bopkit simu lights.bop
```

<details open>
<summary>
Checkout the entire contents of the file lights.bop
</summary>

<!-- $MDX file=lights.bop -->
```bopkit
/**
 * Introduction example for the bopboard.
 *
 * This is a simple circuit that connects the lights to the state of
 * the switches.
 *
 * After having installed bopkit, you may run with:
 *
 * $ bopkit simu lights.bop
 */
#include <bopboard.bop>

// The number of lights and switches.
#define N 8

Main() = ()
where
  switch:[N] = $bopboard.switch();
  $bopboard.light(switch:[N]);
end where;
```

</details>

## lights_bdd.bop

This is a slight tweak to the previous circuit. This time, the state of the
lights is encoded in binary with the state of the 3 first switches. The binary
code formed by the 3 left-most switches of the board is a number between 0 and
7, and is the index of the single light that is on, the rest are off.

<!-- $MDX skip -->
```bash
$ bopkit simu lights_bdd.bop
```

<details open>
<summary>
Checkout the entire contents of the file lights_bdd.bop
</summary>

<!-- $MDX file=lights_bdd.bop -->
```bopkit
/**
 * Introduction example for the bopboard.
 *
 * This is a simple circuit that connects the lights to the state of
 * the switches. The first 3 switches encode which light must be on, using the
 * switch state as binary encoding for the light's index.
 *
 * The lights can be turned off by pressing any of the push buttons.
 *
 * After having installed bopkit, you may run with:
 *
 * $ bopkit simu lights_bdd.bop
 */
#include <stdlib.bop>
#include <bopboard.bop>

// The number of lights and switches.
#define N 8

Main() = ()
with unused = switch[3..7]
where
  switch:[N] = $bopboard.switch();
  push:[5] = $bopboard.push();
  lights:[N] = ReverseBdd[3](en, switch:[3]);
  en = Not(Or[5](push:[5]));
  $bopboard.light(lights:[N]);
end where;
```

</details>

## ram.bop

This example shows how to run 2 boards and an external memory unit. The two
boards are:

- `addr-board`: The switches of the board encode for the address to read/write;
- `data-board`: The switches of the board encode for the data to write.

In addition, the data-board's lights are connected to its switches so as to
better visualize the data to write.

The address-board's lights are connected to the output of the memory-unit, and
always display the value of the bits that the memory returns.

By default, the memory unit is always acting in read-mode, except when the first
push button of the address-board is pushed, in which case the value of the data
board is written to the addr-board's value.

This is a fun little demo with 3 graphical windows interacting with each-other.

<!-- $MDX skip -->
```bash
$ bopkit simu ram.bop
```

<details open>
<summary>
Checkout the entire contents of the file ram.bop
</summary>

<!-- $MDX file=ram.bop -->
```bopkit
#include <stdlib.bop>
#include <bopboard.bop>

#define N 8

external board1 "bopboard run -title addr"

external board2 "bopboard run -title data"

Main() = ()
where
  data_out:[N] =
    external("ram_memory.exe -addresses-len %{N} -words-len %{N}",
      addr:[N],
      addr:[N],
      write_mode,
      data_in:[N]);
  addr:[N] = $board1.switch();
  write_mode = $board1.push("0");
  $board1.light(data_out:[N]);
  data_in:[N] = $board2.switch();
  $board2.light(data_in:[N]);
end where;
```

</details>

## bit_shift.bop

This small circuit implements a bit shifter. At most one light is lit at a given
time, moving from left to right, and starting over from the left when it reaches
the end of the board, or when `reset` is pushed.

To reset it, press the board's push-0 button.

Note that for this simulation to be more human-friendly, we've reduced its
simulation frequency, using the `pulse` external (This may serve as an
introduction to pulse, see [stdlib/pulse](../../pulse/README.md) for more
details).

<!-- $MDX skip -->
```bash
$ bopkit simu bit_shift.bop
```

<details open>
<summary>
Checkout the entire contents of the file bit_shift.bop
</summary>

<!-- $MDX file=bit_shift.bop -->
```bopkit
#include <stdlib.bop>
#include <bopboard.bop>
#include <pulse.bop>

#define N 8
#define PULSE__CYCLES_PER_SECOND 16

/**
 * That's a bus of size N with exactly 1 bit '1' and the rest '0'.
 * The bit that is lit shifts from left to right, until it reaches the
 * end of the bus, and restarts at 0.
 * @param reset set the bus to the initial state.
 * @return bd the shifting bits.
 */
CyclerBD[N](reset, predBD:[N]) = bd:[N]
where
  bd:[N] = Mux[N](reset, Vdd(), Gnd[N - 1](), u:[N]);
  for i = 0 to N - 2
    u[i + 1] = Id(predBD[i]);
  end for;
  u[0] = Id(predBD[N - 1]);
end where;

/**
 * Same as [CyclerBD] but with a memory.
 */
CyclerRG[N](reset) = bd:[N]
where
  bd:[N] = CyclerBD[N](reset, Reg[N](bd:[N]));
end where;

MainCycler(reset) = bd:[N]
where
  bd:[N] = CyclerRG[N](Reg1(reset));
end where;

Main() = bd:[N]
where
  $pulse();
  reset = $bopboard.push("0");
  bd:[N] = MainCycler(reset);
  $bopboard.light(bd:[N]);
end where;
```

</details>
