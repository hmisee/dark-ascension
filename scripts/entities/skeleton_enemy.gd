extends Enemy
class_name SkeletonEnemy

# Melee enemy that chases player aggressively

func _ready():
	super._ready()
	max_health = 30.0
	move_speed = 100.0
	contact_damage = 8.0
	current_health = max_health
	update_health_bar()
