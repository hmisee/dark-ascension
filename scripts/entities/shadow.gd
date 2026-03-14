extends CharacterBody2D
class_name Shadow

# Base shadow companion - follows player in formation and attacks nearby enemies

signal shadow_died(shadow_type: String)

@export var follow_speed: float = 180.0
@export var formation_offset: Vector2 = Vector2.ZERO  # Set by subclass
@export var attack_cooldown: float = 1.2
@export var attack_damage: float = 15.0
@export var attack_range: float = 150.0
@export var max_health: float = 50.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

# Teal tint to distinguish from enemies
const TEAL_TINT := Color(0.3, 1.0, 0.9, 1.0)

var player: Node2D = null
var current_health: float
var attack_timer: float = 0.0
var is_dead: bool = false
var target_enemy: Node2D = null
var shadow_type: String = ""  # Set by subclasses: "skeleton" or "wraith"
var is_weakened: bool = false
var regen_rate: float = 5.0
var _weakened_pulse_time: float = 0.0

func _ready():
	current_health = max_health
	add_to_group("shadow")
	animated_sprite.modulate = TEAL_TINT
	update_health_bar()

func _physics_process(delta):
	if is_dead or not player:
		return
	if is_weakened:
		_process_weakened_state(delta)
	follow_player()
	attack_timer -= delta
	if attack_timer <= 0:
		find_and_attack_nearest_enemy()

func follow_player():
	# Formation offset rotates based on player's aim direction (cursor)
	var aim_dir = player.last_direction
	var perp = Vector2(-aim_dir.y, aim_dir.x)  # perpendicular, unused but available
	
	# Rotate the formation offset to align with aim direction
	var rotated_offset = aim_dir * formation_offset.x + perp * formation_offset.y
	var target_pos = player.global_position + rotated_offset
	
	var to_target = target_pos - global_position
	if to_target.length() > 5.0:
		velocity = to_target.normalized() * follow_speed
		animated_sprite.flip_h = velocity.x < 0
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("walk"):
			if animated_sprite.animation != "walk":
				animated_sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle"):
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
	
	move_and_slide()

func find_and_attack_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest: Node2D = null
	var nearest_dist := attack_range
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	
	if nearest:
		perform_attack(nearest)
		attack_timer = attack_cooldown

func perform_attack(enemy: Node2D):
	# Face the enemy
	animated_sprite.flip_h = enemy.global_position.x < global_position.x
	
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
	
	if enemy.has_method("take_damage"):
		enemy.take_damage(attack_damage)

func take_damage(amount: float):
	if is_dead:
		return
	current_health -= amount
	update_health_bar()
	flash_damage()
	if current_health <= 0:
		die()

func flash_damage():
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	if not is_dead and not is_weakened:
		animated_sprite.modulate = TEAL_TINT

func update_health_bar():
	if health_bar:
		health_bar.value = (current_health / max_health) * 100

func die():
	is_dead = true
	velocity = Vector2.ZERO
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	# Hide and disable instead of queue_free so we can resurrect later
	visible = false
	set_physics_process(false)
	set_process(false)
	shadow_died.emit(shadow_type)

func resurrect_at(pos: Vector2) -> void:
	global_position = pos
	is_dead = false
	current_health = max_health * 0.5
	is_weakened = true
	_weakened_pulse_time = 0.0
	velocity = Vector2.ZERO
	attack_timer = 0.0
	target_enemy = null
	visible = true
	set_physics_process(true)
	set_process(true)
	update_health_bar()
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

func _process_weakened_state(delta: float) -> void:
	# Regenerate HP
	current_health = min(max_health, current_health + regen_rate * delta)
	update_health_bar()
	# Exit weakened state when fully healed
	if current_health >= max_health:
		is_weakened = false
		_weakened_pulse_time = 0.0
		animated_sprite.modulate = TEAL_TINT
		return
	# Pulsing teal tint visual while weakened
	_weakened_pulse_time += delta
	var pulse = (sin(_weakened_pulse_time * 4.0) + 1.0) / 2.0  # oscillates 0..1
	var dimmed_teal = TEAL_TINT.darkened(0.3)
	animated_sprite.modulate = dimmed_teal.lerp(TEAL_TINT, pulse)
