+++
title = "rust-libp2p in 2022"
description = "Recapitulating the year 2022 for the rust-libp2p project"
date = 2023-01-12
slug = "2023-01-12-rust-libp2p-in-2022"

[taxonomies]
tags = ["libp2p", "rust"]

[extra]
author = "Max Inden"
header_image = "/img/blog/rust-libp2p-2022-header.png"
+++
The [rust-libp2p](https://github.com/libp2p/rust-libp2p) project has made significant strides in 2022, with numerous technical advancements and improvements to the project itself. This is the work of many across various organizations including Protocol Labs, Parity Technologies, Sigma Prime, Iroh, Actyx and Little Bear Labs.

## Technical Highlights

### Decentralized Hole Punching

We started the year with the release of the various components needed for hole punching. We added the Circuit Relay v2 protocol, DCUtR protocol and AutoNAT protocol. These features were all included together in rust-libp2p [v0.43.0](https://github.com/libp2p/rust-libp2p/releases/tag/v0.43.0) released in February.

### New Transports

Over the year we worked on two new transports: WebRTC (browser-to-server) and QUIC, which we both released towards the end of the year as alpha/experimental features.

Our implementation of WebRTC enables browsers to connect to rust-libp2p based servers without those servers needing to have signed TLS certificates. QUIC is a better libp2p transport than the combination of TCP+Noise+Yamux in almost every dimension.

### User Experience Improvements

We tackled many smaller improvements including naming consistency across crates, refactoring of event handlers, deprecation of event-based `PollParameters`, rework of Rust feature flags, and removal of listener streams in favor of polling transports directly.

### DoS Protection

rust-libp2p saw a lot of DoS protection improvements in 2022. We enforce various limits and prioritize local work over new incoming work from a remote across the many layers.

### Metrics and Observability

We introduced a metric crate for rust-libp2p exposing Prometheus metrics, e.g. the time to establish a connection or the protocols supported by peers.

## Meta - Improvements to the Project

The core rust-libp2p maintainer team grew from two engineers to four. Beyond the core maintainers, a total of 36 people contributed to rust-libp2p's `master` branch in 2022.

### Automation

We invested heavily into rust-libp2p's automation including mergify, `cargo-semver-checks`, conventional commits, and refactored CI job structure.

### Interoperability

As of September 2022, we continuously test that the various versions of go-libp2p and rust-libp2p can connect.

In 2022 we published 9 releases of the main `libp2p` crate and a total of 268 releases across the workspace.

## What's Next?

Check out the rust-libp2p [project roadmap](https://github.com/libp2p/rust-libp2p/blob/master/ROADMAP.md) for planned developments including improved WASM support, WebRTC browser-to-browser, and WebTransport.
