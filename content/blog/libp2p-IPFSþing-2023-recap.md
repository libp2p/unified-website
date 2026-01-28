+++
title = "libp2p at IPFS þing 2023 Recap"
description = "Recap of libp2p presentations and workshops at IPFS þing 2023"
date = 2023-05-11
slug = "2023-libp2p-IPFS-Thing-recap"

[taxonomies]
tags = ["libp2p"]

[extra]
author = "Dave Huseby"
header_image = "/img/blog/ipfs-thing-2023-logo.png"
+++
Last month, April 15th - 19th 2023, the IPFS community came together in Brussels, Belgium for [IPFS þing 2023](https://blog.ipfs.tech/2023-ipfs-thing-recap/).

The libp2p users and contributors community came out to meet up once again, interface with the broader IPFS community, and share all of the great accomplishments and new work going on in the libp2p project.

Over the course of five days the libp2p community gave 6 different talks on recent developments and finished strong with a workshop where participants built their own peer-to-peer chat application.

## Goals

The goals of the libp2p contributors attending IPFS þing 2023 were to:

1. Build excitement by demonstrating the Universal Connectivity application
2. Give updates on performance, dealing with non-uniform network topology, interoperability improvements, and lowering barriers to libp2p compatibility
3. Reconnect with community contributors and build up the greater libp2p community

## Recap of Talks

### Connecting Everything, Everywhere, All at Once with libp2p

Max Inden (rust-libp2p maintainer)

{% youtube(id="4v-iIB0C9_8") %}
Universal Connectivity demonstrator app
{% end %}

Max's talk about the Universal Connectivity demonstrator app broke the record for the most people involved! The live demo showed a go-libp2p node talking to a rust-libp2p node talking to a laptop talking to js-libp2p browsers using a variety of transports including QUIC, WebRTC Direct, WebRTC, and WebTransport.

### libp2p Performance

Max Inden & Marco Munizaga

{% youtube(id="2h9jth3nvJw") %}
Performance benchmarking and optimization
{% end %}

Watch Max and Marco describe how libp2p maintainers think about and measure performance, plus learn about some optimizations in the latest versions.

### The Incredible Benefits of libp2p + HTTP

Marten Seemann & Marco Munizaga

{% youtube(id="Ixyo1G2tJZE") %}
HTTP over libp2p
{% end %}

Marten and Marco demonstrated using js-libp2p and service workers to intercept normal HTTP calls in the browser and re-route them over libp2p connections.

### How to Build Your Own Compatible libp2p Stack from Scratch

Marten Seemann & Marco Munizaga

{% youtube(id="aDHymXQJ4bs") %}
Building a minimal libp2p stack
{% end %}

Marten and Marco showed how simple it is to create a compatible libp2p stack out of a QUIC library, the libp2p TLS extension and some code for peer ID encoding.

### Enabling More Applications to Join the libp2p DHT Ecosystem

Gui Michel (Research Engineer at Protocol Labs)

{% youtube(id="OHrtv1jz2Jc") %}
libp2p DHT ecosystem
{% end %}

This talk covered improvements to the DHT to enable more applications to participate.

## Workshop: Build Your Own p2p Chat

Participants built their own peer-to-peer chat application leveraging the same technology as the Universal Connectivity demonstrator project. It was a great hands-on experience for everyone!
