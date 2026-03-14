extends Control

## Options menu UI — reads/writes settings through the OptionsManager autoload.

signal closed

# --- Node references ---

@onready var display_mode_option: OptionButton = $PanelContainer/VBoxContainer/DisplaySection/DisplayModeOption
@onready var resolution_option: OptionButton = $PanelContainer/VBoxContainer/ResolutionSection/ResolutionOption

@onready var move_up_button: Button = $PanelContainer/VBoxContainer/KeyBindSection/MoveUpRow/RebindButton
@onready var move_down_button: Button = $PanelContainer/VBoxContainer/KeyBindSection/MoveDownRow/RebindButton
@onready var move_left_button: Button = $PanelContainer/VBoxContainer/KeyBindSection/MoveLeftRow/RebindButton
@onready var move_right_button: Button = $PanelContainer/VBoxContainer/KeyBindSection/MoveRightRow/RebindButton

@onready var apply_button: Button = $PanelContainer/VBoxContainer/ButtonRow/ApplyButton
@onready var cancel_button: Button = $PanelContainer/VBoxContainer/ButtonRow/CancelButton

@onready var _options_manager: Node = get_node("/root/OptionsManager")

# --- State ---

var _snapshot: Dictionary = {}
var _pending_action: String = ""

## Maps action names to their corresponding rebind buttons.
var _action_buttons: Dictionary = {}


func _ready() -> void:
	_action_buttons = {
		"move_up": move_up_button,
		"move_down": move_down_button,
		"move_left": move_left_button,
		"move_right": move_right_button
	}

	apply_button.pressed.connect(_on_apply_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	move_up_button.pressed.connect(_on_rebind_button_pressed.bind("move_up"))
	move_down_button.pressed.connect(_on_rebind_button_pressed.bind("move_down"))
	move_left_button.pressed.connect(_on_rebind_button_pressed.bind("move_left"))
	move_right_button.pressed.connect(_on_rebind_button_pressed.bind("move_right"))

	# Auto-open since this is now a standalone scene
	_snapshot = _options_manager.get_settings_snapshot()
	_pending_action = ""
	display_mode_option.selected = _options_manager.display_mode
	resolution_option.selected = _options_manager.resolution_index
	_refresh_rebind_buttons()


# --- Public ---

## Snapshots current settings, populates UI controls, and shows the menu.
func open() -> void:
	_snapshot = _options_manager.get_settings_snapshot()
	_pending_action = ""

	display_mode_option.selected = _options_manager.display_mode
	resolution_option.selected = _options_manager.resolution_index
	_refresh_rebind_buttons()

	visible = true


# --- Signal handlers ---

func _on_apply_pressed() -> void:
	_options_manager.apply_display_mode(display_mode_option.selected)
	_options_manager.apply_resolution(resolution_option.selected)
	_options_manager.save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_cancel_pressed() -> void:
	_options_manager.apply_snapshot(_snapshot)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_rebind_button_pressed(action: String) -> void:
	_pending_action = action
	_action_buttons[action].text = "Press a key..."


# --- Input ---

func _unhandled_input(event: InputEvent) -> void:
	if _pending_action == "":
		return

	if not (event is InputEventKey and event.is_pressed()):
		return

	var key_event := event as InputEventKey

	if key_event.keycode == KEY_ESCAPE:
		# Cancel rebind — restore current binding text
		_action_buttons[_pending_action].text = OS.get_keycode_string(_options_manager.key_bindings[_pending_action])
		_pending_action = ""
		get_viewport().set_input_as_handled()
		return

	_options_manager.rebind_key(_pending_action, key_event.keycode)
	_refresh_rebind_buttons()
	_pending_action = ""
	get_viewport().set_input_as_handled()


# --- Helpers ---

func _refresh_rebind_buttons() -> void:
	for action_name: String in _action_buttons:
		var btn: Button = _action_buttons[action_name]
		btn.text = OS.get_keycode_string(_options_manager.key_bindings[action_name])
