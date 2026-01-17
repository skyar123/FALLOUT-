extends Control

## Inventory UI Controller
## Displays and manages player inventory with item details and interactions

@onready var inventory_grid = $Panel/MarginContainer/VBoxContainer/ScrollContainer/InventoryGrid
@onready var item_details_panel = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel
@onready var item_name_label = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/ItemName
@onready var item_type_label = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/ItemType
@onready var item_desc_label = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/ItemDescription
@onready var item_value_label = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/ItemValue
@onready var use_button = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/ButtonContainer/UseButton
@onready var drop_button = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/ButtonContainer/DropButton
@onready var close_button = $Panel/MarginContainer/VBoxContainer/HeaderContainer/CloseButton
@onready var category_tabs = $Panel/MarginContainer/VBoxContainer/CategoryContainer
@onready var equipped_label = $Panel/MarginContainer/VBoxContainer/ItemDetailsPanel/VBoxContainer/EquippedLabel

var selected_item_id: String = ""
var current_category: String = "all"

signal inventory_closed()
signal item_used(item_id: String)

func _ready() -> void:
	print("Inventory UI initialized")

	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	use_button.pressed.connect(_on_use_pressed)
	drop_button.pressed.connect(_on_drop_pressed)
	GameState.inventory_changed.connect(_refresh_inventory)

	# Create category tabs
	_setup_category_tabs()

	# Hide details panel initially
	item_details_panel.visible = false

	# Initial inventory display
	_refresh_inventory()

func _setup_category_tabs() -> void:
	var categories = ["All", "Consumable", "Equipment", "Quest", "Miscellaneous"]

	for category in categories:
		var button = RenderEngine.create_button(category, Vector2(120, 40))
		button.pressed.connect(_on_category_selected.bind(category.to_lower()))
		category_tabs.add_child(button)

func _refresh_inventory() -> void:
	# Clear existing items
	for child in inventory_grid.get_children():
		child.queue_free()

	var inventory_items = GameState.inventory

	if inventory_items.is_empty():
		var empty_label = RenderEngine.create_label("Your inventory is empty", 16, RenderEngine.current_theme["text_color"])
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inventory_grid.add_child(empty_label)
		item_details_panel.visible = false
		return

	# Display items
	for item_id in inventory_items:
		var item_data = GameState.get_item(item_id)
		if item_data.is_empty():
			continue

		# Filter by category
		if current_category != "all":
			var item_type = item_data.get("type", "miscellaneous").to_lower()
			if item_type != current_category:
				continue

		var item_button = _create_item_button(item_id, item_data)
		inventory_grid.add_child(item_button)

func _create_item_button(item_id: String, item_data: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(150, 120)

	# Create button content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)

	# Item sprite/icon
	var sprite_label = Label.new()
	sprite_label.text = item_data.get("sprite", "📦")
	sprite_label.add_theme_font_size_override("font_size", 48)
	sprite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sprite_label)

	# Item name
	var name_label = RenderEngine.create_label(item_data.get("name", "Unknown"), 12, RenderEngine.current_theme["text_color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Item type badge
	var type_label = RenderEngine.create_label("[" + item_data.get("type", "?") + "]", 9, RenderEngine.current_theme["accent_color"])
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(type_label)

	button.add_child(vbox)

	# Style button
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = RenderEngine.current_theme["primary_color"]
	normal_style.corner_radius_all = 8
	normal_style.border_width_all = 2
	normal_style.border_color = RenderEngine.current_theme["highlight_color"]
	button.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = RenderEngine.current_theme["highlight_color"]
	hover_style.corner_radius_all = 8
	hover_style.border_width_all = 2
	hover_style.border_color = RenderEngine.current_theme["accent_color"]
	button.add_theme_stylebox_override("hover", hover_style)

	# Connect button press
	button.pressed.connect(_on_item_selected.bind(item_id))

	return button

func _on_item_selected(item_id: String) -> void:
	selected_item_id = item_id
	var item_data = GameState.get_item(item_id)

	if item_data.is_empty():
		return

	# Show details panel
	item_details_panel.visible = true

	# Update details
	item_name_label.text = item_data.get("name", "Unknown Item")
	item_type_label.text = "Type: " + item_data.get("type", "Unknown")
	item_desc_label.text = item_data.get("description", "No description available.")
	item_value_label.text = "Value: " + str(item_data.get("value", 0)) + " credits"

	# Check if equipped
	var is_equipped = _is_item_equipped(item_id)
	equipped_label.visible = is_equipped
	if is_equipped:
		equipped_label.text = "[EQUIPPED]"

	# Enable/disable use button based on item type
	var item_type = item_data.get("type", "").to_lower()
	use_button.disabled = not (item_type == "consumable" or item_type == "equipment")

	if item_type == "consumable":
		use_button.text = "Use"
	elif item_type == "equipment":
		use_button.text = "Equip" if not is_equipped else "Unequip"
	else:
		use_button.text = "Use"

func _is_item_equipped(item_id: String) -> bool:
	# Check if item is in equipped slots (stored in story flags or separate equipped dict)
	return GameState.get_flag("equipped_" + item_id)

func _on_use_pressed() -> void:
	if selected_item_id.is_empty():
		return

	var item_data = GameState.get_item(selected_item_id)
	var item_type = item_data.get("type", "").to_lower()

	if item_type == "consumable":
		_use_consumable(selected_item_id, item_data)
	elif item_type == "equipment":
		_toggle_equipment(selected_item_id, item_data)

func _use_consumable(item_id: String, item_data: Dictionary) -> void:
	print("Using consumable: ", item_id)

	# Apply item effects
	if item_data.has("effects"):
		var effects = item_data["effects"]

		# Heal effect
		if effects.has("heal"):
			GameState.modify_health(effects["heal"])
			print("Healed for ", effects["heal"], " HP")

		# Stat boosts
		if effects.has("strength"):
			GameState.player_strength += effects["strength"]
		if effects.has("sense"):
			GameState.player_sense += effects["sense"]
		if effects.has("spells"):
			GameState.player_spells += effects["spells"]

	# Remove item from inventory
	GameState.remove_item(item_id)

	# Emit signal
	item_used.emit(item_id)

	# Clear selection and refresh
	selected_item_id = ""
	item_details_panel.visible = false
	_refresh_inventory()

func _toggle_equipment(item_id: String, item_data: Dictionary) -> void:
	var is_equipped = _is_item_equipped(item_id)

	if is_equipped:
		# Unequip
		GameState.set_flag("equipped_" + item_id, false)

		# Remove stat bonuses
		if item_data.has("effects"):
			var effects = item_data["effects"]
			if effects.has("strength"):
				GameState.player_strength -= effects["strength"]
			if effects.has("sense"):
				GameState.player_sense -= effects["sense"]
			if effects.has("spells"):
				GameState.player_spells -= effects["spells"]

		print("Unequipped: ", item_data.get("name", item_id))
	else:
		# Equip
		GameState.set_flag("equipped_" + item_id, true)

		# Apply stat bonuses
		if item_data.has("effects"):
			var effects = item_data["effects"]
			if effects.has("strength"):
				GameState.player_strength += effects["strength"]
			if effects.has("sense"):
				GameState.player_sense += effects["sense"]
			if effects.has("spells"):
				GameState.player_spells += effects["spells"]

		print("Equipped: ", item_data.get("name", item_id))

	# Refresh display
	_on_item_selected(item_id)
	item_used.emit(item_id)

func _on_drop_pressed() -> void:
	if selected_item_id.is_empty():
		return

	var item_data = GameState.get_item(selected_item_id)
	var item_name = item_data.get("name", selected_item_id)

	# Confirm drop (you could add a confirmation dialog here)
	print("Dropping item: ", item_name)

	# Unequip if equipped
	if _is_item_equipped(selected_item_id):
		_toggle_equipment(selected_item_id, item_data)

	# Remove from inventory
	GameState.remove_item(selected_item_id)

	# Clear selection and refresh
	selected_item_id = ""
	item_details_panel.visible = false
	_refresh_inventory()

func _on_category_selected(category: String) -> void:
	current_category = category
	_refresh_inventory()

func _on_close_pressed() -> void:
	inventory_closed.emit()
	queue_free()
