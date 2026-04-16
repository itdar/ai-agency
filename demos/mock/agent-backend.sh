#!/usr/bin/env bash
set -euo pipefail
BOARD="${BOARD:-/tmp/ai-agency-demo-board.md}"
B=$'\033[1m'; C=$'\033[36m'; G=$'\033[32m'; R=$'\033[31m'; D=$'\033[2m'; N=$'\033[0m'

printf '%b\n' "${B}backend${N}  ${D}api/ · AGENTS.md loaded (287 tok)${N}"
printf '\n'
sleep 3

printf '%b\n' "${C}watch${N} task-board.md"
sleep 0.8
printf '%b\n' "${C}claim${N} middleware  ${D}eta 15m${N}"
echo "[backend] claimed middleware" >> "$BOARD"
sleep 2

printf '%b\n' "  editing src/middleware/rate-limit.ts"
sleep 2
printf '%b\n' "  ${R}blocked${N}: need REDIS_URL"
echo "[backend] blocked: REDIS_URL" >> "$BOARD"
sleep 4

printf '%b\n' "  ${G}✓${N} REDIS_URL available — resuming"
sleep 1.5
printf '%b\n' "  ${G}✓${N} tests pass (14/14)"
sleep 0.8
printf '%b\n' "${C}done${N}  middleware"
echo "[backend] done" >> "$BOARD"
sleep 999
