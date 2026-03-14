extends Node
class_name StatBonusApplier

## Applies relic grid stat bonuses to the player and active shadows.
## Captures base stats on initialization, then reapplies base + bonus
## whenever the relic grid changes.

# Base stats captured at registration time
var _player: Player = null
var _player_base_stats := {
	"move_speed": 0.0,
	"attack_cooldown": 0.0,
	"max_health": 0.0,
}

var _shadows: Array[Shadow] = []
var _shadow_base_stats: Dictionary = {}  # shadow instance -> Dictionary of base stats

# Stored modifiers that other systems can read
var damage_amp: float = 0.0
var soul_bonus: float = 0.0
var crit_chance: float = 0.0
var resurrection_cooldown_multiplier: float = 1.0


func register_player(player: Player) -> void:
	_player = player
	_player_base_stats = {
		"move_speed": player.move_speed,
		"attack_cooldown": player.attack_cooldown,
		"max_health": player.max_health,
	}


func register_shadow(shadow: Shadow) -> void:
	if shadow in _shadows:
		return
	_shadows.append(shadow)
	_shadow_base_stats[shadow] = {
		"attack_cooldown": shadow.attack_cooldown,
		"attack_damage": shadow.attack_damage,
		"max_health": shadow.max_health,
		"follow_speed": shadow.follow_speed,
		"regen_rate": shadow.regen_rate,
	}


func unregister_shadow(shadow: Shadow) -> void:
	_shadows.erase(shadow)
	_shadow_base_stats.erase(shadow)


## Call this after any relic grid change or on level load.
func apply_bonuses() -> void:
	var bonuses: Dictionary = Autoloads.game_manager().relic_grid.calculate_all_bonuses()
	var cd_reduce_pct := bonuses.get(Shard.StatType.COOLDOWN_REDUCTION, 0.0) as float
	resurrection_cooldown_multiplier = maxf(0.1, 1.0 - cd_reduce_pct / 100.0)
	_apply_to_player(bonuses)
	_apply_to_shadows(bonuses)


func _apply_to_player(bonuses: Dictionary) -> void:
	if _player == null:
		return

	var base_move := _player_base_stats["move_speed"] as float
	var base_cd := _player_base_stats["attack_cooldown"] as float
	var base_max_hp := _player_base_stats["max_health"] as float

	# Movement speed: percentage increase
	var move_pct := bonuses.get(Shard.StatType.MOVEMENT_SPEED, 0.0) as float
	_player.move_speed = base_move * (1.0 + move_pct / 100.0)

	# Attack cooldown: attack speed percentage decrease (clamped so cooldown doesn't go negative)
	var atk_speed_pct := bonuses.get(Shard.StatType.ATTACK_SPEED, 0.0) as float
	_player.attack_cooldown = base_cd * maxf(0.1, 1.0 - atk_speed_pct / 100.0)

	# Max health: flat addition
	var hp_bonus := bonuses.get(Shard.StatType.MAX_HEALTH, 0.0) as float
	var old_max := _player.max_health
	_player.max_health = base_max_hp + hp_bonus
	# Scale current health proportionally if max increased
	if _player.max_health > old_max and old_max > 0:
		_player.current_health += (_player.max_health - old_max)

	# Damage amp: store as modifier (projectile reads this)
	damage_amp = bonuses.get(Shard.StatType.DAMAGE_AMP, 0.0) as float

	# Soul bonus: stored for SoulEnergyManager to read
	soul_bonus = bonuses.get(Shard.StatType.SOUL_BONUS, 0.0) as float

	# Crit chance: stored for future combat use
	crit_chance = bonuses.get(Shard.StatType.CRIT_CHANCE, 0.0) as float


func _apply_to_shadows(bonuses: Dictionary) -> void:
	var atk_speed_pct := bonuses.get(Shard.StatType.ATTACK_SPEED, 0.0) as float
	var dmg_amp_pct := bonuses.get(Shard.StatType.DAMAGE_AMP, 0.0) as float
	var heal_rate_bonus := bonuses.get(Shard.StatType.HEALING_RATE, 0.0) as float
	var hp_bonus := bonuses.get(Shard.StatType.MAX_HEALTH, 0.0) as float
	var move_pct := bonuses.get(Shard.StatType.MOVEMENT_SPEED, 0.0) as float

	for shadow in _shadows:
		if not is_instance_valid(shadow):
			continue
		var base: Dictionary = _shadow_base_stats.get(shadow, {})
		if base.is_empty():
			continue

		# Attack cooldown: attack speed percentage decrease
		var base_cd := base["attack_cooldown"] as float
		shadow.attack_cooldown = base_cd * maxf(0.1, 1.0 - atk_speed_pct / 100.0)

		# Attack damage: percentage increase
		var base_dmg := base["attack_damage"] as float
		shadow.attack_damage = base_dmg * (1.0 + dmg_amp_pct / 100.0)

		# Healing rate: flat addition
		var base_regen := base["regen_rate"] as float
		shadow.regen_rate = base_regen + heal_rate_bonus

		# Max health: flat addition
		var base_max_hp := base["max_health"] as float
		var old_max := shadow.max_health
		shadow.max_health = base_max_hp + hp_bonus
		if shadow.max_health > old_max and old_max > 0 and not shadow.is_dead:
			shadow.current_health += (shadow.max_health - old_max)

		# Follow speed: percentage increase
		var base_follow := base["follow_speed"] as float
		shadow.follow_speed = base_follow * (1.0 + move_pct / 100.0)
