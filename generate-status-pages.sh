#!/usr/bin/env bash
#
# Generates .md content pages for the status section from interop-results.yml.
# Each unique transport combo, perf dialer, and hole-punch relay gets its own page.
#
# Usage: ./generate-status-pages.sh
#
# Requires: yq (https://github.com/mikefarah/yq)

set -euo pipefail

YAML="static/data/status/interop-results.yml"
CONTENT_DIR="content/status"

if [[ ! -f "$YAML" ]]; then
    echo "Warning: $YAML not found, skipping page generation"
    exit 0
fi

YQ="${YQ:-yq}"
if ! command -v "$YQ" &>/dev/null; then
    if command -v /usr/local/bin/yq &>/dev/null; then
        YQ=/usr/local/bin/yq
    else
        echo "Error: yq not found" >&2
        exit 1
    fi
fi

# Helper: slugify a string (lowercase, replace non-alphanum with hyphens, collapse)
slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//'
}

# --- Transport pages ---
echo "Generating transport pages..."

TRANSPORT_DIR="$CONTENT_DIR/transport"
mkdir -p "$TRANSPORT_DIR"

# Clear old generated pages (keep _index.md)
find "$TRANSPORT_DIR" -name "*.md" ! -name "_index.md" -delete 2>/dev/null || true

# Extract unique combos: "transport - secure-channel - muxer" or just "transport"
# yq v4 uses // for alternative operator; null fields produce "NONE" fallback
COMBOS=$("$YQ" '
    .transport.results[]
    | .transport + " - " + (.secure-channel // "NONE") + " - " + (.muxer // "NONE")
' "$YAML" 2>/dev/null | sort -u | sed 's/ - NONE - NONE$//' || true)

WEIGHT=1
while IFS= read -r combo; do
    [[ -z "$combo" ]] && continue
    SLUG=$(slugify "$combo")
    cat > "$TRANSPORT_DIR/${SLUG}.md" <<FRONTMATTER
+++
title = "${combo}"
weight = ${WEIGHT}
[extra]
combo = "${combo}"
type = "transport"
+++
FRONTMATTER
    WEIGHT=$((WEIGHT + 1))
done <<< "$COMBOS"

TRANSPORT_COUNT=$((WEIGHT - 1))
echo "  Created $TRANSPORT_COUNT transport pages"

# --- Performance pages ---
echo "Generating performance pages..."

PERF_DIR="$CONTENT_DIR/performance"
mkdir -p "$PERF_DIR"

# Clear old generated pages (keep _index.md)
find "$PERF_DIR" -name "*.md" ! -name "_index.md" -delete 2>/dev/null || true

# Extract unique dialers from perf results (excluding baselines)
DIALERS=$("$YQ" -r '.perf.results[].dialer' "$YAML" 2>/dev/null | sort -u || true)

WEIGHT=1
while IFS= read -r dialer; do
    [[ -z "$dialer" ]] && continue
    SLUG=$(slugify "$dialer")
    cat > "$PERF_DIR/${SLUG}.md" <<FRONTMATTER
+++
title = "${dialer}"
weight = ${WEIGHT}
[extra]
dialer = "${dialer}"
type = "perf"
+++
FRONTMATTER
    WEIGHT=$((WEIGHT + 1))
done <<< "$DIALERS"

PERF_COUNT=$((WEIGHT - 1))
echo "  Created $PERF_COUNT performance pages"

# --- Hole-punch pages ---
echo "Generating hole-punch pages..."

HP_DIR="$CONTENT_DIR/hole-punch"
mkdir -p "$HP_DIR"

# Clear old generated pages (keep _index.md)
find "$HP_DIR" -name "*.md" ! -name "_index.md" -delete 2>/dev/null || true

# Extract unique relays from hole-punch results
RELAYS=$("$YQ" -r '.["hole-punch"].results[].relay' "$YAML" 2>/dev/null | sort -u || true)

WEIGHT=1
while IFS= read -r relay; do
    [[ -z "$relay" ]] && continue
    SLUG=$(slugify "$relay")
    cat > "$HP_DIR/${SLUG}.md" <<FRONTMATTER
+++
title = "${relay}"
weight = ${WEIGHT}
[extra]
relay = "${relay}"
type = "hole-punch"
+++
FRONTMATTER
    WEIGHT=$((WEIGHT + 1))
done <<< "$RELAYS"

HP_COUNT=$((WEIGHT - 1))
echo "  Created $HP_COUNT hole-punch pages"

echo "Done. Total pages generated: $((TRANSPORT_COUNT + PERF_COUNT + HP_COUNT))"
