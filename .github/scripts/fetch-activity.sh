#!/bin/bash
# fetch-activity.sh - Fetch GitHub activity from libp2p ecosystem repositories
set -euo pipefail

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Calculate date range
SINCE_DATE=$(date -d "${DAYS_BACK:-7} days ago" -u +"%Y-%m-%dT00:00:00Z")
echo "Fetching activity since: $SINCE_DATE"

# Generate unique alias from repo name (replace special chars)
make_alias() {
  echo "$1" | tr '/-' '__'
}

# Build GraphQL query for a batch of repositories
build_batch_query() {
  local repos=("$@")

  echo "query {"
  for repo in "${repos[@]}"; do
    owner="${repo%/*}"
    name="${repo#*/}"
    alias=$(make_alias "$repo")

    cat <<EOF
  ${alias}: repository(owner: "${owner}", name: "${name}") {
    nameWithOwner
    pullRequests(first: 20, orderBy: {field: UPDATED_AT, direction: DESC}) {
      nodes {
        number
        title
        url
        state
        createdAt
        updatedAt
        mergedAt
        closedAt
        author { login }
        labels(first: 5) { nodes { name } }
        comments(first: 5) {
          nodes {
            url
            createdAt
            author { login }
          }
        }
      }
    }
    issues(first: 20, orderBy: {field: UPDATED_AT, direction: DESC}, filterBy: {since: "${SINCE_DATE}"}) {
      nodes {
        number
        title
        url
        state
        createdAt
        updatedAt
        closedAt
        author { login }
        labels(first: 5) { nodes { name } }
        comments(first: 5) {
          nodes {
            url
            createdAt
            author { login }
          }
        }
      }
    }
  }
EOF
  done
  echo "}"
}

# Fetch using GraphQL in batches
fetch_with_graphql() {
  echo "Fetching with GraphQL in batches..."

  local batch_size=4
  local total=${#REPOS[@]}
  local combined='{"data":{}}'

  for ((i=0; i<total; i+=batch_size)); do
    local batch=("${REPOS[@]:i:batch_size}")
    echo "  Batch $((i/batch_size + 1)): ${batch[*]}"

    local query
    query=$(build_batch_query "${batch[@]}")

    local result
    if ! result=$(gh api graphql -f query="$query" 2>/tmp/graphql-error.txt); then
      echo "  GraphQL batch failed:"
      cat /tmp/graphql-error.txt
      return 1
    fi

    # Merge batch result into combined
    combined=$(echo "$combined" | jq --argjson batch "$result" '.data += $batch.data')

    # Small delay to avoid rate limiting
    sleep 0.5
  done

  echo "$combined" > raw-activity.json
  echo "GraphQL fetch complete"
  return 0
}

# Fallback: fetch via REST API
fetch_with_rest() {
  echo "Falling back to REST API..."

  # Initialize output file
  echo '{"data":{}}' > raw-activity.json

  for repo in "${REPOS[@]}"; do
    echo "  Fetching $repo..."
    alias=$(make_alias "$repo")

    # Fetch PRs
    prs=$(gh api "repos/$repo/pulls?state=all&sort=updated&direction=desc&per_page=20" 2>/dev/null || echo "[]")

    # Fetch issues (exclude PRs)
    issues_raw=$(gh api "repos/$repo/issues?state=all&sort=updated&direction=desc&per_page=20&since=$SINCE_DATE" 2>/dev/null || echo "[]")

    # Filter out PRs from issues and transform
    issues=$(echo "$issues_raw" | jq '[.[] | select(.pull_request == null)]')

    # Transform REST format to match GraphQL format and write to temp file
    jq -n \
      --arg name "$repo" \
      --argjson prs "$prs" \
      --argjson issues "$issues" \
      '{
        nameWithOwner: $name,
        pullRequests: { nodes: ($prs | map({
          number: .number,
          title: .title,
          url: .html_url,
          state: (if .merged_at then "MERGED" elif .state == "closed" then "CLOSED" else "OPEN" end),
          createdAt: .created_at,
          updatedAt: .updated_at,
          mergedAt: .merged_at,
          closedAt: .closed_at,
          author: { login: (.user.login // "unknown") },
          labels: { nodes: (.labels | map({ name: .name })) },
          comments: { nodes: [] }
        })) },
        issues: { nodes: ($issues | map({
          number: .number,
          title: .title,
          url: .html_url,
          state: (if .state == "closed" then "CLOSED" else "OPEN" end),
          createdAt: .created_at,
          updatedAt: .updated_at,
          closedAt: .closed_at,
          author: { login: (.user.login // "unknown") },
          labels: { nodes: (.labels | map({ name: .name })) },
          comments: { nodes: [] }
        })) }
      }' > "/tmp/repo_${alias}.json"

    # Merge into main file
    jq --arg alias "$alias" --slurpfile repo "/tmp/repo_${alias}.json" '.data[$alias] = $repo[0]' raw-activity.json > raw-activity.json.tmp
    mv raw-activity.json.tmp raw-activity.json

    # Small delay
    sleep 0.2
  done

  echo "REST API fetch complete"
}

# Main execution
if ! fetch_with_graphql; then
  fetch_with_rest
fi

# Verify output
if [ ! -f raw-activity.json ] || [ ! -s raw-activity.json ]; then
  echo "Error: Failed to fetch activity data"
  exit 1
fi

# Count items fetched
total_prs=$(jq '[.data[].pullRequests.nodes | length] | add // 0' raw-activity.json)
total_issues=$(jq '[.data[].issues.nodes | length] | add // 0' raw-activity.json)

echo "Fetched: $total_prs PRs, $total_issues issues"

# Check if we have any activity
if [ "$total_prs" -eq 0 ] && [ "$total_issues" -eq 0 ]; then
  echo "::warning::No activity found in the past ${DAYS_BACK:-7} days"
  echo "EMPTY_ACTIVITY=true" >> "${GITHUB_ENV:-/dev/null}"
fi
