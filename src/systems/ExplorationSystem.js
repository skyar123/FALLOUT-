class ExplorationSystem {
    constructor(gameState) {
        this.gameState = gameState;
        this.currentLocation = null;
        this.nearbyNPCs = [];
        this.nearbyItems = [];
        this.availableActions = [];
    }

    enterLocation(locationId) {
        const location = GameData.locations[locationId];
        if (!location) {
            console.error('Location not found:', locationId);
            return;
        }

        this.currentLocation = location;
        this.gameState.changeLocation(locationId);

        // Find NPCs at this location
        this.nearbyNPCs = Object.values(GameData.npcs).filter(npc =>
            npc.location === locationId && this.checkNPCAvailability(npc)
        );

        // Find items at this location
        this.nearbyItems = (location.items || []).filter(item =>
            !this.gameState.getFlag(`collected_${item.id}`)
        );

        // Determine available actions
        this.updateAvailableActions();

        // Trigger location events
        this.triggerLocationEvents(location);

        EventSystem.emit('location-entered', {
            location: this.currentLocation,
            npcs: this.nearbyNPCs,
            items: this.nearbyItems
        });
    }

    checkNPCAvailability(npc) {
        // Check if NPC should be available based on conditions
        if (npc.availableIf) {
            if (npc.availableIf.flag) {
                return this.gameState.getFlag(npc.availableIf.flag);
            }
            if (npc.availableIf.quest) {
                return this.gameState.hasQuest(npc.availableIf.quest);
            }
            if (npc.availableIf.notFlag) {
                return !this.gameState.getFlag(npc.availableIf.notFlag);
            }
        }
        return true;
    }

    updateAvailableActions() {
        this.availableActions = [];

        // Talk to NPCs
        this.nearbyNPCs.forEach(npc => {
            this.availableActions.push({
                type: 'talk',
                label: `Talk to ${npc.name}`,
                target: npc
            });
        });

        // Collect items
        this.nearbyItems.forEach(item => {
            this.availableActions.push({
                type: 'collect',
                label: `Take ${item.name}`,
                target: item
            });
        });

        // Location-specific actions
        if (this.currentLocation.actions) {
            this.currentLocation.actions.forEach(action => {
                if (!action.condition || this.evaluateCondition(action.condition)) {
                    this.availableActions.push(action);
                }
            });
        }

        // Travel to connected locations
        if (this.currentLocation.connections) {
            this.currentLocation.connections.forEach(connection => {
                if (!connection.locked || this.gameState.getFlag(connection.unlockedBy)) {
                    this.availableActions.push({
                        type: 'travel',
                        label: `Go to ${GameData.locations[connection.to].name}`,
                        target: connection.to
                    });
                }
            });
        }

        EventSystem.emit('actions-updated', this.availableActions);
    }

    evaluateCondition(condition) {
        if (condition.hasItem) {
            return this.gameState.hasItem(condition.hasItem);
        }
        if (condition.flag) {
            return this.gameState.getFlag(condition.flag);
        }
        if (condition.attribute) {
            return this.gameState.player.attributes[condition.attribute] >= (condition.min || 0);
        }
        return true;
    }

    triggerLocationEvents(location) {
        // Random encounters
        if (location.encounters && Math.random() < (location.encounterRate || 0.1)) {
            const encounter = location.encounters[Math.floor(Math.random() * location.encounters.length)];
            setTimeout(() => {
                EventSystem.emit('random-encounter', encounter);
            }, 1000);
        }

        // Story triggers
        if (location.triggers) {
            location.triggers.forEach(trigger => {
                if (!this.gameState.getFlag(trigger.flag) && this.evaluateCondition(trigger.condition || {})) {
                    this.gameState.setFlag(trigger.flag);
                    EventSystem.emit('story-trigger', trigger);
                }
            });
        }
    }

    collectItem(item) {
        this.gameState.addItem(item);
        this.gameState.setFlag(`collected_${item.id}`);
        this.nearbyItems = this.nearbyItems.filter(i => i.id !== item.id);
        this.updateAvailableActions();
        EventSystem.emit('item-collected', item);
    }

    rest() {
        // Resting restores health but may trigger events
        const restAmount = Math.floor(this.gameState.player.maxHealth / 2);
        this.gameState.modifyHealth(restAmount);

        EventSystem.emit('player-rested', restAmount);

        // Chance of encounter while resting
        if (this.currentLocation.encounters && Math.random() < 0.3) {
            const encounter = this.currentLocation.encounters[Math.floor(Math.random() * this.currentLocation.encounters.length)];
            EventSystem.emit('random-encounter', encounter);
        }
    }

    search() {
        // Search for hidden items or secrets
        const check = this.gameState.rollCheck('sense', 12);

        if (check.success) {
            // Find something based on location
            if (this.currentLocation.hiddenItems && !this.gameState.getFlag(`searched_${this.currentLocation.id}`)) {
                const hiddenItem = this.currentLocation.hiddenItems[0];
                this.gameState.addItem(hiddenItem);
                this.gameState.setFlag(`searched_${this.currentLocation.id}`);
                EventSystem.emit('search-success', hiddenItem);
            } else {
                EventSystem.emit('search-nothing');
            }
        } else {
            EventSystem.emit('search-failed', check);
        }
    }

    getLocationState() {
        return {
            location: this.currentLocation,
            npcs: this.nearbyNPCs,
            items: this.nearbyItems,
            actions: this.availableActions
        };
    }
}
