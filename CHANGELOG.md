# Unreleased

## Added

- Added changelog.
- Added pretty-printers for all languages. Integrate it to dune-fmt.

## Changed

- Rename project from 'bebop' to 'bopkit'.
- Now building with dune.
- Make tests compatible with dune-promote mechanism.
- Standardize install procedure: now uses opam + dune-site.
- Migrate all parsers to Menhir.
- Rewrite the bopboard in OCaml using tsdl (it was in C and using SDL-1 which is now deprecated).
- Rewrite visa assembly tool from C to OCaml.
- Group executables into a single CLI named 'bopkit'.

## Fixed

- Fixed nondeterministic failure in visa assembler to machine-code. This was fixed as part of the rewrite to OCaml.

## Removed

- Removed bopipe and bopin. Replaced bpo and bpi files by external blocks construction in OCaml.
- Removed bop2vhdl. This was highly experimental and untested.
- Removed bop2xml. This wasn't used by any project.

# 0.1.1 / 0.1.0 - 2007/2008

Project didn't have a changelog then.
