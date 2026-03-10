@tool
extends EditorScript

# Run this script once in Godot Editor (File > Run) to add attack animation to player

func _run():
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	var animated_sprite = player.get_node("AnimatedSprite2D")
	var sprite_frames = animated_sprite.sprite_frames
	
	# Add attack animation
	if not sprite_frames.has_animation("attack"):
		sprite_frames.add_animation("attack")
		sprite_frames.set_animation_loop("attack", false)
		sprite_frames.set_animation_speed("attack", 12.0)
		
		# Load attack frames
		var attack_frames = []
		for i in range(12):
			var frame_path = "res://assets/sprites/characters/necromancer_chibi/attack/0_Necromancer_of_the_Shadow_Slashing_%03d.png" % i
			var texture = load(frame_path)
			if texture:
				sprite_frames.add_frame("attack", texture)
		
		# Save the scene
		var packed_scene = PackedScene.new()
		packed_scene.pack(player)
		ResourceSaver.save(packed_scene, "res://scenes/player.tscn")
		
		print("Attack animation added successfully!")
	else:
		print("Attack animation already exists")
	
	player.queue_free()
