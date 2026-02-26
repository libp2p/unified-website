+++
title = "Standalone Node Connectivity"
description = "Learn about transport protocols for standalone libp2p nodes including TCP, QUIC, and hole punching for NAT traversal."
weight = 50
aliases = ["/concepts/standalone-node", "/concepts/fundamentals/standalone-node", "/guides/standalone-connectivity/"]

[extra]
toc = true
category = "fundamentals"
+++

Standalone nodes are libp2p nodes that run directly on a host machine, without being constrained by a browser environment. Examples are applications using go-libp2p, rust-libp2p, or js-libp2p (when using Node.js).

If a node is on a dedicated connection, or running in a data center, without a router/NAT/firewall in between, we call it a "public node". Public standalone nodes can use two types of transport protocols, TCP or QUIC, to connect to each other.

## TCP

The [Transmission Control Protocol (TCP)](https://datatracker.ietf.org/doc/html/rfc9293) is one of the foundations of the Internet protocol suite and was developed in the 1970s. TCP carried, up to the introduction of QUIC, the vast majority of traffic on the internet. It was also the first transport that was adopted in libp2p.

### TCP in libp2p

Establishing a libp2p connection on top of TCP takes a few steps, upgrading the underlying connection:

1. Dial a TCP connection to the remote node and perform the 3-way-handshake
2. Negotiate a security protocol ([Noise](https://noiseprotocol.org) or [TLS 1.3](https://datatracker.ietf.org/doc/rfc8446)), and then perform the chosen cryptographic handshake. The connection is now encrypted and the peers have verified each others' peer IDs.
3. Apply a stream multiplexer (yamux or mplex).

Setting up a libp2p connection takes quite a few network roundtrips, but is the most reliable option, as very few networks block TCP connections.

### Counting Round Trips

1. TCP Handshake (1 RTT)
2. Multistream Negotiation of the Security Protocol (1 RTT)
3. Security Handshake: TLS 1.3 or Noise (1 RTT)

Establishing and "upgrading" (applying encryption and a stream multiplexer) takes **4 round trips**.

And this is the most optimistic assumption. In case the peer doesn't support the protocol suggested in a Multistream Negotiation step, Multistream will incur additional round trips.

### TCP Implementation Status

{% support_matrix(data="go-libp2p:supported,rust-libp2p:supported,js-libp2p (Node.js):supported,Chrome:not-supported,Firefox:not-supported,Safari:not-supported") %}
TCP connections cannot be made from browsers due to security restrictions.
{% end %}

---

## QUIC

[QUIC](https://datatracker.ietf.org/doc/html/rfc9000) is a new UDP-based transport protocol. QUIC connections are always encrypted (using TLS 1.3) and provides native stream multiplexing.

Whenever possible, QUIC should be preferred over TCP. Not only is it faster, it also increases the chances of a successful holepunch in case of firewalls (see next section).

However: UDP is blocked in ~5-10% of networks, especially in corporate networks, so running a node exclusively with QUIC is usually not an option.

### QUIC in libp2p

Since QUIC provides encryption and stream multiplexing at the transport layer, no "upgrading" is required: As soon as the QUIC handshake finishes, we can use the QUIC connection as a libp2p connection.

To verify the remote's peer ID, it is [added to the TLS certificate](https://github.com/libp2p/specs/blob/master/tls/tls.md) (including a signature using the host's key) which is used during the handshake. Once the handshake is complete, both sides have cryptographically verified each other's identity.

### Counting Round Trips

1. QUIC handshake (1-RTT)

That's all there is. QUIC verifies the client's address (that's what TCP's 3-way handshake is there for) and performs the TLS 1.3 handshake in parallel. And since QUIC comes with transport-level stream multiplexing, we don't need to set up a separate stream multiplexer.

For resumed connections, QUIC even supports a **0-RTT handshake**, although we're currently not (yet) making use of that in libp2p.

### QUIC Implementation Status

{% support_matrix(data="go-libp2p:supported,rust-libp2p:supported,js-libp2p (Node.js):wip,Chrome:not-supported,Firefox:not-supported,Safari:not-supported") %}
Native QUIC support in Node.js is still pending. See the [tracking issue](https://github.com/nodejs/node/pull/44325).
{% end %}

---

## Hole Punching

TCP and QUIC transports are enough for establishing communication between public nodes; however, not all nodes are located in publicly reachable positions.

Nodes in home or corporate networks are private and usually separated from the public internet by a network address translation (NAT) mapping or a firewall. Mobile phones are also usually behind a so-called "carrier-grade NATs".

These private nodes behind firewalls/NATs can dial any node on the public internet, but they cannot receive incoming connections from outside their local network.

Therefore, we introduced a [novel decentralized hole punching mechanism](https://research.protocol.ai/publications/decentralized-hole-punching/) in libp2p to enable connectivity between public and private nodes.

### libp2p Relays

When a libp2p node boots up, one of the first things it does is to start [AutoNAT](https://github.com/libp2p/specs/tree/master/autonat) to determine its position in the network: is it a public node, reachable from the public internet, or is it a private node, located behind a firewall or a NAT?

- **Private nodes** will start looking for relay servers on the network, and obtain a reservation with (at least) one of them. This entails keeping a connection open to that relay. The relay will now forward traffic from other nodes.

- **Public nodes** will become a relay server, offering relay services to private nodes on the network. The relay service is designed such that it's very cheap to run (in terms of CPU, memory and bandwidth). This is achieved by limiting the number of reservations, the connection time for relayed connections as well as their bandwidth.

### Obtaining a Direct Connection

Obtaining a reservation with a relay is only half the story. After all, relayed connections are limited both in terms of time and bandwidth. Nodes use relayed connections to coordinate the establishment of a direct connection.

We need to distinguish two situations here:

1. **The node trying to connect is a public node**: This is the easier scenario. When the node behind the NAT accepts the relayed connection, it notices that the peer has a public IP address. It then dials a direct connection to that node.

2. **The other node is also behind a NAT**: Simply dialing the peer won't work. It's necessary to employ a technique called "hole punching". By carefully timing simultaneous connection attempts from both sides the NATs on both sides are tricked into thinking that they're both handling with outgoing connections.

Setting up the direct connection requires quite some effort, but it's worth it: direct connections have a lower latency, and can use the full bandwidth of the link.

### Hole Punching Implementation Status

{% support_matrix(data="go-libp2p:supported,rust-libp2p:supported,js-libp2p:wip") %}
js-libp2p hole punching support is in progress. See the [tracking issue](https://github.com/libp2p/js-libp2p/issues/1461).
{% end %}

### Further Reading

- [AutoNAT Specification](https://github.com/libp2p/specs/tree/master/autonat)
- [Circuit v2 Specification](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md)
- [Decentralized Hole Punching Research Paper](https://research.protocol.ai/publications/decentralized-hole-punching/)
