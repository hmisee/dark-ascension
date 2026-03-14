extends Control
class_name ShopScene

## Standalone shop scene shown after boss defeat.
## Contains the shard shop, relic grid, and navigation buttons.

const BOSS_LEVEL_PATH := "res://scenes/dungeon/boss_level.tscn"
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"

var shard_shop_ui: ShardShopUI
var relic_grid_ui: RelicGridUI


func _ready() -> void:
	var am = Autoloads.audio_manager()
	if am:
		am.play_bgm("menu")
	_build_ui()
	_generate_shop_offers()


func _build_ui() -> void:
	set_anchors_preset(PRESET_FULL_RECT)

	# Animated dark background using the menu shader
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := load("res://assets/shaders/menu_bg.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("base_color", Color(0.06, 0.05, 0.09, 1.0))
		mat.set_shader_parameter("fog_color", Color(0.18, 0.12, 0.28, 1.0))
		mat.set_shader_parameter("magic_color", Color(0.40, 0.15, 0.55, 1.0))
		mat.set_shader_parameter("time_scale", 0.04)
		bg.material = mat
	else:
		bg.color = Color(0.08, 0.06, 0.12, 1.0)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	add_child(margin)

	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	# Title
	var title := Label.new()
	title.text = "Shadow Shop"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	root.add_child(title)

	# Soul energy display
	var soul_label := Label.new()
	var sem = Autoloads.soul_energy_manager()
	var souls: int = sem.get_souls() if sem else 0
	soul_label.text = "Soul Energy: %d" % souls
	soul_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	soul_label.add_theme_font_size_override("font_size", 16)
	soul_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	root.add_child(soul_label)

	# Content: relic grid on top, shop below
	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	root.add_child(content)

	relic_grid_ui = RelicGridUI.new()
	relic_grid_ui.name = "RelicGridUI"
	relic_grid_ui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	relic_grid_ui.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(relic_grid_ui)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	content.add_child(sep)

	shard_shop_ui = ShardShopUI.new()
	shard_shop_ui.name = "ShardShopUI"
	shard_shop_ui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shard_shop_ui.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(shard_shop_ui)

	# Button row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	root.add_child(btn_row)

	var next_btn := Button.new()
	next_btn.text = "Next Level"
	next_btn.custom_minimum_size = Vector2(160, 40)
	next_btn.pressed.connect(_on_next_level)
	btn_row.add_child(next_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(160, 40)
	menu_btn.pressed.connect(_on_main_menu)
	btn_row.add_child(menu_btn)


func _generate_shop_offers() -> void:
	var gm = Autoloads.game_manager()
	if gm and gm.shard_shop:
		gm.shard_shop.generate_offers()


func _on_next_level() -> void:
	var gm = Autoloads.game_manager()
	if gm:
		LevelManager._saved_run_state = gm.save_run_state()
	get_tree().change_scene_to_file(BOSS_LEVEL_PATH)


func _on_main_menu() -> void:
	LevelManager._saved_run_state = {}
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
