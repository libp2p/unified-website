+++
title = "Announcing the release of nim-libp2p v1.15.2"
description = "An overview of changes and updates in the v1.15.2 release"
date = 2026-02-02
slug = "2026-02-02-nim-libp2p"

[taxonomies]
tags = ["nim-libp2p"]

[extra]
author = "Richard Ramos"
header_image = "/img/blog/js-libp2p-v1-header.png"
version = "v1.15.2"
implementation = "nim"
breaking = false
security = false
github_release = "https://github.com/vacp2p/nim-libp2p/releases/tag/v1.15.2"
+++
`nim-libp2p v1.15.2` has just shipped.

## Hotfix

- fix(gossipsub): race condition issue causing nil pointer exception when sendConn is not set by [@chaitanyaprem](https://github.com/chaitanyaprem) in [#2049](https://github.com/vacp2p/nim-libp2p/pull/2049)

## Contributors

- [@chaitanyaprem](https://github.com/chaitanyaprem)

**Full Changelog:** [v1.15.1...v1.15.2](https://github.com/vacp2p/nim-libp2p/compare/v1.15.1...v1.15.2)
