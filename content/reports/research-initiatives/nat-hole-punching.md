+++
title = "NAT Hole Punching"
description = "A measurement campaign evaluating the DCUtR hole-punching protocol across ~6.25M attempts in 372 networks, with an accompanying research paper."
weight = 2

[extra]
author = "ProbeLab"
+++

This report evaluates the success rate and performance of libp2p's DCUtR (Direct Connection
Upgrade through Relay) protocol for NAT hole punching. The campaign ran from December 2022
through January 2023, tracking roughly **6.25 million hole-punch attempts** across 372
identified networks in 39 countries, using a honeypot to discover NAT'd peers, a central
coordination server, and distributed Go and Rust clients.

**Key findings:**

- **~70% success rate** for hole punching across networks, independent of round-trip time to the relay.
- **TCP and QUIC perform similarly**, but QUIC wins ~81% of races when both are available.
- **First attempts succeed most often**; retries rarely help.
- **IPv6 showed surprisingly low success rates**, flagged for further investigation.
- **VPNs reduce effectiveness** by adding extra NAT layers.
- **90% of successful direct connections** achieve lower latency than the relayed path.

The findings produced three protocol-improvement proposals and surfaced address-reporting
and IPv6 issues in libp2p implementations.

{% alert(type="note") %}
Read the full report in the [network-measurements repository](https://github.com/probe-lab/network-measurements/blob/main/results/rfm15-nat-hole-punching.md), and the accompanying research paper on [arXiv (2510.27500)](https://arxiv.org/abs/2510.27500).
{% end %}
