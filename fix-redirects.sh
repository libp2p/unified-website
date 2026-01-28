#!/bin/bash
# Post-build script to fix absolute URLs to use relative paths
# This is needed because:
# 1. Zola doesn't support custom redirect templates for aliases
# 2. Zola converts some internal anchor links to absolute URLs

set -e

PUBLIC_DIR="${1:-public}"

echo "Fixing absolute URLs in $PUBLIC_DIR..."

# Process all HTML files
find "$PUBLIC_DIR" -name "index.html" -type f | while read -r file; do
    # Check if file contains absolute libp2p.io URLs (excluding canonical and og: tags)
    if grep -q 'https://libp2p.io/' "$file" 2>/dev/null; then
        # Get the directory depth to calculate relative prefix
        dir=$(dirname "$file")
        rel_path="${dir#$PUBLIC_DIR}"

        # Count directory depth
        depth=$(echo "$rel_path" | tr -cd '/' | wc -c)

        # Build the relative prefix
        prefix=""
        for ((i=0; i<depth; i++)); do
            prefix="../$prefix"
        done

        # If at root, prefix is empty, use ./
        if [ -z "$prefix" ]; then
            prefix="./"
        fi

        # Check if this file has URLs to fix (not just canonical/og tags)
        if grep -v 'rel="canonical"' "$file" | grep -v 'property="og:' | grep -q 'https://libp2p.io/'; then
            echo "  Fixing: $file (prefix: $prefix)"

            # Create a temporary file for processing
            tmp_file=$(mktemp)

            # Process the file line by line to avoid modifying canonical/og URLs
            while IFS= read -r line; do
                # Skip lines with canonical or og: tags
                if echo "$line" | grep -q 'rel="canonical"\|property="og:'; then
                    echo "$line"
                else
                    # Replace absolute URLs with relative ones
                    echo "$line" | sed "s|https://libp2p.io/|$prefix|g"
                fi
            done < "$file" > "$tmp_file"

            # Move the temp file back
            mv "$tmp_file" "$file"
        fi
    fi
done

echo "Done fixing absolute URLs."
