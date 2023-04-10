# Pulse

Pulse defines an external block that allows you to control the frequency at which a simulation will run.

<!-- $MDX file=pulse.bop -->
```bopkit
/**
 * Pulse is used to regulate the simulation of bop files to a desired fixed
 * number of simulated cycles per second.
 */
/**
 * This module defines two parameters to regulate the simulation. The first is
 * for setting a maximum number of cycles per seconds. The default is [max], which
 * means that the simulation will run as fast as possible. You may override the
 * value to an integer.
 *
 * For example:
 *
 * | #define PULSE__CYCLES_PER_SECOND 1024
 * |
 */
#define PULSE__CYCLES_PER_SECOND "max"

/**
 * You may set this parameter to ["true"] to indicate to pulse to act as if it
 * had run from midnight. This will cause the first cycles to go as fast as
 * possible, until the normal rate can be resumed when reaching the expected number
 * of cycles at the current time of day.
 */
#define PULSE__AS_IF_STARTED_AT_MIDNIGHT "false"

/**
 * Defines the external block pulse. Beware, each call to [$pulse] will be
 * considered a cycle, thus there should be only one call for the entire circuit.
 * The convention is to place it in the body of the main block of the circuit, such
 * as in the example below:
 *
 * | #define PULSE__CYCLES_PER_SECOND 256
 * |
 * | Main() = ()
 * | where
 * |   $pulse();
 * |   ...
 * | end where;
 */
external pulse "pulse.exe -cycles-per-second %{PULSE__CYCLES_PER_SECOND} -as-if-started-at-midnight %{PULSE__AS_IF_STARTED_AT_MIDNIGHT}"
```

## Example

Below is a minimal example that uses `pulse`.

<!-- $MDX file=example.bop -->
```bopkit
#include <pulse.bop>

#define PULSE__CYCLES_PER_SECOND 4
#define PULSE__AS_IF_STARTED_AT_MIDNIGHT "true"

Main() = ()
where
  $pulse();
end where;
```

To use `pulse`, add the include line, then sets the desired values for the pulse
parameters. Finally, add the call the `$pulse` external block into your main
block, and that's it!
