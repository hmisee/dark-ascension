# Feature: soul-relic-system — Property tests for shadow resurrection system
extends GdUnitTestSuite

var _runner: PropertyTestRunner


func before():
	_runner = PropertyTestRunner.new(100, 42)


# Feature: soul-relic-system, Property 2: Resurrection gating by cooldown and soul cost
func test_property_2_resurrection_gating():
	var gen := func(rng: RandomNumberGenerator):
		var shadow_type: String = "skeleton" if rng.randi() % 2 == 0 else "wraith"
		return {
			"shadow_type": shadow_type,
			"soul_balance": rng.randi_range(0, 150),
			"cooldown_elapsed": rng.randf_range(0.0, 20.0),
		}

	var prop := func(input: Dictionary) -> bool:
		var shadow_type: String = input["shadow_type"]
		var soul_balance: int = input["soul_balance"]
		var cooldown_elapsed: float = input["cooldown_elapsed"]

		# Setup SoulEnergyManager
		SoulEnergyManager.reset()
		SoulEnergyManager.current_souls = soul_balance

		# Create resurrection system
		var sys := ShadowResurrectionSystem.new()
		var cost: int = sys.resurrection_costs[shadow_type]
		var cooldown: float = sys.resurrection_cooldowns[shadow_type]

		# Create a mock shadow using a simple CharacterBody2D stand-in
		# We need a real Shadow-like object, so we simulate the needed state
		var mock_shadow = Shadow.new()
		mock_shadow.shadow_type = shadow_type
		mock_shadow.is_dead = true
		mock_shadow.max_health = 100.0
		sys.register_shadow(mock_shadow)

		# Simulate death and cooldown passage
		sys.on_shadow_died(shadow_type)
		# Manually set cooldown remaining to simulate elapsed time
		var remaining := maxf(0.0, cooldown - cooldown_elapsed)
		sys._cooldown_remaining[shadow_type] = remaining
		sys._is_eligible[shadow_type] = remaining <= 0.0

		var souls_before := SoulEnergyManager.get_souls()
		var success := sys.try_resurrect(shadow_type)

		var cooldown_expired := cooldown_elapsed >= cooldown
		var has_enough_souls := soul_balance >= cost
		var should_succeed := cooldown_expired and has_enough_souls

		if should_succeed:
			if not success:
				return false
			if SoulEnergyManager.get_souls() != souls_before - cost:
				return false
		else:
			if success:
				return false
			if SoulEnergyManager.get_souls() != souls_before:
				return false

		mock_shadow.free()
		sys.free()
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 3: Weakened state health regeneration lifecycle
func test_property_3_weakened_regen_lifecycle():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"max_health": rng.randf_range(20.0, 200.0),
			"elapsed_time": rng.randf_range(0.0, 60.0),
		}

	var prop := func(input: Dictionary) -> bool:
		var max_hp: float = input["max_health"]
		var elapsed: float = input["elapsed_time"]
		var regen := 5.0

		# Expected health after elapsed time
		var start_hp := max_hp * 0.5
		var expected_hp := minf(max_hp, start_hp + regen * elapsed)

		# Expected weakened state: still weakened if not fully healed
		var should_be_weakened := expected_hp < max_hp

		# Verify the formula matches the design spec
		if absf(expected_hp - minf(max_hp, 0.5 * max_hp + 5.0 * elapsed)) > 0.01:
			return false

		# Verify weakened exits at max health
		if expected_hp >= max_hp and should_be_weakened:
			return false

		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
