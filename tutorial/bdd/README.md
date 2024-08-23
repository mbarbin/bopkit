# Binary Decision Diagrams

`bopkit bdd` implements an algorithm to convert boolean functions into bopkit
circuits. The tool takes advantage of unspecified output bits by assigning them
values that minimize the number of gates required to synthesize the circuit.

## Hello bopkit bdd

Let's go over a first example in this guide.

### Truth table

Consider the following truth table:

```text
 00 -> 0101
 10 -> 1001
 01 -> 0111
 11 -> 0101
```

It represents a combinatorial function from 2 bits to 4 bits. Let's save into a
file, which we'll name `fct01.txt`:

```sh
$ cat > fct01.txt <<EOF \
> 0101\
> 1001\
> 0111\
> 0101\
> EOF
```

We can double check that the file was indeed correctly initialized:

```sh
$ cat fct01.txt
0101
1001
0111
0101
```

### Synthesizing a circuit from the truth table

This file format can be imported by bopkit in several contexts, such as when
initializing the contents of memories.

It can also be read by the command `bopkit bdd` to synthesize a bopkit circuit
whose semantics equals that of the combinatorial function.

Let's check it out!

```sh
$ bopkit bdd synthesize --AD 2 --WL 4 -f fct01.txt | tee my_block.bop
// Block synthesized by bopkit from "fct01.txt"
// Gate count: [12|4|4] (33.333 %)

Block(a:[2]) = out:[4]
where
  s1 = Not(a[1]);
  s2 = Mux(a[0], s1, Gnd());
  out[0] = Id(s2);
  s3 = Mux(a[0], a[1], Vdd());
  out[1] = Id(s3);
  s4 = Mux(a[0], Gnd(), a[1]);
  out[2] = Id(s4);
  out[3] = Vdd();
end where;
```

### Simulating the resulting circuit

And now we can simulate it and check the output against the original truth table.

```sh
$ bopkit simu my_block.bop --num-counter-cycles 1
   Cycle | a[0] a[1] | out[0] out[1] out[2] out[3]
       0 | 0 0 | 0 1 0 1
       1 | 1 0 | 1 0 0 1
       2 | 0 1 | 0 1 1 1
       3 | 1 1 | 0 1 0 1
```
