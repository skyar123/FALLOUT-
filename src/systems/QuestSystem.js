class QuestSystem {
    constructor(gameState) {
        this.gameState = gameState;
    }

    getActiveQuests() {
        return this.gameState.player.quests.filter(q => q.status === 'active');
    }

    getCompletedQuests() {
        return this.gameState.player.quests.filter(q => q.status === 'completed');
    }

    getQuest(questId) {
        return this.gameState.player.quests.find(q => q.id === questId);
    }

    checkQuestProgress(questId) {
        const quest = this.getQuest(questId);
        if (!quest) return null;

        const completedObjectives = quest.objectives.filter(obj => obj.completed).length;
        const totalObjectives = quest.objectives.length;

        return {
            quest: quest,
            progress: completedObjectives,
            total: totalObjectives,
            percentage: Math.floor((completedObjectives / totalObjectives) * 100)
        };
    }

    // Called when player performs actions that might progress quests
    checkObjectiveProgress(actionType, actionData) {
        const activeQuests = this.getActiveQuests();

        activeQuests.forEach(quest => {
            quest.objectives.forEach((objective, index) => {
                if (objective.completed) return;

                let shouldComplete = false;

                switch (objective.type) {
                    case 'collect':
                        if (actionType === 'item-collected' && actionData.id === objective.target) {
                            shouldComplete = true;
                        }
                        break;

                    case 'talk':
                        if (actionType === 'npc-talked' && actionData.id === objective.target) {
                            shouldComplete = true;
                        }
                        break;

                    case 'defeat':
                        if (actionType === 'enemy-defeated' && actionData.id === objective.target) {
                            shouldComplete = true;
                        }
                        break;

                    case 'visit':
                        if (actionType === 'location-visited' && actionData === objective.target) {
                            shouldComplete = true;
                        }
                        break;

                    case 'find':
                        if (actionType === 'item-found' && actionData.id === objective.target) {
                            shouldComplete = true;
                        }
                        break;

                    case 'acquire':
                        if (this.gameState.hasItem(objective.target)) {
                            shouldComplete = true;
                        }
                        break;
                }

                if (shouldComplete) {
                    this.gameState.updateQuestObjective(quest.id, index);
                }
            });
        });
    }

    // The main quest for lichdom
    initializeMainQuest() {
        const mainQuest = {
            id: 'quest_lichdom',
            name: 'Path to Lichdom',
            description: 'Seek the three components necessary to perform the transformation ritual and become a lich, transcending mortality to outlast Prime\'s healthcare system.',
            objectives: [
                {
                    type: 'acquire',
                    target: 'spell_source',
                    description: 'Find the Spell Source - ancient knowledge of transformation',
                    completed: false
                },
                {
                    type: 'acquire',
                    target: 'rare_component',
                    description: 'Obtain the Rare Component - a magical artifact of power',
                    completed: false
                },
                {
                    type: 'acquire',
                    target: 'magical_location',
                    description: 'Discover the Magical Location - a place of power for the ritual',
                    completed: false
                }
            ],
            rewards: {
                title: 'Lich',
                unlocks: 'lichdom_ritual'
            }
        };

        this.gameState.addQuest(mainQuest);
    }

    // Sacrifice system for low health
    performSacrifice(sacrificeType, sacrificeTarget) {
        let healthRestored = 0;
        let sacrificeDescription = '';

        switch (sacrificeType) {
            case 'possession':
                // Sacrifice an item
                if (this.gameState.hasItem(sacrificeTarget)) {
                    this.gameState.removeItem(sacrificeTarget);
                    healthRestored = 2;
                    sacrificeDescription = `You sacrifice your ${sacrificeTarget}, channeling its essence into vital energy.`;
                }
                break;

            case 'relationship':
                // Sacrifice relationship with an NPC
                this.gameState.setFlag(`sacrificed_relationship_${sacrificeTarget}`);
                healthRestored = 3;
                sacrificeDescription = `You sever your bond with ${sacrificeTarget}, trading connection for survival.`;
                break;

            case 'memory':
                // Sacrifice a memory/experience
                this.gameState.setFlag(`sacrificed_memory_${sacrificeTarget}`);
                healthRestored = 2;
                sacrificeDescription = `You burn away cherished memories, fueling your body with the emotional energy.`;
                break;

            case 'belief':
                // Sacrifice a core belief
                this.gameState.setFlag(`sacrificed_belief_${sacrificeTarget}`);
                healthRestored = 4;
                sacrificeDescription = `You abandon a fundamental belief, feeling both lighter and emptier.`;
                break;

            case 'humanity':
                // Sacrifice part of humanity (major sacrifice)
                this.gameState.setFlag(`sacrificed_humanity_${sacrificeTarget}`);
                healthRestored = 5;
                sacrificeDescription = `You sacrifice a piece of your humanity. You feel stronger, but also... different.`;
                // This could reduce max HP or change gameplay
                break;
        }

        if (healthRestored > 0) {
            this.gameState.modifyHealth(healthRestored);
            EventSystem.emit('sacrifice-performed', {
                type: sacrificeType,
                target: sacrificeTarget,
                healthRestored: healthRestored,
                description: sacrificeDescription
            });
            return true;
        }

        return false;
    }

    getSacrificeOptions() {
        const options = [];

        // Possessions
        const valuableItems = this.gameState.player.inventory.filter(item =>
            item.type !== 'quest' && item.value > 10
        );
        valuableItems.forEach(item => {
            options.push({
                type: 'possession',
                target: item.id,
                label: `Sacrifice ${item.name}`,
                description: `Burn this item to restore 2 HP`,
                restore: 2
            });
        });

        // Relationships
        const metNPCs = this.gameState.player.metNPCs.filter(npcId =>
            !this.gameState.getFlag(`sacrificed_relationship_${npcId}`)
        );
        metNPCs.forEach(npcId => {
            const npc = GameData.npcs[npcId];
            if (npc) {
                options.push({
                    type: 'relationship',
                    target: npcId,
                    label: `Sacrifice relationship with ${npc.name}`,
                    description: `Sever this bond to restore 3 HP`,
                    restore: 3
                });
            }
        });

        // Core beliefs/values (based on character creation)
        if (!this.gameState.getFlag('sacrificed_belief_politics')) {
            options.push({
                type: 'belief',
                target: 'politics',
                label: `Sacrifice your ${this.gameState.player.politics} beliefs`,
                description: `Abandon your political convictions to restore 4 HP`,
                restore: 4
            });
        }

        if (!this.gameState.getFlag('sacrificed_belief_hobby')) {
            options.push({
                type: 'belief',
                target: 'hobby',
                label: `Sacrifice your passion for ${this.gameState.player.hobby}`,
                description: `Give up what you love to restore 4 HP`,
                restore: 4
            });
        }

        // Humanity (major sacrifice)
        if (!this.gameState.getFlag('sacrificed_humanity_emotions')) {
            options.push({
                type: 'humanity',
                target: 'emotions',
                label: 'Sacrifice your emotional capacity',
                description: 'Become cold and calculating to restore 5 HP (permanent effects)',
                restore: 5
            });
        }

        return options;
    }
}
