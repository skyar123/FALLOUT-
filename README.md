# LICHCRAFT 🏴

> A tale of transformation in the age of Prime

## Overview

LICHCRAFT is a Fallout-inspired mobile RPG that combines:
- **Pokemon-style turn-based combat**
- **Elder Scrolls-style dialogue and character interactions**
- **Heavy focus on exploration and storytelling**
- **Unique narrative** about a trans person seeking immortality to outlast a dystopian healthcare waiting list

## Story

The year is 2069. "Prime" (formerly Amazon) has taken over all public services. Due to healthcare privatization, trans healthcare has become impossible to access - the waiting list for your first appointment is 300 years long.

They don't want to outright refuse you; that would imply inefficiency. Instead, they simply add you to the list and wait for you to die.

But they are fools. For you have learned the secrets of immortality. And you will get to the end of that waiting list, even if it means waiting another millennium.

## Features

### Core Gameplay Systems

- **Character Creation**: Define your identity, politics, hobby, day job, subscription tier, and magical source
- **Attribute System**: Assign points to Strength (combat), Sense (social/perception), and Spells (magic)
- **Turn-Based Combat**: Strategic Pokemon-style battles with attacks, spells, items, and flee options
- **Rich Dialogue**: Branching conversations with multiple NPCs, choices that matter
- **Quest System**: Track your progress toward lichdom and other objectives
- **Sacrifice Mechanic**: Trade possessions, relationships, beliefs, or humanity for survival
- **Exploration**: Multiple locations to discover in a corporate dystopia
- **Inventory Management**: Collect and use items strategically

### Game World

**Locations:**
- Your apartment in Prime Housing Complex
- Prime City Streets (under constant surveillance)
- Underground Market (black market outside Prime control)
- Abandoned Library (forgotten knowledge)
- Abandoned District (where magic lingers)
- Prime Healthcare Center (reminder of the 300-year wait)
- Community Safe House (trans mutual aid)
- The Forgotten Place (ritual site)
- Prime High-Speed Train (for Premium subscribers)

**NPCs:**
- **Ash**: Resistance member who introduces you to lichdom
- **Dr. Morgan**: Former academic with knowledge of transformation magic
- **Taylor**: Your burnt-out coworker, Prime drone operator
- **The Collector**: Mysterious vendor of rare magical items
- **Raven**: Trans community elder offering wisdom and guidance
- **Officer Kane**: Prime Enforcement Officer
- ...and more

**The Quest:**
Gather three components for the lichdom ritual:
1. **Spell Source**: Ancient knowledge of transformation
2. **Rare Component**: A magical artifact of power
3. **Magical Location**: A place of power for the ritual

## Versions

LICHCRAFT is available in two versions:

### Web Version (This Directory)
- Pure JavaScript implementation
- Runs in any modern browser
- Works on desktop and mobile
- No installation required
- Progressive Web App (PWA) support

### Godot Engine Version (godot-version/)
- Native desktop game engine implementation
- Better performance and features
- Native Windows, Mac, and Linux support
- Requires [Godot Engine](https://godotengine.org/) to develop
- See [godot-version/README.md](godot-version/README.md) for details

## How to Play

### Installation

#### Desktop/Web:
1. Clone or download this repository
2. Open `index.html` in a modern web browser
3. Start your journey!

#### Mobile:
1. Open `index.html` in your mobile browser
2. Add to home screen for a native app experience
3. Works offline after first load!

### Controls

- **Touch/Click**: Interact with buttons, choices, and UI elements
- **Action Bar**: Access Explore, Inventory, Quests, and Status screens
- **Combat**: Choose Attack, Spell, Item, or Flee during battles
- **Dialogue**: Select from branching conversation choices

### Tips

- Save often! The game auto-saves, but you can manually save via the menu
- Pay attention to attribute checks in dialogue (requires Strength 2+, Sense 2+, etc.)
- When health is low, consider making sacrifices to survive
- Explore thoroughly - hidden items and secrets await
- Talk to everyone - NPCs have deep stories and valuable information
- Your character creation choices affect dialogue and story options

## Debug Commands

Open browser console and use `window.debug`:

```javascript
// Health management
debug.addHealth(5)

// Add items
debug.listItems()
debug.addItem('health_pack')
debug.addItem('ancient_tome')

// Teleportation
debug.listLocations()
debug.teleport('underground_market')

// Combat
debug.listEnemies()
debug.startCombat('security_drone')

// Quests
debug.completeQuest('quest_lichdom')

// Flags
debug.setFlag('knows_about_lichdom')

// Save/Load
debug.save()
debug.load()
debug.reset() // Clear all data
```

## Technical Details

### Architecture

- **Pure JavaScript** - No frameworks, easy to understand and modify
- **Event-Driven** - Clean separation between systems via EventSystem
- **Modular Design** - Each system (Combat, Dialogue, Exploration) is independent
- **Mobile-First** - Responsive design optimized for touch
- **PWA-Ready** - Can be installed as a standalone mobile app

### File Structure

```
FALLOUT-/
├── index.html              # Main HTML file
├── styles.css              # All styling
├── src/
│   ├── engine/
│   │   ├── GameState.js    # Central game state management
│   │   ├── EventSystem.js  # Event bus for system communication
│   │   └── Game.js         # Main game controller
│   ├── systems/
│   │   ├── CombatSystem.js     # Turn-based combat
│   │   ├── DialogueSystem.js   # Branching conversations
│   │   ├── ExplorationSystem.js # World exploration
│   │   ├── InventorySystem.js  # Item management
│   │   └── QuestSystem.js      # Quest tracking & sacrifices
│   ├── data/
│   │   └── GameData.js     # All game content (NPCs, locations, dialogue)
│   ├── ui/
│   │   └── UIManager.js    # UI rendering and interactions
│   └── main.js             # Entry point
├── godot-version/          # Godot Engine native version
│   ├── project.godot       # Godot project file
│   ├── scenes/             # Game scenes
│   ├── scripts/            # GDScript files
│   └── assets/             # Game assets
└── README.md
```

## Customization

Want to add your own content? Edit `src/data/GameData.js`:

### Add a New NPC

```javascript
npcs: {
    your_npc: {
        id: 'your_npc',
        name: 'NPC Name',
        location: 'city_streets',
        sprite: '👤',
        description: 'Description of the NPC',
        dialogue: 'dialogue_your_npc'
    }
}
```

### Add New Locations

```javascript
locations: {
    your_location: {
        id: 'your_location',
        name: 'Location Name',
        description: 'Location description',
        sprite: '🏢',
        connections: [
            { to: 'city_streets', label: 'Leave' }
        ]
    }
}
```

### Add New Items

```javascript
items: {
    your_item: {
        id: 'your_item',
        name: 'Item Name',
        type: 'consumable', // or 'quest', 'key', 'tool'
        effect: 'heal',
        power: 3,
        description: 'Item description',
        value: 25
    }
}
```

### Add Dialogue Trees

```javascript
dialogues: {
    dialogue_your_npc: {
        greeting: {
            text: "Hello!",
            choices: [
                { text: "Hi", next: "conversation" },
                { text: "Bye", action: "end" }
            ]
        }
    }
}
```

## Themes

LICHCRAFT explores:
- Trans identity and resilience
- Corporate dystopia and resistance
- Transformation as survival and power
- Mutual aid and community
- The cost of immortality
- Sacrifice and what we're willing to give up

## Credits

**Inspired by:**
- Fallout series (exploration and world-building)
- Pokemon (turn-based combat)
- Elder Scrolls (dialogue and character depth)
- The Lichcraft PDF scenario for AI Dungeon

**Created with:**
- HTML5, CSS3, JavaScript
- No external libraries or frameworks
- Pure determination and trans rage ✊

## License

Free to play, modify, and share. If you build something cool with this, let others know!

## Support

If you encounter bugs or have suggestions:
1. Check the browser console for errors
2. Try `debug.reset()` to clear corrupted save data
3. Make sure you're using a modern browser (Chrome, Firefox, Safari, Edge)

---

## Final Note

This game is a love letter to every trans person navigating systems designed to make us wait, to make us disappear, to make us give up.

We don't give up. We transform. We endure. We become unstoppable.

You are valid. You are powerful. You are eternal.

Now go become a lich. 🏴⚧️💀

---

**Version**: 1.0.0
**Last Updated**: 2026-01-14
