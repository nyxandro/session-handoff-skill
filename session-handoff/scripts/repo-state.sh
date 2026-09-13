#!/usr/bin/env bash
# Repository state for a session handoff document and for checking one on receipt.
# Usage: repo-state.sh [project folder]   (defaults to the current folder)
# Read-only. Whatever it could not check, it says so instead of guessing.
set -u

dir="${1:-.}"
cd "$dir" || { echo "Folder not found: $dir"; exit 1; }
echo "Folder: $(pwd)"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository: no version history; leave branch and commits out of the document."
  exit 0
fi

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "detached@$(git rev-parse --short HEAD)")
echo "Branch: $branch"
echo "HEAD: $(git log -1 --format='%h %ad %s' --date=short)"

# Comparison with upstream uses the last fetch: the script does not contact the server.
if upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
  read -r behind ahead < <(git rev-list --left-right --count "$upstream...HEAD")
  echo "Upstream: $upstream (unpushed commits: $ahead, not pulled: $behind; as of last fetch)"
  if [ "$ahead" -gt 0 ]; then
    git log "$upstream..HEAD" --format='  %h %ad %s' --date=short | head -20
  fi
else
  echo "Upstream: not configured, unpushed commits cannot be determined"
fi

status=$(git status --porcelain=v1 --untracked-files=all)
if [ -z "$status" ]; then
  echo "Working tree: clean"
else
  total=$(printf '%s\n' "$status" | wc -l)
  echo "Working tree: uncommitted files: $total (first 30 shown; XY codes as in git status --porcelain)"
  printf '%s\n' "$status" | head -30 | sed 's/^/  /'
fi

echo "Stash entries: $(git stash list | wc -l)"

echo "Worktrees:"
git worktree list | sed 's/^/  /'

echo "Most recently active branches (6):"
git for-each-ref --sort=-committerdate --count=6 \
  --format='  %(refname:short)  %(committerdate:short)  %(subject)' refs/heads

echo "Last commits (5):"
git log -5 --format='  %h %ad %an: %s' --date=short

if command -v gh >/dev/null 2>&1 && git remote get-url origin 2>/dev/null | grep -q github; then
  if prs=$(timeout 15 gh pr list --head "$branch" --state open \
      --json number,title,isDraft,url \
      --template '{{range .}}  #{{.number}} {{if .isDraft}}[draft] {{end}}{{.title}}  {{.url}}{{"\n"}}{{end}}' 2>&1); then
    if [ -n "$prs" ]; then
      echo "Open PRs from this branch:"
      printf '%s\n' "$prs"
    else
      echo "Open PRs from this branch: none"
    fi
  else
    echo "Open PRs: could not check (gh: $(printf '%s' "$prs" | head -1))"
  fi
else
  echo "Open PRs: not checked (no gh, or remote is not GitHub)"
fi
