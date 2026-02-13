+++
title = "Announcing the release of litep2p v0.11.0"
description = "Release v0.11.0 of litep2p"
date = 2025-10-20
slug = "2025-10-20-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "dmitry-markin"
version = "v0.11.0"
implementation = "litep2p"
breaking = true
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.11.0"
+++
## [0.11.0] - 2025-10-20

This release adds support for RSA remote network identity keys gated behind `rsa` feature. It also fixes mDNS initialization in the environment with no multicast addresses available and Bitswap compatibility with kubo IPFS client &amp;gt;= v0.37.0.

## Added

- Support RSA remote network identity keys ([#423](https://github.com/paritytech/litep2p/pull/423))

## Fixed

- bitswap: Reuse inbound substream for subsequent requests ([#447](https://github.com/paritytech/litep2p/pull/447))
- mDNS: Do not fail initialization if the socket could not be created ([#434](https://github.com/paritytech/litep2p/pull/434))
- Make RemotePublicKey public to enable signature verification ([#435](https://github.com/paritytech/litep2p/pull/435))
- improve error handling in webRTC-related noise function ([#377](https://github.com/paritytech/litep2p/pull/377))

## Changed

- Upgrade rcgen 0.10.0 -&amp;gt; 0.14.5 ([#450](https://github.com/paritytech/litep2p/pull/450))
- chore: update str0m dependency, update code based on breaking changes ([#422](https://github.com/paritytech/litep2p/pull/422))
