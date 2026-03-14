extends Label
class_name SurvivalTimerHUD

## Displays the survival timer countdown during boss levels.
## Reads time_remaining from LevelManager and uses its static helpers
## for formatting and color.

var level_manager: LevelManager = null


func _ready() -> void:
	# Style the label
	add_theme_font_size_override("font_size", 32)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	add_theme_constant_override("shadow_offset_x", 2)
	add_theme_constant_override("shadow_offset_y", 2)

	# Position at top center of screen (below soul energy HUD)
	anchors_preset = PRESET_CENTER_TOP
	anchor_left = 0.5
	anchor_top = 0.0
	anchor_right = 0.5
	anchor_bottom = 0.0
	offset_left = -100.0
	offset_top = 40.0
	offset_right = 100.0
	offset_bottom = 80.0
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Find the LevelManager by walking up the tree
	_find_level_manager()

	# Set initial display
	_update_display()


func _process(_delta: float) -> void:
	if level_manager == null:
		_find_level_manager()
		if level_manager == null:
			return
	_update_display()


func _find_level_manager() -> void:
	# Walk up the scene tree to find the LevelManager (root of boss level scene)
	var node := get_parent()
	while node != null:
		if node is LevelManager:
			level_manager = node
			return
		node = node.get_parent()


func _update_display() -> void:
	if level_manager == null:
		return
	if level_manager.state == LevelManager.LevelState.BOSS_PHASE:
		text = "DEFEAT THE BOSS"
		add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	elif level_manager.state == LevelManager.LevelState.WAVE_PHASE:
		var seconds := level_manager.time_remaining
		text = LevelManager.format_time(seconds)
		add_theme_color_override("font_color", LevelManager.get_timer_color(seconds))
	else:
		text = ""
