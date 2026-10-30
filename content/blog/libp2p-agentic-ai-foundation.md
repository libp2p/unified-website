+++
title = "libp2p joins the Agentic AI Foundation as an Associate Member"
description = "libp2p is now an Associate Member of the Agentic AI Foundation, bringing open, encrypted, resilient peer-to-peer networking to agent-to-agent communication."
date = 2026-10-31
slug = "libp2p-agentic-ai-foundation"

[taxonomies]
tags = ["libp2p", "agentic AI", "AI"]

[extra]
author = "Anurag Pandey"
header_image = "img/blog/libp2p-agentic-ai-foundation.png"
+++

The Agentic AI Foundation (AAIF) has passed 305 members in under a year, and libp2p is now one of them.

Most work in agentic AI so far has been about what a single agent can do: the model, its tools, its context. That is a hard problem, but it is a contained one. Everything happens inside one process, one team, one trust boundary.

It stops being contained once agents start working with other agents. These agents belong to different organisations, run on different clouds, sit on phones and edge devices, and connect over networks nobody fully controls. Three questions come up immediately. How does an agent find the right peer? How does it prove who it is? How does it reach that peer through firewalls and NATs it has no control over? None of these are AI problems. They are networking problems, and they are the ones libp2p was built to solve.

libp2p has been doing this in production for nearly a decade.

On identity, every peer has a cryptographic identity, and connections are authenticated and encrypted. An agent doesn't need to be listed in a central registry or sit behind a domain name to be recognised. Its identity comes from its keys, so you can verify who you are talking to before any data moves.

On reachability, most machines are not directly addressable. They live behind NATs, home routers and corporate firewalls. libp2p handles NAT traversal across QUIC, TCP, WebRTC and WebTransport, so two peers that can't see each other directly can still end up connected, including from a browser.

On discovery, peers find each other through the Kademlia DHT, which means there is no single directory that has to stay online or be trusted. On communication, GossipSub provides pub/sub messaging, so agents can announce what they can do or coordinate around a topic without a central broker in the middle.

All of this ships in 17 implementations, including Go, Rust, JS, Python, Nim and .NET. Agents are written in whatever stack suits the job, and a shared network layer only helps if it speaks to all of them.

Agent-to-agent communication needs a network layer that is open, encrypted and resilient. We joined AAIF to work on these problems with the wider community, and we will do it in the open.

To get involved, start here: https://libp2p.io/get-involved/
