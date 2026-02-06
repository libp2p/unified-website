+++
title = "libp2p Annual Report 2025"
description = "libp2p Annual Report 2025"
date = 2026-02-02
slug = "2025-report"

[taxonomies]
tags = ["libp2p", "reporting", "annual report"]

[extra]
author = "Johanna Moran"
header_image = "/img/blog/annual-report-banner.svg"
+++

#### **Get involved with libp2p**

* Read the full [libp2p 2025 Report](/reports/annual-reports/2025/)
* Join a [libp2p community call](https://luma.com/libp2p?tag=community)
* Join our [Discord](https://discord.gg/MRRgEFMAVN)
* Explore the [libp2p Github](https://github.com/libp2p)
* Build a prototype using libp2p technical support and early collaboration \- [johanna@libp2p.io](mailto:johanna@libp2p.io) \- [manu@libp2p.io](mailto:manu@libp2p.io) \- [dave.grantham@libp2p.io](mailto:dave.grantham@libp2p.io)
* Partner with libp2p for funders and ecosystem partners \- [partner@libp2p.io](mailto:partner@libp2p.io)

## The Forefront of Decentralized Networking and AI

In 2025, libp2p became the communication layer behind over $100B in decentralized value flow. What began nearly a decade ago as a modular, secure peer-to-peer networking framework is now one of the most widely deployed foundations for decentralized systems, powering more than 30 blockchain networks, emerging compute fabrics, and next-generation Web3 applications.

Today, libp2p’s influence extends far beyond blockchains. With 10+ active implementations, 300+ monthly contributors, and rapidly expanding research into browser-native connectivity, decentralized AI, and post-quantum-secure networking, libp2p is evolving into a core substrate for a new era of distributed systems spanning Web3, AI infrastructure, edge computing, and embedded systems.

The past year delivered measurable gains in performance, interoperability, and adoption. QUIC and WebTransport matured significantly, reducing latency and improving battery efficiency across mobile and light clients. GossipSub upgrades made cross-client gossip more predictable under load, strengthening Ethereum L1, L2 rollups, shared sequencers, and data availability networks. Browser connectivity advanced through AutoTLS and improved relaying, enabling frontends to communicate directly with sequencing networks and peer-to-peer services without relying on centralized RPC infrastructure.

At the same time, libp2p’s role in decentralized AI and agentic systems became increasingly concrete. As autonomous agents, embedded compute, and on-device intelligence continue to expand, so does the need for trust-minimized, low-latency peer-to-peer messaging. This year’s work positions libp2p as a natural communication layer for agent-to-agent coordination, decentralized inference, and privacy-preserving AI workflows, while ongoing post-quantum and multiformat efforts future-proof the stack for decades to come.

This momentum is already visible in practice. In 2025, the Python implementation of libp2p matured enough to support reference implementations for federated learning and decentralized AI systems. These examples demonstrate peer-to-peer model coordination, gradient and parameter exchange, and privacy-aware training workflows without centralized servers. By lowering the barrier for researchers and AI engineers, Python-libp2p is emerging as a practical bridge between modern ML stacks and decentralized networking.

## **2026 Roadmap**

The year ahead focuses on usability, connectivity, privacy, and maturity, informed by deeper engagement with AI researchers and sustained investment in roadmap-shaping exercises.

Key priorities include:

* **Research Focus: GossipSub** to continue the ongoing research and development to scale decentralized state synchronization
* **Research Focus: Browser-native Connectivity** through broader AutoTLS rollout and improved relaying
* **Research Focus: Decentralized AI Applications** with destributed MCP and IPFS integration for federated learning
* **Research Focus: Mobile-native Advances** with Kotlin and Swift implementations moving toward production readiness
* **Advanced Network Simulation and Testing** enabling empirical testing of research implementations at scale
* **Easy Mode** enabling minimal-configuration peer-to-peer applications in just a few lines of code
* **Unified Developer Center** consolidating documentation, tutorials, and language-specific references
* **Universal Connectivity** supported by an updated specification and a continuous cross-language test suite targeting 95% interoperability

## **Achievements 2025**

* **Ethereum’s Portal Network** adopted libp2p for ultra-light RPC and decentralized state retrieval, enabling phone-native and home-run Ethereum clients.  
* **Sequencer networks** such as Espresso and Astria expanded their use of GossipSub as a coordination layer, with OP Stack teams beginning to integrate compatible meshes.  
* **QUIC and WebTransport improvements** significantly boosted mobile performance and reduced connection overhead, paving the way for emerging “wallet-as-a-node” architectures.  
* **Data availability networks** Celestia, Avail, and EigenDA benefited from upgrades that improved sampling throughput and blob propagation reliability.  
* **Browser connectivity** advanced through AutoTLS and web-to-web relaying, allowing browser-based dApps to participate directly in libp2p networks. The AutoTLS specification itself reflects growing cross-project collaboration, with contributions from nim-libp2p and Waku research teams.

### Across language ecosystems, implementations matured in parallel

* **go-libp2p and js-libp2p** deepened browser and WebTransport support.  
* **cpp-libp2p** was revived to support Lean Consensus research  
* **c-libp2p and eth-p2p-z (zig-libp2p)** expanded into embedded and constrained environments  
* **dotnet-libp2p** reached its first production integrations with Shutter and Optimism  
* **py-libp2p** progressed rapidly toward a 1.0 release, unlocking strong integrations with AI and ML workflows. The ecosystem introduced **production-quality examples for federated learning and decentralized AI**, showcasing peer-to-peer training coordination, model synchronization, and research-friendly experimentation using libp2p as the underlying transport.

## **Ecosystem, Research, and Education**

ProbeLab expanded cross-network monitoring across Ethereum, Gnosis, Base, Celestia, Filecoin, Avail, Polkadot, and IPFS, accelerating interoperability testing and improving visibility into network health. Developer education continued to scale through libp2p Days at EthCC and DevConnect, alongside the Universal Connectivity workshop adapted across Rust, Python, and JavaScript.

Academic adoption also grew in 2025\. Universities across South Asia began incorporating libp2p into curricula spanning engineering, management, and design. Institutions such as Netaji Subhas University of Technology (NSUT) integrated libp2p into coursework on distributed systems, decentralized applications, and platform design, exposing students to real-world peer-to-peer primitives and open-source collaboration.

## **Industry & Volunteer Contributions**

A defining strength of libp2p in 2025 was the depth of industry participation. Engineers from Huddle01, NVIDIA, DDN (Data Direct Networks), Hypertensor, and Linux Foundation Edge contributed code, specifications, performance testing, and real-world operational feedback.

These contributions improved transport efficiency, observability, browser and media-path networking, AI-adjacent workflows, and large-scale deployment resilience. Participation from engineers working in video infrastructure, high-performance computing, enterprise systems, and edge platforms reinforced libp2p’s role as a neutral, production-grade networking layer serving both Web3-native and traditional infrastructure organizations.

Beyond libp2p itself, critical improvements to quic-go and webtransport-go, used by thousands of projects outside Web3 received critical performance, security, and standards-alignment improvements, benefiting the wider internet as much as decentralized systems.

---
<div class="blog-logo-grid">
    <div class="blog-logo-grid__card">
        <img src="../../img/logos/powered-by-libp2p-logo.svg" alt="libp2p">
    </div>
    <div class="blog-logo-grid__card">
        <img src="../../img/logos/filecoin-logo.svg" alt="Filecoin">
    </div>
    <div class="blog-logo-grid__card">
        <img src="../../img/logos/ethereum-logo.svg" alt="Ethereum">
    </div>
    <div class="blog-logo-grid__card">
        <img src="../../img/logos/ipfs-logo.svg" alt="IPFS">
    </div>
    <div class="blog-logo-grid__card">
        <img src="../../img/logos/celestia-logo.svg" alt="Celestia">
    </div>
    <div class="blog-logo-grid__card">
        <img src="../../img/logos/optimism-logo.svg" alt="Optimism">
    </div>
</div>

## **Funding & Partnerships**

The **libp2p Core Fund**, established in 2024, continued investing in the project’s long-term health. Support from the Ethereum Foundation, Protocol Labs, Filecoin Foundation, Celestia, and Optimism enabled sustained maintenance, research, interoperability work, and ecosystem growth.

Notable contributions include:

* **Ethereum Foundation**: Advancing Eth2 networking, GossipSub tuning, instrumentation, developer documentation, and collaborative ZK and privacy tooling with PLDG.  
* **Filecoin Foundation**: Stress-testing libp2p at massive scale and feeding research-driven improvements back into every implementation.  
* **Celestia**: Supporting performance tuning, data-availability retrieval testing, and networking standards for modular blockchain architectures.  
* **Protocol Labs**: Funding cross-implementation maintenance, multiformats and IPLD standards, and ProbeLab’s research.  
* **Optimism**: Pioneering cross-rollup networking and sequencing infrastructure. 

Together with industry volunteers and academic partners, these organizations reflect a shared vision: **a secure, neutral, high-performance networking layer for the decentralized internet—and for the AI systems increasingly built on top of it**.

---

## **Conclusion**

Libp2p’s growth in 2025 was not only technical but structural. Multiple implementations matured in parallel, browser and mobile support strengthened, and decentralized AI systems increasingly relied on peer to peer networking as a foundational primitive.

With Python based reference implementations for federated learning and decentralized AI, growing industry participation, and expanding academic adoption, libp2p is no longer just infrastructure. It is an enabling layer for the next generation of distributed intelligence.

As libp2p enters 2026, it stands at the center of a global shift toward open, resilient, and autonomous compute. The work delivered this year, from AutoTLS and QUIC improvements to decentralized AI examples and university curricula, lays the groundwork for a decade in which distributed systems do not just scale, but become more connected and resilient.

The future of networking is decentralized.

Libp2p is building it.

## **Feedback**

We welcome your feedback.

libp2p is shaped by the builders, researchers, and operators who rely on it. If you have insights on this report, areas we should explore further, or perspectives that can help strengthen the project, please share them with us in the discussion thread:
https://discuss.libp2p.io/t/libp2p-annual-report-2025/3693
