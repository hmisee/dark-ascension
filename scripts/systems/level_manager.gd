extends Node2D
class_name LevelManager

## Orchestrates the boss level lifecycle:
## Phase 1: Survive regular enemies for survival_time seconds
## Phase 2: Boss spawns, kill the boss to win

enum LevelState { INITIALIZING, WAVE_PHASE, BOSS_PHASE, COMPLETE, FAILED }

signal level_completed
signal level_failed

@export var survival_time: float = 240.0
@export var boss_spawn_distance: float = 400.0

var time_remaining: float = 0.0
var state: LevelState = LevelState.INITIALIZING
var boss: Node2D = null
var player: Player = null
var enemy_spawner: EnemySpawner = null

# Persists across scene reloads (static so it survives scene transitions)
static var _saved_run_state: Dictionary = {}

const BOSS_SKELETON_SCENE_PATH := "res://scenes/boss_skeleton.tscn"
const BOSS_WRAITH_SCENE_PATH := "res://scenes/boss_wraith.tscn"
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

	# Reapply stat bonuses after run state (relic grid) is restored
	if gm and gm.stat_bonus_applier:
		gm.stat_bonus_applier.apply_bonuses()

	time_remaining = survival_time
	state = LevelState.WAVE_PHASE

	var am = Autoloads.audio_manager()
	if am:
		am.play_bgm("wave")


func _physics_process(delta: float) -> void:
	if state == LevelState.WAVE_PHASE:
		time_remaining -= delta
		time_remaining = maxf(time_remaining, 0.0)
		if time_remaining <= 0.0:
			_start_boss_phase()


func _start_boss_phase() -> void:
	state = LevelState.BOSS_PHASE

	var am = Autoloads.audio_manager()
	if am:
		am.play_bgm("boss")

	# Stop enemy spawner and clear all regular enemies
	if enemy_spawner:
		enemy_spawner.set_process(false)
		enemy_spawner.set_physics_process(false)
	_clear_regular_enemies()

	# Determine which boss to spawn based on current level
	var gm = Autoloads.game_manager()
	var level: int = gm.current_level if gm else 1
	var boss_scene_path: String
	if level == 2:
		boss_scene_path = BOSS_WRAITH_SCENE_PATH
	else:
		# Default to BossSkeleton for level 1 or unexpected values
		boss_scene_path = BOSS_SKELETON_SCENE_PATH

	# Spawn boss at configured distance from player
	var boss_scene := load(boss_scene_path) as PackedScene
	if boss_scene:
		var boss_instance = boss_scene.instantiate()
		boss = boss_instance
		var spawn_angle := randf() * TAU
		var player_pos: Vector2 = player.global_position if player else Vector2.ZERO
		var spawn_offset := Vector2(cos(spawn_angle), sin(spawn_angle)) * boss_spawn_distance
		boss_instance.global_position = player_pos + spawn_offset
		add_child(boss_instance)
		if not boss_instance.boss_defeated.is_connected(_on_boss_defeated):
			boss_instance.boss_defeated.connect(_on_boss_defeated)


func _clear_regular_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy) and not (enemy is BossSkeleton) and not (enemy is BossWraith):
			enemy.queue_free()


func _on_boss_defeated() -> void:
	var gm = Autoloads.game_manager()

	# Auto-collect the boss's soul drop (game pauses so player can't walk over it)
	if boss and is_instance_valid(boss):
		var bonus := 0.0
		if gm and gm.stat_bonus_applier:
			bonus = gm.stat_bonus_applier.soul_bonus
		var effective_souls := int(round(boss.soul_value * (1.0 + bonus / 100.0)))
		Autoloads.soul_energy_manager().add_souls(effective_souls)
		# Prevent the normal soul drop from spawning
		boss.soul_value = 0

	# Auto-collect a random shard from the pool
	var shard_name := ""
	if gm and gm.shard_inventory:
		var pool := ShardPool.get_all_shards()
		if pool.size() > 0:
			var random_shard := Shard.deserialize(pool[randi() % pool.size()].serialize())
			shard_name = random_shard.shard_name
			gm.shard_inventory.add_shard(random_shard)

	# Advance progression before completing the level
	if gm:
		gm.advance_level()
	_on_level_complete(shard_name)


func _on_level_complete(shard_name: String = "") -> void:
	if state == LevelState.COMPLETE:
		return
	state = LevelState.COMPLETE

	var am = Autoloads.audio_manager()
	if am:
		am.play_bgm("menu")

	# Award relic
	var gm = Autoloads.game_manager()
	if gm:
		gm.award_relic()

	level_completed.emit()

	# Pause the game tree so nothing moves in the background
	get_tree().paused = true

	# Show VictoryScreen if this was the final level, otherwise show post-level popup
	if gm and gm.is_final_level():
		_show_victory_screen()
	else:
		_show_post_level_screen(shard_name)


func _on_level_failed() -> void:
	if state != LevelState.WAVE_PHASE and state != LevelState.BOSS_PHASE:
		return
	state = LevelState.FAILED

	var am = Autoloads.audio_manager()
	if am:
		am.play_bgm("menu")

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


func _on_new_run_pressed() -> void:
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

func _show_victory_screen() -> void:
	var screen := VictoryScreen.new()
	screen.name = "VictoryScreen"
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	screen.size = get_viewport().get_visible_rect().size
	screen.new_run_pressed.connect(_on_new_run_pressed)
	screen.menu_pressed.connect(_on_menu_pressed)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(screen)
	add_child(canvas)


func _show_post_level_screen(shard_name: String = "") -> void:
	var screen := Control.new()
	screen.name = "PostLevelScreen"
	screen.size = get_viewport().get_visible_rect().size
	screen.process_mode = Node.PROCESS_MODE_ALWAYS

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

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

	if shard_name != "":
		var shard_label := Label.new()
		shard_label.text = "Shard Acquired: %s" % shard_name
		shard_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		shard_label.add_theme_font_size_override("font_size", 16)
		shard_label.add_theme_color_override("font_color", Color(0.6, 0.4, 1.0))
		vbox.add_child(shard_label)

	var next_btn := Button.new()
	next_btn.text = "Next Level"
	next_btn.custom_minimum_size = Vector2(180, 44)
	next_btn.pressed.connect(_on_continue_pressed)
	vbox.add_child(next_btn)

	var shop_btn := Button.new()
	shop_btn.text = "Go to Shop"
	shop_btn.custom_minimum_size = Vector2(180, 44)
	shop_btn.pressed.connect(_on_shop_pressed)
	vbox.add_child(shop_btn)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(screen)
	add_child(canvas)


func _show_failure_screen() -> void:
	var screen := FailureScreen.new()
	screen.name = "FailureScreen"
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	screen.size = get_viewport().get_visible_rect().size
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
