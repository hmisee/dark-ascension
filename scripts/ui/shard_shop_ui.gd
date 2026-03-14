extends Control
class_name ShardShopUI

## Shard shop UI for level transitions.
## Shows 5 shard offers in a horizontal row with purchase buttons and a reroll button.
## Connects to GameManager.shard_shop for data and SoulEnergyManager for balance checks.

const OFFER_SIZE := Vector2(140, 150)
const TEAL := Color(0.3, 1.0, 0.9)
const GOLD := Color(1.0, 0.85, 0.3)
const DIMMED := Color(0.5, 0.5, 0.5)
const SOLD_COLOR := Color(0.2, 0.2, 0.25)
const OFFER_BG := Color(0.12, 0.15, 0.2)
const OFFER_HOVER := Color(0.18, 0.22, 0.3)
const REROLL_BG := Color(0.2, 0.15, 0.1)
const REROLL_HOVER := Color(0.3, 0.25, 0.15)

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

var offer_buttons: Array = []  # Array of Button, one per offer slot
var reroll_button: Button
var title_label: Label
var balance_label: Label


func _ready() -> void:
	_build_ui()
	_connect_signals()
	_refresh()


func _connect_signals() -> void:
	var gm := Autoloads.game_manager()
	if gm.shard_shop:
		gm.shard_shop.shop_updated.connect(_on_shop_updated)
	Autoloads.soul_energy_manager().souls_changed.connect(_on_souls_changed)


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.name = "Root"
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	add_child(root)

	# Title
	title_label = Label.new()
	title_label.text = "⬡ Shard Shop ⬡"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", TEAL)
	root.add_child(title_label)

	# Soul balance display
	balance_label = Label.new()
	balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	balance_label.add_theme_font_size_override("font_size", 13)
	balance_label.add_theme_color_override("font_color", GOLD)
	root.add_child(balance_label)

	# Offers row
	var offers_row := HBoxContainer.new()
	offers_row.alignment = BoxContainer.ALIGNMENT_CENTER
	offers_row.add_theme_constant_override("separation", 8)
	offers_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(offers_row)

	offer_buttons.clear()
	for i in 5:
		var btn := Button.new()
		btn.custom_minimum_size = OFFER_SIZE
		btn.add_theme_font_size_override("font_size", 11)
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.pressed.connect(_on_offer_pressed.bind(i))
		offers_row.add_child(btn)
		offer_buttons.append(btn)

	# Reroll button
	var reroll_row := HBoxContainer.new()
	reroll_row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(reroll_row)

	reroll_button = Button.new()
	reroll_button.custom_minimum_size = Vector2(180, 36)
	reroll_button.add_theme_font_size_override("font_size", 13)
	reroll_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	reroll_button.pressed.connect(_on_reroll_pressed)
	reroll_row.add_child(reroll_button)


func _refresh() -> void:
	_refresh_offers()
	_refresh_reroll()
	_refresh_balance()


func _refresh_offers() -> void:
	var shop = Autoloads.game_manager().shard_shop
	if shop == null:
		return

	var souls: int = Autoloads.soul_energy_manager().get_souls()
	var offers := shop.current_offers

	for i in offer_buttons.size():
		var btn: Button = offer_buttons[i]
		var shard: Shard = offers[i] if i < offers.size() else null

		if shard == null:
			btn.text = "[SOLD]"
			btn.disabled = true
			_style_button(btn, SOLD_COLOR)
		else:
			var stat_name: String = STAT_NAMES.get(shard.stat_type, "???")
			var arrows := _direction_arrows(shard.receive_directions)
			var can_afford := souls >= shard.purchase_price
			btn.text = "%s\n%s: %.1f\n%s\n\n%d souls" % [
				shard.shard_name, stat_name, shard.base_value, arrows, shard.purchase_price
			]
			btn.disabled = false
			if can_afford:
				_style_button(btn, OFFER_BG)
				btn.add_theme_color_override("font_color", Color.WHITE)
			else:
				_style_button(btn, OFFER_BG)
				btn.add_theme_color_override("font_color", DIMMED)


func _refresh_reroll() -> void:
	var shop = Autoloads.game_manager().shard_shop
	if shop == null:
		return

	var cost: int = shop.reroll_cost
	var can_afford := Autoloads.soul_energy_manager().get_souls() >= cost
	reroll_button.text = "Reroll (%d souls)" % cost

	if can_afford:
		_style_button(reroll_button, REROLL_BG)
		reroll_button.add_theme_color_override("font_color", GOLD)
	else:
		_style_button(reroll_button, REROLL_BG)
		reroll_button.add_theme_color_override("font_color", DIMMED)


func _refresh_balance() -> void:
	balance_label.text = "Souls: %d" % Autoloads.soul_energy_manager().get_souls()


func _on_offer_pressed(index: int) -> void:
	var shop = Autoloads.game_manager().shard_shop
	if shop == null:
		return
	if shop.purchase(index):
		_refresh()


func _on_reroll_pressed() -> void:
	var shop = Autoloads.game_manager().shard_shop
	if shop == null:
		return
	if shop.reroll():
		_refresh()


func _on_shop_updated(_offers: Array) -> void:
	_refresh()


func _on_souls_changed(_new_total: int) -> void:
	_refresh()


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
	style.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = bg_color.lightened(0.25)
	btn.add_theme_stylebox_override("pressed", pressed_style)
