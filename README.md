🌐 [English](README.md) | [한국어](docs/README_ko.md) | [中文](docs/README_zh.md) | [日本語](docs/README_ja.md) | [Español](docs/README_es.md) | [Português](docs/README_pt.md)

<div align="center">

# ai-agency

**Your own AI agency, built around your goals.**

Build your context once — never explain it again.
Dev, planning, business, design — specialist agents share the same knowledge and collaborate.
No more wasted tokens. Just orchestrated teamwork toward your objectives.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## What is ai-agency?

Every AI session starts from scratch. Your agent doesn't know your APIs, your team rules, or your business goals. You explain the same things over and over — burning time and money.

**ai-agency** builds persistent context for your organization and orchestrates AI specialists on top of it:

1. **Context once, forever** — Build your project's knowledge layer once. Every agent starts fully briefed — codebase, conventions, business rules, team structure. No repeated token costs, no wasted warm-up time.

2. **Orchestrated specialists** — Not just one agent on one repo. Dev, planning, business, design, QA, operations — each specialist shares the same context and collaborates. A PM agent coordinates them to tackle tasks, solve problems, and deliver results across your organization.

Whether it's a single service or an entire company's workflow — ai-agency orchestrates the right experts with the right context.

Works with any AI tool: Claude Code, Codex, Cursor, Copilot, Gemini CLI, Windsurf, Aider.

<!-- TODO: 30-second demo GIF showing ai-agency init → ai-agency session launch → agent working with full context -->

---

## Install

### Homebrew (recommended)

```bash
brew install itdar/tap/ai-agency
```

### Without Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global
```

### Per-project only

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash
```

---

## Getting Started

### 1. Initialize your project

```bash
cd ~/my-project
ai-agency init
```

Or from anywhere: `ai-agency init ~/my-project`

This does three things automatically:
1. **Scans** your directory structure and classifies each directory (backend, frontend, infra, business, etc.)
2. **Generates** `AGENTS.md` files and `.ai-agents/` context for each area
3. **Validates** the generated files for completeness

<!-- TODO: Screenshot of ai-agency init running — showing the interactive tool/language selection CUI -->

You pick your AI tool (Claude Code, Codex, or Gemini) and language. The AI then analyzes your project and builds the context. This is a one-time setup — it takes a few minutes but saves hours later.

### 2. Launch an agent session

```bash
ai-agency
```

That's it. Pick an agent from the interactive menu and start working. The agent already knows your project.

<!-- TODO: Screenshot of ai-agency interactive CUI — showing the agent list with arrow-key navigation, colored agents -->

### 3. Daily use

Your daily workflow doesn't change. Just run `ai-agency` instead of launching your AI tool directly.

```bash
ai-agency                     # Pick agent interactively
ai-agency --agent api         # Jump straight to the API agent
```

When you select a top-level agent (PM, Domain Coordinator), it automatically spawns and coordinates sub-agents as needed — you don't have to manage them yourself.

For running multiple independent agents side-by-side in tmux split panes:

```bash
ai-agency --multi             # Select which agents to run in parallel
```

<!-- TODO: Screenshot of tmux multi-agent split panes — 2-3 agents running simultaneously with colored pane borders -->

---

## Why You Need This

### Without ai-agency

Every session starts from zero. The AI spends time (and your tokens) figuring out your project:

- "What framework is this?" — reads 20 files to figure out
- "What are the API endpoints?" — scans every controller
- "What are the team conventions?" — has no idea, guesses wrong
- "Who approves deploys?" — doesn't know, skips the step

> Research (ETH Zurich, 2026): AI agents that re-analyze a known project waste **20% more tokens** and produce **worse results** than agents with pre-built context.

### With ai-agency

The AI loads everything in seconds and starts working immediately:

```
Session Start
  → Reads AGENTS.md            "I'm the backend expert for order-api"
  → Loads .ai-agents/context/  "I know the APIs, data models, team rules"
  → Starts working             No exploration phase needed
```

<!-- TODO: Before/after comparison image — left side: AI exploring files aimlessly, right side: AI immediately productive with context loaded -->

---

## What Gets Generated

When you run `ai-agency init`, three layers of context are created:

```
your-project/
├── AGENTS.md                    # Who am I? (role, rules, permissions)
├── .ai-agents/
│   ├── context/                 # What do I know? (domain knowledge)
│   │   ├── domain-overview.md   #   Business purpose, policies, constraints
│   │   ├── api-spec.json        #   API endpoints map
│   │   ├── data-model.md        #   Entities and relationships
│   │   └── ...                  #   (generated based on your project type)
│   ├── skills/                  # How do I work? (workflow standards)
│   │   ├── develop/SKILL.md     #   Dev: analyze → implement → test → PR
│   │   └── review/SKILL.md      #   Review: security, performance checklist
│   └── roles/                   # Role-specific loading strategies
│       ├── pm.md
│       └── backend.md
├── apps/
│   ├── api/AGENTS.md            # Per-service agent
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**Only non-obvious information is stored.** Things the AI can figure out by reading code (like "this is a React app") are excluded. Things it can't infer (like "we use squash merge" or "QA approval is required before deploy") are included.

---

## Project Structure Examples

ai-agency adapts to your project's shape. The directory where you run `ai-agency init` becomes the PM (coordinator).

### Simple product

```
my-app/               ← PM agent
├── api/              ← Backend agent
├── web/              ← Frontend agent
└── infra/            ← Infra agent
```

### Product + business teams

```
my-product/            ← PM agent
├── api/              ← Backend agent
├── web/              ← Frontend agent
├── business/         ← Business Analyst agent
├── planning/         ← Planner agent
└── infra/            ← Infra agent
```

Not just code — business, planning, QA, operations, and more. Each area gets its own specialized agent.

### Multi-domain platform

```
platform/              ← PM agent
├── commerce/         ← Domain Coordinator (auto-detected)
│   ├── order-api/    ← Backend agent
│   └── storefront/   ← Frontend agent
├── social/           ← Domain Coordinator (auto-detected)
│   ├── feed-api/     ← Backend agent
│   └── chat-api/     ← Backend agent
└── infra/            ← Infra agent
```

Domains are detected automatically when a directory contains 2+ subdirectories with their own build files.

---

## Team Mode

Run a PM agent that coordinates sub-agents, or launch multiple agents in parallel.

### Coordinated team (Claude Code)

The PM agent delegates tasks to specialists via Claude Code's native agent teams:

```bash
ai-agency                     # Select "team" mode from the menu
```

<!-- TODO: Screenshot of team mode selection in the CUI — showing single/team/multi options -->

### Parallel agents (any AI tool)

Launch multiple agents in tmux split panes. Each agent works independently with file-based coordination:

```bash
ai-agency --multi             # Select agents, they run in split panes
```

Agents coordinate through `.ai-agents/coordination/` — a shared task board and message log that works across any AI tool.

<!-- TODO: Screenshot of tmux multi-agent session with task-board.md visible in one pane -->

---

## Keeping Context Fresh

Context files are updated automatically during AI sessions — each AGENTS.md includes maintenance triggers that tell the agent when to update what.

After a session, ai-agency checks if code changed but context wasn't updated, and warns you:

```
[ai-agency] Code changes detected but no context files updated.
  Run: ai-agency verify --staleness
```

You can also check manually:

```bash
ai-agency verify              # Validate structure and completeness
ai-agency verify --staleness  # Check if context is up-to-date with code
```

For major changes, re-run init in incremental mode — it only generates context for new directories:

```bash
ai-agency init                # Select "incremental" when prompted
```

---

## Supported AI Tools

ai-agency is vendor-neutral. AGENTS.md works with any tool, and bootstrap files are auto-generated for tools that need them.

| Tool | Works out of the box | Auto-bootstrap |
|---|---|---|
| **OpenAI Codex** | Yes | Not needed |
| **Claude Code** | Yes | `CLAUDE.md` generated |
| **Cursor** | Via rules | `.cursor/rules/` generated |
| **GitHub Copilot** | Via instructions | `.github/copilot-instructions.md` generated |
| **Windsurf** | Via rules | `.windsurfrules` generated |
| **Aider** | Via config | `.aider.conf.yml` updated |
| **Gemini CLI** | Yes | Not needed |

Bootstrap files are only generated for tools you actually use. Nothing is created for tools you don't have.

---

## CLI Reference

```bash
# Setup
ai-agency init [path]           # Initialize a project (scan, generate, validate)
ai-agency classify [path]       # Preview directory classification without generating

# Daily use
ai-agency                       # Interactive agent launcher
ai-agency --agent <keyword>     # Launch specific agent
ai-agency --multi               # Parallel agents in tmux split panes
ai-agency --tool <claude|codex> # Specify AI tool
ai-agency --lang <code>         # Set UI language (en ko ja zh es fr de ru hi ar)

# Project management
ai-agency register [path]       # Register a project
ai-agency scan [dir]            # Auto-discover projects with AGENTS.md
ai-agency list                  # List registered projects
ai-agency unregister [path]     # Remove from registry

# Maintenance
ai-agency verify [path]         # Validate generated files
ai-agency verify --staleness    # Check context freshness
ai-agency clear [path]          # Remove all generated files
```

---

## How It Works (Under the Hood)

For those curious about the internals:

1. **classify-dirs.sh** scans your project and provides pre-classification hints using file-pattern rules. The AI makes the final sub-project judgment based on directory content analysis.
2. **scaffold.sh** creates `.ai-agents/` structures — at root for project-wide context, and per sub-project for type-specific context files.
3. **setup.sh** launches your chosen AI tool with `HOW_TO_AGENTS.md` — a meta-instruction that guides the AI through a 7-step analysis and generation process. The AI determines which directories are independent sub-projects and generates appropriate context.
4. **validate.sh** checks the generated files for structural integrity (required sections, token limits, reference completeness)
5. **sync-ai-rules.sh** creates vendor-specific bootstrap files pointing to AGENTS.md
6. **ai-agency.sh** manages the interactive agent selection CUI and session lifecycle, including context checksum tracking and multi-agent coordination

> **Token notice:** Initial setup analyzes the full project and may consume tens of thousands of tokens. This is a one-time cost — subsequent sessions load pre-built context instantly.

---

## References

- [AGENTS.md Standard](https://agents.md/) — The vendor-neutral agent instruction standard this project builds on
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Only document what cannot be inferred"
- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration for the context design

---

## License

MIT

---

<p align="center">
  <sub>Stop re-explaining your project to AI. Set up once, work forever.</sub>
</p>
