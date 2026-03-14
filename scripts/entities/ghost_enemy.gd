extends Enemy
class_name GhostEnemy

# Ranged enemy that keeps distance and shoots projectiles

@export var attack_range: float = 200.0
@export var min_distance: float = 150.0
@export var attack_cooldown: float = 2.0
@export var projectile_scene: PackedScene

var attack_timer: float = 0.0

func _ready():
	super._ready()
	max_health = 20.0
	move_speed = 60.0
	contact_damage = 5.0
	soul_value = 15
	current_health = max_health
	update_health_bar()
	
	# Load projectile if not set
	if not projectile_scene:
		projectile_scene = load("res://scenes/enemy_projectile.tscn")

func _physics_process(delta):
	if is_dead:
		return
	if not player:
		find_player()
		return
	
	_update_taunt(delta)
	var target = get_chase_target()
	if not target:
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# Keep distance from target
	if distance_to_target < min_distance:
		# Move away
		var direction = (global_position - target.global_position).normalized()
		velocity = direction * move_speed
		animated_sprite.flip_h = direction.x < 0
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		move_and_slide()
	elif distance_to_target > attack_range:
		move_toward_player()
	else:
		velocity = Vector2.ZERO
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
		move_and_slide()
	
	# Attack logic
	attack_timer -= delta
	if attack_timer <= 0 and distance_to_target <= attack_range:
		shoot_at_target(target)
		attack_timer = attack_cooldown

func shoot_at_target(target: Node2D):
	if not projectile_scene or not target:
		return
	
	# Play attack animation if available
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
	
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	var direction = (target.global_position - global_position).normalized()
	projectile.global_position = global_position + direction * 20
	projectile.direction = direction
