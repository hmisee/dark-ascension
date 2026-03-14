extends Resource
class_name RelicGrid

const GRID_SIZE := 3

var grid: Array = []
var is_unlocked: bool = false


func _init() -> void:
	_init_grid()


func _init_grid() -> void:
	grid = []
	for row in GRID_SIZE:
		var row_array: Array = []
		for col in GRID_SIZE:
			row_array.append(null)
		grid.append(row_array)


func _is_valid_position(row: int, col: int) -> bool:
	return row >= 0 and row < GRID_SIZE and col >= 0 and col < GRID_SIZE


func place_shard(shard: Shard, row: int, col: int) -> bool:
	if not is_unlocked:
		return false
	if not _is_valid_position(row, col):
		return false
	if grid[row][col] != null:
		return false
	grid[row][col] = shard
	return true


func remove_shard(row: int, col: int) -> Shard:
	if not is_unlocked:
		return null
	if not _is_valid_position(row, col):
		return null
	var shard = grid[row][col]
	grid[row][col] = null
	return shard


func swap_shard(row: int, col: int, new_shard: Shard) -> Shard:
	if not is_unlocked:
		return null
	if not _is_valid_position(row, col):
		return null
	var old_shard = grid[row][col]
	grid[row][col] = new_shard
	return old_shard


func get_shard(row: int, col: int) -> Shard:
	if not _is_valid_position(row, col):
		return null
	return grid[row][col]


func _count_active_adjacencies(row: int, col: int, shard: Shard) -> int:
	var count := 0
	for dir in shard.receive_directions:
		var neighbor_row := row
		var neighbor_col := col
		match dir:
			Shard.Direction.UP:
				neighbor_row = row - 1
			Shard.Direction.DOWN:
				neighbor_row = row + 1
			Shard.Direction.LEFT:
				neighbor_col = col - 1
			Shard.Direction.RIGHT:
				neighbor_col = col + 1
		if _is_valid_position(neighbor_row, neighbor_col) and grid[neighbor_row][neighbor_col] != null:
			count += 1
	return count


func calculate_all_bonuses() -> Dictionary:
	var bonuses := {}
	for row in GRID_SIZE:
		for col in GRID_SIZE:
			var shard: Shard = grid[row][col]
			if shard == null:
				continue
			var active_count := _count_active_adjacencies(row, col, shard)
			var effective_value := shard.get_effective_value(active_count)
			var stat := shard.stat_type
			if bonuses.has(stat):
				bonuses[stat] += effective_value
			else:
				bonuses[stat] = effective_value
	return bonuses


func recalculate() -> void:
	calculate_all_bonuses()


func serialize() -> Dictionary:
	var grid_data: Array = []
	for row in GRID_SIZE:
		var row_data: Array = []
		for col in GRID_SIZE:
			var shard: Shard = grid[row][col]
			if shard != null:
				row_data.append(shard.serialize())
			else:
				row_data.append(null)
		grid_data.append(row_data)
	return {
		"is_unlocked": is_unlocked,
		"grid": grid_data,
	}


static func deserialize(data: Dictionary) -> RelicGrid:
	var relic_grid := RelicGrid.new()
	if data == null or data.is_empty():
		return relic_grid
	relic_grid.is_unlocked = data.get("is_unlocked", false)
	var grid_data = data.get("grid", [])
	for row in GRID_SIZE:
		for col in GRID_SIZE:
			if row < grid_data.size() and col < grid_data[row].size():
				var cell = grid_data[row][col]
				if cell != null and cell is Dictionary:
					relic_grid.grid[row][col] = Shard.deserialize(cell)
				else:
					relic_grid.grid[row][col] = null
			else:
				relic_grid.grid[row][col] = null
	return relic_grid


func reset() -> void:
	_init_grid()
	is_unlocked = false
