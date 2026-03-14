extends Control
class_name PostLevelScreen

## Post-level results screen shown after completing a boss level.
## Displays soul energy earned, embeds ShardShopUI and RelicGridUI,
## and provides buttons to continue or return to the main menu.

signal continue_pressed
signal menu_pressed

const TEAL := Color(0.3, 1.0, 0.9)
const GOLD := Color(1.0, 0.85, 0.3)
const BTN_BG := Color(0.15, 0.18, 0.25)
const BTN_HOVER := Color(0.25, 0.28, 0.35)

var soul_label: Label
var shard_shop_ui: ShardShopUI
var relic_grid_ui: RelicGridUI
var continue_button: Button
var menu_button: Button


func _ready() -> void:
	_build_ui()
	_refresh_soul_display()
	_generate_shop_offers()


func _build_ui() -> void:
	set_anchors_preset(PRESET_FULL_RECT)

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)

	# Main layout
	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	add_child(margin)

	var root := VBoxContainer.new()
	root.name = "Root"
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	# Title
	var title := Label.new()
	title.text = "Level Complete!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", TEAL)
	root.add_child(title)

	# Soul energy display
	soul_label = Label.new()
	soul_label.name = "SoulLabel"
	soul_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	soul_label.add_theme_font_size_override("font_size", 16)
	soul_label.add_theme_color_override("font_color", GOLD)
	root.add_child(soul_label)

	# Shard shop and relic grid side by side
	var content_row := HBoxContainer.new()
	content_row.name = "ContentRow"
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 16)
	root.add_child(content_row)

	# Shard shop
	shard_shop_ui = ShardShopUI.new()
	shard_shop_ui.name = "ShardShopUI"
	shard_shop_ui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.add_child(shard_shop_ui)

	# Relic grid
	relic_grid_ui = RelicGridUI.new()
	relic_grid_ui.name = "RelicGridUI"
	relic_grid_ui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.add_child(relic_grid_ui)

	# Button row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	root.add_child(btn_row)

	# Next Level button
	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "Next Level"
	continue_button.custom_minimum_size = Vector2(160, 40)
	continue_button.add_theme_font_size_override("font_size", 14)
	_style_button(continue_button)
	continue_button.pressed.connect(_on_continue_pressed)
	btn_row.add_child(continue_button)

	# Main Menu button
	menu_button = Button.new()
	menu_button.name = "MenuButton"
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(160, 40)
	menu_button.add_theme_font_size_override("font_size", 14)
	_style_button(menu_button)
	menu_button.pressed.connect(_on_menu_pressed)
	btn_row.add_child(menu_button)


func _refresh_soul_display() -> void:
	var sem = Autoloads.soul_energy_manager()
	var souls: int = sem.get_souls() if sem else 0
	soul_label.text = "Soul Energy: %d" % souls


func _generate_shop_offers() -> void:
	var gm = Autoloads.game_manager()
	if gm and gm.shard_shop:
		gm.shard_shop.generate_offers()


func _on_continue_pressed() -> void:
	continue_pressed.emit()


func _on_menu_pressed() -> void:
	menu_pressed.emit()


func _style_button(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = BTN_BG
	style.border_color = Color(0.4, 0.4, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = BTN_HOVER
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = BTN_HOVER.lightened(0.1)
	btn.add_theme_stylebox_override("pressed", pressed_style)
