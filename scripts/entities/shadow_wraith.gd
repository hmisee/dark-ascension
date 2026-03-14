extends Shadow
class_name ShadowWraith

# Ranged shadow - positions BEHIND player, attacks from distance

@export var projectile_scene: PackedScene

func _ready():
	# Behind player: negative X offset (behind relative to aim direction)
	formation_offset = Vector2(-70, 0)
	attack_range = 200.0
	attack_damage = 12.0
	attack_cooldown = 1.8
	max_health = 40.0
	follow_speed = 180.0
	super._ready()
	
	if not projectile_scene:
		projectile_scene = load("res://scenes/projectile.tscn")

func perform_attack(enemy: Node2D):
	# Face the enemy
	animated_sprite.flip_h = enemy.global_position.x < global_position.x
	
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
	
	# Shoot a projectile toward the enemy
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		var direction = (enemy.global_position - global_position).normalized()
		projectile.global_position = global_position + direction * 25
		projectile.direction = direction
