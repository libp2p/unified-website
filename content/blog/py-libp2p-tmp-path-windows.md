+++
title = "The /tmp Trap: How One Hardcoded Path Broke py-libp2p on Windows"
description = "A single hardcoded /tmp path made py-libp2p unusable on Windows. The fix, and what it says about portability assumptions in networking code."
date = 2025-09-04
slug = "py-libp2p-tmp-path-windows"

[taxonomies]
tags = ["py-libp2p", "cross-platform", "windows"]

[extra]
author = "Yash Kumar Saini"
header_image = "/img/blog/py-libp2p-tmp-path-windows/banner.png"
source_repo = "libp2p/py-libp2p"
source_prs = ["https://github.com/libp2p/py-libp2p/pull/886"]
+++
## A Crash Before the First Packet

Picture this: you're a Windows developer trying out py-libp2p for the first time. You set `LIBP2P_DEBUG=INFO` to see what's happening under the hood. The library crashes — not during a handshake, not during peer discovery, but while trying to *open a log file*. The culprit is a line that's been sitting in the codebase since the logging module was written:

```python
log_file = f"/tmp/py-libp2p_{timestamp}_{unique_id}.log"
```

A Unix path, hardcoded into a library that claims to support all platforms. In this PR, I replaced this and other scattered platform-specific paths with a single, centralized cross-platform toolkit — and shipped an audit script to make sure no hardcoded paths sneak back in.

## Background

**py-libp2p** is the Python implementation of libp2p, the modular peer-to-peer networking framework behind IPFS and Filecoin. Like any networking library, it needs to work everywhere Python runs — Linux, macOS, and Windows.

Python offers two approaches to path handling. The older **`os.path`** module treats paths as strings: you call `os.path.join()`, `os.path.dirname()`, and hope you never forget and concatenate with `/` instead. The newer **`pathlib`** module (Python 3.4+) represents paths as objects that handle OS-specific separators automatically. The `/` operator replaces string concatenation, and methods like `.parent` and `.resolve()` replace verbose function chains. The general rule: if you're writing new code, use `pathlib`. If you're maintaining old code, migrate when you touch it.

## The Problem

[Issue #882](https://github.com/libp2p/py-libp2p/issues/882) documented the state of affairs. A previous attempt (PR #792) had introduced a `paths.py` utility module, but only wired it into test utilities. Core modules and examples were still doing their own thing.

The worst offender was `libp2p/utils/logging.py`:

```python
if os.name == "nt":  # Windows
    log_file = f"C:\\Windows\\Temp\\py-libp2p_{timestamp}.log"
else:  # Unix
    log_file = f"/tmp/py-libp2p_{timestamp}.log"
```

This pattern — branching on `os.name` to pick a hardcoded path — is the classic **platform if/else anti-pattern**. It breaks when assumptions about directory structure don't hold (macOS doesn't always use `/tmp`; Windows may restrict `C:\Windows\Temp`). And it requires every developer to remember both branches.

The kademlia example had a different flavor of the same problem:

```python
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVER_ADDR_LOG = os.path.join(SCRIPT_DIR, "server_node_addr.txt")
```

Not broken per se, but scattered `os.path` calls with no standardization — every module reinventing the same wheel.

*Before PR #886: each module handled paths independently, with hardcoded platform branches or raw `os.path` calls.*

![Before after path construction](/img/blog/py-libp2p-tmp-path-windows/diagram-01-before-after-path-construction.png)

## The Solution

The fix came in three parts: **build the toolkit, migrate the critical modules, audit the rest**.

**Part 1: The toolkit.** I built the new `libp2p/utils/paths.py` with 15 functions built on `pathlib` and Python's `tempfile` module. The key ones:

- `create_temp_file(prefix, suffix)` — creates a temp file using `tempfile.gettempdir()`, never hardcoding a directory
- `get_temp_dir()` — wraps `tempfile.gettempdir()` as a `Path`
- `join_paths(*parts)` — cross-platform path joining via `pathlib`
- `get_script_dir(path)` — replaces the `os.path.dirname(os.path.abspath(__file__))` pattern
- `get_config_dir()` — returns `~/.config/py-libp2p` on Unix, `%APPDATA%/py-libp2p` on Windows
- `find_executable(name)` / `get_binary_path(name)` — venv-aware binary resolution

Every function returns a `Path` object. No strings, no separators, no platform branches at the call site.

**Part 2: Migration.** The logging module's hardcoded temp path became a single line:

```diff
-        if os.name == "nt":  # Windows
-            log_file = f"C:\\Windows\\Temp\\py-libp2p_{timestamp}_{unique_id}.log"
-        else:  # Unix-like
-            log_file = f"/tmp/py-libp2p_{timestamp}_{unique_id}.log"
+        from libp2p.utils.paths import create_temp_file
+        log_file = str(create_temp_file(prefix="py-libp2p_", suffix=".log"))
```

Six lines of platform branching replaced by one function call. The kademlia example got a similar treatment:

```diff
-SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
-SERVER_ADDR_LOG = os.path.join(SCRIPT_DIR, "server_node_addr.txt")
+SCRIPT_DIR = get_script_dir(__file__)
+SERVER_ADDR_LOG = join_paths(SCRIPT_DIR, "server_node_addr.txt")
```

I also added proper handler cleanup in the logging module — closing `FileHandler` instances on exit — which prevents file-lock issues on Windows where open files can't be deleted.

**Part 3: The audit script.** I wrote `scripts/audit_paths.py` to scan the entire codebase for six anti-patterns: hardcoded `/tmp`, `os.path.join()`, `os.path.dirname()`, `os.path.abspath()`, string path concatenation, and hardcoded forward slashes. It outputs a priority matrix — P0 for hardcoded temp paths, P1 for `os.path` usage, P2 for style inconsistencies — so the next contributor knows exactly where to start.

*The audit script identifies remaining path anti-patterns and prioritizes them for migration in future PRs.*

![Audit pipeline](/img/blog/py-libp2p-tmp-path-windows/diagram-02-audit-pipeline.png)

## Before & After

| | Before | After |
|---|---|---|
| Temp file creation | Hardcoded `/tmp` or `C:\Windows\Temp` | `create_temp_file()` via `tempfile` |
| Script directory | `os.path.dirname(os.path.abspath())` | `get_script_dir(__file__)` |
| Path joining | `os.path.join()` (string-based) | `join_paths()` (pathlib-based) |
| Config directory | Not standardized | `get_config_dir()` (per-platform) |
| File handle cleanup | Missing on exit | Explicit `FileHandler.close()` |
| Remaining issue discovery | Manual | `audit_paths.py` with priority matrix |
| Test coverage | No path utility tests | 19 tests across 3 test classes |
| Platform verification | Linux only | Linux + macOS + Windows 10 |

## Lessons Learned

**Build the toolkit before you migrate.** PR #792 tried to introduce utilities and migrate code in the same breath — it stalled. My PR succeeded by first completing the `paths.py` module with comprehensive tests, then migrating modules one by one. When the utility layer is solid and tested, each migration becomes a trivial find-and-replace. The temptation is to "just fix the one broken path," but that leads to fifteen one-off fixes instead of one reusable abstraction.

**An audit script is a gift to your future self.** The `audit_paths.py` script doesn't just find current problems — it prevents regressions. Any contributor can run it before opening a PR. It transforms "did I miss any hardcoded paths?" from a manual code review question into an automated check. The script found six categories of path anti-patterns and ranked them by severity. That priority matrix became the roadmap for future work.

## Conclusion

This PR eliminates the class of bugs where py-libp2p silently fails on non-Linux platforms because someone wrote `/tmp` instead of using `tempfile`. With 668 tests passing across Linux, macOS, and Windows, the library's cross-platform story went from "works on my machine" to verified on three. The audit script ensures this stays true. Sometimes the most impactful refactoring isn't glamorous — it's replacing six lines of platform branching with one function call that does the right thing everywhere.

## Resources

- [PR #886 — Cross-Platform Path Handling Standardization](https://github.com/libp2p/py-libp2p/pull/886)
- [Issue #882 — Standardize cross-platform path handling](https://github.com/libp2p/py-libp2p/issues/882)
- [Python pathlib Documentation](https://docs.python.org/3/library/pathlib.html)
- [Real Python: Python's pathlib Module](https://realpython.com/python-pathlib/)
- [py-libp2p Documentation](https://py-libp2p.readthedocs.io/en/stable/)

If you would like to contribute, please [connect with the libp2p maintainers](@/get-involved/_index.md).
