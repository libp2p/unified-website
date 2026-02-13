+++
title = "Announcing the release of litep2p v0.9.4"
description = "Release v0.9.4 of litep2p"
date = 2025-05-15
slug = "2025-05-15-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "lexnv"
version = "v0.9.4"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.9.4"
+++
## [0.9.4] - 2025-04-29

This release brings several improvements and fixes to litep2p, advancing its stability and readiness for production use.

## Performance Improvements

This release addresses an issue where notification protocols failed to exit on handle drop, lowering CPU usage in scenarios like minimal-relay-chains from 7% to 0.1%.

## Robustness Improvements

- 

Kademlia:


- Optimized address store by sorting addresses based on dialing score, bounding memory consumption and improving efficiency.
- Limited `FIND_NODE` responses to the replication factor, reducing data stored in the routing table.
- Address store improvements enhance robustness against routing table alterations.


- 

Identify Codec:


- Enhanced message decoding to manage malformed or unexpected messages gracefully.


- 

Bitswap:


- Introduced a write timeout for sending frames, preventing protocol hangs or delays.



## Testing and Reliability

- 

Fuzzing Harness: Added a fuzzing harness by SRLabs to uncover and resolve potential issues, improving code robustness. Thanks to <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/R9295/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/R9295">@R9295</a> for the contribution!


- 

Testing Enhancements: Improved notification state machine testing. Thanks to Dominique (<a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/Imod7/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/Imod7">@Imod7</a>) for the contribution!



## Dependency Management

- 

Updated all dependencies for stable feature flags (default and "websocket") to their latest versions.


- 

Reorganized dependencies under specific feature flags, shrinking the default feature set and avoiding exposure of outdated dependencies from experimental features.



## Fixed

- notifications: Exit protocols on handle drop to save up CPU of `minimal-relay-chains`  ([#376](https://github.com/paritytech/litep2p/pull/376))
- identify: Improve identify message decoding  ([#379](https://github.com/paritytech/litep2p/pull/379))
- crypto/noise: Set timeout limits for the noise handshake  ([#373](https://github.com/paritytech/litep2p/pull/373))
- kad: Improve robustness of addresses from the routing table  ([#369](https://github.com/paritytech/litep2p/pull/369))
- kad: Bound kademlia messages to the replication factor  ([#371](https://github.com/paritytech/litep2p/pull/371))
- codec: Decode smaller payloads for identity to None  ([#362](https://github.com/paritytech/litep2p/pull/362))

## Added

- bitswap: Add write timeout for sending frames  ([#361](https://github.com/paritytech/litep2p/pull/361))
- notif/tests: check test state  ([#360](https://github.com/paritytech/litep2p/pull/360))
- SRLabs: Introduce simple fuzzing harness  ([#367](https://github.com/paritytech/litep2p/pull/367))
- SRLabs: Introduce Fuzzing Harness  ([#365](https://github.com/paritytech/litep2p/pull/365))

## Changed

- features: Move quic related dependencies under feature flag  ([#359](https://github.com/paritytech/litep2p/pull/359))
- tests/substrate: Remove outdated substrate specific conformace testing  ([#370](https://github.com/paritytech/litep2p/pull/370))
- ci: Update stable dependencies  ([#375](https://github.com/paritytech/litep2p/pull/375))
- build(deps): bump hex-literal from 0.4.1 to 1.0.0  ([#381](https://github.com/paritytech/litep2p/pull/381))
- build(deps): bump tokio from 1.44.1 to 1.44.2 in /fuzz/structure-aware  ([#378](https://github.com/paritytech/litep2p/pull/378))
- build(deps): bump Swatinem/rust-cache from 2.7.7 to 2.7.8  ([#363](https://github.com/paritytech/litep2p/pull/363))
- build(deps): bump tokio from 1.43.0 to 1.43.1  ([#368](https://github.com/paritytech/litep2p/pull/368))
- build(deps): bump openssl from 0.10.70 to 0.10.72  ([#366](https://github.com/paritytech/litep2p/pull/366))
