+++
title = "Building Resilient P2P Networks: libp2p at Devcon 8 in Mumbai"
description = "How libp2p contributors and ecosystem teams explored peer-to-peer connectivity, IPFS infrastructure, interoperability, and recovery at Devcon 8."
date = 2026-11-22
slug = "devcon-8-building-resilient-p2p-networks"

[taxonomies]
tags = ["libp2p", "Devcon"]

[extra]
author = "Anurag Pandey"
header_image = "/img/blog/Resilient-Networking-Hub.png"
+++

*Resilient Networking Hub · November 3–6, 2026*

Resilient networking is foundational to open protocols. Networks must remain useful when routes disappear, peers become unreachable, services are censored, or infrastructure fails. That means supporting discovery and recovery, giving operators ways to understand what is happening, and keeping applications accessible without depending on a single gateway.

At Devcon 8 in Mumbai, the libp2p-led Resilient Networking Hub convened maintainers, researchers, infrastructure operators, and application builders for four days of sessions on peer-to-peer networking. The program covered peer discovery, transports, secure connections, interoperability, observability, storage, and recovery.

Contributors from libp2p, Ethereum client networking, IPFS, Swarm, and related projects shared their work and compared approaches to resilience. Together, the sessions highlighted the engineering and community work that helps open networks remain useful under real conditions.

![The Resilient Networking Hub at Devcon 8](/img/blog/resilient-networking-hub-1.jpg)

## Start with the connection

The opening session, “Resilient Networks from Zero,” introduced the basic pieces of a peer-to-peer connection: peer identity, discovery, transports, and secure connections. Manu Sheel Gupta, Miglė Rakitaitė, Shouki Tsuda, and Steven Mih welcomed participants and framed the practical questions behind those components.

A peer needs an identity so other peers can recognize it. It needs a way to discover other participants. It needs a transport that works in its environment, and a secure connection that lets the two sides communicate safely. None of these pieces works in isolation. If discovery fails, a healthy peer may as well be invisible. If a transport is blocked, the network needs another route. If implementations disagree about how a protocol works, they may be unable to communicate even when a connection is available.

The Hub program also brought attention to the protocols that make a peer network useful after a connection is established. A distributed hash table helps peers discover content and other peers. GossipSub propagates messages across a changing mesh. NAT traversal and relays help connect participants whose networks do not allow direct inbound connections. Each component addresses a different obstacle, and each needs to work with the others for a network to remain available to users.

That is why interoperability came up throughout the program. Shouki Tsuda’s session on functional languages and protocol implementation looked at how implementation choices affect compatibility across P2P stacks. Tsuda maintains Haskell-libp2p, and the discussion connected language and architecture decisions to a shared ecosystem goal: independent implementations should still be able to speak the same protocols.

The opening day also made space for maintainers to introduce their work. Daniel Thompson, Shouki Tsuda, Sumanjeet, Soham Bhoir, and Yash Saini took part in the maintainer meet-up and Network Lab sessions. Their work spans JavaScript libp2p, Haskell-libp2p, py-libp2p, GossipSub, WebRTC connectivity, and network simulation. Kazuma Sengoku’s session on user-controlled keys, private membership proofs, and shared time added a privacy perspective to how peers can coordinate. Banri Yanahama and Ryosuke Kaga led a formal verification workshop, exploring how to reason about protocol correctness. For participants, meeting the people behind the tools made it easier to move from a general networking question to a concrete project, test, or contribution.

![Participants taking part in a Resilient Networking Hub session](/img/blog/resilient-networking-hub-2.jpg)

## Resilience means planning for failure

The question “What makes a network resilient?” brought together Miglė Rakitaitė, Manu Sheel Gupta, Steven Mih, and contributors from EthSwarm. The roundtable treated connectivity, trust, failure, and recovery as connected parts of the same problem.

Node count alone does not determine resilience. Peers need to find one another, exchange information, and recover when parts of the system become unreachable. Operators also need ways to detect problems and understand what happened. Without that visibility, teams may know that users are having trouble without knowing whether the cause is a failed peer, a broken route, a relay bottleneck, an attack, or a configuration issue.

The Hub’s conversations about permissionless network resilience brought this into real-world settings. Examples from libp2p deployments such as Qaul and Zemzeme showed how peer-to-peer systems can respond to severe connectivity restrictions, censorship, and infrastructure disruption. Regional nodes, discovery mechanisms, automatic recovery, and observability all contribute to the ability to keep communicating when familiar routes are unavailable.

These examples make resilience tangible. A network that works only while every expected service is reachable has not yet answered the most important question. The harder test is whether people can still use it when some of those services or paths disappear.

![A discussion about peer-to-peer network resilience at the Hub](/img/blog/reseilient-networking-hub-3.jpg)

## Ethereum networking is part of Ethereum resilience

Ethereum depends on peer-to-peer networking to connect consensus clients and propagate messages. For that reason, network health, client diversity, protocol security, and consensus cannot be treated as separate concerns.

The “Building Resilient Ethereum: Networking, PQ Security and Verified Consensus” discussion brought together Manu Sheel Gupta, Shouki Tsuda, Miglė Rakitaitė, Leo Lara, and Kazuma Sengoku. They considered the relationship between libp2p, Ethereum consensus clients, implementation diversity, network security, and post-quantum readiness.

Post-quantum migration benefits from early coordination. Cryptographic changes can affect handshakes, peer identity, message sizes, performance, and compatibility between implementations. Implementers need to understand how changes fit into the networking stack and how peers will continue to communicate during a transition.

The second day widened the engineering conversation across projects. The program connected protocol resilience with post-quantum networking, agent infrastructure, distributed quantum services, IPFS operations, and py-libp2p connectivity work. Those projects have different requirements, but they all depend on peers being able to discover one another, communicate across implementations, and keep making progress when a central service is unavailable.

The Hub returned to these issues on the final day. Shouki Tsuda led technical sessions on post-quantum cryptography support in libp2p and Ethereum’s post-quantum migration of its P2P layer. These sessions connected cryptographic research to the practical requirements of shipping secure, interoperable networking software.

Protocol resilience also has an organizational side. Manu Sheel Gupta and Shouki Tsuda facilitated a three-part discussion track on assessing Ethereum’s protocol health, exploring a credibly neutral methodology, and making resilience evidence actionable. Across the sessions, participants considered what current indicators show, where dependencies and cascading failures are hard to observe, and how independent teams might reproduce assessments. The final discussion connected that evidence to engineering priorities, operational planning, security coordination, and sustainable support for critical infrastructure. The discussions built on the ecosystem’s existing security and reliability work and explored what shared information or coordination could make it more useful.

## Building and operating the infrastructure

Resilient networks need software that people can run, maintain, and adapt. The Hub’s practical sessions looked at several implementations and tools, each addressing a different part of the networking stack.

Sumanjeet, a maintainer of py-libp2p and the unified test plans, contributed to discussions and demonstrations around connectivity and cross-implementation testing. py-libp2p helps bring libp2p protocols to Python, while shared tests help identify whether implementations behave consistently. Testing across implementations is essential: a protocol is only interoperable when independently built software can connect and exchange data in practice.

Shouki Tsuda brought the Haskell-libp2p perspective, including how functional language choices shape protocol implementation. Daniel Thompson represented the JavaScript and browser side of the ecosystem through js-libp2p. His work includes peer-to-peer networking for web applications and offline synchronization projects. Yash Saini works on connectivity projects including WebRTC Direct v2 and AutoTLS, and maintains Luminar, a visual tool for exploring P2P network behavior. Soham Bhoir brought experience from QMeshPy and GossipSub, including Python networking infrastructure.

One project that made network behavior visible was Luminar. It simulates a GossipSub v1.1 network and shows messages moving through a peer mesh. Participants can inject conditions such as Sybil peers, eclipses, and network partitions, then watch what peer scoring and recovery do. The simulator can help make an attack or failure mode easier to understand than it is from protocol prose alone. It also shows that defenses have limits: scoring can respond to certain kinds of misbehavior, while an eclipse made up of quiet peers may be harder to detect.

Another emerging effort was leanp2p, presented by Leo Lara with collaborators. The project explores a libp2p implementation in Lean 4, initially aimed at Ethereum’s consensus layer. Its protocol priorities include TCP, the Noise security handshake, Yamux stream multiplexing, Identify, request and response, and GossipSub. The project connects implementation diversity with rigorous protocol engineering, including interoperability vectors and testing. It is an early-stage project, but its ambition is practical: build a networking implementation that can be examined carefully and tested against other stacks.

## Storage and services people can operate

Decentralized networking depends on storage and retrieval as much as it depends on connections. A peer may be reachable, but the application still needs a dependable way to publish, find, and retrieve its data.

Anurag Pandey, an IPFS MeshKit co-author and Code for GovTech contributor, joined Manu Sheel Gupta for a practical workshop on building and sustaining self-hosted IPFS infrastructure. The session focused on operations, maintenance, and accessibility. Running your own IPFS services gives a team more control over its infrastructure, but it also means taking responsibility for keeping those services available and understandable to users.

MeshKit is part of Anurag’s work to make IPFS-based infrastructure more accessible to developers and applications. The project includes a JavaScript module and an MCP server. Alongside that tooling, Anurag Pandey and Manu Sheel Gupta have been working on how to scale and sustain self-hosted IPFS infrastructure so it remains maintainable over time. This is a practical part of resilience: tools should be usable by teams that want to operate them.

The wider IPFS ecosystem includes projects such as Kubo, Boxo, Helia, and IPFS Cluster. They support different roles, from running IPFS nodes and building applications to coordinating replication. Devcon-related contribution work explored resilient storage patterns for applications, including local persistence, content-addressed backups, replication, and retrieval during connectivity interruptions. These approaches are relevant to settings where gateways are unavailable or connectivity is unreliable, including offline-first applications. Content addressing lets an application check that retrieved data matches the expected content, while replication gives it more than one place to retrieve that content from.

The deeper point is that infrastructure choices affect who can keep a service running. A self-hosted node, a replicated dataset, or a local cache can give applications more options when a central provider is unavailable. They do not remove operational work, but they can reduce reliance on any single operator.

![A session on operating IPFS infrastructure at the Hub](/img/blog/resilient-networking-hub-4.jpeg)

## Media is a network resilience test

Day three put decentralized media at the center of the Hub. The sessions explored decentralized hosting, music distribution, permanent archives, streaming, collaborative editing, and publishing without relying on HTTP gateways. Media makes network resilience easy to understand because people notice immediately when a page, stream, or archive stops working.

The program brought together speakers from several projects. Chris H examined who controls access to media. Subcult discussed the cost of platform dependence for artists. Meinhard of Freedom Browser explored a browser that joins the network, while Aron of Swarm Foundation led a workshop on moving frontends away from traditional hosting. Björn of MetaProvide looked at preserving digital memory. Levi from Solar Punk presented streaming from camera to viewer over Swarm. Other sessions examined publishing when someone wants content offline, the resilience test of taking down a gateway, and the engineering trade-offs behind streaming a large event. Together, these sessions made the delivery path visible, from the publisher and storage layer through network peers to the viewer.

These discussions showed both the promise and the difficulty of decentralized media. Tomo from the Ethereum Foundation and Meinhard also took up the usability question: if decentralized publishing is hard to use, will creators and audiences choose it? Gateway resilience needs to go hand in hand with speed, clarity, and dependable access for creators and audiences. People need practical ways to publish and reach work when a particular platform or route is unavailable.

Decentralized storage and distribution introduce practical design choices. Swarm’s content addressing, storage incentives, postage stamps, and bandwidth accounting address how content is identified, kept available, and moved through the network. Browser-based access and peer-to-peer streaming extend those choices to readers and viewers. The Hub’s gateway-resilience experiments asked what happens when a gateway, publisher, or peer goes offline, and how quickly access recovers.

That same question appears in applications beyond media. A healthcare tool, a research archive, or a community service may need local storage and later synchronization. A network that can keep data available across nodes and recover after an outage gives those applications more room to operate in the real world.

![Contributors and attendees gathered at Devcon 8](/img/blog/resilient-networking-hub5.jpg)

## What the four days made clear

The Resilient Networking Hub connected protocol work with the tools and people needed to put it into practice. Manu Sheel Gupta’s libp2p work, Shouki Tsuda’s Haskell implementation and post-quantum research, Sumanjeet’s py-libp2p and interoperability work, Anurag Pandey’s IPFS MeshKit and self-hosted infrastructure work, Daniel Thompson’s js-libp2p contributions, Yash Saini’s connectivity work and Luminar, and Soham Bhoir’s GossipSub experience all represented different routes into the same challenge.

The broader set of conversations included Miglė Rakitaitė and EthSwarm contributors on resilience and community-driven infrastructure, Steven Mih on network trust and observability, discussions on protocol resilience, Kazuma Sengoku on private coordination, Leo Lara and collaborators on leanp2p, and the builders bringing decentralized media to Swarm. Each perspective added a different layer to the picture.

The final day returned to how resilience can be measured and improved in practice. Alongside Shouki Tsuda’s sessions on post-quantum cryptography and Ethereum’s P2P migration, the program explored observability for the Internet of Agents. Operators need enough information to detect failures, trace message delivery, and understand recovery. They also need to consider what their measurements expose about peers. Useful observability supports operations while respecting the privacy of people using the network.

Practical contribution pathways connected those discussions to ongoing work in IPFS Helia and Kubo, Verity Client, and zero-knowledge proofs. For networking teams, contributions can take many forms: implementation work, interoperability tests, reproducible measurements, documentation, and operational feedback. Each helps turn a resilience goal into something maintainers can inspect and improve.

Resilience comes from how those layers work together. Networks need multiple ways to discover peers and establish connections. Implementations need to interoperate. Operators need ways to detect failures and recover. Applications need storage and retrieval paths that continue to work when gateways or connectivity fail. Maintainers need sustainable support to keep improving the software.

The Resilient Networking Hub created space to compare approaches and connect projects working on related challenges. Building resilient P2P networks is continuing work across the ecosystem, supported by open testing, shared tools, and sustained collaboration among maintainers, researchers, operators, and application teams.

## Related resources

- [Devcon outcomes and activities](https://libp2p.tech/devcon-outcomes)
- [Resilient Networking Hub program](https://libp2p.tech/devcon)
- [Hub schedule](https://libp2p.tech/schedule)
- [IPFS Planet Expedition](https://libp2p.tech/ipfs-planet)
- [Decentralized Media Day program](https://libp2p.tech/dmedia-day)
- [Protocol Risk Management and Public Goods Funding in Ethereum](https://libp2p.tech/protocol-risk-management)
