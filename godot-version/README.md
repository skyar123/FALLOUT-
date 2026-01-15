# LICHCRAFT - Godot Version

> Native game engine implementation of LICHCRAFT

This directory contains the Godot Engine version of LICHCRAFT, providing a native desktop implementation with improved performance and access to Godot's powerful features.

## About Godot Engine

[Godot Engine](https://godotengine.org/) is a free and open-source 2D and 3D game engine with a focus on usability and flexibility. It provides:

- Cross-platform desktop support (Windows, Mac, Linux)
- Powerful scene system and node-based architecture
- GDScript (Python-like) scripting language
- Built-in animation, physics, and audio systems
- Visual editor with live editing
- Completely free and open source (MIT license)

## Project Structure

```
godot-version/
├── project.godot          # Main Godot project file
├── icon.svg               # Project icon
├── addons/                # Godot Asset Library plugins (see ASSET_LIBRARY_GUIDE.md)
│   ├── dialogue_manager/  # Dialogue Manager 3 (install via AssetLib)
│   ├── inventory_forge/   # Inventory Forge (install via AssetLib)
│   ├── nexus_quest_weaver/ # Quest tracking system (install via AssetLib)
│   ├── skelerealms/       # Open world RPG framework (install via AssetLib)
│   └── turn_based_combat/ # Combat system (install via AssetLib)
├── scenes/                # Scene files (.tscn)
│   ├── Main.tscn          # Main menu scene
│   ├── GameWorld.tscn     # Game exploration scene
│   └── CombatScene.tscn   # Combat scene
├── scripts/               # GDScript files (.gd)
│   ├── Main.gd            # Main menu controller
│   ├── GameState.gd       # Global game state (autoload)
│   ├── GameWorld.gd       # Game world controller
│   ├── CombatSystem.gd    # Combat system
│   └── DialogueSystem.gd  # Dialogue system
├── assets/                # Game assets
│   ├── sprites/           # Character and object sprites
│   ├── audio/             # Sound effects and music
│   └── fonts/             # Custom fonts
└── data/                  # Game data files
```

## Getting Started

### Prerequisites

1. Download and install [Godot Engine 4.3 or later](https://godotengine.org/download)
2. Godot 4.x is required for this project (uses Godot 4 syntax and features)

### Opening the Project

1. Launch Godot Engine
2. Click "Import" in the project manager
3. Navigate to the `godot-version` directory
4. Select the `project.godot` file
5. Click "Import & Edit"

### Running the Game

- Press **F5** to run the project
- Press **F6** to run the current scene
- Press **F8** to enable debugging
- Press **Escape** to stop the game

## 📦 Godot Asset Library Plugins

This project is designed to work with several high-quality Asset Library plugins to enhance gameplay systems.

### Recommended Plugins

The `addons/` directory is pre-configured for the following plugins:

1. **Dialogue Manager 3** - Advanced branching dialogue system
2. **Inventory Forge** - Modern inventory management (perfect for sacrifice mechanics)
3. **Nexus Quest Weaver** - Quest tracking system
4. **Skelerealms** - Open world RPG framework for exploration
5. **Turn Based Combat** - Pokemon-style combat system

### Installation

**See [ASSET_LIBRARY_GUIDE.md](ASSET_LIBRARY_GUIDE.md) for comprehensive installation instructions and integration notes.**

Quick start:
1. Open project in Godot
2. Click **AssetLib** tab
3. Search for and install each plugin
4. Enable in **Project → Project Settings → Plugins**

All recommended plugins are MIT or CC-BY licensed and free to use.

## Development Status

This Godot version is a work in progress. Current status:

### Implemented
- ✅ Project structure and configuration
- ✅ Basic scene architecture
- ✅ GameState system (player data, inventory, quests, save/load)
- ✅ Main menu with scene transitions
- ✅ Combat system foundation
- ✅ Dialogue system framework
- ✅ Game world exploration structure

### To Do
- ⬜ Character creation screen
- ⬜ Complete dialogue UI
- ⬜ Inventory screen
- ⬜ Quest log UI
- ⬜ Status/character screen
- ⬜ Import game data from web version
- ⬜ Add sprites and visual assets
- ⬜ Sound effects and music
- ⬜ Keyboard shortcuts and controls
- ⬜ Export configurations for desktop platforms

## Key Systems

### GameState (Global Singleton)

The GameState script is an autoload singleton, accessible from any script via `GameState`.

```gdscript
# Player management
GameState.modify_health(-5)
GameState.player_strength

# Inventory
GameState.add_item("health_pack")
GameState.has_item("ancient_tome")

# Quests
GameState.start_quest("quest_lichdom")
GameState.complete_quest("find_ash")

# Story flags
GameState.set_flag("knows_about_lichdom")
GameState.get_flag("met_raven")

# Location
GameState.change_location("underground_market")

# Save/Load
GameState.save_game()
GameState.load_game()
```

### Combat System

Turn-based Pokemon-style combat with:
- Player and enemy health tracking
- Attack, Spell, Item, and Flee actions
- Combat log with event history
- Damage calculations based on attributes
- Victory/defeat handling

### Dialogue System

Branching conversation system with:
- Tree-based dialogue structure
- Attribute and flag requirements
- Multiple choice options
- Effects system (flags, items, health, quests)
- NPC conversations

## Porting from Web Version

The web version (JavaScript) serves as the content reference. To port content:

1. **Game Data**: Convert `src/data/GameData.js` to Godot resources or JSON
2. **Locations**: Create location data files in `data/locations/`
3. **NPCs**: Create NPC data files in `data/npcs/`
4. **Dialogue**: Convert dialogue trees to Godot format
5. **Items**: Create item resources in `data/items/`

## Desktop Export

To export for desktop platforms:

### Windows
1. Project → Export → Add → Windows Desktop
2. Configure executable name and icon
3. Export EXE

### Linux
1. Project → Export → Add → Linux/X11
2. Configure executable name
3. Export binary

### macOS
1. Project → Export → Add → macOS
2. Configure bundle ID and icon
3. Export .app bundle

## Customization

### Adding New Scenes

1. Scene → New Scene
2. Build your scene with nodes
3. Attach a script (extends Node2D or Control)
4. Save in `scenes/` directory

### Adding New Scripts

1. Create new `.gd` file in `scripts/`
2. Start with `extends Node` or appropriate node type
3. Implement your logic
4. Attach to scene nodes as needed

### Game Data

Create JSON files or Godot Resources for game data:

```gdscript
# Example: Loading JSON data
var file = FileAccess.open("res://data/locations.json", FileAccess.READ)
var json = JSON.new()
json.parse(file.get_as_text())
var data = json.data
```

## Performance Tips

- Use `@onready` for node references (deferred initialization)
- Prefer signals over polling for event communication
- Use `queue_free()` instead of `free()` for safe node deletion
- Profile with Godot's built-in profiler (Debug → Profiler)

## Debugging

Enable debugging in the editor:
- **Print statements**: Use `print()` for console output
- **Breakpoints**: Click line numbers in script editor
- **Remote Scene Tree**: View and edit running game
- **Debug → Profiler** for performance monitoring

## Contributing

When adding features to the Godot version:

1. Keep parity with web version content
2. Follow GDScript style guide
3. Document public functions with comments
4. Test on desktop platforms (Windows, Mac, Linux)
5. Update this README with new features

## Differences from Web Version

| Feature | Web Version | Godot Version |
|---------|-------------|---------------|
| Language | JavaScript | GDScript |
| Rendering | HTML/CSS | Godot 2D |
| Save System | localStorage | FileAccess |
| Performance | Browser-dependent | Native, optimized |
| Platform | Browser (PWA) | Desktop (Windows/Mac/Linux) |
| Editor | Text editor | Godot IDE |

## Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot Community](https://godotengine.org/community)
- [Godot Asset Library](https://godotengine.org/asset-library/asset)

## License

Same as main project - free to use, modify, and distribute.

---

**Note**: This Godot version provides a native desktop alternative to the web version with better performance while maintaining the same story, mechanics, and soul of LICHCRAFT. 🏴⚧️💀
