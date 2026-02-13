+++
title = "Announcing the release of jvm-libp2p 1.2.1"
description = "Release 1.2.1 of jvm-libp2p"
date = 2024-10-24
slug = "2024-10-24-jvm-libp2p"

[taxonomies]
tags = ["jvm-libp2p"]

[extra]
author = "tbenr"
version = "1.2.1"
implementation = "jvm-libp2p"
breaking = true
security = false
github_release = "https://github.com/libp2p/jvm-libp2p/releases/tag/1.2.1"
+++

This release improves reliability of message publishing over gossip, improves `DONTWANT` control message usage.


**WARNING:** This release introduces a breaking change in `GossipParams` by replacing `floodPublish` param with `floodPublishMaxMessageSizeThreshold`, which allow to configure flood publish behaviour based on the message size.


- `floodPublish = false` can be configured as `refloodPublishMaxMessageSizeThreshold = NEVER_FLOOD_PUBLISH` (0)
- `floodPublish = true` can be configured as `refloodPublishMaxMessageSizeThreshold = ALWAYS_FLOOD_PUBLISH` (Int.MAX_VALUE)

## What's Changed

- Don't throw `NoPeersForOutboundMessageException` if peers `DONTWANT` message by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/StefanBratanov/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/StefanBratanov">@StefanBratanov</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2590375142" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/385" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/385/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/385">#385</a>
- Send `IDONTWANT` prior to publish by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/StefanBratanov/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/StefanBratanov">@StefanBratanov</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2596223520" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/386" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/386/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/386">#386</a>
- **[BREAKING]** Replace `floodPublish` param with `floodPublishMaxMessageSizeThreshold`  by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/tbenr/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/tbenr">@tbenr</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2602123345" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/391" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/391/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/391">#391</a>
- Logging and other small warnings removal by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/tbenr/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/tbenr">@tbenr</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2602938826" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/392" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/392/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/392">#392</a>
- Gossip: more reliable publishing   by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/Nashatyrev/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/Nashatyrev">@Nashatyrev</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2597802668" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/387" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/387/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/387">#387</a>

## New Contributors

- <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/tbenr/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/tbenr">@tbenr</a> made their first contribution in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2602123345" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/391" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/391/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/391">#391</a>


**Full Changelog**: <a class="commit-link" href="https://github.com/libp2p/jvm-libp2p/compare/1.2.0...1.2.1"><tt>1.2.0...1.2.1</tt></a>
