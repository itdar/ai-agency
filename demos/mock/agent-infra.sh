#!/usr/bin/env bash
set -euo pipefail
BOARD="${BOARD:-/tmp/ai-agency-demo-board.md}"
B=$'\033[1m'; C=$'\033[36m'; G=$'\033[32m'; D=$'\033[2m'; N=$'\033[0m'

printf '%b\n' "${B}infra${N}  ${D}infra/ · AGENTS.md loaded (218 tok)${N}"
printf '\n'
# Watch the board, react to unblock request
sleep 8

printf '%b\n' "${C}picked up${N} REDIS_URL unblock"
sleep 1.2
printf '%b\n' "  terraform plan  ${D}(1 change)${N}"
sleep 1.5
printf '%b\n' "  terraform apply ${G}✓${N}"
echo "[infra] terraform applied, REDIS_URL exposed" >> "$BOARD"
sleep 999
