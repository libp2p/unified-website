+++
title = "WebRTC (Browser-to-Server) in libp2p"
description = "Learn about WebRTC browser-to-server connectivity in libp2p"
date = 2023-02-06
slug = "libp2p-webrtc-browser-to-server"
aliases = ["/libp2p-webrtc-browser-to-server"]

[taxonomies]
tags = ["browser", "transport", "webrtc"]

[extra]
author = "David DiMaria"
header_image = "/img/blog/libp2p_WebRTC_blog_header.png"
+++
This is the second entry in the Universal Browser Connectivity series on how libp2p achieves browser connectivity. Read about WebTransport in the [first post](/blog/2022-12-19-libp2p-webtransport).

## Overview

The [libp2p project](/) supports many transport protocols across a variety of implementations. These transport protocols enable applications using libp2p to run as server nodes (on a personal laptop or in a datacenter) or as browser nodes (inside a Web browser).

Historically, libp2p has bridged these runtime environments with different node connectivity options in varying degrees:
- server node to server node via TCP and QUIC
- browser node to public server node via WebSockets and, more recently, [WebTransport](/blog/2022-12-19-libp2p-webtransport)
- browser node to browser node (via less than ideal solutions)

Today our focus is on advancements in the **browser to public server** use case...

We're excited to present a new paradigm for browser-to-server connectivity and announce, **native support for WebRTC now exists in libp2p across three implementations!**

### Acknowledgements

We would like to recognize and express our gratitude to [Little Bear Labs](https://littlebearlabs.io/) and [Parity Technologies](https://www.parity.io/) for their contributions to the development of the [WebRTC specification](https://github.com/libp2p/specs/tree/master/webrtc) and implementation in libp2p.

## WebRTC in the browser

WebRTC, or Web Real-Time Communication, is a set of standards that enables peer-to-peer connections between browsers, clients, and servers and the exchange of audio, video, and data in real-time. It is built directly into modern browsers and is straightforward to use via its API.

While WebRTC handles audio, video, and data traffic, we're just going to focus on the data aspect because that's the API leveraged in libp2p WebRTC.

In most cases, peers directly connect to other peers, improving privacy and requiring fewer hops than on a relay. Peers connect via an [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection) interface. Once connected, [RTCDataChannels](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel) can be added to the connection to send and receive binary data.

## WebRTC in libp2p

![WebRTC Browser to Server Diagram](/img/blog/webrtc_browser_to_server_diagram.png)

Connecting from a browser to a public server in the WebRTC implementation in libp2p has some similarities but differs in several ways. Many of the features supported in the WebRTC standard, such as video, audio, and centralized STUN and Turn servers, are not needed in libp2p. The primary WebRTC component that libp2p leverages is the RTCDataChannels.

### Server Setup

To prepare for a connection from the browser, the server:

1. Generates a self-signed TLS certificate.
2. Listens on a UDP port for incoming STUN packets.

### Browser Connection

To initiate a connection, the browser:

1. Assembles the multiaddress of the server, which is either known upfront or discovered.
2. Creates an RTCPeerConnection.
3. Generates the server's Answer SDP using the components in the multiaddress.
4. Modifies the SDP, or "munges" it, to include an auto-generated ufrag and password, as well as the server's IP and port.
5. Creates an Offer SDP and modifies it with the same values.
6. Sets the Offer and Answer SDP on the browser, which triggers the sending of STUN packets to the server.

### Server Response

The server responds by creating the browser's Offer SDP using the values in the STUN Binding Request.

### DTLS Handshake

The browser and server then engage in a DTLS handshake to open a DTLS connection that WebRTC can run SCTP on top of. A [Noise handshake](https://github.com/libp2p/specs/blob/master/noise/README.md) is initiated by the server using the fingerprints in the SDP as input to the prologue data, and completed by the browser over the Data Channel.

Once the DTLS and Noise handshakes are complete, DTLS-encrypted SCTP data is ready to be exchanged over the UDP socket.

{% alert(type="tip") %}
Unlike standard WebRTC, signaling is completely removed in libp2p browser-to-server communication, and Signal Channels are not needed. Removing signaling results in fewer roundtrips to establish a Data Channel and reduces complexity.
{% end %}

### Multiaddress

The multiaddress of a WebRTC address begins like a standard UDP address, but adds three additional protocols: `webrtc`, `hash`, and `p2p`.

```
/ip4/1.2.3.4/udp/1234/webrtc/certhash/<hash>/p2p/<peer-id>
```

- `webrtc`: the name of this transport
- `hash`: the multihash of the certificate used in the DTLS handshake
- `p2p`: the peer-id of the libp2p node (optional)

### Benefits

#### Self-signed Certificate

WebRTC enables browsers to connect to public libp2p nodes without the nodes requiring a TLS certificate in the browser's certificate chain. WebRTC allows the server to use a self-signed TLS certificate, eliminating the need for additional services like DNS and Let's Encrypt.

#### Broad support

WebRTC has been supported in Chrome since 2012, and support has since been added to all evergreen browsers. This makes WebRTC widely available and easy to implement in libp2p.

### Limitations

#### Setup and configuration

WebRTC is a complex set of technologies that requires extensive server setup and configuration. While libraries like Pion and webrtc-rs abstract away this functionality, the additional complexity introduced and the configuration fine-tuning required can be a drawback for some users.

#### Extensive Roundtrips

Another limitation is the 6 roundtrips required before data is exchanged. This may make other transports, such as WebTransport, more appealing where the browser supports it.

### Usage

The complexity of WebRTC is abstracted in the libp2p implementations, making it easy to swap in WebRTC as the transport. In the JavaScript implementation, for example, all you need to do is initialize with:

```javascript
import { webRTC } from 'js-libp2p-webrtc'

const node = await createLibp2p({
  transports: [webRTC()],
  connectionEncryption: [() => new Noise()],
});
```

## Alternative transports

WebRTC is just one option for connecting browsers to libp2p nodes. libp2p supports a variety of transports, and choosing the right one for your use case is an important consideration. The [libp2p connectivity guide](/docs/browser-connectivity) was designed to help developers consider the available options.

### WebSocket

The WebSocket protocol allows for the opening of a two-way socket between a browser and a server over TCP. One limitation of WebSocket is the number of roundtrips required to establish a connection—up to six roundtrips. Additionally, WebSocket requires the server to have a trusted TLS certificate using TCP, unlike WebRTC which can use a self-signed certificate.

### WebTransport

[WebTransport](/blog/2022-12-19-libp2p-webtransport) is the new kid on the block for communication in the browser. WebTransport has many of the same benefits as WebRTC, such as fast, secure, and multiplexed connections, without requiring servers to implement the stack. Additionally, WebTransport requires fewer roundtrips to establish a connection than WebRTC, making it the preferred choice when supported.

Currently, it is only implemented in Chrome and is still under development. Until WebTransport is supported by all major browsers, WebRTC can serve as a good fallback option.

## Can I use WebRTC now?

Yes, you can use libp2p-webrtc in the [Rust](https://github.com/libp2p/rust-libp2p/tree/master/transports/webrtc) and [JavaScript](https://github.com/libp2p/js-libp2p-webrtc) implementations! The [Go](https://github.com/libp2p/go-libp2p) implementation is also available.

For how to use WebRTC browser-to-server, you can take a look at the [examples in the js-libp2p-webrtc repo](https://github.com/libp2p/js-libp2p-webrtc/tree/main/examples/browser-to-server).

## What's next?

WebRTC offers the capability for browsers to connect to browsers. The [WebRTC browser-to-browser connectivity spec](https://github.com/libp2p/specs/pull/497) has been authored and development is underway.

## Resources and how you can help contribute

- [WebRTC Docs](/docs/webrtc-browser-connectivity/)
- [WebRTC Connectivity](/docs/browser-connectivity#webrtc)
- [WebRTC Spec](https://github.com/libp2p/specs/tree/master/webrtc)

If you would like to contribute, please [connect with the libp2p maintainers](/get-involved/).

Thank you for reading!
