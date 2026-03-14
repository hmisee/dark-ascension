extends Area2D
## A collectible soul pickup that spawns when an enemy dies.
## The player walks over it to collect soul energy.

@export var soul_value: int = 10

## Gentle bobbing animation
var _time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# Small floating bob effect
	_time += delta
	position.y += sin(_time * 4.0) * 0.15


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var bonus := 0.0
		var gm = Autoloads.game_manager()
		if gm and gm.stat_bonus_applier:
			bonus = gm.stat_bonus_applier.soul_bonus
		var effective_souls := int(round(soul_value * (1.0 + bonus / 100.0)))
		Autoloads.soul_energy_manager().add_souls(effective_souls)
		queue_free()
