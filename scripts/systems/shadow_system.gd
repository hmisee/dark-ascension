extends Node
class_name ShadowSystem

# Manages shadow collection, roles, and formation

enum ShadowRole {
	TANK,
	FIGHTER,
	RANGED,
	SUPPORT
}

class Shadow:
	var id: String
	var name: String
	var level: int = 1
	var role: ShadowRole
	var stats: Dictionary
	var abilities: Array
	
	func _init(shadow_id: String, shadow_name: String):
		id = shadow_id
		name = shadow_name
		stats = {
			"hp": 100,
			"attack": 10,
			"defense": 5,
			"speed": 5
		}
