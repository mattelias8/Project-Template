include ../../generic.make
include ../../shell_functions.make

all: ../output/$(T)sum_macros.tex

# Link the upstream output into input/. If it does not exist yet, generic.make builds it
# by running make in example_numbers/code.
../input/$(T)numbers.csv: ../../example_numbers/output/$(T)numbers.csv | ../input/$(T)
	$(LINK)

../output/$(T)sum_macros.tex: sum.R ../input/$(T)numbers.csv $(LIB_R)/helpers.R | $(R_OOPR)
	$(R) $< $(LIB_R) ../input/$(T)numbers.csv $@
