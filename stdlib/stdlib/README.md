# Stdlib

The file `stdlib.bop` extends the primitives of the languages, and add common
and useful utils that are likely to come in handy in many circuits. To use
blocks defined in the file, simply add the following line on top of your
circuit:

```bopkit
#include <stdlib.bop>
```

You shouldn't worry about adding the line, only the blocks that are actually
needed end up in the resulting circuit, the rest is safely discarded.

## Details

<details open>
<summary>
Checkout the entire contents of the file stdlib.bop
</summary>

<!-- $MDX file=stdlib.bop -->
```bopkit
/**
 * id[N] is the identity bit by bit. Return N signals that are duplicate from
 * the N input signals.
 */
Id[N](a:[N]) = b:[N]
where
  for idi = 0 to N - 1
    b[idi] = Id(a[idi]);
  end for;
end where;

/**
 * mux[N] generalize the mux primitive for N bits. [mux[N](enable, d1, d2)]
 * returns signals connected to d1 if [enable] is true, otherwise d2.
 */
Mux[N](c, d1:[N], d2:[N]) = s:[N]
where
  for k = 0 to N - 1
    s[k] = Mux(c, d1[k], d2[k]);
  end for;
end where;

OneOutputToVector[N]<Fun>() = o:[N]
where
  for i = 0 to N - 1
    o[i] = Fun();
  end for;
end where;

Gnd[N]() = o:[N]
where
  o:[N] = OneOutputToVector[N]<Gnd>();
end where;

Vdd[N]() = o:[N]
where
  o:[N] = OneOutputToVector[N]<Vdd>();
end where;

Clock[N]() = o:[N]
where
  o:[N] = OneOutputToVector[N]<Clock>();
end where;

And[N](a:[N]) = s
where
  b[0] = Id(a[0]);
  for i = 1 to N - 1
    b[i] = And(b[i - 1], a[i]);
  end for;
  s = Id(b[N - 1]);
end where;

And2[N](a:[N], b:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = And(a[i], b[i]);
  end for;
end where;

AndN[M][N](a:[M]:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = And[M](a:[M][i]);
  end for;
end where;

Or[N](a:[N]) = s
where
  b[0] = Id(a[0]);
  for i = 1 to N - 1
    b[i] = Or(b[i - 1], a[i]);
  end for;
  s = Id(b[N - 1]);
end where;

Or2[N](a:[N], b:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Or(a[i], b[i]);
  end for;
end where;

OrN[M][N](a:[M]:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Or[M](a:[M][i]);
  end for;
end where;

Not[N](a:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Not(a[i]);
  end for;
end where;

Xor[N](a:[N]) = s
where
  s = And(atLeastOne[N], Not(moreThanOne[N]));
  atLeastOne[0] = Gnd();
  moreThanOne[0] = Gnd();
  for i = 0 to N - 1
    atLeastOne[i + 1] = Or(atLeastOne[i], a[i]);
    moreThanOne[i + 1] = Or(moreThanOne[i], And(atLeastOne[i], a[i]));
  end for;
end where;

Xor2[N](a:[N], b:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Xor(a[i], b[i]);
  end for;
end where;

XorN[M][N](a:[M]:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Xor[M](a:[M][i]);
  end for;
end where;

Reg[N](a:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Reg(a[i]);
  end for;
end where;

RegEn[N](a:[N], en) = s:[N]
where
  for j = 0 to N - 1
    s[j] = RegEn(a[j], en);
  end for;
end where;

Reg1[N](a:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Reg1(a[i]);
  end for;
end where;

Reg1En[N](a:[N], en) = s:[N]
where
  for j = 0 to N - 1
    s[j] = Reg1En(a[j], en);
  end for;
end where;

Equals(a, b) = s
where
  s = Mux(a, b, Not(b));
end where;

Equals[N](a:[N], b:[N]) = s
where
  q[0] = Vdd();
  for i = 0 to N - 1
    q[i + 1] = And(q[i], Equals(a[i], b[i]));
  end for;
  s = Id(q[N]);
end where;

Equals2[N](a:[N], b:[N]) = s:[N]
where
  for i = 0 to N - 1
    s[i] = Equals(a[i], b[i]);
  end for;
end where;

/**
 * Binary Decision Diagram. Useful to select an input value among many by using
 * some input decision bits.
 *
 * @param N: number of inputs total. Should be a power of 2.
 * @param D: width of each input
 *
 * There are log N bits of decision to select the input.
 *
 * @input input:[N]:[D] a complete tree of N leaves of width D
 * @input decision:[log(N)] the selector bits for the decision
 * @output s:[D] the value of the selected input
 *
 * Decision bits are expected with the least significant bits to the left.
 * Leaves are indexed from index 0 to N-1.
 */
Bdd[N][D](input:[N]:[D], decision:[log N]) = s:[D]
where
  for i = 0 to N - 1
    br[0][i]:[D] = Id[D](input[i]:[D]);
  end for;
  for i = 1 to log N
    for j = 0 to N / 2 ^ i - 1
      br[i][j]:[D] =
        Mux[D](
          decision[i - 1],
          br[i - 1][2 * j + 1]:[D],
          br[i - 1][2 * j]:[D]);
    end for;
  end for;
  s:[D] = Id[D](br[log N][0]:[D]);
end where;

/**
 * ReverseBdd transforms a Bdd decision word into a vector where exactly one
 * component is true and all the rest is false. The component that is true is at
 * the address selected by the decision vector.
 */
ReverseBdd[N](in, dec:[N]) = out:[2 ^ N]
where
  s[-1][0] = Id(in);
  for i = 0 to N - 1
    for j = 0 to 2 ^ i - 1
      s[i][2 * j] = Mux(dec[N - 1 - i], Gnd(), s[i - 1][j]);
      s[i][2 * j + 1] = Mux(dec[N - 1 - i], s[i - 1][j], Gnd());
    end for;
  end for;
  for i = 0 to 2 ^ N - 1
    out[i] = Id(s[N - 1][i]);
  end for;
end where;

/**
 * Copy the input signal N times.
 */
Vectorize[N](a) = b:[N]
where
  for i = 0 to N - 1
    b[i] = Id(a);
  end for;
end where;

FullAdder(a, b, c) = (s, r)
where
  s = Xor(Xor(a, b), c);
  r = Or(Or(And(a, b), And(a, c)), And(b, c));
end where;

/**
 * This is a register with a semantic of anticipation: in case the input is
 * enabled, the output directly echos the input signal rather than waiting one
 * cycle. If the input is not enabled, it keeps its previous value.
 */
Var(set, en) = get
where
  r_out = RegEn(set, en);
  get = Mux(en, set, r_out);
end where;

Var[N](set:[N], en) = get:[N]
where
  for i = 0 to N - 1
    get[i] = Var(set[i], en);
  end for;
end where;

/// Counter on 1 bit
CM2(in) = (s, r)
where
  s = Xor(in, ro);
  ro = Reg(s);
  r = And(in, ro);
end where;

/// Counter modulo 2^D
CM[D](in) = out:[D]
with unused = r[D - 1]
where
  r[-1] = Id(in);
  for i = 0 to D - 1
    out[i], r[i] = CM2(r[i - 1]);
  end for;
end where;

/// Clock divider modulo 2^D
ClockDivider[D](in) = out
where
  out = Not(Or[D](CM[D](in)));
end where;

/// Addition on N bits, with carry in and out.
Add[N](r0:[N], r1:[N], carry_in) = (nr1:[N], carry_out)
where
  c[0] = Id(carry_in);
  for i = 0 to N - 1
    nr1[i], c[i + 1] = FullAdder(r0[i], r1[i], c[i]);
  end for;
  carry_out = Id(c[N]);
end where;

/// Subtraction : a - b = a + 1 + 2^AR - 1 -b = a + 1 + not(b)
Sub[AR](a:[AR], b:[AR]) = r:[AR]
where
  r:[AR], _ = Add[AR](a:[AR], Not[AR](b:[AR]), Vdd());
end where;

Pred[N](a:[N]) = r:[N]
where
  r:[N] = Sub[N](a:[N], Vdd(), Gnd[N - 1]());
end where;

Succ[N](a:[N]) = r:[N]
where
  r:[N], _ = Add[N](a:[N], Gnd[N](), Vdd());
end where;

Posedge(c) = en
where
  en = And(c, Not(Reg(c)));
end where;

Negedge(c) = en
where
  en = And(Not(c), Reg(c));
end where;
```

</details>
