`## Shell functions used by shell_functions.make.
# Make joins this file into a single line, so every statement ends with a semicolon
# and comments must stay inside this backtick block.
# run_R: Rscript --vanilla with the renv project library from setup_environment.
# run_python: the project .venv interpreter.
# run_julia: julia with the repository root as its project.`;

run_R() {
	lib_file=../../setup_environment/output/R_library.txt;
	if [ ! -f "$lib_file" ]; then
		echo "ERROR: $lib_file not found. Run make in tasks/setup_environment/code.";
		exit 1;
	fi;
	print_info R "$@";
	R_LIBS="$(cat "$lib_file")" Rscript --vanilla "$@";
} ;

run_python() {
	python_bin=../../../.venv/bin/python;
	if [ ! -x "$python_bin" ]; then
		echo "ERROR: $python_bin not found. Run make in tasks/setup_environment/code.";
		exit 1;
	fi;
	print_info Python "$@";
	"$python_bin" "$@";
} ;

run_julia() {
	if ! command -v julia > /dev/null; then
		echo "ERROR: julia not found in PATH. Install it with juliaup (see tasks/onboarding).";
		exit 1;
	fi;
	print_info Julia "$@";
	julia --project=../../.. --startup-file=no "$@";
} ;

print_info() {
	software=$1;
	shift;
	mode="";
	if [ "$TEST" == "TRUE" ]; then mode=" [TEST, first $TEST_NROWS rows]"; fi;
	if [ $# == 1 ]; then
		echo "Running ${1} via ${software}${mode}, waiting...";
	else
		echo "Running ${1} via ${software}${mode} with args = ${@:2}, waiting...";
	fi;
}
