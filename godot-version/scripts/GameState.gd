extends Node

## Global game state manager
## Stores player data, inventory, quests, flags, and handles save/load

# Game data loaded from JSON
var game_data: Dictionary = {}
var npcs: Dictionary = {}
var locations: Dictionary = {}
var enemies: Dictionary = {}
var items: Dictionary = {}
var dialogues: Dictionary = {}
var quests: Dictionary = {}
var character_creation: Array = []

# Player attributes
var player_name: String = "Wanderer"
var player_health: int = 10
var player_max_health: int = 10
var player_strength: int = 1
var player_sense: int = 1
var player_spells: int = 1

# Character creation choices
var player_identity: String = ""
var player_politics: String = ""
var player_hobby: String = ""
var player_job: String = ""
var player_subscription: String = ""
var player_magic_source: String = ""

# Current state
var current_location: String = "apartment"
var inventory: Array = []
var active_quests: Array = []
var completed_quests: Array = []
var story_flags: Dictionary = {}

# Save file path
const SAVE_PATH = "user://lichcraft_save.json"

signal health_changed(new_health: int, max_health: int)
signal location_changed(new_location: String)
signal inventory_changed()
signal quest_updated(quest_id: String)

func _ready() -> void:
	print("GameState initialized")
	load_game_data()

## Load game data from JSON
func load_game_data() -> void:
	var file = FileAccess.open("res://data/game_data.json", FileAccess.READ)
	if not file:
		print("ERROR: Could not load game_data.json!")
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		print("ERROR: Failed to parse game_data.json!")
		return

	game_data = json.data
	npcs = game_data.get("npcs", {})
	locations = game_data.get("locations", {})
	enemies = game_data.get("enemies", {})
	items = game_data.get("items", {})
	dialogues = game_data.get("dialogues", {})
	quests = game_data.get("quests", {})
	character_creation = game_data.get("character_creation", [])

	print("Game data loaded successfully!")
	print("- NPCs: ", npcs.size())
	print("- Locations: ", locations.size())
	print("- Enemies: ", enemies.size())
	print("- Items: ", items.size())
	print("- Dialogues: ", dialogues.size())
	print("- Quests: ", quests.size())

## Get data helpers
func get_npc(npc_id: String) -> Dictionary:
	return npcs.get(npc_id, {})

func get_location(location_id: String) -> Dictionary:
	return locations.get(location_id, {})

func get_enemy(enemy_id: String) -> Dictionary:
	return enemies.get(enemy_id, {})

func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

func get_dialogue(dialogue_id: String) -> Dictionary:
	return dialogues.get(dialogue_id, {})

func get_quest(quest_id: String) -> Dictionary:
	return quests.get(quest_id, {})

func get_npcs_at_location(location_id: String) -> Array:
	var npcs_here = []
	for npc_id in npcs:
		var npc = npcs[npc_id]
		if npc.get("location") == location_id:
			# Check if NPC is available (conditional availability)
			if npc.has("availableIf"):
				var condition = npc["availableIf"]
				if condition.has("flag") and not get_flag(condition["flag"]):
					continue
			npcs_here.append(npc)
	return npcs_here

## Character Management
func create_character(char_data: Dictionary) -> void:
	player_name = char_data.get("name", "Wanderer")
	player_identity = char_data.get("identity", "")
	player_politics = char_data.get("politics", "")
	player_hobby = char_data.get("hobby", "")
	player_job = char_data.get("job", "")
	player_subscription = char_data.get("subscription", "")
	player_magic_source = char_data.get("magic_source", "")

	# Set attributes from character creation
	player_strength = char_data.get("strength", 1)
	player_sense = char_data.get("sense", 1)
	player_spells = char_data.get("spells", 1)

## Health Management
func modify_health(amount: int) -> void:
	player_health = clamp(player_health + amount, 0, player_max_health)
	health_changed.emit(player_health, player_max_health)

	if player_health <= 0:
		_handle_player_death()

func _handle_player_death() -> void:
	print("Player has died!")
	# TODO: Implement death/game over logic

## Inventory Management
func add_item(item_id: String) -> void:
	inventory.append(item_id)
	inventory_changed.emit()
	print("Added item: ", item_id)

func remove_item(item_id: String) -> bool:
	var index = inventory.find(item_id)
	if index != -1:
		inventory.remove_at(index)
		inventory_changed.emit()
		print("Removed item: ", item_id)
		return true
	return false

func has_item(item_id: String) -> bool:
	return inventory.has(item_id)

## Quest Management
func start_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		active_quests.append(quest_id)
		quest_updated.emit(quest_id)
		print("Started quest: ", quest_id)

func complete_quest(quest_id: String) -> void:
	var index = active_quests.find(quest_id)
	if index != -1:
		active_quests.remove_at(index)
		completed_quests.append(quest_id)
		quest_updated.emit(quest_id)
		print("Completed quest: ", quest_id)

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

## Story Flags
func set_flag(flag_name: String, value: bool = true) -> void:
	story_flags[flag_name] = value
	print("Set flag: ", flag_name, " = ", value)

func get_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)

## Location Management
func change_location(location_id: String) -> void:
	current_location = location_id
	location_changed.emit(location_id)
	print("Changed location to: ", location_id)

## Save/Load System
func save_game() -> void:
	var save_data = {
		"player_name": player_name,
		"player_health": player_health,
		"player_max_health": player_max_health,
		"player_strength": player_strength,
		"player_sense": player_sense,
		"player_spells": player_spells,
		"player_identity": player_identity,
		"player_politics": player_politics,
		"player_hobby": player_hobby,
		"player_job": player_job,
		"player_subscription": player_subscription,
		"player_magic_source": player_magic_source,
		"current_location": current_location,
		"inventory": inventory,
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"story_flags": story_flags
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved successfully!")
	else:
		print("Failed to save game!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var save_data = json.data
			player_name = save_data.get("player_name", "Wanderer")
			player_health = save_data.get("player_health", 10)
			player_max_health = save_data.get("player_max_health", 10)
			player_strength = save_data.get("player_strength", 1)
			player_sense = save_data.get("player_sense", 1)
			player_spells = save_data.get("player_spells", 1)
			player_identity = save_data.get("player_identity", "")
			player_politics = save_data.get("player_politics", "")
			player_hobby = save_data.get("player_hobby", "")
			player_job = save_data.get("player_job", "")
			player_subscription = save_data.get("player_subscription", "")
			player_magic_source = save_data.get("player_magic_source", "")
			current_location = save_data.get("current_location", "apartment")
			inventory = save_data.get("inventory", [])
			active_quests = save_data.get("active_quests", [])
			completed_quests = save_data.get("completed_quests", [])
			story_flags = save_data.get("story_flags", {})
			print("Game loaded successfully!")
		else:
			print("Failed to parse save file!")
	else:
		print("Failed to open save file!")

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset_game() -> void:
	player_health = 10
	player_max_health = 10
	player_strength = 1
	player_sense = 1
	player_spells = 1
	current_location = "apartment"
	inventory.clear()
	active_quests.clear()
	completed_quests.clear()
	story_flags.clear()
	print("Game state reset")
