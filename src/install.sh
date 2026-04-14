#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# install.sh — One-line installer for ai-agency
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/install.sh | bash
#
#   # Or with options:
#   curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/install.sh | bash -s -- --no-run
#
# Downloads HOW_TO_AGENTS.md + setup.sh + ai-agency.sh into the current directory,
# then runs setup.sh interactively.
# =============================================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Config ---
REPO="itdar/ai-agency"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# Files to download: "repo_path:local_path"
REQUIRED_FILES=(
  "src/HOW_TO_AGENTS.md:HOW_TO_AGENTS.md"
  "src/setup.sh:setup.sh"
  "src/ai-agency.sh:ai-agency.sh"
  "src/scripts/sync-ai-rules.sh:scripts/sync-ai-rules.sh"
)

# --- Parse arguments ---
AUTO_RUN=true
GLOBAL_INSTALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-run)   AUTO_RUN=false; shift ;;
    --global|-g) GLOBAL_INSTALL=true; shift ;;
    --help|-h)
      echo ""
      echo "ai-agency installer"
      echo ""
      echo "Usage:"
      echo "  curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/src/install.sh | bash"
      echo ""
      echo "Options (pass via: ... | bash -s -- [options]):"
      echo "  --no-run         Download files only, don't run setup.sh"
      echo "  --global, -g     Install globally (ai-agency command available everywhere)"
      echo "  -h, --help       Show this help"
      echo ""
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Banner ---
echo ""
echo -e "${CYAN}${BOLD}"
echo "  +---------------------------------------------------------+"
echo "  |                                                         |"
echo "  |              ai-agency  Installer                       |"
echo "  |                                                         |"
echo "  |         github.com/${REPO}                      |"
echo "  |                                                         |"
echo "  +---------------------------------------------------------+"
echo -e "${NC}"

# --- Check prerequisites ---
if ! command -v curl &>/dev/null; then
  echo -e "${RED}Error: curl is required but not installed.${NC}"
  exit 1
fi

# --- Download files ---
echo -e "${BOLD}Downloading files...${NC}"
echo ""

download_file() {
  local repo_path="$1"
  local local_path="${2:-$repo_path}"
  local url="${BASE_URL}/${repo_path}"

  # Create parent directory if needed
  local dir
  dir="$(dirname "$local_path")"
  if [[ "$dir" != "." ]]; then
    mkdir -p "$dir"
  fi

  if [[ -f "$local_path" ]]; then
    echo -e "  ${YELLOW}~${NC} ${local_path} ${DIM}(already exists, overwriting)${NC}"
  fi

  if curl -fsSL "$url" -o "$local_path"; then
    echo -e "  ${GREEN}+${NC} ${local_path}"
  else
    echo -e "  ${RED}x${NC} ${local_path} ${DIM}(download failed)${NC}"
    return 1
  fi
}

# --- Global install mode ---
if $GLOBAL_INSTALL; then
  GLOBAL_FILES=(
    "src/ai-agency.sh:ai-agency.sh"
    "src/setup.sh:setup.sh"
    "src/HOW_TO_AGENTS.md:HOW_TO_AGENTS.md"
    "src/scripts/sync-ai-rules.sh:scripts/sync-ai-rules.sh"
    "src/bin/ai-agency:bin/ai-agency"
  )

  INSTALL_DIR="${HOME}/.local/share/ai-agency"
  BIN_DIR="${HOME}/.local/bin"

  echo -e "${BOLD}Installing globally...${NC}"
  echo ""

  mkdir -p "$INSTALL_DIR" "$BIN_DIR"

  for entry in "${GLOBAL_FILES[@]}"; do
    repo_path="${entry%%:*}"
    file="${entry##*:}"
    download_file "$repo_path" "$file"
    local_path="${INSTALL_DIR}/${file}"
    mkdir -p "$(dirname "$local_path")"
    mv "$file" "$local_path"
    if [[ "$file" == *.sh || "$file" == bin/* ]]; then
      chmod +x "$local_path"
    fi
    echo -e "  ${GREEN}→${NC} ${local_path}"
  done

  # Create symlink in bin
  ln -sf "${INSTALL_DIR}/bin/ai-agency" "${BIN_DIR}/ai-agency"

  echo ""
  echo -e "${GREEN}${BOLD}Global install complete!${NC}"
  echo ""
  echo -e "  Command: ${BOLD}ai-agency${NC}"
  echo -e "  Location: ${DIM}${BIN_DIR}/ai-agency${NC}"
  echo ""

  # Check if BIN_DIR is in PATH
  if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
    echo -e "${YELLOW}Add to your shell profile:${NC}"
    echo -e "  ${BOLD}export PATH=\"${BIN_DIR}:\$PATH\"${NC}"
    echo ""
  fi

  echo -e "${BOLD}Quick start:${NC}"
  echo -e "  ${CYAN}ai-agency init /path/to/project${NC}      — initialize a project"
  echo -e "  ${CYAN}ai-agency register /path/to/project${NC}  — register a project"
  echo -e "  ${CYAN}ai-agency scan ~/projects${NC}             — auto-discover projects"
  echo -e "  ${CYAN}ai-agency${NC}                              — launch agent picker"
  echo ""
  exit 0
fi

# Download required files
for entry in "${REQUIRED_FILES[@]}"; do
  repo_path="${entry%%:*}"
  local_path="${entry##*:}"
  download_file "$repo_path" "$local_path"
done

# Make shell scripts executable
chmod +x setup.sh ai-agency.sh scripts/sync-ai-rules.sh

echo ""
echo -e "${GREEN}${BOLD}Download complete!${NC}"
echo ""

# --- Run setup or show next steps ---
if $AUTO_RUN; then
  echo -e "${DIM}Starting setup...${NC}"
  echo ""
  exec ./setup.sh
else
  echo -e "${BOLD}Next steps:${NC}"
  echo ""
  echo -e "  ${CYAN}# Run interactive setup${NC}"
  echo -e "  ${BOLD}./setup.sh${NC}"
  echo ""
  echo -e "  ${CYAN}# Launch agent sessions after setup${NC}"
  echo -e "  ${BOLD}./ai-agency.sh${NC}"
  echo ""
  echo -e "  ${CYAN}# Or install globally${NC}"
  echo -e "  ${BOLD}curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/src/install.sh | bash -s -- --global${NC}"
  echo ""
fi
