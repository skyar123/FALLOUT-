extends Node

## Dialogue system
## Manages branching conversations and dialogue trees

signal dialogue_started(npc_id: String)
signal dialogue_ended()
signal choice_made(choice_id: String)

var current_dialogue_tree: Dictionary = {}
var current_node: String = ""
var current_npc: String = ""

func start_dialogue(npc_id: String, dialogue_tree_id: String) -> void:
	current_npc = npc_id
	current_dialogue_tree = _load_dialogue_tree(dialogue_tree_id)
	current_node = "greeting"
	dialogue_started.emit(npc_id)
	print("Started dialogue with: ", npc_id)

func _load_dialogue_tree(tree_id: String) -> Dictionary:
	# TODO: Load from actual game data
	# For now, return a sample dialogue tree
	return {
		"greeting": {
			"text": "Hello, wanderer. What brings you here?",
			"choices": [
				{"text": "Just looking around.", "next": "casual"},
				{"text": "I need information.", "next": "information"},
				{"text": "Goodbye.", "action": "end"}
			]
		},
		"casual": {
			"text": "Aren't we all? These days, just surviving is an act of rebellion.",
			"choices": [
				{"text": "Tell me about yourself.", "next": "about"},
				{"text": "I should go.", "action": "end"}
			]
		},
		"information": {
			"text": "Information has a price. What do you need to know?",
			"requires": {"flag": "met_contact"},
			"choices": [
				{"text": "About the ritual...", "next": "ritual_info"},
				{"text": "Never mind.", "next": "greeting"}
			]
		}
	}

func get_current_text() -> String:
	if current_dialogue_tree.has(current_node):
		return current_dialogue_tree[current_node].get("text", "...")
	return "..."

func get_current_choices() -> Array:
	if current_dialogue_tree.has(current_node):
		var choices = current_dialogue_tree[current_node].get("choices", [])
		return _filter_available_choices(choices)
	return []

func _filter_available_choices(choices: Array) -> Array:
	var available = []
	for choice in choices:
		if _check_requirements(choice.get("requires", {})):
			available.append(choice)
	return available

func _check_requirements(requirements: Dictionary) -> bool:
	# Check attribute requirements
	if requirements.has("strength"):
		if GameState.player_strength < requirements["strength"]:
			return false
	if requirements.has("sense"):
		if GameState.player_sense < requirements["sense"]:
			return false
	if requirements.has("spells"):
		if GameState.player_spells < requirements["spells"]:
			return false

	# Check flag requirements
	if requirements.has("flag"):
		if not GameState.get_flag(requirements["flag"]):
			return false

	# Check item requirements
	if requirements.has("item"):
		if not GameState.has_item(requirements["item"]):
			return false

	return true

func make_choice(choice_index: int) -> void:
	var choices = get_current_choices()
	if choice_index < 0 or choice_index >= choices.size():
		print("Invalid choice index: ", choice_index)
		return

	var choice = choices[choice_index]
	choice_made.emit(choice.get("text", ""))

	# Execute choice action
	if choice.has("action"):
		_execute_action(choice["action"])

	# Move to next node
	if choice.has("next"):
		current_node = choice["next"]

	# Execute any effects
	if choice.has("effects"):
		_apply_effects(choice["effects"])

func _execute_action(action: String) -> void:
	match action:
		"end":
			end_dialogue()
		"combat":
			# TODO: Start combat
			end_dialogue()
		"give_item":
			# TODO: Give item to player
			pass
		_:
			print("Unknown action: ", action)

func _apply_effects(effects: Dictionary) -> void:
	# Apply various effects from dialogue choices
	if effects.has("set_flag"):
		GameState.set_flag(effects["set_flag"])

	if effects.has("add_item"):
		GameState.add_item(effects["add_item"])

	if effects.has("modify_health"):
		GameState.modify_health(effects["modify_health"])

	if effects.has("start_quest"):
		GameState.start_quest(effects["start_quest"])

func end_dialogue() -> void:
	current_dialogue_tree = {}
	current_node = ""
	current_npc = ""
	dialogue_ended.emit()
	print("Dialogue ended")
