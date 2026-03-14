extends Shadow
class_name ShadowSkeleton

# Melee shadow - positions in FRONT of player, close-range attacker

func _ready():
	shadow_type = "skeleton"
	# Front of player: positive X offset (in front relative to aim direction)
	formation_offset = Vector2(60, 0)
	attack_range = 80.0
	attack_damage = 20.0
	attack_cooldown = 1.0
	max_health = 60.0
	follow_speed = 200.0
	super._ready()
