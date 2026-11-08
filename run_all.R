# Run the tasks in order without Make or symbolic links.
# For machines where neither is available, such as Windows secure environments
# (e.g. ABS DataLab virtual machines). It keeps the task folders and their inputs and
# outputs, so the work stays modular, but it loses Make's dependency tracking:
# every step reruns every time, and you must keep the order below in sync with the
# Makefiles by hand.
#
# Run from the repository root:  Rscript run_all.R
# Packages: the R packages in renv.lock must be installed on the machine.

# Run one script from its task's code/ folder, as Make would.
# `copy_inputs` are upstream outputs (paths relative to tasks/) copied into input/,
# in place of the symbolic links the Makefiles create.
run_step <- function(task, script, args, copy_inputs = character()) {
  task_dir <- file.path("tasks", task)
  for (folder in c("input", "output")) {
    dir.create(file.path(task_dir, folder), showWarnings = FALSE)
  }
  for (upstream_file in copy_inputs) {
    destination <- file.path(task_dir, "input", basename(upstream_file))
    # Remove any symbolic link left by make, so the copy never writes through it
    unlink(destination)
    copied <- file.copy(file.path("tasks", upstream_file), destination)
    if (!copied) stop("Could not copy ", upstream_file, " into ", task, "/input")
  }
  message("Running ", task, "/code/", script)
  status <- withr::with_dir(file.path(task_dir, "code"),
                            system2("Rscript", c("--vanilla", script, args)))
  if (status != 0) stop(task, "/code/", script, " failed with status ", status)
}

# Child R processes use the same package libraries as this one
Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep))
lib_r <- "../../../lib/R"

# The example tasks, in the order the Makefiles run them.
# For each new task, add the run_step() calls its Makefile recipes make.
run_step("example_numbers", "numbers.R", c(lib_r, "../output/numbers.csv"))
run_step("example_sum", "sum.R", c(lib_r, "../input/numbers.csv", "../output/sum_macros.tex"),
         copy_inputs = "example_numbers/output/numbers.csv")
