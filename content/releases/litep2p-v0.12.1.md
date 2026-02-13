+++
title = "Announcing the release of litep2p v0.12.1"
description = "Release v0.12.1 of litep2p"
date = 2025-11-21
slug = "2025-11-21-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "dmitry-markin"
version = "v0.12.1"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.12.1"
+++
## [0.12.1] - 2025-11-21

This release adds support for connecting to multiple Kademlia DHT networks. The change is backward-compatible, no client code modifications should be needed compared to v0.12.0.

## Changed

- kad: Allow connecting to more than one DHT network ([#473](https://github.com/paritytech/litep2p/pull/473))
- service: Log services that have closed ([#474](https://github.com/paritytech/litep2p/pull/474))

## Fixed

- update simple-dns ([#470](https://github.com/paritytech/litep2p/pull/470))
