# Misc

Miscellaneous bop files.

## iii.bop

<!-- $MDX file=iii.bop -->
```bopkit
#define i "and"
#define ii 3

i[i]<i>(i:[i]) = i
where
  for i = i - i to i - i / i
    for i = i
      i[i + i ^ (i - i)][i + i ^ (i - i)] = i(i[i][i], i[i]);
    end for;
  end for;
  i[i - i][i - i] = vdd();
  i = id(i[i][i]);
end where;

[ Main ]
i(i:[ii]) = i
where
  i = i[ii]<"%{i}">(i:[ii]);
end where;
```

This is sort of a crazy example that shows the various and distinct syntactic
classes that identifiers can have in a circuit.

In the circuit, `i` is sometimes:

- the name of a circuit parameter
- the name of a block with parameters
- the name of a block with no parameters
- the name of a block parameter
- the name of a functional argument
- the name of a signal
- the name of a 1 dimensional bus
- the name of a 2 dimensional bus
- the name of a for loop variable

They all live happily together, without creating conflicts.

<!-- $MDX skip -->
```sh
$ bopkit simu iii.bop
```

Try to guess what this circuit computes. (I personally don't remember!).

This is not a guideline for how to name identifiers in a circuit!!

## cycle.bop

<!-- $MDX file=cycle.bop -->
```bopkit
// Testing the cycle detection
Cycle(a, b) = s
where
  u = and(a, g);
  g = or(b, id(u));
  s = xor(g, vdd());
end where;
```

This is an invalid circuit with a combinatorial cycle in it. The dune-test shows
the kind of error messages produced when that happens.

```sh
$ bopkit simu cycle.bop
File "cycle.bop", line 1, characters 0-0:
Error: The circuit has a cycle.
Hint: Below are some indications to try and find it:
File "cycle.bop", line 2, characters 0-5:
2 | Cycle(a, b) = s
    ^^^^^
Error: In this block, these variables may create a dependency cycle:

  ..#0#.. = ..id(..u..);

  ..u.. = ..and(..g..);

  ..g.. = ..or(..#0#..);

[1]
```
