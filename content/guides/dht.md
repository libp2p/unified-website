+++
title = "The DHT"
description = "Distributed Hash Tables provide a decentralized way to store and retrieve data across a network of peers."
weight = 14
aliases = ["/concepts/dht", "/concepts/fundamentals/dht"]

[extra]
toc = true
category = "fundamentals"
+++

## What is a DHT?

A Distributed Hash Table (DHT) is a distributed system that provides a lookup service similar to a hash table: key-value pairs are stored in the DHT, and any participating node can efficiently retrieve the value associated with a given key. The responsibility for maintaining the mapping from keys to values is distributed among the nodes, so that a change in the set of participants causes a minimal amount of disruption.

In libp2p, the DHT serves two critical functions:

1. **Peer Routing**: Finding the network addresses of peers by their Peer ID
2. **Content Routing**: Finding peers that have specific content (provider records)

## Kademlia DHT

libp2p uses a variant of the [Kademlia](https://en.wikipedia.org/wiki/Kademlia) DHT protocol, originally designed by Petar Maymounkov and David Mazières. Kademlia is well-suited for peer-to-peer networks because it minimizes the number of configuration messages nodes must send to learn about each other.

### XOR Distance Metric

Kademlia uses an XOR-based distance metric to determine how "close" two nodes or keys are to each other. The distance between two identifiers is calculated as:

```
distance(A, B) = A XOR B
```

This distance metric has several important properties:

- **Identity**: `distance(A, A) = 0` — a node is zero distance from itself
- **Symmetry**: `distance(A, B) = distance(B, A)` — distance is the same in both directions
- **Triangle Inequality**: `distance(A, B) + distance(B, C) >= distance(A, C)`

The XOR metric creates a well-defined topology where each node has a consistent view of the network, and lookups converge predictably toward the target.

### Routing Table and K-Buckets

Each node in the Kademlia DHT maintains a routing table organized into "k-buckets." The routing table is structured based on the XOR distance from the node's own ID:

- Bucket 0 contains nodes that differ in the most significant bit
- Bucket 1 contains nodes that match in the first bit but differ in the second
- Bucket n contains nodes that match in the first n bits but differ in bit n+1

Each k-bucket can hold up to `k` entries (typically k=20 in libp2p). This structure ensures that:

- Nodes know more about peers that are "closer" to them in XOR space
- Nodes have at least some knowledge of every region of the ID space
- Lookups require at most O(log n) hops to find any node in a network of n nodes

### The Lookup Process

When a node wants to find the closest nodes to a particular key (for peer routing or content routing), it performs an iterative lookup:

1. The node selects the α (alpha, typically 3) closest nodes to the target from its own routing table
2. It sends parallel `FIND_NODE` requests to these nodes
3. Each contacted node responds with the k closest nodes it knows to the target
4. The querying node updates its list of closest nodes and repeats the process
5. The lookup terminates when the closest k nodes have been queried and no closer nodes are returned

This process converges quickly because each step typically halves the distance to the target.

## DHT Operations

The libp2p Kademlia DHT supports five primary operations:

### FIND_NODE

Locates the k closest peers to a given key. This is the fundamental building block for all DHT operations.

```
Request: FIND_NODE(key)
Response: List of k closest peers to key
```

### PUT_VALUE / GET_VALUE

Store and retrieve arbitrary values in the DHT. Values are stored at the k nodes closest to the key.

```
PUT_VALUE(key, value) → Stores value at nodes closest to key
GET_VALUE(key) → Retrieves value from nodes closest to key
```

{% alert(type="note") %}
For security, libp2p requires that stored records be signed and validates signatures on retrieval. This prevents malicious nodes from injecting false data.
{% end %}

### ADD_PROVIDER / GET_PROVIDERS

These operations are specific to content routing. Instead of storing the content itself, nodes advertise that they can provide content for a given key.

```
ADD_PROVIDER(key) → Advertise this node as a provider for key
GET_PROVIDERS(key) → Find nodes that provide content for key
```

Provider records are used extensively in systems like IPFS, where nodes advertise which content blocks they have available.

## Peer Routing vs Content Routing

The DHT serves two distinct but related purposes:

### Peer Routing

When you have a Peer ID and need to find how to connect to that peer:

1. Compute the DHT key from the Peer ID
2. Perform a `FIND_NODE` lookup for that key
3. The lookup will either find the peer directly or find nodes close enough to have the peer's address in their routing table

### Content Routing

When you want to find peers that have specific content:

1. Compute the DHT key from the content identifier (e.g., CID in IPFS)
2. Perform a `GET_PROVIDERS` lookup for that key
3. Receive a list of peers that have advertised as providers for that content
4. Connect to one or more providers to retrieve the content

## Bootstrap Process

When a new node joins the network, it needs to populate its routing table:

1. The node starts with a list of "bootstrap" nodes — well-known, stable nodes in the network
2. It connects to bootstrap nodes and performs a `FIND_NODE` lookup for its own ID
3. This lookup populates the routing table with nodes across the ID space
4. The node may perform additional random lookups to further diversify its routing table

{% alert(type="info") %}
Bootstrap nodes are critical infrastructure. If a node cannot reach any bootstrap nodes, it cannot join the DHT network.
{% end %}

## Client vs Server Mode

libp2p DHT nodes can operate in two modes:

### Server Mode

Server mode nodes:
- Respond to DHT queries from other nodes
- Store records (values and provider records) for keys they are close to
- Are included in other nodes' routing tables
- Require a publicly reachable address

### Client Mode

Client mode nodes:
- Can query the DHT but do not respond to queries
- Do not store records for other nodes
- Are not included in other nodes' routing tables
- Suitable for nodes behind NAT or with limited resources

{% alert(type="note") %}
By default, libp2p implementations typically start in client mode and may automatically switch to server mode if they detect they have a publicly reachable address.
{% end %}

## Security Considerations

The DHT is subject to several potential attacks:

- **Sybil Attacks**: An attacker creates many fake identities to gain disproportionate influence
- **Eclipse Attacks**: An attacker surrounds a target node with malicious nodes to control its view of the network
- **Content Poisoning**: Malicious nodes return incorrect data for queries

libp2p mitigates these through:
- Signed records with public key validation
- Query responses validated against the original key
- Disjoint lookup paths in some implementations

For more details, see the [Security Considerations](/guides/security-considerations/) guide.

## Implementation Details

Different libp2p implementations may have varying DHT parameters:

| Parameter | Description | Typical Value |
|-----------|-------------|---------------|
| k | Bucket size (max nodes per bucket) | 20 |
| α (alpha) | Parallelism factor for lookups | 3 |
| Record TTL | How long records are stored | 24-48 hours |
| Refresh interval | How often buckets are refreshed | 1 hour |

## Further Reading

- [Kademlia DHT guide](/guides/kademlia-dht/) — Detailed Kademlia implementation specifics
- [libp2p DHT specification](https://github.com/libp2p/specs/tree/master/kad-dht) — Technical specification
- [Original Kademlia paper](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf) — Academic paper by Maymounkov and Mazières
