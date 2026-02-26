+++
title = "mplex"
description = "mplex is a simple stream multiplexer that was developed for libp2p."
weight = 42
aliases = ["/concepts/multiplex/mplex", "/guides/mplex/"]

[extra]
toc = true
category = "multiplexing"
+++

## What is mplex?

mplex is a simple stream multiplexer that was designed in the early days of libp2p.
It is a simple protocol that does not provide many features offered by other
stream multiplexers. Notably, mplex does not provide flow control, a feature which
is now considered critical for a stream multiplexer.

mplex runs over a reliable, ordered pipe between two peers, such as a TCP connection.
Peers can open, write to, close, and reset a stream. mplex uses a message-based framing
layer like [yamux](/docs/yamux/), enabling it to multiplex different
data streams, including stream-oriented data and other types of messages.

### Drawbacks

mplex is currently in the process of being deprecated (to track progress please see [this issue](https://github.com/libp2p/specs/issues/553)).
mplex does not have any flow control.

> Backpressure is a mechanism to prevent one peer from overwhelming a slow time consuming the data.

mplex also doesn't limit how many streams a peer can open.

{% alert(type="warning") %}
**If you need a dedicated muxer, Yamux should be used (overall, QUIC should be preferred over TCP).** Yamux natively supports flow control, it is better suited for applications that require the transfer of large amounts of data.

Until recently, the reason mplex was still supported was compatibility with js-libp2p,
which didn't have yamux support.
Now that
[js-libp2p has gained yamux support](https://github.com/ChainSafe/js-libp2p-yamux/releases/tag/v1.0.0),
mplex should only be used to provide backward-compatibility with legacy nodes.
{% end %}

{% alert(type="note") %}
See the mplex [technical specification](https://github.com/libp2p/specs/tree/master/mplex) for more details.
{% end %}
