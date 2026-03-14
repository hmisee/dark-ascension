# Feature: soul-relic-system — Property test for relic award idempotence
extends GdUnitTestSuite

var _runner: PropertyTestRunner


func before():
	_runner = PropertyTestRunner.new(100, 42)


# Feature: soul-relic-system, Property 16: Relic award idempotence
func test_property_16_relic_award_idempotence():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"already_unlocked": rng.randi() % 2 == 0,
		}

	var prop := func(input: Dictionary) -> bool:
		var g := RelicGrid.new()
		g.is_unlocked = input["already_unlocked"]

		# Capture state before
		var was_unlocked := g.is_unlocked
		var grid_before := g.serialize()

		# Award once
		if not g.is_unlocked:
			g.is_unlocked = true

		var state_after_first := g.serialize()

		# Award again (idempotent)
		if not g.is_unlocked:
			g.is_unlocked = true

		var state_after_second := g.serialize()

		# State after first and second award should be identical
		if str(state_after_first) != str(state_after_second):
			return false

		# Grid should always be unlocked after award
		if not g.is_unlocked:
			return false

		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
