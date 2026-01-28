+++
title = "HTTP-P2P, HTTP with more Ps"
description = "Introducing HTTP semantics in go-libp2p"
date = 2023-09-20
slug = "2023-09-20-http-p2p"

[taxonomies]
tags = ["http", "go"]

[extra]
author = "Marco Munizaga"
header_image = "/img/blog/libp2p_http.png"
+++
We're introducing a new experimental API in go-libp2p, enabling developers to utilize libp2p with the well-known semantics of HTTP. This isn't a special flavor of HTTP; it's standard HTTP, but enhanced with libp2p.

Developers can now benefit from HTTP intermediaries such as CDN caching and layer 7 load balancing. This allows developers to create HTTP applications that operate over NATs and tap into libp2p's diverse transport options.

### Use Cases

- Fetch content from peers over the IPFS Path Gateway protocol, regardless of whether they're a CDN, R2 bucket, random server, laptop, or browser
- HTTP Edge compute nodes can behave as peers in the libp2p network
- Simple HTTP clients like curl can participate in the libp2p network
- Browsers can make secure HTTP requests using WebTransport or WebRTC
- Operators can use layer 7 load balancing with projects like Envoy
- Port existing HTTP applications like Mastodon or Gitea to a p2p environment

## Technical details

This new API implements the libp2p+HTTP spec with three main features:

### A new HTTP Transport

A libp2p node can now listen on an HTTP transport and advertise its address as a multiaddr ending in `/tls/http` (or `/https`). The HTTP transport lives alongside other transports (tcp+tls+yamux, QUIC, WebRTC, etc.).

### HTTP Semantics

HTTP semantics are the abstract form of HTTP, defined by RFC 9110. We can use WebTransport, WebRTC, or a hole-punched QUIC connection to make an HTTP request, allowing developers to create applications using familiar HTTP tools in a p2p setting.

### .well-known/libp2p

This solves protocol discovery in a p2p setting. A node provides information about supported protocols at the `/.well-known/libp2p` resource. For example:

```json
{"/hello/1":{"path":"/hello-path/"}}
```

We're hoping to get early feedback as the API solidifies. Please try it out and let us know what you think in the [go-libp2p Discussions forum](https://github.com/libp2p/go-libp2p/discussions).
