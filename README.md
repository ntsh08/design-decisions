# design-decisions

A Claude skill that keeps a **design decision log** for every project, so the next designer (or PM, or you in six months) knows *why* the product looks and works the way it does.

Engineers have Architecture Decision Records (ADRs). Designers usually have a Figma file, a Slack thread, and a memory. This skill gives design work the same kind of record, written by Claude while you work and shared with your team through git.

## What it does

- **Logs decisions as you work.** When you settle a flow, rename something, set a visual rule, or cut a feature, Claude proposes a short entry. You approve it with one word.
- **Asks when unsure.** Tentative changes ("let's try…") or missing reasons get a question, not a guess. Small tweaks are skipped.
- **Never invents the why.** Reasons and evidence come from you. If you don't give one, the entry says `Not stated`.
- **Warns before undoing a decision.** If someone asks for a change that goes against a logged decision, Claude points it out first.
- **Keeps history.** Old decisions are marked *Superseded*, never deleted.
- **One log per project,** in a `decisions/` folder at the project root, shared through git.

## What an entry looks like

```md
# One Saved list instead of Favorites + Bookmarks

Status: Active          Type: IA
Date: 2026-03-12        Decided by: Priya
Screens: Home, Saved tab, Item sheet

## Problem
Users had two ways to keep an item and couldn't tell them apart.

## Decision
One "Saved" list with filter chips.

## Why
Two save actions = two mental models for one intent.

## Evidence
5 of 6 usability sessions hesitated between the two.   Confidence: High

## Rejected options
- Keep both, explain with labels → still two concepts.

## Guardrails for the next designer
- Don't add a second save action (likes, hearts, wishlist).

## Revisit when
Users ask for named collections.
```

Full template: [`templates/entry.md`](templates/entry.md). Each project also gets an index, `decisions/README.md`, with one row per decision.

## How it decides what to log

A change gets logged when all three are true:

1. **It's a choice:** one option was picked over another.
2. **It shapes the product:** it changes what users see or do.
3. **Someone new would ask "why?"**

Tie-breaker: *if someone new undid this in 3 months, would it hurt?* Yes → log. Don't know → ask. No → skip.

Claude finishes the task first, then asks in one line at the end of its reply:

> **Log decision?** "One Saved list instead of Favorites + Bookmarks" (IA). Why: two save actions confused users. Yes / edit / skip

## Install

### Claude Code (CLI or the desktop app's Code tab)

```bash
git clone https://github.com/ntsh08/design-decisions ~/.claude/skills/design-decisions
```

That's enough to use it. In a project, say "set up a decision log" and Claude creates `decisions/`.

### Optional: set up every project automatically

Add a SessionStart hook to `~/.claude/settings.json`. Replace `~/projects` with the folder that holds your projects (separate several with `:`):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/skills/design-decisions/bin/setup.sh ~/projects 2>/dev/null || true",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

Then, whenever a session starts in a git repo inside that folder, the hook:

1. Pulls, so teammates' new decisions are there.
2. If the project has no log yet: creates `decisions/`, copies the skill into `.claude/skills/design-decisions/`, and adds one pointer line to `CLAUDE.md` (skipped if `CLAUDE.md` has uncommitted edits).
3. Commits only those files and pushes, if the branch has a remote.

Repos outside the folder are never touched. To keep one project out, add an empty `.no-decisions` file at its root.

> Heads-up: the first session in each existing repo will push a commit. If a repo auto-deploys on push, that triggers a deploy.

### Claude apps (web, desktop chat, mobile)

Zip this folder and upload it under **Settings → Capabilities → Skills**. The chat apps can't run git, so there Claude drafts entries for you to add to the repo yourself.

## Working with teammates

Because the hook copies the skill into each project, **anyone who clones the repo gets it.** Their Claude Code reads the same log and follows the same rules, with no install needed. Entries are named by date (`2026-03-12-one-saved-list.md`), so two people never pick the same file name.

## Updating

- **Installed with `git clone`:** run `git pull` inside `~/.claude/skills/design-decisions`.
- **Copy inside a project:** if you also use the hook, it refreshes the project's copy automatically when your installed version is newer, and teammates get it on their next pull. Otherwise rerun `bin/setup.sh <folder>` from the newer copy.
- **If someone has it installed globally,** Claude Code prefers that copy over the one in the project. Both work; the global one decides the rules. Each entry records the skill version that wrote it (`Skill version:`), so mixed versions stay readable.

## Credits

Built on the idea of [Architecture Decision Records](https://adr.github.io/) and the [design-log methodology](https://github.com/yoavaa/design-log-methodology). Inspired by [design-log](https://www.skills.sh/denysdovhan/agents/design-log), which does this for engineering decisions; this skill adapts it for product design and designer handoff.

## License

MIT
