#!/bin/bash
# Sets up a design decision log in the current git project and keeps it synced.
# Runs from a Claude Code SessionStart hook; safe to run on every session.
#
# Usage: setup.sh <folder>[:<folder>...]
# Only repos inside the given folders are touched (or DECISIONS_ROOTS if no
# argument). With neither, it does nothing.
# Opt out per project with a .no-decisions file at the repo root.

set -u
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOTS="${1:-${DECISIONS_ROOTS:-}}"
[ -n "$ROOTS" ] || exit 0

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

in_scope=
for r in $(printf '%s' "$ROOTS" | tr ':' ' '); do
  case "$root/" in "${r%/}/"*) in_scope=1 ;; esac
done
[ -n "$in_scope" ] || exit 0
[ -e "$root/.no-decisions" ] && exit 0
cd "$root" || exit 0

has_upstream() { git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; }

say() {
  if [ -n "$1" ]; then
    printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1" "$2"
  else
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$2"
  fi
}

# Pull teammates' decisions first.
if has_upstream; then
  git pull --ff-only --quiet >/dev/null 2>&1 || true
fi

if [ -d decisions ]; then
  say "" "This project keeps a design decision log in decisions/. Follow the design-decisions skill."
  exit 0
fi

name=$(basename "$root")
mkdir -p decisions/assets .claude/skills/design-decisions
sed "s/<Project name>/$name/" "$SKILL_DIR/templates/index.md" > decisions/README.md
touch decisions/assets/.gitkeep

# Ship the skill with the project so teammates' Claude picks it up on clone.
cp "$SKILL_DIR/SKILL.md" .claude/skills/design-decisions/
cp -R "$SKILL_DIR/templates" .claude/skills/design-decisions/

paths="decisions .claude/skills/design-decisions"

# Point CLAUDE.md at the log, but never touch a CLAUDE.md with uncommitted edits.
line='Design decisions: read decisions/README.md before design work and follow the design-decisions skill.'
if [ ! -e CLAUDE.md ]; then
  printf '%s\n' "$line" > CLAUDE.md
  paths="$paths CLAUDE.md"
elif git ls-files --error-unmatch CLAUDE.md >/dev/null 2>&1 \
  && git diff --quiet -- CLAUDE.md && git diff --cached --quiet -- CLAUDE.md \
  && ! grep -q 'decisions/README.md' CLAUDE.md; then
  printf '\n%s\n' "$line" >> CLAUDE.md
  paths="$paths CLAUDE.md"
fi

for p in $paths; do git add -- "$p" >/dev/null 2>&1 || true; done
# Commit only these paths, leaving anything else the user has staged alone.
git commit --quiet -m "decisions: set up log" -- $paths >/dev/null 2>&1 || {
  say "Design decision log created in decisions/ but not committed." "A decisions/ log was just created for this project but the commit failed. Mention it to the user."
  exit 0
}

if has_upstream && git push --quiet >/dev/null 2>&1; then
  say "Design decision log set up in decisions/ and pushed." "A decisions/ log was just set up for this project and pushed. Follow the design-decisions skill."
else
  say "Design decision log set up in decisions/ and committed. Not pushed: no remote branch." "A decisions/ log was just set up and committed but not pushed (no upstream). Tell the user once."
fi
