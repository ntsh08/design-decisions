---
name: design-decisions
description: Keep a shared log of UX/UI design decisions in a decisions/ folder so the next designer knows why things are the way they are. Use when the project has a decisions/ folder, when the user makes or reverses a design decision (flow, information architecture, naming, visual rule, interaction, content, removing a feature), picks one option out of several you showed, asks "why is it like this?", hands a project over, wraps up a work session, or says "log this". Proposes entries and asks when unsure; never invents the reasoning and never credits the agent.
metadata:
  version: "1.1.0"
---

# Design decisions

A decision log for designers. Each decision is one Markdown file in `decisions/`, kept in git so several people (and their Claudes) share it. It records **why** a design choice was made, what was rejected, and what the next designer must not undo.

Inspired by Architecture Decision Records (ADRs) and the design-log methodology, adapted for product design and handoff.

## Whose reasoning this is

The log shows the **designer's** thinking. It is often read by reviewers, hiring managers and clients, so a reason that isn't theirs misrepresents them.

- The Why holds only the decision-maker's reasoning, in their words: `<Name>: <their reason>`.
- Never write "Claude suggested", "the agent recommended", "X accepted it", or any version of who proposed it. If you proposed the option and they picked it, ask **why they picked it** and log that.
- Never put your own rationale in the Why, Evidence or Rejected options, even when it seems obviously right. Describe rejected options neutrally, without saying who raised them.
- If they don't give a reason, write `Not stated`. Never fill the gap with yours.

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

Use the script's absolute path inside this skill's folder. If the project isn't a git repo, create `decisions/README.md` (from `templates/index.md`) by hand and tell the user it isn't shared yet.

An optional SessionStart hook can run the same script at the start of every session, which also pulls teammates' new decisions. A project opts out by containing a `.no-decisions` file.

## Before you work

- If it's a git repo, `git pull` first.
- Read `decisions/README.md`. Before changing a screen, read the Active entries that list that screen.
- If a requested change goes against an Active decision or its guardrails, say so **before** doing it:
  > This goes against "One Saved list". Its guardrail says no second save action. Replace that decision, or keep it?
- If there are open questions from an earlier session (reasons still `Not stated`, candidates never answered), raise them once, at the start, in one block.

## When to log

Sort every design change into one of three buckets.

### Log it (propose an entry)

All three are true:
1. **It's a choice.** One option was picked over another, even if the other was never said out loud.
2. **It shapes the product.** It changes what users see or do, or how designers must work.
3. **Someone new would ask "why?"** A designer joining in 3 months could undo it without knowing.

Strong signals:
- Words like "let's go with", "instead of", "from now on", "never", "always", "drop", "rename", "we decided".
- **You showed options (A/B/C, directions, variants) and the user picked one.** That is a decision even if nobody says "decided".
- The user rejects something you built and says what they want instead.
- A flow, tab, screen, modal or feature is added, merged, split, or removed.
- A term is chosen or banned ("workspace", never "project").
- A visual or interaction rule that applies everywhere ("no modals on first launch", "primary buttons are full-width on mobile").
- A design-system file (`DESIGN.md`, tokens, type scale, colours) gains or changes a rule.
- A choice that follows from research: an interview, a test, a competitor study.
- Reversing or changing an earlier logged decision.

Interface decisions count as much as scope decisions. Modals, empty states, defaults, what a card shows, who can do what: these are the ones most often missed.

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

## Don't miss decisions: the sweep

Fast iteration is where decisions get lost. Keep a running list of candidates as you work, and run a sweep:

- when the user wraps up ("done", "that's it", "push it", end of a work block),
- after a long run of design changes with no log entry,
- before a handoff or submission.

The sweep: go back over the changes since the last entry, list every choice that passes "Log it", and ask about them together. Say how many you found. If there are none, say nothing.

## How to ask

Don't interrupt the work. Finish the task, then add **one** short block at the end of your reply. Each question must be answerable days later by someone who doesn't remember the conversation:

- Name the screen and the element in plain words ("the refund confirmation modal"), never an internal label ("G3", "option B", "v2").
- Say what was picked and what it was picked over.
- Attach or link the screenshot or option board if there is one.
- Ask for their reason. If you can guess it from what they said, show the guess as a question for them to confirm or correct, never as the answer.

> **Log decision?**
> 1. Refund confirmation: a modal instead of an inline confirm (Interaction). Why did you go with the modal?
> 2. Ticket list sorted by due time, not by created time (IA). From the interview: late first replies get escalated. Is that your reason?
>
> Yes / edit / skip, per line

- If the user says skip, don't ask about it again.
- If they answer some and not others, keep the rest as open questions and raise them at the next session start. Don't store them in a separate file nobody reads.
- The user can also say "log that" at any time. Treat that as a yes.

## Writing an entry

1. File name: `decisions/short-slug.md` (for example `ticket-statuses.md`). If the slug is taken, make it more specific. Add a date prefix only if the project's index already uses one.
2. Fill in `templates/entry.md`. Keep the header as a bullet list so it renders on GitHub.
3. **Why** comes from the person (see "Whose reasoning this is"). Ask once if missing; otherwise `Not stated`.
4. **Evidence**: if the project has research files (interviews, notes, competitor studies), check whether the decision traces to one and propose it. The person confirms the link. If nothing applies, write "Designer judgement".
5. **Confidence, Guardrails and Revisit when** are often drafted by you. Mark them `(draft)` in the preview so the person can see which parts aren't theirs yet. Remove the mark once they approve.
6. **Decided by** is a real person's name (from `git config user.name` or ask). Never the agent.
7. **Links** go only to files that exist in the repo or URLs the user gave you. Check that each link resolves before writing it. Don't link to Figma page names, chat messages or files that may be removed.
8. Show the draft. Write the file only after a yes.
9. Add a row to the right section of `decisions/README.md`. The index is grouped by area (for example Scope, Flows, Workspace, Visual), not by date. Create a section if none fits.
10. Screenshots go in `decisions/assets/`, created only when there's a screenshot to save.

## Keeping entries current

An entry that no longer matches the product is worse than none.

- Before changing a screen, check the entries that list it. After the change, update any entry it affects **in the same commit**: renamed buttons, removed lines, changed behaviour.
- A correction or refinement of the same decision is an edit to the entry, not a new one. Tell the user what you changed.
- A real reversal (a different choice, for a different reason) is a new decision. Handle it as below.

## Replacing a decision

Ask the user which they want, once per project, and follow it after that:

- **Keep history** (default): in the old entry set `Status: Superseded by <new file>`; in the new entry set `Supersedes: <old file>` and say what changed and why. Move the old row to a "Superseded" section at the bottom of the index.
- **Clean log**: delete the old entry and remove its row. The new entry's `Supersedes` line names what it replaced in one sentence. Git keeps the history.

## Sharing through git

- Pull before reading or writing.
- Commit each decision on its own: `decision: <title>`.
- The user's yes to an entry covers writing, committing, and pushing it. Push right away so teammates see it.
- If `README.md` has a merge conflict, keep both rows in their sections.

## Answering "why is it like this?"

Search `decisions/` first and answer with the entry, linking its file. If nothing is logged, say so plainly, and offer to log it if the user knows the reason. Never answer with a reason you made up.
