extends Node2D
class_name EnemySpawner

# Spawns enemies in waves around the player

@export var skeleton_scene: PackedScene = preload("res://scenes/skeleton_enemy.tscn")
@export var ghost_scene: PackedScene = preload("res://scenes/ghost_enemy.tscn")
@export var spawn_interval: float = 3.0
@export var spawn_distance: float = 400.0
@export var max_enemies: int = 15

var spawn_timer: float = 0.0
var player: Node2D = null
var current_enemy_count: int = 0

func _ready():
	find_player()
	spawn_timer = 1.0  # First spawn after 1 second

func _process(delta):
	spawn_timer -= delta
	
	if spawn_timer <= 0 and current_enemy_count < max_enemies:
		spawn_enemy()
		spawn_timer = spawn_interval

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func spawn_enemy():
	if not player:
		find_player()
		return
	
	# Randomly choose enemy type
	var enemy_scene = skeleton_scene if randf() > 0.3 else ghost_scene
	var enemy = enemy_scene.instantiate()
	
	# Spawn at random position around player
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = spawn_pos
	
	# Connect to track enemy count
	enemy.tree_exited.connect(_on_enemy_died)
	
	get_parent().add_child(enemy)
	current_enemy_count += 1

func _on_enemy_died():
	current_enemy_count -= 1
