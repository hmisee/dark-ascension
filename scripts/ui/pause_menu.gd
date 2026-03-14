extends Control
class_name PauseMenu

## In-game pause menu toggled with Escape.
## Pauses the tree and shows Continue / Main Menu options.

const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	# Don't open pause if the game is already paused by something else (victory/failure)
	if get_tree().paused:
		return
	visible = true
	get_tree().paused = true


func _resume() -> void:
	visible = false
	get_tree().paused = false


func _on_continue_pressed() -> void:
	_resume()


func _on_main_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	LevelManager._saved_run_state = {}
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _build_ui() -> void:
	set_anchors_preset(PRESET_FULL_RECT)

	# Dim overlay
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)

	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	vbox.add_child(title)

	var continue_btn := Button.new()
	continue_btn.text = "Continue"
	continue_btn.custom_minimum_size = Vector2(180, 44)
	continue_btn.pressed.connect(_on_continue_pressed)
	vbox.add_child(continue_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(180, 44)
	menu_btn.pressed.connect(_on_main_menu_pressed)
	vbox.add_child(menu_btn)
