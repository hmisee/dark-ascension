extends GhostEnemy
class_name BossWraith

signal boss_defeated

func _ready():
	super._ready()
	max_health = 250.0
	move_speed = 50.0
	contact_damage = 15.0
	soul_value = 75
	attack_cooldown = 1.5
	current_health = max_health
	scale = Vector2(2.0, 2.0)
	update_health_bar()

func die():
	boss_defeated.emit()
	super.die()
