+++
title = "Announcing the release of litep2p v0.13.0"
description = "Release v0.13.0 of litep2p"
date = 2026-01-21
slug = "2026-01-21-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "dmitry-markin"
version = "v0.13.0"
implementation = "litep2p"
breaking = true
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.13.0"
+++
## [0.13.0] - 2026-01-21

This release brings multiple fixes to both the transport and application-level protocols.


Specifically, it enhances WebSocket stability by resolving AsyncWrite errors and ensuring that partial writes during the negotiation phase no longer trigger connection failures.


At the same time, Bitswap client functionality is introduced, which makes this release semver breaking.

## Added

- Add Bitswap client ([#501](https://github.com/paritytech/litep2p/pull/501))

## Fixed

- notif/fix: Avoid CPU busy loops on litep2p full shutdown ([#521](https://github.com/paritytech/litep2p/pull/521))
- protocol: Ensure transport manager knows about closed connections ([#515](https://github.com/paritytech/litep2p/pull/515))
- substream: Decrement the bytes counter to avoid excessive flushing ([#511](https://github.com/paritytech/litep2p/pull/511))
- crypto/noise: Improve stability of websockets by fixing AsyncWrite implementation ([#518](https://github.com/paritytech/litep2p/pull/518))
- bitswap: Split block responses into batches under 2 MiB ([#516](https://github.com/paritytech/litep2p/pull/516))
- crypto/noise: Fix connection negotiation logic on partial writes ([#519](https://github.com/paritytech/litep2p/pull/519))
- substream/fix: Fix partial reads for ProtocolCodec::Identity ([#512](https://github.com/paritytech/litep2p/pull/512))
- webrtc: Avoid panics returning error instead ([#509](https://github.com/paritytech/litep2p/pull/509))
- bitswap: e2e test &amp;amp; max payload fix ([#508](https://github.com/paritytech/litep2p/pull/508))
- tcp: Exit connections when events fail to propagate to protocols ([#506](https://github.com/paritytech/litep2p/pull/506))
- webrtc: Avoid future being dropped when channel is full ([#483](https://github.com/paritytech/litep2p/pull/483))
