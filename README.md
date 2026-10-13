# smith-project-types

The versioned project-type registry for [Smith](https://github.com/cliwright/smith).
Project types define what a kind of project IS: capabilities, required tools,
and the targets Smith can run for it.

## Layout

```
python/astral/lib/v1/
├── project-type.json                  # the type definition
├── project-type.json.sha256           # integrity sidecar (sha256sum format)
├── python-astral-lib@v1.ingot         # the packed artifact: a tar of
├── python-astral-lib@v1.ingot.sha256  #   project-type.json + scripts/ + help/
schemas/
└── project-type.schema.json           # the base contract every type validates against
```

Type names are `language/flavor/kind` (flavor is mandatory — `std` when the
language has a standard toolchain, otherwise an arbitrary string unique within
the language namespace). The version lives in the path (`v1/`) and in the file
(`"version": 1`) and the two must match.

## Publishing a new type or version

1. Create `<language>/<flavor>/<kind>/v<N>/project-type.json` and validate it
   against `schemas/project-type.schema.json`.
2. Generate the definition sidecar in the same directory:
   `sha256sum project-type.json > project-type.json.sha256`
   (on macOS without coreutils: `shasum -a 256 project-type.json | awk '{print $NF"  project-type.json"}' > project-type.json.sha256`)
3. `task publish` — packs every type into its ingot (`smith type pack`): the
   tar archive of `project-type.json` plus the type's `scripts/` and `help/`
   directories, plus the ingot's sidecar. `type pack` fails loudly when the
   directory position and the file disagree (wrong name or version), so an
   incoherent artifact can never be published.
4. `task verify` — every sidecar (definition and ingot) must pass.
5. Commit and push.

The sidecars are the publisher's integrity attestation. At `smith sync` time
the ingot hash is recorded in each consumer repo's `.smith/lock.json`; smith
hard-errors on any mismatch, so sidecars must be regenerated whenever their
files change. `smith sync` downloads exactly two files per type — the ingot
and its sidecar — and unpacks the ingot into `.smith/types/<name>@v<N>/`.
