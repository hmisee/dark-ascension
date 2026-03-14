extends Control
class_name FailureScreen

## Failure screen shown when the player dies during a boss level.
## Displays "You Died" text with retry and main menu buttons.

signal retry_pressed
signal menu_pressed

const RED := Color(0.9, 0.2, 0.2)
const BTN_BG := Color(0.15, 0.18, 0.25)
const BTN_HOVER := Color(0.25, 0.28, 0.35)

var title_label: Label
var retry_button: Button
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
	var vbox := VBoxContainer.new()
	vbox.name = "Root"
	vbox.set_anchors_preset(PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	add_child(vbox)

	# "You Died" title
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "You Died"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", RED)
	vbox.add_child(title_label)

	# Retry button
	retry_button = Button.new()
	retry_button.name = "RetryButton"
	retry_button.text = "Retry"
	retry_button.custom_minimum_size = Vector2(160, 40)
	retry_button.add_theme_font_size_override("font_size", 14)
	_style_button(retry_button)
	retry_button.pressed.connect(_on_retry_pressed)
	vbox.add_child(retry_button)

	# Main Menu button
	menu_button = Button.new()
	menu_button.name = "MenuButton"
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(160, 40)
	menu_button.add_theme_font_size_override("font_size", 14)
	_style_button(menu_button)
	menu_button.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_button)


func _on_retry_pressed() -> void:
	retry_pressed.emit()


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
