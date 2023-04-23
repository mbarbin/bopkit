# Visa Project Introduction

The project originated in 2007 as a class assignment with Professor Jean
Vuillemin[^1]:

> Write a simulator for a hardware description language of your choice; use it
> to execute on a microprocessor of your design a binary code that will drive
> the display of a digital calendar.

Ocan Sankur and Mathieu Barbin teamed up to complete the project, implementing a
HDL based on a subset of the language 2Z[^2] used in the course notes, and
designing a microprocessor called visa.

The HDL part is what gave birth to the bopkit project. Welcome to the part of
the project that relates to the microprocessor visa!

## Visa IS an Assembler

Because the original language used in the course note was called Jazz, we
thought it would be fun to call our toy implementation of a HDL `bebop`. This is
the ancestor of `bopkit`! (we renamed the project in 2023).

At the time we enjoyed using a recursive naming scheme we found in some unix
projects that consists in naming a project by the first letters of a statement
that involves ... the name of the project itself. So, what is Visa? `Visa IS an
Assembler`. This could have worked with pretty much any first letter : Tisa IS
an Assembler too (tisa?), but it so happens that Charlie Parker, which we liked
to listen to while working on bebop circuits, and considered by many as a master
of the Jazz style bebop, had written a song named `visa`. The name became obvious
to us then.

## High-level description of the project

1. Circuit
1. Assembler
1. Calendar.asm

The first goal of the project is to implement a bopkit circuit for a
microprocessor that is capable of running binary codes dedicated to its
architecture. That's the circuit part.

The project then defines an assembly language and the associated tool chain
(assembler, simulator, debugger, editor support) that allows us to write
programs that can be converted to binary code to be executed on the
microprocessor. That's the assembler part.

Then we make use of the assembly language to implement an visa-assembly program
whose goal is to drive the display of a digital calendar. That is, a program
that can keep track of the time of day, as well as the date, as time passes.
That's the calendar part.

To visualize the output, we use a simulated 7-segment device implemented with
the OCaml Graphics library and connect it to the simulation using bopkit's
external construct.

[^1]:Jean Vuillemin, https://www.di.ens.fr/~jv/

[^2]: F. Bourdoncle, J. Vuillemin and G. Berry, The 2Z reference manual, PRL
report ??, Digital Equipment Corp., Paris Research Laboratory, 85, Av. Victor
Hugo. 92563 Rueil-Malmaison Cedex, France, 1994.
