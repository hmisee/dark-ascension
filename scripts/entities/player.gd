extends CharacterBody2D
class_name Player

signal player_died

# Player movement and control

@export var move_speed: float = 200.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
@export var attack_cooldown: float = 1.0
@export var attack_animation_duration: float = 0.3
@export var max_health: float = 100.0
@export var shadow_skeleton_scene: PackedScene = preload("res://scenes/shadow_skeleton.tscn")
@export var shadow_wraith_scene: PackedScene = preload("res://scenes/shadow_wraith.tscn")

@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow_ui = $CanvasLayer/ShadowCooldownUI
@onready var health_bar = $HealthBar

var attack_timer: float = 0.0
var last_direction: Vector2 = Vector2.RIGHT
var is_playing_attack: bool = false
var attack_animation_timer: float = 0.0
var current_health: float
var shadows: Array = []
var managed_level: bool = false

# Shadow resurrection system
var resurrection_system: ShadowResurrectionSystem

func _ready():
	if animated_sprite.sprite_frames != null:
		animated_sprite.play("idle")
	add_to_group("player")
	current_health = max_health
	_style_health_bar()
	update_health_bar()
	_setup_resurrection_system()
	_setup_soul_energy_hud()
	# Register with stat bonus applier
	if Autoloads.game_manager().stat_bonus_applier:
		Autoloads.game_manager().stat_bonus_applier.register_player(self)
	# Spawn shadows after one frame so the scene tree is ready
	call_deferred("spawn_shadows")

func _setup_resurrection_system():
	resurrection_system = ShadowResurrectionSystem.new()
	resurrection_system.name = "ShadowResurrectionSystem"
	resurrection_system.player = self
	add_child(resurrection_system)
	# Connect resurrection system signals to UI updates
	resurrection_system.shadow_died.connect(_on_resurrection_shadow_died)
	resurrection_system.cooldown_updated.connect(_on_resurrection_cooldown_updated)
	resurrection_system.shadow_ready.connect(_on_resurrection_shadow_ready)
	resurrection_system.resurrection_failed.connect(_on_resurrection_failed)

func _setup_soul_energy_hud():
	var soul_hud = SoulEnergyHUD.new()
	soul_hud.name = "SoulEnergyHUD"
	$CanvasLayer.add_child(soul_hud)

func spawn_shadows():
	_spawn_shadow(shadow_skeleton_scene, "skeleton")
	_spawn_shadow(shadow_wraith_scene, "wraith")
	# Apply any existing relic grid bonuses (e.g. restored from level transition)
	if Autoloads.game_manager().stat_bonus_applier:
		Autoloads.game_manager().stat_bonus_applier.apply_bonuses()

func _spawn_shadow(scene: PackedScene, _type: String):
	var shadow = scene.instantiate()
	shadow.player = self
	shadow.global_position = global_position
	get_parent().add_child(shadow)
	shadows.append(shadow)
	# Register with resurrection system and connect shadow_died signal
	resurrection_system.register_shadow(shadow)
	shadow.shadow_died.connect(resurrection_system.on_shadow_died)
	# Register with stat bonus applier
	if Autoloads.game_manager().stat_bonus_applier:
		Autoloads.game_manager().stat_bonus_applier.register_shadow(shadow)
	update_shadow_ui()

func update_shadow_ui():
	if not shadow_ui:
		return
	# Derive UI state from the resurrection system and shadow nodes
	var skel_alive := true
	var skel_timer := 0.0
	var skel_max: float = resurrection_system.resurrection_cooldowns.get("skeleton", 8.0)
	var wraith_alive := true
	var wraith_timer := 0.0
	var wraith_max: float = resurrection_system.resurrection_cooldowns.get("wraith", 12.0)

	var skel_shadow: Shadow = resurrection_system._shadows.get("skeleton")
	if skel_shadow and skel_shadow.is_dead:
		skel_alive = false
		skel_timer = resurrection_system._cooldown_remaining.get("skeleton", 0.0)

	var wraith_shadow: Shadow = resurrection_system._shadows.get("wraith")
	if wraith_shadow and wraith_shadow.is_dead:
		wraith_alive = false
		wraith_timer = resurrection_system._cooldown_remaining.get("wraith", 0.0)

	var skel_cost: int = resurrection_system.resurrection_costs.get("skeleton", 30)
	var wraith_cost: int = resurrection_system.resurrection_costs.get("wraith", 50)
	var current_souls: int = Autoloads.soul_energy_manager().get_souls()

	shadow_ui.update_cooldowns(
		skel_alive, skel_timer, skel_max,
		wraith_alive, wraith_timer, wraith_max,
		skel_cost, wraith_cost, current_souls
	)

func _unhandled_input(event: InputEvent) -> void:
	# Press 1 to resurrect skeleton, press 2 to resurrect wraith
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			resurrection_system.try_resurrect("skeleton")
		elif event.keycode == KEY_2:
			resurrection_system.try_resurrect("wraith")

func _on_resurrection_shadow_died(_shadow_type: String) -> void:
	update_shadow_ui()

func _on_resurrection_cooldown_updated(_shadow_type: String, _remaining: float) -> void:
	update_shadow_ui()

func _on_resurrection_shadow_ready(_shadow_type: String, _cost: int) -> void:
	update_shadow_ui()

func _on_resurrection_failed(_shadow_type: String, _reason: String) -> void:
	update_shadow_ui()

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
	update_health_bar()
	print("Player took %.1f damage! Health: %.1f/%.1f" % [amount, current_health, max_health])
	
	# Visual feedback
	flash_damage()
	
	if current_health <= 0:
		die()

func update_health_bar():
	if health_bar:
		health_bar.value = (current_health / max_health) * 100

func _style_health_bar():
	if health_bar:
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.8, 0.1, 0.1)
		health_bar.add_theme_stylebox_override("fill", fill)
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color(0.2, 0.2, 0.2)
		health_bar.add_theme_stylebox_override("background", bg)

func flash_damage():
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)

func die():
	print("Player died!")
	player_died.emit()
	if not managed_level:
		# Defer scene reload to avoid removing CollisionObjects during physics callback
		get_tree().call_deferred("reload_current_scene")
