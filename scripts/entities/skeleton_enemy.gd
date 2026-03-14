extends Enemy
class_name SkeletonEnemy

# Melee enemy that chases player aggressively and attacks in range

@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
@export var attack_damage_amount: float = 10.0

var attack_timer: float = 0.0

func _ready():
	super._ready()
	max_health = 30.0
	move_speed = 100.0
	contact_damage = 8.0
	soul_value = 10
	current_health = max_health
	update_health_bar()

func _physics_process(delta):
	if is_dead or not player:
		if not player:
			find_player()
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	attack_timer -= delta
	
	if distance_to_player <= attack_range:
		# In range — stop and attack
		velocity = Vector2.ZERO
		if attack_timer <= 0:
			perform_attack()
			attack_timer = attack_cooldown
		move_and_slide()
	else:
		# Chase player
		move_toward_player()

func perform_attack():
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
	
	# Deal damage to player and nearby shadows
	if player and player.has_method("take_damage"):
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range + 10:
			player.take_damage(attack_damage_amount)
	
	# Also damage nearby shadows
	var shadows = get_tree().get_nodes_in_group("shadow")
	for shadow in shadows:
		if shadow.has_method("take_damage"):
			var dist = global_position.distance_to(shadow.global_position)
			if dist <= attack_range + 10:
				shadow.take_damage(attack_damage_amount)
