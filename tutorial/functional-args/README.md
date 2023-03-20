# Functional arguments

For added genericity, blocks may be defined with functional parameters (a block
that takes a block as an argument). This directory shows a few examples.

## Syntax

The functional arguments are to be added after the block name (and after the
block's integer parameters if any), and put them in between chars '<' and '>':

```text
block<fct> a = s
where
  s = fct(a);
end where;
```

In case of several arguments, they're comma separated. Here is another example,
from the stdlib:

```text
OneOutputToVector[N]<fun>() = o:[N]
where
  for i = 0 to N - 1
    o[i] = fun();
  end for;
end where;

gnd[N]() = o:[N]
where
  o:[N] = OneOutputToVector[N]<gnd>();
end where;
```
