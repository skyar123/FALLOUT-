class DialogueSystem {
    constructor(gameState) {
        this.gameState = gameState;
        this.currentDialogue = null;
        this.currentNode = null;
    }

    startDialogue(npc, dialogueTree) {
        this.currentDialogue = {
            npc: npc,
            tree: dialogueTree
        };

        // Mark NPC as met
        this.gameState.markNPCMet(npc.id);

        // Start at root node or greeting based on if met before
        const startNode = this.gameState.hasMetNPC(npc.id) ? 'greeting_repeat' : 'greeting';
        this.goToNode(startNode);

        EventSystem.emit('dialogue-started', {npc, node: this.currentNode});
    }

    goToNode(nodeId) {
        const node = this.currentDialogue.tree[nodeId];
        if (!node) {
            console.error('Dialogue node not found:', nodeId);
            this.endDialogue();
            return;
        }

        this.currentNode = {
            id: nodeId,
            ...node
        };

        // Filter choices based on conditions
        if (this.currentNode.choices) {
            this.currentNode.availableChoices = this.currentNode.choices.filter(choice => {
                if (!choice.condition) return true;
                return this.evaluateCondition(choice.condition);
            });
        }

        EventSystem.emit('dialogue-node-changed', this.currentNode);
    }

    evaluateCondition(condition) {
        // Evaluate various condition types
        if (condition.hasItem) {
            return this.gameState.hasItem(condition.hasItem);
        }
        if (condition.hasQuest) {
            return this.gameState.hasQuest(condition.hasQuest);
        }
        if (condition.questCompleted) {
            return this.gameState.isQuestCompleted(condition.questCompleted);
        }
        if (condition.flag) {
            return this.gameState.getFlag(condition.flag);
        }
        if (condition.attribute) {
            const value = this.gameState.player.attributes[condition.attribute];
            return value >= (condition.min || 0);
        }
        if (condition.health) {
            return this.gameState.player.health >= condition.health;
        }
        return true;
    }

    selectChoice(choiceIndex) {
        if (!this.currentNode || !this.currentNode.availableChoices) return;

        const choice = this.currentNode.availableChoices[choiceIndex];
        if (!choice) return;

        // Execute choice effects
        if (choice.effects) {
            this.executeEffects(choice.effects);
        }

        // Move to next node or end dialogue
        if (choice.next) {
            this.goToNode(choice.next);
        } else if (choice.action === 'end') {
            this.endDialogue();
        } else if (choice.action === 'trade') {
            EventSystem.emit('open-trade', this.currentDialogue.npc);
            this.endDialogue();
        } else if (choice.action === 'combat') {
            EventSystem.emit('start-combat-from-dialogue', choice.enemy);
            this.endDialogue();
        }
    }

    executeEffects(effects) {
        if (effects.addItem) {
            this.gameState.addItem(effects.addItem);
        }
        if (effects.removeItem) {
            this.gameState.removeItem(effects.removeItem);
        }
        if (effects.addQuest) {
            this.gameState.addQuest(effects.addQuest);
        }
        if (effects.updateQuest) {
            this.gameState.updateQuestObjective(
                effects.updateQuest.questId,
                effects.updateQuest.objectiveIndex
            );
        }
        if (effects.setFlag) {
            this.gameState.setFlag(effects.setFlag, effects.flagValue !== false);
        }
        if (effects.modifyHealth) {
            this.gameState.modifyHealth(effects.modifyHealth);
        }
        if (effects.teleport) {
            this.gameState.changeLocation(effects.teleport);
        }
    }

    endDialogue() {
        this.currentDialogue = null;
        this.currentNode = null;
        EventSystem.emit('dialogue-ended');
    }

    getCurrentState() {
        if (!this.currentDialogue || !this.currentNode) return null;

        return {
            npc: this.currentDialogue.npc,
            text: this.currentNode.text,
            choices: this.currentNode.availableChoices || []
        };
    }
}
