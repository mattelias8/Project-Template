test_that("read_config returns the YAML contents", {
  path <- withr::local_tempfile(fileext = ".yaml", lines = c("seed: 42", "years: [2000, 2001]"))
  config <- read_config(path, required = c("seed", "years"))
  expect_equal(config$seed, 42)
  expect_equal(config$years, c(2000, 2001))
})

test_that("read_config names the missing required keys", {
  path <- withr::local_tempfile(fileext = ".yaml", lines = "seed: 42")
  expect_error(read_config(path, required = c("seed", "years", "n")),
               "missing required keys: years, n")
})

test_that("read_config stops when the file does not exist", {
  expect_error(read_config("no_such_config.yaml"), "Config file not found")
})
