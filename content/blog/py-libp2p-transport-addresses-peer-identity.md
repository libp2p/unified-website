+++
title = "The TODO That Took a Year: Separating Transport Addresses from Peer Identity in py-libp2p"
description = "A one-line TODO in basic_host.py hid a layer violation: transport addresses carried peer identity. Separating them aligned py-libp2p with go-libp2p and the spec."
date = 2025-12-21
slug = "py-libp2p-transport-addresses-peer-identity"

[taxonomies]
tags = ["py-libp2p", "multiaddr", "peer-id", "api-design"]

[extra]
author = "Yash Kumar Saini"
header_image = "/img/blog/py-libp2p-transport-addresses-peer-identity/banner.png"
source_repo = "libp2p/py-libp2p"
source_prs = ["https://github.com/libp2p/py-libp2p/pull/1080"]
+++
## A Single Line of Technical Debt

Somewhere in py-libp2p's `basic_host.py`, at line 318, a comment had been sitting for a long time:

```python
# TODO: We don't need "/p2p/{peer_id}" postfix actually.
```

Every time `BasicHost.get_addrs()` was called — by the identify protocol, by NAT managers, by examples, by tests — it returned addresses like `/ip4/127.0.0.1/tcp/8000/p2p/QmPeer...`. The `/p2p/QmPeer...` suffix stamps the peer's identity onto the transport address. But the method gave callers no choice: every address came pre-stamped, whether the caller needed identity information or not.

The problem wasn't that the peer ID suffix was wrong. It was that it was *mandatory*. Transport listeners — the components that actually bind to network interfaces — deal in raw addresses: `/ip4/127.0.0.1/tcp/8000`. The identify protocol needs the peer ID suffix to tell remote peers where to find us. NAT managers need the raw address to know which interface is bound. By forcing the suffix onto every address, `get_addrs()` was serving one consumer at the expense of all others.

PR #1080 fixes this in 60 lines. But the story of how a TODO comment became a discussion, then an issue, then a spec-aligned refactor reveals something about how small API decisions compound in layered networking stacks.

## Background: How libp2p Addresses Work

**libp2p** is the modular peer-to-peer networking framework behind IPFS, Filecoin, and Ethereum's consensus layer. Its addressing system uses **multiaddrs** — self-describing, composable address strings that encode both the network protocol and the endpoint.

A multiaddr has two conceptual halves:

- **Location** (transport): `/ip4/198.51.100.0/tcp/4242` — *where* to connect
- **Identity** (peer): `/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` — *who* to connect to

Combined, they form a **fully qualified address**: `/ip4/198.51.100.0/tcp/4242/p2p/QmYyQSo1...`. This address tells you both where to find the peer and how to verify their identity once connected.

The [libp2p addressing specification](https://github.com/libp2p/specs/blob/master/addressing/README.md) is deliberate about when to combine these halves. For **peer routing** — telling a third party how to reach a peer — the fully qualified form is essential. But for **direct exchange between authenticated peers**, the spec notes that the identity part is "considered superfluous because libp2p connections are authenticated by principle." If I'm already connected to you and authenticated via Noise or TLS, you don't need my peer ID in the address — you already know who I am.

This distinction matters because different components in the stack need different address forms. Transport listeners work with raw addresses. The identify protocol broadcasts full addresses. NAT managers inspect raw interfaces. Relay protocols compose circuit addresses. When a single method forces one form onto all consumers, the abstraction leaks.

*Before PR #1080, `get_addrs()` always appended the `/p2p/{peer_id}` suffix — callers needing raw transport addresses had to strip it manually.*

{{<img src="img/blog/py-libp2p-transport-addresses-peer-identity/diagram-01-before-conflated-addressing.png" alt="Before conflated addressing" />}}

## The Problem: One Method, Two Concerns

py-libp2p's `BasicHost.get_addrs()` did this:

```python
def get_addrs(self) -> list[multiaddr.Multiaddr]:
    # TODO: We don't need "/p2p/{peer_id}" postfix actually.
    p2p_part = multiaddr.Multiaddr(f"/p2p/{self.get_id()!s}")

    addrs: list[multiaddr.Multiaddr] = []
    for transport in self._network.listeners.values():
        for addr in transport.get_addrs():
            addrs.append(addr.encapsulate(p2p_part))
    return addrs
```

Every call to `get_addrs()` walked the transport listeners, collected their raw addresses, and *unconditionally* appended the peer ID. The method was doing two things: (1) collecting transport addresses and (2) decorating them with identity. These are different concerns at different layers of the stack.

[Issue #1073](https://github.com/libp2p/py-libp2p/issues/1073) articulated three concrete problems:

**Blurring of concerns.** Transport addresses describe *where* a host listens. Peer IDs describe *who* the host is. Combining them at the transport level confuses the boundary. Code that needs to know what interfaces are bound — like a NAT manager — has to deconstruct addresses that were unnecessarily constructed.

**Protocol inconsistency.** The identify protocol (`/ipfs/id/1.0.0`) wants addresses with peer IDs to share with remote peers. But transport-level code — listener configuration, port mapping, interface discovery — wants raw addresses. One method can't cleanly serve both.

**Cross-implementation misalignment.** In go-libp2p, the reference implementation, `BasicHost.Addrs()` returns transport addresses *without* the peer ID suffix. The identify protocol adds `/p2p/` when broadcasting addresses externally. py-libp2p was the outlier — the only implementation that forced identity into transport-level addressing.

## Investigation: From TODO to Three Options

The TODO comment at line 318 had been noticed before. [Discussion #716](https://github.com/libp2p/py-libp2p/discussions/716) analyzed it in depth, with @acul71 and @pacrob examining the codebase impact and proposing three paths forward:

*Discussion #716 analyzed three approaches. Option B was chosen for backward compatibility and clean separation, with a path for future deprecation.*

{{<img src="img/blog/py-libp2p-transport-addresses-peer-identity/diagram-02-three-options.png" alt="Three options" />}}

**Option A — Remove the /p2p suffix from `get_addrs()`** — was the purist's fix. It would align py-libp2p with the spec and with go-libp2p immediately. But it was a breaking change. Every test, example, and downstream application that relied on `get_addrs()` returning peer-stamped addresses would break. In a library used by IPFS and Filecoin infrastructure, breaking changes require careful deprecation cycles.

**Option B — Introduce a new method, `get_transport_addrs()`** — provided the clean API without breaking existing consumers. The new method returns raw transport addresses. The old `get_addrs()` is refactored to compose on top of the new method, preserving its behavior exactly. New code can choose the right method for its context. Old code doesn't break.

**Option C — Add a parameter, `get_addrs(include_p2p=True)`** — was functional but added API complexity. Boolean parameters on public methods create unclear call sites and make it harder to reason about method contracts.

Option B won. I filed [Issue #1073](https://github.com/libp2p/py-libp2p/issues/1073) to formalize the approach and volunteered to implement it.

## The Approach: Cross-Implementation Alignment

The research confirmed that go-libp2p — the reference implementation — already separates these concerns cleanly. In Go's `BasicHost`:

```go
func (h *BasicHost) Addrs() []ma.Multiaddr {
    return h.addressManager.Addrs()
}
```

`Addrs()` returns transport addresses. No peer ID appended. The identify protocol, which is responsible for telling other peers how to reach this node, adds the `/p2p/` prefix when constructing the identify message. The peer ID lives in the identity layer, not the transport layer.

*go-libp2p returns raw transport addresses from `Addrs()` and lets protocols add `/p2p` when needed. PR #1080 aligns py-libp2p with this architecture by introducing `get_transport_addrs()`.*

With PR #1080, py-libp2p has both: `get_transport_addrs()` for transport-layer consumers, and `get_addrs()` for identity-aware consumers. The architecture is now explicit about which layer handles which concern.

## The Solution: Extract and Compose

The refactoring follows the classic **extract-and-compose** pattern:

1. **Extract** the core logic (address collection from listeners) into a new method
2. **Rewrite** the original method as a thin composition on top of the extracted method

The new `get_transport_addrs()`:

```python
def get_transport_addrs(self) -> list[multiaddr.Multiaddr]:
    """
    Return the raw multiaddr addresses this host is listening to,
    without the /p2p/{peer_id} suffix.
    """
    addrs: list[multiaddr.Multiaddr] = []
    for transport in self._network.listeners.values():
        addrs.extend(transport.get_addrs())
    return addrs
```

The refactored `get_addrs()`:

```python
def get_addrs(self) -> list[multiaddr.Multiaddr]:
    """
    Return all the multiaddr addresses this host is listening to.

    Note: This method appends the /p2p/{peer_id} suffix to the addresses.
    Use get_transport_addrs() for raw transport addresses.
    """
    p2p_part = multiaddr.Multiaddr(f"/p2p/{self.get_id()!s}")
    return [addr.encapsulate(p2p_part) for addr in self.get_transport_addrs()]
```

*After PR #1080, `get_transport_addrs()` returns raw addresses for transport-layer consumers, while `get_addrs()` composes on top of it for identity-aware consumers.*

{{<img src="img/blog/py-libp2p-transport-addresses-peer-identity/diagram-03-after-separated-layers.png" alt="After separated layers" />}}

Three properties make this design deliberate:

**Single source of truth.** Address collection happens in exactly one place — `get_transport_addrs()`. The `get_addrs()` method is now a pure transformation of that data. If the address collection logic changes (new transport types, filtering logic), both methods automatically reflect the change.

**Contract enforcement.** The `IHost` abstract base class in `abc.py` gains a new abstract method:

```python
@abstractmethod
def get_transport_addrs(self) -> list[Multiaddr]:
    """
    Retrieve the raw multiaddr addresses this host is listening to,
    without the /p2p/{peer_id} suffix.
    """
```

Any future `IHost` implementation is now contractually obligated to provide raw transport addresses. This prevents the conflation pattern from recurring.

**Zero behavioral change for existing callers.** `get_addrs()` returns exactly the same addresses as before. The refactoring is invisible to existing code.

## Under the Hood: The Diff

The core change is compact. Here's the complete diff of `basic_host.py`:

```diff
-    def get_addrs(self) -> list[multiaddr.Multiaddr]:
+    def get_transport_addrs(self) -> list[multiaddr.Multiaddr]:
         """
-        :return: all the multiaddr addresses this host is listening to
+        Return the raw multiaddr addresses this host is listening to,
+        without the /p2p/{peer_id} suffix.
         """
-        # TODO: We don't need "/p2p/{peer_id}" postfix actually.
-        p2p_part = multiaddr.Multiaddr(f"/p2p/{self.get_id()!s}")
-
         addrs: list[multiaddr.Multiaddr] = []
         for transport in self._network.listeners.values():
-            for addr in transport.get_addrs():
-                addrs.append(addr.encapsulate(p2p_part))
+            addrs.extend(transport.get_addrs())
         return addrs
+
+    def get_addrs(self) -> list[multiaddr.Multiaddr]:
+        """
+        Return all the multiaddr addresses this host is listening to.
+
+        Note: This method appends the /p2p/{peer_id} suffix to the addresses.
+        Use get_transport_addrs() for raw transport addresses.
+        """
+        p2p_part = multiaddr.Multiaddr(f"/p2p/{self.get_id()!s}")
+        return [addr.encapsulate(p2p_part) for addr in self.get_transport_addrs()]
```

The TODO comment is gone. The nested loop is replaced by `addrs.extend()`. The encapsulation logic moves from the address collection loop to a list comprehension that operates on the already-collected addresses. The new method is shorter, the old method is clearer, and the separation is explicit.

## Before and After

| | Before (pre-PR #1080) | After (PR #1080) |
|---|---|---|
| **Raw transport addresses** | Not available — must manually strip `/p2p/` suffix | `host.get_transport_addrs()` |
| **Identity-stamped addresses** | `host.get_addrs()` (only option) | `host.get_addrs()` (unchanged) |
| **Code duplication** | Address collection and encapsulation interleaved | Address collection extracted; encapsulation composed |
| **IHost contract** | Only `get_addrs()` required | Both `get_addrs()` and `get_transport_addrs()` required |
| **go-libp2p alignment** | Misaligned — py-libp2p appends `/p2p/`, Go doesn't | Aligned — raw addresses available like Go's `Addrs()` |
| **The TODO** | `# TODO: We don't need "/p2p/{peer_id}" postfix actually.` | Resolved |
| **Spec compliance** | Transport layer carries identity information | Transport layer returns transport addresses |

## Testing and Validation

The test creates a `BasicHost` with a mock transport listener, then verifies both methods:

```python
def test_get_addrs_and_transport_addrs():
    key_pair = create_new_key_pair()
    swarm = new_swarm(key_pair)
    host = BasicHost(swarm)

    mock_transport = MagicMock()
    raw_addr = Multiaddr("/ip4/127.0.0.1/tcp/8000")
    mock_transport.get_addrs.return_value = [raw_addr]
    swarm.listeners = {"tcp": mock_transport}

    # Raw transport address — no /p2p/ suffix
    transport_addrs = host.get_transport_addrs()
    assert len(transport_addrs) == 1
    assert str(transport_addrs[0]) == "/ip4/127.0.0.1/tcp/8000"

    # Full address — with /p2p/{peer_id}
    addrs = host.get_addrs()
    assert len(addrs) == 1
    peer_id_str = str(host.get_id())
    addr_str = str(addrs[0])
    assert addr_str.endswith(f"/p2p/{peer_id_str}") or addr_str.endswith(
        f"/ipfs/{peer_id_str}"
    )
```

*The test verifies that `get_transport_addrs()` returns the raw address while `get_addrs()` returns the identity-encapsulated version.*

The test handles a subtle edge case: the Python `multiaddr` library may normalize `/p2p/` to `/ipfs/` (the older protocol name), so the assertion checks for both suffixes. This defensive check ensures the test doesn't break across multiaddr library versions.

The `ping.py` example was also updated to demonstrate both methods, printing the full peer address and the raw transport address side by side.

## Lessons Learned

**TODOs are issue drafts — promote them before they fossilize.** The TODO at line 318 captured a genuine design insight: the person who wrote it understood the layer violation. But a TODO comment is invisible to issue trackers, project boards, and search queries. Discussion #716 finally promoted it to a tracked discussion, and Issue #1073 turned it into actionable work. If a TODO describes an architectural concern, it belongs in an issue, not a comment.

**Backward-compatible additions are more valuable than breaking changes.** Option A (removing the `/p2p/` suffix from `get_addrs()`) would have been "cleaner" in the abstract, but it would have broken every downstream consumer. Option B achieves the same design goal — clean separation of transport and identity — without breaking a single call site. The existing behavior is preserved verbatim; the new behavior is opt-in. In library code used by production systems, the ability to improve without disrupting is a design feature, not a compromise.

**Cross-implementation comparison reveals design drift.** The discovery that go-libp2p's `Addrs()` does *not* append the peer ID was a concrete signal that py-libp2p's approach was an outlier. Spec compliance is one lens; behavioral parity with the reference implementation is another. When your implementation diverges from the reference, it's worth asking whether the divergence is intentional or accidental. In this case, it was accidental — a convenience shortcut that hardened into an assumption.

**Small refactors with clear separation compound over time.** PR #1080 is 60 lines. It changes no behavior for existing callers. But it opens doors: NAT managers can now use raw transport addresses directly. Relay protocols can compose addresses without decomposing them first. Future implementations of `IHost` are contractually required to provide the separation. The value of this change isn't in the diff — it's in every piece of code that can now be written more simply because the abstraction is clean.

## What's Next

PR #1080 is a foundation, not a destination. Several follow-up items build on the separation:

- **Internal migration**: Code within py-libp2p that needs raw transport addresses (NAT management, relay, transport configuration) can migrate from `get_addrs()` + manual stripping to `get_transport_addrs()` directly.
- **Deprecation path**: Issue #1073 mentions the possibility of deprecating `get_addrs()` in a future major release, eventually having consumers explicitly choose between transport and full addresses. This is Option A from Discussion #716 — but now with a smooth migration path.
- **AddrsFactory support**: go-libp2p's `AddrsFactory` allows filtering or transforming addresses before they're returned. py-libp2p could adopt a similar pattern, now that the raw address collection is cleanly separated.

## Conclusion

PR #1080 resolves a TODO that had been sitting in `basic_host.py` since the early days of py-libp2p's development. The fix is 60 lines: a new `get_transport_addrs()` method that returns raw transport addresses, and a refactored `get_addrs()` that composes identity encapsulation on top. No behavior changes for existing callers. Clean separation of transport and identity. Alignment with go-libp2p's architecture and the libp2p addressing spec.

The work traces a clean arc from a TODO comment → Discussion #716's analysis → Issue #1073's formalization → PR #1080's implementation. @pacrob approved on first review after the newsfragment was added. No design disputes, no CI failures, no integration surprises — because the refactoring was designed to be invisible to everything that already worked.

The deepest takeaway isn't about multiaddrs or peer IDs. It's about layer boundaries. When a method at one layer of the stack forces a decision that belongs to another layer, every consumer of that method carries the cost. PR #1080 gives the decision back to the caller.

## Acknowledgements

- **@yashksaini-coder** for filing Issue #1073 and implementing the refactor
- **@acul71** and **@pacrob** for the Discussion #716 analysis that identified the design options
- **@pacrob** for the review and approval
- **@seetadev** for encouragement and recognizing the importance of the separation

## Resources

- [PR #1080 — Decouple Peer ID Postfix from `get_addrs`](https://github.com/libp2p/py-libp2p/pull/1080)
- [Issue #1073 — Decouple peer ID postfix from get_addrs()](https://github.com/libp2p/py-libp2p/issues/1073)
- [Discussion #716 — TODO Analysis: BasicHost.get_addrs() p2p Postfix Issue](https://github.com/libp2p/py-libp2p/discussions/716)
- [libp2p Addressing Specification](https://github.com/libp2p/specs/blob/master/addressing/README.md)
- [libp2p Addressing Concepts](@/docs/addressing.md)
- [go-libp2p BasicHost Implementation](https://github.com/libp2p/go-libp2p/blob/master/p2p/host/basic/basic_host.go)
- [libp2p Identify Protocol Specification](https://github.com/libp2p/specs/blob/master/identify/README.md)
- [libp2p Peers and Identity](@/docs/peers.md)

Related on libp2p.io: [Addressing](@/docs/addressing.md), [Peers](@/docs/peers.md).

If you would like to contribute, please [connect with the libp2p maintainers](@/get-involved/_index.md).
