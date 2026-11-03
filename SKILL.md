---
name: design-decisions
description: Keep a shared log of UX/UI design decisions in a decisions/ folder so the next designer knows why things are the way they are. Use when the project has a decisions/ folder, when the user makes or reverses a design decision (flow, information architecture, naming, visual rule, interaction, content, removing a feature), asks "why is it like this?", hands a project over, or says "log this". Proposes entries and asks when unsure; never invents the reasoning.
metadata:
  version: "1.0.0"
---

# Design decisions

A decision log for designers. Each decision is one Markdown file in `decisions/`, kept in git so several people (and their Claudes) share it. It records **why** a design choice was made, what was rejected, and what the next designer must not undo.

Inspired by Architecture Decision Records (ADRs) and the design-log methodology, adapted for product design and handoff.

## One log per project

Each project keeps its own log in `decisions/` at the project root (next to its `README.md`, `CLAUDE.md`, or `.git`). The skill is installed once; the logs live with each project.

- Read and write only the current project's log. Never log a decision in another project's folder.
- If the session spans several projects, or you can't tell which project a decision belongs to, ask before writing.
- A decision that applies to several projects goes in each project's log, linking to the others.

## Setup

`bin/setup.sh` does the whole setup: it creates `decisions/` with an index named after the project, copies this skill into the project's `.claude/skills/design-decisions/` (so teammates' Claude gets it on clone, even without installing it), adds a pointer line to `CLAUDE.md`, commits, and pushes. If the project's copy of the skill is older than this one, it refreshes it.

Run it when the user asks to set up a log, or when you start design work in a project that has no `decisions/` folder:

```
bin/setup.sh "$(git rev-parse --show-toplevel)"
```

Use the script's absolute path inside this skill's folder. If the project isn't a git repo, create `decisions/README.md` (from `templates/index.md`) and `decisions/assets/` by hand and tell the user it isn't shared yet.

An optional SessionStart hook can run the same script at the start of every session, which also pulls teammates' new decisions. A project opts out by containing a `.no-decisions` file.

## Before you work

- If it's a git repo, `git pull` first.
- Read `decisions/README.md`. Before changing a screen, read the Active entries that list that screen.
- If a requested change goes against an Active decision or its guardrails, say so **before** doing it:
  > This goes against "One Saved list" (2026-03-12). Its guardrail says no second save action. Supersede it, or keep it?

## When to log

Sort every design change into one of three buckets.

### Log it (propose an entry)

All three are true:
1. **It's a choice.** One option was picked over another, even if the other was never said out loud.
2. **It shapes the product.** It changes what users see or do, or how designers must work.
3. **Someone new would ask "why?"** A designer joining in 3 months could undo it without knowing.

Strong signals:
- Words like "let's go with", "instead of", "from now on", "never", "always", "drop", "rename", "we decided".
- The user rejects something you built and says what they want instead.
- A flow, tab, screen, or feature is added, merged, split, or removed.
- A term is chosen or banned ("workspace", never "project").
- A visual or interaction rule that applies everywhere ("no modals on first launch", "primary buttons are full-width on mobile").
- A decision informed by user research or testing.
- Reversing an earlier logged decision.

### Ask (unsure)

- It sounds tentative: "let's try", "for now", "maybe".
- It's small but could set a pattern for other screens.
- The reason wasn't stated and you can't tell if it was considered.
- You can't tell whether the user decided it or is still exploring.
- It's unclear who made the call.

### Skip it

- Tweaks inside existing rules: spacing, colour nudges within tokens, copy typos.
- Bug fixes that restore intended behaviour.
- Explorations that weren't chosen (unless the rejection itself is the decision).
- Things already logged.

**Tie-breaker:** *If someone new undid this in 3 months, would it hurt?* Yes → log. Don't know → ask. No → skip.

## How to ask

Don't interrupt the work. Finish the task, then add **one** short block at the end of your reply:

> **Log decision?** "One Saved list instead of Favorites + Bookmarks" (IA). Why: two save actions confused users. Yes / edit / skip

- Put several candidates in the same block, one line each.
- If the user says skip, don't ask about it again.
- If the user is in the middle of fast iteration, hold candidates and ask once at a natural pause or when they wrap up.
- The user can also say "log that" at any time. Treat that as a yes.

## Writing an entry

1. File name: `decisions/YYYY-MM-DD-short-slug.md`. Use dates, not running numbers, so two people never pick the same name.
2. Fill in `templates/entry.md`. Set `Skill version` to the `version` in this skill's frontmatter, so a later reader can tell which rules wrote the entry.
3. **Never invent the why or the evidence.** Use only what the person said. If it's missing, ask once. If they don't answer, write `Not stated`.
4. **Decided by** is a real person's name (from `git config user.name` or ask). If an agent proposed it and a person approved it, write the person.
5. Show the draft. Write the file only after a yes.
6. Add a row to the top of the table in `decisions/README.md`.
7. Save before/after screenshots to `decisions/assets/` when they exist.

## Superseding

Never delete or rewrite an old entry. The history is the point.

1. In the old entry, set `Status: Superseded by <new file>`.
2. In the new entry, set `Supersedes: <old file>` and say what changed and why.
3. Update both rows in the index.

## Sharing through git

- Pull before reading or writing.
- Commit each decision on its own: `decision: <title>`.
- The user's yes to an entry covers writing, committing, and pushing it. Push right away so teammates see it.
- If `README.md` has a merge conflict, keep both rows, newest first.

## Answering "why is it like this?"

Search `decisions/` first and answer with the entry, linking its file. If nothing is logged, say so plainly, and offer to log it if the user knows the reason.
