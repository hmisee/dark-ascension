extends GhostEnemy
class_name BossWraith

signal boss_defeated

func _ready():
	super._ready()
	max_health = 600.0
	move_speed = 60.0
	contact_damage = 25.0
	soul_value = 200
	attack_cooldown = 1.2
	current_health = max_health
	scale = Vector2(2.0, 2.0)
	update_health_bar()

func die():
	is_dead = true
	var am = Autoloads.audio_manager()
	if am:
		am.play_sfx("boss_defeat")
	velocity = Vector2.ZERO
	_spawn_soul_drop()
	# Play death animation before signaling defeat
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	# Brief pause to let the moment land
	await get_tree().create_timer(0.6).timeout
	boss_defeated.emit()
	queue_free()
