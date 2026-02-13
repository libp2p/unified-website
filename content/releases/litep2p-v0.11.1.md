+++
title = "Announcing the release of litep2p v0.11.1"
description = "Release v0.11.1 of litep2p"
date = 2025-10-28
slug = "2025-10-28-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "lexnv"
version = "v0.11.1"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.11.1"
+++
## [0.11.1] - 2025-10-28

This release ensures that polling the yamux controller after an error does not lead to unexpected behavior.

## Fixed

- yamux/control: Ensure poll next inbound is not called after errors  ([#445](https://github.com/paritytech/litep2p/pull/445))
