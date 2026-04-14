#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# classify-dirs.sh — Directory Pre-Classification Hint Provider
#
# Provides classification hints for the AI using 19 file-pattern rules.
# The AI (guided by HOW_TO_AGENTS.md) makes the final sub-project judgment
# based on directory content analysis — these are optimization hints only.
#
# Usage:
#   ./classify-dirs.sh <PROJECT_ROOT> [MAX_DEPTH]
#
# Output: TSV to stdout (directory\ttype\tevidence\tsubproject_hint)
# =============================================================================

readonly PROJECT_ROOT="${1:?Usage: classify-dirs.sh <PROJECT_ROOT> [MAX_DEPTH]}"
readonly MAX_DEPTH="${2:-3}"

# --- Colors (stderr only) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Infra type counters for Step 2-1 consolidation check
TOTAL_DIRS=0
INFRA_DIRS=0

# --- Helper: check if file pattern exists in directory ---
has_file() {
  local dir="$1" pattern="$2"
  # shellcheck disable=SC2086
  ls ${dir}/${pattern} &>/dev/null 2>&1
}

has_files() {
  local dir="$1"
  shift
  for pattern in "$@"; do
    has_file "$dir" "$pattern" || return 1
  done
  return 0
}

has_any_file() {
  local dir="$1"
  shift
  for pattern in "$@"; do
    has_file "$dir" "$pattern" && return 0
  done
  return 1
}

# --- Helper: check if directory has only subdirectories (no regular files) ---
has_only_subdirs() {
  local dir="$1"
  local file_count
  file_count=$(find "$dir" -maxdepth 1 -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' ')
  [[ "$file_count" -eq 0 ]]
}

# --- Helper: count subdirectories with build files ---
count_buildfile_subdirs() {
  local dir="$1"
  local count=0
  for sub in "$dir"/*/; do
    [[ -d "$sub" ]] || continue
    if has_any_file "$sub" "package.json" "go.mod" "go.sum" "pom.xml" "build.gradle" "build.gradle.kts" "pyproject.toml" "requirements.txt" "setup.py" "Cargo.toml"; then
      count=$((count + 1))
    fi
  done
  echo "$count"
}

# --- Helper: check if directory has env-specific subdirs ---
has_env_subdirs() {
  local dir="$1"
  local env_count=0
  for env_name in dev staging prod real production test qa; do
    [[ -d "$dir/$env_name" ]] && env_count=$((env_count + 1))
  done
  [[ "$env_count" -ge 2 ]]
}

# --- Helper: count files matching pattern ---
count_files() {
  local dir="$1" pattern="$2"
  find "$dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' '
}

# --- Helper: check if mostly markdown ---
is_mostly_md() {
  local dir="$1"
  local md_count total_count
  md_count=$(count_files "$dir" "*.md")
  total_count=$(find "$dir" -maxdepth 1 -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' ')
  [[ "$total_count" -gt 0 ]] && [[ "$md_count" -gt 0 ]] && [[ $((md_count * 100 / total_count)) -ge 60 ]]
}

# --- Helper: check if has office/docs files ---
has_office_files() {
  local dir="$1"
  has_any_file "$dir" "*.pptx" "*.xlsx" "*.pdf" "*.docx"
}

# --- Helper: check if business-related ---
is_business_dir() {
  local dir="$1"
  local name
  name=$(basename "$dir")
  case "$name" in
    business|biz|revenue|sales|contracts|proposals|finance|marketing|growth|gtm)
      return 0 ;;
  esac
  has_any_file "$dir" "*contract*" "*proposal*" "*revenue*" "*invoice*"
}

# --- Helper: check if customer-support related ---
is_cs_dir() {
  local dir="$1"
  local name
  name=$(basename "$dir")
  case "$name" in
    cs|customer-support|support|helpdesk|customer-service|tickets)
      return 0 ;;
  esac
  return 1
}

# --- Helper: check if secrets-related ---
is_secrets_dir() {
  local dir="$1"
  local name
  name=$(basename "$dir")
  case "$name" in
    secret|secrets|certs|certificates|keys|tls|ssl|pki)
      return 0 ;;
  esac
  return 1
}

# --- Hint: does this classification type suggest an independent sub-project? ---
# The AI makes the final judgment; this is an optimization hint only.
is_subproject_hint() {
  local dir_type="$1"
  case "$dir_type" in
    frontend|backend-node|backend-go|backend-jvm|backend-python)
      echo "yes" ;;
    business|docs-planning|customer-support|domain-grouping)
      echo "yes" ;;
    k8s-workload|infra-component)
      echo "maybe" ;;
    *)
      echo "no" ;;
  esac
}

# --- Main classification: apply 19 priority rules ---
classify_dir() {
  local dir="$1"

  # Priority 1: k8s-workload
  if has_files "$dir" "deployment.yaml" "service.yaml" "ingress.yaml"; then
    echo "k8s-workload	deployment.yaml+service.yaml+ingress.yaml"
    return
  fi

  # Priority 2: infra-component (Helm)
  if has_file "$dir" "values.yaml"; then
    echo "infra-component	values.yaml (Helm)"
    return
  fi

  # Priority 3: gitops-appset
  if has_file "$dir" "*-appset.yaml" || has_file "$dir" "*appset*.yaml"; then
    echo "gitops-appset	ApplicationSet YAML"
    return
  fi

  # Priority 4: bootstrap (ArgoCD Application)
  if has_file "$dir" "*-app.yaml"; then
    echo "bootstrap	ArgoCD Application YAML"
    return
  fi

  # Priority 5: frontend
  if has_file "$dir" "package.json"; then
    if has_any_file "$dir" "*.tsx" "*.vue" "*.svelte" || \
       has_any_file "$dir" "next.config.*" "nuxt.config.*" "svelte.config.*" "vite.config.*" "angular.json"; then
      echo "frontend	package.json + frontend framework"
      return
    fi
  fi

  # Priority 6: backend-node
  if has_file "$dir" "package.json" && has_any_file "$dir" "*.ts" "*.js"; then
    echo "backend-node	package.json + ts/js (no frontend framework)"
    return
  fi

  # Priority 7: backend-go
  if has_any_file "$dir" "go.mod" "go.sum"; then
    echo "backend-go	go.mod/go.sum"
    return
  fi

  # Priority 8: backend-jvm
  if has_any_file "$dir" "pom.xml" "build.gradle" "build.gradle.kts"; then
    echo "backend-jvm	pom.xml/build.gradle"
    return
  fi

  # Priority 9: backend-python
  if has_any_file "$dir" "requirements.txt" "pyproject.toml" "setup.py"; then
    echo "backend-python	requirements.txt/pyproject.toml/setup.py"
    return
  fi

  # Priority 10: cicd
  if has_file "$dir" "Dockerfile"; then
    if has_any_file "$dir" "Jenkinsfile" "Makefile" || [[ -d "$dir/.github/workflows" ]]; then
      echo "cicd	Dockerfile + CI config"
      return
    fi
  fi

  # Priority 11: github-actions
  if [[ -d "$dir/.github/workflows" ]]; then
    echo "github-actions	.github/workflows/"
    return
  fi

  # Priority 12: docs-planning
  if is_mostly_md "$dir" && has_office_files "$dir"; then
    echo "docs-planning	*.md + office files"
    return
  fi

  # Priority 13: docs-technical
  if is_mostly_md "$dir"; then
    echo "docs-technical	mostly *.md files"
    return
  fi

  # Priority 14: env-config
  if has_env_subdirs "$dir"; then
    echo "env-config	environment subdirectories (dev/staging/prod)"
    return
  fi

  # Priority 15: business
  if is_business_dir "$dir"; then
    echo "business	business-related content"
    return
  fi

  # Priority 16: customer-support
  if is_cs_dir "$dir"; then
    echo "customer-support	CS/customer-related"
    return
  fi

  # Priority 17: secrets
  if is_secrets_dir "$dir"; then
    echo "secrets	secrets/certs/keys directory"
    return
  fi

  # Priority 18a: domain-grouping
  if has_only_subdirs "$dir"; then
    local buildfile_count
    buildfile_count=$(count_buildfile_subdirs "$dir")
    if [[ "$buildfile_count" -ge 2 ]]; then
      echo "domain-grouping	only subdirs, ${buildfile_count} with build files"
      return
    fi

    # Priority 18b: grouping
    echo "grouping	only subdirectories, no direct files"
    return
  fi

  # Priority 19: generic
  echo "generic	no matching rules"
}

# --- Scan directories and classify ---
scan_and_classify() {
  local root="$1"
  local max_depth="$2"
  local results=()

  # Find directories (exclude hidden, node_modules, vendor, etc.)
  while IFS= read -r dir; do
    [[ -z "$dir" ]] && continue

    local rel_path="${dir#"$root"}"
    rel_path="${rel_path#/}"
    [[ -z "$rel_path" ]] && rel_path="."

    local classification
    classification=$(classify_dir "$dir")
    local type="${classification%%	*}"
    local evidence="${classification#*	}"

    local subproject_hint
    subproject_hint=$(is_subproject_hint "$type")
    results+=("${rel_path}	${type}	${evidence}	${subproject_hint}")
    TOTAL_DIRS=$((TOTAL_DIRS + 1))

    # Track infra types for Step 2-1
    case "$type" in
      k8s-workload|infra-component|gitops-appset|bootstrap|env-config)
        INFRA_DIRS=$((INFRA_DIRS + 1))
        ;;
    esac
  done < <(find "$root" -mindepth 1 -maxdepth "$max_depth" -type d \
    -not -name '.*' \
    -not -name 'node_modules' \
    -not -name 'vendor' \
    -not -name '__pycache__' \
    -not -name '.git' \
    -not -name '.ai-agents' \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/vendor/*' \
    -not -path '*/__pycache__/*' \
    2>/dev/null | sort)

  # Output results
  echo "# ai-agency directory classification"
  echo "# project: ${root}"
  echo "# depth: ${max_depth}"
  echo "# total_dirs: ${TOTAL_DIRS}"
  echo "# infra_dirs: ${INFRA_DIRS}"

  # Step 2-1: Check infra consolidation
  if [[ "$TOTAL_DIRS" -gt 0 ]]; then
    local infra_pct=$((INFRA_DIRS * 100 / TOTAL_DIRS))
    echo "# infra_pct: ${infra_pct}%"
    if [[ "$infra_pct" -ge 70 ]]; then
      echo "# CONSOLIDATION: infra-dominated repo (>= 70%). Recommend single root GitOps agent."
    fi
  fi

  # Count subproject hints
  local subproject_count=0
  for line in "${results[@]}"; do
    local hint="${line##*	}"
    [[ "$hint" == "yes" ]] && subproject_count=$((subproject_count + 1))
  done
  echo "# subproject_hints: ${subproject_count}"
  echo "#"
  echo "# directory	type	evidence	subproject_hint"
  for line in "${results[@]}"; do
    echo "$line"
  done
}

# --- Entry point ---
if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo -e "${RED}Error: Directory not found: ${PROJECT_ROOT}${NC}" >&2
  exit 1
fi

echo -e "${DIM}Classifying directories in ${PROJECT_ROOT} (depth: ${MAX_DEPTH})...${NC}" >&2
scan_and_classify "$PROJECT_ROOT" "$MAX_DEPTH"
echo -e "${GREEN}Classification complete: ${TOTAL_DIRS} directories classified.${NC}" >&2
