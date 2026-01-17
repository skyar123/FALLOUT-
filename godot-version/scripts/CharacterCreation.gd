extends Control

## Character Creation System
## Guides player through creating their character

signal character_created(character_data: Dictionary)

var current_step: int = 0
var character_data: Dictionary = {
	"name": "",
	"identity": "",
	"politics": "",
	"hobby": "",
	"job": "",
	"subscription": "",
	"magic_source": "",
	"strength": 3,
	"sense": 2,
	"spells": 1
}

@onready var render_engine = preload("res://scripts/RenderEngine.gd").new()
@onready var content_container = $MarginContainer/VBoxContainer/ContentContainer
@onready var button_container = $MarginContainer/VBoxContainer/ButtonContainer
@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var progress_label = $MarginContainer/VBoxContainer/ProgressLabel

func _ready() -> void:
	add_child(render_engine)
	display_current_step()

func display_current_step() -> void:
	# Clear previous content
	for child in content_container.get_children():
		child.queue_free()
	for child in button_container.get_children():
		child.queue_free()

	var creation_steps = GameState.character_creation
	if current_step >= creation_steps.size():
		_complete_character_creation()
		return

	var step = creation_steps[current_step]

	# Update progress
	progress_label.text = "Step %d of %d" % [current_step + 1, creation_steps.size()]

	# Update title
	title_label.text = step.get("prompt", "Character Creation")

	# Handle different step types
	match step.get("type"):
		"text_input":
			_create_text_input(step)
		"choice":
			_create_choice_buttons(step)
		"attribute_assignment":
			_create_attribute_assignment(step)

func _create_text_input(step: Dictionary) -> void:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	content_container.add_child(vbox)

	# Instruction label
	var instruction = render_engine.create_label(step.get("prompt", ""), 18)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instruction)

	# Text input
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = step.get("placeholder", "Enter text...")
	line_edit.custom_minimum_size = Vector2(400, 50)
	line_edit.add_theme_font_size_override("font_size", 20)
	line_edit.text = character_data.get(step.get("stores_in", ""), "")
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(line_edit)

	# Continue button
	var continue_btn = render_engine.create_button("Continue")
	continue_btn.pressed.connect(func():
		var field_name = step.get("stores_in", "")
		character_data[field_name] = line_edit.text if line_edit.text != "" else step.get("placeholder", "Wanderer")
		_next_step()
	)
	button_container.add_child(continue_btn)

func _create_choice_buttons(step: Dictionary) -> void:
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content_container.add_child(grid)

	var choices = step.get("choices", [])
	var field_name = step.get("stores_in", "")

	for choice in choices:
		var button = render_engine.create_button(choice, Vector2(350, 80))
		button.pressed.connect(func():
			character_data[field_name] = choice
			_next_step()
		)
		grid.add_child(button)

func _create_attribute_assignment(step: Dictionary) -> void:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	content_container.add_child(vbox)

	# Instruction
	var instruction = render_engine.create_label(
		"Assign your attributes: Drag to rearrange (highest to lowest)",
		16
	)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instruction)

	# Available points to assign
	var points = step.get("points", [3, 2, 1])
	var attributes = step.get("attributes", ["strength", "sense", "spells"])

	# Create attribute display
	for i in range(attributes.size()):
		var attr_name = attributes[i]
		var attr_panel = render_engine.create_panel(Vector2(500, 100))
		var hbox = HBoxContainer.new()
		attr_panel.add_child(hbox)

		# Attribute name
		var name_label = render_engine.create_label(
			attr_name.capitalize() + ":",
			20,
			render_engine.current_theme["accent_color"]
		)
		name_label.custom_minimum_size = Vector2(200, 0)
		hbox.add_child(name_label)

		# Value display
		var value_label = render_engine.create_label(
			str(points[i]),
			32,
			render_engine.current_theme["text_color"]
		)
		value_label.custom_minimum_size = Vector2(100, 0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(value_label)

		# Description
		var desc_label = render_engine.create_label(
			_get_attribute_description(attr_name),
			12
		)
		hbox.add_child(desc_label)

		vbox.add_child(attr_panel)

		# Store the values
		character_data[attr_name] = points[i]

	# Continue button
	var continue_btn = render_engine.create_button("Confirm Attributes")
	continue_btn.pressed.connect(func():
		_next_step()
	)
	button_container.add_child(continue_btn)

func _get_attribute_description(attr: String) -> String:
	match attr:
		"strength":
			return "Physical combat power"
		"sense":
			return "Perception and social skills"
		"spells":
			return "Magical ability"
		_:
			return ""

func _next_step() -> void:
	current_step += 1
	display_current_step()

func _previous_step() -> void:
	if current_step > 0:
		current_step -= 1
		display_current_step()

func _complete_character_creation() -> void:
	# Clear the screen
	for child in content_container.get_children():
		child.queue_free()
	for child in button_container.get_children():
		child.queue_free()

	title_label.text = "Character Created!"

	# Display summary
	var summary_vbox = VBoxContainer.new()
	summary_vbox.add_theme_constant_override("separation", 15)
	content_container.add_child(summary_vbox)

	var summary_text = """
	Name: %s
	Identity: %s
	Politics: %s
	Hobby: %s
	Job: %s
	Subscription: %s
	Magic Source: %s

	Attributes:
	Strength: %d
	Sense: %d
	Spells: %d
	""" % [
		character_data.get("name", "Wanderer"),
		character_data.get("identity", ""),
		character_data.get("politics", ""),
		character_data.get("hobby", ""),
		character_data.get("job", ""),
		character_data.get("subscription", ""),
		character_data.get("magic_source", ""),
		character_data.get("strength", 1),
		character_data.get("sense", 1),
		character_data.get("spells", 1)
	]

	var summary_label = render_engine.create_label(summary_text, 14)
	summary_vbox.add_child(summary_label)

	# Start game button
	var start_btn = render_engine.create_button("Begin Your Journey", Vector2(300, 60))
	start_btn.pressed.connect(func():
		GameState.create_character(character_data)
		GameState.change_location("home")
		# Give starter items
		for item_id in GameState.game_data.get("starter_items", []):
			GameState.add_item(item_id)
		# Load the game world
		get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")
	)
	button_container.add_child(start_btn)

	character_created.emit(character_data)
