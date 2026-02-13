+++
title = "Announcing the release of litep2p v0.12.2"
description = "Release v0.12.2 of litep2p"
date = 2025-11-28
slug = "2025-11-28-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "lexnv"
version = "v0.12.2"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.12.2"
+++
## [0.12.2] - 2025-11-28

This release allows all Bitswap CIDs (v1) to pass regardless of the used hash. It also enhances local address checks in the transport manager.

## Changed

- transport-service: Enhance logging with protocol names  ([#485](https://github.com/paritytech/litep2p/pull/485))
- bitswap: Reexports for CID  ([#486](https://github.com/paritytech/litep2p/pull/486))
- Allow all the Bitswap CIDs (v1) to pass regardless of used hash  ([#482](https://github.com/paritytech/litep2p/pull/482))
- transport/manager: Enhance local address checks  ([#480](https://github.com/paritytech/litep2p/pull/480))
