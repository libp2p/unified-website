/**
 * Logo Wall Animation Controller
 *
 * Creates smooth, individual card animations for the logo wall.
 * Cards animate continuously from right to left, with each card
 * being created/removed individually rather than as a group.
 */

class LogoWallRow {
    constructor(rowElement, logos, speed, rowIndex, basePath) {
        this.row = rowElement;
        this.logos = logos;
        this.speed = speed;           // pixels per second
        this.rowIndex = rowIndex;
        this.basePath = basePath;
        this.cards = [];              // Active card objects
        this.logoIndex = rowIndex * 3; // Start each row at different logo for variety
        this.cardWidth = 176;         // 160px + 16px gap
        this.lastTime = 0;

        this.init();
    }

    init() {
        // Fill viewport with cards plus extras on right
        const viewportWidth = this.row.parentElement.offsetWidth;
        const cardsNeeded = Math.ceil(viewportWidth / this.cardWidth) + 2;

        // Second row gets an offset for staggered effect
        const offset = this.rowIndex === 1 ? 80 : 0;

        // Create initial cards
        for (let i = 0; i < cardsNeeded; i++) {
            this.createCard(offset + i * this.cardWidth);
        }
    }

    createCard(xPosition) {
        const logo = this.logos[this.logoIndex % this.logos.length];
        this.logoIndex++;

        const card = document.createElement('a');
        card.className = 'logo-wall__card';
        card.href = logo.url;
        card.target = '_blank';
        card.rel = 'noopener noreferrer';
        card.title = logo.alt;
        card.style.transform = `translateX(${xPosition}px)`;

        const img = document.createElement('img');
        img.src = `${this.basePath}img/logos/${logo.name}`;
        img.alt = logo.alt;
        img.loading = 'lazy';

        card.appendChild(img);
        this.row.appendChild(card);

        this.cards.push({ element: card, x: xPosition });
    }

    update(deltaTime) {
        const movement = this.speed * deltaTime;

        // Move all cards left
        for (const card of this.cards) {
            card.x -= movement;
            card.element.style.transform = `translateX(${card.x}px)`;
        }

        // Remove cards that have fully exited left
        while (this.cards.length > 0 && this.cards[0].x < -this.cardWidth) {
            this.cards[0].element.remove();
            this.cards.shift();
        }

        // Add new card on right when rightmost card enters viewport
        if (this.cards.length > 0) {
            const rightmost = this.cards[this.cards.length - 1];
            const viewportWidth = this.row.parentElement.offsetWidth;

            // When rightmost card's left edge is inside viewport, add new card
            if (rightmost.x < viewportWidth) {
                this.createCard(rightmost.x + this.cardWidth);
            }
        }
    }

    // Handle window resize
    handleResize() {
        // Update card width based on responsive breakpoint
        const isMobile = window.innerWidth <= 768;
        this.cardWidth = isMobile ? 136 : 176; // 120px + 16px or 160px + 16px
    }
}

class LogoWall {
    constructor(element) {
        this.element = element;
        this.logos = JSON.parse(element.dataset.logos || '[]');
        this.speed = parseFloat(element.dataset.speed || '50');
        this.basePath = element.dataset.basePath ?? '';
        this.rows = [];
        this.running = false;
        this.lastTime = 0;

        if (this.logos.length === 0) return;

        this.init();
    }

    init() {
        const rowElements = this.element.querySelectorAll('.logo-wall__row');
        rowElements.forEach((row, index) => {
            this.rows.push(new LogoWallRow(row, this.logos, this.speed, index, this.basePath));
        });

        // Handle window resize
        window.addEventListener('resize', () => this.handleResize());

        // Pause when tab is not visible (performance optimization)
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                this.stop();
            } else {
                this.start();
            }
        });

        // Respect reduced motion preference
        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
        if (prefersReducedMotion.matches) {
            return; // Don't start animation
        }

        prefersReducedMotion.addEventListener('change', (e) => {
            if (e.matches) {
                this.stop();
            } else {
                this.start();
            }
        });

        this.start();
    }

    start() {
        if (this.running) return;
        this.running = true;
        this.lastTime = performance.now();
        this.animate();
    }

    stop() {
        this.running = false;
    }

    animate() {
        if (!this.running) return;

        const currentTime = performance.now();
        const deltaTime = (currentTime - this.lastTime) / 1000; // Convert to seconds
        this.lastTime = currentTime;

        // Cap deltaTime to prevent huge jumps (e.g., after tab switch)
        const cappedDelta = Math.min(deltaTime, 0.1);

        for (const row of this.rows) {
            row.update(cappedDelta);
        }

        requestAnimationFrame(() => this.animate());
    }

    handleResize() {
        for (const row of this.rows) {
            row.handleResize();
        }
    }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    const wall = document.querySelector('.logo-wall');
    if (wall) {
        new LogoWall(wall);
    }
});
