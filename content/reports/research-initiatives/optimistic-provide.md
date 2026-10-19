+++
title = "Optimistic Provide"
description = "How statistical network-size estimation and predictive termination cut IPFS DHT publication latency from ~15s to ~0.7s."
weight = 1

[extra]
author = "Yiannis Psarras, Dennis Trautwein"
+++

Publishing content to IPFS via the DHT was historically slow — often 13–20 seconds, sometimes
minutes. The bottleneck was the rigid DHT-walk termination condition, which forced nodes to
wait for specific peers that were frequently unreachable. **Optimistic Provide** rethinks when
a provide operation can safely stop.

**How it works:**

1. **Network size estimation** — nodes estimate the global network size from peer distances observed during routine routing-table refreshes, adding zero network overhead.
2. **Predictive termination** — instead of waiting for rigid confirmation, the algorithm uses statistical heuristics to stop early once it has reached the necessary peers with ~90% confidence.
3. **Early return** — control returns after 15 of 20 peers confirm storage, while remaining requests complete asynchronously.

**Results:**

- Upload latency drops from ~15s to **~0.7s — a 10×+ improvement**, with content discoverable within ~1 second of publication.
- Record availability stays comparable to the original approach (only modest, negligible-impact replication reductions).
- Network overhead is reduced by ~40%.

Shipped as the default in **Kubo v0.39.0** (February 2026).

{% alert(type="note") %}
Read the full write-up on the [ProbeLab blog](https://probelab.io/blog/optimistic-provide/) (Yiannis Psarras & Dennis Trautwein, March 2026).
{% end %}
