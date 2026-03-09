extends Node
class_name BackpackSystem

# Grid-based inventory with adjacency bonuses

var grid_size: Vector2i = Vector2i(4, 4)
var items: Dictionary = {}  # position -> item

func place_item(item, position: Vector2i) -> bool:
	if is_valid_position(position):
		items[position] = item
		check_adjacency_bonuses(position)
		return true
	return false

func is_valid_position(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < grid_size.x and \
	       position.y >= 0 and position.y < grid_size.y

func check_adjacency_bonuses(position: Vector2i):
	# TODO: Implement synergy detection
	pass
