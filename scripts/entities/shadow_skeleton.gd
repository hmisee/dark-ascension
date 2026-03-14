extends Shadow
class_name ShadowSkeleton

# Melee tank shadow - positions in FRONT of player, taunts enemies to protect the necromancer

@export var taunt_radius: float = 500.0
@export var taunt_duration: float = 5.0
@export var taunt_cooldown: float = 10.0
@export var damage_reduction: float = 0.5

var taunt_timer: float = 0.0
var is_taunting: bool = false
var _taunt_cooldown_remaining: float = 3.0  # First taunt after 3s so enemies exist

# Ring effect state
var _ring_active: bool = false
var _ring_time: float = 0.0
var _ring_duration: float = 0.8
var _taunted_enemies: Array = []

func _ready():
	shadow_type = "skeleton"
	formation_offset = Vector2(60, 0)
	attack_range = 80.0
	attack_damage = 20.0
	attack_cooldown = 1.0
	max_health = 80.0
	follow_speed = 200.0
	super._ready()

func _physics_process(delta):
	if is_dead or not player:
		return
	_update_taunt_state(delta)
	_update_ring(delta)
	if is_weakened:
		_process_weakened_state(delta)
	follow_player()
	attack_timer -= delta
	if attack_timer <= 0:
		find_and_attack_nearest_enemy()

func _update_taunt_state(delta: float):
	if is_taunting:
		taunt_timer -= delta
		# Pulsing bright teal while taunting
		var pulse = (sin(taunt_timer * 6.0) + 1.0) / 2.0
		var bright = Color(0.5, 1.0, 1.0)
		animated_sprite.modulate = TEAL_TINT.lerp(bright, pulse)
		if taunt_timer <= 0:
			_end_taunt()
	else:
		_taunt_cooldown_remaining -= delta
		if _taunt_cooldown_remaining <= 0:
			_activate_taunt()

func _activate_taunt():
	is_taunting = true
	taunt_timer = taunt_duration
	_taunt_cooldown_remaining = taunt_cooldown
	_taunted_enemies.clear()
	# Start ring effect
	_ring_active = true
	_ring_time = 0.0
	print("[ShadowSkeleton] TAUNT activated!")
	# Pull aggro from all enemies in radius
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy is Enemy and not enemy.is_dead:
			var dist = global_position.distance_to(enemy.global_position)
			if dist <= taunt_radius:
				enemy.set_taunt(self, taunt_duration)
				_taunted_enemies.append(enemy)
				# Tint enemy orange to show taunt
				if enemy.animated_sprite:
					enemy.animated_sprite.modulate = Color(1.0, 0.7, 0.2)
	print("[ShadowSkeleton] Taunted %d enemies" % _taunted_enemies.size())

func _end_taunt():
	is_taunting = false
	if not is_weakened:
		animated_sprite.modulate = TEAL_TINT
	# Restore enemy colors
	for enemy in _taunted_enemies:
		if is_instance_valid(enemy) and not enemy.is_dead and enemy.animated_sprite:
			enemy.animated_sprite.modulate = Color(1, 1, 1)
	_taunted_enemies.clear()

func _update_ring(delta: float):
	if _ring_active:
		_ring_time += delta
		queue_redraw()
		if _ring_time >= _ring_duration:
			_ring_active = false
			queue_redraw()

func _draw():
	if not _ring_active:
		return
	var t = _ring_time / _ring_duration
	var radius = taunt_radius * t
	var alpha = (1.0 - t) * 0.8
	var color = Color(0.3, 1.0, 0.9, alpha)
	# Draw expanding ring — scale back to world coords since sprite is scaled
	var inv_scale = Vector2(1.0 / scale.x, 1.0 / scale.y) if scale.x != 0 else Vector2.ONE
	draw_arc(Vector2.ZERO, radius * inv_scale.x, 0, TAU, 64, color, 3.0)

func take_damage(amount: float):
	if is_dead:
		return
	# Reduce damage while taunting
	var actual = amount * (1.0 - damage_reduction) if is_taunting else amount
	current_health -= actual
	update_health_bar()
	flash_damage()
	if current_health <= 0:
		is_taunting = false
		_taunted_enemies.clear()
		die()
