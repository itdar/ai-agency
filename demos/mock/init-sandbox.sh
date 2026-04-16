#!/usr/bin/env bash
# Builds a fake project sandbox so the init demo's `tree` / `head` commands
# have real files to show. No AI calls; pure filesystem scaffolding.
set -euo pipefail

SANDBOX="${1:-/tmp/ai-agency-demo-project}"

rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"/{api,web,infra,planning,business,.ai-agents/{context,coordination,roles,skills}}

cat > "$SANDBOX/AGENTS.md" <<'MD'
# my-shop-api  —  root PM

## Role
Coordinator. Delegates to backend / frontend / infra / planning / business.

## Context files
- Domain:       .ai-agents/context/domain-overview.md
- API spec:     .ai-agents/context/api-spec.json
- Stakeholders: .ai-agents/context/stakeholder-map.md

## Conventions
- Conventional Commits. Squash merge. QA approval before deploy.
- Never touch infra/ secrets. REDIS_URL via Terraform only.

## Delegation
- API code      → api/AGENTS.md
- UI code       → web/AGENTS.md
- Terraform     → infra/AGENTS.md
- Specs / ADRs  → planning/AGENTS.md
- GTM / pricing → business/AGENTS.md
MD

: > "$SANDBOX/.ai-agents/context/domain-overview.md"
: > "$SANDBOX/.ai-agents/context/api-spec.json"
: > "$SANDBOX/.ai-agents/context/stakeholder-map.md"
: > "$SANDBOX/.ai-agents/coordination/task-board.md"
: > "$SANDBOX/api/AGENTS.md"
: > "$SANDBOX/web/AGENTS.md"
: > "$SANDBOX/infra/AGENTS.md"

echo "$SANDBOX"
