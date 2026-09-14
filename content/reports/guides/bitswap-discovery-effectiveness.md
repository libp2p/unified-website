+++
title = "Bitswap Discovery Effectiveness"
description = "Measuring how effectively Bitswap discovers IPFS content without DHT lookups, and what that implies for ProviderSearchDelay."
weight = 2

[extra]
author = "Guillaume Michel"
+++

Before falling back to a DHT lookup, IPFS nodes try to find content via **Bitswap** by asking
already-connected peers. This study measures how effective that broadcast-based discovery
actually is on its own. Researchers modified kubo and go-bitswap to request **71,769 CIDs**
(from Bitswap sniffs and IPFS Gateway logs) while blocking DHT lookups, running for 50 hours
from a European data center.

**Key findings:**

- **98% of requested content was discovered by Bitswap alone**, without DHT assistance — far above the ~5% that was expected.
- **Fast**: 75.98% of successful requests completed within 200 ms, and 95.20% within 1 second.
- **Highly concentrated**: just 723 distinct providers served all successful requests, with the top 10 delivering ~60% of content.
- **Expensive**: each request averaged 1,714 messages to 856 peers — heavy flooding compared to the DHT's ~15 messages.

**Recommendations:** remove or shorten the 1-second `ProviderSearchDelay` (to 200–500 ms),
start DHT lookups concurrently with Bitswap (only ~0.4% overhead), and explore selective
broadcasting toward high-performing providers rather than network-wide flooding.

{% alert(type="note") %}
Read the full report in the [network-measurements repository](https://github.com/probe-lab/network-measurements/blob/main/results/rfm16-bitswap-discovery-effectiveness.md) (Guillaume Michel, December 2022).
{% end %}
