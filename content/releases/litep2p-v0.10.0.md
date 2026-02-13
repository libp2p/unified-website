+++
title = "Announcing the release of litep2p v0.10.0"
description = "Release v0.10.0 of litep2p"
date = 2025-07-22
slug = "2025-07-22-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "dmitry-markin"
version = "v0.10.0"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.10.0"
+++
## [0.10.0] - 2025-07-22

This release adds the ability to use system DNS resolver and change Kademlia DNS memory store capacity. It also fixes the Bitswap protocol implementation and correctly handles the dropped notification substreams by unregistering them from the protocol list.

## Added

- kad: Expose memory store configuration ([#407](https://github.com/paritytech/litep2p/pull/407))
- transport: Allow changing DNS resolver config ([#384](https://github.com/paritytech/litep2p/pull/384))

## Fixed

- notification: Unregister dropped protocols ([#391](https://github.com/paritytech/litep2p/pull/391))
- bitswap: Fix protocol implementation ([#402](https://github.com/paritytech/litep2p/pull/402))
- transport-manager: stricter supported multiaddress check ([#403](https://github.com/paritytech/litep2p/pull/403))
