#!/usr/bin/env bash
# PM agent pane: emits task splits, writes to shared task-board.
set -euo pipefail
BOARD="${BOARD:-/tmp/ai-agency-demo-board.md}"
B=$'\033[1m'; Y=$'\033[33m'; M=$'\033[35m'; D=$'\033[2m'; N=$'\033[0m'

printf '%b\n' "${B}pm${N}  ${D}root coordinator · AGENTS.md loaded (241 tok)${N}"
printf '\n'
sleep 1.5

printf '%b\n' "${Y}task${N} add rate-limit to POST /orders"
echo "[pm] task: add rate-limit to POST /orders" >> "$BOARD"
sleep 1.2

printf '%b\n' "${Y}split${N} → ${M}backend${N}  (middleware)"
echo "[pm] → backend: implement middleware" >> "$BOARD"
sleep 0.8

printf '%b\n' "${Y}split${N} → ${M}frontend${N} (429 handler)"
echo "[pm] → frontend: handle 429 on checkout" >> "$BOARD"
sleep 4

printf '%b\n' "${Y}unblock${N} → ${M}infra${N}    (REDIS_URL)"
echo "[pm] → infra: expose REDIS_URL" >> "$BOARD"
sleep 3

printf '%b\n' "${B}✓ all closed.${N} 4 handoffs via coordination/*.md"
echo "[pm] all closed" >> "$BOARD"
sleep 999
