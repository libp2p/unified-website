+++
title = "What is Publish/Subscribe"
description = "Publish/Subscribe is a system where peers congregate around topics they are interested in. Peers interested in a topic are said to be subscribed to that topic. Learn about how peers can message data in libp2p."
weight = 60
aliases = ["/concepts/publish-subscribe", "/concepts/pubsub", "/guides/pubsub/"]

[extra]
toc = true
category = "publish/subscribe"
+++

## Overview

Publish/Subscribe is a system where peers congregate around topics they are
interested in. Peers interested in a topic are said to be subscribed to that
topic.

Peers can send messages to topics. Each message gets delivered to all peers
subscribed to the topic.

Example uses of pub/sub:

* **Chat rooms.** Each room is a pub/sub topic and clients post chat messages to
    which are received by all other clients in the room.
* **File sharing.** Each pub/sub topic represents a file that can be downloaded.
    Uploaders and downloaders advertise which pieces of the file they have in
    the pub/sub topic and coordinate downloads that will happen outside the
    pub/sub system.

## Design goals

In a peer-to-peer pub/sub system all peers participate in delivering messages
throughout the network. There are several different designs for peer-to-peer
pub/sub systems which offer different trade-offs. Desirable properties include:

* **Reliability:** All messages get delivered to all peers subscribed to the topic.
* **Speed:** Messages are delivered quickly.
* **Efficiency:** The network is not flooded with excess copies of messages.
* **Resilience:** Peers can join and leave the network without disrupting it.
  There is no central point of failure.
* **Scale:** Topics can have enormous numbers of subscribers and handle a large
    throughput of messages.
* **Simplicity:** The system is simple to understand and implement. Each peer
  only needs to remember a small amount of state.

libp2p currently uses a design called **gossipsub**. It is named after the fact
that peers gossip to each other about which messages they have seen and use this
information to maintain a message delivery network.

## Discovery

Before a peer can subscribe to a topic it must find other peers and establish
network connections with them. The pub/sub system doesn't have any way to
discover peers by itself. Instead, it relies upon the application to find new
peers on its behalf, a process called **ambient peer discovery**.

Potential methods for discovering peers include:

* Distributed hash tables
* Local network broadcasts
* Exchanging peer lists with existing peers
* Centralized trackers or rendezvous points
* Lists of bootstrap peers

For example, in a BitTorrent application, most of the above methods would
already be used in the process of downloading files. By reusing peers found
while the BitTorrent application goes about its regular business, the
application could build up a robust pub/sub network too.

Discovered peers are asked if they support the pub/sub protocol, and if so, are
added to the pub/sub network.

## Types of peering

In gossipsub, peers connect to each other via either **full-message** peerings
or **metadata-only** peerings. The overall network structure is made up of these
two networks.

### Full-message

Full-message peerings are used to transmit the full contents of messages
throughout the network. This network is sparsely-connected with each peer only
being connected to a few other peers. (In the
[gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md)
this sparsely-connected network is called a *mesh* and peers within it are
called *mesh members*.)

Limiting the number of full-message peerings is useful because it keeps the
amount of network traffic under control; each peer only forwards messages to a
few other peers, rather than all of them. Each peer has a target number of peers
it wants to be connected to.

{% alert(type="note") %}
Throughout this guide, numbers highlighted can be configured by the developer.
{% end %}

The peering degree (also called the *network degree* or *D*) controls the
trade-off between speed, reliability, resilience and efficiency of the network.
A higher peering degree helps messages get delivered faster, with a better
chance of reaching all subscribers and with less chance of any peer disrupting
the network by leaving. However, a high peering degree also causes additional
redundant copies of each message to be sent throughout the network, increasing
the bandwidth required to participate in the network.

In libp2p's default implementation the ideal network peering degree is 6 with anywhere from 4–12 being acceptable.

### Metadata-only

In addition to the sparsely-connected network of full-message peerings, there is
also a densely-connected network of metadata-only peerings. This network is made
up of all the network connections between peers that aren't full-message
peerings.

The metadata-only network shares gossip about which messages are available and
performs functions to help maintain the network of full-message peerings.

## Grafting and pruning

Peerings are **bidirectional**, meaning that for any two connected peers, both
peers consider their connection to be full-message or both peers consider their
connection to be metadata-only.

Either peer can change the connection type by notifying the other. **Grafting** is
the process of converting a metadata-only connection to full-message. **Pruning**
is the opposite process; converting a full-message peering to metadata-only.

When a peer has too few full-message peerings it will randomly graft some of its
metadata-only peerings to become full-message peerings.

Conversely, when a peer has too many full-message peerings it will randomly
prune some of them back to metadata-only.

In libp2p's implementation, each peer performs a series of checks every
1 second. These checks are called the *heartbeat*. Grafting and pruning happens during this time.

## Subscribing and unsubscribing

Peers keep track of which topics their directly-connected peers are subscribed
to. Using this information each peer is able to build up a picture of the topics
around them and which peers are subscribed to each topic.

Keeping track of subscriptions happens by sending **subscribe** and
**unsubscribe** messages. When a new connection is established between two peers
they start by sending each other the list of topics they are subscribed to.

Then over time, whenever a peer subscribes or unsubscribes from a topic, it will
send each of its peers a subscribe or unsubscribe message. These messages are
sent to all connected peers regardless of whether the receiving peer is
subscribed to the topic in question.

Subscribe and unsubscribe messages go hand-in-hand with graft and prune
messages. When a peer subscribes to a topic it will pick some peers that will
become its full-message peers for that topic and send them graft messages at the
same time as their subscribe messages.

When a peer unsubscribes from a topic it will notify its full-message peers that
their connection has been pruned at the same time as sending their unsubscribe
messages.

## Sending messages

When a peer wants to publish a message it sends a copy to all full-message peers
it is connected to.

Similarly, when a peer receives a new message from another peer, it stores the
message and forwards a copy to all other full-message peers it is connected to.

In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#controlling-the-flood),
peers are also known as *routers* because of this function they have in routing
messages through the network.

Peers remember a list of recently seen messages. This lets peers act upon a
message only the first time they see it and ignore retransmissions of already
seen messages.

Peers might also choose to validate the contents of each message received. What
counts as valid and invalid depends on the application. For example, a chat
application might enforce that all messages must be shorter than 100 characters.
If the application tells libp2p that a message is invalid then that message will
be dropped and not replicated further through the network.

## Gossip

Peers gossip about messages they have recently seen. Every
1 second each peer randomly selects 6 metadata-only peers and sends them a list of
recently seen messages.

Gossiping gives peers a chance to notice in case they missed a message on the
full-message network. If a peer notices it is repeatedly missing messages then
it can set up new full-message peerings with peers that do have the messages.

In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#control-messages),
gossip announcing recently seen messages are called *IHAVE* messages and
requests for specific messages are called *IWANT* messages.

## Fan-out

Peers are allowed to publish messages to topics they are not subscribed to.
There are some special rules about how to do this to help ensure these messages
are delivered reliably.

The first time a peer wants to publish a message to a topic it is not subscribed
to, it randomly picks 6 peers (3 shown below) that are
subscribed to that topic and remembers them as **fan-out** peers for that topic.

Unlike the other types of peering, fan-out peerings are unidirectional; they
always point from the peer outside the topic to a peer subscribed to the topic.
Peers subscribed to the topic are not told that they have been selected
and still treat the connection as any other metadata-only peering.

Each time the sender wants to send a message, it sends the message to its
fan-out peers, who then distribute the message within the topic.

If the sender goes to send a message but notices some of their fan-out peers
went away since last time, they will randomly select additional fan-out peers
to top them back up to 6.

When a peer subscribes to a topic, if it already has some fan-out peers it will
prefer them to become the full-message peers.

After 2 minutes of not sending any messages to a topic, all the fan-out peers for that topic are forgotten.

## Network packets

The packets that peers actually send each other over the network are a
combination of all the different message types seen in this guide (application
messages, have/want, subscribe/unsubscribe, graft/prune). This structure allows
several different requests to be batched up and sent in a single network packet.

See the [specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#protobuf) for the exact [Protocol Buffers](https://developers.google.com/protocol-buffers)
schema used to encode network packets.

## State

Here is a summary of the state each peer must remember to participate in the
pub/sub network:

* **Subscriptions:** List of topics subscribed to.
* **Fan-out topics:** These are the topics messaged recently but not subscribed
    to. For each topic the time of the last sent message to that topic is
    remembered.
* **List of peers currently connected to:** For each peer connected to, the
    state includes all the topics they are subscribed to and whether the peering
    for each topic is full-content, metadata-only or fan-out.
* **Recently seen messages**: This is a cache of recently seen messages. It is
    used to detect and ignore retransmitted messages. For each message the state
    includes who sent it and the sequence number, which is enough to uniquely
    identify any message. For very recent messages, the full message contents
    is kept so that it can be sent to any peers that request the message.

## More information

For more detail and a discussion of other pub/sub designs that influenced the
design of gossipsub, see the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md).

For implementation details, see the [gossipsub.go](https://github.com/libp2p/go-libp2p-pubsub/blob/master/gossipsub.go)
file in the source code of [go-libp2p-pubsub](https://github.com/libp2p/go-libp2p-pubsub),
which is the canonical implementation of gossipsub in libp2p.
