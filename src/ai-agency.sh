#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# ai-agency.sh
# AGENTS.md-based agent session launcher
#
# Scans the project for AGENTS.md files, displays the agent list,
# and starts an AI tool session with the selected agent's context.
#
# Usage:
#   ./ai-agency.sh                    # Interactive selection
#   ./ai-agency.sh --tool claude      # Specify tool
#   ./ai-agency.sh --agent infra      # Select agent by keyword
#   ./ai-agency.sh --multi            # tmux multi-session
#   ./ai-agency.sh --list             # Print agent list only
#
# Tip: Use iTerm2 (or kitty/WezTerm) for per-agent background colors.
#      IDE built-in terminals (IntelliJ, VS Code) do not support background
#      color changes. A colored banner is shown instead.
# =============================================================================

# --- Ensure cursor is restored on any exit (Ctrl+C, errors, etc.) ---
trap 'printf "\033[?25h"; tput cnorm 2>/dev/null || true' EXIT INT TERM

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Agent Color Palette ---
# Text colors (bright, for agent list display)
AGENT_COLORS=(
  '\033[38;5;214m'  # orange
  '\033[38;5;39m'   # blue
  '\033[38;5;154m'  # lime green
  '\033[38;5;205m'  # pink
  '\033[38;5;51m'   # cyan
  '\033[38;5;220m'  # gold
  '\033[38;5;141m'  # purple
  '\033[38;5;203m'  # coral
  '\033[38;5;49m'   # teal
  '\033[38;5;183m'  # lavender
  '\033[38;5;208m'  # dark orange
  '\033[38;5;117m'  # sky blue
  '\033[38;5;156m'  # light green
  '\033[38;5;175m'  # mauve
  '\033[38;5;81m'   # steel blue
)

# Terminal background colors (subtle dark tints — readable with light text)
# OSC 11 format: rgb:RR/GG/BB (hex pairs)
TERM_BG_COLORS=(
  '1a/14/0a'  # dark warm brown (PM)
  '0a/14/1a'  # dark navy
  '0a/1a/0f'  # dark forest
  '1a/0a/14'  # dark plum
  '0a/1a/1a'  # dark teal
  '1a/16/0a'  # dark amber
  '12/0a/1a'  # dark violet
  '1a/0e/0a'  # dark rust
  '0a/1a/15'  # dark mint
  '14/0f/1a'  # dark lavender
  '1a/10/0a'  # dark orange-brown
  '0a/12/1a'  # dark steel
  '0f/1a/0a'  # dark lime
  '1a/0a/0f'  # dark rose
  '0a/16/1a'  # dark aqua
)

# Human-readable background color names (matches TERM_BG_COLORS order)
BG_COLOR_NAMES=(
  'Warm Brown'
  'Navy'
  'Forest'
  'Plum'
  'Teal'
  'Amber'
  'Violet'
  'Rust'
  'Mint'
  'Lavender'
  'Orange-Brown'
  'Steel'
  'Lime'
  'Rose'
  'Aqua'
)

get_bg_color_name() {
  local idx=$1
  local palette_size=${#BG_COLOR_NAMES[@]}
  echo "${BG_COLOR_NAMES[$((idx % palette_size))]}"
}

# --- Hidden agents config ---
declare -a HIDDEN_INDICES=()
AI_AGENCY_CONFIG_DIR="${HOME}/.config/ai-agency"

get_hidden_file() {
  local project_hash
  project_hash=$(echo -n "$PROJECT_ROOT" | md5 2>/dev/null || echo -n "$PROJECT_ROOT" | md5sum 2>/dev/null | cut -d' ' -f1)
  echo "${AI_AGENCY_CONFIG_DIR}/hidden_${project_hash}"
}

load_hidden_agents() {
  HIDDEN_INDICES=()
  local hidden_file
  hidden_file=$(get_hidden_file)
  if [[ -f "$hidden_file" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] && HIDDEN_INDICES+=("$line")
    done < "$hidden_file"
  fi
}

save_hidden_agents() {
  mkdir -p "$AI_AGENCY_CONFIG_DIR"
  local hidden_file
  hidden_file=$(get_hidden_file)
  if [[ ${#HIDDEN_INDICES[@]} -gt 0 ]]; then
    printf '%s\n' "${HIDDEN_INDICES[@]}" > "$hidden_file" 2>/dev/null || true
  else
    > "$hidden_file"
  fi
}

is_hidden() {
  local idx=$1
  [[ ${#HIDDEN_INDICES[@]} -eq 0 ]] && return 1
  for h in "${HIDDEN_INDICES[@]}"; do
    [[ "$h" == "$idx" ]] && return 0
  done
  return 1
}

# --- Multi-select CUI ---
# ↑↓ navigate, Space toggle, a toggle-all, Enter confirm.
# Sets CUI_MULTI_RESULT (space-separated 0-based indices). Returns 1 on quit.
CUI_MULTI_RESULT=""
cui_multi_menu() {
  local -a items=("$@")
  local count=${#items[@]}
  local cursor=0
  local first_draw=true
  local -a selected=()

  for (( i=0; i<count; i++ )); do selected+=("0"); done

  [[ $count -eq 0 ]] && { CUI_MULTI_RESULT=""; return 1; }

  printf '\033[?25l'
  trap 'printf "\033[?25h"' RETURN

  while true; do
    if ! $first_draw; then
      printf "\033[${count}A"
    fi
    first_draw=false

    for i in "${!items[@]}"; do
      printf '\033[2K\r'
      local check=" "
      [[ "${selected[$i]}" == "1" ]] && check="✓"
      if (( i == cursor )); then
        echo -e "  ${GREEN}▸${NC} [${GREEN}${check}${NC}] ${BOLD}$((i + 1)))${NC} ${BOLD}${items[$i]}${NC}"
      else
        echo -e "    [${check}] ${DIM}$((i + 1)))${NC} ${items[$i]}"
      fi
    done

    local key=""
    IFS= read -rsn1 key </dev/tty

    case "$key" in
      $'\x1b')
        local seq1 seq2
        IFS= read -rsn1 -t 1 seq1 </dev/tty || true
        IFS= read -rsn1 -t 1 seq2 </dev/tty || true
        case "${seq1}${seq2}" in
          '[A') (( cursor > 0 )) && cursor=$((cursor - 1)) || true ;;
          '[B') (( cursor < count - 1 )) && cursor=$((cursor + 1)) || true ;;
        esac
        ;;
      ' ')
        if [[ "${selected[$cursor]}" == "1" ]]; then
          selected[$cursor]="0"
        else
          selected[$cursor]="1"
        fi
        ;;
      a|A)
        local all_on=true
        for (( i=0; i<count; i++ )); do
          [[ "${selected[$i]}" == "0" ]] && { all_on=false; break; }
        done
        if $all_on; then
          for (( i=0; i<count; i++ )); do selected[$i]="0"; done
        else
          for (( i=0; i<count; i++ )); do selected[$i]="1"; done
        fi
        ;;
      '')
        CUI_MULTI_RESULT=""
        for i in "${!selected[@]}"; do
          if [[ "${selected[$i]}" == "1" ]]; then
            [[ -n "$CUI_MULTI_RESULT" ]] && CUI_MULTI_RESULT+=" "
            CUI_MULTI_RESULT+="$i"
          fi
        done
        return 0
        ;;
      q|Q)
        CUI_MULTI_RESULT=""
        return 1
        ;;
    esac
  done
}

# --- Interactive CUI ---
# Pure bash TUI with arrow key navigation
cui_select() {
  # Usage: cui_select "title" item1 item2 item3 ...
  # Returns selected index (0-based) via CUI_RESULT
  # Returns 255 if quit
  local title="$1"; shift
  local -a items=("$@")
  local count=${#items[@]}
  local cursor=0
  local show_hidden=false
  local viewport_start=0

  [[ $count -eq 0 ]] && return 255

  # Hide cursor
  tput civis 2>/dev/null || true

  # Restore cursor on exit from this function
  trap 'tput cnorm 2>/dev/null || true; printf "\033[?25h"' RETURN

  # Initial clear (only once)
  printf '\033[2J\033[H'

  while true; do
    # Build visible items list based on mode
    local -a visible_indices=()
    local -a hidden_vis_indices=()

    for i in "${!items[@]}"; do
      if is_hidden "$i"; then
        hidden_vis_indices+=("$i")
      else
        visible_indices+=("$i")
      fi
    done

    local -a current_indices
    local mode_label
    if $show_hidden; then
      current_indices=("${hidden_vis_indices[@]+"${hidden_vis_indices[@]}"}")
      mode_label="${DIM}[Hidden Agents]${NC}  ${DIM}Press: ${BOLD}u${NC}${DIM} unhide  ${BOLD}s${NC}${DIM} go back  ${BOLD}←${NC}${DIM} go back${NC}"
    else
      current_indices=("${visible_indices[@]+"${visible_indices[@]}"}")
      mode_label="${DIM}Press: ${BOLD}↑↓${NC}${DIM} navigate  ${BOLD}Enter${NC}${DIM} select  ${BOLD}h${NC}${DIM} hide  ${BOLD}s${NC}${DIM} show hidden (${#hidden_vis_indices[@]})  ${BOLD}q${NC}${DIM} quit${NC}"
    fi

    local current_count=${#current_indices[@]}

    # Clamp cursor
    if [[ $current_count -eq 0 ]]; then
      cursor=0
    elif (( cursor >= current_count )); then
      cursor=$((current_count - 1))
    fi

    # Calculate viewport — fill terminal height, spread items evenly
    local term_lines
    term_lines=$(stty size 2>/dev/null | cut -d' ' -f1)
    [[ -z "$term_lines" || "$term_lines" == "0" ]] && term_lines=$(tput lines 2>/dev/null || echo 24)
    local header_lines=7   # blank + title + project + nav + blank + scroll indicators
    local available=$(( term_lines - header_lines ))
    (( available < 6 )) && available=6

    # Distribute available space across items
    local lines_per_item
    if (( current_count > 0 )); then
      lines_per_item=$(( available / current_count ))
    else
      lines_per_item=4
    fi
    (( lines_per_item > 6 )) && lines_per_item=6   # cap: no excessive gaps
    (( lines_per_item < 3 )) && lines_per_item=3   # floor: always name + path + role

    local max_visible=$(( available / lines_per_item ))
    (( max_visible < 1 )) && max_visible=1
    (( max_visible > current_count )) && max_visible=$current_count

    # Adjust viewport to keep cursor visible
    if (( cursor < viewport_start )); then
      viewport_start=$cursor
    elif (( cursor >= viewport_start + max_visible )); then
      viewport_start=$(( cursor - max_visible + 1 ))
    fi
    (( viewport_start < 0 )) && viewport_start=0

    local viewport_end=$(( viewport_start + max_visible ))
    (( viewport_end > current_count )) && viewport_end=$current_count

    # Draw frame — cursor home, overwrite in place (no clear = no flicker)
    printf '\033[H'

    echo -e "\033[2K"
    if [[ $current_count -gt 0 ]]; then
      echo -e "\033[2K${BOLD}${title}${NC}  ${DIM}($((cursor + 1))/${current_count})${NC}"
    else
      echo -e "\033[2K${BOLD}${title}${NC}"
    fi
    echo -e "\033[2K${DIM}Project: ${PROJECT_ROOT}${NC}"
    echo -e "\033[2K$mode_label"
    echo -e "\033[2K"

    if [[ $current_count -eq 0 ]]; then
      if $show_hidden; then
        echo -e "\033[2K  ${DIM}(no hidden agents)${NC}"
      else
        echo -e "\033[2K  ${DIM}(all agents are hidden — press 's' to manage)${NC}"
      fi
    else
      # Scroll up indicator
      if (( viewport_start > 0 )); then
        echo -e "\033[2K  ${DIM}▲ ${viewport_start} more above${NC}"
      fi

      for (( vi=viewport_start; vi<viewport_end; vi++ )); do
        local real_idx="${current_indices[$vi]}"
        local name="${AGENT_NAMES[$real_idx]}"
        local role="${AGENT_ROLES[$real_idx]}"
        local dir="${AGENT_DIRS[$real_idx]}"
        local color
        color=$(get_agent_color "$real_idx")
        local bg_name
        bg_name=$(get_bg_color_name "$real_idx")

        # Determine hierarchy tag and indentation
        local tag=""
        local indent=""
        if [[ "$dir" == "." ]]; then
          tag="[PM] "
        else
          # Check if this agent has sub-agents (making it a coordinator)
          local has_children=false
          for chk_idx in "${!AGENT_DIRS[@]}"; do
            [[ "$chk_idx" -eq "$real_idx" ]] && continue
            if [[ "${AGENT_DIRS[$chk_idx]}" == "${dir}/"* ]]; then
              has_children=true
              break
            fi
          done
          $has_children && tag="[Coord] "

          # Indentation based on directory depth
          local depth
          depth=$(echo "$dir" | tr '/' '\n' | wc -l | tr -d ' ')
          local d=0
          while (( d < depth )); do
            indent+="  "
            d=$((d + 1))
          done
        fi

        local display_path="./AGENTS.md"
        [[ "$dir" != "." ]] && display_path="${dir}/AGENTS.md"

        if (( vi == cursor )); then
          echo -e "\033[2K${indent}  \033[7m ${color}${BOLD}$((real_idx + 1)))${NC}\033[7m ${BOLD}${tag}${name}${NC}\033[7m ${DIM}(bg: ${bg_name})${NC}\033[0m"
          echo -e "\033[2K${indent}     ${DIM}Path: ${display_path}${NC}"
          echo -e "\033[2K${indent}     ${color}${role}${NC}"
        else
          local num=$((real_idx + 1))
          echo -e "\033[2K${indent}  ${color}${BOLD}${num})${NC} ${color}${BOLD}${tag}${name}${NC} ${DIM}(bg: ${bg_name})${NC}"
          echo -e "\033[2K${indent}     ${DIM}Path: ${display_path}${NC}"
          echo -e "\033[2K${indent}     ${color}${role}${NC}"
        fi
        # Dynamic padding based on available space
        local padding=$(( lines_per_item - 3 ))
        for (( p=0; p<padding; p++ )); do echo -e "\033[2K"; done
      done

      # Scroll down indicator
      local remaining=$(( current_count - viewport_end ))
      if (( remaining > 0 )); then
        echo -e "\033[2K  ${DIM}▼ ${remaining} more below${NC}"
      fi
    fi

    # Clear any leftover lines from previous frame
    printf '\033[J'

    # Read key
    local key=""
    IFS= read -rsn1 key

    case "$key" in
      $'\x1b')
        # Escape sequence — read arrow keys
        local seq1 seq2
        IFS= read -rsn1 -t 1 seq1 || true
        IFS= read -rsn1 -t 1 seq2 || true
        case "${seq1}${seq2}" in
          '[A') # Up arrow
            (( cursor > 0 )) && cursor=$((cursor - 1)) || true
            ;;
          '[B') # Down arrow
            (( cursor < current_count - 1 )) && cursor=$((cursor + 1)) || true
            ;;
          '[D') # Left arrow — same as 's' (toggle hidden view)
            if $show_hidden; then
              show_hidden=false
              cursor=0
              viewport_start=0
            fi
            ;;
          '[C') # Right arrow — same as 's' (toggle hidden view)
            if ! $show_hidden && [[ ${#hidden_vis_indices[@]} -gt 0 ]]; then
              show_hidden=true
              cursor=0
              viewport_start=0
            fi
            ;;
        esac
        ;;
      '')
        # Enter key
        if [[ $current_count -gt 0 ]]; then
          CUI_RESULT="${current_indices[$cursor]}"
          return 0
        fi
        ;;
      h|H)
        # Hide selected agent (only in normal view)
        if ! $show_hidden && [[ $current_count -gt 0 ]]; then
          local to_hide="${current_indices[$cursor]}"
          HIDDEN_INDICES+=("$to_hide")
          save_hidden_agents
        fi
        ;;
      u|U)
        # Unhide selected agent (only in hidden view)
        if $show_hidden && [[ $current_count -gt 0 ]]; then
          local to_unhide="${current_indices[$cursor]}"
          local -a new_hidden=()
          if [[ ${#HIDDEN_INDICES[@]} -gt 0 ]]; then
            for h in "${HIDDEN_INDICES[@]}"; do
              [[ "$h" != "$to_unhide" ]] && new_hidden+=("$h")
            done
          fi
          HIDDEN_INDICES=("${new_hidden[@]+"${new_hidden[@]}"}")
          save_hidden_agents
        fi
        ;;
      s|S)
        # Toggle hidden view
        if $show_hidden; then
          show_hidden=false
        else
          show_hidden=true
        fi
        cursor=0
        viewport_start=0
        ;;
      q|Q)
        CUI_RESULT=255
        return 255
        ;;
      [0-9])
        # Quick number selection (legacy support)
        local num_choice="$key"
        # Try to read more digits quickly
        local more
        IFS= read -rsn1 -t 1 more || true
        if [[ "$more" =~ ^[0-9]$ ]]; then
          num_choice="${num_choice}${more}"
        fi
        if (( num_choice >= 1 && num_choice <= ${#items[@]} )); then
          CUI_RESULT=$((num_choice - 1))
          return 0
        fi
        ;;
    esac
  done
}

# CUI for tool selection
cui_select_tool() {
  local cursor=0
  local -a tools=("claude  — Claude Code CLI" "codex   — OpenAI Codex CLI" "print   — Print prompt only (for manual copy)")
  local -a tool_ids=("claude" "codex" "print")
  local count=${#tools[@]}

  tput civis 2>/dev/null || true
  trap 'tput cnorm 2>/dev/null || true' RETURN

  printf '\033[2J\033[H'

  while true; do
    printf '\033[H'

    echo -e "\033[2K"
    echo -e "\033[2K${BOLD}=== AI Tool ===${NC}"
    echo -e "\033[2K${DIM}Press: ${BOLD}↑↓${NC}${DIM} navigate  ${BOLD}Enter${NC}${DIM} select  ${BOLD}q${NC}${DIM} quit${NC}"
    echo -e "\033[2K"

    for i in "${!tools[@]}"; do
      if (( i == cursor )); then
        echo -e "\033[2K  \033[7m ${GREEN}${BOLD}$((i + 1)))${NC}\033[7m ${BOLD}${tools[$i]}${NC}\033[0m"
      else
        echo -e "\033[2K  ${GREEN}$((i + 1)))${NC} ${tools[$i]}"
      fi
    done
    echo -e "\033[2K"

    printf '\033[J'

    local key=""
    IFS= read -rsn1 key

    case "$key" in
      $'\x1b')
        local seq1 seq2
        IFS= read -rsn1 -t 1 seq1 || true
        IFS= read -rsn1 -t 1 seq2 || true
        case "${seq1}${seq2}" in
          '[A') (( cursor > 0 )) && cursor=$((cursor - 1)) || true ;;
          '[B') (( cursor < count - 1 )) && cursor=$((cursor + 1)) || true ;;
        esac
        ;;
      '')
        TOOL="${tool_ids[$cursor]}"
        return 0
        ;;
      q|Q) exit 0 ;;
      [1-3])
        TOOL="${tool_ids[$((key - 1))]}"
        return 0
        ;;
    esac
  done
}

# tmux pane background colors (256-color approximation of above)
TMUX_PANE_BG=(
  '#1a140a'
  '#0a141a'
  '#0a1a0f'
  '#1a0a14'
  '#0a1a1a'
  '#1a160a'
  '#120a1a'
  '#1a0e0a'
  '#0a1a15'
  '#140f1a'
)

# tmux status-bar foreground colors per window
TMUX_FG_COLORS=(
  'colour214'  # orange
  'colour39'   # blue
  'colour154'  # lime
  'colour205'  # pink
  'colour51'   # cyan
  'colour220'  # gold
  'colour141'  # purple
  'colour203'  # coral
  'colour49'   # teal
  'colour183'  # lavender
)

get_agent_color() {
  local idx=$1
  local palette_size=${#AGENT_COLORS[@]}
  echo "${AGENT_COLORS[$((idx % palette_size))]}"
}

# ANSI background colors for banner (bright enough to be visible, works EVERYWHERE)
BANNER_BG_COLORS=(
  '\033[48;5;94m'   # brown
  '\033[48;5;24m'   # navy
  '\033[48;5;22m'   # forest
  '\033[48;5;53m'   # plum
  '\033[48;5;30m'   # teal
  '\033[48;5;136m'  # amber
  '\033[48;5;54m'   # violet
  '\033[48;5;130m'  # rust
  '\033[48;5;29m'   # mint
  '\033[48;5;60m'   # lavender
  '\033[48;5;166m'  # orange-brown
  '\033[48;5;66m'   # steel
  '\033[48;5;64m'   # lime
  '\033[48;5;125m'  # rose
  '\033[48;5;37m'   # aqua
)

# Change terminal background via OSC 11 (works in iTerm2, kitty, WezTerm; ignored elsewhere)
set_term_bg() {
  local idx=$1
  local palette_size=${#TERM_BG_COLORS[@]}
  local bg="${TERM_BG_COLORS[$((idx % palette_size))]}"
  printf '\033]11;rgb:%s\033\\' "$bg"
}

# Reset terminal background to default
reset_term_bg() {
  printf '\033]111;\033\\'
}

# Set terminal tab/window title via OSC 0 (works in almost all terminals)
set_term_title() {
  local title="$1"
  printf '\033]0;%s\007' "$title"
}

# Print a full-width colored banner (works in ALL terminals including IntelliJ, VS Code)
print_agent_banner() {
  local idx=$1
  local name="$2"
  local bg_name="$3"
  local palette_size=${#BANNER_BG_COLORS[@]}
  local banner_bg="${BANNER_BG_COLORS[$((idx % palette_size))]}"
  local color
  color=$(get_agent_color "$idx")

  # Get terminal width, default 80
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)

  local label=" Agent: ${name} "
  local pad_len=$(( cols - ${#label} ))
  [[ $pad_len -lt 0 ]] && pad_len=0
  local padding
  padding=$(printf '%*s' "$pad_len" '')

  echo ""
  echo -e "${banner_bg}\033[1;37m${label}${padding}${NC}"
  echo ""
}

# --- i18n for mode selection ---
SUPPORTED_LANGS=("en" "ko" "ja" "zh" "es" "fr" "de" "ru" "hi" "ar")
SUPPORTED_LANG_NAMES=("English" "한국어" "日本語" "中文" "Español" "Français" "Deutsch" "Русский" "हिन्दी" "العربية")

load_lang() {
  local lang_file="${HOME}/.config/ai-agency/lang"
  if [[ -f "$lang_file" ]]; then
    UI_LANG=$(cat "$lang_file")
  else
    UI_LANG="en"
  fi
}

save_lang() {
  local code="$1"
  mkdir -p "${HOME}/.config/ai-agency"
  echo "$code" > "${HOME}/.config/ai-agency/lang"
}

is_valid_lang() {
  local code="$1"
  for lang in "${SUPPORTED_LANGS[@]}"; do
    [[ "$lang" == "$code" ]] && return 0
  done
  return 1
}

interactive_lang_select() {
  echo ""
  echo -e "${BOLD}Select UI language:${NC}"
  echo ""
  for i in "${!SUPPORTED_LANGS[@]}"; do
    local mark=" "
    [[ "${SUPPORTED_LANGS[$i]}" == "$UI_LANG" ]] && mark="●"
    echo -e "  ${GREEN}$((i + 1)))${NC} ${mark} ${SUPPORTED_LANG_NAMES[$i]}  ${DIM}(${SUPPORTED_LANGS[$i]})${NC}"
  done
  echo ""
  echo -ne "  ${BOLD}(1-${#SUPPORTED_LANGS[@]}):${NC} "
  read -r choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#SUPPORTED_LANGS[@]} )); then
    local idx=$((choice - 1))
    save_lang "${SUPPORTED_LANGS[$idx]}"
    echo -e "  ${GREEN}✓${NC} ${SUPPORTED_LANG_NAMES[$idx]} (${SUPPORTED_LANGS[$idx]})"
  else
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
  fi
}

set_mode_strings() {
  case "$UI_LANG" in
    ko)
      L_MODE_TITLE="=== 실행 모드 ==="
      L_MODE_NAV="↑↓ 이동  Enter 선택  q 종료"
      L_MODE_TEAM="Team 모드 — PM이 하위 에이전트를 자동 조율 (tmux/iTerm2 분할 창)"
      L_MODE_SINGLE="Single 모드 — 선택한 에이전트 1개만 실행"
      L_MODE_MULTI="Multi 모드 — tmux 창에서 여러 에이전트 병렬 실행"
      L_SUB_AGENTS="하위 에이전트:"
      L_SELECT_SUB_AGENTS="참여할 하위 에이전트를 선택하세요"
      L_SELECT_SUB_NAV="↑↓ 이동  Space 토글  a 전체  Enter 확인"
      ;;
    ja)
      L_MODE_TITLE="=== 実行モード ==="
      L_MODE_NAV="↑↓ 移動  Enter 選択  q 終了"
      L_MODE_TEAM="Teamモード — PMがサブエージェントを自動調整（tmux/iTerm2分割表示）"
      L_MODE_SINGLE="Singleモード — 選択したエージェント1つのみ実行"
      L_MODE_MULTI="Multiモード — tmuxウィンドウで複数エージェント並列実行"
      L_SUB_AGENTS="サブエージェント:"
      L_SELECT_SUB_AGENTS="参加するサブエージェントを選択"
      L_SELECT_SUB_NAV="↑↓ 移動  Space 切替  a 全選択  Enter 確定"
      ;;
    zh)
      L_MODE_TITLE="=== 执行模式 ==="
      L_MODE_NAV="↑↓ 导航  Enter 选择  q 退出"
      L_MODE_TEAM="Team模式 — PM自动协调子代理（tmux/iTerm2分屏）"
      L_MODE_SINGLE="Single模式 — 仅运行所选代理"
      L_MODE_MULTI="Multi模式 — 在tmux窗口中并行运行多个代理"
      L_SUB_AGENTS="子代理:"
      L_SELECT_SUB_AGENTS="选择参与的子代理"
      L_SELECT_SUB_NAV="↑↓ 导航  Space 切换  a 全选  Enter 确认"
      ;;
    *)
      L_MODE_TITLE="=== Execution Mode ==="
      L_MODE_NAV="↑↓ navigate  Enter select  q quit"
      L_MODE_TEAM="Team mode — PM coordinates sub-agents in split panes (tmux/iTerm2)"
      L_MODE_SINGLE="Single mode — run selected agent only"
      L_MODE_MULTI="Multi mode — parallel agents in tmux windows"
      L_SUB_AGENTS="Sub-agents:"
      L_SELECT_SUB_AGENTS="Select sub-agents to include"
      L_SELECT_SUB_NAV="↑↓ navigate  Space toggle  a toggle-all  Enter confirm"
      ;;
  esac
}

# --- Mode selection CUI ---
LAUNCH_MODE="single"  # single | team | multi
TEAM_AGENT_INDICES=""  # space-separated sub-agent indices for team mode

cui_select_mode() {
  local has_sub_agents=$1
  local cursor=0

  # Build options list
  local -a mode_ids=()
  local -a mode_labels=()

  if [[ "$has_sub_agents" == "true" ]]; then
    mode_ids+=("team")
    mode_labels+=("$L_MODE_TEAM")
  fi

  mode_ids+=("single")
  mode_labels+=("$L_MODE_SINGLE")

  # If only single is available, skip CUI
  if [[ ${#mode_ids[@]} -eq 1 ]]; then
    LAUNCH_MODE="${mode_ids[0]}"
    return 0
  fi

  local count=${#mode_ids[@]}

  tput civis 2>/dev/null || true
  trap 'tput cnorm 2>/dev/null || true' RETURN

  printf '\033[2J\033[H'

  while true; do
    printf '\033[H'

    echo -e "\033[2K"
    echo -e "\033[2K${BOLD}${L_MODE_TITLE}${NC}"
    echo -e "\033[2K${DIM}${L_MODE_NAV}${NC}"
    echo -e "\033[2K"

    for i in "${!mode_labels[@]}"; do
      local prefix="${mode_ids[$i]}"
      if (( i == cursor )); then
        echo -e "\033[2K  \033[7m ${GREEN}${BOLD}$((i + 1)))${NC}\033[7m ${BOLD}${mode_labels[$i]}${NC}\033[0m"
      else
        echo -e "\033[2K  ${GREEN}$((i + 1)))${NC} ${mode_labels[$i]}"
      fi
    done
    echo -e "\033[2K"

    # Show sub-agents if team mode is highlighted
    if [[ "${mode_ids[$cursor]}" == "team" ]]; then
      echo -e "\033[2K  ${DIM}${L_SUB_AGENTS}${NC}"
      for sub_idx in "${!AGENT_DIRS[@]}"; do
        [[ "$sub_idx" -eq "$SELECTED_IDX" ]] && continue
        is_hidden "$sub_idx" && continue
        local sub_dir="${AGENT_DIRS[$sub_idx]}"
        local selected_dir="${AGENT_DIRS[$SELECTED_IDX]}"
        if [[ "$selected_dir" == "." ]] || [[ "$sub_dir" == "${selected_dir}/"* ]]; then
          echo -e "\033[2K    ${DIM}• ${AGENT_NAMES[$sub_idx]} (${sub_dir})${NC}"
        fi
      done
      echo -e "\033[2K"
    fi

    printf '\033[J'

    local key=""
    IFS= read -rsn1 key

    case "$key" in
      $'\x1b')
        local seq1 seq2
        IFS= read -rsn1 -t 1 seq1 || true
        IFS= read -rsn1 -t 1 seq2 || true
        case "${seq1}${seq2}" in
          '[A') (( cursor > 0 )) && cursor=$((cursor - 1)) || true ;;
          '[B') (( cursor < count - 1 )) && cursor=$((cursor + 1)) || true ;;
        esac
        ;;
      '')
        LAUNCH_MODE="${mode_ids[$cursor]}"
        return 0
        ;;
      q|Q) exit 0 ;;
      [1-9])
        if (( key >= 1 && key <= count )); then
          LAUNCH_MODE="${mode_ids[$((key - 1))]}"
          return 0
        fi
        ;;
    esac
  done
}

# --- Defaults ---
# PROJECT_ROOT: 1) env var, 2) git root if in a repo, 3) current working directory
if [[ -n "${PROJECT_ROOT:-}" ]]; then
  PROJECT_ROOT="$PROJECT_ROOT"
elif git rev-parse --show-toplevel &>/dev/null; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel)"
else
  PROJECT_ROOT="$PWD"
fi
TOOL=""
AGENT_FILTER=""
MULTI_MODE=false
LIST_ONLY=false
TMUX_SESSION="ai-agents"

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool|-t)    TOOL="$2"; shift 2 ;;
    --agent|-a)   AGENT_FILTER="$2"; shift 2 ;;
    --multi|-m)   MULTI_MODE=true; shift ;;
    --list|-l)    LIST_ONLY=true; shift ;;
    --lang)
      if [[ -n "${2:-}" ]] && [[ "$2" != --* ]]; then
        if is_valid_lang "$2"; then
          save_lang "$2"
          echo -e "Language set to: $2"
        else
          echo -e "Unknown language: $2"
          echo -e "Supported: ${SUPPORTED_LANGS[*]}"
          exit 1
        fi
        exit 0
      else
        load_lang
        interactive_lang_select
        exit 0
      fi
      ;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -t, --tool <claude|codex|cursor>   Select AI tool"
      echo "  -a, --agent <keyword>              Select agent by keyword"
      echo "  -m, --multi                        tmux multi-agent session"
      echo "  -l, --list                         Print agent list only"
      echo "      --lang [code]                  Set UI language (${SUPPORTED_LANGS[*]})"
      echo "  -h, --help                         Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Scan AGENTS.md files ---
declare -a AGENT_PATHS=()
declare -a AGENT_NAMES=()
declare -a AGENT_ROLES=()
declare -a AGENT_DIRS=()

scan_agents() {
  local root="$1"

  while IFS= read -r agents_file; do
    local dir
    dir="$(dirname "$agents_file")"
    local rel_dir="${dir#"$root"}"
    rel_dir="${rel_dir#/}"
    [[ -z "$rel_dir" ]] && rel_dir="."

    # Extract role from AGENTS.md (first ## Role section content, multilingual)
    local role=""
    role=$(awk '/^## (Role|역할|役割|角色|Rol|Rôle|Rolle|Роль|भूमिका|الدور)/{found=1; next} found && /^##/{exit} found && NF{print; exit}' "$agents_file" 2>/dev/null)
    [[ -z "$role" ]] && role=$(head -1 "$agents_file" | sed 's/^# //')

    # Extract name from first heading
    local name=""
    name=$(head -1 "$agents_file" | sed 's/^# //')
    [[ -z "$name" ]] && name="$rel_dir"

    AGENT_PATHS+=("$agents_file")
    AGENT_NAMES+=("$name")
    AGENT_ROLES+=("$role")
    AGENT_DIRS+=("$rel_dir")
  done <<< "$(find "$root" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" -not -path "*/__pycache__/*" | sed 's|/AGENTS\.md$||' | sort | sed 's|$|/AGENTS.md|')"
}

scan_agents "$PROJECT_ROOT"

if [[ ${#AGENT_PATHS[@]} -eq 0 ]]; then
  echo -e "${RED}No AGENTS.md files found.${NC}"
  echo ""
  echo "Generate AGENTS.md files first:"
  echo "  1. Run ./setup.sh (interactive auto-setup)"
  echo "  2. Or manually: claude --dangerously-skip-permissions \"Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project\""
  exit 1
fi

# --- Display agent list ---
display_agents() {
  echo ""
  echo -e "${BOLD}=== AI Agent Sessions ===${NC}"
  echo -e "${DIM}Project: ${PROJECT_ROOT}${NC}"
  echo -e "${DIM}Found: ${#AGENT_PATHS[@]} agent(s)${NC}"
  echo ""

  # Fill terminal height, spread items evenly
  local term_lines
  term_lines=$(stty size 2>/dev/null | cut -d' ' -f1)
  [[ -z "$term_lines" || "$term_lines" == "0" ]] && term_lines=$(tput lines 2>/dev/null || echo 24)
  local header_lines=5  # blank + title + project + found + blank
  local available=$(( term_lines - header_lines ))
  (( available < 6 )) && available=6
  local agent_count=${#AGENT_PATHS[@]}
  local lines_per_item
  if (( agent_count > 0 )); then
    lines_per_item=$(( available / agent_count ))
  else
    lines_per_item=4
  fi
  (( lines_per_item > 6 )) && lines_per_item=6
  (( lines_per_item < 3 )) && lines_per_item=3

  local i=0
  for idx in "${!AGENT_PATHS[@]}"; do
    i=$((idx + 1))
    local dir="${AGENT_DIRS[$idx]}"
    local name="${AGENT_NAMES[$idx]}"
    local role="${AGENT_ROLES[$idx]}"
    local color
    color=$(get_agent_color "$idx")

    local bg_name
    bg_name=$(get_bg_color_name "$idx")

    # Determine tag and indentation
    local tag=""
    local indent=""
    if [[ "$dir" == "." ]]; then
      tag="[PM] "
    else
      local has_children=false
      for chk_idx in "${!AGENT_DIRS[@]}"; do
        [[ "$chk_idx" -eq "$idx" ]] && continue
        if [[ "${AGENT_DIRS[$chk_idx]}" == "${dir}/"* ]]; then
          has_children=true
          break
        fi
      done
      $has_children && tag="[Coord] "

      local depth
      depth=$(echo "$dir" | tr '/' '\n' | wc -l | tr -d ' ')
      local d=0
      while (( d < depth )); do
        indent+="  "
        d=$((d + 1))
      done
    fi

    local display_path="./AGENTS.md"
    [[ "$dir" != "." ]] && display_path="${dir}/AGENTS.md"

    echo -e "${indent}  ${color}${BOLD}${i})${NC} ${color}${BOLD}${tag}${name}${NC} ${DIM}(bg: ${bg_name})${NC}"
    echo -e "${indent}     ${DIM}Path: ${display_path}${NC}"
    echo -e "${indent}     ${color}${role}${NC}"
    local padding=$(( lines_per_item - 3 ))
    for (( p=0; p<padding; p++ )); do echo ""; done
  done
  echo ""
}

# --- List-only mode ---
if $LIST_ONLY; then
  display_agents
  exit 0
fi

# --- Select agent ---
select_agent() {
  # If --agent filter provided, find matching agent
  if [[ -n "$AGENT_FILTER" ]]; then
    for idx in "${!AGENT_DIRS[@]}"; do
      local lc_filter lc_name lc_role
      lc_filter=$(echo "$AGENT_FILTER" | tr '[:upper:]' '[:lower:]')
      lc_name=$(echo "${AGENT_NAMES[$idx]}" | tr '[:upper:]' '[:lower:]')
      lc_role=$(echo "${AGENT_ROLES[$idx]}" | tr '[:upper:]' '[:lower:]')
      if [[ "${AGENT_DIRS[$idx]}" == *"$AGENT_FILTER"* ]] || \
         [[ "$lc_name" == *"$lc_filter"* ]] || \
         [[ "$lc_role" == *"$lc_filter"* ]]; then
        SELECTED_IDX=$idx
        return 0
      fi
    done
    echo -e "${RED}No agent matching \"${AGENT_FILTER}\" found.${NC}"
    exit 1
  fi

  # Load hidden agents for this project
  load_hidden_agents

  # Interactive CUI selection
  local -a agent_labels=()
  for idx in "${!AGENT_NAMES[@]}"; do
    agent_labels+=("${AGENT_NAMES[$idx]}")
  done

  CUI_RESULT=""
  if cui_select "=== AI Agent Sessions ===" "${agent_labels[@]}"; then
    SELECTED_IDX="$CUI_RESULT"
  else
    exit 0
  fi
}

# --- Select AI tool ---
select_tool() {
  if [[ -n "$TOOL" ]]; then
    return
  fi

  cui_select_tool
}

# --- Build context prompt ---
# Only includes the selected agent + its active (non-hidden) sub-agents
build_prompt() {
  local idx=$1
  local agents_file="${AGENT_PATHS[$idx]}"
  local dir="${AGENT_DIRS[$idx]}"
  local name="${AGENT_NAMES[$idx]}"

  # Ensure hidden agents are loaded
  if [[ -z "${HIDDEN_INDICES+x}" ]]; then
    load_hidden_agents
  fi

  local prompt=""

  if [[ "$dir" != "." ]]; then
    # Sub-agent: read own AGENTS.md, detect sub-project context
    prompt+="Read ${agents_file} and work according to this agent's role and permissions. "
    if [[ -d "${PROJECT_ROOT}/${dir}/.ai-agents/context" ]]; then
      prompt+="Load context files from ${dir}/.ai-agents/context/ as listed in your AGENTS.md Context Files section. "
    fi
    prompt+="Do NOT read the root AGENTS.md or root .ai-agents/context/ files — they are for the PM agent only. "
  else
    # PM agent: read root AGENTS.md (context files loaded via CLAUDE.md)
    prompt+="Read ${agents_file} and work according to this agent's role and permissions. "
  fi

  # Find active (non-hidden) sub-agents under the selected agent's directory
  local selected_dir="${AGENT_DIRS[$idx]}"
  local active_sub_agents=()

  for sub_idx in "${!AGENT_DIRS[@]}"; do
    # Skip self
    [[ "$sub_idx" -eq "$idx" ]] && continue
    # Skip hidden agents
    is_hidden "$sub_idx" && continue

    # In team mode, only include user-selected sub-agents
    if [[ -n "$TEAM_AGENT_INDICES" ]]; then
      local _in_team=false
      for _ti in $TEAM_AGENT_INDICES; do
        [[ "$_ti" == "$sub_idx" ]] && { _in_team=true; break; }
      done
      $_in_team || continue
    fi

    local sub_dir="${AGENT_DIRS[$sub_idx]}"
    # Check if this agent is a sub-agent of the selected one
    if [[ "$selected_dir" == "." ]]; then
      # PM agent: all non-hidden agents are sub-agents
      active_sub_agents+=("${AGENT_NAMES[$sub_idx]} (${sub_dir}/AGENTS.md)")
    elif [[ "$sub_dir" == "${selected_dir}/"* ]]; then
      # Sub-directory agent
      active_sub_agents+=("${AGENT_NAMES[$sub_idx]} (${sub_dir}/AGENTS.md)")
    fi
  done

  # Add active sub-agents to context
  if [[ ${#active_sub_agents[@]} -gt 0 ]]; then
    prompt+="Active sub-agents you can delegate to: "
    local joined
    joined=$(printf '%s, ' "${active_sub_agents[@]}")
    prompt+="${joined%, }. "
  fi

  # List hidden (inactive) agents so the AI knows not to delegate to them
  local hidden_sub_agents=()
  for sub_idx in "${!AGENT_DIRS[@]}"; do
    [[ "$sub_idx" -eq "$idx" ]] && continue
    is_hidden "$sub_idx" || continue

    local sub_dir="${AGENT_DIRS[$sub_idx]}"
    if [[ "$selected_dir" == "." ]] || [[ "$sub_dir" == "${selected_dir}/"* ]]; then
      hidden_sub_agents+=("${AGENT_NAMES[$sub_idx]}")
    fi
  done

  if [[ ${#hidden_sub_agents[@]} -gt 0 ]]; then
    local hidden_joined
    hidden_joined=$(printf '%s, ' "${hidden_sub_agents[@]}")
    prompt+="Do NOT delegate to these hidden/inactive agents: ${hidden_joined%, }. "
  fi

  # Add working directory context
  if [[ "$dir" != "." ]]; then
    prompt+="Working scope is the ${PROJECT_ROOT}/${dir}/ directory. "
    prompt+="Delegate changes outside this scope to the PM agent."
  else
    prompt+="Work as the PM agent managing the entire project. "
    prompt+="Only delegate to the active sub-agents listed above."
  fi

  # Inject single-mode delegation instructions (Agent tool, in-process)
  if [[ "$LAUNCH_MODE" != "team" ]] && [[ ${#active_sub_agents[@]} -gt 0 ]]; then
    prompt+=$'\n\n'
    prompt+="## Sub-Agent Delegation (Single Window)"$'\n'
    prompt+=$'\n'
    prompt+="You are running in single-window mode. Use Claude Code's Agent tool to spawn sub-agents internally when you need to delegate work."$'\n'
    prompt+=$'\n'
    prompt+="How to delegate:"$'\n'
    prompt+="1. Read the sub-agent's AGENTS.md to understand its role and permissions."$'\n'
    prompt+="2. Use the Agent tool to spawn a sub-agent. Include in the prompt:"$'\n'
    prompt+="   - The full content of the sub-agent's AGENTS.md"$'\n'
    prompt+="   - The specific task to perform"$'\n'
    prompt+="   - The working directory scope"$'\n'
    prompt+="3. You may spawn multiple Agent calls in parallel for independent tasks."$'\n'
    prompt+="4. Review each agent's result before proceeding — verify the work, don't just trust the summary."$'\n'
    prompt+=$'\n'
    prompt+="Decide when to delegate vs. do the work yourself based on complexity and scope. "
    prompt+="Simple, focused changes can be done directly. "
    prompt+="Cross-cutting or domain-specific work should be delegated to the appropriate sub-agent."$'\n'
  fi

  # Inject team instructions when team mode is selected
  if [[ "$LAUNCH_MODE" == "team" ]] && [[ ${#active_sub_agents[@]} -gt 0 ]]; then
    prompt+=$'\n\n'

    # Collect sub-agent definitions (shared by both backends)
    local sub_agent_defs=""
    for sub_idx in "${!AGENT_DIRS[@]}"; do
      [[ "$sub_idx" -eq "$idx" ]] && continue
      is_hidden "$sub_idx" && continue
      # In team mode, only include user-selected sub-agents
      if [[ -n "$TEAM_AGENT_INDICES" ]]; then
        local _in_team_def=false
        for _ti in $TEAM_AGENT_INDICES; do
          [[ "$_ti" == "$sub_idx" ]] && { _in_team_def=true; break; }
        done
        $_in_team_def || continue
      fi
      local sub_dir="${AGENT_DIRS[$sub_idx]}"
      if [[ "$selected_dir" == "." ]] || [[ "$sub_dir" == "${selected_dir}/"* ]]; then
        sub_agent_defs+=$'\n'
        sub_agent_defs+="**${AGENT_NAMES[$sub_idx]}** (${sub_dir}/)"$'\n'
        sub_agent_defs+="  AGENTS.md: ${AGENT_PATHS[$sub_idx]}"$'\n'
        sub_agent_defs+="  Role: ${AGENT_ROLES[$sub_idx]}"$'\n'
      fi
    done

    prompt+="## Multi-Agent Execution (Claude Code Agent Teams)"$'\n'
    prompt+=$'\n'
    prompt+="You have Claude Code's native agent teams enabled with tmux split-pane display. "
    prompt+="IMMEDIATELY on session start, create an agent team and spawn ALL sub-agents below as teammates. "
    prompt+="Do NOT wait for user instructions — the user already selected these agents in team mode."$'\n'
    prompt+=$'\n'
    prompt+="1. Create an agent team using the TeamCreate tool."$'\n'
    prompt+="2. Spawn ALL sub-agents below as teammates immediately."$'\n'
    prompt+="   - Each teammate prompt should include the content from the sub-agent's AGENTS.md file."$'\n'
    prompt+="   - Set each teammate's working directory to the sub-agent's directory."$'\n'
    prompt+="3. Use the shared task list to decompose work, assign tasks, and track progress."$'\n'
    prompt+="4. Teammates communicate via messages — use SendMessage for direct, broadcast for all."$'\n'
    prompt+="5. Each teammate gets its own tmux pane automatically."$'\n'
    prompt+="6. When all tasks are done, clean up the team."$'\n'

    prompt+=$'\n'
    prompt+="### Sub-agent definitions:"$'\n'
    prompt+="$sub_agent_defs"$'\n'
  fi

  # Inject file-based coordination protocol for multi-mode (cross-vendor)
  if [[ "$LAUNCH_MODE" == "multi" ]]; then
    local coord_dir="${PROJECT_ROOT}/.ai-agents/coordination"
    if [[ -d "$coord_dir" ]]; then
      prompt+=$'\n\n'
      prompt+="## Cross-Agent Coordination (File-Based)"$'\n'
      prompt+=$'\n'
      prompt+="A shared coordination directory exists at \`.ai-agents/coordination/\`. Use it to coordinate with other agents running in parallel:"$'\n'
      prompt+=$'\n'
      prompt+="1. At session start: read \`messages.md\` for messages from other agents addressed to you."$'\n'
      prompt+="2. When starting a task: update \`task-board.md\` — move your task to IN PROGRESS."$'\n'
      prompt+="3. When completing a task: move it to DONE in \`task-board.md\`."$'\n'
      prompt+="4. If your work affects another agent's scope: append a message to \`messages.md\` with format:"$'\n'
      prompt+="   \`[YYYY-MM-DD HH:MM] [your-agent-name] @target-agent: message\`"$'\n'
      prompt+="5. Do NOT delete or overwrite other agents' messages or task entries."$'\n'
    fi
  fi

  echo "$prompt"
}

# --- Post-session context check ---
_post_session_check() {
  local project_root="$1"
  local agent_name="$2"
  local tool_name="$3"
  local ctx_dir="${project_root}/.ai-agents/context"
  local meta_file="${project_root}/.ai-agents/.session-meta.json"

  [[ -d "${project_root}/.ai-agents" ]] || return 0

  # Build current checksums
  local checksums="{"
  local first=true
  if [[ -d "$ctx_dir" ]]; then
    for f in "$ctx_dir"/*; do
      [[ -f "$f" ]] || continue
      local fname hash
      fname=$(basename "$f")
      if command -v md5sum &>/dev/null; then
        hash=$(md5sum "$f" | cut -d' ' -f1)
      else
        hash=$(md5 -q "$f" 2>/dev/null || echo "unknown")
      fi
      $first || checksums+=","
      checksums+="\"${fname}\":\"${hash}\""
      first=false
    done
  fi
  checksums+="}"

  # Write session metadata
  local timestamp
  timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  cat > "$meta_file" <<EOF
{
  "last_session": "${timestamp}",
  "agent": "${agent_name}",
  "tool": "${tool_name}",
  "context_checksums": ${checksums}
}
EOF

  # Check for code changes vs context changes
  if command -v git &>/dev/null && [[ -d "${project_root}/.git" ]]; then
    local code_changed ctx_changed
    code_changed=$(git -C "$project_root" diff --name-only HEAD 2>/dev/null | grep -v '.ai-agents/' | head -5 || true)
    ctx_changed=$(git -C "$project_root" diff --name-only HEAD 2>/dev/null | grep '.ai-agents/' || true)

    if [[ -n "$code_changed" && -z "$ctx_changed" ]]; then
      echo "" >&2
      echo -e "\033[1;33m[ai-agency]\033[0m Code changes detected but no context files updated." >&2
      echo -e "\033[2m  Run: ai-agency verify --staleness\033[0m" >&2
    fi
  fi
}

# --- Launch session ---
launch_session() {
  local idx=$1
  local prompt
  prompt=$(build_prompt "$idx")
  local name="${AGENT_NAMES[$idx]}"
  local dir="${AGENT_DIRS[$idx]}"
  local work_dir="$PROJECT_ROOT"
  [[ "$dir" != "." ]] && work_dir="${PROJECT_ROOT}/${dir}"

  local color
  color=$(get_agent_color "$idx")

  local bg_name
  bg_name=$(get_bg_color_name "$idx")

  # 1. Print colored banner (works in ALL terminals)
  print_agent_banner "$idx" "$name" "$bg_name"
  echo -e "${DIM}Directory: ${work_dir}${NC}"
  echo -e "${DIM}Tool: ${TOOL}${NC}"
  echo ""

  # 2. Set terminal tab/window title (works in most terminals)
  set_term_title "Agent: ${name}"

  # 3. Change terminal background (iTerm2, kitty, WezTerm — ignored elsewhere)
  set_term_bg "$idx"

  # --- Session metadata: record context checksums before session ---
  local session_meta_file="${PROJECT_ROOT}/.ai-agents/.session-meta.json"
  local session_start_checksums=""
  if [[ -d "${PROJECT_ROOT}/.ai-agents/context" ]]; then
    session_start_checksums=$(
      for f in "${PROJECT_ROOT}/.ai-agents/context/"*; do
        [[ -f "$f" ]] || continue
        local fname
        fname=$(basename "$f")
        local hash
        if command -v md5sum &>/dev/null; then
          hash=$(md5sum "$f" | cut -d' ' -f1)
        else
          hash=$(md5 -q "$f" 2>/dev/null || echo "unknown")
        fi
        printf '    "%s": "%s"' "$fname" "$hash"
      done
    )
  fi

  # Ensure background + title reset + session metadata when the session exits
  trap '_post_session_check "'"$PROJECT_ROOT"'" "'"$name"'" "'"$TOOL"'"; printf "\033[?25h"; tput cnorm 2>/dev/null || true; reset_term_bg; set_term_title "Terminal"' EXIT INT TERM

  # Launch AI tool (no exec — so trap EXIT fires and restores background)
  case "$TOOL" in
    claude)
      cd "$work_dir"
      if [[ "$LAUNCH_MODE" == "team" ]]; then
        # Team mode: native Claude Code agent teams inside tmux
        # Claude creates teammates via TeamCreate; --teammate-mode tmux auto-splits panes
        if ! command -v tmux &>/dev/null; then
          echo -e "${RED}tmux is not installed. Run: brew install tmux${NC}"
          exit 1
        fi
        tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

        # Write prompt to temp file (avoids send-keys truncation on long prompts)
        local tmp_dir="/tmp/ai-agency-team-$$"
        mkdir -p "$tmp_dir"
        printf '%s' "$prompt" > "$tmp_dir/prompt-pm.txt"
        cat > "$tmp_dir/launch-pm.sh" <<'LAUNCHER'
#!/bin/bash
cd "$1"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
prompt=$(<"$2")
SESSION="$3"
claude --dangerously-skip-permissions --teammate-mode tmux "$prompt"

# PM finished — wait for all other panes to finish before killing session
pm_pane=$(tmux display-message -p -t "$SESSION" '#{pane_id}' 2>/dev/null)
while true; do
  # List all panes still running a process (not exited shells)
  alive=0
  while IFS= read -r pane_id; do
    [[ "$pane_id" == "$pm_pane" ]] && continue
    alive=$((alive + 1))
  done < <(tmux list-panes -t "$SESSION" -F '#{pane_id}' 2>/dev/null)
  [[ "$alive" -eq 0 ]] && break
  sleep 2
done
tmux kill-session -t "$SESSION" 2>/dev/null
LAUNCHER
        chmod +x "$tmp_dir/launch-pm.sh"

        # Create tmux session with PM agent
        tmux new-session -d -s "$TMUX_SESSION" -n "team" "bash $tmp_dir/launch-pm.sh '$work_dir' '$tmp_dir/prompt-pm.txt' '$TMUX_SESSION'"
        tmux set-option -t "$TMUX_SESSION" pane-border-status top
        tmux set-option -t "$TMUX_SESSION" pane-border-format "#{?pane_active,#[fg=colour214 bold] ● #{pane_title} #[default],#[fg=colour240]   #{pane_title} }"
        tmux set-option -t "$TMUX_SESSION" pane-border-style "fg=colour238"
        tmux set-option -t "$TMUX_SESSION" pane-active-border-style "fg=colour214,bold"
        tmux set-option -t "$TMUX_SESSION" mouse on
        tmux set-option -t "$TMUX_SESSION" status on
        tmux set-option -t "$TMUX_SESSION" status-style "bg=colour236,fg=colour248"
        tmux set-option -t "$TMUX_SESSION" status-left " #[fg=colour214,bold]TEAM#[default] "
        tmux set-option -t "$TMUX_SESSION" status-left-length 8
        tmux set-option -t "$TMUX_SESSION" status-right " ^B ←→↑↓ move │ ^B Alt+←→↑↓ resize │ ^B Z zoom │ ^B D detach "
        tmux set-option -t "$TMUX_SESSION" status-right-length 80
        tmux select-pane -t "$TMUX_SESSION" -T "$name" -P "bg=${TMUX_PANE_BG[0]}"

        echo ""
        echo -e "${GREEN}${BOLD}Team session starting...${NC}"
        echo -e "${DIM}PM will auto-create teammates in split panes via native agent teams.${NC}"
        echo ""

        # Attach (blocks until detach/exit)
        if [[ -n "${TMUX:-}" ]]; then
          tmux switch-client -t "$TMUX_SESSION"
        else
          echo -e "${DIM}Pane navigation:${NC}"
          echo -e "${DIM}  Ctrl+B ↑↓←→   = move between panes${NC}"
          echo -e "${DIM}  Ctrl+B Z      = zoom/unzoom current pane${NC}"
          echo -e "${DIM}  Ctrl+B Q      = show pane numbers${NC}"
          echo -e "${DIM}  Ctrl+B D      = detach (agents keep running)${NC}"
          echo ""
          tmux attach -t "$TMUX_SESSION"
        fi
      else
        claude --dangerously-skip-permissions "$prompt"
      fi
      ;;
    codex)
      cd "$work_dir"
      codex "$prompt"
      ;;
    print)
      echo -e "${YELLOW}=== Copy this prompt ===${NC}"
      echo ""
      echo "$prompt"
      echo ""
      echo -e "${YELLOW}========================${NC}"
      ;;
    *)
      echo -e "${RED}Unknown tool: ${TOOL}${NC}"
      exit 1
      ;;
  esac
  # trap EXIT will reset background + title + session metadata automatically
}

# --- Multi-agent tmux session ---
launch_multi() {
  if ! command -v tmux &>/dev/null; then
    echo -e "${RED}tmux is not installed. Run: brew install tmux${NC}"
    exit 1
  fi

  display_agents

  echo -e "${BOLD}Select agents for multi-session (comma-separated numbers, or 'all'):${NC} "
  read -r multi_choice

  local indices=()
  if [[ "$multi_choice" == "all" ]]; then
    for idx in "${!AGENT_PATHS[@]}"; do
      indices+=("$idx")
    done
  else
    IFS=',' read -ra nums <<< "$multi_choice"
    for num in "${nums[@]}"; do
      num=$(echo "$num" | tr -d ' ')
      if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#AGENT_PATHS[@]} )); then
        indices+=($((num - 1)))
      fi
    done
  fi

  if [[ ${#indices[@]} -eq 0 ]]; then
    echo -e "${RED}No valid agents selected.${NC}"
    exit 1
  fi

  select_tool

  # Kill existing session if any
  tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

  local bg_size=${#TMUX_PANE_BG[@]}

  # Write prompts to temp files (avoids tmux send-keys truncation on long prompts)
  local tmp_dir="/tmp/ai-agency-multi-$$"
  mkdir -p "$tmp_dir"

  # Create tmux session with first agent
  local first_idx="${indices[0]}"
  local first_name="${AGENT_NAMES[$first_idx]}"
  local first_prompt
  first_prompt=$(build_prompt "$first_idx")
  local first_dir="$PROJECT_ROOT"
  [[ "${AGENT_DIRS[$first_idx]}" != "." ]] && first_dir="${PROJECT_ROOT}/${AGENT_DIRS[$first_idx]}"

  # First agent launcher
  printf '%s' "$first_prompt" > "$tmp_dir/prompt-${first_idx}.txt"
  local first_tool_cmd
  case "$TOOL" in
    claude) first_tool_cmd="claude --dangerously-skip-permissions" ;;
    codex)  first_tool_cmd="codex" ;;
    print)  first_tool_cmd="echo" ;;
  esac
  cat > "$tmp_dir/launch-${first_idx}.sh" <<LAUNCHER
#!/bin/bash
cd "$first_dir"
prompt=\$(<"$tmp_dir/prompt-${first_idx}.txt")
$first_tool_cmd "\$prompt"
exec "\$SHELL"
LAUNCHER

  tmux new-session -d -s "$TMUX_SESSION" -n "agents" "bash $tmp_dir/launch-${first_idx}.sh"

  # Enable pane border with agent name titles
  tmux set-option -t "$TMUX_SESSION" pane-border-status top
  tmux set-option -t "$TMUX_SESSION" pane-border-format "#{?pane_active,#[fg=colour214 bold] ● #{pane_title} #[default],#[fg=colour240]   #{pane_title} }"
  tmux set-option -t "$TMUX_SESSION" pane-border-style "fg=colour238"
  tmux set-option -t "$TMUX_SESSION" pane-active-border-style "fg=colour214,bold"
  tmux set-option -t "$TMUX_SESSION" mouse on
  tmux set-option -t "$TMUX_SESSION" status on
  tmux set-option -t "$TMUX_SESSION" status-style "bg=colour236,fg=colour248"
  tmux set-option -t "$TMUX_SESSION" status-left " #[fg=colour39,bold]MULTI#[default] "
  tmux set-option -t "$TMUX_SESSION" status-left-length 9
  tmux set-option -t "$TMUX_SESSION" status-right " ^B ←→↑↓ move │ ^B Alt+←→↑↓ resize │ ^B Z zoom │ ^B D detach "
  tmux set-option -t "$TMUX_SESSION" status-right-length 80

  # First pane — set title, color
  tmux select-pane -t "${TMUX_SESSION}" -T "$first_name" -P "bg=${TMUX_PANE_BG[0]}"

  # Split panes for remaining agents
  for i in "${!indices[@]}"; do
    [[ "$i" -eq 0 ]] && continue
    local idx="${indices[$i]}"
    local name="${AGENT_NAMES[$idx]}"
    local prompt
    prompt=$(build_prompt "$idx")
    local work_dir="$PROJECT_ROOT"
    [[ "${AGENT_DIRS[$idx]}" != "." ]] && work_dir="${PROJECT_ROOT}/${AGENT_DIRS[$idx]}"

    local bg_idx=$((i % bg_size))

    # Sub-agent launcher
    printf '%s' "$prompt" > "$tmp_dir/prompt-${idx}.txt"
    local tool_cmd
    case "$TOOL" in
      claude) tool_cmd="claude --dangerously-skip-permissions" ;;
      codex)  tool_cmd="codex" ;;
      print)  tool_cmd="echo" ;;
    esac
    cat > "$tmp_dir/launch-${idx}.sh" <<LAUNCHER
#!/bin/bash
cd "$work_dir"
prompt=\$(<"$tmp_dir/prompt-${idx}.txt")
$tool_cmd "\$prompt"
exec "\$SHELL"
LAUNCHER

    tmux split-window -t "$TMUX_SESSION" "bash $tmp_dir/launch-${idx}.sh"
    tmux select-pane -t "${TMUX_SESSION}" -T "$name" -P "bg=${TMUX_PANE_BG[$bg_idx]}"

    # Rebalance layout after each split
    tmux select-layout -t "$TMUX_SESSION" tiled
  done

  # Select first pane
  tmux select-pane -t "${TMUX_SESSION}.0"

  echo ""
  echo -e "${GREEN}${BOLD}Multi-agent session created!${NC}"
  echo -e "${DIM}Agents: ${#indices[@]} (split-pane layout)${NC}"
  echo ""

  # Auto-attach (or switch if already inside tmux)
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$TMUX_SESSION"
  else
    echo -e "${DIM}Tips:${NC}"
    echo -e "${DIM}  Ctrl+B Q      = show pane numbers${NC}"
    echo -e "${DIM}  Ctrl+B ↑↓←→   = move between panes${NC}"
    echo -e "${DIM}  Ctrl+B Z      = zoom/unzoom pane${NC}"
    echo -e "${DIM}  Ctrl+B D      = detach${NC}"
    echo ""
    tmux attach -t "$TMUX_SESSION"
  fi
}

# --- Main ---
load_lang
set_mode_strings

if $MULTI_MODE; then
  LAUNCH_MODE="multi"
  launch_multi
else
  select_agent
  select_tool

  # Check if selected agent has sub-agents
  has_sub="false"
  for sub_idx in "${!AGENT_DIRS[@]}"; do
    [[ "$sub_idx" -eq "$SELECTED_IDX" ]] && continue
    is_hidden "$sub_idx" && continue
    local_selected_dir="${AGENT_DIRS[$SELECTED_IDX]}"
    local_sub_dir="${AGENT_DIRS[$sub_idx]}"
    if [[ "$local_selected_dir" == "." ]] || [[ "$local_sub_dir" == "${local_selected_dir}/"* ]]; then
      has_sub="true"
      break
    fi
  done

  # Show mode selection if sub-agents exist
  if [[ "$has_sub" == "true" ]]; then
    cui_select_mode "$has_sub"
  fi

  # Team mode: let user pick which sub-agents to include
  if [[ "$LAUNCH_MODE" == "team" ]]; then
    _sub_items=()
    _sub_indices=()
    for sub_idx in "${!AGENT_DIRS[@]}"; do
      [[ "$sub_idx" -eq "$SELECTED_IDX" ]] && continue
      is_hidden "$sub_idx" && continue
      _sel_dir="${AGENT_DIRS[$SELECTED_IDX]}"
      _s_dir="${AGENT_DIRS[$sub_idx]}"
      if [[ "$_sel_dir" == "." ]] || [[ "$_s_dir" == "${_sel_dir}/"* ]]; then
        _sub_items+=("${AGENT_NAMES[$sub_idx]}  ${DIM}(${_s_dir})${NC}")
        _sub_indices+=("$sub_idx")
      fi
    done
    if [[ ${#_sub_items[@]} -gt 0 ]]; then
      echo ""
      echo -e "  ${BOLD}${L_SELECT_SUB_AGENTS}${NC}"
      echo -e "  ${DIM}${L_SELECT_SUB_NAV}${NC}"
      echo ""
      if cui_multi_menu "${_sub_items[@]}"; then
        TEAM_AGENT_INDICES=""
        for sel_i in $CUI_MULTI_RESULT; do
          [[ -n "$TEAM_AGENT_INDICES" ]] && TEAM_AGENT_INDICES+=" "
          TEAM_AGENT_INDICES+="${_sub_indices[$sel_i]}"
        done
      fi
      if [[ -z "$TEAM_AGENT_INDICES" ]]; then
        echo -e "  ${YELLOW}No sub-agents selected. Falling back to single mode.${NC}"
        LAUNCH_MODE="single"
      fi
    fi
  fi

  case "$LAUNCH_MODE" in
    team|single)
      launch_session "$SELECTED_IDX"
      ;;
  esac
fi
