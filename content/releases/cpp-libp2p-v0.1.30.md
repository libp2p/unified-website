+++
title = "Announcing the release of cpp-libp2p v0.1.30"
description = "Release v0.1.30 of cpp-libp2p"
date = 2025-02-12
slug = "2025-02-12-cpp-libp2p"

[taxonomies]
tags = ["cpp-libp2p"]

[extra]
author = "libp2p maintainers"
version = "v0.1.30"
implementation = "cpp-libp2p"
breaking = false
security = false
github_release = "https://github.com/libp2p/cpp-libp2p/releases/tag/v0.1.30"
+++

Fix closeOnError: call cb() before close() (<a class="issue-link js-issue-link" href="https://github.com/libp2p/cpp-libp2p/pull/293">#293</a>)



* closeOnError: call cb() before close()



Signed-off-by: Igor Egorov &amp;lt;igor@qdrvm.io&amp;gt;



* Countable yamux and yamux read buffer



* Count yamux metrics forcefully



* Revert "Count yamux metrics forcefully"



This reverts commit <a class="commit-link" href="https://github.com/libp2p/cpp-libp2p/commit/88cdeeda9554be05ff4aef6546fc3e716fc36001"><tt>88cdeed</tt></a>.



* Revert "Countable yamux and yamux read buffer"



This reverts commit <a class="commit-link" href="https://github.com/libp2p/cpp-libp2p/commit/e171915acf19121bff668cf7904b14bf5c8eb55b"><tt>e171915</tt></a>.



---------



Signed-off-by: Igor Egorov &amp;lt;igor@qdrvm.io&amp;gt;
