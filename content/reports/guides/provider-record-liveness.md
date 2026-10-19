+++
title = "Provider Record Liveness"
description = "How long IPFS provider records remain retrievable in the DHT, and what that means for replication and republish intervals."
weight = 3

[extra]
author = "Mikel Cortes-Goicoechea, Leonardo Bautista-Gomez (Barcelona Supercomputing Center)"
+++

Provider records (PRs) map content IDs to the peers that host them. This report measures how
long those records stay accessible in the IPFS DHT over time. Using the purpose-built **CID
Hoarder** tool, the authors published 10,000 random CIDs over 36-hour windows, tracked PR
holders roughly every 30 minutes, and tested replication values of K = 15, 20, 25, and 40,
with and without Hydra-Booster nodes.

**Key findings:**

- **75% of initial PR holders remain online 48+ hours**, and 70% serve records for the full 24-hour specification period.
- **K = 20 remains a suitable replication value**, balancing overhead, performance, and reliability.
- **The network functions adequately without Hydra nodes**, though they add stability — the authors suggest halving their count rather than removing them.
- **Raising the republish interval from 12 to 24 hours** could cut network overhead by ~25% without compromising availability.
- **70% of the initial closest peers** stay among the K closest for 48+ hours.

{% alert(type="note") %}
Read the full report in the [network-measurements repository](https://github.com/probe-lab/network-measurements/blob/main/results/rfm17-provider-record-liveness.md) (Cortes-Goicoechea & Bautista-Gomez, August 2022).
{% end %}
