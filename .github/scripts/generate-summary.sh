#!/bin/bash
# generate-summary.sh - Send prompt to Ollama and get LLM response
set -euo pipefail

# Check if generation should be skipped
if [ "${SKIP_GENERATION:-false}" = "true" ]; then
  echo "Skipping LLM generation (no activity)"
  exit 0
fi

# Configuration
OLLAMA_URL="${OLLAMA_URL:-http://doc:11434/api/generate}"
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3.1:8b}"
MAX_RETRIES=3
TIMEOUT=600  # 10 minutes

echo "Generating summary with Ollama..."
echo "  URL: $OLLAMA_URL"
echo "  Model: $OLLAMA_MODEL"

# Read the prompt
if [ ! -f formatted-prompt.txt ]; then
  echo "Error: formatted-prompt.txt not found"
  exit 1
fi

PROMPT=$(cat formatted-prompt.txt)

# Build the request payload
build_request() {
  jq -n \
    --arg model "$OLLAMA_MODEL" \
    --arg prompt "$PROMPT" \
    '{
      model: $model,
      prompt: $prompt,
      stream: false,
      options: {
        temperature: 0.3,
        top_p: 0.9,
        num_predict: 2048
      }
    }'
}

# Call Ollama API with retries
call_ollama() {
  local attempt=1
  local backoff=30

  while [ $attempt -le $MAX_RETRIES ]; do
    echo "Attempt $attempt of $MAX_RETRIES..."

    # Check if Ollama is reachable
    if ! curl -s --connect-timeout 10 "${OLLAMA_URL%/api/generate}/api/tags" > /dev/null 2>&1; then
      echo "::warning::Ollama server not reachable at $OLLAMA_URL"
      if [ $attempt -lt $MAX_RETRIES ]; then
        echo "Waiting ${backoff}s before retry..."
        sleep $backoff
        backoff=$((backoff * 2))
        attempt=$((attempt + 1))
        continue
      else
        return 1
      fi
    fi

    # Make the API call
    HTTP_CODE=$(curl -s -w "%{http_code}" \
      --max-time $TIMEOUT \
      -o ollama-response.json \
      -H "Content-Type: application/json" \
      -d "$(build_request)" \
      "$OLLAMA_URL" 2>/tmp/curl-error.txt) || true

    if [ "$HTTP_CODE" = "200" ] && [ -f ollama-response.json ] && [ -s ollama-response.json ]; then
      # Check if response contains valid data
      if jq -e '.response' ollama-response.json > /dev/null 2>&1; then
        echo "Ollama request successful"
        return 0
      else
        echo "::warning::Ollama response missing 'response' field"
        cat ollama-response.json
      fi
    else
      echo "::warning::Ollama request failed (HTTP $HTTP_CODE)"
      if [ -f /tmp/curl-error.txt ]; then
        cat /tmp/curl-error.txt
      fi
      if [ -f ollama-response.json ]; then
        cat ollama-response.json
      fi
    fi

    if [ $attempt -lt $MAX_RETRIES ]; then
      echo "Waiting ${backoff}s before retry..."
      sleep $backoff
      backoff=$((backoff * 2))
    fi
    attempt=$((attempt + 1))
  done

  return 1
}

# Main execution
if ! call_ollama; then
  echo "::error::Failed to get response from Ollama after $MAX_RETRIES attempts"
  echo "OLLAMA_FAILED=true" >> "$GITHUB_ENV"
  exit 1
fi

# Extract the response text
jq -r '.response' ollama-response.json > llm-output.html

# Show output size
OUTPUT_SIZE=$(wc -c < llm-output.html)
echo "LLM output size: $OUTPUT_SIZE bytes"

# Quick preview
echo "--- Output preview (first 500 chars) ---"
head -c 500 llm-output.html
echo ""
echo "--- End preview ---"
