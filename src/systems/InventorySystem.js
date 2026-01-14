class InventorySystem {
    constructor(gameState) {
        this.gameState = gameState;
    }

    getInventory() {
        return this.gameState.player.inventory;
    }

    getItemsByType(type) {
        return this.gameState.player.inventory.filter(item => item.type === type);
    }

    useItem(itemId) {
        const item = this.gameState.player.inventory.find(i => i.id === itemId);
        if (!item) return false;

        switch (item.type) {
            case 'consumable':
                return this.useConsumable(item);
            case 'quest':
                return this.useQuestItem(item);
            case 'key':
                return this.useKey(item);
            default:
                EventSystem.emit('item-used', {item, success: false, message: 'Cannot use this item here.'});
                return false;
        }
    }

    useConsumable(item) {
        if (item.effect === 'heal') {
            if (this.gameState.player.health >= this.gameState.player.maxHealth) {
                EventSystem.emit('item-used', {item, success: false, message: 'Already at full health.'});
                return false;
            }

            this.gameState.modifyHealth(item.power || 2);
            this.gameState.removeItem(item.id, 1);
            EventSystem.emit('item-used', {item, success: true, message: `Restored ${item.power || 2} HP.`});
            return true;
        } else if (item.effect === 'buff') {
            // Temporary buff system would go here
            this.gameState.removeItem(item.id, 1);
            EventSystem.emit('item-used', {item, success: true, message: `Used ${item.name}.`});
            return true;
        }

        return false;
    }

    useQuestItem(item) {
        // Quest items might have special uses in certain contexts
        EventSystem.emit('item-used', {item, success: false, message: 'This is a quest item. Use it at the right location.'});
        return false;
    }

    useKey(item) {
        // Keys are used automatically when encountering locked doors
        EventSystem.emit('item-used', {item, success: false, message: 'Keys are used automatically at locked locations.'});
        return false;
    }

    dropItem(itemId) {
        const item = this.gameState.player.inventory.find(i => i.id === itemId);
        if (!item) return false;

        if (item.type === 'quest' && item.important) {
            EventSystem.emit('item-drop-failed', {item, message: 'Cannot drop important quest items.'});
            return false;
        }

        this.gameState.removeItem(itemId, 1);
        EventSystem.emit('item-dropped', item);
        return true;
    }

    getItemDetails(itemId) {
        const item = this.gameState.player.inventory.find(i => i.id === itemId);
        return item || null;
    }

    hasSpace() {
        // Simple inventory limit
        return this.gameState.player.inventory.length < 50;
    }

    sortInventory(sortBy = 'name') {
        const inventory = this.gameState.player.inventory;

        switch (sortBy) {
            case 'name':
                inventory.sort((a, b) => a.name.localeCompare(b.name));
                break;
            case 'type':
                inventory.sort((a, b) => a.type.localeCompare(b.type));
                break;
            case 'value':
                inventory.sort((a, b) => (b.value || 0) - (a.value || 0));
                break;
        }

        EventSystem.emit('inventory-sorted', sortBy);
    }
}
