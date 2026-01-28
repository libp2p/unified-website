+++
title = "go-libp2p v0.36.0"
description = "This release includes major performance improvements for connection handling and new WebTransport features."
date = 2026-01-15
draft = true

[extra]
version = "v0.36.0"
implementation = "go"
breaking = false
security = false
github_release = "https://github.com/libp2p/go-libp2p/releases/tag/v0.36.0"
+++

## Highlights

- Improved connection handling performance
- New WebTransport features
- Bug fixes and stability improvements

## New Features

### Connection Manager Improvements

The connection manager has been significantly improved with better memory efficiency and faster connection pruning.

### WebTransport Updates

WebTransport now supports server-initiated streams and improved error handling.

## Bug Fixes

- Fixed memory leak in peer store
- Resolved race condition in connection upgrade
- Fixed timeout handling in QUIC transport

## Breaking Changes

None in this release.

## Deprecations

- `OldFunction()` is deprecated and will be removed in v0.38.0. Use `NewFunction()` instead.

## Full Changelog

See the [GitHub release](https://github.com/libp2p/go-libp2p/releases/tag/v0.36.0) for the complete list of changes.
