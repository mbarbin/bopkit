#!/bin/bash -e

# Parse command line options
PROCESS_BOP=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --bop)
            PROCESS_BOP=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--bop]" >&2
            echo "  --bop: Process .bop files (disabled by default due to header formatting conflicts)" >&2
            exit 1
            ;;
    esac
done

DIRS_FILE="$(dirname "$0")/.headache.dirs"

if [ ! -f "$DIRS_FILE" ]; then
    echo "Directory list file '$DIRS_FILE' not found!" >&2
    exit 1
fi

while IFS= read -r dir; do
    # Ignore empty lines and lines starting with '#'
    [ -z "$dir" ] && continue
    case "$dir" in
        \#*) continue ;;
    esac
    echo "Apply headache to directory ${dir}"

    # Check if .ml files exist in the directory, if so apply headache
    if ls "${dir}"/*.ml 1> /dev/null 2>&1; then
        headache -c .headache.config -h COPYING.HEADER "${dir}"/*.ml
    fi

    # Check if .mli files exist in the directory, if so apply headache
    if ls "${dir}"/*.mli 1> /dev/null 2>&1; then
        headache -c .headache.config -h COPYING.HEADER "${dir}"/*.mli
    fi

    # Check if .bop files exist in the directory, if so apply headache (only if
    # --bop flag is set) NOTE: Headers in .bop files conflict with the bop
    # parser and auto-formatter. No header format currently works with headache
    # + bop tooling, requiring manual fixes.
    if [ "$PROCESS_BOP" = true ] && ls "${dir}"/*.bop 1> /dev/null 2>&1; then
        headache -c .headache.config -h COPYING.HEADER "${dir}"/*.bop
    fi
done < "$DIRS_FILE"

echo "Now reformat the files with: dune fmt"
dune fmt
