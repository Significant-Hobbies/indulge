#!/bin/zsh
set -euo pipefail

if [[ "$(git branch --show-current)" != "main" ]]; then
  print -u2 "Deploy blocked: production deploys must run from main."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  print -u2 "Deploy blocked: the worktree is not clean."
  exit 1
fi

git fetch origin main
local_head="$(git rev-parse HEAD)"
remote_head="$(git rev-parse origin/main)"
if [[ "$local_head" != "$remote_head" ]]; then
  print -u2 "Deploy blocked: local main does not match origin/main."
  exit 1
fi

if command -v gh >/dev/null 2>&1; then
  conclusion="$(gh run list --branch main --commit "$local_head" --workflow web-ci.yml --json conclusion --jq '.[0].conclusion // empty')"
  if [[ "$conclusion" != "success" ]]; then
    print -u2 "Deploy blocked: web CI is not green for current main ($local_head)."
    exit 1
  fi
else
  print -u2 "Deploy blocked: GitHub CLI is required to verify CI."
  exit 1
fi

pnpm check
pnpm exec wrangler pages deploy dist --project-name indulge --branch main --commit-hash "$local_head" --commit-dirty=false
