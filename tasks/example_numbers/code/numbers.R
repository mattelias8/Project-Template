# Write a tiny table: the numbers 1 to 10.
lib_r <- commandArgs(trailingOnly = TRUE)[1]
source(file.path(lib_r, "helpers.R"))

args <- parse_args(c(lib_r = "dir", out = "output"))
save_table(data.frame(x = 1:10), args$out, key = "x")
