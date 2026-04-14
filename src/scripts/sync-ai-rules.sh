#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# sync-ai-rules.sh — Generate vendor-specific bootstrap files pointing to AGENTS.md
#
# For AI tools that don't natively read AGENTS.md, this script creates
# lightweight index files that redirect the tool to AGENTS.md as the
# single source of truth.
#
# Usage:
#   bash scripts/sync-ai-rules.sh          # Auto-detect and generate
#   bash scripts/sync-ai-rules.sh --all    # Generate for all supported vendors
#   bash scripts/sync-ai-rules.sh --help   # Show help
# =============================================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Project Root ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# --- Help ---
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo ""
  echo -e "${BOLD}sync-ai-rules.sh${NC} — Generate vendor bootstrap files"
  echo ""
  echo -e "${BOLD}Usage:${NC}"
  echo "  bash scripts/sync-ai-rules.sh          Auto-detect installed tools"
  echo "  bash scripts/sync-ai-rules.sh --all    Generate for all vendors"
  echo "  bash scripts/sync-ai-rules.sh --help   Show this help"
  echo ""
  echo -e "${BOLD}Supported vendors:${NC}"
  echo "  Claude Code    CLAUDE.md"
  echo "  Cursor         .cursor/rules/agents.mdc"
  echo "  GitHub Copilot .github/copilot-instructions.md"
  echo "  Windsurf       .windsurfrules"
  echo "  Aider          .aider.conf.yml"
  echo ""
  echo "OpenAI Codex reads AGENTS.md natively — no bootstrap needed."
  echo ""
  exit 0
fi

GENERATE_ALL=false
if [[ "${1:-}" == "--all" ]]; then
  GENERATE_ALL=true
fi

# --- Check AGENTS.md exists ---
if [[ ! -f "${PROJECT_ROOT}/AGENTS.md" ]]; then
  echo -e "${RED}Error: AGENTS.md not found in ${PROJECT_ROOT}${NC}"
  echo -e "${DIM}Run setup.sh first to generate AGENTS.md.${NC}"
  exit 1
fi

BOOTSTRAP_DIRECTIVE='## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.'

GENERATED=0
SKIPPED=0

# --- Helper: backup if has content beyond bootstrap ---
backup_if_needed() {
  local file="$1"
  if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
    # Check if file already contains only the bootstrap directive
    if grep -q "read \`AGENTS.md\`" "${PROJECT_ROOT}/${file}" 2>/dev/null; then
      return 1  # Already bootstrapped
    fi
    # Backup original
    local backup="${PROJECT_ROOT}/${file}.pre-agents.bak"
    if [[ ! -f "${backup}" ]]; then
      cp "${PROJECT_ROOT}/${file}" "${backup}"
      echo -e "  ${DIM}Backed up ${file} → ${file}.pre-agents.bak${NC}"
    fi
    return 0
  fi
  return 0
}

# --- Claude Code: CLAUDE.md ---
generate_claude() {
  local file="CLAUDE.md"
  if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
    if ! backup_if_needed "${file}"; then
      echo -e "  ${YELLOW}~${NC} ${file} ${DIM}(already bootstrapped)${NC}"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
  fi

  cat > "${PROJECT_ROOT}/${file}" << 'BOOTSTRAP'
## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
BOOTSTRAP

  echo -e "  ${GREEN}+${NC} ${file}"
  GENERATED=$((GENERATED + 1))
}

# --- Cursor: .cursor/rules/agents.mdc ---
generate_cursor() {
  local dir=".cursor/rules"
  local file="${dir}/agents.mdc"

  if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
    if ! backup_if_needed "${file}"; then
      echo -e "  ${YELLOW}~${NC} ${file} ${DIM}(already bootstrapped)${NC}"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
  fi

  mkdir -p "${PROJECT_ROOT}/${dir}"
  cat > "${PROJECT_ROOT}/${file}" << 'BOOTSTRAP'
---
description: Project context loader — reads AGENTS.md as the single source of truth
globs:
alwaysApply: true
---

At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
BOOTSTRAP

  echo -e "  ${GREEN}+${NC} ${file}"
  GENERATED=$((GENERATED + 1))
}

# --- GitHub Copilot: .github/copilot-instructions.md ---
generate_copilot() {
  local dir=".github"
  local file="${dir}/copilot-instructions.md"

  if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
    if ! backup_if_needed "${file}"; then
      echo -e "  ${YELLOW}~${NC} ${file} ${DIM}(already bootstrapped)${NC}"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
  fi

  mkdir -p "${PROJECT_ROOT}/${dir}"
  cat > "${PROJECT_ROOT}/${file}" << 'BOOTSTRAP'
## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
BOOTSTRAP

  echo -e "  ${GREEN}+${NC} ${file}"
  GENERATED=$((GENERATED + 1))
}

# --- Windsurf: .windsurfrules ---
generate_windsurf() {
  local file=".windsurfrules"

  if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
    if ! backup_if_needed "${file}"; then
      echo -e "  ${YELLOW}~${NC} ${file} ${DIM}(already bootstrapped)${NC}"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
  fi

  cat > "${PROJECT_ROOT}/${file}" << 'BOOTSTRAP'
## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
BOOTSTRAP

  echo -e "  ${GREEN}+${NC} ${file}"
  GENERATED=$((GENERATED + 1))
}

# --- Aider: .aider.conf.yml ---
generate_aider() {
  local file=".aider.conf.yml"

  if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
    # For aider, append read directive if not already present
    if grep -q "AGENTS.md" "${PROJECT_ROOT}/${file}" 2>/dev/null; then
      echo -e "  ${YELLOW}~${NC} ${file} ${DIM}(already bootstrapped)${NC}"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
    backup_if_needed "${file}"
    echo "" >> "${PROJECT_ROOT}/${file}"
    echo "read: [\"AGENTS.md\"]" >> "${PROJECT_ROOT}/${file}"
  else
    cat > "${PROJECT_ROOT}/${file}" << 'BOOTSTRAP'
# Auto-generated by ai-agency — points to AGENTS.md as the single source of truth
read: ["AGENTS.md"]
BOOTSTRAP
  fi

  echo -e "  ${GREEN}+${NC} ${file}"
  GENERATED=$((GENERATED + 1))
}

# --- Main ---
echo ""
echo -e "${BOLD}Generating vendor bootstrap files...${NC}"
echo ""

if $GENERATE_ALL; then
  generate_claude
  generate_cursor
  generate_copilot
  generate_windsurf
  generate_aider
else
  # Auto-detect: generate for tools that have existing config or are likely in use
  # Always generate Claude and Cursor (most common)
  generate_claude
  generate_cursor

  # Generate for others only if their config already exists
  if [[ -d "${PROJECT_ROOT}/.github" ]]; then
    generate_copilot
  fi
  if [[ -f "${PROJECT_ROOT}/.windsurfrules" ]]; then
    generate_windsurf
  fi
  if [[ -f "${PROJECT_ROOT}/.aider.conf.yml" ]]; then
    generate_aider
  fi
fi

# --- Add .pre-agents.bak to .gitignore ---
if [[ -f "${PROJECT_ROOT}/.gitignore" ]]; then
  if ! grep -q "\.pre-agents\.bak" "${PROJECT_ROOT}/.gitignore" 2>/dev/null; then
    echo "" >> "${PROJECT_ROOT}/.gitignore"
    echo "# ai-agency backup files" >> "${PROJECT_ROOT}/.gitignore"
    echo "*.pre-agents.bak" >> "${PROJECT_ROOT}/.gitignore"
    echo -e "  ${GREEN}+${NC} .gitignore ${DIM}(added *.pre-agents.bak)${NC}"
  fi
fi

echo ""
echo -e "${GREEN}${BOLD}Done!${NC} Generated: ${GENERATED}, Skipped: ${SKIPPED}"
echo -e "${DIM}All vendor files now point to AGENTS.md as the single source of truth.${NC}"
echo ""
