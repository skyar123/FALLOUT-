extends Node2D

## Combat system controller
## Manages turn-based Pokemon-style combat with full enemy data loading

enum CombatState {
	PLAYER_TURN,
	ENEMY_TURN,
	COMBAT_END
}

# UI References (will be created dynamically)
var main_container: Control
var player_display: Control
var enemy_display: Control
var combat_log_label: RichTextLabel
var action_buttons_container: Control
var item_selection_panel: Control

var current_state: CombatState = CombatState.PLAYER_TURN
var enemy_data: Dictionary = {}
var enemy_health: int = 0
var enemy_max_health: int = 0
var enemy_id: String = ""

func _ready() -> void:
	print("Combat scene loaded")
	_setup_combat_ui()
	_initialize_combat()

func _setup_combat_ui() -> void:
	# Create main container
	main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)

	# Create main panel
	var main_panel = RenderEngine.create_panel(Vector2(1200, 800))
	main_panel.position = Vector2(60, 40)
	main_container.add_child(main_panel)

	# Main layout
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 20)
	main_panel.add_child(main_vbox)

	# Title
	var title = RenderEngine.create_label("COMBAT", 28, RenderEngine.current_theme["accent_color"])
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title)

	# Combat area (player and enemy)
	var combat_area = HBoxContainer.new()
	combat_area.add_theme_constant_override("separation", 40)
	combat_area.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(combat_area)

	# Player display
	player_display = _create_player_display()
	combat_area.add_child(player_display)

	# VS label
	var vs_label = RenderEngine.create_label("VS", 32, RenderEngine.current_theme["accent_color"])
	combat_area.add_child(vs_label)

	# Enemy display
	enemy_display = _create_enemy_display()
	combat_area.add_child(enemy_display)

	# Combat log
	var log_panel = RenderEngine.create_panel(Vector2(0, 200))
	main_vbox.add_child(log_panel)

	var log_vbox = VBoxContainer.new()
	log_panel.add_child(log_vbox)

	var log_title = RenderEngine.create_label("Combat Log:", 14, RenderEngine.current_theme["accent_color"])
	log_vbox.add_child(log_title)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 150)
	log_vbox.add_child(scroll)

	combat_log_label = RichTextLabel.new()
	combat_log_label.bbcode_enabled = true
	combat_log_label.fit_content = true
	combat_log_label.scroll_following = true
	scroll.add_child(combat_log_label)

	# Action buttons
	action_buttons_container = _create_action_buttons()
	main_vbox.add_child(action_buttons_container)

func _create_player_display() -> PanelContainer:
	var panel = RenderEngine.create_panel(Vector2(350, 300))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Player sprite (will be updated)
	var sprite_label = Label.new()
	sprite_label.name = "PlayerSprite"
	sprite_label.text = "🧙"
	sprite_label.add_theme_font_size_override("font_size", 96)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Player name
	var name_label = RenderEngine.create_label(GameState.player_name, 20, RenderEngine.current_theme["accent_color"])
	name_label.name = "PlayerName"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Health bar
	var health_bar = RenderEngine.create_health_bar(GameState.player_health, GameState.player_max_health, 280)
	health_bar.name = "PlayerHealthBar"
	vbox.add_child(health_bar)

	# Health text
	var health_text = RenderEngine.create_label(
		str(GameState.player_health) + " / " + str(GameState.player_max_health) + " HP",
		14,
		RenderEngine.current_theme["text_color"]
	)
	health_text.name = "PlayerHealthText"
	health_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(health_text)

	return panel

func _create_enemy_display() -> PanelContainer:
	var panel = RenderEngine.create_panel(Vector2(350, 300))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Enemy sprite (will be updated)
	var sprite_label = Label.new()
	sprite_label.name = "EnemySprite"
	sprite_label.text = "👾"
	sprite_label.add_theme_font_size_override("font_size", 96)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Enemy name
	var name_label = RenderEngine.create_label("Enemy", 20, RenderEngine.current_theme["accent_color"])
	name_label.name = "EnemyName"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Health bar
	var health_bar = RenderEngine.create_health_bar(10, 10, 280)
	health_bar.name = "EnemyHealthBar"
	vbox.add_child(health_bar)

	# Health text
	var health_text = RenderEngine.create_label("10 / 10 HP", 14, RenderEngine.current_theme["text_color"])
	health_text.name = "EnemyHealthText"
	health_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(health_text)

	return panel

func _create_action_buttons() -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Attack button (Strength-based)
	var attack_btn = RenderEngine.create_button("Attack (Strength)", Vector2(180, 60))
	attack_btn.pressed.connect(_on_attack_pressed)
	hbox.add_child(attack_btn)

	# Spell button (Spells-based)
	var spell_btn = RenderEngine.create_button("Cast Spell (Spells)", Vector2(180, 60))
	spell_btn.pressed.connect(_on_spell_pressed)
	hbox.add_child(spell_btn)

	# Item button
	var item_btn = RenderEngine.create_button("Use Item", Vector2(180, 60))
	item_btn.pressed.connect(_on_item_pressed)
	hbox.add_child(item_btn)

	# Flee button (Sense-based)
	var flee_btn = RenderEngine.create_button("Flee (Sense)", Vector2(180, 60))
	flee_btn.pressed.connect(_on_flee_pressed)
	hbox.add_child(flee_btn)

	return hbox

func _initialize_combat() -> void:
	# Load enemy data from GameState
	if GameState.story_flags.has("current_enemy_id"):
		enemy_id = GameState.story_flags["current_enemy_id"]
		enemy_data = GameState.get_enemy(enemy_id)
	else:
		# Fallback to default enemy
		enemy_data = _get_default_enemy()
		enemy_id = "default_drone"

	if enemy_data.is_empty():
		print("ERROR: Enemy data not found!")
		enemy_data = _get_default_enemy()

	enemy_health = enemy_data.get("health", 10)
	enemy_max_health = enemy_health

	_update_combat_ui()
	_add_to_combat_log("[color=yellow]Combat begins![/color]")
	_add_to_combat_log("You encounter a " + enemy_data.get("name", "enemy") + "!")
	_set_player_turn()

func _get_default_enemy() -> Dictionary:
	return {
		"name": "Security Drone",
		"health": 15,
		"strength": 2,
		"defense": 1,
		"sprite": "🤖",
		"description": "A Prime Corp security drone."
	}

func _update_combat_ui() -> void:
	# Update player display
	var player_vbox = player_display.get_child(0)
	player_vbox.get_node("PlayerName").text = GameState.player_name

	var player_health_bar = player_vbox.get_node("PlayerHealthBar")
	player_health_bar.max_value = GameState.player_max_health
	player_health_bar.value = GameState.player_health

	player_vbox.get_node("PlayerHealthText").text = str(GameState.player_health) + " / " + str(GameState.player_max_health) + " HP"

	# Update enemy display
	var enemy_vbox = enemy_display.get_child(0)
	enemy_vbox.get_node("EnemySprite").text = enemy_data.get("sprite", "👾")
	enemy_vbox.get_node("EnemyName").text = enemy_data.get("name", "Enemy")

	var enemy_health_bar = enemy_vbox.get_node("EnemyHealthBar")
	enemy_health_bar.max_value = enemy_max_health
	enemy_health_bar.value = enemy_health

	enemy_vbox.get_node("EnemyHealthText").text = str(enemy_health) + " / " + str(enemy_max_health) + " HP"

func _add_to_combat_log(message: String) -> void:
	combat_log_label.text += "\n" + message
	# Auto-scroll happens automatically with scroll_following

func _set_player_turn() -> void:
	current_state = CombatState.PLAYER_TURN
	_enable_action_buttons(true)
	_add_to_combat_log("[color=green]Your turn![/color]")

func _set_enemy_turn() -> void:
	current_state = CombatState.ENEMY_TURN
	_enable_action_buttons(false)
	_add_to_combat_log("[color=red]Enemy's turn![/color]")
	await get_tree().create_timer(1.0).timeout
	_execute_enemy_action()

func _enable_action_buttons(enabled: bool) -> void:
	for button in action_buttons_container.get_children():
		if button is Button:
			button.disabled = not enabled

func _execute_enemy_action() -> void:
	var enemy_strength = enemy_data.get("strength", 1)
	var enemy_defense = enemy_data.get("defense", 0)

	# Calculate damage with randomness
	var base_damage = enemy_strength + randi() % 3
	var damage = max(1, base_damage)  # Minimum 1 damage

	_add_to_combat_log(enemy_data.get("name", "Enemy") + " attacks for [color=red]" + str(damage) + " damage[/color]!")

	# Apply damage
	GameState.modify_health(-damage)
	_update_combat_ui()

	# Check for player defeat
	await get_tree().create_timer(1.0).timeout

	if GameState.player_health <= 0:
		_end_combat(false)
	else:
		_set_player_turn()

func _player_attack() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	# Calculate damage based on Strength
	var base_damage = GameState.player_strength + randi() % 3 + 1
	var enemy_defense = enemy_data.get("defense", 0)
	var damage = max(1, base_damage - enemy_defense)

	_add_to_combat_log("You attack with [color=cyan]Strength[/color] for [color=red]" + str(damage) + " damage[/color]!")

	enemy_health -= damage
	_update_combat_ui()

	# Visual effect
	RenderEngine.shake_node(enemy_display, 15.0, 0.3)

	await get_tree().create_timer(1.0).timeout

	if enemy_health <= 0:
		_end_combat(true)
	else:
		_set_enemy_turn()

func _player_spell() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	# Calculate damage based on Spells (higher multiplier, ignores defense)
	var damage = GameState.player_spells * 2 + randi() % 4

	_add_to_combat_log("You cast a [color=magenta]spell[/color] for [color=red]" + str(damage) + " magic damage[/color]!")

	enemy_health -= damage
	_update_combat_ui()

	# Visual effect
	RenderEngine.flash_screen(Color(0.8, 0.3, 0.8), 0.2)
	RenderEngine.shake_node(enemy_display, 20.0, 0.4)

	await get_tree().create_timer(1.0).timeout

	if enemy_health <= 0:
		_end_combat(true)
	else:
		_set_enemy_turn()

func _player_use_item() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	# Get consumable items from inventory
	var consumable_items = []
	for item_id in GameState.inventory:
		var item_data = GameState.get_item(item_id)
		if item_data.get("type", "").to_lower() == "consumable":
			consumable_items.append({"id": item_id, "data": item_data})

	if consumable_items.is_empty():
		_add_to_combat_log("[color=yellow]No consumable items available![/color]")
		return

	# Show item selection
	_show_item_selection(consumable_items)

func _show_item_selection(items: Array) -> void:
	# Create item selection panel
	item_selection_panel = RenderEngine.create_panel(Vector2(400, 300))
	item_selection_panel.position = Vector2(440, 250)
	main_container.add_child(item_selection_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	item_selection_panel.add_child(vbox)

	var title = RenderEngine.create_label("Select Item:", 16, RenderEngine.current_theme["accent_color"])
	vbox.add_child(title)

	# Create button for each item
	for item_info in items:
		var item_id = item_info["id"]
		var item_data = item_info["data"]

		var item_button = RenderEngine.create_button(item_data.get("name", item_id), Vector2(350, 40))
		item_button.pressed.connect(_use_selected_item.bind(item_id, item_data))
		vbox.add_child(item_button)

	# Cancel button
	var cancel_button = RenderEngine.create_button("Cancel", Vector2(350, 40))
	cancel_button.pressed.connect(_cancel_item_selection)
	vbox.add_child(cancel_button)

func _use_selected_item(item_id: String, item_data: Dictionary) -> void:
	# Close item selection
	if item_selection_panel:
		item_selection_panel.queue_free()
		item_selection_panel = null

	# Apply item effects
	var item_name = item_data.get("name", item_id)
	_add_to_combat_log("You use [color=cyan]" + item_name + "[/color]!")

	if item_data.has("effects"):
		var effects = item_data["effects"]

		if effects.has("heal"):
			var heal_amount = effects["heal"]
			GameState.modify_health(heal_amount)
			_add_to_combat_log("Restored [color=green]" + str(heal_amount) + " HP[/color]!")

	# Remove item from inventory
	GameState.remove_item(item_id)

	_update_combat_ui()

	await get_tree().create_timer(1.0).timeout

	# Enemy turn
	_set_enemy_turn()

func _cancel_item_selection() -> void:
	if item_selection_panel:
		item_selection_panel.queue_free()
		item_selection_panel = null

func _player_flee() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	# Calculate flee chance based on Sense
	var flee_chance = 50 + GameState.player_sense * 10
	var roll = randi() % 100

	_add_to_combat_log("You attempt to flee using [color=cyan]Sense[/color]...")

	await get_tree().create_timer(0.5).timeout

	if roll < flee_chance:
		_add_to_combat_log("[color=green]You successfully fled from combat![/color]")
		await get_tree().create_timer(1.5).timeout
		_exit_combat()
	else:
		_add_to_combat_log("[color=red]Failed to flee![/color]")
		await get_tree().create_timer(1.0).timeout
		_set_enemy_turn()

func _end_combat(player_won: bool) -> void:
	current_state = CombatState.COMBAT_END
	_enable_action_buttons(false)

	if player_won:
		_add_to_combat_log("[color=green]Victory! You defeated " + enemy_data.get("name", "the enemy") + "![/color]")

		# Grant rewards
		if enemy_data.has("drops"):
			var drops = enemy_data["drops"]
			for item_id in drops:
				var item_data = GameState.get_item(item_id)
				GameState.add_item(item_id)
				_add_to_combat_log("Received: [color=yellow]" + item_data.get("name", item_id) + "[/color]")

		# Grant experience/stat increases (optional)
		if enemy_data.has("experience"):
			_add_to_combat_log("Gained experience!")

	else:
		_add_to_combat_log("[color=red]You have been defeated...[/color]")

		# Respawn logic - restore health and return to safe location
		GameState.player_health = GameState.player_max_health
		GameState.change_location("apartment")
		_add_to_combat_log("[color=yellow]You wake up back at your apartment...[/color]")

	await get_tree().create_timer(3.0).timeout
	_exit_combat()

func _exit_combat() -> void:
	print("Exiting combat...")

	# Clear combat flags
	GameState.story_flags.erase("current_enemy_id")
	GameState.set_flag("current_enemy", false)

	# Return to game world
	get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")

# Button signal handlers
func _on_attack_pressed() -> void:
	if current_state == CombatState.PLAYER_TURN:
		_player_attack()

func _on_spell_pressed() -> void:
	if current_state == CombatState.PLAYER_TURN:
		_player_spell()

func _on_item_pressed() -> void:
	if current_state == CombatState.PLAYER_TURN:
		_player_use_item()

func _on_flee_pressed() -> void:
	if current_state == CombatState.PLAYER_TURN:
		_player_flee()
