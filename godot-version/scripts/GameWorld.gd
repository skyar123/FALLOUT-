extends Node2D

## Game world controller
## Manages exploration, location display, and world interactions

@onready var location_name_label = $CanvasLayer/GameContainer/LocationView/LocationName
@onready var location_description = $CanvasLayer/GameContainer/LocationView/LocationDescription
@onready var actions_container = $CanvasLayer/GameContainer/LocationView/ActionsContainer

func _ready() -> void:
	print("Game world loaded")
	_update_location_display()

	# Connect to GameState signals
	GameState.location_changed.connect(_on_location_changed)
	GameState.health_changed.connect(_on_health_changed)

func _update_location_display() -> void:
	# TODO: Load location data from game data resource
	var location_id = GameState.current_location
	location_name_label.text = _get_location_name(location_id)
	location_description.text = _get_location_description(location_id)
	_update_available_actions(location_id)

func _get_location_name(location_id: String) -> String:
	# TODO: Load from actual game data
	var locations = {
		"apartment": "Your Apartment",
		"city_streets": "Prime City Streets",
		"underground_market": "Underground Market",
		"abandoned_library": "Abandoned Library",
		"abandoned_district": "Abandoned District",
		"healthcare_center": "Prime Healthcare Center",
		"safe_house": "Community Safe House",
		"forgotten_place": "The Forgotten Place"
	}
	return locations.get(location_id, "Unknown Location")

func _get_location_description(location_id: String) -> String:
	# TODO: Load from actual game data
	var descriptions = {
		"apartment": "Your small apartment in the Prime Housing Complex. Sterile, monitored, but it's yours. For now.",
		"city_streets": "The streets are lined with surveillance cameras and Prime advertisements. Citizens hurry past, eyes down.",
		"underground_market": "A bustling black market hidden from Prime's watchful eyes. The air smells of freedom and danger.",
		"abandoned_library": "Dusty shelves of forgotten knowledge. Prime doesn't see value in old books - which makes them invaluable.",
		"abandoned_district": "This part of the city was abandoned when it stopped being profitable. Now magic lingers here.",
		"healthcare_center": "Gleaming chrome and false promises. A monument to bureaucracy and waiting lists.",
		"safe_house": "A hidden sanctuary where the trans community supports each other. Mutual aid in action.",
		"forgotten_place": "A place of power, outside Prime's reach. Perfect for rituals they'd never understand."
	}
	return descriptions.get(location_id, "An unknown place.")

func _update_available_actions(location_id: String) -> void:
	# Clear existing action buttons
	for child in actions_container.get_children():
		child.queue_free()

	# TODO: Add dynamic actions based on location
	# For now, just show a placeholder
	var label = Label.new()
	label.text = "Available actions will appear here..."
	actions_container.add_child(label)

func _on_location_changed(new_location: String) -> void:
	_update_location_display()

func _on_health_changed(new_health: int, max_health: int) -> void:
	print("Health: ", new_health, "/", max_health)

func _on_explore_pressed() -> void:
	print("Explore pressed")
	# TODO: Show exploration options

func _on_inventory_pressed() -> void:
	print("Inventory pressed")
	# TODO: Open inventory screen

func _on_quests_pressed() -> void:
	print("Quests pressed")
	# TODO: Open quest log

func _on_status_pressed() -> void:
	print("Status pressed")
	# TODO: Show character status
