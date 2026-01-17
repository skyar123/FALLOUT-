extends Node2D

## Main menu scene controller
## Handles the main menu interactions and scene transitions

@onready var render_engine = preload("res://scripts/RenderEngine.gd").new()

func _ready() -> void:
	print("LICHCRAFT - Godot Version")
	print("A tale of transformation in the age of Prime")
	_setup_ui()

func _setup_ui() -> void:
	# Add RenderEngine to scene for theme utilities
	add_child(render_engine)

func _on_new_game_pressed() -> void:
	print("Starting new game...")
	# Reset game state for fresh start
	GameState.reset_game()
	# Load character creation scene
	get_tree().change_scene_to_file("res://scenes/CharacterCreation.tscn")

func _on_load_game_pressed() -> void:
	print("Loading game...")
	if GameState.has_save_data():
		GameState.load_game()
		get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")
	else:
		print("No save data found!")
		# TODO: Show error message to player

func _on_options_pressed() -> void:
	print("Opening options...")
	# TODO: Implement options menu (sound, controls, display settings)
	pass

func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
