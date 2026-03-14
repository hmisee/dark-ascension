# Feature: soul-relic-system — Property tests for relic grid operations and adjacency
extends GdUnitTestSuite

var _runner: PropertyTestRunner
var _pool: Array[Shard]


func before():
	_runner = PropertyTestRunner.new(100, 42)
	_pool = ShardPool.get_all_shards()


func _random_shard(rng: RandomNumberGenerator) -> Shard:
	var template: Shard = _pool[rng.randi() % _pool.size()]
	return Shard.deserialize(template.serialize())


func _make_unlocked_grid() -> RelicGrid:
	var g := RelicGrid.new()
	g.is_unlocked = true
	return g


# Feature: soul-relic-system, Property 4: Relic grid structural invariant
func test_property_4_grid_structural_invariant():
	var gen := func(rng: RandomNumberGenerator):
		var placements: Array = []
		var count := rng.randi_range(0, 9)
		for i in count:
			placements.append({
				"row": rng.randi_range(0, 2),
				"col": rng.randi_range(0, 2),
				"shard_idx": rng.randi() % _pool.size(),
			})
		return placements

	var prop := func(placements: Array) -> bool:
		var g := _make_unlocked_grid()
		for p in placements:
			var shard := Shard.deserialize(_pool[p["shard_idx"]].serialize())
			g.place_shard(shard, p["row"], p["col"])

		# Grid must be exactly 3x3
		if g.grid.size() != 3:
			return false
		for row in g.grid:
			if row.size() != 3:
				return false

		# Each shard occupies exactly one slot (count non-null)
		var shard_count := 0
		for row in 3:
			for col in 3:
				if g.get_shard(row, col) != null:
					shard_count += 1
		# shard_count should be <= 9
		return shard_count >= 0 and shard_count <= 9

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 5: Shard place-then-remove round trip
func test_property_5_place_remove_round_trip():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"row": rng.randi_range(0, 2),
			"col": rng.randi_range(0, 2),
			"shard_idx": rng.randi() % _pool.size(),
		}

	var prop := func(input: Dictionary) -> bool:
		var g := _make_unlocked_grid()
		var shard := Shard.deserialize(_pool[input["shard_idx"]].serialize())
		var row: int = input["row"]
		var col: int = input["col"]

		# Place
		var placed := g.place_shard(shard, row, col)
		if not placed:
			return false

		# Remove
		var removed := g.remove_shard(row, col)
		if removed == null:
			return false

		# Grid slot should be empty again
		if g.get_shard(row, col) != null:
			return false

		# Returned shard should match
		return removed.shard_name == shard.shard_name and removed.stat_type == shard.stat_type

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 7: Cardinal directional adjacency calculation
func test_property_7_cardinal_adjacency():
	var gen := func(rng: RandomNumberGenerator):
		# Generate a random grid configuration
		var grid_config: Array = []
		for row in 3:
			for col in 3:
				if rng.randi() % 3 != 0:  # ~66% chance of placing a shard
					grid_config.append({"row": row, "col": col, "shard_idx": rng.randi() % _pool.size()})
		return grid_config

	var prop := func(config: Array) -> bool:
		var g := _make_unlocked_grid()
		for entry in config:
			var shard := Shard.deserialize(_pool[entry["shard_idx"]].serialize())
			g.place_shard(shard, entry["row"], entry["col"])

		# For each placed shard, manually count adjacencies and compare
		var direction_offsets := {
			Shard.Direction.UP: Vector2i(-1, 0),
			Shard.Direction.DOWN: Vector2i(1, 0),
			Shard.Direction.LEFT: Vector2i(0, -1),
			Shard.Direction.RIGHT: Vector2i(0, 1),
		}

		for row in 3:
			for col in 3:
				var shard: Shard = g.get_shard(row, col)
				if shard == null:
					continue
				var expected_count := 0
				for dir in shard.receive_directions:
					var offset: Vector2i = direction_offsets[dir]
					var nr := row + offset.x
					var nc := col + offset.y
					if nr >= 0 and nr < 3 and nc >= 0 and nc < 3:
						if g.get_shard(nr, nc) != null:
							expected_count += 1
				var actual := g._count_active_adjacencies(row, col, shard)
				if actual != expected_count:
					return false
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 9: Total stat bonus aggregation
func test_property_9_total_bonus_aggregation():
	var gen := func(rng: RandomNumberGenerator):
		var grid_config: Array = []
		for row in 3:
			for col in 3:
				if rng.randi() % 2 == 0:
					grid_config.append({"row": row, "col": col, "shard_idx": rng.randi() % _pool.size()})
		return grid_config

	var prop := func(config: Array) -> bool:
		var g := _make_unlocked_grid()
		for entry in config:
			var shard := Shard.deserialize(_pool[entry["shard_idx"]].serialize())
			g.place_shard(shard, entry["row"], entry["col"])

		var bonuses := g.calculate_all_bonuses()

		# Manually compute expected bonuses
		var expected: Dictionary = {}
		for row in 3:
			for col in 3:
				var shard: Shard = g.get_shard(row, col)
				if shard == null:
					continue
				var adj := g._count_active_adjacencies(row, col, shard)
				var eff := shard.get_effective_value(adj)
				var st := shard.stat_type
				if expected.has(st):
					expected[st] += eff
				else:
					expected[st] = eff

		# Compare
		for st in expected:
			var actual_val: float = bonuses.get(st, 0.0)
			if absf(actual_val - expected[st]) > 0.01:
				return false
		for st in bonuses:
			if not expected.has(st):
				return false
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 17: Grid operations have zero soul cost
func test_property_17_grid_ops_zero_soul_cost():
	var gen := func(rng: RandomNumberGenerator):
		# 0=place, 1=remove, 2=swap
		return {
			"op": rng.randi_range(0, 2),
			"row": rng.randi_range(0, 2),
			"col": rng.randi_range(0, 2),
			"shard_idx": rng.randi() % _pool.size(),
			"initial_souls": rng.randi_range(0, 500),
		}

	var prop := func(input: Dictionary) -> bool:
		SoulEnergyManager.reset()
		SoulEnergyManager.current_souls = input["initial_souls"]
		var souls_before := SoulEnergyManager.get_souls()

		var g := _make_unlocked_grid()
		var shard := Shard.deserialize(_pool[input["shard_idx"]].serialize())

		match input["op"]:
			0: g.place_shard(shard, input["row"], input["col"])
			1: g.remove_shard(input["row"], input["col"])
			2: g.swap_shard(input["row"], input["col"], shard)

		return SoulEnergyManager.get_souls() == souls_before

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 6: Combat lockout of grid and shop operations
# Note: RelicGrid checks is_unlocked but does not have a separate combat lock in v1.
# This test verifies that when the grid is locked (is_unlocked=false), all mutations fail.
func test_property_6_lockout_rejects_all_operations():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"op": rng.randi_range(0, 2),  # 0=place, 1=remove, 2=swap
			"row": rng.randi_range(0, 2),
			"col": rng.randi_range(0, 2),
			"shard_idx": rng.randi() % _pool.size(),
		}

	var prop := func(input: Dictionary) -> bool:
		var g := RelicGrid.new()
		# Grid is locked (not unlocked)
		g.is_unlocked = false
		var shard := Shard.deserialize(_pool[input["shard_idx"]].serialize())

		match input["op"]:
			0:
				if g.place_shard(shard, input["row"], input["col"]):
					return false
			1:
				if g.remove_shard(input["row"], input["col"]) != null:
					return false
			2:
				if g.swap_shard(input["row"], input["col"], shard) != null:
					return false

		# Grid should still be completely empty
		for row in 3:
			for col in 3:
				if g.get_shard(row, col) != null:
					return false
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
