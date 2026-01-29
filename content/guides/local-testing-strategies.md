+++
title = "Local Testing Strategies"
description = "Learn how to run libp2p interoperability and performance tests locally, including installation, filtering, snapshots, and local patching."
weight = 80

[extra]
toc = true
category = "testing"
+++

Running libp2p tests locally enables rapid iteration and debugging. The test-plans framework provides powerful tools for reproducibility through snapshots, flexible test selection through filtering, and local development through patching.

## Prerequisites

### System Requirements

- **Bash 4.0+** (required for associative arrays)
- **Docker 20.10+** with Docker Compose v2
- **yq 4.0+** (YAML processor)
- **Git 2.0+**
- Standard UNIX tools (curl, openssl, patch, wget, etc.)

## Installation

### Linux (Debian 13)

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y bash docker.io git curl patch wget zip unzip

# Install yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64 \
  -O /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq

# Install Docker Compose v2 (if not included with docker.io)
sudo apt install docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Clone test-plans
git clone https://github.com/libp2p/test-plans.git
cd test-plans
```

### macOS

```bash
# Using Homebrew
brew install bash docker yq git

# Start Docker Desktop
open -a Docker

# Verify bash version (must be 4.0+)
/opt/homebrew/bin/bash --version

# Clone test-plans
git clone https://github.com/libp2p/test-plans.git
cd test-plans

# Run with Homebrew bash (macOS ships with bash 3.x)
/opt/homebrew/bin/bash perf/run.sh --check-deps
```

### Windows (WSL)

```bash
# Install WSL2 with Ubuntu
wsl --install -d Ubuntu

# Inside WSL Ubuntu
sudo apt update
sudo apt install -y bash docker.io git curl patch wget zip unzip

# Install yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64 \
  -O /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq

# Configure Docker (ensure Docker Desktop WSL integration is enabled)
# Or install Docker in WSL directly

# Clone test-plans
git clone https://github.com/libp2p/test-plans.git
cd test-plans
```

## Verification

Run the dependency checker to verify your environment:

```bash
cd perf
./run.sh --check-deps
```

Expected output:

```
                        ╔╦╦╗  ╔═╗
▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ║╠╣╚╦═╬╝╠═╗ ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
═══════════════════════ ║║║║║║║╔╣║║ ════════════════════════
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔ ╚╩╩═╣╔╩═╣╔╝ ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                            ╚╝  ╚╝

╲ Checking dependencies...
 ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
  → Checking versioned tools...
    → bash...              [OK] 5.2
    → docker...            [OK] 29.1.5
    → yq...                [OK] 4.48.1
    → git...               [OK] 2.47.3

  → Checking required utilities...
    → patch...             [OK]
    → wget...              [OK]
    → zip...               [OK]
    → unzip...             [OK]
    → cut...               [OK]
    → bc...                [OK]
    → sha256sum...         [OK]
    → timeout...           [OK]
    → flock...             [OK]
    → tar...               [OK]
    → gzip...              [OK]
    → awk...               [OK]
    → sed...               [OK]
    → grep...              [OK]
    → sort...              [OK]
    → head...              [OK]
    → tail...              [OK]
    → wc...                [OK]
    → tr...                [OK]
    → paste...             [OK]
    → cat...               [OK]
    → mkdir...             [OK]
    → cp...                [OK]
    → mv...                [OK]
    → rm...                [OK]
    → chmod...             [OK]
    → find...              [OK]
    → xargs...             [OK]
    → basename...          [OK]
    → dirname...           [OK]
    → mktemp...            [OK]
    → date...              [OK]
    → sleep...             [OK]
    → uname...             [OK]
    → hostname...          [OK]
    → ps...                [OK]

  → Checking Docker services...
    → docker daemon...     [OK]
    → docker compose...    [OK] using 'docker compose'

  → Checking optional dependencies...
    → gnuplot...           [OK] 6.0
    → pandoc...            [OK]

  ✓ All required dependencies are satisfied
```

## Understanding the Filtering System

The test-plans framework uses a powerful two-stage filtering model that lets you precisely control which tests run.

### Filter Syntax: Pipe-Separated Substring Matching

Filters are specified as `|`-separated strings, where each part is used for **substring matching** against the target value. A filter matches if **any** of the pipe-separated parts is found as a substring.

For example, in the transport test suite, using `--test-select 'rust'` selects all tests where the test name contains the substring "rust". Since test names follow the format `dialer x listener (transport, secure, muxer)`, this matches any test where either the dialer or listener contains "rust":

```bash
# This selects tests like:
#   rust-v0.56 x rust-v0.56 (tcp, noise, yamux)
#   rust-v0.55 x go-v0.45 (quic-v1)
#   chromium-rust-v0.56 x rust-v0.56 (webrtc-direct)
#   go-v0.45 x rust-v0.56 (tcp, tls, yamux)
./run.sh --test-select 'rust'

# Multiple patterns: matches tests containing "rust" OR "go"
./run.sh --test-select 'rust|go'

# More specific: only tests with rust-v0.56 as dialer
./run.sh --test-select 'rust-v0.56 x'
```

### Two-Stage Model: SELECT then IGNORE

**Stage 1: SELECT** - Narrows from the complete list
- Empty SELECT = include all items
- Use `--impl-select`, `--transport-select`, etc.

**Stage 2: IGNORE** - Removes items from the selected set
- Empty IGNORE = remove nothing
- Use `--impl-ignore`, `--transport-ignore`, etc.

### Alias Expansion

The `images.yaml` file defines aliases for common patterns:

```yaml
test-aliases:
  - alias: rust
    value: "rust-v0.56|rust-v0.55|rust-v0.54"
  - alias: go
    value: "go-v0.45|go-v0.44"
  - alias: stable
    value: "~rust|~go"
```

Use aliases with the `~` prefix:
- `~rust` expands to all rust versions
- `!~rust` (negation) matches everything NOT matching rust

### Filter Dimensions

- `--impl-select/ignore`: Filter implementations
- `--baseline-select/ignore`: Filter baseline tests (perf only)
- `--transport-select/ignore`: Filter transport protocols
- `--secure-select/ignore`: Filter secure channels
- `--muxer-select/ignore`: Filter muxers
- `--test-select/ignore`: Filter by test name pattern

### Filtering Examples

```bash
# Run only rust implementations
./run.sh --impl-select "~rust"

# Run rust and go, exclude experimental
./run.sh --impl-select "~rust|~go" --impl-ignore "experimental"

# Only TCP and QUIC transports
./run.sh --transport-select "tcp|quic-v1"

# Only noise secure channel
./run.sh --secure-select "noise"

# Complex: rust + TCP + noise
./run.sh --impl-select "~rust" \
         --transport-select "tcp" \
         --secure-select "noise"
```

### Listing Without Running

Preview which tests would run before executing:

```bash
# Preview which tests would run
./run.sh --impl-select "~rust" --list-tests

# List available implementations
./run.sh --list-images
```

## Working with Snapshots

### What Are Snapshots?

Snapshots capture the complete test configuration for reproducibility:
- `inputs.yaml` - all command-line args and environment variables
- `images.yaml` - implementation definitions
- `test-matrix.yaml` - generated test combinations
- Results and logs

### Creating a Snapshot

```bash
# Run tests and create snapshot
./run.sh --impl-select "~rust" --iterations 5 --snapshot

# Snapshot saved to:
# /srv/cache/snapshots/perf-<key>-<timestamp>.zip
```

### Reproducing from Snapshot

```bash
# Copy inputs.yaml from previous run
cp /srv/cache/test-run/perf-abc12345-183045-01-01-2026/inputs.yaml ./

# Re-run with identical configuration
./run.sh

# Override specific parameters if needed
./run.sh --iterations 20
```

## Local Patching Strategy

The patching strategy lets you test local changes without forking the remote repository. The framework downloads the GitHub snapshot, applies your patch, then builds using the remote Dockerfile.

### Step 1: Create a Working Directory

```bash
mkdir -p images/rust/v0.55
```

### Step 2: Clone the Implementation Repository

```bash
cd images/rust/v0.55
git clone https://github.com/libp2p/rust-libp2p .
git checkout v0.55.0
```

### Step 3: Make Your Changes

Edit the test application code to implement your fix or feature:

```bash
# Make changes to get the test application working
vim interop-tests/src/main.rs
```

### Step 4: Create the Patch File

Generate a unified diff patch:

```bash
git diff -U > ../test-app.patch
```

### Step 5: Update images.yaml

Keep the `source.type` as `github` but add `patchPath` and `patchFile` fields:

```yaml
implementations:
  - id: rust-v0.55
    imageType: peer
    transports: [tcp, quic-v1]
    secureChannels: [noise, tls]
    muxers: [yamux]
    source:
      type: github
      org: libp2p
      repo: rust-libp2p
      commit: abc123def456
      dockerfile: interop-tests/Dockerfile
      patchPath: images/rust/v0.55         # Directory where patch applies
      patchFile: test-app.patch            # Path to your patch file
```

### Step 6: Run the Tests

The framework will:
1. Download the GitHub snapshot
2. Apply your patch to the specified directory
3. Build the Docker image using the remote Dockerfile

```bash
# Test your patched implementation
./run.sh --impl-select "rust-v0.55"

# Compare patched vs another version
./run.sh --impl-select "rust-v0.55|rust-v0.56"

# Run just the "rust-v0.55 x js-v3.x (quic-v1)" test
./run.sh --test-select "rust-v0.55 x js-v3.x" --transport-ignore '!quic'
```

## Best Practices

### Start Small, Listing First

Run a minimal set of tests first and have them listed to see what your filters select:

```bash
# First run with minimal tests and list them
./run.sh --impl-select "rust-v0.56" --list-tests
```

### Use Caching

The framework caches test matrices and Docker images. Avoid `--force-*` flags unless necessary:

```bash
# Force rebuild only when needed
./run.sh --force-image-rebuild  # Rebuild Docker images
./run.sh --force-matrix-rebuild # Regenerate test matrix
```

Specify the `CACHE_DIR` to determine where the cached files are stored:

```bash
CACHE_DIR=/srv/cache ./run.sh --test-ignore '~failing'
```

### Check Logs

Logs are stored in the test pass directory:

```bash
# View logs from a test run
ls /srv/cache/test-run/perf-*/logs/

# Tail a specific test log
tail -f /srv/cache/test-run/perf-*/logs/rust-v0.56-x-rust-v0.56-tcp-noise-yamux.log
```

### Clean Up Periodically

```bash
# Remove old test runs
rm -rf "${CACHE_DIR:-.cache}"

# Prune Docker
docker system prune -af
```

## Troubleshooting

### "bash: associative array: bad array subscript"

Ensure you're using bash 4.0+. On macOS, use Homebrew bash:

```bash
/opt/homebrew/bin/bash run.sh
```

Using Homebrew to install bash and setting your `PATH` environment variable to search /opt/homebrew/bin before other folders makes automatic using the correct version of bash.

### Docker Permission Denied

Add your user to the docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### yq Command Not Found

The `yq` command is the only dependency that isn't commonly installed on the target development machines. Fortunately, it is a standalone binary that can be installed from Github easily. There are pre-built binaries for all of our target operating systems and hardware architecture. Install yq from GitHub releases, not the snap package (different tool with same name):

```bash
sudo wget https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64 \
  -O /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq
```

## Next Steps

- [Write a Performance Test Application](/guides/write-a-perf-test-app/)
- [Write a Transport Test Application](/guides/write-a-transport-test-app/)
- [Write a Hole-Punch Test Application](/guides/write-a-hole-punch-test-app/)
