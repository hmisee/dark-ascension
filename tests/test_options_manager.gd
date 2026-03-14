# Feature: game-options-system — Unit tests for OptionsManager
extends GdUnitTestSuite

var _om: Node


func before_test():
	_om = auto_free(load("res://scripts/autoloads/options_manager.gd").new())
	add_child(_om)


# Validates: Requirements 1.1, 3.4, 5.4
func test_default_settings_state():
	_om.reset_to_defaults()
	# Display mode should be fullscreen (0)
	assert_int(_om.display_mode).is_equal(0)
	# Resolution should be 1920x1080 (index 0)
	assert_int(_om.resolution_index).is_equal(0)
	assert_int(_om.RESOLUTIONS[0].x).is_equal(1920)
	assert_int(_om.RESOLUTIONS[0].y).is_equal(1080)
	# Key bindings should be WASD
	assert_int(_om.key_bindings["move_up"]).is_equal(KEY_W)
	assert_int(_om.key_bindings["move_down"]).is_equal(KEY_S)
	assert_int(_om.key_bindings["move_left"]).is_equal(KEY_A)
	assert_int(_om.key_bindings["move_right"]).is_equal(KEY_D)


# Validates: Requirements 2.1, 3.1
func test_display_modes_and_resolutions_counts():
	assert_int(_om.DISPLAY_MODES.size()).is_equal(3)
	assert_int(_om.RESOLUTIONS.size()).is_equal(4)


# Validates: Requirement 5.2
func test_settings_path():
	assert_bool(_om.SETTINGS_PATH == "user://settings.cfg").is_true()


# Validates: Requirement 5.4
func test_missing_file_fallback():
	# Ensure no settings file exists by trying to delete it
	DirAccess.remove_absolute(_om.SETTINGS_PATH)
	var result: bool = _om.load_settings()
	assert_bool(result).is_false()


# Validates: Requirement 5.4
func test_corrupted_file_fallback():
	# Write garbage to the settings file
	var f := FileAccess.open(_om.SETTINGS_PATH, FileAccess.WRITE)
	f.store_string("NOT_A_VALID_CONFIG_FILE{{{{garbage")
	f.close()
	# load_settings should return false on corrupted file
	var result: bool = _om.load_settings()
	assert_bool(result).is_false()
	# Clean up
	DirAccess.remove_absolute(_om.SETTINGS_PATH)


# Validates: Requirements 3.4, 5.4
func test_rebind_same_key_is_noop():
	_om.reset_to_defaults()
	var original_bindings: Dictionary = _om.key_bindings.duplicate()
	# Rebind move_up to its current key (KEY_W) — should be a no-op
	_om.rebind_key("move_up", KEY_W)
	assert_int(_om.key_bindings["move_up"]).is_equal(original_bindings["move_up"])
	assert_int(_om.key_bindings["move_down"]).is_equal(original_bindings["move_down"])
	assert_int(_om.key_bindings["move_left"]).is_equal(original_bindings["move_left"])
	assert_int(_om.key_bindings["move_right"]).is_equal(original_bindings["move_right"])
