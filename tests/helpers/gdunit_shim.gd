## Minimal GdUnit4 shim so tests can run without the addon.
## Provides GdUnitTestSuite base class and assert helpers.
extends Node
class_name GdUnitTestSuite


## Lifecycle hooks — override in test scripts.
func before() -> void:
	pass

func after() -> void:
	pass

func before_test() -> void:
	pass

func after_test() -> void:
	pass


## Utility: auto_free wraps a node so it's freed after the test.
var _auto_free_list: Array = []

func auto_free(node):
	_auto_free_list.append(node)
	return node

func _cleanup_auto_free() -> void:
	for obj in _auto_free_list:
		if obj is Node and is_instance_valid(obj):
			obj.queue_free()
	_auto_free_list.clear()


## --- Assert helpers ---

class BoolAssert:
	var _value: bool
	func _init(v: bool) -> void:
		_value = v
	func is_true() -> void:
		assert(_value, "Expected true but got false")
	func is_false() -> void:
		assert(not _value, "Expected false but got true")

class IntAssert:
	var _value: int
	func _init(v: int) -> void:
		_value = v
	func is_equal(expected: int) -> void:
		assert(_value == expected, "Expected %d but got %d" % [expected, _value])

static func assert_bool(value: bool) -> BoolAssert:
	return BoolAssert.new(value)

static func assert_int(value: int) -> IntAssert:
	return IntAssert.new(value)
