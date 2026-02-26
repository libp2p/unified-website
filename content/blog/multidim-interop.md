+++
title = "Testing all the libp2ps"
description = "Basic interoperability tests for every libp2p implementation on all transport dimensions."
date = 2023-08-23
slug = "multidim-interop"
aliases = ["/multidim-interop"]

[taxonomies]
tags = ["libp2p"]

[extra]
author = "Marco Munizaga"
header_image = "/img/blog/interop-testing.png"
+++
There are many [implementations](https://github.com/libp2p/libp2p#implementations) of libp2p with varying degrees of feature completeness. Each implementation has transports, secure channels, and muxers that they support. How do we make sure that each implementation can communicate with every other implementation? And how do we check that they can communicate over each supported combination?

In this post I'll cover how we test every implementation on every strategy, on many versions, and highlight some open problems that you can contribute to.

Testing connectivity interoperability is as simple as starting up two libp2p nodes and having them ping each other. The difficulty arises in how we make a reproducible environment for every implementation and connection strategy.

The first attempt used Testground, but it was too complicated and slow for what we wanted to do. The next attempt used Docker's compose directly with some TypeScript to help generate the compose files. This was much easier to build.

## Problems to solve

Compose handles spinning up the test environment, but there were still problems to solve:

1. How do we define this test environment?
2. How do we share the listener's address to the dialer?
3. How do we build each implementation?

We solved the first problem with Sqlite. The problem of finding all combinations of implementations and parameters is equivalent to a Join operation.

The second problem we solved using Redis as a synchronization point. The listener pushes its address to Redis, and the dialer blocks until it can read it.

For building implementations, we use Makefiles and Docker container images with caching in S3.

## Coverage

Right now, the system tests 6 different libp2p implementations and runs about 1700 tests. The tests are also run on each PR in Go, Rust, JS, Nim, and Zig libp2p.

![Multidim Interop coverage matrix](/img/blog/multidim-interop-coverage.png)

See the latest full run at the [libp2p Status Page](https://libp2p.io/status).

## Impact realized so far

The system has already helped catch several bugs:

- quic-go wrong cipher selection
- Interop failure with Firefox WebRTC
- zig-libp2p multistream-select issue
- Interop issue with Yamux between rust-libp2p and js-libp2p
- Wrong default Noise handshake pattern

It has also validated big code changes like the new WebTransport transport for rust-libp2p in Wasm.

## Next steps

There's still room for improvement, especially in making tests faster. The biggest optimization would be reducing the Docker overhead.

Beyond basic connectivity, we want to add tests for mDNS and test interoperability of libp2p protocols like Kademlia, GossipSub, and more.

Are you working on a libp2p implementation? Check out the [unified-testing docs](https://github.com/libp2p/unified-testing/tree/master/docs) for specifics on how to implement these tests.
