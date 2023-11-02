# Signals and buses

## Connectivity between blocks via named signals

The connectivity between the gates of a circuit is described thanks to variables that are attached to the gates' inputs and outputs.

```bopkit
  a = And(b, c);
  d = Or(a, e);
```

Note that not all inputs and outputs are named, simply because blocks may be nested:

```bopkit
  d = Or(And(b, c), e);
```

The output of the `And` gate below is not named. It's connectivity with the `Or`'s gate is implicit.

## Signal values

Electrical signals are of type `bit` (or `bool`), and can have 2 values: `0` (`gnd`) and `1` (`vdd`).

## Buses

Rather than always having to list signals individually, it is possible to group
signals together into an array of signals, a construction named `bus` in bopkit.

### Indexation

:::info

Buses and signals are in 2 distinct syntactic classes. There is no inference or hidden type assignment that will make a variable a bus. Rather, a bus is a named variable followed by some indexation.

:::

 For example:

| Syntax      | Syntactic class |
| ----------- | --------------- |
| a           | Signal          |
| a:[8]       | Bus             |

Here is a table of the supported indexations, and how they're resolved to expand a bus into the signals that compose it. Bus indexes are 0 based.

| Syntax      | Expanded to | Description |
| ----------- | ----------- | ------------|
| a[5] | a[5] | The 5th bit of bus a |
| a[3..7] | a[3], a[4], a[5], a[6], a[7] | Bits 3 to 7 of bus a |
| a:[4] | a[0], a[1], a[2], a[3] | Equivalent to a[0..3] |
| a:[-4] | a[3], a[2], a[1], a[0] | Equivalent to a[3..0] |
| a[3..4]:[2] | a[3][0], a[3][1], a[4][0], a[4][1] | 2 dimensional bus |

:::warning

Because bus indexes are 0-based, note that for example `a:[8]` is of size 8, and it's last signal is `a[7]` (and not `a[8]`). Beware of off-by-1 errors.

:::

Also note that multi dimensional bus are expanded from right to left, as shown in the last line of the table above.
