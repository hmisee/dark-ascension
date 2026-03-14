extends Node

# Global game state manager
# Handles meta progression, unlocks, and persistent data

var player_data = {
	"shadow_slots": 3,
	"backpack_size": Vector2i(4, 4),
	"unlocked_floors": 1,
	"collected_shadows": [],
	"discovered_synergies": []
}

# --- Run-level relic system state ---
var relic_grid: RelicGrid = RelicGrid.new()
var shard_inventory = null  # ShardInventory — set in _init_relic_system
var shard_shop = null  # ShardShop — set in _init_relic_system
var stat_bonus_applier = null  # StatBonusApplier — set in _init_relic_system

# --- Level progression state ---
var current_level: int = 1  # 1 or 2
var current_cycle: int = 1  # 1 or 2


func _ready():
	_init_relic_system()
	load_game_data()


func _init_relic_system() -> void:
	shard_inventory = ShardInventory.new()
	shard_inventory.name = "ShardInventory"
	add_child(shard_inventory)

	shard_shop = ShardShop.new()
	shard_shop.name = "ShardShop"
	add_child(shard_shop)

	shard_shop.inventory_ref = shard_inventory

	stat_bonus_applier = StatBonusApplier.new()
	stat_bonus_applier.name = "StatBonusApplier"
	add_child(stat_bonus_applier)


## Advances to the next level in the sequence.
## Level 1 → Level 2 (same cycle). Level 2 → Level 1 (next cycle).
## No-op if already at the final level (cycle 2, level 2).
func advance_level() -> void:
	if is_final_level():
		return
	if current_level == 1:
		current_level = 2
	elif current_level == 2:
		current_level = 1
		current_cycle += 1


## Returns true when the player is on the final level (cycle 2, level 2).
func is_final_level() -> bool:
	return current_cycle == 2 and current_level == 2


## Resets all run-level systems for a fresh run.
func start_new_run() -> void:
	current_level = 1
	current_cycle = 1
	Autoloads.soul_energy_manager().reset()
	relic_grid.reset()
	shard_inventory.reset()


## Awards the relic to the player. Idempotent — does nothing if already unlocked.
func award_relic() -> void:
	if relic_grid.is_unlocked:
		return
	relic_grid.is_unlocked = true


## Returns whether the relic has been unlocked.
func is_relic_unlocked() -> bool:
	return relic_grid.is_unlocked


## Serializes all run-level state for persistence across level transitions.
func save_run_state() -> Dictionary:
	return {
		"soul_energy": Autoloads.soul_energy_manager().get_souls(),
		"relic_grid": relic_grid.serialize(),
		"shard_inventory": shard_inventory.serialize(),
		"current_level": current_level,
		"current_cycle": current_cycle,
	}


## Restores run-level state from a previously saved dictionary.
func load_run_state(data: Dictionary) -> void:
	if data == null or data.is_empty():
		return

	# Restore soul energy
	var souls: int = data.get("soul_energy", 0)
	var sem = Autoloads.soul_energy_manager()
	sem.current_souls = souls
	sem.souls_changed.emit(souls)

	# Restore level progression (default to 1 if missing)
	current_level = data.get("current_level", 1)
	current_cycle = data.get("current_cycle", 1)

	# Restore relic grid
	var grid_data = data.get("relic_grid", {})
	if grid_data is Dictionary and not grid_data.is_empty():
		relic_grid = RelicGrid.deserialize(grid_data)

	# Restore shard inventory
	var inv_data = data.get("shard_inventory", [])
	if inv_data is Array:
		var deserialized: Array[Shard] = []
		for entry in inv_data:
			if entry is Dictionary:
				deserialized.append(Shard.deserialize(entry))
		shard_inventory.shards = deserialized
		shard_inventory.inventory_changed.emit()

	# Reapply stat bonuses from restored grid
	stat_bonus_applier.apply_bonuses()


func save_game_data():
	# TODO: Implement save system
	pass

func load_game_data():
	# TODO: Implement load system
	pass
