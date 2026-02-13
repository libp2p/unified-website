+++
title = "Announcing the release of go-libp2p v0.45.0"
description = "Release v0.45.0 of go-libp2p"
date = 2025-11-06
slug = "2025-11-06-go-libp2p"

[taxonomies]
tags = ["go-libp2p"]

[extra]
author = "libp2p maintainers"
version = "v0.45.0"
implementation = "go"
breaking = false
security = false
github_release = "https://github.com/libp2p/go-libp2p/releases/tag/v0.45.0"
+++

A small release that adjust some noisy logging levels and adds a method for dynamically change the slog Handler for better integration with applications that use go-log.

## What's Changed

- fix(websocket): use debug level for operational noise errors by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/lidel/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/lidel">@lidel</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="3553122418" data-permission-text="Title is private" data-url="https://github.com/libp2p/go-libp2p/issues/3413" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/go-libp2p/pull/3413/hovercard" href="https://github.com/libp2p/go-libp2p/pull/3413">#3413</a>
- chore: Update Drips ownedBy address in FUNDING.json by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/p-shahi/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/p-shahi">@p-shahi</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="3584056209" data-permission-text="Title is private" data-url="https://github.com/libp2p/go-libp2p/issues/3422" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/go-libp2p/pull/3422/hovercard" href="https://github.com/libp2p/go-libp2p/pull/3422">#3422</a>
- feat(gologshim): Add SetDefaultHandler by <a class="user-mention notranslate" data-hovercard-type="user" data-hovercard-url="/users/lidel/hovercard" data-octo-click="hovercard-link-click" data-octo-dimensions="link_type:self" href="https://github.com/lidel">@lidel</a> in <a class="issue-link js-issue-link" data-error-text="Failed to load title" data-id="3559114238" data-permission-text="Title is private" data-url="https://github.com/libp2p/go-libp2p/issues/3418" data-hovercard-type="pull_request" data-hovercard-url="/libp2p/go-libp2p/pull/3418/hovercard" href="https://github.com/libp2p/go-libp2p/pull/3418">#3418</a>


**Full Changelog**: <a class="commit-link" href="https://github.com/libp2p/go-libp2p/compare/v0.44.0...v0.45.0"><tt>v0.44.0...v0.45.0</tt></a>
