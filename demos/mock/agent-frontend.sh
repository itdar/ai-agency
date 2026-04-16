#!/usr/bin/env bash
set -euo pipefail
BOARD="${BOARD:-/tmp/ai-agency-demo-board.md}"
B=$'\033[1m'; C=$'\033[36m'; G=$'\033[32m'; D=$'\033[2m'; N=$'\033[0m'

printf '%b\n' "${B}frontend${N}  ${D}web/ · AGENTS.md loaded (262 tok)${N}"
printf '\n'
sleep 3.2

printf '%b\n' "${C}claim${N} 429 handler  ${D}eta 10m${N}"
echo "[frontend] claimed 429 handler" >> "$BOARD"
sleep 1.5

printf '%b\n' "  editing app/checkout/retry.tsx"
sleep 2
printf '%b\n' "  adding toast + backoff"
sleep 2
printf '%b\n' "  ${G}✓${N} type-check, lint clean"
sleep 0.8
printf '%b\n' "${C}done${N}  (see messages.md#14)"
echo "[frontend] done" >> "$BOARD"
sleep 999
