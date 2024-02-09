## 0.2.5 (2024-02-09)

### Changed

- Internal changes related to the release process.
- Upgrade dune and internal dependencies.

## 0.2.4 (2024-01-18)

### Changed

- Internal changes related to build and release process.
- Rename most file path variables from [filename] to [path] and switch from type
  [string] to [Fpath.t] (#7, @mbarbin).
- Extract some libraries into their own packages to reuse in other projects:
  `auto-format`, `error-log`, `loc`, `parsing-utils` (#7, @mbarbin).

## 0.2.3 (2023-11-03)

### Changed

- Migrate Docusaurus config files to TypeScript.

### Fixed

- Fix `bopkit -version`. There are subtle differences between using
  `public_name` and `(install (section bin))` which I do not understand yet, but
  using the latter disables dune-build-info.

## 0.2.2 (2023-11-03)

### Changed

- Now generating opam file from dune-project.

### Fixed

- Use `command-unix-for-opam` to fix `-version` for all binaries.
- Fix dune-install invocation to locate shared files at runtime (#6).

## 0.2.1 (2023-11-02)

### Changed

- Change changelog format to be closer to dune-release's.
- Now building distribution with `dune-release`.
- Internal refactoring related to -open via flags.

### Fixed

- `bopkit -version` now prints the distribution version correctly.

## 0.2.0 (2023-10-30)

### Added

- Added docusaurus documentation website, publish to GitHub Pages.
- Added changelog.
- Added pretty-printers for all languages. Integrate it to dune-fmt.

### Changed

- Rename project from 'bebop' to 'bopkit'.
- Now building with dune.
- Make tests compatible with dune-promote mechanism.
- Standardize install procedure: now uses opam + dune-site.
- Migrate all parsers to Menhir.
- Rewrite the bopboard in OCaml using tsdl (it was in C and using SDL-1 which is now deprecated).
- Rewrite visa assembly tool from C to OCaml.
- Group executables into a single CLI named 'bopkit'.
- In external blocks, always use method_name as implementation_name, merge the two concepts.

### Fixed

- Fixed nondeterministic failure in visa assembler to machine-code. This was
  fixed as part of the rewrite to OCaml.

### Removed

- Removed bopipe and bopin. Replaced bpo and bpi files by external blocks construction in OCaml.
- Removed bop2vhdl. This was highly experimental and untested.
- Removed bop2xml. This wasn't used by any project.

## 0.1.1 (2007/2008)

Project didn't have a changelog then.
