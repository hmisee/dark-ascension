extends CharacterBody2D
class_name Enemy

# Base enemy class

@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 10.0
@export var contact_damage: float = 5.0

@onready var health_bar = $HealthBar
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_health: float
var player: Node2D = null
var is_dead: bool = false

func _ready():
	current_health = max_health
	update_health_bar()
	find_player()

func _physics_process(_delta):
	if player and not is_dead:
		move_toward_player()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func move_toward_player():
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed
	
	# Flip sprite based on direction
	animated_sprite.flip_h = direction.x < 0
	
	if animated_sprite.animation != "walk":
		animated_sprite.play("walk")
	
	move_and_slide()

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
	if not is_dead:
		animated_sprite.modulate = Color(1, 1, 1)

func update_health_bar():
	if health_bar:
		health_bar.value = (current_health / max_health) * 100

func die():
	is_dead = true
	velocity = Vector2.ZERO
	# Play death animation if available, otherwise just free
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)
