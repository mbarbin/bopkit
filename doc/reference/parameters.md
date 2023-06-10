# Parameters

Parameters are variables that allow some genericity when defining components for
a circuit.

## Circuit's parameters

Parameters may optionally be defined at the top of a circuit, right after the
include section. Example:

```bopkit
#define N 4
```

Parameters may be of type `int` or `string`. When including a file that defines some parameters, these parameters may be overridden. This constitutes a mechanism by which all the components that a file brings to scope may be parametrized by some collection of values.

:::info

Parameters may be defined out of order, as long as there exists a valid topological order that allows their complete evaluation.

:::

## Block's parameters

Blocks with parameters are called `parametrized blocks`. Their parameters are local to the block definition, and arguments must be supplied for all parameters on block invocation. Example:

<!-- $MDX file=parametrized-block.bop -->
```bopkit
NotAnd[N](a:[N], b:[N]) = c:[N]
where
  for i = 0 to N - 1
    c[i] = Not(And(a[i], b[i]));
  end for;
end where;

Main(a:[2], b:[2]) = c:[2]
where
  c:[2] = NotAnd[2](a:[2], b:[2]);
end where;
```

## Using parameters in other constructs

### Arithmetic expressions and control structures

Parameters may be variables in places expecting an arithmetic or conditional
expression. It that case they're expected to have type `int`. In particular in
control structures:

<!-- $MDX file=and2_recursive.bop -->
```bopkit
And2[N](e:[N]) = s
where
  if N == 1 then
    s = Id(e[0]);
  else
    s = And(And2[N - 1](e:[N - 1]), e[N - 1]);
  end if;
end where;

Main(e:[8]) = s
where
  s = And2[8](e:[8]);
end where;
```

### Strings with vars

It is possible to inject parameters into string values, using the syntax `%{_}`.
For example, you may have external blocks whose command depends on the value of
a parameter.

```bopkit
#define N 8

external my_calculator "./my_calculator.exe -n %{N}"
  def add
  def sub
  // ...
end external;
```

The string representation of the parameters is injected in the string, so this works for parameters of any type.
