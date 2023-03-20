# GtkSourceView

[GtkSourceView](https://gnome.pages.gitlab.gnome.org/gtksourceview/gtksourceview5/)
is a GNOME library that extends GtkTextView, the standard GTK widget for
multiline text editing. GtkSourceView includes support for syntax highlighting.

The Bopkit distribution includes a GtkSourceView language definition for bopkit
files `*.bop`, which should give you support for syntax highlighting for editors
based on GtkSourceView, for example `gedit`.

## Supported versions

:::note

Bopkit language definition is using GtkSourceView's language definition version 2.

:::

The version 2 refers to the language definition file format, not to the version
of GtkSourceView. Version 2 of the language definition is suitable for
GtkSourceView 2, 3 and 4. More details can be found
[here](https://gnome.pages.gitlab.gnome.org/gtksourceview/gtksourceview5/lang-reference.html).

## Install

The preinstalled language files are located in
`${PREFIX}/share/gtksourceview-${GSV_API_VERSION}/language-specs/`.

Custom user languages are usually placed in
`~/.local/share/gtksourceview-${GSV_API_VERSION}/language-specs/`.

- `${PREFIX}` can be `/usr/` or `/usr/local/` if you have installed from source.
- Replace `${GSV_API_VERSION}` with `2.0` or `3.0` in the path for GtkSourceView
  version 2, 3, etc.

To install Bopkit language, simply copy the [bopkit.lang](bopkit.lang) file to
one of these locations, and restart `gedit` to pick it up. You should now see
`Bopkit` in the language dropdown, and the language mode should be enabled by
default on extension `.bop`.

## Contributing to the language specification

### Validating the file

GtkSourceView's
[lang-reference](https://gnome.pages.gitlab.gnome.org/gtksourceview/gtksourceview5/lang-reference.html).

The language definition is an XML file. It describes the meaning and usage of
every element and attribute.

The formal definition is stored in the [RelaxNG](https://relaxng.org/) schema
file `language2.rng` which should be installed on your system in the directory
`${PREFIX}/share/gtksourceview-${GSV_API_VERSION}/`.

We use [jing](https://manpages.ubuntu.com/manpages/xenial/man1/jing.1.html) to
validate the bopkit definition against the language specification file.

This is done in the script `./validate-lang-file.sh`:

```sh
$ ./validate-lang-file.sh
✅ Validation of bopkit.lang succeeded.
```

To contribute, open an PR and check that your updated file passes the
validation.