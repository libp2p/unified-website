+++
title = "Announcing the release of jvm-libp2p 1.1.1"
description = "Release 1.1.1 of jvm-libp2p"
date = 2024-05-22
slug = "2024-05-22-jvm-libp2p"

[taxonomies]
tags = ["jvm-libp2p"]

[extra]
author = "StefanBratanov"
version = "1.1.1"
implementation = "jvm-libp2p"
breaking = false
security = false
github_release = "https://github.com/libp2p/jvm-libp2p/releases/tag/1.1.1"
+++

This release contains a change to set `topicID` on outbound `IHAVE` messages as well as ignore unknown topics on inbound `IHAVE` messages for [GossipSub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub). It also adds a beta support for [Autonat](https://github.com/libp2p/specs/tree/master/autonat) as well as other fixes.

## What's Changed

- chore(cfg): update new issue templates by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/dhuseby/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/dhuseby">@dhuseby</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2094765243" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/347" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/347/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/347">#347</a>
- Implement autonat protocol by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/ianopolous/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/ianopolous">@ianopolous</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2096216338" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/349" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/349/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/349">#349</a>
- Update netty by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/ianopolous/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/ianopolous">@ianopolous</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2211918737" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/355" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/355/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/355">#355</a>
- update dokka by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/ianopolous/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/ianopolous">@ianopolous</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2212887458" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/357" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/357/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/357">#357</a>
- AbstractRouter.getPeerTopics() may throw ConcurrentModificationException by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/Nashatyrev/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/Nashatyrev">@Nashatyrev</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2280520800" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/362" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/362/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/362">#362</a>
- Fix remotePubKey in Noise secure Session by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/Nashatyrev/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/Nashatyrev">@Nashatyrev</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2297526587" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/364" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/364/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/364">#364</a>
- Fix mdns when listening with ipv6 wildcard (which includes ipv4) by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/ianopolous/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/ianopolous">@ianopolous</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2306755919" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/366" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/366/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/366">#366</a>
- Set topicID on outbound IHAVE and ignore inbound IHAVE for unknown topic by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/StefanBratanov/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/StefanBratanov">@StefanBratanov</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2298042779" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/365" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/365/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/365">#365</a>

## New Contributors

- <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/dhuseby/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/dhuseby">@dhuseby</a> made their first contribution in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2094765243" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/347" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/347/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/347">#347</a>
