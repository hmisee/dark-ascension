extends Node
class_name ShardShop

## Between-levels shop that offers random shards for purchase with soul energy.
## Offers 5 shards drawn from the v1 shard pool. Supports purchasing individual
## shards and rerolling the entire offer set for a soul cost.

signal shop_updated(offers: Array)

@export var offer_count: int = 5
@export var reroll_cost: int = 20

## Reference to the player's shard inventory — must be set before use.
var inventory_ref: Node = null

## The current 5 offered shards. A null entry means that slot was already purchased.
var current_offers: Array = []


## Generates a fresh set of offers by picking random shards from the pool.
## Each offer is a new Shard instance cloned from a random pool entry.
func generate_offers() -> void:
	current_offers.clear()
	var pool := ShardPool.get_all_shards()
	if pool.is_empty():
		for i in offer_count:
			current_offers.append(null)
		shop_updated.emit(current_offers)
		return

	for i in offer_count:
		var template: Shard = pool[randi() % pool.size()]
		var offer := Shard.new()
		offer.shard_name = template.shard_name
		offer.stat_type = template.stat_type
		offer.base_value = template.base_value
		offer.adjacency_bonus_percent = template.adjacency_bonus_percent
		offer.receive_directions = template.receive_directions.duplicate()
		offer.purchase_price = template.purchase_price
		offer.sell_value = template.sell_value
		current_offers.append(offer)

	shop_updated.emit(current_offers)


## Attempts to purchase the shard at the given index.
## Returns true if successful, false if insufficient souls, invalid index, or already sold.
func purchase(index: int) -> bool:
	if index < 0 or index >= current_offers.size():
		return false

	var shard: Shard = current_offers[index]
	if shard == null:
		return false

	if not Autoloads.soul_energy_manager().spend_souls(shard.purchase_price):
		return false

	if inventory_ref != null:
		inventory_ref.add_shard(shard)

	current_offers[index] = null
	shop_updated.emit(current_offers)
	return true


## Attempts to reroll all offers for the reroll cost.
## Returns true if successful, false if insufficient souls.
func reroll() -> bool:
	if not Autoloads.soul_energy_manager().spend_souls(reroll_cost):
		return false

	generate_offers()
	return true
