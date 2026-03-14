extends Control
class_name RelicGridUI

## Functional 3x3 relic grid UI for placing/removing shards during level transitions.
## Reads from GameManager.relic_grid and GameManager.shard_inventory.
## Click a shard in inventory to select it, then click an empty slot to place it.
## Click an occupied slot to remove the shard back to inventory.

const SLOT_SIZE := Vector2(70, 60)
const GRID_SPACING := 4
const TEAL := Color(0.3, 1.0, 0.9)
const SLOT_EMPTY_COLOR := Color(0.15, 0.15, 0.2)
const SLOT_HOVER_COLOR := Color(0.25, 0.25, 0.35)
const SLOT_OCCUPIED_COLOR := Color(0.12, 0.2, 0.18)
const SELECTED_COLOR := Color(0.4, 1.0, 0.5)

var selected_shard: Shard = null
var slot_buttons: Array = []  # flat array of 9 Buttons (row-major)
var inventory_container: VBoxContainer
var inventory_buttons: Array = []
var bonuses_label: Label
var title_label: Label

# Direction arrow characters
const DIR_ARROWS := {
	Shard.Direction.UP: "↑",
	Shard.Direction.DOWN: "↓",
	Shard.Direction.LEFT: "←",
	Shard.Direction.RIGHT: "→",
}

# Stat type display names
const STAT_NAMES := {
	Shard.StatType.COOLDOWN_REDUCTION: "CD Reduce",
	Shard.StatType.DAMAGE_AMP: "Damage",
	Shard.StatType.ATTACK_SPEED: "Atk Spd",
	Shard.StatType.HEALING_RATE: "Healing",
	Shard.StatType.MAX_HEALTH: "Max HP",
	Shard.StatType.MOVEMENT_SPEED: "Move Spd",
	Shard.StatType.SOUL_BONUS: "Soul Bonus",
	Shard.StatType.CRIT_CHANCE: "Crit",
}


func _ready() -> void:
	_build_ui()
	_refresh()
	# Connect to inventory changes for live updates
	if Autoloads.game_manager().shard_inventory:
		Autoloads.game_manager().shard_inventory.inventory_changed.connect(_refresh)


func _build_ui() -> void:
	# Main vertical layout
	var root := VBoxContainer.new()
	root.name = "Root"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root)

	# Title
	title_label = Label.new()
	title_label.text = "⬡ Relic Grid ⬡"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", TEAL)
	root.add_child(title_label)

	# Horizontal split: grid on left, inventory on right
	var hsplit := HBoxContainer.new()
	hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hsplit.add_theme_constant_override("separation", 16)
	root.add_child(hsplit)

	# --- Grid section ---
	var grid_section := VBoxContainer.new()
	hsplit.add_child(grid_section)

	var grid_label := Label.new()
	grid_label.text = "Grid (click to place/remove)"
	grid_label.add_theme_font_size_override("font_size", 12)
	grid_section.add_child(grid_label)

	var grid_container := GridContainer.new()
	grid_container.columns = RelicGrid.GRID_SIZE
	grid_container.add_theme_constant_override("h_separation", GRID_SPACING)
	grid_container.add_theme_constant_override("v_separation", GRID_SPACING)
	grid_section.add_child(grid_container)

	# Create 9 slot buttons
	slot_buttons.clear()
	for row in RelicGrid.GRID_SIZE:
		for col in RelicGrid.GRID_SIZE:
			var btn := Button.new()
			btn.custom_minimum_size = SLOT_SIZE
			btn.add_theme_font_size_override("font_size", 11)
			btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.pressed.connect(_on_slot_pressed.bind(row, col))
			grid_container.add_child(btn)
			slot_buttons.append(btn)

	# Bonuses summary
	bonuses_label = Label.new()
	bonuses_label.text = ""
	bonuses_label.add_theme_font_size_override("font_size", 12)
	bonuses_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.6))
	grid_section.add_child(bonuses_label)

	# --- Inventory section ---
	var inv_section := VBoxContainer.new()
	inv_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hsplit.add_child(inv_section)

	var inv_label := Label.new()
	inv_label.text = "Inventory (click to select)"
	inv_label.add_theme_font_size_override("font_size", 12)
	inv_section.add_child(inv_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(160, 0)
	inv_section.add_child(scroll)

	inventory_container = VBoxContainer.new()
	inventory_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inventory_container)


func _refresh() -> void:
	_refresh_grid()
	_refresh_inventory()
	_refresh_bonuses()


func _refresh_grid() -> void:
	var relic: RelicGrid = Autoloads.game_manager().relic_grid
	var _bonuses_map := relic.calculate_all_bonuses()

	for row in RelicGrid.GRID_SIZE:
		for col in RelicGrid.GRID_SIZE:
			var idx := row * RelicGrid.GRID_SIZE + col
			var btn: Button = slot_buttons[idx]
			var shard: Shard = relic.get_shard(row, col)

			if shard != null:
				var adj_count := relic._count_active_adjacencies(row, col, shard)
				var effective := shard.get_effective_value(adj_count)
				var arrows := _direction_arrows(shard.receive_directions)
				var stat_name: String = STAT_NAMES.get(shard.stat_type, "???")
				var bonus_text := ""
				if adj_count > 0:
					bonus_text = "\n+%d adj (%.1f)" % [adj_count, effective]
				btn.text = "%s\n%s: %.1f%s\n%s" % [shard.shard_name, stat_name, shard.base_value, bonus_text, arrows]
				_style_button(btn, SLOT_OCCUPIED_COLOR)
			else:
				btn.text = "[empty]"
				_style_button(btn, SLOT_EMPTY_COLOR)


func _refresh_inventory() -> void:
	# Clear old buttons
	for child in inventory_container.get_children():
		child.queue_free()
	inventory_buttons.clear()

	var shards = Autoloads.game_manager().shard_inventory.get_all()
	if shards.is_empty():
		var empty_label := Label.new()
		empty_label.text = "(no shards)"
		empty_label.add_theme_font_size_override("font_size", 11)
		inventory_container.add_child(empty_label)
		return

	for shard in shards:
		var btn := Button.new()
		var stat_name: String = STAT_NAMES.get(shard.stat_type, "???")
		var arrows := _direction_arrows(shard.receive_directions)
		btn.text = "%s  %s:%.1f  %s" % [shard.shard_name, stat_name, shard.base_value, arrows]
		btn.add_theme_font_size_override("font_size", 11)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_inventory_shard_pressed.bind(shard))
		inventory_container.add_child(btn)
		inventory_buttons.append(btn)

		# Highlight if this shard is selected
		if shard == selected_shard:
			btn.add_theme_color_override("font_color", SELECTED_COLOR)


func _refresh_bonuses() -> void:
	var bonuses = Autoloads.game_manager().relic_grid.calculate_all_bonuses()
	if bonuses.is_empty():
		bonuses_label.text = "No bonuses active"
		return
	var parts: Array[String] = []
	for stat_type in bonuses:
		var stat_name: String = STAT_NAMES.get(stat_type, "???")
		parts.append("%s: %.1f" % [stat_name, bonuses[stat_type]])
	bonuses_label.text = "Bonuses: " + ", ".join(parts)


func _on_slot_pressed(row: int, col: int) -> void:
	var relic: RelicGrid = Autoloads.game_manager().relic_grid
	var existing: Shard = relic.get_shard(row, col)

	if existing != null and selected_shard == null:
		# Remove shard from grid back to inventory
		var removed := relic.remove_shard(row, col)
		if removed:
			Autoloads.game_manager().shard_inventory.add_shard(removed)
			_on_grid_changed()
	elif existing != null and selected_shard != null:
		# Swap: replace occupied slot with selected shard
		var old := relic.swap_shard(row, col, selected_shard)
		if old:
			Autoloads.game_manager().shard_inventory.remove_shard(selected_shard)
			Autoloads.game_manager().shard_inventory.add_shard(old)
			selected_shard = null
			_on_grid_changed()
	elif existing == null and selected_shard != null:
		# Place selected shard into empty slot
		if relic.place_shard(selected_shard, row, col):
			Autoloads.game_manager().shard_inventory.remove_shard(selected_shard)
			selected_shard = null
			_on_grid_changed()


func _on_grid_changed() -> void:
	var gm := Autoloads.game_manager()
	if gm.stat_bonus_applier:
		gm.stat_bonus_applier.apply_bonuses()
	_refresh()


func _on_inventory_shard_pressed(shard: Shard) -> void:
	if selected_shard == shard:
		# Deselect
		selected_shard = null
	else:
		selected_shard = shard
	_refresh_inventory()


func _direction_arrows(directions: Array[Shard.Direction]) -> String:
	var arrows: Array[String] = []
	for d in directions:
		if DIR_ARROWS.has(d):
			arrows.append(DIR_ARROWS[d])
	return " ".join(arrows)


func _style_button(btn: Button, bg_color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = Color(0.4, 0.4, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = bg_color.lightened(0.25)
	btn.add_theme_stylebox_override("pressed", pressed_style)
