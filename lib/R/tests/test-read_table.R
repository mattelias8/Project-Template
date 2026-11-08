test_that("read_table reads Parquet and CSV, selecting columns", {
  dt <- data.table::data.table(id = 1:5, x = letters[1:5], y = 5:1)
  folder <- withr::local_tempdir()
  arrow::write_parquet(dt, file.path(folder, "t.parquet"))
  data.table::fwrite(dt, file.path(folder, "t.csv"))
  from_parquet <- read_table(file.path(folder, "t.parquet"), columns = c("id", "y"))
  expect_s3_class(from_parquet, "data.table")
  expect_equal(names(from_parquet), c("id", "y"))
  expect_equal(nrow(read_table(file.path(folder, "t.csv"))), 5)
})

test_that("read_table keeps only test_nrows() rows in test mode", {
  withr::local_envvar(TEST = "TRUE", TEST_NROWS = "2")
  dt <- data.table::data.table(id = 1:5)
  folder <- withr::local_tempdir()
  arrow::write_parquet(dt, file.path(folder, "t.parquet"))
  data.table::fwrite(dt, file.path(folder, "t.csv"))
  expect_equal(read_table(file.path(folder, "t.parquet"))$id, 1:2)
  expect_equal(read_table(file.path(folder, "t.csv"))$id, 1:2)
})

test_that("read_table rejects unknown formats", {
  expect_error(read_table("x.rds"), "unsupported")
})
