# Bopkit Stdlib

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/bopkit-stdlib.png?raw=true"
    width='384'
    alt="Logo"
  />
</p>

## Syntax

Bopkit's standard library is made of `*.bop` files that may be included in
circuits using the `#include <file.bop>` syntax, such as:

```bopkit
#include <stdlib.bop>
#include <bopboard.bop>
// etc...
```

as well as executables that implements some common functionality as external
blocks that we want to make easily available to bopkit circuit, such as the
`bopboard`, `bopdebug`, 7-segment displays, memory-units with graphical windows,
etc.

## Install

The files and executables are installed via `dune-sites`, and found at runtime
by the simulator.

To troubleshoot an installation, you may run the following command which should
print the directories where the installation occurred:

<!-- $MDX skip -->
```bash
$ bopkit print-sites
```