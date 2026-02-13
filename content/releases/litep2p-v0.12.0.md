+++
title = "Announcing the release of litep2p v0.12.0"
description = "Release v0.12.0 of litep2p"
date = 2025-11-11
slug = "2025-11-11-litep2p"

[taxonomies]
tags = ["litep2p"]

[extra]
author = "dmitry-markin"
version = "v0.12.0"
implementation = "litep2p"
breaking = false
security = false
github_release = "https://github.com/paritytech/litep2p/releases/tag/v0.12.0"
+++
## [0.12.0] - 2025-11-11

This release adds `KademliaEvent::PutRecordSuccess` &amp;amp; `KademliaEvent::AddProviderSuccess` events to Kademlia, allowing to track whether publishing a record or a provider was successfull. While `PutRecordSuccess` was present in the previous versions of litep2p, it was actually never emitted. Note that `AddProviderSuccess` and `QueryFailed` are also generated during automatic provider refresh, so those may be emitted for `QueryId`s not known to the client code.

## Added

- kademlia: Track success of `ADD_PROVIDER` queries ([#432](https://github.com/paritytech/litep2p/pull/432))
- kademlia: Workaround for dealing with not implemented `PUT_VALUE` ACKs ([#430](https://github.com/paritytech/litep2p/pull/430))
- kademlia: Track success of `PUT_VALUE` queries ([#427](https://github.com/paritytech/litep2p/pull/427))

## Fixed

- Identify: gracefully close substream after sending payload ([#466](https://github.com/paritytech/litep2p/pull/466))
- fix: transport context polling order ([#456](https://github.com/paritytech/litep2p/pull/456))

## Changed

- refactor: implement builder pattern for TransportManager ([#453](https://github.com/paritytech/litep2p/pull/453))
