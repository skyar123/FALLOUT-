class GameState {
    constructor() {
        this.player = {
            name: '',
            genderIdentity: '',
            politics: '',
            hobby: '',
            dayJob: '',
            subscriptionTier: '',
            magicalSource: '',
            attributes: {
                strength: 0,
                sense: 0,
                spells: 0
            },
            health: 5,
            maxHealth: 5,
            inventory: [],
            quests: [],
            location: 'home',
            discoveredLocations: ['home'],
            metNPCs: [],
            flags: {} // For tracking story choices and events
        };

        this.currentDialogue = null;
        this.currentCombat = null;
        this.gamePhase = 'loading'; // loading, creation, exploration, dialogue, combat
    }

    // Save/Load System
    saveGame() {
        try {
            const saveData = {
                player: this.player,
                timestamp: Date.now()
            };
            localStorage.setItem('lichcraft_save', JSON.stringify(saveData));
            return true;
        } catch (e) {
            console.error('Save failed:', e);
            return false;
        }
    }

    loadGame() {
        try {
            const saveData = localStorage.getItem('lichcraft_save');
            if (saveData) {
                const data = JSON.parse(saveData);
                this.player = data.player;
                return true;
            }
            return false;
        } catch (e) {
            console.error('Load failed:', e);
            return false;
        }
    }

    hasSave() {
        return localStorage.getItem('lichcraft_save') !== null;
    }

    // Player Management
    setPlayerAttribute(key, value) {
        if (key.includes('.')) {
            const parts = key.split('.');
            let obj = this.player;
            for (let i = 0; i < parts.length - 1; i++) {
                obj = obj[parts[i]];
            }
            obj[parts[parts.length - 1]] = value;
        } else {
            this.player[key] = value;
        }
        this.saveGame();
    }

    getPlayerAttribute(key) {
        if (key.includes('.')) {
            const parts = key.split('.');
            let obj = this.player;
            for (const part of parts) {
                obj = obj[part];
            }
            return obj;
        }
        return this.player[key];
    }

    // Health Management
    modifyHealth(amount) {
        this.player.health = Math.max(0, Math.min(this.player.maxHealth, this.player.health + amount));
        if (this.player.health === 0) {
            this.handleDeath();
        }
        this.saveGame();
    }

    handleDeath() {
        EventSystem.emit('player-death');
    }

    // Inventory Management
    addItem(item) {
        const existing = this.player.inventory.find(i => i.id === item.id);
        if (existing && item.stackable) {
            existing.quantity = (existing.quantity || 1) + (item.quantity || 1);
        } else {
            this.player.inventory.push({...item, quantity: item.quantity || 1});
        }
        this.saveGame();
        EventSystem.emit('inventory-changed');
    }

    removeItem(itemId, quantity = 1) {
        const item = this.player.inventory.find(i => i.id === itemId);
        if (item) {
            if (item.quantity > quantity) {
                item.quantity -= quantity;
            } else {
                this.player.inventory = this.player.inventory.filter(i => i.id !== itemId);
            }
            this.saveGame();
            EventSystem.emit('inventory-changed');
            return true;
        }
        return false;
    }

    hasItem(itemId) {
        return this.player.inventory.some(i => i.id === itemId);
    }

    // Quest Management
    addQuest(quest) {
        if (!this.player.quests.find(q => q.id === quest.id)) {
            this.player.quests.push({
                ...quest,
                status: 'active',
                objectives: quest.objectives.map(obj => ({...obj, completed: false}))
            });
            this.saveGame();
            EventSystem.emit('quest-added', quest);
        }
    }

    updateQuestObjective(questId, objectiveIndex) {
        const quest = this.player.quests.find(q => q.id === questId);
        if (quest && quest.objectives[objectiveIndex]) {
            quest.objectives[objectiveIndex].completed = true;

            // Check if all objectives are complete
            if (quest.objectives.every(obj => obj.completed)) {
                quest.status = 'completed';
                EventSystem.emit('quest-completed', quest);
            }

            this.saveGame();
            EventSystem.emit('quest-updated', quest);
        }
    }

    hasQuest(questId) {
        return this.player.quests.some(q => q.id === questId);
    }

    isQuestCompleted(questId) {
        const quest = this.player.quests.find(q => q.id === questId);
        return quest && quest.status === 'completed';
    }

    // Location Management
    changeLocation(locationId) {
        this.player.location = locationId;
        if (!this.player.discoveredLocations.includes(locationId)) {
            this.player.discoveredLocations.push(locationId);
        }
        this.saveGame();
        EventSystem.emit('location-changed', locationId);
    }

    // NPC Tracking
    markNPCMet(npcId) {
        if (!this.player.metNPCs.includes(npcId)) {
            this.player.metNPCs.push(npcId);
            this.saveGame();
        }
    }

    hasMetNPC(npcId) {
        return this.player.metNPCs.includes(npcId);
    }

    // Story Flags
    setFlag(flag, value = true) {
        this.player.flags[flag] = value;
        this.saveGame();
    }

    getFlag(flag) {
        return this.player.flags[flag] || false;
    }

    // Combat Check
    rollCheck(attribute, difficulty = 10) {
        const attrValue = this.player.attributes[attribute] || 0;
        const roll = Math.floor(Math.random() * 6) + 1; // D6
        const total = roll + attrValue;
        return {
            success: total >= difficulty,
            roll: roll,
            total: total,
            needed: difficulty
        };
    }
}
