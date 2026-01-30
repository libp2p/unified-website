#!/bin/bash
# format-prompt.sh - Transform GitHub activity JSON into LLM prompt
set -euo pipefail

# Check for empty activity
if [ "${EMPTY_ACTIVITY:-false}" = "true" ]; then
  echo "No activity to format, skipping"
  echo "SKIP_GENERATION=true" >> "$GITHUB_ENV"
  exit 0
fi

# Calculate date range for display
END_DATE=$(date -u +"%Y-%m-%d")
START_DATE=$(date -d "${DAYS_BACK:-7} days ago" -u +"%Y-%m-%d")
SINCE_DATE=$(date -d "${DAYS_BACK:-7} days ago" -u +"%Y-%m-%dT00:00:00Z")

echo "Formatting activity data for $START_DATE to $END_DATE..."

# Transform JSON to structured text format
format_activity() {
  jq -r --arg since "$SINCE_DATE" '
    def format_date: if . then (. | split("T")[0]) else "N/A" end;

    def format_comments:
      if . and (. | length) > 0 then
        . | map("    - @\(.author.login // "unknown") (\(.createdAt | format_date)): \(.url)") | join("\n")
      else
        "    (no comments)"
      end;

    def format_labels:
      if . and .nodes and (.nodes | length) > 0 then
        .nodes | map(.name) | join(", ")
      else
        ""
      end;

    def filter_recent($since):
      select(.updatedAt >= $since or .createdAt >= $since);

    .data | to_entries | map(
      "=== REPOSITORY: \(.value.nameWithOwner) ===\n" +

      "\n--- PULL REQUESTS ---\n" +
      (if .value.pullRequests.nodes and (.value.pullRequests.nodes | length) > 0 then
        (.value.pullRequests.nodes | map(select(.updatedAt >= $since)) |
          if length > 0 then
            map(
              "PR #\(.number): \"\(.title)\"\n" +
              "  URL: \(.url)\n" +
              "  Status: \(.state)" +
              (if .state == "MERGED" then " (merged \(.mergedAt | format_date))"
               elif .state == "CLOSED" then " (closed \(.closedAt | format_date))"
               else " (updated \(.updatedAt | format_date))" end) + "\n" +
              "  Author: @\(.author.login // "unknown")\n" +
              (if (.labels | format_labels) != "" then "  Labels: \(.labels | format_labels)\n" else "" end) +
              "  Comments:\n\(.comments.nodes | format_comments)"
            ) | join("\n\n")
          else
            "(no recent PR activity)"
          end)
      else
        "(no recent PR activity)"
      end) +

      "\n\n--- ISSUES ---\n" +
      (if .value.issues.nodes and (.value.issues.nodes | length) > 0 then
        (.value.issues.nodes |
          if length > 0 then
            map(
              "Issue #\(.number): \"\(.title)\"\n" +
              "  URL: \(.url)\n" +
              "  Status: \(.state)" +
              (if .state == "CLOSED" then " (closed \(.closedAt | format_date))"
               else " (updated \(.updatedAt | format_date))" end) + "\n" +
              "  Author: @\(.author.login // "unknown")\n" +
              (if (.labels | format_labels) != "" then "  Labels: \(.labels | format_labels)\n" else "" end) +
              "  Comments:\n\(.comments.nodes | format_comments)"
            ) | join("\n\n")
          else
            "(no recent issue activity)"
          end)
      else
        "(no recent issue activity)"
      end) +

      "\n\n--- DISCUSSIONS ---\n" +
      (if .value.discussions and .value.discussions.nodes and (.value.discussions.nodes | length) > 0 then
        (.value.discussions.nodes | map(select(.updatedAt >= $since)) |
          if length > 0 then
            map(
              "Discussion #\(.number): \"\(.title)\"\n" +
              "  URL: \(.url)\n" +
              "  Category: \(.category.name // "General")\n" +
              "  Author: @\(.author.login // "unknown")\n" +
              "  Updated: \(.updatedAt | format_date)\n" +
              "  Comments:\n\(.comments.nodes | format_comments)"
            ) | join("\n\n")
          else
            "(no recent discussion activity)"
          end)
      else
        "(no discussions)"
      end)
    ) | join("\n\n\n")
  ' raw-activity.json
}

# Build the complete prompt
build_prompt() {
  cat <<'SYSTEM_CONTEXT'
You are a technical analyst summarizing the daily activity across the libp2p ecosystem. The libp2p project is a modular networking stack for peer-to-peer applications.

The repositories you are analyzing include:
- Core implementations: go-libp2p, rust-libp2p, js-libp2p, py-libp2p, jvm-libp2p, nim-libp2p, zig-libp2p, dotnet-libp2p, c-libp2p, swift-libp2p, litep2p
- Specifications: specs
- Testing: test-plans
- Examples: universal-connectivity, workshop
- Main organization: libp2p

SYSTEM_CONTEXT

  echo ""
  echo "Week: $START_DATE to $END_DATE"
  echo ""
  echo "=== ACTIVITY DATA ==="
  echo ""

  format_activity

  cat <<'INSTRUCTIONS'


=== INSTRUCTIONS ===

Based on the activity data above, create a summary of 3-5 notable topics from the past ${DAYS_BACK:-7} days. Focus on:
- Significant merged PRs or new features
- Important bug fixes
- Active discussions or decisions
- Cross-implementation coordination
- Breaking changes or deprecations

For each topic, provide:
1. A concise title (5-10 words)
2. A brief description (2-3 sentences) explaining what happened and why it matters
3. Include inline reference links to the relevant GitHub URLs

Output ONLY valid HTML in this exact format (no markdown, no code blocks, no explanations):

<div class="update-item">
    <div class="update-item__title">Topic Title Here</div>
    <div class="update-item__description">
        Description of the topic with inline links like
        <a href="https://github.com/...">[1]</a> and
        <a href="https://github.com/...">[2]</a>.
    </div>
</div>

Important:
- Output 3-5 update-item divs
- Use the exact class names: "update-item", "update-item__title", "update-item__description"
- Include real GitHub URLs from the activity data
- Do not include any text before or after the HTML divs
- Do not wrap output in code blocks or markdown
INSTRUCTIONS
}

# Generate the prompt
PROMPT=$(build_prompt)

# Check prompt size
PROMPT_SIZE=$(echo "$PROMPT" | wc -c)
echo "Prompt size: $PROMPT_SIZE bytes"

# Truncate if too large (250KB limit)
MAX_SIZE=256000
if [ "$PROMPT_SIZE" -gt "$MAX_SIZE" ]; then
  echo "::warning::Prompt exceeds 250KB, truncating activity data"

  # Rebuild with truncated data
  TRUNCATED_ACTIVITY=$(format_activity | head -c 200000)
  PROMPT=$(cat <<EOF
You are a technical analyst summarizing the daily activity across the libp2p ecosystem.

Week: $START_DATE to $END_DATE

=== ACTIVITY DATA (TRUNCATED) ===

$TRUNCATED_ACTIVITY

[... data truncated due to size ...]

=== INSTRUCTIONS ===

Based on the activity data above, create a summary of 3-5 notable topics from the past ${DAYS_BACK:-7} days.

Output ONLY valid HTML in this exact format:

<div class="update-item">
    <div class="update-item__title">Topic Title Here</div>
    <div class="update-item__description">
        Description with inline links like <a href="https://github.com/...">[1]</a>.
    </div>
</div>

Output 3-5 divs. Use exact class names. Include real GitHub URLs. No markdown or code blocks.
EOF
)
fi

# Save the prompt
echo "$PROMPT" > formatted-prompt.txt
echo "Prompt saved to formatted-prompt.txt"
