🌐 [English](README.md) | [한국어](docs/README_ko.md) | [日本語](docs/README_ja.md) | [中文](docs/README_zh.md) | [Español](docs/README_es.md)

<div align="center">

# ai-agency

**Stop re-explaining your project to AI.**

A vendor-neutral CLI that builds a persistent context layer for your project
— so every AI session (Claude Code, Codex, Cursor, Gemini, Copilot, Windsurf, Aider)
starts already knowing your codebase, conventions, and business rules.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## Try it in 60 seconds

```bash
brew install itdar/tap/ai-agency

cd ~/your-project
ai-agency init      # scans, generates AGENTS.md + .ai-agents/ context
ai-agency           # pick an agent — it's already briefed
```

No Homebrew? `curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global`

---

## Why

Every new AI session starts from zero. The model burns tokens figuring out:

- "What framework is this?" — reads 20 files
- "What are the team conventions?" — guesses wrong
- "Who approves deploys?" — skips the step

> Research (ETH Zurich, reviewed 2026-03): agents re-analyzing a known project waste **~20% more tokens** and produce **worse results** than agents primed with a curated context file. [Review article ↗](https://www.infoq.com/news/2026/03/agents-context-file-value-review/)

`ai-agency` writes that context file once — vendor-neutral, under 300 tokens per agent — and your AI tool of choice loads it on every session.

---

## What actually gets built

When you run `ai-agency init`, the tool classifies each directory, then generates a layered context:

```
your-project/
├── AGENTS.md                     # Who am I? — role, rules, permissions (≤300 tokens)
├── .ai-agents/
│   ├── context/                  # What do I know? — only non-inferable facts
│   │   ├── domain-overview.md    #   business purpose, policies, constraints
│   │   ├── api-spec.json         #   endpoints map (JSON DSL — ~3× cheaper than prose)
│   │   ├── data-model.md         #   entities + relationships
│   │   ├── business-metrics.md   #   KPIs, OKRs
│   │   ├── stakeholder-map.md    #   RACI, approval flows
│   │   └── planning-roadmap.md   #   milestones, decisions log
│   ├── skills/                   # How do I work? — loaded on demand
│   │   └── develop/SKILL.md
│   ├── roles/                    # Role-specific loading strategies
│   │   ├── pm.md
│   │   └── backend.md
│   └── coordination/             # Cross-vendor task board (multi-agent mode)
│       ├── task-board.md
│       ├── messages.md
│       └── agent-status.json
├── apps/
│   ├── api/AGENTS.md             # per-service agent
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**Only what the AI can't derive from code gets stored.** "This is a React app" is obvious from `package.json`. "We squash-merge and require QA approval before deploy" is not — that goes in.

---

## It's not just code

Most AI tooling stops at the repo boundary. `ai-agency` treats your whole organization as the project:

```
my-product/              ← PM agent (coordinator)
├── api/                 ← Backend agent
├── web/                 ← Frontend agent
├── planning/            ← Technical Writer (specs, ADRs, roadmap)
├── business/            ← Business Analyst (GTM, KPIs, stakeholders)
└── infra/               ← Infra agent
```

The PM agent delegates to whichever specialist fits the task — code changes to backend, pricing questions to business, spec drafts to planning. Each specialist loads only its own context, so token usage stays predictable.

For multi-domain platforms, domains are auto-detected when a directory has 2+ sub-projects with their own build files:

```
platform/
├── commerce/           ← Domain Coordinator (auto-detected)
│   ├── order-api/
│   └── storefront/
├── social/             ← Domain Coordinator (auto-detected)
│   ├── feed-api/
│   └── chat-api/
└── infra/
```

---

## Running agents

### Single agent

```bash
ai-agency                       # interactive menu
ai-agency --agent api           # jump straight to a specific agent
```

### Team mode (Claude Code)

Pick "team" from the menu. A PM agent uses Claude Code's native agent teams to delegate sub-tasks to specialists. You don't manage sub-agents manually — the PM does.

### Parallel agents (any AI tool)

```bash
ai-agency --multi               # tmux split panes, one agent per pane
```

Each pane runs an independent agent in its own tool of choice. They coordinate through `.ai-agents/coordination/` — a plain-text task board, message log, and status JSON. That's how a Claude Code agent in one pane can hand work off to a Codex agent in another. No proprietary protocol; just files.

---

## Supported AI tools

`ai-agency` writes `AGENTS.md` (the [open standard](https://agents.md/)) plus per-vendor bootstrap files — but only for vendors already present in your project.

| Tool | Works out of the box | Auto-generated bootstrap |
|---|---|---|
| OpenAI Codex | Reads `AGENTS.md` natively | — |
| Gemini CLI | Reads `AGENTS.md` natively | — |
| Claude Code | ✓ | `CLAUDE.md` |
| Cursor | ✓ | `.cursor/rules/agents.mdc` |
| GitHub Copilot | ✓ | `.github/copilot-instructions.md` |
| Windsurf | ✓ | `.windsurfrules` |
| Aider | ✓ | `.aider.conf.yml` (read directive appended) |

Switch tools anytime — the context layer doesn't change.

---

## Keeping context fresh

Each `AGENTS.md` embeds maintenance triggers ("if the API contract changes, update `api-spec.json`"). The AI updates context in-session.

After each session, `ai-agency` compares a checksum of your code against the context files and warns if they drifted:

```
[ai-agency] Code changes detected but no context files updated.
  Run: ai-agency verify --staleness
```

Manual checks:

```bash
ai-agency verify                # structure + completeness
ai-agency verify --staleness    # drift between code and context
```

For major refactors, re-run `ai-agency init` — it offers an **incremental** mode that only regenerates context for new/changed directories.

---

## CLI reference

```bash
# Setup
ai-agency init [path]            # scan → classify → generate → validate
ai-agency classify [path]        # preview classification without generating

# Daily use
ai-agency                        # interactive launcher
ai-agency --agent <keyword>      # launch a specific agent
ai-agency --multi                # parallel agents in tmux panes
ai-agency --tool <claude|codex|gemini>
ai-agency --lang <code>          # UI language: en ko ja zh es fr de ru hi ar

# Project registry
ai-agency register [path]
ai-agency scan [dir]
ai-agency list
ai-agency unregister [path]

# Maintenance
ai-agency verify [path]
ai-agency verify --staleness
ai-agency clear [path]           # remove all generated files
```

---

## Design principles

- **Vendor-neutral.** `AGENTS.md` is the shared standard; bootstrap files are thin pointers.
- **Only non-inferable facts.** If the AI can learn it by reading the code, it doesn't belong in context.
- **Token budgets.** Each `AGENTS.md` stays under ~300 tokens after template substitution. API/event specs use JSON DSL (~3× cheaper than prose).
- **Separation of knowledge / behavior / role.** Context (always loaded), skills (on demand), roles (per-agent loading strategy) — mixing them makes token usage unpredictable.
- **File-based coordination.** Multi-agent handoffs use plain Markdown + JSON in `.ai-agents/coordination/`, so any tool can participate.

---

## How it works (internals)

1. `classify-dirs.sh` applies 19 file-pattern rules to hint at each directory's type. The AI makes the final call.
2. `scaffold.sh` creates `.ai-agents/` at root and per sub-project.
3. `setup.sh` launches your AI tool with `HOW_TO_AGENTS.md` — a 7-step meta-instruction that drives the generation.
4. `validate.sh` enforces required sections, token limits, and reference integrity.
5. `sync-ai-rules.sh` emits vendor bootstrap files (only for vendors you already use).
6. `ai-agency.sh` runs the interactive CUI, tracks session checksums, and injects the coordination protocol into multi-agent sessions.

> **Cost note:** the initial generation scans the whole project and can run into tens of thousands of tokens. That cost is paid once; every subsequent session loads the prebuilt context in a fraction of the time.

---

## References

- [AGENTS.md](https://agents.md/) — the vendor-neutral standard this builds on
- [ETH Zurich context-file review (InfoQ, 2026-03)](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "only document what cannot be inferred"
- [Kurly OMS team workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — inspiration for the context design

---

## License

MIT

---

<p align="center">
  <sub>Set up once. Work forever.</sub>
</p>
