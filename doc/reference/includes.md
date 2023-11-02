# Includes

Bopkit projects are broken down into multiple `.bop` files. The files may refer
to each other thanks to an inclusion construct which is described here.

:::tip

When present, includes must necessarily be located at the very top of the file,
before any other construct. Having an include in the middle of a file is going
to trigger a syntax error.

:::

The actual syntax will change depending on whether to include a file coming from
the bopkit distribution, or a file in the users' project.

## Including files from the distribution

The name of the file will be surrounded by the chars `<...>`. For example:

```bopkit
#include <stdlib.bop>
#include <pulse.bop>
```

These files are installed with bopkit and the simulator should known where to
find them. To trouble shoot an installation, you may run the following command,
which should print out the location of the stdlib files:

<!-- $MDX skip -->
```sh
$ bopkit print-sites
(stdlib (/home/$USER/.opam/5.1.0/share/bopkit/stdlib))
 ...
```

:::warning

Certain included filenames from the distribution must be quoted.

```bopkit
#include <"7_segment.bop">
```

If an include triggers a syntax error, try and quote the filename. The pretty
printer will remove the quotes if they're not needed. This part of bopkit is
unstable and may change in the future.

:::

## Including files from the user's project

In this case the name of the file will be quoted. For example:

```bopkit
#include "my_other_file.bop"
```

:::info

It is OK for includes to create cyclic dependencies between files, as long as there exists a valid topological ordering of your blocks to create your final circuit.

:::
