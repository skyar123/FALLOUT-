class UIManager {
    constructor() {
        this.screens = {
            loading: document.getElementById('loading-screen'),
            creation: document.getElementById('character-creation'),
            game: document.getElementById('game-screen'),
            combat: document.getElementById('combat-screen'),
            inventory: document.getElementById('inventory-screen'),
            quests: document.getElementById('quests-screen'),
            stats: document.getElementById('stats-screen'),
            menu: document.getElementById('menu-screen')
        };

        this.currentScreen = 'loading';
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Start button
        document.getElementById('start-button').addEventListener('click', () => {
            EventSystem.emit('start-game');
        });

        // Action buttons
        document.getElementById('explore-btn').addEventListener('click', () => {
            this.showExplorationOptions();
        });

        document.getElementById('inventory-btn').addEventListener('click', () => {
            this.showScreen('inventory');
            this.updateInventoryUI();
        });

        document.getElementById('quests-btn').addEventListener('click', () => {
            this.showScreen('quests');
            this.updateQuestsUI();
        });

        document.getElementById('stats-btn').addEventListener('click', () => {
            this.showScreen('stats');
            this.updateStatsUI();
        });

        document.getElementById('menu-button').addEventListener('click', () => {
            this.showScreen('menu');
        });

        // Close buttons for overlay screens
        document.querySelectorAll('.close-button').forEach(btn => {
            btn.addEventListener('click', () => {
                this.showScreen('game');
            });
        });

        // Combat actions
        document.querySelectorAll('.combat-button').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.target.dataset.action;
                EventSystem.emit('combat-action', action);
            });
        });

        // Menu options
        document.getElementById('main-menu-btn').addEventListener('click', () => {
            if (confirm('Return to main menu? Unsaved progress will be lost.')) {
                location.reload();
            }
        });
    }

    showScreen(screenName) {
        // Hide all screens
        Object.values(this.screens).forEach(screen => {
            screen.classList.remove('active');
        });

        // Show requested screen
        if (this.screens[screenName]) {
            this.screens[screenName].classList.add('active');
            this.currentScreen = screenName;
        }
    }

    // Character Creation UI
    showCharacterCreation(step, prompt, inputType, options = null) {
        this.showScreen('creation');

        const titleEl = document.getElementById('creation-title');
        const promptEl = document.getElementById('creation-prompt');
        const containerEl = document.getElementById('creation-input-container');

        titleEl.textContent = 'Character Creation';
        promptEl.textContent = prompt;
        containerEl.innerHTML = '';

        if (inputType === 'text') {
            const input = document.createElement('input');
            input.type = 'text';
            input.id = 'creation-input';
            input.placeholder = 'Enter your answer...';
            containerEl.appendChild(input);
            input.focus();
        } else if (inputType === 'select') {
            const select = document.createElement('select');
            select.id = 'creation-input';
            options.forEach(option => {
                const optionEl = document.createElement('option');
                optionEl.value = option;
                optionEl.textContent = option;
                select.appendChild(optionEl);
            });
            containerEl.appendChild(select);
        } else if (inputType === 'attributes') {
            const attributesDiv = document.createElement('div');
            attributesDiv.className = 'attribute-selector';
            attributesDiv.id = 'attribute-selector';

            const attributes = ['Strength', 'Sense', 'Spells'];
            const values = [3, 2, 1];
            let assignments = {};

            attributes.forEach(attr => {
                const attrDiv = document.createElement('div');
                attrDiv.className = 'attribute-item';
                attrDiv.innerHTML = `
                    <h4>${attr}</h4>
                    <p class="attr-description">${this.getAttributeDescription(attr)}</p>
                    <p class="attr-value">Click to assign</p>
                `;

                attrDiv.addEventListener('click', () => {
                    // Get next unassigned value
                    const assigned = Object.values(assignments);
                    const nextValue = values.find(v => !assigned.includes(v));

                    if (nextValue) {
                        // Remove previous assignment for this attr if exists
                        if (assignments[attr]) {
                            const prevValue = assignments[attr];
                            delete assignments[attr];
                            values.push(prevValue);
                        }

                        assignments[attr] = nextValue;
                        values.splice(values.indexOf(nextValue), 1);

                        attrDiv.querySelector('.attr-value').textContent = nextValue;
                        attrDiv.classList.add('selected');
                    }
                });

                attributesDiv.appendChild(attrDiv);
            });

            containerEl.appendChild(attributesDiv);
        }
    }

    getAttributeDescription(attr) {
        const descriptions = {
            'Strength': 'Physical power and combat',
            'Sense': 'Perception and social skills',
            'Spells': 'Magical ability and knowledge'
        };
        return descriptions[attr] || '';
    }

    getCreationInput() {
        const input = document.getElementById('creation-input');
        if (input) {
            return input.value || input.options[input.selectedIndex]?.value;
        }

        // For attributes
        const selector = document.getElementById('attribute-selector');
        if (selector) {
            const attributes = {};
            selector.querySelectorAll('.attribute-item').forEach(item => {
                const name = item.querySelector('h4').textContent.toLowerCase();
                const value = parseInt(item.querySelector('.attr-value').textContent);
                if (!isNaN(value)) {
                    attributes[name] = value;
                }
            });
            if (Object.keys(attributes).length === 3) {
                return attributes;
            }
        }

        return null;
    }

    // Game Screen UI
    updatePlayerUI(player) {
        document.getElementById('player-name').textContent = player.name;
        document.getElementById('player-hp').textContent = player.health;
        document.getElementById('player-tier').textContent = player.subscriptionTier;
    }

    updateLocationUI(location, npcs, items) {
        document.getElementById('location-name').textContent = location.name;
        document.getElementById('location-description').textContent = location.description;

        // Render simple canvas representation
        this.renderLocationCanvas(location, npcs, items);
    }

    renderLocationCanvas(location, npcs, items) {
        const canvas = document.getElementById('game-canvas');
        const ctx = canvas.getContext('2d');

        // Set canvas size
        canvas.width = canvas.offsetWidth;
        canvas.height = canvas.offsetHeight;

        // Clear canvas
        ctx.fillStyle = '#1a1a1a';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Draw location sprite
        ctx.font = '120px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(location.sprite, canvas.width / 2, canvas.height / 3);

        // Draw NPCs
        if (npcs && npcs.length > 0) {
            ctx.font = '40px Arial';
            let x = canvas.width / 4;
            npcs.forEach((npc, index) => {
                ctx.fillText(npc.sprite, x, canvas.height * 2/3);
                x += canvas.width / (npcs.length + 1);
            });
        }

        // Draw items
        if (items && items.length > 0) {
            ctx.font = '30px Arial';
            ctx.fillText('✨', canvas.width - 50, 50);
        }
    }

    showExplorationOptions() {
        EventSystem.emit('request-exploration-options');
    }

    displayExplorationActions(actions) {
        // Show actions as dialogue choices
        const dialogueBox = document.getElementById('dialogue-box');
        const speakerName = document.getElementById('speaker-name');
        const dialogueText = document.getElementById('dialogue-text');
        const choicesDiv = document.getElementById('dialogue-choices');

        speakerName.textContent = 'Actions';
        dialogueText.textContent = 'What would you like to do?';
        choicesDiv.innerHTML = '';

        actions.forEach((action, index) => {
            const button = document.createElement('button');
            button.className = 'dialogue-choice';
            button.textContent = action.label;
            button.addEventListener('click', () => {
                EventSystem.emit('exploration-action', action);
                dialogueBox.classList.add('hidden');
            });
            choicesDiv.appendChild(button);
        });

        dialogueBox.classList.remove('hidden');
    }

    // Dialogue UI
    showDialogue(npc, text, choices) {
        const dialogueBox = document.getElementById('dialogue-box');
        const speakerName = document.getElementById('speaker-name');
        const dialogueText = document.getElementById('dialogue-text');
        const choicesDiv = document.getElementById('dialogue-choices');

        speakerName.textContent = npc.name;
        dialogueText.textContent = text;
        choicesDiv.innerHTML = '';

        choices.forEach((choice, index) => {
            const button = document.createElement('button');
            button.className = 'dialogue-choice';
            button.textContent = choice.text;
            button.addEventListener('click', () => {
                EventSystem.emit('dialogue-choice', index);
            });
            choicesDiv.appendChild(button);
        });

        dialogueBox.classList.remove('hidden');
    }

    hideDialogue() {
        document.getElementById('dialogue-box').classList.add('hidden');
    }

    // Combat UI
    showCombat(combatState) {
        this.showScreen('combat');
        this.updateCombatUI(combatState);
    }

    updateCombatUI(combatState) {
        const { enemy, player, log } = combatState;

        // Enemy
        document.getElementById('enemy-name').textContent = enemy.name;
        document.getElementById('enemy-sprite').textContent = enemy.sprite;
        document.getElementById('enemy-hp').textContent = `${enemy.currentHealth}/${enemy.maxHealth}`;
        const enemyHealthPercent = (enemy.currentHealth / enemy.maxHealth) * 100;
        document.getElementById('enemy-health-bar').style.width = `${enemyHealthPercent}%`;

        // Player
        document.getElementById('combat-player-name').textContent = player.name;
        document.getElementById('combat-player-hp').textContent = `${player.health}/${player.maxHealth}`;
        const playerHealthPercent = (player.health / player.maxHealth) * 100;
        document.getElementById('combat-player-health-bar').style.width = `${playerHealthPercent}%`;

        // Combat log
        const logDiv = document.getElementById('combat-log');
        logDiv.innerHTML = log.map(msg => `<p>${msg}</p>`).join('');
        logDiv.scrollTop = logDiv.scrollHeight;
    }

    // Inventory UI
    updateInventoryUI() {
        const grid = document.getElementById('inventory-grid');
        const details = document.getElementById('inventory-details');

        grid.innerHTML = '';

        EventSystem.emit('get-inventory', (inventory) => {
            if (inventory.length === 0) {
                grid.innerHTML = '<p style="grid-column: 1/-1; text-align: center;">Inventory is empty</p>';
                return;
            }

            inventory.forEach(item => {
                const itemDiv = document.createElement('div');
                itemDiv.className = 'inventory-item';
                itemDiv.innerHTML = `
                    <div class="inventory-item-icon">${item.type === 'consumable' ? '⚗️' : item.type === 'quest' ? '📜' : '🔑'}</div>
                    <div class="inventory-item-name">${item.name}</div>
                    ${item.quantity > 1 ? `<div class="inventory-item-quantity">x${item.quantity}</div>` : ''}
                `;

                itemDiv.addEventListener('click', () => {
                    details.innerHTML = `
                        <h3>${item.name}</h3>
                        <p><strong>Type:</strong> ${item.type}</p>
                        <p>${item.description}</p>
                        ${item.type === 'consumable' ? '<button class="prime-button" onclick="window.useSelectedItem(\'' + item.id + '\')">USE</button>' : ''}
                        <button class="prime-button" style="background: #f44336; margin-top: 0.5rem;" onclick="window.dropSelectedItem(\'' + item.id + '\')">DROP</button>
                    `;
                });

                grid.appendChild(itemDiv);
            });
        });
    }

    // Quests UI
    updateQuestsUI() {
        const questList = document.getElementById('quest-list');

        EventSystem.emit('get-quests', (quests) => {
            questList.innerHTML = '';

            const activeQuests = quests.filter(q => q.status === 'active');

            if (activeQuests.length === 0) {
                questList.innerHTML = '<p>No active quests</p>';
                return;
            }

            activeQuests.forEach(quest => {
                const questDiv = document.createElement('div');
                questDiv.className = 'quest-item';

                const objectives = quest.objectives.map(obj =>
                    `<div class="quest-objective ${obj.completed ? 'completed' : ''}">${obj.completed ? '✓' : '○'} ${obj.description}</div>`
                ).join('');

                questDiv.innerHTML = `
                    <h3>${quest.name}</h3>
                    <p>${quest.description}</p>
                    <div class="quest-objectives">${objectives}</div>
                `;

                questList.appendChild(questDiv);
            });
        });
    }

    // Stats UI
    updateStatsUI() {
        const statsContent = document.getElementById('stats-content');

        EventSystem.emit('get-player-stats', (player) => {
            statsContent.innerHTML = `
                <div class="stat-section">
                    <h3>Identity</h3>
                    <div class="stat-row"><span>Name:</span><span>${player.name}</span></div>
                    <div class="stat-row"><span>Gender Identity:</span><span>${player.genderIdentity}</span></div>
                    <div class="stat-row"><span>Politics:</span><span>${player.politics}</span></div>
                    <div class="stat-row"><span>Hobby:</span><span>${player.hobby}</span></div>
                    <div class="stat-row"><span>Day Job:</span><span>${player.dayJob}</span></div>
                </div>

                <div class="stat-section">
                    <h3>Status</h3>
                    <div class="stat-row"><span>Health:</span><span>${player.health} / ${player.maxHealth}</span></div>
                    <div class="stat-row"><span>Subscription Tier:</span><span>${player.subscriptionTier}</span></div>
                    <div class="stat-row"><span>Magical Source:</span><span>${player.magicalSource}</span></div>
                </div>

                <div class="stat-section">
                    <h3>Attributes</h3>
                    <div class="stat-row"><span>Strength:</span><span>${player.attributes.strength}</span></div>
                    <div class="stat-row"><span>Sense:</span><span>${player.attributes.sense}</span></div>
                    <div class="stat-row"><span>Spells:</span><span>${player.attributes.spells}</span></div>
                </div>

                <div class="stat-section">
                    <h3>Progress</h3>
                    <div class="stat-row"><span>Locations Discovered:</span><span>${player.discoveredLocations.length}</span></div>
                    <div class="stat-row"><span>NPCs Met:</span><span>${player.metNPCs.length}</span></div>
                </div>
            `;

            // Add sacrifice options if health is low
            if (player.health <= 2) {
                EventSystem.emit('get-sacrifice-options', (options) => {
                    if (options.length > 0) {
                        const sacrificeSection = document.createElement('div');
                        sacrificeSection.className = 'stat-section';
                        sacrificeSection.style.borderColor = '#f44336';
                        sacrificeSection.innerHTML = `
                            <h3 style="color: #f44336;">⚠️ Critical Health - Sacrifice Available</h3>
                            <p>Your health is dangerously low. You can sacrifice something important to restore health.</p>
                            <div id="sacrifice-options"></div>
                        `;
                        statsContent.appendChild(sacrificeSection);

                        const optionsDiv = sacrificeSection.querySelector('#sacrifice-options');
                        options.forEach(option => {
                            const optionBtn = document.createElement('button');
                            optionBtn.className = 'prime-button';
                            optionBtn.style.marginTop = '0.5rem';
                            optionBtn.style.background = '#f44336';
                            optionBtn.textContent = `${option.label} (+${option.restore} HP)`;
                            optionBtn.addEventListener('click', () => {
                                if (confirm(`${option.description}\n\nThis action cannot be undone. Proceed?`)) {
                                    EventSystem.emit('perform-sacrifice', option);
                                    this.showScreen('game');
                                }
                            });
                            optionsDiv.appendChild(optionBtn);
                        });
                    }
                });
            }
        });
    }

    // Notifications
    showNotification(message, type = 'info') {
        // Simple notification system
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#f44336' : '#FF9900'};
            color: white;
            padding: 1rem 2rem;
            border-radius: 5px;
            z-index: 1000;
            font-family: 'Courier New', monospace;
            animation: slideDown 0.3s ease-out;
        `;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.animation = 'slideUp 0.3s ease-out';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
}

// Add animation styles
const style = document.createElement('style');
style.textContent = `
    @keyframes slideDown {
        from { top: -100px; opacity: 0; }
        to { top: 20px; opacity: 1; }
    }
    @keyframes slideUp {
        from { top: 20px; opacity: 1; }
        to { top: -100px; opacity: 0; }
    }
`;
document.head.appendChild(style);
