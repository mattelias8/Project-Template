test_that("parse_args returns a named list when every argument is valid", {
  input_file <- withr::local_tempfile(lines = "x")
  output_file <- file.path(tempdir(), "out.parquet")
  spec <- c(lib = "dir", data = "input", out = "output", n = "value")
  args <- parse_args(spec, args = c(tempdir(), input_file, output_file, "5"))
  expect_equal(names(args), names(spec))
  expect_equal(args$n, "5")
})

test_that("parse_args stops on the wrong number of arguments", {
  expect_error(parse_args(c(a = "value", b = "value"), args = "1"),
               "Expected 2 arguments \\(a, b\\) but got 1")
})

test_that("parse_args names every missing input, folder and output folder", {
  spec <- c(data = "input", lib = "dir", out = "output")
  args <- c("no_such_file.csv", "no_such_dir", "no_such_dir/out.parquet")
  expect_error(parse_args(spec, args = args), "data = no_such_file.csv: input file not found")
  expect_error(parse_args(spec, args = args), "lib = no_such_dir: folder not found")
  expect_error(parse_args(spec, args = args), "output folder not found")
})

test_that("parse_args rejects a malformed spec", {
  expect_error(parse_args(c("value"), args = "1"), "named character vector")
  expect_error(parse_args(c(a = "value", a = "value"), args = c("1", "2")), "duplicate")
  expect_error(parse_args(c(a = "file"), args = "1"), "unknown kinds file")
})
