# Setting up your editor

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/bopkit-editor.png?raw=true"
    width='384'
    alt="Logo"
  />
</p>

In this directory you'll find basic support for some editors. This includes
syntax highlighting and autoformatting.

## Autoformatting

Bopkit comes with a pretty-printer for `*.bop` files, which you can set up for
your editor. If you develop a `bopkit` project, we recommend using `dune` as
the build system. You can checkout the source of bopkit to see how we integrated
this command to `dune fmt`.

<details open>

<summary>
Checkout: bopkit fmt file --help=plain
</summary>

```sh
$ bopkit fmt file --help=plain
NAME
       bopkit-fmt-file - autoformat bopkit files

SYNOPSIS
       bopkit fmt file [OPTION]… FILE



       This is a pretty-print command for bopkit files (extensions .bop).



       This reads the contents of a file supplied in the command line, and
       pretty-print it on stdout, leaving the original file unchanged.



       If [--read-contents-from-stdin] is supplied, then the contents of the
       file is read from stdin. In this case the filename must still be
       supplied, and will be used for located error messages only.



       In case of syntax errors or other issues, some contents may still be
       printed to stdout, however the exit code will be non zero (typically
       [1]). Errors are printed on stderr.



       The hope for this command is for it to be compatible with editors and
       build systems so that you can integrate autoformatting of files into
       your workflow.



       Because this command has been tested with a vscode extension that
       strips the last newline, a flag has been added to add an extra blank
       line, shall you run into this issue.

ARGUMENTS
       FILE (required)
           file to format.

OPTIONS
       --add-extra-blank-line
           add an extra blank line at the end.

       --color=WHEN (absent=auto)
           Colorize the output. WHEN must be one of 'auto', 'always' or
           'never'.

       -q, --quiet
           Be quiet. Takes over v and --verbosity.

       --read-contents-from-stdin
           read contents from stdin rather than from the file.

       -v, --verbose
           Increase verbosity. Repeatable, but more than twice does not bring
           more.

       --verbosity=LEVEL, --log-level=LEVEL
           Be more or less verbose. Takes over v. LEVEL must be one of
           'quiet', 'app', 'error', 'warning', 'info' or 'debug'.

       --warn-error
           Treat warnings as errors.

COMMON OPTIONS
       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of auto,
           pager, groff or plain. With auto, the format is pager or plain
           whenever the TERM env var is dumb or undefined.

       --version
           Show version information.

EXIT STATUS
       bopkit fmt file exits with:

       0   on success.

       123 on indiscriminate errors reported on standard error.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

SEE ALSO
       bopkit(1)

```

</details>
