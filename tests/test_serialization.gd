# Feature: soul-relic-system — Property tests for serialization round trips
extends GdUnitTestSuite

var _runner: PropertyTestRunner
var _pool: Array[Shard]


func before():
	_runner = PropertyTestRunner.new(100, 42)
	_pool = ShardPool.get_all_shards()


func _random_shard(rng: RandomNumberGenerator) -> Shard:
	var template: Shard = _pool[rng.randi() % _pool.size()]
	return Shard.deserialize(template.serialize())


# Feature: soul-relic-system, Property 10: Relic grid serialization round trip
func test_property_10_grid_serialization_round_trip():
	var gen := func(rng: RandomNumberGenerator):
		var placements: Array = []
		for row in 3:
			for col in 3:
				if rng.randi() % 2 == 0:
					placements.append({"row": row, "col": col, "shard_idx": rng.randi() % _pool.size()})
		return {"placements": placements, "unlocked": rng.randi() % 2 == 0}

	var prop := func(input: Dictionary) -> bool:
		var g := RelicGrid.new()
		g.is_unlocked = input["unlocked"]
		if g.is_unlocked:
			for p in input["placements"]:
				var shard := Shard.deserialize(_pool[p["shard_idx"]].serialize())
				g.place_shard(shard, p["row"], p["col"])

		var data := g.serialize()
		var restored := RelicGrid.deserialize(data)

		# Compare unlock state
		if restored.is_unlocked != g.is_unlocked:
			return false

		# Compare grid contents
		for row in 3:
			for col in 3:
				var orig: Shard = g.get_shard(row, col)
				var rest: Shard = restored.get_shard(row, col)
				if orig == null and rest == null:
					continue
				if orig == null or rest == null:
					return false
				if orig.shard_name != rest.shard_name or orig.stat_type != rest.stat_type:
					return false
				if absf(orig.base_value - rest.base_value) > 0.01:
					return false

		# Compare adjacency bonuses
		var orig_bonuses := g.calculate_all_bonuses()
		var rest_bonuses := restored.calculate_all_bonuses()
		for st in orig_bonuses:
			if absf(orig_bonuses[st] - rest_bonuses.get(st, 0.0)) > 0.01:
				return false
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 11: Shard inventory serialization round trip
func test_property_11_inventory_serialization_round_trip():
	var gen := func(rng: RandomNumberGenerator):
		var count := rng.randi_range(0, 15)
		var shard_indices: Array[int] = []
		for i in count:
			shard_indices.append(rng.randi() % _pool.size())
		return shard_indices

	var prop := func(indices: Array) -> bool:
		var shards: Array[Shard] = []
		for idx in indices:
			shards.append(Shard.deserialize(_pool[idx].serialize()))

		# Serialize
		var data: Array = []
		for shard in shards:
			data.append(shard.serialize())

		# Deserialize
		var restored := ShardInventory.deserialize(data)

		if restored.size() != shards.size():
			return false

		for i in shards.size():
			if restored[i].shard_name != shards[i].shard_name:
				return false
			if restored[i].stat_type != shards[i].stat_type:
				return false
			if absf(restored[i].base_value - shards[i].base_value) > 0.01:
				return false
			if restored[i].purchase_price != shards[i].purchase_price:
				return false
			if restored[i].sell_value != shards[i].sell_value:
				return false
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
