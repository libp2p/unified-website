+++
title = "Announcing the release of jvm-libp2p 1.2.0"
description = "Release 1.2.0 of jvm-libp2p"
date = 2024-09-26
slug = "2024-09-26-jvm-libp2p"

[taxonomies]
tags = ["jvm-libp2p"]

[extra]
author = "StefanBratanov"
version = "1.2.0"
implementation = "jvm-libp2p"
breaking = false
security = true
github_release = "https://github.com/libp2p/jvm-libp2p/releases/tag/1.2.0"
+++

This release adds support for [gossipsub v1.2](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/gossipsub-v1.2.md) (more specifically support for IDONTWANT). It also contains a fix for [CVE-2024-7254](https://avd.aquasec.com/nvd/2024/cve-2024-7254/) as well as other fixes.

## What's Changed

- More mdns fixes by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/ianopolous/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/ianopolous">@ianopolous</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2310534479" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/368" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/368/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/368">#368</a>
- chore: Update funding.json by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/p-shahi/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/p-shahi">@p-shahi</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2506433037" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/372" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/372/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/372">#372</a>
- Updating com.google.protobuf to 3.25.5 by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/lucassaldanha/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/lucassaldanha">@lucassaldanha</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2537399598" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/373" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/373/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/373">#373</a>
- Fix Gossip simulator issue  by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/Nashatyrev/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/Nashatyrev">@Nashatyrev</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2547937727" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/375" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/375/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/375">#375</a>
- [GossipSub 1.2] Add IDONTWANT support by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/StefanBratanov/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/StefanBratanov">@StefanBratanov</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2543018702" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/374" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/374/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/374">#374</a>
- Dependencies sweep by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/StefanBratanov/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/StefanBratanov">@StefanBratanov</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2549946129" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/376" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/376/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/376">#376</a>

## New Contributors

- <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/p-shahi/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/p-shahi">@p-shahi</a> made their first contribution in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2506433037" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/372" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/372/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/372">#372</a>
- <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/lucassaldanha/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/lucassaldanha">@lucassaldanha</a> made their first contribution in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="2537399598" data-permission-text="Title is private" data-url="https://github.com/libp2p/jvm-libp2p/issues/373" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/jvm-libp2p/pull/373/hovercard" href="https://github.com/libp2p/jvm-libp2p/pull/373">#373</a>


**Full Changelog**: <a class="commit-link" href="https://github.com/libp2p/jvm-libp2p/compare/1.1.1...1.2.0"><tt>1.1.1...1.2.0</tt></a>
