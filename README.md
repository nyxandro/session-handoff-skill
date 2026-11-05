<div align="center">

# Session Handoff

**A Claude Code skill that carries unfinished work to a new AI agent session in one document, checked against the real repository.**

[![Release](https://img.shields.io/github/v/release/nyxandro/session-handoff-skill)](https://github.com/nyxandro/session-handoff-skill/releases)
[![License](https://img.shields.io/github/license/nyxandro/session-handoff-skill)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-SKILL.md-6f42c1)](https://agentskills.io/specification)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757)](#install)

**English** · [Русский](README.ru.md)

</div>

Session Handoff is a skill for Claude Code, Codex, OpenCode, Cursor and other agents that read Agent
Skills. When a session runs out of context or gets compacted, the agent writes one copy-ready
document for the next session. The agent in the new session checks it against the repository
before doing anything.

## Why

Ask an agent to "write a prompt for the new session" and you get something different every time.

- Once the branch state is missing.
- Another time the prohibitions you gave are gone.
- The third time the task scope has quietly changed.

This skill fixes the structure of the document, takes repository facts from a script instead of
the agent's memory, and teaches the receiving agent to verify the document rather than trust it.

## Install

| Agent | Command |
|---|---|
| Claude Code, as a plugin | `/plugin install session-handoff --marketplace nyxandro/skills` |
| Claude Code, Codex, OpenCode, Cursor and others | `npx skills add nyxandro/session-handoff-skill` |
| Any agent, by hand | Download the [latest `.skill` archive](https://github.com/nyxandro/session-handoff-skill/releases/latest/download/session-handoff.skill) and unpack it into the agent's skills folder |

Pick one. If you install it two ways, Claude Code loads the skill twice.

<details>
<summary>Requirements and more install options</summary>

<br>

- The script needs `git`. `gh` is optional and only lists open pull requests. The script is
  read-only and never contacts the remote.
- The one-line plugin install needs Claude Code 2.1.275 or later. On an older version, add the
  catalog first with `/plugin marketplace add nyxandro/skills` and then run
  `/plugin install session-handoff@nyxandro`.
- The catalog pins no version, so every commit here reaches plugin users as an update. Run
  `claude plugin marketplace update nyxandro` and `claude plugin update session-handoff@nyxandro`,
  or turn on auto-update under `/plugin` → Marketplaces.
- With `npx skills`, add `-g` to install the skill for every project. To install a given version,
  add its tag, as in `nyxandro/session-handoff-skill@v1.0.0`.
- You can also clone this repository and link the `session-handoff/` folder into your agent's
  skills folder. There is no build step.

</details>

## Usage

**At the end of a session**, ask for the handoff.

- *Write a prompt for a new session, I'll copy it and send it to the agent.*
- *Your context is about to run out. Write down all the details for the next session.*
- *Do a handoff, the next session is about the digest failures.*

The agent runs `scripts/repo-state.sh`, collects the decisions, prohibitions and evidence from the
session and returns one copy-ready block in the chat. It creates no files unless you ask.

**At the start of a new session**, paste the block and say "here's the context" or "let's
continue". The agent then does five things.

1. Reads the document to the end.
2. Runs the same script and names every difference from the real repository first. Branch, HEAD,
   uncommitted and unpushed changes, open pull requests.
3. Checks that every file the document mentions exists and reads the ones marked "read first".
4. Briefs you in five to seven lines. Where we are, what's done, what comes first, what you have
   to decide.
5. Stops. Work starts only when you say so.

## What's in the document

| Section | What goes there |
|---|---|
| The gist in five lines | What the work is, where it stopped, the focus of the next session |
| Project and repository state | Folder, branch, HEAD, uncommitted and unpushed changes, open PRs, someone else's edits marked "do not touch" |
| How it started | The original problem with facts and dates, in your words |
| Done, do not redo | Every item with evidence you can check, such as a commit SHA, a test or a PR. Unproven items go under "Assumed, verify" |
| Where to start and why | The first step of the next session and why it comes first |
| Read first | Paths to files with item codes and statuses, not a retelling |
| How to work | The process you require on this task |
| Environment constraints | Only the ones that concern this task |
| Prohibitions for this task | In your words, close to a quote |
| Skills for the next agent | Which skills the task needs and why |

The document is written in the language you use with the agent. The hard ceiling is 500 lines,
and that's a ceiling, not a target. Secrets, retold code, logs, stack traces and copies of what
already lives in the repository never go in.

## Example

Real output of `scripts/repo-state.sh` in one of our repositories, shortened.

```text
Folder: ~/projects/feature-blueprint-skill
Branch: main
HEAD: 726b268 2026-11-06 Russian README in the new layout; changelog without em dashes
Upstream: origin/main (unpushed commits: 0, not pulled: 0; as of last fetch)
Working tree: clean
Stash entries: 0
Last commits (5):
  726b268 2026-11-06 nyxandro: Russian README in the new layout; changelog without em dashes
  d2ac941 2026-11-06 nyxandro: README: rewrite the English page, install table first, ...
Open PRs from this branch: none
```

The same lines go into the handoff document, and the receiving agent compares them with what it
sees.

## Versions

The current version sits in `metadata.version` of `session-handoff/SKILL.md`, so any installed
copy tells you which one it is. Every version has a git tag and a
[release](https://github.com/nyxandro/session-handoff-skill/releases) with its own archive.
[CHANGELOG.md](CHANGELOG.md) lists what changed.

<details>
<summary>Repository layout</summary>

<br>

```text
session-handoff/              the skill
  SKILL.md                    instructions for both sides and the document template
  scripts/repo-state.sh       repository state in one read-only command
dist/session-handoff.skill    the skill folder as a downloadable archive
CHANGELOG.md                  what changed in each version
README.md, README.ru.md       this page in English and in Russian
```

</details>

## License

[MIT](LICENSE)
