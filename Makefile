# Rebuild the whole project: the task graph, every task, then paper, slides and logbook.
#   make              full rebuild
#   make TEST=TRUE    run every task in test mode (first TEST_NROWS rows, outputs in output/test/)
#   make test         unit tests for lib/
#   make lint         lintr on R code, ruff on Python code
#   make clean        clear every task's input/ and output/
SHELL := bash

# Tasks in the order they must run. Add each new task here.
TASKS = example_numbers example_sum

.PHONY: all tasks task_graph paper slides logbook test lint clean $(TASKS)

ifeq ($(TEST),TRUE)
all: tasks
else
all: task_graph tasks paper slides logbook
endif

tasks: $(TASKS)
$(TASKS):
	$(MAKE) -C tasks/$@/code

task_graph:
	$(MAKE) -C tasks/task_graph/code

paper slides logbook: tasks
	$(MAKE) -C $@

# R runs as in tasks: Rscript --vanilla with the renv project library
R_LIBRARY = tasks/setup_environment/output/R_library.txt
PYTHON_VENV = tasks/setup_environment/output/python_venv.txt
RSCRIPT = R_LIBS="$$(cat $(R_LIBRARY))" Rscript --vanilla
$(R_LIBRARY) $(PYTHON_VENV):
	$(MAKE) -C tasks/setup_environment/code ../output/$(notdir $@)

test: $(R_LIBRARY)
	$(RSCRIPT) -e 'testthat::test_dir("lib/R/tests", stop_on_failure = TRUE)'

R_FILES = $(wildcard *.R lib/R/*.R lib/R/tests/*.R tasks/*/code/*.R)
PYTHON_FILES = $(wildcard lib/python/*.py tasks/*/code/*.py)
lint: $(R_LIBRARY) $(if $(PYTHON_FILES),$(PYTHON_VENV))
	$(RSCRIPT) -e 'lints <- Filter(length, lapply(commandArgs(TRUE), lintr::lint))' \
		-e 'for (l in lints) print(l)' \
		-e 'if (length(lints) > 0) quit(status = 1)' $(R_FILES)
ifneq ($(PYTHON_FILES),)
	.venv/bin/ruff check $(PYTHON_FILES)
endif

clean:
	for task in $(TASKS); do $(MAKE) -C tasks/$$task/code clean; done
