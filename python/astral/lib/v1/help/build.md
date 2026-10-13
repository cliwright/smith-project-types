# build

Builds source and wheel distributions with `uv build` into `dist/`.

The type's `depends_on` puts `lint` and `test` before `build`, so a bare
`smith <ns> <name> build` lints and tests first.
