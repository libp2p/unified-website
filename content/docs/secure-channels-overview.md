+++
title = "What are Secure Channels"
description = "Before two peers can transmit data, the communication channel they established with a transport protocol should be secure. Learn about secure channels in libp2p."
weight = 30
aliases = ["/concepts/secure-comm", "/guides/secure-channels-overview/"]

[extra]
toc = true
category = "secure channels"
+++

## Overview

Before two peers can transmit data, the communication channel they
establish needs to be secured. By design,
libp2p supports many different transports (TCP, QUIC, WebSocket, WebTransport,
etc.). Some transports have built-in encryption at the transport layer
like [QUIC](/docs/quic/), while other transports (e.g. TCP, WebSocket)
lack native security and require a security handshake after the transport connection has been
established.

## Secure channels in libp2p

libp2p specifies two security protocols, [TLS 1.3](/docs/tls/) and [Noise](/docs/noise/).
After the handshake has finished, we need to negotiate a
[stream multiplexer](/docs/multiplexing-overview/) for the connection.
