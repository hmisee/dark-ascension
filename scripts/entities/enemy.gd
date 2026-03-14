extends CharacterBody2D
class_name Enemy

# Base enemy class

@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 10.0
@export var contact_damage: float = 5.0
@export var soul_value: int = 10
@export var soul_drop_scene: PackedScene

@onready var health_bar = $HealthBar
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_health: float
var player: Node2D = null
var is_dead: bool = false
var taunt_target: Node2D = null
var _taunt_timer: float = 0.0

func _ready():
	current_health = max_health
	_style_health_bar()
	update_health_bar()
	find_player()

func _style_health_bar():
	if health_bar:
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.8, 0.1, 0.1)
		health_bar.add_theme_stylebox_override("fill", fill)
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color(0.2, 0.2, 0.2)
		health_bar.add_theme_stylebox_override("background", bg)

func _physics_process(delta):
	if is_dead:
		return
	_update_taunt(delta)
	if player:
		move_toward_player()

func _update_taunt(delta: float):
	if taunt_target:
		_taunt_timer -= delta
		if _taunt_timer <= 0 or not is_instance_valid(taunt_target) or taunt_target.is_dead:
			taunt_target = null
			_taunt_timer = 0.0

func get_chase_target() -> Node2D:
	if taunt_target and is_instance_valid(taunt_target) and not taunt_target.is_dead:
		return taunt_target
	return player

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func move_toward_player():
	var target = get_chase_target()
	if not target:
		return
	
	var direction = (target.global_position - global_position).normalized()
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
		call_deferred("die")
	else:
		var am = Autoloads.audio_manager()
		if am:
			am.play_sfx("enemy_hit")

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
	var am = Autoloads.audio_manager()
	if am:
		am.play_sfx("enemy_death")
	velocity = Vector2.ZERO
	# Spawn soul drop at death position
	_spawn_soul_drop()
	# Play death animation if available, otherwise just free
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	queue_free()

func _spawn_soul_drop():
	var scene = soul_drop_scene
	if not scene:
		scene = load("res://scenes/soul_drop.tscn")
	if scene:
		var drop = scene.instantiate()
		drop.soul_value = soul_value
		drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", drop)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)

func set_taunt(source: Node2D, duration: float) -> void:
	taunt_target = source
	_taunt_timer = duration
