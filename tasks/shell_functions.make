SHELL := bash
FUNCTIONS = $(shell cat ../../shell_functions.sh)
R = @$(FUNCTIONS); run_R
PYTHON = @$(FUNCTIONS); run_python
JULIA = @$(FUNCTIONS); run_julia

#If 'make -n' option is invoked, print readable commands instead of the function bodies
ifneq (,$(findstring n,$(firstword -$(MAKEFLAGS))))
R := R
PYTHON := PYTHON
JULIA := JULIA
endif
