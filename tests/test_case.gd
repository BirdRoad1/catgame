extends RefCounted
## Base for test files. Extend this, and write methods starting with "test_".
## Assertions record failures instead of stopping, so one test can report several.

var _failures: Array[String] = []
var _pending_reason: String = ""


## Runs before every test method. Override to build fresh objects for each test.
func before_each() -> void:
	pass


## Runs after every test method.
func after_each() -> void:
	pass


## Marks the current test as not written yet. It's reported, but doesn't fail the run.
func pending(reason: String = "not implemented") -> void:
	_pending_reason = reason


func fail(message: String) -> void:
	_failures.append(message)


func assert_true(value: bool, message: String = "") -> void:
	if not value:
		fail("expected true. %s" % message)


func assert_false(value: bool, message: String = "") -> void:
	if value:
		fail("expected false. %s" % message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if typeof(actual) != typeof(expected) or actual != expected:
		fail("expected %s, got %s. %s" % [var_to_str(expected), var_to_str(actual), message])


func assert_ne(actual: Variant, not_expected: Variant, message: String = "") -> void:
	if typeof(actual) == typeof(not_expected) and actual == not_expected:
		fail("expected anything but %s. %s" % [var_to_str(not_expected), message])


func assert_null(value: Variant, message: String = "") -> void:
	if value != null:
		fail("expected null, got %s. %s" % [var_to_str(value), message])


func assert_not_null(value: Variant, message: String = "") -> void:
	if value == null:
		fail("expected a value, got null. %s" % message)


func assert_between(value: float, low: float, high: float, message: String = "") -> void:
	if value < low or value > high:
		fail("expected %s to be between %s and %s. %s" % [value, low, high, message])


func assert_has(collection: Variant, item: Variant, message: String = "") -> void:
	if not collection.has(item):
		fail("expected %s to contain %s. %s" % [var_to_str(collection), var_to_str(item), message])
