# Feature: soul-relic-system — Lightweight property-based test runner
# Used by GdUnit4 tests to verify correctness properties across random inputs.
extends RefCounted
class_name PropertyTestRunner

## Result of a property test run.
class Result:
	var passed: bool
	var iterations: int
	var failing_input  # Variant — the generator output that caused the failure
	var error_message: String

	func _init(p_passed: bool, p_iterations: int, p_failing_input = null, p_error: String = "") -> void:
		passed = p_passed
		iterations = p_iterations
		failing_input = p_failing_input
		error_message = p_error


## Number of random iterations per property run.
var iterations: int = 100

## Optional seed for reproducibility. When -1 the runner picks a random seed.
var seed_value: int = -1

var _rng: RandomNumberGenerator


func _init(p_iterations: int = 100, p_seed: int = -1) -> void:
	iterations = p_iterations
	seed_value = p_seed
	_rng = RandomNumberGenerator.new()
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()


## Run a property [param iterations] times.
## [param generator] — Callable that receives a [RandomNumberGenerator] and returns a random input.
## [param property] — Callable that receives the generated input and returns [code]true[/code] when the property holds.
## Returns a [Result] with pass/fail info and the first failing input (if any).
func run(generator: Callable, property: Callable) -> Result:
	for i in iterations:
		var input = generator.call(_rng)
		var holds: bool = property.call(input)
		if not holds:
			return Result.new(false, i + 1, input, "Property violated on iteration %d" % (i + 1))
	return Result.new(true, iterations)


## Convenience: run and return a human-readable summary string.
func run_and_summarize(generator: Callable, property: Callable) -> String:
	var result := run(generator, property)
	if result.passed:
		return "PASSED — %d iterations" % result.iterations
	return "FAILED on iteration %d — input: %s" % [result.iterations, str(result.failing_input)]


## Access the internal RNG (useful for generators that need sub-values).
func get_rng() -> RandomNumberGenerator:
	return _rng
