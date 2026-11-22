+++
title = "From 0.0.0.0 to Dynamic Discovery: How py-libp2p Migrated 17 Examples Away From the Wildcard Trap"
description = "Migrating 17 py-libp2p examples off the 0.0.0.0 wildcard bind to dynamic interface discovery, without breaking multi-machine demos."
date = 2025-09-22
slug = "py-libp2p-wildcard-bind-migration"

[taxonomies]
tags = ["py-libp2p", "security", "multiaddr"]

[extra]
author = "Yash Kumar Saini"
header_image = "/img/blog/py-libp2p-wildcard-bind-migration/banner.png"
source_repo = "libp2p/py-libp2p"
source_prs = ["https://github.com/libp2p/py-libp2p/pull/892"]
+++
## A Wildcard on Every Interface

Picture this: a contributor copies `ping.py` from py-libp2p's examples directory. They deploy it on a shared development server to test peer-to-peer connectivity. Everything works — peers connect, pings round-trip in milliseconds. What they don't notice is a single line buried in the setup code:

```python
listen_addr = multiaddr.Multiaddr(f"/ip4/0.0.0.0/tcp/{port}")
```

That `0.0.0.0` means the service is listening on *every* network interface — the LAN, the VPN, the Docker bridge, the campus Wi-Fi. Anyone on any of those networks can connect. This isn't a hypothetical risk. In September 2024, CVE-2024-47176 in the cups-browsed print service — which bound to `INADDR_ANY` on UDP port 631 — enabled a full remote code execution chain scoring CVSS 9.9. The pattern is so common it has its own classification: CWE-1327, "Binding to an Unrestricted IP Address."

PR #892 eliminated this pattern from py-libp2p's entire example suite — 17 files, one consistent migration, zero wildcards in the default path — and shipped guard tests to make sure it stays that way.

## Background: The System Before

**py-libp2p** is the Python implementation of libp2p, the modular peer-to-peer networking framework that powers IPFS and Filecoin. Addresses in libp2p use the **multiaddr** format — self-describing strings like `/ip4/192.168.1.5/tcp/8080/p2p/QmPeerID` that encode transport, network, and identity in a single value.

A previous PR (#811) had introduced py-libp2p's address validation toolkit: a set of functions in `libp2p/utils/address_validation.py` that could discover available network interfaces, expand wildcard addresses to concrete IPs, and pick an optimal binding address. But PR #811 only wired this toolkit into the echo example. The remaining 17 examples — ping, chat, pubsub, identify, bootstrap, kademlia, mDNS, random walk, QUIC echo, 10 documentation examples, and the network discovery demo — still constructed their own addresses by hand.

The gap was visible in the output. Running `echo-demo` on a machine with multiple interfaces showed:

```
Listener ready, listening on:

/ip4/192.168.1.17/tcp/43857/p2p/16Uiu2HAm...
/ip4/10.156.233.51/tcp/43857/p2p/16Uiu2HAm...
/ip4/127.0.0.1/tcp/43857/p2p/16Uiu2HAm...
```

Running `ping-demo` showed:

```
Run this from the same folder in another console:

ping-demo -d /ip4/0.0.0.0/tcp/42547/p2p/QmRShbR5...
```

One example knew its real addresses. Seventeen others advertised a wildcard.

{{<img src="img/blog/py-libp2p-wildcard-bind-migration/diagram-01-migration-landscape.png" alt="Migration landscape" />}}

*Before PR #892: only echo.py used the address validation module. All other examples hardcoded `0.0.0.0` for binding.*

For context, libp2p implementations handle this differently across languages. **go-libp2p** defaults to `/ip4/0.0.0.0/tcp/0` (wildcard, like the old py-libp2p examples). **js-libp2p** defaults to `/ip4/127.0.0.1/tcp/0` (localhost only). py-libp2p's new approach — dynamic interface discovery — is actually more sophisticated than either.

## The Problem: Symptoms, Root Cause, Impact

The core issue is deceptively simple: `0.0.0.0` tells the OS to bind to all network interfaces. The MITRE CWE database classifies this as **CWE-1327: Binding to an Unrestricted IP Address**:

> When a server binds to the address 0.0.0.0, it allows connections from every IP address on the local machine, effectively exposing the server to every possible network.

This isn't an abstract concern. Real-world vulnerabilities with this exact root cause include:

- **CVE-2024-47176** (cups-browsed): Bound UDP 631 to `INADDR_ANY`, enabling remote code execution. CVSS 9.9.
- **OpenTelemetry Collector** (Issue #6151): OTLP receiver defaults of `0.0.0.0:4317` flagged as CWE-1327.
- **TensorBoard** (Issue #2513): Changed default `--host` from `0.0.0.0` to `localhost` after security review.

In py-libp2p's case, the wildcard problem was amplified by two factors:

**Examples get copied.** Documentation examples are effectively an API — developers copy-paste them into their own projects. Every `0.0.0.0` in an example becomes a `0.0.0.0` in someone's production code.

**Inconsistency breeds confusion.** With echo using dynamic discovery and everything else using hardcoded wildcards, contributors had no clear signal about which pattern to follow. The path of least resistance was copying the broken pattern from the majority of examples.

## Investigation: How We Found It

[Issue #885](https://github.com/libp2p/py-libp2p/issues/885) documented the gap systematically. After PR #811 landed the address validation toolkit and migrated echo, I audited the rest of the codebase and found the wildcard pattern in every corner:

- **Core examples** (6 files): `ping.py`, `chat.py`, `bootstrap.py`, `mDNS.py`, `pubsub.py`, `random_walk.py`
- **Identify examples** (3 files): `identify.py`, `identify_push_demo.py`, `identify_push_listener_dialer.py`
- **Documentation examples** (10 files): encryption (insecure, noise, secio), transport, multiplexer, running, net stream, peer discovery, QUIC transport, multiple connections
- **Advanced** (1 file): `network_discover.py`
- **QUIC** (1 file): `echo_quic.py`

The issue also flagged the documentation `.rst` files that showed `0.0.0.0` addresses in example output, further normalizing the pattern for readers.

## The Approach: Design Options Considered

My first attempt at fixing this was straightforward: find `0.0.0.0`, replace with `127.0.0.1`. Commit `87550113` did exactly this across 18 files. Reviewer @acul71 immediately rejected the approach:

> All examples became localhost-only, breaking network accessibility.

{{<img src="img/blog/py-libp2p-wildcard-bind-migration/diagram-02-naive-vs-correct-fix.png" alt="Naive vs correct fix" />}}

*Replacing `0.0.0.0` with `127.0.0.1` fixes the security issue but breaks network connectivity. Dynamic interface discovery solves both problems.*

The problem: `127.0.0.1` only accepts connections from the local machine. For a peer-to-peer networking library, that defeats the purpose. You can't demonstrate peer discovery, gossipsub fanout, or DHT routing when peers can't reach each other across a LAN.

The correct approach — the one @acul71 demanded — was the **dynamic interface discovery paradigm** established in PR #811. Instead of binding to a single address (wildcard or loopback), discover all real interfaces on the machine and bind to each one. Display the optimal address for client connections. Provide wildcard binding as an explicit opt-in for the rare cases that need it.

## The Solution: Architecture and Implementation

The migration followed a three-layer pattern: **discover, bind, advertise**.

**Layer 1: Discover.** Each example calls `get_available_interfaces(port)`, which uses the multiaddr library's thin waist utilities to enumerate real network interfaces. The function returns a list of `Multiaddr` objects — one per interface — with deduplication and a guarantee that loopback (`127.0.0.1`) is always included:

```python
listen_addrs = get_available_interfaces(port)
# → [Multiaddr("/ip4/192.168.1.17/tcp/8000"),
#    Multiaddr("/ip4/10.156.233.51/tcp/8000"),
#    Multiaddr("/ip4/127.0.0.1/tcp/8000")]
```

**Layer 2: Bind.** The discovered addresses feed directly into the host's `run()` method:

```python
async with host.run(listen_addrs=listen_addrs):
```

No wildcard. The host binds to each real interface individually.

**Layer 3: Advertise.** After binding, the example displays all addresses and picks the optimal one for the client command:

```python
all_addrs = host.get_addrs()
print("Listener ready, listening on:\n")
for addr in all_addrs:
    print(f"{addr}")

optimal_addr = get_optimal_binding_address(port)
optimal_addr_with_peer = f"{optimal_addr}/p2p/{host.get_id().to_string()}"
print(f"\nRun this from the same folder in another console:\n\n"
      f"ping-demo -d {optimal_addr_with_peer}\n")
```

`get_optimal_binding_address()` applies heuristics: prefer a non-loopback address (so LAN peers can connect), fall back to loopback if nothing else is available. Never return `0.0.0.0`.

For the rare case where wildcard binding is genuinely needed — like `network_discover.py`, which demonstrates address expansion — a new `get_wildcard_address()` function provides explicit opt-in:

```python
wildcard = get_wildcard_address(port)  # → Multiaddr("/ip4/0.0.0.0/tcp/8000")
```

{{<img src="img/blog/py-libp2p-wildcard-bind-migration/diagram-03-after-all-migrated.png" alt="After all migrated" />}}

*After PR #892: all examples route through `address_validation.py`. The wildcard is preserved only for `network_discover.py`, which demonstrates it as an explicit feature.*

## Under the Hood: Key Technical Details

### The Migration Pattern

Every example follows the same transformation. Here's `ping.py`:

```diff
-    listen_addr = multiaddr.Multiaddr(f"/ip4/0.0.0.0/tcp/{port}")
+    listen_addrs = get_available_interfaces(port)
     host = new_host()
-    async with host.run(listen_addrs=[listen_addr]):
+    async with host.run(listen_addrs=listen_addrs):
+        all_addrs = host.get_addrs()
+        print("Listener ready, listening on:\n")
+        for addr in all_addrs:
+            print(f"{addr}")
+        optimal_addr = get_optimal_binding_address(port)
+        optimal_addr_with_peer = f"{optimal_addr}/p2p/{host.get_id().to_string()}"
         print(
-            "Run this from the same folder in another console:\n\n"
-            f"ping-demo -d {host.get_addrs()[0]}\n"
+            f"\nRun this from the same folder in another console:\n\n"
+            f"ping-demo -d {optimal_addr_with_peer}\n"
         )
```

One line of hardcoded binding becomes three lines of dynamic discovery, plus an improved output that shows all available addresses and suggests the optimal one.

### QUIC Address Conversion

QUIC runs over UDP, so multiaddrs use `/udp/` instead of `/tcp/` with a `/quic-v1` suffix. Since `get_available_interfaces()` returns TCP addresses, QUIC examples perform a conversion:

```python
tcp_addrs = get_available_interfaces(port)
quic_addrs = []
for addr in tcp_addrs:
    addr_str = str(addr).replace("/tcp/", "/udp/") + "/quic-v1"
    quic_addrs.append(Multiaddr(addr_str))
```

### IP Deduplication

The `get_available_interfaces()` function now deduplicates IPs before constructing multiaddrs:

```diff
     for ip in _safe_get_network_addrs(4):
-        seen_v4.add(ip)
-        addrs.append(Multiaddr(f"/ip4/{ip}/{protocol}/{port}"))
+        if ip not in seen_v4:  # Avoid duplicates
+            seen_v4.add(ip)
+            addrs.append(Multiaddr(f"/ip4/{ip}/{protocol}/{port}"))
```

This prevents the same address from appearing multiple times when a network interface reports duplicate entries.

### The Fallback Chain

The function's fallback logic changed from wildcard to loopback:

```diff
     if not addrs:
-        addrs.append(Multiaddr(f"/ip4/0.0.0.0/{protocol}/{port}"))
+        addrs.append(Multiaddr(f"/ip4/127.0.0.1/{protocol}/{port}"))
```

Similarly, `get_optimal_binding_address()` now returns loopback as its final fallback instead of wildcard. The invariant: *no function in the default path ever returns `0.0.0.0`*.

### The identify-demo Bug Fix

During review, @acul71 discovered that `identify-demo` displayed inverted format instructions. The bug was a single line:

```diff
-    use_varint_format = args.raw_format
+    use_varint_format = not args.raw_format
```

When `--raw-format` is true (use raw protobuf), `use_varint_format` should be false. The original code had this backwards, causing the demo to display instructions for the wrong format.

## Before and After

| | Before | After |
|---|---|---|
| Binding strategy | `Multiaddr(f"/ip4/0.0.0.0/tcp/{port}")` | `get_available_interfaces(port)` |
| What binds | Wildcard (all interfaces) | Real discovered interfaces |
| Displayed address | `/ip4/0.0.0.0/tcp/42547/p2p/...` | `/ip4/192.168.1.17/tcp/43857/p2p/...` |
| Client command | Uses first (wildcard) address | Uses optimal (non-loopback) address |
| Security posture | Exposed on all interfaces | Bound to specific interfaces |
| Wildcard access | Default | Explicit opt-in via `get_wildcard_address()` |
| Consistency | 1/18 examples used new paradigm | 18/18 examples use new paradigm |
| Output format | Single address shown | All interfaces listed |
| Regression protection | None | Guard tests scan source for anti-patterns |
| Fallback behavior | Falls back to `0.0.0.0` | Falls back to `127.0.0.1` |

## Testing and Validation

The PR introduced two new test files covering different layers of verification.

### Unit Tests: `test_default_bind_address.py`

The `TestAddressParadigm` class validates the address functions themselves:

- **Wildcard is opt-in**: `get_wildcard_address()` returns `0.0.0.0`, but `get_available_interfaces()` never includes it
- **Loopback always present**: `get_available_interfaces()` guarantees `127.0.0.1` in every result
- **Optimal is from available**: `get_optimal_binding_address()` returns an address from the available interfaces list
- **Protocol parametrization**: Both TCP and UDP produce valid multiaddrs with correct protocol strings
- **Paradigm consistency**: Optimal address is never wildcard; wildcard is always available as a feature

### Guard Tests: `test_examples_bind_address.py`

The `TestExamplesAddressParadigm` class scans source code for anti-patterns:

```python
def test_examples_use_address_paradigm(self):
    """Test that examples use the new address paradigm functions"""
    networking_examples = [
        "echo/echo.py", "chat/chat.py", "ping/ping.py",
        "bootstrap/bootstrap.py", "pubsub/pubsub.py",
        "identify/identify.py",
    ]
    paradigm_functions = [
        "get_available_interfaces",
        "get_optimal_binding_address",
    ]
    for filename in networking_examples:
        # ... find file, read content ...
        for func in paradigm_functions:
            assert func in content, (
                f"{filepath} should use {func}"
            )
```

This is the regression insurance: any future contributor who adds an example with `Multiaddr(f"/ip4/0.0.0.0/...")` instead of `get_available_interfaces()` will fail this test. The guard test also verifies that `network_discover.py` correctly demonstrates wildcard binding as an explicit feature, and that all documentation examples use the paradigm functions.

{{<img src="img/blog/py-libp2p-wildcard-bind-migration/diagram-04-testing-pyramid.png" alt="Testing pyramid" />}}

*Three layers of verification: unit tests validate the address functions, guard tests scan source code for anti-patterns, and manual testing confirms all examples run end-to-end.*

### Manual Verification

Reviewer @acul71 required manual testing evidence for all 12 interactive example demos — screenshots or terminal output showing server startup, client connection, and data exchange. This caught the identify-demo format bug that automated tests missed.

## The Review Story

PR #892's review history is a case study in how rigorous code review shapes better software. The timeline:

**Round 1**: My initial implementation took the straightforward approach — find `0.0.0.0`, replace with `127.0.0.1`, across 18 files. @acul71 rejected it immediately. The mass conversion broke network accessibility: every example became localhost-only, defeating the purpose of a peer-to-peer networking library. The reviewer's instruction was clear: use the dynamic interface discovery paradigm from PR #811, not a naive string replacement.

**Round 2**: My second iteration partially implemented the paradigm. Some files were migrated, but @acul71's follow-up review found QUIC examples and encryption doc-examples still using hardcoded addresses. The review flagged each broken file by name.

**Round 3**: The third iteration achieved complete coverage. All 17 examples used the new paradigm. But @acul71 wasn't done — running the identify demo manually revealed the inverted format logic bug. The reviewer also caught line-length violations (`92 > 88` chars in `identify.py`) that `make pr` would flag, and requested a newsfragment for the release notes.

The reviewer's final requirement: **manual testing evidence for every example**. Not just "tests pass" — actual screenshots of server and client terminals, for all 12 interactive demos. This is what caught the identify-demo bug that no unit test would surface.

The PR went through multiple rounds of feedback before @seetadev confirmed it was ready for merge. Total review comments: 16.

## Lessons Learned

**Don't replace a bad default with a different bad default.** The naive fix — `0.0.0.0` → `127.0.0.1` — trades one problem for another. Wildcard binding is a security risk; localhost-only binding breaks networking. Dynamic interface discovery solves both: bind to real interfaces, advertise real addresses, fall back to loopback only when nothing else is available. When you're fixing a default, ask whether the replacement is actually correct in all the contexts where the original was used.

**Examples are the real API documentation.** Developers copy examples verbatim. Every `0.0.0.0` in a sample file becomes a `0.0.0.0` in someone's deployment. This makes example code a higher-leverage fix than library internals — fixing the examples fixes every project that copies them. The corollary: example code deserves the same rigor as production code, because it *becomes* production code.

**Guard tests are regression insurance.** Unit tests verify behavior; guard tests verify *code structure*. A test that scans `examples/*.py` for `0.0.0.0` catches mistakes that no unit test can — it doesn't test what the code does, it tests what the code *says*. This pattern is underused. Any time you complete a codebase-wide migration, write a test that asserts the migration is complete. Your future self will thank you.

**Thorough code review is a feature, not a bottleneck.** @acul71's rejection of the naive fix, demand for comprehensive testing, and manual identification of the identify-demo bug transformed what could have been a broken migration into a robust one. The PR took three rounds of review. Each round made the code better. The final result — tested, consistent, regression-proof — was worth the iteration.

## What's Next

The current implementation has IPv6 interface discovery commented out in `get_available_interfaces()` — the code is written but disabled, pending testing on IPv6-enabled environments. The guard test pattern could be integrated into CI as a pre-merge check. And the address validation module itself could extend beyond examples to cover any internal library code that constructs addresses.

## Conclusion

PR #892 completed what PR #811 started: the systematic elimination of hardcoded `0.0.0.0` from py-libp2p. Seventeen examples migrated to dynamic interface discovery. Five documentation files updated. Two new test suites — unit tests for the address functions and guard tests that scan source code for anti-patterns — ensure the migration won't regress. A bug in identify-demo's format logic, caught during manual review, was fixed along the way.

The pattern is simple: **discover** real interfaces, **bind** to them individually, **advertise** the optimal one. No wildcards in the default path. Wildcard available as an explicit opt-in when genuinely needed.

With 881 additions across 34 files, the diff is substantial. But the core idea fits in three function calls: `get_available_interfaces()`, `host.run(listen_addrs=...)`, `get_optimal_binding_address()`. Sometimes the most impactful security improvement isn't a clever cryptographic fix — it's replacing a dangerous default with one that does the right thing everywhere.

## Acknowledgements

- **@yashksaini-coder** for the implementation across three review rounds
- **@acul71** for rigorous review that caught the naive fix, the identify-demo bug, and demanded comprehensive manual testing
- **@seetadev** for coordination and final review

## Resources

- [PR #892 — Fix/885 Update Default Bind Address](https://github.com/libp2p/py-libp2p/pull/892)
- [Issue #885 — Refactor: Update Default Bind Addresses](https://github.com/libp2p/py-libp2p/issues/885)
- [PR #811 — Thin Waist Address Validation Utilities](https://github.com/libp2p/py-libp2p/pull/811)
- [CWE-1327: Binding to an Unrestricted IP Address](https://cwe.mitre.org/data/definitions/1327.html)
- [CVE-2024-47176: cups-browsed Remote Code Execution](https://securitylabs.datadoghq.com/articles/emerging-vulnerability-cups/)
- [TensorBoard Issue #2513: Bind to localhost](https://github.com/tensorflow/tensorboard/issues/2513)
- [py-multiaddr Documentation](https://github.com/multiformats/py-multiaddr)
- [libp2p Documentation](@/docs/_index.md)

Related on libp2p.io: [Addressing](@/docs/addressing.md), [Security Considerations](@/docs/security-considerations.md), [From Hardcoded to Dynamic](@/blog/py-libp2p-dynamic-interface-discovery.md).

If you would like to contribute, please [connect with the libp2p maintainers](@/get-involved/_index.md).
