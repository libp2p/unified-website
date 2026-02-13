+++
title = "Announcing the release of litep2p v0.9.5"
description = "Release v0.9.5 of litep2p"
date = 2025-06-10
slug = "2025-06-10-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "lexnv"
version = "v0.9.5"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.9.5"
+++
## [0.9.5] - 2025-05-26

This release primarily focuses on strengthening the stability of the websocket transport. We've resolved an issue where higher-level buffering was causing the Noise protocol to fail when decoding messages.


We've also significantly improved connectivity between litep2p and Smoldot (the Substrate-based light client). Empty frames are now handled correctly, preventing handshake timeouts and ensuring smoother communication.


Finally, we've carried out several dependency updates to keep the library current with the latest versions of its underlying components.

## Fixed

- substream/fix: Allow empty payloads with 0-length frame  ([#395](https://github.com/paritytech/litep2p/pull/395))
- websocket: Fix connection stability on decrypt messages  ([#393](https://github.com/paritytech/litep2p/pull/393))

## Changed

- crypto/noise: Show peerIDs that fail to decode  ([#392](https://github.com/paritytech/litep2p/pull/392))
- cargo: Bump yamux to 0.13.5 and tokio to 1.45.0  ([#396](https://github.com/paritytech/litep2p/pull/396))
- ci: Enforce and apply clippy rules  ([#388](https://github.com/paritytech/litep2p/pull/388))
- build(deps): bump ring from 0.16.20 to 0.17.14  ([#389](https://github.com/paritytech/litep2p/pull/389))
- Update hickory-resolver 0.24.2 -&amp;gt; 0.25.2  ([#386](https://github.com/paritytech/litep2p/pull/386))
