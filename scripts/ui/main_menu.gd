extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/dungeon/boss_level.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
