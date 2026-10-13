# python/astral/lib

Python library on the Astral toolchain (uv, ruff, ty).

Sources live in `src/` and `tests/`; `uv sync --extra dev` installs the dev
extra. All targets run with the project directory as the working directory
unless the manifest overrides it.

## Params

- `config_path` — ruff/pytest config location (default `pyproject.toml`).
  Override it in a project's smith.yml when the config lives elsewhere.
