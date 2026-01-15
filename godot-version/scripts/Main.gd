extends Node2D

## Main menu scene controller
## Handles the main menu interactions and scene transitions

func _ready() -> void:
	print("LICHCRAFT - Godot Version")
	_setup_ui()

func _setup_ui() -> void:
	# Add custom styling and theme setup here if needed
	pass

func _on_new_game_pressed() -> void:
	print("Starting new game...")
	# TODO: Load character creation scene or go straight to game world
	get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")

func _on_load_game_pressed() -> void:
	print("Loading game...")
	# TODO: Implement save/load system
	GameState.load_game()
	if GameState.has_save_data():
		get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")
	else:
		print("No save data found!")

func _on_options_pressed() -> void:
	print("Opening options...")
	# TODO: Implement options menu
	pass

func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
