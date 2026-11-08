# setup_environment

**Purpose:** restore the R, Python and Julia environments from the dependency files
committed at the repository root.

**Inputs** (repository root, committed):
- `renv.lock` (R, via `renv`; `.Rprofile` and `renv/activate.R` bootstrap renv itself)
- `requirements.txt` (Python, pinned; installed into `.venv/`)
- `Project.toml` and `Manifest.toml` (Julia)

**Outputs:**
- `R_library.txt`: path of the renv project library, used by `run_R` in `shell_functions.sh`
- `python_venv.txt`: full `pip freeze` of `.venv/`
- `julia_env.txt`: `Pkg.status()` of the Julia environment

`make` builds R and Python. `make julia` builds Julia.
Tasks build the environment they need automatically through their order-only prerequisites.

**Adding a package**
- R: in R at the repository root, `renv::install("pkg")`, then `renv::snapshot()`.
- Python: add a pinned line (`pkg==x.y.z`) to `requirements.txt`, then `make python`.
- Julia: `julia --project=.` at the root, then `] add Pkg`; commit both TOML files.

Commit the updated dependency file in the same pull request as the code that needs it.
