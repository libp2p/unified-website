+++
title = "go-libp2p in 2022"
description = "A look at the progress made on go-libp2p in 2022"
date = 2023-02-13
slug = "go-libp2p-2022"
aliases = ["/go-libp2p-2022"]

[taxonomies]
tags = ["libp2p", "update", "Go"]

[extra]
author = "Prithvi Shahi"
header_image = "/img/blog/go-2022.png"
+++
We are excited to share with you all the progress that has been made on [go-libp2p](https://github.com/libp2p/go-libp2p) in 2022. It has been a year full of exciting new features, code organization, and a growing team of talented contributors.

Throughout the year, we released seven updates to go-libp2p ranging from [v0.18.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.18.0) to [v0.24.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.24.0), with a number of patch releases in between. In total, we had [21 contributors](https://github.com/libp2p/go-libp2p/graphs/contributors?from=2022-01-01&to=2022-12-31&type=c) to the project in 2022.

## New Features

### Transport Protocols

#### WebTransport

One of the most exciting developments of the year was the release of the WebTransport protocol in [v0.23.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.23.0). WebTransport enables browser-to-server connectivity in go-libp2p when paired with a peer running js-libp2p-webtransport in the browser.

To learn more about this exciting feature, check out our blog post on [WebTransport in libp2p](/blog/2022-12-19-libp2p-webtransport) and the [WebTransport documentation](/docs/webtransport/).

#### WebRTC (Browser to Server)

In addition to WebTransport, the go-libp2p team also began work on enabling the WebRTC transport, in partnership with Little Bear Labs. This new transport allows for connectivity between go-libp2p server nodes and js-libp2p browser nodes.

#### QUIC Versions

We also made developments to the existing QUIC implementation in go-libp2p. In [v0.24.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.24.0), go-libp2p changed to properly distinguish between QUIC versions (in their multiaddresses) and changed the default dial behavior to prefer the new QUIC version.

### DoS Protection & Resource Management

We added the [Resource Manager component](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager#readme) in [v0.18.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.18.0). This feature allows developers to configure limits on connections, streams, and memory usage.

### Faster Handshakes

In [v0.24.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.24.0), go-libp2p added optimized muxer selection via TLS' ALPN extension and Noise extensions. This resulted in saving one round trip during connection establishment.

### AutoRelay discovers Circuit Relay v2

In [v0.19.0](https://github.com/libp2p/go-libp2p/releases/tag/v0.19.0), we enabled AutoRelay to discover nodes running Circuit Relay v2, improving the overall performance and reliability of the network.

## Project Improvements

### Interoperability Testing

We began a concerted effort to improve interoperability between go-libp2p and libp2p implementations in other languages. The details can be seen in the shared [unified-testing repo](https://github.com/libp2p/unified-testing).

### Monorepo Consolidation

**go-libp2p is a monorepo as of the [v0.22.0 release](https://github.com/libp2p/go-libp2p/releases/tag/v0.22.0).** This improvement makes changes and improvements across go-libp2p much easier.

## Plans for 2023

Key areas of focus:

- Interoperability and end-to-end testing
- Expanding seamless browser connectivity
- Adding support for libp2p + HTTP
- Optimizing performance
- Better observability with metrics

## Resources and how you can help contribute

We always welcome contributions from the community! Check out [any of these help wanted/good first issues](https://github.com/libp2p/go-libp2p/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) to start contributing.

Thank you for reading!
