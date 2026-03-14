extends Node

## Manages all game options: display mode, resolution, and key bindings.
## Registered as an autoload so settings are available before any scene loads.

# --- Constants ---

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720),
	Vector2i(1024, 576)
]

const DISPLAY_MODES: PackedStringArray = ["Fullscreen", "Borderless Window", "Windowed"]

const ACTIONS: PackedStringArray = ["move_up", "move_down", "move_left", "move_right"]

const DEFAULT_BINDINGS: Dictionary = {
	"move_up": KEY_W,
	"move_down": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D
}

const SETTINGS_PATH: String = "user://settings.cfg"

# --- State ---

var display_mode: int = 0
var resolution_index: int = 0
var key_bindings: Dictionary = {}
var master_volume: int = 100
var music_volume: int = 100
var sfx_volume: int = 100


# --- Lifecycle ---

func _ready() -> void:
	if not load_settings():
		reset_to_defaults()
	apply_display_mode(display_mode)
	apply_resolution(resolution_index)
	apply_key_bindings()
	apply_volume("Master", master_volume)
	apply_volume("Music", music_volume)
	apply_volume("SFX", sfx_volume)


## Resets all settings state to default values.
func reset_to_defaults() -> void:
	display_mode = 0
	resolution_index = 0
	key_bindings = DEFAULT_BINDINGS.duplicate()
	master_volume = 100
	music_volume = 100
	sfx_volume = 100


# --- Display Settings ---

## Applies the given display mode to the game window.
## 0 = Exclusive Fullscreen, 1 = Borderless Fullscreen, 2 = Windowed.
func apply_display_mode(mode: int) -> void:
	display_mode = mode
	match mode:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			var res := RESOLUTIONS[resolution_index]
			DisplayServer.window_set_size(res)


## Applies the given resolution to the viewport and, if windowed, resizes the window.
func apply_resolution(index: int) -> void:
	resolution_index = index
	var res := RESOLUTIONS[resolution_index]
	get_tree().root.content_scale_size = res
	if display_mode == 2:
		DisplayServer.window_set_size(res)


# --- Key Bindings ---

## Rebuilds InputMap events for all four WASD actions from key_bindings dict,
## preserving any non-WASD events (e.g. arrow keys) already on each action.
func apply_key_bindings() -> void:
	var wasd_keycodes := {}
	for action_name: String in ACTIONS:
		wasd_keycodes[key_bindings[action_name]] = true

	for action_name: String in ACTIONS:
		# Collect events to preserve: non-keyboard events and keyboard events
		# whose keycode is NOT one of the current WASD keycodes.
		var preserved_events: Array[InputEvent] = []
		for event: InputEvent in InputMap.action_get_events(action_name):
			if event is InputEventKey:
				if not wasd_keycodes.has((event as InputEventKey).keycode):
					preserved_events.append(event)
			else:
				preserved_events.append(event)

		# Erase all events and rebuild
		InputMap.action_erase_events(action_name)
		for event: InputEvent in preserved_events:
			InputMap.action_add_event(action_name, event)

		# Add the WASD key event from key_bindings
		var key_event := InputEventKey.new()
		key_event.keycode = key_bindings[action_name]
		InputMap.action_add_event(action_name, key_event)


## Assigns new_keycode to action. If new_keycode is already bound to another
## WASD action, swaps the two bindings. Updates InputMap for affected actions.
func rebind_key(action: String, new_keycode: int) -> void:
	# No-op if already bound to this key
	if key_bindings[action] == new_keycode:
		return

	# Check for conflict with another WASD action
	var conflicting_action := ""
	for other_action: String in ACTIONS:
		if other_action != action and key_bindings[other_action] == new_keycode:
			conflicting_action = other_action
			break

	# Swap on conflict
	if conflicting_action != "":
		key_bindings[conflicting_action] = key_bindings[action]

	key_bindings[action] = new_keycode
	apply_key_bindings()


# --- Volume ---

## Converts a linear 0-100 volume value to decibels.
func _volume_to_db(value: int) -> float:
	return linear_to_db(value / 100.0)


## Applies a volume value (0-100) to the named AudioServer bus.
## Clamps value to [0, 100]. Mutes the bus when value is 0.
func apply_volume(bus_name: String, value: int) -> void:
	value = clampi(value, 0, 100)
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("OptionsManager: Audio bus '%s' not found." % bus_name)
		return
	if value == 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, _volume_to_db(value))


# --- Persistence & Snapshots ---

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "mode", display_mode)
	config.set_value("display", "resolution_index", resolution_index)
	for action_name: String in ACTIONS:
		config.set_value("input", action_name, key_bindings[action_name])
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	var err := config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("OptionsManager: Failed to save settings to %s (error %d)" % [SETTINGS_PATH, err])


func load_settings() -> bool:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		return false

	# Display settings — clamp to valid ranges, default to 0 if out of range
	var loaded_mode: int = config.get_value("display", "mode", 0)
	if loaded_mode < 0 or loaded_mode > 2:
		loaded_mode = 0
	display_mode = loaded_mode

	var loaded_res: int = config.get_value("display", "resolution_index", 0)
	if loaded_res < 0 or loaded_res > 3:
		loaded_res = 0
	resolution_index = loaded_res

	# Key bindings — fall back to default if keycode is invalid (0 or negative)
	key_bindings = DEFAULT_BINDINGS.duplicate()
	for action_name: String in ACTIONS:
		var keycode: int = config.get_value("input", action_name, DEFAULT_BINDINGS[action_name])
		if keycode <= 0:
			keycode = DEFAULT_BINDINGS[action_name]
		key_bindings[action_name] = keycode

	# Audio settings — default to 100, clamp to [0, 100]
	master_volume = clampi(config.get_value("audio", "master_volume", 100), 0, 100)
	music_volume = clampi(config.get_value("audio", "music_volume", 100), 0, 100)
	sfx_volume = clampi(config.get_value("audio", "sfx_volume", 100), 0, 100)

	return true


func get_settings_snapshot() -> Dictionary:
	return {
		"display_mode": display_mode,
		"resolution_index": resolution_index,
		"key_bindings": key_bindings.duplicate(),
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}


func apply_snapshot(snapshot: Dictionary) -> void:
	display_mode = snapshot["display_mode"]
	resolution_index = snapshot["resolution_index"]
	key_bindings = snapshot["key_bindings"].duplicate()
	apply_display_mode(display_mode)
	apply_resolution(resolution_index)
	apply_key_bindings()
	master_volume = snapshot["master_volume"]
	music_volume = snapshot["music_volume"]
	sfx_volume = snapshot["sfx_volume"]
	apply_volume("Master", master_volume)
	apply_volume("Music", music_volume)
	apply_volume("SFX", sfx_volume)
