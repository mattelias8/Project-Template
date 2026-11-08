# Project template

A starting point for empirical economics projects in R, Python, Julia and LaTeX.
Work is organised as tasks, each with its own `input/`, `code/` and `output/` folders, linked
by symbolic links and run with `make`, so one command rebuilds every result, table, the paper,
the slides and the logbook from the raw data.
Environments are pinned (`renv`, `requirements.txt`, `Project.toml`), every number in the text
comes from a task output, and `CLAUDE.md` encodes the conventions for Claude Code.

## Start a new project

1. Create the repository from this template and clone it:
   ```bash
   gh repo create <name> --template <your-github-username>/projecttemplate --private --clone
   ```
2. Fill in the **Project** block at the top of `CLAUDE.md`.
3. Copy your real style files into `latex/` over the placeholders (`mystyle.sty`,
   `mybeamer.sty`, `macros.tex`), and your references into `bib/references.bib`.
4. Restore the environments for the languages you use, in `tasks/setup_environment/code/`:
   `make R`, `make python` (needs Python 3) and/or `make julia` (needs Julia, e.g. via `juliaup`).
   Tasks also build the environment they need on first use.
5. Delete `tasks/example_numbers` and `tasks/example_sum`, remove them from `TASKS` in the
   top-level `Makefile`, and remove the example input rules and sentences from `paper/`,
   `slides/` and `logbook/`.
6. Replace the TODO title and author in `paper/paper.tex` and `slides/slides.tex`.

New machine setup (Homebrew, BasicTeX, R, Julia) is in `tasks/onboarding/`.
The logbook (`make -C logbook`, then open `logbook/logbook.pdf`) explains the workflow in
detail, including how this template adapts Dingel's original.

## Commands

| Command (at the root) | What it does |
|---|---|
| `make` | Task graph, every task in `TASKS` order, then paper, slides and logbook |
| `make TEST=TRUE` | Every task on the first `TEST_NROWS` rows (default 1000), writing to `output/test/` |
| `make test` | Unit tests for `lib/R` (`testthat`) |
| `make lint` | `lintr` on R files; `ruff` on Python files if there are any |
| `make clean` | Delete every task's `input/` and `output/` |

In a task's `code/` folder, `make`, `make TEST=TRUE` and `make clean` do the same for that
task, building any missing upstream outputs first.

## Structure

```
.
├── CLAUDE.md                  # conventions for Claude Code; fill in the Project block
├── Makefile                   # top-level build
├── run_all.R                  # fallback runner where make and symlinks are unavailable
├── renv.lock  .Rprofile  renv/        # R environment (renv)
├── requirements.txt                    # Python environment (.venv/)
├── Project.toml  (Manifest.toml)       # Julia environment
├── .lintr  ruff.toml  .JuliaFormatter.toml   # style: lines ≤ 100 characters
├── .latexmkrc                 # puts latex/ and bib/ on LaTeX's search paths
├── .claude/settings.json      # stops Claude Code's file tools reading data files
├── .github/workflows/         # CI: Makefile checks, R tests and lint, LaTeX, style
├── latex/                     # shared .sty files and macros (placeholders)
├── bib/                       # references.bib and the AEA bibliography style
├── lib/R/                     # shared R helpers (helpers.R) and tests/
├── paper/  slides/  logbook/  # LaTeX; each links task outputs into its input/
└── tasks/
    ├── generic.make  shell_functions.make  shell_functions.sh   # shared Make rules
    ├── setup_environment/     # restores the R, Python and Julia environments
    ├── task_graph/            # draws the task dependency graph (needs graphviz)
    ├── actions_scripts/       # scripts used by CI
    ├── onboarding/            # new-machine setup
    └── example_numbers/  example_sum/   # trivial example: one task linking another
```

The same `lib/R` pattern applies to other languages if a project needs it: `lib/python/`
with `pytest`, or `lib/julia/` with `Test`.

## Notes

- **Data stay out of git.** `.gitignore` excludes task inputs and outputs, data formats
  (`.parquet`, `.rds`, `.feather`, `.arrow`, `.dta`, `.jld2`), all CSV and PDF files, and
  LaTeX build files.
- **Claude Code permissions.** `.claude/settings.json` denies Claude Code's Read tool access to
  task `input/` folders and data files, and Claude Code applies those rules to Grep and Glob on
  a best-effort basis. They do not cover shell commands such as `cat` or `head`, so the data
  rules in `CLAUDE.md` still matter.
- **Windows and secure environments.** Where `make` or symbolic links are unavailable (for
  example ABS DataLab virtual machines), keep the same task folders and run the tasks in order
  with `Rscript run_all.R`. It copies upstream outputs into each `input/` folder instead of
  linking them. This keeps the work modular but loses automatic dependency tracking: it reruns
  everything, and its list of steps must be kept in sync with the Makefiles by hand.

## Credits

- Jonathan Dingel's [projecttemplate](https://github.com/jdingel/projecttemplate): the task
  structure, Make machinery, task graph, CI checks and the logbook, which is kept in full.
- Joshua Gottlieb, *Research Workflow Tools and Structure* (UChicago slides): the workflow
  criteria, YAML configuration, test modes and pinned environments.
- Matthew Gentzkow and Jesse Shapiro,
  [*Code and Data for the Social Sciences: A Practitioner's Guide*](https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf)
  (2014): the rules on automation, directories, keys, abstraction and documentation.
