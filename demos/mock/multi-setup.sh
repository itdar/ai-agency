#!/usr/bin/env bash
# Launches a 4-pane tmux session showing file-based multi-agent coordination.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION="${SESSION:-ai-agency-demo}"
BOARD="${BOARD:-/tmp/ai-agency-demo-board.md}"

: > "$BOARD"
export BOARD

tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session  -d -s "$SESSION" -x 200 -y 50
tmux set -t "$SESSION" -g pane-border-status top
tmux set -t "$SESSION" -g pane-border-format ' #{pane_title} '

# Layout: 2x2 grid. 0.0 TL | 0.1 TR | 0.2 BL | 0.3 BR
tmux split-window -h -t "${SESSION}:0.0"
tmux split-window -v -t "${SESSION}:0.0"
tmux split-window -v -t "${SESSION}:0.2"
tmux select-layout -t "$SESSION" tiled

tmux select-pane  -t "${SESSION}:0.0" -T ' pm '
tmux select-pane  -t "${SESSION}:0.1" -T ' backend '
tmux select-pane  -t "${SESSION}:0.2" -T ' frontend '
tmux select-pane  -t "${SESSION}:0.3" -T ' .ai-agents/coordination/task-board.md '

export BOARD
tmux send-keys -t "${SESSION}:0.0" "clear; exec bash '$HERE/agent-pm.sh'" Enter
tmux send-keys -t "${SESSION}:0.1" "clear; exec bash '$HERE/agent-backend.sh'" Enter
tmux send-keys -t "${SESSION}:0.2" "clear; exec bash '$HERE/agent-frontend.sh'" Enter
tmux send-keys -t "${SESSION}:0.3" "clear; bash '$HERE/agent-infra.sh' & exec tail -f '$BOARD'" Enter

exec tmux attach -t "$SESSION"
