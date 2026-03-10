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
	current_health = max_health
	update_health_bar()
	
	# Load projectile if not set
	if not projectile_scene:
		projectile_scene = load("res://scenes/enemy_projectile.tscn")

func _physics_process(delta):
	if not player:
		find_player()
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Keep distance from player
	if distance_to_player < min_distance:
		move_away_from_player()
	elif distance_to_player > attack_range:
		move_toward_player(delta)
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
	# Attack logic
	attack_timer -= delta
	if attack_timer <= 0 and distance_to_player <= attack_range:
		shoot_at_player()
		attack_timer = attack_cooldown

func move_away_from_player():
	var direction = (global_position - player.global_position).normalized()
	velocity = direction * move_speed
	
	# Flip sprite
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	move_and_slide()

func shoot_at_player():
	if not projectile_scene or not player:
		return
	
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	var direction = (player.global_position - global_position).normalized()
	projectile.global_position = global_position + direction * 20
	projectile.direction = direction
