#!/usr/bin/env python3
"""Checks `zola build` does not make. Run from the repo root; exits 1 on any finding.

1. U+FFFD in content/ or templates/: text that was saved through the wrong encoding.
2. An image or video a page points at (Markdown image, <img src>, header_image,
   header_video) that is not in static/. Zola does not validate these paths.
"""

import re
import sys
from pathlib import Path

ASSET = re.compile(
    r'!\[[^\]]*\]\(\s*(/?img/[^)\s]+)'  # ![alt](/img/x.png)
    r'|<img[^>]+src="(/?img/[^"]+)"'  # <img src="/img/x.png">
    r'|^header_(?:image|video)\s*=\s*"([^"]+)"',  # front matter
    re.M,
)

problems = []
for path in sorted([*Path("content").rglob("*.md"), *Path("templates").rglob("*.html")]):
    text = path.read_text(encoding="utf-8", errors="replace")
    for n, line in enumerate(text.splitlines(), 1):
        if "�" in line:
            problems.append(f"{path}:{n}: corrupted character (U+FFFD)")
    if path.suffix != ".md":
        continue
    for m in ASSET.finditer(text):
        ref = next(g for g in m.groups() if g)
        if not ref.startswith("http") and not (Path("static") / ref.lstrip("/")).is_file():
            n = text.count("\n", 0, m.start()) + 1
            problems.append(f"{path}:{n}: {ref} is not in static/")

print("\n".join(problems) or "content checks: ok")
sys.exit(1 if problems else 0)
