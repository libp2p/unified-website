+++
title = "DoS Mitigation"
description = "DoS mitigation is an essential part of any peer-to-peer application. Learn how to design protocols to be resilient to malicious peers."
weight = 16
aliases = ["/reference/dos-mitigation", "/concepts/dos-mitigation", "/guides/dos-mitigation/"]

[extra]
toc = true
category = "fundamentals"
+++

## What is DoS Mitigation?

DoS mitigation is an essential part of any P2P application. We need to design
our protocols to be resilient to malicious peers. We need to monitor our
application for signs of suspicious activity or an attack. And we need to be
able to respond to an attack.

Here we'll cover how we can use libp2p to achieve the above goals.

## What we mean by a DOS attack

A DOS attack is any attack that can cause your application to crash, stall, or
otherwise fail to respond normally. An attack is considered viable if it takes
fewer resources to execute than the damage it does. In other words, if the
payoff is higher than the investment it is a viable attack and should be
mitigated. Here are a few examples:

1. A node opening many connections to a remote node and forcing that
   node to spend 10x the compute time to handle the request relative to the
   attacker node. This is attack viable because a single node amplifies its
   affect 10x. This attack will continue to scale if the attacker adds more
   nodes.

2. 100 nodes asking a single node to do some work, but if this single node
   goes down it will indirectly cause the loss of an asset. If the asset is more
   valuable than the compute time of 100 nodes, this attack is viable.

3. Many nodes connecting to a single node such that that node can no
   longer accept new connections from an honest peer. This node is now
   isolated from the honest peers in the network. This is commonly called an
   eclipse attack and is viable if it's either cheap to eclipse this node, or if
   eclipsing this node has a high payoff.

Generally, the effect on our application can range from crashing to stalling to
failing to handle new peers to degraded performance. Ideally we want
our application to at worst suffer a slight performance penalty, but otherwise
stay up and healthy.

## Incorporating DOS mitigation from the start

The general strategy is to use the minimum amount of resources as possible and
make sure that there's no untrusted amplification mechanism (e.g. an untrusted
node can force you to do 10x the work it does). A protocol-level reputation
system can help (take a look at [GossipSub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub) for inspiration) as well as
logging misbehaving nodes and actioning those logs separately (see fail2ban
below).

### Limit the number of connections your application needs

Each connection has a resource cost associated with it. A connection will
usually represent a peer and a set of protocols with each their own resource
usage. So limiting connections can have a leveraged effect on your resource
usage.

In go-libp2p the number of active connections is managed by the
[`ConnManager`](https://pkg.go.dev/github.com/libp2p/go-libp2p/p2p/net/connmgr).
The `ConnManager` will trim connections when you hit the high watermark number of
connections, and try to keep the number of connections above the low watermark.

In rust-libp2p handlers should implement
[`connection_keep_alive`](https://docs.rs/libp2p/latest/libp2p/swarm/trait.ConnectionHandler.html#tymethod.connection_keep_alive)
to define when a connection can be closed. The swarm will close connections when
the root behavior no longer needs it.

js-libp2p users should read the section on [connection limits](https://github.com/libp2p/js-libp2p/blob/master/doc/LIMITS.md#connection-limits) in the js-libp2p docs.

### Transient Connections

When a connection is first established to libp2p but before that connection has
been tied to a specific peer (before security and muxer have been negotiated),
it is labeled as "transient" in go-libp2p and "negotiating" in rust-libp2p. Both
go-libp2p and rust-libp2p limit the total number of connections that can be in
this state since it can be an avenue for DOS attacks.

### Limit the number of concurrent streams per connection

Each stream has some resource cost associated with it. Depending on the
transport and multiplexer, this can be bigger or smaller. Design your protocol
to avoid having too many concurrent streams open per peer for your protocol.
Instead, try to limit the maximum number of concurrent streams to something
reasonable (surely you don't need >512 streams open at once for a peer?).

Using a stream for a short period of time and then closing it is fine. It's
the number of _concurrent_ streams that you need to be careful of.

### Reduce blast radius

If you can split up your libp2p application into multiple separate processes you
can increase the resiliency of your overall system. For example, your node may
have to help achieve consensus and respond to user queries. By splitting this up
into two processes you now rely on the OS's guarantee that the user query
process won't take down the consensus process.

### Fail2ban

If you can log when a peer is misbehaving or is malicious, you can then hook up
those logs to fail2ban and have fail2ban manage your firewall to automatically
block misbehaving nodes. go-libp2p includes some built-in support for this
use case.

### Rate limiting incoming connections

Depending on your use case, it can help to limit the rate of inbound
connections. You can use go-libp2p's
[ConnectionGater](https://pkg.go.dev/github.com/libp2p/go-libp2p/core/connmgr#ConnectionGater)
and `InterceptAccept` for this.

js-libp2p has a similar [connection gater](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#configuring-connection-gater) that can be configured on node start up.

## Monitoring your application

Once we've designed our protocols to be resilient to DOS attacks and deployed
them, we then need to monitor our application both to verify our mitigation works
and to be alerted if a new attack vector is exploited.

For rust-libp2p look at the [libp2p-metrics crate](https://github.com/libp2p/rust-libp2p/tree/master/misc/metrics).

For go-libp2p resource usage take a look at the OpenCensus metrics exposed by the resource
manager.

js-libp2p collects various system metrics, please see the [metrics documentation](https://github.com/libp2p/js-libp2p/blob/master/doc/METRICS.md)
for more information.

## Responding to an attack

When you see that your node is being attacked (e.g. crashing, stalling, high cpu
usage), then the next step is responding to the attack.

### Who's misbehaving?

To answer the question of which peer is misbehaving and harming you, go-libp2p
exposes canonical log lines that identify misbehaving peers. A canonical log line is simply a log line
with a special format.

### How to block a misbehaving peer

Once you've identified the misbehaving peer, you can block them with `iptables`
or `ufw`. You can get the ip address of the peer from the multiaddr in the log.

```bash
sudo ufw deny from 192.0.2.0
```

### How to automate blocking with fail2ban

You can hook up [fail2ban](https://www.fail2ban.org) to
automatically block connections from these misbehaving peers if they emit this
log line multiple times in some period of time.

### Deny specific peers or create an allow list of trusted peers

The go-libp2p [resource manager](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager) can
accept a list of trusted multiaddrs and can use a different set of limits in
case the normal system limits are reached. This is useful if you're currently
experiencing an attack since you can set low limits for general use, and
higher limits for trusted peers.

js-libp2p provides a straightforward allow and deny list mechanism with its [connection manager limits](https://github.com/libp2p/js-libp2p/blob/master/doc/LIMITS.md#allowdeny-lists).

## Summary

Mitigating DOS attacks is hard because an attacker needs only one flaw, while a
protocol developer needs to cover _all_ their bases. Libp2p provides some tools
to design better protocols, but developers should still monitor their
applications to protect against novel attacks. Finally, developers should
leverage existing tools like `fail2ban` to automate blocking misbehaving nodes
by logging when peers behave maliciously.
