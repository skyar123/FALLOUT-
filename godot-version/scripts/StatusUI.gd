extends Control

## Status/Character Screen UI Controller
## Displays player character information, stats, and current status

@onready var player_name_label = $Panel/MarginContainer/VBoxContainer/CharacterInfo/NameLabel
@onready var health_bar = $Panel/MarginContainer/VBoxContainer/CharacterInfo/HealthContainer/HealthBar
@onready var health_text = $Panel/MarginContainer/VBoxContainer/CharacterInfo/HealthContainer/HealthText
@onready var identity_label = $Panel/MarginContainer/VBoxContainer/CharacterInfo/IdentityLabel
@onready var location_label = $Panel/MarginContainer/VBoxContainer/CharacterInfo/LocationLabel

@onready var strength_label = $Panel/MarginContainer/VBoxContainer/StatsPanel/StatsGrid/StrengthValue
@onready var sense_label = $Panel/MarginContainer/VBoxContainer/StatsPanel/StatsGrid/SenseValue
@onready var spells_label = $Panel/MarginContainer/VBoxContainer/StatsPanel/StatsGrid/SpellsValue

@onready var politics_label = $Panel/MarginContainer/VBoxContainer/BackgroundPanel/BackgroundGrid/PoliticsValue
@onready var hobby_label = $Panel/MarginContainer/VBoxContainer/BackgroundPanel/BackgroundGrid/HobbyValue
@onready var job_label = $Panel/MarginContainer/VBoxContainer/BackgroundPanel/BackgroundGrid/JobValue
@onready var subscription_label = $Panel/MarginContainer/VBoxContainer/BackgroundPanel/BackgroundGrid/SubscriptionValue
@onready var magic_source_label = $Panel/MarginContainer/VBoxContainer/BackgroundPanel/BackgroundGrid/MagicSourceValue

@onready var close_button = $Panel/MarginContainer/VBoxContainer/HeaderContainer/CloseButton

signal status_closed()

func _ready() -> void:
	print("Status UI initialized")

	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	GameState.health_changed.connect(_on_health_changed)
	GameState.location_changed.connect(_on_location_changed)

	# Initial display
	_update_all_stats()

func _update_all_stats() -> void:
	_update_character_info()
	_update_stats()
	_update_background()

func _update_character_info() -> void:
	# Player name with fancy formatting
	player_name_label.text = GameState.player_name
	player_name_label.add_theme_font_size_override("font_size", 28)
	player_name_label.add_theme_color_override("font_color", RenderEngine.current_theme["accent_color"])

	# Health bar
	health_bar.max_value = GameState.player_max_health
	health_bar.value = GameState.player_health
	health_text.text = str(GameState.player_health) + " / " + str(GameState.player_max_health) + " HP"

	# Update health bar color based on percentage
	var health_percent = float(GameState.player_health) / float(GameState.player_max_health)
	var fill_style = StyleBoxFlat.new()

	if health_percent > 0.6:
		fill_style.bg_color = Color(0.2, 0.8, 0.2)  # Green
	elif health_percent > 0.3:
		fill_style.bg_color = Color(0.9, 0.7, 0.2)  # Yellow
	else:
		fill_style.bg_color = Color(0.9, 0.2, 0.2)  # Red

	health_bar.add_theme_stylebox_override("fill", fill_style)

	# Identity
	var identity_text = GameState.player_identity
	if identity_text.is_empty():
		identity_text = "Unknown"
	identity_label.text = "Identity: " + identity_text

	# Location
	var location_data = GameState.get_location(GameState.current_location)
	var location_name = location_data.get("name", "Unknown Location")
	location_label.text = "Current Location: " + location_name

func _update_stats() -> void:
	# Primary attributes
	strength_label.text = str(GameState.player_strength)
	sense_label.text = str(GameState.player_sense)
	spells_label.text = str(GameState.player_spells)

	# Color code stats
	_color_stat_label(strength_label, GameState.player_strength)
	_color_stat_label(sense_label, GameState.player_sense)
	_color_stat_label(spells_label, GameState.player_spells)

func _color_stat_label(label: Label, value: int) -> void:
	if value >= 5:
		label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2))  # Green
	elif value >= 3:
		label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))  # Yellow
	else:
		label.add_theme_color_override("font_color", RenderEngine.current_theme["text_color"])

func _update_background() -> void:
	# Character creation choices
	politics_label.text = GameState.player_politics if not GameState.player_politics.is_empty() else "Unknown"
	hobby_label.text = GameState.player_hobby if not GameState.player_hobby.is_empty() else "Unknown"
	job_label.text = GameState.player_job if not GameState.player_job.is_empty() else "Unknown"
	subscription_label.text = GameState.player_subscription if not GameState.player_subscription.is_empty() else "Unknown"
	magic_source_label.text = GameState.player_magic_source if not GameState.player_magic_source.is_empty() else "Unknown"

func _on_health_changed(new_health: int, max_health: int) -> void:
	_update_character_info()

func _on_location_changed(new_location: String) -> void:
	_update_character_info()

func _on_close_pressed() -> void:
	status_closed.emit()
	queue_free()
