class Game {
    constructor() {
        this.state = new GameState();
        this.ui = new UIManager();
        this.systems = {
            combat: new CombatSystem(this.state),
            dialogue: new DialogueSystem(this.state),
            exploration: new ExplorationSystem(this.state),
            inventory: new InventorySystem(this.state),
            quest: new QuestSystem(this.state)
        };

        this.characterCreationStep = 0;
        this.characterCreationSteps = [
            { key: 'name', prompt: 'What is your name?', type: 'text' },
            {
                key: 'genderIdentity',
                prompt: 'What is your gender identity?',
                type: 'select',
                options: ['Trans Woman', 'Trans Man', 'Non-Binary', 'Genderfluid', 'Agender', 'Other']
            },
            {
                key: 'politics',
                prompt: 'What are your political views?',
                type: 'select',
                options: ['Communist', 'Anarchist', 'Eco-Socialist', 'Democratic Socialist', 'Syndicalist', 'Other']
            },
            {
                key: 'hobby',
                prompt: 'What is your hobby?',
                type: 'select',
                options: ['Crafting', 'Cooking', 'Reading', 'Gardening', 'Gaming', 'Music', 'Art', 'Sports']
            },
            {
                key: 'dayJob',
                prompt: 'What is your day job?',
                type: 'select',
                options: ['Prime Drone Operator', 'Barista', 'Warehouse Worker', 'Data Entry', 'Retail Worker', 'Gig Worker', 'Unemployed']
            },
            {
                key: 'subscriptionTier',
                prompt: 'What is your Prime subscription tier?',
                type: 'select',
                options: ['Basic', 'Plus', 'Premium']
            },
            {
                key: 'magicalSource',
                prompt: 'Where does your magical affinity come from?',
                type: 'select',
                options: ['Nature', 'Ritual Practice', 'Bloodline', 'Academic Study', 'Divine Connection', 'Raw Will']
            },
            {
                key: 'attributes',
                prompt: 'Assign your attribute values: 3 (highest), 2 (medium), and 1 (lowest) to Strength, Sense, and Spells.',
                type: 'attributes'
            }
        ];

        this.setupEventListeners();
    }

    setupEventListeners() {
        // Game start
        EventSystem.on('start-game', () => this.startGame());

        // Character creation
        document.getElementById('creation-next').addEventListener('click', () => {
            this.nextCharacterCreationStep();
        });

        // Location events
        EventSystem.on('location-changed', (locationId) => {
            this.systems.exploration.enterLocation(locationId);
        });

        EventSystem.on('location-entered', (data) => {
            this.ui.updateLocationUI(data.location, data.npcs, data.items);
        });

        // Exploration
        EventSystem.on('request-exploration-options', () => {
            const state = this.systems.exploration.getLocationState();
            this.ui.displayExplorationActions(state.actions);
        });

        EventSystem.on('exploration-action', (action) => {
            this.handleExplorationAction(action);
        });

        // Dialogue events
        EventSystem.on('dialogue-started', () => {
            const dialogueState = this.systems.dialogue.getCurrentState();
            if (dialogueState) {
                this.ui.showDialogue(dialogueState.npc, dialogueState.text, dialogueState.choices);
            }
        });

        EventSystem.on('dialogue-node-changed', () => {
            const dialogueState = this.systems.dialogue.getCurrentState();
            if (dialogueState) {
                this.ui.showDialogue(dialogueState.npc, dialogueState.text, dialogueState.choices);
            }
        });

        EventSystem.on('dialogue-ended', () => {
            this.ui.hideDialogue();
        });

        EventSystem.on('dialogue-choice', (choiceIndex) => {
            this.systems.dialogue.selectChoice(choiceIndex);
        });

        // Combat events
        EventSystem.on('combat-started', () => {
            const combatState = this.systems.combat.getCombatState();
            this.ui.showCombat(combatState);
        });

        EventSystem.on('combat-action', (action) => {
            this.handleCombatAction(action);
        });

        EventSystem.on('combat-turn-start', () => {
            const combatState = this.systems.combat.getCombatState();
            this.ui.updateCombatUI(combatState);
        });

        EventSystem.on('combat-log-updated', () => {
            const combatState = this.systems.combat.getCombatState();
            this.ui.updateCombatUI(combatState);
        });

        // Add event to get combat state
        EventSystem.on('get-combat-state', (callback) => {
            const state = this.systems.combat.getCombatState();
            if (state) callback(state);
        });

        EventSystem.on('combat-ended', (victory) => {
            setTimeout(() => {
                this.ui.showScreen('game');
                if (victory) {
                    this.ui.showNotification('Victory!', 'success');
                } else {
                    this.ui.showNotification('Combat ended', 'info');
                }
                // Update player UI
                this.ui.updatePlayerUI(this.state.player);
            }, 500);
        });

        EventSystem.on('combat-fled', () => {
            this.ui.showNotification('Escaped from combat', 'info');
        });

        EventSystem.on('combat-lost', () => {
            this.handlePlayerDeath();
        });

        EventSystem.on('random-encounter', (encounter) => {
            if (encounter.type === 'combat') {
                const enemy = GameData.enemies[encounter.enemy];
                if (enemy) {
                    this.ui.showNotification('Enemy encountered!', 'error');
                    setTimeout(() => {
                        this.systems.combat.startCombat(enemy);
                    }, 1000);
                }
            }
        });

        // Quest events
        EventSystem.on('quest-added', (quest) => {
            this.ui.showNotification(`New quest: ${quest.name}`, 'success');
        });

        EventSystem.on('quest-completed', (quest) => {
            this.ui.showNotification(`Quest completed: ${quest.name}`, 'success');
        });

        EventSystem.on('item-collected', (item) => {
            this.ui.showNotification(`Obtained: ${item.name}`, 'success');
            this.systems.quest.checkObjectiveProgress('item-collected', item);
        });

        // Inventory events
        EventSystem.on('get-inventory', (callback) => {
            callback(this.systems.inventory.getInventory());
        });

        EventSystem.on('inventory-changed', () => {
            if (this.ui.currentScreen === 'inventory') {
                this.ui.updateInventoryUI();
            }
        });

        EventSystem.on('item-used', (data) => {
            this.ui.showNotification(data.message, data.success ? 'success' : 'error');
            this.ui.updatePlayerUI(this.state.player);
        });

        // Quest events
        EventSystem.on('get-quests', (callback) => {
            callback(this.state.player.quests);
        });

        // Stats events
        EventSystem.on('get-player-stats', (callback) => {
            callback(this.state.player);
        });

        EventSystem.on('get-sacrifice-options', (callback) => {
            callback(this.systems.quest.getSacrificeOptions());
        });

        EventSystem.on('perform-sacrifice', (option) => {
            const success = this.systems.quest.performSacrifice(option.type, option.target);
            if (success) {
                this.ui.showNotification('Sacrifice completed', 'success');
                this.ui.updatePlayerUI(this.state.player);
            }
        });

        EventSystem.on('sacrifice-performed', (data) => {
            this.ui.showNotification(data.description, 'info');
        });

        // Global item use functions for UI buttons
        window.useSelectedItem = (itemId) => {
            this.systems.inventory.useItem(itemId);
        };

        window.dropSelectedItem = (itemId) => {
            if (confirm('Drop this item?')) {
                this.systems.inventory.dropItem(itemId);
            }
        };
    }

    startGame() {
        // Check for existing save
        if (this.state.hasSave()) {
            if (confirm('Continue from saved game?')) {
                this.state.loadGame();
                this.enterGameWorld();
                return;
            }
        }

        // Start character creation
        this.startCharacterCreation();
    }

    startCharacterCreation() {
        this.characterCreationStep = 0;
        const step = this.characterCreationSteps[this.characterCreationStep];
        this.ui.showCharacterCreation(
            this.characterCreationStep,
            step.prompt,
            step.type,
            step.options
        );
    }

    nextCharacterCreationStep() {
        const step = this.characterCreationSteps[this.characterCreationStep];
        const value = this.ui.getCreationInput();

        if (!value || (typeof value === 'string' && value.trim() === '')) {
            this.ui.showNotification('Please provide an answer', 'error');
            return;
        }

        // Validate attributes
        if (step.type === 'attributes') {
            const attrs = value;
            if (Object.keys(attrs).length !== 3) {
                this.ui.showNotification('Please assign all three attributes', 'error');
                return;
            }
            // Set all attributes
            this.state.setPlayerAttribute('attributes.strength', attrs.strength);
            this.state.setPlayerAttribute('attributes.sense', attrs.sense);
            this.state.setPlayerAttribute('attributes.spells', attrs.spells);
        } else {
            // Set the character attribute
            this.state.setPlayerAttribute(step.key, value);
        }

        // Move to next step
        this.characterCreationStep++;

        if (this.characterCreationStep >= this.characterCreationSteps.length) {
            this.finishCharacterCreation();
        } else {
            const nextStep = this.characterCreationSteps[this.characterCreationStep];
            this.ui.showCharacterCreation(
                this.characterCreationStep,
                nextStep.prompt,
                nextStep.type,
                nextStep.options
            );
        }
    }

    finishCharacterCreation() {
        // Add starting items
        GameData.starterItems.forEach(item => {
            this.state.addItem(item);
        });

        // Initialize main quest
        this.systems.quest.initializeMainQuest();

        // Enter game world
        this.enterGameWorld();
    }

    enterGameWorld() {
        this.state.gamePhase = 'exploration';
        this.ui.showScreen('game');
        this.ui.updatePlayerUI(this.state.player);

        // Enter starting location
        this.systems.exploration.enterLocation(this.state.player.location);

        // Welcome message
        setTimeout(() => {
            this.ui.showNotification(`Welcome, ${this.state.player.name}`, 'success');
        }, 500);
    }

    handleExplorationAction(action) {
        switch (action.type) {
            case 'talk':
                this.startDialogueWithNPC(action.target);
                break;

            case 'collect':
                this.systems.exploration.collectItem(action.target);
                break;

            case 'travel':
                this.state.changeLocation(action.target);
                this.systems.quest.checkObjectiveProgress('location-visited', action.target);
                break;

            case 'custom':
                this.handleCustomAction(action.action);
                break;
        }
    }

    startDialogueWithNPC(npc) {
        const dialogueTree = GameData.dialogues[npc.dialogue];
        if (dialogueTree) {
            this.systems.dialogue.startDialogue(npc, dialogueTree);
            this.systems.quest.checkObjectiveProgress('npc-talked', npc);
        }
    }

    handleCustomAction(action) {
        switch (action) {
            case 'open-shop':
                this.ui.showNotification('Shop system coming soon!', 'info');
                break;

            case 'check-waiting-list':
                this.ui.showNotification('Waiting list position: 299 years, 364 days remaining', 'info');
                break;

            case 'lichdom-ritual':
                this.performLichdomRitual();
                break;

            default:
                this.ui.showNotification('Action not implemented', 'error');
        }
    }

    handleCombatAction(action) {
        switch (action) {
            case 'attack':
                this.systems.combat.playerAttack();
                break;

            case 'spell':
                this.systems.combat.playerSpell();
                break;

            case 'item':
                // Show item selection
                const items = this.systems.inventory.getItemsByType('consumable');
                if (items.length === 0) {
                    this.ui.showNotification('No usable items', 'error');
                } else {
                    // Use first healing item for simplicity
                    const item = items.find(i => i.effect === 'heal');
                    if (item) {
                        this.systems.combat.playerUseItem(item);
                    }
                }
                break;

            case 'flee':
                this.systems.combat.playerFlee();
                break;
        }
    }

    handlePlayerDeath() {
        setTimeout(() => {
            if (confirm('You have been defeated. Try again?')) {
                // Restore some health and return to safe location
                this.state.player.health = Math.floor(this.state.player.maxHealth / 2);
                this.state.changeLocation('home');
                this.ui.showScreen('game');
                this.ui.updatePlayerUI(this.state.player);
                this.ui.showNotification('You awaken in your apartment, battered but alive', 'info');
            } else {
                location.reload();
            }
        }, 1000);
    }

    performLichdomRitual() {
        // Check if player has all required items
        const hasSpellSource = this.state.hasItem('ancient_tome');
        const hasRareComponent = this.state.hasItem('crystal_heart');
        const atMagicalLocation = this.state.player.location === 'ritual_site';

        if (!hasSpellSource || !hasRareComponent || !atMagicalLocation) {
            this.ui.showNotification('You do not yet have everything needed for the ritual', 'error');
            return;
        }

        // Perform ritual (ending)
        if (confirm('Perform the lichdom ritual? This will end your current journey and transform you forever.')) {
            this.triggerEnding();
        }
    }

    triggerEnding() {
        this.ui.showScreen('loading');
        const loadingScreen = document.getElementById('loading-screen');
        loadingScreen.innerHTML = `
            <h1>TRANSFORMATION COMPLETE</h1>
            <div style="max-width: 600px; text-align: left; line-height: 1.8;">
                <p>The ritual energy surges through you. Your mortal form dissolves, reforms, transcends.</p>
                <p>You are no longer bound by flesh, by time, by Prime's control.</p>
                <p>You are ${this.state.player.name}, and you are eternal.</p>
                <p>The 300-year waiting list? You'll be there. And you'll be there for every trans person who comes after.</p>
                <p>Prime thought they could make you disappear by making you wait forever.</p>
                <p>But you've become forever.</p>
                <p style="margin-top: 2rem; color: #FF9900; font-size: 1.2rem;">Thank you for playing LICHCRAFT.</p>
            </div>
            <button class="prime-button" onclick="location.reload()" style="margin-top: 2rem;">NEW GAME</button>
        `;
    }
}
