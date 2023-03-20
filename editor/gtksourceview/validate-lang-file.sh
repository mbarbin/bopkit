#!/bin/bash -e

SPEC='language2.rng'
LANG='bopkit.lang'

if [ ! -e "$SPEC" ]; then
    SRC="/usr/share/gtksourceview-4/language-specs/$SPEC"
    if [ -e "$SRC" ]; then
        ln -sf $SRC $SPEC
    fi;
fi;

if [ ! -e "$SPEC" ]; then
    SRC="/usr/share/gtksourceview-3.0/language-specs/$SPEC"
    if [ -e "$SRC" ]; then
        ln -sf $SRC $SPEC
    fi;
fi;

if [ ! -e "$SPEC" ]; then
    echo "Couldn't locate $SPEC on your machine."
    exit 1
fi;

if jing $SPEC $LANG; then
    echo "✅ Validation of $LANG succeeded."
    exit 0
else
    echo "❌ Validation of '$LANG' failed."
    exit 1
fi;
