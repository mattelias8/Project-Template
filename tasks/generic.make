# Shared rules for every task. Include this at the top of the task's Makefile, before
# `all`, because target names use $(T) below. `all` stays the default goal.
.DEFAULT_GOAL := all

# Test mode: `make TEST=TRUE` makes scripts read only the first TEST_NROWS rows.
# Test runs read from input/test/ and write to output/test/, so they never touch full outputs.
TEST ?= FALSE
TEST_NROWS ?= 1000
export TEST TEST_NROWS
ifeq ($(TEST),TRUE)
T := test/
else
T :=
endif

# Paths that scripts receive as arguments
ROOT := ../../..
LIB_R := $(ROOT)/lib/R

# Order-only prerequisites: folders, plus the environment for each language
SETUP := ../../setup_environment/output
OOPR = ../input/$(T) ../output/$(T)
R_OOPR = $(OOPR) $(SETUP)/R_library.txt
PYTHON_OOPR = $(OOPR) $(SETUP)/python_venv.txt
JULIA_OOPR = $(OOPR) $(SETUP)/julia_env.txt

../input/ ../output/ ../input/test/ ../output/test/:
	mkdir -p $@

# Recipe for symlinking an upstream output into input/. Usage:
#   ../input/$(T)x.parquet: ../../upstream/output/$(T)x.parquet | ../input/$(T)
#   	$(LINK)
# The link is relative to input/, which is one level deeper in test mode.
LINK = ln -sf $(if $(T),../)$< $@

# G&S: clearing outputs and rebuilding proves every output comes from current code.
# In test mode this clears only the test folders.
.PHONY: clean
clean:
	rm -rf ../input/$(T) ../output/$(T)

# Build a missing upstream file by running Make in the task that produces it.
# ../../<task>/output/[test/]<file>  ->  make -C ../../<task>/code ../output/[test/]<file>
upstream_task = $(firstword $(subst /, ,$*))
.PRECIOUS: ../../%
../../%:
	$(MAKE) -C ../../$(upstream_task)/code ../$(patsubst $(upstream_task)/%,%,$*)
