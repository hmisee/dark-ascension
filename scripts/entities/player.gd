extends CharacterBody2D
class_name Player

# Player movement and control

@export var move_speed: float = 200.0

@onready var sprite = $Sprite2D

func _ready():
	# Load the sprite texture
	sprite.texture = load("res://assets/sprites/characters/necromancer_idle.png")
	# Scale up the sprite to be more visible
	sprite.scale = Vector2(2, 2)
	print("Player ready! Use WASD or Arrow keys to move")

func _physics_process(delta):
	handle_movement()

func handle_movement():
	# Simple direct input check
	var input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	
	# Normalize diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	# Set velocity
	velocity = input_direction * move_speed
	
	# Move the character
	move_and_slide()
