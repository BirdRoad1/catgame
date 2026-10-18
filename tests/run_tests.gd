extends SceneTree
## Headless test runner. From the project folder:
##   godot --headless -s res://tests/run_tests.gd
## Runs every tests/**/test_*.gd file. Pass a word after "--" to only run files
## whose path contains it:
##   godot --headless -s res://tests/run_tests.gd -- corridor
## Exits with code 1 if anything failed, so it can be used in scripts/CI.
##
## Each test file runs in its own Godot process. Script errors are read from that
## process's output, so a test that errors counts as failed, and a test that
## crashes the engine only fails its own file instead of the whole run.

const TESTS_DIR := "res://tests"
const CHILD_FLAG := "--run-one-file"

# Lines the child process prints so the parent can tell which test an error belongs to
const MARK_START := "@@TEST_START "
const MARK_RESULT := "@@TEST_RESULT "

var passed := 0
var failed := 0
var pending := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2 and args[0] == CHILD_FLAG:
		await _child_run_file(args[1])
		quit(0)
		return

	var filter := args[0] if args.size() > 0 else ""
	var files := _find_test_files(TESTS_DIR)
	files.sort()
	for path in files:
		if filter.is_empty() or path.contains(filter):
			_run_file_in_child(path)

	print("\n%d passed, %d failed, %d pending" % [passed, failed, pending])
	quit(1 if failed > 0 else 0)


func _find_test_files(dir_path: String) -> Array[String]:
	var found: Array[String] = []
	for sub in DirAccess.get_directories_at(dir_path):
		found.append_array(_find_test_files(dir_path.path_join(sub)))
	for file in DirAccess.get_files_at(dir_path):
		if file.begins_with("test_") and file.ends_with(".gd") and file != "test_case.gd":
			found.append(dir_path.path_join(file))
	return found


# --- Parent: run one file in a separate process and read its output ---

func _run_file_in_child(path: String) -> void:
	print("\n%s" % path.trim_prefix(TESTS_DIR + "/"))
	var output: Array = []
	var exit_code := OS.execute(OS.get_executable_path(),
		["--headless", "--path", ProjectSettings.globalize_path("res://"),
		 "-s", "res://tests/run_tests.gd", "--", CHILD_FLAG, path],
		output, true)
	var lines: PackedStringArray = "".join(output).split("\n")

	var current_test := ""      # test currently running in the child
	var errors: Array[String] = []  # errors seen since current_test started
	var file_errors: Array[String] = []  # errors before any test started (compile errors)
	var finished := {}
	var in_crash_dump := false

	for line in lines:
		# Skip the engine's crash dump; the crash itself is reported below
		if line.begins_with("handle_crash:"):
			in_crash_dump = true
		if in_crash_dump or line.begins_with("====="):
			continue
		if line.begins_with(MARK_START):
			current_test = line.trim_prefix(MARK_START)
			errors = []
		elif line.begins_with(MARK_RESULT):
			var result: Dictionary = JSON.parse_string(line.trim_prefix(MARK_RESULT))
			var failures: Array = result.failures
			for e in errors:
				failures.append("error: " + e)
			_report(result.name, failures, result.pending)
			finished[result.name] = true
			current_test = ""
		elif line.begins_with("SCRIPT ERROR:") or line.begins_with("ERROR:"):
			var message := line.trim_prefix("SCRIPT ERROR:").trim_prefix("ERROR:").strip_edges()
			if current_test.is_empty():
				file_errors.append(message)
			else:
				errors.append(message)
		elif line.strip_edges().begins_with("at: ") and not errors.is_empty():
			errors[-1] += " (" + line.strip_edges().trim_prefix("at: ") + ")"
		elif not line.begins_with("Godot Engine") and not line.strip_edges().is_empty() \
				and not line.begins_with("   ") and not line.begins_with("\t"):
			print("          | " + line)  # the code's own print() output

	if not current_test.is_empty():
		# The child died in the middle of a test
		_report(current_test, ["crashed the engine (exit code %d)" % exit_code] + errors, "")
	elif finished.is_empty() and (exit_code != 0 or not file_errors.is_empty()):
		failed += 1
		print("  FAIL    could not load this file or a script it uses:")
		for e in file_errors:
			print("          %s" % e)


func _report(name: String, failures: Array, pending_reason: String) -> void:
	if not failures.is_empty():
		failed += 1
		print("  FAIL    %s" % name)
		for message in failures:
			print("          %s" % message)
	elif pending_reason != "":
		pending += 1
		print("  PENDING %s (%s)" % [name, pending_reason])
	else:
		passed += 1
		print("  ok      %s" % name)


# --- Child: actually run the tests in one file ---

func _child_run_file(path: String) -> void:
	var script: GDScript = load(path)
	if script == null or not script.can_instantiate():
		return

	for method in script.get_script_method_list():
		var name: String = method.name
		if not name.begins_with("test_"):
			continue

		print(MARK_START + name)
		# Fresh instance per test so state never leaks between tests
		var test_case = script.new()
		test_case.before_each()
		await test_case.call(name)
		test_case.after_each()
		print(MARK_RESULT + JSON.stringify({
			"name": name,
			"failures": test_case._failures,
			"pending": test_case._pending_reason,
		}))
