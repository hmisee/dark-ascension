extends Control
class_name ShadowCooldownUI

# Shows shadow companion status and respawn cooldowns

@onready var skeleton_icon = $HBox/SkeletonPanel/VBox/Icon
@onready var skeleton_cooldown_label = $HBox/SkeletonPanel/VBox/CooldownLabel
@onready var skeleton_bar = $HBox/SkeletonPanel/VBox/CooldownBar
@onready var wraith_icon = $HBox/WraithPanel/VBox/Icon
@onready var wraith_cooldown_label = $HBox/WraithPanel/VBox/CooldownLabel
@onready var wraith_bar = $HBox/WraithPanel/VBox/CooldownBar

const TEAL = Color(0.3, 1.0, 0.9)
const DEAD_COLOR = Color(0.4, 0.4, 0.4)

func update_cooldowns(
	skel_alive: bool, skel_timer: float, skel_max: float,
	wraith_alive: bool, wraith_timer: float, wraith_max: float
):
	# Skeleton shadow
	if skel_alive:
		skeleton_icon.modulate = TEAL
		skeleton_cooldown_label.text = "READY"
		skeleton_bar.visible = false
	else:
		skeleton_icon.modulate = DEAD_COLOR
		var t = max(skel_timer, 0.0)
		skeleton_cooldown_label.text = "%0.1fs" % t
		skeleton_bar.visible = true
		skeleton_bar.value = (1.0 - t / skel_max) * 100.0 if skel_max > 0 else 0
	
	# Wraith shadow
	if wraith_alive:
		wraith_icon.modulate = TEAL
		wraith_cooldown_label.text = "READY"
		wraith_bar.visible = false
	else:
		wraith_icon.modulate = DEAD_COLOR
		var t = max(wraith_timer, 0.0)
		wraith_cooldown_label.text = "%0.1fs" % t
		wraith_bar.visible = true
		wraith_bar.value = (1.0 - t / wraith_max) * 100.0 if wraith_max > 0 else 0
