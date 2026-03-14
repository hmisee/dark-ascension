extends SkeletonEnemy
class_name BossSkeleton

signal boss_defeated

func _ready():
	super._ready()
	max_health = 200.0
	move_speed = 70.0
	contact_damage = 20.0
	soul_value = 50
	current_health = max_health
	scale = Vector2(2.0, 2.0)
	update_health_bar()

func die():
	boss_defeated.emit()
	super.die()
