extends Node2D

## Combat system controller
## Manages turn-based Pokemon-style combat

enum CombatState {
	PLAYER_TURN,
	ENEMY_TURN,
	COMBAT_END
}

@onready var player_name_label = $CanvasLayer/CombatUI/PlayerArea/PlayerName
@onready var player_hp_bar = $CanvasLayer/CombatUI/PlayerArea/PlayerHP
@onready var enemy_name_label = $CanvasLayer/CombatUI/EnemyArea/EnemyName
@onready var enemy_hp_bar = $CanvasLayer/CombatUI/EnemyArea/EnemyHP
@onready var combat_log = $CanvasLayer/CombatUI/CombatLog
@onready var action_buttons = $CanvasLayer/CombatUI/ActionButtons

var current_state: CombatState = CombatState.PLAYER_TURN
var enemy_data: Dictionary = {}
var enemy_health: int = 0
var enemy_max_health: int = 0

func _ready() -> void:
	print("Combat scene loaded")
	_initialize_combat()

func _initialize_combat() -> void:
	# TODO: Load enemy data from parameter or game state
	enemy_data = _get_default_enemy()
	enemy_health = enemy_data.get("health", 10)
	enemy_max_health = enemy_health

	_update_combat_ui()
	_add_to_combat_log("Combat begins!")
	_set_player_turn()

func _get_default_enemy() -> Dictionary:
	# TODO: Load from actual game data
	return {
		"name": "Security Drone",
		"health": 15,
		"strength": 2,
		"defense": 1,
		"sprite": "🤖"
	}

func _update_combat_ui() -> void:
	player_name_label.text = GameState.player_name
	player_hp_bar.max_value = GameState.player_max_health
	player_hp_bar.value = GameState.player_health

	enemy_name_label.text = enemy_data.get("name", "Enemy")
	enemy_hp_bar.max_value = enemy_max_health
	enemy_hp_bar.value = enemy_health

func _add_to_combat_log(message: String) -> void:
	combat_log.text += "\n" + message
	# Auto-scroll to bottom
	await get_tree().create_timer(0.1).timeout
	combat_log.scroll_to_line(combat_log.get_line_count())

func _set_player_turn() -> void:
	current_state = CombatState.PLAYER_TURN
	_enable_action_buttons(true)
	_add_to_combat_log("Your turn!")

func _set_enemy_turn() -> void:
	current_state = CombatState.ENEMY_TURN
	_enable_action_buttons(false)
	_add_to_combat_log("Enemy's turn!")
	await get_tree().create_timer(1.0).timeout
	_execute_enemy_action()

func _enable_action_buttons(enabled: bool) -> void:
	for button in action_buttons.get_children():
		button.disabled = not enabled

func _execute_enemy_action() -> void:
	var damage = enemy_data.get("strength", 1) + randi() % 3
	_add_to_combat_log(enemy_data.get("name", "Enemy") + " attacks for " + str(damage) + " damage!")
	GameState.modify_health(-damage)
	_update_combat_ui()

	await get_tree().create_timer(1.0).timeout

	if GameState.player_health <= 0:
		_end_combat(false)
	else:
		_set_player_turn()

func _player_attack() -> void:
	var damage = GameState.player_strength + randi() % 3 + 1
	_add_to_combat_log("You attack for " + str(damage) + " damage!")
	enemy_health -= damage
	_update_combat_ui()

	await get_tree().create_timer(1.0).timeout

	if enemy_health <= 0:
		_end_combat(true)
	else:
		_set_enemy_turn()

func _player_spell() -> void:
	var damage = GameState.player_spells * 2 + randi() % 4
	_add_to_combat_log("You cast a spell for " + str(damage) + " damage!")
	enemy_health -= damage
	_update_combat_ui()

	await get_tree().create_timer(1.0).timeout

	if enemy_health <= 0:
		_end_combat(true)
	else:
		_set_enemy_turn()

func _player_use_item() -> void:
	# TODO: Implement item selection UI
	_add_to_combat_log("Item system not yet implemented!")
	await get_tree().create_timer(0.5).timeout
	# Stay on player turn

func _player_flee() -> void:
	var flee_chance = 50 + GameState.player_sense * 10
	var roll = randi() % 100

	if roll < flee_chance:
		_add_to_combat_log("You successfully fled from combat!")
		await get_tree().create_timer(1.0).timeout
		_exit_combat()
	else:
		_add_to_combat_log("Failed to flee!")
		await get_tree().create_timer(1.0).timeout
		_set_enemy_turn()

func _end_combat(player_won: bool) -> void:
	current_state = CombatState.COMBAT_END
	_enable_action_buttons(false)

	if player_won:
		_add_to_combat_log("Victory! You defeated " + enemy_data.get("name", "the enemy") + "!")
		# TODO: Grant rewards (XP, items, etc.)
	else:
		_add_to_combat_log("You have been defeated...")
		# TODO: Handle defeat (game over, sacrifice mechanic, etc.)

	await get_tree().create_timer(2.0).timeout
	_exit_combat()

func _exit_combat() -> void:
	print("Exiting combat...")
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
