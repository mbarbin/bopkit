# Visa Microprocessor

This part documents the hardware design of the microprocessor visa.

To see all the files of this project, check out the source code on
[GitHub](https://github.com/mbarbin/bopkit/tree/main/project/visa).

## Architecture

### Memory

The visa microprocessor has a memory of 128 bytes, which can be manipulated via
the instructions `load` and `store`.

### Output device

To connect output signals to the outside world, visa has an output device of 128
bytes, which can written to via the instruction `write`. The output device is
write-only, so there are no instruction to read back from the output device.

Because the entire output device has to be available as output signals at all
times, this cannot be implemented with a RAM, from which we only can ready one
cell at a time. We're using dedicated registers here, in addition to the ALU
registers documented in the next paragraph.

Even though the instruction to write to the output device is `write` in the
assembly language, in the hardware implementation the write instruction is
encoded as a `store` operation. We use the most significant bit of the store
address to distinguish between the internal memory and the output device.

| Instruction      | Address        | Meaning                                   |
|------------------|----------------|-------------------------------------------|
| store R, address | address < 128  | Store R to RAM memory at $address          |
| store R, address | address >= 128 | Write R to output device at $(address-128) |

### Registers

The visa microprocessor has an arithmetic logic unit (ALU) with 2 1-byte
registers named `R0` and `R1`. When an overflow occurs during a register
operation, a positive bit is stored into an extra 1-bit register named
`Overflow_flag`.

Unless specified otherwise, when an instruction is a binary operation involving
both registers, the result is stored into `R1`. For example, `add` mutates `R1`
by assigning to it the result of `R0 + R1`.

Unary operations are available for both registers, as specified by the supplied
register_name. For example, `not R0` negates the contents of register `R0`, and
leaves `R1` untouched.

## The circuit

<details open>
<summary>
The microprocessor visa implemented in bopkit.
</summary>

<!-- $MDX file=visa.bop -->
```bopkit
/* =========================================================================
 * bopkit: An educational project for digital circuits programming
 * SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>
 * SPDX-License-Identifier: MIT
 * =========================================================================
 */

/**
 * VISA3: Visa Is Also An Assembler, but visa is first a microprocessor!
 *
 * This is the bopkit implementation of the visa microprocessor. This circuit
 * was originally implemented by Mathieu Barbin & Ocan Sankur in 2007.
 */
#include <stdlib.bop>
#include <pulse.bop>

/**
 * Setting the frequency for the simulation with pulse. For the clock divider to
 * work well, it should be a power of 2. Because the visa microprocessor is used
 * to run a binary program that drives the display of a digital calendar, and
 * some part of the program requires many instructions to run between 2 updates
 * of the calendar, this should be large enough to allow for the calendar to
 * have time to run all needed instructions between 2 seconds. It cannot be too
 * big, or else the bopkit simulator may not be able to keep up. [2^10] seems to
 * work well in practice.
 */
#define PULSE__CYCLES_PER_SECOND 2 ^ 10

/**
 * Defines the architecture of the microprocessor. Visa is implemented with an
 * architecture of 8 bits. This is a hard constraint of the design, and visa is
 * not designed for this parameter to be set to a different value (consider this
 * to be a design constant).
 */
#define AR 8

/**
 * The number of bits reserved to the part that contains the operation code in
 * an instruction.
 */
#define CL 4

/**
 * The number of bits of address to write to the OutputDevice
 */
#define OutputDeviceWidth 3

/**
 * The number of bytes returned by the output device. The other are truncated.
 */
#define OutputDeviceSize 2 ^ OutputDeviceWidth

/**
 * This parameter points to the binary code to execute. It was compiled from a
 * VISA assembly program contained in the file "calendar.asm"
 */
#define Executable "calendar.bin"

/**
 * Initial value for the date. We use [get_date.exe] to produce the contents
 * below, to initialize it to any desired date/time. [get_date.exe] is called
 * from a [dune] rule to produce the contents of the memory file.
 */
#define InitialMemory "initial-memory.txt"

/**
 * This parameter determines whether to include a call to `$pulse` in the body of
 * the main block. Having it means the execution is real-time, so the second
 * passing on the display are actual seconds. In tests we disable pulse, so the
 * test run faster.
 */
#define WithPulse 1

/**
 * This ROM contains the binary code to execute.
 */
ROM MICROCODE (AR, AR) = file("%{Executable}")

/**
 * Initialization for the microprocessor memory.
 */
RAM MEM (AR - 1, AR) = file("%{InitialMemory}")

// Jmp : 00010000 - opcode=08
IsJmp(p:[CL]) = b
where
  b = And(Not(p[0]), And(Not(p[1]), And(Not(p[2]), p[3])));
end where;

// Jmn : 10010000 - opcode=09
IsJmn(p:[CL]) = b
where
  b = And(p[0], And(Not(p[1]), And(Not(p[2]), p[3])));
end where;

// Jmz : 01010000 - opcode=10
IsJmz(p:[CL]) = b
where
  b = And(Not(p[0]), And(p[1], And(Not(p[2]), p[3])));
end where;

// Store_R0 : 11010000 - opcode=11
// Store_R1 : 11011000 - opcode=11
IsStore(p:[CL]) = b
where
  b = And[4](p[0], p[1], Not(p[2]), p[3]);
end where;

// Sleep : 10000000 - opcode=01
IsSleep(p:[CL]) = b
where
  b = And[4](p[0], Not(p[1]), Not(p[2]), Not(p[3]));
end where;

/**
 * Handling of the Output Device.
 *
 * The visa microprocessor has 8 bytes of output that we call the 'Output
 * Device'. This allows the microprocessor to be connected to external material,
 * such as a digital calendar display in this project.
 *
 * All the bits of the device are always returned, so it cannot be implemented
 * with a simple RAM memory, and is implemented using Registers instead.
 *
 * Writing to the device is encoded by a [Store] instruction, when the highest
 * bit of the store address is set to 1. This means that:
 *
 * | store Ri, (Addr >= 128)
 *
 * Means in fact:
 *
 * | write_to_output_device data=Ri, address=(Addr-128)
 */
DeviceOut(addr:[AR - 1], write_dev, data:[AR]) = out:[OutputDeviceSize]:[AR]
with unused = addr[OutputDeviceWidth..AR - 2]
where
  en_out:[OutputDeviceSize] =
    ReverseBdd[OutputDeviceWidth](write_dev, addr:[OutputDeviceWidth]);
  for i = 0 to OutputDeviceSize - 1
    out[i]:[AR] = RegEn[AR](data:[AR], en_out[i]);
  end for;
end where;

/**
 * p0 and p1 hold the instruction to execute. p0 is the control part, and p1 the
 * data, for instructions that are encoded on 2 bytes. s is the output of the sleep
 * register.
 */
ALU(p0:[AR], p1:[AR], isActive, write_time) = (r1:[AR],
  out:[OutputDeviceSize]:[AR])
with unused = (p0[6], p0[7])
where
  // Registers
  overflow_flag =
    RegEn(new_overflow_flag, And(isActive, write_overflow_flag));
  r0:[AR] = RegEn[AR](nr0:[AR], And(isActive, write_r0));
  r1:[AR] = RegEn[AR](nr1:[AR], And(isActive, write_r1));

  // LOCAL MEMORY for STORE and LOAD
  mem_out:[AR] =
    ram_MEM(
      p1:[AR - 1],
      p1:[AR - 1],
      And(isActive, write_mem),
      mem_input:[AR]);
  store = And(write_time, IsStore(p0:[CL]));
  write_dev = And(store, p1[AR - 1]);
  write_mem = And(store, Not(p1[AR - 1]));

  // The input for [Store]. If p0[Cl] then R1, else R0.
  mem_input:[AR] = Mux[AR](p0[CL], r1:[AR], r0:[AR]);

  // output device
  out:[OutputDeviceSize]:[AR] =
    DeviceOut(p1:[AR - 1], And(isActive, write_dev), mem_input:[AR]);

  /* Effective mem_out: whether the load instruction is [Load_address] or
   * [Load_value]. p0[CL+1] equals to 1 if we're loading from an address.
   */
  eff_mem_out:[AR] = Mux[AR](p0[CL + 1], mem_out:[AR], p1:[AR]);
  addResult:[AR], addOverflow = Add[AR](r0:[AR], r1:[AR], Gnd());

  // Calculate next values to assign to registers
  for SIZE = AR + 1 + AR + 1 + 2
    nr0:[AR], write_r0, nr1:[AR], write_r1, new_overflow_flag,
      write_overflow_flag =
      Bdd[2 ^ CL][SIZE](
        // 0000 : Nop
        Gnd[SIZE](),
        // 1000 : Sleep
        Gnd[SIZE](),
        // 0100 : Add
        Gnd[AR + 1](),
        addResult:[AR],
        Vdd(),
        addOverflow,
        Vdd(),
        // 1100 : And
        Gnd[AR + 1](),
        And2[AR](r0:[AR], r1:[AR]),
        Vdd(),
        Gnd[2](),
        // 0010 : Swc
        r1:[AR],
        Vdd(),
        r0:[AR],
        Vdd(),
        Gnd[2](),
        // 1010 : Cmp
        Gnd[AR + 1](),
        Equals[AR](r0:[AR], r1:[AR]),
        Gnd[AR - 1](),
        Vdd(),
        Gnd[2](),
        // 0110 : Not
        Not[AR](r0:[AR]),
        Not(p0[CL]),
        Not[AR](r1:[AR]),
        p0[CL],
        Gnd[2](),
        // 1110 : Gof
        Gnd[AR + 1](),
        overflow_flag,
        Gnd[AR - 1](),
        Vdd(),
        Gnd[2](),
        // 0001 : Jmp
        Gnd[SIZE](),
        // 1001 : Jmn
        Gnd[SIZE](),
        // 0101 : Jmz
        Gnd[SIZE](),
        // 1101 : Store
        Gnd[SIZE](),
        // 0011 : Load
        eff_mem_out:[AR],
        Not(p0[CL]),
        eff_mem_out:[AR],
        p0[CL],
        Gnd[2](),
        // 1011 : UnassignedOp13
        Gnd[SIZE](),
        // 0111 : UnassignedOp14
        Gnd[SIZE](),
        // 1111 : UnassignedOp15
        Gnd[SIZE](),
        // Decision
        p0:[CL]);
  end for;
end where;

VisaMicroprocessor() = d:[OutputDeviceSize]:[AR]
where
  if WithPulse == 1 then
    $pulse();
  end if;

  // Program Counter
  rom_out:[AR] = rom_MICROCODE(pc:[AR]);
  p0:[AR] = Var[AR](rom_out:[AR], And(isActive, write_p0));
  p1:[AR] = Var[AR](rom_out:[AR], And(isActive, write_p1));
  pc:[AR] = RegEn[AR](next_pc:[AR], isActive);
  incr_pc:[AR] = Succ[AR](pc:[AR]);

  // Computing the next program counter.
  next_pc:[AR] = Mux[AR](And(jump, write_p1), p1:[AR], incr_pc:[AR]);
  jump =
    Or[2](
      IsJmp(p0:[CL]),
      Mux(Or[AR](r1:[AR]), IsJmn(p0:[CL]), IsJmz(p0:[CL])));

  // Handling of the sleep register
  second = ClockDivider[log PULSE__CYCLES_PER_SECOND](Vdd());
  isActive = Reg1En(second, Or(IsSleep(p0:[CL]), second));

  // Determining whether we're reading instruction part 0 or 1
  // Does instr take 2 words?
  isP2W = Id(p0[3]);
  write_p0 = Reg1(Mux(isP2W, Not(write_p0), Vdd()));
  write_p1 = Not(write_p0);

  // p0 and p1 as sent to ALU
  write_time = Mux(isP2W, write_p1, write_p0);
  p'0:[AR] = Mux[AR](write_time, p0:[AR], Gnd[AR]());
  p'1:[AR] = Mux[AR](write_time, p1:[AR], Gnd[AR]());

  // ********************************* //
  r1:[AR], d:[OutputDeviceSize]:[AR] =
    ALU(p'0:[AR], p'1:[AR], isActive, write_time);
end where;
```

</details>

## Calendar Output

As we've discussed in the [calendar](calendar.md) section, the output dedicated
to the digital calendar will consist of the first 6 bytes of the output device,
each encoding a value on 8 bits (between 0-255) for each of the digits of the
time of day (sec, min, hour) and the date (day, month, year).

The output bytes cannot be directly connected to the calendar display, because
its input is not directly compatible. Indeed, the display expects 7-segment
codes.

Thus, we've added a small circuit to fit right in between the output of the
microprocessor and the input of the calendar display. We've called it
`calendar-output.bop`.

<details open>
<summary>
Mapping the microprocessor output in bopkit.
</summary>

<!-- $MDX file=calendar-output.bop -->
```bopkit
/* =========================================================================
 * bopkit: An educational project for digital circuits programming
 * SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>
 * SPDX-License-Identifier: MIT
 * =========================================================================
 */

/**
 * The microprocessor visa is not specialized to produce an output for the digital
 * calendar. Rather, it has a generic output device composed of 8 bytes.
 *
 * We make use of this small circuit to map the output of the microprocessor to
 * the format that is expected by the digital-calendar device.
 */
#include <stdlib.bop>
#include <"7_segment.bop">
#include "div10.bop"

MapOutput(visa:[8]:[8]) = calendar:[13]:[7]
with unused = (visa:[8][7], visa[3]:[7], visa[7]:[7])
where
  su:[4], st:[4] = Div10(visa[0]:[7]);
  mu:[4], mt:[4] = Div10(visa[1]:[7]);
  hu:[4], ht:[4] = Div10(visa[2]:[7]);

  // visa[3] is currently unused. At some point there was a plan for it to
  // encode the day of the week, but this is not done.
  du:[4], dt:[4] = Div10(Succ[7](visa[4]:[7]));
  mou:[4], mot:[4] = Div10(Succ[7](visa[5]:[7]));
  yu:[4], yt:[4] = Div10(visa[6]:[7]);

  // And now mapping all the values through the 7-segment encoder.
  calendar[0]:[7] = rom_Dec7(su:[4]);
  calendar[1]:[7] = rom_Dec7(st:[4]);
  calendar[2]:[7] = rom_Dec7(mu:[4]);
  calendar[3]:[7] = rom_Dec7(mt:[4]);
  calendar[4]:[7] = rom_Dec7(hu:[4]);
  calendar[5]:[7] = rom_Dec7(ht:[4]);
  calendar[6]:[7] = Gnd[7]();
  calendar[7]:[7] = rom_Dec7(du:[4]);
  calendar[8]:[7] = rom_Dec7(dt:[4]);
  calendar[9]:[7] = rom_Dec7(mou:[4]);
  calendar[10]:[7] = rom_Dec7(mot:[4]);
  calendar[11]:[7] = rom_Dec7(yu:[4]);
  calendar[12]:[7] = rom_Dec7(yt:[4]);
end where;
```

</details>

### Div10

The calendar-output circuit makes use of a division modulo 10. To implement it,
we used `bopkit bdd` to synthesize a circuit based on the truth table of the
div10 function.

This technic is already discussed in greater details in
[this tutorial](https://mbarbin.github.io/bopkit/tutorial/bdd/division/), so we're not
going to detail it here.

## Putting it all together

We've put all the components into a single entry point circuit named `main.bop`.

<details open>
<summary>
Mapping the microprocessor output in bopkit.
</summary>

<!-- $MDX file=main.bop -->
```bopkit
/* =========================================================================
 * bopkit: An educational project for digital circuits programming
 * SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>
 * SPDX-License-Identifier: MIT
 * =========================================================================
 */
#include "visa.bop"
#include "calendar-output.bop"
#include <"7_segment.bop">

Main() = ()
where
  d:[OutputDeviceSize]:[AR] = VisaMicroprocessor();
  calendar:[91] = MapOutput(d:[8]:[8]);
  $digital_calendar_display(calendar:[91]);
end where;
```

</details>

Simulate with:

<!-- $MDX skip -->
```sh
$ bopkit simu main.bop
```
