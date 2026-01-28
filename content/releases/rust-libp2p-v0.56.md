+++
title = "Announcing the release of rust-libp2p v0.56"
description = "An overview of changes and updates in the v0.56 release"
date = 2025-06-28
slug = "2025-06-28-rust-libp2p"

[taxonomies]
tags = ["rust-libp2p"]

[extra]
author = "Elena Frank"
header_image = "/img/blog/js-libp2p-v1-header.png"
version = "v0.56"
implementation = "rust"
breaking = false
security = false
github_release = "https://github.com/libp2p/rust-libp2p/releases/tag/libp2p-v0.56.0"
+++
`rust-libp2p v0.56` has just shipped.

See individual [changelogs](https://github.com/libp2p/rust-libp2p/blob/libp2p-v0.56.0/CHANGELOG.md) for details.

## What's new?

Notably, we've removed support for `async-std` in all crates, as `async-std`
[has been discontinued](https://github.com/async-rs/async-std/pull/1099). Users
should switch to using tokio instead. For now, we've kept the abstractions for
supporting alternative runtimes, although not all parts may be public. Please
open an issue if you are planning to support a custom runtime and run into any
issues with that..

Thanks to everyone who contributed to the release!
