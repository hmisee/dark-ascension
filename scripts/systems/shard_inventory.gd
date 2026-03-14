extends Node
class_name ShardInventory

## Manages the player's collection of shards not currently placed in the relic grid.
## Handles adding, removing, selling shards, and serialization for persistence.

signal inventory_changed()

var shards: Array[Shard] = []


func add_shard(shard: Shard) -> void:
	if shard == null:
		return
	shards.append(shard)
	inventory_changed.emit()


func remove_shard(shard: Shard) -> bool:
	var idx := shards.find(shard)
	if idx == -1:
		return false
	shards.remove_at(idx)
	inventory_changed.emit()
	return true


func sell_shard(shard: Shard) -> bool:
	if shard == null:
		return false
	var idx := shards.find(shard)
	if idx == -1:
		return false
	shards.remove_at(idx)
	var sem := Autoloads.soul_energy_manager()
	sem.add_souls(shard.sell_value)
	inventory_changed.emit()
	return true


func get_all() -> Array[Shard]:
	return shards.duplicate()


func reset() -> void:
	shards.clear()
	inventory_changed.emit()


func serialize() -> Array:
	var data: Array = []
	for shard in shards:
		data.append(shard.serialize())
	return data


static func deserialize(data: Array) -> Array[Shard]:
	var result: Array[Shard] = []
	if data == null:
		return result
	for entry in data:
		if entry is Dictionary:
			result.append(Shard.deserialize(entry))
	return result
