#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# scaffold.sh — Context Hierarchy Scaffolding Engine
#
# Creates .ai-agents/ directory structure and placeholder files based on
# classification results from classify-dirs.sh.
#
# Usage:
#   ./scaffold.sh <PROJECT_ROOT> [CLASSIFICATION_FILE]
#
# If CLASSIFICATION_FILE is not given, runs classify-dirs.sh internally.
# =============================================================================

readonly PROJECT_ROOT="${1:?Usage: scaffold.sh <PROJECT_ROOT> [CLASSIFICATION_FILE]}"
readonly CLASSIFICATION_FILE="${2:-}"

# --- Colors (stderr only) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

created_count=0
skipped_count=0

# --- Helper: create file if not exists ---
create_if_missing() {
  local file="$1"
  local content="$2"
  local parent
  parent=$(dirname "$file")
  mkdir -p "$parent"
  if [[ -f "$file" ]]; then
    skipped_count=$((skipped_count + 1))
    return
  fi
  echo "$content" > "$file"
  created_count=$((created_count + 1))
  echo -e "  ${GREEN}+${NC} ${file#"$PROJECT_ROOT"/}" >&2
}

# --- Step 1: Create base .ai-agents/ structure ---
scaffold_base() {
  local root="$1"
  local ai_dir="${root}/.ai-agents"

  mkdir -p "${ai_dir}/context"
  mkdir -p "${ai_dir}/skills"
  mkdir -p "${ai_dir}/roles"

  # Core context files (always needed)
  create_if_missing "${ai_dir}/context/domain-overview.md" "# Domain Overview

## Business Purpose
<!-- AI FILL: Describe what this project does and why it exists -->

## Core Deliverables
<!-- AI FILL: List the main outputs of this project -->

## Core Policies / Constraints
<!-- AI FILL: List non-inferable rules and constraints -->

## Legacy Quirks
<!-- HUMAN INPUT NEEDED: Non-obvious historical context -->"

  # Standard skill directories
  for skill in develop deploy review hotfix context-update; do
    local skill_dir="${ai_dir}/skills/${skill}"
    mkdir -p "$skill_dir"
    if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
      create_if_missing "${skill_dir}/SKILL.md" "# Skill: ${skill}

## Trigger
<!-- AI FILL: When should this skill be activated? -->

## Steps
<!-- AI FILL: Step-by-step procedure -->

## Done Criteria
<!-- AI FILL: How to verify completion -->"
    fi
  done

  # Root AGENTS.md (always needed — classify-dirs.sh skips root with -mindepth 1)
  local project_name
  project_name=$(basename "$root")
  create_if_missing "${root}/AGENTS.md" "# ${project_name}

## Role
<!-- AI FILL: Describe this agent's role based on the project structure.
     If sub-agents exist, this is the PM that coordinates them.
     If this is a standalone project, describe the project's primary purpose. -->

## Context Files
- Domain: \`.ai-agents/context/domain-overview.md\`

## Session Start
Read this AGENTS.md at every session start and follow its instructions.
Load all files in \`.ai-agents/context/\` at session start.

## Delegation
<!-- AI FILL: List sub-agents if any, or remove this section for standalone projects -->

## Permissions
- Never: <!-- AI FILL -->
- Ask First: <!-- AI FILL -->

## Context Maintenance
<!-- AI FILL: List maintenance triggers per HOW_TO_AGENTS.md Step 6 -->"

  # PM role (always needed)
  create_if_missing "${ai_dir}/roles/pm.md" "# Role: Project Manager

## Responsibilities
- Coordinate sub-agents and delegate tasks
- Track project progress and resolve blockers
- Maintain context files and agent tree consistency

## Context Loading
Load all files in .ai-agents/context/ at session start."
}

# --- Step 1.5: Create sub-project .ai-agents/context/ ---
# Sub-projects get a lightweight .ai-agents/ (context only, no roles/skills)
scaffold_subproject_base() {
  local subproject_dir="$1"
  local ai_dir="${subproject_dir}/.ai-agents"
  mkdir -p "${ai_dir}/context"

  create_if_missing "${ai_dir}/context/domain-overview.md" "# Domain Overview

## Purpose
<!-- AI FILL: What this sub-project does and why it exists -->

## Technical Stack
<!-- AI FILL: Key technologies and frameworks -->

## Scope
<!-- AI FILL: What is in scope vs out of scope -->"
}

# --- Step 2: Create type-specific context files ---
# context_base: the directory whose .ai-agents/context/ receives the files
# For root-level context: pass PROJECT_ROOT
# For sub-project context: pass the sub-project directory
scaffold_type_context() {
  local context_base="$1"
  local dir_type="$2"
  local ai_dir="${context_base}/.ai-agents"

  case "$dir_type" in
    k8s-workload|infra-component|gitops-appset|bootstrap|env-config)
      create_if_missing "${ai_dir}/context/infra-spec.md" "# Infrastructure Specification

## Services
<!-- AI FILL: List deployed services and their topology -->

## Environments
<!-- AI FILL: List environments (dev/staging/prod) and promotion flow -->

## Deployment Strategy
<!-- AI FILL: Describe deployment method (ArgoCD, Helm, etc.) -->"
      ;;

    frontend|backend-node|backend-go|backend-jvm|backend-python)
      create_if_missing "${ai_dir}/context/api-spec.json" '{
  "_comment": "AI FILL: Define API endpoints",
  "endpoints": []
}'
      create_if_missing "${ai_dir}/context/data-model.md" "# Data Model

## Entities
<!-- AI FILL: List main entities and their relationships -->

## Database
<!-- AI FILL: Database type, schema conventions -->"
      ;;

    business)
      create_if_missing "${ai_dir}/context/business-metrics.md" "# Business Metrics

## KPIs
<!-- AI FILL: Key performance indicators and targets -->

## Revenue Model
<!-- AI FILL: How the project generates value -->"
      create_if_missing "${ai_dir}/context/stakeholder-map.md" "# Stakeholder Map

## Team Structure
<!-- AI FILL: Who does what -->

## Approval Flow
<!-- AI FILL: RACI matrix for key decisions -->"
      create_if_missing "${ai_dir}/roles/business-analyst.md" "# Role: Business Analyst

## Responsibilities
- Manage KPIs, GTM strategy, and business metrics
- Bridge business requirements to technical specifications

## Context Loading
Load business-metrics.md and stakeholder-map.md at session start."
      ;;

    docs-planning|docs-technical)
      create_if_missing "${ai_dir}/context/planning-roadmap.md" "# Planning Roadmap

## Current Milestone
<!-- AI FILL: What's being worked on now -->

## Decision Log
<!-- AI FILL: Key decisions and their rationale -->"
      create_if_missing "${ai_dir}/roles/planner.md" "# Role: Planner / Technical Writer

## Responsibilities
- Maintain specifications, roadmaps, and architecture documents
- Bridge business requirements to technical specs

## Context Loading
Load planning-roadmap.md and domain-overview.md at session start."
      ;;

    customer-support)
      create_if_missing "${ai_dir}/context/ops-runbook.md" "# Operations Runbook

## Procedures
<!-- AI FILL: Standard operating procedures for CS -->

## Escalation Path
<!-- AI FILL: When and how to escalate -->"
      ;;

    cicd|github-actions)
      create_if_missing "${ai_dir}/context/infra-spec.md" "# CI/CD Specification

## Pipelines
<!-- AI FILL: List pipelines and their triggers -->

## Environments
<!-- AI FILL: Deployment targets and promotion flow -->"
      ;;
  esac
}

# --- Step 3: Create AGENTS.md skeleton for each classified directory ---
scaffold_agents_md() {
  local dir_path="$1"
  local dir_type="$2"
  local agents_file="${dir_path}/AGENTS.md"

  [[ -f "$agents_file" ]] && return

  local dir_name
  dir_name=$(basename "$dir_path")

  # Detect if this directory has its own .ai-agents/context/
  local context_note=""
  if [[ -d "${dir_path}/.ai-agents/context" ]]; then
    context_note="Load context files from this directory's \`.ai-agents/context/\` (local sub-project context).
Do NOT load root \`.ai-agents/context/\` files — they are for the PM agent only."
  else
    context_note="If \`.ai-agents/context/\` exists at the project root, load the files listed in Context Files."
  fi

  create_if_missing "$agents_file" "# ${dir_name}

## Role
<!-- AI FILL: Agent role based on type '${dir_type}' -->

## Context Files
<!-- AI FILL: List .ai-agents/context/ files this agent needs -->

## Session Start
Read this AGENTS.md at every session start and follow its instructions.
${context_note}

## Delegation
<!-- AI FILL: Which sub-agents to delegate to -->

## Permissions
- Never: <!-- AI FILL -->
- Ask First: <!-- AI FILL -->

## Context Maintenance
<!-- AI FILL: List maintenance triggers per HOW_TO_AGENTS.md Step 6 -->"
}

# --- Step 4: Scaffold coordination directory for multi-agent projects ---
scaffold_coordination() {
  local root="$1"
  local agent_count="$2"
  local coord_dir="${root}/.ai-agents/coordination"

  [[ "$agent_count" -lt 2 ]] && return

  mkdir -p "$coord_dir"

  create_if_missing "${coord_dir}/task-board.md" "# Task Board

## TODO

## IN PROGRESS

## DONE"

  create_if_missing "${coord_dir}/messages.md" "# Agent Messages

<!-- Agents append messages here for cross-agent communication -->
<!-- Format: [YYYY-MM-DD HH:MM] [agent-name] message -->"

  create_if_missing "${coord_dir}/agent-status.json" '{
  "_comment": "Updated by ai-agency.sh at session start/end",
  "agents": {}
}'
}

# --- Main ---
if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo -e "${RED}Error: Directory not found: ${PROJECT_ROOT}${NC}" >&2
  exit 1
fi

echo -e "${BOLD}Scaffolding .ai-agents/ structure...${NC}" >&2

# Get classification results
classification=""
if [[ -n "$CLASSIFICATION_FILE" && -f "$CLASSIFICATION_FILE" ]]; then
  classification=$(cat "$CLASSIFICATION_FILE")
else
  # Run classify-dirs.sh if available
  classify_script="${SCRIPT_DIR}/classify-dirs.sh"
  if [[ -f "$classify_script" ]]; then
    classification=$("$classify_script" "$PROJECT_ROOT" 2>/dev/null)
  fi
fi

# Always create base structure
scaffold_base "$PROJECT_ROOT"

# Track unique types and agent count for coordination
declare -A seen_types
agent_count=0

# Process classification results
if [[ -n "$classification" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    local_dir="${line%%	*}"
    rest="${line#*	}"
    dir_type="${rest%%	*}"
    # Parse subproject_hint (4th column, after evidence)
    local evidence_and_hint="${rest#*	}"
    local subproject_hint="${evidence_and_hint##*	}"
    # Fallback for old 3-column format (no subproject_hint)
    [[ "$subproject_hint" == "$evidence_and_hint" ]] && subproject_hint="no"

    [[ -z "$dir_type" ]] && continue

    # Full path
    if [[ "$local_dir" == "." ]]; then
      full_dir="$PROJECT_ROOT"
    else
      full_dir="${PROJECT_ROOT}/${local_dir}"
    fi

    # Type-specific context files: sub-project gets own .ai-agents/context/
    if [[ "$subproject_hint" == "yes" && "$local_dir" != "." ]]; then
      scaffold_subproject_base "$full_dir"
      scaffold_type_context "$full_dir" "$dir_type"
    elif [[ -z "${seen_types[$dir_type]:-}" ]]; then
      scaffold_type_context "$PROJECT_ROOT" "$dir_type"
      seen_types[$dir_type]=1
    fi

    # AGENTS.md skeleton
    scaffold_agents_md "$full_dir" "$dir_type"
    agent_count=$((agent_count + 1))
  done <<< "$classification"
fi

# Coordination directory for multi-agent projects
scaffold_coordination "$PROJECT_ROOT" "$agent_count"

echo "" >&2
echo -e "${GREEN}Scaffolding complete: ${created_count} files created, ${skipped_count} existing files skipped.${NC}" >&2
