# Bopboard

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/bopboard.png?raw=true"
    alt="Logo"
  />
</p>

The bopboard is a user-friendly interface that can be connected to any bopkit
design. It enables users to control circuit inputs through push and switch
buttons while providing a visual representation of critical circuit signals
using the board's lights.

The original bopboard application was written in 2008 by Samuel Kvaalen, who
also designed board's images as well as bopkit's ladybug.

## Installation

Using bopboard requires to install the bopkit package. The bopboard executable
is installed via dune-sites in the bopkit's libexec directory, where the
simulator knowns to find it.

## Usage in bopkit file

To use the bopboard, add the following include to your bop file:

```text
#include <bopboard.bop>
```

The bopboard external has 3 methods which access respectively:

- the 8 lights;
- the 5 push buttons;
- the 8 switch buttons.

From the perspective of the board, the lights are input signals (the circuit
sets the lights), whereas pushes and switches are output signals (the user moves
them on the board, and doing so defines their state).

To connect all the lights to an input bus of width 8 in a bopkit file, use the
syntax:

```text
  $bopboard.light(i:[8]);
```

Note that you may also connect the lights one by one (and leave some
unconnected), by adding a textual argument indicating the index of the light. In
this case, the input of the method is expected to be a simple signal (size 1).

```text
  $bopboard.light("0", i);
```

The same applies to pushes and switches.

```text
  // Access the bus with the state of the 5 push buttons.
  // The signal [vdd] means that the button is pressed down.
  p:[5] = $bopboard.push();

  // Access the state of a single push button, e.g. the "2"
  p2 = $bopboard.push("2");

  // Access the bus with the state of the 8 switch buttons.
  // The signal [vdd] means that the switch is on the up position.
  p:[8] = $bopboard.switch();

  // Access the state of a single switch button, e.g. the "7"
  p2 = $bopboard.switch("7");
```

## Examples

See some examples in [this directory](example/).
