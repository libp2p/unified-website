+++
title = "Announcing the release of js-libp2p v3.0.0"
description = "An overview of changes and updates in the v3 release"
date = 2025-09-30
slug = "2025-09-30-js-libp2p"

[taxonomies]
tags = ["browser", "transport", "webrtc", "js-libp2p"]

[extra]
author = "Alex Potsides"
header_image = "/img/blog/js-libp2p-v1-header.png"
version = "v3.0.0"
implementation = "js"
breaking = true
security = false
github_release = "https://github.com/libp2p/js-libp2p/releases/tag/libp2p-v3.0.0"
+++
`libp2p@3.x.x` has just shipped, representing our once-yearly roll-up of breaking changes.

Let's find out what's changed and why, and how you can upgrade your project to the latest and greatest.

## What's new?

### Streams as EventTargets

Prior to v3, streams were streaming iterables. This convention has not been adopted outside the libp2p project, which raises the bar for new developers, and leans heavily on promises which can introduce surprising latency to simple operations.

As of v3, streams have become EventTargets. These follow a familiar pattern where you attach event listeners for incoming message events and write data synchronously.

```ts
import { createLibp2p } from 'libp2p'
import { peerIdFromString } from '@libp2p/peer-id'

const node = await createLibp2p()
const peer = peerIdFromString('123Foo...')
const stream = await node.dialProtocol(peer, '/my-protocol/1.0.0', {
  signal: AbortSignal.timeout(5_000)
})

// register a listener for incoming data
stream.addEventListener('message', (evt) => {
  console.info(new TextDecoder().decode(evt.data.subarray()))
})

// send some data
stream.send(new TextEncoder().encode('hello world'))
```

Synchronous streams have shown a small increase in throughput and more predictable behavior.

### Write back pressure

Streams can apply back pressure by their `.send()` method returning false. Once this returns false, the sender should wait for a `'drain'` event before continuing:

```ts
for (const buf of bufs) {
  if (!stream.send(buf)) {
    await pEvent(stream, 'drain', {
      rejectionEvents: ['close']
    })
  }
}
```

### Other improvements

- Better TypeScript types
- Improved error handling
- Performance optimizations

Check out the [migration guide](https://github.com/libp2p/js-libp2p/blob/main/UPGRADING.md) for detailed upgrade instructions.
