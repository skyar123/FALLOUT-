class RenderEngine {
    constructor() {
        this.canvas = document.getElementById('game-canvas');
        this.ctx = this.canvas.getContext('2d');
        this.tileSize = 64;
        this.playerPos = { x: 5, y: 5 };
        this.cameraOffset = { x: 0, y: 0 };
        this.animationFrame = 0;
        this.lastFrameTime = 0;

        this.setupCanvas();
    }

    setupCanvas() {
        // Set canvas to full size
        this.resizeCanvas();
        window.addEventListener('resize', () => this.resizeCanvas());
    }

    resizeCanvas() {
        const container = this.canvas.parentElement;
        this.canvas.width = container.offsetWidth;
        this.canvas.height = container.offsetHeight;
    }

    // Main render function
    render(location, npcs, items, player) {
        this.clear();

        // Calculate grid dimensions
        const gridWidth = Math.ceil(this.canvas.width / this.tileSize);
        const gridHeight = Math.ceil(this.canvas.height / this.tileSize);

        // Draw location background
        this.drawLocationBackground(location);

        // Draw ground tiles
        this.drawGroundTiles(gridWidth, gridHeight, location);

        // Draw location features
        this.drawLocationFeatures(location);

        // Draw items in the scene
        this.drawItems(items);

        // Draw NPCs
        this.drawNPCs(npcs);

        // Draw player character
        this.drawPlayer(player);

        // Draw UI overlay
        this.drawUIOverlay(location);

        // Update animation frame
        this.animationFrame++;
    }

    clear() {
        this.ctx.fillStyle = '#0a0a0a';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    }

    drawLocationBackground(location) {
        // Create gradient based on location type
        const gradient = this.ctx.createLinearGradient(0, 0, 0, this.canvas.height);

        switch(location.id) {
            case 'home':
                gradient.addColorStop(0, '#1a1a2e');
                gradient.addColorStop(1, '#16213e');
                break;
            case 'city_streets':
                gradient.addColorStop(0, '#2d1b3d');
                gradient.addColorStop(1, '#1a0f2e');
                break;
            case 'underground_market':
                gradient.addColorStop(0, '#0f0f0f');
                gradient.addColorStop(1, '#1a1a00');
                break;
            case 'abandoned_library':
                gradient.addColorStop(0, '#1a1a1a');
                gradient.addColorStop(1, '#2d2d2d');
                break;
            case 'abandoned_district':
                gradient.addColorStop(0, '#1a0f0f');
                gradient.addColorStop(1, '#0f1a0f');
                break;
            case 'prime_facility':
                gradient.addColorStop(0, '#e8f4f8');
                gradient.addColorStop(1, '#b8d4e8');
                break;
            default:
                gradient.addColorStop(0, '#1a1a1a');
                gradient.addColorStop(1, '#0a0a0a');
        }

        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    }

    drawGroundTiles(gridWidth, gridHeight, location) {
        const isDark = location.id !== 'prime_facility';

        for (let y = 0; y < gridHeight; y++) {
            for (let x = 0; x < gridWidth; x++) {
                const px = x * this.tileSize;
                const py = y * this.tileSize;

                // Draw tile
                if (isDark) {
                    this.ctx.fillStyle = (x + y) % 2 === 0 ? '#1a1a1a' : '#151515';
                } else {
                    this.ctx.fillStyle = (x + y) % 2 === 0 ? '#ffffff' : '#f0f0f0';
                }

                this.ctx.fillRect(px, py, this.tileSize, this.tileSize);

                // Draw grid lines
                this.ctx.strokeStyle = isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.05)';
                this.ctx.lineWidth = 1;
                this.ctx.strokeRect(px, py, this.tileSize, this.tileSize);
            }
        }
    }

    drawLocationFeatures(location) {
        // Draw large location icon in background
        this.ctx.save();
        this.ctx.globalAlpha = 0.15;
        this.ctx.font = `${this.canvas.height * 0.4}px Arial`;
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillStyle = '#ffffff';
        this.ctx.fillText(
            location.sprite,
            this.canvas.width / 2,
            this.canvas.height / 2
        );
        this.ctx.restore();

        // Draw some decorative elements based on location
        this.drawLocationDecorations(location);
    }

    drawLocationDecorations(location) {
        const decorations = {
            'city_streets': ['🏢', '🚗', '🚶', '📡'],
            'underground_market': ['📦', '💡', '🔧', '💊'],
            'abandoned_library': ['📚', '🕯️', '🪑', '🗝️'],
            'abandoned_district': ['🏚️', '🌿', '🪨', '🚪'],
            'prime_facility': ['💉', '🩺', '💊', '🏥'],
            'safe_house': ['🛋️', '🎨', '🏳️‍⚧️', '☕'],
            'ritual_site': ['🕯️', '⭐', '🔮', '✨']
        };

        const items = decorations[location.id] || [];

        items.forEach((emoji, index) => {
            const angle = (index / items.length) * Math.PI * 2;
            const radius = Math.min(this.canvas.width, this.canvas.height) * 0.35;
            const x = this.canvas.width / 2 + Math.cos(angle) * radius;
            const y = this.canvas.height / 2 + Math.sin(angle) * radius;

            this.ctx.font = '48px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';
            this.ctx.globalAlpha = 0.3;
            this.ctx.fillText(emoji, x, y);
            this.ctx.globalAlpha = 1;
        });
    }

    drawItems(items) {
        if (!items || items.length === 0) return;

        items.forEach((item, index) => {
            const x = this.canvas.width * 0.2 + (index * 80);
            const y = this.canvas.height * 0.2;

            // Draw glow effect
            const glowSize = 60 + Math.sin(this.animationFrame * 0.1 + index) * 5;
            const gradient = this.ctx.createRadialGradient(x, y, 0, x, y, glowSize);
            gradient.addColorStop(0, 'rgba(255, 215, 0, 0.3)');
            gradient.addColorStop(1, 'rgba(255, 215, 0, 0)');
            this.ctx.fillStyle = gradient;
            this.ctx.fillRect(x - glowSize, y - glowSize, glowSize * 2, glowSize * 2);

            // Draw item icon
            this.ctx.font = '40px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';
            this.ctx.fillStyle = '#FFD700';
            this.ctx.fillText('✨', x, y);

            // Draw item name
            this.ctx.font = '14px "Courier New"';
            this.ctx.fillStyle = '#FFD700';
            this.ctx.fillText(item.name, x, y + 40);
        });
    }

    drawNPCs(npcs) {
        if (!npcs || npcs.length === 0) return;

        const spacing = Math.min(150, this.canvas.width / (npcs.length + 2));

        npcs.forEach((npc, index) => {
            const x = this.canvas.width * 0.5 + (index - npcs.length / 2) * spacing;
            const y = this.canvas.height * 0.55;

            // Draw shadow
            this.ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
            this.ctx.beginPath();
            this.ctx.ellipse(x, y + 70, 30, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();

            // Draw NPC sprite with bounce animation
            const bounce = Math.sin(this.animationFrame * 0.05 + index) * 5;

            this.ctx.font = '72px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';

            // Draw outline
            this.ctx.strokeStyle = '#000';
            this.ctx.lineWidth = 4;
            this.ctx.strokeText(npc.sprite, x, y + bounce);

            // Draw sprite
            this.ctx.fillStyle = '#ffffff';
            this.ctx.fillText(npc.sprite, x, y + bounce);

            // Draw name
            this.ctx.font = 'bold 16px "Courier New"';
            this.ctx.fillStyle = '#FF9900';
            this.ctx.strokeStyle = '#000';
            this.ctx.lineWidth = 3;
            this.ctx.strokeText(npc.name, x, y + 90);
            this.ctx.fillText(npc.name, x, y + 90);

            // Draw interaction prompt
            this.ctx.font = '14px "Courier New"';
            this.ctx.fillStyle = '#4CAF50';
            this.ctx.fillText('▲ TALK', x, y + 110);
        });
    }

    drawPlayer(player) {
        const x = this.canvas.width / 2;
        const y = this.canvas.height * 0.75;

        // Draw shadow
        this.ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
        this.ctx.beginPath();
        this.ctx.ellipse(x, y + 50, 35, 12, 0, 0, Math.PI * 2);
        this.ctx.fill();

        // Idle animation
        const bob = Math.sin(this.animationFrame * 0.08) * 3;

        // Draw player sprite (based on gender identity)
        let playerSprite = '🧑';
        if (player.genderIdentity) {
            if (player.genderIdentity.includes('Woman')) playerSprite = '👩';
            else if (player.genderIdentity.includes('Man')) playerSprite = '👨';
            else playerSprite = '🧑';
        }

        this.ctx.font = '80px Arial';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';

        // Draw player outline
        this.ctx.strokeStyle = '#FF9900';
        this.ctx.lineWidth = 4;
        this.ctx.strokeText(playerSprite, x, y + bob);

        // Draw player
        this.ctx.fillStyle = '#ffffff';
        this.ctx.fillText(playerSprite, x, y + bob);

        // Draw player name
        this.ctx.font = 'bold 18px "Courier New"';
        this.ctx.fillStyle = '#FF9900';
        this.ctx.strokeStyle = '#000';
        this.ctx.lineWidth = 3;
        this.ctx.strokeText(player.name, x, y + 70);
        this.ctx.fillText(player.name, x, y + 70);

        // Draw health bar
        this.drawHealthBar(x, y - 50, player.health, player.maxHealth);
    }

    drawHealthBar(x, y, current, max) {
        const width = 100;
        const height = 12;

        // Background
        this.ctx.fillStyle = '#000';
        this.ctx.fillRect(x - width/2 - 2, y - 2, width + 4, height + 4);

        // Health bar background
        this.ctx.fillStyle = '#2d2d2d';
        this.ctx.fillRect(x - width/2, y, width, height);

        // Health bar fill
        const healthPercent = current / max;
        const fillWidth = width * healthPercent;

        const gradient = this.ctx.createLinearGradient(x - width/2, y, x + width/2, y);
        if (healthPercent > 0.5) {
            gradient.addColorStop(0, '#4CAF50');
            gradient.addColorStop(1, '#81C784');
        } else if (healthPercent > 0.25) {
            gradient.addColorStop(0, '#FFC107');
            gradient.addColorStop(1, '#FFD54F');
        } else {
            gradient.addColorStop(0, '#f44336');
            gradient.addColorStop(1, '#ef5350');
        }

        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(x - width/2, y, fillWidth, height);

        // Health text
        this.ctx.font = 'bold 12px "Courier New"';
        this.ctx.textAlign = 'center';
        this.ctx.fillStyle = '#fff';
        this.ctx.strokeStyle = '#000';
        this.ctx.lineWidth = 2;
        this.ctx.strokeText(`${current}/${max}`, x, y + height/2 + 1);
        this.ctx.fillText(`${current}/${max}`, x, y + height/2 + 1);
    }

    drawUIOverlay(location) {
        // Draw location name at top
        const nameY = 40;

        this.ctx.font = 'bold 24px "Courier New"';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';

        // Background
        const textWidth = this.ctx.measureText(location.name).width;
        this.ctx.fillStyle = 'rgba(35, 47, 62, 0.9)';
        this.ctx.fillRect(
            this.canvas.width / 2 - textWidth / 2 - 20,
            nameY - 20,
            textWidth + 40,
            40
        );

        // Text
        this.ctx.strokeStyle = '#000';
        this.ctx.lineWidth = 3;
        this.ctx.strokeText(location.name, this.canvas.width / 2, nameY);
        this.ctx.fillStyle = '#FF9900';
        this.ctx.fillText(location.name, this.canvas.width / 2, nameY);

        // Draw hint text at bottom
        this.ctx.font = '14px "Courier New"';
        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
        this.ctx.textAlign = 'center';
        this.ctx.fillText('Press EXPLORE to interact', this.canvas.width / 2, this.canvas.height - 20);
    }

    // Combat rendering
    renderCombat(player, enemy, log) {
        this.clear();

        // Draw combat arena background
        const gradient = this.ctx.createLinearGradient(0, 0, 0, this.canvas.height);
        gradient.addColorStop(0, '#2a0a0a');
        gradient.addColorStop(1, '#0a0a0a');
        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

        // Draw enemy (top)
        this.drawCombatEnemy(enemy);

        // Draw player (bottom)
        this.drawCombatPlayer(player);

        // Draw combat effects
        this.drawCombatEffects();
    }

    drawCombatEnemy(enemy) {
        const x = this.canvas.width / 2;
        const y = this.canvas.height * 0.25;

        // Pulsing threat effect
        const pulse = Math.sin(this.animationFrame * 0.1) * 10;

        // Draw enemy shadow
        this.ctx.fillStyle = 'rgba(255, 0, 0, 0.2)';
        this.ctx.beginPath();
        this.ctx.ellipse(x, y + 100, 60 + pulse, 20, 0, 0, Math.PI * 2);
        this.ctx.fill();

        // Draw enemy sprite
        this.ctx.font = `${120 + pulse}px Arial`;
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';

        // Red outline
        this.ctx.strokeStyle = '#ff0000';
        this.ctx.lineWidth = 5;
        this.ctx.strokeText(enemy.sprite, x, y);

        // Enemy sprite
        this.ctx.fillStyle = '#ffffff';
        this.ctx.fillText(enemy.sprite, x, y);

        // Enemy name
        this.ctx.font = 'bold 20px "Courier New"';
        this.ctx.fillStyle = '#ff4444';
        this.ctx.strokeStyle = '#000';
        this.ctx.lineWidth = 3;
        this.ctx.strokeText(enemy.name, x, y - 100);
        this.ctx.fillText(enemy.name, x, y - 100);

        // Enemy health bar
        this.drawHealthBar(x, y + 120, enemy.currentHealth, enemy.maxHealth);
    }

    drawCombatPlayer(player) {
        const x = this.canvas.width / 2;
        const y = this.canvas.height * 0.7;

        // Draw player sprite
        let playerSprite = '🧑';
        if (player.genderIdentity) {
            if (player.genderIdentity.includes('Woman')) playerSprite = '👩';
            else if (player.genderIdentity.includes('Man')) playerSprite = '👨';
        }

        this.ctx.font = '100px Arial';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';

        // Blue outline
        this.ctx.strokeStyle = '#00aaff';
        this.ctx.lineWidth = 4;
        this.ctx.strokeText(playerSprite, x, y);

        // Player sprite
        this.ctx.fillStyle = '#ffffff';
        this.ctx.fillText(playerSprite, x, y);

        // Player health bar
        this.drawHealthBar(x, y - 70, player.health, player.maxHealth);
    }

    drawCombatEffects() {
        // Draw impact particles if needed
        if (this.combatEffect) {
            const { type, frame, maxFrames, x, y } = this.combatEffect;
            const progress = frame / maxFrames;

            if (type === 'hit') {
                const size = 30 * (1 - progress);
                this.ctx.fillStyle = `rgba(255, 100, 100, ${1 - progress})`;
                this.ctx.beginPath();
                this.ctx.arc(x, y, size, 0, Math.PI * 2);
                this.ctx.fill();
            } else if (type === 'spell') {
                const particles = 8;
                for (let i = 0; i < particles; i++) {
                    const angle = (i / particles) * Math.PI * 2 + progress * Math.PI;
                    const dist = progress * 100;
                    const px = x + Math.cos(angle) * dist;
                    const py = y + Math.sin(angle) * dist;

                    this.ctx.fillStyle = `rgba(150, 100, 255, ${1 - progress})`;
                    this.ctx.beginPath();
                    this.ctx.arc(px, py, 10 * (1 - progress), 0, Math.PI * 2);
                    this.ctx.fill();
                }
            }

            this.combatEffect.frame++;
            if (this.combatEffect.frame >= maxFrames) {
                this.combatEffect = null;
            }
        }
    }

    showCombatEffect(type, x, y) {
        this.combatEffect = {
            type: type,
            frame: 0,
            maxFrames: 30,
            x: x,
            y: y
        };
    }

    // Animation loop
    startAnimation(renderCallback) {
        const animate = (timestamp) => {
            if (timestamp - this.lastFrameTime > 16) { // ~60 FPS
                renderCallback();
                this.lastFrameTime = timestamp;
            }
            this.animationId = requestAnimationFrame(animate);
        };
        this.animationId = requestAnimationFrame(animate);
    }

    stopAnimation() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
    }
}
