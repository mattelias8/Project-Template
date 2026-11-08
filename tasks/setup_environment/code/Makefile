# Restore the project's software environments from the committed dependency files
# at the repository root: renv.lock (R), requirements.txt (Python), Project.toml and
# Manifest.toml (Julia). Tasks pull in only what they need via R_OOPR, PYTHON_OOPR
# or JULIA_OOPR in generic.make, so a project that never uses Julia never needs it.
include ../../generic.make

PYTHON_BASE ?= python3

all: R python

.PHONY: R python julia
R: ../output/R_library.txt
python: ../output/python_venv.txt
julia: ../output/julia_env.txt

# renv bootstraps itself through renv/activate.R (sourced by the root .Rprofile).
# The output records the project library path that run_R passes to Rscript --vanilla.
../output/R_library.txt: ../../../renv.lock | ../output/
	cd ../../.. && Rscript -e 'renv::restore(prompt = FALSE)' \
		-e 'writeLines(renv::paths$$library(), "tasks/setup_environment/output/R_library.txt")'

# The output is the full `pip freeze`, a record of every installed version.
../output/python_venv.txt: ../../../requirements.txt | ../output/
	$(PYTHON_BASE) -m venv ../../../.venv
	../../../.venv/bin/python -m pip install --quiet --upgrade pip
	../../../.venv/bin/python -m pip install --quiet -r $<
	../../../.venv/bin/python -m pip freeze > $@

# Pkg.instantiate() writes Manifest.toml on first run; commit it afterwards.
../output/julia_env.txt: ../../../Project.toml $(wildcard ../../../Manifest.toml) | ../output/
	julia --project=../../.. --startup-file=no -e 'using Pkg; Pkg.instantiate(); Pkg.status()' > $@
