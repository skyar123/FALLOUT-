# Turn Based Combat (3D)

**Author**: TheRealFame
**Version**: 0.5 (Godot 4.1)
**License**: CC-BY-4.0

## Installation

1. Open project in Godot Engine
2. Click **AssetLib** tab
3. Search for "Turn Based Combat 3D"
4. Click Download → Install
5. Enable in **Project → Project Settings → Plugins**

## Features

- Turn-based combat system
- Action queue management
- Turn order handling
- Combat state machine
- Extensible framework

## Integration with LICHCRAFT

### Adaptation Needed
- Convert from 3D to 2D/UI implementation
- Integrate with existing `CombatSystem.gd`
- Implement Pokemon-style mechanics:
  - Attack
  - Spell
  - Item
  - Flee

### Combat Flow
1. Player turn: choose action
2. Execute action with attribute-based calculations
3. Enemy turn: AI decision
4. Repeat until victory or defeat

### Attributes
- Strength: Physical attacks
- Sense: Flee chance
- Spells: Magic damage

## Attribution Required

CC-BY-4.0 license requires attribution in your game credits.

See [../../ASSET_LIBRARY_GUIDE.md](../../ASSET_LIBRARY_GUIDE.md) for full details.
