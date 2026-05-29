+++
title = "GossipSub"
description = "The research paper behind libp2p's attack-resilient publish-subscribe protocol, now powering messaging in Filecoin and Ethereum."
weight = 4

[extra]
author = "Dimitris Vyzovitis, Yusef Napora, Dirk McCormick, David Dias, Yiannis Psaras"
+++

GossipSub is a gossip-based publish-subscribe protocol built for permissionless blockchain
networks, where fast message propagation must coexist with resilience against adversarial
peers. This paper introduces its design and evaluates it against a range of attacks.

**Key contributions:**

- **Mesh construction** — an eager-push delivery model that keeps fan-out low while balancing bandwidth against propagation speed.
- **Gossip dissemination** — a lazy-pull model that reaches nodes outside the mesh.
- **Peer scoring** — reputation profiles for connected peers, so well-behaved nodes are preferred for mesh inclusion.
- **Attack mitigation** — defenses tailored to Sybil-based attacks against each of the protocol's three core components.

The authors validated GossipSub across **5,000+ virtual nodes on AWS**, demonstrating
resilience against the considered attacks. The protocol was subsequently adopted as the
messaging layer for **Filecoin and Ethereum 2.0**.

{% alert(type="note") %}
Read the full paper on [arXiv (2007.02754)](https://arxiv.org/abs/2007.02754) (Vyzovitis et al., 2020).
{% end %}
