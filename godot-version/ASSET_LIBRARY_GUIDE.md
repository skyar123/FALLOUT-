# Godot Asset Library Integration Guide

This document provides a comprehensive list of recommended Godot Asset Library plugins for LICHCRAFT, organized by system.

## 📥 How to Install Assets

### Method 1: Via Godot Editor (Recommended)
1. Open the project in Godot Engine
2. Click **AssetLib** tab at the top
3. Search for the asset by name
4. Click **Download** → **Install**
5. Check which files to import
6. Click **Install** to complete

### Method 2: Manual Installation
1. Download the asset from [Godot Asset Library](https://godotengine.org/asset-library/asset)
2. Extract to `godot-version/addons/[plugin-name]/`
3. Restart Godot
4. Enable in **Project → Project Settings → Plugins**

---

## ⚔️ TURN-BASED COMBAT SYSTEMS

### Primary Recommendation: Turn Based Combat (3D)
- **Author**: TheRealFame
- **Version**: 0.5 (Godot 4.1)
- **License**: CC-BY-4.0
- **Asset Library ID**: Search "Turn Based Combat 3D"

**Why**: Perfect template foundation, can be adapted for 2D/hybrid approach

**Integration Notes**:
- Install in `addons/turn_based_combat/`
- Adapt 3D mechanics to 2D UI
- Integrate with existing `CombatSystem.gd`
- Use for turn order, action queue, and combat flow

### Alternative: JRPG Fragment - Turn-Based Combat
- **Author**: mechPenSketch
- **Version**: 1.1 (Godot 3.2)
- **License**: MIT
- **Note**: Needs porting to Godot 4.x

**Why**: Great reference for Pokemon-style mechanics

---

## 💬 DIALOGUE SYSTEMS

### 🌟 Primary Recommendation: Dialogue Manager 3
- **Author**: nathanhoad
- **Version**: 3.9.1 (Godot 4.4)
- **License**: MIT
- **Asset Library ID**: Search "Dialogue Manager"

**Why**: Most actively maintained, perfect for Elder Scrolls-style branching dialogue

**Features**:
- Branching conversation trees
- Variable and condition system
- Character portraits and emotion support
- Save/load dialogue state
- Custom syntax for dialogue writing

**Integration Steps**:
1. Install via AssetLib
2. Replace current `DialogueSystem.gd` with Dialogue Manager
3. Convert dialogue trees to `.dialogue` files
4. Connect to GameState flags and variables
5. Integrate with NPC interaction system

### Alternative Options (Elite Tier)

#### Oasis Dialogue
- **Author**: thephilipquan
- **Version**: 0.5.0 (Godot 4.5)
- **License**: MIT
- **Why**: Latest Godot version support, excellent for branching trees

#### Clyde Dialogue
- **Author**: viniciusgerevini
- **Version**: v7.0.0 (Godot 4.4)
- **License**: MIT
- **Why**: Robust, well-supported framework

#### MadTalk - Dialogue System
- **Author**: fbcosentino
- **Version**: 1.0 (Godot 4.4)
- **License**: MIT
- **Why**: Great for emotional storytelling (perfect for LICHCRAFT narrative)

#### Parley Dialogue Manager
- **Author**: jonnydgreen
- **Version**: 2.0.0 (Godot 4.4)
- **License**: MIT
- **Why**: Excellent branching conversation support

### Advanced Options

#### DialogueQuest
- **Author**: hohfchns
- **Why**: Integrated quest + dialogue system

#### Rakugo Dialogue System
- **Why**: Advanced scripting capabilities

---

## 📦 INVENTORY MANAGEMENT SYSTEMS

### 🌟 Primary Recommendation: Inventory Forge
- **Author**: menkos
- **Version**: 1.2.0 (Godot 4.0)
- **License**: MIT
- **Last Updated**: 2026-01-06 (Most Recent!)

**Why**: Modern, clean interface - ideal for sacrificial mechanics

**Features**:
- Drag-and-drop inventory UI
- Item stacking
- Equipment slots
- Custom item properties
- Save/load support

**Integration for LICHCRAFT**:
- Perfect for tracking possessions, relationships, beliefs, humanity
- Can customize item types for sacrifice mechanic
- Integrate with existing `GameState.inventory`

### Alternative Options

#### Inventory System
- **Author**: expressobits
- **Version**: Latest (Godot 4.4)
- **License**: MIT
- **Why**: Comprehensive and flexible

#### P0nni Inventory System (Data-Driven Core & Editor Tools)
- **Author**: p0nni
- **Version**: 1.0 (Godot 4.5)
- **License**: MIT
- **Why**: Perfect for customizing item types

#### GLoot (Universal Inventory System)
- **Author**: pkish
- **Version**: 3.0.1 (Godot 4.4)
- **License**: MIT
- **Why**: Very flexible for unique items

#### Wyvernbox - Inventory System
- **Author**: don-tnowe
- **Version**: 1.3.14 (Godot 4.0)
- **License**: MIT
- **Why**: Mature, battle-tested system

---

## 📜 QUEST/TRACKING SYSTEMS

### 🌟 Primary Recommendation: Nexus Quest Weaver
- **Author**: movec
- **Version**: 0.8.3 (Godot 4.4)
- **License**: MIT

**Why**: Perfect for tracking your 3-component lichdom quest

**Features**:
- Quest tracking and objectives
- Quest chains and dependencies
- Progress monitoring
- Quest log UI
- Save/load quest state

**Integration**:
- Replace existing quest system in `GameState.gd`
- Track the three lichdom components:
  1. Spell Source
  2. Rare Component
  3. Magical Location
- Integrate with dialogue system for quest triggers

### Alternative Options

#### Quest Manager
- **Version**: (Godot 4.2)
- **License**: MIT
- **Why**: Solid quest tracking system

#### DialogueQuest
- **Author**: hohfchns
- **Why**: Integrates dialogue with quest tracking (NPC-driven quests)

---

## 🌍 RPG FRAMEWORKS

### 🌟 Primary Recommendation: Skelerealms - Open World RPG Framework
- **Author**: Slashscreen
- **Version**: 0.6 (Godot 4.3)
- **License**: MIT

**HIGHLY RECOMMENDED**: Built specifically for exploration-heavy RPGs

**Features**:
- World exploration system
- NPC interaction framework
- Location management
- Event system
- Save/load game state

**Why Perfect for LICHCRAFT**:
- Prime City Streets exploration
- Multiple interconnected locations
- NPC-rich world
- Story-driven exploration

**Integration**:
- Use as foundation for `GameWorld.gd`
- Integrate existing location system
- Connect to dialogue and quest systems

### Alternative: DRPG Framework
- **Version**: Latest (Godot 4.2)
- **License**: MIT
- **Why**: Good general RPG foundation

---

## 🎨 COMPLEMENTARY ASSETS

### UI/UX Enhancement

#### Bubble Dialogue Assets
- For character interaction visuals
- Speech bubble UI for NPC conversations

#### Inventory UI Templates
- Various templates available in Asset Library
- Look for "Inventory UI" or "RPG UI"

### Advanced Features

#### NobodyWho | Local LLMs for Dialogue
- **Version**: v8.0.0 (Godot 4.5)
- **Why**: AI-assisted NPC dialogue for dynamic character interactions
- **Note**: Advanced feature, use only if you want procedural dialogue

#### Simple Dialogue
- **Why**: Lightweight option if you want minimal overhead

---

## ⭐ RECOMMENDED TECH STACK FOR LICHCRAFT

Based on your requirements, here's the optimal combination:

### Core Systems (Install in this order)

1. **Skelerealms** - Open World RPG Framework
   - Foundation for exploration and world management

2. **Dialogue Manager 3** - Dialogue System
   - Most mature and widely used
   - Elder Scrolls-style branching conversations

3. **Inventory Forge** - Inventory Management
   - Newest and cleanest
   - Perfect for sacrifice mechanics (possessions, relationships, beliefs, humanity)

4. **Nexus Quest Weaver** - Quest Tracking
   - Purpose-built for quest tracking
   - Track the three lichdom components

5. **Turn Based Combat (3D)** - Combat System
   - Adapt to 2D as needed
   - Pokemon-style turn-based mechanics

---

## 📂 PROJECT STRUCTURE AFTER INSTALLATION

```
godot-version/
├── addons/                      # Plugin directory
│   ├── dialogue_manager/        # Dialogue Manager 3
│   ├── inventory_forge/         # Inventory Forge
│   ├── nexus_quest_weaver/      # Quest system
│   ├── skelerealms/             # RPG framework
│   └── turn_based_combat/       # Combat system
├── scenes/
│   ├── Main.tscn
│   ├── GameWorld.tscn           # Integrate with Skelerealms
│   └── CombatScene.tscn         # Integrate with Turn Based Combat
├── scripts/
│   ├── Main.gd
│   ├── GameState.gd             # Connect to all systems
│   ├── GameWorld.gd             # Use Skelerealms foundation
│   ├── CombatSystem.gd          # Integrate combat addon
│   └── DialogueSystem.gd        # May be replaced by Dialogue Manager
└── data/
    ├── dialogues/               # .dialogue files for Dialogue Manager
    ├── quests/                  # Quest definitions for Nexus
    └── items/                   # Item definitions for Inventory Forge
```

---

## 🚀 INSTALLATION PRIORITY

### Phase 1: Core Systems (Install First)
1. Dialogue Manager 3 ⭐ (Most critical for your narrative)
2. Inventory Forge ⭐ (Essential for sacrifice mechanics)

### Phase 2: Gameplay Systems
3. Nexus Quest Weaver (Quest tracking)
4. Turn Based Combat (Combat mechanics)

### Phase 3: Framework Integration
5. Skelerealms (Exploration framework - largest integration)

### Phase 4: Polish & Enhancement
6. UI/UX assets as needed
7. Additional complementary systems

---

## ⚠️ IMPORTANT NOTES

### License Compatibility
- **ALL listed assets are MIT or CC-BY licensed**
- Free for commercial use
- Attribution required for CC-BY assets
- Check individual licenses in each addon

### Version Compatibility
- All recommended assets support **Godot 4.0+**
- Some may require minor adjustments for Godot 4.4/4.5
- Check asset documentation for version-specific notes

### Integration Strategy
1. Install ONE system at a time
2. Test integration before moving to next
3. Keep backups of your project
4. Read each addon's documentation thoroughly
5. Some systems may conflict - prioritize based on your needs

---

## 📚 NEXT STEPS

1. **Download Dialogue Manager 3 + Inventory Forge first** (most critical)
2. **Review Skelerealms** documentation for exploration framework
3. **Check Nexus Quest Weaver** for quest tracking integration
4. **Start with Turn Based Combat** template and customize for LICHCRAFT

---

## 🎯 LICHCRAFT-SPECIFIC INTEGRATION NOTES

### For Your Trans Narrative
- Use **MadTalk** or **Dialogue Manager 3** for emotional storytelling
- Configure dialogue to handle attribute checks (Strength, Sense, Spells)
- Set up story flags for trans healthcare narrative

### For Sacrifice Mechanics
- Use **Inventory Forge** to track:
  - Possessions (physical items)
  - Relationships (NPC connection items)
  - Beliefs (ideology items)
  - Humanity (transformation progress)

### For Lichdom Quest
- Use **Nexus Quest Weaver** to track:
  1. Spell Source component
  2. Rare Component artifact
  3. Magical Location discovery

### For Dystopian Exploration
- Use **Skelerealms** for:
  - Prime City Streets
  - Underground Market
  - Abandoned Library
  - Abandoned District
  - All 9 locations in your game world

---

## 📖 ADDITIONAL RESOURCES

- [Godot Asset Library](https://godotengine.org/asset-library/asset)
- [Godot Documentation](https://docs.godotengine.org/)
- Each addon has its own documentation in `addons/[plugin-name]/README.md`

---

Good luck building LICHCRAFT! This tech stack will give you a solid foundation for your unique trans cyberpunk lich simulator. 🏴⚧️💀
