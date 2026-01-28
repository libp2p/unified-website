+++
title = "Adding a QUIC API for Go's standard library TLS package"
description = "How we worked with the Go team to add QUIC support to crypto/tls"
date = 2023-09-13
slug = "2023-09-13-quic-crypto-tls"

[taxonomies]
tags = ["quic", "go", "standard library", "crypto/tls"]

[extra]
author = "Marten Seemann"
header_image = "/img/blog/crypto_tls_header.png"
+++
QUIC is becoming the most important transport in libp2p. For example, QUIC accounts for 80-90% of the connections made to PL-run bootstrappers participating in the public IPFS DHT.

[quic-go](https://github.com/quic-go/quic-go) is a QUIC implementation written in pure Go that is used in go-libp2p, Caddy, Adguard, syncthing, and many other projects.

## QUIC and TLS 1.3

All QUIC connections use TLS 1.3 to encrypt messages. However, due to running on top of UDP, QUIC's interactions with the TLS stack differs from how TLS over TCP functions.

When QUIC was standardized, it became necessary for TLS stacks to expose new APIs. For the longest time, Go's crypto/tls lacked an API for this purpose. The quic-go project had to fork crypto/tls to add the required APIs.

This meant:
- Extra effort every time a new Go version was released
- Security fixes in crypto/tls required updating quic-go
- Lack of forwards-compatibility with future Go versions

## Solving the Problem

To tackle this situation, we joined forces with Filippo Valsorda, who maintains crypto/tls. Filippo is sponsored by Protocol Labs for his remarkable open-source work.

Our first joint endeavor established an API for crypto/tls that enables QUIC implementations to use it. After long discussions, we arrived at a much cleaner proposal than our homegrown qtls API.

## 0-RTT Support

0-RTT allows clients to resume connections and send encrypted data in the first packet. Adding support for 0-RTT was a large endeavor requiring coordination between the TLS and QUIC stacks.

The server typically encrypts transport parameters and stores them in the session ticket. When the client restores the session, it sends the session ticket allowing the server to restore parameters without persisting them.

## Current Status

After an intense period of collaboration, we are thrilled to have all these changes included in Go 1.21. The implementation was performed by Damien Neil and Filippo Valsorda.

The changes have been released in quic-go v0.37 and go-libp2p v0.30. We anticipate that these changes will work seamlessly once users update their dependencies and compiler version.
