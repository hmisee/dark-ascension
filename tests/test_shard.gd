# Feature: soul-relic-system — Property tests for Shard data and effective values
extends GdUnitTestSuite

var _runner: PropertyTestRunner


func before():
	_runner = PropertyTestRunner.new(100, 42)


# Feature: soul-relic-system, Property 15: Shard pool invariants
func test_property_15_shard_pool_invariants():
	var pool := ShardPool.get_all_shards()

	# Exactly 8 shard types
	assert_int(pool.size()).is_equal(8)

	# Each shard has 1–4 receive directions
	for shard in pool:
		assert_bool(shard.receive_directions.size() >= 1 and shard.receive_directions.size() <= 4)\
			.is_true()

	# All shards have unique (stat_type, base_value, adjacency_bonus_percent, receive_directions)
	var seen: Array[String] = []
	for shard in pool:
		var dirs_sorted: Array = []
		for d in shard.receive_directions:
			dirs_sorted.append(d as int)
		dirs_sorted.sort()
		var key := "%d|%.2f|%.2f|%s" % [shard.stat_type as int, shard.base_value, shard.adjacency_bonus_percent, str(dirs_sorted)]
		assert_bool(key in seen).is_false()
		seen.append(key)

	# Required stat types present: cooldown_reduction, damage_amp, attack_speed, healing_rate
	var stat_types: Array[int] = []
	for shard in pool:
		if not (shard.stat_type as int) in stat_types:
			stat_types.append(shard.stat_type as int)
	for required in [Shard.StatType.COOLDOWN_REDUCTION, Shard.StatType.DAMAGE_AMP, Shard.StatType.ATTACK_SPEED, Shard.StatType.HEALING_RATE]:
		assert_bool((required as int) in stat_types).is_true()


# Feature: soul-relic-system, Property 8: Effective shard value with adjacency bonus
func test_property_8_effective_value_formula():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"base_value": rng.randf_range(-20.0, 50.0),
			"bonus_percent": rng.randf_range(0.0, 100.0),
			"adjacency_count": rng.randi_range(0, 4),
		}

	var prop := func(input: Dictionary) -> bool:
		var shard := Shard.new()
		shard.base_value = input["base_value"]
		shard.adjacency_bonus_percent = input["bonus_percent"]
		var count: int = input["adjacency_count"]
		var expected: float = input["base_value"] * (1.0 + count * input["bonus_percent"] / 100.0)
		var actual: float = shard.get_effective_value(count)
		return absf(actual - expected) < 0.001

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
