+++
title = "One UDP Port, Two Event Loops, No Signaling: WebRTC-Direct Lands in py-libp2p"
description = "How WebRTC-Direct landed in py-libp2p across 11 PRs: bridging trio and asyncio, sharing one UDP port, inferring offers from STUN, and passing go-libp2p interop."
date = 2026-09-07
slug = "py-libp2p-webrtc-direct"

[taxonomies]
tags = ["py-libp2p", "webrtc", "transport", "browser", "interoperability"]

[extra]
author = "Yash Kumar Saini"
header_image = "/img/blog/py-libp2p-webrtc-direct/banner.png"
source_repo = "libp2p/py-libp2p"
source_prs = ["https://github.com/libp2p/py-libp2p/pull/1309", "https://github.com/libp2p/py-libp2p/pull/1395", "https://github.com/libp2p/py-libp2p/pull/1396", "https://github.com/libp2p/py-libp2p/pull/1397", "https://github.com/libp2p/py-libp2p/pull/1446", "https://github.com/libp2p/py-libp2p/pull/1447", "https://github.com/libp2p/py-libp2p/pull/1448", "https://github.com/libp2p/py-libp2p/pull/1449", "https://github.com/libp2p/py-libp2p/pull/1459", "https://github.com/libp2p/py-libp2p/pull/1471", "https://github.com/libp2p/py-libp2p/pull/1495"]
+++
My first WebRTC pull request to py-libp2p merged on 28 June 2026. It was 6,698 lines across 54 files, it had 153 passing tests, and it could not accept a single connection. The listener's inbound path ended in `lambda: None  # placeholder — full wiring in follow-up`. Ten PRs later, on 7 September, a go-libp2p node dialed a Python node over `/webrtc-direct` on one shared UDP port, in both versions of the protocol, and CI checked it on every push.

Three problems sat between those two dates. The Python WebRTC library runs on asyncio and py-libp2p runs on trio. The library opens one UDP socket per connection and the protocol wants one port for everybody. And WebRTC-Direct has no signaling server, so the listener has to rebuild the dialer's offer from a single STUN packet. A fourth problem arrived uninvited: everything worked when Python talked to Python, and nothing worked when Go called.

## WebRTC-Direct in Two Paragraphs

libp2p is a networking stack for peer-to-peer applications. Every node has a **peer ID** derived from its public key, every address is a self-describing **multiaddr**, and transports (TCP, QUIC, WebSocket) plug in underneath. Browsers are the awkward peer: they cannot open raw sockets, and they will only speak TLS to a server with a CA-signed certificate. WebRTC is the exception. A browser will open a WebRTC connection to a server that has no domain name and only a self-signed certificate.

Ordinary WebRTC needs a **signaling** channel to swap SDP offers and answers before any packet flows. WebRTC-Direct removes it. The listener's multiaddr, `/ip4/<ip>/udp/<port>/webrtc-direct/certhash/<hash>/p2p/<peer-id>`, already carries its address and the hash of its DTLS certificate, so the dialer builds the listener's answer locally. The listener never receives an offer. It infers one from the dialer's first **STUN** connectivity check, whose `USERNAME` attribute is `server_ufrag:client_ufrag` (the ICE username fragments of both sides). DTLS then encrypts the path, but the listener cannot verify a certificate it has never seen. So a **Noise XX** handshake runs over data channel 0, with both DTLS fingerprints mixed into its prologue, and that is what authenticates the two peer IDs. After that, every libp2p stream is its own data channel.

*The WebRTC-Direct handshake. There is no signaling round trip; the listener learns everything it needs from the first STUN packet, and Noise authenticates what DTLS cannot.*

![Webrtc direct handshake](/img/blog/py-libp2p-webrtc-direct/diagram-01-webrtc-direct-handshake.png)

In Python the WebRTC stack is [aiortc](https://github.com/aiortc/aiortc), with [aioice](https://github.com/aiortc/aioice) doing ICE underneath. Both are asyncio libraries. py-libp2p is built on trio.

## A Scaffold That Could Not Accept a Connection

[PR #1309](https://github.com/libp2p/py-libp2p/pull/1309) was open for 76 days and grew to 43 commits. I wrote it from scratch after studying @Nkovaturient's earlier attempts in #557 and #780. It brought the package skeleton: transport, listener, connection and stream classes, certificate and fingerprint encoding, SDP helpers, protobuf framing, the Noise prologue and the trio-to-asyncio bridge.

The first Copilot pass left 22 findings. The serious one was that `dial()` returned a `WebRTCConnection` without ever creating an `RTCPeerConnection`, so the swarm would treat a dead object as a live peer. I replaced it with a `NotImplementedError`. @acul71 then caught a regression I had introduced in the swarm itself: a copied `except Exception: raise` made native-muxing transports skip the `SwarmException` wrapping and broke an existing test.

My own later audit found three more. Data-channel messages went out as bare protobuf with no length prefix. Application channels were created with `negotiated=True`, which never fires the peer's `datachannel` event, so `accept_stream()` blocked forever. And pinning the DTLS certificate with `pc._certificates = [...]` was a silent no-op, because aiortc stores it in a name-mangled slot, `pc._RTCPeerConnection__certificates`. Without that fix the advertised `/certhash/` would not have matched the certificate actually used.

The decision that shaped everything after came from a question. My listener exchanged SDP over a small HTTP `POST /sdp` server. I asked whether to wire the inbound path onto it. The answer:

> Do not invest further in the HTTP inbound path.
> — @acul71, review of PR #1309

No go-libp2p or js-libp2p dialer would ever speak to an HTTP endpoint. The PR merged as "experimental v1 node-to-node scaffolding", with follow-up issues for everything it lacked.

## Problem One: Two Event Loops

You cannot `await` an asyncio coroutine from trio. The bridge runs one asyncio loop on a background daemon thread, shared by every connection of a transport. Trio code hands it a coroutine and waits in a worker thread:

```python
        future = asyncio.run_coroutine_threadsafe(coro, loop)

        def _wait_for_result() -> T:
            return future.result()

        try:
            # abandon_on_cancel=True lets trio cancel the scope immediately.
            # The background thread is abandoned but we cancel the asyncio
            # future below so it doesn't leak.  The keyword is supported at
            # runtime by trio>=0.22 even though the stubs don't declare it.
            return await trio.to_thread.run_sync(  # type: ignore[call-arg]
                _wait_for_result, abandon_on_cancel=True
            )
        except trio.Cancelled:
            # Trio scope was cancelled — propagate to the asyncio side
            future.cancel()
            raise
```

That is the easy direction. The bugs were in the other one. aiortc fires its callbacks on the asyncio thread, and trio primitives are not thread-safe. Copilot flagged `on_data()` calling `MemorySendChannel.send_nowait` straight from the bridge thread. The fix was to capture a trio token at construction and route every mutation through `trio.from_thread.run_sync(..., trio_token=...)`. The same round of fixes removed a deadlock: a send path ran a trio-facing callback on the asyncio thread, and that callback waited on a future scheduled on the very thread it was blocking.

The subtle case came in [PR #1447](https://github.com/libp2p/py-libp2p/pull/1447), which finally wired the inbound path. Once ICE and DTLS finish on the asyncio side, the Noise handshake has to run on trio. But Noise reads from data channel 0, and those messages are delivered by the asyncio loop. A blocking hop would starve the handshake of its own input. So the hop only schedules a task and returns:

```python
            trio.from_thread.run_sync(
                nursery.start_soon,
                self._finish_inbound,
                pc,
                bridge,
                dialer_fp,
                noise_send,
                noise_recv,
                trio_token=token,
            )
```

*The threading model. aiortc, aioice and the shared socket live on one asyncio thread; Noise and the connection handler run on trio; the bridge is the only crossing point.*

![Webrtc two event loops](/img/blog/py-libp2p-webrtc-direct/diagram-02-webrtc-two-event-loops.png)

The same PR fixed three other things the scaffold had wrong. `get_remote_fingerprint` read `pc._dtlsTransport._remote_certificate`, which aiortc does not have, so `dial()` could never succeed. The Noise roles were inverted: the spec makes the listener the Noise initiator. And `PatternXX.handshake_outbound` gained `remote_peer=None`, because a listener that initiates cannot know the dialer's peer ID in advance. It also added the first transport-level test that dials, listens, opens a stream and echoes.

## Problem Two: One Port, Many Peers

Before the scaffold merged, @acul71 asked for a spike: could aiortc do what a spec-aligned listener needs? I wrote it up in [issue #1352](https://github.com/libp2p/py-libp2p/issues/1352). Two of the three capabilities were reachable. The third was not:

> **Verdict: NOT supported; architecturally absent from both aiortc and aioice.**
> — my spike findings, Issue #1352

aioice binds a fresh ephemeral socket for every `Connection`. A listener built on it would hand each dialer a different port, and a multiaddr can only advertise one. My write-up recommended adding a mux to aioice upstream and estimated two to three weeks.

What I built instead is an in-tree `UdpMux` ([PR #1397](https://github.com/libp2p/py-libp2p/pull/1397)). It is a single `asyncio.DatagramProtocol` that owns the one socket and hands each `aioice.Connection` a fake transport backed by it. The routing rule fits in one method:

```python
    def datagram_received(self, data: bytes, addr: tuple[str, int]) -> None:
        norm: tuple[str, int] = (addr[0], addr[1])
        try:
            msg = _stun.parse_message(data)
            username: str = msg.attributes.get("USERNAME", "")
            ufrag = username.split(":")[0]
            protocol = self._by_ufrag.get(ufrag)
            if protocol is not None:
                protocol.datagram_received(data, norm)
                return
            # First contact: an inbound BINDING REQUEST for an unregistered
            # ufrag. A WebRTC-Direct listener registers a handler to create the
            # connection (add_ice_connection) and replay this datagram.
            if self._unknown_stun_handler is not None:
                self._unknown_stun_handler(ufrag, data, norm)
                return
```

Before ICE completes, packets are STUN and route by the `USERNAME` ufrag. After it, they are DTLS and SCTP: parsing fails, and they route by source address. The first-contact branch exists because of review. My first version logged and dropped STUN for an unknown ufrag, and @acul71 pointed out the chicken-and-egg: the listener cannot register a ufrag it has not seen, and it only sees it in the packet it just dropped.

This PR also sat. I opened it on 10 July as #1381, with two small siblings. On 19 July I recreated my fork and GitHub auto-closed all three. They came back the same day as #1395, #1396 and #1397 with identical diffs, and merged on 14 August.

### Making aiortc use a socket it did not open

aiortc builds its own `aioice.Connection` and offers no way to inject another. [PR #1448](https://github.com/libp2p/py-libp2p/pull/1448) swaps it out by hand:

```python
    set_private_attr(ice.iceGatherer, "_connection", conn)
    set_private_attr(ice, "_connection", conn)
    set_private_attr(ice, "_recv", conn.recv)
    set_private_attr(ice, "_send", conn.send)
```

The last two lines are the ones that matter. aiortc captures `_recv` and `_send` when the ICE transport is constructed, bound to the original connection. Replace only `_connection` and DTLS keeps talking to the orphan. The bridge module's first docstring had promised "No monkey-patching — aiortc's public API only." The dependency is now pinned (`aiortc>=1.15,<2.0`) and covered by loopback tests so a breaking upgrade fails loudly.

Driving the mux with a real peer also surfaced two Windows-only failures. One was a hang in the proactor loop's `close()`. The other was `WSAECONNRESET`: Windows reports an ICMP port-unreachable for one peer as an error on the shared socket's next receive, and the mux went deaf to every other peer. A `SIO_UDP_CONNRESET` ioctl turns that off.

### The listener

[PR #1449](https://github.com/libp2p/py-libp2p/pull/1449) is where it comes together. On a first contact the listener rate-limits, parses the `USERNAME`, rejects any unknown version prefix, registers a mux-backed connection, replays the packet into it, and infers the dialer's offer. In v1 the dialer sets its ufrag and password to the same `libp2p+webrtc+v1/<random>` string, so the username alone gives the listener the credentials.

*How one UDP socket serves many peers. STUN routes by ufrag, everything else by source address, and an unknown ufrag is the start of a new inbound dial.*

![Webrtc udp mux dispatch](/img/blog/py-libp2p-webrtc-direct/diagram-03-webrtc-udp-mux-dispatch.png)

Review found a real regression. My spec-path `dial()` passed the default ICE servers, which meant every dial contacted `stun.l.google.com` for candidates that never reach a STUN listener. I believed I had already reverted that. The edit had not applied, and the tests could not tell because their helper passed `ice_servers=[]`. The rate limiter also came from review. My in-flight cap only bounded connections after parsing. The merged version is a per-source-IP token bucket (burst 8, 4 per second, 4,096 tracked sources) that runs before any parsing or allocation.

### The two-line PR that made the rest count

[PR #1446](https://github.com/libp2p/py-libp2p/pull/1446) is the smallest of the eleven:

```diff
     uv pip install --upgrade pip
-    uv pip install --group dev -e .
+    uv pip install --group dev -e ".[webrtc]"
```

aiortc is an optional extra. tox never installed it, so every test in `tests/core/transport/webrtc/` was being skipped in CI. Green meant untested. I put this at the bottom of the stack so the three PRs above it had to prove themselves. All four were opened within 27 minutes on 16 August and landed together on 28 August.

## Version Two: The Same Address Without the Trick

Version 1 depends on the dialer overwriting its own ICE credentials, a practice called SDP munging. Chrome is removing the ability to do that, behind a field trial named `WebRTC-NoSdpMangleUfrag`. @seetadev raised it during the scaffold review, which is why that PR was scoped node-to-node only.

Version 2 ([libp2p/specs#715](https://github.com/libp2p/specs/pull/715), by @dozyio) keeps the same multiaddr and moves the trick. The dialer leaves its own credentials alone. It tells the listener its password by encoding it in the *listener's* ufrag: `libp2p+webrtc+v2/<client_pwd>`. On the listener, the difference between the versions is one line in `parse_direct_username`:

```python
            client_pwd = client_ufrag if version == 1 else server_ufrag[len(prefix) :]
```

*Version dispatch on first contact. v1 and v2 share one listener and one port; only the place the dialer's ICE password is recovered from differs.*

![Webrtc v1 vs v2 credentials](/img/blog/py-libp2p-webrtc-direct/diagram-04-webrtc-v1-vs-v2-credentials.png)

[PR #1459](https://github.com/libp2p/py-libp2p/pull/1459) made the listener accept both versions and added an opt-in `webrtc_direct_dial_version=2` for the dialer. The default stayed at 1 because the spec PR was still open; it merged eight days later, on 11 September.

## Problem Three: go-libp2p Disagreed

Every test so far was Python dialing Python. When I ran the v1 code against go-libp2p v0.49.0, the connection died at the first Noise message. Three separate bugs were waiting, and none of them can show up in a loopback test, because both ends share the same wrong assumption.

**Framing.** My decoder expected one complete length-prefixed frame per SCTP message. go-libp2p writes the varint prefix and the body as two writes, which arrive as two messages. Python failed with `malformed handshake frame length`. The fix decodes frames from an accumulating byte buffer.

**Stream-ID parity.** RFC 8832 says the DTLS client opens even SCTP stream IDs and the server odd ones. aiortc seeds its allocator from the ICE role instead. A WebRTC-Direct listener is ICE-controlled but the DTLS server, so the parity came out inverted and collided with go's IDs. The fix is one re-seed before each channel is created:

```python
            set_private_attr(sctp, "_data_channel_id", 0 if role == "client" else 1)
```

Both fixes were PR #1460, which was never merged. It was reviewed, I addressed the requested changes (a hard `assert` in a live connection path became a warning with a fallback), and then it was closed as superseded because #1459 already contained its commits.

**The stall.** In those two PR descriptions I wrote that go → py connected in my live runs. Then I turned the manual run into a real test, [PR #1471](https://github.com/libp2p/py-libp2p/pull/1471): a pinned go-libp2p v0.49 harness that listens or dials, built on demand under a file lock and skipped when Go is missing. py → go passed for v1 and v2. go → py failed for both. I filed [issue #1470](https://github.com/libp2p/py-libp2p/issues/1470) and shipped the failing direction as `xfail(strict=True)`, so the suite would complain the moment it started passing. Review caught the #1446 mistake a second time: Go was not installed in CI, so the new tests would have skipped there. An `actions/setup-go` step fixed that.

The py listener's log showed one ICE candidate pair reaching `SUCCEEDED` and then nothing until the handshake timeout. I added logging inside aioice's `check_start` and ran the go harness again. The crashing call had no remote username and no remote password, about a millisecond before aiortc set them.

*The go → py stall. A connectivity check for a second candidate ran before the remote ICE credentials existed, crashed silently, and stranded the exact pair the dialer later nominated.*

![Webrtc go dial race](/img/blog/py-libp2p-webrtc-direct/diagram-05-webrtc-go-dial-race.png)

A full ICE agent like go-libp2p sends checks from every host candidate the instant it starts. aiortc only sets the remote credentials when it processes the inferred offer, slightly later. A check for a second candidate landed in that gap, hit `remote_password=None`, and raised `AttributeError` inside a fire-and-forget task that nothing was waiting on. That pair stayed `IN_PROGRESS` and was never retried. When go nominated exactly that pair, the listener had no succeeded pair to match, ICE never completed and DTLS never started. A window that small may also be why my earlier manual runs passed; I cannot prove that from the record.

The listener builds the inferred offer, so it already knows the credentials. [PR #1495](https://github.com/libp2p/py-libp2p/pull/1495) sets them before replaying the first packet:

```diff
+        conn.remote_username = client_ufrag
+        conn.remote_password = client_pwd
+
         self._in_flight += 1
```

The same diff deletes the `xfail` marker. The PR was opened at 07:51 UTC on 7 September and merged at 09:33. All four combinations, py ↔ go in v1 and v2, now run as real assertions.

## The Eleven PRs at a Glance

*The landing order. Six merge events carried eleven PRs; one PR in the chain was closed and absorbed rather than merged.*

![Webrtc pr stack](/img/blog/py-libp2p-webrtc-direct/diagram-06-webrtc-pr-stack.png)

| PR | What it did | Opened | Merged | Size |
|---|---|---|---|---|
| #1309 | Transport scaffolding, bridge, framing | 13 Apr | 28 Jun | +6698 / −36 |
| #1395 | Delete the package's private varint copy | 19 Jul | 14 Aug | +42 / −81 |
| #1396 | Bound the `/sdp` HTTP harness | 19 Jul | 14 Aug | +275 / −6 |
| #1397 | `UdpMux` shared-port dispatcher | 19 Jul | 14 Aug | +688 / −0 |
| #1446 | Install the `webrtc` extra in CI | 16 Aug | 28 Aug | +2 / −1 |
| #1447 | Wire the inbound path, spec Noise roles | 16 Aug | 28 Aug | +772 / −155 |
| #1448 | Run aiortc over `UdpMux` | 16 Aug | 28 Aug | +1292 / −195 |
| #1449 | STUN-dispatch listener and v1 dialer | 16 Aug | 28 Aug | +2268 / −270 |
| #1459 | v2 flow, plus the folded #1460 fixes | 28 Aug | 3 Sep | +802 / −205 |
| #1471 | go-libp2p interop tests | 3 Sep | 6 Sep | +662 / −5 |
| #1495 | Complete go → py inbound dials | 7 Sep | 7 Sep | +15 / −5 |

Two small ones deserve a note. #1396 capped the HTTP harness at a 32 KiB body, 64 header lines and 8 KiB of headers; before it, a `Content-Length: 2147483647` header made the server try to buffer about 2 GiB. #1395 was meant to be a pure refactor, and review showed it was not: the shared decoder returns `(0, 0)` for an empty prefix where my deleted copy raised.

## Lessons Learned

**1. A suite that skips is not a suite that passes.**
Optional dependencies make tests vanish quietly. It happened with aiortc in tox and again with Go in the interop job. Check the skip count, not only the colour.

**2. Loopback tests verify agreement, not correctness.**
Two copies of the same code agree about framing, stream-ID parity and timing. All three were wrong against another implementation. The first test against a foreign peer is worth more than the hundredth against yourself.

**3. Ask the architecture question before building on a harness.**
Wiring Noise onto the HTTP `/sdp` listener would have produced a transport nobody else could dial. One question in review moved everything that followed onto the STUN path.

**4. A strict xfail is a promise with a deadline.**
Shipping the failing direction as `xfail(strict=True)` put the bug in CI before the fix existed. The fix then needed no argument: fifteen added lines, one marker deleted, merged in under two hours.

## Can I Use It Now?

Yes, between Python and Go nodes. The transport is an optional extra, because aiortc is not a dependency of the core library:

```bash
pip install "libp2p[webrtc]"
```

A py-libp2p listener accepts both protocol versions on the same port without configuration. The dialer picks one with `WebRTCTransportConfig(webrtc_direct_dial_version=1)` or `2`. Version 1 is the default today, for compatibility with go and js dialers that still start there. Version 2 is the one to prefer for new deployments, and the one browsers will need once Chrome's change is everywhere. The experimental HTTP `/sdp` harness is off by default and only ever worked Python to Python; leave it off.

## What Is Still Not Done

When #1495 merged, the listener was still a full ICE agent in the controlled role rather than the ICE-Lite agent the spec describes. That landed afterwards in #1532, and the README guidance on v1 versus v2 in #1513. The scaffold shipped in v0.7.0 and the STUN listener in v0.8.0.

Browser interop was out of scope for all eleven PRs. js-libp2p's v2 support merged in October, and a py ↔ js interop harness is open as #1605 at the time of writing. There is no rust-libp2p WebRTC test. The dialer still defaults to v1. The relay-signaled `/webrtc` transport is still a skeleton whose `dial()` raises `NotImplementedError`. And `UdpMux` still lives in py-libp2p, not upstream in aioice where my own spike said it belonged.

## Conclusion

None of the three planned problems was the one that took longest to see. The bridge, the mux and the inferred offer all worked against my own dialer. The transport became real on the day a Go process dialed it and failed, and two lines later that failure was a passing test.

## Acknowledgements

- **@acul71** reviewed and merged all eleven PRs, redirected the listener onto the STUN path, pushed his own round-3 commit onto #1449 and fixed a 45-second wait in my interop harness.
- **@seetadev** flagged the Chrome change and the v2 spec work while the scaffold was still in review.
- **@dozyio** wrote the WebRTC-Direct v2 spec and its js-libp2p reference implementation.
- **@Nkovaturient** explored WebRTC for py-libp2p first, in #557 and #780.

## Resources

1. [Issue #546 — Add Support for WebRTC in py-libp2p](https://github.com/libp2p/py-libp2p/issues/546)
2. [Issue #1437 — WebRTC-Direct STUN listener tracker](https://github.com/libp2p/py-libp2p/issues/1437)
3. [Issue #1352 — Spike: aiortc ICE mux and STUN USERNAME exposure](https://github.com/libp2p/py-libp2p/issues/1352)
4. [Issue #1470 — go-libp2p dialer cannot connect to the py listener](https://github.com/libp2p/py-libp2p/issues/1470)
5. [libp2p WebRTC-Direct specification](https://github.com/libp2p/specs/blob/master/webrtc/webrtc-direct.md)
6. [libp2p/specs#715 — WebRTC-Direct v2](https://github.com/libp2p/specs/pull/715)
7. [RFC 8832 — WebRTC Data Channel Establishment Protocol](https://www.rfc-editor.org/rfc/rfc8832)

Related on libp2p.io: [WebRTC](@/docs/webrtc.md), [Browser Node Connectivity](@/docs/browser-connectivity.md), [WebRTC (Browser-to-Server) in libp2p](@/blog/libp2p-webrtc-browser-to-server.md), [Bridging the Gap](@/blog/py-libp2p-websocket-transport.md).

If you would like to contribute, please [connect with the libp2p maintainers](@/get-involved/_index.md).
