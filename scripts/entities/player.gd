extends CharacterBody2D
class_name Player

# Player movement and control

@export var move_speed: float = 200.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
@export var attack_cooldown: float = 1.0
@export var attack_animation_duration: float = 0.3
@export var max_health: float = 100.0
@export var shadow_skeleton_scene: PackedScene = preload("res://scenes/shadow_skeleton.tscn")
@export var shadow_wraith_scene: PackedScene = preload("res://scenes/shadow_wraith.tscn")
@export var shadow_respawn_cooldown: float = 10.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow_ui = $CanvasLayer/ShadowCooldownUI

var attack_timer: float = 0.0
var last_direction: Vector2 = Vector2.RIGHT
var is_playing_attack: bool = false
var attack_animation_timer: float = 0.0
var current_health: float
var shadows: Array = []

# Shadow respawn tracking
var shadow_skeleton_alive: bool = false
var shadow_wraith_alive: bool = false
var skeleton_respawn_timer: float = 0.0
var wraith_respawn_timer: float = 0.0

func _ready():
	if animated_sprite.sprite_frames != null:
		animated_sprite.play("idle")
	add_to_group("player")
	current_health = max_health
	# Spawn shadows after one frame so the scene tree is ready
	call_deferred("spawn_shadows")

func spawn_shadows():
	_spawn_shadow(shadow_skeleton_scene, "skeleton")
	_spawn_shadow(shadow_wraith_scene, "wraith")

func _spawn_shadow(scene: PackedScene, type: String):
	var shadow = scene.instantiate()
	shadow.player = self
	shadow.global_position = global_position
	shadow.tree_exiting.connect(_on_shadow_died.bind(type))
	get_parent().add_child(shadow)
	shadows.append(shadow)
	if type == "skeleton":
		shadow_skeleton_alive = true
	elif type == "wraith":
		shadow_wraith_alive = true
	update_shadow_ui()

func _on_shadow_died(type: String):
	if type == "skeleton":
		shadow_skeleton_alive = false
		skeleton_respawn_timer = shadow_respawn_cooldown
	elif type == "wraith":
		shadow_wraith_alive = false
		wraith_respawn_timer = shadow_respawn_cooldown
	# Clean up dead shadows from array
	shadows = shadows.filter(func(s): return is_instance_valid(s) and not s.is_queued_for_deletion())
	update_shadow_ui()

func handle_shadow_respawns(delta):
	if not shadow_skeleton_alive:
		skeleton_respawn_timer -= delta
		if skeleton_respawn_timer <= 0:
			_spawn_shadow(shadow_skeleton_scene, "skeleton")
	
	if not shadow_wraith_alive:
		wraith_respawn_timer -= delta
		if wraith_respawn_timer <= 0:
			_spawn_shadow(shadow_wraith_scene, "wraith")
	
	update_shadow_ui()

func update_shadow_ui():
	if shadow_ui:
		shadow_ui.update_cooldowns(
			shadow_skeleton_alive, skeleton_respawn_timer, shadow_respawn_cooldown,
			shadow_wraith_alive, wraith_respawn_timer, shadow_respawn_cooldown
		)

func _physics_process(delta):
	handle_movement()
	handle_auto_attack(delta)
	handle_attack_animation(delta)
	update_aim_direction()
	handle_shadow_respawns(delta)

func handle_movement():
	var input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		velocity = input_direction * move_speed
		
		if not is_playing_attack:
			animated_sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		if not is_playing_attack:
			animated_sprite.play("idle")
	
	move_and_slide()

func update_aim_direction():
	# Get direction from player to mouse cursor
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	last_direction = direction_to_mouse
	
	# Flip sprite based on mouse position
	if direction_to_mouse.x > 0:
		animated_sprite.flip_h = false  # Face right
	elif direction_to_mouse.x < 0:
		animated_sprite.flip_h = true   # Face left

func handle_attack_animation(delta):
	if is_playing_attack:
		attack_animation_timer -= delta
		if attack_animation_timer <= 0:
			is_playing_attack = false

func handle_auto_attack(delta):
	attack_timer -= delta
	
	if attack_timer <= 0:
		play_attack_animation()
		spawn_projectile()
		attack_timer = attack_cooldown

func play_attack_animation():
	# Play attack animation if it exists
	if animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
		is_playing_attack = true
		attack_animation_timer = attack_animation_duration

func spawn_projectile():
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Position projectile in front of player
	var spawn_offset = last_direction * 30
	projectile.global_position = global_position + spawn_offset
	projectile.direction = last_direction


func take_damage(amount: float):
	current_health -= amount
	print("Player took %.1f damage! Health: %.1f/%.1f" % [amount, current_health, max_health])
	
	# Visual feedback
	flash_damage()
	
	if current_health <= 0:
		die()

func flash_damage():
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)

func die():
	print("Player died!")
	# TODO: Game over screen
	get_tree().reload_current_scene()
