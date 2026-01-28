+++
title = "libp2p & Ethereum (the Merge)"
description = "How libp2p became integrated into the Ethereum network through the Merge"
date = 2023-01-06
slug = "libp2p-and-ethereum"

[taxonomies]
tags = ["libp2p", "Ethereum", "Merge"]

[extra]
author = "Prithvi Shahi"
header_image = "/img/blog/libp2p_Ethereum_header.png"
+++
If you've kept up with developments in Web3, you've likely heard of the [Paris upgrade](https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/paris.md), more widely known as [The Merge](https://ethereum.org/en/upgrades/merge/), on the Ethereum network.

You may be wondering... why is the libp2p blog writing about Ethereum and the Merge?

Well, as a result of the Merge, we're excited to share that:

**libp2p is integrated into the Ethereum network!**

## A Brief History of libp2p

Protocol Labs first developed libp2p as a networking library inside of IPFS. At the outset, their code and repositories were coupled. However, Protocol Labs soon realized libp2p's potential and utility beyond IPFS, and project maintainers split the two codebases apart.

As a result, the libp2p project saw tremendous growth and adoption. Besides IPFS and Filecoin, libp2p is relied on by networks like Polkadot, Polygon, Mina, Celestia, Flow, and many more.

## The Merge

Ethereum's genesis occurred on July 30, 2015 as a part of a milestone called Frontier. The most recent (and arguably the most anticipated) upgrade was Paris, a.k.a. The Merge, executed on September 15, 2022.

The Merge encompassed major changes:

1. **Upgrading the consensus mechanism** - Transitioning to proof-of-stake, away from proof-of-work
2. **Reducing network energy consumption by 99.95%**
3. **Integrating libp2p** into the mainnet's networking layer

## How libp2p was integrated into Ethereum

In the early days of Ethereum and libp2p, libp2p didn't exist when Ethereum was first developed, so it never got a chance to be evaluated and/or adopted.

Prior to the Merge, Ethereum solely used devp2p, a dedicated networking stack. Though there were talks between the Ethereum and IPFS/libp2p communities to have one solution instead of two, the timing didn't work.

### Early Days (2016-2017)

At Devcon 2, David Dias from Protocol Labs gave a talk titled "libp2p ❤ devp2p: IPFS and Ethereum Networking". He gave an overview of libp2p and demonstrated running the EVM in a browser connecting to a go-ethereum node using libp2p.

![Early libp2p and Ethereum collaboration](/img/blog/eth-libp2p-2016.png)

### The Integration

The integration of libp2p into Ethereum came through the new consensus layer (beacon chain) that powers proof-of-stake. Beacon nodes use libp2p for peer discovery, establishing connections, and exchanging messages.

This is the work of many across various organizations including the Ethereum Foundation, Prysmatic Labs, Sigma Prime, ChainSafe, Status.im, and Protocol Labs.

## How Ethereum Beacon Nodes use libp2p

Beacon nodes use libp2p in several ways:

- **Peer Discovery**: Using discv5 for discovery and libp2p for connections
- **GossipSub**: For propagating blocks and attestations
- **Request/Response**: For syncing and specific data requests

## Conclusion

The integration of libp2p into Ethereum represents years of collaboration between the communities. It demonstrates the power of open-source development and the value of modular, reusable networking libraries.

We're excited about this milestone and look forward to continued collaboration with the Ethereum community!
