extends Control

## Quest Log UI Controller
## Displays active and completed quests with progress tracking

@onready var quest_tabs = $Panel/MarginContainer/VBoxContainer/TabContainer
@onready var active_quests_list = $Panel/MarginContainer/VBoxContainer/TabContainer/Active/ScrollContainer/QuestList
@onready var completed_quests_list = $Panel/MarginContainer/VBoxContainer/TabContainer/Completed/ScrollContainer/QuestList
@onready var quest_details_panel = $Panel/MarginContainer/VBoxContainer/QuestDetailsPanel
@onready var quest_title_label = $Panel/MarginContainer/VBoxContainer/QuestDetailsPanel/VBoxContainer/QuestTitle
@onready var quest_desc_label = $Panel/MarginContainer/VBoxContainer/QuestDetailsPanel/VBoxContainer/QuestDescription
@onready var quest_objectives_container = $Panel/MarginContainer/VBoxContainer/QuestDetailsPanel/VBoxContainer/ObjectivesContainer
@ontml:parameter name="content">@onready var quest_rewards_label = $Panel/MarginContainer/VBoxContainer/QuestDetailsPanel/VBoxContainer/QuestRewards
@onready var close_button = $Panel/MarginContainer/VBoxContainer/HeaderContainer/CloseButton

var selected_quest_id: String = ""

signal quest_log_closed()

func _ready() -> void:
	print("Quest Log UI initialized")

	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	GameState.quest_updated.connect(_on_quest_updated)

	# Hide details panel initially
	quest_details_panel.visible = false

	# Display quests
	_refresh_quest_lists()

func _refresh_quest_lists() -> void:
	_display_active_quests()
	_display_completed_quests()

func _display_active_quests() -> void:
	# Clear existing
	for child in active_quests_list.get_children():
		child.queue_free()

	var active_quests = GameState.active_quests

	if active_quests.is_empty():
		var empty_label = RenderEngine.create_label("No active quests", 14, RenderEngine.current_theme["text_color"])
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		active_quests_list.add_child(empty_label)
		return

	# Display each active quest
	for quest_id in active_quests:
		var quest_data = GameState.get_quest(quest_id)
		if quest_data.is_empty():
			continue

		var quest_button = _create_quest_button(quest_id, quest_data, false)
		active_quests_list.add_child(quest_button)

	# Highlight main lichdom quest if active
	if GameState.is_quest_active("main_lichdom_quest"):
		var main_quest_label = RenderEngine.create_label(">>> MAIN QUEST: Path to Lichdom <<<", 16, RenderEngine.current_theme["accent_color"])
		main_quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		active_quests_list.add_child(main_quest_label)
		active_quests_list.move_child(main_quest_label, 0)

func _display_completed_quests() -> void:
	# Clear existing
	for child in completed_quests_list.get_children():
		child.queue_free()

	var completed_quests = GameState.completed_quests

	if completed_quests.is_empty():
		var empty_label = RenderEngine.create_label("No completed quests yet", 14, RenderEngine.current_theme["text_color"])
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		completed_quests_list.add_child(empty_label)
		return

	# Display each completed quest
	for quest_id in completed_quests:
		var quest_data = GameState.get_quest(quest_id)
		if quest_data.is_empty():
			continue

		var quest_button = _create_quest_button(quest_id, quest_data, true)
		completed_quests_list.add_child(quest_button)

func _create_quest_button(quest_id: String, quest_data: Dictionary, is_completed: bool) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 80)

	# Create button content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)

	# Quest name
	var name_label = RenderEngine.create_label(
		quest_data.get("name", "Unknown Quest"),
		14,
		RenderEngine.current_theme["accent_color"] if not is_completed else RenderEngine.current_theme["text_color"]
	)
	vbox.add_child(name_label)

	# Quest progress/status
	if not is_completed:
		var progress_text = _get_quest_progress_text(quest_id, quest_data)
		var progress_label = RenderEngine.create_label(progress_text, 11, RenderEngine.current_theme["highlight_color"])
		vbox.add_child(progress_label)
	else:
		var completed_label = RenderEngine.create_label("[COMPLETED]", 11, Color(0.3, 0.8, 0.3))
		vbox.add_child(completed_label)

	button.add_child(vbox)

	# Style button
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = RenderEngine.current_theme["primary_color"]
	normal_style.corner_radius_all = 6
	normal_style.border_width_all = 1
	normal_style.border_color = RenderEngine.current_theme["highlight_color"]
	button.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = RenderEngine.current_theme["highlight_color"]
	hover_style.corner_radius_all = 6
	hover_style.border_width_all = 2
	hover_style.border_color = RenderEngine.current_theme["accent_color"]
	button.add_theme_stylebox_override("hover", hover_style)

	# Connect button press
	button.pressed.connect(_on_quest_selected.bind(quest_id))

	return button

func _get_quest_progress_text(quest_id: String, quest_data: Dictionary) -> String:
	# Check for lichdom quest components
	if quest_id == "main_lichdom_quest":
		var components_found = 0
		if GameState.has_item("ancient_grimoire"):
			components_found += 1
		if GameState.has_item("phylactery"):
			components_found += 1
		if GameState.has_item("ritual_components"):
			components_found += 1

		return "Components: " + str(components_found) + "/3"

	# Check for objectives
	if quest_data.has("objectives"):
		var objectives = quest_data["objectives"]
		var completed_count = 0
		var total_count = objectives.size()

		for objective in objectives:
			if objective.has("requiredFlag"):
				if GameState.get_flag(objective["requiredFlag"]):
					completed_count += 1
			elif objective.has("requiredItem"):
				if GameState.has_item(objective["requiredItem"]):
					completed_count += 1

		return "Progress: " + str(completed_count) + "/" + str(total_count)

	return "In Progress"

func _on_quest_selected(quest_id: String) -> void:
	selected_quest_id = quest_id
	var quest_data = GameState.get_quest(quest_id)

	if quest_data.is_empty():
		return

	# Show details panel
	quest_details_panel.visible = true

	# Update quest title
	quest_title_label.text = quest_data.get("name", "Unknown Quest")

	# Update description
	quest_desc_label.text = quest_data.get("description", "No description available.")

	# Clear and update objectives
	for child in quest_objectives_container.get_children():
		child.queue_free()

	var objectives_title = RenderEngine.create_label("Objectives:", 14, RenderEngine.current_theme["accent_color"])
	quest_objectives_container.add_child(objectives_title)

	if quest_data.has("objectives"):
		for objective in quest_data["objectives"]:
			var obj_text = objective.get("text", "Unknown objective")
			var is_completed = _is_objective_completed(objective)

			var checkbox = "☑" if is_completed else "☐"
			var obj_label = RenderEngine.create_label(
				checkbox + " " + obj_text,
				12,
				Color(0.3, 0.8, 0.3) if is_completed else RenderEngine.current_theme["text_color"]
			)
			quest_objectives_container.add_child(obj_label)
	else:
		var no_obj_label = RenderEngine.create_label("No specific objectives", 12, RenderEngine.current_theme["text_color"])
		quest_objectives_container.add_child(no_obj_label)

	# Update rewards
	if quest_data.has("rewards"):
		var rewards = quest_data["rewards"]
		var reward_text = "Rewards: "
		var reward_parts = []

		if rewards.has("items"):
			for item in rewards["items"]:
				var item_data = GameState.get_item(item)
				reward_parts.append(item_data.get("name", item))

		if rewards.has("flags"):
			reward_parts.append("Story Progress")

		quest_rewards_label.text = reward_text + ", ".join(reward_parts)
		quest_rewards_label.visible = true
	else:
		quest_rewards_label.visible = false

func _is_objective_completed(objective: Dictionary) -> bool:
	if objective.has("requiredFlag"):
		return GameState.get_flag(objective["requiredFlag"])
	elif objective.has("requiredItem"):
		return GameState.has_item(objective["requiredItem"])
	return false

func _on_quest_updated(quest_id: String) -> void:
	_refresh_quest_lists()

	# Refresh details if currently viewing this quest
	if selected_quest_id == quest_id:
		_on_quest_selected(quest_id)

func _on_close_pressed() -> void:
	quest_log_closed.emit()
	queue_free()
