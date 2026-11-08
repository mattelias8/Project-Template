test_that("assert_key passes a unique, complete key and returns the table", {
  dt <- data.table::data.table(county = c(1, 1, 2), year = c(2000, 2001, 2000), y = 1:3)
  expect_identical(assert_key(dt, c("county", "year")), dt)
})

test_that("assert_key stops on duplicated keys", {
  dt <- data.table::data.table(county = c(1, 1, 2), y = 1:3)
  expect_error(assert_key(dt, "county"), "not unique: 1 duplicated rows")
})

test_that("assert_key stops on missing key values", {
  dt <- data.frame(county = c(1, NA, 2), year = c(NA, NA, 2000))
  expect_error(assert_key(dt, c("county", "year")), "county \\(1\\), year \\(2\\)")
})

test_that("assert_key stops on absent key columns", {
  expect_error(assert_key(data.frame(a = 1), c("a", "b")), "not in table: b")
})
