#!/usr/bin/env bash
# SessionStart hook — load working memory + current branch into context, so a fresh
# cloud session starts knowing the guide's state instead of amnesiac. Filesystem and
# git only; never the network (mirrors the guide's own memory-loading hook).
set -euo pipefail

if [ -f MEMORY.md ]; then
  echo "===== MEMORY.md (repo working memory) ====="
  cat MEMORY.md
  echo
fi

echo "===== current git branch ====="
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(not a git checkout)"
