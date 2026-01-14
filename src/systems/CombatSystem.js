class CombatSystem {
    constructor(gameState) {
        this.gameState = gameState;
        this.currentEnemy = null;
        this.turnPhase = 'player'; // player, enemy, resolve
        this.combatLog = [];
    }

    startCombat(enemy) {
        this.currentEnemy = {
            ...enemy,
            currentHealth: enemy.maxHealth
        };
        this.combatLog = [];
        this.turnPhase = 'player';
        this.addLog(`Combat started with ${enemy.name}!`);
        EventSystem.emit('combat-started', this.currentEnemy);
    }

    addLog(message) {
        this.combatLog.push(message);
        if (this.combatLog.length > 10) {
            this.combatLog.shift();
        }
        EventSystem.emit('combat-log-updated', this.combatLog);
    }

    playerAttack() {
        if (this.turnPhase !== 'player') return;

        const check = this.gameState.rollCheck('strength', this.currentEnemy.defense || 8);

        if (check.success) {
            const damage = Math.floor(Math.random() * 3) + this.gameState.player.attributes.strength + 1;
            this.currentEnemy.currentHealth -= damage;
            this.addLog(`You attack! Roll: ${check.roll} + ${this.gameState.player.attributes.strength} = ${check.total}`);
            this.addLog(`Hit! Dealt ${damage} damage to ${this.currentEnemy.name}.`);
        } else {
            this.addLog(`You attack! Roll: ${check.roll} + ${this.gameState.player.attributes.strength} = ${check.total}`);
            this.addLog(`Miss! Your attack failed.`);
        }

        this.checkCombatEnd() || this.enemyTurn();
    }

    playerSpell() {
        if (this.turnPhase !== 'player') return;

        const check = this.gameState.rollCheck('spells', this.currentEnemy.defense || 8);

        if (check.success) {
            const damage = Math.floor(Math.random() * 4) + this.gameState.player.attributes.spells + 2;
            this.currentEnemy.currentHealth -= damage;
            this.addLog(`You cast a spell! Roll: ${check.roll} + ${this.gameState.player.attributes.spells} = ${check.total}`);
            this.addLog(`Critical hit! Dealt ${damage} magical damage.`);
        } else {
            this.addLog(`You cast a spell! Roll: ${check.roll} + ${this.gameState.player.attributes.spells} = ${check.total}`);
            this.addLog(`Fizzle! Your spell failed.`);
        }

        this.checkCombatEnd() || this.enemyTurn();
    }

    playerUseItem(item) {
        if (this.turnPhase !== 'player') return;

        if (item.effect === 'heal') {
            const healAmount = item.power || 2;
            this.gameState.modifyHealth(healAmount);
            this.addLog(`You used ${item.name} and restored ${healAmount} HP.`);
            this.gameState.removeItem(item.id, 1);
        } else if (item.effect === 'damage') {
            this.currentEnemy.currentHealth -= item.power;
            this.addLog(`You used ${item.name} on ${this.currentEnemy.name} for ${item.power} damage!`);
            this.gameState.removeItem(item.id, 1);
        }

        this.checkCombatEnd() || this.enemyTurn();
    }

    playerFlee() {
        if (this.turnPhase !== 'player') return;

        const check = this.gameState.rollCheck('sense', 10);

        if (check.success) {
            this.addLog(`You successfully fled from combat!`);
            EventSystem.emit('combat-fled');
            this.endCombat(false);
        } else {
            this.addLog(`Failed to flee! Roll: ${check.roll} + ${this.gameState.player.attributes.sense} = ${check.total}`);
            this.enemyTurn();
        }
    }

    enemyTurn() {
        this.turnPhase = 'enemy';

        setTimeout(() => {
            // Simple AI: 70% attack, 30% special
            const action = Math.random() < 0.7 ? 'attack' : 'special';

            if (action === 'attack') {
                const damage = Math.floor(Math.random() * 3) + (this.currentEnemy.attack || 1);
                this.gameState.modifyHealth(-damage);
                this.addLog(`${this.currentEnemy.name} attacks! Dealt ${damage} damage.`);
            } else if (this.currentEnemy.specialAttack) {
                this.addLog(`${this.currentEnemy.name} uses ${this.currentEnemy.specialAttack}!`);
                const damage = Math.floor(Math.random() * 4) + (this.currentEnemy.attack || 1) + 1;
                this.gameState.modifyHealth(-damage);
                this.addLog(`Special attack! Dealt ${damage} damage.`);
            }

            if (this.gameState.player.health <= 0) {
                this.addLog('You have been defeated!');
                EventSystem.emit('combat-lost');
                this.endCombat(false);
            } else {
                this.turnPhase = 'player';
                EventSystem.emit('combat-turn-start');
            }
        }, 1500);
    }

    checkCombatEnd() {
        if (this.currentEnemy.currentHealth <= 0) {
            this.addLog(`${this.currentEnemy.name} has been defeated!`);

            // Drop rewards
            if (this.currentEnemy.drops) {
                this.currentEnemy.drops.forEach(drop => {
                    if (Math.random() < (drop.chance || 1)) {
                        this.gameState.addItem(drop.item);
                        this.addLog(`Obtained: ${drop.item.name}`);
                    }
                });
            }

            EventSystem.emit('combat-won', this.currentEnemy);
            this.endCombat(true);
            return true;
        }
        return false;
    }

    endCombat(victory) {
        setTimeout(() => {
            this.currentEnemy = null;
            this.combatLog = [];
            EventSystem.emit('combat-ended', victory);
        }, 2000);
    }

    getCombatState() {
        return {
            enemy: this.currentEnemy,
            player: {
                health: this.gameState.player.health,
                maxHealth: this.gameState.player.maxHealth,
                name: this.gameState.player.name
            },
            turnPhase: this.turnPhase,
            log: this.combatLog
        };
    }
}
