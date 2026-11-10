# design-decisions

A Claude skill that keeps a **design decision log** for every project, so the next designer (or PM, or you in six months) knows *why* the product looks and works the way it does.

Engineers have Architecture Decision Records (ADRs). Designers usually have a Figma file, a Slack thread, and a memory. This skill gives design work the same kind of record, written by Claude while you work and shared with your team through git.

## What it does

- **Logs decisions as you work.** When you settle a flow, rename something, set a visual rule, or cut a feature, Claude proposes a short entry. You approve it with one word.
- **Asks when unsure.** Tentative changes ("let's try…") or missing reasons get a question, not a guess. Small tweaks are skipped.
- **Never invents the why, and never credits itself.** Reasons come from you, in your words. If Claude proposed an option and you picked it, it asks why you picked it. No reason given → the entry says `Not stated`.
- **Catches the decisions you'd miss.** Picking one of several options counts as a decision, and a sweep at the end of a work session lists anything not yet logged.
- **Asks questions you can answer later.** Each one names the screen and element in plain words, not internal labels.
- **Keeps entries current.** When a screen changes, the entries that cover it are updated in the same commit.
- **Warns before undoing a decision.** If someone asks for a change that goes against a logged decision, Claude points it out first.
- **Your choice of history.** Replaced decisions are either kept as *Superseded* or deleted for a clean log (git still has them).
- **Only where you want it.** A project gets a `decisions/` folder only when you ask for one. It lives at the project root and is shared through git.

## What an entry looks like

```md
# One Saved list instead of Favorites + Bookmarks

- **Status:** Active
- **Type:** IA
- **Decided by:** Priya
- **Screens:** Home, Saved tab, Item sheet
- **Link:** ../screens/saved.png
- **Supersedes:** none

## Problem
Users had two ways to keep an item and couldn't tell them apart.

## Decision
One "Saved" list with filter chips.

## Why
Priya: two save actions meant two mental models for one intent.

## Evidence
5 of 6 usability sessions hesitated between the two.   Confidence: High

## Rejected options
- Keep both, explain with labels → still two concepts.

## Guardrails for the next designer
- Don't add a second save action (likes, hearts, wishlist).

## Revisit when
Users ask for named collections.
```

Full template: [`templates/entry.md`](templates/entry.md). Each project also gets an index, `decisions/README.md`, grouped by area, with one row per decision.

## How it decides what to log

A change gets logged when all three are true:

1. **It's a choice:** one option was picked over another.
2. **It shapes the product:** it changes what users see or do.
3. **Someone new would ask "why?"**

Tie-breaker: *if someone new undid this in 3 months, would it hurt?* Yes → log. Don't know → ask. No → skip.

Claude finishes the task first, then asks in one line at the end of its reply:

> **Log decision?**
> 1. Saved tab: one "Saved" list instead of Favorites + Bookmarks (IA). Why did you merge them?
>
> Yes / edit / skip

## Install

### Claude Code (CLI or the desktop app's Code tab)

Install it once per machine, for all your projects:

```bash
npx skills add ntsh08/design-decisions -g -a claude-code
```

(Without `-g` it installs into the current project only.) Or, without npx:

```bash
git clone https://github.com/ntsh08/design-decisions ~/.claude/skills/design-decisions
```

Then, in each project, say "set up a decision log" once and Claude creates `decisions/`, shares the skill with the repo, and pushes.

### Optional: keep logs synced automatically

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

Then, whenever a session starts in a git repo inside that folder that already has a `decisions/` log, the hook:

1. Pulls, so teammates' new decisions are there.
2. Refreshes the project's copy of the skill if your installed version is newer, then commits and pushes that.

It never creates a log. Projects without `decisions/` are left alone until you ask Claude to set one up. Repos outside the folder are never touched, and an empty `.no-decisions` file keeps a project out completely.

### Claude apps (web, desktop chat, mobile)

Zip this folder and upload it under **Settings → Capabilities → Skills**. The chat apps can't run git, so there Claude drafts entries for you to add to the repo yourself.

## Working with teammates

Because setup copies the skill into the project, **anyone who clones the repo gets it.** Their Claude Code reads the same log and follows the same rules, with no install needed. Entries are named with a short slug (`one-saved-list.md`); if a slug is taken, Claude makes it more specific.

## Updating

- **Installed with `npx skills add -g`:** run `npx skills update -g`.
- **Installed with `git clone`:** run `git pull` inside `~/.claude/skills/design-decisions`.
- **Copy inside a project:** if you also use the hook, it refreshes the project's copy automatically when your installed version is newer, and teammates get it on their next pull. Otherwise rerun `bin/setup.sh <folder>` from the newer copy.
- **If someone has it installed globally,** Claude Code prefers that copy over the one in the project. Both work; the global one decides the rules.

## Credits

Built on the idea of [Architecture Decision Records](https://adr.github.io/) and the [design-log methodology](https://github.com/yoavaa/design-log-methodology). Inspired by [design-log](https://www.skills.sh/denysdovhan/agents/design-log), which does this for engineering decisions; this skill adapts it for product design and designer handoff.

## License

MIT
