+++
title = "Announcing the release of js-libp2p v1.0.0"
description = "Recap of the major improvements and features in js-libp2p over the last year."
date = 2023-12-12
slug = "2023-12-12-js-libp2p"

[taxonomies]
tags = ["browser", "transport", "webrtc", "js-libp2p"]

[extra]
author = "Chad Nehemiah"
header_image = "/img/blog/js-libp2p-v1-header.png"
version = "v1.0.0"
implementation = "js"
breaking = false
security = false
github_release = "https://github.com/libp2p/js-libp2p/releases/tag/libp2p-v1.0.0"
+++
js-libp2p has been used in production for many years in IPFS and Ethereum, as well as a wide variety of other ecosystems. Today, we're excited to announce the release of [js-libp2p v1.0.0](https://github.com/libp2p/js-libp2p/releases/tag/libp2p-v1.0.0)!

## What's new?

### Smart Dialing

One of the major inefficiencies we recognized was how we dialed peers, particularly in the browser. Smart dialing is a dialing strategy that is more aware of the network topology and the reachability of the multiaddrs it is dialing. This has led to a significant reduction in the number of dials made and failed dials.

### Circuit Relay v2

Circuit relay was introduced as a means to establish connectivity between libp2p nodes that wouldn't otherwise be able to establish a direct connection. Circuit Relay v2 has significant improvements over v1, including support for resource reservation and limitations on durations and data caps.

### NAT Hole punching with DCUtR

The libp2p DCUtR (Direct Connection Upgrade through Relay) is a protocol for establishing direct connections between nodes through hole punching, without a signaling server. Implementing this in js-libp2p has benefitted browser nodes significantly.

### WebRTC Private-to-Private Connectivity

Currently js-libp2p is the only implementation that supports private-to-private browser connectivity using WebRTC. This allows direct peer-to-peer connectivity within the browser regardless of whether nodes are located behind NATs/Firewalls.

### WebTransport

WebTransport is a new web standard built on top of QUIC that allows establishing WebTransport connections to servers that only have self-signed certificates.

## Performance Improvements

### Reducing latency

We've made an 80%+ improvement in the time it takes to establish a connection between two js-libp2p nodes.

![Latency Improvements](/img/blog/js-libp2p-v1-latency-improvements.png)

### Increasing throughput

Currently js-libp2p has the highest throughput of any of the libp2p implementations, averaging 2.06GB/s on both uploads and downloads!

![Throughput Improvements](/img/blog/js-libp2p-v1-throughput-improvements.png)

### Reducing Dependencies

We reduced the bundle size by over 40% by removing modules that are tangential for many use cases.

## Developer Experience Improvements

### Monorepo Setup

The js-libp2p ecosystem once consisted of over 81 repositories! We consolidated all of the repositories into a single monorepo.

### Modernization of Tooling

We've completely re-written our codebase in TypeScript and standardized our modules through ESM.

### Documentation Improvements

We've introduced tools to automate and validate our docs, including a JS-docs based documentation generator and architectural diagrams.

## What's next?

- React Native Support
- QUIC support
- Improved documentation
- Improved observability and metrics

## Resources and how you can contribute

* [js-libp2p Discussions](https://github.com/libp2p/js-libp2p/discussions)
* [Slack - the libp2p-implementers channel](https://filecoinproject.slack.com/archives/C03K82MU486)
* [libp2p Specifications](https://github.com/libp2p/specs/)

Thank you for reading!
