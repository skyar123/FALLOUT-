// Main entry point for LICHCRAFT

// Initialize game when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    console.log('%c🏴 LICHCRAFT 🏴', 'font-size: 24px; color: #FF9900; font-weight: bold;');
    console.log('%cA tale of transformation in the age of Prime', 'font-size: 14px; color: #37475A;');
    console.log('%cDeveloped with resistance ✊', 'font-size: 12px; color: #4CAF50;');

    // Initialize the game
    window.game = new Game();

    // Add some debug commands for development
    window.debug = {
        addHealth: (amount) => {
            window.game.state.modifyHealth(amount);
            window.game.ui.updatePlayerUI(window.game.state.player);
            console.log(`Added ${amount} health`);
        },

        addItem: (itemId) => {
            const item = GameData.items[itemId];
            if (item) {
                window.game.state.addItem(item);
                console.log(`Added ${item.name}`);
            } else {
                console.error('Item not found:', itemId);
            }
        },

        teleport: (locationId) => {
            if (GameData.locations[locationId]) {
                window.game.state.changeLocation(locationId);
                console.log(`Teleported to ${locationId}`);
            } else {
                console.error('Location not found:', locationId);
            }
        },

        completeQuest: (questId) => {
            const quest = window.game.state.player.quests.find(q => q.id === questId);
            if (quest) {
                quest.objectives.forEach((_, index) => {
                    window.game.state.updateQuestObjective(questId, index);
                });
                console.log(`Completed quest: ${questId}`);
            } else {
                console.error('Quest not found:', questId);
            }
        },

        setFlag: (flag, value = true) => {
            window.game.state.setFlag(flag, value);
            console.log(`Set flag ${flag} to ${value}`);
        },

        listItems: () => {
            console.log('Available items:', Object.keys(GameData.items));
        },

        listLocations: () => {
            console.log('Available locations:', Object.keys(GameData.locations));
        },

        listNPCs: () => {
            console.log('Available NPCs:', Object.keys(GameData.npcs));
        },

        listEnemies: () => {
            console.log('Available enemies:', Object.keys(GameData.enemies));
        },

        startCombat: (enemyId) => {
            const enemy = GameData.enemies[enemyId];
            if (enemy) {
                window.game.systems.combat.startCombat(enemy);
                console.log(`Started combat with ${enemy.name}`);
            } else {
                console.error('Enemy not found:', enemyId);
            }
        },

        save: () => {
            window.game.state.saveGame();
            console.log('Game saved');
        },

        load: () => {
            window.game.state.loadGame();
            console.log('Game loaded');
        },

        reset: () => {
            if (confirm('Reset all game data?')) {
                localStorage.removeItem('lichcraft_save');
                location.reload();
            }
        }
    };

    console.log('%cDebug commands available via window.debug', 'color: #FF9900;');
    console.log('Examples: debug.addHealth(5), debug.addItem("health_pack"), debug.teleport("underground_market")');

    // Service Worker for PWA (optional - for mobile deployment)
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/sw.js').catch(() => {
            // Service worker not available, that's okay
        });
    }

    // Prevent zoom on mobile double-tap
    document.addEventListener('touchend', (e) => {
        const now = Date.now();
        if (window.lastTouchEnd && now - window.lastTouchEnd < 300) {
            e.preventDefault();
        }
        window.lastTouchEnd = now;
    }, false);

    // Handle window resize for canvas
    window.addEventListener('resize', () => {
        if (window.game.ui.currentScreen === 'game') {
            const location = window.game.systems.exploration.currentLocation;
            if (location) {
                const state = window.game.systems.exploration.getLocationState();
                window.game.ui.updateLocationUI(location, state.npcs, state.items);
            }
        }
    });

    console.log('%c✨ Game initialized. Click START to begin your journey.', 'color: #4CAF50; font-weight: bold;');
});

// Handle page visibility changes (pause/resume)
document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
        // Auto-save when tab becomes hidden
        if (window.game && window.game.state) {
            window.game.state.saveGame();
        }
    }
});

// Auto-save every 2 minutes
setInterval(() => {
    if (window.game && window.game.state && window.game.state.gamePhase !== 'loading') {
        window.game.state.saveGame();
        console.log('Auto-saved');
    }
}, 120000);
