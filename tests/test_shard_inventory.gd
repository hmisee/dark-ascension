# Feature: soul-relic-system — Property tests for shard inventory and selling
extends GdUnitTestSuite

var _runner: PropertyTestRunner
var _pool: Array[Shard]


func before():
	_runner = PropertyTestRunner.new(100, 42)
	_pool = ShardPool.get_all_shards()


# Feature: soul-relic-system, Property 12: Shard selling adds souls and removes from inventory
func test_property_12_shard_selling():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"shard_idx": rng.randi() % _pool.size(),
			"initial_souls": rng.randi_range(0, 500),
		}

	var prop := func(input: Dictionary) -> bool:
		SoulEnergyManager.reset()
		SoulEnergyManager.current_souls = input["initial_souls"]

		var inv := ShardInventory.new()
		var shard := Shard.deserialize(_pool[input["shard_idx"]].serialize())
		inv.add_shard(shard)

		var souls_before := SoulEnergyManager.get_souls()
		var sell_value := shard.sell_value
		var sold := inv.sell_shard(shard)

		if not sold:
			inv.free()
			return false

		# Souls increased by exactly sell_value
		if SoulEnergyManager.get_souls() != souls_before + sell_value:
			inv.free()
			return false

		# Shard removed from inventory
		if inv.get_all().size() != 0:
			inv.free()
			return false

		inv.free()
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
