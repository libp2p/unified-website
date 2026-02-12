#!/bin/bash
# fetch-releases.sh - Fetch new releases from GitHub Atom feeds and generate Zola markdown
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONTENT_DIR="$REPO_ROOT/content/releases"
CONFIG_FILE="$REPO_ROOT/config.toml"

# Counter for new releases
NEW_COUNT=0

# Extract feed URLs from config.toml [extra.release_feeds] section
declare -A FEEDS
in_feeds_section=false
while IFS= read -r line; do
    if [[ "$line" =~ ^\[extra\.release_feeds\] ]]; then
        in_feeds_section=true
        continue
    fi
    if $in_feeds_section; then
        # Stop at next section header
        if [[ "$line" =~ ^\[.+\] ]] || [[ "$line" =~ ^\[\[.+\]\] ]]; then
            break
        fi
        # Parse key = "value" lines
        if [[ "$line" =~ ^([a-z0-9_-]+)[[:space:]]*=[[:space:]]*\"(.+)\" ]]; then
            FEEDS["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
        fi
    fi
done < "$CONFIG_FILE"

if [ ${#FEEDS[@]} -eq 0 ]; then
    echo "Error: No feeds found in [extra.release_feeds] section of config.toml"
    exit 1
fi

echo "Found ${#FEEDS[@]} feed(s) to check"

# Map implementation name to short name used in front matter
get_short_name() {
    local impl="$1"
    case "$impl" in
        go-libp2p)   echo "go" ;;
        rust-libp2p) echo "rust" ;;
        js-libp2p)   echo "js" ;;
        py-libp2p)   echo "py" ;;
        nim-libp2p)  echo "nim" ;;
        *)           echo "$impl" ;;
    esac
}

# Map implementation name to GitHub org/repo
get_repo_path() {
    local url="$1"
    # Extract org/repo from https://github.com/ORG/REPO/releases.atom
    echo "$url" | sed -E 's|https://github.com/([^/]+/[^/]+)/releases\.atom|\1|'
}

# Basic HTML to markdown conversion
html_to_markdown() {
    sed -E \
        -e 's|&lt;|<|g' \
        -e 's|&gt;|>|g' \
        -e 's|&amp;|&|g' \
        -e 's|&quot;|"|g' \
        -e 's|&#39;|'"'"'|g' \
        -e 's|<br\s*/?>|\n|g' \
        -e 's|</?p>|\n|g' \
        -e 's|<h([1-6])[^>]*>|## |g' \
        -e 's|</h[1-6]>||g' \
        -e 's|<strong>|**|g' -e 's|</strong>|**|g' \
        -e 's|<b>|**|g' -e 's|</b>|**|g' \
        -e 's|<em>|*|g' -e 's|</em>|*|g' \
        -e 's|<i>|*|g' -e 's|</i>|*|g' \
        -e 's|<code>|`|g' -e 's|</code>|`|g' \
        -e 's|<a href="([^"]+)"[^>]*>([^<]+)</a>|[\2](\1)|g' \
        -e 's|<li>|- |g' -e 's|</li>||g' \
        -e 's|</?[ou]l[^>]*>||g' \
        -e 's|</?div[^>]*>||g' \
        -e 's|</?span[^>]*>||g' \
        -e 's|</?pre[^>]*>||g'
}

# Detect breaking changes or security flags from title + content
detect_breaking() {
    local text="$1"
    echo "$text" | grep -qi 'breaking\|BREAKING' && echo "true" || echo "false"
}

detect_security() {
    local text="$1"
    echo "$text" | grep -qi 'security\|CVE\|vulnerability\|advisory' && echo "true" || echo "false"
}

# Process each feed
for impl in "${!FEEDS[@]}"; do
    feed_url="${FEEDS[$impl]}"
    short_name=$(get_short_name "$impl")
    repo_path=$(get_repo_path "$feed_url")

    echo ""
    echo "Processing $impl ($feed_url)..."

    # Fetch the Atom feed
    feed_xml=$(curl -sS --max-time 30 "$feed_url" 2>/dev/null) || {
        echo "  Warning: Failed to fetch feed for $impl, skipping"
        continue
    }

    # Count entries
    entry_count=$(echo "$feed_xml" | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" -t -v "count(//atom:entry)" 2>/dev/null) || {
        echo "  Warning: Failed to parse feed for $impl, skipping"
        continue
    }

    echo "  Found $entry_count entries"

    for i in $(seq 1 "$entry_count"); do
        # Extract fields using xmlstarlet with Atom namespace
        title=$(echo "$feed_xml" | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" \
            -t -v "//atom:entry[$i]/atom:title" 2>/dev/null || echo "")
        link=$(echo "$feed_xml" | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" \
            -t -v "//atom:entry[$i]/atom:link/@href" 2>/dev/null || echo "")
        updated=$(echo "$feed_xml" | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" \
            -t -v "//atom:entry[$i]/atom:updated" 2>/dev/null || echo "")
        content=$(echo "$feed_xml" | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" \
            -t -v "//atom:entry[$i]/atom:content" 2>/dev/null || echo "")
        author=$(echo "$feed_xml" | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" \
            -t -v "//atom:entry[$i]/atom:author/atom:name" 2>/dev/null || echo "")

        # Skip empty entries
        if [ -z "$title" ]; then
            continue
        fi

        # Extract version from title/tag
        tag="$title"
        version=""

        # rust-libp2p special handling: only process libp2p-v* tags
        if [ "$impl" = "rust-libp2p" ]; then
            if [[ ! "$tag" =~ ^libp2p-v ]]; then
                continue
            fi
            # Strip libp2p- prefix to get version
            version="${tag#libp2p-}"
        else
            # For other implementations, extract version from tag
            # Handle tags like "v0.47.0", "js-libp2p-v3.0.0", etc.
            if [[ "$tag" =~ v([0-9]+(\.[0-9]+)*) ]]; then
                version="v${BASH_REMATCH[1]}"
            else
                version="$tag"
            fi
        fi

        # Build the filename: {impl-name}-{version}.md
        # Sanitize version for filename
        safe_version=$(echo "$version" | sed 's/[^a-zA-Z0-9._-]/-/g')
        filename="${impl}-${safe_version}.md"

        # Skip if file already exists
        if [ -f "$CONTENT_DIR/$filename" ]; then
            continue
        fi

        echo "  New release: $impl $version ($tag)"

        # Extract date (YYYY-MM-DD from ISO 8601)
        release_date=$(echo "$updated" | cut -c1-10)
        if [ -z "$release_date" ]; then
            release_date=$(date -u +"%Y-%m-%d")
        fi

        # Build slug
        slug="${release_date}-${impl}"

        # Detect flags
        combined_text="$title $content"
        breaking=$(detect_breaking "$combined_text")
        security=$(detect_security "$combined_text")

        # Clean up author
        if [ -z "$author" ] || [ "$author" = "github-actions[bot]" ]; then
            author="libp2p maintainers"
        fi

        # Build description
        description="Release ${version} of ${impl}"

        # Convert content to markdown
        body=""
        if [ -n "$content" ]; then
            body=$(echo "$content" | html_to_markdown)
        fi

        # Generate the markdown file
        cat > "$CONTENT_DIR/$filename" <<FRONTMATTER
+++
title = "Announcing the release of ${impl} ${version}"
description = "${description}"
date = ${release_date}
slug = "${slug}"

[taxonomies]
tags = ["${impl}"]

[extra]
author = "${author}"
version = "${version}"
implementation = "${short_name}"
breaking = ${breaking}
security = ${security}
github_release = "${link}"
+++
FRONTMATTER

        # Append body content if available
        if [ -n "$body" ]; then
            echo "$body" >> "$CONTENT_DIR/$filename"
        fi

        NEW_COUNT=$((NEW_COUNT + 1))
    done
done

echo ""
echo "Done. Created $NEW_COUNT new release file(s)."

# Export for use by GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "new_count=$NEW_COUNT" >> "$GITHUB_OUTPUT"
fi
