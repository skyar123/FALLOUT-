extends Node

## Graphics and Visual Rendering System
## Handles all visual display elements, sprites, and rendering for LICHCRAFT

signal sprite_rendered(sprite_data: Dictionary)
signal animation_complete(animation_name: String)

# Current theme settings
var current_theme: Dictionary = {
	"background_color": Color("#1a1a2e"),
	"primary_color": Color("#16213e"),
	"accent_color": Color("#e94560"),
	"text_color": Color("#f0f0f0"),
	"highlight_color": Color("#0f3460")
}

# Sprite cache for performance
var sprite_cache: Dictionary = {}

func _ready() -> void:
	print("RenderEngine initialized")

## Render a sprite with the given emoji/icon
func render_sprite(sprite_text: String, size: int = 64) -> TextureRect:
	var texture_rect = TextureRect.new()
	var label = Label.new()
	label.text = sprite_text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Create a texture from the label
	texture_rect.custom_minimum_size = Vector2(size, size)
	texture_rect.add_child(label)

	return texture_rect

## Create a styled panel for UI elements
func create_panel(size: Vector2, color: Color = current_theme["primary_color"]) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = size

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.border_width_all = 2
	style_box.border_color = current_theme["accent_color"]

	panel.add_theme_stylebox_override("panel", style_box)

	return panel

## Create styled text label
func create_label(text: String, size: int = 16, color: Color = current_theme["text_color"]) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

## Create a styled button
func create_button(text: String, size: Vector2 = Vector2(200, 50)) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size

	# Normal state
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = current_theme["highlight_color"]
	normal_style.corner_radius_all = 6
	normal_style.border_width_all = 2
	normal_style.border_color = current_theme["accent_color"]
	button.add_theme_stylebox_override("normal", normal_style)

	# Hover state
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = current_theme["accent_color"]
	hover_style.corner_radius_all = 6
	hover_style.border_width_all = 2
	hover_style.border_color = current_theme["text_color"]
	button.add_theme_stylebox_override("hover", hover_style)

	# Pressed state
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = current_theme["primary_color"]
	pressed_style.corner_radius_all = 6
	pressed_style.border_width_all = 2
	pressed_style.border_color = current_theme["accent_color"]
	button.add_theme_stylebox_override("pressed", pressed_style)

	return button

## Create a location display card
func create_location_card(location_data: Dictionary) -> PanelContainer:
	var panel = create_panel(Vector2(600, 300))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Sprite
	var sprite_label = Label.new()
	sprite_label.text = location_data.get("sprite", "📍")
	sprite_label.add_theme_font_size_override("font_size", 72)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Name
	var name_label = create_label(location_data.get("name", "Unknown"), 24, current_theme["accent_color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Description
	var desc_label = create_label(location_data.get("description", ""), 14)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	return panel

## Create an NPC display card
func create_npc_card(npc_data: Dictionary) -> PanelContainer:
	var panel = create_panel(Vector2(400, 200))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Sprite
	var sprite_label = Label.new()
	sprite_label.text = npc_data.get("sprite", "👤")
	sprite_label.add_theme_font_size_override("font_size", 64)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Name and title
	var name_label = create_label(npc_data.get("name", "Unknown"), 20, current_theme["accent_color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	if npc_data.has("title"):
		var title_label = create_label(npc_data["title"], 12, current_theme["highlight_color"])
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title_label)

	# Description
	if npc_data.has("description"):
		var desc_label = create_label(npc_data["description"], 11)
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(desc_label)

	return panel

## Create an item display card
func create_item_card(item_data: Dictionary) -> PanelContainer:
	var panel = create_panel(Vector2(300, 150))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)

	# Name
	var name_label = create_label(item_data.get("name", "Unknown Item"), 16, current_theme["accent_color"])
	vbox.add_child(name_label)

	# Type
	if item_data.has("type"):
		var type_label = create_label("[" + item_data["type"] + "]", 12, current_theme["highlight_color"])
		vbox.add_child(type_label)

	# Description
	if item_data.has("description"):
		var desc_label = create_label(item_data["description"], 11)
		vbox.add_child(desc_label)

	# Value
	if item_data.has("value"):
		var value_label = create_label("Value: " + str(item_data["value"]) + " credits", 10)
		vbox.add_child(value_label)

	return panel

## Create enemy display for combat
func create_enemy_display(enemy_data: Dictionary) -> PanelContainer:
	var panel = create_panel(Vector2(350, 250))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Sprite
	var sprite_label = Label.new()
	sprite_label.text = enemy_data.get("sprite", "👾")
	sprite_label.add_theme_font_size_override("font_size", 96)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Name
	var name_label = create_label(enemy_data.get("name", "Enemy"), 22, current_theme["accent_color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Description
	if enemy_data.has("description"):
		var desc_label = create_label(enemy_data["description"], 12)
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(desc_label)

	return panel

## Create a health bar
func create_health_bar(current_hp: int, max_hp: int, width: int = 200) -> ProgressBar:
	var health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(width, 30)
	health_bar.value = (float(current_hp) / float(max_hp)) * 100.0
	health_bar.show_percentage = false

	# Style the health bar
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color("#e94560")  # Red
	health_bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color("#1a1a2e")  # Dark background
	health_bar.add_theme_stylebox_override("background", bg_style)

	return health_bar

## Create dialogue box
func create_dialogue_box(text: String, speaker: String = "") -> PanelContainer:
	var panel = create_panel(Vector2(700, 200))
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Speaker name
	if speaker != "":
		var speaker_label = create_label(speaker, 18, current_theme["accent_color"])
		speaker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		vbox.add_child(speaker_label)

	# Dialogue text
	var text_label = create_label(text, 14)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(text_label)

	return panel

## Apply theme to node
func apply_theme(node: Control) -> void:
	if node is Panel or node is PanelContainer:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = current_theme["primary_color"]
		node.add_theme_stylebox_override("panel", style_box)

## Create a glowing effect animation
func create_glow_effect(node: Control, duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate:a", 0.5, duration / 2)
	tween.tween_property(node, "modulate:a", 1.0, duration / 2)

## Flash screen effect
func flash_screen(color: Color = Color.WHITE, duration: float = 0.2) -> void:
	# Implementation would depend on having a ColorRect overlay
	print("Screen flash: ", color)
	animation_complete.emit("flash_screen")

## Shake effect
func shake_node(node: Control, intensity: float = 10.0, duration: float = 0.3) -> void:
	var original_pos = node.position
	var tween = create_tween()

	for i in range(10):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(node, "position", original_pos + offset, duration / 10)

	tween.tween_property(node, "position", original_pos, duration / 10)
	tween.finished.connect(func(): animation_complete.emit("shake"))
