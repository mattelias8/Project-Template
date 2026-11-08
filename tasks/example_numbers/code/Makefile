include ../../generic.make
include ../../shell_functions.make

all: ../output/$(T)numbers.csv

../output/$(T)numbers.csv: numbers.R $(LIB_R)/helpers.R | $(R_OOPR)
	$(R) $< $(LIB_R) $@
