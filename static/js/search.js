/**
 * Search results page JavaScript
 * Handles loading the search index, performing searches, and displaying results
 */

(function() {
    'use strict';

    var searchIndex = null;
    var searchInput = document.getElementById('search-input');
    var searchForm = document.getElementById('search-form');
    var searchResults = document.getElementById('search-results');
    var searchLoading = document.getElementById('search-loading');
    var searchEmpty = document.getElementById('search-empty');
    var searchEmptyText = document.getElementById('search-empty-text');
    var searchCount = document.getElementById('search-count');
    var searchList = document.getElementById('search-list');

    // Get the base URL for the search index
    function getBaseUrl() {
        var scripts = document.getElementsByTagName('script');
        for (var i = 0; i < scripts.length; i++) {
            var src = scripts[i].src;
            if (src && src.indexOf('js/search.js') !== -1) {
                return src.replace('js/search.js', '');
            }
        }
        return '/';
    }

    // Load the search index
    function loadSearchIndex(callback) {
        if (searchIndex !== null) {
            callback(searchIndex);
            return;
        }

        var baseUrl = getBaseUrl();
        var xhr = new XMLHttpRequest();
        xhr.open('GET', baseUrl + 'search_index.en.json', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    searchIndex = elasticlunr.Index.load(data);
                    callback(searchIndex);
                } else {
                    console.error('Failed to load search index');
                    searchLoading.style.display = 'none';
                    searchEmpty.style.display = 'block';
                    searchEmptyText.textContent = 'Failed to load search index';
                }
            }
        };
        xhr.send();
    }

    // Escape HTML to prevent XSS
    function escapeHtml(text) {
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Highlight search terms in text
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

    // Get a snippet of text around the first match
    function getSnippet(text, terms, maxLength) {
        maxLength = maxLength || 200;

        if (!text) return '';

        // Try to find the first matching term
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
            // Center the snippet around the match
            start = Math.max(0, firstMatchIndex - Math.floor(maxLength / 2));
            end = Math.min(text.length, start + maxLength);

            // Adjust start to not cut words
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

        if (start > 0) {
            snippet = '...' + snippet;
        }
        if (end < text.length) {
            snippet = snippet + '...';
        }

        return snippet;
    }

    // Perform search and display results
    function performSearch(query) {
        if (!query || query.trim() === '') {
            searchList.innerHTML = '';
            searchCount.style.display = 'none';
            searchEmpty.style.display = 'block';
            searchEmptyText.textContent = 'Enter a search term to find results';
            return;
        }

        searchLoading.style.display = 'block';
        searchEmpty.style.display = 'none';
        searchCount.style.display = 'none';
        searchList.innerHTML = '';

        loadSearchIndex(function(index) {
            var results = index.search(query, {
                fields: {
                    title: { boost: 2 },
                    body: { boost: 1 }
                },
                expand: true,
                bool: 'OR'
            });

            searchLoading.style.display = 'none';

            if (results.length === 0) {
                searchEmpty.style.display = 'block';
                searchEmptyText.textContent = 'No results found for "' + query + '"';
                return;
            }

            // Get search terms for highlighting
            var terms = query.toLowerCase().split(/\s+/).filter(function(t) {
                return t.length >= 2;
            });

            searchCount.style.display = 'block';
            searchCount.textContent = results.length + ' result' + (results.length === 1 ? '' : 's') + ' for "' + query + '"';

            var baseUrl = getBaseUrl();

            results.forEach(function(result) {
                var doc = index.documentStore.getDoc(result.ref);
                if (!doc) return;

                var resultEl = document.createElement('a');
                // Handle different URL formats in search index
                var docPath = doc.id || '';
                if (docPath.indexOf('http://') === 0 || docPath.indexOf('https://') === 0) {
                    // Already an absolute URL
                    resultEl.href = docPath;
                } else if (docPath.indexOf('/') === 0) {
                    // Absolute path from root - use directly for relative navigation
                    resultEl.href = docPath;
                } else {
                    // Relative path
                    resultEl.href = baseUrl + docPath;
                }
                resultEl.className = 'search-result';

                var title = highlightMatches(doc.title || 'Untitled', terms);
                var path = doc.id || '';
                var snippet = highlightMatches(getSnippet(doc.body, terms, 250), terms);

                resultEl.innerHTML =
                    '<h3 class="search-result__title">' + title + '</h3>' +
                    '<p class="search-result__path">' + escapeHtml(path) + '</p>' +
                    (snippet ? '<p class="search-result__snippet">' + snippet + '</p>' : '');

                searchList.appendChild(resultEl);
            });
        });
    }

    // Initialize
    function init() {
        // Get query from URL
        var urlParams = new URLSearchParams(window.location.search);
        var query = urlParams.get('q') || '';

        if (searchInput) {
            searchInput.value = query;
        }

        // Perform initial search if query exists
        if (query) {
            performSearch(query);
        } else {
            searchEmpty.style.display = 'block';
            searchEmptyText.textContent = 'Enter a search term to find results';
        }

        // Handle form submission
        if (searchForm) {
            searchForm.addEventListener('submit', function(e) {
                e.preventDefault();
                var query = searchInput.value.trim();

                // Update URL without reload
                var url = new URL(window.location);
                url.searchParams.set('q', query);
                window.history.pushState({}, '', url);

                performSearch(query);
            });
        }

        // Live search with debounce
        var debounceTimer;
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(function() {
                    var query = searchInput.value.trim();

                    // Update URL without reload
                    var url = new URL(window.location);
                    if (query) {
                        url.searchParams.set('q', query);
                    } else {
                        url.searchParams.delete('q');
                    }
                    window.history.replaceState({}, '', url);

                    performSearch(query);
                }, 300);
            });
        }
    }

    // Run on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
