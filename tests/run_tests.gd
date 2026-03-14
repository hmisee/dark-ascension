## Console test runner — execute with:
##   Godot_v4.6.1-stable_win64_console.exe --headless --path . -s tests/run_tests.gd
extends SceneTree

var _test_files: Array[String] = [
	"res://tests/test_shard.gd",
	"res://tests/test_soul_energy_manager.gd",
	"res://tests/test_relic_grid.gd",
	"res://tests/test_relic_award.gd",
	"res://tests/test_serialization.gd",
	"res://tests/test_shard_inventory.gd",
	"res://tests/test_shard_shop.gd",
	"res://tests/test_shadow_resurrection.gd",
]

var _passed := 0
var _failed := 0
var _errors: Array[String] = []


func _init() -> void:
	# Wait one frame so autoloads are ready
	call_deferred("_run_all")


func _run_all() -> void:
	print("\n========================================")
	print("  Running Soul & Relic System Tests")
	print("========================================\n")

	for file_path in _test_files:
		_run_test_file(file_path)

	print("\n========================================")
	print("  Results: %d passed, %d failed" % [_passed, _failed])
	print("========================================\n")

	if not _errors.is_empty():
		print("FAILURES:")
		for err in _errors:
			print("  - %s" % err)
		print("")

	if _failed > 0:
		quit(1)
	else:
		quit(0)


func _run_test_file(path: String) -> void:
	var script: GDScript = load(path)
	if script == null:
		print("  SKIP  %s (could not load)" % path)
		_failed += 1
		_errors.append("%s: could not load script" % path)
		return

	var suite: GdUnitTestSuite = script.new()
	suite.name = path.get_file().get_basename()
	root.add_child(suite)

	# Run before() once for the suite
	suite.before()

	# Discover test methods (functions starting with "test_")
	var methods: Array = []
	for m in script.get_script_method_list():
		if m["name"].begins_with("test_"):
			methods.append(m["name"])

	for method_name in methods:
		suite.before_test()
		var full_name := "%s::%s" % [path.get_file(), method_name]
		var err_msg := _run_single_test(suite, method_name)
		if err_msg.is_empty():
			print("  PASS  %s" % full_name)
			_passed += 1
		else:
			print("  FAIL  %s — %s" % [full_name, err_msg])
			_failed += 1
			_errors.append("%s: %s" % [full_name, err_msg])
		suite._cleanup_auto_free()
		suite.after_test()

	suite.after()
	suite.queue_free()


func _run_single_test(suite: GdUnitTestSuite, method_name: String) -> String:
	# Returns empty string on success, error message on failure
	var callable := Callable(suite, method_name)
	if not callable.is_valid():
		return "method not found"
	callable.call()
	return ""
