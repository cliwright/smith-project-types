# smith-project-types

The versioned project-type registry for [Smith](https://github.com/cliwright/smith).
Project types define what a kind of project IS: capabilities, required tools,
and the targets Smith can run for it.

## Layout

```
python/astral/lib/v1/
├── project-type.json         # the type definition
└── project-type.json.sha256  # integrity sidecar (sha256sum format)
schemas/
└── project-type.schema.json  # the base contract every type validates against
```

Type names are `language/flavor/kind` (flavor is mandatory — `std` when the
language has a standard toolchain, otherwise an arbitrary string unique within
the language namespace). The version lives in the path (`v1/`) and in the file
(`"version": 1`) and the two must match.

## Publishing a new type or version

1. Create `<language>/<flavor>/<kind>/v<N>/project-type.json` and validate it
   against `schemas/project-type.schema.json`.
2. Generate the sidecar in the same directory:
   `sha256sum project-type.json > project-type.json.sha256`
   (on macOS without coreutils: `shasum -a 256 project-type.json | awk '{print $NF"  project-type.json"}' > project-type.json.sha256`)
3. `task verify` — every sidecar must pass.
4. Commit and push.

The sidecar is the publisher's integrity attestation. At `smith sync` time the
hash is recorded in each consumer repo's `.smith/lock.json`; smith hard-errors
on any mismatch, so a sidecar must be regenerated whenever its file changes.
