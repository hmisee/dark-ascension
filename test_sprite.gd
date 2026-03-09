extends Node2D

func _ready():
	var sprite = Sprite2D.new()
	var texture = load("res://assets/sprites/characters/necromancer_idle.png")
	
	if texture:
		print("✓ Texture loaded successfully!")
		sprite.texture = texture
		add_child(sprite)
	else:
		print("✗ Failed to load texture")
		print("Check if file exists at: res://assets/sprites/characters/necromancer_idle.png")
