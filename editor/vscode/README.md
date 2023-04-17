# Visual Studio Code Bopkit Extension

https://github.com/mbarbin/bopkit/tree/main/editor/vscode

This directory defines a basic visual studio code extension for bopkit, to
support syntax highlighting, snippets completion and auto-format.

:::note

This is experimental and hasn't been tested much at the moment.

:::

## Install

It should be enough to copy the files to your local vscode extensions path and
restart vscode.

## Auto-formatting

Currently the way we've set up auto-formatting for bopkit files in vscode is
through a third party extension that allows you to configure external formatting
commands and associate them with languages id.

The extension in question is this one:

https://marketplace.visualstudio.com/items?itemName=Vehmloewff.custom-format

After installing the bopkit extension, we've configured custom-format with the
following lines:

```json
    "custom-format.formatters": [
        {
            // Whatever language id you need to format
            "language": "bopkit",
            // The command that will be run to format files with the language id specified above
            // $FILE is replaced with the path of the file to be formatted
            "command": "bopkit fmt file $FILE -read-contents-from-stdin -add-extra-blank-line"
        },
```