# Session Handoff Skill

[![Download Skill](https://img.shields.io/badge/Download-session--handoff.skill-blue?style=for-the-badge)](https://github.com/nyxandro/session-handoff-skill/raw/main/dist/session-handoff.skill)

A skill for Claude Code and OpenCode that carries unfinished work from one agent session to the
next with a single document.

Agent sessions run out of context or get compacted, and the work continues in a fresh one. Ask
the agent to "write a prompt for the new session" and every time it assembles something
different: one time the branch state is missing, another time the prohibitions you gave are
gone, the third time the task scope has quietly changed. This skill fixes the structure of that
document, takes repository facts from a script instead of the agent's memory, and teaches the
receiving agent to verify the document rather than trust it.

## Two sides

**Write.** At the end of a session, say something like:

```text
Write a prompt for a new session, I'll copy it and send it to the agent.
Your context is about to run out, write down all the details for the next session.
Do a handoff, the next session is about the digest failures.
```

The agent runs `scripts/repo-state.sh`, collects decisions, prohibitions and evidence from the
session, and returns one copy-ready block in the chat. It does not create files unless you tell
it to.

**Receive.** At the start of a new session, paste the block and say "here's the context" or
"let's continue". The agent:

1. reads the document to the end;
2. runs the same script and names every discrepancy with the real repository first: branch,
   HEAD, uncommitted and unpushed changes, open PRs;
3. checks that every file the document mentions exists and reads the ones marked "read first";
4. briefs you in five to seven lines: where we are, what is done, what is first in line, what
   you have to decide;
5. stops. Work starts only on your separate word.

## What the document contains

| Section | What goes there |
| --- | --- |
| The gist in five lines | What the work is, where it stopped, the focus of the next session |
| Project and repository state | Folder, branch, HEAD, uncommitted and unpushed changes, open PRs, someone else's edits marked "do not touch" |
| How it started | The original problem with facts and dates, in the owner's words |
| Done, do not redo | Every item with checkable evidence: commit SHA, test, PR, date. Unproven items go under "Assumed, verify" |
| Where to start and why | The first step of the next session and the reason it is first |
| Read first | Paths to files with item codes and statuses, not a retelling |
| How to work | The process the owner requires on this task |
| Environment constraints | Only those that concern this task |
| Prohibitions for this task | In the owner's words, close to a quote |
| Skills for the next agent | Which skills the task needs and why |

The document is written in the language the owner uses with the agent. Hard ceiling is 500
lines, and that is a ceiling, not a target.

What never goes in: secret values, standing project facts that belong in agent memory or
project rules, retold code, logs, tool calls, stack traces, and copies of what already lives in
repository files.

## Install

The committed `dist/session-handoff.skill` archive contains the same self-contained skill
folder as `session-handoff/`: `SKILL.md` plus `scripts/repo-state.sh`. No build step.

With the [skills](https://skills.sh) CLI:

```bash
npx skills add https://github.com/nyxandro/session-handoff-skill --skill session-handoff
```

Into Claude Code by hand:

```bash
curl -L -o /tmp/session-handoff.skill https://github.com/nyxandro/session-handoff-skill/raw/main/dist/session-handoff.skill
rm -rf ~/.claude/skills/session-handoff
unzip /tmp/session-handoff.skill -d ~/.claude/skills
```

Into OpenCode by hand:

```bash
rm -rf ~/.config/opencode/skills/session-handoff
unzip /tmp/session-handoff.skill -d ~/.config/opencode/skills
```

Or clone this repository and symlink `session-handoff/` into the skills folder of your agent.

`scripts/repo-state.sh` needs `git`; `gh` is optional and is used only to list open pull
requests. The script is read-only and never contacts the remote.

## Repository layout

```text
session-handoff/            the skill itself
  SKILL.md                  instructions for both sides and the document template
  scripts/repo-state.sh     repository state in one read-only command
dist/session-handoff.skill  downloadable archive of the skill folder
```

## License

MIT.
