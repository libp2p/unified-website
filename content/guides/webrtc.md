+++
title = "WebRTC"
description = "WebRTC is a specification and API that enables browsers to build real-time, peer-to-peer applications. Learn how to use WebRTC in libp2p."
weight = 23
aliases = ["/concepts/transports/webrtc"]

[extra]
toc = true
category = "transports"
+++

## What is WebRTC?

WebRTC is a general-purpose framework that enables real-time communication capabilities in browsers and mobile applications. WebRTC is unique because it allows browsers to directly connect without the need for intermediate servers, enabling audio, video, and generic data to be exchanged between endpoints.

{% alert(type="info") %}
WebRTC in libp2p is implemented, available and documented in [js-libp2p](https://github.com/libp2p/js-libp2p/tree/master/packages/transport-webrtc) and [go-libp2p](https://github.com/libp2p/go-libp2p/tree/master/p2p/transport/webrtc).
{% end %}

libp2p uses WebRTC to enable browsers to connect directly to other public nodes in the network. There are two different transports specified for WebRTC: [WebRTC transport](https://github.com/libp2p/specs/tree/master/webrtc#browser-to-public-server) and [WebRTC direct](https://github.com/libp2p/specs/blob/master/webrtc/webrtc-direct.md#browser-to-server).

### The WebRTC handshake

Unlike other transport protocols like [QUIC](/guides/quic/) and TCP, browsers are not able to establish
direct connections (e.g. by opening a TCP or QUIC connection) to server nodes. Instead,
they rely on the WebRTC standard for p2p connections. The WebRTC standard involves
a complex handshake mechanism to establish a connection:

1. SDP (Session Description Protocol) offers and answers that describe the media and data
   channels to be established.
2. ICE (Interactive Connectivity Establishment) candidates that are used to establish
   the connection.
3. DTLS (Datagram Transport Layer Security) handshake to establish a secure connection.
4. SCTP (Stream Control Transmission Protocol) handshake to establish a data channel.

At a simplified level, there are a few ways a WebRTC connection is established.
At an abstract level, WebRTC connections work by generating local "SDP" messages (also known
as "offers" and "answers") and exchanging them via some out-of-band channel. Once both parties
have each other's SDP, they attempt to establish a direct connection. libp2p uses two methods
to accomplish this: **signaling** via a relay or **encoding the SDP** directly into the dialer and
listener multiaddrs.

In the case of browser-to-server (also known as WebRTC Direct), the server publishes its IP address and a hash
of its certificate in its advertised multiaddr, so the browser node connects to the server,
performs STUN binding request, and then completes the rest of the DTLS+SCTP handshake directly.

### WebRTC vs WebRTC Direct

Both WebRTC transports have the same capabilities, but they differ in how they establish a
connection between two parties.

**WebRTC Direct** uses a simplified signaling mechanism where the server's TLS certificate fingerprint
is encoded directly into the dialing multiaddr. This allows the browser and server to exchange SDPs
out-of-band by piggybacking on top of the libp2p handshake. WebRTC Direct is primarily used for browser-to-server connectivity.

**WebRTC**, aka WebRTC private-to-private, uses a relay node for signaling to exchange SDPs. This
is primarily used for browser-to-browser connectivity.

## WebRTC in libp2p

Because browsers do not allow access to raw UDP or TCP sockets, WebRTC is one of only a few ways
browsers can connect to other nodes.

### Browser-to-server

For browser-to-server connections, libp2p uses [WebRTC Direct](https://github.com/libp2p/specs/blob/master/webrtc/webrtc-direct.md).
This requires the server to generate and send their TLS certificate (specifically the certificate's hash fingerprint) in their multiaddr.
When a browser dials a peer that advertises a WebRTC Direct multiaddr, they connect and exchange SDPs and ICE candidates directly.

A WebRTC Direct multiaddr looks as follows: `/ip4/192.0.2.0/udp/12345/webrtc-direct/certhash/<hash>/p2p/<peer-id>`

In the above example, `/ip4/192.0.2.0/udp/12345` tells the browser where to send the ICE candidate to. `webrtc-direct` is the protocol that is used to establish the connection. `/certhash/<hash>` is the hash of the server's certificate that will be used during the DTLS handshake. `/p2p/<peer-id>` is the peer ID of the server.

### Browser-to-browser

Because browser-to-browser communication requires an intermediary relay to complete, the multiaddr for WebRTC uses a more complex format
that includes both the relay node and the destination node: `/ip4/192.0.2.0/udp/54321/quic-v1/p2p/<relay-peer-id>/p2p-circuit/webrtc/p2p/<destination-peer-id>`.

`/ip4/192.0.2.0/udp/54321/quic-v1/p2p/<relay-peer-id>` is the address of the relay node. `/p2p-circuit` is the protocol that is used to establish a circuit relay connection. `webrtc` is the protocol
upgrade for the final WebRTC connection. `/p2p/<destination-peer-id>` is the peer ID of the destination browser node.

Once the connection is established, users can open and use streams.

### Further resources

The libp2p WebRTC specifications exist here:

- [WebRTC](https://github.com/libp2p/specs/blob/master/webrtc/webrtc.md)
- [WebRTC Direct](https://github.com/libp2p/specs/blob/master/webrtc/webrtc-direct.md)

{% alert(type="note") %}
See the WebRTC [technical specification](https://github.com/libp2p/specs/tree/master/webrtc) for more details.
{% end %}
