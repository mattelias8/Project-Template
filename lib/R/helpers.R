# Shared helpers for R scripts in tasks/. A script's Makefile passes $(LIB_R) as the
# first argument; the script sources helpers.R from that folder before parse_args().
# See tasks/example_build/code/build.R for the pattern.
# Functions are ordered for top-to-bottom reading: each is defined after its first caller.
# Unit tests: lib/R/tests/ (run with `make test` at the repository root).

# Read and validate positional command-line arguments.
# `spec` is a named character vector: names are argument names, values are kinds.
#   "input"  a file that must exist
#   "dir"    a folder that must exist
#   "output" a file whose folder must exist
#   "value"  anything else (a number, a label)
# Returns a named list of argument values.
parse_args <- function(spec, args = commandArgs(trailingOnly = TRUE)) {
  arg_kinds <- c("input", "dir", "output", "value")
  if (!is.character(spec) || is.null(names(spec)) || !all(nzchar(names(spec)))) {
    stop("parse_args(): spec must be a named character vector")
  }
  if (anyDuplicated(names(spec))) {
    stop("parse_args(): duplicate argument names in spec: ",
         toString(unique(names(spec)[duplicated(names(spec))])))
  }
  unknown_kinds <- setdiff(spec, arg_kinds)
  if (length(unknown_kinds) > 0) {
    stop("parse_args(): unknown kinds ", toString(unknown_kinds),
         "; use one of ", toString(arg_kinds))
  }
  if (length(args) != length(spec)) {
    stop(sprintf("Expected %d arguments (%s) but got %d: %s",
                 length(spec), toString(names(spec)), length(args), toString(args)))
  }
  names(args) <- names(spec)

  problems <- c(
    describe_failures(args, spec == "input" & !file.exists(args), "input file not found"),
    describe_failures(args, spec == "dir" & !dir.exists(args), "folder not found"),
    describe_failures(args, spec == "output" & !dir.exists(dirname(args)),
                      "output folder not found")
  )
  if (length(problems) > 0) {
    stop("Invalid arguments:\n", paste0("  ", problems, collapse = "\n"))
  }
  as.list(args)
}

describe_failures <- function(args, failed, message) {
  sprintf("%s = %s: %s", names(args)[failed], args[failed], rep(message, sum(failed)))
}

# Read a YAML config file and stop if any required key is absent.
read_config <- function(path, required = character()) {
  if (!file.exists(path)) stop("Config file not found: ", path)
  config <- yaml::read_yaml(path)
  missing_keys <- setdiff(required, names(config))
  if (length(missing_keys) > 0) {
    stop("Config ", path, " is missing required keys: ", toString(missing_keys))
  }
  config
}

# Rows to read: TEST_NROWS when make runs with TEST=TRUE, otherwise Inf (all rows).
# Use as data.table::fread(path, nrows = test_nrows()) or head(dt, test_nrows()).
test_nrows <- function() {
  if (Sys.getenv("TEST") != "TRUE") return(Inf)
  n_rows <- suppressWarnings(as.integer(Sys.getenv("TEST_NROWS", "1000")))
  if (is.na(n_rows) || n_rows < 1) {
    stop("TEST_NROWS must be a positive integer, not '", Sys.getenv("TEST_NROWS"), "'")
  }
  n_rows
}

# Read a Parquet or CSV table as a data.table, keeping only `columns` (all if NULL).
# In test mode only the first test_nrows() rows are kept.
read_table <- function(path, columns = NULL) {
  extension <- tolower(tools::file_ext(path))
  table <- switch(extension,
                  parquet = read_parquet_columns(path, columns),
                  csv = data.table::fread(path, select = columns, nrows = test_nrows()),
                  stop("read_table(): unsupported extension '", extension, "'"))
  utils::head(data.table::as.data.table(table), test_nrows())
}

read_parquet_columns <- function(path, columns) {
  if (is.null(columns)) return(arrow::read_parquet(path))
  arrow::read_parquet(path, col_select = tidyselect::all_of(columns))
}

# Check the key, write the table (format from the file extension), then write a small
# data report next to it: <name>_report.txt. Parquet for anything large; CSV only when
# the table has at most max_csv_rows rows.
save_table <- function(dt, path, key, max_csv_rows = 1e5) {
  assert_key(dt, key)
  extension <- tolower(tools::file_ext(path))
  if (extension == "csv" && nrow(dt) > max_csv_rows) {
    stop(sprintf("save_table(): %s has %d rows; write Parquet for tables over %d rows",
                 path, nrow(dt), as.integer(max_csv_rows)))
  }
  switch(extension,
         parquet = arrow::write_parquet(dt, path),
         csv = data.table::fwrite(dt, path),
         stop("save_table(): unsupported extension '", extension, "'; use .parquet or .csv"))
  writeLines(data_report(dt, key, basename(path)), report_path(path))
  invisible(path)
}

# Stop unless the key columns exist, contain no missing values and are jointly unique.
assert_key <- function(dt, key) {
  if (!is.data.frame(dt)) stop("assert_key(): dt must be a data frame")
  if (!is.character(key) || length(key) == 0) {
    stop("assert_key(): key must be a non-empty character vector")
  }
  absent <- setdiff(key, names(dt))
  if (length(absent) > 0) stop("Key columns not in table: ", toString(absent))

  key_columns <- as.data.frame(dt)[, key, drop = FALSE]
  n_missing <- vapply(key_columns, function(column) sum(is.na(column)), integer(1))
  if (any(n_missing > 0)) {
    has_missing <- n_missing > 0
    stop("Key has missing values: ",
         toString(sprintf("%s (%d)", key[has_missing], n_missing[has_missing])))
  }
  n_duplicates <- sum(duplicated(key_columns))
  if (n_duplicates > 0) {
    stop(sprintf("Key (%s) is not unique: %d duplicated rows", toString(key), n_duplicates))
  }
  invisible(dt)
}

# Lines of a data report: row count, key, and each column's type and missing count.
# No timestamps, so a report changes only when the data change.
data_report <- function(dt, key, table_name) {
  column_types <- vapply(dt, function(column) class(column)[1], character(1))
  column_missing <- vapply(dt, function(column) sum(is.na(column)), integer(1))
  column_lines <- sprintf("  %-30s %-12s %d", names(dt), column_types, column_missing)
  c(
    paste("Table:", table_name),
    paste("Rows:", format(nrow(dt), big.mark = ",")),
    paste("Key:", toString(key), "(unique, non-missing)"),
    "Columns (name, type, missing):",
    column_lines
  )
}

report_path <- function(path) {
  sub("\\.[^.]+$", "_report.txt", path)
}

# Write LaTeX macros, one per value: write_tex_macros(list(nObs = 3100), path) writes
# \newcommand{\nObs}{3{,}100}. Numbers get thousands separators and `digits` decimals
# unless they are whole; character values are written as given. `digits` is one number
# for every value, or one per value.
write_tex_macros <- function(values, path, digits = 2) {
  macro_names <- names(values)
  if (is.null(macro_names) || !all(grepl("^[A-Za-z]+$", macro_names))) {
    stop("write_tex_macros(): every value needs a name made of letters only ",
         "(LaTeX macro names cannot contain digits or underscores)")
  }
  if (anyDuplicated(macro_names)) {
    stop("write_tex_macros(): duplicate macro names: ",
         toString(unique(macro_names[duplicated(macro_names)])))
  }
  if (!length(digits) %in% c(1, length(values))) {
    stop("write_tex_macros(): digits must have length 1 or one entry per value")
  }
  formatted <- mapply(format_tex_value, values, rep_len(digits, length(values)))
  lines <- c(
    "% Generated by write_tex_macros() in lib/R/helpers.R. Do not edit by hand.",
    sprintf("\\newcommand{\\%s}{%s}", macro_names, formatted)
  )
  writeLines(lines, path)
  invisible(path)
}

format_tex_value <- function(value, digits) {
  if (length(value) != 1 || is.na(value)) {
    stop("write_tex_macros(): each value must be a single non-missing value")
  }
  if (is.character(value)) return(value)
  if (!is.numeric(value)) stop("write_tex_macros(): values must be numbers or strings")

  is_whole <- value == round(value)
  magnitude <- formatC(abs(value), format = if (is_whole) "d" else "f",
                       digits = if (is_whole) 0 else digits, big.mark = "{,}")
  if (value < 0) paste0("\\ensuremath{-}", magnitude) else magnitude
}
