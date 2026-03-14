extends Node2D
class_name LevelManager

## Orchestrates the boss level lifecycle:
## Phase 1: Survive regular enemies for survival_time seconds
## Phase 2: Boss spawns, kill the boss to win

enum LevelState { INITIALIZING, WAVE_PHASE, BOSS_PHASE, COMPLETE, FAILED }

signal level_completed
signal level_failed

@export var survival_time: float = 20.0
@export var boss_spawn_distance: float = 400.0

var time_remaining: float = 0.0
var state: LevelState = LevelState.INITIALIZING
var boss: BossSkeleton = null
var player: Player = null
var enemy_spawner: EnemySpawner = null

# Persists across scene reloads (static so it survives scene transitions)
static var _saved_run_state: Dictionary = {}

const BOSS_SCENE_PATH := "res://scenes/boss_skeleton.tscn"
const BOSS_LEVEL_SCENE_PATH := "res://scenes/dungeon/boss_level.tscn"
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"


func _ready() -> void:
	start_level()


func start_level() -> void:
	# Restore previous run state if available
	var gm = Autoloads.game_manager()
	if gm and not _saved_run_state.is_empty():
		gm.load_run_state(_saved_run_state)

	# Find the player in the scene tree
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	if player:
		player.global_position = Vector2.ZERO
		player.managed_level = true
		if not player.player_died.is_connected(_on_level_failed):
			player.player_died.connect(_on_level_failed)

	# Find and enable the EnemySpawner for wave phase
	for child in get_children():
		if child is EnemySpawner:
			enemy_spawner = child
			enemy_spawner.set_process(true)
			enemy_spawner.set_physics_process(true)
			# Override process_mode so it actually runs
			enemy_spawner.process_mode = Node.PROCESS_MODE_INHERIT
			break

	time_remaining = survival_time
	state = LevelState.WAVE_PHASE


func _physics_process(delta: float) -> void:
	if state == LevelState.WAVE_PHASE:
		time_remaining -= delta
		time_remaining = maxf(time_remaining, 0.0)
		if time_remaining <= 0.0:
			_start_boss_phase()


func _start_boss_phase() -> void:
	state = LevelState.BOSS_PHASE

	# Stop enemy spawner and clear all regular enemies
	if enemy_spawner:
		enemy_spawner.set_process(false)
		enemy_spawner.set_physics_process(false)
	_clear_regular_enemies()

	# Spawn boss at configured distance from player
	var boss_scene := load(BOSS_SCENE_PATH) as PackedScene
	if boss_scene:
		boss = boss_scene.instantiate() as BossSkeleton
		var spawn_angle := randf() * TAU
		var player_pos: Vector2 = player.global_position if player else Vector2.ZERO
		var spawn_offset := Vector2(cos(spawn_angle), sin(spawn_angle)) * boss_spawn_distance
		boss.global_position = player_pos + spawn_offset
		add_child(boss)
		if not boss.boss_defeated.is_connected(_on_boss_defeated):
			boss.boss_defeated.connect(_on_boss_defeated)


func _clear_regular_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy) and not (enemy is BossSkeleton):
			enemy.queue_free()


func _on_boss_defeated() -> void:
	# Boss killed = level complete
	_on_level_complete()


func _on_level_complete() -> void:
	if state == LevelState.COMPLETE:
		return
	state = LevelState.COMPLETE

	# Award relic
	var gm = Autoloads.game_manager()
	if gm:
		gm.award_relic()

	level_completed.emit()

	# Pause the game tree so nothing moves in the background
	get_tree().paused = true
	_show_victory_popup()


func _on_level_failed() -> void:
	if state != LevelState.WAVE_PHASE and state != LevelState.BOSS_PHASE:
		return
	state = LevelState.FAILED

	# Remove boss if still alive
	if is_instance_valid(boss):
		boss.queue_free()

	level_failed.emit()

	get_tree().paused = true
	_show_failure_screen()


# --- Level transition methods ---

func _on_shop_pressed() -> void:
	get_tree().paused = false
	var gm = Autoloads.game_manager()
	if gm:
		_saved_run_state = gm.save_run_state()
	get_tree().change_scene_to_file("res://scenes/shop_scene.tscn")


func _on_continue_pressed() -> void:
	get_tree().paused = false
	var gm = Autoloads.game_manager()
	if gm:
		_saved_run_state = gm.save_run_state()
	get_tree().change_scene_to_file(BOSS_LEVEL_SCENE_PATH)


func _on_retry_pressed() -> void:
	get_tree().paused = false
	var gm = Autoloads.game_manager()
	if gm:
		gm.start_new_run()
	_saved_run_state = {}
	get_tree().change_scene_to_file(BOSS_LEVEL_SCENE_PATH)


func _on_menu_pressed() -> void:
	get_tree().paused = false
	_saved_run_state = {}
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


# --- UI helpers ---

func _show_victory_popup() -> void:
	var screen := Control.new()
	screen.name = "VictoryPopup"
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.process_mode = Node.PROCESS_MODE_ALWAYS

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	screen.add_child(vbox)

	var title := Label.new()
	title.text = "Boss Defeated!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	vbox.add_child(title)

	var soul_label := Label.new()
	var sem = Autoloads.soul_energy_manager()
	var souls: int = sem.get_souls() if sem else 0
	soul_label.text = "Soul Energy: %d" % souls
	soul_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	soul_label.add_theme_font_size_override("font_size", 16)
	soul_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(soul_label)

	var shop_btn := Button.new()
	shop_btn.text = "Go to Shop"
	shop_btn.custom_minimum_size = Vector2(180, 44)
	shop_btn.pressed.connect(_on_shop_pressed)
	vbox.add_child(shop_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(180, 44)
	menu_btn.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_btn)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(screen)
	add_child(canvas)


func _show_failure_screen() -> void:
	var screen := FailureScreen.new()
	screen.name = "FailureScreen"
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	screen.retry_pressed.connect(_on_retry_pressed)
	screen.menu_pressed.connect(_on_menu_pressed)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(screen)
	add_child(canvas)


# --- Static helper functions ---

static func format_time(seconds: float) -> String:
	if seconds <= 0.0:
		return "0.0"
	if seconds <= 10.0:
		return "%.1f" % seconds
	return "%d" % ceili(seconds)


static func get_timer_color(seconds: float) -> Color:
	if seconds <= 5.0:
		return Color.RED
	return Color.WHITE
