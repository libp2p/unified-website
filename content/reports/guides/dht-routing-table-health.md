+++
title = "DHT Routing Table Health"
description = "Measuring how complete and current IPFS peers' Kademlia routing tables are despite high network churn."
weight = 4

[extra]
author = "Guillaume Michel"
+++

This report assesses the health of Kademlia DHT routing tables across the IPFS network: how
many entries are stale or unreachable, how peers are distributed across k-buckets, and
whether nodes actually maintain their 20 closest peers. The data comes from the
[Nebula crawler](https://github.com/dennis-tra/nebula) over 28 crawls across 7 days
(19–26 April 2022), reconstructing expected k-bucket contents with a binary trie to compare
actual versus theoretical peer distributions.

**Key findings:**

- **95.21% of peers** keep at least 18 of their 20 closest peers in their routing table.
- **Full k-buckets (0–8)** average only 0.12 missing peers each; non-full buckets (9+) show ~20% missing, as expected from the network design.
- **Unreachable peers** account for just 3.78% in heavily populated buckets.
- Peer distribution closely matches theoretical expectations for the network size.

The overall takeaway: DHT routing tables are surprisingly resilient despite high churn,
keeping peers discoverable and routing information current.

{% alert(type="note") %}
Read the full report in the [network-measurements repository](https://github.com/probe-lab/network-measurements/blob/main/results/rfm19-dht-routing-table-health.md) (Guillaume Michel, August 2022).
{% end %}
