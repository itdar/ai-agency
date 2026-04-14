#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# validate.sh — Post-Generation Validator
#
# Validates structural integrity of generated AGENTS.md and .ai-agents/ files.
#
# Usage:
#   ./validate.sh <PROJECT_ROOT> [--staleness]
#
# Exit codes:
#   0 = PASS (all checks passed)
#   1 = FAIL (critical issues found)
#   2 = WARN (non-critical issues found)
# =============================================================================

readonly PROJECT_ROOT="${1:?Usage: validate.sh <PROJECT_ROOT> [--staleness]}"
readonly CHECK_STALENESS="${2:-}"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
pass_count=0
warn_count=0
fail_count=0

# --- Helpers ---
log_pass() {
  echo -e "  ${GREEN}PASS${NC}  $1"
  pass_count=$((pass_count + 1))
}

log_warn() {
  echo -e "  ${YELLOW}WARN${NC}  $1"
  warn_count=$((warn_count + 1))
}

log_fail() {
  echo -e "  ${RED}FAIL${NC}  $1"
  fail_count=$((fail_count + 1))
}

# --- Check 1: AGENTS.md files exist ---
check_agents_exist() {
  echo -e "${BOLD}[1/6] AGENTS.md files${NC}"

  local count
  count=$(find "$PROJECT_ROOT" -name "AGENTS.md" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.omc/*" \
    2>/dev/null | wc -l | tr -d ' ')

  if [[ "$count" -eq 0 ]]; then
    log_fail "No AGENTS.md files found"
    return
  fi

  # Root AGENTS.md is required
  if [[ -f "${PROJECT_ROOT}/AGENTS.md" ]]; then
    log_pass "Root AGENTS.md exists"
  else
    log_fail "Root AGENTS.md missing"
  fi

  log_pass "${count} AGENTS.md file(s) found"
}

# --- Check 2: Required sections in AGENTS.md ---
check_required_sections() {
  echo -e "${BOLD}[2/6] Required sections${NC}"

  # Support both English and Korean section headers
  local required_sections=("## Role|## 역할" "## Session Start|## 세션 시작")
  local root_sections=("## Global|## 글로벌" "## Context Maintenance|## 컨텍스트 유지보수|## 컨텍스트 유지")

  while IFS= read -r agents_file; do
    local rel_path="${agents_file#"$PROJECT_ROOT"/}"

    # Check common required sections (pipe-separated alternatives)
    for section in "${required_sections[@]}"; do
      local display_name="${section%%|*}"
      if grep -qiE "$section" "$agents_file" 2>/dev/null; then
        log_pass "${rel_path}: '${display_name}' present"
      else
        log_warn "${rel_path}: '${display_name}' missing"
      fi
    done

    # Root-only sections
    if [[ "$agents_file" == "${PROJECT_ROOT}/AGENTS.md" ]]; then
      for section in "${root_sections[@]}"; do
        local display_name="${section%%|*}"
        if grep -qiE "$section" "$agents_file" 2>/dev/null; then
          log_pass "${rel_path}: '${display_name}' present"
        else
          log_warn "${rel_path}: '${display_name}' missing"
        fi
      done
    fi
  done < <(find "$PROJECT_ROOT" -name "AGENTS.md" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.omc/*" \
    2>/dev/null)
}

# --- Check 3: No unreplaced placeholders ---
check_placeholders() {
  echo -e "${BOLD}[3/6] Unreplaced placeholders${NC}"

  local found=false
  while IFS= read -r agents_file; do
    local rel_path="${agents_file#"$PROJECT_ROOT"/}"

    # Check for {placeholder} patterns (but not in code blocks)
    if grep -Pn '\{[a-z][a-z_]*\}' "$agents_file" 2>/dev/null | grep -v '^\s*#' | grep -v '```' | grep -v 'AI FILL' | head -5 | while IFS= read -r match; do
      log_warn "${rel_path}: possible unreplaced placeholder — ${match}"
      found=true
    done; then
      :
    fi

    # Check for <!-- AI FILL --> markers (these should be replaced by AI)
    local fill_count
    fill_count=$(grep -c 'AI FILL' "$agents_file" 2>/dev/null) || fill_count=0
    if [[ "$fill_count" -gt 0 ]]; then
      log_warn "${rel_path}: ${fill_count} <!-- AI FILL --> markers remain (pre-scaffold, not yet filled by AI)"
    fi
  done < <(find "$PROJECT_ROOT" -name "AGENTS.md" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.omc/*" \
    2>/dev/null)

  # Check context files in ALL .ai-agents/context/ directories (root + sub-projects)
  while IFS= read -r ctx_dir; do
    while IFS= read -r ctx_file; do
      local rel_path="${ctx_file#"$PROJECT_ROOT"/}"
      local fill_count
      fill_count=$(grep -c 'AI FILL' "$ctx_file" 2>/dev/null) || fill_count=0
      local human_count
      human_count=$(grep -c 'HUMAN INPUT NEEDED' "$ctx_file" 2>/dev/null) || human_count=0
      if [[ "$fill_count" -gt 0 ]]; then
        log_warn "${rel_path}: ${fill_count} <!-- AI FILL --> markers remain"
      fi
      if [[ "$human_count" -gt 0 ]]; then
        log_pass "${rel_path}: ${human_count} <!-- HUMAN INPUT NEEDED --> markers (expected)"
      fi
    done < <(find "$ctx_dir" -type f 2>/dev/null)
  done < <(find "$PROJECT_ROOT" -path "*/.ai-agents/context" -type d \
    -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null)
}

# --- Check 4: Context file references resolve ---
check_context_refs() {
  echo -e "${BOLD}[4/6] Context file references${NC}"

  while IFS= read -r agents_file; do
    local rel_path="${agents_file#"$PROJECT_ROOT"/}"
    local agents_dir
    agents_dir=$(dirname "$agents_file")

    # Extract .ai-agents/ references — resolve locally first, then root
    while IFS= read -r ref; do
      local local_ref="${agents_dir}/${ref}"
      local root_ref="${PROJECT_ROOT}/${ref}"
      if [[ -f "$local_ref" ]] || [[ -d "$local_ref" ]]; then
        log_pass "${rel_path}: ref '${ref}' exists (local)"
      elif [[ -f "$root_ref" ]] || [[ -d "$root_ref" ]]; then
        log_pass "${rel_path}: ref '${ref}' exists (root)"
      else
        log_fail "${rel_path}: ref '${ref}' not found (checked local and root)"
      fi
    done < <(grep -oP '`\.ai-agents/[^`]+`' "$agents_file" 2>/dev/null | tr -d '`' || true)
  done < <(find "$PROJECT_ROOT" -name "AGENTS.md" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.omc/*" \
    2>/dev/null)
}

# --- Check 5: Token count estimation ---
check_token_count() {
  echo -e "${BOLD}[5/6] Token count (300 token target)${NC}"

  while IFS= read -r agents_file; do
    local rel_path="${agents_file#"$PROJECT_ROOT"/}"
    local word_count
    word_count=$(wc -w < "$agents_file" | tr -d ' ')

    # Rough estimate: 1 token ~ 0.75 words for mixed content
    local est_tokens=$((word_count * 4 / 3))

    if [[ "$est_tokens" -le 300 ]]; then
      log_pass "${rel_path}: ~${est_tokens} tokens (within 300 limit)"
    elif [[ "$est_tokens" -le 450 ]]; then
      log_warn "${rel_path}: ~${est_tokens} tokens (exceeds 300 target, consider trimming)"
    else
      log_warn "${rel_path}: ~${est_tokens} tokens (significantly over 300 target)"
    fi
  done < <(find "$PROJECT_ROOT" -name "AGENTS.md" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.omc/*" \
    2>/dev/null)
}

# --- Check 6: .ai-agents/ structure completeness ---
check_structure() {
  echo -e "${BOLD}[6/6] .ai-agents/ structure${NC}"

  local ai_dir="${PROJECT_ROOT}/.ai-agents"

  if [[ ! -d "$ai_dir" ]]; then
    log_fail ".ai-agents/ directory missing"
    return
  fi

  log_pass ".ai-agents/ directory exists"

  # Required subdirectories
  for subdir in context skills roles; do
    if [[ -d "${ai_dir}/${subdir}" ]]; then
      local count
      count=$(find "${ai_dir}/${subdir}" -type f 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$count" -eq 0 ]]; then
        log_warn ".ai-agents/${subdir}/ exists but is empty"
      else
        log_pass ".ai-agents/${subdir}/ has ${count} file(s)"
      fi
    else
      log_warn ".ai-agents/${subdir}/ directory missing"
    fi
  done

  # domain-overview.md is always expected
  if [[ -f "${ai_dir}/context/domain-overview.md" ]]; then
    log_pass ".ai-agents/context/domain-overview.md exists"
  else
    log_fail ".ai-agents/context/domain-overview.md missing (required)"
  fi

  # Validate sub-project .ai-agents/ directories
  while IFS= read -r sub_ai_dir; do
    [[ "$sub_ai_dir" == "$ai_dir" ]] && continue
    local sub_rel="${sub_ai_dir#"$PROJECT_ROOT"/}"
    if [[ -d "${sub_ai_dir}/context" ]]; then
      local ctx_count
      ctx_count=$(find "${sub_ai_dir}/context" -type f 2>/dev/null | wc -l | tr -d ' ')
      log_pass "${sub_rel}/context/ has ${ctx_count} file(s) (sub-project)"
    else
      log_warn "${sub_rel}/ exists but has no context/ directory"
    fi
  done < <(find "$PROJECT_ROOT" -name ".ai-agents" -type d \
    -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null)
}

# --- Check 7 (optional): Staleness detection ---
check_staleness() {
  echo -e "${BOLD}[Staleness] Context freshness check${NC}"

  local meta_file="${PROJECT_ROOT}/.ai-agents/.session-meta.json"

  if [[ ! -f "$meta_file" ]]; then
    log_warn "No session metadata found (.ai-agents/.session-meta.json). Run an agent session first."
    return
  fi

  # Read last session timestamp
  local last_session
  last_session=$(grep -o '"last_session"[[:space:]]*:[[:space:]]*"[^"]*"' "$meta_file" 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"' || echo "")

  if [[ -z "$last_session" ]]; then
    log_warn "Could not read last session date from metadata"
    return
  fi

  log_pass "Last session: ${last_session}"

  # Check if git is available and there are changes since last session
  if command -v git &>/dev/null && [[ -d "${PROJECT_ROOT}/.git" ]]; then
    local changed_files
    changed_files=$(git -C "$PROJECT_ROOT" log --since="$last_session" --name-only --pretty=format: 2>/dev/null | sort -u | grep -v '^$' | grep -v '.ai-agents/' || true)

    if [[ -n "$changed_files" ]]; then
      local change_count
      change_count=$(echo "$changed_files" | wc -l | tr -d ' ')
      log_warn "${change_count} code file(s) changed since last session — context may be stale"

      # Check if context files were also updated
      local ctx_changed
      ctx_changed=$(git -C "$PROJECT_ROOT" log --since="$last_session" --name-only --pretty=format: 2>/dev/null | sort -u | grep '.ai-agents/' || true)

      if [[ -n "$ctx_changed" ]]; then
        local ctx_count
        ctx_count=$(echo "$ctx_changed" | wc -l | tr -d ' ')
        log_pass "${ctx_count} context file(s) also updated"
      else
        log_warn "No context files updated since last session — consider running 'ai-agency verify --staleness'"
      fi
    else
      log_pass "No code changes since last session"
    fi

    # Check saved checksums vs current
    if command -v md5sum &>/dev/null || command -v md5 &>/dev/null; then
      local ctx_dir="${PROJECT_ROOT}/.ai-agents/context"
      [[ -d "$ctx_dir" ]] || return

      while IFS= read -r ctx_file; do
        local fname
        fname=$(basename "$ctx_file")
        local current_hash

        if command -v md5sum &>/dev/null; then
          current_hash=$(md5sum "$ctx_file" | cut -d' ' -f1)
        else
          current_hash=$(md5 -q "$ctx_file")
        fi

        local saved_hash
        saved_hash=$(grep -o "\"${fname}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$meta_file" 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"' || echo "")

        if [[ -z "$saved_hash" ]]; then
          log_warn "${fname}: no saved checksum in metadata"
        elif [[ "$current_hash" == "$saved_hash" ]]; then
          log_pass "${fname}: checksum matches (unchanged since last session)"
        else
          log_pass "${fname}: checksum changed (updated since last session)"
        fi
      done < <(find "$ctx_dir" -type f 2>/dev/null)
    fi
  else
    log_warn "Not a git repository — cannot check for code changes"
  fi
}

# --- Main ---
if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo -e "${RED}Error: Directory not found: ${PROJECT_ROOT}${NC}"
  exit 1
fi

echo ""
echo -e "${BOLD}ai-agency validate: ${PROJECT_ROOT}${NC}"
echo -e "${DIM}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""

check_agents_exist
echo ""
check_required_sections
echo ""
check_placeholders
echo ""
check_context_refs
echo ""
check_token_count
echo ""
check_structure
echo ""

# Optional staleness check
if [[ "$CHECK_STALENESS" == "--staleness" ]]; then
  check_staleness
  echo ""
fi

# --- Summary ---
echo -e "${BOLD}Summary${NC}"
echo -e "  ${GREEN}PASS${NC}: ${pass_count}"
echo -e "  ${YELLOW}WARN${NC}: ${warn_count}"
echo -e "  ${RED}FAIL${NC}: ${fail_count}"
echo ""

if [[ "$fail_count" -gt 0 ]]; then
  echo -e "${RED}${BOLD}Result: FAIL${NC} — ${fail_count} critical issue(s) found"
  exit 1
elif [[ "$warn_count" -gt 0 ]]; then
  echo -e "${YELLOW}${BOLD}Result: WARN${NC} — ${warn_count} warning(s), no critical issues"
  exit 2
else
  echo -e "${GREEN}${BOLD}Result: PASS${NC} — all checks passed"
  exit 0
fi
