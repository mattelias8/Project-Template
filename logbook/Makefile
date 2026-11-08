# Compile the logbook with latexmk (shared settings in ../.latexmkrc).
# Files under input/ are symlinks to task outputs: add one rule per file under INPUT RECIPES.
ENTRIES = $(shell grep -v '^ *%' logbook.tex | grep -o 'entries/[A-Za-z0-9_-]*\.tex')
INPUTS = $(sort $(shell grep --no-filename -v '^ *%' logbook.tex $(ENTRIES) \
	| grep -o '{\(\.\/\)\{0,1\}input/[A-Za-z0-9_.-]*\.[a-z]*' | sed 's|^{\(\.\/\)\{0,1\}||'))

all: logbook.pdf

logbook.pdf: logbook.tex $(ENTRIES) $(INPUTS)
	latexmk -interaction=nonstopmode -halt-on-error logbook.tex

.PHONY: all clean inputs
inputs: $(INPUTS)
clean:
	latexmk -C logbook.tex
	rm -rf input

input/:
	mkdir -p $@

## INPUT RECIPES: link each task output the logbook uses. Links are relative to input/.
input/sum_macros.tex: ../tasks/example_sum/output/sum_macros.tex | input/
	ln -sf ../$< $@

# Build a missing task output by running make in the task that produces it
../tasks/%:
	$(MAKE) -C ../tasks/$(firstword $(subst /, ,$*))/code \
		../$(patsubst $(firstword $(subst /, ,$*))/%,%,$*)
