+++
title = "Announcing the release of litep2p v0.13.1"
description = "Release v0.13.1 of litep2p"
date = 2026-02-27
slug = "2026-02-27-litep2p-0.13.1"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "dmitry-markin"
version = "v0.13.1"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.13.1"
+++
## [0.13.1] - 2026-02-27

This release includes multiple fixes of transports and protocols, fixing connection stability issues with other libraries (specifically, [smoldot](https://github.com/smol-dot/smoldot/)) and increasing success rates of dialing &amp;amp; opening substreams, especially in extreme cases when remote nodes have a lot of private addresses published to the DHT.

## Fixed

- ping: Conform to the spec &amp;amp; exclude from connection keep-alive ([#416](https://github.com/paritytech/litep2p/pull/416))
- transport: Make accept async to close the gap on service races ([#525](https://github.com/paritytech/litep2p/pull/525))
- transport: Limit dial concurrency and bound total dialing time ([#538](https://github.com/paritytech/litep2p/pull/538))
- webrtc: Support `FIN`/`FIN_ACK` handshake for substream shutdown ([#513](https://github.com/paritytech/litep2p/pull/513))
- transport: Expose failed addresses to the transport manager ([#529](https://github.com/paritytech/litep2p/pull/529))

## Changed

- manager: Prioritize public addresses for dialing ([#530](https://github.com/paritytech/litep2p/pull/530))
