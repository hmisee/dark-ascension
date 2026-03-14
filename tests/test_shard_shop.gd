# Feature: soul-relic-system — Property tests for shard shop purchase and reroll
extends GdUnitTestSuite

var _runner: PropertyTestRunner
var _pool: Array[Shard]


func before():
	_runner = PropertyTestRunner.new(100, 42)
	_pool = ShardPool.get_all_shards()


# Feature: soul-relic-system, Property 13: Shop purchase gating by soul cost
func test_property_13_shop_purchase_gating():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"offer_index": rng.randi_range(0, 4),
			"soul_balance": rng.randi_range(0, 150),
		}

	var prop := func(input: Dictionary) -> bool:
		SoulEnergyManager.reset()
		SoulEnergyManager.current_souls = input["soul_balance"]

		var inv := ShardInventory.new()
		var shop := ShardShop.new()
		shop.inventory_ref = inv
		shop.generate_offers()

		var idx: int = input["offer_index"]
		var offer: Shard = shop.current_offers[idx]
		if offer == null:
			inv.free()
			shop.free()
			return true  # already sold, skip

		var price: int = offer.purchase_price
		var souls_before := SoulEnergyManager.get_souls()
		var inv_before := inv.get_all().size()
		var success := shop.purchase(idx)

		var should_succeed := souls_before >= price

		if should_succeed:
			if not success:
				inv.free()
				shop.free()
				return false
			if SoulEnergyManager.get_souls() != souls_before - price:
				inv.free()
				shop.free()
				return false
			if inv.get_all().size() != inv_before + 1:
				inv.free()
				shop.free()
				return false
		else:
			if success:
				inv.free()
				shop.free()
				return false
			if SoulEnergyManager.get_souls() != souls_before:
				inv.free()
				shop.free()
				return false

		inv.free()
		shop.free()
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()


# Feature: soul-relic-system, Property 14: Shop reroll replaces offers
func test_property_14_shop_reroll():
	var gen := func(rng: RandomNumberGenerator):
		return {
			"soul_balance": rng.randi_range(0, 200),
		}

	var prop := func(input: Dictionary) -> bool:
		SoulEnergyManager.reset()
		SoulEnergyManager.current_souls = input["soul_balance"]

		var inv := ShardInventory.new()
		var shop := ShardShop.new()
		shop.inventory_ref = inv
		shop.generate_offers()

		var reroll_cost: int = shop.reroll_cost
		var souls_before := SoulEnergyManager.get_souls()
		var success := shop.reroll()

		var should_succeed := souls_before >= reroll_cost

		if should_succeed:
			if not success:
				inv.free()
				shop.free()
				return false
			if SoulEnergyManager.get_souls() != souls_before - reroll_cost:
				inv.free()
				shop.free()
				return false
			# Should have exactly 5 offers
			if shop.current_offers.size() != 5:
				inv.free()
				shop.free()
				return false
			# All offers should be valid shards from the pool
			var pool_names: Array[String] = []
			for s in _pool:
				pool_names.append(s.shard_name)
			for offer in shop.current_offers:
				if offer != null and not (offer.shard_name in pool_names):
					inv.free()
					shop.free()
					return false
		else:
			if success:
				inv.free()
				shop.free()
				return false
			if SoulEnergyManager.get_souls() != souls_before:
				inv.free()
				shop.free()
				return false

		inv.free()
		shop.free()
		return true

	var result := _runner.run(gen, prop)
	assert_bool(result.passed).is_true()
