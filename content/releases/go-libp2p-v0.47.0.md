+++
title = "Announcing the release of go-libp2p v0.47"
description = "An overview of changes and updates in the v0.47 release"
date = 2026-01-25
slug = "2026-01-25-go-libp2p"

[taxonomies]
tags = ["go-libp2p"]

[extra]
author = "Marco Munizaga"
header_image = "/img/blog/js-libp2p-v1-header.png"
version = "v0.47"
implementation = "go"
breaking = false
security = false
github_release = "https://github.com/libp2p/go-libp2p/releases/tag/v0.47.0"
+++
`go-libp2p v0.47` has just shipped.

A relatively small release. The main changes are dependency updates and a
couple of bug fixes. [#3435](https://github.com/libp2p/go-libp2p/pull/3435)
changes autonatv2 reachability logic, which should be a net win for most users.

## What's Changed

- fix(autonatv2): secondary addrs inherit reachability from primary by [@lidel](https://github.com/lidel) in [#3435](https://github.com/libp2p/go-libp2p/pull/3435)
- Update simnet by [@MarcoPolo](https://github.com/MarcoPolo) in [#3449](https://github.com/libp2p/go-libp2p/pull/3449)
- mod tidy test-plans package by @MarcoPolo in #3450
- fix(basic_host): stream.Close() blocks indefinitely on unresponsive peers by [@lidel](https://github.com/lidel) in [#3448](https://github.com/libp2p/go-libp2p/pull/3448)
- fix: handle error from mh.Sum in IDFromPublicKey by [@MozirDmitriy](https://github.com/MozirDmitriy) in [#3437](https://github.com/libp2p/go-libp2p/pull/3437)
- update webtransport-go to v0.10.0 and quic-go to v0.59.0 by [@marten-seemann](https://github.com/marten-seemann) in [#3452](https://github.com/libp2p/go-libp2p/pull/3452)
- rcmgr: expose resource limits to Prometheus by [@sneaxhuh](https://github.com/sneaxhuh) in [#3433](https://github.com/libp2p/go-libp2p/pull/3433)

## New Contributors

- [@MozirDmitriy](https://github.com/MozirDmitriy) made their first contribution in [#3437](https://github.com/libp2p/go-libp2p/pull/3437)
- [@sneaxhuh](https://github.com/sneaxhuh) made their first contribution in [#3433](https://github.com/libp2p/go-libp2p/pull/3433)

**Full Changelog:** [v0.46.0...v0.47.0](https://github.com/libp2p/go-libp2p/compare/v0.46.0...v0.47.0)
