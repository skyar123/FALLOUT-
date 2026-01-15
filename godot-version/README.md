# LICHCRAFT - Godot Version

> Native game engine implementation of LICHCRAFT

This directory contains the Godot Engine version of LICHCRAFT, providing a native implementation with improved performance, better mobile support, and access to Godot's powerful features.

## About Godot Engine

[Godot Engine](https://godotengine.org/) is a free and open-source 2D and 3D game engine with a focus on usability and flexibility. It provides:

- Cross-platform support (Windows, Mac, Linux, Android, iOS, HTML5)
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
- ⬜ Mobile touch controls optimization
- ⬜ Export configurations for mobile platforms

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

## Mobile Export

To export for mobile platforms:

### Android
1. Install Android SDK and configure in Editor Settings
2. Project → Export → Add → Android
3. Configure package name, icons, and permissions
4. Export APK or AAB

### iOS
1. Requires macOS with Xcode installed
2. Project → Export → Add → iOS
3. Configure bundle ID, icons, and signing
4. Export Xcode project

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
- **Debug → Deploy with Remote Debug** for mobile testing
- **Print statements**: Use `print()` for console output
- **Breakpoints**: Click line numbers in script editor
- **Remote Scene Tree**: View and edit running game

## Contributing

When adding features to the Godot version:

1. Keep parity with web version content
2. Follow GDScript style guide
3. Document public functions with comments
4. Test on both desktop and mobile resolutions
5. Update this README with new features

## Differences from Web Version

| Feature | Web Version | Godot Version |
|---------|-------------|---------------|
| Language | JavaScript | GDScript |
| Rendering | HTML/CSS | Godot 2D |
| Save System | localStorage | FileAccess |
| Performance | Browser-dependent | Native, optimized |
| Mobile | PWA | Native APK/IPA |
| Editor | Text editor | Godot IDE |

## Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot Community](https://godotengine.org/community)
- [Godot Asset Library](https://godotengine.org/asset-library/asset)

## License

Same as main project - free to use, modify, and distribute.

---

**Note**: This Godot version aims to provide a more performant, native alternative to the web version while maintaining the same story, mechanics, and soul of LICHCRAFT. 🏴⚧️💀
