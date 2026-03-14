extends Label
class_name SoulEnergyHUD

## Displays the player's current soul energy total in the HUD.
## Connects to SoulEnergyManager.souls_changed for real-time updates.

func _ready() -> void:
	# Style the label
	add_theme_font_size_override("font_size", 20)
	add_theme_color_override("font_color", Color(0.6, 0.4, 1.0))  # Purple tint for souls
	add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	add_theme_constant_override("shadow_offset_x", 1)
	add_theme_constant_override("shadow_offset_y", 1)

	# Position at top-center of the screen
	anchors_preset = PRESET_CENTER_TOP
	anchor_left = 0.5
	anchor_top = 0.0
	anchor_right = 0.5
	anchor_bottom = 0.0
	offset_left = -80.0
	offset_top = 10.0
	offset_right = 80.0
	offset_bottom = 40.0
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Connect to the SoulEnergyManager signal
	var sem := Autoloads.soul_energy_manager()
	sem.souls_changed.connect(_on_souls_changed)

	# Set initial value
	_on_souls_changed(sem.get_souls())


func _on_souls_changed(new_total: int) -> void:
	text = "Souls: %d" % new_total
