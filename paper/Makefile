# Compile the paper with latexmk (shared settings in ../.latexmkrc).
# Files under input/ are symlinks to task outputs: add one rule per file under INPUT RECIPES.
SECTIONS = $(shell grep -v '^ *%' paper.tex | grep -o 'sections/[A-Za-z0-9_]*\.tex')
INPUTS = $(sort $(shell grep --no-filename -v '^ *%' paper.tex $(SECTIONS) \
	| grep -o '{\(\.\/\)\{0,1\}input/[A-Za-z0-9_.-]*\.[a-z]*' | sed 's|^{\(\.\/\)\{0,1\}||'))

all: paper.pdf

paper.pdf: paper.tex $(SECTIONS) $(INPUTS)
	latexmk -interaction=nonstopmode -halt-on-error paper.tex

.PHONY: all clean inputs
inputs: $(INPUTS)
clean:
	latexmk -C paper.tex
	rm -rf input

input/:
	mkdir -p $@

## INPUT RECIPES: link each task output the paper uses. Links are relative to input/.
input/sum_macros.tex: ../tasks/example_sum/output/sum_macros.tex | input/
	ln -sf ../$< $@

# Build a missing task output by running make in the task that produces it
../tasks/%:
	$(MAKE) -C ../tasks/$(firstword $(subst /, ,$*))/code \
		../$(patsubst $(firstword $(subst /, ,$*))/%,%,$*)
