+++
title = "Refactoring the libp2p Test Framework: A Fresh Start"
description = "Announcing the complete rewrite of the libp2p test-plans framework from TypeScript to Bash, delivering cross-platform support, powerful filtering, reproducibility, testing on arbitrary network topologies with almost zero depedency maintenance overhead."
date = 2026-01-28
slug = "new-test-plans"

[taxonomies]
tags = ["testing", "libp2p", "interoperability", "performance"]

[extra]
author = "Dave Grantham"
header_video = "/img/blog/test-plans-animation.mp4"
+++

The libp2p ecosystem spans multiple programming languages, transports, and protocols. Testing interoperability across this diverse landscape has always been challenging. Today, we're announcing a complete rewrite of the [test-plans repository](https://github.com/libp2p/test-plans) that fundamentally improves how we test libp2p implementations.

## Why a Complete Rewrite?

The original test framework was built with TypeScript, Docker Compose, and various npm dependencies. While functional, it presented several challenges:

- **Complex dependency chains**: Node.js, npm, and Python dependencies created friction for contributors and a perpetual dependency maintenance headache
- **Platform inconsistencies**: Tests behaved differently across Linux, macOS, and Windows
- **Limited reproducibility**: Recreating test failures was difficult without considerable effort
- **Rigid test selection**: Running specific subsets of tests required manual configuration
- **Slow iteration cycles**: The build and test pipeline was optimized for CI, not local development

More importantly, 2026 marks a pivotal year for libp2p research efforts focused on scaling and optimization. As we push the boundaries of what's possible with peer-to-peer networking, we need a test framework that can keep pace. Researchers investigating new transport protocols, scaling strategies, and exploring AI-driven dynamic protocols require fast feedback loops, reproducible experiments, and the ability to quickly iterate on implementations across multiple languages. The old framework simply couldn't support the velocity and rigor that this research demands.

We set out to address these issues with a clear set of goals.

## The 10 Primary Goals

### 1. Cross-Platform Support

The new framework runs natively on Linux, macOS, and Windows (via WSL). We've eliminated platform-specific code paths and ensured consistent behavior across all environments. A developer on macOS can reproduce the exact test that failed in CI on Linux.

### 2. Minimal Dependencies

We reduced dependencies to the essentials:

- **Bash 4.0+** (for associative arrays and modern shell features)
- **Docker 20.10+** with Docker Compose v2
- **yq 4.0+** (for YAML processing)
- **Git 2.0+**

No Node.js. No npm. No Python. No pip. Just standard tools available on any development machine.

### 3. Reproducible Testing in CI/CD and Local Environments

The framework is optimized for both CI pipelines and local development. You can run the same commands locally that CI runs, with identical results. Quick feedback loops enable faster iteration. The snapshot capability supports capturing the entire test setup—including inputs, docker images, and environment variables—into a downloadable artifact that can be unpacked locally and re-run with a single command, fully reproducing the exact same test pass that was executed on the CI/CD infrastructure. This local reproducibility greatly increases the velocity of developers debugging tests and fixing compatibility issues. It also helps with optimization work by recreating the same conditions locally that led to the measured results in the CI/CD environment.

### 4. Follow CI/CD and Programming Conventions

We adhere to standard patterns: clear exit codes, structured logging to stderr, machine-readable output to stdout, and conventional command-line arguments. The barrier to entry is low for anyone familiar with shell scripting.

### 5. Code Reusability via Shared Library

The `lib/` directory contains 19 reusable shell scripts (~4,000+ lines) that provide common functionality:

- **Filter engine** with alias expansion and negation
- **Image building** for GitHub, local, and browser sources
- **Caching** with content-addressed keys
- **Test execution** coordination with Redis
- **Output formatting** for consistent terminal UI

Each test suite (perf, transport, hole-punch) imports these libraries, ensuring consistency and reducing duplication.

### 6. Aggressive Caching

Three levels of caching dramatically improve performance:

| Cache Type | Miss | Hit | Speedup |
|------------|------|-----|---------|
| Test matrix | 2-5s | 50-200ms | 10-100x |
| GitHub snapshots | 5-30s | 1-2s | 5-15x |
| Docker images | 30-300s | 0.1s | 300-3000x |

The test matrix cache uses a content-addressed key computed from `images.yaml` and all filter parameters. Change a filter, get a new key. Same filters, same cached matrix.

### 7. Fine-Grained Filtering

The two-stage filtering model provides precise control:

**Stage 1 (SELECT)**: Narrow from the complete list
```bash
./run.sh --impl-select "~rust|~go"  # Only rust and go implementations
```

**Stage 2 (IGNORE)**: Remove from selected set
```bash
./run.sh --impl-ignore "experimental"  # Exclude experimental versions
```

Filter dimensions include:
- `--impl-select/ignore`: Filter implementations
- `--transport-select/ignore`: Filter transports (tcp, quic-v1, ws, etc.)
- `--secure-select/ignore`: Filter secure channels (noise, tls)
- `--muxer-select/ignore`: Filter muxers (yamux, mplex)
- `--test-select/ignore`: Filter by test name pattern

Aliases make common patterns easy:
```bash
./run.sh --impl-select "~rust"  # Expands to rust-v0.56|rust-v0.55|rust-v0.54|...
./run.sh --impl-ignore "!~rust"  # Everything NOT matching rust (negation)
```

### 8. YAML Configuration with Comments

All configuration uses YAML files with extensive comments:

- **images.yaml**: Implementation definitions with versions, transports, and sources
- **inputs.yaml**: Auto-generated capture of all test parameters
- **test-matrix.yaml**: Generated test combinations with metadata

Human-readable configuration lowers the barrier to understanding and modification.

### 9. Local and Remote Test Applications with Patching

Testing local changes doesn't require forking repositories. The patching strategy lets you:

1. Clone an implementation locally
2. Make your changes
3. Generate a patch file
4. Reference it in `images.yaml`

The framework downloads the upstream snapshot, applies your patch, and builds the image. See our [Local Testing Strategies](/guides/local-testing-strategies/) guide for details.

### 10. Docker for Arbitrary Network Layouts

Each test suite uses Docker to create isolated, reproducible network environments:

- **Transport tests**: Simple dialer/listener on a shared network
- **Performance tests**: Controlled environment for accurate measurements
- **Hole-punch tests**: Complex topology with NAT routers, relay servers, and isolated LANs

The hole-punch tests create five containers per test with three networks, simulating realistic NAT traversal scenarios.

## What Changed: By the Numbers

Between commits `f58b7472` and `d6e5bea1`:

- **196 commits** of focused development
- **284 files** changed
- **+73,488 insertions**, **-49,912 deletions**
- **11 new documentation files** (~6,000+ lines)
- Migration from TypeScript to **~4,000+ lines** of shared bash libraries

The result is a simpler, more maintainable codebase that's easier to understand and extend.

## Test Suites

### Performance Benchmarking (`perf/`)

Measures the overhead that libp2p introduces:

- **Upload throughput** (bytes/second)
- **Download throughput** (bytes/second)
- **Latency** with statistical distribution (min, q1, median, q3, max, outliers)

Baseline tests against iperf, raw QUIC, and HTTPS establish reference points for measuring libp2p overhead.

### Transport Interoperability (`transport/`)

Verifies cross-implementation compatibility:

- **Dial success/failure**
- **Handshake latency**
- **Ping latency**

Tests run in parallel (default: CPU core count) for fast feedback on large test matrices.

### Hole-Punch NAT Traversal (`hole-punch/`)

Tests the DCUtR protocol for establishing direct connections through NAT:

- Realistic network topology with NAT routers
- Relay server coordination
- Direct connection verification

Each test gets unique subnets calculated from the test key, enabling parallel execution without network conflicts.

## Implementation Coverage

The test suite covers implementations in:

- **Rust** (rust-libp2p)
- **Go** (go-libp2p)
- **JavaScript** (js-libp2p v1.x, v2.x, v3.x)
- **Python** (py-libp2p)
- **Nim** (nim-libp2p)
- **JVM** (jvm-libp2p)
- **C** (c-libp2p)
- **.NET** (dotnet-libp2p)
- **Zig** (zig-libp2p)
- **Browsers** (via WebRTC and WebTransport)

With 40+ implementation variations across different versions and configurations.

## Getting Started

### Check Dependencies

```bash
cd perf
./run.sh --check-deps
```

### List Available Implementations

```bash
./run.sh --list-images
```

### Preview Test Selection

```bash
./run.sh --impl-select "~rust" --list-tests
```

### Run Tests

```bash
# Performance tests with rust implementations
cd perf
./run.sh --impl-select "~rust" --iterations 5

# Transport interoperability
cd transport
./run.sh --impl-select "~rust|~go"

# Hole-punch tests
cd hole-punch
./run.sh --impl-select "~rust"
```

### Create Reproducible Snapshots

```bash
./run.sh --impl-select "~rust" --snapshot
```

The snapshot captures everything needed to reproduce the test run.

## Reproducibility with inputs.yaml

Every test run generates an `inputs.yaml` file capturing:

- All command-line arguments
- Environment variables
- Filter settings
- Test-specific parameters

To reproduce a previous run:

```bash
cp /srv/cache/test-run/perf-abc12345/inputs.yaml ./
./run.sh
```

The framework reads `inputs.yaml` at startup and applies the same configuration.

## Future Work

- **Remote host testing** via Docker Swarm for real network conditions
- **Additional test suites** for other protocols
- **Improved reporting** with historical comparisons
- **Community contributions** welcome for new implementations

## Resources

- [test-plans repository](https://github.com/libp2p/test-plans)
- [Local Testing Strategies](/guides/local-testing-strategies/) - Installation, filtering, and patching
- [Write a Performance Test Application](/guides/write-a-perf-test-app/)
- [Write a Transport Test Application](/guides/write-a-transport-test-app/)
- [Write a Hole-Punch Test Application](/guides/write-a-hole-punch-test-app/)

We believe this rewrite significantly improves the developer experience for testing libp2p implementations. The combination of cross-platform support, powerful filtering, reproducibility, and comprehensive documentation makes it easier than ever to ensure your libp2p implementation works correctly with the rest of the ecosystem.

Try it out, and let us know what you think!
