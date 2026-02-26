+++
title = "libp2p Day 2022 Recap"
description = "Recap of libp2p Day during IPFS Camp 2022 in Lisbon!"
date = 2022-11-22
slug = "2022-11-22-libp2p-day-2022-recap"
aliases = ["/2022-11-22-libp2p-day-2022-recap"]

[taxonomies]
tags = ["libp2p"]

[extra]
author = "Prithvi Shahi"
header_image = "/img/blog/libp2p-day-blog-header.png"
+++
Last month, on October 30th 2022, libp2p users and contributors gathered together for the first ever libp2p Day!

The day included talks from maintainers, contributors, community members, and users. Topics included latest libp2p updates, preview of future roadmap items, bleeding-edge demos on browser connectivity using new transport protocols, and much more.

Speakers shared new, exciting developments built on libp2p and represented organizations like Little Bear Labs, ChainSafe Systems, Status.im, Gather, Quiet, Pyrsia, Satellite.im, and Protocol Labs.

In the larger context, libp2p Day was hosted at [IPFS Camp 2022](https://2022.ipfs.camp/) as a part of a diverse lineup.

### Goals

The goals of libp2p Day were to:

1. Share updates on libp2p and highlight new developments through demos
2. Gather the libp2p ecosystem, give a spotlight to projects building on libp2p, and energize the community
3. Empower newcomers and existing users to become contributors and spec authors

### Key Takeaways

#### Browser Connectivity Unlocked

First-class support for WebTransport enables libp2p nodes running in the browser to connect directly with peers on a host machine. WebRTC browser-to-server has also made significant progress.

Check out the [new libp2p connectivity guide](/docs/browser-connectivity).

#### libp2p Interoperability

The libp2p ecosystem continues to flourish with several implementations, each with its own set of supported features. libp2p teams are focusing on testing interoperability.

#### Demand for libp2p + HTTP

With the growing demand for libp2p + HTTP, the team has started drafting an HTTP specification.

## Recap of talks

### Intro to libp2p: helping with real world application problems

Max Inden (rust-libp2p maintainer, Software Engineer at Protocol Labs)

{% youtube(id="J7ZWbpo2AZk") %}
Max introduced libp2p by giving an overview of the supported transport protocols, secure channels, and multiplexing mechanisms.
{% end %}

Max introduced libp2p covering transport protocols, secure channels, multiplexing mechanisms, how libp2p traverses NATs, discovers peers, uses Kademlia for peer-to-peer routing, and GossipSub for pub/sub messaging.

For all the talk recordings, visit the [IPFS Camp 2022 archive](https://2022.ipfs.camp/).
