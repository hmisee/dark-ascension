extends CharacterBody2D
class_name Player

# Player movement and control

@export var move_speed: float = 200.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Animation will be set up in Godot editor
	if animated_sprite.sprite_frames != null:
		animated_sprite.play("default")
	print("Player ready! Use WASD or Arrow keys to move")

func _physics_process(delta):
	handle_movement()

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
		animated_sprite.play("walk")
		
		# Flip sprite based on horizontal movement direction
		if input_direction.x > 0:
			animated_sprite.flip_h = false  # Face right
		elif input_direction.x < 0:
			animated_sprite.flip_h = true   # Face left
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
	
	move_and_slide()
