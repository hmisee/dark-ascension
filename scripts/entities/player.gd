extends CharacterBody2D
class_name Player

# Player movement and control

@export var move_speed: float = 200.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
@export var attack_cooldown: float = 1.0
@export var attack_animation_duration: float = 0.3
@export var max_health: float = 100.0

@onready var animated_sprite = $AnimatedSprite2D

var attack_timer: float = 0.0
var last_direction: Vector2 = Vector2.RIGHT
var is_playing_attack: bool = false
var attack_animation_timer: float = 0.0
var current_health: float

func _ready():
	# Animation will be set up in Godot editor
	if animated_sprite.sprite_frames != null:
		animated_sprite.play("default")
	
	# Add to player group for enemy targeting
	add_to_group("player")
	
	# Initialize health
	current_health = max_health
	
	print("Player ready! Use WASD or Arrow keys to move")
	print("Aim with mouse cursor - Auto-attacking every %.1f seconds" % attack_cooldown)

func _physics_process(delta):
	handle_movement()
	handle_auto_attack(delta)
	handle_attack_animation(delta)
	update_aim_direction()

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
