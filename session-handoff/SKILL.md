---
name: session-handoff
description: >
  Hand unfinished work from one agent session to the next with a single document: at the end
  of a session, write it so the owner can copy the text into the chat of a new session; at the
  start of a new session, receive such a document, check it against the real repository state,
  and brief the owner in a few lines. Always use it when the owner asks for a prompt for a new
  session or for a handoff, in any wording: "write a prompt for a new session", "a detailed
  prompt with every nuance, I'll copy it and send it to the agent", "your context is about to
  run out, write down all the details", "I want to start a new session, write everything down
  so nothing gets lost", "do a handoff", "session handoff". Also use it when the owner opens a
  session with "I'm in a new session, here's the context", "let's continue, here's the
  document", "study it and let's discuss", or pastes a document whose first line names
  session-handoff. The owner may phrase any of this in another language; match on meaning.
metadata:
  version: "1.0.0"
---

# Session handoff

Sessions run out of context or get compacted, and the owner continues the work in a new one.
A document assembled from scratch every time loses something different every time: branch
state, the owner's prohibitions, the task scope. This skill keeps one structure, takes facts
from commands rather than from memory, and receives the document with verification instead of
trust.

Write the document in the language the owner uses with you. Translate the template headings
into that language as well, keeping their order and meaning; only the token `session-handoff`
in the first line stays as it is, so the receiving side can recognise the document.

## Which side you are on

- The owner asks to write a document or a prompt for a new session: section "Write".
- The owner pasted a handoff document and asks to study it or continue: section "Receive".
- Both sides take repository facts from `scripts/repo-state.sh` in this skill's folder. It
  changes nothing and says plainly what it could not check.

## Write

### 1. Pin down the focus

The argument after the command, or the owner's words in the request, define what the next
session is for. Write the document for that focus: what matters for it stays, the rest shrinks
to a link. If no focus is named, take the current unfinished thread of work and name it in
"The gist in five lines". Do not ask the owner; they expect the finished text.

### 2. Capture the repository state with the script

Run `bash <skill folder>/scripts/repo-state.sh <project folder>` and carry the branch, HEAD,
uncommitted and unpushed changes, and open PRs from its output into the document. Written from
memory, this section was the one most often wrong, so it is filled only from the command.

Anything in the working tree that you did not change in this session counts as someone else's
edits: the owner often works in parallel through another agent or in another branch. List such
files by name, marked "do not touch". Otherwise the next agent takes them for its own and
commits or reverts them.

### 3. Collect from the session

- **How it started**: the original problem with facts and dates, in the owner's words. Not
  "refactor module X" but what exactly broke and for whom.
- **The owner's decisions and prohibitions**: close to a quote. A rephrased prohibition has
  already lost its meaning once, and the owner explicitly forbade "improving the wording" of the
  previous session. Not like this: "be careful with CI for now". Like this: "Do not run CI and
  do not push to the PR branch until the owner confirms".
- **Task scope** exactly as agreed. Do not widen it, narrow it, or carry over "useful
  neighbouring" work. Scope changes are the owner's decision, not the document's.
- **Done, do not redo**: every item with evidence that can be checked: commit SHA, test file,
  PR number, date. An item without evidence goes on a separate line under "Assumed, verify".
  The next agent reads the document as a contract and does not re-check it, so a confident
  "done" without evidence becomes a false premise for all the work that follows. Not like this:
  "company search reworked from tax ID to a group of legal entities". Like this: "12.09 company
  search accepts a group of legal entities, not only a tax ID — commit a1b2c3d, test
  company-resolution.test.ts".
- **What to read first**: paths to files with item codes and their statuses, not a retelling
  of those files.
- **Skills for the next agent**: which skills this task needs and why, one line each. A fresh
  agent will not think of them on its own.

### 4. What does not go into the document

- Secret values: passwords, tokens, keys, connection strings. Only the path to the file where
  they live.
- Standing facts about the project that will still be true in a month: how deployment works,
  where the test database is, what is forbidden on the shared server. Their place is agent
  memory and project rules. If such a fact surfaced in the session for the first time, save it
  there and leave a one-line pointer in the document. The document carries only work in flight.
- Retelling code, listing classes and functions, logs, tool calls, stack traces. What is needed
  is state and decisions, not an inventory.
- Copies of what is already written in repository files. A link instead of a copy: two copies
  drift apart.

### 5. Size and delivery

Hard ceiling: 500 lines. That is a ceiling, not a target: if everything essential fits in 150
lines, the document is 150 lines. Do not inflate it without need; completeness comes from
precise wording, not from volume: the owner asked twice for "not a huge one". Over the ceiling:
move long material into links to files, cut repeats of project rules.

Deliver the document as one continuous block in the chat, with no preamble and no comments
after it: the owner copies the block whole and pastes it into the new session. The document is
written to a file only on the owner's explicit instruction. Do not make that decision yourself
and do not create files "just in case".

### Template

Keep the headings and their order as they are: the receiving side finds the sections by them.

```
# Session handoff document (session-handoff). Read the session-handoff skill, section "Receive".

## The gist in five lines
What the work is, where it stopped, what comes next. Focus of the next session.

## Project and repository state
Folder: … Branch: … HEAD: <sha> <date> <subject>.
Working tree: clean / uncommitted: … Unpushed: … Open PRs: …
Someone else's edits, do not touch: …

## How it started
The original problem with facts and dates, in the owner's words.

## Done, do not redo
- <date> what was done — evidence (SHA / test / PR)
Assumed, verify: …

## Where to start and why
…

## Read first
- <path> — what is there and which items (codes, statuses)

## How to work
The process the owner requires on this task (for example: exploration → plan in plain words →
agreement → implementation → checks → independent review by a subagent).

## Environment constraints
Only those that concern this task.

## Prohibitions for this task
In the owner's words.

## Skills for the next agent
- <name> — why
```

## Receive

1. Read the document to the very end. A status may have been appended at the bottom that
   contradicts the beginning.
2. Run `repo-state.sh` in the project folder and compare it with the section "Project and
   repository state": branch, HEAD, clean tree, unpushed commits, PRs. The document was written
   at the end of the previous session; since then the owner may have committed, personally or
   through another agent. Name every discrepancy in the first line of your reply, before any
   conclusions.
3. Check that every file mentioned in the document exists. Read the files listed under "Read
   first": without them the check against reality is incomplete. Open nothing else.
4. Reply in five to seven lines in your own words: where we are, what is done, what is first in
   line, what the owner has to decide. Do not retell the document or quote its sections: the
   owner did not write it to read it twice. In their words: "I won't read all that, tell me
   what's going on".
5. Stop. Receiving the document briefs you; it does not start the work. Work starts only on the
   owner's separate word: "do it", "go ahead", "let's go". Until then: no file edits, no tests,
   no code exploration, and no offers like "I can start right away".
