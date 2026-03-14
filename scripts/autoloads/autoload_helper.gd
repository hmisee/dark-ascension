class_name Autoloads

## Helper to access autoload singletons from class_name scripts.
## In Godot 4, scripts with class_name are parsed before autoloads are registered,
## so they cannot reference autoload names directly at compile time.

static func soul_energy_manager() -> Node:
	return Engine.get_main_loop().root.get_node("SoulEnergyManager")

static func game_manager() -> Node:
	return Engine.get_main_loop().root.get_node("GameManager")

static func audio_manager() -> Node:
	return Engine.get_main_loop().root.get_node("AudioManager")
