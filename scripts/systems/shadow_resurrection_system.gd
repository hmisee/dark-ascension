extends Node
class_name ShadowResurrectionSystem

## Manages shadow death tracking, cooldown timers, and soul-cost resurrection.
## Holds references to registered shadow nodes so it can call resurrect_at() on them.

signal shadow_died(shadow_type: String)
signal cooldown_updated(shadow_type: String, remaining: float)
signal shadow_ready(shadow_type: String, cost: int)
signal resurrection_failed(shadow_type: String, reason: String)

# Per-shadow-type configuration
var resurrection_costs: Dictionary = {"skeleton": 30, "wraith": 50}
var resurrection_cooldowns: Dictionary = {"skeleton": 8.0, "wraith": 12.0}

# Cooldown state: shadow_type -> remaining seconds (only present while on cooldown or eligible)
var _cooldown_remaining: Dictionary = {}
# Whether each shadow type is eligible (cooldown expired, still dead)
var _is_eligible: Dictionary = {}
# Registered shadow node references: shadow_type -> Shadow node
var _shadows: Dictionary = {}

# Player reference for getting resurrection position
var player: Node2D = null


func register_shadow(shadow: Shadow) -> void:
	_shadows[shadow.shadow_type] = shadow


func on_shadow_died(shadow_type: String) -> void:
	if shadow_type not in resurrection_cooldowns:
		return
	_cooldown_remaining[shadow_type] = resurrection_cooldowns[shadow_type]
	_is_eligible[shadow_type] = false
	shadow_died.emit(shadow_type)


func try_resurrect(shadow_type: String) -> bool:
	# Unknown type
	if shadow_type not in resurrection_costs:
		resurrection_failed.emit(shadow_type, "unknown_type")
		return false

	# No registered shadow for this type
	if shadow_type not in _shadows:
		resurrection_failed.emit(shadow_type, "unknown_type")
		return false

	var shadow: Shadow = _shadows[shadow_type]

	# Shadow isn't actually dead
	if not shadow.is_dead:
		resurrection_failed.emit(shadow_type, "not_dead")
		return false

	# Still on cooldown
	if not _is_eligible.get(shadow_type, false):
		resurrection_failed.emit(shadow_type, "on_cooldown")
		return false

	# Check soul cost
	var cost: int = resurrection_costs[shadow_type]
	if not Autoloads.soul_energy_manager().spend_souls(cost):
		resurrection_failed.emit(shadow_type, "insufficient_souls")
		return false

	# Resurrect at player position
	var pos := get_player_position()
	shadow.resurrect_at(pos)

	# Clear cooldown/eligibility state
	_cooldown_remaining.erase(shadow_type)
	_is_eligible.erase(shadow_type)
	return true


func get_player_position() -> Vector2:
	if player and is_instance_valid(player):
		return player.global_position
	return Vector2.ZERO


func _process(delta: float) -> void:
	for shadow_type in _cooldown_remaining.keys():
		if _is_eligible.get(shadow_type, false):
			# Already eligible, nothing to tick
			continue

		_cooldown_remaining[shadow_type] -= delta

		if _cooldown_remaining[shadow_type] <= 0.0:
			_cooldown_remaining[shadow_type] = 0.0
			_is_eligible[shadow_type] = true
			shadow_ready.emit(shadow_type, resurrection_costs.get(shadow_type, 0))
		else:
			cooldown_updated.emit(shadow_type, _cooldown_remaining[shadow_type])
