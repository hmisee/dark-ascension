# Feature: soul-relic-system — Property tests for soul energy economy
extends GdUnitTestSuite

var _runner: PropertyTestRunner
var _sem: Node


func before():
	_runner = PropertyTestRunner.new(100, 42)


func before_test():
	# Create a fresh SoulEnergyManager-like node for isolated testing
	_sem = auto_free(load("res://scripts/autoloads/soul_energy_manager.gd").new())
	add_child(_sem)


# Feature: soul-relic-system, Property 1: Soul accumulation is additive
func test_property_1_soul_accumulation_additive():
	var gen := func(rng: RandomNumberGenerator):
		var count := rng.randi_range(1, 20)
		var values: Array[int] = []
		for i in count:
			values.append(rng.randi_range(1, 200))
		return values

	var prop := func(values: Array) -> bool:
		_sem.reset()
		var expected_sum := 0
		for v in values:
			_sem.add_souls(v)
			expected_sum += v
		return _sem.get_souls() == expected_sum

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
