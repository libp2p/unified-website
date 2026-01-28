+++
title = "WebTransport in libp2p"
description = "Learn about WebTransport support in libp2p for browser connectivity"
date = 2022-12-19
slug = "2022-12-19-libp2p-webtransport"

[taxonomies]
tags = ["browser", "transport"]

[extra]
author = "Marten Seemann"
header_image = "/img/blog/libp2p_WebTransport_Blog_Header.png"
+++
This is the first entry in a series of posts on how libp2p achieves browser connectivity.

## Overview

Seamless browser connectivity is a crucial goal of the [libp2p project](/). Over many years, libp2p has made many strides to realize that vision. Today, we are proud to announce a significant milestone that puts us much closer to that aim:

**libp2p now supports the new, bleeding-edge WebTransport protocol!**

In this article, we:

* Introduce WebTransport
* Show what it means for apps and how you can use it today
* Explain its advantages over existing solutions
* Give you a deep dive into how it works
* Describe the current state of WebTransport (specs and implementations)

## What is WebTransport?

At a high level, [WebTransport](https://www.w3.org/TR/webtransport/) is a new [transport protocol](https://osi-model.com/transport-layer/) and [Web API](https://developer.mozilla.org/en-US/docs/Web/API) currently under development by both the [Internet Engineering Task Force (IETF)](https://www.ietf.org/) and the [World Wide Web Consortium (W3C)](https://www.w3.org/).

WebTransport is developing to meet [these goals](https://github.com/w3c/webtransport/blob/main/explainer.md#goals):

- Enable low latency communication between browsers and servers (efficiently transfer data and decrease travel time from browser to server).
- Have an API that supports different protocols and use cases (e.g., reliable/unreliable and ordered/unordered data transmission, client-server and peer-to-peer architectures, transmitting audio/video media as well as generic data).
- Have the same security properties as current solutions (e.g., WebSocket over TLS.)

With these goals in mind, WebTransport seeks to address a multitude of use cases, including browser gaming, live streaming, multimedia applications, and more.

## WebSocket: The old solution and its challenges

Before we delve deeper, let's reflect on the history of browser connectivity in libp2p. How did libp2p browser nodes connect to server nodes before the advent of WebTransport, and what challenges existed when bridging browsers to the libp2p ecosystem?

Browsers dial [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) connections (for HTTP 1.1 and HTTP/2) and [QUIC](https://www.rfc-editor.org/rfc/rfc9000.html) connections (for HTTP/3) all the time. However, there's no way to *just* dial a TCP or QUIC connection and use it for things other than HTTP.

This posed a problem when integrating browser applications with libp2p. libp2p is built on top of a bidirectional, asynchronous stream abstraction, whereas HTTP is a stateless, unidirectional, synchronous request-response protocol.

Therefore, for the longest time, the only way to connect a libp2p client running in the browser to the rest of the network was using the somewhat dated [WebSocket protocol](https://www.rfc-editor.org/rfc/rfc6455).

WebSocket has multiple drawbacks:

- **Slow time to connect**: It takes six network roundtrips until the libp2p connection is finally established because of the steps involved in establishing a WebSocket connection.
- **Inefficiency**: We're double-encrypting the data: The first time, it's encrypted on the outer (HTTPS) connection, and then again by the libp2p security protocol.
- **Increased latency**: There's no native stream multiplexing in WebSocket, and each internal stream can suffer from head-of-line blocking.

In practice, a different obstacle prevented WebSocket from achieving widespread deployment in libp2p. When a browser connects to a website, in practically all cases, it does so via HTTPS. This means that the server needs a valid TLS certificate signed by a Certificate Authority like Let's Encrypt.

However, most libp2p nodes don't have such a certificate. This is because libp2p nodes constitute a decentralized peer-to-peer network where participants can run nodes on home laptops or browsers and join or leave the network at will. Most nodes don't even possess a domain name.

## Meet WebTransport

Thankfully, WebTransport addresses almost all of the pain points when using WebSocket!

Conceptually, WebTransport is similar to WebSocket, although it's a new protocol on the wire. The browser can "upgrade" an HTTP/2 or an HTTP/3 connection to a **WebTransport session**. HTTP/3 runs on top of QUIC. A WebTransport session over HTTP/3 allows both endpoints to open (very thinly wrapped) QUIC streams to each other. This enables WebTransport to take advantage of QUIC's offerings:

- Speedy time to connect using a fast handshake (just one network roundtrip)
- Native stream multiplexing without head-of-line blocking
- Advanced loss recovery and congestion control
- Low latency communication and unordered and unreliable delivery of data

### Certificate Hash Verification

The most critical change for our peer-to-peer use case is the new verification option. The WebTransport browser API allows for two distinct modes:

1. **Verification of the TLS certificate chain**: This is precisely what the browser does when checking the certificate for any website it connects to.
2. **Verification of the TLS certificate hash**: The browser will trust the server if the hash of the certificate used during the handshake matches its expected hash.

Option (2) allows us to use WebTransport on *any* libp2p node without manual configuration!

It works because when setting up a WebTransport server, the libp2p node will generate a self-signed TLS certificate and calculate the certificate hash. It then advertises the following [multiaddress](/guides/addressing/) to the network:

`/ip4/1.2.3.4/udp/4001/quic/webtransport/certhash/<hash>`

The `certhash` component of the multiaddress tells the browser the certificate hash, allowing it to establish the WebTransport connection successfully.

### Deep dive: How WebTransport works

1. The browser dials a regular HTTP/3 connection to the server, verifying the certificate either by its chain of trust or by the certificate's hash.
2. The browser sends an `Extended CONNECT` request on an HTTP/3 stream, requesting establishing a WebTransport session. If the server sends a `200` HTTP status, the WebTransport session is successfully established.

![WebTransport Diagram](/img/blog/WebTransport-blog-post-diagram-1.png)

Both sides can now open streams (both bidirectional and unidirectional) and send (unreliable) HTTP datagrams.

In libp2p, we still need to verify the libp2p peer IDs, so we're not entirely done yet. The browser opens a new WebTransport stream and starts a [Noise](https://noiseprotocol.org/noise.html) handshake. This is the same handshake we use to secure connections on top of TCP in libp2p.

Therefore, setting up a WebTransport connection in libp2p takes no more than **three network roundtrips**. Compare that to the six roundtrips we needed for WebSocket!

### Limitations

WebTransport does not support browser-to-browser connectivity. To meet this need, libp2p implementations are adding support for WebRTC browser-to-server connectivity and browser-to-browser connectivity.

## What's the current state of WebTransport, and where is it supported?

### State of Specifications

The IETF specification of the protocol itself is still in the draft stage with ongoing revisions. The libp2p specification is here: [libp2p WebTransport spec](https://github.com/libp2p/specs/tree/master/webtransport).

### State in Browsers

Currently, WebTransport support is limited to Chromium browsers. See the [Can I Use? page for more details](https://caniuse.com/webtransport).

### State in libp2p implementations

WebTransport is supported in two libp2p implementations as an experimental feature:

- go-libp2p as of v0.23.0
- js-libp2p through the js-libp2p-webtransport npm package

{% youtube(id="Dt42Ss6X_Vk") %}
WebTransport demo from libp2p Day
{% end %}

## Can I use this right now?

Yes, please! WebTransport already works between browsers and servers in applications powered by go-libp2p and js-libp2p.

### What use cases does this unlock?

- Enable browser nodes (or light clients) as "full" peers in a decentralized network
- Enable browser extension crypto wallets to submit transactions directly to the blockchain
- Get data from the DHT by directly connecting to a DHT server node
- Upload to Filecoin directly from the browser
- Enable decentralized peer-to-peer video streaming as a dapp

## Resources and How you can help contribute

- [Documentation on WebTransport](/guides/webtransport/)
- [Connectivity site section on the protocol](/guides/browser-connectivity#webtransport)
- [Specification on WebTransport](https://github.com/libp2p/specs/tree/master/webtransport)

If you would like to contribute, please [connect with the libp2p maintainers](/get-involved/).

Thank you for reading!
