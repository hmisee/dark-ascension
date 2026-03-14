extends Control
class_name ShardInventoryUI

## Shows all unequipped shards with stat details and sell buttons.
## Connects to GameManager.shard_inventory for live updates.

const TEAL := Color(0.3, 1.0, 0.9)
const GOLD := Color(1.0, 0.85, 0.3)

const DIR_ARROWS := {
	Shard.Direction.UP: "↑",
	Shard.Direction.DOWN: "↓",
	Shard.Direction.LEFT: "←",
	Shard.Direction.RIGHT: "→",
}

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

var list_container: VBoxContainer
var title_label: Label


func _ready() -> void:
	_build_ui()
	_refresh()
	if Autoloads.game_manager().shard_inventory:
		Autoloads.game_manager().shard_inventory.inventory_changed.connect(_refresh)


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	add_child(root)

	title_label = Label.new()
	title_label.text = "⬡ Shard Inventory ⬡"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", TEAL)
	root.add_child(title_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_container)


func _refresh() -> void:
	for child in list_container.get_children():
		child.queue_free()

	var shards := Autoloads.game_manager().shard_inventory.get_all()
	if shards.is_empty():
		var empty := Label.new()
		empty.text = "(no shards)"
		empty.add_theme_font_size_override("font_size", 12)
		list_container.add_child(empty)
		return

	for shard in shards:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list_container.add_child(row)

		var info := Label.new()
		var stat_name: String = STAT_NAMES.get(shard.stat_type, "???")
		var arrows := _direction_arrows(shard.receive_directions)
		info.text = "%s  %s:%.1f  %s" % [shard.shard_name, stat_name, shard.base_value, arrows]
		info.add_theme_font_size_override("font_size", 11)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)

		var sell_btn := Button.new()
		sell_btn.text = "Sell (%d)" % shard.sell_value
		sell_btn.add_theme_font_size_override("font_size", 11)
		sell_btn.add_theme_color_override("font_color", GOLD)
		sell_btn.pressed.connect(_on_sell_pressed.bind(shard))
		row.add_child(sell_btn)


func _on_sell_pressed(shard: Shard) -> void:
	Autoloads.game_manager().shard_inventory.sell_shard(shard)


func _direction_arrows(directions: Array[Shard.Direction]) -> String:
	var arrows: Array[String] = []
	for d in directions:
		if DIR_ARROWS.has(d):
			arrows.append(DIR_ARROWS[d])
	return " ".join(arrows)
