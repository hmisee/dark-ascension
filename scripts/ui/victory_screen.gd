extends Control
class_name VictoryScreen

## Victory screen shown when the player completes all levels.
## Displays congratulatory message with total soul energy and action buttons.

signal new_run_pressed
signal menu_pressed

const GOLD := Color(1.0, 0.85, 0.3)
const TITLE_COLOR := Color(0.3, 1.0, 0.9)
const BTN_BG := Color(0.15, 0.18, 0.25)
const BTN_HOVER := Color(0.25, 0.28, 0.35)

var title_label: Label
var soul_label: Label
var new_run_button: Button
var menu_button: Button


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	set_anchors_preset(PRESET_FULL_RECT)

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)

	# Centered layout
	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.name = "Root"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	# Congratulatory title
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Victory!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", TITLE_COLOR)
	vbox.add_child(title_label)

	# Total soul energy label
	soul_label = Label.new()
	soul_label.name = "SoulLabel"
	var sem = Autoloads.soul_energy_manager()
	var souls: int = sem.get_souls() if sem else 0
	soul_label.text = "Total Soul Energy: %d" % souls
	soul_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	soul_label.add_theme_font_size_override("font_size", 16)
	soul_label.add_theme_color_override("font_color", GOLD)
	vbox.add_child(soul_label)

	# New Run button
	new_run_button = Button.new()
	new_run_button.name = "NewRunButton"
	new_run_button.text = "New Run"
	new_run_button.custom_minimum_size = Vector2(160, 40)
	new_run_button.add_theme_font_size_override("font_size", 14)
	_style_button(new_run_button)
	new_run_button.pressed.connect(_on_new_run_pressed)
	vbox.add_child(new_run_button)

	# Main Menu button
	menu_button = Button.new()
	menu_button.name = "MenuButton"
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(160, 40)
	menu_button.add_theme_font_size_override("font_size", 14)
	_style_button(menu_button)
	menu_button.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_button)


func _on_new_run_pressed() -> void:
	new_run_pressed.emit()


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
