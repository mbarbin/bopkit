# Testing Visa

## Software vs Hardware

We've created expect tests for both execution styles of the calendar:

1. Simulated execution of the assembly code via the visa simulator

<!-- $MDX skip -->
```sh
  $ visa_run () {
  >   visa run calendar.asm -sleep false -stop-after-n-outputs $1 \
  >     -initial-memory test-memory.txt \
  >   | bopkit digital-calendar map-raw-input \
  >   | bopkit digital-calendar print -print-index
  > }

  $ visa_run_date () {
  >   ./get_date.exe $1 $2 > test-memory.txt
  >   visa_run $3
  > }
```

2. Simulated execution of the hardware via the bopkit simulator

<!-- $MDX skip -->
```sh
  $ visa_run () {
  >   bopkit simu visa.bop -num-cycles $1 \
  >     -parameter 'InitialMemory=test-memory.txt' \
  >     -parameter 'WithPulse=0' \
  >     -output-only \
  >   | bopkit digital-calendar map-raw-input \
  >   | bopkit digital-calendar print -print-index -print-on-change
  > }

  $ visa_run_date () {
  >   ./get_date.exe $1 $2 > test-memory.txt
  >   visa_run $3
  > }
```

This allows to monitor the behavior of the calendar crossing any boundaries we
feel like including in the tests, including crossing minutes, hours, days,
months, years, century.

The cram test of the microprocessor includes the index of the simulation cycles
at which the output changes, which allows us to monitor precisely the order and
the timing with which the microprocessor updates its output.

## Excerpts

### Assembly simulator

<!-- $MDX skip -->
```sh
  $ visa_run 15
  0000: 01/01/00 - 00:00:58
  0001: 01/01/00 - 00:59:58
  0002: 01/01/00 - 23:59:58
  0003: 31/01/00 - 23:59:58
  0004: 31/01/23 - 23:59:58
  0005: 31/01/23 - 23:59:59
  0006: 31/01/23 - 23:59:00
  0007: 31/01/23 - 23:00:00
  0008: 31/01/23 - 00:00:00
  0009: 01/01/23 - 00:00:00
  0010: 01/02/23 - 00:00:00
  0011: 01/02/23 - 00:00:01
  0012: 01/02/23 - 00:00:02
  0013: 01/02/23 - 00:00:03
  0014: 01/02/23 - 00:00:04
```

There'are a few interesting things to note here.

1. The program is such that the output device takes a few cycles to get in sync
with the initial memory, because it has to go over all the initialization
happening inside the macro [UPDATE_SEC].

2. When boundary are encountered, the output device is updated byte after byte,
in the order: Sec, Min, Hour, Day, Month, Year. So for a very brief moment, the
output device contains nonsensical values (it looks as if the time goes
backward). In practice this is invisible, because this happens on consecutive
instructions, and the microprocessor runs at 1024 instructions per second, but
this is visible in this test.

Checkout the complete test [here](https://github.com/mbarbin/bopkit/tree/main/project/visa/circuit/visa-simulator.t).

### Microprocessor

End of January.

For a detailed explanation of the behavior seen below, see `visa-simulator.t`,
since the behavior is not specific to the execution of the microprocessor, but
rather comes from the way `calendar.asm` is implemented. We check here that the
execution of the microprocessor is in par with that of the visa-simulator.

<!-- $MDX skip -->
```sh
  $ visa_run_date 23:59:58 2023/01/31 5000
  0000: 01/01/00 - 00:00:00
  1028: 01/01/00 - 00:00:58
  1032: 01/01/00 - 00:59:58
  1036: 01/01/00 - 23:59:58
  1040: 31/01/00 - 23:59:58
  1048: 31/01/23 - 23:59:58
  2052: 31/01/23 - 23:59:59
  3076: 31/01/23 - 23:59:00
  3080: 31/01/23 - 23:00:00
  3084: 31/01/23 - 00:00:00
  3088: 01/01/23 - 00:00:00
  3092: 01/02/23 - 00:00:00
  4100: 01/02/23 - 00:00:01
```

End of February when it has 28 days.

<!-- $MDX skip -->
```sh
  $ visa_run_date 23:59:59 2023/02/28 5000
  0000: 01/01/00 - 00:00:00
  1028: 01/01/00 - 00:00:59
  1032: 01/01/00 - 00:59:59
  1036: 01/01/00 - 23:59:59
  1040: 28/01/00 - 23:59:59
  1044: 28/02/00 - 23:59:59
  1048: 28/02/23 - 23:59:59
  2052: 28/02/23 - 23:59:00
  2056: 28/02/23 - 23:00:00
  2060: 28/02/23 - 00:00:00
  2064: 01/02/23 - 00:00:00
  2068: 01/03/23 - 00:00:00
  3076: 01/03/23 - 00:00:01
  4100: 01/03/23 - 00:00:02
```

Addendum. There used to be a bug in the execution of the microprocessor that was
when noticeable when crossing centuries. The bug was that the seconds were not
passing steadily. The microprocessor somehow lagged just before crossing the
century, and then resumed its normal course. The test below was able to show
this problem, so we are keeping it to avoid a regression.

<!-- $MDX skip -->
```sh
  $ visa_run_date 23:59:56 1999/12/31 10000
  0000: 01/01/00 - 00:00:00
  1028: 01/01/00 - 00:00:56
  1032: 01/01/00 - 00:59:56
  1036: 01/01/00 - 23:59:56
  1040: 31/01/00 - 23:59:56
  1044: 31/12/00 - 23:59:56
  1048: 31/12/99 - 23:59:56
  2052: 31/12/99 - 23:59:57
  3076: 31/12/99 - 23:59:58
  4100: 31/12/99 - 23:59:59
  5124: 31/12/99 - 23:59:00
  5128: 31/12/99 - 23:00:00
  5132: 31/12/99 - 00:00:00
  5136: 01/12/99 - 00:00:00
  5140: 01/01/99 - 00:00:00
  5144: 01/01/00 - 00:00:00
  6148: 01/01/00 - 00:00:01
  7172: 01/01/00 - 00:00:02
  8196: 01/01/00 - 00:00:03
  9220: 01/01/00 - 00:00:04
```

After the initialization phase, the microprocessor stabilizes on ticks falling
on cycles (1028 + i * 1024). According to this schedule, the expectation would
be to have:

- 2052: 31/12/99 - 23:59:57
- 3076: 31/12/99 - 23:59:58
- 4100: 31/12/99 - 23:59:59
- **5124**: 01/01/00 - 00:00:00
- 6148: 01/01/00 - 00:00:01

However, it is not possible to update all digits at once. The next best, is for
the change to start occurring exactly on tempo, even if it takes a few cycles
for all the digits to update. This is the case here, between the cycles 5124 (on
the beat) and cycles 5144, all the digits have been updated, and the micro
resumes its cycles from there.

Checkout the complete test [here](https://github.com/mbarbin/bopkit/tree/main/project/visa/circuit/visa.t).
