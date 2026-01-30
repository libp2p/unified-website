/**
 * Common JavaScript for libp2p unified website
 */

(function() {
    'use strict';

    // Mobile navigation toggle
    function initMobileNav() {
        var toggle = document.querySelector('[data-menu-toggle]');
        var close = document.querySelector('[data-menu-close]');
        var nav = document.getElementById('mobile-nav');

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
        var toggle = document.querySelector('[data-sidebar-toggle]');
        var sidebar = document.getElementById('sidebar');
        var overlay = document.getElementById('sidebar-overlay');

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
        var sectionToggles = document.querySelectorAll('[data-section-toggle]');
        sectionToggles.forEach(function(btn) {
            btn.addEventListener('click', function() {
                var expanded = this.getAttribute('aria-expanded') === 'true';
                this.setAttribute('aria-expanded', !expanded);
                this.classList.toggle('sidebar__section-title--collapsed');

                var list = this.nextElementSibling;
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
                var href = this.getAttribute('href');
                if (href === '#') return;

                var target = document.querySelector(href);
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
                var codeBlock = this.closest('.code-block');
                var code = codeBlock.querySelector('code');

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

    // Search modal functionality
    function initSearch() {
        var searchToggle = document.querySelector('[data-search-toggle]');
        var searchModal = document.getElementById('search-modal');
        var searchInput = document.getElementById('search-modal-input');
        var searchResults = document.getElementById('search-modal-results');
        var searchEmpty = document.getElementById('search-modal-empty');
        var searchLoading = document.getElementById('search-modal-loading');

        if (!searchModal) return;

        var searchIndex = null;
        var selectedIndex = -1;
        var results = [];
        var debounceTimer;

        // Get the base URL for links and search index
        function getBaseUrl() {
            var link = document.querySelector('link[rel="stylesheet"][href*="main.css"]');
            if (link) {
                return link.href.replace('main.css', '');
            }
            return '/';
        }

        // Load search index
        function loadSearchIndex(callback) {
            if (searchIndex !== null) {
                callback(searchIndex);
                return;
            }

            searchLoading.style.display = 'block';
            searchEmpty.style.display = 'none';
            searchResults.innerHTML = '';

            var baseUrl = getBaseUrl();
            var xhr = new XMLHttpRequest();
            xhr.open('GET', baseUrl + 'search_index.en.json', true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    searchLoading.style.display = 'none';
                    if (xhr.status === 200) {
                        var data = JSON.parse(xhr.responseText);
                        searchIndex = elasticlunr.Index.load(data);
                        callback(searchIndex);
                    } else {
                        searchEmpty.style.display = 'block';
                        searchEmpty.textContent = 'Failed to load search index';
                    }
                }
            };
            xhr.send();
        }

        // Escape HTML
        function escapeHtml(text) {
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        // Highlight matches
        function highlightMatches(text, terms) {
            if (!text || !terms || terms.length === 0) {
                return escapeHtml(text);
            }

            var escaped = escapeHtml(text);
            terms.forEach(function(term) {
                if (term.length < 2) return;
                var regex = new RegExp('(' + term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
                escaped = escaped.replace(regex, '<mark>$1</mark>');
            });
            return escaped;
        }

        // Get snippet around match
        function getSnippet(text, terms, maxLength) {
            maxLength = maxLength || 100;
            if (!text) return '';

            var lowerText = text.toLowerCase();
            var firstMatchIndex = -1;

            for (var i = 0; i < terms.length; i++) {
                var term = terms[i].toLowerCase();
                if (term.length < 2) continue;
                var idx = lowerText.indexOf(term);
                if (idx !== -1 && (firstMatchIndex === -1 || idx < firstMatchIndex)) {
                    firstMatchIndex = idx;
                }
            }

            var start, end;
            if (firstMatchIndex !== -1) {
                start = Math.max(0, firstMatchIndex - 30);
                end = Math.min(text.length, start + maxLength);
                if (start > 0) {
                    var spaceIndex = text.indexOf(' ', start);
                    if (spaceIndex !== -1 && spaceIndex < start + 20) {
                        start = spaceIndex + 1;
                    }
                }
            } else {
                start = 0;
                end = Math.min(text.length, maxLength);
            }

            var snippet = text.substring(start, end);
            if (start > 0) snippet = '...' + snippet;
            if (end < text.length) snippet = snippet + '...';
            return snippet;
        }

        // Perform search
        function performSearch(query) {
            if (!query || query.trim() === '') {
                searchResults.innerHTML = '';
                searchEmpty.style.display = 'none';
                results = [];
                selectedIndex = -1;
                return;
            }

            loadSearchIndex(function(index) {
                var searchResults_data = index.search(query, {
                    fields: {
                        title: { boost: 2 },
                        body: { boost: 1 }
                    },
                    expand: true,
                    bool: 'OR'
                });

                // Limit to 8 results for modal
                results = searchResults_data.slice(0, 8);
                selectedIndex = -1;

                if (results.length === 0) {
                    searchResults.innerHTML = '';
                    searchEmpty.style.display = 'block';
                    searchEmpty.textContent = 'No results found';
                    return;
                }

                searchEmpty.style.display = 'none';

                var terms = query.toLowerCase().split(/\s+/).filter(function(t) {
                    return t.length >= 2;
                });

                var baseUrl = getBaseUrl();
                var html = '';

                results.forEach(function(result, i) {
                    var doc = index.documentStore.getDoc(result.ref);
                    if (!doc) return;

                    var title = highlightMatches(doc.title || 'Untitled', terms);
                    var docPath = doc.id || '';
                    var snippet = highlightMatches(getSnippet(doc.body, terms, 100), terms);

                    // Handle different URL formats in search index
                    var resultUrl;
                    if (docPath.indexOf('http://') === 0 || docPath.indexOf('https://') === 0) {
                        // Already an absolute URL
                        resultUrl = docPath;
                    } else if (docPath.indexOf('/') === 0) {
                        // Absolute path from root - use directly
                        resultUrl = docPath;
                    } else {
                        // Relative path
                        resultUrl = baseUrl + docPath;
                    }

                    html += '<li role="option" id="search-result-' + i + '">' +
                        '<a href="' + escapeHtml(resultUrl) + '" class="search-modal__result" data-index="' + i + '">' +
                        '<div class="search-modal__result-title">' + title + '</div>' +
                        '<div class="search-modal__result-path">' + escapeHtml(docPath) + '</div>' +
                        (snippet ? '<div class="search-modal__result-snippet">' + snippet + '</div>' : '') +
                        '</a></li>';
                });

                searchResults.innerHTML = html;
            });
        }

        // Update selection
        function updateSelection() {
            var items = searchResults.querySelectorAll('.search-modal__result');
            items.forEach(function(item, i) {
                if (i === selectedIndex) {
                    item.classList.add('search-modal__result--selected');
                    item.scrollIntoView({ block: 'nearest' });
                } else {
                    item.classList.remove('search-modal__result--selected');
                }
            });
        }

        // Open modal
        function openModal() {
            searchModal.classList.add('search-modal--open');
            searchModal.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';

            // Load elasticlunr if not loaded
            if (typeof elasticlunr === 'undefined') {
                var script = document.createElement('script');
                script.src = getBaseUrl() + 'elasticlunr.min.js';
                script.onload = function() {
                    searchInput.focus();
                };
                document.head.appendChild(script);
            } else {
                searchInput.focus();
            }
        }

        // Close modal
        function closeModal() {
            searchModal.classList.remove('search-modal--open');
            searchModal.setAttribute('aria-hidden', 'true');
            document.body.style.overflow = '';
            searchInput.value = '';
            searchResults.innerHTML = '';
            searchEmpty.style.display = 'none';
            results = [];
            selectedIndex = -1;
        }

        // Navigate to search page
        function navigateToSearchPage(query) {
            var baseUrl = getBaseUrl();
            window.location.href = baseUrl + 'search/?q=' + encodeURIComponent(query);
        }

        // Event listeners
        if (searchToggle) {
            searchToggle.addEventListener('click', function(e) {
                e.preventDefault();
                openModal();
            });
        }

        // Close on backdrop click
        searchModal.addEventListener('click', function(e) {
            if (e.target === searchModal) {
                closeModal();
            }
        });

        // Input handling
        searchInput.addEventListener('input', function() {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(function() {
                performSearch(searchInput.value);
            }, 150);
        });

        // Keyboard handling
        searchInput.addEventListener('keydown', function(e) {
            var items = searchResults.querySelectorAll('.search-modal__result');

            switch (e.key) {
                case 'ArrowDown':
                    e.preventDefault();
                    if (items.length > 0) {
                        selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
                        updateSelection();
                    }
                    break;

                case 'ArrowUp':
                    e.preventDefault();
                    if (items.length > 0) {
                        selectedIndex = Math.max(selectedIndex - 1, -1);
                        updateSelection();
                    }
                    break;

                case 'Enter':
                    e.preventDefault();
                    if (selectedIndex >= 0 && selectedIndex < items.length) {
                        // Navigate to selected result
                        items[selectedIndex].click();
                    } else if (searchInput.value.trim()) {
                        // Navigate to search page
                        navigateToSearchPage(searchInput.value.trim());
                    }
                    break;

                case 'Escape':
                    e.preventDefault();
                    closeModal();
                    break;
            }
        });

        // Global keyboard shortcut
        document.addEventListener('keydown', function(e) {
            // Ignore if typing in an input or modal is already open
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                return;
            }

            if (e.key === '/' && !searchModal.classList.contains('search-modal--open')) {
                e.preventDefault();
                openModal();
            }

            if (e.key === 'Escape' && searchModal.classList.contains('search-modal--open')) {
                closeModal();
            }
        });

        // Handle click on results (for mouse users)
        searchResults.addEventListener('mouseover', function(e) {
            var result = e.target.closest('.search-modal__result');
            if (result) {
                var index = parseInt(result.dataset.index, 10);
                if (!isNaN(index)) {
                    selectedIndex = index;
                    updateSelection();
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
        initSearch();
        initExternalLinks();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
