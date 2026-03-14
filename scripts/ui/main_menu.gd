extends Control

func _ready():
	var am = Autoloads.audio_manager()
	if am:
		am.play_bgm("menu")

func _on_start_button_pressed():
	LevelManager._saved_run_state = {}
	var gm = Autoloads.game_manager()
	if gm:
		gm.start_new_run()
	get_tree().change_scene_to_file("res://scenes/dungeon/boss_level.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
