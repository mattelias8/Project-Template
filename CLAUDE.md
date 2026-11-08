# CLAUDE.md

## Project

<!-- Replace when starting a new project -->
- **Title:** TODO
- **Question:** TODO (one or two sentences)
- **Data:** TODO (sources, access restrictions, where raw data lives)
- **Languages used:** TODO (R / Python / Julia)
- **Coauthors:** TODO

## Repository structure

The project is a set of **tasks** in `tasks/`. Each task:

```
tasks/<task_name>/
├── readme.md   # purpose, inputs, outputs
├── input/      # symlinks to upstream outputs (created by Makefile; gitignored)
├── code/       # Makefile, scripts, config YAML
└── output/     # everything the task produces (gitignored)
```

Test runs use `input/test/` and `output/test/` instead.

Other folders: `paper/`, `slides/`, `logbook/` (LaTeX), `bib/`, `latex/` (shared styles via
`TEXINPUTS` in `.latexmkrc`), `lib/R/` (shared helpers in `helpers.R`, tests in `tests/`).
Environment files are at the root: `renv.lock`, `requirements.txt`, `Project.toml`,
`Manifest.toml`; `tasks/setup_environment` restores them.
`make` in `tasks/task_graph/code/` regenerates the dependency diagram.
Copy `tasks/example_numbers` (no inputs) or `tasks/example_sum` (one linked input) when
scaffolding a new task, then add it to `TASKS` in the top-level `Makefile`.

## Hard rules

1. A task writes **only** to its own `output/` and reads **only** from its own `input/`
   (symlinks made by its Makefile). Raw data outside the repo is the one exception:
   read-only, with its path defined once in the Makefile.
2. **Relative paths** everywhere. No `setwd()`, `os.chdir()`, `cd()`, `/Users/...`, or `~`.
3. Do not fix a downstream problem by editing an upstream task without saying so.
4. Never commit `tasks/*/input/`, `tasks/*/output/`, data files (including CSV), PDFs, or
   credentials. `.gitignore` enforces most of this; do not override it.
5. **Every number in the paper, slides, or logbook comes from a task output.**
   Never type a result by hand or copy one from a console.
6. Before committing, `make clean && make` in every changed task and everything
   downstream. Committed code must run from scratch.

## Data

- Every saved table has a unique, non-missing key (`assert_key()` / `save_table()`).
- Keep data normalised as long as possible: build normalised tables, add derived variables
  while still normalised, then do the final merge with **no transformations in the merge
  step**.
- Variables live at the level they describe.
- Do not open, print, `head`, or summarise raw or confidential microdata into the
  conversation. Inspect structure via code (names, types, row counts, key checks) or read
  the `*_report.txt` data reports that `save_table()` writes.
- Anything leaving a secure environment is subject to disclosure and cell-size rules.
  Flag doubts; do not proceed.

## New task workflow

1. Open or confirm a GitHub issue; branch with `git checkout -b <task_name>`.
2. Write `readme.md` (purpose, inputs, outputs).
3. Write the Makefile first, as pseudocode; the first target is `all`.
4. Write the scripts.
5. Run `make -n`, then `make TEST=TRUE`, then the full `make`.
6. Small commits with descriptive messages; one task per PR; squash and merge.

## Task design

- Separate slow tasks (estimation, simulation) from fast tasks (tables, figures, summary
  stats), so presentation changes never re-run estimation.
- Slow tasks store "too much": full fitted objects and all parameters.
- Abstract into `lib/` only to remove real duplication or improve clarity, and add a unit
  test when you do. Otherwise don't abstract. Functions shared by scripts within one task
  go in a file in that task's `code/`.

## Make

- Task Makefiles start with `include ../../generic.make` and
  `include ../../shell_functions.make`, then `all:` (targets use `$(T)`, defined there).
- Write targets as `../output/$(T)file` and inputs as `../input/$(T)file`; `$(T)` is
  `test/` under `TEST=TRUE`.
- Link inputs with one explicit rule per file:
  `../input/$(T)x.parquet: ../../upstream/output/$(T)x.parquet | ../input/$(T)` then `$(LINK)`.
- Run scripts with `$(R)`, `$(PYTHON)` or `$(JULIA)`; use `| $(R_OOPR)` (or
  `$(PYTHON_OOPR)`, `$(JULIA_OOPR)`) as the order-only prerequisites.
- Recipe lines start with a TAB. One recipe per target. Use `$@`, `$<`, `$^`.
  macOS ships GNU Make 3.81: no grouped targets (`&:`). When one script writes two files,
  use a pattern rule with two targets, and link each file downstream with its own rule.
- Scripts get input paths, output paths, and parameters as arguments from the Makefile.
  R scripts get `$(LIB_R)` first. Nothing the Makefile cannot see should determine an output.
- Support `TEST=TRUE` (first `TEST_NROWS` rows via `test_nrows()` or `read_table()`).
- At the root: `make` (everything), `make TEST=TRUE`, `make test` (unit tests),
  `make lint`, `make clean`.

## All languages

- Validate arguments at the top of every script; fail loudly with clear messages.
- No hardcoded constants or globals; read YAML config passed as an argument.
- Functions are "shy" (explicit inputs and outputs, minimal arguments), ≲ 80 lines, and
  ordered for top-to-bottom reading. Scripts no more than a few hundred lines.
- Descriptive snake_case names; abbreviate only when unambiguous and consistent.
- Set off key algebra; break long expressions into named steps; match whiteboard notation.
- Logical tests say what you mean (`all(x == 0)`, not `max(x) == 0`).
- Guards are code (assertions, informative errors), not "don't do X" comments.
- Comments explain *why* and cite sources; compute constants from their components rather
  than restating them in comments. Don't write comments you won't maintain.
- Read only needed columns, set types explicitly, filter before merging, prefer Parquet for
  large intermediates. Profile anything that takes more than a minute.
- Lines ≤ 100 characters.

## R

- Scripts run through `$(R)`: `Rscript --vanilla` with the renv project library.
  Add packages with `renv::install()` at the root, then `renv::snapshot()` (updates `renv.lock`).
- Start each script by sourcing `helpers.R` from the `lib_r` argument, then `parse_args()`.
  Use `read_config()`, `read_table()`, `save_table()`, `write_tex_macros()` from `lib/R/`.
- `data.table` idioms (`fread`/`fwrite`, `[i, j, by]`, `:=`); avoid tidyverse unless asked.
- Style checked by `.lintr` (`make lint`).

## Python

- Scripts run through `$(PYTHON)` (the project `.venv`); pin new packages in
  `requirements.txt` (`pkg==x.y.z`), then `make python` in `tasks/setup_environment/code`.
- `argparse` for arguments; `pathlib` for paths; type hints on functions.
- Use the Parquet/Arrow tools already in `requirements.txt` for large data.
  Style checked by `ruff` (`ruff.toml`).

## Julia

- Scripts run through `$(JULIA)`: `julia --project=<repo root>`; add packages with `Pkg` so
  `Project.toml` and `Manifest.toml` update.
- Put code in functions, not global scope (performance and clarity).
  Style checked by JuliaFormatter (`.JuliaFormatter.toml`).

## LaTeX

- One sentence per line. Use `latex/` styles and macros; check there before adding packages.
- Compile with `latexmk` (or `make` in `paper/`, `slides/`, `logbook/`). Tables, figures,
  and in-text numbers come from task outputs, linked into each document's `input/` by its
  Makefile.

## Working with me

- State a plan and the files you will touch before large changes.
- On failure, report the actual error and your diagnosis before changing code.
- Prefer editing existing files; don't create notes or summary files unless asked.
- When done, say what was produced, where, and what you did not verify.
