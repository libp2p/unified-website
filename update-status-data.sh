#!/usr/bin/env bash
#
# Downloads the latest interop results and rebuilds the status page
#

set -euo pipefail

TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Download to temporary file
curl -fsSL "https://results.s3.filebase.com/results.yaml" \
    -o "$TEMP_FILE"

# Move to final location
mkdir -p static/data/status
mv "$TEMP_FILE" static/data/status/interop-results.yml

echo "Downloaded static/data/status/interop-results.yml"

# Generate status content pages from the YAML data
./generate-status-pages.sh

# Build the site to generate the status page
zola build && echo "Status page generated at public/status/index.html"
