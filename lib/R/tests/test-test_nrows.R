test_that("test_nrows is Inf outside test mode", {
  withr::local_envvar(TEST = "FALSE")
  expect_equal(test_nrows(), Inf)
})

test_that("test_nrows returns TEST_NROWS in test mode", {
  withr::local_envvar(TEST = "TRUE", TEST_NROWS = "250")
  expect_identical(test_nrows(), 250L)
})

test_that("test_nrows rejects a bad TEST_NROWS", {
  withr::local_envvar(TEST = "TRUE", TEST_NROWS = "many")
  expect_error(test_nrows(), "positive integer")
})

test_that("Inf rows reads the whole table", {
  dt <- data.table::data.table(x = 1:5)
  expect_equal(nrow(head(dt, Inf)), 5)
})
