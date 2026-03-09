extends Node

# Global game state manager
# Handles meta progression, unlocks, and persistent data

var player_data = {
	"shadow_slots": 3,
	"backpack_size": Vector2i(4, 4),
	"unlocked_floors": 1,
	"collected_shadows": [],
	"discovered_synergies": []
}

func _ready():
	load_game_data()

func save_game_data():
	# TODO: Implement save system
	pass

func load_game_data():
	# TODO: Implement load system
	pass
