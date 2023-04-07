# Bopkit Stdlib

<p>
  <img src="https://github.com/mbarbin/bopkit/blob/assets/image/bopkit-stdlib.png?raw=true" alt="Logo"/>
</p>

Bopkit's standard library is made of `*.bop` files that may be included in
circuits using this syntax:

```text
#include <stdlib.bop>
```

as well as executables that implements some common functionality as external
blocks that we want to make easily available to bopkit circuit, such as the
`bopboard`, `bopdebug`, memory-units with graphical windows, etc.

The files and executables are installed via `dune-sites`, and found at runtime
by the simulator.
