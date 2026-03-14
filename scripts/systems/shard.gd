extends Resource
class_name Shard

enum StatType {
	COOLDOWN_REDUCTION,
	DAMAGE_AMP,
	ATTACK_SPEED,
	HEALING_RATE,
	MAX_HEALTH,
	MOVEMENT_SPEED,
	SOUL_BONUS,
	CRIT_CHANCE
}

enum Direction { UP, DOWN, LEFT, RIGHT }

@export var shard_name: String
@export var stat_type: StatType
@export var base_value: float
@export var adjacency_bonus_percent: float = 25.0
@export var receive_directions: Array[Direction] = []
@export var purchase_price: int = 0
@export var sell_value: int = 0


func get_effective_value(active_adjacency_count: int) -> float:
	return base_value * (1.0 + active_adjacency_count * adjacency_bonus_percent / 100.0)


func serialize() -> Dictionary:
	var dirs: Array[int] = []
	for d in receive_directions:
		dirs.append(d as int)
	return {
		"shard_name": shard_name,
		"stat_type": stat_type as int,
		"base_value": base_value,
		"adjacency_bonus_percent": adjacency_bonus_percent,
		"receive_directions": dirs,
		"purchase_price": purchase_price,
		"sell_value": sell_value,
	}


static func deserialize(data: Dictionary) -> Shard:
	var shard := Shard.new()
	shard.shard_name = data.get("shard_name", "")
	shard.stat_type = data.get("stat_type", StatType.COOLDOWN_REDUCTION) as StatType
	shard.base_value = data.get("base_value", 0.0)
	shard.adjacency_bonus_percent = data.get("adjacency_bonus_percent", 25.0)
	var dirs_raw = data.get("receive_directions", [])
	var dirs: Array[Direction] = []
	for d in dirs_raw:
		dirs.append(d as Direction)
	shard.receive_directions = dirs
	shard.purchase_price = data.get("purchase_price", 0)
	shard.sell_value = data.get("sell_value", 0)
	return shard
