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
		SoulEnergyManager.add_souls(soul_value)
		queue_free()
