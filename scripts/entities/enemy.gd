extends CharacterBody2D
class_name Enemy

# Base enemy class

@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 10.0
@export var contact_damage: float = 5.0

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D

var current_health: float
var player: Node2D = null

func _ready():
	current_health = max_health
	update_health_bar()
	find_player()

func _physics_process(delta):
	if player:
		move_toward_player(delta)

func find_player():
	# Find player in scene
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func move_toward_player(delta):
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed
	
	# Flip sprite based on direction
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	move_and_slide()

func take_damage(amount: float):
	current_health -= amount
	update_health_bar()
	
	# Visual feedback
	flash_damage()
	
	if current_health <= 0:
		die()

func flash_damage():
	# Flash red when hit
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

func update_health_bar():
	if health_bar:
		health_bar.value = (current_health / max_health) * 100

func die():
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)
