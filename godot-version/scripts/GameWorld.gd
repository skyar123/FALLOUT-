extends Node2D

## Game world controller
## Manages exploration, location display, and world interactions

# UI References (will be created dynamically)
var main_container: Control
var location_display: Control
var npcs_container: Control
var exits_container: Control
var action_buttons_container: Control

# Preloaded scenes
var inventory_scene = preload("res://scenes/InventoryScreen.tscn")
var quest_log_scene = preload("res://scenes/QuestLog.tscn")
var status_screen_scene = preload("res://scenes/StatusScreen.tscn")

# Random encounter system
var encounter_timer: Timer
var base_encounter_rate: float = 30.0  # seconds between checks

func _ready() -> void:
	print("Game world loaded")
	_setup_ui()
	_setup_encounter_system()

	# Connect to GameState signals
	GameState.location_changed.connect(_on_location_changed)
	GameState.health_changed.connect(_on_health_changed)

	# Initial display
	_update_location_display()

func _setup_ui() -> void:
	# Create main UI container
	main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)

	# Create main panel
	var main_panel = RenderEngine.create_panel(Vector2(1200, 800))
	main_panel.position = Vector2(60, 40)
	main_container.add_child(main_panel)

	# Create main layout
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 15)
	main_panel.add_child(main_vbox)

	# Header with player info
	var header = _create_header()
	main_vbox.add_child(header)

	# Location display
	location_display = _create_location_display()
	main_vbox.add_child(location_display)

	# NPCs section
	npcs_container = _create_npcs_section()
	main_vbox.add_child(npcs_container)

	# Exits section
	exits_container = _create_exits_section()
	main_vbox.add_child(exits_container)

	# Action buttons
	action_buttons_container = _create_action_buttons()
	main_vbox.add_child(action_buttons_container)

func _create_header() -> HBoxContainer:
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 20)

	# Player name
	var name_label = RenderEngine.create_label(GameState.player_name, 20, RenderEngine.current_theme["accent_color"])
	header.add_child(name_label)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	# Health display
	var health_label = RenderEngine.create_label(
		"HP: " + str(GameState.player_health) + "/" + str(GameState.player_max_health),
		16,
		RenderEngine.current_theme["text_color"]
	)
	header.add_child(health_label)

	# Health bar
	var health_bar = RenderEngine.create_health_bar(GameState.player_health, GameState.player_max_health, 200)
	header.add_child(health_bar)

	return header

func _create_location_display() -> PanelContainer:
	var panel = RenderEngine.create_panel(Vector2(0, 200))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Will be populated by _update_location_display()
	return panel

func _create_npcs_section() -> PanelContainer:
	var panel = RenderEngine.create_panel(Vector2(0, 150))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title = RenderEngine.create_label("NPCs Here:", 16, RenderEngine.current_theme["accent_color"])
	vbox.add_child(title)

	return panel

func _create_exits_section() -> PanelContainer:
	var panel = RenderEngine.create_panel(Vector2(0, 100))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title = RenderEngine.create_label("Available Exits:", 16, RenderEngine.current_theme["accent_color"])
	vbox.add_child(title)

	return panel

func _create_action_buttons() -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Explore button
	var explore_btn = RenderEngine.create_button("Explore", Vector2(150, 50))
	explore_btn.pressed.connect(_on_explore_pressed)
	hbox.add_child(explore_btn)

	# Inventory button
	var inventory_btn = RenderEngine.create_button("Inventory", Vector2(150, 50))
	inventory_btn.pressed.connect(_on_inventory_pressed)
	hbox.add_child(inventory_btn)

	# Quests button
	var quests_btn = RenderEngine.create_button("Quests", Vector2(150, 50))
	quests_btn.pressed.connect(_on_quests_pressed)
	hbox.add_child(quests_btn)

	# Status button
	var status_btn = RenderEngine.create_button("Status", Vector2(150, 50))
	status_btn.pressed.connect(_on_status_pressed)
	hbox.add_child(status_btn)

	return hbox

func _setup_encounter_system() -> void:
	encounter_timer = Timer.new()
	encounter_timer.timeout.connect(_check_random_encounter)
	add_child(encounter_timer)
	encounter_timer.start(base_encounter_rate)

func _update_location_display() -> void:
	var location_id = GameState.current_location
	var location_data = GameState.get_location(location_id)

	if location_data.is_empty():
		print("Warning: Location data not found for ", location_id)
		return

	# Clear and rebuild location display
	for child in location_display.get_children():
		child.queue_free()

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	location_display.add_child(vbox)

	# Location sprite
	var sprite_label = Label.new()
	sprite_label.text = location_data.get("sprite", "📍")
	sprite_label.add_theme_font_size_override("font_size", 64)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Location name
	var name_label = RenderEngine.create_label(location_data.get("name", "Unknown"), 22, RenderEngine.current_theme["accent_color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Location description
	var desc_label = RenderEngine.create_label(location_data.get("description", ""), 14)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	# Update NPCs
	_update_npcs_display(location_id)

	# Update exits
	_update_exits_display(location_data)

func _update_npcs_display(location_id: String) -> void:
	# Clear existing NPCs
	for child in npcs_container.get_children():
		if child is VBoxContainer or child is HBoxContainer:
			for grandchild in child.get_children():
				if grandchild.name != "NPCTitle":  # Keep title
					grandchild.queue_free()

	var npcs_here = GameState.get_npcs_at_location(location_id)

	# Find or create NPCs container
	var npcs_list = npcs_container.get_child(0) if npcs_container.get_child_count() > 0 else null
	if not npcs_list:
		npcs_list = VBoxContainer.new()
		npcs_list.add_theme_constant_override("separation", 10)
		npcs_container.add_child(npcs_list)

		var title = RenderEngine.create_label("NPCs Here:", 16, RenderEngine.current_theme["accent_color"])
		title.name = "NPCTitle"
		npcs_list.add_child(title)

	if npcs_here.is_empty():
		var empty_label = RenderEngine.create_label("No one here.", 12, RenderEngine.current_theme["text_color"])
		npcs_list.add_child(empty_label)
		return

	# Display each NPC
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	npcs_list.add_child(hbox)

	for npc_data in npcs_here:
		var npc_button = RenderEngine.create_button(npc_data.get("name", "???"), Vector2(150, 60))
		npc_button.pressed.connect(_on_npc_clicked.bind(npc_data.get("id", "")))
		hbox.add_child(npc_button)

func _update_exits_display(location_data: Dictionary) -> void:
	# Clear existing exits
	for child in exits_container.get_children():
		if child is VBoxContainer or child is HBoxContainer:
			for grandchild in child.get_children():
				if grandchild.name != "ExitsTitle":  # Keep title
					grandchild.queue_free()

	# Find or create exits container
	var exits_list = exits_container.get_child(0) if exits_container.get_child_count() > 0 else null
	if not exits_list:
		exits_list = VBoxContainer.new()
		exits_list.add_theme_constant_override("separation", 10)
		exits_container.add_child(exits_list)

		var title = RenderEngine.create_label("Available Exits:", 16, RenderEngine.current_theme["accent_color"])
		title.name = "ExitsTitle"
		exits_list.add_child(title)

	var connections = location_data.get("connections", [])

	if connections.is_empty():
		var no_exits = RenderEngine.create_label("No exits available.", 12, RenderEngine.current_theme["text_color"])
		exits_list.add_child(no_exits)
		return

	# Display each exit
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	exits_list.add_child(hbox)

	for connection in connections:
		var target_id = connection.get("target", "")
		var target_data = GameState.get_location(target_id)
		var target_name = target_data.get("name", target_id)

		# Check if exit requires a flag
		if connection.has("requiredFlag"):
			if not GameState.get_flag(connection["requiredFlag"]):
				continue  # Skip this exit if flag not set

		var exit_button = RenderEngine.create_button(target_name, Vector2(180, 50))
		exit_button.pressed.connect(_on_location_change.bind(target_id))
		hbox.add_child(exit_button)

func _on_npc_clicked(npc_id: String) -> void:
	print("Interacting with NPC: ", npc_id)
	var npc_data = GameState.get_npc(npc_id)

	if npc_data.is_empty():
		return

	# Get dialogue ID
	var dialogue_id = npc_data.get("dialogue", "")

	if dialogue_id.is_empty():
		print("NPC has no dialogue")
		return

	# Load and show dialogue scene
	var dialogue_scene = load("res://scenes/DialogueScene.tscn")
	if dialogue_scene:
		var dialogue_instance = dialogue_scene.instantiate()
		get_tree().root.add_child(dialogue_instance)

		# Pass dialogue ID to dialogue system
		if dialogue_instance.has_method("start_dialogue"):
			dialogue_instance.start_dialogue(dialogue_id)
	else:
		print("Dialogue scene not found")

func _on_location_change(target_location: String) -> void:
	print("Traveling to: ", target_location)
	GameState.change_location(target_location)

func _on_location_changed(new_location: String) -> void:
	_update_location_display()
	# Restart encounter timer for new location
	encounter_timer.stop()
	encounter_timer.start(base_encounter_rate)

func _on_health_changed(new_health: int, max_health: int) -> void:
	# Update health display in header
	if main_container:
		_setup_ui()  # Rebuild UI to update health

func _check_random_encounter() -> void:
	var location_data = GameState.get_location(GameState.current_location)
	var encounter_rate = location_data.get("encounterRate", 0.0)

	if encounter_rate <= 0:
		return

	var roll = randf()
	if roll < encounter_rate:
		_trigger_random_encounter(location_data)

	# Continue timer
	encounter_timer.start(base_encounter_rate)

func _trigger_random_encounter(location_data: Dictionary) -> void:
	var enemies = location_data.get("enemies", [])

	if enemies.is_empty():
		return

	# Pick random enemy
	var enemy_id = enemies[randi() % enemies.size()]

	print("Random encounter: ", enemy_id)

	# Stop encounter timer during combat
	encounter_timer.stop()

	# Load combat scene with enemy
	_start_combat(enemy_id)

func _start_combat(enemy_id: String) -> void:
	# Store enemy ID for combat scene to load
	GameState.set_flag("current_enemy", true)
	GameState.story_flags["current_enemy_id"] = enemy_id

	# Change to combat scene
	get_tree().change_scene_to_file("res://scenes/CombatScene.tscn")

func _on_explore_pressed() -> void:
	print("Explore pressed")
	var location_data = GameState.get_location(GameState.current_location)

	# Check for items to find
	if location_data.has("items"):
		var items = location_data["items"]
		if not items.is_empty():
			var found_item = items[randi() % items.size()]
			var item_data = GameState.get_item(found_item)

			if not GameState.has_item(found_item):
				GameState.add_item(found_item)
				_show_message("Found: " + item_data.get("name", found_item) + "!")
			else:
				_show_message("Nothing new to find here.")
		else:
			_show_message("Nothing to find here.")
	else:
		_show_message("Nothing to find here.")

func _on_inventory_pressed() -> void:
	print("Opening inventory")
	var inventory_instance = inventory_scene.instantiate()
	get_tree().root.add_child(inventory_instance)
	inventory_instance.inventory_closed.connect(func(): print("Inventory closed"))

func _on_quests_pressed() -> void:
	print("Opening quest log")
	var quest_log_instance = quest_log_scene.instantiate()
	get_tree().root.add_child(quest_log_instance)
	quest_log_instance.quest_log_closed.connect(func(): print("Quest log closed"))

func _on_status_pressed() -> void:
	print("Opening status screen")
	var status_instance = status_screen_scene.instantiate()
	get_tree().root.add_child(status_instance)
	status_instance.status_closed.connect(func(): print("Status closed"))

func _show_message(message: String) -> void:
	print("Message: ", message)
	# Could create a popup label here
	var message_label = RenderEngine.create_label(message, 14, RenderEngine.current_theme["accent_color"])
	message_label.position = Vector2(500, 400)
	main_container.add_child(message_label)

	# Auto-remove after delay
	await get_tree().create_timer(2.0).timeout
	message_label.queue_free()
