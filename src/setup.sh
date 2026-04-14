#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# setup.sh — One-command interactive setup for ai-agency
#
# Replaces the manual flow:
#   clone → open AI tool → read HOW_TO_AGENTS.md → run → launch ai-agency.sh
#
# With:
#   ./setup.sh → select language → select tool → auto-setup → done
#
# Usage:
#   ./setup.sh              # Interactive setup
#   ./setup.sh --help       # Show help
# =============================================================================

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

# --- Inline CUI Helpers ---
# Single-select: ↑↓ navigate, Enter select, number keys for quick pick.
# Sets CUI_RESULT (0-based index). Returns 1 on quit.
CUI_RESULT=0
cui_menu() {
  local -a items=("$@")
  local count=${#items[@]}
  local cursor=0
  local first_draw=true

  [[ $count -eq 0 ]] && { CUI_RESULT=255; return 1; }

  printf '\033[?25l'  # hide cursor
  trap 'printf "\033[?25h"' RETURN

  while true; do
    if ! $first_draw; then
      printf "\033[${count}A"
    fi
    first_draw=false

    for i in "${!items[@]}"; do
      printf '\033[2K\r'
      if (( i == cursor )); then
        echo -e "  ${GREEN}▸${NC} ${BOLD}$((i + 1)))${NC} ${BOLD}${items[$i]}${NC}"
      else
        echo -e "    ${DIM}$((i + 1)))${NC} ${items[$i]}"
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
      '')
        CUI_RESULT=$cursor
        return 0
        ;;
      q|Q)
        CUI_RESULT=255
        return 1
        ;;
      [0-9])
        local num_choice="$key"
        local more
        IFS= read -rsn1 -t 0.5 more </dev/tty || true
        if [[ "${more:-}" =~ ^[0-9]$ ]]; then
          num_choice="${num_choice}${more}"
        fi
        if (( num_choice >= 1 && num_choice <= count )); then
          CUI_RESULT=$((num_choice - 1))
          return 0
        fi
        ;;
    esac
  done
}

# Multi-select: ↑↓ navigate, Space toggle, a toggle-all, Enter confirm.
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

# --- Project Root ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$SCRIPT_DIR}"

# --- Help ---
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo ""
  echo -e "${BOLD}setup.sh${NC} — One-command interactive setup for ai-agency"
  echo ""
  echo -e "${BOLD}Usage:${NC}"
  echo "  ./setup.sh          Interactive setup"
  echo "  ./setup.sh --help   Show this help"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  1. Select language for interface and generated context"
  echo "  2. Check prerequisites and detect AI tools"
  echo "  3. Select AI agent tool (Claude Code, Codex, Gemini CLI)"
  echo "  4. Auto-run HOW_TO_AGENTS.md to generate AGENTS.md + context"
  echo ""
  exit 0
fi

# =============================================================================
# i18n — set_ui_lang() sets all L_* variables for the selected language
# =============================================================================
set_ui_lang() {
  case "$1" in
    en)
      # --- Banner ---
      L_BANNER_SUB1="This script sets up AI agent context for your project."
      L_BANNER_SUB2="It will generate AGENTS.md, knowledge, skills, and roles."
      # --- Step headers ---
      L_STEP_PREREQ="[1/3] Checking prerequisites..."
      L_STEP_TOOL="[2/3] Select AI agent tool"
      L_STEP_EXEC="[3/3] Running setup..."
      # --- Prerequisites ---
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md not found in"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md found"
      L_RUN_FROM_DIR="Make sure you're running this from the ai-agency directory,"
      L_OR_COPIED="or from a project that has HOW_TO_AGENTS.md copied into it."
      L_CLI_DETECTED="CLI detected"
      L_NO_TOOL="No AI CLI tool found."
      L_INSTALL_ONE="Install one of the following:"
      # --- Existing setup ---
      L_EXISTING_SETUP="Existing setup detected:"
      L_AGENTS_FILES_FOUND="AGENTS.md file(s) found"
      L_AI_DIR_EXISTS=".ai-agents/ directory exists"
      L_HOW_PROCEED="How would you like to proceed?"
      L_OPT_FULL="Full regeneration"
      L_OPT_FULL_DESC="(overwrites everything)"
      L_OPT_INCREMENTAL="Incremental update"
      L_OPT_INCR_DESC="(new directories only, preserves existing)"
      L_OPT_SELECTIVE="Selective regeneration"
      L_OPT_SELECTIVE_DESC="(pick directories to generate or regenerate)"
      L_SELECT_DIRS="Select directories (comma-separated, or 'all'):"
      L_SELECT_DEPTH="Search depth"
      L_TAG_EXISTING="[existing]"
      L_TAG_NEW="[new]"
      L_OPT_CANCEL="Cancel"
      L_SELECT_MODE="Select mode"
      # --- Common ---
      L_SELECTED="Selected:"
      L_CANCELLED="Setup cancelled."
      L_INVALID="Invalid selection. Exiting."
      L_MODE="Mode:"
      # --- Tool selection ---
      L_SELECT_TOOL="Select tool"
      # --- Execution ---
      L_TOOL_LABEL="Tool:"
      L_LANG_LABEL="Language:"
      L_GUIDE_LABEL="Guide:"
      L_MODE_LABEL="Mode:"
      L_PROMPT_LABEL="Prompt:"
      L_PROCEED="Proceed? (Y/n):"
      L_STARTING="Starting AI agent..."
      # --- Progress ---
      L_INITIALIZING="Initializing..."
      L_COMPLETED_IN="Completed in"
      L_WORKING="Working..."
      # --- Error ---
      L_SETUP_ERROR="Setup encountered an error"
      L_TRY_AGAIN="You can try running it again, or run manually:"
      # --- Completion ---
      L_SETUP_COMPLETE="Setup Complete!"
      L_AGENTS_GENERATED="AGENTS.md file(s) generated"
      L_CTX_CREATED=".ai-agents/ context directory created"
      L_NEXT_STEPS="Next steps -- launch an agent session:"
      L_INTERACTIVE_MODE="Interactive mode (select agent + tool)"
      L_DIRECT_LAUNCH="Direct launch with Claude"
      L_MULTI_AGENT="Multi-agent parallel sessions (tmux)"
      L_LIST_AGENTS="List all available agents"
      L_SEE_README="See README.md for full documentation."
      ;;
    ko)
      L_BANNER_SUB1="이 스크립트는 프로젝트에 AI 에이전트 컨텍스트를 설정합니다."
      L_BANNER_SUB2="AGENTS.md, 지식, 스킬, 역할을 자동 생성합니다."
      L_STEP_PREREQ="[1/3] 사전 요건 확인 중..."
      L_STEP_TOOL="[2/3] AI 에이전트 도구 선택"
      L_STEP_EXEC="[3/3] 셋업 실행 중..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md를 찾을 수 없음:"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md 확인됨"
      L_RUN_FROM_DIR="ai-agency 디렉토리에서 실행 중인지 확인하세요."
      L_OR_COPIED="또는 HOW_TO_AGENTS.md가 복사된 프로젝트인지 확인하세요."
      L_CLI_DETECTED="CLI 감지됨"
      L_NO_TOOL="AI CLI 도구를 찾을 수 없습니다."
      L_INSTALL_ONE="다음 중 하나를 설치하세요:"
      L_EXISTING_SETUP="기존 설정이 감지되었습니다:"
      L_AGENTS_FILES_FOUND="개의 AGENTS.md 파일 발견"
      L_AI_DIR_EXISTS=".ai-agents/ 디렉토리 존재"
      L_HOW_PROCEED="어떻게 진행하시겠습니까?"
      L_OPT_FULL="전체 재생성"
      L_OPT_FULL_DESC="(모두 덮어쓰기)"
      L_OPT_INCREMENTAL="증분 업데이트"
      L_OPT_INCR_DESC="(새 디렉토리만, 기존 유지)"
      L_OPT_SELECTIVE="선택적 재생성"
      L_OPT_SELECTIVE_DESC="(디렉토리를 골라서 생성/재생성)"
      L_SELECT_DIRS="디렉토리 선택 (쉼표 구분, 또는 'all'):"
      L_SELECT_DEPTH="검색 깊이"
      L_TAG_EXISTING="[기존]"
      L_TAG_NEW="[신규]"
      L_OPT_CANCEL="취소"
      L_SELECT_MODE="모드 선택"
      L_SELECTED="선택됨:"
      L_CANCELLED="셋업이 취소되었습니다."
      L_INVALID="잘못된 선택입니다. 종료합니다."
      L_MODE="모드:"
      L_SELECT_TOOL="도구 선택"
      L_TOOL_LABEL="도구:"
      L_LANG_LABEL="언어:"
      L_GUIDE_LABEL="가이드:"
      L_MODE_LABEL="모드:"
      L_PROMPT_LABEL="프롬프트:"
      L_PROCEED="진행하시겠습니까? (Y/n):"
      L_STARTING="AI 에이전트 시작 중..."
      L_INITIALIZING="초기화 중..."
      L_COMPLETED_IN="완료 소요 시간:"
      L_WORKING="작업 중..."
      L_SETUP_ERROR="셋업 중 오류가 발생했습니다"
      L_TRY_AGAIN="다시 실행하거나 수동으로 실행하세요:"
      L_SETUP_COMPLETE="셋업 완료!"
      L_AGENTS_GENERATED="개의 AGENTS.md 파일 생성됨"
      L_CTX_CREATED=".ai-agents/ 컨텍스트 디렉토리 생성됨"
      L_NEXT_STEPS="다음 단계 -- 에이전트 세션 실행:"
      L_INTERACTIVE_MODE="대화형 모드 (에이전트 + 도구 선택)"
      L_DIRECT_LAUNCH="Claude로 직접 실행"
      L_MULTI_AGENT="멀티 에이전트 병렬 세션 (tmux)"
      L_LIST_AGENTS="사용 가능한 에이전트 목록"
      L_SEE_README="자세한 내용은 README.md를 참조하세요."
      ;;
    ja)
      L_BANNER_SUB1="このスクリプトはプロジェクトにAIエージェントコンテキストを設定します。"
      L_BANNER_SUB2="AGENTS.md、ナレッジ、スキル、ロールを自動生成します。"
      L_STEP_PREREQ="[1/3] 前提条件を確認中..."
      L_STEP_TOOL="[2/3] AIエージェントツールの選択"
      L_STEP_EXEC="[3/3] セットアップ実行中..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md が見つかりません:"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md 確認済み"
      L_RUN_FROM_DIR="ai-agencyディレクトリから実行しているか確認してください。"
      L_OR_COPIED="またはHOW_TO_AGENTS.mdがコピーされたプロジェクトか確認してください。"
      L_CLI_DETECTED="CLI 検出済み"
      L_NO_TOOL="AI CLIツールが見つかりません。"
      L_INSTALL_ONE="以下のいずれかをインストールしてください:"
      L_EXISTING_SETUP="既存のセットアップが検出されました:"
      L_AGENTS_FILES_FOUND="個のAGENTS.mdファイルが見つかりました"
      L_AI_DIR_EXISTS=".ai-agents/ ディレクトリが存在します"
      L_HOW_PROCEED="どのように進めますか？"
      L_OPT_FULL="完全再生成"
      L_OPT_FULL_DESC="(すべて上書き)"
      L_OPT_INCREMENTAL="増分アップデート"
      L_OPT_INCR_DESC="(新規ディレクトリのみ、既存を保持)"
      L_OPT_SELECTIVE="選択的再生成"
      L_OPT_SELECTIVE_DESC="(ディレクトリを選んで生成/再生成)"
      L_SELECT_DIRS="ディレクトリを選択 (カンマ区切り、または 'all'):"
      L_TAG_EXISTING="[既存]"
      L_TAG_NEW="[新規]"
      L_OPT_CANCEL="キャンセル"
      L_SELECT_MODE="モードを選択"
      L_SELECTED="選択済み:"
      L_CANCELLED="セットアップがキャンセルされました。"
      L_INVALID="無効な選択です。終了します。"
      L_MODE="モード:"
      L_SELECT_TOOL="ツールを選択"
      L_TOOL_LABEL="ツール:"
      L_LANG_LABEL="言語:"
      L_GUIDE_LABEL="ガイド:"
      L_MODE_LABEL="モード:"
      L_PROMPT_LABEL="プロンプト:"
      L_PROCEED="続行しますか？ (Y/n):"
      L_STARTING="AIエージェントを起動中..."
      L_INITIALIZING="初期化中..."
      L_COMPLETED_IN="完了時間:"
      L_WORKING="作業中..."
      L_SETUP_ERROR="セットアップ中にエラーが発生しました"
      L_TRY_AGAIN="再実行するか、手動で実行してください:"
      L_SETUP_COMPLETE="セットアップ完了！"
      L_AGENTS_GENERATED="個のAGENTS.mdファイルが生成されました"
      L_CTX_CREATED=".ai-agents/ コンテキストディレクトリが作成されました"
      L_NEXT_STEPS="次のステップ -- エージェントセッションを起動:"
      L_INTERACTIVE_MODE="対話モード (エージェント+ツール選択)"
      L_DIRECT_LAUNCH="Claudeで直接起動"
      L_MULTI_AGENT="マルチエージェント並列セッション (tmux)"
      L_LIST_AGENTS="利用可能なエージェント一覧"
      L_SEE_README="詳細はREADME.mdを参照してください。"
      ;;
    zh)
      L_BANNER_SUB1="此脚本为您的项目设置 AI 代理上下文。"
      L_BANNER_SUB2="将自动生成 AGENTS.md、知识、技能和角色。"
      L_STEP_PREREQ="[1/3] 检查前提条件..."
      L_STEP_TOOL="[2/3] 选择 AI 代理工具"
      L_STEP_EXEC="[3/3] 正在运行设置..."
      L_HOW_TO_NOT_FOUND="未找到 HOW_TO_AGENTS.md："
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md 已确认"
      L_RUN_FROM_DIR="请确保您在 ai-agency 目录中运行，"
      L_OR_COPIED="或者项目中已复制了 HOW_TO_AGENTS.md。"
      L_CLI_DETECTED="CLI 已检测到"
      L_NO_TOOL="未找到 AI CLI 工具。"
      L_INSTALL_ONE="请安装以下工具之一："
      L_EXISTING_SETUP="检测到已有设置："
      L_AGENTS_FILES_FOUND="个 AGENTS.md 文件已找到"
      L_AI_DIR_EXISTS=".ai-agents/ 目录已存在"
      L_HOW_PROCEED="您希望如何继续？"
      L_OPT_FULL="完全重新生成"
      L_OPT_FULL_DESC="(覆盖所有内容)"
      L_OPT_INCREMENTAL="增量更新"
      L_OPT_INCR_DESC="(仅新目录，保留现有内容)"
      L_OPT_SELECTIVE="选择性重新生成"
      L_OPT_SELECTIVE_DESC="(选择目录生成/重新生成)"
      L_SELECT_DIRS="选择目录（逗号分隔，或 'all'）:"
      L_TAG_EXISTING="[现有]"
      L_TAG_NEW="[新增]"
      L_OPT_CANCEL="取消"
      L_SELECT_MODE="选择模式"
      L_SELECTED="已选择："
      L_CANCELLED="设置已取消。"
      L_INVALID="无效的选择。退出。"
      L_MODE="模式："
      L_SELECT_TOOL="选择工具"
      L_TOOL_LABEL="工具："
      L_LANG_LABEL="语言："
      L_GUIDE_LABEL="指南："
      L_MODE_LABEL="模式："
      L_PROMPT_LABEL="提示："
      L_PROCEED="继续？ (Y/n)："
      L_STARTING="正在启动 AI 代理..."
      L_INITIALIZING="初始化中..."
      L_COMPLETED_IN="完成耗时："
      L_WORKING="工作中..."
      L_SETUP_ERROR="设置过程中出现错误"
      L_TRY_AGAIN="您可以重试，或手动运行："
      L_SETUP_COMPLETE="设置完成！"
      L_AGENTS_GENERATED="个 AGENTS.md 文件已生成"
      L_CTX_CREATED=".ai-agents/ 上下文目录已创建"
      L_NEXT_STEPS="下一步 -- 启动代理会话："
      L_INTERACTIVE_MODE="交互模式（选择代理 + 工具）"
      L_DIRECT_LAUNCH="使用 Claude 直接启动"
      L_MULTI_AGENT="多代理并行会话 (tmux)"
      L_LIST_AGENTS="列出所有可用代理"
      L_SEE_README="详情请参阅 README.md。"
      ;;
    es)
      L_BANNER_SUB1="Este script configura el contexto de agentes IA para tu proyecto."
      L_BANNER_SUB2="Generara AGENTS.md, conocimiento, habilidades y roles."
      L_STEP_PREREQ="[1/3] Verificando requisitos previos..."
      L_STEP_TOOL="[2/3] Seleccionar herramienta de agente IA"
      L_STEP_EXEC="[3/3] Ejecutando configuracion..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md no encontrado en"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md encontrado"
      L_RUN_FROM_DIR="Asegurate de ejecutar desde el directorio ai-agency,"
      L_OR_COPIED="o desde un proyecto que tenga HOW_TO_AGENTS.md copiado."
      L_CLI_DETECTED="CLI detectado"
      L_NO_TOOL="No se encontro ninguna herramienta AI CLI."
      L_INSTALL_ONE="Instala una de las siguientes:"
      L_EXISTING_SETUP="Configuracion existente detectada:"
      L_AGENTS_FILES_FOUND="archivo(s) AGENTS.md encontrado(s)"
      L_AI_DIR_EXISTS="directorio .ai-agents/ existe"
      L_HOW_PROCEED="Como deseas proceder?"
      L_OPT_FULL="Regeneracion completa"
      L_OPT_FULL_DESC="(sobrescribe todo)"
      L_OPT_INCREMENTAL="Actualizacion incremental"
      L_OPT_INCR_DESC="(solo nuevos directorios, preserva existentes)"
      L_OPT_SELECTIVE="Regeneracion selectiva"
      L_OPT_SELECTIVE_DESC="(elegir directorios a generar o regenerar)"
      L_SELECT_DIRS="Seleccionar directorios (separados por coma, o 'all'):"
      L_TAG_EXISTING="[existente]"
      L_TAG_NEW="[nuevo]"
      L_OPT_CANCEL="Cancelar"
      L_SELECT_MODE="Seleccionar modo"
      L_SELECTED="Seleccionado:"
      L_CANCELLED="Configuracion cancelada."
      L_INVALID="Seleccion invalida. Saliendo."
      L_MODE="Modo:"
      L_SELECT_TOOL="Seleccionar herramienta"
      L_TOOL_LABEL="Herramienta:"
      L_LANG_LABEL="Idioma:"
      L_GUIDE_LABEL="Guia:"
      L_MODE_LABEL="Modo:"
      L_PROMPT_LABEL="Prompt:"
      L_PROCEED="Continuar? (Y/n):"
      L_STARTING="Iniciando agente IA..."
      L_INITIALIZING="Inicializando..."
      L_COMPLETED_IN="Completado en"
      L_WORKING="Trabajando..."
      L_SETUP_ERROR="La configuracion encontro un error"
      L_TRY_AGAIN="Puedes intentar de nuevo o ejecutar manualmente:"
      L_SETUP_COMPLETE="Configuracion completa!"
      L_AGENTS_GENERATED="archivo(s) AGENTS.md generado(s)"
      L_CTX_CREATED="directorio .ai-agents/ creado"
      L_NEXT_STEPS="Siguientes pasos -- iniciar sesion de agente:"
      L_INTERACTIVE_MODE="Modo interactivo (seleccionar agente + herramienta)"
      L_DIRECT_LAUNCH="Lanzamiento directo con Claude"
      L_MULTI_AGENT="Sesiones multi-agente en paralelo (tmux)"
      L_LIST_AGENTS="Listar todos los agentes disponibles"
      L_SEE_README="Consulta README.md para documentacion completa."
      ;;
    fr)
      L_BANNER_SUB1="Ce script configure le contexte d'agents IA pour votre projet."
      L_BANNER_SUB2="Il generera AGENTS.md, connaissances, competences et roles."
      L_STEP_PREREQ="[1/3] Verification des prerequis..."
      L_STEP_TOOL="[2/3] Selectionner l'outil d'agent IA"
      L_STEP_EXEC="[3/3] Execution de la configuration..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md introuvable dans"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md trouve"
      L_RUN_FROM_DIR="Verifiez que vous executez depuis le repertoire ai-agency,"
      L_OR_COPIED="ou depuis un projet contenant HOW_TO_AGENTS.md."
      L_CLI_DETECTED="CLI detecte"
      L_NO_TOOL="Aucun outil AI CLI trouve."
      L_INSTALL_ONE="Installez l'un des suivants :"
      L_EXISTING_SETUP="Configuration existante detectee :"
      L_AGENTS_FILES_FOUND="fichier(s) AGENTS.md trouve(s)"
      L_AI_DIR_EXISTS="repertoire .ai-agents/ existe"
      L_HOW_PROCEED="Comment souhaitez-vous proceder ?"
      L_OPT_FULL="Regeneration complete"
      L_OPT_FULL_DESC="(ecrase tout)"
      L_OPT_INCREMENTAL="Mise a jour incrementale"
      L_OPT_INCR_DESC="(nouveaux repertoires uniquement, preserve l'existant)"
      L_OPT_SELECTIVE="Regeneration selective"
      L_OPT_SELECTIVE_DESC="(choisir les repertoires a generer ou regenerer)"
      L_SELECT_DIRS="Selectionner les repertoires (separes par virgule, ou 'all'):"
      L_TAG_EXISTING="[existant]"
      L_TAG_NEW="[nouveau]"
      L_OPT_CANCEL="Annuler"
      L_SELECT_MODE="Selectionner le mode"
      L_SELECTED="Selectionne :"
      L_CANCELLED="Configuration annulee."
      L_INVALID="Selection invalide. Fermeture."
      L_MODE="Mode :"
      L_SELECT_TOOL="Selectionner l'outil"
      L_TOOL_LABEL="Outil :"
      L_LANG_LABEL="Langue :"
      L_GUIDE_LABEL="Guide :"
      L_MODE_LABEL="Mode :"
      L_PROMPT_LABEL="Prompt :"
      L_PROCEED="Continuer ? (Y/n) :"
      L_STARTING="Demarrage de l'agent IA..."
      L_INITIALIZING="Initialisation..."
      L_COMPLETED_IN="Termine en"
      L_WORKING="En cours..."
      L_SETUP_ERROR="La configuration a rencontre une erreur"
      L_TRY_AGAIN="Vous pouvez reessayer ou executer manuellement :"
      L_SETUP_COMPLETE="Configuration terminee !"
      L_AGENTS_GENERATED="fichier(s) AGENTS.md genere(s)"
      L_CTX_CREATED="repertoire .ai-agents/ cree"
      L_NEXT_STEPS="Prochaines etapes -- lancer une session d'agent :"
      L_INTERACTIVE_MODE="Mode interactif (selectionner agent + outil)"
      L_DIRECT_LAUNCH="Lancement direct avec Claude"
      L_MULTI_AGENT="Sessions multi-agents en parallele (tmux)"
      L_LIST_AGENTS="Lister tous les agents disponibles"
      L_SEE_README="Consultez README.md pour la documentation complete."
      ;;
    de)
      L_BANNER_SUB1="Dieses Skript richtet den AI-Agenten-Kontext fuer Ihr Projekt ein."
      L_BANNER_SUB2="Es generiert AGENTS.md, Wissen, Faehigkeiten und Rollen."
      L_STEP_PREREQ="[1/3] Voraussetzungen pruefen..."
      L_STEP_TOOL="[2/3] AI-Agenten-Tool auswaehlen"
      L_STEP_EXEC="[3/3] Setup ausfuehren..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md nicht gefunden in"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md gefunden"
      L_RUN_FROM_DIR="Stellen Sie sicher, dass Sie im ai-agency-Verzeichnis ausfuehren,"
      L_OR_COPIED="oder in einem Projekt, das HOW_TO_AGENTS.md kopiert hat."
      L_CLI_DETECTED="CLI erkannt"
      L_NO_TOOL="Kein AI-CLI-Tool gefunden."
      L_INSTALL_ONE="Installieren Sie eines der folgenden:"
      L_EXISTING_SETUP="Bestehende Konfiguration erkannt:"
      L_AGENTS_FILES_FOUND="AGENTS.md-Datei(en) gefunden"
      L_AI_DIR_EXISTS=".ai-agents/ Verzeichnis existiert"
      L_HOW_PROCEED="Wie moechten Sie fortfahren?"
      L_OPT_FULL="Vollstaendige Neugenerierung"
      L_OPT_FULL_DESC="(ueberschreibt alles)"
      L_OPT_INCREMENTAL="Inkrementelles Update"
      L_OPT_INCR_DESC="(nur neue Verzeichnisse, bestehende beibehalten)"
      L_OPT_SELECTIVE="Selektive Regenerierung"
      L_OPT_SELECTIVE_DESC="(Verzeichnisse zur Generierung/Regenerierung auswahlen)"
      L_SELECT_DIRS="Verzeichnisse auswahlen (kommagetrennt, oder 'all'):"
      L_TAG_EXISTING="[vorhanden]"
      L_TAG_NEW="[neu]"
      L_OPT_CANCEL="Abbrechen"
      L_SELECT_MODE="Modus waehlen"
      L_SELECTED="Ausgewaehlt:"
      L_CANCELLED="Setup abgebrochen."
      L_INVALID="Ungueltige Auswahl. Beenden."
      L_MODE="Modus:"
      L_SELECT_TOOL="Tool waehlen"
      L_TOOL_LABEL="Tool:"
      L_LANG_LABEL="Sprache:"
      L_GUIDE_LABEL="Anleitung:"
      L_MODE_LABEL="Modus:"
      L_PROMPT_LABEL="Prompt:"
      L_PROCEED="Fortfahren? (Y/n):"
      L_STARTING="AI-Agent wird gestartet..."
      L_INITIALIZING="Initialisierung..."
      L_COMPLETED_IN="Abgeschlossen in"
      L_WORKING="Arbeitet..."
      L_SETUP_ERROR="Beim Setup ist ein Fehler aufgetreten"
      L_TRY_AGAIN="Sie koennen es erneut versuchen oder manuell ausfuehren:"
      L_SETUP_COMPLETE="Setup abgeschlossen!"
      L_AGENTS_GENERATED="AGENTS.md-Datei(en) generiert"
      L_CTX_CREATED=".ai-agents/ Kontextverzeichnis erstellt"
      L_NEXT_STEPS="Naechste Schritte -- Agentensitzung starten:"
      L_INTERACTIVE_MODE="Interaktiver Modus (Agent + Tool waehlen)"
      L_DIRECT_LAUNCH="Direktstart mit Claude"
      L_MULTI_AGENT="Multi-Agent parallele Sitzungen (tmux)"
      L_LIST_AGENTS="Alle verfuegbaren Agenten auflisten"
      L_SEE_README="Siehe README.md fuer vollstaendige Dokumentation."
      ;;
    ru)
      L_BANNER_SUB1="Этот скрипт настраивает контекст AI-агентов для вашего проекта."
      L_BANNER_SUB2="Он сгенерирует AGENTS.md, знания, навыки и роли."
      L_STEP_PREREQ="[1/3] Проверка предварительных условий..."
      L_STEP_TOOL="[2/3] Выбор инструмента AI-агента"
      L_STEP_EXEC="[3/3] Запуск настройки..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md не найден в"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md найден"
      L_RUN_FROM_DIR="Убедитесь, что вы запускаете из директории ai-agency,"
      L_OR_COPIED="или из проекта, в который скопирован HOW_TO_AGENTS.md."
      L_CLI_DETECTED="CLI обнаружен"
      L_NO_TOOL="AI CLI инструмент не найден."
      L_INSTALL_ONE="Установите один из следующих:"
      L_EXISTING_SETUP="Обнаружена существующая настройка:"
      L_AGENTS_FILES_FOUND="файл(ов) AGENTS.md найдено"
      L_AI_DIR_EXISTS="директория .ai-agents/ существует"
      L_HOW_PROCEED="Как вы хотите продолжить?"
      L_OPT_FULL="Полная регенерация"
      L_OPT_FULL_DESC="(перезаписать всё)"
      L_OPT_INCREMENTAL="Инкрементальное обновление"
      L_OPT_INCR_DESC="(только новые директории, существующие сохранить)"
      L_OPT_SELECTIVE="Выборочная регенерация"
      L_OPT_SELECTIVE_DESC="(выбрать директории для генерации/регенерации)"
      L_SELECT_DIRS="Выберите директории (через запятую, или 'all'):"
      L_TAG_EXISTING="[существующий]"
      L_TAG_NEW="[новый]"
      L_OPT_CANCEL="Отмена"
      L_SELECT_MODE="Выберите режим"
      L_SELECTED="Выбрано:"
      L_CANCELLED="Настройка отменена."
      L_INVALID="Неверный выбор. Выход."
      L_MODE="Режим:"
      L_SELECT_TOOL="Выберите инструмент"
      L_TOOL_LABEL="Инструмент:"
      L_LANG_LABEL="Язык:"
      L_GUIDE_LABEL="Руководство:"
      L_MODE_LABEL="Режим:"
      L_PROMPT_LABEL="Промпт:"
      L_PROCEED="Продолжить? (Y/n):"
      L_STARTING="Запуск AI-агента..."
      L_INITIALIZING="Инициализация..."
      L_COMPLETED_IN="Завершено за"
      L_WORKING="Работает..."
      L_SETUP_ERROR="При настройке произошла ошибка"
      L_TRY_AGAIN="Попробуйте снова или запустите вручную:"
      L_SETUP_COMPLETE="Настройка завершена!"
      L_AGENTS_GENERATED="файл(ов) AGENTS.md сгенерировано"
      L_CTX_CREATED="директория .ai-agents/ создана"
      L_NEXT_STEPS="Следующие шаги -- запуск сессии агента:"
      L_INTERACTIVE_MODE="Интерактивный режим (выбор агента + инструмента)"
      L_DIRECT_LAUNCH="Прямой запуск с Claude"
      L_MULTI_AGENT="Мультиагентные параллельные сессии (tmux)"
      L_LIST_AGENTS="Список всех доступных агентов"
      L_SEE_README="Подробности см. в README.md."
      ;;
    hi)
      L_BANNER_SUB1="यह स्क्रिप्ट आपके प्रोजेक्ट के लिए AI एजेंट कॉन्टेक्स्ट सेट करती है।"
      L_BANNER_SUB2="यह AGENTS.md, ज्ञान, कौशल और भूमिकाएं स्वतः उत्पन्न करेगी।"
      L_STEP_PREREQ="[1/3] पूर्वापेक्षाएं जांच रहे हैं..."
      L_STEP_TOOL="[2/3] AI एजेंट टूल चुनें"
      L_STEP_EXEC="[3/3] सेटअप चला रहे हैं..."
      L_HOW_TO_NOT_FOUND="HOW_TO_AGENTS.md नहीं मिला:"
      L_HOW_TO_FOUND="HOW_TO_AGENTS.md पाया गया"
      L_RUN_FROM_DIR="सुनिश्चित करें कि आप ai-agency डायरेक्टरी से चला रहे हैं,"
      L_OR_COPIED="या ऐसे प्रोजेक्ट से जिसमें HOW_TO_AGENTS.md कॉपी किया गया है।"
      L_CLI_DETECTED="CLI पाया गया"
      L_NO_TOOL="कोई AI CLI टूल नहीं मिला।"
      L_INSTALL_ONE="निम्न में से एक इंस्टॉल करें:"
      L_EXISTING_SETUP="मौजूदा सेटअप पाया गया:"
      L_AGENTS_FILES_FOUND="AGENTS.md फाइल(ें) मिलीं"
      L_AI_DIR_EXISTS=".ai-agents/ डायरेक्टरी मौजूद है"
      L_HOW_PROCEED="आप कैसे आगे बढ़ना चाहेंगे?"
      L_OPT_FULL="पूर्ण पुनर्निर्माण"
      L_OPT_FULL_DESC="(सब कुछ ओवरराइट)"
      L_OPT_INCREMENTAL="क्रमिक अपडेट"
      L_OPT_INCR_DESC="(केवल नई डायरेक्टरी, मौजूदा सुरक्षित)"
      L_OPT_SELECTIVE="चयनात्मक पुनर्निर्माण"
      L_OPT_SELECTIVE_DESC="(निर्माण/पुनर्निर्माण के लिए डायरेक्टरी चुनें)"
      L_SELECT_DIRS="डायरेक्टरी चुनें (अल्पविराम से अलग, या 'all'):"
      L_TAG_EXISTING="[मौजूदा]"
      L_TAG_NEW="[नया]"
      L_OPT_CANCEL="रद्द करें"
      L_SELECT_MODE="मोड चुनें"
      L_SELECTED="चयनित:"
      L_CANCELLED="सेटअप रद्द किया गया।"
      L_INVALID="अमान्य चयन। बाहर निकल रहे हैं।"
      L_MODE="मोड:"
      L_SELECT_TOOL="टूल चुनें"
      L_TOOL_LABEL="टूल:"
      L_LANG_LABEL="भाषा:"
      L_GUIDE_LABEL="गाइड:"
      L_MODE_LABEL="मोड:"
      L_PROMPT_LABEL="प्रॉम्प्ट:"
      L_PROCEED="जारी रखें? (Y/n):"
      L_STARTING="AI एजेंट शुरू हो रहा है..."
      L_INITIALIZING="आरंभ हो रहा है..."
      L_COMPLETED_IN="पूर्ण हुआ:"
      L_WORKING="कार्य जारी..."
      L_SETUP_ERROR="सेटअप में त्रुटि आई"
      L_TRY_AGAIN="पुनः प्रयास करें या मैन्युअली चलाएं:"
      L_SETUP_COMPLETE="सेटअप पूर्ण!"
      L_AGENTS_GENERATED="AGENTS.md फाइल(ें) उत्पन्न हुईं"
      L_CTX_CREATED=".ai-agents/ कॉन्टेक्स्ट डायरेक्टरी बनाई गई"
      L_NEXT_STEPS="अगले कदम -- एजेंट सत्र शुरू करें:"
      L_INTERACTIVE_MODE="इंटरैक्टिव मोड (एजेंट + टूल चुनें)"
      L_DIRECT_LAUNCH="Claude के साथ सीधे लॉन्च"
      L_MULTI_AGENT="मल्टी-एजेंट समानांतर सत्र (tmux)"
      L_LIST_AGENTS="सभी उपलब्ध एजेंट देखें"
      L_SEE_README="पूरी जानकारी के लिए README.md देखें।"
      ;;
    ar)
      L_BANNER_SUB1="يقوم هذا البرنامج بإعداد سياق وكلاء الذكاء الاصطناعي لمشروعك."
      L_BANNER_SUB2="سيقوم بإنشاء AGENTS.md والمعرفة والمهارات والأدوار تلقائياً."
      L_STEP_PREREQ="[1/3] التحقق من المتطلبات المسبقة..."
      L_STEP_TOOL="[2/3] اختيار أداة وكيل الذكاء الاصطناعي"
      L_STEP_EXEC="[3/3] تشغيل الإعداد..."
      L_HOW_TO_NOT_FOUND="لم يتم العثور على HOW_TO_AGENTS.md في"
      L_HOW_TO_FOUND="تم العثور على HOW_TO_AGENTS.md"
      L_RUN_FROM_DIR="تأكد من التشغيل من مجلد ai-agency،"
      L_OR_COPIED="أو من مشروع يحتوي على نسخة من HOW_TO_AGENTS.md."
      L_CLI_DETECTED="تم اكتشاف CLI"
      L_NO_TOOL="لم يتم العثور على أداة AI CLI."
      L_INSTALL_ONE="قم بتثبيت أحد التالي:"
      L_EXISTING_SETUP="تم اكتشاف إعداد موجود:"
      L_AGENTS_FILES_FOUND="ملف(ات) AGENTS.md موجودة"
      L_AI_DIR_EXISTS="مجلد .ai-agents/ موجود"
      L_HOW_PROCEED="كيف تريد المتابعة؟"
      L_OPT_FULL="إعادة إنشاء كاملة"
      L_OPT_FULL_DESC="(الكتابة فوق كل شيء)"
      L_OPT_INCREMENTAL="تحديث تدريجي"
      L_OPT_INCR_DESC="(مجلدات جديدة فقط، الحفاظ على الموجود)"
      L_OPT_SELECTIVE="إعادة إنشاء انتقائية"
      L_OPT_SELECTIVE_DESC="(اختر المجلدات للإنشاء أو إعادة الإنشاء)"
      L_SELECT_DIRS="اختر المجلدات (مفصولة بفاصلة، أو 'all'):"
      L_TAG_EXISTING="[موجود]"
      L_TAG_NEW="[جديد]"
      L_OPT_CANCEL="إلغاء"
      L_SELECT_MODE="اختر الوضع"
      L_SELECTED="تم الاختيار:"
      L_CANCELLED="تم إلغاء الإعداد."
      L_INVALID="اختيار غير صالح. الخروج."
      L_MODE="الوضع:"
      L_SELECT_TOOL="اختر الأداة"
      L_TOOL_LABEL="الأداة:"
      L_LANG_LABEL="اللغة:"
      L_GUIDE_LABEL="الدليل:"
      L_MODE_LABEL="الوضع:"
      L_PROMPT_LABEL="الأمر:"
      L_PROCEED="متابعة؟ (Y/n):"
      L_STARTING="جارٍ تشغيل وكيل الذكاء الاصطناعي..."
      L_INITIALIZING="جارٍ التهيئة..."
      L_COMPLETED_IN="اكتمل في"
      L_WORKING="جارٍ العمل..."
      L_SETUP_ERROR="حدث خطأ أثناء الإعداد"
      L_TRY_AGAIN="يمكنك المحاولة مرة أخرى أو التشغيل يدوياً:"
      L_SETUP_COMPLETE="اكتمل الإعداد!"
      L_AGENTS_GENERATED="ملف(ات) AGENTS.md تم إنشاؤها"
      L_CTX_CREATED="تم إنشاء مجلد .ai-agents/"
      L_NEXT_STEPS="الخطوات التالية -- تشغيل جلسة وكيل:"
      L_INTERACTIVE_MODE="الوضع التفاعلي (اختيار وكيل + أداة)"
      L_DIRECT_LAUNCH="تشغيل مباشر مع Claude"
      L_MULTI_AGENT="جلسات متعددة الوكلاء بالتوازي (tmux)"
      L_LIST_AGENTS="عرض جميع الوكلاء المتاحين"
      L_SEE_README="راجع README.md للتوثيق الكامل."
      ;;
    *)
      # Fallback to English
      set_ui_lang "en"
      ;;
  esac
}

# Initialize with English defaults (before language selection)
set_ui_lang "en"

# =============================================================================
# Banner
# =============================================================================
clear
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │                                                         │"
echo "  │               ai-agency  Setup                          │"
echo "  │                                                         │"
echo "  │     Automatic AGENTS.md + Context Generator             │"
echo "  │                                                         │"
echo "  └─────────────────────────────────────────────────────────┘"
echo -e "${NC}"

# =============================================================================
# Language Selection (first — enables i18n for all subsequent messages)
# =============================================================================
echo -e "  ${BOLD}Select language / 언어 선택 / 言語選択 / 选择语言${NC}"
echo ""
echo -e "  ${DIM}English is recommended for lower token cost and optimal AI performance.${NC}"
echo -e "  ${DIM}영어는 토큰 비용과 AI 성능 면에서 최적입니다.${NC}"
echo ""
echo -e "  ${DIM}However, choosing your own language makes the generated files and structure${NC}"
echo -e "  ${DIM}much easier for you to understand and maintain.${NC}"
echo -e "  ${DIM}하지만 본인의 언어를 선택하면 생성된 파일 및 구조를 더 쉽게 이해할 수 있는 장점이 있습니다.${NC}"
echo ""

# Language options with HOW_TO_AGENTS file mapping
declare -a LANG_NAMES=("English" "한국어 (Korean)" "日本語 (Japanese)" "中文 (Chinese)" "Español (Spanish)" "Français (French)" "Deutsch (German)" "Русский (Russian)" "हिन्दी (Hindi)" "العربية (Arabic)")
declare -a LANG_CODES=("en" "ko" "ja" "zh" "es" "fr" "de" "ru" "hi" "ar")
declare -a LANG_FILES=("HOW_TO_AGENTS.md" "" "" "" "" "" "" "" "" "")
declare -a LANG_PROMPTS_EN=(
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project."
  "HOW_TO_AGENTS.md를 읽고 지시에 맞게 AGENTS.md를 생성."
  "HOW_TO_AGENTS.mdを読み、このプロジェクトに合わせてAGENTS.mdを生成せよ。"
  "阅读 HOW_TO_AGENTS.md，为本项目生成定制的 AGENTS.md。"
  "Lee HOW_TO_AGENTS.md y genera AGENTS.md adaptado a este proyecto."
  "Lis HOW_TO_AGENTS.md et génère un AGENTS.md adapté à ce projet."
  "Lies HOW_TO_AGENTS.md und generiere eine auf dieses Projekt zugeschnittene AGENTS.md."
  "Прочитай HOW_TO_AGENTS.md и сгенерируй AGENTS.md, адаптированный для этого проекта."
  "HOW_TO_AGENTS.md पढ़ें और इस प्रोजेक्ट के लिए अनुकूलित AGENTS.md बनाएं।"
  "اقرأ HOW_TO_AGENTS.md وأنشئ AGENTS.md مخصصًا لهذا المشروع."
)

declare -a _lang_items=()
for i in "${!LANG_NAMES[@]}"; do
  if [[ $i -eq 0 ]]; then
    _lang_items+=("${LANG_NAMES[$i]}  ${DIM}(recommended)${NC}")
  else
    _lang_items+=("${LANG_NAMES[$i]}")
  fi
done

echo -e "  ${DIM}↑↓ navigate  Enter select${NC}"
echo ""
if cui_menu "${_lang_items[@]}"; then
  LANG_IDX=$CUI_RESULT
else
  echo -e "${RED}  Invalid selection. Exiting.${NC}"
  exit 1
fi
SELECTED_LANG="${LANG_NAMES[$LANG_IDX]}"
SELECTED_LANG_CODE="${LANG_CODES[$LANG_IDX]}"
SELECTED_PROMPT="${LANG_PROMPTS_EN[$LANG_IDX]}"

# Activate i18n for the selected language
set_ui_lang "$SELECTED_LANG_CODE"

# Determine which HOW_TO_AGENTS file to use
HOW_TO_FILE="${LANG_FILES[$LANG_IDX]}"
if [[ -z "$HOW_TO_FILE" || ! -f "$PROJECT_ROOT/$HOW_TO_FILE" ]]; then
  HOW_TO_FILE="HOW_TO_AGENTS.md"
fi

# For non-English languages without a native HOW_TO_AGENTS, add language instruction
LANG_SUFFIX=""
if [[ "$SELECTED_LANG_CODE" != "en" && "$HOW_TO_FILE" == "HOW_TO_AGENTS.md" && -z "${LANG_FILES[$LANG_IDX]}" ]]; then
  LANG_SUFFIX=" Write all generated files (AGENTS.md, context, skills, roles) in ${SELECTED_LANG}."
fi

# Save language preference for ai-agency.sh
mkdir -p "${HOME}/.config/ai-agency"
echo "$SELECTED_LANG_CODE" > "${HOME}/.config/ai-agency/lang"

echo -e "  ${DIM}→ ${L_SELECTED} ${SELECTED_LANG}${NC}"
echo ""

# Show translated banner subtitle now that language is set
echo -e "  ${DIM}${L_BANNER_SUB1}${NC}"
echo -e "  ${DIM}${L_BANNER_SUB2}${NC}"
echo ""

# =============================================================================
# Step 1: Check prerequisites
# =============================================================================
echo -e "${BOLD}${L_STEP_PREREQ}${NC}"
echo ""

# Check HOW_TO_AGENTS.md exists
if [[ ! -f "$PROJECT_ROOT/HOW_TO_AGENTS.md" ]]; then
  echo -e "${RED}  ✗ ${L_HOW_TO_NOT_FOUND} $PROJECT_ROOT${NC}"
  echo -e "  ${DIM}${L_RUN_FROM_DIR}${NC}"
  echo -e "  ${DIM}${L_OR_COPIED}${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓${NC} ${L_HOW_TO_FOUND}"

# Detect available tools
HAS_CLAUDE=false
HAS_CODEX=false
HAS_GEMINI=false

if command -v claude &>/dev/null; then
  HAS_CLAUDE=true
  echo -e "${GREEN}  ✓${NC} Claude Code ${L_CLI_DETECTED}"
fi
if command -v codex &>/dev/null; then
  HAS_CODEX=true
  echo -e "${GREEN}  ✓${NC} OpenAI Codex ${L_CLI_DETECTED}"
fi
if command -v gemini &>/dev/null; then
  HAS_GEMINI=true
  echo -e "${GREEN}  ✓${NC} Gemini ${L_CLI_DETECTED}"
fi

if ! $HAS_CLAUDE && ! $HAS_CODEX && ! $HAS_GEMINI; then
  echo ""
  echo -e "${RED}  ✗ ${L_NO_TOOL}${NC}"
  echo ""
  echo -e "  ${BOLD}${L_INSTALL_ONE}${NC}"
  echo -e "    Claude Code:  ${DIM}npm install -g @anthropic-ai/claude-code${NC}"
  echo -e "    Codex CLI:    ${DIM}npm install -g @openai/codex${NC}"
  echo -e "    Gemini CLI:   ${DIM}see https://ai.google.dev/gemini-api/docs/gemini-cli${NC}"
  echo ""
  exit 1
fi

# --- Check for existing setup ---
EXISTING_AGENTS=0
HAS_AI_AGENTS_DIR=false
SETUP_MODE="full"

EXISTING_AGENTS_LIST=""
if command -v find &>/dev/null; then
  EXISTING_AGENTS_LIST=$(find "$PROJECT_ROOT" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" 2>/dev/null | sort | while read -r f; do
    rel="${f#"$PROJECT_ROOT"/}"
    echo "$rel"
  done | tr '\n' ',' | sed 's/,$//')
  EXISTING_AGENTS=$(find "$PROJECT_ROOT" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ -d "$PROJECT_ROOT/.ai-agents" ]]; then
  HAS_AI_AGENTS_DIR=true
fi

if [[ "$EXISTING_AGENTS" -gt 0 ]] || $HAS_AI_AGENTS_DIR; then
  echo ""
  echo -e "  ${YELLOW}⚠  ${L_EXISTING_SETUP}${NC}"
  if [[ "$EXISTING_AGENTS" -gt 0 ]]; then
    echo -e "     ${DIM}${EXISTING_AGENTS} ${L_AGENTS_FILES_FOUND}${NC}"
  fi
  if $HAS_AI_AGENTS_DIR; then
    echo -e "     ${DIM}${L_AI_DIR_EXISTS}${NC}"
  fi
  echo ""
  echo -e "  ${BOLD}${L_HOW_PROCEED}${NC}"
  echo -e "  ${DIM}↑↓ navigate  Enter select${NC}"
  echo ""
  declare -a _mode_items=(
    "${L_OPT_FULL}  ${DIM}${L_OPT_FULL_DESC}${NC}"
    "${L_OPT_INCREMENTAL}  ${DIM}${L_OPT_INCR_DESC}${NC}"
    "${L_OPT_SELECTIVE}  ${DIM}${L_OPT_SELECTIVE_DESC}${NC}"
    "${L_OPT_CANCEL}"
  )
  if cui_menu "${_mode_items[@]}"; then
    case "$CUI_RESULT" in
      0) SETUP_MODE="full" ;;
      1) SETUP_MODE="incremental" ;;
      2)
        SETUP_MODE="selective"
        # Select search depth (1-3)
        echo ""
        echo -e "  ${BOLD}${L_SELECT_DEPTH}${NC}"
        _depth_items=(
          "Depth 1  ${DIM}(top-level only)${NC}"
          "Depth 2  ${DIM}(+1 sub-level)${NC}"
          "Depth 3  ${DIM}(+2 sub-levels)${NC}"
        )
        _search_depth=1
        if cui_menu "${_depth_items[@]}"; then
          _search_depth=$((CUI_RESULT + 1))
        fi

        # Build directory list for multi-select
        echo ""
        declare -a AGENT_DIR_LIST=()
        declare -a _dir_items=()
        _existing_dirs="|"
        # 1) Existing directories (have AGENTS.md)
        while IFS= read -r agent_file; do
          local_dir="${agent_file%/AGENTS.md}"
          local_rel="${local_dir#"$PROJECT_ROOT"}"
          local_rel="${local_rel#/}"
          [[ -z "$local_rel" ]] && local_rel="."
          AGENT_DIR_LIST+=("$local_rel")
          _existing_dirs="${_existing_dirs}${local_rel}|"
          _dir_items+=("${local_rel}  ${DIM}${L_TAG_EXISTING}${NC}")
        done < <(find "$PROJECT_ROOT" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" 2>/dev/null | sort)
        # 2) New directories (no AGENTS.md yet, up to selected depth)
        while IFS= read -r new_dir; do
          [[ -f "${new_dir}/AGENTS.md" ]] && continue
          local_rel="${new_dir#"$PROJECT_ROOT"}"
          local_rel="${local_rel#/}"
          [[ -z "$local_rel" ]] && continue
          [[ "$_existing_dirs" == *"|${local_rel}|"* ]] && continue
          AGENT_DIR_LIST+=("$local_rel")
          _dir_items+=("${local_rel}  ${CYAN}${L_TAG_NEW}${NC}")
        done < <(find "$PROJECT_ROOT" -mindepth 1 -maxdepth "$_search_depth" -type d \
          -not -name ".*" \
          -not -name "node_modules" \
          -not -path "*/.*/*" \
          -not -path "*/node_modules/*" \
          2>/dev/null | sort)

        echo -e "  ${BOLD}${L_SELECT_DIRS}${NC}"
        echo -e "  ${DIM}↑↓ navigate  Space toggle  a toggle-all  Enter confirm${NC}"
        echo ""
        SELECTED_DIRS=""
        if cui_multi_menu "${_dir_items[@]}"; then
          for idx in $CUI_MULTI_RESULT; do
            [[ -n "$SELECTED_DIRS" ]] && SELECTED_DIRS+=", "
            SELECTED_DIRS+="${AGENT_DIR_LIST[$idx]}"
          done
        fi

        if [[ -z "$SELECTED_DIRS" ]]; then
          echo -e "${RED}  ${L_INVALID}${NC}"
          exit 1
        fi
        echo -e "  ${DIM}→ ${SELECTED_DIRS}${NC}"
        ;;
      3)
        echo -e "  ${YELLOW}${L_CANCELLED}${NC}"
        exit 0
        ;;
    esac
  else
    echo -e "  ${YELLOW}${L_CANCELLED}${NC}"
    exit 0
  fi
  echo -e "  ${DIM}→ ${L_MODE} ${SETUP_MODE}${NC}"
fi

echo ""

# =============================================================================
# Step 2: Select AI tool
# =============================================================================
echo -e "${BOLD}${L_STEP_TOOL}${NC}"
echo ""

TOOL_OPTIONS=()
TOOL_COMMANDS=()
declare -a _tool_items=()

if $HAS_CLAUDE; then
  _tool_items+=("Claude Code  ${DIM}(claude --dangerously-skip-permissions)${NC}")
  TOOL_OPTIONS+=("claude")
  TOOL_COMMANDS+=("claude")
fi
if $HAS_CODEX; then
  _tool_items+=("Codex CLI    ${DIM}(codex --full-auto)${NC}")
  TOOL_OPTIONS+=("codex")
  TOOL_COMMANDS+=("codex")
fi
if $HAS_GEMINI; then
  _tool_items+=("Gemini CLI   ${DIM}(gemini)${NC}")
  TOOL_OPTIONS+=("gemini")
  TOOL_COMMANDS+=("gemini")
fi

echo -e "  ${DIM}↑↓ navigate  Enter select${NC}"
echo ""
if cui_menu "${_tool_items[@]}"; then
  SELECTED_TOOL="${TOOL_OPTIONS[$CUI_RESULT]}"
  SELECTED_CMD="${TOOL_COMMANDS[$CUI_RESULT]}"
else
  echo -e "${RED}  ${L_INVALID}${NC}"
  exit 1
fi
echo -e "  ${DIM}→ ${L_SELECTED} ${SELECTED_TOOL}${NC}"
echo ""

# =============================================================================
# Step 3: Execute setup
# =============================================================================
echo -e "${BOLD}${L_STEP_EXEC}${NC}"
echo ""

# Build the full prompt — replace HOW_TO_AGENTS.md reference with actual file path
FULL_PROMPT="${SELECTED_PROMPT//HOW_TO_AGENTS.md/$HOW_TO_FILE}${LANG_SUFFIX}"

# Append pre-classification results if available
CLASSIFICATION_FILE="${PROJECT_ROOT}/.ai-agents/.classification.tsv"
if [[ -f "$CLASSIFICATION_FILE" ]]; then
  CLASSIFICATION_DATA=$(grep -v '^#' "$CLASSIFICATION_FILE" 2>/dev/null | head -50 || true)
  if [[ -n "$CLASSIFICATION_DATA" ]]; then
    FULL_PROMPT="${FULL_PROMPT} PRE-CLASSIFICATION: The following directories have been pre-classified by the classify-dirs engine. Use these results as a starting point — verify and adjust if needed, but do not re-classify from scratch unless a classification seems wrong: ${CLASSIFICATION_DATA}"
  fi
fi

# Append mode-specific instructions
if [[ "$SETUP_MODE" == "full" ]]; then
  FULL_PROMPT="${FULL_PROMPT} IMPORTANT: This is a full regeneration. Delete ALL existing AGENTS.md files and the entire .ai-agents/ directory (context, roles, skills) first, then regenerate everything from scratch following the full classification and generation rules."
elif [[ "$SETUP_MODE" == "incremental" ]]; then
  FULL_PROMPT="${FULL_PROMPT} IMPORTANT: This is an INCREMENTAL update — NOT a full regeneration. The following AGENTS.md files already exist and MUST NOT be modified or overwritten: [${EXISTING_AGENTS_LIST}]. Skip Steps 1-2 (scan/classify) for directories that already have AGENTS.md. Only scan and classify directories that do NOT have AGENTS.md yet. Only generate new AGENTS.md files for those new directories. Only create new .ai-agents/context/ files that do not yet exist. If the root AGENTS.md agent tree section needs updating to include new agents, update ONLY that section. Preserve all other existing files and content unchanged. If there are no new directories without AGENTS.md, report that no changes are needed and exit."
elif [[ "$SETUP_MODE" == "selective" ]]; then
  FULL_PROMPT="${FULL_PROMPT} IMPORTANT: This is a selective generation/regeneration. ONLY generate or regenerate AGENTS.md and .ai-agents/context/ files for the following directories: ${SELECTED_DIRS}. For directories that already have AGENTS.md, delete the existing files first then regenerate from scratch. For directories without AGENTS.md, generate new ones. Follow the full classification and generation rules. Do NOT touch any other directories — leave all other AGENTS.md and .ai-agents/ files completely unchanged."
fi

# Show what will be executed
echo -e "  ${DIM}${L_TOOL_LABEL}     ${SELECTED_TOOL}${NC}"
echo -e "  ${DIM}${L_LANG_LABEL} ${SELECTED_LANG}${NC}"
echo -e "  ${DIM}${L_GUIDE_LABEL}    ${HOW_TO_FILE}${NC}"
echo -e "  ${DIM}${L_MODE_LABEL}     ${SETUP_MODE}${NC}"
echo -e "  ${DIM}${L_PROMPT_LABEL}   ${FULL_PROMPT}${NC}"
echo ""

# Confirm before execution
echo -ne "  ${BOLD}${L_PROCEED}${NC} "
read -r confirm </dev/tty
confirm="${confirm:-Y}"

if [[ "$confirm" != "Y" && "$confirm" != "y" && "$confirm" != "yes" ]]; then
  echo -e "  ${YELLOW}${L_CANCELLED}${NC}"
  exit 0
fi

echo ""
echo -e "  ${CYAN}${BOLD}${L_STARTING}${NC}"
echo ""

# Execute the selected tool with progress display
cd "$PROJECT_ROOT"

# --- Progress display helpers ---
SPINNER_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

format_elapsed() {
  local elapsed=$1
  local mins=$(( elapsed / 60 ))
  local secs=$(( elapsed % 60 ))
  if [[ $mins -gt 0 ]]; then
    printf '%dm %ds' "$mins" "$secs"
  else
    printf '%ds' "$secs"
  fi
}

# Run claude with stream-json and show real-time progress
run_claude_with_progress() {
  local prompt="$1"
  local stream_file
  stream_file=$(mktemp /tmp/ai-setup-stream-XXXXXX)

  # Run claude with stream-json in background
  local err_file="${stream_file}.err"
  claude -p --dangerously-skip-permissions --model claude-opus-4-6 \
    --verbose --output-format stream-json "$prompt" > "$stream_file" 2>"$err_file" &
  local pid=$!

  local start=$SECONDS
  local spin_idx=0
  local last_pos=0
  local status_msg="$L_INITIALIZING"
  local files_read=0
  local files_written=0

  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( SECONDS - start ))
    local time_str
    time_str=$(format_elapsed "$elapsed")

    # Parse new lines from stream for progress events
    local cur_size
    cur_size=$(wc -c < "$stream_file" 2>/dev/null | tr -d ' ')

    if [[ "${cur_size:-0}" -gt "$last_pos" ]]; then
      # Read new content and extract tool use info
      local new_data
      new_data=$(dd if="$stream_file" bs=1 skip="$last_pos" count=$(( cur_size - last_pos )) 2>/dev/null)
      last_pos=$cur_size

      # Check for tool_use events — extract tool name and file path
      local tool_name=""
      tool_name=$(echo "$new_data" | grep -o '"name":"[^"]*"' | tail -1 | cut -d'"' -f4 2>/dev/null || true)

      if [[ -n "$tool_name" ]]; then
        local file_path=""
        file_path=$(echo "$new_data" | grep -o '"file_path":"[^"]*"' | tail -1 | cut -d'"' -f4 2>/dev/null || true)
        local short_file="${file_path##*/}"

        case "$tool_name" in
          Read)   files_read=$((files_read + 1));    status_msg="Reading ${short_file:-file}" ;;
          Write)  files_written=$((files_written + 1)); status_msg="Writing ${short_file:-file}" ;;
          Edit)   status_msg="Editing ${short_file:-file}" ;;
          Bash)
            local cmd_hint=""
            cmd_hint=$(echo "$new_data" | grep -o '"command":"[^"]*"' | tail -1 | cut -d'"' -f4 | head -c 40 2>/dev/null || true)
            status_msg="Running: ${cmd_hint:-command}"
            ;;
          Glob)   status_msg="Searching files" ;;
          Grep)   status_msg="Searching content" ;;
          *)      status_msg="${tool_name}" ;;
        esac
      fi
    fi

    # Build stats suffix
    local stats=""
    if [[ $files_read -gt 0 || $files_written -gt 0 ]]; then
      stats=" ${DIM}(read:${files_read} write:${files_written})${NC}"
    fi

    local char="${SPINNER_CHARS:spin_idx:1}"
    printf '\r\033[K  %s  \033[2m[%s]\033[0m %s%b' "$char" "$time_str" "$status_msg" "$stats"
    spin_idx=$(( (spin_idx + 1) % ${#SPINNER_CHARS} ))
    sleep 0.3
  done

  wait "$pid"
  local exit_code=$?
  local elapsed=$(( SECONDS - start ))
  local time_str
  time_str=$(format_elapsed "$elapsed")
  printf '\r\033[K'

  if [[ $exit_code -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} ${L_COMPLETED_IN} ${time_str} ${DIM}(read:${files_read} write:${files_written})${NC}"
  else
    # Show captured stderr so the user can see why claude failed
    if [[ -s "$err_file" ]]; then
      echo ""
      cat "$err_file"
    fi
  fi

  rm -f "$stream_file" "$err_file"
  return $exit_code
}

# Run non-claude tools with a simple elapsed-time spinner
run_with_spinner() {
  local cmd="$1"
  local output_file
  output_file=$(mktemp /tmp/ai-setup-out-XXXXXX)

  eval "$cmd" > "$output_file" 2>&1 &
  local pid=$!

  local start=$SECONDS
  local spin_idx=0

  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( SECONDS - start ))
    local time_str
    time_str=$(format_elapsed "$elapsed")

    local char="${SPINNER_CHARS:spin_idx:1}"
    printf '\r\033[K  %s  \033[2m[%s]\033[0m %s' "$char" "$time_str" "$L_WORKING"
    spin_idx=$(( (spin_idx + 1) % ${#SPINNER_CHARS} ))
    sleep 0.5
  done

  wait "$pid"
  local exit_code=$?
  local elapsed=$(( SECONDS - start ))
  local time_str
  time_str=$(format_elapsed "$elapsed")
  printf '\r\033[K'

  if [[ $exit_code -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} ${L_COMPLETED_IN} ${time_str}"
  fi

  cat "$output_file"
  rm -f "$output_file"
  return $exit_code
}

EXIT_CODE=0
case "$SELECTED_TOOL" in
  claude)
    run_claude_with_progress "$FULL_PROMPT" || EXIT_CODE=$?
    ;;
  codex)
    run_with_spinner "codex --full-auto $(printf '%q' "$FULL_PROMPT")" || EXIT_CODE=$?
    ;;
  gemini)
    run_with_spinner "gemini $(printf '%q' "$FULL_PROMPT")" || EXIT_CODE=$?
    ;;
esac

echo ""

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "${RED}${BOLD}  ✗ ${L_SETUP_ERROR} (exit code: $EXIT_CODE)${NC}"
  echo ""
  echo -e "  ${DIM}${L_TRY_AGAIN}${NC}"
  case "$SELECTED_TOOL" in
    claude)
      echo -e "  ${DIM}  claude -p --dangerously-skip-permissions --verbose --model claude-opus-4-6 \"${FULL_PROMPT}\"${NC}"
      ;;
    codex)
      echo -e "  ${DIM}  codex --full-auto \"${FULL_PROMPT}\"${NC}"
      ;;
    gemini)
      echo -e "  ${DIM}  gemini \"${FULL_PROMPT}\"${NC}"
      ;;
  esac
  exit 1
fi

# =============================================================================
# Done — show next steps
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}"
echo ""
echo "  ✓  ${L_SETUP_COMPLETE}"
echo ""
echo -e "${NC}"

# Check what was generated
AGENT_COUNT=0
if command -v find &>/dev/null; then
  AGENT_COUNT=$(find "$PROJECT_ROOT" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ "$AGENT_COUNT" -gt 0 ]]; then
  echo -e "  ${GREEN}✓${NC} ${AGENT_COUNT} ${L_AGENTS_GENERATED}"
fi

if [[ -d "$PROJECT_ROOT/.ai-agents" ]]; then
  echo -e "  ${GREEN}✓${NC} ${L_CTX_CREATED}"
fi

# --- Auto-run sync-ai-rules.sh to generate vendor bootstrap files ---
SYNC_SCRIPT="${SCRIPT_DIR}/scripts/sync-ai-rules.sh"
if [[ -f "$SYNC_SCRIPT" && "$AGENT_COUNT" -gt 0 ]]; then
  echo ""
  bash "$SYNC_SCRIPT"
fi

# --- Auto-run validate.sh to check generated files ---
VALIDATE_SCRIPT="${SCRIPT_DIR}/scripts/validate.sh"
if [[ -f "$VALIDATE_SCRIPT" && "$AGENT_COUNT" -gt 0 ]]; then
  echo ""
  echo -e "  ${DIM}Validating generated files...${NC}"
  bash "$VALIDATE_SCRIPT" "$PROJECT_ROOT" 2>&1 || true
fi

echo ""
echo -e "  ${BOLD}${L_NEXT_STEPS}${NC}"
echo ""

# Use global CLI command when invoked via 'ai-agency init', local script otherwise
if [[ -n "${AI_AGENCY_CLI:-}" ]]; then
  AGENCY_CMD="ai-agency"
else
  AGENCY_CMD="./ai-agency.sh"
fi

echo -e "    ${CYAN}# ${L_INTERACTIVE_MODE}${NC}"
echo -e "    ${BOLD}${AGENCY_CMD}${NC}"
echo ""
echo -e "    ${CYAN}# ${L_DIRECT_LAUNCH}${NC}"
echo -e "    ${BOLD}${AGENCY_CMD} --tool claude${NC}"
echo ""
echo -e "    ${CYAN}# ${L_LIST_AGENTS}${NC}"
echo -e "    ${BOLD}${AGENCY_CMD} --list${NC}"
echo ""
echo -e "  ${DIM}${L_SEE_README}${NC}"
echo ""

# --- Cleanup installer artifacts ---
# Only remove if this is a target project (not the ai-agency source repo itself).
# The source repo has bin/ and install.sh which a target project would not.
if [[ ! -f "$PROJECT_ROOT/install.sh" && ! -d "$PROJECT_ROOT/bin" ]]; then
  if [[ -f "$PROJECT_ROOT/setup.sh" ]]; then
    rm -f "$PROJECT_ROOT/setup.sh"
  fi
  if [[ -f "$PROJECT_ROOT/HOW_TO_AGENTS.md" ]]; then
    rm -f "$PROJECT_ROOT/HOW_TO_AGENTS.md"
  fi
fi
