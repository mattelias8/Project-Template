# example_sum

**Purpose:** a trivial downstream task showing how tasks connect: its Makefile symlinks
`example_numbers/output/numbers.csv` into `input/`. Delete it when starting a project.

**Inputs:** `numbers.csv` (from `example_numbers`).

**Outputs:** `sum_macros.tex`, defining `\exampleSum`, which the paper, slides and logbook
`\input`.
