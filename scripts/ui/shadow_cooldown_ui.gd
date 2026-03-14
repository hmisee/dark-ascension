extends Control
class_name ShadowCooldownUI

# Shows shadow companion status, respawn cooldowns, and resurrection indicators

@onready var skeleton_panel = $HBox/SkeletonPanel
@onready var skeleton_icon = $HBox/SkeletonPanel/VBox/Icon
@onready var skeleton_cooldown_label = $HBox/SkeletonPanel/VBox/CooldownLabel
@onready var skeleton_bar = $HBox/SkeletonPanel/VBox/CooldownBar
@onready var wraith_panel = $HBox/WraithPanel
@onready var wraith_icon = $HBox/WraithPanel/VBox/Icon
@onready var wraith_cooldown_label = $HBox/WraithPanel/VBox/CooldownLabel
@onready var wraith_bar = $HBox/WraithPanel/VBox/CooldownBar

const TEAL = Color(0.3, 1.0, 0.9)
const DEAD_COLOR = Color(0.4, 0.4, 0.4)
const READY_COLOR = Color(0.4, 1.0, 0.5)
const DIM_ALPHA = 0.4

func update_cooldowns(
	skel_alive: bool, skel_timer: float, skel_max: float,
	wraith_alive: bool, wraith_timer: float, wraith_max: float,
	skel_cost: int = 0, wraith_cost: int = 0, current_souls: int = 0
):
	# Skeleton shadow
	_update_shadow_panel(
		skel_alive, skel_timer, skel_max, skel_cost, current_souls,
		skeleton_panel, skeleton_icon, skeleton_cooldown_label, skeleton_bar, "[1]"
	)

	# Wraith shadow
	_update_shadow_panel(
		wraith_alive, wraith_timer, wraith_max, wraith_cost, current_souls,
		wraith_panel, wraith_icon, wraith_cooldown_label, wraith_bar, "[2]"
	)


func _update_shadow_panel(
	alive: bool, timer: float, max_cd: float, cost: int, current_souls: int,
	panel: PanelContainer, icon: Label, label: Label, bar: ProgressBar, key_hint: String
):
	if alive:
		# Shadow is alive and active
		icon.modulate = TEAL
		label.text = "READY"
		bar.visible = false
		panel.modulate = Color.WHITE
	elif timer > 0.0:
		# Dead and still on cooldown
		icon.modulate = DEAD_COLOR
		var t = max(timer, 0.0)
		label.text = "%0.1fs" % t
		bar.visible = true
		bar.value = (1.0 - t / max_cd) * 100.0 if max_cd > 0 else 0
		panel.modulate = Color.WHITE
	else:
		# Dead, cooldown expired — eligible for resurrection
		icon.modulate = READY_COLOR
		label.text = "Cost: %d 💀 %s" % [cost, key_hint]
		bar.visible = false
		if current_souls < cost:
			panel.modulate = Color(1, 1, 1, DIM_ALPHA)
		else:
			panel.modulate = Color.WHITE
