test_that("save_table writes Parquet and a data report", {
  dt <- data.table::data.table(county = 1:3, sales = c(1.5, NA, 3))
  path <- file.path(withr::local_tempdir(), "county.parquet")
  save_table(dt, path, key = "county")
  expect_equal(as.data.frame(arrow::read_parquet(path)), as.data.frame(dt))
  report <- readLines(sub("\\.parquet$", "_report.txt", path))
  expect_equal(report[1:3],
               c("Table: county.parquet", "Rows: 3", "Key: county (unique, non-missing)"))
  expect_match(report[length(report)], "^  sales +numeric +1$")
})

test_that("save_table writes small CSVs and refuses large ones", {
  dt <- data.table::data.table(id = 1:20)
  folder <- withr::local_tempdir()
  save_table(dt, file.path(folder, "small.csv"), key = "id")
  expect_equal(nrow(data.table::fread(file.path(folder, "small.csv"))), 20)
  expect_error(save_table(dt, file.path(folder, "big.csv"), key = "id", max_csv_rows = 10),
               "write Parquet")
})

test_that("save_table checks the key before writing anything", {
  dt <- data.table::data.table(id = c(1, 1))
  path <- file.path(withr::local_tempdir(), "bad.parquet")
  expect_error(save_table(dt, path, key = "id"), "not unique")
  expect_false(file.exists(path))
})

test_that("save_table rejects unknown formats", {
  dt <- data.table::data.table(id = 1)
  expect_error(save_table(dt, file.path(tempdir(), "x.rds"), key = "id"), "unsupported")
})
