/**
 * Common JavaScript for libp2p unified website
 */

(function() {
    'use strict';

    // Mobile navigation toggle
    function initMobileNav() {
        const toggle = document.querySelector('[data-menu-toggle]');
        const close = document.querySelector('[data-menu-close]');
        const nav = document.getElementById('mobile-nav');

        if (toggle && nav) {
            toggle.addEventListener('click', function() {
                nav.classList.add('mobile-nav--open');
                nav.setAttribute('aria-hidden', 'false');
                document.body.style.overflow = 'hidden';
            });
        }

        if (close && nav) {
            close.addEventListener('click', function() {
                nav.classList.remove('mobile-nav--open');
                nav.setAttribute('aria-hidden', 'true');
                document.body.style.overflow = '';
            });
        }

        // Close on escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && nav && nav.classList.contains('mobile-nav--open')) {
                nav.classList.remove('mobile-nav--open');
                nav.setAttribute('aria-hidden', 'true');
                document.body.style.overflow = '';
            }
        });
    }

    // Sidebar toggle (for guides)
    function initSidebar() {
        const toggle = document.querySelector('[data-sidebar-toggle]');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('sidebar-overlay');

        if (toggle && sidebar) {
            toggle.addEventListener('click', function() {
                sidebar.classList.toggle('sidebar--open');
                if (overlay) {
                    overlay.classList.toggle('sidebar-overlay--visible');
                }
                document.body.style.overflow = sidebar.classList.contains('sidebar--open') ? 'hidden' : '';
            });
        }

        if (overlay) {
            overlay.addEventListener('click', function() {
                sidebar.classList.remove('sidebar--open');
                overlay.classList.remove('sidebar-overlay--visible');
                document.body.style.overflow = '';
            });
        }

        // Collapsible sidebar sections
        const sectionToggles = document.querySelectorAll('[data-section-toggle]');
        sectionToggles.forEach(function(btn) {
            btn.addEventListener('click', function() {
                const expanded = this.getAttribute('aria-expanded') === 'true';
                this.setAttribute('aria-expanded', !expanded);
                this.classList.toggle('sidebar__section-title--collapsed');

                const list = this.nextElementSibling;
                if (list) {
                    list.classList.toggle('sidebar__list--collapsed');
                }
            });
        });
    }

    // Smooth scroll for anchor links
    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
            anchor.addEventListener('click', function(e) {
                const href = this.getAttribute('href');
                if (href === '#') return;

                const target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });

                    // Update URL without triggering scroll
                    history.pushState(null, null, href);
                }
            });
        });
    }

    // Copy code button
    function initCopyCode() {
        document.querySelectorAll('.code-block__copy').forEach(function(btn) {
            btn.addEventListener('click', function() {
                const codeBlock = this.closest('.code-block');
                const code = codeBlock.querySelector('code');

                if (code) {
                    navigator.clipboard.writeText(code.textContent).then(function() {
                        btn.classList.add('code-block__copy--copied');
                        btn.textContent = 'Copied!';

                        setTimeout(function() {
                            btn.classList.remove('code-block__copy--copied');
                            btn.textContent = 'Copy';
                        }, 2000);
                    });
                }
            });
        });
    }

    // Search shortcut (/ key)
    function initSearchShortcut() {
        const searchToggle = document.querySelector('[data-search-toggle]');

        document.addEventListener('keydown', function(e) {
            // Ignore if typing in an input
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                return;
            }

            if (e.key === '/') {
                e.preventDefault();
                if (searchToggle) {
                    searchToggle.click();
                }
            }
        });
    }

    // External link handling
    function initExternalLinks() {
        document.querySelectorAll('a[href^="http"]').forEach(function(link) {
            // Skip if already has target or is same origin
            if (link.hasAttribute('target') || link.hostname === window.location.hostname) {
                return;
            }

            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        });
    }

    // Initialize on DOM ready
    function init() {
        initMobileNav();
        initSidebar();
        initSmoothScroll();
        initCopyCode();
        initSearchShortcut();
        initExternalLinks();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
