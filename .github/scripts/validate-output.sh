#!/bin/bash
# validate-output.sh - Validate LLM output and save to static/data/latest-updates
set -euo pipefail

# Source shared configuration for REPOS and prohibited patterns
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

OUTPUT_FILE="static/data/latest-updates"

# Check if we should skip
if [ "${SKIP_GENERATION:-false}" = "true" ]; then
  echo "Skipping validation (no activity)"
  exit 0
fi

if [ "${OLLAMA_FAILED:-false}" = "true" ]; then
  echo "Skipping validation (Ollama failed)"
  echo "Keeping existing $OUTPUT_FILE"
  exit 0
fi

# Check for LLM output
if [ ! -f llm-output.html ] || [ ! -s llm-output.html ]; then
  echo "::error::LLM output file missing or empty"
  exit 1
fi

echo "Validating LLM output..."

# Read the raw output
RAW_OUTPUT=$(cat llm-output.html)

# Extract only the HTML content (remove any markdown or explanatory text)
# Look for content between first <div and last </div>
extract_html() {
  local input="$1"

  # If it starts with <div, it's probably clean
  if [[ "$input" =~ ^[[:space:]]*\<div ]]; then
    echo "$input"
    return
  fi

  # Try to extract just the div content
  echo "$input" | awk '
    /<div class="update-item">/ { capture=1 }
    capture { print }
    /<\/div>/ && capture { }
  '
}

EXTRACTED=$(extract_html "$RAW_OUTPUT")

# If extraction produced nothing, use the raw output
if [ -z "$EXTRACTED" ]; then
  EXTRACTED="$RAW_OUTPUT"
fi

# Check that all links point to approved repositories
validate_links() {
  local content="$1"
  local errors=0

  # Extract all href URLs pointing to github.com
  local urls
  urls=$(echo "$content" | grep -oP 'href="https://github\.com/[^"]+' | sed 's/href="//' || true)

  if [ -n "$urls" ]; then
    while IFS= read -r url; do
      # Check if URL starts with any allowed repo
      local is_allowed=false
      for repo in "${REPOS[@]}"; do
        if [[ "$url" == "https://github.com/${repo}"* ]]; then
          is_allowed=true
          break
        fi
      done

      if [ "$is_allowed" = false ]; then
        echo "::error::Disallowed link found: $url"
        errors=$((errors + 1))
      fi
    done <<< "$urls"
  fi

  return $errors
}

# Check for prohibited words or content
check_prohibited_content() {
  local content="$1"
  local content_lower
  content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')
  local errors=0

  for pattern in "${PROHIBITED_PATTERNS[@]}"; do
    if echo "$content_lower" | grep -qiE "$pattern"; then
      echo "::error::Prohibited content detected (pattern: $pattern)"
      errors=$((errors + 1))
    fi
  done

  return $errors
}

# Warn on negative sentiment (non-blocking)
check_negative_sentiment() {
  local content="$1"
  local content_lower
  content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')

  for pattern in "${NEGATIVE_SENTIMENT_PATTERNS[@]}"; do
    if echo "$content_lower" | grep -qiE "$pattern"; then
      echo "::warning::Potential negative sentiment detected (pattern: $pattern)"
    fi
  done
}

# Validation checks
ERRORS=0

# Check 1: Contains update-item divs
if ! echo "$EXTRACTED" | grep -q '<div class="update-item">'; then
  echo "::error::Missing <div class=\"update-item\"> elements"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: Contains title divs
if ! echo "$EXTRACTED" | grep -q 'update-item__title'; then
  echo "::error::Missing update-item__title elements"
  ERRORS=$((ERRORS + 1))
fi

# Check 3: Contains description divs
if ! echo "$EXTRACTED" | grep -q 'update-item__description'; then
  echo "::error::Missing update-item__description elements"
  ERRORS=$((ERRORS + 1))
fi

# Check 4: Count items (expect 2-5)
ITEM_COUNT=$(echo "$EXTRACTED" | grep -c '<div class="update-item">' || echo "0")
echo "Found $ITEM_COUNT update items"
if [ "$ITEM_COUNT" -lt 2 ]; then
  echo "::warning::Only $ITEM_COUNT items found (expected 3-5)"
  if [ "$ITEM_COUNT" -eq 0 ]; then
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check 5: Balanced div tags
OPEN_DIVS=$(echo "$EXTRACTED" | grep -o '<div' | wc -l || echo "0")
CLOSE_DIVS=$(echo "$EXTRACTED" | grep -o '</div>' | wc -l || echo "0")
if [ "$OPEN_DIVS" -ne "$CLOSE_DIVS" ]; then
  echo "::warning::Unbalanced div tags: $OPEN_DIVS opens, $CLOSE_DIVS closes"
fi

# Check 6: GitHub links present (warning only)
if ! echo "$EXTRACTED" | grep -q 'github.com'; then
  echo "::warning::No GitHub links found in output"
fi

# Check 7: All links point to approved repositories
echo "Checking link destinations..."
if ! validate_links "$EXTRACTED"; then
  LINK_ERRORS=$?
  echo "::error::Found $LINK_ERRORS links to non-approved repositories"
  ERRORS=$((ERRORS + LINK_ERRORS))
fi

# Check 8: No prohibited content
echo "Checking for prohibited content..."
if ! check_prohibited_content "$EXTRACTED"; then
  CONTENT_ERRORS=$?
  echo "::error::Found $CONTENT_ERRORS prohibited content matches"
  ERRORS=$((ERRORS + CONTENT_ERRORS))
fi

# Check 9: Negative sentiment (warning only, non-blocking)
echo "Checking for negative sentiment..."
check_negative_sentiment "$EXTRACTED"

# If validation failed, keep existing file
if [ "$ERRORS" -gt 0 ]; then
  echo "::error::Validation failed with $ERRORS errors"
  echo "Keeping existing $OUTPUT_FILE"
  exit 1
fi

echo "Validation passed"

# Post-processing: Add target="_blank" to links that don't have it
process_output() {
  local input="$1"

  # Add target="_blank" rel="noopener noreferrer" to <a> tags that don't already have target
  echo "$input" | sed -E '
    # For links without target attribute, add it
    s/<a href="([^"]+)"([^>]*)>/<a target="_blank" rel="noopener noreferrer" href="\1"\2>/g
  ' | sed -E '
    # Clean up any duplicate attributes
    s/target="_blank" target="_blank"/target="_blank"/g
    s/rel="noopener noreferrer" rel="noopener noreferrer"/rel="noopener noreferrer"/g
  '
}

PROCESSED=$(process_output "$EXTRACTED")

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Save the processed output
echo "$PROCESSED" > "$OUTPUT_FILE"

echo "Saved to $OUTPUT_FILE"
echo "--- Final output ---"
cat "$OUTPUT_FILE"
echo ""
echo "--- End output ---"

# Final stats
FINAL_SIZE=$(wc -c < "$OUTPUT_FILE")
FINAL_ITEMS=$(grep -c '<div class="update-item">' "$OUTPUT_FILE" || echo "0")
FINAL_LINKS=$(grep -o 'href="https://github.com' "$OUTPUT_FILE" | wc -l || echo "0")

echo ""
echo "Summary:"
echo "  Size: $FINAL_SIZE bytes"
echo "  Items: $FINAL_ITEMS"
echo "  GitHub links: $FINAL_LINKS"
