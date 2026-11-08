# Sum the upstream numbers and write the result as a LaTeX macro for the paper.
lib_r <- commandArgs(trailingOnly = TRUE)[1]
source(file.path(lib_r, "helpers.R"))

args <- parse_args(c(lib_r = "dir", numbers = "input", out = "output"))
numbers <- read_table(args$numbers)
write_tex_macros(list(exampleSum = sum(numbers$x)), args$out)
