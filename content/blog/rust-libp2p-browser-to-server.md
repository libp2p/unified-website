+++
title = "rust-libp2p in the Browser with WebRTC!"
description = "News about how rust-libp2p in the browser connects to nodes in a network using WebRTC"
date = 2024-02-21
slug = "rust-libp2p-browser-webrtc"
aliases = ["/rust-libp2p-browser-webrtc"]

[taxonomies]
tags = ["rust-libp2p", "rust", "libp2p", "browser", "webrtc", "webassembly", "wasm"]

[extra]
author = "DougAnderson444"
header_image = "/img/blog/rust-libp2p.jpeg"
+++
We are excited to announce that rust-libp2p running in the browser can now establish WebRTC connections. Before now, WebRTC was only available on the server in rust-libp2p, but after months of coding and reviews, it is available on both the server and in the browser.

## Why WebRTC for rust-libp2p?

### Easier node operation

Modern browsers require served connections to use TLS. In the case of WebSockets, certificates need to be signed by a Certificate Authority, meaning you need to set up DNS and Let's Encrypt. These steps create a barrier to entry.

With WebRTC, we can use self-signed certificates, removing the need for domain names and trusted Certificate Authorities!

Imagine being able to write a web app in Rust that connects to a Rust node running on your desktop at home, without having to set up DNS, Let's Encrypt, or any external server infrastructure!

### Improved connectivity

WebRTC also allows connecting two browsers directly. With the ease of setting up a libp2p WebRTC server, anyone can set up their own signalling server or use one embedded into a Rust application!

## Benefits of Full Stack rust-libp2p

Now that we have rust-libp2p over WebRTC on both server and browser, we can share code between the two layers! Writing isomorphic code speeds up development and makes reviews and debugging easier.

## How does libp2p use WebRTC?

### Data Channels

WebRTC's flagship purpose is connecting media (audio and video). However, there is also a powerful data channel API which allows exchanging data streams. This is what libp2p uses at the transport layer.

### Breaking down the stack

- The browser provides WebRTC through the Web API
- `wasm-bindgen` provides bindings through `web-sys`
- rust-libp2p wraps these bindings to implement a WebRTC Transport
- This Transport is available for applications (Kademlia, Gossipsub, etc.)
- Finally, Rust code is compiled to WebAssembly and runs in the browser

## Demo

There is a full stack example [in the repo](https://github.com/libp2p/rust-libp2p/tree/master/examples/browser-webrtc) that runs a local server, compiles browser code to WebAssembly, and demonstrates pinging back and forth.

## What's next?

Now that we have browser to server connections, the next step is browser to browser connections using the WebRTC circuit relay pattern. Stay tuned for updates!
